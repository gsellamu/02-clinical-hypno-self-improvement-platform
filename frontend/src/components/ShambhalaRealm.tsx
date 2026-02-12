// @ts-nocheck
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import React, { useMemo } from "react";


export function ShambhalaRealm() {
  // Refs for all animated elements
  const terrainRef = useRef(null);
  const riverRef = useRef(null);
  const waterfallRef = useRef(null);
  const foliageRef = useRef(null);
  const crystalTemplesRef = useRef(null);
  const treeHousesRef = useRef(null);
  const cosmicSkyRef = useRef(null);
  const auroraRef = useRef(null);
  const siddhasRef = useRef(null);
  const godRaysRef = useRef(null);
  const particlesRef = useRef(null);
  const birdsRef = useRef(null);

    // CREATE TEXTURES ONCE using useMemo
  const waterTexture = useMemo(() => createWaterTexture(), []);

   // Atmospheric particles
  const particleCount = 100;
  const { particlePositions, particleColors, particleSizes, particleVelocities } = useMemo(() => {
    const positions = new Float32Array(particleCount * 2);
    const colors = new Float32Array(particleCount * 10);
    const sizes = new Float32Array(particleCount/4);
    const velocities = new Float32Array(particleCount/4);

    for (let i = 0; i < particleCount; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 120;
      positions[i * 3 + 1] = Math.random() * 50;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 120 - 40;
      
      velocities[i * 3] = (Math.random() - 0.5) * 0.01;
      velocities[i * 3 + 1] = Math.random() * 0.02 + 0.01;
      velocities[i * 3 + 2] = (Math.random() - 0.5) * 0.01;
      
      const type = Math.random();
      if (type < 0.6) {
        colors[i * 3] = 1;
        colors[i * 3 + 1] = 0.9 + Math.random() * 0.1;
        colors[i * 3 + 2] = 0.6 + Math.random() * 0.2;
        sizes[i] = Math.random() * 1.5 + 0.5;
      } else if (type < 0.85) {
        colors[i * 3] = 0.9 + Math.random() * 0.1;
        colors[i * 3 + 1] = 0.95 + Math.random() * 0.05;
        colors[i * 3 + 2] = 1;
        sizes[i] = Math.random() * 2 + 0.8;
      } else {
        colors[i * 3] = 0.9 + Math.random() * 0.1;
        colors[i * 3 + 1] = 0.6 + Math.random() * 0.2;
        colors[i * 3 + 2] = 1;
        sizes[i] = Math.random() * 1.8 + 0.6;
      }
    }

    return { 
      particlePositions: positions, 
      particleColors: colors, 
      particleSizes: sizes, 
      particleVelocities: velocities 
    };
  }, [particleCount]);

  useFrame(({ clock }) => {
    const t = clock.getElapsedTime();

    // Animate flowing river
    if (riverRef.current && riverRef.current.material.map) {
      riverRef.current.material.map.offset.x = t * 0.05;
      riverRef.current.material.map.offset.y = t * 0.03;
      riverRef.current.material.opacity = 0.7 + Math.sin(t * 2) * 0.1;
    }

    // Animate waterfall
    if (waterfallRef.current && waterfallRef.current.material.map) {
      waterfallRef.current.material.map.offset.y = -t * 0.3;
      waterfallRef.current.material.opacity = 0.6 + Math.sin(t * 3) * 0.15;
    }

    // Gentle terrain breathing
    if (terrainRef.current) {
      terrainRef.current.position.y = Math.sin(t * 0.3) * 0.3;
    }

    // Animate foliage (gentle swaying)
    if (foliageRef.current) {
      foliageRef.current.children.forEach((tree, i) => {
        tree.rotation.z = Math.sin(t * 0.5 + i * 0.5) * 0.05;
      });
    }

    // Crystal temples pulsing with energy
    if (crystalTemplesRef.current) {
      crystalTemplesRef.current.children.forEach((temple, i) => {
        const pulse = Math.sin(t * 0.6 + i * 1.2) * 0.4 + 1.4;
        if (temple.material && temple.material.emissiveIntensity !== undefined) {
          temple.material.emissiveIntensity = pulse;
        }
      });
    }

    // Cosmic sky rotation
    if (cosmicSkyRef.current) {
      cosmicSkyRef.current.rotation.y = t * 0.005;
      cosmicSkyRef.current.rotation.z = t * 0.003;
    }

    // Aurora waves
    if (auroraRef.current) {
      auroraRef.current.rotation.z = Math.sin(t * 0.2) * 0.2;
      auroraRef.current.position.y = 35 + Math.sin(t * 0.3) * 4;
      auroraRef.current.material.opacity = 0.3 + Math.sin(t * 0.5) * 0.15;
    }

    // Glowing Siddhas floating and meditating
    if (siddhasRef.current) {
      siddhasRef.current.children.forEach((siddha, i) => {
        siddha.position.y = 2 + Math.sin(t * 0.4 + i * 2) * 1.5;
        siddha.rotation.y = t * 0.1 + i;
        const glow = Math.sin(t * 0.7 + i * 1.5) * 0.5 + 1.8;
        if (siddha.material && siddha.material.emissiveIntensity !== undefined) {
          siddha.material.emissiveIntensity = glow;
        }
      });
    }

    // Animate atmospheric particles
    if (particlesRef.current) {
      const positions = particlesRef.current.geometry.attributes.position.array;
      
      for (let i = 0; i < particleCount; i++) {
        const i3 = i * 3;
        
        positions[i3] += particleVelocities[i3] + Math.sin(t * 0.5 + i * 0.1) * 0.005;
        positions[i3 + 1] += particleVelocities[i3 + 1];
        positions[i3 + 2] += particleVelocities[i3 + 2];
        
        if (positions[i3 + 1] > 50) {
          positions[i3 + 1] = 0;
          positions[i3] = (Math.random() - 0.5) * 120;
          positions[i3 + 2] = (Math.random() - 0.5) * 120 - 40;
        }
        
        if (Math.abs(positions[i3]) > 60) positions[i3] = (Math.random() - 0.5) * 120;
        if (Math.abs(positions[i3 + 2] + 40) > 60) positions[i3 + 2] = (Math.random() - 0.5) * 120 - 40;
      }
      
      particlesRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Animate birds
    if (birdsRef.current) {
      birdsRef.current.children.forEach((bird, i) => {
        const radius = 30 + i * 5;
        const speed = 0.1 + i * 0.05;
        const angle = t * speed + i * 2;
        
        bird.position.x = Math.cos(angle) * radius;
        bird.position.z = Math.sin(angle) * radius - 30;
        bird.position.y = 15 + Math.sin(t * 2 + i) * 3;
        bird.rotation.y = angle + Math.PI / 2;
      });
    }
  });

  return (
    <>
      {/* === LIGHTING SETUP === */}
      <directionalLight position={[40, 50, -20]} intensity={1.5} color="#ffd700" castShadow />
      <ambientLight intensity={0.4} color="#d4f1d4" />
      <pointLight position={[0, 15, -35]} intensity={3} color="#87ceeb" distance={60} />
      <pointLight position={[-20, 12, -40]} intensity={2.5} color="#ffd700" distance={50} />
      <pointLight position={[20, 10, -30]} intensity={2.5} color="#dda0dd" distance={50} />
      <pointLight position={[0, 5, -20]} intensity={1.5} color="#4682b4" distance={40} />

      {/* === COSMIC SKY === */}
      <group ref={cosmicSkyRef}>
        <mesh position={[30, 40, -90]}>
          <sphereGeometry args={[45, 24, 24]} />
          <meshBasicMaterial color="#4b0082" transparent opacity={0.2} side={THREE.BackSide} />
        </mesh>

        <mesh position={[-35, 35, -85]}>
          <sphereGeometry args={[38, 24, 24]} />
          <meshBasicMaterial color="#191970" transparent opacity={0.18} side={THREE.BackSide} />
        </mesh>

        <mesh position={[0, 50, -95]}>
          <sphereGeometry args={[50, 24, 24]} />
          <meshBasicMaterial color="#1e3a8a" transparent opacity={0.15} side={THREE.BackSide} />
        </mesh>
      </group>

      {/* Galaxy particles */}
      {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
        const angle = (i / 8) * Math.PI * 2;
        const radius = 60 + i * 8;
        return (
          <mesh
            key={`galaxy-${i}`}
            position={[Math.cos(angle) * radius, 45 + Math.sin(i * 2) * 10, Math.sin(angle) * radius - 85]}
          >
            <sphereGeometry args={[3, 16, 16]} />
            <meshBasicMaterial color={['#4169e1', '#9370db', '#dda0dd', '#87ceeb'][i % 4]} transparent opacity={0.6} />
          </mesh>
        );
      })}

      {/* Aurora */}
      <mesh ref={auroraRef} position={[0, 35, -70]} rotation={[Math.PI / 5, 0, 0]}>
        <planeGeometry args={[140, 50, 20, 10]} />
        <meshBasicMaterial color="#00ff88" transparent opacity={0.3} side={THREE.DoubleSide} />
      </mesh>

      <mesh position={[30, 38, -75]} rotation={[Math.PI / 4, 0, 0]}>
        <planeGeometry args={[100, 45, 15, 8]} />
        <meshBasicMaterial color="#4169e1" transparent opacity={0.25} side={THREE.DoubleSide} />
      </mesh>

      {/* === TERRAIN === */}
      <group ref={terrainRef}>
        <mesh position={[0, -15, -40]} rotation={[-Math.PI / 2, 0, 0]}>
          <planeGeometry args={[120, 120, 30, 30]} />
          <meshStandardMaterial color="#2d5016" roughness={0.9} metalness={0.1} />
        </mesh>

        {[0, 1, 2, 3, 4].map((i) => (
          <mesh key={`hill-${i}`} position={[(i - 2) * 15, -12 + i * 2, -45 - i * 8]} rotation={[-Math.PI / 2, 0, 0]}>
            <circleGeometry args={[12, 32]} />
            <meshStandardMaterial color="#3d6b1f" roughness={0.85} />
          </mesh>
        ))}
      </group>

      {/* === FOREST === */}
      <group ref={foliageRef}>
        {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => {
          const angle = (i / 10) * Math.PI * 2;
          const radius = 25 + (i % 3) * 10;
          return (
            <group key={`tree-${i}`} position={[Math.cos(angle) * radius, -8, Math.sin(angle) * radius - 35]}>
              <mesh>
                <cylinderGeometry args={[2, 2.5, 25, 12]} />
                <meshStandardMaterial color="#4a3520" roughness={0.95} />
              </mesh>
              <mesh position={[0, 15, 0]}>
                <sphereGeometry args={[8, 12, 12]} />
                <meshStandardMaterial color="#2d5016" emissive="#3d6b1f" emissiveIntensity={0.3} roughness={0.8} />
              </mesh>
              <mesh position={[0, 5, 0]}>
                <sphereGeometry args={[0.5, 12, 12]} />
                <meshStandardMaterial color="#ffd700" emissive="#ffd700" emissiveIntensity={2} />
                <pointLight position={[0, 0, 0]} intensity={1.5} color="#ffd700" distance={15} />
              </mesh>
            </group>
          );
        })}
      </group>

      {/* === CRYSTAL TEMPLES === */}
      <group ref={crystalTemplesRef}>
        <group position={[0, 0, -35]}>
          <mesh position={[0, -2, 0]}>
            <cylinderGeometry args={[6, 8, 4, 8]} />
            <meshStandardMaterial color="#f5deb3" roughness={0.5} metalness={0.2} />
          </mesh>
          <mesh position={[0, 3, 0]}>
            <octahedronGeometry args={[5, 0]} />
            <meshStandardMaterial color="#87ceeb" transparent opacity={0.8} metalness={0.9} roughness={0.1} emissive="#87ceeb" emissiveIntensity={1.2} />
          </mesh>
          <mesh position={[0, 12, 0]}>
            <coneGeometry args={[0.8, 12, 8]} />
            <meshStandardMaterial color="#ffd700" metalness={1} roughness={0.1} emissive="#ffd700" emissiveIntensity={1.5} />
            <pointLight position={[0, 6, 0]} intensity={4} color="#ffd700" distance={30} />
          </mesh>
        </group>

        {[-15, 15].map((x, idx) => (
          <group key={`side-temple-${idx}`} position={[x, -3, -40]}>
            <mesh position={[0, 2, 0]}>
              <octahedronGeometry args={[3, 0]} />
              <meshStandardMaterial
                color={idx === 0 ? "#dda0dd" : "#98ff98"}
                transparent opacity={0.75} metalness={0.8} roughness={0.2}
                emissive={idx === 0 ? "#dda0dd" : "#98ff98"}
                emissiveIntensity={1}
              />
            </mesh>
          </group>
        ))}
      </group>

      {/* === RIVER === USE TEXTURE FROM useMemo */}
      <mesh ref={riverRef} position={[0, -10, -20]} rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[15, 80, 20, 40]} />
        <meshStandardMaterial
          color="#4682b4"
          transparent
          opacity={0.7}
          metalness={0.9}
          roughness={0.1}
          emissive="#87ceeb"
          emissiveIntensity={0.3}
          map={waterTexture}
        />
      </mesh>

      <mesh ref={waterfallRef} position={[0, -5, -50]} rotation={[Math.PI / 4, 0, 0]}>
        <planeGeometry args={[8, 12, 10, 20]} />
        <meshBasicMaterial color="#e0ffff" transparent opacity={0.6} map={waterTexture} />
      </mesh>

      {/* === SIDDHAS === */}
      <group ref={siddhasRef}>
        {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
          const angle = (i / 8) * Math.PI * 2;
          const radius = 15 + (i % 2) * 8;
          return (
            <group key={`siddha-${i}`} position={[Math.cos(angle) * radius, 2, Math.sin(angle) * radius - 30]}>
              <mesh position={[0, 1, 0]}>
                <capsuleGeometry args={[0.5, 2, 8, 16]} />
                <meshStandardMaterial color="#fff8dc" emissive="#ffd700" emissiveIntensity={1.8} transparent opacity={0.85} />
              </mesh>
              <mesh position={[0, 3, 0]}>
                <sphereGeometry args={[0.6, 12, 12]} />
                <meshStandardMaterial color="#fff8dc" emissive="#ffffff" emissiveIntensity={2} transparent opacity={0.9} />
              </mesh>
              <mesh position={[0, 1.5, 0]}>
                <sphereGeometry args={[2, 16, 16]} />
                <meshBasicMaterial color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]} transparent opacity={0.2} />
              </mesh>
              <pointLight position={[0, 2, 0]} intensity={2.5} color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]} distance={15} />
            </group>
          );
        })}
      </group>

      {/* === PARTICLES === */}
      <points ref={particlesRef}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" count={particleCount} array={particlePositions} itemSize={3} />
          <bufferAttribute attach="attributes-color" count={particleCount} array={particleColors} itemSize={3} />
          <bufferAttribute attach="attributes-size" count={particleCount} array={particleSizes} itemSize={1} />
        </bufferGeometry>
        <pointsMaterial size={1.5} vertexColors transparent opacity={0.8} sizeAttenuation blending={THREE.AdditiveBlending} />
      </points>

      {/* === BIRDS === */}
      <group ref={birdsRef}>
        {[0, 1, 2, 3, 4].map((i) => (
          <group key={`bird-${i}`}>
            <mesh>
              <coneGeometry args={[0.3, 1, 3]} />
              <meshBasicMaterial color="#ffffff" />
            </mesh>
          </group>
        ))}
      </group>
    </>
  );
}

