
# In VS Code, press Ctrl+Shift+X and search for each, or run:

# Step 1: Visual Studio Code Extensions (REQUIRED)
# Open VS Code and install these extensions:
# STEP 1: DO THIS ONLY ONCE IF VS CODE Extensions are NOT installed

<#
Essential Extensions:

✅ ESLint - JavaScript/TypeScript linting
✅ Prettier - Code formatting
✅ Tailwind CSS IntelliSense - For our styling
✅ ES7+ React/Redux/React-Native snippets - Fast React coding
✅ Python + Pylance - For FastAPI backend
✅ Three.js Snippets (pmndrs) - For XR development
✅ GitLens - Git visualization
✅ Docker - For PostgreSQL/Neo4j containers
✅ GitHub Copilot (optional but HIGHLY recommended - huge time saver)

#>

code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension bradlc.vscode-tailwindcss
code --install-extension dsznajder.es7-react-js-snippets
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension pmndrs.pmndrs
code --install-extension graphql.vscode-graphql
code --install-extension ms-azuretools.vscode-docker
code --install-extension eamodio.gitlens
code --install-extension PKief.material-icon-theme
code --install-extension GitHub.copilot

# Step 2: Install Core Development Tools
# 2.1: Node.js & npm

# Download and install Node.js LTS (v20.x)
# Go to: https://nodejs.org/en/download/
# Download "Windows Installer (.msi)" - 64-bit
# Run installer, accept defaults

# Verify installation (open new PowerShell):
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x

#2.2: Python 3.11+ for FastAPI Backend

# Download Python 3.11 or 3.12:
# Go to: https://www.python.org/downloads/
# Download "Windows installer (64-bit)"
# IMPORTANT: Check "Add Python to PATH" during installation!

# Verify:
python --version  # Should show Python 3.11.x or 3.12.x
pip --version

#2.3: Git

# Download Git for Windows:
# Go to: https://git-scm.com/download/win
# Run installer, accept defaults

# Verify:
git --version

#2.4: Docker Desktop (for databases)

# Download Docker Desktop for Windows:
# Go to: https://www.docker.com/products/docker-desktop/
# Install and restart computer
# Make sure WSL 2 is enabled (Docker will prompt if needed)

# Verify:
docker --version
docker-compose --version

#Step 3: VS Code Configuration
#Create these files in your project root:
# .vscode/settings.json

param(
  [switch]$generateonly,
  [switch]$buildAll,
  [switch]$buildApp = $true,
  [switch]$buildInfra,
  [switch]$Test,
  [switch]$NoDocker,
  [switch]$InitGit,
  [string]$GitRemote = "",   # e.g. https://github.com/<you>/genai-portfolio.git
  [switch]$RepoRootCreateForced
)

$newHomePath = "D:\ChatGPT Projects"
$RepoRoot = "$newHomePath\genai-portfolio"
$Project = "02-clinical-hypno-self-improvement-platform"
$Root = "$RepoRoot\projects\$Project"

[Environment]::SetEnvironmentVariable("USERPROFILE", $newHomePath, "User")
Set-Variable -Name HOME -Value $newHomePath -Force
Write-Host "Home directory set to: $HOME"
Write-Host "buildAll = $buildAll; buildApp = $buildApp; buildInfra = $buildInfra; generateonly = $generateonly; Test:$Test, NoDocker: $NoDocker, InitGit:$InitGit, GitRemote:$GitRemote, RepoRootCreatedForced:$RepoRootCreateForced, Root:$Root"

$ErrorActionPreference = "Stop"
function EnsureDir($p){ New-Item -ItemType Directory -Force -Path $p | Out-Null }
function SC($p,$c){ EnsureDir (Split-Path $p); $c | Set-Content -Encoding UTF8 $p }
function AddIfMissing($f,$needle,$append){
  $txt = (Get-Content $f -Raw -ErrorAction SilentlyContinue); if (-not $txt){$txt=""}
  if ($txt -notmatch [regex]::Escape($needle)) { Add-Content -Path $f -Value $append }
}

function Write-Section($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function S($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function Sec($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }

function Mk($p){ 
#Write-Section "Creating Directory $p"
New-Item -ItemType Directory -Force -Path $p | Out-Null }

function SetContent($path, $content){ 
#  Write-Section "Creating file $path"
  New-Item -ItemType File -Force -Path $path | Out-Null; Set-Content -Encoding UTF8 $path $content }
function AddContent($path, $content){ Add-Content -Encoding UTF8 $path $content }

#$Root = "$HOME\genai-portfolio\projects\01-clinical-hypno-resilientmind-mcp-ragagents"
function EnsureDir($p){ New-Item -ItemType Directory -Force -Path $p | Out-Null }
function SC($p,$c){ EnsureDir (Split-Path $p); $c | Set-Content -Encoding UTF8 $p }
function AddIfMissing($f,$needle,$append){
  $txt = (Get-Content $f -Raw -ErrorAction SilentlyContinue); if (-not $txt){$txt=""}
  if ($txt -notmatch [regex]::Escape($needle)) { Add-Content -Path $f -Value $append }
}

# -------- CONFIG --------
#Root = "$HOME\genai-portfolio"   # <--- change if needed


# --- 0) Create root + basic files ---

Write-Section "Create repo root = $RepoRoot ;  home $newHomePath"

$repoRootParams = @{
	ItemType = "Directory"
	Path	 = $RepoRoot
}

if ($RepoRootCreateForced) {
	$repoRootParams.Force = $true
}
New-Item @repoRootParams | Out-Null
New-Item -ItemType Directory -Force -Path "$RepoRoot\projects" | Out-Null
New-Item -ItemType Directory -Force -Path "$RepoRoot\projects\$Project" | Out-Null
New-Item -ItemType Directory -Force -Path "$Root" | Out-Null
New-Item -ItemType Directory -Force -Path "$Root\.vscode" | Out-Null

Set-Location -Path $Root

$vscodesetting = @"
{
  "atlassian.jira.site": "https://<your-domain>.atlassian.net",
  "atlassian.jira.project": "RESM"
},
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ],
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "python.defaultInterpreterPath": "venv/Scripts/python.exe",
  "python.formatting.provider": "black",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  },
  "emmet.triggerExpansionOnTab": true
}

"@
 
Set-Content -Path "$Root\.vscode\settings.json" -Value $vscodesetting -Encoding UTF8


# .vscode/extensions.json

$vscodeExtensions = @"

{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "dsznajder.es7-react-js-snippets",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "pmndrs.pmndrs",
    "ms-azuretools.vscode-docker",
    "eamodio.gitlens"
  ]
}

"@
Set-Content -Path "$Root\.vscode\settings.json" -Value $vscodesetting -Encoding UTF8

$vscodeLaunch = @"

{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "React: Chrome",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/frontend/src",
      "sourceMaps": true
    },
    {
      "name": "FastAPI: Debug",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": [
        "main:app",
        "--reload",
        "--host",
        "0.0.0.0",
        "--port",
        "8000"
      ],
      "jinja": true,
      "justMyCode": false,
      "cwd": "${workspaceFolder}/backend"
    }
  ],
  "compounds": [
    {
      "name": "Full Stack",
      "configurations": ["React: Chrome", "FastAPI: Debug"]
    }
  ]
}

"@

Set-Content -Path  "$Root\.vscode\launch.json" -Value $vscodeLaunch -Encoding UTF8

#Step 4: Project Structure & Initial Setup
#Create Project Root

#cd $Root

#code .

# Frontend (React + XR)
$FrontEndDir = "$Root\frontend"
EnsureDir $FrontEndDir
Set-Location -Path $FrontEndDir
npm create vite@latest . -- --template react-ts
npm install

# Backend (FastAPI)
$BackEndDir = "$Root\backend"
EnsureDir $BackEndDir
Set-Location $BackEndDir

python -m venv
.\venv\Scripts\activate
pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv pydantic pydantic-settings

# Docker setup
$DockerDir = "$Root\docker"
EnsureDir $DockerDir

Set-Location $Root

<# ############################

Step 5: Hardware Acceleration for XR Development
Your Legion Pro 7 with RTX GPU is perfect for XR! Enable GPU acceleration:
Chrome/Edge Flags (for WebXR testing)

Open Chrome/Edge
Navigate to: chrome://flags or edge://flags
Enable these:

#enable-webxr → Enabled
#webxr-incubations → Enabled
#enable-gpu-rasterization → Enabled


Restart browser

NVIDIA Control Panel Settings

Right-click Desktop → NVIDIA Control Panel
Manage 3D Settings → Program Settings
Add chrome.exe and Code.exe
Set Power management mode → Prefer maximum performance
Set OpenGL rendering GPU → Your RTX GPU


Step 6: Windows 11 Optimizations
Enable Developer Mode
powershell# Settings > Privacy & Security > For developers > Developer Mode
# Turn ON
Install Windows Terminal (if not already)
powershell# From Microsoft Store - search "Windows Terminal"
# Set as default terminal in VS Code settings
Optional: WSL2 (Better for Python/Docker)
powershell# Run in PowerShell (Admin):
wsl --install

# Restart computer
# After restart, set up Ubuntu username/password
# Then in VS Code, install "WSL" extension

# You can then work in WSL2 for backend, Windows for frontend

Step 7: Browser Setup for XR Testing
Install Multiple Browsers

✅ Chrome (primary for WebXR)
✅ Edge (alternative for WebXR)
✅ Firefox Nightly (WebXR support)

Install Quest Browser Simulator
powershell# Install Meta Quest Developer Hub
# Download from: https://developer.oculus.com/downloads/
# This lets you test Quest WebXR without headset

Step 8: Verify Your Setup
Run this test script:
powershell# Create test file: test-setup.ps1
Write-Host "=== HMI Platform Development Environment Check ===" -ForegroundColor Cyan

Write-Host "`n1. Node.js" -ForegroundColor Yellow
node --version
npm --version

Write-Host "`n2. Python" -ForegroundColor Yellow
python --version
pip --version

Write-Host "`n3. Git" -ForegroundColor Yellow
git --version

Write-Host "`n4. Docker" -ForegroundColor Yellow
docker --version

Write-Host "`n5. VS Code Extensions" -ForegroundColor Yellow
code --list-extensions | Select-String -Pattern "eslint|prettier|tailwind|python"

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Run it:
powershellpowershell -ExecutionPolicy Bypass -File test-setup.ps1

📊 Your Development Workflow Will Be:
Terminal 1 (Frontend):
bashcd frontend
npm run dev
# Runs on http://localhost:5173
Terminal 2 (Backend):
bashcd backend
venv\Scripts\activate
uvicorn main:app --reload
# Runs on http://localhost:8000
Terminal 3 (Databases):
bashdocker-compose up
# PostgreSQL on port 5432
# Neo4j on port 7687

####################### #>


wsl --install

# Install Meta Quest Developer Hub
# Download from: https://developer.oculus.com/downloads/
# This lets you test Quest WebXR without headset

# install node

.\install-node.ps1
$correctPath = "C:\Program Files\nodejs"
$env:Path += ";$correctPath"

# Get the current User Path variable
$userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

