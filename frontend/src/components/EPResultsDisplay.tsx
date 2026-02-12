import React, { useState } from 'react';
import { motion } from 'framer-motion';
import {
  Brain,
  Heart,
  TrendingUp,
  Sparkles,
  Users,
  Target,
  MessageCircle,
  Book,
  Lightbulb,
  Download,
  Share2,
  RefreshCw
} from 'lucide-react';

interface AssessmentResults {
  q1Score: number;
  q2Score: number;
  combinedScore: number;
  physicalPercentage: number;
  emotionalPercentage: number;
  profile: string;
  answers: Record<number, boolean>;
}

interface EPResultsDisplayProps {
  results: AssessmentResults;
  onRetake: () => void;
}

const EPResultsDisplay: React.FC<EPResultsDisplayProps> = ({ results, onRetake }) => {
  const [activeTab, setActiveTab] = useState<'overview' | 'strengths' | 'communication' | 'growth'>('overview');

  const { physicalPercentage, emotionalPercentage, profile } = results;

  // Determine dominant type
  const isDominantPhysical = physicalPercentage > 60;
  const isDominantEmotional = emotionalPercentage > 60;
  const isBalanced = !isDominantPhysical && !isDominantEmotional;

  // Profile descriptions
  const getProfileDescription = () => {
    if (isDominantPhysical) {
      return {
        title: "Physical Suggestible",
        subtitle: "The Direct Communicator",
        description: "You process information literally and directly. Your mind responds best to clear, straightforward suggestions and concrete examples. You're action-oriented and prefer hands-on learning.",
        color: "from-blue-500 to-indigo-600",
        icon: Target
      };
    } else if (isDominantEmotional) {
      return {
        title: "Emotional Suggestible",
        subtitle: "The Intuitive Processor",
        description: "You process information through inference and emotion. Your mind responds best to context, tone, and feeling. You're reflective and prefer understanding the 'why' behind things.",
        color: "from-purple-500 to-pink-600",
        icon: Heart
      };
    } else {
      return {
        title: "Balanced (Somnambulist)",
        subtitle: "The Adaptive Communicator",
        description: "You have the unique ability to process both directly and emotionally. You can switch between literal and inferential thinking, making you highly adaptable in communication.",
        color: "from-emerald-500 to-teal-600",
        icon: Brain
      };
    }
  };

  const profileInfo = getProfileDescription();
  const ProfileIcon = profileInfo.icon;

  // Communication strengths
  const getCommunicationStrengths = () => {
    if (isDominantPhysical) {
      return [
        {
          title: "Clear & Direct",
          description: "You communicate straightforwardly and appreciate when others do the same",
          icon: MessageCircle
        },
        {
          title: "Action-Oriented",
          description: "You prefer practical examples and hands-on demonstrations",
          icon: Target
        },
        {
          title: "Present-Focused",
          description: "You stay grounded in the here-and-now, making quick decisions",
          icon: Sparkles
        },
        {
          title: "Confident Expression",
          description: "You're comfortable initiating conversations and public speaking",
          icon: Users
        }
      ];
    } else if (isDominantEmotional) {
      return [
        {
          title: "Deep Listener",
          description: "You pick up on tone, subtext, and emotional nuances others miss",
          icon: MessageCircle
        },
        {
          title: "Thoughtful Processor",
          description: "You take time to reflect and understand the deeper meaning",
          icon: Brain
        },
        {
          title: "Empathic Connection",
          description: "You naturally attune to others' emotions and create safe spaces",
          icon: Heart
        },
        {
          title: "Creative Thinker",
          description: "You excel at seeing patterns, metaphors, and connections",
          icon: Lightbulb
        }
      ];
    } else {
      return [
        {
          title: "Versatile Communicator",
          description: "You adapt your style to match different people and situations",
          icon: MessageCircle
        },
        {
          title: "Balanced Processing",
          description: "You can think both literally and abstractly with ease",
          icon: Brain
        },
        {
          title: "Bridge Builder",
          description: "You help others with different styles understand each other",
          icon: Users
        },
        {
          title: "Comprehensive Learning",
          description: "You benefit from multiple learning approaches simultaneously",
          icon: Book
        }
      ];
    }
  };

  // Growth opportunities
  const getGrowthOpportunities = () => {
    if (isDominantPhysical) {
      return [
        {
          title: "Practice Active Listening",
          description: "Take time to hear not just words, but tone and emotion behind them",
          tip: "Before responding, ask yourself: 'What feeling is this person expressing?'"
        },
        {
          title: "Explore Subtext",
          description: "Look beyond literal meanings to understand deeper implications",
          tip: "In conversations, consider: 'What are they really saying?'"
        },
        {
          title: "Embrace Reflection",
          description: "Build in time to process experiences emotionally, not just logically",
          tip: "After important conversations, journal about how you felt, not just what happened"
        }
      ];
    } else if (isDominantEmotional) {
      return [
        {
          title: "Take Information at Face Value",
          description: "Practice accepting direct statements without over-analyzing",
          tip: "When someone says something, try believing that's exactly what they mean"
        },
        {
          title: "Build Confidence in Action",
          description: "Take small steps toward being more spontaneous and direct",
          tip: "Start conversations before you're 'ready' - trust your instincts"
        },
        {
          title: "Strengthen Your Voice",
          description: "Practice stating your needs and opinions clearly and directly",
          tip: "Use 'I' statements: 'I want...', 'I need...', 'I think...'"
        }
      ];
    } else {
      return [
        {
          title: "Leverage Your Flexibility",
          description: "Recognize when to use each processing style intentionally",
          tip: "Match your communication style to your audience's preferences"
        },
        {
          title: "Avoid Over-Adaptation",
          description: "Don't lose yourself by constantly adapting to others",
          tip: "Check in regularly: 'Is this what I really think/feel?'"
        },
        {
          title: "Teach Others",
          description: "Help people understand different communication styles",
          tip: "You can be a bridge between Physical and Emotional Suggestibles"
        }
      ];
    }
  };

  // Optimal communication tips
  const getCommunicationTips = () => {
    if (isDominantPhysical) {
      return {
        forYou: [
          "Speak directly and state exactly what you mean",
          "Use concrete examples and demonstrations",
          "Focus on 'what' and 'how' rather than 'why'",
          "Make decisions quickly based on facts"
        ],
        toYou: [
          "Be clear and concise - avoid beating around the bush",
          "Show, don't just tell (use examples and visuals)",
          "Get to the point quickly without excessive context",
          "Give action steps rather than abstract concepts"
        ]
      };
    } else if (isDominantEmotional) {
      return {
        forYou: [
          "Share the context and 'why' behind your points",
          "Pay attention to tone and emotional subtext",
          "Take time to process before responding",
          "Express feelings alongside facts"
        ],
        toYou: [
          "Provide context and background before getting to the point",
          "Use stories, metaphors, and emotional connections",
          "Be patient with their processing time",
          "Pay attention to how you say things, not just what you say"
        ]
      };
    } else {
      return {
        forYou: [
          "Assess your audience and adapt accordingly",
          "Use both direct statements and emotional context",
          "Balance action with reflection",
          "Help translate between different communication styles"
        ],
        toYou: [
          "You're flexible - communicators can use either style",
          "Don't hesitate to ask for what you need",
          "Your adaptability is a strength, not a weakness",
          "You can code-switch between literal and emotional communication"
        ]
      };
    }
  };

  const strengths = getCommunicationStrengths();
  const growth = getGrowthOpportunities();
  const commTips = getCommunicationTips();

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 p-4 md:p-8">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", duration: 0.6 }}
            className="inline-block mb-4"
          >
            <div className={`w-24 h-24 rounded-full bg-gradient-to-r ${profileInfo.color} flex items-center justify-center shadow-2xl`}>
              <ProfileIcon className="w-12 h-12 text-white" />
            </div>
          </motion.div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Your Mind's Blueprint
          </h1>
          <p className="text-lg text-gray-600">
            Understanding how you process the world
          </p>
        </motion.div>

        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
          className="bg-white rounded-2xl shadow-2xl p-8 mb-8"
        >
          <div className="text-center mb-6">
            <h2 className={`text-3xl font-bold bg-gradient-to-r ${profileInfo.color} bg-clip-text text-transparent mb-2`}>
              {profileInfo.title}
            </h2>
            <p className="text-xl text-gray-600 font-medium mb-4">
              {profileInfo.subtitle}
            </p>
            <p className="text-gray-700 leading-relaxed max-w-2xl mx-auto">
              {profileInfo.description}
            </p>
          </div>

          {/* Percentage Visualization */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
            {/* Physical Suggestibility */}
            <div className="relative">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700 flex items-center gap-2">
                  <Target className="w-4 h-4 text-blue-600" />
                  Physical Suggestibility
                </span>
                <span className="text-2xl font-bold text-blue-600">
                  {physicalPercentage}%
                </span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${physicalPercentage}%` }}
                  transition={{ duration: 1, delay: 0.5 }}
                  className="h-full bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full"
                />
              </div>
              <p className="text-xs text-gray-600 mt-2">
                Direct, literal, action-oriented processing
              </p>
            </div>

            {/* Emotional Suggestibility */}
            <div className="relative">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700 flex items-center gap-2">
                  <Heart className="w-4 h-4 text-purple-600" />
                  Emotional Suggestibility
                </span>
                <span className="text-2xl font-bold text-purple-600">
                  {emotionalPercentage}%
                </span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${emotionalPercentage}%` }}
                  transition={{ duration: 1, delay: 0.7 }}
                  className="h-full bg-gradient-to-r from-purple-500 to-pink-600 rounded-full"
                />
              </div>
              <p className="text-xs text-gray-600 mt-2">
                Inferential, reflective, emotion-based processing
              </p>
            </div>
          </div>
        </motion.div>

        {/* Tabs */}
        <div className="flex gap-2 mb-6 overflow-x-auto">
          {[
            { key: 'overview', label: 'Overview', icon: Brain },
            { key: 'strengths', label: 'Your Strengths', icon: Sparkles },
            { key: 'communication', label: 'Communication', icon: MessageCircle },
            { key: 'growth', label: 'Growth Areas', icon: TrendingUp }
          ].map(tab => {
            const TabIcon = tab.icon;
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key as any)}
                className={`flex items-center gap-2 px-4 py-3 rounded-lg font-medium transition-all whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'bg-white text-indigo-600 shadow-md'
                    : 'bg-white/50 text-gray-600 hover:bg-white/80'
                }`}
              >
                <TabIcon className="w-4 h-4" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Tab Content */}
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          {activeTab === 'overview' && (
            <div className="bg-white rounded-2xl shadow-lg p-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                What This Means For You
              </h3>
              <div className="space-y-6">
                <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-xl p-6">
                  <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Lightbulb className="w-5 h-5 text-indigo-600" />
                    Your Processing Style
                  </h4>
                  <p className="text-gray-700 leading-relaxed">
                    {profileInfo.description}
                  </p>
                </div>

                <div className="grid md:grid-cols-2 gap-6">
                  <div className="bg-blue-50 rounded-xl p-6">
                    <h4 className="font-semibold text-blue-900 mb-3">
                      Best Learning Methods
                    </h4>
                    <ul className="space-y-2 text-sm text-blue-800">
                      {isDominantPhysical ? (
                        <>
                          <li>• Hands-on demonstrations</li>
                          <li>• Step-by-step instructions</li>
                          <li>• Visual examples and diagrams</li>
                          <li>• Practice and repetition</li>
                        </>
                      ) : isDominantEmotional ? (
                        <>
                          <li>• Stories and case studies</li>
                          <li>• Understanding the context first</li>
                          <li>• Emotional connections to material</li>
                          <li>• Time for reflection and processing</li>
                        </>
                      ) : (
                        <>
                          <li>• Multi-modal approaches</li>
                          <li>• Both concrete and abstract examples</li>
                          <li>• Flexible learning environments</li>
                          <li>• Variety in teaching methods</li>
                        </>
                      )}
                    </ul>
                  </div>

                  <div className="bg-purple-50 rounded-xl p-6">
                    <h4 className="font-semibold text-purple-900 mb-3">
                      Ideal Work Environment
                    </h4>
                    <ul className="space-y-2 text-sm text-purple-800">
                      {isDominantPhysical ? (
                        <>
                          <li>• Clear expectations and goals</li>
                          <li>• Immediate feedback</li>
                          <li>• Active collaboration</li>
                          <li>• Tangible results</li>
                        </>
                      ) : isDominantEmotional ? (
                        <>
                          <li>• Supportive team culture</li>
                          <li>• Time for deep work</li>
                          <li>• Meaning-driven projects</li>
                          <li>• Psychological safety</li>
                        </>
                      ) : (
                        <>
                          <li>• Flexible work arrangements</li>
                          <li>• Diverse project types</li>
                          <li>• Cross-functional teams</li>
                          <li>• Autonomy and variety</li>
                        </>
                      )}
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'strengths' && (
            <div className="bg-white rounded-2xl shadow-lg p-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                Your Communication Superpowers
              </h3>
              <div className="grid md:grid-cols-2 gap-6">
                {strengths.map((strength, index) => {
                  const StrengthIcon = strength.icon;
                  return (
                    <motion.div
                      key={strength.title}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="bg-gradient-to-br from-emerald-50 to-teal-50 rounded-xl p-6 border border-emerald-200"
                    >
                      <div className="flex items-start gap-4">
                        <div className="p-3 bg-emerald-100 rounded-lg">
                          <StrengthIcon className="w-6 h-6 text-emerald-600" />
                        </div>
                        <div>
                          <h4 className="font-semibold text-gray-900 mb-2">
                            {strength.title}
                          </h4>
                          <p className="text-sm text-gray-700">
                            {strength.description}
                          </p>
                        </div>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </div>
          )}

          {activeTab === 'communication' && (
            <div className="bg-white rounded-2xl shadow-lg p-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                Communication Guide
              </h3>
              <div className="grid md:grid-cols-2 gap-6">
                <div className="bg-blue-50 rounded-xl p-6">
                  <h4 className="font-semibold text-blue-900 mb-4 flex items-center gap-2">
                    <MessageCircle className="w-5 h-5" />
                    When You Communicate
                  </h4>
                  <ul className="space-y-3">
                    {commTips.forYou.map((tip, index) => (
                      <li key={index} className="flex items-start gap-3 text-sm text-blue-800">
                        <span className="text-blue-600 font-bold">→</span>
                        <span>{tip}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="bg-purple-50 rounded-xl p-6">
                  <h4 className="font-semibold text-purple-900 mb-4 flex items-center gap-2">
                    <Users className="w-5 h-5" />
                    Communicating With You
                  </h4>
                  <ul className="space-y-3">
                    {commTips.toYou.map((tip, index) => (
                      <li key={index} className="flex items-start gap-3 text-sm text-purple-800">
                        <span className="text-purple-600 font-bold">→</span>
                        <span>{tip}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'growth' && (
            <div className="bg-white rounded-2xl shadow-lg p-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                Areas for Growth & Development
              </h3>
              <div className="space-y-6">
                {growth.map((item, index) => (
                  <motion.div
                    key={item.title}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="bg-gradient-to-r from-orange-50 to-amber-50 rounded-xl p-6 border border-orange-200"
                  >
                    <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                      <TrendingUp className="w-5 h-5 text-orange-600" />
                      {item.title}
                    </h4>
                    <p className="text-gray-700 mb-3">{item.description}</p>
                    <div className="bg-white rounded-lg p-3 border-l-4 border-orange-400">
                      <p className="text-sm text-gray-600">
                        <strong className="text-orange-700">Try this:</strong> {item.tip}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>
          )}
        </motion.div>

        {/* Action Buttons */}
        <div className="mt-8 flex flex-wrap gap-4 justify-center">
          <button
            onClick={onRetake}
            className="flex items-center gap-2 px-6 py-3 bg-white text-indigo-600 rounded-lg font-medium hover:bg-indigo-50 transition-colors shadow-md"
          >
            <RefreshCw className="w-5 h-5" />
            Retake Assessment
          </button>
          <button className="flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 transition-colors shadow-md">
            <Download className="w-5 h-5" />
            Download Results
          </button>
          <button className="flex items-center gap-2 px-6 py-3 bg-purple-600 text-white rounded-lg font-medium hover:bg-purple-700 transition-colors shadow-md">
            <Share2 className="w-5 h-5" />
            Share Profile
          </button>
        </div>
      </div>
    </div>
  );
};

export default EPResultsDisplay;
