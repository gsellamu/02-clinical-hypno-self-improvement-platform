# DEV3: Audio Engine (Ambient + TTS Ducking)
## WebAudio Mixer with Dynamic Ducking

**Version:** 1.0  
**Date:** 2026-02-11

---

## ARCHITECTURE

```
AudioContext
├── Ambient Loop → ambientGain → masterGain → speakers
├── SFX → sfxGain → masterGain → speakers
└── TTS → ttsGain → masterGain → speakers

TTS speaks: ambient -10dB (300ms)
TTS ends: ambient +10dB (500ms)
```

---

## AUDIO ENGINE CLASS

```typescript
// apps/web/src/audio/AudioEngine.ts

export class AudioEngine {
  private context: AudioContext
  private masterGain: GainNode
  private ambientGain: GainNode
  private sfxGain: GainNode
  private ttsGain: GainNode
  
  private ambientSource: AudioBufferSourceNode | null = null
  private isSpeaking: boolean = false
  private originalAmbientVolume: number = 0.3
  
  constructor() {
    this.context = new (window.AudioContext || (window as any).webkitAudioContext)()
    
    this.masterGain = this.context.createGain()
    this.ambientGain = this.context.createGain()
    this.sfxGain = this.context.createGain()
    this.ttsGain = this.context.createGain()
    
    this.masterGain.gain.value = 1.0
    this.ambientGain.gain.value = 0.3
    this.sfxGain.gain.value = 0.5
    this.ttsGain.gain.value = 0.8
    
    this.ambientGain.connect(this.masterGain)
    this.sfxGain.connect(this.masterGain)
    this.ttsGain.connect(this.masterGain)
    this.masterGain.connect(this.context.destination)
  }
  
  async resume() {
    if (this.context.state === 'suspended') {
      await this.context.resume()
    }
  }
  
  async playAmbient(url: string, volume: number = 0.3, fadeIn: number = 3000) {
    await this.resume()
    
    const response = await fetch(url)
    const arrayBuffer = await response.arrayBuffer()
    const buffer = await this.context.decodeAudioData(arrayBuffer)
    
    this.ambientSource = this.context.createBufferSource()
    this.ambientSource.buffer = buffer
    this.ambientSource.loop = true
    this.ambientSource.connect(this.ambientGain)
    
    this.ambientGain.gain.setValueAtTime(0, this.context.currentTime)
    this.ambientGain.gain.linearRampToValueAtTime(
      volume,
      this.context.currentTime + fadeIn / 1000
    )
    
    this.originalAmbientVolume = volume
    this.ambientSource.start(0)
  }
  
  async playSFX(url: string, volume: number = 1.0) {
    await this.resume()
    
    const response = await fetch(url)
    const arrayBuffer = await response.arrayBuffer()
    const buffer = await this.context.decodeAudioData(arrayBuffer)
    
    const source = this.context.createBufferSource()
    source.buffer = buffer
    
    const gain = this.context.createGain()
    gain.gain.value = volume
    
    source.connect(gain)
    gain.connect(this.sfxGain)
    source.start(0)
    
    source.onended = () => {
      source.disconnect()
      gain.disconnect()
    }
  }
  
  async playTTS(url: string, onComplete?: () => void) {
    await this.resume()
    
    this.duckAmbient()
    
    const response = await fetch(url)
    const arrayBuffer = await response.arrayBuffer()
    const buffer = await this.context.decodeAudioData(arrayBuffer)
    
    const source = this.context.createBufferSource()
    source.buffer = buffer
    source.connect(this.ttsGain)
    
    source.onended = () => {
      this.unduckAmbient()
      source.disconnect()
      if (onComplete) onComplete()
    }
    
    source.start(0)
  }
  
  private duckAmbient() {
    if (this.isSpeaking) return
    this.isSpeaking = true
    
    const currentTime = this.context.currentTime
    const duckedVolume = this.originalAmbientVolume * Math.pow(10, -10 / 20) // -10dB
    
    this.ambientGain.gain.setValueAtTime(this.ambientGain.gain.value, currentTime)
    this.ambientGain.gain.exponentialRampToValueAtTime(
      Math.max(duckedVolume, 0.001),
      currentTime + 0.3 // 300ms
    )
  }
  
  private unduckAmbient() {
    if (!this.isSpeaking) return
    this.isSpeaking = false
    
    const currentTime = this.context.currentTime
    
    this.ambientGain.gain.setValueAtTime(this.ambientGain.gain.value, currentTime)
    this.ambientGain.gain.exponentialRampToValueAtTime(
      this.originalAmbientVolume,
      currentTime + 0.5 // 500ms
    )
  }
}

let audioEngineInstance: AudioEngine | null = null

export function getAudioEngine(): AudioEngine {
  if (!audioEngineInstance) {
    audioEngineInstance = new AudioEngine()
  }
  return audioEngineInstance
}
```

---

## REACT HOOK

```typescript
// apps/web/src/hooks/useAudioEngine.ts
import { useEffect, useRef } from 'react'
import { getAudioEngine } from '../audio/AudioEngine'

export function useAudioEngine() {
  const engineRef = useRef(getAudioEngine())
  
  return {
    playAmbient: (url: string, volume?: number) => 
      engineRef.current.playAmbient(url, volume),
    playSFX: (url: string, volume?: number) => 
      engineRef.current.playSFX(url, volume),
    playTTS: (url: string, onComplete?: () => void) => 
      engineRef.current.playTTS(url, onComplete)
  }
}
```

---

**STATUS:** DEV3 Complete ✅
