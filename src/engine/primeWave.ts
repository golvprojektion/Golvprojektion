// PrimeWaveEngine: generates organic multi-frequency motion using primes
export interface PrimeWaveConfig {
  baseRadius: number;
  t: number;
  angle: number;
}

const PRIMES = [11, 13, 17, 19];

export function primeRadius({ baseRadius, t, angle }: PrimeWaveConfig): number {
  let r = baseRadius;
  const amps = [12, 7, 5, 3];

  for (let i = 0; i < PRIMES.length; i++) {
    const p = PRIMES[i];
    const amp = amps[i];
    r += Math.sin(angle * p + t * (3 + i)) * amp;
  }

  return r;
}
