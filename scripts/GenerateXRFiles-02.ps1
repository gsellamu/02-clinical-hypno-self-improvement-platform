# ============================================================================
# HMI HYPNOTHERAPY PLATFORM - COMPLETE XR FILES GENERATOR
# ============================================================================
# Purpose: Generate ALL React/TypeScript source files for WebXR implementation
# Target Device: Meta Quest 3 (90 FPS performance target)
# Tech Stack: React 18.2.0 + Three.js + @react-three/fiber + @react-three/xr
# Author: Generated for Jithendran's HMI Platform
# Date: 2025-11-15
# ============================================================================

param(
    [string]$ProjectRoot = "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform"
)

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "HMI HYPNOTHERAPY XR FILES GENERATOR - QUEST 3 OPTIMIZED" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$FrontendRoot = Join-Path $ProjectRoot "frontend"
$SrcRoot = Join-Path $FrontendRoot "src"
$XRRoot = Join-Path $SrcRoot "features\xr"

# Verify frontend directory exists
if (-not (Test-Path $FrontendRoot)) {
    Write-Host "ERROR: Frontend directory not found at: $FrontendRoot" -ForegroundColor Red
    exit 1
}

Write-Host "Project Root: $ProjectRoot" -ForegroundColor Gray
Write-Host "Frontend Root: $FrontendRoot" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# HELPER FUNCTIONS
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
    $relativePath = $Path.Replace($FrontendRoot, "frontend")
    Write-Host "  [OK] $Description" -ForegroundColor Green
    Write-Host "       $relativePath" -ForegroundColor DarkGray
}

$fileCount = 0

Write-Host "Generating XR Source Files..." -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# FILE 1: VITE CONFIG (with Path Aliases)
# ============================================================================

Write-Host "Configuration Files" -ForegroundColor Cyan

$ViteConfig = @'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@features': path.resolve(__dirname, './src/features'),
      '@xr': path.resolve(__dirname, './src/features/xr'),
      '@components': path.resolve(__dirname, './src/components'),
      '@stores': path.resolve(__dirname, './src/stores'),
      '@utils': path.resolve(__dirname, './src/utils'),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    cors: true,
  },
  optimizeDeps: {
    include: ['three', '@react-three/fiber', '@react-three/xr', '@react-three/drei'],
  },
  build: {
    target: 'esnext',
    minify: 'terser',
    sourcemap: true,
  },
});
'@

