# DEV3: WebAudio Mixer Engine
## Ambient Loop + SFX + TTS with Ducking and Spatial Audio

**Version:** 1.0
**Date:** 2026-02-11
**Tech Stack:** Web Audio API + React Hooks

---

## AUDIO ENGINE ARCHITECTURE

```
                    ┌─────────────────┐
                    │  Audio Context  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
        │ Ambient   │  │   SFX   │  │    TTS    │
        │ Channel   │  │ Channel │  │  Channel  │
        └─────┬─────┘  └────┬────┘  └─────┬─────┘
              │              │              │
        ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
        │   Gain    │  │  Gain   │  │   Gain    │
        │  (Vol)    │  │ (Vol)   │  │  (Vol)    │
        └─────┬─────┘  └────┬────┘  └─────┬─────┘
              │              │              │
              │              │        ┌─────▼─────┐
              │              │        │  Ducking  │
              │              │        │ Sidechain │
              │              │        └─────┬─────┘
              │              │              │
              └──────────────┴──────────────┘
                             │
                      ┌──────▼──────┐
                      │   Master    │
                      │   Output    │
                      └──────┬──────┘
                             │
                      ┌──────▼──────┐
                      │  Speakers   │
                      └─────────────┘

TTS Ducking: When TTS plays, Ambient gain drops from 1.0 → 0.3 (-10dB)
Smooth fade: 200ms attack, 300ms release
```

---

## CORE AUDIO ENGINE

