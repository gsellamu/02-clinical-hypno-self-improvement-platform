// @ts-nocheck

import { useState, useEffect, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { XRApp } from './features/xr/XRApp';
import { ShambhalaRealm } from './components/ShambhalaRealm';
import * as THREE from 'three';
import guruImage from './assets/Jeeth-Blessing.png';

// Single Cosmic Particle Component
function CosmicParticle({ position, color, size, velocity, index }) {
  const meshRef = useRef();

  useFrame(({ clock }) => {
    if (!meshRef.current) return;
    
    const t = clock.getElapsedTime();
    
    // Move particle
    meshRef.current.position.x += velocity.current.x;
    meshRef.current.position.y += velocity.current.y;
    meshRef.current.position.z += velocity.current.z;
    
    // Gentle pulsing
    const pulse = Math.sin(t * 0.5 + index * 0.1) * 0.02;
    const dist = Math.sqrt(
      meshRef.current.position.x ** 2 +
      meshRef.current.position.y ** 2 +
      meshRef.current.position.z ** 2
    );
    
    if (dist < 85) {
      meshRef.current.position.x += (meshRef.current.position.x / dist) * pulse;
      meshRef.current.position.y += (meshRef.current.position.y / dist) * pulse;
      meshRef.current.position.z += (meshRef.current.position.z / dist) * pulse;
    } else {
      // Respawn at center
      const newRadius = 15 + Math.random() * 10;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      
      meshRef.current.position.x = newRadius * Math.sin(phi) * Math.cos(theta);
      meshRef.current.position.y = newRadius * Math.sin(phi) * Math.sin(theta);
      meshRef.current.position.z = newRadius * Math.cos(phi) - 40;
    }
    
    // Glow pulsing
    const glowPulse = Math.sin(t * 0.7 + index * 0.2) * 0.3 + 1.2;
    if (meshRef.current.material) {
      meshRef.current.material.emissiveIntensity = glowPulse;
    }
  });

  return (
    <mesh ref={meshRef} position={position}>
      <sphereGeometry args={[size, 8, 8]} />
      <meshStandardMaterial
        color={color}
        emissive={color}
        emissiveIntensity={1.5}
        transparent
        opacity={0.9}
        metalness={0.3}
        roughness={0.3}
      />
    </mesh>
  );
}

// Single Cosmic Ray Component
function CosmicRay({ position, color, velocity, index }) {
  const meshRef = useRef();

  useFrame(() => {
    if (!meshRef.current) return;
    
    // Move ray
    meshRef.current.position.x += velocity.current.x;
    meshRef.current.position.y += velocity.current.y;
    meshRef.current.position.z += velocity.current.z;
    
    const dist = Math.sqrt(
      meshRef.current.position.x ** 2 +
      meshRef.current.position.y ** 2 +
      (meshRef.current.position.z + 40) ** 2
    );
    
    if (dist > 80) {
      // Respawn at center
      const angle = Math.random() * Math.PI * 2;
      const startRadius = 5 + Math.random() * 10;
      
      meshRef.current.position.x = Math.cos(angle) * startRadius;
      meshRef.current.position.y = (Math.random() - 0.5) * 20;
      meshRef.current.position.z = Math.sin(angle) * startRadius - 40;
      
      const speed = 0.1 + Math.random() * 0.15;
      velocity.current.x = Math.cos(angle) * speed;
      velocity.current.y = (Math.random() - 0.5) * 0.05;
      velocity.current.z = Math.sin(angle) * speed;
    }
    
    // Orient toward movement
    const angle = Math.atan2(velocity.current.z, velocity.current.x);
    meshRef.current.rotation.y = angle;
  });

  return (
    <group position={position}>
      <mesh ref={meshRef} scale={[2, 0.5, 0.5]}>
        <sphereGeometry args={[0.5, 8, 8]} />
        <meshBasicMaterial
          color={color}
          transparent
          opacity={0.85}
        />
      </mesh>
      <pointLight intensity={1.5} color={color} distance={10} />
    </group>
  );
}

// ==================== COSMIC SPIRITUAL REALM ====================
function CosmicSpiritualRealm() {
  const nebula1Ref = useRef(null);
  const nebula2Ref = useRef(null);
  const nebula3Ref = useRef(null);
  const groupRef = useRef(null);

  // Generate particle data
  const particles = useRef([]);
  const rays = useRef([]);

  if (particles.current.length === 0) {
    // Create 600 particles
    for (let i = 0; i < 500; i++) {
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
        size = Math.random() * 0.4 + 0.3;
      } else if (colorType < 0.35) {
        color = '#4169e1';
        size = Math.random() * 0.35 + 0.25;
      } else if (colorType < 0.55) {
        color = '#9370db';
        size = Math.random() * 0.4 + 0.2;
      } else if (colorType < 0.75) {
        color = '#ffd700';
        size = Math.random() * 0.35 + 0.25;
      } else {
        color = '#87ceeb';
        size = Math.random() * 0.3 + 0.2;
      }
      
      //color = "#011899"
      //size = 0.5
      particles.current.push({
        position,
        color,
        size,
        velocity: { current: velocity },
        id: `particle-${i}`
      });
    }

    // Create 30 cosmic rays
    for (let i = 0; i < 30; i++) {
      const angle = Math.random() * Math.PI * 2;
      const height = (Math.random() - 0.5) * 60;
      const distance = 30 + Math.random() * 50;
      
      const position = [
        Math.cos(angle) * distance,
        height,
        Math.sin(angle) * distance - 40
      ];
      
      const speed = 0.1 + Math.random() * 0.001;
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

    if (groupRef.current) {
      groupRef.current.rotation.y = t * 0.01;
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
    <>
      <ambientLight intensity={0.3} color="#1a0a3e" />
      <pointLight position={[0, 30, -20]} intensity={6} color="#ffd700" distance={120} decay={2} />
      <pointLight position={[-30, 20, -40]} intensity={5} color="#9370db" distance={100} decay={2} />
      <pointLight position={[30, 15, -30]} intensity={5} color="#4169e1" distance={100} decay={2} />
      <pointLight position={[0, -20, -50]} intensity={4} color="#ff69b4" distance={90} decay={2} />

      {/* 3D SPHERICAL PARTICLES - These will be in FRONT */}
      <group ref={groupRef}>
        {particles.current.map((particle, i) => (
          <CosmicParticle
            key={particle.id}
            position={particle.position}
            color={particle.color}
            size={particle.size}
            velocity={particle.velocity}
            index={i}
          />
        ))}
      </group>

      {/* COSMIC RAY STREAKS - These will be in FRONT */}
      {rays.current.map((ray, i) => (
        <CosmicRay
          key={ray.id}
          position={ray.position}
          color={ray.color}
          velocity={ray.velocity}
          index={i}
        />
      ))}

      {/* Ethereal nebulas - FAR BACK */}
      <mesh ref={nebula1Ref} position={[0, 10, -90]}>
        <sphereGeometry args={[50, 24, 24]} />
        <meshBasicMaterial color="#1a0a4e" transparent opacity={0.2} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula2Ref} position={[35, 20, -100]}>
        <sphereGeometry args={[40, 24, 24]} />
        <meshBasicMaterial color="#4b0082" transparent opacity={0.18} side={THREE.BackSide} />
      </mesh>

      <mesh ref={nebula3Ref} position={[-30, 15, -95]}>
        <sphereGeometry args={[45, 24, 24]} />
        <meshBasicMaterial color="#191970" transparent opacity={0.18} side={THREE.BackSide} />
      </mesh>

      {/* Floating energy spheres */}
      {[0, 1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
        <mesh
          key={`glow-${i}`}
          position={[
            (Math.random() - 0.5) * 60,
            (Math.random() - 0.5) * 40,
            -30 - Math.random() * 40
          ]}
        >
          <sphereGeometry args={[1.5, 12, 12]} />
          <meshBasicMaterial
            color={['#ffd700', '#9370db', '#4169e1', '#ff69b4', '#00ced1', '#dda0dd', '#98ff98', '#ffa500', '#ff1493'][i]}
            transparent
            opacity={0.9}
          />
        </mesh>
      ))}
    </>
  );
}

