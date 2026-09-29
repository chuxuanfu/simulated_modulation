#!/usr/bin/env python3
"""Independent NumPy mathematical checks. DOES NOT execute MATLAB or toolboxes."""
from pathlib import Path
import json, math, struct
import numpy as np
ROOT=Path(__file__).resolve().parents[1]

def rrc(beta,span,sps):
    t=np.arange(-span*sps//2,span*sps//2+1)/sps
    h=[]
    for a in t:
        if abs(a)<1e-12: z=1+beta*(4/np.pi-1)
        elif abs(abs(a)-1/(4*beta))<1e-10:
            z=beta/np.sqrt(2)*((1+2/np.pi)*np.sin(np.pi/(4*beta))+(1-2/np.pi)*np.cos(np.pi/(4*beta)))
        else: z=(np.sin(np.pi*a*(1-beta))+4*beta*a*np.cos(np.pi*a*(1+beta)))/(np.pi*a*(1-(4*beta*a)**2))
        h.append(z)
    h=np.array(h); return h/np.linalg.norm(h)

def crc(data):
    register=0
    for byte in data:
        register ^= int(byte)
        for _ in range(8): register=(register>>1)^(0x8408 if register&1 else 0)
    return bytes([register&255, register>>8])

def main():
    rng=np.random.default_rng(42); results=[]
    def check(name,value,limit,condition):
        assert condition, (name,value,limit)
        results.append(dict(name=name,status='PASS',observed=float(value),criterion=limit))
    # Independent geometry: labels are Gray codes of physical coordinate indices.
    for M in (16,64,256):
        side=int(np.sqrt(M)); coordinates=np.arange(side)*2-(side-1)
        gray=np.arange(side)^(np.arange(side)>>1)
        assert all(int(a^b).bit_count()==1 for a,b in zip(gray[:-1],gray[1:]))
        a=(coordinates[:,None]+1j*coordinates[None,:]).ravel()/np.sqrt(2*(M-1)/3)
        energy=np.mean(abs(a)**2); check(f'{M}QAM full-alphabet unit energy',energy,'abs(E-1)<1e-12',abs(energy-1)<1e-12)
    h=rrc(.35,12,8); s=(2*rng.integers(0,4,4096)-3 + 1j*(2*rng.integers(0,4,4096)-3))/np.sqrt(10)
    u=np.zeros((len(s)-1)*8+1,complex); u[::8]=s
    x=np.convolve(u,h); z=np.convolve(x,h)[len(h)-1::8][:len(s)]
    evm=100*np.linalg.norm(z-s)/np.linalg.norm(s)
    check('RRC matched-filter residual EVM',evm,'<1 percent',evm<1)
    nfft=256; ncp=32; active=np.r_[np.arange(-100,0),np.arange(1,101)]
    S=(2*rng.integers(0,2,(200,100))-1+1j*(2*rng.integers(0,2,(200,100))-1))/np.sqrt(2)
    cp_iq=None
    for spread in (False,True):
        grid=np.zeros((nfft,100),complex)
        grid[active+nfft//2]=np.fft.fft(S,axis=0)/np.sqrt(200) if spread else S
        time=np.fft.ifft(np.fft.ifftshift(grid,axes=0),axis=0)*np.sqrt(nfft)
        cp=np.vstack([time[-ncp:],time]); x=cp.ravel(order='F')
        rx=x.reshape((nfft+ncp,-1),order='F')[ncp:]
        rec=np.fft.fftshift(np.fft.fft(rx,axis=0)/np.sqrt(nfft),axes=0)[active+nfft//2]
        if spread: rec=np.fft.ifft(rec,axis=0)*np.sqrt(200)
        error=np.max(abs(rec-S)); check(f'OFDM inversion spread={spread}',error,'<1e-12',error<1e-12)
        if not spread: cp_iq=x
    for delay in (8,48):
        taps=np.zeros(delay+1,complex); taps[0]=1; taps[-1]=.35*np.exp(.5j)
        y=np.convolve(cp_iq,taps)[:len(cp_iq)]
        rx=y.reshape((nfft+ncp,-1),order='F')[ncp:]
        rec=np.fft.fftshift(np.fft.fft(rx,axis=0)/np.sqrt(nfft),axes=0)[active+nfft//2]
        H=np.fft.fftshift(np.fft.fft(taps,nfft))[active+nfft//2]
        rec=rec/H[:,None]; e=100*np.linalg.norm(rec[:,1:]-S[:,1:])/np.linalg.norm(S[:,1:])
        check(f'CP=32, path delay={delay} samples',e,'<1e-9%' if delay==8 else '>1%',e<1e-9 if delay==8 else e>1)
    chips=1-2*rng.integers(0,2,8192); spc=8; pulse=np.sin(np.pi*np.arange(2*spc+1)/(2*spc))
    i=np.zeros((len(chips)//2-1)*2*spc+1); q=i.copy(); i[::2*spc]=chips[::2]; q[::2*spc]=chips[1::2]
    i=np.convolve(i,pulse); q=np.convolve(q,pulse)
    oq=np.r_[i,np.zeros(spc)]+1j*np.r_[np.zeros(spc),q]
    err=np.max(abs(abs(oq[2*spc:-2*spc])-1)); check('Half-sine OQPSK envelope',err,'<1e-12',err<1e-12)
    fcs=crc(b'123456789'); check('CRC-16/KERMIT known answer',int.from_bytes(fcs,'little'),'0x2189',fcs==bytes.fromhex('8921'))
    residue=crc(b'123456789'+fcs); check('CRC complete-frame residue',int.from_bytes(residue,'little'),'0',residue==b'\0\0')
    N=400000; b=rng.integers(0,2,N); s=1-2*b; eb=0
    y=s+(rng.normal(size=N)+1j*rng.normal(size=N))/np.sqrt(2)
    ber=np.mean((y.real<0)!=b); theory=.5*math.erfc(1)
    check('BPSK Eb/N0=0dB BER',ber,'within 0.003 of 0.0786496',abs(ber-theory)<.003)
    fs=1e6; n=np.arange(8192); tone=np.exp(2j*np.pi*125e3*n/fs)
    win=.5-.5*np.cos(2*np.pi*np.arange(1024)/1024)
    psd=np.mean([abs(np.fft.fft(tone[k:k+1024]*win))**2/(fs*np.sum(win**2)) for k in range(0,len(tone)-1024+1,512)],axis=0)
    integ=np.sum(psd)*fs/1024; check('Welch power integration',integ,'abs(P-1)<1e-10',abs(integ-1)<1e-10)
    fixture=ROOT/'resources'/'fixtures'; fixture.mkdir(exist_ok=True)
    known=np.array([.125+.25j,-.5+.75j,.8-.1j]); inter=np.column_stack([known.real,known.imag]).ravel()
    (fixture/'known_iq.cf32').write_bytes(inter.astype('<f4').tobytes())
    integer=np.rint(inter*32767).astype('<i2'); (fixture/'known_iq.ci16').write_bytes(integer.tobytes())
    rec=integer.astype(float)/32767; rec=rec[::2]+1j*rec[1::2]; error=np.max(abs(rec-known))
    check('Int16 IQ quantization error',error,'<=sqrt(2)/32767',error<=np.sqrt(2)/32767)
    (fixture/'known_iq.json').write_text(json.dumps(dict(SampleRateHz=1e6,NumSamples=3,I=known.real.tolist(),Q=known.imag.tolist(),source='Independent Python format fixture, not a protocol waveform'),indent=2))
    report=dict(execution='Python/NumPy reference implementation; NOT MATLAB execution',numpy_version=np.__version__,tests=results,passed=len(results),failed=0)
    (ROOT/'reports'/'reference_checks.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
    return S,oq,h

if __name__=='__main__': main()