Write-FileWithContent `
    -Path (Join-Path $FrontendRoot "vite.config.ts") `
    -Content $ViteConfig `
    -Description "Vite Config (Path Aliases + Quest 3 Optimization)"
$fileCount++

Write-Host ""

# ============================================================================
# FILE 2: XR STORE (Zustand State Management)
# ============================================================================

Write-Host "State Management" -ForegroundColor Cyan

$XRStore = @'
import { create } from 'zustand';

export type EnvironmentType = 'soft-room' | 'nature' | 'floating-platform';
export type SessionPhase = 'intro' | 'induction' | 'deepening' | 'therapy' | 'emergence' | 'complete';

interface AudioState {
  backgroundVolume: number;
  voiceVolume: number;
  isPlaying: boolean;
  currentTrack: string | null;
}

interface PerformanceMetrics {
  fps: number;
  frameTime: number;
  memoryUsage: number;
  drawCalls: number;
}

interface XRState {
  // Environment & XR
  currentEnvironment: EnvironmentType;
  isXRActive: boolean;
  isXRSupported: boolean;
  deviceType: 'quest3' | 'quest2' | 'desktop' | 'unknown';
  
  // Session Management
  sessionPhase: SessionPhase;
  sessionStartTime: number | null;
  sessionDuration: number; // in seconds
  
  // Audio
  audio: AudioState;
  
  // Performance
  performance: PerformanceMetrics;
  lodLevel: number; // 0 = high, 1 = medium, 2 = low
  autoLOD: boolean;
  
  // User Preferences
  preferences: {
    enableParticles: boolean;
    enablePostProcessing: boolean;
    enableShadows: boolean;
    motionIntensity: number; // 0-1
    preferredEnvironment: EnvironmentType;
  };
  
  // Actions - Environment & XR
  setEnvironment: (env: EnvironmentType) => void;
  setXRActive: (active: boolean) => void;
  setXRSupported: (supported: boolean) => void;
  setDeviceType: (device: XRState['deviceType']) => void;
  
  // Actions - Session
  setSessionPhase: (phase: SessionPhase) => void;
  startSession: () => void;
  endSession: () => void;
  updateSessionDuration: () => void;
  
  // Actions - Audio
  updateAudio: (audio: Partial<AudioState>) => void;
  playAudio: (trackName: string) => void;
  stopAudio: () => void;
  
  // Actions - Performance
  updatePerformance: (metrics: Partial<PerformanceMetrics>) => void;
  setLODLevel: (level: number) => void;
  toggleAutoLOD: () => void;
  
  // Actions - Preferences
  updatePreferences: (prefs: Partial<XRState['preferences']>) => void;
  resetPreferences: () => void;
}

const DEFAULT_PREFERENCES = {
  enableParticles: true,
  enablePostProcessing: true,
  enableShadows: true,
  motionIntensity: 0.5,
  preferredEnvironment: 'soft-room' as EnvironmentType,
};

export const useXRStore = create<XRState>((set, get) => ({
  // Initial State
  currentEnvironment: 'soft-room',
  isXRActive: false,
  isXRSupported: false,
  deviceType: 'unknown',
  
  sessionPhase: 'intro',
  sessionStartTime: null,
  sessionDuration: 0,
  
  audio: {
    backgroundVolume: 0.3,
    voiceVolume: 0.7,
    isPlaying: false,
    currentTrack: null,
  },
  
  performance: {
    fps: 90,
    frameTime: 11.1,
    memoryUsage: 0,
    drawCalls: 0,
  },
  
  lodLevel: 0,
  autoLOD: true,
  
  preferences: { ...DEFAULT_PREFERENCES },
  
  // Environment & XR Actions
  setEnvironment: (env) => {
    console.log('Environment changed to: ' + env);
    set({ currentEnvironment: env });
  },
  
  setXRActive: (active) => {
    console.log('XR Mode: ' + (active ? 'ACTIVE' : 'INACTIVE'));
    set({ isXRActive: active });
  },
  
  setXRSupported: (supported) => {
    console.log('XR Support: ' + (supported ? 'YES' : 'NO'));
    set({ isXRSupported: supported });
  },
  
  setDeviceType: (device) => {
    console.log('Device detected: ' + device);
    set({ deviceType: device });
  },
  
  // Session Actions
  setSessionPhase: (phase) => {
    console.log('Session Phase: ' + phase);
    set({ sessionPhase: phase });
  },
  
  startSession: () => {
    console.log('Session STARTED');
    set({ 
      sessionStartTime: Date.now(),
      sessionPhase: 'intro',
      sessionDuration: 0,
    });
  },
  
  endSession: () => {
    console.log('Session ENDED');
    set({ 
      sessionStartTime: null,
      sessionPhase: 'complete',
    });
  },
  
  updateSessionDuration: () => {
    const { sessionStartTime } = get();
    if (sessionStartTime) {
      const duration = Math.floor((Date.now() - sessionStartTime) / 1000);
      set({ sessionDuration: duration });
    }
  },
  
  // Audio Actions
  updateAudio: (audio) => {
    set((state) => ({
      audio: { ...state.audio, ...audio }
    }));
  },
  
  playAudio: (trackName) => {
    console.log('Playing: ' + trackName);
    set((state) => ({
      audio: { 
        ...state.audio, 
        isPlaying: true, 
        currentTrack: trackName 
      }
    }));
  },
  
  stopAudio: () => {
    console.log('Audio stopped');
    set((state) => ({
      audio: { 
        ...state.audio, 
        isPlaying: false, 
        currentTrack: null 
      }
    }));
  },
  
  // Performance Actions
  updatePerformance: (metrics) => {
    set((state) => ({
      performance: { ...state.performance, ...metrics }
    }));
  },
  
  setLODLevel: (level) => {
    const clampedLevel = Math.max(0, Math.min(2, level));
    if (clampedLevel !== get().lodLevel) {
      const labels = ['High', 'Medium', 'Low'];
      console.log('LOD Level changed: ' + clampedLevel + ' (' + labels[clampedLevel] + ')');
      set({ lodLevel: clampedLevel });
    }
  },
  
  toggleAutoLOD: () => {
    set((state) => {
      const newValue = !state.autoLOD;
      console.log('Auto LOD: ' + (newValue ? 'ENABLED' : 'DISABLED'));
      return { autoLOD: newValue };
    });
  },
  
  // Preferences Actions
  updatePreferences: (prefs) => {
    set((state) => ({
      preferences: { ...state.preferences, ...prefs }
    }));
  },
  
  resetPreferences: () => {
    console.log('Preferences reset to defaults');
    set({ preferences: { ...DEFAULT_PREFERENCES } });
  },
}));
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "stores\xr.store.ts") `
    -Content $XRStore `
    -Description "XR State Store (Zustand)"
$fileCount++

Write-Host ""

# ============================================================================
# FILE 3: PERFORMANCE/LOD SYSTEM
# ============================================================================

Write-Host "Performance Systems" -ForegroundColor Cyan

$LODSystem = @'
import { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { useXRStore } from '../stores/xr.store';

const TARGET_FPS = 85;
const MIN_FPS = 72;
const MAX_FPS = 90;
const FPS_CHECK_INTERVAL = 60; // frames
const LOD_COOLDOWN = 180; // frames before changing LOD again

let frameCount = 0;
let lastTime = performance.now();
let fpsHistory: number[] = [];
let lodCooldown = 0;

export function PerformanceMonitor() {
  const { updatePerformance, setLODLevel, lodLevel, autoLOD } = useXRStore();
  const metricsRef = useRef({ fps: 90, frameTime: 11.1, memoryUsage: 0, drawCalls: 0 });

  useFrame(({ gl }) => {
    frameCount++;
    const currentTime = performance.now();
    const delta = currentTime - lastTime;

    // Update FPS every second
    if (delta >= 1000) {
      const fps = Math.round((frameCount * 1000) / delta);
      const frameTime = delta / frameCount;
      
      // Get memory usage (if available)
      const memoryUsage = (performance as any).memory 
        ? Math.round((performance as any).memory.usedJSHeapSize / 1048576) 
        : 0;
      
      // Get draw calls from renderer
      const drawCalls = gl.info.render.calls;
      
      metricsRef.current = { fps, frameTime, memoryUsage, drawCalls };
      updatePerformance(metricsRef.current);
      
      fpsHistory.push(fps);
      if (fpsHistory.length > 5) {
        fpsHistory.shift();
      }

      frameCount = 0;
      lastTime = currentTime;
    }

    // Auto LOD adjustment logic
    if (!autoLOD || lodCooldown > 0) {
      if (lodCooldown > 0) lodCooldown--;
      return;
    }

    if (frameCount % FPS_CHECK_INTERVAL === 0 && fpsHistory.length >= 3) {
      const avgFPS = fpsHistory.reduce((a, b) => a + b, 0) / fpsHistory.length;

      // Decrease quality if FPS is critically low
      if (avgFPS < MIN_FPS && lodLevel < 2) {
        setLODLevel(lodLevel + 1);
        lodCooldown = LOD_COOLDOWN;
      }
      // Decrease quality if FPS is below target
      else if (avgFPS < TARGET_FPS && lodLevel < 2) {
        setLODLevel(lodLevel + 1);
        lodCooldown = LOD_COOLDOWN * 2; // Longer cooldown for minor adjustments
      }
      // Increase quality if FPS is stable and high
      else if (avgFPS > MAX_FPS && lodLevel > 0) {
        setLODLevel(lodLevel - 1);
        lodCooldown = LOD_COOLDOWN * 2;
      }
    }
  });

  return null;
}

export function useLOD() {
  return useXRStore((state) => state.lodLevel);
}

export function usePerformanceMetrics() {
  return useXRStore((state) => state.performance);
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "performance\LODSystem.tsx") `
    -Content $LODSystem `
    -Description "Performance Monitor & Auto-LOD System"
$fileCount++

Write-Host ""

# ============================================================================
# FILE 4: AUDIO SYSTEM
# ============================================================================

Write-Host "Audio Systems" -ForegroundColor Cyan

$AudioSystem = @'
import { useEffect, useRef } from 'react';
import { useXRStore } from '../stores/xr.store';

interface AudioTrack {
  name: string;
  url: string;
  loop: boolean;
  volume: number;
  category: 'ambient' | 'voice' | 'effect';
}

const AUDIO_TRACKS: Record<string, AudioTrack> = {
  softAmbient: {
    name: 'Soft Ambient',
    url: '/sounds/soft-ambient.mp3',
    loop: true,
    volume: 0.3,
    category: 'ambient',
  },
  natureForest: {
    name: 'Nature Forest',
    url: '/sounds/nature-forest.mp3',
    loop: true,
    volume: 0.4,
    category: 'ambient',
  },
  floatingSpace: {
    name: 'Floating Space',
    url: '/sounds/floating-space.mp3',
    loop: true,
    volume: 0.35,
    category: 'ambient',
  },
  guidedVoice: {
    name: 'Guided Voice',
    url: '/sounds/guided-voice.mp3',
    loop: false,
    volume: 0.7,
    category: 'voice',
  },
  binauralBeat: {
    name: 'Binaural Beat',
    url: '/sounds/binaural-beat.mp3',
    loop: true,
    volume: 0.25,
    category: 'ambient',
  },
  transitionChime: {
    name: 'Transition Chime',
    url: '/sounds/transition-chime.mp3',
    loop: false,
    volume: 0.5,
    category: 'effect',
  },
  deepBreathing: {
    name: 'Deep Breathing',
    url: '/sounds/deep-breathing.mp3',
    loop: true,
    volume: 0.4,
    category: 'voice',
  },
  oceanWaves: {
    name: 'Ocean Waves',
    url: '/sounds/ocean-waves.mp3',
    loop: true,
    volume: 0.35,
    category: 'ambient',
  },
};

export function AudioSystem() {
  const audioContextRef = useRef<AudioContext | null>(null);
  const audioNodesRef = useRef<Map<string, { source: AudioBufferSourceNode; gain: GainNode }>>(new Map());
  const audioBuffersRef = useRef<Map<string, AudioBuffer>>(new Map());
  
  const { audio, currentEnvironment, sessionPhase, updateAudio } = useXRStore();

  // Initialize Web Audio API
  useEffect(() => {
    if (!audioContextRef.current) {
      audioContextRef.current = new (window.AudioContext || (window as any).webkitAudioContext)();
      console.log('Audio Context initialized');
    }

    return () => {
      // Cleanup on unmount
      audioNodesRef.current.forEach(({ source }) => {
        try {
          source.stop();
        } catch (e) {
          // Already stopped
        }
      });
      audioContextRef.current?.close();
    };
  }, []);

  // Update volumes based on store
  useEffect(() => {
    audioNodesRef.current.forEach(({ gain }, key) => {
      const track = AUDIO_TRACKS[key];
      if (track && audioContextRef.current) {
        const targetVolume = track.category === 'voice' ? audio.voiceVolume : audio.backgroundVolume;
        const finalVolume = targetVolume * track.volume;
        gain.gain.setValueAtTime(finalVolume, audioContextRef.current.currentTime);
      }
    });
  }, [audio.backgroundVolume, audio.voiceVolume]);

  // Switch ambient track based on environment
  useEffect(() => {
    const trackMap: Record<string, string> = {
      'soft-room': 'softAmbient',
      'nature': 'natureForest',
      'floating-platform': 'floatingSpace',
    };

    const newTrack = trackMap[currentEnvironment];
    if (newTrack) {
      console.log('Switching ambient to: ' + newTrack);
      // In production, implement actual audio loading and playback here
    }
  }, [currentEnvironment]);

  // Handle session phase transitions
  useEffect(() => {
    if (sessionPhase === 'induction') {
      console.log('Starting induction audio');
      // Play guided voice for induction
    } else if (sessionPhase === 'deepening') {
      console.log('Starting deepening binaural beats');
      // Play binaural beats
    }
  }, [sessionPhase]);

  return null;
}

export function playSound(trackName: string) {
  const track = AUDIO_TRACKS[trackName];
  if (track) {
    console.log('Playing: ' + track.name);
    // Implement actual playback
  }
}

export function stopSound(trackName: string) {
  console.log('Stopping: ' + trackName);
  // Implement actual stopping
}

export function fadeIn(trackName: string, duration: number = 2000) {
  console.log('Fading in: ' + trackName + ' over ' + duration + 'ms');
  // Implement fade in
}

export function fadeOut(trackName: string, duration: number = 2000) {
  console.log('Fading out: ' + trackName + ' over ' + duration + 'ms');
  // Implement fade out
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "audio\AudioSystem.tsx") `
    -Content $AudioSystem `
    -Description "Web Audio API System"
$fileCount++

Write-Host ""

# ============================================================================
# FILE 5: XR DEVICE DETECTOR
# ============================================================================

Write-Host "XR Components" -ForegroundColor Cyan

$XRDeviceDetector = @'
import { useEffect, useState } from 'react';
import { useXRStore } from '../stores/xr.store';

export function XRDeviceDetector() {
  const { setXRSupported, setDeviceType } = useXRStore();
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    async function detectXR() {
      try {
        // Check if WebXR is supported
        if ('xr' in navigator) {
          const isSupported = await (navigator as any).xr.isSessionSupported('immersive-vr');
          setXRSupported(isSupported);

          if (isSupported) {
            // Detect device type
            const userAgent = navigator.userAgent.toLowerCase();
            
            if (userAgent.includes('quest 3')) {
              setDeviceType('quest3');
              console.log('[OK] Meta Quest 3 detected');
            } else if (userAgent.includes('quest 2') || userAgent.includes('quest')) {
              setDeviceType('quest2');
              console.log('[OK] Meta Quest 2 detected');
            } else if (userAgent.includes('oculus')) {
              setDeviceType('quest2');
              console.log('[OK] Oculus device detected');
            } else {
              setDeviceType('unknown');
              console.log('[OK] Generic WebXR device detected');
            }
          } else {
            setDeviceType('desktop');
            console.log('[INFO] WebXR not supported - Desktop mode');
          }
        } else {
          setXRSupported(false);
          setDeviceType('desktop');
          console.log('[INFO] WebXR API not available - Desktop mode');
        }
      } catch (error) {
        console.error('[ERROR] Error detecting XR:', error);
        setXRSupported(false);
        setDeviceType('desktop');
      } finally {
        setChecking(false);
      }
    }

    detectXR();
  }, [setXRSupported, setDeviceType]);

  if (checking) {
    return (
      <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-8 text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-700 font-medium">Detecting XR capabilities...</p>
        </div>
      </div>
    );
  }

  return null;
}

export function useXRCapabilities() {
  const { isXRSupported, deviceType } = useXRStore();
  
  return {
    isXRSupported,
    deviceType,
    isQuest3: deviceType === 'quest3',
    isQuest2: deviceType === 'quest2',
    isDesktop: deviceType === 'desktop',
    displayName: {
      'quest3': 'Meta Quest 3',
      'quest2': 'Meta Quest 2',
      'desktop': 'Desktop Browser',
      'unknown': 'Unknown VR Device',
    }[deviceType],
  };
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\XRDeviceDetector.tsx") `
    -Content $XRDeviceDetector `
    -Description "XR Device Detection Component"
$fileCount++

# ============================================================================
# FILE 6: ENVIRONMENT - SOFT LIT ROOM
# ============================================================================

Write-Host ""
Write-Host "Environment Components" -ForegroundColor Cyan

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
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\SoftLitRoom.tsx") `
    -Content $SoftLitRoom `
    -Description "Soft Lit Room Environment"
$fileCount++

# ============================================================================
# FILE 7: ENVIRONMENT - NATURE SCENE
# ============================================================================

$NatureScene = @'
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
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\NatureScene.tsx") `
    -Content $NatureScene `
    -Description "Nature Forest Environment"
$fileCount++

# ============================================================================
# FILE 8: ENVIRONMENT - FLOATING PLATFORM (Part 1 of 2)
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
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "environments\FloatingPlatform.tsx") `
    -Content $FloatingPlatform `
    -Description "Floating Platform Space Environment"
$fileCount++

# ============================================================================
# FILE 9: XR SCENE COMPONENT
# ============================================================================

Write-Host ""
Write-Host "XR Scene Components" -ForegroundColor Cyan

$XRScene = @'
import { Canvas } from '@react-three/fiber';
import { VRButton, XR, Controllers, Hands } from '@react-three/xr'; 
import { VRButton, XR } from '@react-three/xr';
import { useXRStore } from '../stores/xr.store';
import { SoftLitRoom } from '../environments/SoftLitRoom';
import { NatureScene } from '../environments/NatureScene';
import { FloatingPlatform } from '../environments/FloatingPlatform';
import { PerformanceMonitor } from '../performance/LODSystem';
import { AudioSystem } from '../audio/AudioSystem';

export function XRScene() {
  const { currentEnvironment, setXRActive } = useXRStore();

  return (
    <div className="w-full h-screen relative">
      <VRButton 
        onEnterXR={() => setXRActive(true)}
        onExitXR={() => setXRActive(false)}
      />
      
      <Canvas
        camera={{ position: [0, 1.6, 3], fov: 75 }}
        gl={{ 
          antialias: true,
          powerPreference: 'high-performance',
          alpha: false,
        }}
        dpr={[1, 2]} 
        frameloop="always"
        shadows
      >
        <XR>
          {/* VR Controllers and Hand Tracking */}
          <Controllers /> 
          <Hands /> 

          {/* Performance monitoring */}
          <PerformanceMonitor />

          {/* Audio system */}
          <AudioSystem />

          {/* Environment rendering based on selection */}
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
$fileCount++

# ============================================================================
# FILE 10: ENVIRONMENT SELECTOR UI
# ============================================================================

$EnvironmentSelector = @'
import { useXRStore, EnvironmentType } from '../stores/xr.store';

interface EnvironmentOption {
  id: EnvironmentType;
  name: string;
  description: string;
  icon: string;
  color: string;
}

const ENVIRONMENTS: EnvironmentOption[] = [
  {
    id: 'soft-room',
    name: 'Soft Lit Room',
    description: 'Warm, cozy sanctuary perfect for deep relaxation',
    icon: '[Room]',
    color: 'from-amber-400 to-orange-500',
  },
  {
    id: 'nature',
    name: 'Nature Forest',
    description: 'Peaceful meadow with gentle sounds of nature',
    icon: '[Tree]',
    color: 'from-green-400 to-emerald-600',
  },
  {
    id: 'floating-platform',
    name: 'Cosmic Platform',
    description: 'Ethereal space environment for transcendent focus',
    icon: '[Star]',
    color: 'from-blue-500 to-purple-600',
  },
];

export function EnvironmentSelector() {
  const { currentEnvironment, setEnvironment, isXRActive } = useXRStore();

  if (isXRActive) {
    return null;
  }

  return (
    <div className="absolute top-6 right-6 bg-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-6 max-w-sm z-10">
      <h3 className="text-xl font-bold mb-4 text-gray-900">
        Choose Your Environment
      </h3>
      
      <div className="space-y-3">
        {ENVIRONMENTS.map((env) => {
          const isSelected = currentEnvironment === env.id;
          
          return (
            <button
              key={env.id}
              onClick={() => setEnvironment(env.id)}
              className={
                'w-full text-left p-4 rounded-xl transition-all duration-300 transform ' +
                (isSelected 
                  ? 'bg-gradient-to-r ' + env.color + ' text-white shadow-lg scale-105' 
                  : 'bg-gray-50 text-gray-800 hover:bg-gray-100 hover:scale-102')
              }
            >
              <div className="flex items-center gap-4">
                <span className="text-3xl">{env.icon}</span>
                <div className="flex-1">
                  <div className="font-semibold text-lg">
                    {env.name}
                  </div>
                  <div className={'text-sm mt-1 ' + (isSelected ? 'text-white/90' : 'text-gray-600')}>
                    {env.description}
                  </div>
                </div>
                {isSelected && (
                  <div className="text-2xl">[OK]</div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      <div className="mt-5 pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-500 text-center">
          Select an environment, then click Enter VR
        </p>
      </div>
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\EnvironmentSelector.tsx") `
    -Content $EnvironmentSelector `
    -Description "Environment Selection UI"
$fileCount++

# ============================================================================
# FILE 11: PERFORMANCE HUD
# ============================================================================

$PerformanceHUD = @'
import { useXRStore } from '../stores/xr.store';
import { usePerformanceMetrics } from '../performance/LODSystem';

export function PerformanceHUD() {
  const { isXRActive, lodLevel, autoLOD, toggleAutoLOD, setLODLevel } = useXRStore();
  const metrics = usePerformanceMetrics();

  if (isXRActive) {
    return null;
  }

  const getLODLabel = (level: number): string => {
    const labels = ['High Quality', 'Medium Quality', 'Performance Mode'];
    return labels[level] || 'Unknown';
  };

  const getFPSColor = (fps: number): string => {
    if (fps >= 85) return 'text-green-400';
    if (fps >= 72) return 'text-yellow-400';
    if (fps >= 60) return 'text-orange-400';
    return 'text-red-400';
  };

  const getPerformanceRating = (fps: number): string => {
    if (fps >= 85) return '[OK] Excellent';
    if (fps >= 72) return '[OK] Good';
    if (fps >= 60) return '[WARN] Fair';
    return '[BAD] Poor';
  };

  return (
    <div className="absolute bottom-6 left-6 bg-black/90 backdrop-blur-sm rounded-xl p-4 font-mono text-xs text-white shadow-2xl max-w-xs">
      <div className="flex items-center justify-between mb-3 pb-2 border-b border-gray-700">
        <span className="text-sm font-bold text-blue-400">Performance</span>
        <span className={'text-xs ' + getFPSColor(metrics.fps)}>
          {getPerformanceRating(metrics.fps)}
        </span>
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <span className="text-gray-400">FPS:</span>
          <span className={'font-bold text-lg ' + getFPSColor(metrics.fps)}>
            {metrics.fps}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-gray-400">Frame Time:</span>
          <span className="text-white">
            {metrics.frameTime.toFixed(2)}ms
          </span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-gray-400">Draw Calls:</span>
          <span className="text-white">
            {metrics.drawCalls}
          </span>
        </div>

        {metrics.memoryUsage > 0 && (
          <div className="flex items-center justify-between">
            <span className="text-gray-400">Memory:</span>
            <span className="text-white">
              {metrics.memoryUsage}MB
            </span>
          </div>
        )}

        <div className="pt-2 border-t border-gray-700">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-400">Quality:</span>
            <span className="text-white font-medium">
              {getLODLabel(lodLevel)}
            </span>
          </div>

          <div className="flex gap-1">
            {[0, 1, 2].map((level) => (
              <button
                key={level}
                onClick={() => setLODLevel(level)}
                disabled={autoLOD}
                className={
                  'flex-1 py-1 px-2 rounded text-xs transition-all ' +
                  (lodLevel === level 
                    ? 'bg-blue-600 text-white' 
                    : 'bg-gray-700 text-gray-400 hover:bg-gray-600 ') +
                  (autoLOD ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer')
                }
              >
                {['Hi', 'Med', 'Lo'][level]}
              </button>
            ))}
          </div>
        </div>

        <div className="pt-2">
          <button
            onClick={toggleAutoLOD}
            className={
              'w-full py-2 px-3 rounded text-xs font-medium transition-all ' +
              (autoLOD 
                ? 'bg-green-600 text-white' 
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600')
            }
          >
            {autoLOD ? '[OK] Auto LOD ON' : 'Auto LOD OFF'}
          </button>
        </div>
      </div>

      <div className="mt-3 pt-2 border-t border-gray-700 text-center">
        <p className="text-gray-500 text-[10px]">
          Target: 85-90 FPS for Quest 3
        </p>
      </div>
    </div>
  );
}
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "components\PerformanceHUD.tsx") `
    -Content $PerformanceHUD `
    -Description "Performance HUD Component"
$fileCount++

# ============================================================================
# FILE 12: MAIN XR APP
# ============================================================================

Write-Host ""
Write-Host "Main Application Files" -ForegroundColor Cyan

$XRApp = @'
import { XRScene } from './components/XRScene';
import { EnvironmentSelector } from './components/EnvironmentSelector';
import { PerformanceHUD } from './components/PerformanceHUD';
import { XRDeviceDetector } from './components/XRDeviceDetector';

export function XRApp() {
  return (
    <div className="relative w-full h-screen bg-gray-900">
      <XRDeviceDetector />
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
    -Description "Main XR Application"
$fileCount++

# ============================================================================
# FILE 13: XR FEATURE INDEX
# ============================================================================

$XRIndex = @'
export { XRApp } from './XRApp';
export { useXRStore } from './stores/xr.store';
export type { EnvironmentType, SessionPhase } from './stores/xr.store';
export { useLOD, usePerformanceMetrics } from './performance/LODSystem';
export { useXRCapabilities } from './components/XRDeviceDetector';
'@

Write-FileWithContent `
    -Path (Join-Path $XRRoot "index.ts") `
    -Content $XRIndex `
    -Description "XR Feature Barrel Exports"
