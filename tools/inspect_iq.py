#!/usr/bin/env python3
"""Inspect one exported IQ file. Standard library only; never transmits."""
import argparse, hashlib, json, math, struct
from pathlib import Path

def inspect(path, datatype, sample_rate):
    fmt, scale, width = ('<ff', 1.0, 8) if datatype == 'cf32_le' else ('<hh', 32767.0, 4)
    size = path.stat().st_size
    if size == 0 or size % width:
        raise ValueError('Empty/truncated file: byte count is not a whole complex sample.')
    n = size // width; energy = 0.; peak = 0.; mean_i = 0.; mean_q = 0.; h = hashlib.sha256()
    with path.open('rb') as f:
        while chunk := f.read(width * 65536):
            h.update(chunk)
            for i,q in struct.iter_unpack(fmt, chunk):
                i /= scale; q /= scale
                if not (math.isfinite(i) and math.isfinite(q)):
                    raise ValueError('Non-finite IQ sample.')
                p = i*i+q*q; energy += p; peak = max(peak,p); mean_i += i; mean_q += q
    return dict(path=str(path), datatype=datatype, bytes=size, complex_samples=n,
                sample_rate_hz=sample_rate, duration_seconds=n/sample_rate,
                rms=math.sqrt(energy/n), peak_magnitude=math.sqrt(peak),
                papr_db=10*math.log10(peak/(energy/n)) if energy else None,
                mean_i=mean_i/n, mean_q=mean_q/n, sha256=h.hexdigest())

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('file',type=Path)
    parser.add_argument('--format',choices=['cf32_le','ci16_le'],default='cf32_le')
    parser.add_argument('--sample-rate',type=float)
    parser.add_argument('--manifest',type=Path)
    args=parser.parse_args(); meta={}
    if args.manifest: meta=json.loads(args.manifest.read_text())
    fs=args.sample_rate or meta.get('SampleRateHz')
    if fs is None or not math.isfinite(fs) or fs<=0: parser.error('Provide a finite positive sample rate or manifest.')
    r=inspect(args.file,args.format,fs)
    if meta and r['complex_samples'] != meta['NumSamples']: raise ValueError('Manifest sample count mismatch.')
    print(json.dumps(r,indent=2,ensure_ascii=False))
if __name__=='__main__': main()