// ==================== COMBINED SCENE ====================
function CombinedScene() {
  return (
    <>
      {/* Cosmic particles and background - rendered first (far back) */}
       <CosmicSpiritualRealm /> 
      
      {/* Shambhala realm - rendered second (in middle/front) */}
       <ShambhalaRealm /> 
    </>
  );
}

// ==================== DRAGGABLE CONTAINER ====================
function DraggableResizableContainer({ children }) {
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
      {/* Drag Handle with Photo */}
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
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flex: 1 }}>
          <div style={{
            width: '80px',
            height: '80px',
            borderRadius: '50%',
            overflow: 'hidden',
            border: '3px solid rgba(255, 215, 0, 0.8)',
            boxShadow: '0 0 50px rgba(255, 215, 0, 0.7), 0 0 100px rgba(147, 112, 219, 0.5)',
            position: 'relative'
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
            />
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
              textShadow: '0 0 25px rgba(255, 215, 0, 0.8)',
              marginBottom: '5px',
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
        >
          ↺ Reset
        </button>
      </div>

      <div style={{ 
        padding: '30px',
        height: 'calc(100% - 112px)',
        overflowY: 'auto',
      }}>
        {children}
      </div>

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
      />
    </div>
  );
}

// ==================== MAIN APP ====================
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
      
      {/* SINGLE CANVAS WITH BOTH REALMS - Proper depth sorting! */}
      <div style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', zIndex: 0 }}>
        <Canvas
          camera={{ position: [0, 8, 35], fov: 70 }}
          gl={{ antialias: true, alpha: false }}
          shadows
          style={{ display: 'block', width: '100%', height: '100%' }}
        >
       <CombinedScene />
        </Canvas>
      </div>

      {/* Gradient Overlay */}
      <div style={{
        position: 'absolute', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 1,
        background: 'radial-gradient(ellipse at center, transparent 0%, rgba(10, 5, 32, 0.2) 100%)',
        pointerEvents: 'none'
      }} />

      {/* UI Content */}
      <DraggableResizableContainer>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ marginBottom: '16px' }}>
            <div style={{
              display: 'inline-block',
              padding: '20px',
              background: 'linear-gradient(135deg, #ffd700, #9370db, #87ceeb)',
              borderRadius: '50%',
              boxShadow: '0 0 80px rgba(255, 215, 0, 0.7)',
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
          }}>
            HMI Hypnotherapy
          </h1>
          <p style={{ fontSize: '19px', color: '#f5deb3', fontStyle: 'italic' }}>
            Journey to Inner Shambhala • Consciousness Transformation
          </p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '24px' }}>
          <button
            onClick={() => setMode('xr')}
            disabled={isChecking}
            style={{
              width: '100%',
              padding: '20px 32px',
              borderRadius: '14px',
              fontWeight: 'bold',
              fontSize: '19px',
              background: 'linear-gradient(135deg, #ffd700, #daa520, #9370db)',
              color: 'white',
              border: 'none',
              cursor: isChecking ? 'not-allowed' : 'pointer',
              boxShadow: '0 15px 35px rgba(255, 215, 0, 0.5)',
              transition: 'all 0.3s'
            }}
          >
            <span style={{ marginRight: '12px', fontSize: '24px' }}>🥽</span>
            Launch Mystical VR Journey
            {isXRSupported && <div style={{ fontSize: '14px', marginTop: '6px' }}>✨ Quest 3 Ready</div>}
          </button>

          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', margin: '8px 0' }}>
            <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to right, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
            <span style={{ color: '#ffd700', fontWeight: '700', fontSize: '15px' }}>OR</span>
            <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to left, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
          </div>

          <button
            onClick={() => setMode('3d')}
            disabled={isChecking}
            style={{
              width: '100%',
              padding: '20px 32px',
              borderRadius: '14px',
              fontWeight: 'bold',
              fontSize: '19px',
              background: 'linear-gradient(135deg, #2d5016, #3d6b1f, #4a7c2a)',
              color: 'white',
              border: 'none',
              cursor: isChecking ? 'not-allowed' : 'pointer',
              boxShadow: '0 15px 35px rgba(45, 80, 22, 0.5)',
              transition: 'all 0.3s'
            }}
          >
            <span style={{ marginRight: '12px', fontSize: '24px' }}>🌿</span>
            Explore Sacred 3D Realm
            <div style={{ fontSize: '14px', marginTop: '6px' }}>🖱️ Desktop Mode</div>
          </button>
        </div>
      </DraggableResizableContainer>
    </div>
  );
}

export default App;

