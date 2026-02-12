import { useXRStore} from '../stores/xr.store';

export type EnvironmentType = 'soft-room' | 'nature' | 'floating-platform';
export type SessionPhase = 'intro' | 'induction' | 'deepening' | 'therapy' | 'emergence' | 'complete';

interface EnvironmentOption {
  id: EnvironmentType;
  name: string;
  description: string;
  icon: string;
  color: string;
}

const ENVIRONMENTS: EnvironmentOption[] = [
  {
    id: 'soft-room',
    name: 'Soft Lit Room',
    description: 'Warm, cozy sanctuary perfect for deep relaxation',
    icon: '[Room]',
    color: 'from-amber-400 to-orange-500',
  },
  {
    id: 'nature',
    name: 'Nature Forest',
    description: 'Peaceful meadow with gentle sounds of nature',
    icon: '[Tree]',
    color: 'from-green-400 to-emerald-600',
  },
  {
    id: 'floating-platform',
    name: 'Cosmic Platform',
    description: 'Ethereal space environment for transcendent focus',
    icon: '[Star]',
    color: 'from-blue-500 to-purple-600',
  },
];

export function EnvironmentSelector() {
  const { currentEnvironment, setEnvironment, isXRActive } = useXRStore();

  if (isXRActive) {
    return null;
  }

  return (
    <div className="absolute top-6 right-6 bg-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-6 max-w-sm z-10">
      <h3 className="text-xl font-bold mb-4 text-gray-900">
        Choose Your Environment
      </h3>
      
      <div className="space-y-3">
        {ENVIRONMENTS.map((env) => {
          const isSelected = currentEnvironment === env.id;
          
          return (
            <button
              key={env.id}
              onClick={() => setEnvironment(env.id)}
              className={
                'w-full text-left p-4 rounded-xl transition-all duration-300 transform ' +
                (isSelected 
                  ? 'bg-gradient-to-r ' + env.color + ' text-white shadow-lg scale-105' 
                  : 'bg-gray-50 text-gray-800 hover:bg-gray-100 hover:scale-102')
              }
            >
              <div className="flex items-center gap-4">
                <span className="text-3xl">{env.icon}</span>
                <div className="flex-1">
                  <div className="font-semibold text-lg">
                    {env.name}
                  </div>
                  <div className={'text-sm mt-1 ' + (isSelected ? 'text-white/90' : 'text-gray-600')}>
                    {env.description}
                  </div>
                </div>
                {isSelected && (
                  <div className="text-2xl">[OK]</div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      <div className="mt-5 pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-500 text-center">
          Select an environment, then click Enter VR
        </p>
      </div>
    </div>
  );
}