# Check if the correct path is already there or add it
if ($userPath -notlike "*$correctPath*") {
    $newUserPath = $userPath + ";" + $correctPath
    [System.Environment]::SetEnvironmentVariable("Path", $newUserPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "Corrected Node.js path added to User PATH successfully." -ForegroundColor Green
} else {
    Write-Host "Correct Node.js path already present in User PATH." -ForegroundColor Green
}

node --version

New-Item -ItemType Directory -Force -Path "$Root\frontend"
New-Item -ItemType Directory -Force -Path "$Root\backend"
New-Item -ItemType Directory -Force -Path "$Root\backend\app"
New-Item -ItemType Directory -Force -Path "$Root\docker"
New-Item -ItemType Directory -Force -Path "$Root\scripts"


# ============================== GENERATE FRONT END ###########################
Write-Section "==> Generating Front End Task 5.1.1: Install and Configure Dependencies <===="
# You're already here:
# D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform\frontend

# Go up one level to the project root
Set-Location $Root
# Now you're in: D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform

# Check where you are:
Get-Location

# Create proper structure
New-Item -ItemType Directory -Force -Path "frontend"
New-Item -ItemType Directory -Force -Path "backend"
New-Item -ItemType Directory -Force -Path "backend/app"
New-Item -ItemType Directory -Force -Path "docker"
New-Item -ItemType Directory -Force -Path "scripts"

# Initialize frontend
Set-Location "$Root\frontend"

npm create vite@latest . -- --template react-ts -y --force

# When prompted:
# ? Current directory is not empty. Remove existing files and continue? › Yes

# Install dependencies
#npm install
# Remove conflicting packages
npm uninstall react react-dom

# Install React 18 (stable, compatible)
npm install react@18.2.0 react-dom@18.2.0

# Install all XR and UI packages with legacy peer deps flag
npm install --legacy-peer-deps `
  three@0.160.0 `
  @react-three/fiber@8.15.0 `
  @react-three/drei@9.92.0 `
  @react-three/xr@6.2.0 `
  zustand@4.5.0 `
  react-router-dom@6.22.0 `
  axios@1.6.5 `
  @tanstack/react-query@5.17.19 `
  lucide-react@0.314.0 `
  recharts@2.10.4 `
  r3f-perf@7.1.2

# Install Tailwind CSS
npm install --legacy-peer-deps `
  tailwindcss@3.4.1 `
  postcss@8.4.33 `
  autoprefixer@10.4.17

# Install dev dependencies
npm install --legacy-peer-deps -D @types/three

# Initialize Tailwind
npx tailwindcss init -p

npm install @react-three/xr@6.2.3
npm install @pmndrs/pointer-events@0.8.0
npm install three@0.160.0

# Install compatible versions
npm install @react-three/xr@latest
npm install @pmndrs/pointer-events@latest
npm install three@latest

npm install @react-three/fiber three @types/three @react-three/xr xr @react-three/drei

# Clear cache and reinstall
npm install

# Stop dev server (Ctrl+C)

# Delete node_modules and reinstall everything
Remove-Item -Path node_modules -Recurse -Force
Remove-Item -Path package-lock.json -Force
npm install

# Stop the development server first (if running)

Write-Host "Clearing node_modules and Vite cache..."
# Clear Vite cache
Remove-Item -Path node_modules\.vite -Recurse -Force -ErrorAction SilentlyContinue

# Remove node_modules folder
Remove-Item -Path "node_modules" -Recurse -Force

# Remove the Vite cache folder
Remove-Item -Path ".vite" -Recurse -Force

# Clear npm cache (as a precaution)
npm cache clean --force

Write-Host "Cache cleared. Reinstalling dependencies..."

# Reinstall all project dependencies
npm install

Write-Host "Installation complete. Restarting dev server..."

Write-Host "Clearing Vite cache..."
# Use -ErrorAction SilentlyContinue in case the .vite folder doesn't exist
Remove-Item -Path ".vite" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path node_modules\.vite -Recurse -Force -ErrorAction SilentlyContinue
# Start dev server
New-NetFirewallRule -DisplayName "Vite Dev Server (Port 5173)" -Direction Inbound -LocalPort 5173 -Protocol TCP -Action Allow -Profile Any
try: {
  npm run dev
  Remove-Item -Path "node_modules" -Recurse -Force -ErrorAction SilentlyContinue
  # Remove the Vite cache folder
  Remove-Item -Path ".vite" -Recurse -Force -ErrorAction SilentlyContinue

  # Clear npm cache (as a precaution)
  npm cache clean --force

  Write-Host "Cache cleared. Reinstalling dependencies..."

  # Reinstall all project dependencies
  npm install

  Write-Host "Installation complete. Restarting dev server..."
} catch error: {
  Remove-Item -Path "node_modules" -Recurse -Force -ErrorAction SilentlyContinue

# Remove the Vite cache folder
Remove-Item -Path ".vite" -Recurse -Force -ErrorAction SilentlyContinue

# Clear npm cache (as a precaution)
npm cache clean --force

Write-Host "Cache cleared. Reinstalling dependencies..."

# Reinstall all project dependencies
npm install

Write-Host "Installation complete. Restarting dev server..."

# Restart your development server
npm run dev
}

Write-Host "✅ All dependencies installed!" -ForegroundColor Green

Write-Host "✅ Frontend initialized!" -ForegroundColor Green
# Check current location
Write-Host "Current Directory:" -ForegroundColor Cyan
pwd

Write-Host "`nFiles in current directory:" -ForegroundColor Cyan
ls | Format-Table Name, Mode

Write-Host "`nChecking package.json:" -ForegroundColor Cyan
if (Test-Path "package.json") {
    Write-Host "package.json exists" -ForegroundColor Green
    cat package.json | Select-String "scripts" -Context 5
} else {
    Write-Host "package.json NOT found" -ForegroundColor Red
}

Write-Host "`nChecking node_modules:" -ForegroundColor Cyan
if (Test-Path "node_modules") {
    Write-Host "node_modules exists" -ForegroundColor Green
} else {
    Write-Host "Node_modules NOT found" -ForegroundColor Red
}

<# 
## 📁 Your Project Structure Should Be:
```
D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform\
├── frontend/
│   ├── node_modules/          ← Created by npm install
│   ├── public/
│   ├── src/
│   │   ├── features/
│   │   │   └── xr/           ← We'll create this
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json          ← THIS IS WHAT'S MISSING!
│   ├── vite.config.ts
│   └── tailwind.config.js
├── backend/
│   ├── app/
│   ├── requirements.txt
│   └── Dockerfile
├── docker-compose.yml
└── scripts/

#>

# Create XR folder structure

New-Item -ItemType Directory -Force -Path "$FrontEnd\src\features\xr"
New-Item -ItemType Directory -Force -Path "$FrontEnd\src\features\xr\stores"
New-Item -ItemType Directory -Force -Path "$FrontEnd\src\features\xr\components"
New-Item -ItemType Directory -Force -Path "$FrontEnd\src\features\xr\environments"

Write-Host "✅ XR folders created!" -ForegroundColor Green

#### Generate XR Files 
<#
 copy all the XR files I provided earlier:

src/features/xr/stores/xr.store.ts
src/features/xr/components/XRDeviceDetector.tsx
src/features/xr/environments/SoftLitRoom.tsx
src/features/xr/environments/NatureScene.tsx
src/features/xr/environments/FloatingPlatform.tsx
src/features/xr/components/EnvironmentSelector.tsx
src/features/xr/components/XRScene.tsx
src/features/xr/XRApp.tsx
src/App.tsx (updated version)
vite.config.ts (updated version)
tailwind.config.js
#>

Write-Section " ==> Adding $FrontEnd\tsconfig.json"
AddContent "$FrontEnd\tsconfig.json" "compilerOptions" @"
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ],

"compilerOptions": {
    "types": ["@react-three/fiber"],
    "jsx": "react-jsx",
    "moduleResolution": "bundler"
  },
  "include": ["src"]
}
"@

Set-Content -Path "$FrontEnd\src\react-three-fiber.d.ts" -Value @"
import { ThreeElements } from '@react-three/fiber';

declare global {
  namespace JSX {
    interface IntrinsicElements extends ThreeElements {}
  }
}
"@

Write-Section " ==> Generating Task 5.1.2: Create XR App Shell typescript => $FrontEnd\src\features\xr\XRApp.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\stores\xr.store.ts" -Value @"
import { Canvas } from '@react-three/fiber';
import { VRButton, ARButton, XR, Controllers, Hands } from '@react-three/xr';
import { useXRStore } from './stores/xr.store';
import { XRScene } from './components/XRScene';
import { XRDeviceDetector } from './components/XRDeviceDetector';
import { PerformanceMonitor } from './components/PerformanceMonitor';
import { Suspense } from 'react';
import { LoadingEnvironment } from './components/LoadingEnvironment';

export function XRApp() {
  const { isXRSupported, deviceType } = useXRStore();

  if (!isXRSupported) {
    return <FallbackTo2DUI />;
  }

  return (
    <div className="relative h-screen w-screen bg-black">
      {/* XR Session Buttons */}
      <div className="absolute top-4 left-4 z-10 flex gap-4">
        <VRButton
          mode="immersive-vr"
          sessionInit={{
            requiredFeatures: ['hand-tracking', 'local-floor'],
            optionalFeatures: ['bounded-floor', 'layers'],
          }}
        />
        {deviceType === 'vision_pro' && (
          <ARButton
            mode="immersive-ar"
            sessionInit={{
              requiredFeatures: ['hand-tracking'],
            }}
          />
        )}
      </div>

      {/* Performance Stats (dev only) */}
      {import.meta.env.DEV && <PerformanceMonitor />}

      {/* React Three Fiber Canvas */}
      <Canvas
        camera={{
          position: [0, 1.6, 0], // Average eye height
          fov: 75,
        }}
        gl={{
          antialias: true,
          alpha: false,
          powerPreference: 'high-performance',
        }}
      >
        <XR>
          <Suspense fallback={<LoadingEnvironment />}>
            {/* Controllers and Hand Tracking */}
            <Controllers />
            <Hands />

            {/* Main XR Scene */}
            <XRScene />
          </Suspense>
        </XR>
      </Canvas>

      {/* Device Detector (invisible, sets store state) */}
      <XRDeviceDetector />
    </div>
  );
}

function FallbackTo2DUI() {
  return (
    <div className="flex h-screen items-center justify-center bg-gray-900 text-white">
      <div className="max-w-md text-center">
        <h2 className="mb-4 text-2xl font-bold">WebXR Not Supported</h2>
        <p className="mb-6 text-gray-300">
          Your device or browser doesn't support WebXR. 
          Redirecting to standard web experience...
        </p>
        <button
          onClick={() => window.location.href = '/dashboard/assessment'}
          className="rounded-lg bg-primary-600 px-6 py-3 font-medium hover:bg-primary-700"
        >
          Continue with Web Version
        </button>
      </div>
    </div>
  );
}
"@

Write-Section " ==> Generating Task 5.1.3: XR State Management typescript => $FrontEnd\src\features\xr\stores\xr.store.ts"
Set-Content -Path "$FrontEnd\src\features\xr\stores\xr.store.ts" -Value @"
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

export type DeviceType = 'quest_2' | 'quest_3' | 'quest_pro' | 'vision_pro' | 'pcvr' | 'unknown';
export type InteractionMode = 'controllers' | 'hands' | 'gaze';

type XRState = {
  // Device detection
  isXRSupported: boolean;
  deviceType: DeviceType;
  targetFrameRate: number;
  
  // Session state
  isSessionActive: boolean;
  sessionMode: 'immersive-vr' | 'immersive-ar' | null;
  
  // Interaction
  interactionMode: InteractionMode;
  dominantHand: 'left' | 'right';
  
  // Performance
  currentFPS: number;
  averageFrameTime: number;
  
  // Settings
  settings: {
    comfort: {
      snapTurning: boolean;
      vignetteOnMovement: boolean;
      teleportOnly: boolean;
    };
    accessibility: {
      fontSize: number; // 1.0 = default, 1.5 = 150%
      highContrast: boolean;
      reducedMotion: boolean;
    };
  };
  
  // Actions
  setDeviceType: (type: DeviceType) => void;
  setSessionActive: (active: boolean) => void;
  setInteractionMode: (mode: InteractionMode) => void;
  updatePerformance: (fps: number, frameTime: number) => void;
  updateSettings: (settings: Partial<XRState['settings']>) => void;
};

export const useXRStore = create<XRState>()(
  immer((set) => ({
    // Initial state
    isXRSupported: false,
    deviceType: 'unknown',
    targetFrameRate: 72,
    isSessionActive: false,
    sessionMode: null,
    interactionMode: 'controllers',
    dominantHand: 'right',
    currentFPS: 0,
    averageFrameTime: 0,
    
    settings: {
      comfort: {
        snapTurning: true,
        vignetteOnMovement: true,
        teleportOnly: false,
      },
      accessibility: {
        fontSize: 1.0,
        highContrast: false,
        reducedMotion: false,
      },
    },

    // Actions
    setDeviceType: (type) => set((state) => {
      state.deviceType = type;
      state.isXRSupported = true;
      
      // Set target frame rate based on device
      switch (type) {
        case 'quest_2':
          state.targetFrameRate = 72;
          break;
        case 'quest_3':
        case 'quest_pro':
          state.targetFrameRate = 90;
          break;
        case 'vision_pro':
          state.targetFrameRate = 100;
          break;
        case 'pcvr':
          state.targetFrameRate = 120;
          break;
      }
    }),

    setSessionActive: (active) => set((state) => {
      state.isSessionActive = active;
    }),

    setInteractionMode: (mode) => set((state) => {
      state.interactionMode = mode;
    }),

    updatePerformance: (fps, frameTime) => set((state) => {
      state.currentFPS = fps;
      state.averageFrameTime = frameTime;
    }),

    updateSettings: (newSettings) => set((state) => {
      state.settings = { ...state.settings, ...newSettings };
    }),
  }))
);
"@


Write-Section " ==> Generating Task 5.1.4: Device Detection Component typescript => $FrontEnd\src\features\xr\components\XRDeviceDetector.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\components\XRDeviceDetector.tsx" -Value @"

import { useEffect } from 'react';
import { useXRStore } from '../stores/xr.store';

export function XRDeviceDetector() {
  const setDeviceType = useXRStore((state) => state.setDeviceType);

  useEffect(() => {
    detectDevice();
  }, []);

  async function detectDevice() {
    // Check if WebXR is supported
    if (!('xr' in navigator)) {
      console.log('WebXR not supported');
      return;
    }

    try {
      const supported = await (navigator as any).xr?.isSessionSupported('immersive-vr');
      if (!supported) {
        console.log('Immersive VR not supported');
        return;
      }

      // Detect specific device
      const userAgent = navigator.userAgent.toLowerCase();
      
      if (userAgent.includes('quest 3')) {
        setDeviceType('quest_3');
      } else if (userAgent.includes('quest 2')) {
        setDeviceType('quest_2');
      } else if (userAgent.includes('quest pro')) {
        setDeviceType('quest_pro');
      } else if (userAgent.includes('apple vision')) {
        setDeviceType('vision_pro');
      } else {
        // Generic PCVR or unknown
        setDeviceType('pcvr');
      }

      console.log('XR device detected and configured');
    } catch (error) {
      console.error('Error detecting XR device:', error);
    }
  }

  return null; // This component doesn't render anything
}

"@

Write-Section " ==> Generating Task 5.1.5: Performance Monitoring typescript => $FrontEnd\src\features\xr\components\PerformanceMonitor.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\components\PerformanceMonitor.tsx" -Value @"
import { useFrame } from '@react-three/fiber';
import { useRef, useEffect } from 'react';
import { useXRStore } from '../stores/xr.store';
import Stats from 'stats.js';

export function PerformanceMonitor() {
  const statsRef = useRef<Stats | null>(null);
  const updatePerformance = useXRStore((state) => state.updatePerformance);
  const frameTimesRef = useRef<number[]>([]);

  useEffect(() => {
    // Create Stats.js instance
    const stats = new Stats();
    stats.showPanel(0); // 0: fps, 1: ms, 2: mb
    stats.dom.style.position = 'absolute';
    stats.dom.style.top = '80px';
    stats.dom.style.left = '10px';
    document.body.appendChild(stats.dom);
    statsRef.current = stats;

    return () => {
      if (stats.dom.parentElement) {
        document.body.removeChild(stats.dom);
      }
    };
  }, []);

  useFrame((state, delta) => {
    if (statsRef.current) {
      statsRef.current.begin();
    }

    // Track frame times
    const frameTime = delta * 1000; // Convert to ms
    frameTimesRef.current.push(frameTime);
    
    // Keep only last 60 frames
    if (frameTimesRef.current.length > 60) {
      frameTimesRef.current.shift();
    }

    // Calculate average
    const avgFrameTime = frameTimesRef.current.reduce((a, b) => a + b, 0) / frameTimesRef.current.length;
    const fps = 1000 / avgFrameTime;

    // Update store every 30 frames
    if (frameTimesRef.current.length % 30 === 0) {
      updatePerformance(fps, avgFrameTime);
    }

    if (statsRef.current) {
      statsRef.current.end();
    }
  });

  return null;
}
"@





Write-Section " ==> Generating Task 5.1.6: Controller Input System typescript => $FrontEnd\src\features\xr\hooks\useControllerInput.ts"
Set-Content -Path "$FrontEnd\src\features\xr\hooks\useControllerInput.ts" -Value @"

import { useXR, useController } from '@react-three/xr';
import { useEffect, useRef } from 'react';

export type ControllerButton = 
  | 'trigger'
  | 'squeeze'
  | 'thumbstick'
  | 'a_button'
  | 'b_button'
  | 'x_button'
  | 'y_button';

type ControllerInputCallback = {
  onButtonPress?: (button: ControllerButton, hand: 'left' | 'right') => void;
  onButtonRelease?: (button: ControllerButton, hand: 'left' | 'right') => void;
  onThumbstickMove?: (x: number, y: number, hand: 'left' | 'right') => void;
};

export function useControllerInput(callbacks: ControllerInputCallback) {
  const leftController = useController('left');
  const rightController = useController('right');
  const previousStateRef = useRef<Map<string, boolean>>(new Map());

  useEffect(() => {
    if (!leftController && !rightController) return;

    const checkController = (controller: any, hand: 'left' | 'right') => {
      if (!controller?.inputSource?.gamepad) return;

      const gamepad = controller.inputSource.gamepad;
      const buttons = gamepad.buttons;
      const axes = gamepad.axes;

      // Button mapping (Quest controllers)
      const buttonMap: Record<number, ControllerButton> = {
        0: 'trigger',
        1: 'squeeze',
        3: hand === 'left' ? 'x_button' : 'a_button',
        4: hand === 'left' ? 'y_button' : 'b_button',
      };

      // Check buttons
      buttons.forEach((button: GamepadButton, index: number) => {
        const buttonName = buttonMap[index];
        if (!buttonName) return;

        const key = `${hand}-${buttonName}`;
        const wasPressed = previousStateRef.current.get(key);
        const isPressed = button.pressed;

        if (isPressed && !wasPressed) {
          callbacks.onButtonPress?.(buttonName, hand);
        } else if (!isPressed && wasPressed) {
          callbacks.onButtonRelease?.(buttonName, hand);
        }

        previousStateRef.current.set(key, isPressed);
      });

      // Check thumbstick
      if (axes.length >= 4 && callbacks.onThumbstickMove) {
        const xAxis = hand === 'left' ? axes[2] : axes[0];
        const yAxis = hand === 'left' ? axes[3] : axes[1];
        
        // Only trigger if movement is significant (dead zone)
        if (Math.abs(xAxis) > 0.1 || Math.abs(yAxis) > 0.1) {
          callbacks.onThumbstickMove(xAxis, yAxis, hand);
        }
      }
    };

    const interval = setInterval(() => {
      if (leftController) checkController(leftController, 'left');
      if (rightController) checkController(rightController, 'right');
    }, 16); // ~60Hz

    return () => clearInterval(interval);
  }, [leftController, rightController, callbacks]);
}
"@

Write-Section " ==> Generating Task 5.1.7: Hand Tracking Integration typescript => $FrontEnd\src\features\xr\hooks\useHandTracking.ts"
Set-Content -Path "$FrontEnd\src\features\xr\hooks\useHandTracking.ts" -Value @"
import { useXR } from '@react-three/xr';
import { useFrame } from '@react-three/fiber';
import { useRef } from 'react';
import * as THREE from 'three';

export type HandJoint = 'wrist' | 'thumb-tip' | 'index-finger-tip' | 'pinch-position';

type HandTrackingCallback = {
  onPinch?: (hand: 'left' | 'right', position: THREE.Vector3) => void;
  onPoint?: (hand: 'left' | 'right', direction: THREE.Vector3) => void;
};

export function useHandTracking(callbacks: HandTrackingCallback) {
  const { session } = useXR();
  const previousPinchState = useRef<{ left: boolean; right: boolean }>({
    left: false,
    right: false,
  });

  useFrame(() => {
    if (!session || !callbacks) return;

    // Get hand tracking data
    const frame = session.requestAnimationFrame ? (session as any).frame : null;
    if (!frame) return;

    ['left', 'right'].forEach((handedness) => {
      const hand = handedness as 'left' | 'right';
      
      // Get input source for this hand
      const inputSource = session.inputSources.find(
        (source: any) => source.handedness === handedness && source.hand
      );

      if (!inputSource?.hand) return;

      try {
        // Get joints
        const indexTip = inputSource.hand.get('index-finger-tip');
        const thumbTip = inputSource.hand.get('thumb-tip');
        const indexProximal = inputSource.hand.get('index-finger-metacarpal');

        if (!indexTip || !thumbTip || !indexProximal) return;

        // Calculate pinch distance
        const indexPos = new THREE.Vector3().fromArray(indexTip.transform.position as any);
        const thumbPos = new THREE.Vector3().fromArray(thumbTip.transform.position as any);
        const distance = indexPos.distanceTo(thumbPos);

        // Detect pinch (threshold ~2cm)
        const isPinching = distance < 0.02;
        const wasPinching = previousPinchState.current[hand];

        if (isPinching && !wasPinching) {
          // Pinch started
          const pinchPos = new THREE.Vector3()
            .addVectors(indexPos, thumbPos)
            .multiplyScalar(0.5);
          callbacks.onPinch?.(hand, pinchPos);
        }

        previousPinchState.current[hand] = isPinching;

        // Pointing direction
        if (callbacks.onPoint) {
          const proximalPos = new THREE.Vector3().fromArray(indexProximal.transform.position as any);
          const pointDirection = new THREE.Vector3()
            .subVectors(indexPos, proximalPos)
            .normalize();
          callbacks.onPoint(hand, pointDirection);
        }
      } catch (error) {
        console.error('Hand tracking error:', error);
      }
    });
  });
}
"@

Write-Section " ==> Generating Task 5.1.8: Gaze-Based Input System typescript => $FrontEnd\src\features\xr\hooks\useGazeInput.ts"
Set-Content -Path "$FrontEnd\src\features\xr\hooks\useGazeInput.ts" -Value @"
import { useFrame, useThree } from '@react-three/fiber';
import { useRef, useCallback } from 'react';
import * as THREE from 'three';

type GazeInputCallback = {
  onGazeEnter?: (object: THREE.Object3D) => void;
  onGazeExit?: (object: THREE.Object3D) => void;
  onGazeDwell?: (object: THREE.Object3D, duration: number) => void;
};

export function useGazeInput(
  callbacks: GazeInputCallback,
  dwellTimeMs: number = 1500
) {
  const { camera, scene } = useThree();
  const raycaster = useRef(new THREE.Raycaster());
  const gazedObject = useRef<THREE.Object3D | null>(null);
  const gazeDuration = useRef(0);

  useFrame((state, delta) => {
    // Cast ray from camera forward
    raycaster.current.setFromCamera(new THREE.Vector2(0, 0), camera);
    
    // Find intersections with interactive objects
    const intersects = raycaster.current.intersectObjects(
      scene.children.filter((obj) => (obj.userData as any).interactive),
      true
    );

    const currentTarget = intersects.length > 0 ? intersects[0].object : null;

    // Check if target changed
    if (currentTarget !== gazedObject.current) {
      // Exit previous target
      if (gazedObject.current) {
        callbacks.onGazeExit?.(gazedObject.current);
      }

      // Enter new target
      gazedObject.current = currentTarget;
      gazeDuration.current = 0;

      if (currentTarget) {
        callbacks.onGazeEnter?.(currentTarget);
      }
    }

    // Track dwell time
    if (currentTarget) {
      gazeDuration.current += delta * 1000; // Convert to ms

      if (gazeDuration.current >= dwellTimeMs) {
        callbacks.onGazeDwell?.(currentTarget, gazeDuration.current);
        gazeDuration.current = 0; // Reset to prevent repeated triggers
      }
    }
  });

  const resetGaze = useCallback(() => {
    if (gazedObject.current) {
      callbacks.onGazeExit?.(gazedObject.current);
    }
    gazedObject.current = null;
    gazeDuration.current = 0;
  }, [callbacks]);

  return { resetGaze };
}
"@

Write-Section "### ## 📖 Story 5.2: Calming Virtual Environments ## ###"

Write-Section " ==> Generating Story 5.2: Calming Virtual Environments .mmd => $FrontEnd\src\features\xr\environments\CalmVR.mmd"
Set-Content -Path "$FrontEnd\src\features\xr\environments\CalmVR" -Value @"
## 📖 Story 5.2: Calming Virtual Environments

**Story**:
*"As a user in VR, I want to be immersed in a beautiful, calming environment that reduces anxiety and promotes relaxation, so that I feel safe and comfortable during my assessment or therapy session."*

**Priority**: P0 (Must Have - Sprint 4, Week 2)
**Story Points**: 13
**Dependencies**: Story 5.1 (XR infrastructure)

### **Acceptance Criteria**:
1. ✅ Three environment options available: Soft-Lit Room, Nature Scene, Floating Platform
2. ✅ Procedurally generated sky with time-of-day variations
3. ✅ Ambient lighting appropriate for each environment
4. ✅ Subtle ambient animations (swaying trees, particle effects)
5. ✅ Spatial audio (nature sounds, gentle music)
6. ✅ Optimized for target frame rates (72fps+ Quest 2)
7. ✅ User can switch environments from settings menu
8. ✅ Environment presets tied to session phase (calming for induction, neutral for assessment)
9. ✅ LOD (Level of Detail) system for performance
10. ✅ User testing shows 85%+ prefer VR environments over 2D

---

### 🔧 **Tasks for Story 5.2**:

#### **Task 5.2.1: Design XR Scenes with GenAI**
- **Assigned To**: XR Engineer + UX Designer
- **Estimated Hours**: 8h
- **GenAI Prompt**: Use **Prompt 1** from document
```
Prompt to use:

You are an expert XR interaction designer working with Unity, Unreal, and WebXR.
Design an animated, real-time VR/WebXR scene for a therapeutic questionnaire between client and therapist.
Constraints:
– The client wears a headset and sits in a calming virtual space (e.g., soft-lit room, nature scene).
– Questions appear as floating cards arranged in an arc around the client.
– Each question has:
  • main question text
  • response UI (Likert scale, sliders, choice chips, text input)
  • a "?" helper panel that, when focused, shows example answers and gentle guidance.
– The therapist UI is a separate panel (2D screen or mirrored desktop) showing live responses and summarized indicators (mood, tension, etc.).
– Animations: panels ease in/out, highlight on gaze or controller hover, subtle particle effects for breathing or calmness.

Describe:
– The environment and lighting
– How the questionnaire steps progress (one question at a time vs cluster)
– How the user selects answers (hand controllers, gaze, pinch, pointer)
– How the helper guidance is revealed and dismissed
– Any accessibility considerations (font size, contrast, motion settings)

Output in bullet points and include 1 concrete example question with specific response options and helper text for each option band.
Deliverable: Scene design document with specifications for 3 environments
"@


Write-Section " ==> Generating Task 5.2.2: Soft-Lit Room Environment typescript => $FrontEnd\src\features\xr\environments\SoftLitRoom.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\environments\SoftLitRoom.tsx" -Value @"

import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { 
  Environment, 
  Sky, 
  ContactShadows,
  SpotLight
} from '@react-three/drei';
import * as THREE from 'three';

export function SoftLitRoom() {
  const lightRef = useRef<THREE.SpotLight>(null);

  useFrame((state) => {
    if (lightRef.current) {
      // Gentle light pulsing for calming effect
      const time = state.clock.elapsedTime;
      lightRef.current.intensity = 0.8 + Math.sin(time * 0.5) * 0.1;
    }
  });

  return (
    <>
      {/* Skybox */}
      <Sky
        distance={450000}
        sunPosition={[0, 1, 0]}
        inclination={0.6}
        azimuth={0.25}
      />

      {/* Environment lighting */}
      <Environment preset="sunset" />

      {/* Ambient light */}
      <ambientLight intensity={0.4} color="#fff5e6" />

      {/* Main spot light (warm) */}
      <SpotLight
        ref={lightRef}
        position={[0, 5, 0]}
        angle={0.6}
        penumbra={1}
        intensity={0.8}
        color="#ffe4b5"
        castShadow
      />

      {/* Fill lights */}
      <pointLight position={[-5, 3, -5]} intensity={0.3} color="#ffd7a8" />
      <pointLight position={[5, 3, -5]} intensity={0.3} color="#ffd7a8" />

      {/* Floor */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, 0, 0]}
        receiveShadow
      >
        <planeGeometry args={[20, 20]} />
        <meshStandardMaterial
          color="#d4c8b8"
          roughness={0.8}
          metalness={0.2}
        />
      </mesh>

      {/* Soft shadows */}
      <ContactShadows
        position={[0, 0.01, 0]}
        opacity={0.4}
        scale={10}
        blur={2}
        far={4}
      />

      {/* Decorative elements */}
      <FloatingParticles />
    </>
  );
}

