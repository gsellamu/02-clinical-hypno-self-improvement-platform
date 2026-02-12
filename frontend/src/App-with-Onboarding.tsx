// @ts-nocheck

import { useState, useEffect } from 'react';
import { Canvas } from '@react-three/fiber';
import { XRApp } from './features/xr/XRApp';
import { ShambhalaRealm } from './components/ShambhalaRealm';
import { CosmicSpiritualRealm } from './components/CosmicSpiritualRealm';
import { DraggableResizableContainer } from './components/DraggableResizableContainer';
import EPAssessmentQuestionnaire from './components/EPAssessmentQuestionnaire';
import EPResultsDisplay from './components/EPResultsDisplay';
import guruImage from './assets/Jeeth-Blessing.png';
import './App-with-Onboarding.css';

// ==================== ONBOARDING STATE MACHINE ====================
type OnboardingStep = 
  | 'welcome'           // Initial welcome screen
  | 'ep-intro'          // E&P Assessment introduction
  | 'ep-assessment'     // Taking the assessment
  | 'ep-results'        // Viewing results
  | 'profile-complete'  // Confirmation
  | 'main-menu';        // Launch VR/3D

interface UserProfile {
  hasCompletedEP: boolean;
  epResults?: {
    q1Score: number;
    q2Score: number;
    combinedScore: number;
    physicalPercentage: number;
    emotionalPercentage: number;
    profile: string;
    answers: Record<number, boolean>;
  };
  createdAt?: string;
}

// ==================== WELCOME SCREEN ====================
function WelcomeScreen({ onNext }: { onNext: () => void }) {
  return (
    <DraggableResizableContainer>
      <div style={{ textAlign: 'center' }}>
        <div style={{ marginBottom: '30px' }}>
          <div style={{
            display: 'inline-block',
            padding: '20px',
            background: 'linear-gradient(135deg, #ffd700, #9370db, #87ceeb)',
            borderRadius: '50%',
            boxShadow: '0 0 80px rgba(255, 215, 0, 0.7)',
          }}>
            <span style={{ fontSize: '56px' }}>🕉️</span>
          </div>
        </div>

        <h1 style={{
          fontSize: '48px',
          fontWeight: 'bold',
          background: 'linear-gradient(135deg, #ffd700, #f5deb3, #9370db)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: '12px',
        }}>
          Welcome to Jeeth.ai
        </h1>
        
        <p style={{ 
          fontSize: '19px', 
          color: '#f5deb3', 
          fontStyle: 'italic',
          marginBottom: '40px' 
        }}>
          HMI Hypnotherapy • Inner Shambhala • Consciousness Transformation
        </p>

        <div style={{
          background: 'rgba(255, 215, 0, 0.1)',
          border: '2px solid rgba(255, 215, 0, 0.3)',
          borderRadius: '16px',
          padding: '30px',
          marginBottom: '30px',
          textAlign: 'left'
        }}>
          <h2 style={{ 
            color: '#ffd700', 
            fontSize: '24px', 
            marginBottom: '20px',
            textAlign: 'center'
          }}>
            🌟 Your Journey Begins Here
          </h2>
          
          <div style={{ color: '#f5deb3', lineHeight: '1.8', fontSize: '16px' }}>
            <p style={{ marginBottom: '16px' }}>
              Before we begin your mystical journey into consciousness transformation, 
              we need to understand how your mind naturally processes information.
            </p>
            
            <p style={{ marginBottom: '16px' }}>
              This is called your <strong style={{ color: '#ffd700' }}>E&P Profile</strong> 
              (Emotional & Physical Suggestibility), a scientifically-validated assessment 
              developed by Dr. John Kappas, founder of the Hypnosis Motivation Institute.
            </p>
            
            <div style={{
              background: 'rgba(147, 112, 219, 0.2)',
              borderLeft: '4px solid #9370db',
              padding: '16px',
              marginTop: '20px',
              borderRadius: '8px'
            }}>
              <p style={{ margin: 0, fontSize: '15px' }}>
                <strong>Why is this important?</strong><br/>
                Your E&P profile determines how we communicate with your subconscious mind, 
                personalize your hypnotherapy sessions, and guide you through the realms of 
                Inner Shambhala.
              </p>
            </div>
          </div>
        </div>

        <button
          onClick={onNext}
          style={{
            width: '100%',
            padding: '24px',
            borderRadius: '14px',
            fontWeight: 'bold',
            fontSize: '20px',
            background: 'linear-gradient(135deg, #ffd700, #daa520, #9370db)',
            color: 'white',
            border: 'none',
            cursor: 'pointer',
            boxShadow: '0 15px 35px rgba(255, 215, 0, 0.5)',
            transition: 'all 0.3s'
          }}
        >
          <span style={{ marginRight: '12px' }}>✨</span>
          Begin E&P Assessment
          <div style={{ fontSize: '14px', marginTop: '8px', opacity: 0.9 }}>
            10-15 minutes • 36 questions
          </div>
        </button>
      </div>
    </DraggableResizableContainer>
  );
}

