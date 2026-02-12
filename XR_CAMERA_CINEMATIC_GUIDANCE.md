# XR Camera Rail + Cinematic Guidance
## 10-Minute Guided Journaling Session with Cinematic Camera System

**Version:** 1.0
**Date:** 2026-02-11
**Target Platform:** Quest 3, WebXR
**Camera System:** Bezier curve rails with smooth interpolation

---

## CINEMATIC MODE OVERVIEW

**Purpose:** Guide user through 10-minute journaling session with smooth camera movements, timed prompts, and synchronized TTS narration

**Session Structure:** 5 scenes (Intro → Settle → Exercise → Reflection → Close)

**Technical Stack:**
- Camera animation: Bezier curves with ease-in/ease-out
- On-screen prompts: Fade-in text overlays
- TTS: ElevenLabs API, chunked ≤12s each
- Synchronization: Timeline-based event system

---

## FULL SESSION SPECIFICATION (JSON)

```json
{
  "session_id": "cinematic_journaling_sprint_v1",
  "total_duration_seconds": 600,
  "technique": "sprint_journaling",
  "theme": "forest_clearing",
  "camera_rail_system": {
    "type": "bezier_curve",
    "interpolation": "catmull_rom",
    "default_easing": "ease_in_out_cubic",
    "comfort_constraints": {
      "max_velocity": 0.5,
      "max_acceleration": 0.2,
      "vignette_on_movement": true,
      "maintain_horizon_level": true
    }
  },
  "scenes": [
    {
      "scene_id": "intro",
      "name": "Welcome & Grounding",
      "start_time": 0,
      "end_time": 90,
      "duration_seconds": 90,
      "camera": {
        "keyframes": [
          {
            "time": 0,
            "position": [0, 1.6, 3],
            "look_at": [0, 1.5, -2],
            "fov": 75,
            "transition": "cut"
          },
          {
            "time": 10,
            "position": [0, 1.6, 2],
            "look_at": [0, 1.5, -2],
            "fov": 70,
            "transition": "ease_in_out",
            "duration": 10
          },
          {
            "time": 60,
            "position": [0.5, 1.6, 1.5],
            "look_at": [0, 1.5, -2],
            "fov": 65,
            "transition": "ease_in_out",
            "duration": 30
          }
        ],
        "rail_path": {
          "type": "arc",
          "start": [0, 1.6, 3],
          "end": [0.5, 1.6, 1.5],
          "control_points": [
            [0, 1.65, 2.5],
            [0.2, 1.62, 2]
          ],
          "samples": 100
        }
      },
      "prompts": [
        {
          "time": 0,
          "type": "text_overlay",
          "content": "Welcome to Your Journaling Practice",
          "position": "center",
          "font_size": 0.12,
          "color": "#ffffff",
          "background": "rgba(0,0,0,0.6)",
          "fade_in": 1,
          "duration": 5,
          "fade_out": 1
        },
        {
          "time": 10,
          "type": "text_overlay",
          "content": "Find a comfortable seated position",
          "position": "center",
          "font_size": 0.08,
          "duration": 5,
          "fade_in": 1,
          "fade_out": 1
        },
        {
          "time": 25,
          "type": "breathing_cue",
          "content": "Take 3 deep breaths with me",
          "visual": "pulsing_circle",
          "position": "center",
          "duration": 20,
          "breath_cycles": 3,
          "inhale_duration": 4,
          "hold_duration": 2,
          "exhale_duration": 6
        },
        {
          "time": 60,
          "type": "text_overlay",
          "content": "Today you'll practice Sprint Journaling",
          "position": "center",
          "duration": 8,
          "fade_in": 1,
          "fade_out": 1
        }
      },
      "tts_narration": {
        "chunks": [
          {
            "chunk_id": 1,
            "time": 0,
            "text": "Welcome. You've arrived. Take a moment to settle into this space.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "calm",
            "audio_url": "https://cdn.jeeth.ai/tts/intro_chunk_1.mp3"
          },
          {
            "chunk_id": 2,
            "time": 10,
            "text": "Find a comfortable seated position. Let your body relax.",
            "duration": 5,
            "voice_id": "sophia",
            "emotion": "warm",
            "audio_url": "https://cdn.jeeth.ai/tts/intro_chunk_2.mp3"
          },
          {
            "chunk_id": 3,
            "time": 18,
            "text": "We'll begin with three grounding breaths.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "calm"
          },
          {
            "chunk_id": 4,
            "time": 25,
            "text": "Breathe in deeply through your nose.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "calm",
            "sync_with": "breath_cue_inhale"
          },
          {
            "chunk_id": 5,
            "time": 31,
            "text": "Hold for a moment.",
            "duration": 2,
            "voice_id": "sophia",
            "emotion": "calm",
            "sync_with": "breath_cue_hold"
          },
          {
            "chunk_id": 6,
            "time": 33,
            "text": "And release slowly through your mouth.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "calm",
            "sync_with": "breath_cue_exhale"
          },
          {
            "chunk_id": 7,
            "time": 60,
            "text": "Today you'll practice Sprint Journaling. Seven minutes of free writing with no editing or judgment.",
            "duration": 9,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 8,
            "time": 75,
            "text": "This is a space for your truth to flow onto the page.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "compassionate"
          }
        ]
      },
      "audio_layers": {
        "ambient": {
          "track": "forest_ambient_loop.mp3",
          "volume": 0.25,
          "fade_in": 3
        },
        "breath_cue": {
          "track": "breath_bell_soft.mp3",
          "trigger_times": [25, 40, 55],
          "volume": 0.5
        }
      }
    },
    {
      "scene_id": "settle",
      "name": "Set Intention & Prepare",
      "start_time": 90,
      "end_time": 150,
      "duration_seconds": 60,
      "camera": {
        "keyframes": [
          {
            "time": 90,
            "position": [0.5, 1.6, 1.5],
            "look_at": [0, 1.5, -2],
            "fov": 65
          },
          {
            "time": 120,
            "position": [0, 1.6, 1],
            "look_at": [0, 1.4, -2],
            "fov": 60,
            "transition": "ease_in_out",
            "duration": 30
          }
        ],
        "rail_path": {
          "type": "linear",
          "start": [0.5, 1.6, 1.5],
          "end": [0, 1.6, 1],
          "samples": 50
        }
      },
      "prompts": [
        {
          "time": 90,
          "type": "text_overlay",
          "content": "What do you want to explore today?",
          "position": "upper_center",
          "font_size": 0.07,
          "duration": 10,
          "fade_in": 1,
          "fade_out": 1
        },
        {
          "time": 110,
          "type": "interactive_input",
          "content": "Take a moment to think about your intention...",
          "position": "center",
          "duration": 30,
          "input_field": {
            "enabled": true,
            "placeholder": "My intention is...",
            "max_length": 200,
            "voice_input_enabled": true
          }
        }
      ],
      "tts_narration": {
        "chunks": [
          {
            "chunk_id": 9,
            "time": 90,
            "text": "Before we begin, set an intention. What do you want to explore in your writing today?",
            "duration": 8,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 10,
            "time": 105,
            "text": "There's no right answer. Just notice what's present for you.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "permissive"
          },
          {
            "chunk_id": 11,
            "time": 130,
            "text": "In a moment, your journaling canvas will appear. Remember, keep your pen moving for seven minutes.",
            "duration": 9,
            "voice_id": "sophia",
            "emotion": "encouraging"
          }
        ]
      },
      "ui_transitions": {
        "journal_canvas": {
          "action": "fade_in",
          "time": 140,
          "duration": 3,
          "target_position": [0, 1.4, -2],
          "target_opacity": 0.95
        }
      }
    },
    {
      "scene_id": "exercise",
      "name": "Sprint Journaling (7 minutes)",
      "start_time": 150,
      "end_time": 570,
      "duration_seconds": 420,
      "camera": {
        "keyframes": [
          {
            "time": 150,
            "position": [0, 1.6, 1],
            "look_at": [0, 1.4, -2],
            "fov": 60
          },
          {
            "time": 570,
            "position": [0, 1.6, 1],
            "look_at": [0, 1.4, -2],
            "fov": 60,
            "transition": "static"
          }
        ],
        "rail_path": null,
        "static_shot": true,
        "micro_movements": {
          "enabled": true,
          "breathing_sway": {
            "amplitude": 0.005,
            "frequency": 0.15
              },
          "subtle_drift": {
            "amplitude": 0.01,
            "frequency": 0.05
          }
        }
      },
      "prompts": [
        {
          "time": 150,
          "type": "timer_start",
          "content": "7:00",
          "position": "upper_right",
          "font_size": 0.06,
          "color": "#34495e",
          "countdown": true,
          "warning_at": 60
        },
        {
          "time": 270,
          "type": "guidepost",
          "content": "You're doing great. Keep going.",
          "position": "lower_center",
          "duration": 3,
          "fade_in": 0.5,
          "fade_out": 0.5,
          "voice_sync": true
        },
        {
          "time": 390,
          "type": "guidepost",
          "content": "Halfway there. What else wants to be said?",
          "position": "lower_center",
          "duration": 4,
          "fade_in": 0.5,
          "fade_out": 0.5,
          "voice_sync": true
        },
        {
          "time": 510,
          "type": "guidepost",
          "content": "One more minute. Bring it to a close.",
          "position": "lower_center",
          "duration": 5,
          "fade_in": 0.5,
          "fade_out": 0.5,
          "voice_sync": true
        }
      ],
      "tts_narration": {
        "chunks": [
          {
            "chunk_id": 12,
            "time": 150,
            "text": "Begin writing now. Let your thoughts flow freely for seven minutes.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "calm"
          },
          {
            "chunk_id": 13,
            "time": 270,
            "text": "You're doing great. Keep your pen moving.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "encouraging"
          },
          {
            "chunk_id": 14,
            "time": 390,
            "text": "Halfway there. What else wants to be said? Stay with it.",
            "duration": 7,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 15,
            "time": 510,
            "text": "One more minute. Begin moving toward a natural close.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "gentle"
          },
          {
            "chunk_id": 16,
            "time": 555,
            "text": "Fifteen seconds. Complete your final thought.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "calm"
          }
        ]
      },
      "audio_layers": {
        "ambient": {
          "track": "forest_ambient_loop.mp3",
          "volume": 0.2,
          "continue": true
        },
        "writing_ambience": {
          "track": "soft_rain_subtle.mp3",
          "volume": 0.15,
          "fade_in": 5,
          "loop": true
        }
      },
      "auto_save": {
        "enabled": true,
        "interval_seconds": 30,
        "visual_indicator": true
      }
    },
    {
      "scene_id": "reflection",
      "name": "Pause & Reflect",
      "start_time": 570,
      "end_time": 750,
      "duration_seconds": 180,
      "camera": {
        "keyframes": [
          {
            "time": 570,
            "position": [0, 1.6, 1],
            "look_at": [0, 1.4, -2],
            "fov": 60
          },
          {
            "time": 580,
            "position": [-0.3, 1.65, 1.2],
            "look_at": [0, 1.5, -2],
            "fov": 65,
            "transition": "ease_out",
            "duration": 10
          },
          {
            "time": 630,
            "position": [0.3, 1.65, 1.2],
            "look_at": [0, 1.5, -2],
            "fov": 65,
            "transition": "ease_in_out",
            "duration": 50
          }
        ],
        "rail_path": {
          "type": "gentle_sway",
          "center": [0, 1.65, 1.2],
          "amplitude": 0.3,
          "frequency": 0.02
        }
      },
      "prompts": [
        {
          "time": 575,
          "type": "text_overlay",
          "content": "Well done. Take a breath.",
          "position": "center",
          "font_size": 0.1,
          "duration": 5,
          "fade_in": 1,
          "fade_out": 1
        },
        {
          "time": 600,
          "type": "reflection_questions",
          "content": [
            "What surprised you about what you wrote?",
            "What emotion is most present right now?",
            "If this writing had one message for you, what would it be?"
          ],
          "position": "center",
          "display_mode": "sequential",
          "time_per_question": 40,
          "allow_written_response": true,
          "allow_voice_response": true
        }
      ],
      "tts_narration": {
        "chunks": [
          {
            "chunk_id": 17,
            "time": 570,
            "text": "And... pause. Your seven minutes are complete. Well done.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 18,
            "time": 585,
            "text": "Take a breath. Notice how you feel.",
            "duration": 5,
            "voice_id": "sophia",
            "emotion": "calm"
          },
          {
            "chunk_id": 19,
            "time": 600,
            "text": "Let's reflect together. What surprised you about what you wrote?",
            "duration": 7,
            "voice_id": "sophia",
            "emotion": "curious"
          },
          {
            "chunk_id": 20,
            "time": 640,
            "text": "What emotion is most present for you right now?",
            "duration": 5,
            "voice_id": "sophia",
            "emotion": "gentle"
          },
          {
            "chunk_id": 21,
            "time": 680,
            "text": "If this writing had one message for you, what would it be?",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 22,
            "time": 720,
            "text": "Thank you for this honest reflection.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "grateful"
          }
        ]
      },
      "ui_transitions": {
        "reflection_panel": {
          "action": "fade_in",
          "time": 600,
          "duration": 2,
          "position": [-1.5, 1.5, -2],
          "opacity": 0.9
        }
      }
    },
    {
      "scene_id": "close",
      "name": "Grounding Close & Completion",
      "start_time": 750,
      "end_time": 900,
      "duration_seconds": 150,
      "camera": {
        "keyframes": [
          {
            "time": 750,
            "position": [0.3, 1.65, 1.2],
            "look_at": [0, 1.5, -2],
            "fov": 65
          },
          {
            "time": 780,
            "position": [0, 1.6, 1.5],
            "look_at": [0, 1.5, 0],
            "fov": 70,
            "transition": "ease_in_out",
            "duration": 30
          },
          {
            "time": 870,
            "position": [0, 1.6, 3],
            "look_at": [0, 1.5, 0],
            "fov": 75,
            "transition": "ease_in",
            "duration": 60
          }
        ],
        "rail_path": {
          "type": "pullback",
          "start": [0.3, 1.65, 1.2],
          "end": [0, 1.6, 3],
          "control_points": [
            [0.15, 1.63, 1.35],
            [0, 1.6, 2]
          ]
        }
      },
      "prompts": [
        {
          "time": 750,
          "type": "breathing_cue",
          "content": "Three grounding breaths",
          "visual": "pulsing_circle",
          "position": "center",
          "duration": 30,
          "breath_cycles": 3,
          "inhale_duration": 4,
          "exhale_duration": 6
        },
        {
          "time": 810,
          "type": "text_overlay",
          "content": "Your entry is saved safely",
          "position": "center",
          "font_size": 0.08,
          "duration": 5,
          "fade_in": 1,
          "fade_out": 1
        },
        {
          "time": 840,
          "type": "text_overlay",
          "content": "You can return to it anytime",
          "position": "center",
          "font_size": 0.07,
          "duration": 5,
          "fade_in": 1,
          "fade_out": 1
        },
        {
          "time": 870,
          "type": "completion_message",
          "content": "Session Complete",
          "position": "center",
          "font_size": 0.12,
          "color": "#27ae60",
          "duration": 10,
          "fade_in": 2,
          "fade_out": 2,
          "particles": "gentle_sparkles"
        }
      ],
      "tts_narration": {
        "chunks": [
          {
            "chunk_id": 23,
            "time": 750,
            "text": "Let's close with three grounding breaths.",
            "duration": 5,
            "voice_id": "sophia",
            "emotion": "calm"
          },
          {
            "chunk_id": 24,
            "time": 758,
            "text": "Breathe in deeply.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "calm",
            "sync_with": "breath_cue_inhale"
          },
          {
            "chunk_id": 25,
            "time": 764,
            "text": "And release.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "calm",
            "sync_with": "breath_cue_exhale"
          },
          {
            "chunk_id": 26,
            "time": 810,
            "text": "You showed up for yourself today. That takes courage.",
            "duration": 7,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 27,
            "time": 825,
            "text": "Your writing is saved safely and held with care.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "reassuring"
          },
          {
            "chunk_id": 28,
            "time": 840,
            "text": "You can return to this space anytime you need.",
            "duration": 6,
            "voice_id": "sophia",
            "emotion": "warm"
          },
          {
            "chunk_id": 29,
            "time": 855,
            "text": "Thank you for this practice.",
            "duration": 4,
            "voice_id": "sophia",
            "emotion": "grateful"
          },
          {
            "chunk_id": 30,
            "time": 870,
            "text": "Session complete. Gentle return.",
            "duration": 5,
            "voice_id": "sophia",
            "emotion": "closing"
          }
        ]
      },
      "audio_layers": {
        "transition_chime": {
          "track": "tibetan_bowl_medium.mp3",
          "trigger_time": 870,
          "volume": 0.6
        },
        "ambient": {
          "fade_out": 10,
          "start_fade_at": 890
        }
      },
      "ui_transitions": {
        "journal_canvas": {
          "action": "fade_out",
          "time": 820,
          "duration": 5
        },
        "save_confirmation": {
          "action": "fade_in",
          "time": 810,
          "duration": 2,
          "icon": "checkmark_green",
          "position": "center"
        }
      }
    }
  ],
  "timeline_events": {
    "auto_save_triggers": [180, 210, 240, 270, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570],
    "safety_checks": [0, 300, 570],
    "analytics_pings": [90, 270, 450, 750, 900]
  }
}
```

