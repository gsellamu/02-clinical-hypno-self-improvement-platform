# XR Scene Specifications - Therapeutic Journaling Rooms
## React Three Fiber / WebXR Scene Configurations

**Version:** 1.0
**Date:** 2026-02-11
**Target Platform:** Quest 3, WebXR-compatible browsers
**Rendering:** React Three Fiber (R3F), Three.js r128

---

## THEME 1: FOREST CLEARING

```json
{
  "scene_id": "forest_clearing_v1",
  "theme": "forest",
  "description": "Sunlit forest clearing with gentle stream, birdsong, and soft natural lighting",
  "comfort_settings": {
    "motion_intensity": "low",
    "seated_friendly": true,
    "vignette_on_movement": true,
    "teleport_enabled": true,
    "continuous_movement": false
  },
  "environment": {
    "skybox": {
      "type": "hdri",
      "asset_url": "https://cdn.jeeth.ai/environments/forest_clearing_4k.hdr",
      "intensity": 0.8,
      "rotation": [0, 45, 0],
      "blur": 0.05
    },
    "fog": {
      "enabled": true,
      "color": "#a8d5ba",
      "near": 5,
      "far": 25,
      "density": 0.02
    },
    "lighting": {
      "ambient": {
        "color": "#ffffff",
        "intensity": 0.6
      },
      "directional": {
        "color": "#fffae6",
        "intensity": 1.2,
        "position": [5, 10, 7],
        "castShadow": true,
        "shadow_map_size": 2048
      },
      "hemisphere": {
        "skyColor": "#87ceeb",
        "groundColor": "#5d7a3e",
        "intensity": 0.5
      }
    },
    "ground": {
      "type": "grass",
      "radius": 15,
      "texture": "https://cdn.jeeth.ai/textures/grass_forest_1k.jpg",
      "normal_map": "https://cdn.jeeth.ai/textures/grass_normal_1k.jpg",
      "color": "#6b8e4a",
      "roughness": 0.9
    },
    "water": {
      "enabled": true,
      "type": "stream",
      "geometry": {
        "width": 2,
        "length": 20,
        "position": [-8, 0, 0],
        "rotation": [0, 15, 0]
      },
      "material": {
        "color": "#5ab9d4",
        "opacity": 0.7,
        "roughness": 0.1,
        "metalness": 0.2,
        "transparent": true
      },
      "animation": {
        "flow_speed": 0.3,
        "ripple_frequency": 2.0,
        "ripple_amplitude": 0.05
      }
    },
    "particles": {
      "enabled": true,
      "type": "fireflies",
      "count": 50,
      "spawn_volume": {
        "type": "sphere",
        "radius": 10,
        "center": [0, 1.5, 0]
      },
      "particle_size": 0.05,
      "color": "#ffeb99",
      "glow_intensity": 1.5,
      "movement": {
        "speed": 0.2,
        "randomness": 0.8,
        "vertical_bias": 0.1
      }
    },
    "vegetation": {
      "trees": {
        "count": 12,
        "models": [
          "https://cdn.jeeth.ai/models/oak_tree_low.glb",
          "https://cdn.jeeth.ai/models/birch_tree_low.glb"
        ],
        "positions": "procedural_ring",
        "ring_radius": 12,
        "scale_variation": [0.8, 1.2],
        "rotation_randomize": true
      },
      "bushes": {
        "count": 8,
        "model": "https://cdn.jeeth.ai/models/fern_cluster.glb",
        "positions": "scattered",
        "scatter_radius": 10
      }
    }
  },
  "audio_layers": {
    "ambient": {
      "track_url": "https://cdn.jeeth.ai/audio/forest_ambient_loop.mp3",
      "volume": 0.3,
      "loop": true,
      "spatial": false,
      "fade_in_duration": 3,
      "fade_out_duration": 2,
      "description": "Birds chirping, gentle wind, distant stream"
    },
    "stream_water": {
      "track_url": "https://cdn.jeeth.ai/audio/stream_water_loop.mp3",
      "volume": 0.2,
      "loop": true,
      "spatial": true,
      "position": [-8, 0, 0],
      "ref_distance": 3,
      "max_distance": 15
    },
    "breath_cue": {
      "track_url": "https://cdn.jeeth.ai/audio/breath_bell_soft.mp3",
      "volume": 0.5,
      "loop": false,
      "spatial": false,
      "trigger": "manual",
      "description": "Soft bell chime for breathing prompts"
    },
    "transition_chime": {
      "track_url": "https://cdn.jeeth.ai/audio/tibetan_bowl_medium.mp3",
      "volume": 0.6,
      "loop": false,
      "spatial": false,
      "trigger": "manual",
      "description": "Tibetan singing bowl for phase transitions"
    }
  },
  "interaction_hotspots": {
    "start_session": {
      "type": "button_3d",
      "position": [0, 1.2, -2],
      "scale": [0.6, 0.3, 0.1],
      "label": "Begin Journaling",
      "color_idle": "#4a7c59",
      "color_hover": "#6b9e7a",
      "color_active": "#8bc09f",
      "glow_on_hover": true,
      "glow_color": "#b8e6c9",
      "glow_intensity": 1.2,
      "haptic_feedback": {
        "on_hover": "light_tap",
        "on_click": "medium_pulse"
      },
      "action": {
        "event": "journaling.session.start",
        "payload": { "location": "forest_clearing" }
      }
    },
    "choose_technique": {
      "type": "panel_carousel",
      "position": [0, 1.5, -2.5],
      "scale": [1.5, 1, 0.01],
      "techniques": [
        { "id": "sprint", "label": "Sprint Writing", "icon": "⚡" },
        { "id": "unsent_letter", "label": "Unsent Letter", "icon": "✉️" },
        { "id": "sentence_stems", "label": "Sentence Stems", "icon": "📝" },
        { "id": "bilateral_drawing", "label": "Bilateral Drawing", "icon": "🎨" }
      ],
      "carousel_mode": "horizontal_scroll",
      "color_idle": "#ffffff",
      "color_hover": "#e6f7ff",
      "haptic_feedback": {
        "on_scroll": "light_tick",
        "on_select": "medium_pulse"
      },
      "action": {
        "event": "journaling.technique.selected",
        "payload_dynamic": true
      }
    },
    "journal_canvas": {
      "type": "floating_panel",
      "position": [0, 1.4, -2],
      "scale": [1.2, 1.6, 0.01],
      "material": {
        "color": "#fefdf5",
        "opacity": 0.95,
        "emissive": "#fffef0",
        "emissive_intensity": 0.2
      },
      "text_area": {
        "font_family": "Inter, sans-serif",
        "font_size": 0.05,
        "line_height": 1.5,
        "color": "#2c3e50",
        "max_chars": 5000,
        "auto_scroll": true
      },
      "keyboard": {
        "type": "virtual_qwerty",
        "position": [0, 0.6, -1.8],
        "scale": [1.4, 0.5, 0.01],
        "layout": "standard",
        "haptic_feedback": "light_tap"
      },
      "voice_input": {
        "enabled": true,
        "icon_position": [0.5, -0.7, 0],
        "whisper_api": true,
        "real_time_transcription": true
      }
    },
    "draw_bilateral": {
      "type": "dual_canvas",
      "left_canvas": {
        "position": [-0.8, 1.4, -2],
        "scale": [0.6, 0.8, 0.01],
        "color": "#ffffff",
        "border_color": "#4a7c59",
        "brush_color": "#3498db"
      },
      "right_canvas": {
        "position": [0.8, 1.4, -2],
        "scale": [0.6, 0.8, 0.01],
        "color": "#ffffff",
        "border_color": "#4a7c59",
        "brush_color": "#e67e22"
      },
      "symmetry_options": ["mirrored", "independent", "merged"],
      "brush_size": 0.01,
      "smoothing": 0.7
    },
    "save_entry": {
      "type": "button_3d",
      "position": [0, 0.8, -2],
      "scale": [0.5, 0.25, 0.1],
      "label": "Save & Continue",
      "color_idle": "#27ae60",
      "color_hover": "#2ecc71",
      "color_active": "#52d98e",
      "glow_on_hover": true,
      "haptic_feedback": {
        "on_click": "strong_pulse"
      },
      "action": {
        "event": "journaling.entry.save",
        "confirm_modal": true
      }
    },
    "exit": {
      "type": "button_3d",
      "position": [1.5, 1.2, -2],
      "scale": [0.4, 0.2, 0.1],
      "label": "Exit",
      "color_idle": "#95a5a6",
      "color_hover": "#bdc3c7",
      "color_active": "#d5dbdc",
      "icon": "🚪",
      "haptic_feedback": {
        "on_click": "medium_pulse"
      },
      "action": {
        "event": "journaling.session.exit",
        "confirm_modal": true,
        "confirm_text": "Exit and save progress?"
      }
    }
  },
  "ui_panels": {
    "typography": {
      "font_family": "Inter, system-ui, sans-serif",
      "heading_size": 0.08,
      "body_size": 0.05,
      "line_height": 1.6,
      "letter_spacing": 0.02,
      "color": "#2c3e50",
      "color_secondary": "#7f8c8d"
    },
    "panel_defaults": {
      "material": {
        "color": "#ffffff",
        "opacity": 0.95,
        "roughness": 0.3,
        "metalness": 0.1
      },
      "distance": {
        "min": 1.5,
        "max": 2.5,
        "default": 2.0
      },
      "dimming": {
        "enabled": true,
        "dim_level": 0.5,
        "auto_dim_after_seconds": 30
      },
      "always_face_camera": true,
      "billboard_rotation": "y_axis_only"
    },
    "timer_display": {
      "position": [0, 2.2, -2],
      "scale": [0.8, 0.3, 0.01],
      "format": "MM:SS",
      "color_normal": "#34495e",
      "color_warning": "#f39c12",
      "warning_threshold_seconds": 60,
      "show_progress_bar": true
    },
    "prompts_panel": {
      "position": [-1.8, 1.5, -2],
      "scale": [0.6, 1.2, 0.01],
      "auto_scroll": true,
      "fade_in_duration": 1,
      "guideposts_appear_on_timer": true
    }
  },
  "performance": {
    "target_framerate": 72,
    "min_framerate": 60,
    "dynamic_quality": true,
    "lod_levels": 3,
    "shadow_quality": "medium",
    "texture_max_resolution": 2048,
    "anti_aliasing": "msaa_4x",
    "post_processing": {
      "bloom": {
        "enabled": true,
        "intensity": 0.3,
        "threshold": 0.9
      },
      "tone_mapping": "aces_filmic",
      "color_grading": {
        "saturation": 1.1,
        "contrast": 1.05,
        "brightness": 1.0
      }
    }
  },
  "accessibility": {
    "seated_mode": true,
    "height_adjustment": {
      "min": -0.3,
      "max": 0.3,
      "default": 0
    },
    "font_size_options": ["small", "medium", "large"],
    "high_contrast_mode": false,
    "reduce_motion": false,
    "subtitles_enabled": true
  }
}
```

---

**[Additional themes: Zen Garden, Minimalist Studio, Space Observatory, Ancient Temple - see full file]**

---

**STATUS:** XR1 Scene Specifications Complete ✅
