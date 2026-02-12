import { useEffect, useState } from 'react';
import { useXRStore } from '../stores/xr.store';

export function XRDeviceDetector() {
  const { setXRSupported, setDeviceType } = useXRStore();
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    async function detectXR() {
      try {
        // Check if WebXR is supported
        if ('xr' in navigator) {
          const isSupported = await (navigator as any).xr.isSessionSupported('immersive-vr');
          setXRSupported(isSupported);

          if (isSupported) {
            // Detect device type
            const userAgent = navigator.userAgent.toLowerCase();
            
            if (userAgent.includes('quest 3')) {
              setDeviceType('quest3');
              console.log('[OK] Meta Quest 3 detected');
            } else if (userAgent.includes('quest 2') || userAgent.includes('quest')) {
              setDeviceType('quest2');
              console.log('[OK] Meta Quest 2 detected');
            } else if (userAgent.includes('oculus')) {
              setDeviceType('quest2');
              console.log('[OK] Oculus device detected');
            } else {
              setDeviceType('unknown');
              console.log('[OK] Generic WebXR device detected');
            }
          } else {
            setDeviceType('desktop');
            console.log('[INFO] WebXR not supported - Desktop mode');
          }
        } else {
          setXRSupported(false);
          setDeviceType('desktop');
          console.log('[INFO] WebXR API not available - Desktop mode');
        }
      } catch (error) {
        console.error('[ERROR] Error detecting XR:', error);
        setXRSupported(false);
        setDeviceType('desktop');
      } finally {
        setChecking(false);
      }
    }

    detectXR();
  }, [setXRSupported, setDeviceType]);

  if (checking) {
    return (
      <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-8 text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-700 font-medium">Detecting XR capabilities...</p>
        </div>
      </div>
    );
  }

  return null;
}

export function useXRCapabilities() {
  const { isXRSupported, deviceType } = useXRStore();
  
  return {
    isXRSupported,
    deviceType,
    isQuest3: deviceType === 'quest3',
    isQuest2: deviceType === 'quest2',
    isDesktop: deviceType === 'desktop',
    displayName: {
      'quest3': 'Meta Quest 3',
      'quest2': 'Meta Quest 2',
      'desktop': 'Desktop Browser',
      'unknown': 'Unknown VR Device',
    }[deviceType],
  };
}