---

## TTS CHUNK GENERATION SCRIPT

```python
# generate_tts_chunks.py
from elevenlabs import generate, Voice
import os

TTS_CHUNKS = [
    {"chunk_id": 1, "text": "Welcome. You've arrived. Take a moment to settle into this space.", "voice": "sophia", "emotion": "calm"},
    {"chunk_id": 2, "text": "Find a comfortable seated position. Let your body relax.", "voice": "sophia", "emotion": "warm"},
    # ... (all 30 chunks)
]

def generate_tts_audio():
    for chunk in TTS_CHUNKS:
        audio = generate(
            text=chunk["text"],
            voice=Voice(voice_id="sophia_calm_voice_id"),
            model="eleven_multilingual_v2"
        )
        
        filename = f"tts/intro_chunk_{chunk['chunk_id']}.mp3"
        with open(filename, "wb") as f:
            f.write(audio)
        
        print(f"Generated: {filename} ({len(chunk['text'])} chars)")

if __name__ == "__main__":
    generate_tts_audio()
```

---

## CAMERA IMPLEMENTATION (React Three Fiber)

```typescript
// CinematicCamera.tsx
import { useFrame, useThree } from '@react-three/fiber'
import { Vector3, CatmullRomCurve3 } from 'three'
import { useEffect, useRef } from 'react'

interface CameraKeyframe {
  time: number
  position: [number, number, number]
  lookAt: [number, number, number]
  fov: number
  transition: string
  duration?: number
}

interface CinematicCameraProps {
  keyframes: CameraKeyframe[]
  currentTime: number
}

export const CinematicCamera: React.FC<CinematicCameraProps> = ({ keyframes, currentTime }) => {
  const { camera } = useThree()
  const curveRef = useRef<CatmullRomCurve3 | null>(null)
  
  useEffect(() => {
    // Build Catmull-Rom curve from keyframes
    const points = keyframes.map(kf => new Vector3(...kf.position))
    curveRef.current = new CatmullRomCurve3(points)
  }, [keyframes])
  
  useFrame(() => {
    if (!curveRef.current) return
    
    // Find current keyframe
    const currentKeyframe = keyframes.find((kf, i) => {
      const nextKf = keyframes[i + 1]
      return currentTime >= kf.time && (!nextKf || currentTime < nextKf.time)
    })
    
    if (!currentKeyframe) return
    
    // Interpolate position along curve
    const t = (currentTime - currentKeyframe.time) / (currentKeyframe.duration || 1)
    const easedT = easeInOutCubic(Math.min(t, 1))
    
    const position = curveRef.current.getPoint(easedT)
    camera.position.copy(position)
    
    // Interpolate lookAt
    const lookAt = new Vector3(...currentKeyframe.lookAt)
    camera.lookAt(lookAt)
    
    // Interpolate FOV
    camera.fov = currentKeyframe.fov
    camera.updateProjectionMatrix()
  })
  
  return null
}

function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2
}
```

