#!/usr/bin/env python3
"""Original reference illustrations: Python/NumPy, not MATLAB execution."""
from pathlib import Path
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from reference_checks import rrc
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'resources'/'reference_figures'; OUT.mkdir(exist_ok=True)
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False,'figure.facecolor':'white','axes.grid':True,'grid.alpha':.18,'axes.titleweight':'bold','axes.prop_cycle':plt.cycler(color=['#00878d','#e77636','#426581','#9b67a8'])})
rng=np.random.default_rng(1729)
def save(fig,name,title):
    fig.suptitle(title,fontsize=18,fontweight='bold',x=.07,ha='left')
    fig.text(.07,.02,'Independent Python / NumPy reference illustration • Not a MATLAB or protocol-toolbox test result',fontsize=9,color='#536773')
    fig.tight_layout(rect=[.03,.05,.99,.93]); fig.savefig(OUT/name,dpi=150); plt.close(fig)
fig,axes=plt.subplots(1,3,figsize=(13,4.8))
s=(2*rng.integers(0,4,2000)-3+1j*(2*rng.integers(0,4,2000)-3))/np.sqrt(10)
h=rrc(.35,12,8); u=np.zeros((len(s)-1)*8+1,complex); u[::8]=s
x=np.convolve(u,h); z=np.convolve(x,h)[len(h)-1::8][:len(s)]
for ax,v,title in zip(axes,[s,x[:8000],z],['Mapped symbols','Pulse-shaped time samples','Matched filter + correct timing']):
    ax.scatter(v.real,v.imag,s=3,alpha=.4); ax.set_aspect('equal'); ax.set_title(title,fontsize=12); ax.set_xlabel('I'); ax.set_ylabel('Q')
save(fig,'01_constellation.png','01  •  A waveform is more than its constellation')
fig,axes=plt.subplots(1,2,figsize=(12,5))
for alpha in [.1,.35,.8]:
    pulse=rrc(alpha,20,16); f=np.fft.fftshift(np.fft.fftfreq(16384,1/16)); H=abs(np.fft.fftshift(np.fft.fft(pulse,16384)))**2
    axes[0].plot(np.arange(-160,161)/16,pulse,label=f'rolloff = {alpha}')
    axes[1].plot(f,10*np.log10(np.maximum(H/H.max(),1e-9)),label=f'rolloff = {alpha}')
axes[0].set(xlim=(-5,5),xlabel='Time / symbol period',ylabel='Pulse amplitude',title='Long tails at low rolloff')
axes[1].set(xlim=(-1.3,1.3),ylim=(-70,3),xlabel='Frequency / symbol rate',ylabel='Relative power (dB)',title='Bandwidth versus transition sharpness')
for ax in axes: ax.legend(fontsize=9)
save(fig,'02_rrc.png','02  •  Pulse shape trades bandwidth for time-domain extent')
fig,axes=plt.subplots(1,2,figsize=(12,5)); eb=np.linspace(0,12,100); pb=np.array([.5*math.erfc(math.sqrt(10**(e/10))) for e in eb])
axes[0].semilogy(eb,pb,label='BPSK = Gray QPSK, uncoded AWGN'); axes[0].set(xlabel='Eb/N0 (dB)',ylabel='Theoretical BER',ylim=(1e-8,.2),title='A benchmark for noise scaling'); axes[0].legend(fontsize=9)
noisy=s+np.sqrt(.01/2)*(rng.normal(size=s.shape)+1j*rng.normal(size=s.shape)); axes[1].scatter(noisy.real,noisy.imag,s=3,alpha=.25)
axes[1].set(xlabel='I',ylabel='Q',title='16QAM with Es/N0 = 20 dB'); axes[1].set_aspect('equal')
save(fig,'03_noise.png','03  •  Noise spreads symbols and creates decision errors')
fig,axes=plt.subplots(2,2,figsize=(12,7)); fs=8e6; sps=8
bits=rng.integers(0,2,256); t=np.arange(-16,17)/sps; gauss=np.exp(-2*(np.pi*.5*t)**2/np.log(2)); gauss/=gauss.sum()
freq=250e3*np.convolve(np.repeat(2*bits-1,sps),gauss,mode='same'); gfsk=np.exp(2j*np.pi*np.cumsum(freq)/fs)
axes[0,0].plot(np.arange(240)/fs*1e6,freq[:240]/1e3); axes[0,0].set(xlabel='Time (us)',ylabel='Frequency (kHz)',title='GFSK: smooth frequency transitions')
axes[1,0].plot(np.arange(240)/fs*1e6,abs(gfsk[:240])); axes[1,0].set(xlabel='Time (us)',ylabel='Envelope',ylim=(0,1.2),title='Constant envelope')
N=256; grid=np.zeros((N,30),complex); grid[np.r_[np.arange(28,128),np.arange(129,229)]]=(2*rng.integers(0,2,(200,30))-1+1j*(2*rng.integers(0,2,(200,30))-1))/np.sqrt(2)
ofdm=np.fft.ifft(np.fft.ifftshift(grid,axes=0),axis=0)*np.sqrt(N)
axes[0,1].imshow(abs(grid),aspect='auto',origin='lower',cmap='viridis'); axes[0,1].set(xlabel='OFDM symbol',ylabel='FFT bin',title='OFDM: many active subcarriers')
axes[1,1].plot(abs(ofdm[:,0])); axes[1,1].set(xlabel='Time sample',ylabel='Envelope',title='Peaks from carrier addition')
save(fig,'04_waveform_families.png','04  •  Constant-envelope and multicarrier waveforms')
print('Built 4 reference PNG figures.')
