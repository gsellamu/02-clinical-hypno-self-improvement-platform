import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useLOD } from '../performance/LODSystem';

export function FloatingPlatform() {
  const platformRef = useRef<THREE.Group>(null);
  const lodLevel = useLOD();

  useFrame(({ clock }) => {
    if (platformRef.current) {
      // Gentle floating motion
      const float = Math.sin(clock.getElapsedTime() * 0.25) * 0.12;
      platformRef.current.position.y = float;
      
      // Very slow rotation
      platformRef.current.rotation.y = clock.getElapsedTime() * 0.04;
    }
  });

  const starCount = lodLevel === 0 ? 600 : lodLevel === 1 ? 300 : 150;
  const pillarCount = lodLevel === 0 ? 4 : lodLevel === 1 ? 3 : 2;
  const orbCount = lodLevel === 0 ? 3 : lodLevel === 1 ? 2 : 1;

  return (
    <group ref={platformRef}>
      {/* Deep space background */}
      <color attach="background" args={['#000408']} />

      {/* Main floating platform - crystalline structure */}
      <mesh position={[0, 0, 0]} receiveShadow castShadow>
        <cylinderGeometry args={[3.5, 3.5, 0.4, 48]} />
        <meshStandardMaterial 
          color="#1a1a3e" 
          metalness={0.8}
          roughness={0.25}
          emissive="#0f3460"
          emissiveIntensity={0.15}
        />
      </mesh>

      {/* Platform surface detail */}
      <mesh position={[0, 0.21, 0]}>
        <cylinderGeometry args={[3.3, 3.3, 0.02, 48]} />
        <meshStandardMaterial 
          color="#2a2a5e"
          metalness={0.9}
          roughness={0.1}
          emissive="#1a4080"
          emissiveIntensity={0.2}
        />
      </mesh>

      {/* Energy ring - outer glow */}
      <mesh position={[0, -0.2, 0]} rotation={[0, 0, 0]}>
        <torusGeometry args={[3.6, 0.08, 16, 64]} />
        <meshBasicMaterial 
          color="#00d4ff" 
          transparent 
          opacity={0.7}
        />
      </mesh>

      {/* Inner energy ring */}
      <mesh position={[0, -0.2, 0]} rotation={[0, 0, 0]}>
        <torusGeometry args={[3.2, 0.04, 16, 64]} />
        <meshBasicMaterial 
          color="#00ffff" 
          transparent 
          opacity={0.9}
        />
      </mesh>

      {/* Ethereal pillars at cardinal points */}
      {Array.from({ length: pillarCount }).map((_, i) => {
        const angle = (i / pillarCount) * Math.PI * 2;
        const radius = 2.5;
        const x = Math.cos(angle) * radius;
        const z = Math.sin(angle) * radius;
        return (
          <EtherealPillar 
            key={i} 
            position={[x, 1.2, z]} 
            delay={i * 1.2}
          />
        );
      })}

      {/* Central meditation zone glow */}
      <mesh position={[0, 0.25, 0]}>
        <circleGeometry args={[1.2, 32]} />
        <meshBasicMaterial 
          color="#3b82f6"
          transparent
          opacity={0.15}
        />
      </mesh>

      {/* Ambient space lighting */}
      <ambientLight intensity={0.15} color="#0a1929" />

      {/* Main platform lighting from below */}
      <pointLight 
        position={[0, -1, 0]} 
        intensity={1.2} 
        color="#00d4ff" 
        distance={8}
        decay={2}
      />

      {/* Top accent light */}
      <pointLight 
        position={[0, 6, 0]} 
        intensity={0.6} 
        color="#00d4ff" 
        distance={12}
      />

      {/* Distant nebula glows */}
      <pointLight position={[20, 12, -30]} intensity={3.5} color="#9333ea" distance={60} decay={2} />
      <pointLight position={[-20, 12, -30]} intensity={3.5} color="#3b82f6" distance={60} decay={2} />
      <pointLight position={[0, 15, -40]} intensity={2.5} color="#ec4899" distance={55} decay={2} />

      {/* Star field */}
      <Stars count={starCount} />

      {/* Floating energy orbs */}
      {Array.from({ length: orbCount }).map((_, i) => (
        <EnergyOrb 
          key={i}
          position={[
            Math.cos(i * 2.1) * 1.8,
            0.6 + i * 0.3,
            Math.sin(i * 2.1) * 1.8
          ]}
          color={['#00d4ff', '#9333ea', '#3b82f6'][i % 3]}
          delay={i * 2}
        />
      ))}

      {/* Geometric accent shapes */}
      {lodLevel === 0 && (
        <>
          <FloatingRing position={[0, 3, 0]} />
          <FloatingRing position={[0, 4.5, 0]} delay={3} />
        </>
      )}
    </group>
  );
}

