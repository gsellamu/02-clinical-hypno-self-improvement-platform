import { Object3DNode, ThreeElements } from '@react-three/fiber';
import * as THREE from 'three';

declare module '@react-three/fiber' {
  interface ThreeElements {
    mesh: Object3DNode<THREE.Mesh, typeof THREE.Mesh>;
    group: Object3DNode<THREE.Group, typeof THREE.Group>;
    points: Object3DNode<THREE.Points, typeof THREE.Points>;
    ambientLight: Object3DNode<THREE.AmbientLight, typeof THREE.AmbientLight>;
    pointLight: Object3DNode<THREE.PointLight, typeof THREE.PointLight>;
  }
}

declare global {
  namespace JSX {
    interface IntrinsicElements extends ThreeElements {}
  }
}

export {};