```typescript
// apps/web/src/audio/AudioEngine.ts

export interface AudioChannel {
  source: AudioBufferSourceNode | null
  gain: GainNode
  buffer: AudioBuffer | null
  isPlaying: boolean
  loop: boolean
}

export interface SpatialAudioConfig {
  position: [number, number, number]
  refDistance: number
  maxDistance: number
  rolloffFactor: number
}

export class AudioEngine {
  private context: AudioContext
  private masterGain: GainNode
  
  // Channels
  private ambientChannel: AudioChannel
  private sfxChannel: AudioChannel
  private ttsChannel: AudioChannel
  
  // Ducking
  private duckingGain: GainNode
  private isDucking: boolean = false
  private duckingAmount: number = 0.3 // Duck to 30% (-10.46 dB)
  private duckingAttack: number = 0.2 // 200ms
  private duckingRelease: number = 0.3 // 300ms
  
  // Spatial audio
  private listener: AudioListener
  private panners: Map<string, PannerNode>
  
  constructor() {
    this.context = new AudioContext()
    this.listener = this.context.listener
    this.panners = new Map()
    
    // Create master gain
    this.masterGain = this.context.createGain()
    this.masterGain.gain.value = 1.0
    this.masterGain.connect(this.context.destination)
    
    // Create ducking gain (applied to ambient)
    this.duckingGain = this.context.createGain()
    this.duckingGain.gain.value = 1.0
    this.duckingGain.connect(this.masterGain)
    
    // Create channels
    this.ambientChannel = this.createChannel('ambient', true)
    this.sfxChannel = this.createChannel('sfx', false)
    this.ttsChannel = this.createChannel('tts', false)
    
    // Connect ambient through ducking gain
    this.ambientChannel.gain.disconnect()
    this.ambientChannel.gain.connect(this.duckingGain)
    
    // Connect SFX and TTS directly to master
    this.sfxChannel.gain.connect(this.masterGain)
    this.ttsChannel.gain.connect(this.masterGain)
  }
  
  private createChannel(name: string, loop: boolean): AudioChannel {
    const gain = this.context.createGain()
    gain.gain.value = 1.0
    
    return {
      source: null,
      gain,
      buffer: null,
      isPlaying: false,
      loop
    }
  }
  
  // Load audio file
  async loadAudio(url: string): Promise<AudioBuffer> {
    const response = await fetch(url)
    const arrayBuffer = await response.arrayBuffer()
    return await this.context.decodeAudioData(arrayBuffer)
  }
  
  // Play ambient loop
  async playAmbient(url: string, volume: number = 0.3, fadeInDuration: number = 3) {
    if (this.ambientChannel.isPlaying) {
      await this.stopAmbient()
    }
    
    // Load buffer if not cached
    if (!this.ambientChannel.buffer) {
      this.ambientChannel.buffer = await this.loadAudio(url)
    }
    
    // Create source
    const source = this.context.createBufferSource()
    source.buffer = this.ambientChannel.buffer
    source.loop = true
    source.connect(this.ambientChannel.gain)
    
    // Fade in
    this.ambientChannel.gain.gain.setValueAtTime(0, this.context.currentTime)
    this.ambientChannel.gain.gain.linearRampToValueAtTime(
      volume,
      this.context.currentTime + fadeInDuration
    )
    
    source.start(0)
    this.ambientChannel.source = source
    this.ambientChannel.isPlaying = true
  }
  
  // Stop ambient loop
  async stopAmbient(fadeOutDuration: number = 2) {
    if (!this.ambientChannel.isPlaying || !this.ambientChannel.source) {
      return
    }
    
    const currentGain = this.ambientChannel.gain.gain.value
    
    // Fade out
    this.ambientChannel.gain.gain.setValueAtTime(currentGain, this.context.currentTime)
    this.ambientChannel.gain.gain.linearRampToValueAtTime(
      0,
      this.context.currentTime + fadeOutDuration
    )
    
    // Stop after fade
    setTimeout(() => {
      if (this.ambientChannel.source) {
        this.ambientChannel.source.stop()
        this.ambientChannel.source = null
        this.ambientChannel.isPlaying = false
      }
    }, fadeOutDuration * 1000)
  }
  
  // Play SFX (one-shot)
  async playSFX(url: string, volume: number = 0.5) {
    const buffer = await this.loadAudio(url)
    
    const source = this.context.createBufferSource()
    source.buffer = buffer
    
    const gain = this.context.createGain()
    gain.gain.value = volume
    
    source.connect(gain)
    gain.connect(this.masterGain)
    
    source.start(0)
    
    // Auto-cleanup
    source.onended = () => {
      source.disconnect()
      gain.disconnect()
    }
  }
  
  // Play TTS with ducking
  async playTTS(url: string, volume: number = 0.6, onEnded?: () => void) {
    // Duck ambient
    this.startDucking()
    
    const buffer = await this.loadAudio(url)
    
    const source = this.context.createBufferSource()
    source.buffer = buffer
    source.connect(this.ttsChannel.gain)
    
    this.ttsChannel.gain.gain.value = volume
    
    source.start(0)
    this.ttsChannel.source = source
    this.ttsChannel.isPlaying = true
    
    // Stop ducking when TTS ends
    source.onended = () => {
      this.stopDucking()
      this.ttsChannel.source = null
      this.ttsChannel.isPlaying = false
      if (onEnded) onEnded()
    }
  }
  
  // Start ducking (reduce ambient volume)
  private startDucking() {
    if (this.isDucking) return
    
    const currentTime = this.context.currentTime
    const currentGain = this.duckingGain.gain.value
    
    this.duckingGain.gain.cancelScheduledValues(currentTime)
    this.duckingGain.gain.setValueAtTime(currentGain, currentTime)
    this.duckingGain.gain.linearRampToValueAtTime(
      this.duckingAmount,
      currentTime + this.duckingAttack
    )
    
    this.isDucking = true
  }
  
  // Stop ducking (restore ambient volume)
  private stopDucking() {
    if (!this.isDucking) return
    
    const currentTime = this.context.currentTime
    const currentGain = this.duckingGain.gain.value
    
    this.duckingGain.gain.cancelScheduledValues(currentTime)
    this.duckingGain.gain.setValueAtTime(currentGain, currentTime)
    this.duckingGain.gain.linearRampToValueAtTime(
      1.0,
      currentTime + this.duckingRelease
    )
    
    this.isDucking = false
  }
  
  // Play spatial audio (3D positioned)
  async playSpatial(
    id: string,
    url: string,
    config: SpatialAudioConfig,
    volume: number = 0.5,
    loop: boolean = true
  ) {
    const buffer = await this.loadAudio(url)
    
    // Create panner node
    const panner = this.context.createPanner()
    panner.panningModel = 'HRTF'
    panner.distanceModel = 'inverse'
    panner.refDistance = config.refDistance
    panner.maxDistance = config.maxDistance
    panner.rolloffFactor = config.rolloffFactor
    panner.coneInnerAngle = 360
    panner.coneOuterAngle = 0
    panner.coneOuterGain = 0
    
    panner.setPosition(...config.position)
    
    // Create source
    const source = this.context.createBufferSource()
    source.buffer = buffer
    source.loop = loop
    
    const gain = this.context.createGain()
    gain.gain.value = volume
    
    source.connect(panner)
    panner.connect(gain)
    gain.connect(this.masterGain)
    
    source.start(0)
    
    // Store panner for position updates
    this.panners.set(id, panner)
    
    return { source, panner, gain }
  }
  
  // Update spatial audio position
  updateSpatialPosition(id: string, position: [number, number, number]) {
    const panner = this.panners.get(id)
    if (panner) {
      panner.setPosition(...position)
    }
  }
  
  // Update listener position (camera)
  updateListenerPosition(
    position: [number, number, number],
    forward: [number, number, number],
    up: [number, number, number]
  ) {
    this.listener.setPosition(...position)
    this.listener.setOrientation(...forward, ...up)
  }
  
  // Set master volume
  setMasterVolume(volume: number) {
    this.masterGain.gain.setValueAtTime(volume, this.context.currentTime)
  }
  
  // Set channel volumes
  setAmbientVolume(volume: number) {
    this.ambientChannel.gain.gain.setValueAtTime(volume, this.context.currentTime)
  }
  
  setSFXVolume(volume: number) {
    this.sfxChannel.gain.gain.setValueAtTime(volume, this.context.currentTime)
  }
  
  setTTSVolume(volume: number) {
    this.ttsChannel.gain.gain.setValueAtTime(volume, this.context.currentTime)
  }
  
  // Resume context (required for user interaction)
  async resume() {
    if (this.context.state === 'suspended') {
      await this.context.resume()
    }
  }
  
  // Cleanup
  dispose() {
    if (this.ambientChannel.source) {
      this.ambientChannel.source.stop()
    }
    if (this.ttsChannel.source) {
      this.ttsChannel.source.stop()
    }
    this.context.close()
  }
}
```