function EtherealPillar({ position, delay = 0 }: { 
  position: [number, number, number];
  delay?: number;
}) {
  const pillarRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (pillarRef.current) {
      const t = clock.getElapsedTime() + delay;
      const pulse = Math.sin(t * 1.8) * 0.25 + 0.75;
      pillarRef.current.scale.y = pulse;
      (pillarRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse * 0.6;
      pillarRef.current.rotation.y = t * 0.5;
    }
  });

  return (
    <mesh ref={pillarRef} position={position}>
      <cylinderGeometry args={[0.12, 0.12, 2.5, 16]} />
      <meshStandardMaterial 
        color="#00d4ff"
        emissive="#00d4ff"
        emissiveIntensity={0.6}
        transparent
        opacity={0.5}
        metalness={0.9}
        roughness={0.1}
      />
    </mesh>
  );
}

function EnergyOrb({ position, color, delay = 0 }: { 
  position: [number, number, number];
  color: string;
  delay?: number;
}) {
  const orbRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (orbRef.current) {
      const t = clock.getElapsedTime() + delay;
      orbRef.current.position.y = position[1] + Math.sin(t * 0.7) * 0.35;
      orbRef.current.rotation.x = t * 0.4;
      orbRef.current.rotation.y = t * 0.35;
      
      const pulse = Math.sin(t * 2.5) * 0.35 + 0.65;
      (orbRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse;
    }
  });

  return (
    <mesh ref={orbRef} position={position}>
      <sphereGeometry args={[0.22, 20, 20]} />
      <meshStandardMaterial 
        color={color}
        emissive={color}
        emissiveIntensity={0.8}
        transparent
        opacity={0.85}
        metalness={0.6}
        roughness={0.2}
      />
    </mesh>
  );
}

function FloatingRing({ position, delay = 0 }: {
  position: [number, number, number];
  delay?: number;
}) {
  const ringRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (ringRef.current) {
      const t = clock.getElapsedTime() + delay;
      ringRef.current.rotation.y = t * 0.3;
      ringRef.current.rotation.x = Math.sin(t * 0.5) * 0.3;
      
      const pulse = Math.sin(t * 2) * 0.3 + 0.7;
      (ringRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse * 0.4;
    }
  });

  return (
    <mesh ref={ringRef} position={position}>
      <torusGeometry args={[1.5, 0.03, 16, 64]} />
      <meshStandardMaterial
        color="#00d4ff"
        emissive="#00d4ff"
        emissiveIntensity={0.4}
        transparent
        opacity={0.6}
        metalness={0.8}
        roughness={0.2}
      />
    </mesh>
  );
}

function Stars({ count }: { count: number }) {
  const starsRef = useRef<THREE.Points>(null);

  const positions = new Float32Array(count * 3);
  const colors = new Float32Array(count * 3);
  const sizes = new Float32Array(count);

  for (let i = 0; i < count; i++) {
    // Random positions in a large sphere
    const radius = 35 + Math.random() * 25;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);

    positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = radius * Math.cos(phi);

    // Star colors with variation (white to blue-ish to purple-ish)
    const colorType = Math.random();
    if (colorType < 0.7) {
      // White stars (most common)
      colors[i * 3] = 0.85 + Math.random() * 0.15;
      colors[i * 3 + 1] = 0.85 + Math.random() * 0.15;
      colors[i * 3 + 2] = 1;
    } else if (colorType < 0.9) {
      // Blue stars
      colors[i * 3] = 0.6 + Math.random() * 0.2;
      colors[i * 3 + 1] = 0.7 + Math.random() * 0.2;
      colors[i * 3 + 2] = 1;
    } else {
      // Purple/pink stars
      colors[i * 3] = 0.9 + Math.random() * 0.1;
      colors[i * 3 + 1] = 0.6 + Math.random() * 0.2;
      colors[i * 3 + 2] = 0.9 + Math.random() * 0.1;
    }

    // Varying sizes for depth
    sizes[i] = Math.random() * 0.08 + 0.02;
  }

  useFrame(({ clock }) => {
    if (starsRef.current) {
      starsRef.current.rotation.y = clock.getElapsedTime() * 0.008;
      starsRef.current.rotation.x = clock.getElapsedTime() * 0.003;
    }
  });

  return (
    <points ref={starsRef}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={count}
          array={positions}
          itemSize={3}
        />
        <bufferAttribute
          attach="attributes-color"
          count={count}
          array={colors}
          itemSize={3}
        />
        <bufferAttribute
          attach="attributes-size"
          count={count}
          array={sizes}
          itemSize={1}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.06}
        vertexColors
        transparent
        opacity={0.85}
        sizeAttenuation
      />
    </points>
  );
}