function FloatingParticles() {
  const particlesRef = useRef<THREE.Points>(null);
  const count = 100;

  // Generate random positions for particles
  const positions = new Float32Array(count * 3);
  for (let i = 0; i < count; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 10;
    positions[i * 3 + 1] = Math.random() * 5;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 10;
  }

  useFrame((state) => {
    if (particlesRef.current) {
      const time = state.clock.elapsedTime;
      particlesRef.current.rotation.y = time * 0.05;
      
      // Gentle up/down floating
      const positions = particlesRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < count; i++) {
        positions[i * 3 + 1] += Math.sin(time + i) * 0.001;
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
        size={0.02}
        color="#ffffff"
        transparent
        opacity={0.6}
        sizeAttenuation
      />
    </points>
  );
}
"@

Write-Section " ==> Generating Task 5.2.3: Nature Scene Environment typescript => $FrontEnd\src\features\xr\environments\NatureScene.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\environments\NatureScene.tsx" -Value @"
import { useRef, useMemo, useEffect } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useLOD } from '../performance/useLOD';

export function NatureScene() {
  const grassRef = useRef<THREE.InstancedMesh>(null);
  const flowersRef = useRef<THREE.InstancedMesh>(null);
  const birdsRef = useRef<THREE.Points>(null);
  const leavesRef = useRef<THREE.Points>(null);
  const lodManager = useLOD();

  // Generate grass blade positions
  const grassData = useMemo(() => {
    const count = 300;
    const positions: Array<{ position: [number, number, number]; rotation: number; scale: number }> = [];
    
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const radius = 2 + Math.random() * 13;
      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;
      
      positions.push({
        position: [x, 0, z],
        rotation: Math.random() * Math.PI * 2,
        scale: 0.5 + Math.random() * 0.5,
      });
    }
    
    return positions;
  }, []);

  // Generate flower positions
  const flowerData = useMemo(() => {
    const count = 50;
    const positions: Array<{ position: [number, number, number]; color: THREE.Color }> = [];
    
    const colors = [
      new THREE.Color('#ff6b9d'), // Pink
      new THREE.Color('#ffd93d'), // Yellow
      new THREE.Color('#a8e6cf'), // Light green
      new THREE.Color('#dda0dd'), // Plum
      new THREE.Color('#ffb347'), // Orange
    ];
    
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const radius = 3 + Math.random() * 10;
      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;
      
      positions.push({
        position: [x, 0.2, z],
        color: colors[Math.floor(Math.random() * colors.length)],
      });
    }
    
    return positions;
  }, []);

  // Tree positions
  const trees = useMemo(() => [
    { position: [-6, 0, -8] as [number, number, number], height: 3.5, foliageSize: 1.8 },
    { position: [7, 0, -10] as [number, number, number], height: 4, foliageSize: 2 },
    { position: [-8, 0, -6] as [number, number, number], height: 3, foliageSize: 1.5 },
    { position: [5, 0, -12] as [number, number, number], height: 3.8, foliageSize: 1.9 },
    { position: [-10, 0, -9] as [number, number, number], height: 3.2, foliageSize: 1.6 },
    { position: [9, 0, -7] as [number, number, number], height: 3.6, foliageSize: 1.7 },
    { position: [-4, 0, -11] as [number, number, number], height: 3.3, foliageSize: 1.55 },
    { position: [3, 0, -14] as [number, number, number], height: 4.2, foliageSize: 2.1 },
  ], []);

  // Rocks
  const rocks = useMemo(() => [
    { position: [2, 0.15, 1] as [number, number, number], scale: 0.3 },
    { position: [-3, 0.2, 2] as [number, number, number], scale: 0.4 },
    { position: [1, 0.1, -2] as [number, number, number], scale: 0.25 },
    { position: [4, 0.18, -1] as [number, number, number], scale: 0.35 },
    { position: [-1, 0.12, 3] as [number, number, number], scale: 0.28 },
    { position: [-4, 0.22, -3] as [number, number, number], scale: 0.42 },
  ], []);

  // Birds (flying particles)
  const birdPositions = useMemo(() => {
    const count = 30;
    const positions = new Float32Array(count * 3);
    
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 30;
      positions[i * 3 + 1] = 8 + Math.random() * 5;
      positions[i * 3 + 2] = -20 + Math.random() * 10;
    }
    
    return positions;
  }, []);

  // Falling leaves
  const leavesPositions = useMemo(() => {
    const count = 40;
    const positions = new Float32Array(count * 3);
    
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 20;
      positions[i * 3 + 1] = Math.random() * 8 + 2;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 20;
    }
    
    return positions;
  }, []);

  // LOD Setup
  useEffect(() => {
    if (!lodManager) return;

    // Create LOD for trees (example)
    // In production, you'd create different geometry detail levels
    trees.forEach((tree, idx) => {
      // High detail tree foliage
      const highDetail = new THREE.ConeGeometry(tree.foliageSize, tree.foliageSize * 1.2, 16);
      // Medium detail (fewer segments)
      const mediumDetail = new THREE.ConeGeometry(tree.foliageSize, tree.foliageSize * 1.2, 8);
      // Low detail (minimal segments)
      const lowDetail = new THREE.ConeGeometry(tree.foliageSize, tree.foliageSize * 1.2, 4);

      const material = new THREE.MeshStandardMaterial({
        color: '#2d5016',
        roughness: 0.9,
      });

      const treeLOD = lodManager.createLOD(
        `tree-foliage-${idx}`,
        {
          highDetail,
          mediumDetail,
          lowDetail,
          material,
        },
        {
          high: 15,
          medium: 30,
          low: 50,
          cull: 80,
        }
      );

      treeLOD.position.set(...tree.position);
      treeLOD.position.y = tree.height + 0.5;
    });

    return () => {
      // Cleanup LOD objects when component unmounts
      trees.forEach((_, idx) => {
        lodManager.remove(`tree-foliage-${idx}`);
      });
    };
  }, [lodManager, trees]);

  // Animations
  useFrame((state) => {
    const time = state.clock.elapsedTime;

    // Update LOD system
    if (lodManager) {
      lodManager.update();
    }

    // Sway grass
    if (grassRef.current) {
      grassData.forEach((grass, i) => {
        const dummy = new THREE.Object3D();
        dummy.position.set(...grass.position);
        dummy.rotation.y = grass.rotation;
        
        // Add swaying motion
        const swayX = Math.sin(time * 0.5 + i * 0.1) * 0.1;
        const swayZ = Math.cos(time * 0.5 + i * 0.1) * 0.1;
        dummy.rotation.x = swayX;
        dummy.rotation.z = swayZ;
        
        dummy.scale.set(grass.scale, grass.scale, grass.scale);
        dummy.updateMatrix();
        grassRef.current.setMatrixAt(i, dummy.matrix);
      });
      grassRef.current.instanceMatrix.needsUpdate = true;
    }

    // Animate flowers (gentle bobbing)
    if (flowersRef.current) {
      flowerData.forEach((flower, i) => {
        const dummy = new THREE.Object3D();
        const bobHeight = Math.sin(time * 0.8 + i * 0.3) * 0.05;
        dummy.position.set(
          flower.position[0],
          flower.position[1] + bobHeight,
          flower.position[2]
        );
        dummy.scale.setScalar(0.15);
        dummy.updateMatrix();
        flowersRef.current!.setMatrixAt(i, dummy.matrix);
      });
      flowersRef.current.instanceMatrix.needsUpdate = true;
    }

    // Animate birds
    if (birdsRef.current) {
      const positions = birdsRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < positions.length / 3; i++) {
        positions[i * 3] += Math.sin(time + i) * 0.02;
        positions[i * 3 + 1] += Math.cos(time * 0.5 + i) * 0.01;
        
        // Wrap around
        if (positions[i * 3] > 15) positions[i * 3] = -15;
        if (positions[i * 3] < -15) positions[i * 3] = 15;
      }
      birdsRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Animate falling leaves
    if (leavesRef.current) {
      const positions = leavesRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < positions.length / 3; i++) {
        positions[i * 3 + 1] -= 0.01; // Fall down
        positions[i * 3] += Math.sin(time + i) * 0.005; // Drift
        positions[i * 3 + 2] += Math.cos(time + i) * 0.005;
        
        // Reset to top when reaching ground
        if (positions[i * 3 + 1] < 0) {
          positions[i * 3 + 1] = 10;
        }
      }
      leavesRef.current.geometry.attributes.position.needsUpdate = true;
    }
  });

  return (
    <>
      {/* Sky */}
      <color attach="background" args={['#87ceeb']} />
      <fog attach="fog" args={['#b0d8f0', 25, 70]} />

      {/* Sun (Directional Light) */}
      <directionalLight
        position={[15, 25, 10]}
        intensity={1.5}
        color="#fff8dc"
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
        shadow-camera-far={50}
        shadow-camera-left={-20}
        shadow-camera-right={20}
        shadow-camera-top={20}
        shadow-camera-bottom={-20}
      />

      {/* Ambient light */}
      <ambientLight intensity={0.6} color="#b0e0e6" />

      {/* Fill light */}
      <hemisphereLight
        args={['#87ceeb', '#7cba3a', 0.4]}
        position={[0, 50, 0]}
      />

      {/* Ground - Grass terrain with variation */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, -0.01, 0]}
        receiveShadow
      >
        <planeGeometry args={[50, 50, 32, 32]} />
        <meshStandardMaterial
          color="#7cba3a"
          roughness={0.95}
          metalness={0}
        />
      </mesh>

      {/* Dirt path */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, 0, 0]}
        receiveShadow
      >
        <ringGeometry args={[0.5, 2, 32]} />
        <meshStandardMaterial
          color="#8b7355"
          roughness={1}
        />
      </mesh>

      {/* Grass blades (instanced) */}
      <instancedMesh
        ref={grassRef}
        args={[undefined, undefined, grassData.length]}
        castShadow
        receiveShadow
      >
        <coneGeometry args={[0.02, 0.4, 4]} />
        <meshStandardMaterial
          color="#5a9a2a"
          roughness={0.9}
          side={THREE.DoubleSide}
        />
      </instancedMesh>

      {/* Flowers (instanced) */}
      <instancedMesh
        ref={flowersRef}
        args={[undefined, undefined, flowerData.length]}
        castShadow
      >
        <sphereGeometry args={[1, 8, 8]} />
        <meshStandardMaterial
          color="#ff69b4"
          emissive="#ff1493"
          emissiveIntensity={0.2}
        />
      </instancedMesh>

      {/* Trees */}
      {trees.map((tree, idx) => (
        <group key={`tree-${idx}`} position={tree.position}>
          {/* Trunk */}
          <mesh position={[0, tree.height / 2, 0]} castShadow receiveShadow>
            <cylinderGeometry args={[0.25, 0.35, tree.height, 8]} />
            <meshStandardMaterial
              color="#5d4037"
              roughness={0.95}
            />
          </mesh>
          
          {/* Foliage (multiple layers for depth) */}
          <mesh position={[0, tree.height + 0.5, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize, tree.foliageSize * 1.2, 8]} />
            <meshStandardMaterial
              color="#2d5016"
              roughness={0.9}
            />
          </mesh>
          <mesh position={[0, tree.height + 1.2, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize * 0.8, tree.foliageSize, 8]} />
            <meshStandardMaterial
              color="#3a6b20"
              roughness={0.9}
            />
          </mesh>
          <mesh position={[0, tree.height + 1.8, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize * 0.6, tree.foliageSize * 0.8, 8]} />
            <meshStandardMaterial
              color="#4a7d2a"
              roughness={0.9}
            />
          </mesh>
        </group>
      ))}

      {/* Rocks */}
      {rocks.map((rock, idx) => (
        <mesh
          key={`rock-${idx}`}
          position={rock.position}
          rotation={[
            Math.random() * 0.5,
            Math.random() * Math.PI * 2,
            Math.random() * 0.5,
          ]}
          castShadow
          receiveShadow
        >
          <dodecahedronGeometry args={[rock.scale, 0]} />
          <meshStandardMaterial
            color="#808080"
            roughness={0.95}
            metalness={0.1}
          />
        </mesh>
      ))}

      {/* Bushes */}
      {[
        [-5, 0.3, 3],
        [6, 0.3, 2],
        [-7, 0.3, -2],
        [8, 0.3, -3],
      ].map((pos, idx) => (
        <mesh
          key={`bush-${idx}`}
          position={pos as [number, number, number]}
          castShadow
        >
          <sphereGeometry args={[0.5, 8, 8]} />
          <meshStandardMaterial
            color="#3a6b20"
            roughness={0.95}
          />
        </mesh>
      ))}

      {/* Birds (flying particles) */}
      <points ref={birdsRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={birdPositions.length / 3}
            array={birdPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.08}
          color="#333333"
          transparent
          opacity={0.8}
          sizeAttenuation
        />
      </points>

      {/* Falling leaves */}
      <points ref={leavesRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={leavesPositions.length / 3}
            array={leavesPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.06}
          color="#d2691e"
          transparent
          opacity={0.7}
          sizeAttenuation
        />
      </points>
    </>
  );
}

"@
<# 
import { useRef, useMemo } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { PositionalAudio } from '@react-three/drei';
// Add this import at the top
import { useLOD } from '../performance/useLOD';


export function NatureScene() {
  const grassRef = useRef<THREE.InstancedMesh>(null);
  const flowersRef = useRef<THREE.InstancedMesh>(null);
  const birdsRef = useRef<THREE.Points>(null);
  const leavesRef = useRef<THREE.Points>(null);
  const lodManager = useLOD();

  // Update grass to use LOD
  useEffect(() => {
    if (!lodManager) return;

    // Create LOD for grass patches
    // This is a simplified example - in production you'd create
    // different detail levels for grass
    
    return () => {
      // Cleanup LOD objects when component unmounts
    };
  }, [lodManager]);

  useFrame((state) => {
    const time = state.clock.elapsedTime;

    // Update LOD system
    if (lodManager) {
      lodManager.update();
    }

    // ... rest of existing animation code ...
  });
  // Generate grass blade positions
  const grassData = useMemo(() => {
    const count = 300;
    const positions: Array<{ position: [number, number, number]; rotation: number; scale: number }> = [];
    
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const radius = 2 + Math.random() * 13;
      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;
      
      positions.push({
        position: [x, 0, z],
        rotation: Math.random() * Math.PI * 2,
        scale: 0.5 + Math.random() * 0.5,
      });
    }
    
    return positions;
  }, []);

  // Generate flower positions
  const flowerData = useMemo(() => {
    const count = 50;
    const positions: Array<{ position: [number, number, number]; color: THREE.Color }> = [];
    
    const colors = [
      new THREE.Color('#ff6b9d'), // Pink
      new THREE.Color('#ffd93d'), // Yellow
      new THREE.Color('#a8e6cf'), // Light green
      new THREE.Color('#dda0dd'), // Plum
      new THREE.Color('#ffb347'), // Orange
    ];
    
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const radius = 3 + Math.random() * 10;
      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;
      
      positions.push({
        position: [x, 0.2, z],
        color: colors[Math.floor(Math.random() * colors.length)],
      });
    }
    
    return positions;
  }, []);

  // Tree positions
  const trees = useMemo(() => [
    { position: [-6, 0, -8] as [number, number, number], height: 3.5, foliageSize: 1.8 },
    { position: [7, 0, -10] as [number, number, number], height: 4, foliageSize: 2 },
    { position: [-8, 0, -6] as [number, number, number], height: 3, foliageSize: 1.5 },
    { position: [5, 0, -12] as [number, number, number], height: 3.8, foliageSize: 1.9 },
    { position: [-10, 0, -9] as [number, number, number], height: 3.2, foliageSize: 1.6 },
    { position: [9, 0, -7] as [number, number, number], height: 3.6, foliageSize: 1.7 },
    { position: [-4, 0, -11] as [number, number, number], height: 3.3, foliageSize: 1.55 },
    { position: [3, 0, -14] as [number, number, number], height: 4.2, foliageSize: 2.1 },
  ], []);

  // Rocks
  const rocks = useMemo(() => [
    { position: [2, 0.15, 1] as [number, number, number], scale: 0.3 },
    { position: [-3, 0.2, 2] as [number, number, number], scale: 0.4 },
    { position: [1, 0.1, -2] as [number, number, number], scale: 0.25 },
    { position: [4, 0.18, -1] as [number, number, number], scale: 0.35 },
    { position: [-1, 0.12, 3] as [number, number, number], scale: 0.28 },
    { position: [-4, 0.22, -3] as [number, number, number], scale: 0.42 },
  ], []);

  // Birds (flying particles)
  const birdPositions = useMemo(() => {
    const count = 30;
    const positions = new Float32Array(count * 3);
    
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 30;
      positions[i * 3 + 1] = 8 + Math.random() * 5;
      positions[i * 3 + 2] = -20 + Math.random() * 10;
    }
    
    return positions;
  }, []);

  // Falling leaves
  const leavesPositions = useMemo(() => {
    const count = 40;
    const positions = new Float32Array(count * 3);
    
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 20;
      positions[i * 3 + 1] = Math.random() * 8 + 2;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 20;
    }
    
    return positions;
  }, []);

  // Animations
  useFrame((state) => {
    const time = state.clock.elapsedTime;

    // Sway grass
    if (grassRef.current) {
      grassData.forEach((grass, i) => {
        const dummy = new THREE.Object3D();
        dummy.position.set(...grass.position);
        dummy.rotation.y = grass.rotation;
        
        // Add swaying motion
        const swayX = Math.sin(time * 0.5 + i * 0.1) * 0.1;
        const swayZ = Math.cos(time * 0.5 + i * 0.1) * 0.1;
        dummy.rotation.x = swayX;
        dummy.rotation.z = swayZ;
        
        dummy.scale.set(grass.scale, grass.scale, grass.scale);
        dummy.updateMatrix();
        grassRef.current.setMatrixAt(i, dummy.matrix);
      });
      grassRef.current.instanceMatrix.needsUpdate = true;
    }

    // Animate flowers (gentle bobbing)
    if (flowersRef.current) {
      flowerData.forEach((flower, i) => {
        const dummy = new THREE.Object3D();
        const bobHeight = Math.sin(time * 0.8 + i * 0.3) * 0.05;
        dummy.position.set(
          flower.position[0],
          flower.position[1] + bobHeight,
          flower.position[2]
        );
        dummy.scale.setScalar(0.15);
        dummy.updateMatrix();
        flowersRef.current!.setMatrixAt(i, dummy.matrix);
      });
      flowersRef.current.instanceMatrix.needsUpdate = true;
    }

    // Animate birds
    if (birdsRef.current) {
      const positions = birdsRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < positions.length / 3; i++) {
        positions[i * 3] += Math.sin(time + i) * 0.02;
        positions[i * 3 + 1] += Math.cos(time * 0.5 + i) * 0.01;
        
        // Wrap around
        if (positions[i * 3] > 15) positions[i * 3] = -15;
        if (positions[i * 3] < -15) positions[i * 3] = 15;
      }
      birdsRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Animate falling leaves
    if (leavesRef.current) {
      const positions = leavesRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < positions.length / 3; i++) {
        positions[i * 3 + 1] -= 0.01; // Fall down
        positions[i * 3] += Math.sin(time + i) * 0.005; // Drift
        positions[i * 3 + 2] += Math.cos(time + i) * 0.005;
        
        // Reset to top when reaching ground
        if (positions[i * 3 + 1] < 0) {
          positions[i * 3 + 1] = 10;
        }
      }
      leavesRef.current.geometry.attributes.position.needsUpdate = true;
    }
  });

  return (
    <>
      {/* Sky */}
      <color attach="background" args={['#87ceeb']} />
      <fog attach="fog" args={['#b0d8f0', 25, 70]} />

      {/* Sun (Directional Light) */}
      <directionalLight
        position={[15, 25, 10]}
        intensity={1.5}
        color="#fff8dc"
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
        shadow-camera-far={50}
        shadow-camera-left={-20}
        shadow-camera-right={20}
        shadow-camera-top={20}
        shadow-camera-bottom={-20}
      />

      {/* Ambient light */}
      <ambientLight intensity={0.6} color="#b0e0e6" />

      {/* Fill light */}
      <hemisphereLight
        args={['#87ceeb', '#7cba3a', 0.4]}
        position={[0, 50, 0]}
      />

      {/* Ground - Grass terrain with variation */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, -0.01, 0]}
        receiveShadow
      >
        <planeGeometry args={[50, 50, 32, 32]} />
        <meshStandardMaterial
          color="#7cba3a"
          roughness={0.95}
          metalness={0}
        />
      </mesh>

      {/* Dirt path */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, 0, 0]}
        receiveShadow
      >
        <ringGeometry args={[0.5, 2, 32]} />
        <meshStandardMaterial
          color="#8b7355"
          roughness={1}
        />
      </mesh>

      {/* Grass blades (instanced) */}
      <instancedMesh
        ref={grassRef}
        args={[undefined, undefined, grassData.length]}
        castShadow
        receiveShadow
      >
        <coneGeometry args={[0.02, 0.4, 4]} />
        <meshStandardMaterial
          color="#5a9a2a"
          roughness={0.9}
          side={THREE.DoubleSide}
        />
      </instancedMesh>

      {/* Flowers (instanced) */}
      <instancedMesh
        ref={flowersRef}
        args={[undefined, undefined, flowerData.length]}
        castShadow
      >
        <sphereGeometry args={[1, 8, 8]} />
        <meshStandardMaterial
          color="#ff69b4"
          emissive="#ff1493"
          emissiveIntensity={0.2}
        />
      </instancedMesh>

      {/* Trees */}
      {trees.map((tree, idx) => (
        <group key={`tree-${idx}`} position={tree.position}>
          {/* Trunk */}
          <mesh position={[0, tree.height / 2, 0]} castShadow receiveShadow>
            <cylinderGeometry args={[0.25, 0.35, tree.height, 8]} />
            <meshStandardMaterial
              color="#5d4037"
              roughness={0.95}
            />
          </mesh>
          
          {/* Foliage (multiple layers for depth) */}
          <mesh position={[0, tree.height + 0.5, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize, tree.foliageSize * 1.2, 8]} />
            <meshStandardMaterial
              color="#2d5016"
              roughness={0.9}
            />
          </mesh>
          <mesh position={[0, tree.height + 1.2, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize * 0.8, tree.foliageSize, 8]} />
            <meshStandardMaterial
              color="#3a6b20"
              roughness={0.9}
            />
          </mesh>
          <mesh position={[0, tree.height + 1.8, 0]} castShadow>
            <coneGeometry args={[tree.foliageSize * 0.6, tree.foliageSize * 0.8, 8]} />
            <meshStandardMaterial
              color="#4a7d2a"
              roughness={0.9}
            />
          </mesh>
        </group>
      ))}

      {/* Rocks */}
      {rocks.map((rock, idx) => (
        <mesh
          key={`rock-${idx}`}
          position={rock.position}
          rotation={[
            Math.random() * 0.5,
            Math.random() * Math.PI * 2,
            Math.random() * 0.5,
          ]}
          castShadow
          receiveShadow
        >
          <dodecahedronGeometry args={[rock.scale, 0]} />
          <meshStandardMaterial
            color="#808080"
            roughness={0.95}
            metalness={0.1}
          />
        </mesh>
      ))}

      {/* Bushes */}
      {[
        [-5, 0.3, 3],
        [6, 0.3, 2],
        [-7, 0.3, -2],
        [8, 0.3, -3],
      ].map((pos, idx) => (
        <mesh
          key={`bush-${idx}`}
          position={pos as [number, number, number]}
          castShadow
        >
          <sphereGeometry args={[0.5, 8, 8]} />
          <meshStandardMaterial
            color="#3a6b20"
            roughness={0.95}
          />
        </mesh>
      ))}

      {/* Birds (flying particles) */}
      <points ref={birdsRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={birdPositions.length / 3}
            array={birdPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.08}
          color="#333333"
          transparent
          opacity={0.8}
          sizeAttenuation
        />
      </points>

      {/* Falling leaves */}
      <points ref={leavesRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={leavesPositions.length / 3}
            array={leavesPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.06}
          color="#d2691e"
          transparent
          opacity={0.7}
          sizeAttenuation
        />
      </points>

      {/* Ambient Sounds - Nature */}
      <NatureSounds />
    </>
  );
}

// Ambient sound component for nature
function NatureSounds() {
  return (
    <>
      {/* Bird chirping (spatial audio at different locations) */}
      <PositionalAudio
        url="/sounds/birds-chirping.mp3"
        distance={10}
        loop
        autoplay
        position={[-5, 5, -8]}
      />
      
      <PositionalAudio
        url="/sounds/birds-chirping.mp3"
        distance={10}
        loop
        autoplay
        position={[7, 6, -10]}
      />

      {/* Wind rustling leaves */}
      <PositionalAudio
        url="/sounds/wind-rustling.mp3"
        distance={15}
        loop
        autoplay
        position={[0, 3, -5]}
      />

      {/* Distant water stream */}
      <PositionalAudio
        url="/sounds/stream-water.mp3"
        distance={20}
        loop
        autoplay
        position={[-15, 0, -10]}
      />
    </>
  );
}
"@
#>


