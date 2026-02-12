import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useLOD } from '../performance/LODSystem';

export function SoftLitRoom() {
  const roomRef = useRef<THREE.Group>(null);
  const lodLevel = useLOD();

  useFrame(({ clock }) => {
    if (roomRef.current) {
      // Gentle breathing-like ambient animation
      const breathe = Math.sin(clock.getElapsedTime() * 0.3) * 0.015;
      roomRef.current.scale.setScalar(1 + breathe);
    }
  });

  const particleCount = lodLevel === 0 ? 120 : lodLevel === 1 ? 60 : 25;
  const orbCount = lodLevel === 0 ? 3 : lodLevel === 1 ? 2 : 1;

  return (
    <group ref={roomRef}>
      {/* Floor - Warm wooden texture simulation */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -2, 0]} receiveShadow>
        <planeGeometry args={[12, 12, 1, 1]} />
        <meshStandardMaterial 
          color="#f5efe6" 
          roughness={0.85} 
          metalness={0.05}
        />
      </mesh>

      {/* Walls - Curved beige sanctuary */}
      <mesh position={[0, 0, -5]}>
        <cylinderGeometry args={[6, 6, 5, 32, 1, true, 0, Math.PI]} />
        <meshStandardMaterial 
          color="#e8dcc8" 
          side={THREE.DoubleSide}
          roughness={0.9}
        />
      </mesh>

      {/* Side walls */}
      <mesh position={[5, 0, 0]} rotation={[0, Math.PI / 2, 0]}>
        <planeGeometry args={[10, 5]} />
        <meshStandardMaterial 
          color="#e8dcc8" 
          side={THREE.DoubleSide}
          roughness={0.9}
        />
      </mesh>
      <mesh position={[-5, 0, 0]} rotation={[0, -Math.PI / 2, 0]}>
        <planeGeometry args={[10, 5]} />
        <meshStandardMaterial 
          color="#e8dcc8" 
          side={THREE.DoubleSide}
          roughness={0.9}
        />
      </mesh>

      {/* Ceiling with soft diffuse glow */}
      <mesh rotation={[Math.PI / 2, 0, 0]} position={[0, 2.5, 0]}>
        <circleGeometry args={[6, 32]} />
        <meshStandardMaterial 
          color="#fff9e6" 
          emissive="#fff3d9"
          emissiveIntensity={0.25}
        />
      </mesh>

      {/* Soft overhead ambient light */}
      <pointLight 
        position={[0, 2, 0]} 
        intensity={0.9} 
        color="#ffe8cc" 
        distance={10} 
        decay={2} 
        castShadow={lodLevel === 0}
      />

      {/* Accent lights - warm corners */}
      <pointLight position={[3, 0.8, 2]} intensity={0.35} color="#ffd9a3" distance={6} />
      <pointLight position={[-3, 0.8, 2]} intensity={0.35} color="#ffd9a3" distance={6} />
      <pointLight position={[0, 0.5, -3]} intensity={0.25} color="#ffe4c4" distance={5} />

      {/* Ambient light for base illumination */}
      <ambientLight intensity={0.4} color="#fff5e6" />

      {/* Floating orbs - calming presence */}
      {Array.from({ length: orbCount }).map((_, i) => (
        <FloatingOrb 
          key={i}
          position={[
            (i - 1) * 1.5, 
            0.5 + i * 0.3, 
            -2 - i * 0.5
          ]} 
          color={['#ffebcd', '#ffe4c4', '#ffd9a3'][i]}
          delay={i * 1.5}
        />
      ))}

      {/* Particle system - gentle floating motes */}
      {lodLevel < 2 && <FloatingParticles count={particleCount} />}

      {/* Meditation cushion/seat */}
      {lodLevel === 0 && (
        <mesh position={[0, -1.7, 0]}>
          <cylinderGeometry args={[0.6, 0.7, 0.3, 16]} />
          <meshStandardMaterial 
            color="#d4b896" 
            roughness={0.95}
          />
        </mesh>
      )}
    </group>
  );
}

function FloatingOrb({ position, color, delay = 0 }: { 
  position: [number, number, number]; 
  color: string;
  delay?: number;
}) {
  const orbRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (orbRef.current) {
      const t = clock.getElapsedTime() + delay;
      orbRef.current.position.y = position[1] + Math.sin(t * 0.5) * 0.2;
      orbRef.current.rotation.y = t * 0.3;
      
      // Gentle pulsing glow
      const pulse = Math.sin(t * 2) * 0.2 + 0.6;
      (orbRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse;
    }
  });

  return (
    <mesh ref={orbRef} position={position}>
      <sphereGeometry args={[0.12, 16, 16]} />
      <meshStandardMaterial 
        color={color} 
        emissive={color}
        emissiveIntensity={0.6}
        transparent
        opacity={0.7}
      />
    </mesh>
  );
}

function FloatingParticles({ count }: { count: number }) {
  const particlesRef = useRef<THREE.Points>(null);
  const velocitiesRef = useRef<Float32Array>(new Float32Array(count * 3));

  const positions = new Float32Array(count * 3);

  // Initialize positions and velocities
  for (let i = 0; i < count; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 10;
    positions[i * 3 + 1] = Math.random() * 4 - 1.5;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 10;
    
    velocitiesRef.current[i * 3] = (Math.random() - 0.5) * 0.015;
    velocitiesRef.current[i * 3 + 1] = Math.random() * 0.008 + 0.003;
    velocitiesRef.current[i * 3 + 2] = (Math.random() - 0.5) * 0.015;
  }

  useFrame(() => {
    if (particlesRef.current) {
      const positions = particlesRef.current.geometry.attributes.position.array as Float32Array;
      const velocities = velocitiesRef.current;
      
      for (let i = 0; i < count; i++) {
        positions[i * 3] += velocities[i * 3];
        positions[i * 3 + 1] += velocities[i * 3 + 1];
        positions[i * 3 + 2] += velocities[i * 3 + 2];

        // Wrap around boundaries
        if (positions[i * 3 + 1] > 2.5) positions[i * 3 + 1] = -1.5;
        if (Math.abs(positions[i * 3]) > 5) velocities[i * 3] *= -1;
        if (Math.abs(positions[i * 3 + 2]) > 5) velocities[i * 3 + 2] *= -1;
      }

      particlesRef.current.geometry.attributes.position.needsUpdate = true;
    }
  });

  return (
    <points ref={particlesRef}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={count}
          array={positions}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.025}
        color="#ffefd5"
        transparent
        opacity={0.65}
        sizeAttenuation
      />
    </points>
  );
}
