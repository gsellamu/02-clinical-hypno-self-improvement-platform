// LOW PRIORITY #2: VR Environments (Temple & Beach)
// File: 02-clinical.../frontend/src/components/environments/index.tsx

import React from 'react';
import { Sky, Environment } from '@react-three/drei';

export function TempleEnvironment() {
  return (
    <>
      <ambientLight intensity={0.3} />
      <directionalLight position={[10, 10, 5]} intensity={0.8} castShadow />
      <Sky sunPosition={[0, 1, 0]} />
      
      <group position={[0, 0, -5]}>
        {/* Floor */}
        <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
          <planeGeometry args={[50, 50]} />
          <meshStandardMaterial color="#d4af37" />
        </mesh>
        
        {/* Columns */}
        {[0, 90, 180, 270].map((angle, i) => {
          const rad = (angle * Math.PI) / 180;
          return (
            <mesh key={i} position={[Math.cos(rad) * 8, 3, Math.sin(rad) * 8]} castShadow>
              <cylinderGeometry args={[0.5, 0.5, 6, 16]} />
              <meshStandardMaterial color="#f0e68c" />
            </mesh>
          );
        })}
        
        {/* Altar */}
        <mesh position={[0, 1, 0]} castShadow>
          <boxGeometry args={[2, 2, 2]} />
          <meshStandardMaterial color="#daa520" metalness={0.5} />
        </mesh>
      </group>
      
      <Environment preset="sunset" />
    </>
  );
}

export function BeachEnvironment() {
  return (
    <>
      <ambientLight intensity={0.5} />
      <directionalLight position={[10, 20, 5]} intensity={1.2} castShadow />
      <Sky sunPosition={[100, 20, 100]} />
      
      {/* Ocean */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]}>
        <planeGeometry args={[100, 100]} />
        <meshStandardMaterial color="#006994" opacity={0.9} transparent />
      </mesh>
      
      {/* Sand */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, -10]}>
        <planeGeometry args={[50, 30]} />
        <meshStandardMaterial color="#f4a460" />
      </mesh>
      
      {/* Palm trees */}
      {[-10, 0, 10].map((x, i) => (
        <group key={i} position={[x, 0, -15]}>
          <mesh position={[0, 3, 0]} castShadow>
            <cylinderGeometry args={[0.3, 0.4, 6, 8]} />
            <meshStandardMaterial color="#8b4513" />
          </mesh>
          <mesh position={[0, 6, 0]} castShadow>
            <coneGeometry args={[2, 3, 8]} />
            <meshStandardMaterial color="#228b22" />
          </mesh>
        </group>
      ))}
      
      <Environment preset="sunset" />
    </>
  );
}

interface EnvironmentSelectorProps {
  environment: 'temple' | 'beach' | 'office';
}

export function EnvironmentSelector({ environment }: EnvironmentSelectorProps) {
  if (environment === 'temple') return <TempleEnvironment />;
  if (environment === 'beach') return <BeachEnvironment />;
  
  return (
    <>
      <ambientLight intensity={0.4} />
      <directionalLight position={[5, 5, 5]} intensity={0.8} />
      <Environment preset="apartment" />
    </>
  );
}
