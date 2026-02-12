// @ts-nocheck
import { useState, useEffect, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { XRApp } from './features/xr/XRApp';
import { ShambhalaRealm } from './components/ShambhalaRealm';
//import { CosmicSpiritualRealm } from './components/CosmicSpiritualRealm';
//import { DraggableResizableContainer } from './components/DraggableResizableContainer';
import * as THREE from 'three';
import guruImage from './assets/Jeeth-Blessing.png';

// ==================== COSMIC SPIRITUAL REALM ====================
function CosmicSpiritualRealm() {
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

// ==================== COMBINED SCENE ====================
function CombinedScene() {
  return (
    <>
      {/* Cosmic particles - rendered in background */}
      <CosmicSpiritualRealm />
      
      {/* Shambhala realm - rendered in foreground */}
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
      
      {/* SINGLE CANVAS - Proper depth sorting! */}
      <div style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', zIndex: 0 }}>
        <Canvas
          camera={{ position: [0, 8, 35], fov: 70 }}
          gl={{ 
            antialias: true, 
            alpha: false,
            powerPreference: "high-performance"
          }}
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
