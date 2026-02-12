import { useXRStore } from '../stores/xr.store';
import { usePerformanceMetrics } from '../performance/LODSystem';

export function PerformanceHUD() {
  const { isXRActive, lodLevel, autoLOD, toggleAutoLOD, setLODLevel } = useXRStore();
  const metrics = usePerformanceMetrics();

  if (isXRActive) {
    return null;
  }

  const getLODLabel = (level: number): string => {
    const labels = ['High Quality', 'Medium Quality', 'Performance Mode'];
    return labels[level] || 'Unknown';
  };

  const getFPSColor = (fps: number): string => {
    if (fps >= 85) return 'text-green-400';
    if (fps >= 72) return 'text-yellow-400';
    if (fps >= 60) return 'text-orange-400';
    return 'text-red-400';
  };

  const getPerformanceRating = (fps: number): string => {
    if (fps >= 85) return '[OK] Excellent';
    if (fps >= 72) return '[OK] Good';
    if (fps >= 60) return '[WARN] Fair';
    return '[BAD] Poor';
  };

  return (
    <div className="absolute bottom-6 left-6 bg-black/90 backdrop-blur-sm rounded-xl p-4 font-mono text-xs text-white shadow-2xl max-w-xs">
      <div className="flex items-center justify-between mb-3 pb-2 border-b border-gray-700">
        <span className="text-sm font-bold text-blue-400">Performance</span>
        <span className={'text-xs ' + getFPSColor(metrics.fps)}>
          {getPerformanceRating(metrics.fps)}
        </span>
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <span className="text-gray-400">FPS:</span>
          <span className={'font-bold text-lg ' + getFPSColor(metrics.fps)}>
            {metrics.fps}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-gray-400">Frame Time:</span>
          <span className="text-white">
            {metrics.frameTime.toFixed(2)}ms
          </span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-gray-400">Draw Calls:</span>
          <span className="text-white">
            {metrics.drawCalls}
          </span>
        </div>

        {metrics.memoryUsage > 0 && (
          <div className="flex items-center justify-between">
            <span className="text-gray-400">Memory:</span>
            <span className="text-white">
              {metrics.memoryUsage}MB
            </span>
          </div>
        )}

        <div className="pt-2 border-t border-gray-700">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-400">Quality:</span>
            <span className="text-white font-medium">
              {getLODLabel(lodLevel)}
            </span>
          </div>

          <div className="flex gap-1">
            {[0, 1, 2].map((level) => (
              <button
                key={level}
                onClick={() => setLODLevel(level)}
                disabled={autoLOD}
                className={
                  'flex-1 py-1 px-2 rounded text-xs transition-all ' +
                  (lodLevel === level 
                    ? 'bg-blue-600 text-white' 
                    : 'bg-gray-700 text-gray-400 hover:bg-gray-600 ') +
                  (autoLOD ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer')
                }
              >
                {['Hi', 'Med', 'Lo'][level]}
              </button>
            ))}
          </div>
        </div>

        <div className="pt-2">
          <button
            onClick={toggleAutoLOD}
            className={
              'w-full py-2 px-3 rounded text-xs font-medium transition-all ' +
              (autoLOD 
                ? 'bg-green-600 text-white' 
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600')
            }
          >
            {autoLOD ? '[OK] Auto LOD ON' : 'Auto LOD OFF'}
          </button>
        </div>
      </div>

      <div className="mt-3 pt-2 border-t border-gray-700 text-center">
        <p className="text-gray-500 text-[10px]">
          Target: 85-90 FPS for Quest 3
        </p>
      </div>
    </div>
  );
}
