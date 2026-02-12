// @ts-nocheck - Disable type checking for Three.js/R3F elements
// @ts-nocheck - Disable type checking for Three.js/R3F elements// @ts-nocheck
// @ts-nocheck
// @ts-nocheck
// @ts-nocheck
import { useState, useEffect, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { XRApp } from './features/xr/XRApp';
import * as THREE from 'three';
import guruImage from './assets/Jeeth-Blessing.png';  // ← Add this import
import { ShambhalaRealm } from './components/ShambhalaRealm';
import React, { useMemo } from "react";


function CosmicSpiritualRealm() {
  const particlesRef = useRef(null);
  const cosmicRaysRef = useRef(null);
  const auroraRef = useRef(null);
  const spiritBeingsRef = useRef(null);
  const sacredGeometryRef = useRef(null);
  const nebula1Ref = useRef(null);
  const nebula2Ref = useRef(null);
  const nebula3Ref = useRef(null);
  const energyFieldRef = useRef(null);
  const frameCount = useRef(0);

  // Reduced particle count for better performance
  const particleCount = 2000; // Reduced from 3000
  const positions = new Float32Array(particleCount * 3);
  const colors = new Float32Array(particleCount * 3);
  const sizes = new Float32Array(particleCount);
  const velocities = new Float32Array(particleCount * 3);

  // CREATE TEXTURES ONCE
  const circleTexture = useMemo(() => createCircleTexture(), []);
  const streakTexture = useMemo(() => createStreakTexture(), []);


  for (let i = 0; i < particleCount; i++) {
    const radius = 15 + Math.random() * 70;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    
    positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = radius * Math.cos(phi) - 40;
    
    velocities[i * 3] = (Math.random() - 0.5) * 0.02;
    velocities[i * 3 + 1] = (Math.random() - 0.5) * 0.02;
    velocities[i * 3 + 2] = (Math.random() - 0.5) * 0.01;
    
    const colorType = Math.random();
    if (colorType < 0.15) {
      colors[i * 3] = 1;
      colors[i * 3 + 1] = 1;
      colors[i * 3 + 2] = 1;
      sizes[i] = Math.random() * 3 + 2;
    } else if (colorType < 0.35) {
      colors[i * 3] = 0.2 + Math.random() * 0.3;
      colors[i * 3 + 1] = 0.4 + Math.random() * 0.4;
      colors[i * 3 + 2] = 0.9 + Math.random() * 0.1;
      sizes[i] = Math.random() * 2 + 1;
    } else if (colorType < 0.55) {
      colors[i * 3] = 0.6 + Math.random() * 0.3;
      colors[i * 3 + 1] = 0.2 + Math.random() * 0.3;
      colors[i * 3 + 2] = 0.8 + Math.random() * 0.2;
      sizes[i] = Math.random() * 2.5 + 0.8;
    } else if (colorType < 0.75) {
      colors[i * 3] = 1;
      colors[i * 3 + 1] = 0.7 + Math.random() * 0.3;
      colors[i * 3 + 2] = 0.2 + Math.random() * 0.3;
      sizes[i] = Math.random() * 2 + 1.2;
    } else {
      colors[i * 3] = 0.3 + Math.random() * 0.3;
      colors[i * 3 + 1] = 0.8 + Math.random() * 0.2;
      colors[i * 3 + 2] = 0.9 + Math.random() * 0.1;
      sizes[i] = Math.random() * 1.8 + 0.7;
    }
  }

  // Reduced ray count for better performance
  const rayCount = 80; // Reduced from 150
  const rayPositions = new Float32Array(rayCount * 3);
  const rayColors = new Float32Array(rayCount * 3);
  const raySizes = new Float32Array(rayCount);
  const rayVelocities = new Float32Array(rayCount * 3);

  for (let i = 0; i < rayCount; i++) {
    const angle = Math.random() * Math.PI * 2;
    const height = (Math.random() - 0.5) * 60;
    const distance = 30 + Math.random() * 50;
    
    rayPositions[i * 3] = Math.cos(angle) * distance;
    rayPositions[i * 3 + 1] = height;
    rayPositions[i * 3 + 2] = Math.sin(angle) * distance - 40;
    
    const speed = 0.1 + Math.random() * 0.15;
    rayVelocities[i * 3] = Math.cos(angle) * speed;
    rayVelocities[i * 3 + 1] = (Math.random() - 0.5) * 0.05;
    rayVelocities[i * 3 + 2] = Math.sin(angle) * speed;
    
    const rayColorType = Math.random();
    if (rayColorType < 0.3) {
      rayColors[i * 3] = 0.9 + Math.random() * 0.1;
      rayColors[i * 3 + 1] = 0.95 + Math.random() * 0.05;
      rayColors[i * 3 + 2] = 1;
    } else if (rayColorType < 0.6) {
      rayColors[i * 3] = 1;
      rayColors[i * 3 + 1] = 0.8 + Math.random() * 0.2;
      rayColors[i * 3 + 2] = 0.3 + Math.random() * 0.2;
    } else {
      rayColors[i * 3] = 0.9 + Math.random() * 0.1;
      rayColors[i * 3 + 1] = 0.3 + Math.random() * 0.3;
      rayColors[i * 3 + 2] = 0.9 + Math.random() * 0.1;
    }
    
    raySizes[i] = Math.random() * 8 + 4;
  }

  useFrame(({ clock, scene }) => {
    const t = clock.getElapsedTime();
    frameCount.current++;
    
    scene.background = new THREE.Color('#050215');

    // Update particles every frame
    if (particlesRef.current) {
      const positions = particlesRef.current.geometry.attributes.position.array;
      
      // Optimized loop - pre-calculate common values
      const pulse = Math.sin(t * 0.5) * 0.03;
      
      for (let i = 0; i < particleCount; i++) {
        const i3 = i * 3;
        
        // Simplified distance calculation
        const x = positions[i3];
        const y = positions[i3 + 1];
        const z = positions[i3 + 2];
        const distSq = x * x + y * y + z * z;
        
        // Only update if distance squared is below threshold (avoids sqrt)
        if (distSq < 7225) { // 85^2
          const invDist = 1 / Math.sqrt(distSq);
          const pulseVal = pulse * (Math.sin(i * 0.1) > 0 ? 1 : -1); // Alternate direction
          
          positions[i3] += velocities[i3] + x * invDist * pulseVal;
          positions[i3 + 1] += velocities[i3 + 1] + y * invDist * pulseVal;
          positions[i3 + 2] += velocities[i3 + 2] + z * invDist * pulseVal;
        } else {
          // Respawn near center
          const newRadius = 15 + Math.random() * 10;
          const theta = Math.random() * Math.PI * 2;
          const phi = Math.acos(2 * Math.random() - 1);
          
          positions[i3] = newRadius * Math.sin(phi) * Math.cos(theta);
          positions[i3 + 1] = newRadius * Math.sin(phi) * Math.sin(theta);
          positions[i3 + 2] = newRadius * Math.cos(phi) - 40;
        }
      }
      
      particlesRef.current.geometry.attributes.position.needsUpdate = true;
      particlesRef.current.rotation.y = t * 0.01;
    }

    // Update cosmic rays every frame (they're fewer so less expensive)
    if (cosmicRaysRef.current) {
      const positions = cosmicRaysRef.current.geometry.attributes.position.array;
      
      for (let i = 0; i < rayCount; i++) {
        const i3 = i * 3;
        
        positions[i3] += rayVelocities[i3];
        positions[i3 + 1] += rayVelocities[i3 + 1];
        positions[i3 + 2] += rayVelocities[i3 + 2];
        
        const x = positions[i3];
        const y = positions[i3 + 1];
        const z = positions[i3 + 2] + 40;
        const distSq = x * x + y * y + z * z;
        
        if (distSq > 6400) { // 80^2
          const angle = Math.random() * Math.PI * 2;
          const startRadius = 5 + Math.random() * 10;
          
          positions[i3] = Math.cos(angle) * startRadius;
          positions[i3 + 1] = (Math.random() - 0.5) * 20;
          positions[i3 + 2] = Math.sin(angle) * startRadius - 40;
          
          const speed = 0.1 + Math.random() * 0.15;
          rayVelocities[i3] = Math.cos(angle) * speed;
          rayVelocities[i3 + 1] = (Math.random() - 0.5) * 0.05;
          rayVelocities[i3 + 2] = Math.sin(angle) * speed;
        }
      }
      
      cosmicRaysRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Update less critical animations every other frame
    const updateSlowAnimations = frameCount.current % 2 === 0;
    
    if (updateSlowAnimations) {
      if (auroraRef.current) {
        auroraRef.current.rotation.z = Math.sin(t * 0.2) * 0.15;
        auroraRef.current.position.y = 25 + Math.sin(t * 0.3) * 3;
        auroraRef.current.material.opacity = 0.25 + Math.sin(t * 0.5) * 0.1;
      }

      if (spiritBeingsRef.current) {
        spiritBeingsRef.current.children.forEach((being, i) => {
          being.position.y = 5 + Math.sin(t * 0.4 + i * 1.5) * 2;
          being.rotation.y = t * 0.15 + i;
          const pulse = Math.sin(t * 0.8 + i) * 0.5 + 1.5;
          if (being.material && being.material.emissiveIntensity !== undefined) {
            being.material.emissiveIntensity = pulse;
          }
        });
      }

      [nebula1Ref, nebula2Ref, nebula3Ref].forEach((ref, i) => {
        if (ref.current) {
          const pulse = Math.sin(t * 0.4 + i * 2) * 0.2 + 0.85;
          ref.current.scale.setScalar(pulse);
          ref.current.rotation.z = t * (0.02 + i * 0.01);
        }
      });
    }

    // Update geometry rotation every 3rd frame
    if (frameCount.current % 3 === 0) {
      if (sacredGeometryRef.current) {
        sacredGeometryRef.current.rotation.x = t * 0.08;
        sacredGeometryRef.current.rotation.y = t * 0.12;
        sacredGeometryRef.current.rotation.z = t * 0.04;
      }

      if (energyFieldRef.current) {
        energyFieldRef.current.rotation.y = t * 0.05;
        energyFieldRef.current.children.forEach((ring, i) => {
          ring.rotation.x = t * (0.1 + i * 0.05);
          ring.rotation.z = t * (0.08 + i * 0.03);
        });
      }
    }
  });

  return (
    <>
      <ambientLight intensity={0.3} color="#1a0a3e" />
      <pointLight position={[0, 30, -20]} intensity={6} color="#ffd700" distance={120} decay={2} />
      <pointLight position={[-30, 20, -40]} intensity={5} color="#9370db" distance={100} decay={2} />
      <pointLight position={[30, 15, -30]} intensity={5} color="#4169e1" distance={100} decay={2} />
      <pointLight position={[0, -20, -50]} intensity={4} color="#ff69b4" distance={90} decay={2} />

      <points ref={particlesRef}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" count={particleCount} array={positions} itemSize={3} />
          <bufferAttribute attach="attributes-color" count={particleCount} array={colors} itemSize={3} />
          <bufferAttribute attach="attributes-size" count={particleCount} array={sizes} itemSize={1} />
        </bufferGeometry>
        <pointsMaterial
          size={2}
          vertexColors
          transparent
          opacity={0.9}
          sizeAttenuation
          blending={THREE.AdditiveBlending}
          map={circleTexture}
        />
      </points>

      <points ref={cosmicRaysRef}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" count={rayCount} array={rayPositions} itemSize={3} />
          <bufferAttribute attach="attributes-color" count={rayCount} array={rayColors} itemSize={3} />
          <bufferAttribute attach="attributes-size" count={rayCount} array={raySizes} itemSize={1} />
        </bufferGeometry>
        <pointsMaterial
          size={6}
          vertexColors
          transparent
          opacity={0.7}
          sizeAttenuation
          blending={THREE.AdditiveBlending}
          map={streakTexture}
        />
      </points>

      <mesh ref={nebula1Ref} position={[0, 10, -60]}>
        <sphereGeometry args={[40, 24, 24]} />
        <meshBasicMaterial color="#1a0a4e" transparent opacity={0.18} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula2Ref} position={[35, 20, -70]}>
        <sphereGeometry args={[30, 24, 24]} />
        <meshBasicMaterial color="#4b0082" transparent opacity={0.15} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula3Ref} position={[-30, 15, -65]}>
        <sphereGeometry args={[35, 24, 24]} />
        <meshBasicMaterial color="#191970" transparent opacity={0.16} side={THREE.BackSide} />
      </mesh>

      <mesh ref={auroraRef} position={[0, 25, -55]} rotation={[Math.PI / 6, 0, 0]}>
        <planeGeometry args={[100, 40, 10, 5]} />
        <meshBasicMaterial color="#6366f1" transparent opacity={0.25} side={THREE.DoubleSide} />
      </mesh>

      <mesh position={[20, 28, -60]} rotation={[Math.PI / 5, 0, 0]}>
        <planeGeometry args={[80, 35, 10, 5]} />
        <meshBasicMaterial color="#4169e1" transparent opacity={0.2} side={THREE.DoubleSide} />
      </mesh>

      <mesh position={[-25, 30, -58]} rotation={[Math.PI / 4, 0, 0]}>
        <planeGeometry args={[70, 30, 10, 5]} />
        <meshBasicMaterial color="#8a2be2" transparent opacity={0.18} side={THREE.DoubleSide} />
      </mesh>

      <group ref={spiritBeingsRef}>
        {[0, 1, 2, 3, 4, 5].map((i) => {
          const angle = (i / 6) * Math.PI * 2;
          const radius = 18 + (i % 2) * 8;
          return (
            <mesh key={`spirit-${i}`} position={[Math.cos(angle) * radius, 5, Math.sin(angle) * radius - 35]}>
              <sphereGeometry args={[0.6, 12, 12]} />
              <meshStandardMaterial color="#fff8dc" emissive="#ffd700" emissiveIntensity={1.5} transparent opacity={0.75} />
              <pointLight position={[0, 0, 0]} intensity={2.5} color="#ffd700" distance={12} />
            </mesh>
          );
        })}
      </group>

      <group ref={sacredGeometryRef} position={[0, 10, -50]}>
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <mesh key={`sacred-outer-${i}`} position={[Math.cos((i / 6) * Math.PI * 2) * 4, Math.sin((i / 6) * Math.PI * 2) * 4, 0]}>
            <torusGeometry args={[2.5, 0.08, 12, 24]} />
            <meshBasicMaterial color="#ffd700" transparent opacity={0.5} />
          </mesh>
        ))}
        <mesh>
          <torusGeometry args={[4, 0.12, 12, 24]} />
          <meshBasicMaterial color="#9370db" transparent opacity={0.6} />
        </mesh>
        <mesh>
          <torusGeometry args={[2, 0.1, 12, 24]} />
          <meshBasicMaterial color="#4169e1" transparent opacity={0.55} />
        </mesh>
      </group>

      <group ref={energyFieldRef} position={[0, 0, -40]}>
        {[0, 1, 2, 3].map((i) => (
          <mesh key={`ring-${i}`} rotation={[Math.PI / 2 + i * 0.3, 0, i * 0.5]}>
            <torusGeometry args={[20 + i * 5, 0.3, 12, 48]} />
            <meshBasicMaterial color={['#ffd700', '#9370db', '#4169e1', '#ff69b4'][i]} transparent opacity={0.3} />
          </mesh>
        ))}
      </group>

      {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
        const angle = (i / 8) * Math.PI * 2;
        const radius = 25 + (i % 3) * 10;
        return (
          <mesh
            key={`crystal-${i}`}
            position={[Math.cos(angle) * radius, Math.sin(i * 2) * 10, Math.sin(angle) * radius - 40]}
            rotation={[Math.random() * Math.PI, Math.random() * Math.PI, Math.random() * Math.PI]}
          >
            <octahedronGeometry args={[0.7, 0]} />
            <meshStandardMaterial
              color={['#ffd700', '#4169e1', '#9370db', '#ff69b4'][i % 4]}
              emissive={['#ffd700', '#4169e1', '#9370db', '#ff69b4'][i % 4]}
              emissiveIntensity={1.8}
              transparent
              opacity={0.85}
              metalness={0.9}
              roughness={0.1}
            />
          </mesh>
        );
      })}

      {[0, 1, 2, 3].map((i) => (
        <mesh
          key={`glow-${i}`}
          position={[(Math.random() - 0.5) * 60, (Math.random() - 0.5) * 40, -30 - Math.random() * 40]}
        >
          <sphereGeometry args={[1.5, 12, 12]} />
          <meshBasicMaterial
            color={['#ffd700', '#9370db', '#4169e1', '#ff69b4'][i]}
            transparent
            opacity={0.4}
          />
        </mesh>
      ))}
    </>
  );
}

