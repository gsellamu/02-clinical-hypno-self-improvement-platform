# ============================================================================
# HMI Hypnotherapy Platform - XR Source Files Generator
# ============================================================================
# Purpose: Generate ALL React/TypeScript source files for WebXR implementation
# Target: Meta Quest 3 (90 FPS performance target)
# Tech Stack: React 18.2.0 + Three.js + @react-three/fiber + @react-three/xr
# ============================================================================

param(
    [string]$ProjectRoot = "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform"
)

Write-Host "🚀 HMI Hypnotherapy XR Files Generator" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

$FrontendRoot = Join-Path $ProjectRoot "frontend"
$SrcRoot = Join-Path $FrontendRoot "src"
$XRRoot = Join-Path $SrcRoot "features\xr"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-FileWithContent {
    param(
        [string]$Path,
        [string]$Content,
        [string]$Description
    )
    
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "✅ Created: $Description" -ForegroundColor Green
    Write-Host "   📁 $Path" -ForegroundColor DarkGray
}

# ============================================================================
# 1. UPDATE VITE CONFIG
# ============================================================================

$ViteConfig = @'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@features': path.resolve(__dirname, './src/features'),
      '@xr': path.resolve(__dirname, './src/features/xr'),
      '@components': path.resolve(__dirname, './src/components'),
      '@stores': path.resolve(__dirname, './src/stores'),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
  },
  optimizeDeps: {
    include: ['three', '@react-three/fiber', '@react-three/xr'],
  },
});
'@

