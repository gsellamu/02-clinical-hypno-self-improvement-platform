import { Canvas } from '@react-three/fiber';
import { XR, createXRStore } from '@react-three/xr';
import { OrbitControls } from '@react-three/drei';
import { useEffect, useMemo, useState } from 'react';
import { useXRStore } from '../stores/xr.store';
import { SoftLitRoom } from '../environments/SoftLitRoom';
import { NatureScene } from '../environments/NatureScene';
import { FloatingPlatform } from '../environments/FloatingPlatform';
import { PerformanceMonitor } from '../performance/LODSystem';
import { AudioSystem } from '../audio/AudioSystem';

interface XRSceneProps {
  mode: 'xr' | '3d';
}

export function XRScene({ mode }: XRSceneProps) {
  const { currentEnvironment, setXRActive } = useXRStore();
  const [error, setError] = useState<string | null>(null);
  const [isXRAvailable, setIsXRAvailable] = useState(false);
  const [isInVR, setIsInVR] = useState(false);
  const [debugInfo, setDebugInfo] = useState<string>('');
  
  // Create XR store - SIMPLIFIED configuration
  const store = useMemo(() => {
    if (mode === 'xr') {
      try {
        const xrStore = createXRStore();
        console.log('✅ XR Store created successfully');
        return xrStore;
      } catch (err) {
        console.error('❌ Failed to create XR store:', err);
        setError('Failed to initialize XR store');
        return null;
      }
    }
    return null;
  }, [mode]);

  // Check XR availability with detailed logging
  useEffect(() => {
    if (mode !== 'xr') return;

    const checkXR = async () => {
      try {
        setDebugInfo('Checking WebXR support...');
        
        if (!('xr' in navigator)) {
          setDebugInfo('navigator.xr not found');
          setIsXRAvailable(false);
          return;
        }

        if (!navigator.xr) {
          setDebugInfo('navigator.xr is null');
          setIsXRAvailable(false);
          return;
        }

        const supported = await navigator.xr.isSessionSupported('immersive-vr');
        setIsXRAvailable(supported);
        setDebugInfo(supported 
          ? '✅ WebXR immersive-vr supported' 
          : '❌ WebXR immersive-vr NOT supported');
        
        console.log('WebXR Check:', {
          hasNavigatorXR: 'xr' in navigator,
          xrObject: navigator.xr,
          supported,
        });
      } catch (err) {
        console.error('XR check error:', err);
        setDebugInfo(`Error checking XR: ${err}`);
        setIsXRAvailable(false);
      }
    };

    checkXR();
    
    // Check periodically (emulator might be enabled after page load)
    const interval = setInterval(checkXR, 3000);
    return () => clearInterval(interval);
  }, [mode]);

  // Subscribe to XR session state
  useEffect(() => {
    if (!store) return;
    
    try {
      const unsubscribe = store.subscribe((state) => {
        const active = state.session !== null;
        setXRActive(active);
        setIsInVR(active);
        
        if (active) {
          console.log('🎉 XR Session is ACTIVE');
          setError(null);
        } else {
          console.log('📴 XR Session is INACTIVE');
        }
      });
      
      return () => unsubscribe();
    } catch (err) {
      console.error('Error subscribing to XR store:', err);
    }
  }, [store, setXRActive]);

  // Handle VR entry with comprehensive error handling
  const handleEnterVR = async () => {
    console.log('🚀 handleEnterVR called');
    console.log('Store exists:', !!store);
    console.log('XR Available:', isXRAvailable);

    if (!store) {
      const msg = 'XR store not initialized';
      console.error('❌', msg);
      setError(msg);
      return;
    }

    if (!isXRAvailable) {
      const msg = 'WebXR not available. Enable WebXR Emulator in DevTools > WebXR tab, then refresh.';
      console.error('❌', msg);
      setError(msg);
      return;
    }
    
    try {
      console.log('🎯 Attempting to enter VR...');
      setError(null);
      
      // Check if XR is really available before calling enterVR
      if ('xr' in navigator && navigator.xr) {
        const isSupported = await navigator.xr.isSessionSupported('immersive-vr');
        console.log('Double-checking XR support:', isSupported);
        
        if (!isSupported) {
          throw new Error('WebXR became unavailable. Refresh and try again.');
        }
      }

      // Attempt to enter VR
      await store.enterVR();
      console.log('✅ Successfully entered VR!');
      
    } catch (err: any) {
      console.error('❌ Error entering VR:', err);
      console.error('Error details:', {
        name: err.name,
        message: err.message,
        stack: err.stack,
      });
      
      let errorMessage = 'Failed to enter VR. ';
      
      // Provide specific error messages
      if (err.name === 'NotSupportedError') {
        errorMessage += 'WebXR not supported. Enable WebXR Emulator in DevTools.';
      } else if (err.name === 'SecurityError') {
        errorMessage += 'Security error. Make sure page is served over HTTPS or localhost.';
      } else if (err.message.includes('session')) {
        errorMessage += 'Session error. Close any open VR sessions and try again.';
      } else {
        errorMessage += err.message || 'Unknown error';
      }
      
      setError(errorMessage);
    }
  };

  return (
    <div className="w-full h-screen relative">
      {/* ENTER VR BUTTON */}
      {mode === 'xr' && !isInVR && (
        <div className="absolute top-0 left-0 right-0 z-50 flex justify-center pt-6 pointer-events-none">
          <button
            onClick={handleEnterVR}
            disabled={!isXRAvailable}
            className={`pointer-events-auto px-10 py-5 font-bold text-2xl rounded-2xl shadow-2xl transition-all duration-300 ${
              isXRAvailable
                ? 'bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 text-white hover:scale-110 hover:shadow-3xl cursor-pointer animate-pulse'
                : 'bg-gray-500 text-gray-300 cursor-not-allowed'
            }`}
          >
            {isXRAvailable ? '🥽 ENTER VR' : '⚠️ ENABLE WEBXR EMULATOR'}
          </button>
        </div>
      )}

      {/* Debug Info Panel */}
      {mode === 'xr' && (
        <div className="absolute top-6 left-6 z-40 bg-black/80 text-white px-4 py-2 rounded-lg text-xs font-mono max-w-xs">
          <div className="font-bold mb-1">DEBUG INFO:</div>
          <div>{debugInfo}</div>
          <div className="mt-1">Store: {store ? '✅ OK' : '❌ NULL'}</div>
          <div>XR Available: {isXRAvailable ? '✅ YES' : '❌ NO'}</div>
          <div>In VR: {isInVR ? '✅ YES' : '❌ NO'}</div>
        </div>
      )}

      {/* XR STATUS - Top Right */}
      {mode === 'xr' && (
        <div className={`absolute top-6 right-6 z-40 px-6 py-3 rounded-xl text-base font-bold shadow-lg ${
          isInVR 
            ? 'bg-green-500 text-white animate-pulse'
            : isXRAvailable 
              ? 'bg-blue-500 text-white' 
              : 'bg-yellow-500 text-black'
        }`}>
          {isInVR ? '✅ IN VR MODE' : isXRAvailable ? '🔵 XR READY' : '⚠️ XR NOT DETECTED'}
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="absolute top-32 left-1/2 transform -translate-x-1/2 z-50 bg-red-600 text-white px-8 py-6 rounded-xl shadow-2xl max-w-2xl">
          <div className="text-2xl font-bold mb-3">❌ ERROR</div>
          <div className="text-sm leading-relaxed">{error}</div>
          <button
            onClick={() => setError(null)}
            className="mt-4 px-4 py-2 bg-white text-red-600 rounded-lg font-bold hover:bg-gray-100"
          >
            Dismiss
          </button>
        </div>
      )}

      {/* WebXR Emulator Setup Instructions */}
      {mode === 'xr' && !isXRAvailable && !isInVR && (
        <div className="absolute top-40 left-1/2 transform -translate-x-1/2 z-40 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-8 py-6 rounded-2xl shadow-2xl max-w-xl">
          <div className="text-2xl font-bold mb-4 text-center">
            🛠️ WEBXR EMULATOR SETUP
          </div>
          <ol className="space-y-2 text-sm">
            <li className="flex items-start gap-3">
              <span className="font-bold text-yellow-300">1.</span>
              <span>Press <kbd className="bg-black/30 px-2 py-1 rounded">F12</kbd> to open DevTools</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-yellow-300">2.</span>
              <span>Click the <strong>"WebXR"</strong> tab at the top</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-yellow-300">3.</span>
              <span>Check the <strong>"Enable"</strong> checkbox</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-yellow-300">4.</span>
              <span>Select <strong>"Oculus Quest 2"</strong> from dropdown</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-yellow-300">5.</span>
              <span>Press <kbd className="bg-black/30 px-2 py-1 rounded">Ctrl+R</kbd> to refresh</span>
            </li>
          </ol>
          
          <div className="mt-4 text-center text-xs opacity-75">
            Current Status: {debugInfo}
          </div>
        </div>
      )}

      {/* Success Message when in VR */}
      {isInVR && (
        <div className="absolute top-32 left-1/2 transform -translate-x-1/2 z-40 bg-green-600 text-white px-8 py-4 rounded-xl shadow-2xl text-center font-bold animate-bounce">
          <div className="text-2xl mb-2">🎉 VR MODE ACTIVE!</div>
          <div className="text-sm">Use WebXR panel controls to move headset</div>
        </div>
      )}

      {/* Controls hint for 3D mode */}
      {mode === '3d' && (
        <div className="absolute bottom-24 left-1/2 transform -translate-x-1/2 z-30 bg-black/80 text-white px-8 py-4 rounded-xl shadow-xl text-center">
          <div className="font-bold text-lg mb-2">🖱️ 3D CONTROLS</div>
          <div className="text-sm space-y-1">
            <div>Left Click + Drag: Rotate View</div>
            <div>Right Click + Drag: Pan Camera</div>
            <div>Scroll: Zoom In/Out</div>
          </div>
        </div>
      )}
      
      {/* THREE.JS CANVAS */}
      <Canvas
        camera={{ position: [0, 1.6, 5], fov: 75 }}
        gl={{ 
          antialias: true,
          powerPreference: 'high-performance',
        }}
        shadows
      >
        {mode === 'xr' && store ? (
          <XR store={store}>
            <SceneContent currentEnvironment={currentEnvironment} />
          </XR>
        ) : (
          <>
            <OrbitControls 
              enablePan={true}
              enableZoom={true}
              enableRotate={true}
              minDistance={2}
              maxDistance={20}
              maxPolarAngle={Math.PI / 2}
            />
            <SceneContent currentEnvironment={currentEnvironment} />
          </>
        )}
      </Canvas>
    </div>
  );
}

