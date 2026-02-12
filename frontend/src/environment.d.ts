// src/global.d.ts
import { ThreeElements } from '@react-three/fiber';

declare global {
  namespace JSX {
    interface IntrinsicElements extends ThreeElements {}
  }
}

// IMPORTANT: Ensure there is NO 'export {}' at the bottom of this file.