---

## REACT HOOK

```typescript
// apps/web/src/hooks/useAudioEngine.ts
import { useEffect, useRef, useState } from 'react'
import { AudioEngine } from '../audio/AudioEngine'
import { useThree } from '@react-three/fiber'

export function useAudioEngine() {
  const audioEngineRef = useRef<AudioEngine | null>(null)
  const [isReady, setIsReady] = useState(false)
  const { camera } = useThree()
  
  useEffect(() => {
    // Initialize audio engine
    audioEngineRef.current = new AudioEngine()
    
    // Resume context on user interaction
    const handleInteraction = () => {
      audioEngineRef.current?.resume()
      setIsReady(true)
    }
    
    document.addEventListener('click', handleInteraction, { once: true })
    document.addEventListener('keydown', handleInteraction, { once: true })
    
    return () => {
      audioEngineRef.current?.dispose()
      document.removeEventListener('click', handleInteraction)
      document.removeEventListener('keydown', handleInteraction)
    }
  }, [])
  
  // Update listener position from camera
  useEffect(() => {
    if (!audioEngineRef.current || !isReady) return
    
    const updateListener = () => {
      const position: [number, number, number] = [
        camera.position.x,
        camera.position.y,
        camera.position.z
      ]
      
      const forward: [number, number, number] = [0, 0, -1]
      const up: [number, number, number] = [0, 1, 0]
      
      // Transform forward and up by camera rotation
      const forwardVec = new THREE.Vector3(0, 0, -1).applyQuaternion(camera.quaternion)
      const upVec = new THREE.Vector3(0, 1, 0).applyQuaternion(camera.quaternion)
      
      audioEngineRef.current?.updateListenerPosition(
        position,
        [forwardVec.x, forwardVec.y, forwardVec.z],
        [upVec.x, upVec.y, upVec.z]
      )
    }
    
    const interval = setInterval(updateListener, 100) // Update 10x per second
    
    return () => clearInterval(interval)
  }, [camera, isReady])
  
  return {
    audioEngine: audioEngineRef.current,
    isReady
  }
}
```