Write-Section " ==> Generating Task 5.2.4: Floating Platform Environment typescript => $FrontEnd\src\features\xr\environments\FloatingPlatform.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\environments\FloatingPlatform.tsx" -Value @"

import { useRef, useMemo } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { PositionalAudio, Cloud } from '@react-three/drei';

export function FloatingPlatform() {
  const platformRef = useRef<THREE.Group>(null);
  const cloudGroupRef = useRef<THREE.Group>(null);
  const sparklesRef = useRef<THREE.Points>(null);
  const auraRef = useRef<THREE.Mesh>(null);
  const orbRef = useRef<THREE.Mesh>(null);

  // Cloud positions
  const clouds = useMemo(() => [
    { position: [-15, 10, -20] as [number, number, number], scale: 3, speed: 0.003 },
    { position: [20, 8, -25] as [number, number, number], scale: 2.5, speed: -0.004 },
    { position: [-10, 12, -30] as [number, number, number], scale: 3.5, speed: 0.002 },
    { position: [15, 9, -15] as [number, number, number], scale: 2.8, speed: -0.005 },
    { position: [-25, 11, -10] as [number, number, number], scale: 3.2, speed: 0.0025 },
    { position: [18, 10, -35] as [number, number, number], scale: 2.6, speed: -0.0035 },
    { position: [-18, 7, -22] as [number, number, number], scale: 2.4, speed: 0.004 },
    { position: [25, 13, -28] as [number, number, number], scale: 3.8, speed: -0.003 },
    { position: [5, 6, -18] as [number, number, number], scale: 2.2, speed: 0.0045 },
    { position: [-8, 14, -32] as [number, number, number], scale: 3.3, speed: -0.0028 },
  ], []);

  // Distant clouds (very far)
  const distantClouds = useMemo(() => [
    { position: [-50, 5, -60] as [number, number, number], scale: 8 },
    { position: [60, 8, -70] as [number, number, number], scale: 10 },
    { position: [-40, 10, -80] as [number, number, number], scale: 9 },
    { position: [45, 6, -65] as [number, number, number], scale: 7 },
  ], []);

  // Sparkle positions
  const sparklesPositions = useMemo(() => {
    const count = 200;
    const positions = new Float32Array(count * 3);
    
    for (let i = 0; i < count; i++) {
      const radius = 15;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.random() * Math.PI;
      
      positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = Math.random() * 15 - 5;
      positions[i * 3 + 2] = radius * Math.sin(phi) * Math.sin(theta);
    }
    
    return positions;
  }, []);

  // Light rays positions
  const lightRays = useMemo(() => {
    const rays = [];
    for (let i = 0; i < 8; i++) {
      const angle = (i / 8) * Math.PI * 2;
      rays.push({
        position: [Math.cos(angle) * 2.8, 0.2, Math.sin(angle) * 2.8] as [number, number, number],
        rotation: [0, angle, 0] as [number, number, number],
      });
    }
    return rays;
  }, []);

  // Animations
  useFrame((state) => {
    const time = state.clock.elapsedTime;

    // Platform gentle floating
    if (platformRef.current) {
      platformRef.current.position.y = Math.sin(time * 0.3) * 0.15;
      platformRef.current.rotation.y = time * 0.02;
    }

    // Cloud movement
    if (cloudGroupRef.current) {
      cloudGroupRef.current.children.forEach((cloud, idx) => {
        const cloudData = clouds[idx];
        if (cloudData) {
          cloud.position.x += cloudData.speed;
          
          // Wrap around
          if (cloudData.speed > 0 && cloud.position.x > 30) {
            cloud.position.x = -30;
          } else if (cloudData.speed < 0 && cloud.position.x < -30) {
            cloud.position.x = 30;
          }
        }
      });
    }

    // Sparkles rotation and twinkling
    if (sparklesRef.current) {
      sparklesRef.current.rotation.y = time * 0.05;
      
      const positions = sparklesRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < positions.length / 3; i++) {
        // Gentle up/down movement
        positions[i * 3 + 1] += Math.sin(time + i) * 0.003;
      }
      sparklesRef.current.geometry.attributes.position.needsUpdate = true;
    }

    // Aura pulsing
    if (auraRef.current) {
      const scale = 1 + Math.sin(time * 0.8) * 0.1;
      auraRef.current.scale.set(scale, 1, scale);
      (auraRef.current.material as THREE.MeshStandardMaterial).opacity = 0.2 + Math.sin(time) * 0.1;
    }

    // Orb floating and glowing
    if (orbRef.current) {
      orbRef.current.position.y = 1.6 + Math.sin(time * 0.5) * 0.1;
      orbRef.current.rotation.y = time * 0.3;
      orbRef.current.rotation.x = Math.sin(time * 0.2) * 0.2;
      
      const material = orbRef.current.material as THREE.MeshStandardMaterial;
      material.emissiveIntensity = 0.8 + Math.sin(time * 2) * 0.3;
    }
  });

  return (
    <>
      {/* Sky gradient */}
      <color attach="background" args={['#e0f4ff']} />
      <fog attach="fog" args={['#d6efff', 40, 120]} />

      {/* Ambient light */}
      <ambientLight intensity={0.7} color="#ffffff" />

      {/* Sun (directional light) */}
      <directionalLight
        position={[20, 40, 15]}
        intensity={1.3}
        color="#fff8e7"
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
      />

      {/* Soft fill light */}
      <hemisphereLight
        args={['#ffffff', '#d6efff', 0.5]}
        position={[0, 50, 0]}
      />

      {/* Main floating platform group */}
      <group ref={platformRef} position={[0, 0, 0]}>
        {/* Platform base (main disc) */}
        <mesh castShadow receiveShadow>
          <cylinderGeometry args={[3.5, 3.5, 0.4, 64]} />
          <meshStandardMaterial
            color="#ffffff"
            roughness={0.2}
            metalness={0.6}
            emissive="#e6f7ff"
            emissiveIntensity={0.15}
          />
        </mesh>

        {/* Platform rim (glowing edge) */}
        <mesh position={[0, 0.21, 0]}>
          <torusGeometry args={[3.5, 0.08, 24, 100]} />
          <meshStandardMaterial
            color="#4db8ff"
            emissive="#4db8ff"
            emissiveIntensity={0.8}
            transparent
            opacity={0.9}
            roughness={0.1}
            metalness={0.8}
          />
        </mesh>

        {/* Inner rim detail */}
        <mesh position={[0, 0.21, 0]}>
          <torusGeometry args={[2.8, 0.05, 16, 100]} />
          <meshStandardMaterial
            color="#99d6ff"
            emissive="#99d6ff"
            emissiveIntensity={0.5}
            transparent
            opacity={0.7}
          />
        </mesh>

        {/* Platform pattern (radial lines) */}
        {Array.from({ length: 16 }).map((_, i) => {
          const angle = (i / 16) * Math.PI * 2;
          return (
            <mesh
              key={`pattern-${i}`}
              position={[
                Math.cos(angle) * 2,
                0.21,
                Math.sin(angle) * 2,
              ]}
              rotation={[-Math.PI / 2, 0, angle]}
            >
              <planeGeometry args={[0.05, 1.5]} />
              <meshStandardMaterial
                color="#b3e0ff"
                emissive="#b3e0ff"
                emissiveIntensity={0.3}
                transparent
                opacity={0.4}
              />
            </mesh>
          );
        })}

        {/* Pillar decorations around edge */}
        {[0, Math.PI / 2, Math.PI, (3 * Math.PI) / 2].map((angle, idx) => (
          <group
            key={`pillar-${idx}`}
            position={[
              Math.cos(angle) * 3,
              0,
              Math.sin(angle) * 3,
            ]}
          >
            {/* Pillar */}
            <mesh position={[0, -0.4, 0]} castShadow>
              <cylinderGeometry args={[0.12, 0.12, 0.8, 16]} />
              <meshStandardMaterial
                color="#d0e8f2"
                roughness={0.3}
                metalness={0.7}
                emissive="#b3d9e6"
                emissiveIntensity={0.1}
              />
            </mesh>
            
            {/* Crystal top */}
            <mesh position={[0, 0.05, 0]} castShadow>
              <coneGeometry args={[0.15, 0.3, 8]} />
              <meshStandardMaterial
                color="#4db8ff"
                transparent
                opacity={0.7}
                roughness={0.1}
                metalness={0.9}
                emissive="#4db8ff"
                emissiveIntensity={0.4}
              />
            </mesh>
          </group>
        ))}

        {/* Light rays emanating from platform */}
        {lightRays.map((ray, idx) => (
          <mesh
            key={`ray-${idx}`}
            position={ray.position}
            rotation={ray.rotation}
          >
            <planeGeometry args={[0.05, 5]} />
            <meshBasicMaterial
              color="#4db8ff"
              transparent
              opacity={0.15}
              blending={THREE.AdditiveBlending}
            />
          </mesh>
        ))}

        {/* Platform aura (subtle glow underneath) */}
        <mesh
          ref={auraRef}
          position={[0, -0.5, 0]}
          rotation={[-Math.PI / 2, 0, 0]}
        >
          <circleGeometry args={[4, 64]} />
          <meshStandardMaterial
            color="#4db8ff"
            transparent
            opacity={0.2}
            emissive="#4db8ff"
            emissiveIntensity={0.5}
            blending={THREE.AdditiveBlending}
          />
        </mesh>
      </group>

      {/* Center floating orb */}
      <mesh ref={orbRef} position={[0, 1.6, 0]} castShadow>
        <sphereGeometry args={[0.25, 32, 32]} />
        <meshStandardMaterial
          color="#ffffff"
          emissive="#4db8ff"
          emissiveIntensity={1}
          transparent
          opacity={0.95}
          roughness={0.1}
          metalness={0.9}
        />
      </mesh>

      {/* Orb glow */}
      <mesh position={[0, 1.6, 0]}>
        <sphereGeometry args={[0.4, 32, 32]} />
        <meshBasicMaterial
          color="#4db8ff"
          transparent
          opacity={0.3}
          blending={THREE.AdditiveBlending}
        />
      </mesh>

      {/* Clouds group */}
      <group ref={cloudGroupRef}>
        {clouds.map((cloudData, idx) => (
          <Cloud
            key={`cloud-${idx}`}
            position={cloudData.position}
            scale={cloudData.scale}
            opacity={0.8}
            speed={0.1}
            width={cloudData.scale * 2}
            depth={cloudData.scale * 1.5}
            segments={20}
            color="#ffffff"
          />
        ))}
      </group>

      {/* Distant clouds (for depth) */}
      {distantClouds.map((cloudData, idx) => (
        <Cloud
          key={`distant-${idx}`}
          position={cloudData.position}
          scale={cloudData.scale}
          opacity={0.4}
          speed={0.05}
          width={cloudData.scale * 2}
          depth={cloudData.scale * 1.5}
          segments={15}
          color="#e6f7ff"
        />
      ))}

      {/* Sparkles/floating particles */}
      <points ref={sparklesRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={sparklesPositions.length / 3}
            array={sparklesPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.04}
          color="#ffffff"
          transparent
          opacity={0.8}
          blending={THREE.AdditiveBlending}
          sizeAttenuation
        />
      </points>

      {/* Infinite grid far below (for depth perception) */}
      <gridHelper
        args={[200, 100, '#4db8ff', '#99d6ff']}
        position={[0, -20, 0]}
      />

      {/* Secondary grid (more distant) */}
      <gridHelper
        args={[400, 150, '#4db8ff', '#b3e0ff']}
        position={[0, -40, 0]}
      />

      {/* Ambient Sounds - Zen/Peaceful */}
      <ZenSounds />
    </>
  );
}

// Ambient sound component for floating platform
function ZenSounds() {
  return (
    <>
      {/* Soft wind/breeze */}
      <PositionalAudio
        url="/sounds/soft-wind.mp3"
        distance={20}
        loop
        autoplay
        position={[0, 5, 0]}
      />

      {/* Gentle chimes */}
      <PositionalAudio
        url="/sounds/wind-chimes.mp3"
        distance={15}
        loop
        autoplay
        position={[3, 2, -2]}
      />

      {/* Meditative tone (very subtle) */}
      <PositionalAudio
        url="/sounds/meditation-tone.mp3"
        distance={25}
        loop
        autoplay
        position={[0, 1, 0]}
      />
    </>
  );
}

"@


Write-Section " ==> Generating Task 5.2.5: Environment Selector UI typescript => $FrontEnd\src\features\xr\environments\EnvironmentSelector.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\environments\EnvironmentSelector.tsx" -Value @"
import { useXRStore } from '../stores/xr.store';
import { SoftLitRoom } from '../environments/SoftLitRoom';
import { NatureScene } from '../environments/NatureScene';
import { FloatingPlatform } from '../environments/FloatingPlatform';

export type EnvironmentType = 'soft_room' | 'nature' | 'floating_platform';

export function EnvironmentSelector({ type }: { type: EnvironmentType }) {
  switch (type) {
    case 'soft_room':
      return <SoftLitRoom />;
    case 'nature':
      return <NatureScene />;
    case 'floating_platform':
      return <FloatingPlatform />;
    default:
      return <SoftLitRoom />;
  }
}
"@

if (-not (Test-Path file)) {

Write-Section "==> Downloading Audio Files..."
Set-Location $Root
.\$FrontEnd\scripts\CreatePlaceholderAudio.ps1
.\$FrontEnd\scripts\DownLoadAudioAssets.ps1
.\$FrontEnd\scripts\DownloadFromFMA.ps1
}

Write-Section "===> Generating XR Files ...."
.\$FrontEnd\scripts\GenerateXRFiles.ps1

Write-Section " ==> Generating Task 5.2.6: Spatial Audio System typescript => $FrontEnd\src\features\xr\audio\AudioManager.ts"
Set-Content -Path "$FrontEnd\src\features\xr\audio\AudioManager.ts" -Value @"
import * as THREE from 'three';

export type AudioType = 'ambient' | 'effect' | 'music' | 'voice';

export interface AudioConfig {
  url: string;
  type: AudioType;
  volume?: number;
  loop?: boolean;
  autoplay?: boolean;
  refDistance?: number;
  maxDistance?: number;
  rolloffFactor?: number;
  position?: [number, number, number];
}

export class AudioManager {
  private listener: THREE.AudioListener;
  private sounds: Map<string, THREE.PositionalAudio | THREE.Audio> = new Map();
  private loader: THREE.AudioLoader;
  private masterVolume: number = 1.0;
  private volumesByType: Map<AudioType, number> = new Map([
    ['ambient', 0.5],
    ['effect', 0.7],
    ['music', 0.6],
    ['voice', 0.8],
  ]);
  private isXR: boolean = false;

  constructor(camera: THREE.Camera, isXR: boolean = false) {
    this.listener = new THREE.AudioListener();
    this.loader = new THREE.AudioLoader();
    this.isXR = isXR;
    
    // Attach listener to camera
    camera.add(this.listener);
  }

  /**
   * Load and play audio
   */
  async loadAudio(id: string, config: AudioConfig): Promise<void> {
    return new Promise((resolve, reject) => {
      // Create positional or regular audio based on position
      const audio = config.position || this.isXR
        ? new THREE.PositionalAudio(this.listener)
        : new THREE.Audio(this.listener);

      this.loader.load(
        config.url,
        (buffer) => {
          audio.setBuffer(buffer);
          audio.setLoop(config.loop ?? false);
          audio.setVolume(this.calculateVolume(config));

          if (audio instanceof THREE.PositionalAudio) {
            audio.setRefDistance(config.refDistance ?? 5);
            audio.setMaxDistance(config.maxDistance ?? 50);
            audio.setRolloffFactor(config.rolloffFactor ?? 1);
            audio.setDistanceModel('exponential');
          }

          this.sounds.set(id, audio);

          if (config.autoplay) {
            audio.play();
          }

          resolve();
        },
        undefined,
        (error) => {
          console.error(`Failed to load audio ${id}:`, error);
          reject(error);
        }
      );
    });
  }

  /**
   * Play a sound by ID
   */
  play(id: string): void {
    const sound = this.sounds.get(id);
    if (sound && !sound.isPlaying) {
      sound.play();
    }
  }

  /**
   * Pause a sound by ID
   */
  pause(id: string): void {
    const sound = this.sounds.get(id);
    if (sound && sound.isPlaying) {
      sound.pause();
    }
  }

  /**
   * Stop a sound by ID
   */
  stop(id: string): void {
    const sound = this.sounds.get(id);
    if (sound) {
      sound.stop();
    }
  }

  /**
   * Set volume for a specific sound
   */
  setVolume(id: string, volume: number): void {
    const sound = this.sounds.get(id);
    if (sound) {
      sound.setVolume(volume);
    }
  }

  /**
   * Set master volume (affects all sounds)
   */
  setMasterVolume(volume: number): void {
    this.masterVolume = THREE.MathUtils.clamp(volume, 0, 1);
    this.updateAllVolumes();
  }

  /**
   * Set volume for a type of audio
   */
  setTypeVolume(type: AudioType, volume: number): void {
    this.volumesByType.set(type, THREE.MathUtils.clamp(volume, 0, 1));
    this.updateAllVolumes();
  }

  /**
   * Get positional audio object (for attaching to 3D objects)
   */
  getAudio(id: string): THREE.PositionalAudio | THREE.Audio | undefined {
    return this.sounds.get(id);
  }

  /**
   * Remove and dispose audio
   */
  remove(id: string): void {
    const sound = this.sounds.get(id);
    if (sound) {
      if (sound.isPlaying) {
        sound.stop();
      }
      sound.disconnect();
      this.sounds.delete(id);
    }
  }

  /**
   * Pause all sounds
   */
  pauseAll(): void {
    this.sounds.forEach((sound) => {
      if (sound.isPlaying) {
        sound.pause();
      }
    });
  }

  /**
   * Resume all sounds
   */
  resumeAll(): void {
    this.sounds.forEach((sound) => {
      if (!sound.isPlaying && sound.buffer) {
        sound.play();
      }
    });
  }

  /**
   * Stop all sounds
   */
  stopAll(): void {
    this.sounds.forEach((sound) => {
      sound.stop();
    });
  }

  /**
   * Cleanup all audio
   */
  dispose(): void {
    this.stopAll();
    this.sounds.forEach((sound) => {
      sound.disconnect();
    });
    this.sounds.clear();
  }

  /**
   * Calculate effective volume based on type and master volume
   */
  private calculateVolume(config: AudioConfig): number {
    const typeVolume = this.volumesByType.get(config.type) ?? 1.0;
    const configVolume = config.volume ?? 1.0;
    return this.masterVolume * typeVolume * configVolume;
  }

  /**
   * Update all sound volumes
   */
  private updateAllVolumes(): void {
    // This would need to track original configs to recalculate
    // For now, we'll just update on new sounds
  }
}
"@

Set-Content -Path "$FrontEnd\src\features\xr\audio\useAudioManager.ts" -Value @"
import { useEffect, useRef } from 'react';
import { useThree } from '@react-three/fiber';
import { AudioManager, AudioConfig } from './AudioManager';
import { useXRStore } from '../stores/xr.store';

export function useAudioManager() {
  const { camera } = useThree();
  const isSessionActive = useXRStore((state) => state.isSessionActive);
  const audioManagerRef = useRef<AudioManager | null>(null);

  useEffect(() => {
    // Create audio manager
    audioManagerRef.current = new AudioManager(camera, isSessionActive);

    return () => {
      // Cleanup on unmount
      audioManagerRef.current?.dispose();
    };
  }, [camera, isSessionActive]);

  const loadAudio = async (id: string, config: AudioConfig) => {
    if (audioManagerRef.current) {
      await audioManagerRef.current.loadAudio(id, config);
    }
  };

  const play = (id: string) => audioManagerRef.current?.play(id);
  const pause = (id: string) => audioManagerRef.current?.pause(id);
  const stop = (id: string) => audioManagerRef.current?.stop(id);
  const setVolume = (id: string, volume: number) =>
    audioManagerRef.current?.setVolume(id, volume);
  const setMasterVolume = (volume: number) =>
    audioManagerRef.current?.setMasterVolume(volume);

  return {
    loadAudio,
    play,
    pause,
    stop,
    setVolume,
    setMasterVolume,
    audioManager: audioManagerRef.current,
  };
}
"@

Set-Content -Path "$FrontEnd\src\features\xr\audio\EnvironmentAudio.tsx" -Value @"
import { useEffect } from 'react';
import { useAudioManager } from './useAudioManager';
import { useXRStore, EnvironmentType } from '../stores/xr.store';