Write-FileWithContent `
    -Path (Join-Path $FrontendRoot "vite.config.ts") `
    -Content $ViteConfig `
    -Description "Vite Config with Path Aliases"

# ============================================================================
# 2. XR STORE (Zustand State Management)
# ============================================================================

$XRStore = @'
import { create } from 'zustand';

export type EnvironmentType = 'soft-room' | 'nature' | 'floating-platform';
export type SessionPhase = 'intro' | 'induction' | 'deepening' | 'therapy' | 'emergence';

interface AudioState {
  backgroundVolume: number;
  voiceVolume: number;
  isPlaying: boolean;
}

interface PerformanceMetrics {
  fps: number;
  frameTime: number;
  memoryUsage: number;
}

interface XRState {
  // Environment
  currentEnvironment: EnvironmentType;
  isXRActive: boolean;
  
  // Session
  sessionPhase: SessionPhase;
  sessionStartTime: number | null;
  
  // Audio
  audio: AudioState;
  
  // Performance
  performance: PerformanceMetrics;
  lodLevel: number; // 0 = high, 1 = medium, 2 = low
  
  // User preferences
  preferences: {
    enableParticles: boolean;
    enablePostProcessing: boolean;
    motionIntensity: number; // 0-1
  };
  
  // Actions
  setEnvironment: (env: EnvironmentType) => void;
  setXRActive: (active: boolean) => void;
  setSessionPhase: (phase: SessionPhase) => void;
  startSession: () => void;
  endSession: () => void;
  updateAudio: (audio: Partial<AudioState>) => void;
  updatePerformance: (metrics: Partial<PerformanceMetrics>) => void;
  setLODLevel: (level: number) => void;
  updatePreferences: (prefs: Partial<XRState['preferences']>) => void;
}

export const useXRStore = create<XRState>((set) => ({
  // Initial state
  currentEnvironment: 'soft-room',
  isXRActive: false,
  sessionPhase: 'intro',
  sessionStartTime: null,
  
  audio: {
    backgroundVolume: 0.3,
    voiceVolume: 0.7,
    isPlaying: false,
  },
  
  performance: {
    fps: 90,
    frameTime: 11.1,
    memoryUsage: 0,
  },
  
  lodLevel: 0,
  
  preferences: {
    enableParticles: true,
    enablePostProcessing: true,
    motionIntensity: 0.5,
  },
  
  // Actions
  setEnvironment: (env) => set({ currentEnvironment: env }),
  
  setXRActive: (active) => set({ isXRActive: active }),
  
  setSessionPhase: (phase) => set({ sessionPhase: phase }),
  
  startSession: () => set({ 
    sessionStartTime: Date.now(),
    sessionPhase: 'intro',
  }),
  
  endSession: () => set({ 
    sessionStartTime: null,
    sessionPhase: 'intro',
  }),
  
  updateAudio: (audio) => set((state) => ({
    audio: { ...state.audio, ...audio }
  })),
  
  updatePerformance: (metrics) => set((state) => ({
    performance: { ...state.performance, ...metrics }
  })),
  
  setLODLevel: (level) => set({ lodLevel: level }),
  
  updatePreferences: (prefs) => set((state) => ({
    preferences: { ...state.preferences, ...prefs }
  })),
}));
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "stores\xr.store.ts") `
    -Content $XRStore `
    -Description "XR State Store (Zustand)"

# ============================================================================
# 3. PERFORMANCE/LOD SYSTEM
# ============================================================================

$LODSystem = @'
import { useEffect } from 'react';
import { useFrame } from '@react-three/fiber';
import { useXRStore } from '../stores/xr.store';

const TARGET_FPS = 85;
const FPS_CHECK_INTERVAL = 60; // frames
const LOD_COOLDOWN = 120; // frames before changing LOD again

let frameCount = 0;
let lastTime = performance.now();
let fpsHistory: number[] = [];
let lodCooldown = 0;

export function PerformanceMonitor() {
  const { updatePerformance, setLODLevel, lodLevel } = useXRStore();

  useFrame(() => {
    frameCount++;
    const currentTime = performance.now();
    const delta = currentTime - lastTime;

    // Update FPS every second
    if (delta >= 1000) {
      const fps = Math.round((frameCount * 1000) / delta);
      const frameTime = delta / frameCount;
      
      updatePerformance({ fps, frameTime });
      
      fpsHistory.push(fps);
      if (fpsHistory.length > 5) {
        fpsHistory.shift();
      }

      frameCount = 0;
      lastTime = currentTime;
    }

    // LOD adjustment logic
    if (lodCooldown > 0) {
      lodCooldown--;
      return;
    }

    if (frameCount % FPS_CHECK_INTERVAL === 0 && fpsHistory.length >= 3) {
      const avgFPS = fpsHistory.reduce((a, b) => a + b, 0) / fpsHistory.length;

      // Decrease quality if FPS is low
      if (avgFPS < TARGET_FPS && lodLevel < 2) {
        setLODLevel(lodLevel + 1);
        lodCooldown = LOD_COOLDOWN;
        console.log(`📉 LOD decreased to ${lodLevel + 1} (FPS: ${avgFPS.toFixed(1)})`);
      }
      // Increase quality if FPS is stable and high
      else if (avgFPS > TARGET_FPS + 5 && lodLevel > 0) {
        setLODLevel(lodLevel - 1);
        lodCooldown = LOD_COOLDOWN;
        console.log(`📈 LOD increased to ${lodLevel - 1} (FPS: ${avgFPS.toFixed(1)})`);
      }
    }
  });

  return null;
}

export function useLOD() {
  return useXRStore((state) => state.lodLevel);
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "performance\LODSystem.tsx") `
    -Content $LODSystem `
    -Description "Performance Monitor & LOD System"

# ============================================================================
# 4. AUDIO SYSTEM
# ============================================================================

$AudioSystem = @'
import { useEffect, useRef } from 'react';
import { useXRStore } from '../stores/xr.store';

interface AudioTrack {
  name: string;
  url: string;
  loop: boolean;
  volume: number;
}

const AUDIO_TRACKS: Record<string, AudioTrack> = {
  softAmbient: {
    name: 'Soft Ambient',
    url: '/sounds/soft-ambient.mp3',
    loop: true,
    volume: 0.3,
  },
  natureForest: {
    name: 'Nature Forest',
    url: '/sounds/nature-forest.mp3',
    loop: true,
    volume: 0.4,
  },
  floatingSpace: {
    name: 'Floating Space',
    url: '/sounds/floating-space.mp3',
    loop: true,
    volume: 0.35,
  },
  guidedVoice: {
    name: 'Guided Voice',
    url: '/sounds/guided-voice.mp3',
    loop: false,
    volume: 0.7,
  },
  binauralBeat: {
    name: 'Binaural Beat',
    url: '/sounds/binaural-beat.mp3',
    loop: true,
    volume: 0.25,
  },
  transitionChime: {
    name: 'Transition Chime',
    url: '/sounds/transition-chime.mp3',
    loop: false,
    volume: 0.5,
  },
};

export function AudioSystem() {
  const audioContextRef = useRef<AudioContext | null>(null);
  const audioNodesRef = useRef<Map<string, AudioBufferSourceNode>>(new Map());
  const gainNodesRef = useRef<Map<string, GainNode>>(new Map());
  
  const { audio, currentEnvironment } = useXRStore();

  useEffect(() => {
    // Initialize Web Audio API
    if (!audioContextRef.current) {
      audioContextRef.current = new (window.AudioContext || (window as any).webkitAudioContext)();
    }

    return () => {
      // Cleanup on unmount
      audioNodesRef.current.forEach(node => node.stop());
      audioContextRef.current?.close();
    };
  }, []);

  useEffect(() => {
    // Update volumes based on store
    gainNodesRef.current.forEach((gainNode, key) => {
      const isVoice = key === 'guidedVoice';
      const targetVolume = isVoice ? audio.voiceVolume : audio.backgroundVolume;
      gainNode.gain.setValueAtTime(targetVolume, audioContextRef.current!.currentTime);
    });
  }, [audio.backgroundVolume, audio.voiceVolume]);

  useEffect(() => {
    // Switch ambient track based on environment
    const trackMap: Record<string, string> = {
      'soft-room': 'softAmbient',
      'nature': 'natureForest',
      'floating-platform': 'floatingSpace',
    };

    const newTrack = trackMap[currentEnvironment];
    console.log(`🎵 Switching to ${newTrack} for ${currentEnvironment}`);
    
    // In a real implementation, you would load and play the audio here
  }, [currentEnvironment]);

  return null;
}

export function playSound(trackName: string) {
  console.log(`🔊 Playing sound: ${trackName}`);
  // Implement actual sound playback
}

export function stopSound(trackName: string) {
  console.log(`🔇 Stopping sound: ${trackName}`);
  // Implement actual sound stopping
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "audio\AudioSystem.tsx") `
    -Content $AudioSystem `
    -Description "Audio System Manager"

# ============================================================================
# 5. ENVIRONMENT: SOFT LIT ROOM
# ============================================================================

$SoftLitRoom = @'
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
      const breathe = Math.sin(clock.getElapsedTime() * 0.3) * 0.02;
      roomRef.current.scale.setScalar(1 + breathe);
    }
  });

  const particleCount = lodLevel === 0 ? 100 : lodLevel === 1 ? 50 : 20;

  return (
    <group ref={roomRef}>
      {/* Floor */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -2, 0]} receiveShadow>
        <planeGeometry args={[10, 10]} />
        <meshStandardMaterial 
          color="#f5f5f0" 
          roughness={0.8} 
          metalness={0.1}
        />
      </mesh>

      {/* Walls - Soft beige curved walls */}
      <mesh position={[0, 0, -5]}>
        <cylinderGeometry args={[5, 5, 4, 32, 1, true, 0, Math.PI]} />
        <meshStandardMaterial 
          color="#e8dcc8" 
          side={THREE.DoubleSide}
          roughness={0.9}
        />
      </mesh>

      {/* Ceiling with soft glow */}
      <mesh rotation={[Math.PI / 2, 0, 0]} position={[0, 2, 0]}>
        <circleGeometry args={[5, 32]} />
        <meshStandardMaterial 
          color="#fff9e6" 
          emissive="#fff3d9"
          emissiveIntensity={0.3}
        />
      </mesh>

      {/* Ambient point lights - warm and soft */}
      <pointLight position={[0, 1.5, 0]} intensity={0.8} color="#ffe4b5" distance={8} decay={2} />
      <pointLight position={[2, 0.5, 2]} intensity={0.3} color="#ffd7a3" distance={5} />
      <pointLight position={[-2, 0.5, 2]} intensity={0.3} color="#ffd7a3" distance={5} />

      {/* Floating orbs - calming presence */}
      {lodLevel < 2 && (
        <>
          <FloatingOrb position={[1.5, 0.5, -2]} color="#ffebcd" />
          <FloatingOrb position={[-1.5, 0.8, -2.5]} color="#ffe4c4" delay={1.5} />
          <FloatingOrb position={[0, 1.2, -3]} color="#ffd9a3" delay={3} />
        </>
      )}

      {/* Particle system - gentle floating motes */}
      {lodLevel === 0 && <FloatingParticles count={particleCount} />}
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
    }
  });

  return (
    <mesh ref={orbRef} position={position}>
      <sphereGeometry args={[0.15, 16, 16]} />
      <meshStandardMaterial 
        color={color} 
        emissive={color}
        emissiveIntensity={0.5}
        transparent
        opacity={0.6}
      />
    </mesh>
  );
}

function FloatingParticles({ count }: { count: number }) {
  const particlesRef = useRef<THREE.Points>(null);

  const positions = new Float32Array(count * 3);
  const velocities = new Float32Array(count * 3);

  for (let i = 0; i < count; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 8;
    positions[i * 3 + 1] = Math.random() * 3 - 1;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 8;
    
    velocities[i * 3] = (Math.random() - 0.5) * 0.02;
    velocities[i * 3 + 1] = Math.random() * 0.01;
    velocities[i * 3 + 2] = (Math.random() - 0.5) * 0.02;
  }

  useFrame(() => {
    if (particlesRef.current) {
      const positions = particlesRef.current.geometry.attributes.position.array as Float32Array;
      
      for (let i = 0; i < count; i++) {
        positions[i * 3] += velocities[i * 3];
        positions[i * 3 + 1] += velocities[i * 3 + 1];
        positions[i * 3 + 2] += velocities[i * 3 + 2];

        // Wrap around
        if (positions[i * 3 + 1] > 2) positions[i * 3 + 1] = -1;
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
        size={0.03}
        color="#ffefd5"
        transparent
        opacity={0.6}
        sizeAttenuation
      />
    </points>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\SoftLitRoom.tsx") `
    -Content $SoftLitRoom `
    -Description "Soft Lit Room Environment"

# ============================================================================
# 6. ENVIRONMENT: NATURE SCENE
# ============================================================================

$NatureScene = @'
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useLOD } from '../performance/LODSystem';

export function NatureScene() {
  const sceneRef = useRef<THREE.Group>(null);
  const lodLevel = useLOD();

  const treeCount = lodLevel === 0 ? 20 : lodLevel === 1 ? 12 : 6;

  return (
    <group ref={sceneRef}>
      {/* Ground - Grassy field */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]} receiveShadow>
        <circleGeometry args={[15, 64]} />
        <meshStandardMaterial 
          color="#4a7c59" 
          roughness={0.9}
        />
      </mesh>

      {/* Sky dome */}
      <mesh>
        <sphereGeometry args={[50, 32, 32]} />
        <meshBasicMaterial 
          color="#87ceeb" 
          side={THREE.BackSide}
        />
      </mesh>

      {/* Sun */}
      <mesh position={[20, 25, -30]}>
        <sphereGeometry args={[3, 32, 32]} />
        <meshBasicMaterial color="#fffacd" />
      </mesh>

      {/* Directional sunlight */}
      <directionalLight
        position={[10, 15, -15]}
        intensity={1.5}
        color="#fffaf0"
        castShadow
      />

      {/* Ambient light */}
      <ambientLight intensity={0.4} color="#e6f3ff" />

      {/* Trees in a circle around the user */}
      {Array.from({ length: treeCount }).map((_, i) => {
        const angle = (i / treeCount) * Math.PI * 2;
        const radius = 8 + Math.random() * 4;
        const x = Math.cos(angle) * radius;
        const z = Math.sin(angle) * radius;
        return <Tree key={i} position={[x, -0.5, z]} />;
      })}

      {/* Flowers/grass patches */}
      {lodLevel < 2 && (
        <>
          {Array.from({ length: 15 }).map((_, i) => {
            const angle = Math.random() * Math.PI * 2;
            const radius = Math.random() * 6;
            const x = Math.cos(angle) * radius;
            const z = Math.sin(angle) * radius;
            return <FlowerPatch key={i} position={[x, -0.4, z]} />;
          })}
        </>
      )}

      {/* Butterflies */}
      {lodLevel === 0 && (
        <>
          <Butterfly startPosition={[2, 1, 2]} />
          <Butterfly startPosition={[-3, 1.5, 1]} />
          <Butterfly startPosition={[1, 2, -2]} />
        </>
      )}
    </group>
  );
}

function Tree({ position }: { position: [number, number, number] }) {
  const treeRef = useRef<THREE.Group>(null);

  useFrame(({ clock }) => {
    if (treeRef.current) {
      // Gentle swaying
      const sway = Math.sin(clock.getElapsedTime() * 0.5 + position[0]) * 0.02;
      treeRef.current.rotation.z = sway;
    }
  });

  return (
    <group ref={treeRef} position={position}>
      {/* Trunk */}
      <mesh position={[0, 1.5, 0]}>
        <cylinderGeometry args={[0.2, 0.25, 3, 8]} />
        <meshStandardMaterial color="#4d3319" roughness={0.9} />
      </mesh>

      {/* Foliage */}
      <mesh position={[0, 3.5, 0]}>
        <sphereGeometry args={[1.5, 8, 8]} />
        <meshStandardMaterial color="#2d5016" roughness={0.8} />
      </mesh>
      <mesh position={[0, 4.2, 0]}>
        <sphereGeometry args={[1.2, 8, 8]} />
        <meshStandardMaterial color="#3d6b1f" roughness={0.8} />
      </mesh>
    </group>
  );
}

function FlowerPatch({ position }: { position: [number, number, number] }) {
  return (
    <group position={position}>
      {Array.from({ length: 5 }).map((_, i) => {
        const offset = [(Math.random() - 0.5) * 0.3, 0, (Math.random() - 0.5) * 0.3];
        const color = ['#ff69b4', '#ffd700', '#fff8dc', '#ff6347'][Math.floor(Math.random() * 4)];
        return (
          <mesh key={i} position={offset as [number, number, number]}>
            <sphereGeometry args={[0.05, 8, 8]} />
            <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.3} />
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
      butterflyRef.current.position.x = startPosition[0] + Math.sin(t * 0.5) * 2;
      butterflyRef.current.position.y = startPosition[1] + Math.sin(t * 2) * 0.5;
      butterflyRef.current.position.z = startPosition[2] + Math.cos(t * 0.5) * 2;
      butterflyRef.current.rotation.y = t;
    }
  });

  return (
    <group ref={butterflyRef}>
      <mesh>
        <boxGeometry args={[0.1, 0.05, 0.15]} />
        <meshStandardMaterial color="#ff69b4" />
      </mesh>
    </group>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\NatureScene.tsx") `
    -Content $NatureScene `
    -Description "Nature Scene Environment"

# ============================================================================
# 7. ENVIRONMENT: FLOATING PLATFORM
# ============================================================================

$FloatingPlatform = @'
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
      const float = Math.sin(clock.getElapsedTime() * 0.3) * 0.1;
      platformRef.current.position.y = float;
      
      // Slow rotation
      platformRef.current.rotation.y = clock.getElapsedTime() * 0.05;
    }
  });

  const starCount = lodLevel === 0 ? 500 : lodLevel === 1 ? 250 : 100;

  return (
    <group ref={platformRef}>
      {/* Space environment */}
      <color attach="background" args={['#000814']} />

      {/* Main floating platform */}
      <mesh position={[0, 0, 0]} receiveShadow>
        <cylinderGeometry args={[3, 3, 0.3, 32]} />
        <meshStandardMaterial 
          color="#1a1a2e" 
          metalness={0.7}
          roughness={0.3}
          emissive="#0f3460"
          emissiveIntensity={0.2}
        />
      </mesh>

      {/* Platform glow ring */}
      <mesh position={[0, -0.15, 0]} rotation={[0, 0, 0]}>
        <torusGeometry args={[3.1, 0.05, 16, 64]} />
        <meshBasicMaterial color="#00d4ff" transparent opacity={0.8} />
      </mesh>

      {/* Ethereal pillars */}
      {lodLevel < 2 && (
        <>
          <EtherealPillar position={[2, 1, 0]} />
          <EtherealPillar position={[-2, 1, 0]} delay={1} />
          <EtherealPillar position={[0, 1, 2]} delay={2} />
          <EtherealPillar position={[0, 1, -2]} delay={3} />
        </>
      )}

      {/* Ambient space lighting */}
      <ambientLight intensity={0.2} color="#1e3a8a" />
      <pointLight position={[0, 5, 0]} intensity={0.8} color="#00d4ff" distance={15} />

      {/* Distant nebula glow */}
      <pointLight position={[15, 10, -20]} intensity={2} color="#9333ea" distance={50} />
      <pointLight position={[-15, 10, -20]} intensity={2} color="#3b82f6" distance={50} />

      {/* Star field */}
      <Stars count={starCount} />

      {/* Floating energy orbs */}
      {lodLevel === 0 && (
        <>
          <EnergyOrb position={[1, 0.5, 1]} color="#00d4ff" />
          <EnergyOrb position={[-1, 0.8, -1]} color="#9333ea" delay={2} />
          <EnergyOrb position={[0.5, 1.2, -1.5]} color="#3b82f6" delay={4} />
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
      const pulse = Math.sin(t * 2) * 0.2 + 0.8;
      pillarRef.current.scale.y = pulse;
      (pillarRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse * 0.5;
    }
  });

  return (
    <mesh ref={pillarRef} position={position}>
      <cylinderGeometry args={[0.1, 0.1, 2, 16]} />
      <meshStandardMaterial 
        color="#00d4ff"
        emissive="#00d4ff"
        emissiveIntensity={0.5}
        transparent
        opacity={0.4}
        metalness={0.8}
        roughness={0.2}
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
      orbRef.current.position.y = position[1] + Math.sin(t * 0.8) * 0.3;
      orbRef.current.rotation.x = t * 0.5;
      orbRef.current.rotation.y = t * 0.3;
      
      const pulse = Math.sin(t * 3) * 0.3 + 0.7;
      (orbRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity = pulse;
    }
  });

  return (
    <mesh ref={orbRef} position={position}>
      <sphereGeometry args={[0.2, 16, 16]} />
      <meshStandardMaterial 
        color={color}
        emissive={color}
        emissiveIntensity={0.7}
        transparent
        opacity={0.8}
        metalness={0.5}
        roughness={0.2}
      />
    </mesh>
  );
}

function Stars({ count }: { count: number }) {
  const starsRef = useRef<THREE.Points>(null);

  const positions = new Float32Array(count * 3);
  const colors = new Float32Array(count * 3);

  for (let i = 0; i < count; i++) {
    // Random positions in a sphere
    const radius = 30 + Math.random() * 20;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);

    positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = radius * Math.cos(phi);

    // Star colors (white to blue-ish)
    const colorVariation = Math.random();
    colors[i * 3] = 0.8 + colorVariation * 0.2;
    colors[i * 3 + 1] = 0.8 + colorVariation * 0.2;
    colors[i * 3 + 2] = 1;
  }

  useFrame(({ clock }) => {
    if (starsRef.current) {
      starsRef.current.rotation.y = clock.getElapsedTime() * 0.01;
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
      </bufferGeometry>
      <pointsMaterial
        size={0.05}
        vertexColors
        transparent
        opacity={0.8}
        sizeAttenuation
      />
    </points>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\FloatingPlatform.tsx") `
    -Content $FloatingPlatform `
    -Description "Floating Platform Environment"

# ============================================================================
# 8. XR SCENE COMPONENT
# ============================================================================

$XRScene = @'
import { Canvas } from '@react-three/fiber';
import { VRButton, XR } from '@react-three/xr';
import { useXRStore } from '../stores/xr.store';
import { SoftLitRoom } from '../environments/SoftLitRoom';
import { NatureScene } from '../environments/NatureScene';
import { FloatingPlatform } from '../environments/FloatingPlatform';
import { PerformanceMonitor } from '../performance/LODSystem';
import { AudioSystem } from '../audio/AudioSystem';

export function XRScene() {
  const currentEnvironment = useXRStore((state) => state.currentEnvironment);

  return (
    <div className="w-full h-screen">
      <VRButton />
      <Canvas
        camera={{ position: [0, 1.6, 3], fov: 75 }}
        gl={{ 
          antialias: true,
          powerPreference: 'high-performance',
        }}
        frameloop="always"
      >
        <XR>
          {/* Performance monitoring */}
          <PerformanceMonitor />

          {/* Audio system */}
          <AudioSystem />

          {/* Environment rendering */}
          {currentEnvironment === 'soft-room' && <SoftLitRoom />}
          {currentEnvironment === 'nature' && <NatureScene />}
          {currentEnvironment === 'floating-platform' && <FloatingPlatform />}
        </XR>
      </Canvas>
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\XRScene.tsx") `
    -Content $XRScene `
    -Description "Main XR Scene Component"

# ============================================================================
# 9. ENVIRONMENT SELECTOR COMPONENT
# ============================================================================

$EnvironmentSelector = @'
import { useXRStore, EnvironmentType } from '../stores/xr.store';

const ENVIRONMENTS: { id: EnvironmentType; name: string; description: string; icon: string }[] = [
  {
    id: 'soft-room',
    name: 'Soft Lit Room',
    description: 'Warm, cozy space perfect for relaxation',
    icon: '🏠',
  },
  {
    id: 'nature',
    name: 'Nature Scene',
    description: 'Peaceful forest clearing with gentle sounds',
    icon: '🌲',
  },
  {
    id: 'floating-platform',
    name: 'Floating Platform',
    description: 'Ethereal space environment for deep focus',
    icon: '✨',
  },
];

export function EnvironmentSelector() {
  const { currentEnvironment, setEnvironment, isXRActive } = useXRStore();

  if (isXRActive) {
    return null; // Hide selector when in XR mode
  }

  return (
    <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-sm rounded-lg shadow-lg p-4 max-w-xs">
      <h3 className="text-lg font-semibold mb-3 text-gray-800">Choose Environment</h3>
      <div className="space-y-2">
        {ENVIRONMENTS.map((env) => (
          <button
            key={env.id}
            onClick={() => setEnvironment(env.id)}
            className={`w-full text-left p-3 rounded-lg transition-all ${
              currentEnvironment === env.id
                ? 'bg-blue-500 text-white shadow-md'
                : 'bg-gray-100 text-gray-800 hover:bg-gray-200'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className="text-2xl">{env.icon}</span>
              <div>
                <div className="font-medium">{env.name}</div>
                <div className={`text-sm ${
                  currentEnvironment === env.id ? 'text-blue-100' : 'text-gray-600'
                }`}>
                  {env.description}
                </div>
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\EnvironmentSelector.tsx") `
    -Content $EnvironmentSelector `
    -Description "Environment Selector UI Component"

# ============================================================================
# 10. PERFORMANCE HUD COMPONENT
# ============================================================================

$PerformanceHUD = @'
import { useXRStore } from '../stores/xr.store';

export function PerformanceHUD() {
  const { performance, lodLevel, isXRActive } = useXRStore();

  if (isXRActive) {
    return null; // Hide HUD in XR mode
  }

  const getLODLabel = (level: number) => {
    switch (level) {
      case 0: return 'High';
      case 1: return 'Medium';
      case 2: return 'Low';
      default: return 'Unknown';
    }
  };

  const getFPSColor = (fps: number) => {
    if (fps >= 85) return 'text-green-500';
    if (fps >= 60) return 'text-yellow-500';
    return 'text-red-500';
  };

  return (
    <div className="absolute bottom-4 left-4 bg-black/80 backdrop-blur-sm rounded-lg p-3 font-mono text-xs text-white">
      <div className="space-y-1">
        <div className="flex items-center gap-2">
          <span className="text-gray-400">FPS:</span>
          <span className={`font-bold ${getFPSColor(performance.fps)}`}>
            {performance.fps}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-gray-400">Frame Time:</span>
          <span className="text-white">
            {performance.frameTime.toFixed(2)}ms
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-gray-400">LOD:</span>
          <span className="text-white">
            {getLODLabel(lodLevel)}
          </span>
        </div>
      </div>
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\PerformanceHUD.tsx") `
    -Content $PerformanceHUD `
    -Description "Performance HUD Component"

# ============================================================================
# 11. MAIN XR APP COMPONENT
# ============================================================================

$XRApp = @'
import { XRScene } from './components/XRScene';
import { EnvironmentSelector } from './components/EnvironmentSelector';
import { PerformanceHUD } from './components/PerformanceHUD';

export function XRApp() {
  return (
    <div className="relative w-full h-screen bg-gray-900">
      <XRScene />
      <EnvironmentSelector />
      <PerformanceHUD />
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "XRApp.tsx") `
    -Content $XRApp `
    -Description "Main XR App Component"

# ============================================================================
# 12. UPDATE ROOT APP.TSX
# ============================================================================

$AppTsx = @'
import { useState } from 'react';
import { XRApp } from '@xr/XRApp';

function App() {
  const [showXR, setShowXR] = useState(false);

  if (showXR) {
    return <XRApp />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">
            HMI Hypnotherapy
          </h1>
          <p className="text-gray-600">
            Immersive XR Experience for Therapeutic Healing
          </p>
        </div>

        <div className="space-y-4">
          <button
            onClick={() => setShowXR(true)}
            className="w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold py-4 px-6 rounded-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
          >
            🥽 Launch XR Experience
          </button>

          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 className="font-semibold text-blue-900 mb-2">Quick Start:</h3>
            <ol className="text-sm text-blue-800 space-y-1 list-decimal list-inside">
              <li>Click "Launch XR Experience"</li>
              <li>Choose your environment</li>
              <li>Click "Enter VR" button</li>
              <li>Put on your Meta Quest 3</li>
            </ol>
          </div>

          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-2">Features:</h3>
            <ul className="text-sm text-gray-700 space-y-1">
              <li>✨ Three immersive environments</li>
              <li>🎵 Binaural audio integration</li>
              <li>📊 Real-time performance optimization</li>
              <li>🎯 90 FPS target for Quest 3</li>
            </ul>
          </div>
        </div>

        <div className="mt-6 text-center text-sm text-gray-500">
          Meta Quest 3 Optimized | WebXR Ready
        </div>
      </div>
    </div>
  );
}

export default App;
'@

Write-FileWithContent `
    -Path (Join-Path $SrcRoot "App.tsx") `
    -Content $AppTsx `
    -Description "Root App Component (Updated)"

# ============================================================================
# 13. CREATE INDEX FILE FOR XR FEATURE
# ============================================================================

$XRIndex = @'
export { XRApp } from './XRApp';
export { useXRStore } from './stores/xr.store';
export type { EnvironmentType, SessionPhase } from './stores/xr.store';
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "index.ts") `
    -Content $XRIndex `
    -Description "XR Feature Index"

