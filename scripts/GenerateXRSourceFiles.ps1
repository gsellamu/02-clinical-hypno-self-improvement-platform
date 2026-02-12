<#
.SYNOPSIS
    Generate all XR source files for HMI Platform
.DESCRIPTION
    Creates complete folder structure and all React/TypeScript files
#>

$PROJECT_ROOT = Get-Location
$FRONTEND_DIR = Join-Path $PROJECT_ROOT "frontend"
$SRC_DIR = Join-Path $FRONTEND_DIR "src"

Write-Host ""
Write-Host "🎨 GENERATING XR SOURCE FILES" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend
cd $FRONTEND_DIR

# ============================================================================
# CREATE FOLDER STRUCTURE
# ============================================================================

Write-Host "📁 Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    "src/features/xr",
    "src/features/xr/stores",
    "src/features/xr/components",
    "src/features/xr/environments",
    "src/features/xr/audio",
    "src/features/xr/performance",
    "src/shared/components"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path $FRONTEND_DIR $folder
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "  ✅ Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  ⏩ Exists: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# ============================================================================
# GENERATE FILES
# ============================================================================

Write-Host "📝 Generating source files..." -ForegroundColor Yellow
Write-Host ""

# ----------------------------------------------------------------------------
# 1. UPDATE APP.TSX
# ----------------------------------------------------------------------------

$appTsx = @'
import { useState } from 'react';
import { XRApp } from './features/xr/XRApp';

function App() {
  const [showXR, setShowXR] = useState(false);

  if (showXR) {
    return <XRApp />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-depth-50">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold text-gray-900 mb-4">
              🧠 HMI Hypnotherapy Platform
            </h1>
            <p className="text-xl text-gray-600">
              AI-Powered Personalized Hypnotherapy System
            </p>
          </div>

          {/* XR Launch Section */}
          <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
            <div className="text-center">
              <div className="text-6xl mb-4">🥽</div>
              <h2 className="text-3xl font-bold mb-4">
                Launch XR Experience
              </h2>
              <p className="text-gray-600 mb-6">
                Experience immersive hypnotherapy in virtual reality
              </p>
              <button
                onClick={() => setShowXR(true)}
                className="bg-primary-600 hover:bg-primary-700 text-white font-bold py-4 px-8 rounded-lg text-lg transition-colors shadow-lg"
              >
                🚀 Enter Virtual Reality
              </button>
              <p className="text-sm text-gray-500 mt-4">
                Works with Meta Quest, Vision Pro, and Desktop VR
              </p>
            </div>
          </div>

          {/* Feature Grid */}
          <div className="grid md:grid-cols-3 gap-6">
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h3 className="text-lg font-semibold mb-2">🏠 Soft Room</h3>
              <p className="text-sm text-gray-600">
                Warm, calming environment with gentle lighting
              </p>
            </div>

            <div className="bg-white rounded-lg shadow-lg p-6">
              <h3 className="text-lg font-semibold mb-2">🌲 Nature Scene</h3>
              <p className="text-sm text-gray-600">
                Forest clearing with trees and ambient sounds
              </p>
            </div>

            <div className="bg-white rounded-lg shadow-lg p-6">
              <h3 className="text-lg font-semibold mb-2">☁️ Floating Platform</h3>
              <p className="text-sm text-gray-600">
                Minimalist platform in serene sky
              </p>
            </div>
          </div>

          {/* Instructions */}
          <div className="mt-8 bg-primary-50 rounded-lg p-6">
            <h3 className="font-bold mb-3">📋 Instructions:</h3>
            <ol className="text-sm text-gray-700 space-y-2">
              <li>1. Put on your VR headset</li>
              <li>2. Click "Enter Virtual Reality" button</li>
              <li>3. Click "Enter VR" in the browser prompt</li>
              <li>4. Use controllers or hand gestures to interact</li>
              <li>5. Switch environments using the bottom panel</li>
            </ol>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
'@

Set-Content -Path "src/App.tsx" -Value $appTsx
Write-Host "✅ Created: src/App.tsx" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 2. UPDATE INDEX.CSS
# ----------------------------------------------------------------------------

$indexCss = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Montserrat:wght@700;800&display=swap');

body {
  margin: 0;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
'@

Set-Content -Path "src/index.css" -Value $indexCss
Write-Host "✅ Created: src/index.css" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 3. UPDATE VITE.CONFIG.TS
# ----------------------------------------------------------------------------

$viteConfig = @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/ws': {
        target: 'ws://localhost:8000',
        ws: true,
      },
    },
  },
})
'@

Set-Content -Path "vite.config.ts" -Value $viteConfig
Write-Host "✅ Created: vite.config.ts" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 4. XR STORE
# ----------------------------------------------------------------------------

$xrStore = @'
import { create } from 'zustand';

export type DeviceType = 'quest_2' | 'quest_3' | 'quest_pro' | 'vision_pro' | 'pcvr' | 'unknown';
export type InteractionMode = 'controllers' | 'hands' | 'gaze';
export type EnvironmentType = 'soft_room' | 'nature' | 'floating_platform';

interface XRState {
  isXRSupported: boolean;
  deviceType: DeviceType;
  targetFrameRate: number;
  isSessionActive: boolean;
  sessionMode: 'immersive-vr' | 'immersive-ar' | null;
  currentEnvironment: EnvironmentType;
  interactionMode: InteractionMode;
  dominantHand: 'left' | 'right';
  currentFPS: number;
  averageFrameTime: number;
  
  setXRSupported: (supported: boolean) => void;
  setDeviceType: (type: DeviceType) => void;
  setSessionActive: (active: boolean, mode: 'immersive-vr' | 'immersive-ar' | null) => void;
  setEnvironment: (env: EnvironmentType) => void;
  setInteractionMode: (mode: InteractionMode) => void;
  updatePerformance: (fps: number, frameTime: number) => void;
}

export const useXRStore = create<XRState>((set) => ({
  isXRSupported: false,
  deviceType: 'unknown',
  targetFrameRate: 72,
  isSessionActive: false,
  sessionMode: null,
  currentEnvironment: 'soft_room',
  interactionMode: 'controllers',
  dominantHand: 'right',
  currentFPS: 0,
  averageFrameTime: 0,

  setXRSupported: (supported) => set({ isXRSupported: supported }),
  
  setDeviceType: (type) => set((state) => {
    let targetFrameRate = 72;
    switch (type) {
      case 'quest_2': targetFrameRate = 72; break;
      case 'quest_3':
      case 'quest_pro': targetFrameRate = 90; break;
      case 'vision_pro': targetFrameRate = 100; break;
      case 'pcvr': targetFrameRate = 120; break;
    }
    return { deviceType: type, targetFrameRate, isXRSupported: true };
  }),

  setSessionActive: (active, mode) => set({ 
    isSessionActive: active, 
    sessionMode: mode 
  }),

  setEnvironment: (env) => set({ currentEnvironment: env }),
  setInteractionMode: (mode) => set({ interactionMode: mode }),
  updatePerformance: (fps, frameTime) => set({ 
    currentFPS: fps, 
    averageFrameTime: frameTime 
  }),
}));
'@

Set-Content -Path "src/features/xr/stores/xr.store.ts" -Value $xrStore
Write-Host "✅ Created: xr.store.ts" -ForegroundColor Green

Write-Host ""
Write-Host "⏳ Generating remaining files (this may take a moment)..." -ForegroundColor Yellow
Write-Host ""

# Continue in next message due to length...