// ==================== E&P INTRO SCREEN ====================
function EPIntroScreen({ onStart, onSkip }: { onStart: () => void; onSkip: () => void }) {
  return (
    <DraggableResizableContainer>
      <div style={{ textAlign: 'center' }}>
        <div style={{ marginBottom: '24px' }}>
          <span style={{ fontSize: '64px' }}>🧠</span>
        </div>

        <h1 style={{
          fontSize: '36px',
          color: '#ffd700',
          marginBottom: '16px',
        }}>
          Understanding Your Mind's Language
        </h1>

        <p style={{ 
          fontSize: '16px', 
          color: '#f5deb3', 
          marginBottom: '30px',
          lineHeight: '1.6'
        }}>
          The E&P Assessment reveals whether you are:
        </p>

        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: '1fr 1fr', 
          gap: '20px',
          marginBottom: '30px' 
        }}>
          <div style={{
            background: 'linear-gradient(135deg, rgba(65, 105, 225, 0.2), rgba(147, 112, 219, 0.2))',
            border: '2px solid rgba(65, 105, 225, 0.4)',
            borderRadius: '16px',
            padding: '24px',
            textAlign: 'left'
          }}>
            <div style={{ fontSize: '32px', marginBottom: '12px' }}>🎯</div>
            <h3 style={{ color: '#4169e1', marginBottom: '12px', fontSize: '20px' }}>
              Physical Suggestible
            </h3>
            <p style={{ color: '#f5deb3', fontSize: '14px', lineHeight: '1.6' }}>
              Direct, literal, action-oriented. You respond best to clear, 
              straightforward suggestions and concrete examples.
            </p>
          </div>

          <div style={{
            background: 'linear-gradient(135deg, rgba(147, 112, 219, 0.2), rgba(255, 105, 180, 0.2))',
            border: '2px solid rgba(147, 112, 219, 0.4)',
            borderRadius: '16px',
            padding: '24px',
            textAlign: 'left'
          }}>
            <div style={{ fontSize: '32px', marginBottom: '12px' }}>💜</div>
            <h3 style={{ color: '#9370db', marginBottom: '12px', fontSize: '20px' }}>
              Emotional Suggestible
            </h3>
            <p style={{ color: '#f5deb3', fontSize: '14px', lineHeight: '1.6' }}>
              Inferential, reflective, emotion-focused. You respond best to 
              context, stories, and understanding the deeper meaning.
            </p>
          </div>
        </div>

        <div style={{
          background: 'rgba(255, 215, 0, 0.15)',
          border: '2px solid rgba(255, 215, 0, 0.4)',
          borderRadius: '12px',
          padding: '20px',
          marginBottom: '30px'
        }}>
          <p style={{ color: '#ffd700', fontSize: '15px', margin: 0, lineHeight: '1.7' }}>
            <strong>🔮 Sacred Knowledge:</strong> Some seekers are <strong>Balanced (Somnambulist)</strong> 
            — rare individuals who can flow between both processing styles, adapting to any situation.
          </p>
        </div>

        <div style={{ display: 'flex', gap: '16px' }}>
          <button
            onClick={onStart}
            style={{
              flex: 1,
              padding: '20px',
              borderRadius: '12px',
              fontWeight: 'bold',
              fontSize: '18px',
              background: 'linear-gradient(135deg, #ffd700, #9370db)',
              color: 'white',
              border: 'none',
              cursor: 'pointer',
              boxShadow: '0 10px 25px rgba(255, 215, 0, 0.4)',
            }}
          >
            ✨ Start Assessment
          </button>

          <button
            onClick={onSkip}
            style={{
              padding: '20px',
              borderRadius: '12px',
              fontWeight: '600',
              fontSize: '14px',
              background: 'rgba(255, 255, 255, 0.1)',
              color: '#d4af37',
              border: '1px solid rgba(212, 175, 55, 0.3)',
              cursor: 'pointer',
            }}
          >
            Skip for now
          </button>
        </div>
      </div>
    </DraggableResizableContainer>
  );
}