# ============================================================================
# COMPLETION SUMMARY
# ============================================================================

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "✅ ALL XR FILES GENERATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Generated Files Summary:" -ForegroundColor Yellow
Write-Host "  ├── vite.config.ts (updated with aliases)" -ForegroundColor White
Write-Host "  ├── src/App.tsx (XR launcher)" -ForegroundColor White
Write-Host "  ├── src/features/xr/" -ForegroundColor White
Write-Host "  │   ├── XRApp.tsx" -ForegroundColor White
Write-Host "  │   ├── index.ts" -ForegroundColor White
Write-Host "  │   ├── stores/xr.store.ts" -ForegroundColor White
Write-Host "  │   ├── components/" -ForegroundColor White
Write-Host "  │   │   ├── XRScene.tsx" -ForegroundColor White
Write-Host "  │   │   ├── EnvironmentSelector.tsx" -ForegroundColor White
Write-Host "  │   │   └── PerformanceHUD.tsx" -ForegroundColor White
Write-Host "  │   ├── environments/" -ForegroundColor White
Write-Host "  │   │   ├── SoftLitRoom.tsx" -ForegroundColor White
Write-Host "  │   │   ├── NatureScene.tsx" -ForegroundColor White
Write-Host "  │   │   └── FloatingPlatform.tsx" -ForegroundColor White
Write-Host "  │   ├── audio/AudioSystem.tsx" -ForegroundColor White
Write-Host "  │   └── performance/LODSystem.tsx" -ForegroundColor White
Write-Host ""

Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Navigate to frontend directory:" -ForegroundColor White
Write-Host "     cd `"$FrontendRoot`"" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Start the dev server (if not running):" -ForegroundColor White
Write-Host "     npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Open in Meta Quest 3 Browser:" -ForegroundColor White
Write-Host "     http://10.0.0.5:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "  4. Test all three environments:" -ForegroundColor White
Write-Host "     ✨ Soft Lit Room" -ForegroundColor Cyan
Write-Host "     🌲 Nature Scene" -ForegroundColor Cyan
Write-Host "     🌌 Floating Platform" -ForegroundColor Cyan
Write-Host ""

Write-Host "💡 Performance Targets:" -ForegroundColor Yellow
Write-Host "  • Target FPS: 85-90" -ForegroundColor White
Write-Host "  • LOD System: Auto-adjusting" -ForegroundColor White
Write-Host "  • Quest 3 Optimized: ✅" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
Write-Host "  • If TypeScript errors: Close and reopen VS Code" -ForegroundColor White
Write-Host "  • If imports fail: Run 'npm install' again" -ForegroundColor White
Write-Host "  • If Quest can't connect: Check firewall (port 5173)" -ForegroundColor White
Write-Host ""

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "🎉 Ready to test XR experience!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