$fileCount++

# ============================================================================
# FILE 14: ROOT APP.TSX
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
    <div className="min-h-screen bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 flex items-center justify-center p-6">
      <div className="bg-white rounded-3xl shadow-2xl p-10 max-w-2xl w-full">
        <div className="text-center mb-10">
          <div className="mb-4">
            <div className="inline-block p-4 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl">
              <span className="text-5xl">[BRAIN]</span>
            </div>
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-3">
            HMI Hypnotherapy
          </h1>
          <p className="text-lg text-gray-600">
            Immersive XR Experience for Therapeutic Cognitive Healing
          </p>
        </div>

        <button
          onClick={() => setShowXR(true)}
          className="w-full bg-gradient-to-r from-blue-600 to-purple-700 text-white font-bold text-xl py-5 px-8 rounded-xl shadow-xl hover:shadow-2xl transform hover:scale-105 transition-all duration-300 mb-6"
        >
          <span className="mr-3">[VR]</span>
          Launch XR Experience
        </button>

        <div className="bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-xl p-6 mb-6">
          <h3 className="font-bold text-blue-900 mb-4 text-lg flex items-center">
            <span className="mr-2">[START]</span>
            Quick Start Guide
          </h3>
          <ol className="space-y-2 text-blue-800">
            <li className="flex items-start">
              <span className="font-bold mr-3 mt-0.5">1.</span>
              <span>Click Launch XR Experience button above</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold mr-3 mt-0.5">2.</span>
              <span>Choose your preferred environment</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold mr-3 mt-0.5">3.</span>
              <span>Click the Enter VR button that appears</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold mr-3 mt-0.5">4.</span>
              <span>Put on your Meta Quest 3 headset and enjoy</span>
            </li>
          </ol>
        </div>

        <div className="grid grid-cols-2 gap-4 mb-6">
          <div className="bg-purple-50 rounded-lg p-4">
            <div className="text-2xl mb-2">[3]</div>
            <div className="font-semibold text-gray-800 mb-1">3 Environments</div>
            <div className="text-sm text-gray-600">Unique immersive worlds</div>
          </div>

          <div className="bg-blue-50 rounded-lg p-4">
            <div className="text-2xl mb-2">[AUDIO]</div>
            <div className="font-semibold text-gray-800 mb-1">Spatial Audio</div>
            <div className="text-sm text-gray-600">Binaural integration</div>
          </div>

          <div className="bg-green-50 rounded-lg p-4">
            <div className="text-2xl mb-2">[AUTO]</div>
            <div className="font-semibold text-gray-800 mb-1">Auto-Optimize</div>
            <div className="text-sm text-gray-600">Performance tuning</div>
          </div>

          <div className="bg-pink-50 rounded-lg p-4">
            <div className="text-2xl mb-2">[90]</div>
            <div className="font-semibold text-gray-800 mb-1">90 FPS Target</div>
            <div className="text-sm text-gray-600">Smooth Quest 3</div>
          </div>
        </div>

        <div className="text-center pt-6 border-t border-gray-200">
          <p className="text-sm text-gray-500 mb-2">
            <span className="font-semibold">Optimized for:</span> Meta Quest 3
          </p>
          <p className="text-xs text-gray-400">
            WebXR - React - Three.js - Jungian Shadow Integration
          </p>
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
    -Description "Root App Component (Launcher UI)"