// ==================== PROFILE COMPLETE SCREEN ====================
function ProfileCompleteScreen({ 
  profile, 
  onContinue 
}: { 
  profile: string; 
  onContinue: () => void;
}) {
  const getProfileEmoji = () => {
    if (profile.includes('Physical')) return '🎯';
    if (profile.includes('Emotional')) return '💜';
    return '🧠';
  };

  return (
    <DraggableResizableContainer>
      <div style={{ textAlign: 'center' }}>
        <div style={{
          fontSize: '80px',
          marginBottom: '24px',
          animation: 'pulse 2s infinite'
        }}>
          {getProfileEmoji()}
        </div>

        <h1 style={{
          fontSize: '42px',
          color: '#ffd700',
          marginBottom: '16px',
        }}>
          Profile Complete! ✨
        </h1>

        <div style={{
          background: 'linear-gradient(135deg, rgba(255, 215, 0, 0.15), rgba(147, 112, 219, 0.15))',
          border: '2px solid rgba(255, 215, 0, 0.4)',
          borderRadius: '16px',
          padding: '30px',
          marginBottom: '30px'
        }}>
          <p style={{ 
            fontSize: '18px', 
            color: '#f5deb3', 
            marginBottom: '20px',
            lineHeight: '1.7'
          }}>
            Your consciousness blueprint has been mapped.<br/>
            You are identified as:
          </p>
          
          <h2 style={{
            fontSize: '32px',
            background: 'linear-gradient(135deg, #ffd700, #9370db)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            fontWeight: 'bold',
            marginBottom: '20px'
          }}>
            {profile}
          </h2>

          <p style={{ 
            fontSize: '15px', 
            color: '#d4af37', 
            lineHeight: '1.8',
            fontStyle: 'italic'
          }}>
            All your hypnotherapy sessions, AI-generated content, and consciousness 
            transformation experiences will now be personalized to your unique 
            information processing style.
          </p>
        </div>

        <button
          onClick={onContinue}
          style={{
            width: '100%',
            padding: '24px',
            borderRadius: '14px',
            fontWeight: 'bold',
            fontSize: '20px',
            background: 'linear-gradient(135deg, #ffd700, #daa520, #9370db)',
            color: 'white',
            border: 'none',
            cursor: 'pointer',
            boxShadow: '0 15px 35px rgba(255, 215, 0, 0.5)',
            transition: 'all 0.3s'
          }}
        >
          <span style={{ marginRight: '12px' }}>🚀</span>
          Enter Inner Shambhala
          <div style={{ fontSize: '14px', marginTop: '8px', opacity: 0.9 }}>
            Your mystical journey awaits
          </div>
        </button>
      </div>
    </DraggableResizableContainer>
  );
}

