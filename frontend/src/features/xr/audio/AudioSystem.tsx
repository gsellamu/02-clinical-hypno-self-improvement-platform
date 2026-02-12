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