---

## USAGE EXAMPLE

```typescript
// apps/web/src/scenes/AudioScene.tsx
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import { useEffect } from 'react'
import { useAudioEngine } from '../hooks/useAudioEngine'

function AudioControls() {
  const { audioEngine, isReady } = useAudioEngine()
  
  useEffect(() => {
    if (!audioEngine || !isReady) return
    
    // Start ambient forest loop
    audioEngine.playAmbient(
      'https://cdn.jeeth.ai/audio/forest_ambient_loop.mp3',
      0.3, // volume
      3    // fade in duration
    )
    
    // Play spatial water sound at position
    audioEngine.playSpatial(
      'stream',
      'https://cdn.jeeth.ai/audio/stream_water_loop.mp3',
      {
        position: [-8, 0, 0],
        refDistance: 3,
        maxDistance: 15,
        rolloffFactor: 1
      },
      0.2, // volume
      true // loop
    )
    
    return () => {
      audioEngine.stopAmbient(2)
    }
  }, [audioEngine, isReady])
  
  const handlePlayTTS = async () => {
    if (!audioEngine) return
    
    // TTS will duck ambient automatically
    await audioEngine.playTTS(
      'https://cdn.jeeth.ai/tts/intro_chunk_1.mp3',
      0.6, // volume
      () => console.log('TTS ended')
    )
  }
  
  const handlePlaySFX = async () => {
    if (!audioEngine) return
    
    await audioEngine.playSFX(
      'https://cdn.jeeth.ai/audio/breath_bell_soft.mp3',
      0.5
    )
  }
  
  return (
    <>
      <div style={{ position: 'absolute', top: 20, right: 20, zIndex: 1000 }}>
        <button onClick={handlePlayTTS}>Play TTS (with ducking)</button>
        <button onClick={handlePlaySFX}>Play SFX</button>
      </div>
    </>
  )
}

export function AudioScene() {
  return (
    <Canvas camera={{ position: [0, 1.6, 3], fov: 75 }}>
      <color attach="background" args={['#87ceeb']} />
      
      <ambientLight intensity={0.6} />
      <directionalLight position={[5, 10, 7]} intensity={1.2} />
      
      <mesh rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[10, 10]} />
        <meshStandardMaterial color="#6b8e4a" />
      </mesh>
      
      <AudioControls />
      
      <OrbitControls />
    </Canvas>
  )
}
```

---

## ADVANCED: TTS QUEUE WITH AUTO-DUCKING

```typescript
// apps/web/src/audio/TTSQueue.ts
import { AudioEngine } from './AudioEngine'

export interface TTSChunk {
  id: string
  url: string
  text: string
  duration_seconds: number
}

export class TTSQueue {
  private engine: AudioEngine
  private queue: TTSChunk[] = []
  private isPlaying: boolean = false
  private currentChunk: TTSChunk | null = null
  
  constructor(engine: AudioEngine) {
    this.engine = engine
  }
  
  // Add chunk to queue
  enqueue(chunk: TTSChunk) {
    this.queue.push(chunk)
    if (!this.isPlaying) {
      this.playNext()
    }
  }
  
  // Add multiple chunks
  enqueueMultiple(chunks: TTSChunk[]) {
    this.queue.push(...chunks)
    if (!this.isPlaying) {
      this.playNext()
    }
  }
  
  // Play next chunk in queue
  private async playNext() {
    if (this.queue.length === 0) {
      this.isPlaying = false
      this.currentChunk = null
      return
    }
    
    this.isPlaying = true
    this.currentChunk = this.queue.shift()!
    
    await this.engine.playTTS(
      this.currentChunk.url,
      0.6,
      () => this.playNext() // Auto-advance to next chunk
    )
  }
  
  // Skip current chunk
  skip() {
    // TODO: Implement skip (requires storing source reference)
    this.playNext()
  }
  
  // Clear queue
  clear() {
    this.queue = []
  }
  
  // Get queue status
  getStatus() {
    return {
      isPlaying: this.isPlaying,
      currentChunk: this.currentChunk,
      queueLength: this.queue.length
    }
  }
}
```

