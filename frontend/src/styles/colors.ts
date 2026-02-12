// Jeeth.ai Color Palette
// Import and use these constants for consistency

export const JeethColors = {
  // Background Gradients
  backgrounds: {
    cosmic: 'from-indigo-950 via-purple-900 to-black',
    ocean: 'from-cyan-900 via-blue-800 to-teal-900',
    sunset: 'from-orange-900 via-red-800 to-purple-900',
    forest: 'from-green-900 via-emerald-800 to-teal-900',
    twilight: 'from-purple-900 via-indigo-900 to-blue-900',
    light: 'from-blue-50 via-purple-100 to-pink-50',
  },

  // Profile Colors
  profiles: {
    physical: {
      gradient: 'from-cyan-500 to-blue-500',
      solid: 'bg-cyan-600',
      text: 'text-cyan-400',
      border: 'border-cyan-500',
    },
    emotional: {
      gradient: 'from-purple-500 to-pink-500',
      solid: 'bg-purple-600',
      text: 'text-purple-400',
      border: 'border-purple-500',
    },
    balanced: {
      gradient: 'from-green-500 to-teal-500',
      solid: 'bg-green-600',
      text: 'text-green-400',
      border: 'border-green-500',
    },
  },

  // UI Elements
  ui: {
    cardDark: 'bg-gray-900',
    cardLight: 'bg-white',
    cardTransparent: 'bg-white/5 backdrop-blur-md',
    cardSolid: 'bg-gray-800/90',
    
    textPrimary: 'text-white',
    textSecondary: 'text-gray-300',
    textMuted: 'text-gray-500',
    
    buttonYes: 'from-green-600 to-emerald-600',
    buttonNo: 'from-red-600 to-pink-600',
    buttonPrimary: 'from-purple-600 to-pink-600',
    buttonSecondary: 'bg-gray-700',
  },
};

// Example Usage:
// <div className={`bg-gradient-to-br ${JeethColors.backgrounds.cosmic}`}>