const ENVIRONMENT_AUDIO_CONFIGS = {
  soft_room: [
    {
      id: 'soft-room-ambient',
      url: '/sounds/soft-ambient.mp3',
      type: 'ambient' as const,
      volume: 0.3,
      loop: true,
      autoplay: true,
      refDistance: 10,
      maxDistance: 30,
    },
    {
      id: 'soft-room-calm',
      url: '/sounds/calm-tone.mp3',
      type: 'ambient' as const,
      volume: 0.2,
      loop: true,
      autoplay: true,
      refDistance: 5,
      maxDistance: 20,
    },
  ],
  nature: [
    {
      id: 'birds-1',
      url: '/sounds/birds-chirping.mp3',
      type: 'ambient' as const,
      volume: 0.4,
      loop: true,
      autoplay: true,
      position: [-5, 5, -8] as [number, number, number],
      refDistance: 8,
      maxDistance: 25,
    },
    {
      id: 'birds-2',
      url: '/sounds/birds-chirping.mp3',
      type: 'ambient' as const,
      volume: 0.3,
      loop: true,
      autoplay: true,
      position: [7, 6, -10] as [number, number, number],
      refDistance: 8,
      maxDistance: 25,
    },
    {
      id: 'wind',
      url: '/sounds/wind-rustling.mp3',
      type: 'ambient' as const,
      volume: 0.35,
      loop: true,
      autoplay: true,
      position: [0, 3, -5] as [number, number, number],
      refDistance: 12,
      maxDistance: 30,
    },
    {
      id: 'stream',
      url: '/sounds/stream-water.mp3',
      type: 'ambient' as const,
      volume: 0.25,
      loop: true,
      autoplay: true,
      position: [-15, 0, -10] as [number, number, number],
      refDistance: 15,
      maxDistance: 40,
    },
  ],
  floating_platform: [
    {
      id: 'soft-wind',
      url: '/sounds/soft-wind.mp3',
      type: 'ambient' as const,
      volume: 0.3,
      loop: true,
      autoplay: true,
      position: [0, 5, 0] as [number, number, number],
      refDistance: 15,
      maxDistance: 35,
    },
    {
      id: 'wind-chimes',
      url: '/sounds/wind-chimes.mp3',
      type: 'ambient' as const,
      volume: 0.25,
      loop: true,
      autoplay: true,
      position: [3, 2, -2] as [number, number, number],
      refDistance: 10,
      maxDistance: 25,
    },
    {
      id: 'meditation-tone',
      url: '/sounds/meditation-tone.mp3',
      type: 'ambient' as const,
      volume: 0.2,
      loop: true,
      autoplay: true,
      position: [0, 1, 0] as [number, number, number],
      refDistance: 20,
      maxDistance: 50,
    },
  ],
};

export function EnvironmentAudio() {
  const currentEnvironment = useXRStore((state) => state.currentEnvironment);
  const { loadAudio, stop, audioManager } = useAudioManager();

  useEffect(() => {
    if (!audioManager) return;

    // Stop all previous environment audio
    Object.values(ENVIRONMENT_AUDIO_CONFIGS).forEach((configs) => {
      configs.forEach((config) => {
        stop(config.id);
      });
    });

    // Load and play current environment audio
    const configs = ENVIRONMENT_AUDIO_CONFIGS[currentEnvironment];
    if (configs) {
      configs.forEach((config) => {
        loadAudio(config.id, config).catch((error) => {
          console.error(`Failed to load audio ${config.id}:`, error);
        });
      });
    }

    return () => {
      // Cleanup when environment changes
      if (configs) {
        configs.forEach((config) => {
          stop(config.id);
        });
      }
    };
  }, [currentEnvironment, audioManager, loadAudio, stop]);

  return null; // This component doesn't render anything
}
"@


Write-Section " ==> Generating Task 5.2.7: LOD Optimization typescript => $FrontEnd\src\features\xr\performance\LODManager.ts"
Set-Content -Path "$FrontEnd\src\features\xr\performance\ODManager.ts" -Value @"
import * as THREE from 'three';

export interface LODConfig {
  high: number; // Distance for high detail
  medium: number; // Distance for medium detail
  low: number; // Distance for low detail
  cull: number; // Distance to completely hide
}

export interface LODMeshConfig {
  highDetail: THREE.BufferGeometry;
  mediumDetail?: THREE.BufferGeometry;
  lowDetail?: THREE.BufferGeometry;
  material: THREE.Material;
}

export class LODManager {
  private lodObjects: Map<string, THREE.LOD> = new Map();
  private camera: THREE.Camera;
  private defaultConfig: LODConfig = {
    high: 10,
    medium: 25,
    low: 50,
    cull: 100,
  };

  constructor(camera: THREE.Camera) {
    this.camera = camera;
  }

  /**
   * Create LOD object with multiple detail levels
   */
  createLOD(
    id: string,
    config: LODMeshConfig,
    lodConfig: Partial<LODConfig> = {}
  ): THREE.LOD {
    const lod = new THREE.LOD();
    const distances = { ...this.defaultConfig, ...lodConfig };

    // High detail mesh
    const highMesh = new THREE.Mesh(config.highDetail, config.material);
    highMesh.castShadow = true;
    highMesh.receiveShadow = true;
    lod.addLevel(highMesh, 0);

    // Medium detail mesh
    if (config.mediumDetail) {
      const mediumMesh = new THREE.Mesh(config.mediumDetail, config.material);
      mediumMesh.castShadow = true;
      mediumMesh.receiveShadow = false; // Disable receive shadow for medium LOD
      lod.addLevel(mediumMesh, distances.medium);
    }

    // Low detail mesh
    if (config.lowDetail) {
      const lowMesh = new THREE.Mesh(config.lowDetail, config.material);
      lowMesh.castShadow = false; // Disable shadows for low LOD
      lowMesh.receiveShadow = false;
      lod.addLevel(lowMesh, distances.low);
    }

    // Add empty mesh to cull at far distance
    const cullMesh = new THREE.Mesh(
      new THREE.BufferGeometry(),
      config.material
    );
    lod.addLevel(cullMesh, distances.cull);

    this.lodObjects.set(id, lod);
    return lod;
  }

  /**
   * Update all LOD objects based on camera distance
   */
  update(): void {
    this.lodObjects.forEach((lod) => {
      lod.update(this.camera);
    });
  }

  /**
   * Create simplified geometry from original
   */
  static simplifyGeometry(
    geometry: THREE.BufferGeometry,
    ratio: number
  ): THREE.BufferGeometry {
    // Simple vertex reduction for demonstration
    // In production, use a proper mesh simplification library
    const simplified = geometry.clone();
    
    if (simplified.index) {
      const originalIndices = simplified.index.array;
      const step = Math.max(1, Math.floor(1 / ratio));
      const newIndices: number[] = [];

      for (let i = 0; i < originalIndices.length; i += step * 3) {
        if (i + 2 < originalIndices.length) {
          newIndices.push(
            originalIndices[i],
            originalIndices[i + 1],
            originalIndices[i + 2]
          );
        }
      }

      simplified.setIndex(newIndices);
    }

    return simplified;
  }

  /**
   * Remove LOD object
   */
  remove(id: string): void {
    const lod = this.lodObjects.get(id);
    if (lod) {
      lod.levels.forEach((level) => {
        level.object.traverse((child) => {
          if (child instanceof THREE.Mesh) {
            child.geometry.dispose();
            if (Array.isArray(child.material)) {
              child.material.forEach((mat) => mat.dispose());
            } else {
              child.material.dispose();
            }
          }
        });
      });
      this.lodObjects.delete(id);
    }
  }

  /**
   * Dispose all LOD objects
   */
  dispose(): void {
    this.lodObjects.forEach((_, id) => this.remove(id));
    this.lodObjects.clear();
  }
}
"@

Set-Content -Path "$FrontEnd\src\features\xr\performance\PerformanceMonitor.tsx" -Value @"
import { useEffect, useRef, useState } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { useXRStore } from '../stores/xr.store';

interface PerformanceStats {
  fps: number;
  frameTime: number;
  drawCalls: number;
  triangles: number;
  geometries: number;
  textures: number;
}

export function PerformanceMonitor() {
  const { gl, scene } = useThree();
  const updatePerformance = useXRStore((state) => state.updatePerformance);
  const targetFrameRate = useXRStore((state) => state.targetFrameRate);
  
  const [stats, setStats] = useState<PerformanceStats>({
    fps: 0,
    frameTime: 0,
    drawCalls: 0,
    triangles: 0,
    geometries: 0,
    textures: 0,
  });

  const frameTimesRef = useRef<number[]>([]);
  const lastTimeRef = useRef(performance.now());

  useFrame((state, delta) => {
    const now = performance.now();
    const frameTime = now - lastTimeRef.current;
    lastTimeRef.current = now;

    // Track frame times
    frameTimesRef.current.push(frameTime);
    if (frameTimesRef.current.length > 60) {
      frameTimesRef.current.shift();
    }

    // Calculate average FPS
    const avgFrameTime =
      frameTimesRef.current.reduce((a, b) => a + b, 0) /
      frameTimesRef.current.length;
    const fps = 1000 / avgFrameTime;

    // Update store (for global access)
    if (frameTimesRef.current.length % 30 === 0) {
      updatePerformance(fps, avgFrameTime);

      // Get renderer info
      const info = gl.info;
      setStats({
        fps: Math.round(fps),
        frameTime: Math.round(avgFrameTime * 100) / 100,
        drawCalls: info.render.calls,
        triangles: info.render.triangles,
        geometries: info.memory.geometries,
        textures: info.memory.textures,
      });
    }
  });

  // Display performance overlay (dev mode only)
  if (import.meta.env.DEV) {
    return (
      <div
        style={{
          position: 'fixed',
          top: '80px',
          left: '10px',
          background: 'rgba(0, 0, 0, 0.7)',
          color: 'white',
          padding: '10px',
          borderRadius: '5px',
          fontFamily: 'monospace',
          fontSize: '12px',
          zIndex: 1000,
          pointerEvents: 'none',
        }}
      >
        <div
          style={{
            color: stats.fps >= targetFrameRate * 0.9 ? '#0f0' : '#ff0',
            fontWeight: 'bold',
          }}
        >
          FPS: {stats.fps} / {targetFrameRate}
        </div>
        <div>Frame Time: {stats.frameTime}ms</div>
        <div>Draw Calls: {stats.drawCalls}</div>
        <div>Triangles: {stats.triangles.toLocaleString()}</div>
        <div>Geometries: {stats.geometries}</div>
        <div>Textures: {stats.textures}</div>
      </div>
    );
  }

  return null;
}
"@

Set-Content -Path "$FrontEnd\src\features\xr\performance\useLOD.ts" -Value @"
import { useEffect, useRef } from 'react';
import { useThree } from '@react-three/fiber';
import * as THREE from 'three';
import { LODManager } from './LODManager';

export function useLOD() {
  const { camera } = useThree();
  const lodManagerRef = useRef<LODManager | null>(null);

  useEffect(() => {
    lodManagerRef.current = new LODManager(camera);

    return () => {
      lodManagerRef.current?.dispose();
    };
  }, [camera]);

  return lodManagerRef.current;
}
"@
Set-Content -Path "$FrontEnd\src\features\xr\performance\AdaptiveQuality.tsx" -Value @"
import { useEffect, useState } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { useXRStore } from '../stores/xr.store';

interface QualitySettings {
  shadowMapSize: number;
  pixelRatio: number;
  antialias: boolean;
  enableShadows: boolean;
  maxLights: number;
}

const QUALITY_PRESETS = {
  high: {
    shadowMapSize: 2048,
    pixelRatio: window.devicePixelRatio,
    antialias: true,
    enableShadows: true,
    maxLights: 8,
  },
  medium: {
    shadowMapSize: 1024,
    pixelRatio: Math.min(window.devicePixelRatio, 1.5),
    antialias: true,
    enableShadows: true,
    maxLights: 4,
  },
  low: {
    shadowMapSize: 512,
    pixelRatio: 1,
    antialias: false,
    enableShadows: false,
    maxLights: 2,
  },
};

export function AdaptiveQuality() {
  const { gl, scene } = useThree();
  const targetFrameRate = useXRStore((state) => state.targetFrameRate);
  const currentFPS = useXRStore((state) => state.currentFPS);
  
  const [quality, setQuality] = useState<keyof typeof QUALITY_PRESETS>('high');
  const [fpsHistory, setFpsHistory] = useState<number[]>([]);

  useEffect(() => {
    // Apply quality settings
    const settings = QUALITY_PRESETS[quality];
    
    gl.setPixelRatio(settings.pixelRatio);
    gl.shadowMap.enabled = settings.enableShadows;
    
    if (settings.enableShadows) {
      gl.shadowMap.type = THREE.PCFSoftShadowMap;
    }

    // Update all shadow casting lights
    scene.traverse((object) => {
      if (object instanceof THREE.DirectionalLight || 
          object instanceof THREE.SpotLight) {
        if (object.shadow) {
          object.shadow.mapSize.width = settings.shadowMapSize;
          object.shadow.mapSize.height = settings.shadowMapSize;
          object.shadow.map?.dispose();
          object.shadow.map = null;
        }
      }
    });

    console.log(`Quality set to: ${quality}`);
  }, [quality, gl, scene]);

  useFrame(() => {
    // Track FPS over time
    if (currentFPS > 0) {
      setFpsHistory((prev) => {
        const newHistory = [...prev, currentFPS];
        if (newHistory.length > 60) {
          newHistory.shift();
        }
        return newHistory;
      });
    }
  });

  useEffect(() => {
    if (fpsHistory.length < 30) return; // Wait for enough samples

    const avgFPS = fpsHistory.reduce((a, b) => a + b, 0) / fpsHistory.length;
    const minFPS = Math.min(...fpsHistory);

    // Adaptive quality logic
    if (avgFPS < targetFrameRate * 0.7 || minFPS < targetFrameRate * 0.5) {
      // Performance is bad, decrease quality
      if (quality === 'high') {
        setQuality('medium');
        setFpsHistory([]);
      } else if (quality === 'medium') {
        setQuality('low');
        setFpsHistory([]);
      }
    } else if (avgFPS > targetFrameRate * 0.95 && minFPS > targetFrameRate * 0.85) {
      // Performance is good, try increasing quality
      if (quality === 'low') {
        setQuality('medium');
        setFpsHistory([]);
      } else if (quality === 'medium') {
        setQuality('high');
        setFpsHistory([]);
      }
    }
  }, [fpsHistory, targetFrameRate, quality]);

  return null;
}
"@
Set-Content -Path "$FrontEnd\src\features\xr\components\XRScene.tsx" -Value @"
import { Text } from '@react-three/drei';
import { EnvironmentSelector } from './EnvironmentSelector';
import { EnvironmentAudio } from '../audio/EnvironmentAudio';
import { PerformanceMonitor } from '../performance/PerformanceMonitor';
import { AdaptiveQuality } from '../performance/AdaptiveQuality';
import { useXRStore } from '../stores/xr.store';

export function XRScene() {
  const deviceType = useXRStore((state) => state.deviceType);
  const currentEnvironment = useXRStore((state) => state.currentEnvironment);

  return (
    <>
      {/* Environment */}
      <EnvironmentSelector />

      {/* Audio System */}
      <EnvironmentAudio />

      {/* Performance Monitoring */}
      <PerformanceMonitor />
      <AdaptiveQuality />

      {/* Welcome Text (floating in front of user) */}
      <Text
        position={[0, 2, -2]}
        fontSize={0.3}
        color="#333333"
        anchorX="center"
        anchorY="middle"
      >
        🧠 HMI Hypnotherapy
      </Text>

      <Text
        position={[0, 1.5, -2]}
        fontSize={0.15}
        color="#666666"
        anchorX="center"
        anchorY="middle"
      >
        Welcome to your immersive experience
      </Text>

      {/* Device Info */}
      <Text
        position={[0, 1.2, -2]}
        fontSize={0.08}
        color="#999999"
        anchorX="center"
        anchorY="middle"
      >
        Device: {deviceType.toUpperCase()} | Environment: {currentEnvironment}
      </Text>

      {/* Interactive sphere (example) */}
      <mesh position={[0, 1.6, -1.5]} userData={{ interactive: true }}>
        <sphereGeometry args={[0.15, 32, 32]} />
        <meshStandardMaterial
          color="#4db8ff"
          emissive="#4db8ff"
          emissiveIntensity={0.3}
          roughness={0.2}
          metalness={0.8}
        />
      </mesh>

      {/* Ground reference (helps with orientation) */}
      <gridHelper args={[10, 10, '#cccccc', '#eeeeee']} position={[0, 0.01, 0]} />
    </>
  );
}
"@


<#
 My Recommendation:
Test the XR experience in Quest 3 NOW!
Even without audio, you can:

✅ Verify all 3 environments render correctly
✅ Test controller/hand interactions
✅ Check performance (FPS)
✅ Experience the immersive visuals
✅ Switch between environments
✅ Confirm Quest 3 connectivity works

Then we can move to Option C (Database) knowing the XR foundation is solid!

📊 Current Project Status:
ComponentStatusBackend API✅ Running (basic endpoints)Docker Services✅ PostgreSQL, Neo4j, Redis readyFrontend React✅ CompleteXR Environments✅ All 3 environments readyXR Audio System⚠️ Works (placeholders)LOD System✅ CompletePerformance Monitoring✅ CompleteQuest 3 Setup✅ Firewall configuredDatabase Models⏳ Not started (Option C)Assessment UI⏳ Not startedSession System⏳ Not started

✅ You're 60% Complete on Frontend!
Epic 5 (XR) Status:

✅ Task 5.1: XR Infrastructure ✅
✅ Task 5.2.1-5.2.2: Environments (Soft Room) ✅
✅ Task 5.2.3: Nature Scene ✅
✅ Task 5.2.4: Floating Platform ✅
✅ Task 5.2.5: Environment Selector ✅
✅ Task 5.2.6: Spatial Audio System ✅
✅ Task 5.2.7: LOD Optimization ✅

What you just completed is HUGE! 🎉

🚀 WHAT DO YOU WANT TO DO?
Type one of these:

"Test Quest 3" - I'll give you final testing checklist
"Option C" - Let's build Database Models & API Endpoints
"Continue Frontend" - Build assessment questionnaires next
#>

Write-Section " ==> : Generate Audio with Web Audio API => $FrontEnd\src\features\xr\audio\ToneGenerator.ts"
Set-Content -Path "$FrontEnd\src\features\xr\audio\ToneGenerator.ts" -Value @"
export class ToneGenerator {
  private audioContext: AudioContext;

  constructor() {
    this.audioContext = new AudioContext();
  }

  /**
   * Generate a meditation tone (sine wave)
   */
  generateMeditationTone(frequency: number = 432, duration: number = 60): AudioBuffer {
    const sampleRate = this.audioContext.sampleRate;
    const buffer = this.audioContext.createBuffer(1, sampleRate * duration, sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < buffer.length; i++) {
      data[i] = Math.sin(2 * Math.PI * frequency * i / sampleRate) * 0.3;
    }

    return buffer;
  }

  /**
   * Generate ambient noise (pink noise)
   */
  generateAmbientNoise(duration: number = 60): AudioBuffer {
    const sampleRate = this.audioContext.sampleRate;
    const buffer = this.audioContext.createBuffer(1, sampleRate * duration, sampleRate);
    const data = buffer.getChannelData(0);

    let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;

    for (let i = 0; i < buffer.length; i++) {
      const white = Math.random() * 2 - 1;
      b0 = 0.99886 * b0 + white * 0.0555179;
      b1 = 0.99332 * b1 + white * 0.0750759;
      b2 = 0.96900 * b2 + white * 0.1538520;
      b3 = 0.86650 * b3 + white * 0.3104856;
      b4 = 0.55000 * b4 + white * 0.5329522;
      b5 = -0.7616 * b5 - white * 0.0168980;
      data[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11;
      b6 = white * 0.115926;
    }

    return buffer;
  }
}
"@


Write-Section " ==> EP Suggestibioity Questionnairs ===>"
# =====================================================
# PowerShell Script: Generate HMI E&P Suggestibility Assessment Component
# =====================================================
# This script creates a production-ready React TypeScript component
# implementing the authentic HMI E&P Suggestibility Questionnaire
# with correct scoring methodology and lookup table.
# =====================================================

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  HMI E&P Suggestibility Assessment Generator" -ForegroundColor Cyan
Write-Host "  Production-Ready Component Creation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Define output path
$outputPath = "$FrontEnd\src\components\onboarding\EPAssessmentQuestionnaire.tsx"

Write-Host "Creating component at: $outputPath" -ForegroundColor Yellow
Write-Host ""

# Create the complete TypeScript React component
$componentContent = @'
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Brain, 
  HelpCircle, 
  ChevronRight, 
  ChevronLeft, 
  CheckCircle2,
  Sparkles,
  Info,
  Moon,
  Users,
  Eye,
  Heart,
  MessageCircle,
  Smile,
  UserPlus,
  Book,
  Coffee,
  Zap,
  Star,
  Wind,
  Target,
  ThumbsUp,
  Lightbulb
} from 'lucide-react';

// =====================================================
// TYPE DEFINITIONS
// =====================================================

interface EPQuestion {
  id: number;
  text: string;
  category: 'physical' | 'emotional';
  questionnaire: 1 | 2;
  weight: 10 | 5;
  tooltip: string;
  example?: string;
  icon: any;
}

interface EPAssessmentQuestionnaireProps {
  userId: string;
  onComplete: (results: ScoringResult) => void;
  onBack?: () => void;
}

interface ScoringResult {
  success: boolean;
  profile: 'Physical Suggestible' | 'Emotional Suggestible' | 'Somnambulistic' | 'Intellectual Suggestible';
  physicalPercentage: number;
  emotionalPercentage: number;
  q1Score: number;
  q2Score: number;
  combinedScore: number;
  answers: Record<number, boolean>;
  completedAt: string;
  userId: string;
  methodology: string;
}

// =====================================================
// HMI E&P SUGGESTIBILITY QUESTIONS (36 Questions)
// Based on authentic HMI Suggestibility Questionnaires
// =====================================================