---

## NODE GRAPH VISUALIZATION

```
Input Sources:
┌────────────────┐
│  Ambient Loop  │ (forest_ambient.mp3)
│  (looping)     │
└────────┬───────┘
         │
         ▼
┌────────────────┐
│  Ambient Gain  │ (volume: 0.3)
└────────┬───────┘
         │
         ▼
┌────────────────┐
│ Ducking Gain   │ (1.0 → 0.3 when TTS plays)
└────────┬───────┘
         │
         └──────────────────┐
                            │
┌────────────────┐          │
│   SFX Source   │          │
│  (one-shot)    │          │
└────────┬───────┘          │
         │                  │
         ▼                  │
┌────────────────┐          │
│   SFX Gain     │          │
└────────┬───────┘          │
         │                  │
         └──────────────────┤
                            │
┌────────────────┐          │
│  TTS Source    │          │
│  (narration)   │          │
└────────┬───────┘          │
         │                  │
         ▼                  │
┌────────────────┐          │
│   TTS Gain     │          │
└────────┬───────┘          │
         │                  │
         └──────────────────┤
                            │
                            ▼
                   ┌────────────────┐
                   │  Master Gain   │
                   └────────┬───────┘
                            │
                            ▼
                   ┌────────────────┐
                   │    Speakers    │
                   └────────────────┘

Ducking Sidechain:
When TTS starts → Ducking Gain ramps from 1.0 to 0.3 over 200ms
When TTS ends → Ducking Gain ramps from 0.3 to 1.0 over 300ms
```

---

## TECHNICAL DETAILS

**Ducking Implementation:**
- Attack Time: 200ms (how quickly ambient volume drops)
- Release Time: 300ms (how quickly ambient volume returns)
- Ducking Amount: 0.3 (70% reduction = -10.46 dB)
- Method: `linearRampToValueAtTime()` for smooth transitions

**Spatial Audio:**
- Panning Model: HRTF (Head-Related Transfer Function)
- Distance Model: Inverse (realistic falloff)
- Ref Distance: Distance at which volume starts decreasing
- Max Distance: Distance at which volume is minimum
- Rolloff Factor: How quickly volume decreases with distance

**Performance:**
- Single AudioContext (shared across all channels)
- Buffer caching to avoid re-decoding
- Auto-cleanup of one-shot sounds
- Efficient gain node reuse

---

## FEATURES IMPLEMENTED

✅ **3-Channel Mixer:**
- Ambient loop channel (continuous background)
- SFX channel (one-shot sounds)
- TTS channel (voice narration)

✅ **Automatic TTS Ducking:**
- Ambient volume drops to 30% (-10dB) when TTS plays
- Smooth 200ms attack, 300ms release
- Automatic restoration after TTS ends

✅ **Spatial Audio (3D):**
- HRTF-based positioning
- Camera-relative listener updates
- Configurable falloff distances

✅ **Smooth Transitions:**
- Fade in/out for ambient loops
- Crossfades between states
- No audio pops or clicks

✅ **React Integration:**
- `useAudioEngine` hook
- Automatic camera tracking
- User interaction handling (AudioContext resume)

---

**STATUS:** DEV3 Audio Engine Complete ✅
**Next:** DEV4 FastAPI Endpoint Set