// Keep the same texture functions
function createCircleTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 32;
  canvas.height = 32;
  const ctx = canvas.getContext('2d');
  
  const gradient = ctx.createRadialGradient(16, 16, 0, 16, 16, 16);
  gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
  gradient.addColorStop(0.3, 'rgba(255, 255, 255, 0.8)');
  gradient.addColorStop(0.6, 'rgba(255, 255, 255, 0.3)');
  gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
  
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 32, 32);
  
  const texture = new THREE.CanvasTexture(canvas);
  return texture;
}

function createStreakTexture() {
  const canvas = document.createElement('canvas');
  canvas.width = 64;
  canvas.height = 64;
  const ctx = canvas.getContext('2d');
  
  const gradient = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
  gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
  gradient.addColorStop(0.2, 'rgba(255, 255, 255, 0.9)');
  gradient.addColorStop(0.4, 'rgba(255, 255, 255, 0.5)');
  gradient.addColorStop(0.7, 'rgba(255, 255, 255, 0.2)');
  gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
  
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 64, 64);
  
  ctx.globalCompositeOperation = 'lighter';
  const streakGradient = ctx.createLinearGradient(0, 32, 64, 32);
  streakGradient.addColorStop(0, 'rgba(255, 255, 255, 0)');
  streakGradient.addColorStop(0.5, 'rgba(255, 255, 255, 0.6)');
  streakGradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
  
  ctx.fillStyle = streakGradient;
  ctx.fillRect(0, 28, 64, 8);
  
  const texture = new THREE.CanvasTexture(canvas);
  return texture;
}

  
function DraggableResizableContainer({ children, onModeChange }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [size, setSize] = useState({ width: 700, height: 600 });
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [resizeStart, setResizeStart] = useState({ x: 0, y: 0, width: 0, height: 0 });
  const containerRef = useRef(null);

  const handleMouseDown = (e) => {
    if (e.target.classList.contains('drag-handle') || e.target.closest('.drag-handle')) {
      setIsDragging(true);
      setDragStart({
        x: e.clientX - position.x,
        y: e.clientY - position.y
      });
      e.preventDefault();
    }
  };

  const handleResizeMouseDown = (e) => {
    e.stopPropagation();
    e.preventDefault();
    setIsResizing(true);
    const rect = containerRef.current.getBoundingClientRect();
    setResizeStart({
      x: e.clientX,
      y: e.clientY,
      width: rect.width,
      height: rect.height
    });
  };

  useEffect(() => {
    const handleMouseMove = (e) => {
      if (isDragging) {
        setPosition({
          x: e.clientX - dragStart.x,
          y: e.clientY - dragStart.y
        });
      } else if (isResizing) {
        const deltaX = e.clientX - resizeStart.x;
        const deltaY = e.clientY - resizeStart.y;
        setSize({
          width: Math.max(450, Math.min(1200, resizeStart.width + deltaX)),
          height: Math.max(400, Math.min(900, resizeStart.height + deltaY))
        });
      }
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      setIsResizing(false);
    };

    if (isDragging || isResizing) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      return () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [isDragging, isResizing, dragStart, resizeStart]);

  return (
    <div
      ref={containerRef}
      style={{
        position: 'fixed',
        left: `calc(50% + ${position.x}px)`,
        top: `calc(50% + ${position.y}px)`,
        transform: 'translate(-50%, -50%)',
        width: size.width,
        height: size.height,
        backgroundColor: 'rgba(10, 5, 30, 0.75)',
        backdropFilter: 'blur(50px)',
        borderRadius: '24px',
        boxShadow: '0 25px 50px -12px rgba(212, 175, 55, 0.4), 0 0 100px rgba(147, 112, 219, 0.3)',
        border: '2px solid rgba(212, 175, 55, 0.4)',
        overflow: 'hidden',
        zIndex: 1000,
        cursor: isDragging ? 'move' : 'default',
        userSelect: isDragging || isResizing ? 'none' : 'auto'
      }}
    >
      {/* Drag Handle with Divine Photo */}
      <div
        className="drag-handle"
        onMouseDown={handleMouseDown}
        style={{
          padding: '16px 20px',
          background: 'linear-gradient(135deg, rgba(255, 215, 0, 0.25), rgba(147, 112, 219, 0.25))',
          borderBottom: '2px solid rgba(212, 175, 55, 0.4)',
          cursor: 'move',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          gap: '16px'
        }}
      >
        {/* Spiritual Guide Photo */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          gap: '16px',
          flex: 1
        }}>
          <div style={{
  width: '80px',
  height: '80px',
  borderRadius: '50%',
  overflow: 'hidden',
  border: '3px solid rgba(255, 215, 0, 0.8)',
  boxShadow: '0 0 50px rgba(255, 215, 0, 0.7), 0 0 100px rgba(147, 112, 219, 0.5), 0 0 150px rgba(255, 215, 0, 0.3)',
  background: 'radial-gradient(circle at center, rgba(255, 215, 0, 0.4), transparent)',
  position: 'relative',
  animation: 'pulse 3s ease-in-out infinite'
}}>
  <img 
    src={guruImage}
    alt="Swamy Jithendarji"
    style={{
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      objectPosition: 'center',
    }}
    onError={(e) => {
      console.error('Image failed to load from /Jeeth-Blessing.png');
      e.target.style.display = 'none';
      e.target.parentElement.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:40px;background:linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(147, 112, 219, 0.3))">🕉️</div>';
    }}
  />
  {/* Divine light overlay */}
  <div style={{
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    background: 'radial-gradient(circle at 50% 20%, rgba(255, 215, 0, 0.3), transparent 50%)',
    pointerEvents: 'none'
  }} />
</div>
          
          <div>
            <div style={{ 
              color: '#ffd700', 
              fontWeight: 'bold', 
              fontSize: '18px',
              textShadow: '0 0 25px rgba(255, 215, 0, 0.8), 0 0 50px rgba(147, 112, 219, 0.5)',
              marginBottom: '5px',
              letterSpacing: '0.5px'
            }}>
              🕉️ Swamy Jithendarji
            </div>
            <div style={{
              color: '#d4af37',
              fontSize: '13px',
              fontStyle: 'italic',
              textShadow: '0 0 15px rgba(212, 175, 55, 0.5)',
              marginBottom: '2px'
            }}>
              Master Hypnotherapist & Spiritual Guide
            </div>
            <div style={{
              color: '#c9a0dc',
              fontSize: '11px',
              textShadow: '0 0 10px rgba(201, 160, 220, 0.4)'
            }}>
              Consciousness Transformation • Inner Shambhala
            </div>
          </div>
        </div>

        {/* Controls */}
        <div style={{ display: 'flex', gap: '8px' }}>
          <button
            onClick={(e) => {
              e.stopPropagation();
              setPosition({ x: 0, y: 0 });
              setSize({ width: 700, height: 600 });
            }}
            style={{
              background: 'rgba(255, 215, 0, 0.2)',
              border: '1px solid rgba(255, 215, 0, 0.5)',
              borderRadius: '6px',
              color: '#ffd700',
              padding: '6px 12px',
              cursor: 'pointer',
              fontSize: '12px',
              fontWeight: '600',
              transition: 'all 0.2s',
              boxShadow: '0 0 10px rgba(255, 215, 0, 0.3)'
            }}
            onMouseEnter={(e) => {
              e.target.style.background = 'rgba(255, 215, 0, 0.3)';
              e.target.style.boxShadow = '0 0 20px rgba(255, 215, 0, 0.5)';
            }}
            onMouseLeave={(e) => {
              e.target.style.background = 'rgba(255, 215, 0, 0.2)';
              e.target.style.boxShadow = '0 0 10px rgba(255, 215, 0, 0.3)';
            }}
          >
            ↺ Reset
          </button>
        </div>
      </div>

      {/* Content */}
      <div style={{ 
        padding: '30px',
        height: 'calc(100% - 112px)',
        overflowY: 'auto',
        overflowX: 'hidden'
      }}>
        {children}
      </div>

      {/* Resize Handle */}
      <div
        onMouseDown={handleResizeMouseDown}
        style={{
          position: 'absolute',
          bottom: 0,
          right: 0,
          width: '30px',
          height: '30px',
          cursor: 'nwse-resize',
          background: 'linear-gradient(135deg, transparent 45%, rgba(255, 215, 0, 0.6) 50%, rgba(255, 215, 0, 0.8) 55%)',
          borderTopLeftRadius: '6px',
          zIndex: 1001
        }}
      >
        <div style={{
          position: 'absolute',
          bottom: '4px',
          right: '4px',
          width: '12px',
          height: '12px',
          borderRight: '2px solid rgba(255, 215, 0, 0.8)',
          borderBottom: '2px solid rgba(255, 215, 0, 0.8)'
        }} />
      </div>
    </div>
  );
}
function App() {
  const [mode, setMode] = useState('none');
  const [isXRSupported, setIsXRSupported] = useState(false);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const checkXRSupport = async () => {
      if ('xr' in navigator && navigator.xr) {
        try {
          const supported = await navigator.xr.isSessionSupported('immersive-vr');
          setIsXRSupported(supported);
        } catch (err) {
          setIsXRSupported(false);
        }
      } else {
        setIsXRSupported(false);
      }
      setIsChecking(false);
    };
    checkXRSupport();
  }, []);

  if (mode !== 'none') {
    return <XRApp mode={mode} />;
  }

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', margin: 0, padding: 0, overflow: 'hidden' }}>
      
      {/* LAYER 1: Deep Cosmic Background (Behind everything) */}
      <div style={{ 
        position: 'absolute', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 0 
      }}>
        <Canvas
          camera={{ position: [0, 5, 25], fov: 75 }}
          gl={{ 
            antialias: true, 
            alpha: true,  // Enable transparency
            premultipliedAlpha: false
          }}
          style={{ display: 'block', width: '100%', height: '100%' }}
        >
          <color attach="background" args={['#050215']} />
          <CosmicSpiritualRealm />
        </Canvas>
      </div>

      {/* LAYER 2: Shambhala Realm (Middle layer with transparency) */}
      <div style={{ 
        position: 'absolute', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 1,
        opacity: 0.85  // Make entire layer semi-transparent
      }}>
        <Canvas
          camera={{ position: [0, 8, 40], fov: 70 }}
          gl={{ 
            antialias: true, 
            alpha: true,  // Enable transparency
            premultipliedAlpha: false
          }}
          shadows
          style={{ display: 'block', width: '100%', height: '100%' }}
        >
          {/* Transparent background so cosmic shows through */}
          <color attach="background" args={['rgba(0,0,0,0)']} />
          <ShambhalaRealm />
        </Canvas>
      </div>

      {/* LAYER 3: Atmospheric Gradient Overlay */}
      <div style={{
        position: 'absolute', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 2,
        background: `
          radial-gradient(ellipse at 30% 20%, rgba(255, 215, 0, 0.05) 0%, transparent 40%),
          radial-gradient(ellipse at 70% 80%, rgba(135, 206, 235, 0.05) 0%, transparent 40%),
          radial-gradient(ellipse at center, transparent 0%, rgba(10, 5, 32, 0.2) 100%)
        `,
        pointerEvents: 'none'
      }} />

      {/* LAYER 4: UI Content (Top layer) */}
      <DraggableResizableContainer onModeChange={setMode}>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ marginBottom: '16px' }}>
            <div style={{
              display: 'inline-block',
              padding: '20px',
              background: 'linear-gradient(135deg, #ffd700, #9370db, #87ceeb)',
              borderRadius: '50%',
              boxShadow: '0 0 80px rgba(255, 215, 0, 0.7), 0 0 120px rgba(147, 112, 219, 0.5)',
              animation: 'pulse 3s ease-in-out infinite'
            }}>
              <span style={{ fontSize: '56px' }}>🕉️</span>
            </div>
          </div>
          <h1 style={{
            fontSize: '48px',
            fontWeight: 'bold',
            background: 'linear-gradient(135deg, #ffd700, #f5deb3, #9370db)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            marginBottom: '12px',
            textShadow: '0 0 50px rgba(255, 215, 0, 0.4)',
            letterSpacing: '1px'
          }}>
            HMI Hypnotherapy
          </h1>
          <p style={{ 
            fontSize: '19px', 
            color: '#f5deb3', 
            textShadow: '0 0 25px rgba(245, 222, 179, 0.6)',
            fontStyle: 'italic'
          }}>
            Journey to Inner Shambhala • Consciousness Transformation
          </p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '24px' }}>
          <button
            onClick={() => setMode('xr')}
            disabled={isChecking}
            style={{
              width: '100%', padding: '20px 32px', borderRadius: '14px', fontWeight: 'bold', fontSize: '19px',
              background: 'linear-gradient(135deg, #ffd700, #daa520, #9370db)',
              color: 'white', border: 'none', cursor: isChecking ? 'not-allowed' : 'pointer',
              boxShadow: '0 15px 35px rgba(255, 215, 0, 0.5), 0 0 60px rgba(147, 112, 219, 0.3)',
              transition: 'all 0.3s'
            }}
            onMouseEnter={(e) => { 
              if (!isChecking) {
                e.currentTarget.style.transform = 'scale(1.05) translateY(-2px)';
                e.currentTarget.style.boxShadow = '0 20px 40px rgba(255, 215, 0, 0.6), 0 0 80px rgba(147, 112, 219, 0.4)';
              }
            }}
            onMouseLeave={(e) => { 
              e.currentTarget.style.transform = 'scale(1) translateY(0)';
              e.currentTarget.style.boxShadow = '0 15px 35px rgba(255, 215, 0, 0.5), 0 0 60px rgba(147, 112, 219, 0.3)';
            }}
          >
            <span style={{ marginRight: '12px', fontSize: '24px' }}>🥽</span>
            Launch Mystical VR Journey
            {isXRSupported && <div style={{ fontSize: '14px', marginTop: '6px', opacity: 0.95 }}>✨ Quest 3 Ready</div>}
          </button>

          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', margin: '8px 0' }}>
            <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to right, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
            <span style={{ 
              color: '#ffd700', 
              fontWeight: '700', 
              fontSize: '15px',
              textShadow: '0 0 15px rgba(255, 215, 0, 0.6)',
              letterSpacing: '2px'
            }}>OR</span>
            <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to left, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
          </div>

          <button
            onClick={() => setMode('3d')}
            disabled={isChecking}
            style={{
              width: '100%', padding: '20px 32px', borderRadius: '14px', fontWeight: 'bold', fontSize: '19px',
              background: 'linear-gradient(135deg, #2d5016, #3d6b1f, #4a7c2a)',
              color: 'white', border: 'none', cursor: isChecking ? 'not-allowed' : 'pointer',
              boxShadow: '0 15px 35px rgba(45, 80, 22, 0.5), 0 0 60px rgba(61, 107, 31, 0.3)',
              transition: 'all 0.3s'
            }}
            onMouseEnter={(e) => { 
              if (!isChecking) {
                e.currentTarget.style.transform = 'scale(1.05) translateY(-2px)';
                e.currentTarget.style.boxShadow = '0 20px 40px rgba(45, 80, 22, 0.6), 0 0 80px rgba(61, 107, 31, 0.4)';
              }
            }}
            onMouseLeave={(e) => { 
              e.currentTarget.style.transform = 'scale(1) translateY(0)';
              e.currentTarget.style.boxShadow = '0 15px 35px rgba(45, 80, 22, 0.5), 0 0 60px rgba(61, 107, 31, 0.3)';
            }}
          >
            <span style={{ marginRight: '12px', fontSize: '24px' }}>🌿</span>
            Explore Sacred 3D Realm
            <div style={{ fontSize: '14px', marginTop: '6px', opacity: 0.95 }}>🖱️ Desktop Mode</div>
          </button>
        </div>

        <div style={{
          borderRadius: '14px', padding: '18px',
          border: '2px solid rgba(212, 175, 55, 0.35)',
          backgroundColor: 'rgba(212, 175, 55, 0.12)',
          boxShadow: '0 0 40px rgba(255, 215, 0, 0.15), inset 0 0 30px rgba(255, 215, 0, 0.05)'
        }}>
          <div style={{ display: 'flex', gap: '14px', alignItems: 'center' }}>
            <div style={{ fontSize: '28px' }}>{isXRSupported ? '✨' : '🧘'}</div>
            <div>
              <h3 style={{ 
                fontWeight: 'bold', 
                color: '#ffd700', 
                marginBottom: '6px', 
                fontSize: '16px',
                textShadow: '0 0 15px rgba(255, 215, 0, 0.5)'
              }}>
                {isXRSupported ? 'Sacred VR Portal Active' : 'Desktop Meditation Mode'}
              </h3>
              <p style={{ fontSize: '13px', color: '#f5deb3', margin: 0, lineHeight: '1.5' }}>
                {isXRSupported
                  ? 'Enter the mystical realm with full immersive consciousness expansion.'
                  : 'Begin your transformative journey through the desktop portal.'}
              </p>
            </div>
          </div>
        </div>
      </DraggableResizableContainer>
    </div>
  );
}

export default App;


/*
     {/* Cosmic Spiritual Background *** /}
      <div style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', zIndex: 0 }}>
        <Canvas
          camera={{ position: [0, 5, 25], fov: 75 }}
          gl={{ antialias: true, alpha: false }}
          style={{ display: 'block', width: '100%', height: '100%' }}
        >
          <CosmicSpiritualRealm />
        </Canvas>
      </div>

      {/* Gradient overlay *** /}
      <div style={{
        position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', zIndex: 1,
        background: 'radial-gradient(ellipse at center, transparent 0%, rgba(10, 5, 32, 0.4) 100%)',
        pointerEvents: 'none'
      }} />

*/