// ==================== MAIN MENU (EXISTING) ====================
function MainMenuScreen({ 
  onModeSelect, 
  isXRSupported, 
  isChecking,
  userProfile 
}: { 
  onModeSelect: (mode: string) => void;
  isXRSupported: boolean;
  isChecking: boolean;
  userProfile: UserProfile;
}) {
  return (
    <DraggableResizableContainer>
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <div style={{ marginBottom: '16px' }}>
          <div style={{
            display: 'inline-block',
            padding: '20px',
            background: 'linear-gradient(135deg, #ffd700, #9370db, #87ceeb)',
            borderRadius: '50%',
            boxShadow: '0 0 80px rgba(255, 215, 0, 0.7)',
          }}>
            <span style={{ fontSize: '56px' }}>🕉️</span>
          </div>
        </div>
        
        <h1 style={{
          fontSize: '48px',
          fontWeight: 'bold',
          background: 'linear-gradient(135deg, #ffd700, #f5deb3, #9370db)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: '12px',
        }}>
          HMI Hypnotherapy
        </h1>
        
        <p style={{ fontSize: '19px', color: '#f5deb3', fontStyle: 'italic' }}>
          Journey to Inner Shambhala • Consciousness Transformation
        </p>

        {/* Profile Badge */}
        {userProfile.hasCompletedEP && (
          <div style={{
            marginTop: '20px',
            display: 'inline-block',
            padding: '12px 24px',
            background: 'rgba(255, 215, 0, 0.2)',
            border: '2px solid rgba(255, 215, 0, 0.5)',
            borderRadius: '20px',
            color: '#ffd700',
            fontSize: '14px',
            fontWeight: 'bold'
          }}>
            ✨ Profile: {userProfile.epResults?.profile}
          </div>
        )}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '24px' }}>
        <button
          onClick={() => onModeSelect('xr')}
          disabled={isChecking}
          style={{
            width: '100%',
            padding: '20px 32px',
            borderRadius: '14px',
            fontWeight: 'bold',
            fontSize: '19px',
            background: 'linear-gradient(135deg, #ffd700, #daa520, #9370db)',
            color: 'white',
            border: 'none',
            cursor: isChecking ? 'not-allowed' : 'pointer',
            boxShadow: '0 15px 35px rgba(255, 215, 0, 0.5)',
            transition: 'all 0.3s'
          }}
        >
          <span style={{ marginRight: '12px', fontSize: '24px' }}>🥽</span>
          Launch Mystical VR Journey
          {isXRSupported && <div style={{ fontSize: '14px', marginTop: '6px' }}>✨ Quest 3 Ready</div>}
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '14px', margin: '8px 0' }}>
          <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to right, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
          <span style={{ color: '#ffd700', fontWeight: '700', fontSize: '15px' }}>OR</span>
          <div style={{ flex: 1, height: '2px', background: 'linear-gradient(to left, transparent, rgba(212, 175, 55, 0.5), transparent)' }}></div>
        </div>

        <button
          onClick={() => onModeSelect('3d')}
          disabled={isChecking}
          style={{
            width: '100%',
            padding: '20px 32px',
            borderRadius: '14px',
            fontWeight: 'bold',
            fontSize: '19px',
            background: 'linear-gradient(135deg, #2d5016, #3d6b1f, #4a7c2a)',
            color: 'white',
            border: 'none',
            cursor: isChecking ? 'not-allowed' : 'pointer',
            boxShadow: '0 15px 35px rgba(45, 80, 22, 0.5)',
            transition: 'all 0.3s'
          }}
        >
          <span style={{ marginRight: '12px', fontSize: '24px' }}>🌿</span>
          Explore Sacred 3D Realm
          <div style={{ fontSize: '14px', marginTop: '6px' }}>🖱️ Desktop Mode</div>
        </button>
      </div>
    </DraggableResizableContainer>
  );
}

