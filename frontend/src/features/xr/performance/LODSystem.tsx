import { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { useXRStore } from '../stores/xr.store';

const TARGET_FPS = 85;
const MIN_FPS = 72;
const MAX_FPS = 90;
const FPS_CHECK_INTERVAL = 60; // frames
const LOD_COOLDOWN = 180; // frames before changing LOD again

let frameCount = 0;
let lastTime = performance.now();
let fpsHistory: number[] = [];
let lodCooldown = 0;

export function PerformanceMonitor() {
  const { updatePerformance, setLODLevel, lodLevel, autoLOD } = useXRStore();
  const metricsRef = useRef({ fps: 90, frameTime: 11.1, memoryUsage: 0, drawCalls: 0 });

  useFrame(({ gl }) => {
    frameCount++;
    const currentTime = performance.now();
    const delta = currentTime - lastTime;

    // Update FPS every second
    if (delta >= 1000) {
      const fps = Math.round((frameCount * 1000) / delta);
      const frameTime = delta / frameCount;
      
      // Get memory usage (if available)
      const memoryUsage = (performance as any).memory 
        ? Math.round((performance as any).memory.usedJSHeapSize / 1048576) 
        : 0;
      
      // Get draw calls from renderer
      const drawCalls = gl.info.render.calls;
      
      metricsRef.current = { fps, frameTime, memoryUsage, drawCalls };
      updatePerformance(metricsRef.current);
      
      fpsHistory.push(fps);
      if (fpsHistory.length > 5) {
        fpsHistory.shift();
      }

      frameCount = 0;
      lastTime = currentTime;
    }

    // Auto LOD adjustment logic
    if (!autoLOD || lodCooldown > 0) {
      if (lodCooldown > 0) lodCooldown--;
      return;
    }

    if (frameCount % FPS_CHECK_INTERVAL === 0 && fpsHistory.length >= 3) {
      const avgFPS = fpsHistory.reduce((a, b) => a + b, 0) / fpsHistory.length;

      // Decrease quality if FPS is critically low
      if (avgFPS < MIN_FPS && lodLevel < 2) {
        setLODLevel(lodLevel + 1);
        lodCooldown = LOD_COOLDOWN;
      }
      // Decrease quality if FPS is below target
      else if (avgFPS < TARGET_FPS && lodLevel < 2) {
        setLODLevel(lodLevel + 1);
        lodCooldown = LOD_COOLDOWN * 2; // Longer cooldown for minor adjustments
      }
      // Increase quality if FPS is stable and high
      else if (avgFPS > MAX_FPS && lodLevel > 0) {
        setLODLevel(lodLevel - 1);
        lodCooldown = LOD_COOLDOWN * 2;
      }
    }
  });

  return null;
}

export function useLOD() {
  return useXRStore((state) => state.lodLevel);
}

export function usePerformanceMetrics() {
  return useXRStore((state) => state.performance);
}
