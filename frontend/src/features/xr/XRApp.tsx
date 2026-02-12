import { XRScene } from './components/XRScene';
import { EnvironmentSelector } from './components/EnvironmentSelector';
import { PerformanceHUD } from './components/PerformanceHUD';
import { XRDeviceDetector } from './components/XRDeviceDetector';

interface XRAppProps {
  mode: 'xr' | '3d';
}

export function XRApp({ mode }: XRAppProps) {
  return (
    <div className="relative w-full h-screen bg-gray-900">
      <XRDeviceDetector />
      <XRScene mode={mode} />
      <EnvironmentSelector />
      <PerformanceHUD />
      
      {/* Mode indicator */}
      <div className="absolute top-4 right-4 z-10 bg-black/70 text-white px-4 py-2 rounded-lg text-sm font-mono">
        {mode === 'xr' ? '[VR MODE]' : '[3D MODE]'}
      </div>
    </div>
  );
}

/* 

## ✅ That's It!

The TypeScript error should now be gone. The `mode` prop flows like this:
```
App.tsx (user clicks button)
   ↓ passes mode='xr' or mode='3d'
XRApp.tsx (receives mode)
   ↓ passes mode to XRScene
XRScene.tsx (uses mode to decide XR vs 3D)
*/