// Helper function - moved outside component
function createWaterTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  
  const gradient = ctx.createLinearGradient(0, 0, 512, 512);
  gradient.addColorStop(0, 'rgba(70, 130, 180, 0.8)');
  gradient.addColorStop(0.5, 'rgba(135, 206, 235, 0.9)');
  gradient.addColorStop(1, 'rgba(70, 130, 180, 0.8)');
  
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 512, 512);
  
  for (let i = 0; i < 50; i++) {
    ctx.beginPath();
    ctx.arc(Math.random() * 512, Math.random() * 512, Math.random() * 3, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.fill();
  }
  
  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(4, 4);
  return texture;
}

/*

  // Atmospheric particles (pollen, light motes, fireflies)
  const particleCount = 1500;
  const particlePositions = new Float32Array(particleCount * 3);
  const particleColors = new Float32Array(particleCount * 3);
  const particleSizes = new Float32Array(particleCount);
  const particleVelocities = new Float32Array(particleCount * 3);

  for (let i = 0; i < particleCount; i++) {
    particlePositions[i * 3] = (Math.random() - 0.5) * 120;
    particlePositions[i * 3 + 1] = Math.random() * 50;
    particlePositions[i * 3 + 2] = (Math.random() - 0.5) * 120 - 40;
    
    particleVelocities[i * 3] = (Math.random() - 0.5) * 0.01;
    particleVelocities[i * 3 + 1] = Math.random() * 0.02 + 0.01;
    particleVelocities[i * 3 + 2] = (Math.random() - 0.5) * 0.01;
    
    const type = Math.random();
    if (type < 0.6) {
      // Golden light motes
      particleColors[i * 3] = 1;
      particleColors[i * 3 + 1] = 0.9 + Math.random() * 0.1;
      particleColors[i * 3 + 2] = 0.6 + Math.random() * 0.2;
      particleSizes[i] = Math.random() * 1.5 + 0.5;
    } else if (type < 0.85) {
      // White-blue spiritual lights
      particleColors[i * 3] = 0.9 + Math.random() * 0.1;
      particleColors[i * 3 + 1] = 0.95 + Math.random() * 0.05;
      particleColors[i * 3 + 2] = 1;
      particleSizes[i] = Math.random() * 2 + 0.8;
    } else {
      // Violet mystical particles
      particleColors[i * 3] = 0.9 + Math.random() * 0.1;
      particleColors[i * 3 + 1] = 0.6 + Math.random() * 0.2;
      particleColors[i * 3 + 2] = 1;
      particleSizes[i] = Math.random() * 1.8 + 0.6;
    }
  }

  useFrame(({ clock, scene }) => {
    const t = clock.getElapsedTime();
    scene.background = null;

    // Animate flowing river
    if (riverRef.current) {
      riverRef.current.material.map.offset.x = t * 0.05;
      riverRef.current.material.map.offset.y = t * 0.03;
      riverRef.current.material.opacity = 0.7 + Math.sin(t * 2) * 0.1;
    }

    // Animate waterfall
    if (waterfallRef.current) {
      waterfallRef.current.material.map.offset.y = -t * 0.3;
      waterfallRef.current.material.opacity = 0.6 + Math.sin(t * 3) * 0.15;
    }

    // Gentle terrain breathing
    if (terrainRef.current) {
      terrainRef.current.position.y = Math.sin(t * 0.3) * 0.3;
    }

    // Animate foliage (gentle swaying)
    if (foliageRef.current) {
      foliageRef.current.children.forEach((tree, i) => {
        tree.rotation.z = Math.sin(t * 0.5 + i * 0.5) * 0.05;
      });
    }

    // Crystal temples pulsing with energy
    if (crystalTemplesRef.current) {
      crystalTemplesRef.current.children.forEach((temple, i) => {
        const pulse = Math.sin(t * 0.6 + i * 1.2) * 0.4 + 1.4;
        if (temple.material && temple.material.emissiveIntensity !== undefined) {
          temple.material.emissiveIntensity = pulse;
        }
      });
    }

    // Cosmic sky rotation
    if (cosmicSkyRef.current) {
      cosmicSkyRef.current.rotation.y = t * 0.005;
      cosmicSkyRef.current.rotation.z = t * 0.003;
    }

    // Aurora waves
    if (auroraRef.current) {
      auroraRef.current.rotation.z = Math.sin(t * 0.2) * 0.2;
      auroraRef.current.position.y = 35 + Math.sin(t * 0.3) * 4;
      auroraRef.current.material.opacity = 0.3 + Math.sin(t * 0.5) * 0.15;
    }

    // Glowing Siddhas floating and meditating
    if (siddhasRef.current) {
      siddhasRef.current.children.forEach((siddha, i) => {
        siddha.position.y = 2 + Math.sin(t * 0.4 + i * 2) * 1.5;
        siddha.rotation.y = t * 0.1 + i;
        const glow = Math.sin(t * 0.7 + i * 1.5) * 0.5 + 1.8;
        if (siddha.material && siddha.material.emissiveIntensity !== undefined) {
          siddha.material.emissiveIntensity = glow;
        }
      });
    }

    // Animate atmospheric particles
    if (particlesRef.current) {
      const positions = particlesRef.current.geometry.attributes.position.array;
      
      for (let i = 0; i < particleCount; i++) {
        const i3 = i * 3;
        
        positions[i3] += particleVelocities[i3] + Math.sin(t * 0.5 + i * 0.1) * 0.005;
        positions[i3 + 1] += particleVelocities[i3 + 1];
        positions[i3 + 2] += particleVelocities[i3 + 2];
        
        // Respawn particles that float too high
        if (positions[i3 + 1] > 50) {
          positions[i3 + 1] = 0;
          positions[i3] = (Math.random() - 0.5) * 120;
          positions[i3 + 2] = (Math.random() - 0.5) * 120 - 40;
        }
        
        // Boundary checks
        if (Math.abs(positions[i3]) > 60) positions[i3] = (Math.random() - 0.5) * 120;
        if (Math.abs(positions[i3 + 2] + 40) > 60) positions[i3 + 2] = (Math.random() - 0.5) * 120 - 40;
      }
      
      particlesRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Animate birds
    if (birdsRef.current) {
      birdsRef.current.children.forEach((bird, i) => {
        const radius = 30 + i * 5;
        const speed = 0.1 + i * 0.05;
        const angle = t * speed + i * 2;
        
        bird.position.x = Math.cos(angle) * radius;
        bird.position.z = Math.sin(angle) * radius - 30;
        bird.position.y = 15 + Math.sin(t * 2 + i) * 3;
        bird.rotation.y = angle + Math.PI / 2;
      });
    }
  });

  return (
    <>
      {/* === LIGHTING SETUP === * /}
      
      {/* Warm golden sunlight filtering through trees * /}
      <directionalLight
        position={[40, 50, -20]}
        intensity={1.5}
        color="#ffd700"
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
      />
      
      {/* Ambient forest light * /}
      <ambientLight intensity={0.4} color="#d4f1d4" />
      
      {/* Mystical temple glow lights * /}
      <pointLight position={[0, 15, -35]} intensity={3} color="#87ceeb" distance={60} />
      <pointLight position={[-20, 12, -40]} intensity={2.5} color="#ffd700" distance={50} />
      <pointLight position={[20, 10, -30]} intensity={2.5} color="#dda0dd" distance={50} />
      
      {/* River reflection light * /}
      <pointLight position={[0, 5, -20]} intensity={1.5} color="#4682b4" distance={40} />

      {/* === COSMIC SKY === * /}
      
      {/* Deep space background * /}
      {/* <mesh position={[0, 0, -100]}>
        <sphereGeometry args={[150, 32, 32]} />
        <meshBasicMaterial
          color="#0a0520"
          side={THREE.BackSide}
        />
      </mesh> * /}

      {/* Cosmic nebulae layers * /}
      <group ref={cosmicSkyRef}>
        <mesh position={[30, 40, -90]}>
          <sphereGeometry args={[45, 24, 24]} />
          <meshBasicMaterial
            color="#4b0082"
            transparent
            opacity={0.2}
            side={THREE.BackSide}
          />
        </mesh>

        <mesh position={[-35, 35, -85]}>
          <sphereGeometry args={[38, 24, 24]} />
          <meshBasicMaterial
            color="#191970"
            transparent
            opacity={0.18}
            side={THREE.BackSide}
          />
        </mesh>

        <mesh position={[0, 50, -95]}>
          <sphereGeometry args={[50, 24, 24]} />
          <meshBasicMaterial
            color="#1e3a8a"
            transparent
            opacity={0.15}
            side={THREE.BackSide}
          />
        </mesh>
      </group>

      {/* Galaxy spiral effect * /}
      {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
        const angle = (i / 8) * Math.PI * 2;
        const radius = 60 + i * 8;
        return (
          <mesh
            key={`galaxy-${i}`}
            position={[
              Math.cos(angle) * radius,
              45 + Math.sin(i * 2) * 10,
              Math.sin(angle) * radius - 85
            ]}
          >
            <sphereGeometry args={[3, 16, 16]} />
            <meshBasicMaterial
              color={['#4169e1', '#9370db', '#dda0dd', '#87ceeb'][i % 4]}
              transparent
              opacity={0.6}
            />
          </mesh>
        );
      })}

      {/* Aurora Borealis * /}
      <mesh ref={auroraRef} position={[0, 35, -70]} rotation={[Math.PI / 5, 0, 0]}>
        <planeGeometry args={[140, 50, 20, 10]} />
        <meshBasicMaterial
          color="#00ff88"
          transparent
          opacity={0.3}
          side={THREE.DoubleSide}
        />
      </mesh>

      <mesh position={[30, 38, -75]} rotation={[Math.PI / 4, 0, 0]}>
        <planeGeometry args={[100, 45, 15, 8]} />
        <meshBasicMaterial
          color="#4169e1"
          transparent
          opacity={0.25}
          side={THREE.DoubleSide}
        />
      </mesh>

      {/* === TERRAIN & LANDSCAPE === * /}
      
      <group ref={terrainRef}>
        {/* Main hillside terrain * /}
        <mesh position={[0, -15, -40]} rotation={[-Math.PI / 2, 0, 0]}>
          <planeGeometry args={[120, 120, 30, 30]} />
          <meshStandardMaterial
            color="#2d5016"
            roughness={0.9}
            metalness={0.1}
          />
        </mesh>

        {/* Hillside elevation * /}
        {[0, 1, 2, 3, 4].map((i) => (
          <mesh
            key={`hill-${i}`}
            position={[(i - 2) * 15, -12 + i * 2, -45 - i * 8]}
            rotation={[-Math.PI / 2, 0, 0]}
          >
            <circleGeometry args={[12, 32]} />
            <meshStandardMaterial
              color="#3d6b1f"
              roughness={0.85}
            />
          </mesh>
        ))}
      </group>

      {/* === LUSH FOREST === * /}
      
      <group ref={foliageRef}>
        {/* Ancient massive trees * /}
        {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => {
          const angle = (i / 10) * Math.PI * 2;
          const radius = 25 + (i % 3) * 10;
          return (
            <group
              key={`tree-${i}`}
              position={[
                Math.cos(angle) * radius,
                -8,
                Math.sin(angle) * radius - 35
              ]}
            >
              {/* Trunk * /}
              <mesh>
                <cylinderGeometry args={[2, 2.5, 25, 12]} />
                <meshStandardMaterial
                  color="#4a3520"
                  roughness={0.95}
                />
              </mesh>
              
              {/* Canopy * /}
              <mesh position={[0, 15, 0]}>
                <sphereGeometry args={[8, 12, 12]} />
                <meshStandardMaterial
                  color="#2d5016"
                  emissive="#3d6b1f"
                  emissiveIntensity={0.3}
                  roughness={0.8}
                />
              </mesh>

              {/* Glowing tree heart (spiritual energy) * /}
              <mesh position={[0, 5, 0]}>
                <sphereGeometry args={[0.5, 12, 12]} />
                <meshStandardMaterial
                  color="#ffd700"
                  emissive="#ffd700"
                  emissiveIntensity={2}
                />
                <pointLight position={[0, 0, 0]} intensity={1.5} color="#ffd700" distance={15} />
              </mesh>
            </group>
          );
        })}

        {/* Smaller trees and vegetation * /}
        {Array.from({ length: 20 }).map((_, i) => (
          <group
            key={`small-tree-${i}`}
            position={[
              (Math.random() - 0.5) * 80,
              -10,
              (Math.random() - 0.5) * 80 - 40
            ]}
          >
            <mesh>
              <cylinderGeometry args={[0.5, 0.8, 8, 8]} />
              <meshStandardMaterial color="#4a3520" roughness={0.9} />
            </mesh>
            <mesh position={[0, 5, 0]}>
              <sphereGeometry args={[3, 8, 8]} />
              <meshStandardMaterial
                color="#228b22"
                roughness={0.85}
              />
            </mesh>
          </group>
        ))}
      </group>

      {/* === CRYSTAL TEMPLES & GOLDEN SPIRES === * /}
      
      <group ref={crystalTemplesRef}>
        {/* Central main temple * /}
        <group position={[0, 0, -35]}>
          {/* Crystal base * /}
          <mesh position={[0, -2, 0]}>
            <cylinderGeometry args={[6, 8, 4, 8]} />
            <meshStandardMaterial
              color="#f5deb3"
              roughness={0.5}
              metalness={0.2}
            />
          </mesh>

          {/* Main crystal structure * /}
          <mesh position={[0, 3, 0]}>
            <octahedronGeometry args={[5, 0]} />
            <meshStandardMaterial
              color="#87ceeb"
              transparent
              opacity={0.8}
              metalness={0.9}
              roughness={0.1}
              emissive="#87ceeb"
              emissiveIntensity={1.2}
            />
          </mesh>

          {/* Golden spire * /}
          <mesh position={[0, 12, 0]}>
            <coneGeometry args={[0.8, 12, 8]} />
            <meshStandardMaterial
              color="#ffd700"
              metalness={1}
              roughness={0.1}
              emissive="#ffd700"
              emissiveIntensity={1.5}
            />
            <pointLight position={[0, 6, 0]} intensity={4} color="#ffd700" distance={30} />
          </mesh>
        </group>

        {/* Side temples * /}
        {[-15, 15].map((x, idx) => (
          <group key={`side-temple-${idx}`} position={[x, -3, -40]}>
            <mesh position={[0, 2, 0]}>
              <octahedronGeometry args={[3, 0]} />
              <meshStandardMaterial
                color={idx === 0 ? "#dda0dd" : "#98ff98"}
                transparent
                opacity={0.75}
                metalness={0.8}
                roughness={0.2}
                emissive={idx === 0 ? "#dda0dd" : "#98ff98"}
                emissiveIntensity={1}
              />
            </mesh>
            <mesh position={[0, 7, 0]}>
              <coneGeometry args={[0.5, 8, 6]} />
              <meshStandardMaterial
                color="#ffd700"
                metalness={1}
                roughness={0.1}
                emissive="#ffd700"
                emissiveIntensity={1.2}
              />
            </mesh>
          </group>
        ))}

        {/* Small crystal formations scattered * /}
        {Array.from({ length: 12 }).map((_, i) => {
          const angle = (i / 12) * Math.PI * 2;
          const radius = 35 + (i % 3) * 8;
          return (
            <mesh
              key={`crystal-${i}`}
              position={[
                Math.cos(angle) * radius,
                -6,
                Math.sin(angle) * radius - 35
              ]}
              rotation={[0, Math.random() * Math.PI, 0]}
            >
              <octahedronGeometry args={[1.2, 0]} />
              <meshStandardMaterial
                color={['#87ceeb', '#ffd700', '#dda0dd', '#98ff98'][i % 4]}
                emissive={['#87ceeb', '#ffd700', '#dda0dd', '#98ff98'][i % 4]}
                emissiveIntensity={1.5}
                transparent
                opacity={0.85}
                metalness={0.9}
                roughness={0.1}
              />
            </mesh>
          );
        })}
      </group>

      {/* === TREE HOUSES === * /}
      
      <group ref={treeHousesRef}>
        {[0, 1, 2, 3, 4].map((i) => {
          const angle = (i / 5) * Math.PI * 2 + 0.5;
          const radius = 28;
          return (
            <group
              key={`treehouse-${i}`}
              position={[
                Math.cos(angle) * radius,
                8,
                Math.sin(angle) * radius - 35
              ]}
            >
              {/* House structure * /}
              <mesh>
                <boxGeometry args={[4, 3, 4]} />
                <meshStandardMaterial
                  color="#d2691e"
                  roughness={0.8}
                />
              </mesh>
              
              {/* Roof * /}
              <mesh position={[0, 2.5, 0]}>
                <coneGeometry args={[3, 2, 4]} />
                <meshStandardMaterial
                  color="#8b4513"
                  roughness={0.9}
                />
              </mesh>

              {/* Glowing window * /}
              <mesh position={[0, 0, 2.1]}>
                <planeGeometry args={[1.5, 1.5]} />
                <meshBasicMaterial
                  color="#ffd700"
                  emissive="#ffd700"
                  emissiveIntensity={2}
                />
                <pointLight position={[0, 0, 0.5]} intensity={1} color="#ffd700" distance={8} />
              </mesh>
            </group>
          );
        })}
      </group>

      {/* === PRISTINE RIVER === * /}
      
      {/* Main river body * /}
      <mesh ref={riverRef} position={[0, -10, -20]} rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[15, 80, 20, 40]} />
        <meshStandardMaterial
          color="#4682b4"
          transparent
          opacity={0.7}
          metalness={0.9}
          roughness={0.1}
          emissive="#87ceeb"
          emissiveIntensity={0.3}
          map={createWaterTexture()}
        />
      </mesh>

      {/* Waterfall * /}
      <mesh ref={waterfallRef} position={[0, -5, -50]} rotation={[Math.PI / 4, 0, 0]}>
        <planeGeometry args={[8, 12, 10, 20]} />
        <meshBasicMaterial
          color="#e0ffff"
          transparent
          opacity={0.6}
          map={createWaterTexture()}
        />
      </mesh>

      {/* River stones * /}
      {Array.from({ length: 15 }).map((_, i) => (
        <mesh
          key={`stone-${i}`}
          position={[
            (Math.random() - 0.5) * 12,
            -9.5,
            (Math.random() - 0.5) * 70 - 20
          ]}
        >
          <sphereGeometry args={[0.5 + Math.random(), 8, 8]} />
          <meshStandardMaterial
            color="#696969"
            roughness={0.8}
          />
        </mesh>
      ))}

      {/* === GLOWING SIDDHAS & ASCENDED MASTERS === * /}
      
      <group ref={siddhasRef}>
        {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
          const angle = (i / 8) * Math.PI * 2;
          const radius = 15 + (i % 2) * 8;
          return (
            <group
              key={`siddha-${i}`}
              position={[
                Math.cos(angle) * radius,
                2,
                Math.sin(angle) * radius - 30
              ]}
            >
              {/* Body (simplified humanoid form) * /}
              <mesh position={[0, 1, 0]}>
                <capsuleGeometry args={[0.5, 2, 8, 16]} />
                <meshStandardMaterial
                  color="#fff8dc"
                  emissive="#ffd700"
                  emissiveIntensity={1.8}
                  transparent
                  opacity={0.85}
                />
              </mesh>

              {/* Head * /}
              <mesh position={[0, 3, 0]}>
                <sphereGeometry args={[0.6, 12, 12]} />
                <meshStandardMaterial
                  color="#fff8dc"
                  emissive="#ffffff"
                  emissiveIntensity={2}
                  transparent
                  opacity={0.9}
                />
              </mesh>

              {/* Aura * /}
              <mesh position={[0, 1.5, 0]}>
                <sphereGeometry args={[2, 16, 16]} />
                <meshBasicMaterial
                  color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]}
                  transparent
                  opacity={0.2}
                />
              </mesh>

              {/* Point light emanating from Siddha * /}
              <pointLight
                position={[0, 2, 0]}
                intensity={2.5}
                color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]}
                distance={15}
              />

              {/* Meditation pose indicator (lotus position effect) * /}
              <mesh position={[0, 0, 0]} rotation={[-Math.PI / 2, 0, 0]}>
                <torusGeometry args={[0.8, 0.1, 8, 16]} />
                <meshBasicMaterial
                  color="#ffd700"
                  transparent
                  opacity={0.6}
                />
              </mesh>
            </group>
          );
        })}
      </group>

      {/* === ATMOSPHERIC PARTICLES (Pollen, Light Motes) === * /}
      
      <points ref={particlesRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={particleCount}
            array={particlePositions}
            itemSize={3}
          />
          <bufferAttribute
            attach="attributes-color"
            count={particleCount}
            array={particleColors}
            itemSize={3}
          />
          <bufferAttribute
            attach="attributes-size"
            count={particleCount}
            array={particleSizes}
            itemSize={1}
          />
        </bufferGeometry>
        <pointsMaterial
          size={1.5}
          vertexColors
          transparent
          opacity={0.8}
          sizeAttenuation
          blending={THREE.AdditiveBlending}
        />
      </points>

      {/* === VOLUMETRIC GOD RAYS === * /}
      
      <group ref={godRaysRef}>
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <mesh
            key={`godray-${i}`}
            position={[
              (i - 2.5) * 12,
              25,
              -35
            ]}
            rotation={[0, 0, (i - 2.5) * 0.15]}
          >
            <coneGeometry args={[2, 40, 4]} />
            <meshBasicMaterial
              color="#ffd700"
              transparent
              opacity={0.15}
            />
          </mesh>
        ))}
      </group>

      {/* === FLYING BIRDS === * /}
      
      <group ref={birdsRef}>
        {[0, 1, 2, 3, 4].map((i) => (
          <group key={`bird-${i}`}>
            <mesh>
              <coneGeometry args={[0.3, 1, 3]} />
              <meshBasicMaterial color="#ffffff" />
            </mesh>
            <mesh position={[-0.5, 0, 0]} rotation={[0, 0, Math.PI / 6]}>
              <planeGeometry args={[1, 0.3]} />
              <meshBasicMaterial color="#ffffff" side={THREE.DoubleSide} />
            </mesh>
            <mesh position={[0.5, 0, 0]} rotation={[0, 0, -Math.PI / 6]}>
              <planeGeometry args={[1, 0.3]} />
              <meshBasicMaterial color="#ffffff" side={THREE.DoubleSide} />
            </mesh>
          </group>
        ))}
      </group>

      {/* === MYSTICAL ENERGY ORBS FLOATING === * /}
      
      {Array.from({ length: 10 }).map((_, i) => {
        const angle = (i / 10) * Math.PI * 2;
        const radius = 40;
        return (
          <mesh
            key={`energy-orb-${i}`}
            position={[
              Math.cos(angle) * radius,
              10 + Math.sin(i * 3) * 5,
              Math.sin(angle) * radius - 35
            ]}
          >
            <sphereGeometry args={[0.8, 12, 12]} />
            <meshBasicMaterial
              color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]}
              transparent
              opacity={0.6}
            />
            <pointLight
              position={[0, 0, 0]}
              intensity={1.5}
              color={['#ffd700', '#87ceeb', '#dda0dd', '#98ff98'][i % 4]}
              distance={12}
            />
          </mesh>
        );
      })}

      {/* === FOREST FLOOR VEGETATION === * /}
      
      {Array.from({ length: 30 }).map((_, i) => (
        <group
          key={`vegetation-${i}`}
          position={[
            (Math.random() - 0.5) * 90,
            -10,
            (Math.random() - 0.5) * 90 - 35
          ]}
        >
          {/* Grass * /}
          <mesh>
            <coneGeometry args={[0.3, 2, 4]} />
            <meshStandardMaterial
              color="#228b22"
              roughness={0.9}
            />
          </mesh>
          
          {/* Flowers * /}
          {Math.random() > 0.6 && (
            <mesh position={[0, 1, 0]}>
              <sphereGeometry args={[0.15, 6, 6]} />
              <meshBasicMaterial
                color={['#ff69b4', '#ffd700', '#87ceeb', '#dda0dd'][i % 4]}
                emissive={['#ff69b4', '#ffd700', '#87ceeb', '#dda0dd'][i % 4]}
                emissiveIntensity={1}
              />
            </mesh>
          )}
        </group>
      ))}
    </>
  );
}

// Helper function to create water texture
function createWaterTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  
  // Create wavy water pattern
  const gradient = ctx.createLinearGradient(0, 0, 512, 512);
  gradient.addColorStop(0, 'rgba(70, 130, 180, 0.8)');
  gradient.addColorStop(0.5, 'rgba(135, 206, 235, 0.9)');
  gradient.addColorStop(1, 'rgba(70, 130, 180, 0.8)');
  
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 512, 512);
  
  // Add shimmer effect
  for (let i = 0; i < 50; i++) {
    ctx.beginPath();
    ctx.arc(
      Math.random() * 512,
      Math.random() * 512,
      Math.random() * 3,
      0,
      Math.PI * 2
    );
    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.fill();
  }
  
  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(4, 4);
  return texture;
}
*/