import { useState, useEffect } from 'react';

export type ThemeType = 'cosmic' | 'ocean' | 'sunset' | 'light';

interface ThemeConfig {
  background: string;
  cardBg: string;
  textPrimary: string;
  textSecondary: string;
  buttonPrimary: string;
}

const themes: Record<ThemeType, ThemeConfig> = {
  cosmic: {
    background: 'from-indigo-950 via-purple-900 to-black',
    cardBg: 'bg-gray-900',
    textPrimary: 'text-white',
    textSecondary: 'text-gray-300',
    buttonPrimary: 'from-purple-600 to-pink-600',
  },
  ocean: {
    background: 'from-cyan-900 via-blue-800 to-teal-900',
    cardBg: 'bg-blue-900',
    textPrimary: 'text-white',
    textSecondary: 'text-blue-200',
    buttonPrimary: 'from-cyan-600 to-blue-600',
  },
  sunset: {
    background: 'from-orange-900 via-red-800 to-purple-900',
    cardBg: 'bg-red-900',
    textPrimary: 'text-white',
    textSecondary: 'text-orange-200',
    buttonPrimary: 'from-orange-600 to-red-600',
  },
  light: {
    background: 'from-blue-50 via-purple-100 to-pink-50',
    cardBg: 'bg-white',
    textPrimary: 'text-gray-900',
    textSecondary: 'text-gray-600',
    buttonPrimary: 'from-purple-500 to-pink-500',
  },
};

export const useTheme = () => {
  const [currentTheme, setCurrentTheme] = useState<ThemeType>('cosmic');

  useEffect(() => {
    // Load saved theme from localStorage
    const saved = localStorage.getItem('jeeth-theme') as ThemeType;
    if (saved && themes[saved]) {
      setCurrentTheme(saved);
    }
  }, []);

  const setTheme = (theme: ThemeType) => {
    setCurrentTheme(theme);
    localStorage.setItem('jeeth-theme', theme);
  };

  return {
    theme: themes[currentTheme],
    currentTheme,
    setTheme,
    availableThemes: Object.keys(themes) as ThemeType[],
  };
};
