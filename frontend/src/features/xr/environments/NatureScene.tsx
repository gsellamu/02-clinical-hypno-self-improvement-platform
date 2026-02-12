import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useLOD } from '../performance/LODSystem';

export function NatureScene() {
  const sceneRef = useRef<THREE.Group>(null);
  const lodLevel = useLOD();

  const treeCount = lodLevel === 0 ? 24 : lodLevel === 1 ? 14 : 8;
  const flowerPatchCount = lodLevel === 0 ? 18 : lodLevel === 1 ? 10 : 5;
  const butterflyCount = lodLevel === 0 ? 3 : lodLevel === 1 ? 2 : 0;

  return (
    <group ref={sceneRef}>
      {/* Ground - Lush grassy meadow */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]} receiveShadow>
        <circleGeometry args={[18, 64]} />
        <meshStandardMaterial 
          color="#4a7c59" 
          roughness={0.95}
          metalness={0.0}
        />
      </mesh>

      {/* Secondary grass layer for depth */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.48, 0]}>
        <circleGeometry args={[10, 48]} />
        <meshStandardMaterial 
          color="#5a8c69" 
          transparent
          opacity={0.6}
          roughness={1.0}
        />
      </mesh>

      {/* Sky dome with gradient */}
      <mesh>
        <sphereGeometry args={[60, 32, 32, 0, Math.PI * 2, 0, Math.PI / 2]} />
        <meshBasicMaterial 
          color="#87ceeb" 
          side={THREE.BackSide}
        />
      </mesh>

      {/* Horizon glow */}
      <mesh position={[0, 0, -50]} rotation={[0, 0, 0]}>
        <planeGeometry args={[100, 30]} />
        <meshBasicMaterial 
          color="#b0d8f0"
          transparent
          opacity={0.4}
        />
      </mesh>

      {/* Sun */}
      <mesh position={[25, 30, -40]}>
        <sphereGeometry args={[4, 32, 32]} />
        <meshBasicMaterial color="#fffacd" />
      </mesh>

      {/* Directional sunlight */}
      <directionalLight
        position={[15, 20, -20]}
        intensity={1.8}
        color="#fffaf0"
        castShadow={lodLevel === 0}
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
      />

      {/* Ambient light - soft daylight */}
      <ambientLight intensity={0.5} color="#e6f3ff" />

      {/* Hemisphere light for natural sky/ground lighting */}
      <hemisphereLight
        color="#87ceeb"
        groundColor="#4a7c59"
        intensity={0.6}
      />

      {/* Trees in organic circle pattern */}
      {Array.from({ length: treeCount }).map((_, i) => {
        const angle = (i / treeCount) * Math.PI * 2 + Math.random() * 0.3;
        const radius = 9 + Math.random() * 5;
        const x = Math.cos(angle) * radius;
        const z = Math.sin(angle) * radius;
        return (
          <Tree 
            key={i} 
            position={[x, -0.5, z]} 
            scale={0.8 + Math.random() * 0.4}
          />
        );
      })}

      {/* Flower patches scattered naturally */}
      {Array.from({ length: flowerPatchCount }).map((_, i) => {
        const angle = Math.random() * Math.PI * 2;
        const radius = Math.random() * 7;
        const x = Math.cos(angle) * radius;
        const z = Math.sin(angle) * radius;
        return <FlowerPatch key={i} position={[x, -0.4, z]} />;
      })}

      {/* Butterflies floating around */}
      {Array.from({ length: butterflyCount }).map((_, i) => (
        <Butterfly 
          key={i} 
          startPosition={[
            (Math.random() - 0.5) * 8,
            1 + Math.random() * 1.5,
            (Math.random() - 0.5) * 8
          ]}
        />
      ))}

      {/* Clouds */}
      {lodLevel === 0 && (
        <>
          <Cloud position={[15, 20, -30]} />
          <Cloud position={[-20, 18, -35]} />
          <Cloud position={[5, 22, -40]} />
        </>
      )}
    </group>
  );
}

