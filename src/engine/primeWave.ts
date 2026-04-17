export function primeRadius(base: number, t: number, angle: number): number {
  return (
    base +
    Math.sin(angle * 11 + t * 3) * 12 +
    Math.sin(angle * 13 + t * 2) * 7 +
    Math.sin(angle * 17 + t * 4) * 5 +
    Math.sin(angle * 19 + t * 1.5) * 3
  );
}