---

## PROMPT OVERLAY SYSTEM

```typescript
// PromptOverlay.tsx
import { Html } from '@react-three/drei'
import { useEffect, useState } from 'react'

interface Prompt {
  time: number
  type: string
  content: string
  position: string
  duration: number
  fade_in: number
  fade_out: number
}

interface PromptOverlayProps {
  prompts: Prompt[]
  currentTime: number
}

export const PromptOverlay: React.FC<PromptOverlayProps> = ({ prompts, currentTime }) => {
  const [activePrompt, setActivePrompt] = useState<Prompt | null>(null)
  const [opacity, setOpacity] = useState(0)
  
  useEffect(() => {
    const prompt = prompts.find(p => 
      currentTime >= p.time && 
      currentTime < p.time + p.duration + p.fade_in + p.fade_out
    )
    
    if (prompt) {
      setActivePrompt(prompt)
      
      // Calculate opacity based on fade in/out
      const elapsed = currentTime - prompt.time
      if (elapsed < prompt.fade_in) {
        setOpacity(elapsed / prompt.fade_in)
      } else if (elapsed > prompt.duration + prompt.fade_in) {
        const fadeOutElapsed = elapsed - (prompt.duration + prompt.fade_in)
        setOpacity(1 - (fadeOutElapsed / prompt.fade_out))
      } else {
        setOpacity(1)
      }
    } else {
      setActivePrompt(null)
      setOpacity(0)
    }
  }, [currentTime, prompts])
  
  if (!activePrompt) return null
  
  return (
    <Html
      center
      position={getPosition(activePrompt.position)}
      style={{
        opacity,
        transition: 'opacity 0.5s',
        fontSize: '2rem',
        color: 'white',
        textAlign: 'center',
        textShadow: '0 2px 10px rgba(0,0,0,0.8)',
        maxWidth: '800px',
        padding: '20px',
        background: 'rgba(0,0,0,0.6)',
        borderRadius: '10px'
      }}
    >
      {activePrompt.content}
    </Html>
  )
}

function getPosition(position: string): [number, number, number] {
  switch (position) {
    case 'center': return [0, 0, 0]
    case 'upper_center': return [0, 0.5, 0]
    case 'lower_center': return [0, -0.5, 0]
    default: return [0, 0, 0]
  }
}
```

---

**STATUS:** XR2 Camera Rail + Cinematic Guidance Complete ✅
**Next:** XR3 Bilateral Drawing Interaction Design
