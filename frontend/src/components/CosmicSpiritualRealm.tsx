// @ts-nocheck
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import React, { useMemo } from "react";


// ==================== COSMIC SPIRITUAL REALM ====================
export function CosmicSpiritualRealm() {
  const particlesRef = useRef(null);
  const cosmicRaysRef = useRef(null);
  const nebula1Ref = useRef(null);
  const nebula2Ref = useRef(null);
  const nebula3Ref = useRef(null);
  const groupRef = useRef(null);

  // Reduced particle count for performance
  const particleCount = 300;
  const particles = useRef([]);
  
  const rayCount = 20;
  const rays = useRef([]);

  if (particles.current.length === 0) {
    // Create particles
    for (let i = 0; i < particleCount; i++) {
      const radius = 15 + Math.random() * 70;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      
      const position = [
        radius * Math.sin(phi) * Math.cos(theta),
        radius * Math.sin(phi) * Math.sin(theta),
        radius * Math.cos(phi) - 40
      ];
      
      const velocity = {
        x: (Math.random() - 0.5) * 0.02,
        y: (Math.random() - 0.5) * 0.02,
        z: (Math.random() - 0.5) * 0.01
      };
      
      const colorType = Math.random();
      let color, size;
      
      if (colorType < 0.15) {
        color = '#ffffff';
        size = Math.random() * 0.5 + 0.3;
      } else if (colorType < 0.35) {
        color = '#4169e1';
        size = Math.random() * 0.4 + 0.25;
      } else if (colorType < 0.55) {
        color = '#9370db';
        size = Math.random() * 0.5 + 0.2;
      } else if (colorType < 0.75) {
        color = '#ffd700';
        size = Math.random() * 0.4 + 0.25;
      } else {
        color = '#87ceeb';
        size = Math.random() * 0.35 + 0.2;
      }
      
      particles.current.push({
        position,
        color,
        size,
        velocity: { current: velocity },
        id: `particle-${i}`
      });
    }

    // Create cosmic rays
    for (let i = 0; i < rayCount; i++) {
      const angle = Math.random() * Math.PI * 2;
      const height = (Math.random() - 0.5) * 60;
      const distance = 30 + Math.random() * 50;
      
      const position = [
        Math.cos(angle) * distance,
        height,
        Math.sin(angle) * distance - 40
      ];
      
      const speed = 0.1 + Math.random() * 0.15;
      const velocity = {
        x: Math.cos(angle) * speed,
        y: (Math.random() - 0.5) * 0.05,
        z: Math.sin(angle) * speed
      };
      
      const rayColorType = Math.random();
      let color;
      
      if (rayColorType < 0.3) {
        color = '#e0ffff';
      } else if (rayColorType < 0.6) {
        color = '#ffd700';
      } else {
        color = '#ff69b4';
      }
      
      rays.current.push({
        position,
        color,
        velocity: { current: velocity },
        id: `ray-${i}`
      });
    }
  }

  useFrame(({ clock, scene }) => {
    const t = clock.getElapsedTime();
    
    scene.background = new THREE.Color('#050215');

    // Animate particle group rotation
    if (groupRef.current) {
      groupRef.current.rotation.y = t * 0.008;
    }

    // Animate individual particles
    if (particlesRef.current && particlesRef.current.children) {
      particlesRef.current.children.forEach((particle, i) => {
        const data = particles.current[i];
        if (!particle || !data) return;
        
        // Apply velocity
        particle.position.x += data.velocity.current.x;
        particle.position.y += data.velocity.current.y;
        particle.position.z += data.velocity.current.z;
        
        // Gentle pulsing
        const pulse = Math.sin(t * 0.5 + i * 0.1) * 0.02;
        const dist = Math.sqrt(
          particle.position.x ** 2 +
          particle.position.y ** 2 +
          particle.position.z ** 2
        );
        
        if (dist < 85) {
          particle.position.x += (particle.position.x / dist) * pulse;
          particle.position.y += (particle.position.y / dist) * pulse;
          particle.position.z += (particle.position.z / dist) * pulse;
        } else {
          // Respawn at center
          const newRadius = 15 + Math.random() * 10;
          const theta = Math.random() * Math.PI * 2;
          const phi = Math.acos(2 * Math.random() - 1);
          
          particle.position.x = newRadius * Math.sin(phi) * Math.cos(theta);
          particle.position.y = newRadius * Math.sin(phi) * Math.sin(theta);
          particle.position.z = newRadius * Math.cos(phi) - 40;
        }
        
        // Glow pulsing
        const glowPulse = Math.sin(t * 0.7 + i * 0.2) * 0.3 + 1.2;
        if (particle.material && particle.material.emissiveIntensity !== undefined) {
          particle.material.emissiveIntensity = glowPulse;
        }
      });
    }

    // Animate cosmic rays
    if (cosmicRaysRef.current && cosmicRaysRef.current.children) {
      cosmicRaysRef.current.children.forEach((rayGroup, i) => {
        const data = rays.current[i];
        if (!rayGroup || !data) return;
        
        const ray = rayGroup.children[0];
        if (!ray) return;
        
        rayGroup.position.x += data.velocity.current.x;
        rayGroup.position.y += data.velocity.current.y;
        rayGroup.position.z += data.velocity.current.z;
        
        const dist = Math.sqrt(
          rayGroup.position.x ** 2 +
          rayGroup.position.y ** 2 +
          (rayGroup.position.z + 40) ** 2
        );
        
        if (dist > 80) {
          const angle = Math.random() * Math.PI * 2;
          const startRadius = 5 + Math.random() * 10;
          
          rayGroup.position.x = Math.cos(angle) * startRadius;
          rayGroup.position.y = (Math.random() - 0.5) * 20;
          rayGroup.position.z = Math.sin(angle) * startRadius - 40;
          
          const speed = 0.1 + Math.random() * 0.15;
          data.velocity.current.x = Math.cos(angle) * speed;
          data.velocity.current.y = (Math.random() - 0.5) * 0.05;
          data.velocity.current.z = Math.sin(angle) * speed;
        }
        
        const angle = Math.atan2(data.velocity.current.z, data.velocity.current.x);
        ray.rotation.y = angle;
      });
    }

    // Update nebulas
    [nebula1Ref, nebula2Ref, nebula3Ref].forEach((ref, i) => {
      if (ref.current) {
        const pulse = Math.sin(t * 0.4 + i * 2) * 0.2 + 0.85;
        ref.current.scale.setScalar(pulse);
        ref.current.rotation.z = t * (0.02 + i * 0.01);
      }
    });
  });

  return (
    <group ref={groupRef}>
      <ambientLight intensity={0.3} color="#1a0a3e" />
      <pointLight position={[0, 30, -20]} intensity={5} color="#ffd700" distance={120} decay={2} />
      <pointLight position={[-30, 20, -40]} intensity={4} color="#9370db" distance={100} decay={2} />
      <pointLight position={[30, 15, -30]} intensity={4} color="#4169e1" distance={100} decay={2} />
      <pointLight position={[0, -20, -50]} intensity={3} color="#ff69b4" distance={90} decay={2} />

      {/* 3D SPHERICAL PARTICLES */}
      <group ref={particlesRef}>
        {particles.current.map((particle) => (
          <mesh key={particle.id} position={particle.position}>
            <sphereGeometry args={[particle.size, 6, 6]} />
            <meshStandardMaterial
              color={particle.color}
              emissive={particle.color}
              emissiveIntensity={1.5}
              transparent
              opacity={0.9}
              metalness={0.3}
              roughness={0.3}
            />
          </mesh>
        ))}
      </group>

      {/* COSMIC RAY STREAKS */}
      <group ref={cosmicRaysRef}>
        {rays.current.map((ray) => (
          <group key={ray.id} position={ray.position}>
            <mesh scale={[2, 0.5, 0.5]}>
              <sphereGeometry args={[0.5, 6, 6]} />
              <meshBasicMaterial
                color={ray.color}
                transparent
                opacity={0.85}
              />
            </mesh>
            <pointLight intensity={1.5} color={ray.color} distance={10} />
          </group>
        ))}
      </group>

      {/* Ethereal nebulas */}
      <mesh ref={nebula1Ref} position={[0, 10, -90]}>
        <sphereGeometry args={[50, 16, 16]} />
        <meshBasicMaterial color="#1a0a4e" transparent opacity={0.2} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula2Ref} position={[35, 20, -100]}>
        <sphereGeometry args={[40, 16, 16]} />
        <meshBasicMaterial color="#4b0082" transparent opacity={0.18} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula3Ref} position={[-30, 15, -95]}>
        <sphereGeometry args={[45, 16, 16]} />
        <meshBasicMaterial color="#191970" transparent opacity={0.18} side={THREE.BackSide} />
      </mesh>

      {/* Floating energy spheres */}
      {[0, 1, 2, 3, 4, 5].map((i) => (
        <mesh
          key={`glow-${i}`}
          position={[
            (Math.random() - 0.5) * 60,
            (Math.random() - 0.5) * 40,
            -30 - Math.random() * 40
          ]}
        >
          <sphereGeometry args={[1.5, 8, 8]} />
          <meshBasicMaterial
            color={['#ffd700', '#9370db', '#4169e1', '#ff69b4', '#00ced1', '#dda0dd'][i]}
            transparent
            opacity={0.5}
          />
        </mesh>
      ))}
    </group>
  );
}