// Shared scene content
function SceneContent({ currentEnvironment }: { currentEnvironment: string }) {
  return (
    <>
      <PerformanceMonitor />
      <AudioSystem />
      
      {currentEnvironment === 'soft-room' && <SoftLitRoom />}
      {currentEnvironment === 'nature' && <NatureScene />}
      {currentEnvironment === 'floating-platform' && <FloatingPlatform />}
    </>
  );
}

/* 

## 🔍 What This Does:

1. **Debug Panel** (top-left): Shows real-time status of:
   - XR store initialization
   - WebXR availability
   - Current VR state

2. **Better Error Messages**: Specific messages for different error types

3. **Comprehensive Logging**: Check browser console (F12) for detailed logs

4. **Double-Check**: Re-verifies WebXR support before entering VR

## 📋 Debugging Steps:

### **Step 1: Check Browser Console**

Open console (F12) and look for these messages:
```
✅ XR Store created successfully
WebXR Check: { hasNavigatorXR: true, supported: true }
🚀 handleEnterVR called
🎯 Attempting to enter VR...
```

### **Step 2: Check Debug Panel** (top-left)

Should show:
```
DEBUG INFO:
✅ WebXR immersive-vr supported
Store: ✅ OK
XR Available: ✅ YES
In VR: ❌ NO


## 🎯 Key Changes Made:

1. **Higher Z-Index**: Button now has `z-50` (highest priority)
2. **Better Positioning**: Centered at top with `flex justify-center`
3. **Pointer Events**: Fixed with `pointer-events-none` on container, `pointer-events-auto` on button
4. **More Visible**: Larger button with emoji `🥽 ENTER VR`
5. **Animated**: Added `animate-pulse` so it pulses and catches attention
6. **State Tracking**: Added `isInVR` to track when user is actually in VR
7. **Visual Feedback**: Shows different states clearly

## 📸 Now You Should See:
```
┌─────────────────────────────────────────────────┐
│                                                 │
│        ╔═══════════════════════════╗           │
│        ║  🥽 ENTER VR (pulsing)   ║  ← BIG!  │
│        ╚═══════════════════════════╝           │
│                                        [XR READY]│
│                                                 │
│  Choose Your Environment                        │
│  ┌─────────────────────────────┐              │
│  │ [Room] Soft Lit Room   [OK] │              │
│  └─────────────────────────────┘              │
│                                                 │
│  Performance [OK] Excellent                     │
└─────────────────────────────────────────────────┘
*/