// ==================== MAIN APP WITH ONBOARDING ====================
function App() {
  const [onboardingStep, setOnboardingStep] = useState<OnboardingStep>('welcome');
  const [mode, setMode] = useState('none');
  const [isXRSupported, setIsXRSupported] = useState(false);
  const [isChecking, setIsChecking] = useState(true);
  const [userProfile, setUserProfile] = useState<UserProfile>({
    hasCompletedEP: false
  });

  useEffect(() => {
    const checkXRSupport = async () => {
      if ('xr' in navigator && navigator.xr) {
        try {
          const supported = await navigator.xr.isSessionSupported('immersive-vr');
          setIsXRSupported(supported);
        } catch (err) {
          setIsXRSupported(false);
        }
      } else {
        setIsXRSupported(false);
      }
      setIsChecking(false);
    };
    checkXRSupport();

    // Check if user has completed E&P assessment
    const savedProfile = localStorage.getItem('jeeth_user_profile');
    if (savedProfile) {
      const profile = JSON.parse(savedProfile);
      setUserProfile(profile);
      if (profile.hasCompletedEP) {
        setOnboardingStep('main-menu');
      }
    }
  }, []);

  const handleEPComplete = (results: any) => {
    const newProfile: UserProfile = {
      hasCompletedEP: true,
      epResults: results,
      createdAt: new Date().toISOString()
    };
    
    // Save to localStorage (in production, save to backend)
    localStorage.setItem('jeeth_user_profile', JSON.stringify(newProfile));
    setUserProfile(newProfile);
    
    // Move to results screen
    setOnboardingStep('ep-results');
  };

  const handleResultsViewed = () => {
    setOnboardingStep('profile-complete');
  };

  const handleProfileComplete = () => {
    setOnboardingStep('main-menu');
  };

  const handleModeSelect = (selectedMode: string) => {
    setMode(selectedMode);
  };

  // If VR/3D mode selected, show XRApp
  if (mode !== 'none') {
    return <XRApp mode={mode} userProfile={userProfile} />;
  }

  return (
    <div className="fixed top-0 left-0 w-screen h-screen m-0 p-0 overflow-hidden bg-stone-100">
        
      {/* Background Scene */}
      <div style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', zIndex: 0 }}>
        <Canvas
          camera={{ position: [0, 8, 35], fov: 70 }} 
          gl={{ 
            antialias: true, 
            alpha: false,
            powerPreference: "high-performance"
          }}
          shadows
          style={{ display: 'block', width: '100%', height: '100%' }}
        >
          {/* <CosmicSpiritualRealm /> */}
          {/* <ShambhalaRealm /> */}
        </Canvas>
      </div>

      {/* Gradient Overlay */}
      <div style={{
        position: 'absolute', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 1,
        background: 'radial-gradient(ellipse at center, transparent 0%, rgba(10, 5, 32, 0.2) 100%)',
        pointerEvents: 'none'
      }} />

      {/* Onboarding Flow */}
      <div style={{ position: 'relative', zIndex: 2 }}>
        {onboardingStep === 'welcome' && (
          <WelcomeScreen onNext={() => setOnboardingStep('ep-intro')} />
        )}

        {onboardingStep === 'ep-intro' && (
          <EPIntroScreen 
            onStart={() => setOnboardingStep('ep-assessment')}
            onSkip={() => setOnboardingStep('main-menu')}
          />
        )}

        {onboardingStep === 'ep-assessment' && (
          <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', zIndex: 1000 }}>
            <EPAssessmentQuestionnaire onComplete={handleEPComplete} />
          </div>
        )}

        {onboardingStep === 'ep-results' && userProfile.epResults && (
          <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', zIndex: 1000 }}>
            <EPResultsDisplay 
              results={userProfile.epResults} 
              onRetake={() => setOnboardingStep('ep-assessment')}
            />
            <div style={{ 
              position: 'fixed', 
              bottom: '40px', 
              left: '50%', 
              transform: 'translateX(-50%)',
              zIndex: 1001
            }}>
              <button
                onClick={handleResultsViewed}
                style={{
                  padding: '16px 48px',
                  borderRadius: '12px',
                  fontWeight: 'bold',
                  fontSize: '18px',
                  background: 'linear-gradient(135deg, #ffd700, #9370db)',
                  color: 'white',
                  border: 'none',
                  cursor: 'pointer',
                  boxShadow: '0 10px 30px rgba(255, 215, 0, 0.6)',
                }}
              >
                Continue to Journey ✨
              </button>
            </div>
          </div>
        )}

        {onboardingStep === 'profile-complete' && userProfile.epResults && (
          <ProfileCompleteScreen 
            profile={userProfile.epResults.profile}
            onContinue={handleProfileComplete}
          />
        )}

        {onboardingStep === 'main-menu' && (
          <MainMenuScreen
            onModeSelect={handleModeSelect}
            isXRSupported={isXRSupported}
            isChecking={isChecking}
            userProfile={userProfile}
          />
        )}
      </div>
    </div>
  );
}

export default App;