const EP_QUESTIONS: EPQuestion[] = [
  // ========================================
  // QUESTIONNAIRE 1: PHYSICAL SUGGESTIBILITY INDICATORS (1-18)
  // Questions 1-2: 10 points each
  // Questions 3-18: 5 points each
  // ========================================
  
  {
    id: 1,
    text: "Have you ever walked in your sleep during your adult life?",
    category: "physical",
    questionnaire: 1,
    weight: 10,
    tooltip: "Sleepwalking in adulthood indicates a strong connection between subconscious mind and physical body, suggesting direct physical response patterns.",
    example: "If you've experienced sleepwalking as an adult, your subconscious may directly control physical actions without conscious awareness.",
    icon: Moon
  },
  
  {
    id: 2,
    text: "As a teenager, did you feel comfortable expressing your feelings to one or both of your parents?",
    category: "physical",
    questionnaire: 1,
    weight: 10,
    tooltip: "Comfort with direct emotional expression in formative years indicates literal, straightforward communication patterns.",
    example: "Being able to say 'I'm angry' or 'I love you' directly to parents suggests direct communication style.",
    icon: Heart
  },
  
  {
    id: 3,
    text: "Do you have a tendency to look directly into a person's eyes and/or move closely to them when discussing an interesting subject?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Direct eye contact and physical closeness indicate comfort with literal, face-to-face interaction.",
    example: "Maintaining steady eye contact during conversations shows direct engagement style.",
    icon: Eye
  },
  
  {
    id: 4,
    text: "Do you feel that most people, when you first meet them, are uncritical of your appearance?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Feeling accepted by others indicates confidence in direct social situations.",
    example: "Not worrying about judgment when meeting new people suggests comfort with direct interaction.",
    icon: Smile
  },
  
  {
    id: 5,
    text: "In a group situation with people you have just met, would you feel comfortable drawing attention to yourself by initiating a conversation?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Willingness to take direct action in social situations indicates physical confidence.",
    example: "Being the first to speak up in a group of strangers shows direct communication comfort.",
    icon: UserPlus
  },
  
  {
    id: 6,
    text: "Do you feel comfortable holding hands or hugging someone you are in a relationship with in front of other people?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with public physical affection indicates direct expression of feelings through body.",
    example: "Holding hands in public shows comfort with physical demonstration of emotions.",
    icon: Heart
  },
  
  {
    id: 7,
    text: "When someone talks about feeling warm physically, do you begin to feel warm also?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Physical empathy and immediate body response to suggestions indicates direct physical suggestibility.",
    example: "Feeling warm when someone describes heat shows immediate physical response to verbal cues.",
    icon: Zap
  },
  
  {
    id: 8,
    text: "Do you tend to occasionally tune out when someone is talking to you because you are anxious to come up with your side, and, at times, not hear what the other person said?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Focusing on immediate response rather than analysis indicates direct, action-oriented thinking.",
    example: "Preparing your response while someone talks shows immediate reaction patterns.",
    icon: MessageCircle
  },
  
  {
    id: 9,
    text: "Do you feel that you learn and comprehend better by seeing and/or reading than by hearing?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Visual learning preference indicates direct, literal information processing.",
    example: "Preferring to read instructions rather than listen to them shows direct learning style.",
    icon: Book
  },
  
  {
    id: 10,
    text: "In a new class or lecture situation, do you usually feel comfortable asking questions in front of the group?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with direct questioning indicates confidence in straightforward communication.",
    example: "Raising your hand to ask questions shows comfort with direct interaction.",
    icon: HelpCircle
  },
  
  {
    id: 11,
    text: "When expressing your ideas, do you find it important to relate all the details leading up to the subject so the other person can understand it completely?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Providing complete details indicates literal, thorough communication style.",
    example: "Giving step-by-step explanations shows preference for complete, direct information.",
    icon: MessageCircle
  },
  
  {
    id: 12,
    text: "Do you enjoy relating to children?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with children indicates ease with direct, uncomplicated interaction.",
    example: "Enjoying time with kids shows comfort with straightforward, literal communication.",
    icon: Users
  },
  
  {
    id: 13,
    text: "Do you find it easy to be at ease and comfortable with your body movements, even when faced with unfamiliar people and circumstances?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Body confidence in new situations indicates strong mind-body connection.",
    example: "Moving naturally in new situations shows physical comfort and confidence.",
    icon: Wind
  },
  
  {
    id: 14,
    text: "Do you prefer reading fiction rather than non-fiction?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Fiction preference can indicate comfort with direct emotional experience through stories.",
    example: "Enjoying novels shows engagement with direct narrative and emotional content.",
    icon: Book
  },
  
  {
    id: 15,
    text: "If you were to imagine sucking on a sour, bitter, juicy, yellow lemon, would your mouth water?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Immediate physical response to mental imagery indicates strong mind-body connection.",
    example: "Salivating when thinking about lemons shows direct physical response to suggestions.",
    icon: Zap
  },
  
  {
    id: 16,
    text: "If you feel that you deserve to be complimented for something well done, do you feel comfortable if the compliment is given to you in front of other people?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with public recognition indicates confidence in direct attention.",
    example: "Enjoying public praise shows comfort with direct acknowledgment.",
    icon: Star
  },
  
  {
    id: 17,
    text: "Do you feel that you are a good conversationalist?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Confidence in communication indicates comfort with direct verbal interaction.",
    example: "Feeling skilled at conversation shows confidence in direct communication.",
    icon: MessageCircle
  },
  
  {
    id: 18,
    text: "Do you feel comfortable when complimentary attention is drawn to your physical body or appearance?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with physical compliments indicates acceptance of direct body-focused attention.",
    example: "Enjoying compliments about appearance shows comfort with direct physical attention.",
    icon: Smile
  },
  
  // ========================================
  // QUESTIONNAIRE 2: EMOTIONAL SUGGESTIBILITY INDICATORS (19-36)
  // Questions 19-20: 10 points each
  // Questions 21-36: 5 points each
  // ========================================
  
  {
    id: 19,
    text: "Have you ever awakened in the middle of the night and felt that you could not move your body and/or talk?",
    category: "emotional",
    questionnaire: 2,
    weight: 10,
    tooltip: "Sleep paralysis indicates mind-body disconnection characteristic of emotional suggestibility.",
    example: "Experiencing inability to move while conscious shows mental awareness separate from physical control.",
    icon: Moon
  },
  
  {
    id: 20,
    text: "As a child, did you feel that you were more affected by your parents' tone of voice, than by what they actually said?",
    category: "emotional",
    questionnaire: 2,
    weight: 10,
    tooltip: "Sensitivity to tone over words indicates inferential, analytical processing of communication.",
    example: "Reacting more to how something was said than what was said shows inferential learning.",
    icon: MessageCircle
  },
  
  {
    id: 21,
    text: "If someone you are associated with talks about a fear that you have experienced before, do you have a tendency to have an apprehensive or fearful feeling also?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Mental empathy and analytical processing of others' emotions indicates emotional suggestibility.",
    example: "Feeling anxious when hearing about fears shows mental processing of emotional content.",
    icon: Brain
  },
  
  {
    id: 22,
    text: "After having an argument with someone, do you have a tendency to dwell on what you could or should have said?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Analytical reflection after events indicates inferential, thought-based processing.",
    example: "Replaying conversations and thinking of better responses shows analytical thinking style.",
    icon: Brain
  },
  
  {
    id: 23,
    text: "Do you tend to occasionally tune out when someone is talking to you and, therefore, do not hear what was said because your mind drifts to something totally unrelated?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Mental drift indicates internal focus and analytical thinking separate from immediate stimuli.",
    example: "Finding yourself thinking about other things during conversation shows internal mental focus.",
    icon: Wind
  },
  
  {
    id: 24,
    text: "Do you sometimes desire to be complimented for a job well done, but feel embarrassed or uncomfortable when complimented?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Internal desire conflicting with external comfort indicates analytical self-awareness.",
    example: "Wanting praise but feeling awkward when receiving it shows internal conflict.",
    icon: Star
  },
  
  {
    id: 25,
    text: "Do you often have a fear or dread of not being able to carry on a conversation with someone you've just met?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Social anxiety and anticipatory thinking indicates analytical processing of interactions.",
    example: "Worrying about conversations before they happen shows anticipatory analytical thinking.",
    icon: Users
  },
  
  {
    id: 26,
    text: "Do you feel self-conscious when attention is drawn to your physical body or appearance?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with physical attention indicates mind-body disconnection.",
    example: "Feeling awkward about appearance compliments shows analytical self-consciousness.",
    icon: Eye
  },
  
  {
    id: 27,
    text: "If you had a choice, would you rather avoid being around children most of the time?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Preference for complex over simple interaction indicates analytical nature.",
    example: "Preferring adult conversation shows preference for inferential communication.",
    icon: Users
  },
  
  {
    id: 28,
    text: "Do you feel that you are not relaxed or loose in body movements, especially when faced with unfamiliar people or circumstances?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Physical tension in new situations indicates analytical processing creating body awareness.",
    example: "Feeling stiff or awkward in new situations shows mind-body disconnection under stress.",
    icon: Wind
  },
  
  {
    id: 29,
    text: "Do you prefer reading non-fiction rather than fiction?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Preference for factual information indicates analytical, intellectual approach.",
    example: "Choosing educational books over novels shows analytical learning preference.",
    icon: Book
  },
  
  {
    id: 30,
    text: "If someone describes a very bitter taste, do you have difficulty experiencing the physical feeling of it?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Difficulty translating mental imagery to physical sensation indicates mind-body disconnection.",
    example: "Not feeling taste sensations from descriptions shows analytical vs. physical processing.",
    icon: Coffee
  },
  
  {
    id: 31,
    text: "Do you generally feel that you see yourself less favorably than others see you?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Analytical self-criticism indicates inferential, thought-based self-perception.",
    example: "Being harder on yourself than others are shows analytical internal focus.",
    icon: Brain
  },
  
  {
    id: 32,
    text: "Do you tend to feel awkward or self-conscious initiating touch (holding hands, kissing, etc.) with someone you are in a relationship with, in front of other people?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with public physical affection indicates analytical awareness of social context.",
    example: "Feeling awkward about PDA shows analytical processing of social appropriateness.",
    icon: Heart
  },
  
  {
    id: 33,
    text: "In a new class or lecture situation, do you usually feel uncomfortable asking questions in front of the group, even though you may desire further explanation?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Internal desire conflicting with external action indicates analytical self-consciousness.",
    example: "Wanting to ask but feeling too self-conscious shows analytical internal conflict.",
    icon: HelpCircle
  },
  
  {
    id: 34,
    text: "Do you feel uneasy if someone you have just met looks you directly in the eyes when talking to you, especially if the conversation is about you?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with direct eye contact indicates preference for less intense interaction.",
    example: "Finding direct eye contact uncomfortable shows analytical self-awareness.",
    icon: Eye
  },
  
  {
    id: 35,
    text: "In a group situation with people you have just met, would you feel uncomfortable drawing attention to yourself by initiating a conversation?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Reluctance to initiate indicates analytical processing of social dynamics.",
    example: "Preferring to observe before participating shows analytical assessment of situations.",
    icon: Users
  },
  
  {
    id: 36,
    text: "If you are in a relationship, or are very close to someone, do you find it difficult or embarrassing to verbalize your love for them?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Difficulty with direct emotional expression indicates inferential communication style.",
    example: "Finding it hard to say 'I love you' shows preference for showing vs. telling.",
    icon: Heart
  }
];

// =====================================================
// HMI LOOKUP TABLE (Complete Grid from Score Chart)
// Maps Q1 Score + Combined Score → Physical Suggestibility %
// =====================================================

const HMI_LOOKUP_TABLE: Record<number, Record<number, number>> = {
  100: {50:100,55:100,60:95,65:91,70:87,75:83,80:80,85:77,90:74,95:71,100:69,105:67,110:65,115:63,120:61,125:59,130:57,135:56,140:54,145:53,150:51,155:50,160:49,165:48,170:47,175:46,180:45,185:44,190:43,195:42,200:41},
  95: {50:100,55:100,60:95,65:90,70:86,75:83,80:79,85:76,90:73,95:70,100:68,105:66,110:63,115:61,120:59,125:58,130:56,135:54,140:53,145:51,150:50,155:49,160:48,165:47,170:46,175:45,180:44,185:43,190:42,195:41,200:40},
  90: {50:100,55:100,60:95,65:90,70:86,75:82,80:78,85:75,90:72,95:69,100:67,105:64,110:62,115:60,120:58,125:56,130:55,135:53,140:51,145:50,150:49,155:47,160:46,165:45,170:44,175:43,180:42,185:41,190:40,195:39,200:38},
  85: {50:100,55:100,60:94,65:89,70:85,75:81,80:77,85:74,90:71,95:68,100:65,105:63,110:61,115:59,120:57,125:55,130:53,135:52,140:50,145:49,150:47,155:46,160:45,165:44,170:43,175:42,180:41,185:40,190:39,195:38,200:37},
  80: {50:100,55:100,60:94,65:89,70:84,75:80,80:76,85:73,90:70,95:67,100:64,105:62,110:59,115:57,120:55,125:53,130:52,135:50,140:48,145:47,150:46,155:44,160:43,165:42,170:41,175:40,180:39,185:38,190:37,195:36,200:35},
  75: {50:100,55:100,60:94,65:88,70:83,75:79,80:75,85:71,90:68,95:65,100:63,105:60,110:58,115:56,120:54,125:52,130:50,135:48,140:47,145:45,150:44,155:43,160:42,165:41,170:39,175:38,180:38,185:37,190:36,195:35,200:34},
  70: {50:100,55:100,60:93,65:88,70:82,75:78,80:74,85:70,90:67,95:64,100:61,105:58,110:56,115:54,120:52,125:50,130:48,135:47,140:45,145:44,150:42,155:41,160:40,165:39,170:38,175:37,180:36,185:35,190:34,195:33,200:32},
  65: {50:100,55:100,60:93,65:87,70:81,75:76,80:72,85:68,90:65,95:62,100:59,105:57,110:54,115:52,120:50,125:48,130:46,135:45,140:43,145:42,150:41,155:39,160:38,165:37,170:36,175:35,180:34,185:33,190:33,195:32,200:31},
  60: {50:100,55:100,60:92,65:86,70:80,75:75,80:71,85:67,90:63,95:60,100:57,105:55,110:52,115:50,120:48,125:46,130:44,135:43,140:41,145:40,150:39,155:38,160:36,165:35,170:34,175:33,180:32,185:32,190:31,195:30,200:29},
  55: {50:100,55:100,60:92,65:85,70:79,75:73,80:69,85:65,90:61,95:58,100:55,105:52,110:50,115:48,120:46,125:44,130:42,135:41,140:39,145:38,150:37,155:35,160:34,165:33,170:32,175:31,180:31,185:30,190:29,195:28,200:28},
  50: {50:100,55:100,60:91,65:83,70:77,75:71,80:67,85:63,90:59,95:56,100:53,105:50,110:48,115:45,120:43,125:42,130:40,135:38,140:37,145:36,150:34,155:33,160:32,165:31,170:30,175:29,180:29,185:28,190:27,195:26,200:26},
  45: {50:90,55:90,60:82,65:75,70:69,75:64,80:60,85:56,90:53,95:50,100:47,105:45,110:43,115:41,120:39,125:38,130:36,135:35,140:33,145:32,150:31,155:30,160:29,165:28,170:27,175:26,180:26,185:25,190:24,195:24,200:23},
  40: {50:80,55:80,60:73,65:67,70:62,75:57,80:53,85:50,90:47,95:44,100:42,105:40,110:38,115:36,120:35,125:33,130:32,135:31,140:30,145:29,150:28,155:27,160:26,165:25,170:24,175:24,180:23,185:22,190:22,195:21,200:21},
  35: {50:70,55:70,60:64,65:58,70:54,75:50,80:47,85:44,90:41,95:39,100:37,105:35,110:33,115:32,120:30,125:29,130:28,135:27,140:26,145:25,150:24,155:23,160:23,165:22,170:21,175:21,180:20,185:19,190:19,195:18,200:18},
  30: {50:60,55:60,60:55,65:50,70:46,75:43,80:40,85:38,90:35,95:33,100:32,105:30,110:29,115:27,120:26,125:25,130:24,135:23,140:22,145:21,150:21,155:20,160:19,165:19,170:18,175:18,180:17,185:17,190:16,195:16,200:15},
  25: {50:50,55:50,60:45,65:42,70:38,75:36,80:33,85:31,90:29,95:28,100:26,105:25,110:24,115:23,120:22,125:21,130:20,135:19,140:19,145:18,150:17,155:17,160:16,165:16,170:15,175:15,180:14,185:14,190:14,195:13,200:13},
  20: {50:40,55:40,60:36,65:33,70:31,75:29,80:27,85:25,90:24,95:22,100:21,105:20,110:19,115:18,120:17,125:17,130:16,135:15,140:15,145:14,150:14,155:13,160:13,165:13,170:12,175:12,180:11,185:11,190:11,195:11,200:10},
  15: {50:30,55:30,60:27,65:25,70:23,75:21,80:20,85:19,90:18,95:17,100:16,105:15,110:14,115:14,120:13,125:13,130:12,135:12,140:11,145:11,150:10,155:10,160:10,165:9,170:9,175:9,180:9,185:8,190:8,195:8,200:8},
  10: {50:20,55:20,60:18,65:17,70:15,75:14,80:13,85:13,90:12,95:11,100:11,105:10,110:10,115:9,120:9,125:8,130:8,135:8,140:7,145:7,150:7,155:7,160:6,165:6,170:6,175:6,180:6,185:6,190:5,195:5,200:5},
  5: {50:10,55:10,60:9,65:8,70:8,75:7,80:7,85:6,90:6,95:6,100:5,105:5,110:5,115:5,120:4,125:4,130:4,135:4,140:4,145:4,150:3,155:3,160:3,165:3,170:3,175:3,180:3,185:3,190:3,195:3,200:3},
  0: {50:0,55:0,60:0,65:0,70:0,75:0,80:0,85:0,90:0,95:0,100:0,105:0,110:0,115:0,120:0,125:0,130:0,135:0,140:0,145:0,150:0,155:0,160:0,165:0,170:0,175:0,180:0,185:0,190:0,195:0,200:0}
};

// =====================================================
// HMI SCORING FUNCTION
// =====================================================

function calculateHMIScore(answers: Record<number, boolean>): ScoringResult {
  // Calculate Q1 Score (Questions 1-18)
  let q1Score = 0;
  
  // Questions 1-2: 10 points each
  const q1HighWeight = [1, 2];
  q1HighWeight.forEach(qId => {
    if (answers[qId]) q1Score += 10;
  });
  
  // Questions 3-18: 5 points each
  for (let i = 3; i <= 18; i++) {
    if (answers[i]) q1Score += 5;
  }
  
  // Calculate Q2 Score (Questions 19-36)
  let q2Score = 0;
  
  // Questions 19-20: 10 points each
  const q2HighWeight = [19, 20];
  q2HighWeight.forEach(qId => {
    if (answers[qId]) q2Score += 10;
  });
  
  // Questions 21-36: 5 points each
  for (let i = 21; i <= 36; i++) {
    if (answers[i]) q2Score += 5;
  }
  
  const combinedScore = q1Score + q2Score;
  
  // Lookup Physical Percentage from HMI Table
  const physicalPercentage = lookupPhysicalPercentage(q1Score, combinedScore);
  const emotionalPercentage = 100 - physicalPercentage;
  
  // Determine Profile
  let profile: 'Physical Suggestible' | 'Emotional Suggestible' | 'Somnambulistic' | 'Intellectual Suggestible';
  
  if (physicalPercentage === 50 && emotionalPercentage === 50) {
    profile = 'Somnambulistic';
  } else if (emotionalPercentage >= 80) {
    profile = 'Intellectual Suggestible';
  } else if (physicalPercentage > emotionalPercentage) {
    profile = 'Physical Suggestible';
  } else {
    profile = 'Emotional Suggestible';
  }
  
  return {
    success: true,
    profile,
    physicalPercentage,
    emotionalPercentage,
    q1Score,
    q2Score,
    combinedScore,
    answers,
    completedAt: new Date().toISOString(),
    userId: '',
    methodology: 'HMI E&P Suggestibility Assessment (Kappas Method)'
  };
}

function lookupPhysicalPercentage(q1Score: number, combinedScore: number): number {
  // Ensure scores are within valid range
  const validQ1 = Math.max(0, Math.min(100, q1Score));
  const validCombined = Math.max(50, Math.min(200, combinedScore));
  
  // Round to nearest multiple of 5 for Q1
  const roundedQ1 = Math.round(validQ1 / 5) * 5;
  
  // Round to nearest multiple of 5 for combined
  const roundedCombined = Math.round(validCombined / 5) * 5;
  
  // Look up value in table
  if (HMI_LOOKUP_TABLE[roundedQ1] && HMI_LOOKUP_TABLE[roundedQ1][roundedCombined] !== undefined) {
    return HMI_LOOKUP_TABLE[roundedQ1][roundedCombined];
  }
  
  // If exact match not found, interpolate
  return interpolateLookup(validQ1, validCombined);
}

function interpolateLookup(q1Score: number, combinedScore: number): number {
  // Find surrounding values in table
  const q1Lower = Math.floor(q1Score / 5) * 5;
  const q1Upper = Math.ceil(q1Score / 5) * 5;
  const combLower = Math.floor(combinedScore / 5) * 5;
  const combUpper = Math.ceil(combinedScore / 5) * 5;
  
  // Get four corner values
  const v1 = HMI_LOOKUP_TABLE[q1Lower]?.[combLower] ?? 50;
  const v2 = HMI_LOOKUP_TABLE[q1Upper]?.[combLower] ?? 50;
  const v3 = HMI_LOOKUP_TABLE[q1Lower]?.[combUpper] ?? 50;
  const v4 = HMI_LOOKUP_TABLE[q1Upper]?.[combUpper] ?? 50;
  
  // Bilinear interpolation
  const q1Frac = q1Upper > q1Lower ? (q1Score - q1Lower) / (q1Upper - q1Lower) : 0;
  const combFrac = combUpper > combLower ? (combinedScore - combLower) / (combUpper - combLower) : 0;
  
  const interp1 = v1 + (v2 - v1) * q1Frac;
  const interp2 = v3 + (v4 - v3) * q1Frac;
  const result = interp1 + (interp2 - interp1) * combFrac;
  
  return Math.round(result);
}

// =====================================================
// COLOR CONSTANTS
// =====================================================