function Tree({ position, scale = 1 }: { 
  position: [number, number, number];
  scale?: number;
}) {
  const treeRef = useRef<THREE.Group>(null);

  useFrame(({ clock }) => {
    if (treeRef.current) {
      // Gentle swaying in the wind
      const sway = Math.sin(clock.getElapsedTime() * 0.5 + position[0]) * 0.025;
      treeRef.current.rotation.z = sway;
    }
  });

  return (
    <group ref={treeRef} position={position} scale={scale}>
      {/* Trunk */}
      <mesh position={[0, 1.8, 0]} castShadow>
        <cylinderGeometry args={[0.25, 0.3, 3.6, 8]} />
        <meshStandardMaterial color="#4d3319" roughness={0.95} />
      </mesh>

      {/* Lower foliage layer */}
      <mesh position={[0, 3.8, 0]} castShadow>
        <sphereGeometry args={[1.8, 10, 10]} />
        <meshStandardMaterial color="#2d5016" roughness={0.85} />
      </mesh>

      {/* Middle foliage layer */}
      <mesh position={[0, 4.6, 0]} castShadow>
        <sphereGeometry args={[1.4, 10, 10]} />
        <meshStandardMaterial color="#3d6b1f" roughness={0.85} />
      </mesh>

      {/* Top foliage layer */}
      <mesh position={[0, 5.2, 0]} castShadow>
        <sphereGeometry args={[1.0, 8, 8]} />
        <meshStandardMaterial color="#4a7c2a" roughness={0.85} />
      </mesh>
    </group>
  );
}

function FlowerPatch({ position }: { position: [number, number, number] }) {
  const colors = ['#ff69b4', '#ffd700', '#fff8dc', '#ff6347', '#da70d6', '#ffb6c1'];
  
  return (
    <group position={position}>
      {Array.from({ length: 6 }).map((_, i) => {
        const offset: [number, number, number] = [
          (Math.random() - 0.5) * 0.4, 
          0, 
          (Math.random() - 0.5) * 0.4
        ];
        const color = colors[Math.floor(Math.random() * colors.length)];
        return (
          <mesh key={i} position={offset}>
            <sphereGeometry args={[0.06, 8, 8]} />
            <meshStandardMaterial 
              color={color} 
              emissive={color} 
              emissiveIntensity={0.25}
            />
          </mesh>
        );
      })}
    </group>
  );
}

function Butterfly({ startPosition }: { startPosition: [number, number, number] }) {
  const butterflyRef = useRef<THREE.Group>(null);

  useFrame(({ clock }) => {
    if (butterflyRef.current) {
      const t = clock.getElapsedTime();
      butterflyRef.current.position.x = startPosition[0] + Math.sin(t * 0.6) * 3;
      butterflyRef.current.position.y = startPosition[1] + Math.sin(t * 2.5) * 0.6 + Math.cos(t * 1.2) * 0.3;
      butterflyRef.current.position.z = startPosition[2] + Math.cos(t * 0.6) * 3;
      butterflyRef.current.rotation.y = Math.sin(t * 0.6) * 2;
    }
  });

  return (
    <group ref={butterflyRef}>
      {/* Body */}
      <mesh>
        <capsuleGeometry args={[0.03, 0.12, 4, 8]} />
        <meshStandardMaterial color="#333333" />
      </mesh>
      {/* Wings */}
      <mesh position={[0.08, 0, 0]}>
        <boxGeometry args={[0.15, 0.08, 0.02]} />
        <meshStandardMaterial color="#ff69b4" emissive="#ff69b4" emissiveIntensity={0.3} />
      </mesh>
      <mesh position={[-0.08, 0, 0]}>
        <boxGeometry args={[0.15, 0.08, 0.02]} />
        <meshStandardMaterial color="#ff69b4" emissive="#ff69b4" emissiveIntensity={0.3} />
      </mesh>
    </group>
  );
}

function Cloud({ position }: { position: [number, number, number] }) {
  const cloudRef = useRef<THREE.Group>(null);

  useFrame(({ clock }) => {
    if (cloudRef.current) {
      cloudRef.current.position.x = position[0] + Math.sin(clock.getElapsedTime() * 0.05) * 2;
    }
  });

  return (
    <group ref={cloudRef} position={position}>
      <mesh>
        <sphereGeometry args={[3, 8, 8]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.7} />
      </mesh>
      <mesh position={[2, 0, 0]}>
        <sphereGeometry args={[2.5, 8, 8]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.7} />
      </mesh>
      <mesh position={[-2, 0, 0]}>
        <sphereGeometry args={[2.5, 8, 8]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.7} />
      </mesh>
    </group>
  );
}
