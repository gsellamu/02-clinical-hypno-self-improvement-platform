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