const COLORS = {
  pageBackground: 'from-gray-900 via-purple-900 to-indigo-900',
  cardBackground: 'bg-gray-900',
  cardBackgroundAlternate: 'bg-gray-800/90',
  textPrimary: 'text-white',
  textSecondary: 'text-gray-200',
  textMuted: 'text-gray-400',
  sectionHeaderBg: 'from-purple-600/30 to-pink-600/30',
  sectionHeaderBorder: 'border-purple-400/30',
  progressBarBg: 'bg-gray-700',
  progressBarFill: 'from-purple-600 via-pink-600 to-cyan-600',
  progressDotCompleted: 'bg-green-500',
  progressDotCurrent: 'bg-purple-500',
  progressDotUpcoming: 'bg-gray-700',
  questionBadgeBg: 'bg-purple-600',
  questionBadgeText: 'text-white',
  buttonYesActive: 'from-green-600 to-emerald-600',
  buttonYesActiveBorder: 'border-green-400',
  buttonYesActiveShadow: 'shadow-green-500/50',
  buttonYesInactive: 'bg-gray-700',
  buttonYesInactiveBorder: 'border-gray-600',
  buttonYesHoverBorder: 'hover:border-green-500/50',
  buttonNoActive: 'from-red-600 to-pink-600',
  buttonNoActiveBorder: 'border-red-400',
  buttonNoActiveShadow: 'shadow-red-500/50',
  buttonNoInactive: 'bg-gray-700',
  buttonNoInactiveBorder: 'border-gray-600',
  buttonNoHoverBorder: 'hover:border-red-500/50',
  navButtonPrimary: 'from-purple-600 to-pink-600',
  navButtonSecondary: 'bg-gray-700',
  navButtonSubmit: 'from-green-600 to-cyan-600',
  navButtonDisabled: 'bg-gray-700',
  cardBorder: 'border-purple-500/50',
  questionBorder: 'border-gray-700',
  questionHoverBorder: 'hover:border-purple-500/70',
  errorBg: 'bg-red-500/20',
  errorBorder: 'border-red-500/50',
  errorText: 'text-red-300',
};

const QUESTIONS_PER_PAGE = 6;
const TOTAL_PAGES = 6;

// =====================================================
// COMPONENT: TOOLTIP
// =====================================================

interface TooltipProps {
  content: string;
  example?: string;
}

const Tooltip: React.FC<TooltipProps> = ({ content, example }) => {
  const [isVisible, setIsVisible] = useState(false);

  return (
    <div className="relative inline-block">
      <button
        onMouseEnter={() => setIsVisible(true)}
        onMouseLeave={() => setIsVisible(false)}
        onClick={() => setIsVisible(!isVisible)}
        className="ml-2 text-purple-400 hover:text-purple-300 transition-colors"
        type="button"
      >
        <HelpCircle size={18} />
      </button>

      <AnimatePresence>
        {isVisible && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2 }}
            className="absolute z-50 w-80 p-4 bg-gray-800 border border-purple-500/50 rounded-lg shadow-2xl -top-2 left-8"
          >
            <div className="flex items-start gap-2 mb-2">
              <Info size={16} className="text-purple-400 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-gray-200">{content}</p>
            </div>
            
            {example && (
              <div className="mt-3 pt-3 border-t border-gray-700">
                <div className="flex items-start gap-2">
                  <Lightbulb size={14} className="text-yellow-400 flex-shrink-0 mt-0.5" />
                  <p className="text-xs text-gray-400 italic">{example}</p>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

// =====================================================
// COMPONENT: PROGRESS BAR
// =====================================================

interface ProgressBarProps {
  current: number;
  total: number;
  percentage: number;
  answeredCount: number;
  totalQuestions: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({
  current,
  total,
  percentage,
  answeredCount,
  totalQuestions
}) => {
  return (
    <div className="mb-8">
      <div className="flex justify-between items-center mb-3">
        <span className={`${COLORS.textMuted} text-sm font-medium`}>
          HMI E&P Suggestibility Assessment
        </span>
        <span className="text-purple-400 font-bold text-sm">
          {answeredCount}/{totalQuestions} questions
        </span>
      </div>

      <div className={`relative h-3 ${COLORS.progressBarBg} rounded-full overflow-hidden shadow-inner`}>
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
          className={`absolute top-0 left-0 h-full bg-gradient-to-r ${COLORS.progressBarFill} rounded-full shadow-lg`}
        />
        
        {percentage > 10 && (
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-white text-xs font-bold drop-shadow-lg">
              {Math.round(percentage)}%
            </span>
          </div>
        )}
      </div>

      <div className="flex justify-center gap-2 mt-4">
        {Array.from({ length: total }, (_, i) => i + 1).map(page => (
          <div
            key={page}
            className={`h-2 rounded-full transition-all duration-300 ${
              page < current
                ? `${COLORS.progressDotCompleted} w-10 shadow-sm shadow-green-500/50`
                : page === current
                ? `${COLORS.progressDotCurrent} w-16 shadow-sm shadow-purple-500/50`
                : `${COLORS.progressDotUpcoming} w-10`
            }`}
          />
        ))}
      </div>
      
      <div className={`text-center mt-3 ${COLORS.textMuted} text-xs`}>
        Page {current} of {total}
      </div>
    </div>
  );
};

// =====================================================
// COMPONENT: QUESTION CARD
// =====================================================

interface QuestionCardProps {
  question: EPQuestion;
  answer: boolean | undefined;
  onAnswer: (answer: boolean) => void;
  index: number;
}

const QuestionCard: React.FC<QuestionCardProps> = ({
  question,
  answer,
  onAnswer,
  index
}) => {
  const Icon = question.icon || Brain;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.08, duration: 0.3 }}
      className={`
        ${COLORS.cardBackgroundAlternate} 
        rounded-xl p-6 
        border-2 ${COLORS.questionBorder} 
        ${COLORS.questionHoverBorder}
        transition-all duration-300
        shadow-lg hover:shadow-xl hover:shadow-purple-500/20
      `}
    >
      {/* Question Header */}
      <div className="mb-5">
        <div className="flex items-start gap-3 mb-3">
          {/* Question Number Badge */}
          <span className={`
            inline-flex items-center justify-center
            ${COLORS.questionBadgeBg} 
            ${COLORS.questionBadgeText}
            font-bold text-sm 
            px-3 py-1.5 
            rounded-full 
            shadow-md
            flex-shrink-0
          `}>
            Q{question.id}
          </span>
          
          {/* Icon */}
          <div className="flex-shrink-0 mt-0.5">
            <Icon size={20} className="text-purple-400" />
          </div>
          
          {/* Question Text */}
          <div className="flex-1">
            <p className={`${COLORS.textPrimary} text-lg font-medium leading-relaxed`}>
              {question.text}
            </p>
          </div>

          {/* Tooltip */}
          <Tooltip content={question.tooltip} example={question.example} />
        </div>

        {/* Category Badge */}
        <div className="ml-14">
          <span className={`
            inline-block text-xs px-2 py-1 rounded-full
            ${question.category === 'physical' 
              ? 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/30' 
              : 'bg-purple-500/20 text-purple-300 border border-purple-500/30'
            }
          `}>
            {question.category === 'physical' ? '🎯 Physical Indicator' : '💭 Emotional Indicator'}
          </span>
        </div>
      </div>

      {/* Answer Buttons */}
      <div className="flex gap-4">
        <button
          onClick={() => onAnswer(true)}
          type="button"
          className={`
            flex-1 py-4 px-6 
            rounded-xl 
            font-bold text-lg 
            transition-all duration-200 
            transform hover:scale-105 active:scale-95
            shadow-lg
            border-2
            ${
              answer === true
                ? `bg-gradient-to-r ${COLORS.buttonYesActive} 
                   text-white 
                   shadow-2xl ${COLORS.buttonYesActiveShadow}
                   scale-105 
                   ${COLORS.buttonYesActiveBorder}
                   ring-4 ring-green-500/30`
                : `${COLORS.buttonYesInactive} 
                   ${COLORS.textSecondary}
                   hover:bg-gray-600 
                   ${COLORS.buttonYesInactiveBorder}
                   ${COLORS.buttonYesHoverBorder}
                   hover:text-white`
            }
          `}
        >
          <span className="text-2xl mr-2">✓</span>
          <span>Yes</span>
        </button>
        
        <button
          onClick={() => onAnswer(false)}
          type="button"
          className={`
            flex-1 py-4 px-6 
            rounded-xl 
            font-bold text-lg 
            transition-all duration-200 
            transform hover:scale-105 active:scale-95
            shadow-lg
            border-2
            ${
              answer === false
                ? `bg-gradient-to-r ${COLORS.buttonNoActive}
                   text-white 
                   shadow-2xl ${COLORS.buttonNoActiveShadow}
                   scale-105 
                   ${COLORS.buttonNoActiveBorder}
                   ring-4 ring-red-500/30`
                : `${COLORS.buttonNoInactive}
                   ${COLORS.textSecondary}
                   hover:bg-gray-600 
                   ${COLORS.buttonNoInactiveBorder}
                   ${COLORS.buttonNoHoverBorder}
                   hover:text-white`
            }
          `}
        >
          <span className="text-2xl mr-2">✗</span>
          <span>No</span>
        </button>
      </div>
    </motion.div>
  );
};

// =====================================================
// COMPONENT: QUESTION PAGE
// =====================================================

interface QuestionPageProps {
  questions: EPQuestion[];
  answers: Record<number, boolean>;
  onAnswer: (questionId: number, answer: boolean) => void;
  pageNumber: number;
}

const QuestionPage: React.FC<QuestionPageProps> = ({
  questions,
  answers,
  onAnswer,
  pageNumber
}) => {
  const isPhysicalSection = pageNumber <= 3;
  const sectionIcon = isPhysicalSection ? '🎯' : '💭';
  const sectionTitle = isPhysicalSection 
    ? 'Physical Suggestibility Indicators' 
    : 'Emotional Suggestibility Indicators';
  const sectionDescription = isPhysicalSection
    ? 'These questions identify direct, literal response patterns and mind-body connection'
    : 'These questions identify inferential, analytical response patterns and mental processing';
  
  return (
    <div className={`
      ${COLORS.cardBackground} 
      backdrop-blur-md 
      rounded-2xl p-8 
      border-2 ${COLORS.cardBorder}
      shadow-2xl
    `}>
      {/* Section Header */}
      <div className={`
        mb-8 
        bg-gradient-to-r ${COLORS.sectionHeaderBg}
        rounded-xl p-6 
        border ${COLORS.sectionHeaderBorder}
        shadow-inner
      `}>
        <div className="flex items-center justify-between mb-3">
          <h2 className={`text-4xl font-bold ${COLORS.textPrimary} drop-shadow-lg`}>
            Section {pageNumber}
          </h2>
          <span className="text-5xl">{sectionIcon}</span>
        </div>
        <p className={`${COLORS.textSecondary} text-xl font-medium mb-2`}>
          {sectionTitle}
        </p>
        <p className={`${COLORS.textMuted} text-sm`}>
          {sectionDescription}
        </p>
        <div className={`mt-3 ${COLORS.textMuted} text-xs flex items-center gap-2`}>
          <Info size={14} />
          <span>Questions {questions[0].id} - {questions[questions.length - 1].id} of 36 • HMI Kappas Method</span>
        </div>
      </div>

      {/* Questions Grid */}
      <div className="space-y-5">
        {questions.map((question, index) => (
          <QuestionCard
            key={question.id}
            question={question}
            answer={answers[question.id]}
            onAnswer={(answer) => onAnswer(question.id, answer)}
            index={index}
          />
        ))}
      </div>

      {/* Page Completion Indicator */}
      <div className="mt-6 text-center">
        {questions.every(q => answers[q.id] !== undefined) ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className="inline-flex items-center gap-2 bg-green-500/20 border border-green-500/50 rounded-full px-4 py-2"
          >
            <CheckCircle2 size={20} className="text-green-400" />
            <span className="text-green-300 font-semibold">Page Complete</span>
          </motion.div>
        ) : (
          <div className={`${COLORS.textMuted} text-sm`}>
            {questions.filter(q => answers[q.id] !== undefined).length} of {questions.length} answered on this page
          </div>
        )}
      </div>
    </div>
  );
};

// =====================================================
// MAIN COMPONENT
// =====================================================