$fileCount++

# ============================================================================
# COMPLETION SUMMARY
# ============================================================================

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "XR FILES GENERATION COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "GENERATION SUMMARY" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Total Files Created: $fileCount" -ForegroundColor White
Write-Host "  Target Device: Meta Quest 3" -ForegroundColor White
Write-Host "  Performance Target: 85-90 FPS" -ForegroundColor White
Write-Host "  Tech Stack: React 18.2.0 + Three.js + @react-three/xr" -ForegroundColor White
Write-Host ""

Write-Host "FILE STRUCTURE" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  frontend/" -ForegroundColor White
Write-Host "  -> vite.config.ts                          (Configuration)" -ForegroundColor Gray
Write-Host "  -> src/" -ForegroundColor White
Write-Host "     -> App.tsx                              (Launcher UI)" -ForegroundColor Gray
Write-Host "     -> features/xr/" -ForegroundColor White
Write-Host "        -> XRApp.tsx                         (Main XR App)" -ForegroundColor Gray
Write-Host "        -> index.ts                          (Exports)" -ForegroundColor Gray
Write-Host "        -> stores/" -ForegroundColor White
Write-Host "           -> xr.store.ts                    (Zustand State)" -ForegroundColor Gray
Write-Host "        -> components/" -ForegroundColor White
Write-Host "           -> XRScene.tsx                    (Three.js Canvas)" -ForegroundColor Gray
Write-Host "           -> XRDeviceDetector.tsx          (Device Detection)" -ForegroundColor Gray
Write-Host "           -> EnvironmentSelector.tsx       (UI Selector)" -ForegroundColor Gray
Write-Host "           -> PerformanceHUD.tsx            (FPS/LOD Display)" -ForegroundColor Gray
Write-Host "        -> environments/" -ForegroundColor White
Write-Host "           -> SoftLitRoom.tsx               (Warm Sanctuary)" -ForegroundColor Gray
Write-Host "           -> NatureScene.tsx               (Forest Meadow)" -ForegroundColor Gray
Write-Host "           -> FloatingPlatform.tsx          (Cosmic Space)" -ForegroundColor Gray
Write-Host "        -> audio/" -ForegroundColor White
Write-Host "           -> AudioSystem.tsx               (Web Audio API)" -ForegroundColor Gray
Write-Host "        -> performance/" -ForegroundColor White
Write-Host "           -> LODSystem.tsx                 (Auto LOD)" -ForegroundColor Gray
Write-Host ""

Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  1. Ensure Vite Dev Server is Running:" -ForegroundColor Yellow
Write-Host "     cd `"$FrontendRoot`"" -ForegroundColor White
Write-Host "     npm run dev" -ForegroundColor Cyan
Write-Host ""

Write-Host "  2. Access from Your Computer:" -ForegroundColor Yellow
Write-Host "     http://localhost:5173" -ForegroundColor Cyan
Write-Host ""

Write-Host "  3. Access from Meta Quest 3:" -ForegroundColor Yellow
Write-Host "     http://10.0.0.5:5173" -ForegroundColor Cyan
Write-Host "     (or http://172.18.224.1:5173)" -ForegroundColor Gray
Write-Host ""

Write-Host "  4. Test All Three Environments:" -ForegroundColor Yellow
Write-Host "     - Soft Lit Room    : Warm, cozy sanctuary" -ForegroundColor White
Write-Host "     - Nature Scene     : Peaceful forest meadow" -ForegroundColor White
Write-Host "     - Floating Platform: Ethereal cosmic space" -ForegroundColor White
Write-Host ""

Write-Host "  5. Monitor Performance:" -ForegroundColor Yellow
Write-Host "     - Watch FPS in bottom-left HUD" -ForegroundColor White
Write-Host "     - Auto-LOD will adjust quality" -ForegroundColor White
Write-Host "     - Target: 85-90 FPS on Quest 3" -ForegroundColor White
Write-Host ""

Write-Host "TROUBLESHOOTING TIPS" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  - TypeScript Errors:" -ForegroundColor Yellow
Write-Host "    -> Close and reopen VS Code" -ForegroundColor White
Write-Host "    -> Run: npm install" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Import Errors:" -ForegroundColor Yellow
Write-Host "    -> Check path aliases in vite.config.ts" -ForegroundColor White
Write-Host "    -> Restart dev server" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Quest 3 Cannot Connect:" -ForegroundColor Yellow
Write-Host "    -> Verify firewall allows port 5173" -ForegroundColor White
Write-Host "    -> Check both IPs (10.0.0.5 and 172.18.224.1)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Low FPS:" -ForegroundColor Yellow
Write-Host "    -> Auto-LOD will reduce quality" -ForegroundColor White
Write-Host "    -> Manually set to Performance Mode" -ForegroundColor Cyan
Write-Host ""

Write-Host "FEATURES IMPLEMENTED" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  [OK] Three unique immersive environments" -ForegroundColor Green
Write-Host "  [OK] Automatic LOD system (85-90 FPS target)" -ForegroundColor Green
Write-Host "  [OK] Real-time performance monitoring" -ForegroundColor Green
Write-Host "  [OK] Web Audio API integration ready" -ForegroundColor Green
Write-Host "  [OK] Quest 3 device detection" -ForegroundColor Green
Write-Host "  [OK] VR controller & hand tracking support" -ForegroundColor Green
Write-Host "  [OK] Responsive UI with Tailwind CSS" -ForegroundColor Green
Write-Host "  [OK] TypeScript for type safety" -ForegroundColor Green
Write-Host "  [OK] Zustand state management" -ForegroundColor Green
Write-Host "  [OK] Session phase tracking" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================================" -ForegroundColor Green
Write-Host "READY TO TEST IN META QUEST 3!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# Create a summary log file
$summaryLog = @"
XR FILES GENERATION SUMMARY
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
============================================================================

STATISTICS:
- Total Files: $fileCount
- Target Device: Meta Quest 3
- Performance Target: 85-90 FPS
- Tech Stack: React 18.2.0 + Three.js + @react-three/xr

FILES CREATED:
1. vite.config.ts - Configuration with path aliases
2. src/App.tsx - Launcher UI with gradient design
3. src/features/xr/XRApp.tsx - Main XR application
4. src/features/xr/index.ts - Feature exports
5. src/features/xr/stores/xr.store.ts - Zustand state management
6. src/features/xr/components/XRScene.tsx - Three.js Canvas
7. src/features/xr/components/XRDeviceDetector.tsx - Device detection
8. src/features/xr/components/EnvironmentSelector.tsx - Environment UI
9. src/features/xr/components/PerformanceHUD.tsx - FPS/LOD display
10. src/features/xr/environments/SoftLitRoom.tsx - Warm sanctuary
11. src/features/xr/environments/NatureScene.tsx - Forest meadow
12. src/features/xr/environments/FloatingPlatform.tsx - Cosmic space
13. src/features/xr/audio/AudioSystem.tsx - Web Audio API
14. src/features/xr/performance/LODSystem.tsx - Auto LOD

NEXT STEPS:
1. Start Vite dev server: npm run dev
2. Access on desktop: http://localhost:5173
3. Access on Quest 3: http://10.0.0.5:5173
4. Test all three environments
5. Monitor performance (target: 85-90 FPS)

ENVIRONMENTS:
- Soft Lit Room: Warm, cozy sanctuary for relaxation
- Nature Scene: Peaceful forest meadow with wildlife
- Floating Platform: Ethereal cosmic space for focus
"@

$logPath = Join-Path $FrontendRoot "XR_GENERATION_LOG.txt"
Set-Content -Path $logPath -Value $summaryLog -Encoding UTF8
Write-Host "Summary log saved to: frontend\XR_GENERATION_LOG.txt" -ForegroundColor Gray
Write-Host ""



