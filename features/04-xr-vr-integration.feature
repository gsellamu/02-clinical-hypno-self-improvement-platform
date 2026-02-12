Feature: XR/VR Integration - Immersive Journaling Experiences
  As a user with VR hardware
  I want immersive journaling environments
  So that I can achieve deeper presence and focus

  Background:
    Given the user has a Quest 3 headset
    And the WebXR API is supported
    And the XR Scene Director Agent is active

  @xr @environment
  Scenario: User selects "cozy cabin" environment for journaling
    Given the user is in session setup
    When the user selects XR mode with "cozy cabin" environment
    Then the XR Scene Director should generate spec:
      | parameter          | value                          |
      | environment_id     | cozy_cabin_v2                  |
      | lighting_mode      | warm_fireplace_ambient         |
      | audio_landscape    | crackling_fire_forest_distant  |
      | camera_position    | seated_desk_view               |
      | interaction_hotspots| [journal_desk, window_view, fireplace] |
    And the R3F scene should load with progressive textures
    And the environment should be cached for instant reload

  @xr @spatial-audio
  Scenario: Spatial audio enhances immersion
    Given the user is in VR journaling session
    And the environment is "forest_clearing"
    When the Content Producer generates narration
    Then the audio should be positioned in 3D space:
      | audio_element      | spatial_position        |
      | narrator_voice     | (0, 1.8, -2)  # front   |
      | ambient_birds      | (5, 3, 2)   # upper right|
      | stream_water       | (-3, 0, 3)  # left rear  |
    And the HRTF rendering should be enabled
    And the user can adjust audio sources via gaze interaction

  @xr @bilateral-drawing
  Scenario: Bilateral drawing in VR for regulation
    Given the user selects "bilateral drawing" exercise
    And the user is in VR mode
    When the exercise begins
    Then the XR Scene Director should create:
      | element               | spec                                  |
      | canvas_1              | positioned at (-0.3, 1.2, -1.0)       |
      | canvas_2              | positioned at (0.3, 1.2, -1.0)        |
      | controller_left       | draws on canvas_1 (mirrored)          |
      | controller_right      | draws on canvas_2 (mirrored)          |
      | symmetry_mode         | true                                  |
    And both hands should draw simultaneously
    And the mirroring should create symmetrical patterns
    And the drawing should be captured as artifact

  @xr @gaze-interaction
  Scenario: Gaze-based UI interaction in VR
    Given the user is wearing VR headset
    When the user gazes at a UI element for 1.5 seconds
    Then the element should highlight
    And a subtle audio cue should play
    And the selection should activate on dwell
    And hand controller input should override gaze

  @xr @cinematic-mode
  Scenario: Cinematic camera rails for guided meditation
    Given the user selects "Six-Phase Meditation" exercise
    And the user enables cinematic mode
    When the meditation begins
    Then the XR Scene Director should create camera path:
      | phase          | camera_movement                    | duration |
      | Compassion     | slow_orbit_around_user             | 3 min    |
      | Gratitude      | gentle_rise_with_environment_reveal| 3 min    |
      | Forgiveness    | close_intimate_focal_shift         | 3 min    |
      | Vision         | expansive_pull_back_to_horizon     | 3 min    |
      | Perfect_Day    | smooth_journey_through_ideal_scene | 3 min    |
      | Blessings      | return_to_center_grounded          | 3 min    |
    And the narration should sync with camera movement
    And the user should maintain passive observation role

  @xr @hand-tracking
  Scenario: Hand tracking for non-dominant hand writing in VR
    Given the user has hand tracking enabled
    And the exercise is "non-dominant hand writing"
    When the user begins writing in mid-air
    Then the hand position should be captured at 60 Hz
    And the writing strokes should be rendered with trailing effect
    And the 3D strokes should be saved as volumetric data
    And the rendering should show natural hand tremor/awkwardness

  @xr @environment-transitions
  Scenario: Smooth environment transitions during session
    Given the user is in "cozy cabin" environment
    When the Somatic Regulator suggests changing to "beach sunset"
    Then the transition should use cross-fade (5 seconds)
    And the audio should blend between soundscapes
    And the lighting should interpolate smoothly
    And the user should not experience motion sickness cues

  @xr @ui-overlay
  Scenario: Floating UI for journaling prompts in VR
    Given the user is in immersive journaling session
    When the Journaling Coach provides a prompt
    Then the UI overlay should:
      | parameter        | value                              |
      | position         | (0, 1.5, -1.2) # comfortable read  |
      | follow_mode      | lazy_follow (head rotation)        |
      | transparency     | 0.95 (semi-transparent)            |
      | font_size        | adaptive to distance               |
      | dismiss_method   | gaze_away for 3 seconds            |
    And the overlay should not obstruct environment
    And the text should be high-contrast readable

  @xr @haptic-feedback
  Scenario: Haptic feedback for grounding exercises
    Given the user is in VR grounding exercise
    When the Somatic Regulator cues "deep breath"
    Then the controller should vibrate in sync:
      | breath_phase | vibration_pattern          |
      | inhale       | gradual_increase (4s)      |
      | hold         | steady_pulse (4s)          |
      | exhale       | gradual_decrease (6s)      |
    And the vibration intensity should be user-adjustable
    And the pattern should match visual breathing sphere

  @xr @desktop-fallback
  Scenario: Desktop 3D mode when VR unavailable
    Given the user does not have VR headset
    When the user selects XR experience
    Then the platform should offer Desktop 3D mode with R3F
    And the camera should be mouse-controlled orbit
    And the environment should render at 1080p minimum
    And all interactions should use mouse/keyboard
    And spatial audio should be binaural stereo

  @xr @performance
  Scenario: VR session maintains 72fps minimum
    Given the user is in VR journaling session
    When complex scene with particles and audio is active
    Then the frame rate should never drop below 72fps
    And the GPU should be monitored for thermal throttling
    And the scene complexity should adapt if performance degrades
    And a performance warning should show if sustained < 72fps

  @xr @session-recording
  Scenario: User records VR session for later review
    Given the user enables session recording
    When the VR journaling session is active
    Then the recording should capture:
      | element            | format       |
      | environment_view   | 360° video   |
      | user_journaling    | encrypted    |
      | narration_audio    | separate track|
      | gaze_heatmap       | overlay      |
    And the recording should be stored in MinIO
    And the user can review in 2D or re-enter in VR

  @xr @accessibility
  Scenario: VR accessibility for seated users
    Given the user has limited mobility
    When the user enters VR mode
    Then the seated_mode should be automatically detected
    And all UI elements should be within reach zone
    And the standing interactions should be disabled
    And the environment should adjust to seated perspective

  @xr @exit-safety
  Scenario: Safe VR exit with grounding
    Given the user has been in VR for 30+ minutes
    When the user initiates exit
    Then the Somatic Regulator should offer transition grounding
    And the environment should gradually brighten
    And a "remove headset slowly" reminder should display
    And the session summary should be available in 2D

  @xr @chaperone
  Scenario: VR boundary awareness during emotional exercises
    Given the user is in intense emotional exercise
    When the user approaches VR boundary
    Then the chaperone grid should fade in gently
    And the narration should pause automatically
    And a grounding reminder should be offered
    And the user can re-center the play space