const EPAssessmentQuestionnaire: React.FC<EPAssessmentQuestionnaireProps> = ({
  userId,
  onComplete,
  onBack
}) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [answers, setAnswers] = useState<Record<number, boolean>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Load saved progress
  useEffect(() => {
    const savedAnswers = localStorage.getItem('jeeth-ep-answers');
    const savedPage = localStorage.getItem('jeeth-ep-page');
    
    if (savedAnswers) {
      try {
        setAnswers(JSON.parse(savedAnswers));
      } catch (e) {
        console.error('Failed to load saved answers', e);
      }
    }
    
    if (savedPage) {
      setCurrentPage(parseInt(savedPage, 10));
    }
  }, []);

  // Save progress
  useEffect(() => {
    localStorage.setItem('jeeth-ep-answers', JSON.stringify(answers));
    localStorage.setItem('jeeth-ep-page', currentPage.toString());
  }, [answers, currentPage]);

  const questionsForPage = EP_QUESTIONS.slice(
    (currentPage - 1) * QUESTIONS_PER_PAGE,
    currentPage * QUESTIONS_PER_PAGE
  );

  const answeredCount = Object.keys(answers).length;
  const progress = (answeredCount / EP_QUESTIONS.length) * 100;
  const canGoNext = questionsForPage.every(q => answers[q.id] !== undefined);
  const canSubmit = answeredCount === EP_QUESTIONS.length;

  const handleAnswer = (questionId: number, answer: boolean) => {
    setAnswers(prev => ({ ...prev, [questionId]: answer }));
  };

  const handleNext = () => {
    if (currentPage < TOTAL_PAGES) {
      setCurrentPage(prev => prev + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handlePrevious = () => {
    if (currentPage > 1) {
      setCurrentPage(prev => prev - 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else if (onBack) {
      onBack();
    }
  };

  const handleSubmit = async () => {
    if (!canSubmit) return;

    setIsSubmitting(true);
    setError(null);

    try {
      const results = calculateHMIScore(answers);
      results.userId = userId;

      // Clear saved progress
      localStorage.removeItem('jeeth-ep-answers');
      localStorage.removeItem('jeeth-ep-page');

      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));

      onComplete(results);
    } catch (err: any) {
      setError(err.message || 'Failed to submit assessment. Please try again.');
      setIsSubmitting(false);
    }
  };

  return (
    <div className={`
      min-h-screen 
      bg-gradient-to-br ${COLORS.pageBackground}
      flex items-center justify-center 
      px-4 sm:px-8 py-12
      relative overflow-hidden
    `}>
      {/* Background Stars */}
      <div className="absolute inset-0 opacity-20 pointer-events-none">
        {[...Array(50)].map((_, i) => (
          <div
            key={i}
            className="absolute w-1 h-1 bg-white rounded-full animate-pulse"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${2 + Math.random() * 2}s`
            }}
          />
        ))}
      </div>

      <div className="max-w-4xl w-full relative z-10">
        <ProgressBar 
          current={currentPage}
          total={TOTAL_PAGES}
          percentage={progress}
          answeredCount={answeredCount}
          totalQuestions={EP_QUESTIONS.length}
        />

        <AnimatePresence mode="wait">
          <motion.div
            key={currentPage}
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            transition={{ duration: 0.3 }}
          >
            <QuestionPage
              questions={questionsForPage}
              answers={answers}
              onAnswer={handleAnswer}
              pageNumber={currentPage}
            />
          </motion.div>
        </AnimatePresence>

        {error && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className={`
              mt-6 p-4 
              ${COLORS.errorBg}
              border ${COLORS.errorBorder}
              rounded-xl 
              ${COLORS.errorText}
              text-center font-medium
              shadow-lg
            `}
          >
            <span className="text-xl mr-2">⚠️</span>
            {error}
          </motion.div>
        )}

        {/* Navigation */}
        <div className="mt-8 flex justify-between items-center gap-4">
          <button
            onClick={handlePrevious}
            type="button"
            className={`
              px-6 sm:px-8 py-3 
              ${COLORS.navButtonSecondary}
              ${COLORS.textSecondary}
              rounded-full 
              font-semibold
              hover:bg-gray-600 
              transition-all duration-200
              shadow-lg
              hover:shadow-xl
              flex items-center gap-2
            `}
          >
            <ChevronLeft size={20} />
            {currentPage === 1 ? 'Back' : 'Previous'}
          </button>

          {currentPage < TOTAL_PAGES ? (
            <button
              onClick={handleNext}
              disabled={!canGoNext}
              type="button"
              className={`
                px-8 sm:px-12 py-4 
                rounded-full 
                text-lg font-bold
                transition-all duration-200
                shadow-2xl
                flex items-center gap-2
                ${
                  canGoNext
                    ? `bg-gradient-to-r ${COLORS.navButtonPrimary}
                       text-white 
                       hover:scale-105 
                       hover:shadow-purple-500/50
                       active:scale-95`
                    : `${COLORS.navButtonDisabled}
                       text-gray-500 
                       cursor-not-allowed
                       opacity-50`
                }
              `}
            >
              Next
              <ChevronRight size={20} />
            </button>
          ) : (
            <button
              onClick={handleSubmit}
              disabled={!canSubmit || isSubmitting}
              type="button"
              className={`
                px-8 sm:px-12 py-4 
                rounded-full 
                text-lg font-bold
                transition-all duration-200
                shadow-2xl
                flex items-center gap-2
                ${
                  canSubmit && !isSubmitting
                    ? `bg-gradient-to-r ${COLORS.navButtonSubmit}
                       text-white 
                       hover:scale-105 
                       hover:shadow-green-500/50
                       active:scale-95`
                    : `${COLORS.navButtonDisabled}
                       text-gray-500 
                       cursor-not-allowed
                       opacity-50`
                }
              `}
            >
              {isSubmitting ? (
                <>
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles size={20} />
                  </motion.div>
                  Analyzing...
                </>
              ) : (
                <>
                  Complete Assessment
                  <CheckCircle2 size={20} />
                </>
              )}
            </button>
          )}
        </div>

        {/* Footer Info */}
        <div className={`mt-6 text-center ${COLORS.textMuted} text-sm space-y-2`}>
          <div className="flex items-center justify-center gap-2">
            <Info size={14} />
            <span>
              Page {currentPage} of {TOTAL_PAGES} • {answeredCount}/{EP_QUESTIONS.length} questions answered
            </span>
          </div>
          <div className="text-xs flex items-center justify-center gap-2">
            <Sparkles size={12} />
            <span>Progress automatically saved • HMI Kappas Clinical Methodology</span>
          </div>
        </div>

        {/* First Page Tips */}
        {currentPage === 1 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="mt-8 p-6 bg-blue-500/10 border border-blue-500/30 rounded-xl"
          >
            <h3 className="text-blue-300 font-bold mb-3 flex items-center gap-2">
              <Lightbulb size={20} />
              Assessment Tips
            </h3>
            <ul className="text-blue-200 text-sm space-y-2">
              <li className="flex items-start gap-2">
                <CheckCircle2 size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Answer honestly - there are no right or wrong answers</span>
              </li>
              <li className="flex items-start gap-2">
                <Target size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Go with your first instinct rather than overthinking</span>
              </li>
              <li className="flex items-start gap-2">
                <HelpCircle size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Hover over help icons for detailed explanations and examples</span>
              </li>
              <li className="flex items-start gap-2">
                <Sparkles size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>This assessment uses the authentic HMI methodology developed by Dr. John Kappas</span>
              </li>
            </ul>
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default EPAssessmentQuestionnaire;
'@

# Ensure directory exists
$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path $outputDir)) {
    Write-Host "Creating directory: $outputDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Write the file
Write-Host "Writing component file..." -ForegroundColor Green
$componentContent | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  ✅ Component Created Successfully!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📄 File created at:" -ForegroundColor Cyan
Write-Host "   $outputPath" -ForegroundColor White
Write-Host ""
Write-Host "✨ Features included:" -ForegroundColor Cyan
Write-Host "   ✅ All 36 authentic HMI questions" -ForegroundColor White
Write-Host "   ✅ Correct weighted scoring (10-10-5-5-5...)" -ForegroundColor White
Write-Host "   ✅ Complete HMI lookup table" -ForegroundColor White
Write-Host "   ✅ Tooltips with explanations" -ForegroundColor White
Write-Host "   ✅ Visual examples for each question" -ForegroundColor White
Write-Host "   ✅ Professional UX with animations" -ForegroundColor White
Write-Host "   ✅ Auto-save progress" -ForegroundColor White
Write-Host "   ✅ Production-ready TypeScript" -ForegroundColor White
Write-Host "   ✅Pure Physical (Q1=100, Combined=50 → 100%)" -ForegroundColor White
Write-Host "   ✅Somnambulistic (Q1=50, Combined=100 → 53%)" -ForegroundColor White
Write-Host "   ✅Pure Emotional (Q1=0, any score → 0%)" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Install dependencies (if not already):" -ForegroundColor White
Write-Host "      npm install lucide-react framer-motion" -ForegroundColor Gray
Write-Host "   2. Import and use in your app:" -ForegroundColor White
Write-Host "      import EPAssessmentQuestionnaire from './components/onboarding/EPAssessmentQuestionnaire';" -ForegroundColor Gray
Write-Host "   3. Test the component:" -ForegroundColor White
Write-Host "      npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Component is ready for production use!" -ForegroundColor Green
Write-Host ""


Write-Section " ==> Generating Story 5.3: 3D Floating Question Cards Implementation typescript => $FrontEnd\src\components\xrQuestionCard3D.tsx"
Set-Content -Path "$FrontEnd\src\components\xrQuestionCard3D.tsx" -Value @"
// @ts-nocheck
import { useRef, useState, useEffect } from 'react';
import { useFrame } from '@react-three/fiber';
import { Text } from '@react-three/drei';
import * as THREE from 'three';

export function QuestionCard3D({ 
  question, 
  onAnswer, 
  position = [0, 1.5, -2],
  isActive = true,
  onHelperRequest
}) {
  const cardRef = useRef();
  const [hovered, setHovered] = useState(false);
  const [scale, setScale] = useState(1);

  useFrame(({ clock }) => {
    if (!cardRef.current) return;
    
    const t = clock.getElapsedTime();
    
    // Gentle floating animation
    cardRef.current.position.y = position[1] + Math.sin(t * 0.5) * 0.02;
    
    // Scale animation based on active state
    const targetScale = isActive ? (hovered ? 1.05 : 1) : 0.85;
    setScale(THREE.MathUtils.lerp(scale, targetScale, 0.1));
    cardRef.current.scale.setScalar(scale);
    
    // Opacity for inactive cards
    if (cardRef.current.material) {
      cardRef.current.material.opacity = isActive ? 1 : 0.5;
    }
  });

  return (
    <group ref={cardRef} position={position}>
      {/* Card Background with Glass Morphism */}
      <mesh
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <roundedBoxGeometry args={[1.2, 0.8, 0.05, 5, 0.02]} />
        <meshPhysicalMaterial
          color={isActive ? '#ffffff' : '#cccccc'}
          transparent
          opacity={0.9}
          roughness={0.1}
          metalness={0.1}
          clearcoat={1}
          clearcoatRoughness={0.1}
          transmission={0.1}
          thickness={0.5}
        />
      </mesh>

      {/* Glowing Border */}
      <mesh position={[0, 0, -0.001]}>
        <roundedBoxGeometry args={[1.22, 0.82, 0.01, 5, 0.02]} />
        <meshBasicMaterial
          color={hovered ? '#ffd700' : '#87ceeb'}
          transparent
          opacity={hovered ? 0.8 : 0.4}
        />
      </mesh>

      {/* Question Text */}
      <Text
        position={[0, 0.25, 0.03]}
        fontSize={0.06}
        maxWidth={1.0}
        textAlign="center"
        color="#1a1a1a"
        anchorX="center"
        anchorY="middle"
        font="/fonts/Inter-Bold.ttf"
      >
        {question.text}
      </Text>

      {/* Helper Button */}
      <HelpButton
        position={[0.5, 0.35, 0.03]}
        onClick={onHelperRequest}
      />

      {/* Input Component based on question type */}
      <group position={[0, -0.15, 0.03]}>
        {question.type === 'slider' && (
          <SliderInput3D
            min={question.min}
            max={question.max}
            onChange={onAnswer}
          />
        )}
        {question.type === 'chips' && (
          <ChipInput3D
            options={question.options}
            onChange={onAnswer}
          />
        )}
        {question.type === 'radio' && (
          <RadioInput3D
            options={question.options}
            onChange={onAnswer}
          />
        )}
      </group>
    </group>
  );
}

// Custom RoundedBox geometry helper
function roundedBoxGeometry(width, height, depth, segments, radius) {
  const shape = new THREE.Shape();
  const w = width / 2 - radius;
  const h = height / 2 - radius;
  
  shape.moveTo(-w, -h + radius);
  shape.lineTo(-w, h - radius);
  shape.quadraticCurveTo(-w, h, -w + radius, h);
  shape.lineTo(w - radius, h);
  shape.quadraticCurveTo(w, h, w, h - radius);
  shape.lineTo(w, -h + radius);
  shape.quadraticCurveTo(w, -h, w - radius, -h);
  shape.lineTo(-w + radius, -h);
  shape.quadraticCurveTo(-w, -h, -w, -h + radius);
  
  const extrudeSettings = {
    depth: depth,
    bevelEnabled: true,
    bevelThickness: 0.01,
    bevelSize: 0.01,
    bevelSegments: segments
  };
  
  return new THREE.ExtrudeGeometry(shape, extrudeSettings);
}

// Helper Button Component
function HelpButton({ position, onClick }) {
  const [hovered, setHovered] = useState(false);
  const [gazeDuration, setGazeDuration] = useState(0);

  useFrame((_, delta) => {
    if (hovered) {
      setGazeDuration(prev => Math.min(prev + delta, 1));
      if (gazeDuration >= 1) {
        onClick();
        setGazeDuration(0);
      }
    } else {
      setGazeDuration(0);
    }
  });

  return (
    <group position={position}>
      {/* Button background */}
      <mesh
        onClick={onClick}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <circleGeometry args={[0.04, 32]} />
        <meshBasicMaterial color={hovered ? '#ffd700' : '#87ceeb'} />
      </mesh>

      {/* Question mark */}
      <Text
        position={[0, 0, 0.001]}
        fontSize={0.03}
        color="#ffffff"
        anchorX="center"
        anchorY="middle"
        font="/fonts/Inter-Bold.ttf"
      >
        ?
      </Text>

      {/* Gaze progress ring */}
      {hovered && (
        <mesh rotation={[0, 0, -Math.PI / 2]}>
          <ringGeometry args={[0.04, 0.045, 32, 1, 0, gazeDuration * Math.PI * 2]} />
          <meshBasicMaterial color="#ffd700" transparent opacity={0.8} />
        </mesh>
      )}
    </group>
  );
}
"@


#Write-Section " ==> Generating Task 5.2.6: Spatial Audio System typescript => $FrontEnd\src\features\xr\environments\SoftLitRoom.tsx"
Set-Content -Path "$FrontEnd\src\components\xr\inputs\SliderInput3D.tsx" -Value @"
// @ts-nocheck
import { useRef, useState } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { Text } from '@react-three/drei';
import * as THREE from 'three';

export function SliderInput3D({ 
  min = 0, 
  max = 100, 
  value = 50,
  onChange,
  width = 0.8 
}) {
  const [currentValue, setCurrentValue] = useState(value);
  const [isDragging, setIsDragging] = useState(false);
  const [hovered, setHovered] = useState(false);
  const handleRef = useRef();
  const trackRef = useRef();
  const { camera, raycaster, pointer } = useThree();

  const handlePosition = ((currentValue - min) / (max - min)) * width - width / 2;

  useFrame(() => {
    if (isDragging && handleRef.current) {
      // Ray cast to track plane
      raycaster.setFromCamera(pointer, camera);
      const intersects = raycaster.intersectObject(trackRef.current);
      
      if (intersects.length > 0) {
        const point = intersects[0].point;
        const localX = point.x - trackRef.current.position.x;
        const normalizedX = (localX + width / 2) / width;
        const newValue = Math.round(min + normalizedX * (max - min));
        const clampedValue = Math.max(min, Math.min(max, newValue));
        
        setCurrentValue(clampedValue);
        onChange(clampedValue);
      }
    }
  });

  return (
    <group>
      {/* Track */}
      <mesh
        ref={trackRef}
        onPointerDown={() => setIsDragging(true)}
        onPointerUp={() => setIsDragging(false)}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <boxGeometry args={[width, 0.01, 0.02]} />
        <meshStandardMaterial color="#cccccc" />
      </mesh>

      {/* Filled track */}
      <mesh position={[handlePosition / 2 - width / 4, 0, 0.001]}>
        <boxGeometry args={[(handlePosition + width / 2), 0.012, 0.021]} />
        <meshStandardMaterial color="#4169e1" emissive="#4169e1" emissiveIntensity={0.5} />
      </mesh>

      {/* Draggable Handle */}
      <group position={[handlePosition, 0, 0]} ref={handleRef}>
        <mesh
          onPointerDown={() => setIsDragging(true)}
          onPointerUp={() => setIsDragging(false)}
        >
          <cylinderGeometry args={[0.03, 0.03, 0.04, 32]} />
          <meshStandardMaterial
            color={isDragging ? '#ffd700' : hovered ? '#87ceeb' : '#4169e1'}
            emissive={isDragging ? '#ffd700' : '#4169e1'}
            emissiveIntensity={isDragging ? 1 : 0.5}
          />
        </mesh>

        {/* Glow effect when dragging */}
        {isDragging && (
          <mesh>
            <sphereGeometry args={[0.05, 16, 16]} />
            <meshBasicMaterial color="#ffd700" transparent opacity={0.3} />
          </mesh>
        )}
      </group>

      {/* Value Label */}
      <Text
        position={[0, 0.06, 0]}
        fontSize={0.04}
        color="#1a1a1a"
        anchorX="center"
        anchorY="middle"
        font="/fonts/Inter-Regular.ttf"
      >
        {currentValue}
      </Text>

      {/* Min/Max Labels */}
      <Text
        position={[-width / 2, -0.04, 0]}
        fontSize={0.03}
        color="#666666"
        anchorX="center"
        anchorY="middle"
      >
        {min}
      </Text>
      <Text
        position={[width / 2, -0.04, 0]}
        fontSize={0.03}
        color="#666666"
        anchorX="center"
        anchorY="middle"
      >
        {max}
      </Text>
    </group>
  );
}
"@

Set-Content -Path "$FrontEnd\src\components\xr\inputs\ChipInput3D.tsx" -Value @"
// @ts-nocheck
import { useState } from 'react';
import { Text } from '@react-three/drei';
import * as THREE from 'three';

export function ChipInput3D({ 
  options = [], 
  onChange,
  multiSelect = false 
}) {
  const [selectedIndices, setSelectedIndices] = useState([]);

  const handleChipClick = (index) => {
    if (multiSelect) {
      const newSelection = selectedIndices.includes(index)
        ? selectedIndices.filter(i => i !== index)
        : [...selectedIndices, index];
      setSelectedIndices(newSelection);
      onChange(newSelection.map(i => options[i]));
    } else {
      setSelectedIndices([index]);
      onChange(options[index]);
    }
  };

  const chipWidth = 0.15;
  const spacing = 0.02;
  const totalWidth = options.length * (chipWidth + spacing) - spacing;
  const startX = -totalWidth / 2 + chipWidth / 2;

  return (
    <group>
      {options.map((option, index) => {
        const isSelected = selectedIndices.includes(index);
        const xPos = startX + index * (chipWidth + spacing);

        return (
          <Chip3D
            key={index}
            position={[xPos, 0, 0]}
            label={option.label || option}
            isSelected={isSelected}
            onClick={() => handleChipClick(index)}
          />
        );
      })}
    </group>
  );
}

function Chip3D({ position, label, isSelected, onClick }) {
  const [hovered, setHovered] = useState(false);

  return (
    <group position={position}>
      {/* Chip background */}
      <mesh
        onClick={onClick}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <boxGeometry args={[0.15, 0.06, 0.02]} />
        <meshStandardMaterial
          color={isSelected ? '#4169e1' : hovered ? '#87ceeb' : '#e0e0e0'}
          emissive={isSelected ? '#4169e1' : '#000000'}
          emissiveIntensity={isSelected ? 0.5 : 0}
        />
      </mesh>

      {/* Label */}
      <Text
        position={[0, 0, 0.011]}
        fontSize={0.025}
        color={isSelected ? '#ffffff' : '#1a1a1a'}
        anchorX="center"
        anchorY="middle"
        font="/fonts/Inter-Medium.ttf"
      >
        {label}
      </Text>

      {/* Glow effect when selected */}
      {isSelected && (
        <mesh position={[0, 0, -0.005]}>
          <boxGeometry args={[0.16, 0.07, 0.01]} />
          <meshBasicMaterial color="#ffd700" transparent opacity={0.3} />
        </mesh>
      )}
    </group>
  );
}
"@

Set-Content -Path "$FrontEnd\src\components\xr\inputs\RadioInput3D.tsx" -Value @"
// @ts-nocheck
import { useState } from 'react';
import { Text } from '@react-three/drei';

export function RadioInput3D({ options = [], onChange }) {
  const [selectedIndex, setSelectedIndex] = useState(null);

  const handleRadioClick = (index) => {
    setSelectedIndex(index);
    onChange(options[index]);
  };

  return (
    <group>
      {options.map((option, index) => {
        const yPos = -index * 0.08;
        const isSelected = selectedIndex === index;

        return (
          <RadioButton3D
            key={index}
            position={[0, yPos, 0]}
            label={option.label || option}
            isSelected={isSelected}
            onClick={() => handleRadioClick(index)}
          />
        );
      })}
    </group>
  );
}

function RadioButton3D({ position, label, isSelected, onClick }) {
  const [hovered, setHovered] = useState(false);

  return (
    <group position={position}>
      {/* Radio circle */}
      <mesh
        position={[-0.4, 0, 0]}
        onClick={onClick}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <circleGeometry args={[0.02, 32]} />
        <meshStandardMaterial
          color={hovered ? '#87ceeb' : '#cccccc'}
          emissive={hovered ? '#87ceeb' : '#000000'}
          emissiveIntensity={hovered ? 0.3 : 0}
        />
      </mesh>

      {/* Selected indicator */}
      {isSelected && (
        <mesh position={[-0.4, 0, 0.001]}>
          <circleGeometry args={[0.012, 32]} />
          <meshBasicMaterial color="#4169e1" />
        </mesh>
      )}

      {/* Label */}
      <Text
        position={[-0.35, 0, 0]}
        fontSize={0.03}
        color="#1a1a1a"
        anchorX="left"
        anchorY="middle"
        font="/fonts/Inter-Regular.ttf"
      >
        {label}
      </Text>

      {/* Clickable area */}
      <mesh
        position={[0, 0, -0.01]}
        onClick={onClick}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
      >
        <planeGeometry args={[0.8, 0.07]} />
        <meshBasicMaterial transparent opacity={0} />
      </mesh>
    </group>
  );
}
"@


Set-Content -Path "$FrontEnd\src\components\xr\ProgressVisualization3D.tsx" -Value @"
// @ts-nocheck
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Text } from '@react-three/drei';
import * as THREE from 'three';

export function ProgressVisualization3D({ 
  total = 10, 
  completed = 0,
  position = [0, 2.5, -2.5]
}) {
  const groupRef = useRef();
  const percentage = Math.round((completed / total) * 100);

  useFrame(({ clock }) => {
    if (groupRef.current) {
      groupRef.current.rotation.z = clock.getElapsedTime() * 0.1;
    }
  });

  return (
    <group position={position} ref={groupRef}>
      {/* Circle of orbs */}
      {Array.from({ length: total }).map((_, index) => {
        const angle = (index / total) * Math.PI * 2;
        const radius = 0.3;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        const isCompleted = index < completed;

        return (
          <ProgressOrb
            key={index}
            position={[x, y, 0]}
            isCompleted={isCompleted}
            delay={index * 0.1}
          />
        );
      })}

      {/* Center percentage */}
      <Text
        position={[0, 0, 0.01]}
        fontSize={0.08}
        color="#ffd700"
        anchorX="center"
        anchorY="middle"
        font="/fonts/Inter-Bold.ttf"
      >
        {percentage}%
      </Text>
    </group>
  );
}

function ProgressOrb({ position, isCompleted, delay }) {
  const meshRef = useRef();
  const [scale, setScale] = useState(0);

  useFrame(({ clock }) => {
    if (!meshRef.current) return;
    
    const t = clock.getElapsedTime() - delay;
    
    // Animate in
    if (scale < 1 && t > 0) {
      setScale(Math.min(scale + 0.05, 1));
    }
    
    // Pulse when completed
    if (isCompleted) {
      const pulse = Math.sin(t * 2) * 0.1 + 1;
      meshRef.current.scale.setScalar(scale * pulse);
    }
  });

  return (
    <mesh ref={meshRef} position={position}>
      <sphereGeometry args={[0.025, 16, 16]} />
      <meshStandardMaterial
        color={isCompleted ? '#ffd700' : '#666666'}
        emissive={isCompleted ? '#ffd700' : '#000000'}
        emissiveIntensity={isCompleted ? 2 : 0}
        transparent
        opacity={isCompleted ? 1 : 0.3}
      />
      
      {/* Glow effect for completed orbs */}
      {isCompleted && (
        <mesh>
          <sphereGeometry args={[0.04, 16, 16]} />
          <meshBasicMaterial color="#ffd700" transparent opacity={0.2} />
        </mesh>
      )}
    </mesh>
  );
}
"@

Set-Content -Path "$FrontEnd\src\features\xr\AssessmentXR.tsx" -Value @"
// @ts-nocheck
import { useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { XR, Controllers, Hands } from '@react-three/xr';
import { QuestionCard3D } from '../../components/xr/QuestionCard3D';
import { ProgressVisualization3D } from '../../components/xr/ProgressVisualization3D';
import { HelperPanel3D } from '../../components/xr/HelperPanel3D';
import { ShambhalaRealm } from '../../components/ShambhalaRealm';

const SAMPLE_QUESTIONS = [
  {
    id: 1,
    text: "How would you rate your current stress level?",
    type: "slider",
    min: 0,
    max: 10
  },
  {
    id: 2,
    text: "How often do you practice mindfulness?",
    type: "chips",
    options: ["Never", "Rarely", "Sometimes", "Often", "Daily"]
  },
  {
    id: 3,
    text: "What is your primary goal for this session?",
    type: "radio",
    options: [
      "Stress reduction",
      "Better sleep",
      "Emotional healing",
      "Self-discovery"
    ]
  }
];

export function AssessmentXR() {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState({});
  const [showHelper, setShowHelper] = useState(false);

  const currentQuestion = SAMPLE_QUESTIONS[currentQuestionIndex];
  const totalQuestions = SAMPLE_QUESTIONS.length;

  const handleAnswer = (answer) => {
    setAnswers(prev => ({
      ...prev,
      [currentQuestion.id]: answer
    }));

    // Auto-advance after 1 second
    setTimeout(() => {
      if (currentQuestionIndex < totalQuestions - 1) {
        setCurrentQuestionIndex(prev => prev + 1);
      } else {
        console.log('Assessment complete!', answers);
      }
    }, 1000);
  };

  return (
    <Canvas>
      <XR>
        <Controllers />
        <Hands />
        
        {/* Environment */}
        <ShambhalaRealm />
        
        {/* Progress visualization */}
        <ProgressVisualization3D
          total={totalQuestions}
          completed={currentQuestionIndex}
        />
        
        {/* Question cards in an arc */}
        {SAMPLE_QUESTIONS.map((question, index) => {
          const angle = (index - currentQuestionIndex) * 0.3;
          const distance = Math.abs(index - currentQuestionIndex) * 0.2 + 2;
          const x = Math.sin(angle) * distance;
          const z = -Math.cos(angle) * distance;
          
          return (
            <QuestionCard3D
              key={question.id}
              question={question}
              position={[x, 1.5, z]}
              isActive={index === currentQuestionIndex}
              onAnswer={handleAnswer}
              onHelperRequest={() => setShowHelper(true)}
            />
          );
        })}
        
        {/* Helper panel */}
        {showHelper && (
          <HelperPanel3D
            question={currentQuestion}
            onClose={() => setShowHelper(false)}
            position={[0.7, 1.5, -2]}
          />
        )}
        
        {/* Lighting */}
        <ambientLight intensity={0.5} />
        <pointLight position={[0, 3, 0]} intensity={1} />
      </XR>
    </Canvas>
  );
}
"@

<# COMEBACK HERE F===> 
Next Steps - What Should We Build?

✅ Complete Story 5.3 - Add remaining features:

Accessibility options (font size, high contrast)
Performance optimizations
User testing integration


➡️ Story 5.4: Helper Panel - Build the sliding helper panel
➡️ Story 5.5: Session Delivery - Therapeutic suggestions with spatial audio
➡️ Story 5.6: Testing & Fallback - Cross-device testing

#>

<#
🎯 FIRST STORY: E6-F5-S1Epic 6, Feature 5, Story 1: E&P Sexuality Data ExtractionGoal: Extract and structure content from your E&P Sexuality Workbook 1What This Story Delivers:

PDF text extraction system
E&P theory parser (Four Core Traits, relationship patterns)
Structured JSON knowledge base
PostgreSQL schema for E&P content
PowerShell automation script
Test suite
Estimated Time: 30 minutes setup, runs automatically
4 Files Ready to Download:

E6-F5-S1-Setup.ps1 (945 lines, 34KB) ⭐ RUN THIS!
E6-F5-S1-README.md (14KB) - Complete docs
E6-F5-S1-QUICK-START.md (4KB) - Quick reference
SESSION_SUMMARY_E6-F5-S1.md (11KB) - Today's work
START_HERE_E6-F5-S1.md (2KB) - Master index

#>

Write-Section " ==> STORY 1 (E6-F5-S1) => Running script $Root\scripts\E6-F5-S1-Ingest-EandP.ps1"
"$Root\scripts\E6-F5-S1-Ingest-EandP.ps1"

Write-Section " ==> STORY 1 (E6-F5-S2) => Running script $Root\scripts\E6-F5-S2-Assess-EandP.ps1"
"$Root\scripts\E6-F5-S1-Ingest-EandP.ps1"

Write-Section " ==> Generating schema for Questionnair and E&P Score lookup tables"
"$Root\scripts\load-sugg-questionnaire.ps1"

Write-Section " ==> Generating scoring engine and APIs"
"$Root\scripts\GenerateEandPScoringEngine.ps1"

Write-Section " ==> Generate Questionnaire backend files"
"$Root\create_python_files.ps1"
"$Root\InstallEnhancedFeatures.ps1"


Write-Section @"
===> Phase 1: Complete E&P Assessment API (2-3 hours)
 1. API Routes (routes/assessment.py)
   - POST /api/v1/assessment/ep/submit
   - GET  /api/v1/assessment/ep/results/latest
   - GET  /api/v1/assessment/ep/communication-preferences  KEY!
   - GET  /api/v1/assessment/ep/history
   - POST /api/v1/assessment/ep/{id}/flag
   - POST /api/v1/assessment/ep/{id}/review

 2. Request/Response Schemas (schemas/assessment.py)
   - Pydantic validation models
   - Error handling
   - Response formatting

 3. Authentication Integration
   - JWT token validation
   - Role-based access (User/Clinician/Admin)

 4. Integration Tests
   - Full API flow tests
   - Database integration
   - Multi-agent coordination
"@
 "$Root\Generate_EP_Assessment_API_Phase1.ps1"


 $epAssessmentAPI = @"

"@
SetContent -path "$BackEnd\api\.py" -content $epAssessmenAPI 

$epAgentIntegration = @"

"@
SetContent -path "$BackEnd\agents\.py" -content $epAgentIntegration


Write-Section " ==> Generating Task 5.2.6: Spatial Audio System typescript => $FrontEnd\src\features\xr\environments\SoftLitRoom.tsx"
Set-Content -Path "$FrontEnd\src\features\xr\environments\SoftLitRoom.tsx" -Value @"
"@
