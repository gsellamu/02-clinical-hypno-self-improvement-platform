

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Brain, 
  HelpCircle, 
  ChevronRight, 
  ChevronLeft, 
  CheckCircle2,
  Sparkles,
  Info,
  Moon,
  Users,
  Eye,
  Heart,
  MessageCircle,
  Smile,
  UserPlus,
  Book,
  Coffee,
  Zap,
  Star,
  Wind,
  Target,
  ThumbsUp,
  Lightbulb
} from 'lucide-react';

// =====================================================
// TYPE DEFINITIONS
// =====================================================

interface EPQuestion {
  id: number;
  text: string;
  category: 'physical' | 'emotional';
  questionnaire: 1 | 2;
  weight: 10 | 5;
  tooltip: string;
  example?: string;
  icon: unknown;
}

interface EPAssessmentQuestionnaireProps {
  userId: string;
  onComplete: (results: ScoringResult) => void;
  onBack?: () => void;
}

interface ScoringResult {
  success: boolean;
  profile: 'Physical Suggestible' | 'Emotional Suggestible' | 'Somnambulistic' | 'Intellectual Suggestible';
  physicalPercentage: number;
  emotionalPercentage: number;
  q1Score: number;
  q2Score: number;
  combinedScore: number;
  answers: Record<number, boolean>;
  completedAt: string;
  userId: string;
  methodology: string;
}

// =====================================================
// HMI E&P SUGGESTIBILITY QUESTIONS (36 Questions)
// Based on authentic HMI Suggestibility Questionnaires
// =====================================================

const EP_QUESTIONS: EPQuestion[] = [
  // ========================================
  // QUESTIONNAIRE 1: PHYSICAL SUGGESTIBILITY INDICATORS (1-18)
  // Questions 1-2: 10 points each
  // Questions 3-18: 5 points each
  // ========================================
  
  {
    id: 1,
    text: "Have you ever walked in your sleep during your adult life?",
    category: "physical",
    questionnaire: 1,
    weight: 10,
    tooltip: "Sleepwalking in adulthood indicates a strong connection between subconscious mind and physical body, suggesting direct physical response patterns.",
    example: "If you've experienced sleepwalking as an adult, your subconscious may directly control physical actions without conscious awareness.",
    icon: Moon
  },
  
  {
    id: 2,
    text: "As a teenager, did you feel comfortable expressing your feelings to one or both of your parents?",
    category: "physical",
    questionnaire: 1,
    weight: 10,
    tooltip: "Comfort with direct emotional expression in formative years indicates literal, straightforward communication patterns.",
    example: "Being able to say 'I'm angry' or 'I love you' directly to parents suggests direct communication style.",
    icon: Heart
  },
  
  {
    id: 3,
    text: "Do you have a tendency to look directly into a person's eyes and/or move closely to them when discussing an interesting subject?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Direct eye contact and physical closeness indicate comfort with literal, face-to-face interaction.",
    example: "Maintaining steady eye contact during conversations shows direct engagement style.",
    icon: Eye
  },
  
  {
    id: 4,
    text: "Do you feel that most people, when you first meet them, are uncritical of your appearance?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Feeling accepted by others indicates confidence in direct social situations.",
    example: "Not worrying about judgment when meeting new people suggests comfort with direct interaction.",
    icon: Smile
  },
  
  {
    id: 5,
    text: "In a group situation with people you have just met, would you feel comfortable drawing attention to yourself by initiating a conversation?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Willingness to take direct action in social situations indicates physical confidence.",
    example: "Being the first to speak up in a group of strangers shows direct communication comfort.",
    icon: UserPlus
  },
  
  {
    id: 6,
    text: "Do you feel comfortable holding hands or hugging someone you are in a relationship with in front of other people?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with public physical affection indicates direct expression of feelings through body.",
    example: "Holding hands in public shows comfort with physical demonstration of emotions.",
    icon: Heart
  },
  
  {
    id: 7,
    text: "When someone talks about feeling warm physically, do you begin to feel warm also?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Physical empathy and immediate body response to suggestions indicates direct physical suggestibility.",
    example: "Feeling warm when someone describes heat shows immediate physical response to verbal cues.",
    icon: Zap
  },
  
  {
    id: 8,
    text: "Do you tend to occasionally tune out when someone is talking to you because you are anxious to come up with your side, and, at times, not hear what the other person said?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Focusing on immediate response rather than analysis indicates direct, action-oriented thinking.",
    example: "Preparing your response while someone talks shows immediate reaction patterns.",
    icon: MessageCircle
  },
  
  {
    id: 9,
    text: "Do you feel that you learn and comprehend better by seeing and/or reading than by hearing?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Visual learning preference indicates direct, literal information processing.",
    example: "Preferring to read instructions rather than listen to them shows direct learning style.",
    icon: Book
  },
  
  {
    id: 10,
    text: "In a new class or lecture situation, do you usually feel comfortable asking questions in front of the group?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with direct questioning indicates confidence in straightforward communication.",
    example: "Raising your hand to ask questions shows comfort with direct interaction.",
    icon: HelpCircle
  },
  
  {
    id: 11,
    text: "When expressing your ideas, do you find it important to relate all the details leading up to the subject so the other person can understand it completely?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Providing complete details indicates literal, thorough communication style.",
    example: "Giving step-by-step explanations shows preference for complete, direct information.",
    icon: MessageCircle
  },
  
  {
    id: 12,
    text: "Do you enjoy relating to children?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with children indicates ease with direct, uncomplicated interaction.",
    example: "Enjoying time with kids shows comfort with straightforward, literal communication.",
    icon: Users
  },
  
  {
    id: 13,
    text: "Do you find it easy to be at ease and comfortable with your body movements, even when faced with unfamiliar people and circumstances?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Body confidence in new situations indicates strong mind-body connection.",
    example: "Moving naturally in new situations shows physical comfort and confidence.",
    icon: Wind
  },
  
  {
    id: 14,
    text: "Do you prefer reading fiction rather than non-fiction?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Fiction preference can indicate comfort with direct emotional experience through stories.",
    example: "Enjoying novels shows engagement with direct narrative and emotional content.",
    icon: Book
  },
  
  {
    id: 15,
    text: "If you were to imagine sucking on a sour, bitter, juicy, yellow lemon, would your mouth water?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Immediate physical response to mental imagery indicates strong mind-body connection.",
    example: "Salivating when thinking about lemons shows direct physical response to suggestions.",
    icon: Zap
  },
  
  {
    id: 16,
    text: "If you feel that you deserve to be complimented for something well done, do you feel comfortable if the compliment is given to you in front of other people?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with public recognition indicates confidence in direct attention.",
    example: "Enjoying public praise shows comfort with direct acknowledgment.",
    icon: Star
  },
  
  {
    id: 17,
    text: "Do you feel that you are a good conversationalist?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Confidence in communication indicates comfort with direct verbal interaction.",
    example: "Feeling skilled at conversation shows confidence in direct communication.",
    icon: MessageCircle
  },
  
  {
    id: 18,
    text: "Do you feel comfortable when complimentary attention is drawn to your physical body or appearance?",
    category: "physical",
    questionnaire: 1,
    weight: 5,
    tooltip: "Comfort with physical compliments indicates acceptance of direct body-focused attention.",
    example: "Enjoying compliments about appearance shows comfort with direct physical attention.",
    icon: Smile
  },
  
  // ========================================
  // QUESTIONNAIRE 2: EMOTIONAL SUGGESTIBILITY INDICATORS (19-36)
  // Questions 19-20: 10 points each
  // Questions 21-36: 5 points each
  // ========================================
  
  {
    id: 19,
    text: "Have you ever awakened in the middle of the night and felt that you could not move your body and/or talk?",
    category: "emotional",
    questionnaire: 2,
    weight: 10,
    tooltip: "Sleep paralysis indicates mind-body disconnection characteristic of emotional suggestibility.",
    example: "Experiencing inability to move while conscious shows mental awareness separate from physical control.",
    icon: Moon
  },
  
  {
    id: 20,
    text: "As a child, did you feel that you were more affected by your parents' tone of voice, than by what they actually said?",
    category: "emotional",
    questionnaire: 2,
    weight: 10,
    tooltip: "Sensitivity to tone over words indicates inferential, analytical processing of communication.",
    example: "Reacting more to how something was said than what was said shows inferential learning.",
    icon: MessageCircle
  },
  
  {
    id: 21,
    text: "If someone you are associated with talks about a fear that you have experienced before, do you have a tendency to have an apprehensive or fearful feeling also?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Mental empathy and analytical processing of others' emotions indicates emotional suggestibility.",
    example: "Feeling anxious when hearing about fears shows mental processing of emotional content.",
    icon: Brain
  },
  
  {
    id: 22,
    text: "After having an argument with someone, do you have a tendency to dwell on what you could or should have said?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Analytical reflection after events indicates inferential, thought-based processing.",
    example: "Replaying conversations and thinking of better responses shows analytical thinking style.",
    icon: Brain
  },
  
  {
    id: 23,
    text: "Do you tend to occasionally tune out when someone is talking to you and, therefore, do not hear what was said because your mind drifts to something totally unrelated?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Mental drift indicates internal focus and analytical thinking separate from immediate stimuli.",
    example: "Finding yourself thinking about other things during conversation shows internal mental focus.",
    icon: Wind
  },
  
  {
    id: 24,
    text: "Do you sometimes desire to be complimented for a job well done, but feel embarrassed or uncomfortable when complimented?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Internal desire conflicting with external comfort indicates analytical self-awareness.",
    example: "Wanting praise but feeling awkward when receiving it shows internal conflict.",
    icon: Star
  },
  
  {
    id: 25,
    text: "Do you often have a fear or dread of not being able to carry on a conversation with someone you've just met?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Social anxiety and anticipatory thinking indicates analytical processing of interactions.",
    example: "Worrying about conversations before they happen shows anticipatory analytical thinking.",
    icon: Users
  },
  
  {
    id: 26,
    text: "Do you feel self-conscious when attention is drawn to your physical body or appearance?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with physical attention indicates mind-body disconnection.",
    example: "Feeling awkward about appearance compliments shows analytical self-consciousness.",
    icon: Eye
  },
  
  {
    id: 27,
    text: "If you had a choice, would you rather avoid being around children most of the time?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Preference for complex over simple interaction indicates analytical nature.",
    example: "Preferring adult conversation shows preference for inferential communication.",
    icon: Users
  },
  
  {
    id: 28,
    text: "Do you feel that you are not relaxed or loose in body movements, especially when faced with unfamiliar people or circumstances?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Physical tension in new situations indicates analytical processing creating body awareness.",
    example: "Feeling stiff or awkward in new situations shows mind-body disconnection under stress.",
    icon: Wind
  },
  
  {
    id: 29,
    text: "Do you prefer reading non-fiction rather than fiction?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Preference for factual information indicates analytical, intellectual approach.",
    example: "Choosing educational books over novels shows analytical learning preference.",
    icon: Book
  },
  
  {
    id: 30,
    text: "If someone describes a very bitter taste, do you have difficulty experiencing the physical feeling of it?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Difficulty translating mental imagery to physical sensation indicates mind-body disconnection.",
    example: "Not feeling taste sensations from descriptions shows analytical vs. physical processing.",
    icon: Coffee
  },
  
  {
    id: 31,
    text: "Do you generally feel that you see yourself less favorably than others see you?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Analytical self-criticism indicates inferential, thought-based self-perception.",
    example: "Being harder on yourself than others are shows analytical internal focus.",
    icon: Brain
  },
  
  {
    id: 32,
    text: "Do you tend to feel awkward or self-conscious initiating touch (holding hands, kissing, etc.) with someone you are in a relationship with, in front of other people?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with public physical affection indicates analytical awareness of social context.",
    example: "Feeling awkward about PDA shows analytical processing of social appropriateness.",
    icon: Heart
  },
  
  {
    id: 33,
    text: "In a new class or lecture situation, do you usually feel uncomfortable asking questions in front of the group, even though you may desire further explanation?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Internal desire conflicting with external action indicates analytical self-consciousness.",
    example: "Wanting to ask but feeling too self-conscious shows analytical internal conflict.",
    icon: HelpCircle
  },
  
  {
    id: 34,
    text: "Do you feel uneasy if someone you have just met looks you directly in the eyes when talking to you, especially if the conversation is about you?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Discomfort with direct eye contact indicates preference for less intense interaction.",
    example: "Finding direct eye contact uncomfortable shows analytical self-awareness.",
    icon: Eye
  },
  
  {
    id: 35,
    text: "In a group situation with people you have just met, would you feel uncomfortable drawing attention to yourself by initiating a conversation?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Reluctance to initiate indicates analytical processing of social dynamics.",
    example: "Preferring to observe before participating shows analytical assessment of situations.",
    icon: Users
  },
  
  {
    id: 36,
    text: "If you are in a relationship, or are very close to someone, do you find it difficult or embarrassing to verbalize your love for them?",
    category: "emotional",
    questionnaire: 2,
    weight: 5,
    tooltip: "Difficulty with direct emotional expression indicates inferential communication style.",
    example: "Finding it hard to say 'I love you' shows preference for showing vs. telling.",
    icon: Heart
  }
];

// =====================================================
// HMI LOOKUP TABLE (Complete Grid from Score Chart)
// Maps Q1 Score + Combined Score → Physical Suggestibility %
// =====================================================

const HMI_LOOKUP_TABLE: Record<number, Record<number, number>> = {
  100: {50:100,55:100,60:95,65:91,70:87,75:83,80:80,85:77,90:74,95:71,100:69,105:67,110:65,115:63,120:61,125:59,130:57,135:56,140:54,145:53,150:51,155:50,160:49,165:48,170:47,175:46,180:45,185:44,190:43,195:42,200:41},
  95: {50:100,55:100,60:95,65:90,70:86,75:83,80:79,85:76,90:73,95:70,100:68,105:66,110:63,115:61,120:59,125:58,130:56,135:54,140:53,145:51,150:50,155:49,160:48,165:47,170:46,175:45,180:44,185:43,190:42,195:41,200:40},
  90: {50:100,55:100,60:95,65:90,70:86,75:82,80:78,85:75,90:72,95:69,100:67,105:64,110:62,115:60,120:58,125:56,130:55,135:53,140:51,145:50,150:49,155:47,160:46,165:45,170:44,175:43,180:42,185:41,190:40,195:39,200:38},
  85: {50:100,55:100,60:94,65:89,70:85,75:81,80:77,85:74,90:71,95:68,100:65,105:63,110:61,115:59,120:57,125:55,130:53,135:52,140:50,145:49,150:47,155:46,160:45,165:44,170:43,175:42,180:41,185:40,190:39,195:38,200:37},
  80: {50:100,55:100,60:94,65:89,70:84,75:80,80:76,85:73,90:70,95:67,100:64,105:62,110:59,115:57,120:55,125:53,130:52,135:50,140:48,145:47,150:46,155:44,160:43,165:42,170:41,175:40,180:39,185:38,190:37,195:36,200:35},
  75: {50:100,55:100,60:94,65:88,70:83,75:79,80:75,85:71,90:68,95:65,100:63,105:60,110:58,115:56,120:54,125:52,130:50,135:48,140:47,145:45,150:44,155:43,160:42,165:41,170:39,175:38,180:38,185:37,190:36,195:35,200:34},
  70: {50:100,55:100,60:93,65:88,70:82,75:78,80:74,85:70,90:67,95:64,100:61,105:58,110:56,115:54,120:52,125:50,130:48,135:47,140:45,145:44,150:42,155:41,160:40,165:39,170:38,175:37,180:36,185:35,190:34,195:33,200:32},
  65: {50:100,55:100,60:93,65:87,70:81,75:76,80:72,85:68,90:65,95:62,100:59,105:57,110:54,115:52,120:50,125:48,130:46,135:45,140:43,145:42,150:41,155:39,160:38,165:37,170:36,175:35,180:34,185:33,190:33,195:32,200:31},
  60: {50:100,55:100,60:92,65:86,70:80,75:75,80:71,85:67,90:63,95:60,100:57,105:55,110:52,115:50,120:48,125:46,130:44,135:43,140:41,145:40,150:39,155:38,160:36,165:35,170:34,175:33,180:32,185:32,190:31,195:30,200:29},
  55: {50:100,55:100,60:92,65:85,70:79,75:73,80:69,85:65,90:61,95:58,100:55,105:52,110:50,115:48,120:46,125:44,130:42,135:41,140:39,145:38,150:37,155:35,160:34,165:33,170:32,175:31,180:31,185:30,190:29,195:28,200:28},
  50: {50:100,55:100,60:91,65:83,70:77,75:71,80:67,85:63,90:59,95:56,100:53,105:50,110:48,115:45,120:43,125:42,130:40,135:38,140:37,145:36,150:34,155:33,160:32,165:31,170:30,175:29,180:29,185:28,190:27,195:26,200:26},
  45: {50:90,55:90,60:82,65:75,70:69,75:64,80:60,85:56,90:53,95:50,100:47,105:45,110:43,115:41,120:39,125:38,130:36,135:35,140:33,145:32,150:31,155:30,160:29,165:28,170:27,175:26,180:26,185:25,190:24,195:24,200:23},
  40: {50:80,55:80,60:73,65:67,70:62,75:57,80:53,85:50,90:47,95:44,100:42,105:40,110:38,115:36,120:35,125:33,130:32,135:31,140:30,145:29,150:28,155:27,160:26,165:25,170:24,175:24,180:23,185:22,190:22,195:21,200:21},
  35: {50:70,55:70,60:64,65:58,70:54,75:50,80:47,85:44,90:41,95:39,100:37,105:35,110:33,115:32,120:30,125:29,130:28,135:27,140:26,145:25,150:24,155:23,160:23,165:22,170:21,175:21,180:20,185:19,190:19,195:18,200:18},
  30: {50:60,55:60,60:55,65:50,70:46,75:43,80:40,85:38,90:35,95:33,100:32,105:30,110:29,115:27,120:26,125:25,130:24,135:23,140:22,145:21,150:21,155:20,160:19,165:19,170:18,175:18,180:17,185:17,190:16,195:16,200:15},
  25: {50:50,55:50,60:45,65:42,70:38,75:36,80:33,85:31,90:29,95:28,100:26,105:25,110:24,115:23,120:22,125:21,130:20,135:19,140:19,145:18,150:17,155:17,160:16,165:16,170:15,175:15,180:14,185:14,190:14,195:13,200:13},
  20: {50:40,55:40,60:36,65:33,70:31,75:29,80:27,85:25,90:24,95:22,100:21,105:20,110:19,115:18,120:17,125:17,130:16,135:15,140:15,145:14,150:14,155:13,160:13,165:13,170:12,175:12,180:11,185:11,190:11,195:11,200:10},
  15: {50:30,55:30,60:27,65:25,70:23,75:21,80:20,85:19,90:18,95:17,100:16,105:15,110:14,115:14,120:13,125:13,130:12,135:12,140:11,145:11,150:10,155:10,160:10,165:9,170:9,175:9,180:9,185:8,190:8,195:8,200:8},
  10: {50:20,55:20,60:18,65:17,70:15,75:14,80:13,85:13,90:12,95:11,100:11,105:10,110:10,115:9,120:9,125:8,130:8,135:8,140:7,145:7,150:7,155:7,160:6,165:6,170:6,175:6,180:6,185:6,190:5,195:5,200:5},
  5: {50:10,55:10,60:9,65:8,70:8,75:7,80:7,85:6,90:6,95:6,100:5,105:5,110:5,115:5,120:4,125:4,130:4,135:4,140:4,145:4,150:3,155:3,160:3,165:3,170:3,175:3,180:3,185:3,190:3,195:3,200:3},
  0: {50:0,55:0,60:0,65:0,70:0,75:0,80:0,85:0,90:0,95:0,100:0,105:0,110:0,115:0,120:0,125:0,130:0,135:0,140:0,145:0,150:0,155:0,160:0,165:0,170:0,175:0,180:0,185:0,190:0,195:0,200:0}
};

// =====================================================
// HMI SCORING FUNCTION
// =====================================================

function calculateHMIScore(answers: Record<number, boolean>): ScoringResult {
  // Calculate Q1 Score (Questions 1-18)
  let q1Score = 0;
  
  // Questions 1-2: 10 points each
  const q1HighWeight = [1, 2];
  q1HighWeight.forEach(qId => {
    if (answers[qId]) q1Score += 10;
  });
  
  // Questions 3-18: 5 points each
  for (let i = 3; i <= 18; i++) {
    if (answers[i]) q1Score += 5;
  }
  
  // Calculate Q2 Score (Questions 19-36)
  let q2Score = 0;
  
  // Questions 19-20: 10 points each
  const q2HighWeight = [19, 20];
  q2HighWeight.forEach(qId => {
    if (answers[qId]) q2Score += 10;
  });
  
  // Questions 21-36: 5 points each
  for (let i = 21; i <= 36; i++) {
    if (answers[i]) q2Score += 5;
  }
  
  const combinedScore = q1Score + q2Score;
  
  // Lookup Physical Percentage from HMI Table
  const physicalPercentage = lookupPhysicalPercentage(q1Score, combinedScore);
  const emotionalPercentage = 100 - physicalPercentage;
  
  // Determine Profile
  let profile: 'Physical Suggestible' | 'Emotional Suggestible' | 'Somnambulistic' | 'Intellectual Suggestible';
  
  if (physicalPercentage === 50 && emotionalPercentage === 50) {
    profile = 'Somnambulistic';
  } else if (emotionalPercentage >= 80) {
    profile = 'Intellectual Suggestible';
  } else if (physicalPercentage > emotionalPercentage) {
    profile = 'Physical Suggestible';
  } else {
    profile = 'Emotional Suggestible';
  }
  
  return {
    success: true,
    profile,
    physicalPercentage,
    emotionalPercentage,
    q1Score,
    q2Score,
    combinedScore,
    answers,
    completedAt: new Date().toISOString(),
    userId: '',
    methodology: 'HMI E&P Suggestibility Assessment (Kappas Method)'
  };
}

function lookupPhysicalPercentage(q1Score: number, combinedScore: number): number {
  // Ensure scores are within valid range
  const validQ1 = Math.max(0, Math.min(100, q1Score));
  const validCombined = Math.max(50, Math.min(200, combinedScore));
  
  // Round to nearest multiple of 5 for Q1
  const roundedQ1 = Math.round(validQ1 / 5) * 5;
  
  // Round to nearest multiple of 5 for combined
  const roundedCombined = Math.round(validCombined / 5) * 5;
  
  // Look up value in table
  if (HMI_LOOKUP_TABLE[roundedQ1] && HMI_LOOKUP_TABLE[roundedQ1][roundedCombined] !== undefined) {
    return HMI_LOOKUP_TABLE[roundedQ1][roundedCombined];
  }
  
  // If exact match not found, interpolate
  return interpolateLookup(validQ1, validCombined);
}

function interpolateLookup(q1Score: number, combinedScore: number): number {
  // Find surrounding values in table
  const q1Lower = Math.floor(q1Score / 5) * 5;
  const q1Upper = Math.ceil(q1Score / 5) * 5;
  const combLower = Math.floor(combinedScore / 5) * 5;
  const combUpper = Math.ceil(combinedScore / 5) * 5;
  
  // Get four corner values
  const v1 = HMI_LOOKUP_TABLE[q1Lower]?.[combLower] ?? 50;
  const v2 = HMI_LOOKUP_TABLE[q1Upper]?.[combLower] ?? 50;
  const v3 = HMI_LOOKUP_TABLE[q1Lower]?.[combUpper] ?? 50;
  const v4 = HMI_LOOKUP_TABLE[q1Upper]?.[combUpper] ?? 50;
  
  // Bilinear interpolation
  const q1Frac = q1Upper > q1Lower ? (q1Score - q1Lower) / (q1Upper - q1Lower) : 0;
  const combFrac = combUpper > combLower ? (combinedScore - combLower) / (combUpper - combLower) : 0;
  
  const interp1 = v1 + (v2 - v1) * q1Frac;
  const interp2 = v3 + (v4 - v3) * q1Frac;
  const result = interp1 + (interp2 - interp1) * combFrac;
  
  return Math.round(result);
}

// =====================================================
// COLOR CONSTANTS
// =====================================================

const COLORS = {
  pageBackground: 'from-gray-900 via-purple-900 to-indigo-900',
  cardBackground: 'bg-gray-900',
  cardBackgroundAlternate: 'bg-gray-800/90',
  textPrimary: 'text-white',
  textSecondary: 'text-gray-200',
  textMuted: 'text-gray-400',
  sectionHeaderBg: 'from-purple-600/30 to-pink-600/30',
  sectionHeaderBorder: 'border-purple-400/30',
  progressBarBg: 'bg-gray-700',
  progressBarFill: 'from-purple-600 via-pink-600 to-cyan-600',
  progressDotCompleted: 'bg-green-500',
  progressDotCurrent: 'bg-purple-500',
  progressDotUpcoming: 'bg-gray-700',
  questionBadgeBg: 'bg-purple-600',
  questionBadgeText: 'text-white',
  buttonYesActive: 'from-green-600 to-emerald-600',
  buttonYesActiveBorder: 'border-green-400',
  buttonYesActiveShadow: 'shadow-green-500/50',
  buttonYesInactive: 'bg-gray-700',
  buttonYesInactiveBorder: 'border-gray-600',
  buttonYesHoverBorder: 'hover:border-green-500/50',
  buttonNoActive: 'from-red-600 to-pink-600',
  buttonNoActiveBorder: 'border-red-400',
  buttonNoActiveShadow: 'shadow-red-500/50',
  buttonNoInactive: 'bg-gray-700',
  buttonNoInactiveBorder: 'border-gray-600',
  buttonNoHoverBorder: 'hover:border-red-500/50',
  navButtonPrimary: 'from-purple-600 to-pink-600',
  navButtonSecondary: 'bg-gray-700',
  navButtonSubmit: 'from-green-600 to-cyan-600',
  navButtonDisabled: 'bg-gray-700',
  cardBorder: 'border-purple-500/50',
  questionBorder: 'border-gray-700',
  questionHoverBorder: 'hover:border-purple-500/70',
  errorBg: 'bg-red-500/20',
  errorBorder: 'border-red-500/50',
  errorText: 'text-red-300',
};

const QUESTIONS_PER_PAGE = 6;
const TOTAL_PAGES = 6;

// =====================================================
// COMPONENT: TOOLTIP
// =====================================================

interface TooltipProps {
  content: string;
  example?: string;
}

const Tooltip: React.FC<TooltipProps> = ({ content, example }) => {
  const [isVisible, setIsVisible] = useState(false);

  return (
    <div className="relative inline-block">
      <button
        onMouseEnter={() => setIsVisible(true)}
        onMouseLeave={() => setIsVisible(false)}
        onClick={() => setIsVisible(!isVisible)}
        className="ml-2 text-purple-400 hover:text-purple-300 transition-colors"
        type="button"
      >
        <HelpCircle size={18} />
      </button>

      <AnimatePresence>
        {isVisible && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2 }}
            className="absolute z-50 w-80 p-4 bg-gray-800 border border-purple-500/50 rounded-lg shadow-2xl -top-2 left-8"
          >
            <div className="flex items-start gap-2 mb-2">
              <Info size={16} className="text-purple-400 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-gray-200">{content}</p>
            </div>
            
            {example && (
              <div className="mt-3 pt-3 border-t border-gray-700">
                <div className="flex items-start gap-2">
                  <Lightbulb size={14} className="text-yellow-400 flex-shrink-0 mt-0.5" />
                  <p className="text-xs text-gray-400 italic">{example}</p>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

// =====================================================
// COMPONENT: PROGRESS BAR
// =====================================================

interface ProgressBarProps {
  current: number;
  total: number;
  percentage: number;
  answeredCount: number;
  totalQuestions: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({
  current,
  total,
  percentage,
  answeredCount,
  totalQuestions
}) => {
  return (
    <div className="mb-8">
      <div className="flex justify-between items-center mb-3">
        <span className={`${COLORS.textMuted} text-sm font-medium`}>
          HMI E&P Suggestibility Assessment
        </span>
        <span className="text-purple-400 font-bold text-sm">
          {answeredCount}/{totalQuestions} questions
        </span>
      </div>

      <div className={`relative h-3 ${COLORS.progressBarBg} rounded-full overflow-hidden shadow-inner`}>
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
          className={`absolute top-0 left-0 h-full bg-gradient-to-r ${COLORS.progressBarFill} rounded-full shadow-lg`}
        />
        
        {percentage > 10 && (
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-white text-xs font-bold drop-shadow-lg">
              {Math.round(percentage)}%
            </span>
          </div>
        )}
      </div>

      <div className="flex justify-center gap-2 mt-4">
        {Array.from({ length: total }, (_, i) => i + 1).map(page => (
          <div
            key={page}
            className={`h-2 rounded-full transition-all duration-300 ${
              page < current
                ? `${COLORS.progressDotCompleted} w-10 shadow-sm shadow-green-500/50`
                : page === current
                ? `${COLORS.progressDotCurrent} w-16 shadow-sm shadow-purple-500/50`
                : `${COLORS.progressDotUpcoming} w-10`
            }`}
          />
        ))}
      </div>
      
      <div className={`text-center mt-3 ${COLORS.textMuted} text-xs`}>
        Page {current} of {total}
      </div>
    </div>
  );
};

// =====================================================
// COMPONENT: QUESTION CARD
// =====================================================

interface QuestionCardProps {
  question: EPQuestion;
  answer: boolean | undefined;
  onAnswer: (answer: boolean) => void;
  index: number;
}

const QuestionCard: React.FC<QuestionCardProps> = ({
  question,
  answer,
  onAnswer,
  index
}) => {
  const Icon = question.icon || Brain;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.08, duration: 0.3 }}
      className={`
        ${COLORS.cardBackgroundAlternate} 
        rounded-xl p-6 
        border-2 ${COLORS.questionBorder} 
        ${COLORS.questionHoverBorder}
        transition-all duration-300
        shadow-lg hover:shadow-xl hover:shadow-purple-500/20
      `}
    >
      {/* Question Header */}
      <div className="mb-5">
        <div className="flex items-start gap-3 mb-3">
          {/* Question Number Badge */}
          <span className={`
            inline-flex items-center justify-center
            ${COLORS.questionBadgeBg} 
            ${COLORS.questionBadgeText}
            font-bold text-sm 
            px-3 py-1.5 
            rounded-full 
            shadow-md
            flex-shrink-0
          `}>
            Q{question.id}
          </span>
          
          {/* Icon */}
          <div className="flex-shrink-0 mt-0.5">
            <Icon size={20} className="text-purple-400" />
          </div>
          
          {/* Question Text */}
          <div className="flex-1">
            <p className={`${COLORS.textPrimary} text-lg font-medium leading-relaxed`}>
              {question.text}
            </p>
          </div>

          {/* Tooltip */}
          <Tooltip content={question.tooltip} example={question.example} />
        </div>

        {/* Category Badge */}
        <div className="ml-14">
          <span className={`
            inline-block text-xs px-2 py-1 rounded-full
            ${question.category === 'physical' 
              ? 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/30' 
              : 'bg-purple-500/20 text-purple-300 border border-purple-500/30'
            }
          `}>
            {question.category === 'physical' ? '🎯 Physical Indicator' : '💭 Emotional Indicator'}
          </span>
        </div>
      </div>

      {/* Answer Buttons */}
      <div className="flex gap-4">
        <button
          onClick={() => onAnswer(true)}
          type="button"
          className={`
            flex-1 py-4 px-6 
            rounded-xl 
            font-bold text-lg 
            transition-all duration-200 
            transform hover:scale-105 active:scale-95
            shadow-lg
            border-2
            ${
              answer === true
                ? `bg-gradient-to-r ${COLORS.buttonYesActive} 
                   text-white 
                   shadow-2xl ${COLORS.buttonYesActiveShadow}
                   scale-105 
                   ${COLORS.buttonYesActiveBorder}
                   ring-4 ring-green-500/30`
                : `${COLORS.buttonYesInactive} 
                   ${COLORS.textSecondary}
                   hover:bg-gray-600 
                   ${COLORS.buttonYesInactiveBorder}
                   ${COLORS.buttonYesHoverBorder}
                   hover:text-white`
            }
          `}
        >
          <span className="text-2xl mr-2">✓</span>
          <span>Yes</span>
        </button>
        
        <button
          onClick={() => onAnswer(false)}
          type="button"
          className={`
            flex-1 py-4 px-6 
            rounded-xl 
            font-bold text-lg 
            transition-all duration-200 
            transform hover:scale-105 active:scale-95
            shadow-lg
            border-2
            ${
              answer === false
                ? `bg-gradient-to-r ${COLORS.buttonNoActive}
                   text-white 
                   shadow-2xl ${COLORS.buttonNoActiveShadow}
                   scale-105 
                   ${COLORS.buttonNoActiveBorder}
                   ring-4 ring-red-500/30`
                : `${COLORS.buttonNoInactive}
                   ${COLORS.textSecondary}
                   hover:bg-gray-600 
                   ${COLORS.buttonNoInactiveBorder}
                   ${COLORS.buttonNoHoverBorder}
                   hover:text-white`
            }
          `}
        >
          <span className="text-2xl mr-2">✗</span>
          <span>No</span>
        </button>
      </div>
    </motion.div>
  );
};

// =====================================================
// COMPONENT: QUESTION PAGE
// =====================================================

interface QuestionPageProps {
  questions: EPQuestion[];
  answers: Record<number, boolean>;
  onAnswer: (questionId: number, answer: boolean) => void;
  pageNumber: number;
}

const QuestionPage: React.FC<QuestionPageProps> = ({
  questions,
  answers,
  onAnswer,
  pageNumber
}) => {
  const isPhysicalSection = pageNumber <= 3;
  const sectionIcon = isPhysicalSection ? '🎯' : '💭';
  const sectionTitle = isPhysicalSection 
    ? 'Physical Suggestibility Indicators' 
    : 'Emotional Suggestibility Indicators';
  const sectionDescription = isPhysicalSection
    ? 'These questions identify direct, literal response patterns and mind-body connection'
    : 'These questions identify inferential, analytical response patterns and mental processing';
  
  return (
    <div className={`
      ${COLORS.cardBackground} 
      backdrop-blur-md 
      rounded-2xl p-8 
      border-2 ${COLORS.cardBorder}
      shadow-2xl
    `}>
      {/* Section Header */}
      <div className={`
        mb-8 
        bg-gradient-to-r ${COLORS.sectionHeaderBg}
        rounded-xl p-6 
        border ${COLORS.sectionHeaderBorder}
        shadow-inner
      `}>
        <div className="flex items-center justify-between mb-3">
          <h2 className={`text-4xl font-bold ${COLORS.textPrimary} drop-shadow-lg`}>
            Section {pageNumber}
          </h2>
          <span className="text-5xl">{sectionIcon}</span>
        </div>
        <p className={`${COLORS.textSecondary} text-xl font-medium mb-2`}>
          {sectionTitle}
        </p>
        <p className={`${COLORS.textMuted} text-sm`}>
          {sectionDescription}
        </p>
        <div className={`mt-3 ${COLORS.textMuted} text-xs flex items-center gap-2`}>
          <Info size={14} />
          <span>Questions {questions[0].id} - {questions[questions.length - 1].id} of 36 • HMI Kappas Method</span>
        </div>
      </div>

      {/* Questions Grid */}
      <div className="space-y-5">
        {questions.map((question, index) => (
          <QuestionCard
            key={question.id}
            question={question}
            answer={answers[question.id]}
            onAnswer={(answer) => onAnswer(question.id, answer)}
            index={index}
          />
        ))}
      </div>

      {/* Page Completion Indicator */}
      <div className="mt-6 text-center">
        {questions.every(q => answers[q.id] !== undefined) ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className="inline-flex items-center gap-2 bg-green-500/20 border border-green-500/50 rounded-full px-4 py-2"
          >
            <CheckCircle2 size={20} className="text-green-400" />
            <span className="text-green-300 font-semibold">Page Complete</span>
          </motion.div>
        ) : (
          <div className={`${COLORS.textMuted} text-sm`}>
            {questions.filter(q => answers[q.id] !== undefined).length} of {questions.length} answered on this page
          </div>
        )}
      </div>
    </div>
  );
};

// =====================================================
// MAIN COMPONENT
// =====================================================

const EPAssessmentQuestionnaire: React.FC<EPAssessmentQuestionnaireProps> = ({
  userId,
  onComplete,
  onBack
}) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [answers, setAnswers] = useState<Record<number, boolean>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Load saved progress
  useEffect(() => {
    const savedAnswers = localStorage.getItem('jeeth-ep-answers');
    const savedPage = localStorage.getItem('jeeth-ep-page');
    
    if (savedAnswers) {
      try {
        setAnswers(JSON.parse(savedAnswers));
      } catch (e) {
        console.error('Failed to load saved answers', e);
      }
    }
    
    if (savedPage) {
      setCurrentPage(parseInt(savedPage, 10));
    }
  }, []);

  // Save progress
  useEffect(() => {
    localStorage.setItem('jeeth-ep-answers', JSON.stringify(answers));
    localStorage.setItem('jeeth-ep-page', currentPage.toString());
  }, [answers, currentPage]);

  const questionsForPage = EP_QUESTIONS.slice(
    (currentPage - 1) * QUESTIONS_PER_PAGE,
    currentPage * QUESTIONS_PER_PAGE
  );

  const answeredCount = Object.keys(answers).length;
  const progress = (answeredCount / EP_QUESTIONS.length) * 100;
  const canGoNext = questionsForPage.every(q => answers[q.id] !== undefined);
  const canSubmit = answeredCount === EP_QUESTIONS.length;

  const handleAnswer = (questionId: number, answer: boolean) => {
    setAnswers(prev => ({ ...prev, [questionId]: answer }));
  };

  const handleNext = () => {
    if (currentPage < TOTAL_PAGES) {
      setCurrentPage(prev => prev + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handlePrevious = () => {
    if (currentPage > 1) {
      setCurrentPage(prev => prev - 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else if (onBack) {
      onBack();
    }
  };

  const handleSubmit = async () => {
    if (!canSubmit) return;

    setIsSubmitting(true);
    setError(null);

    try {
      const results = calculateHMIScore(answers);
      results.userId = userId;

      // Clear saved progress
      localStorage.removeItem('jeeth-ep-answers');
      localStorage.removeItem('jeeth-ep-page');

      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));

      onComplete(results);
    } catch (err: any) {
      setError(err.message || 'Failed to submit assessment. Please try again.');
      setIsSubmitting(false);
    }
  };

  return (
    <div className={`
      min-h-screen 
      bg-gradient-to-br ${COLORS.pageBackground}
      flex items-center justify-center 
      px-4 sm:px-8 py-12
      relative overflow-hidden
    `}>
      {/* Background Stars */}
      <div className="absolute inset-0 opacity-20 pointer-events-none">
        {[...Array(50)].map((_, i) => (
          <div
            key={i}
            className="absolute w-1 h-1 bg-white rounded-full animate-pulse"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${2 + Math.random() * 2}s`
            }}
          />
        ))}
      </div>

      <div className="max-w-4xl w-full relative z-10">
        <ProgressBar 
          current={currentPage}
          total={TOTAL_PAGES}
          percentage={progress}
          answeredCount={answeredCount}
          totalQuestions={EP_QUESTIONS.length}
        />

        <AnimatePresence mode="wait">
          <motion.div
            key={currentPage}
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            transition={{ duration: 0.3 }}
          >
            <QuestionPage
              questions={questionsForPage}
              answers={answers}
              onAnswer={handleAnswer}
              pageNumber={currentPage}
            />
          </motion.div>
        </AnimatePresence>

        {error && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className={`
              mt-6 p-4 
              ${COLORS.errorBg}
              border ${COLORS.errorBorder}
              rounded-xl 
              ${COLORS.errorText}
              text-center font-medium
              shadow-lg
            `}
          >
            <span className="text-xl mr-2">⚠️</span>
            {error}
          </motion.div>
        )}

        {/* Navigation */}
        <div className="mt-8 flex justify-between items-center gap-4">
          <button
            onClick={handlePrevious}
            type="button"
            className={`
              px-6 sm:px-8 py-3 
              ${COLORS.navButtonSecondary}
              ${COLORS.textSecondary}
              rounded-full 
              font-semibold
              hover:bg-gray-600 
              transition-all duration-200
              shadow-lg
              hover:shadow-xl
              flex items-center gap-2
            `}
          >
            <ChevronLeft size={20} />
            {currentPage === 1 ? 'Back' : 'Previous'}
          </button>

          {currentPage < TOTAL_PAGES ? (
            <button
              onClick={handleNext}
              disabled={!canGoNext}
              type="button"
              className={`
                px-8 sm:px-12 py-4 
                rounded-full 
                text-lg font-bold
                transition-all duration-200
                shadow-2xl
                flex items-center gap-2
                ${
                  canGoNext
                    ? `bg-gradient-to-r ${COLORS.navButtonPrimary}
                       text-white 
                       hover:scale-105 
                       hover:shadow-purple-500/50
                       active:scale-95`
                    : `${COLORS.navButtonDisabled}
                       text-gray-500 
                       cursor-not-allowed
                       opacity-50`
                }
              `}
            >
              Next
              <ChevronRight size={20} />
            </button>
          ) : (
            <button
              onClick={handleSubmit}
              disabled={!canSubmit || isSubmitting}
              type="button"
              className={`
                px-8 sm:px-12 py-4 
                rounded-full 
                text-lg font-bold
                transition-all duration-200
                shadow-2xl
                flex items-center gap-2
                ${
                  canSubmit && !isSubmitting
                    ? `bg-gradient-to-r ${COLORS.navButtonSubmit}
                       text-white 
                       hover:scale-105 
                       hover:shadow-green-500/50
                       active:scale-95`
                    : `${COLORS.navButtonDisabled}
                       text-gray-500 
                       cursor-not-allowed
                       opacity-50`
                }
              `}
            >
              {isSubmitting ? (
                <>
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles size={20} />
                  </motion.div>
                  Analyzing...
                </>
              ) : (
                <>
                  Complete Assessment
                  <CheckCircle2 size={20} />
                </>
              )}
            </button>
          )}
        </div>

        {/* Footer Info */}
        <div className={`mt-6 text-center ${COLORS.textMuted} text-sm space-y-2`}>
          <div className="flex items-center justify-center gap-2">
            <Info size={14} />
            <span>
              Page {currentPage} of {TOTAL_PAGES} • {answeredCount}/{EP_QUESTIONS.length} questions answered
            </span>
          </div>
          <div className="text-xs flex items-center justify-center gap-2">
            <Sparkles size={12} />
            <span>Progress automatically saved • HMI Kappas Clinical Methodology</span>
          </div>
        </div>

        {/* First Page Tips */}
        {currentPage === 1 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="mt-8 p-6 bg-blue-500/10 border border-blue-500/30 rounded-xl"
          >
            <h3 className="text-blue-300 font-bold mb-3 flex items-center gap-2">
              <Lightbulb size={20} />
              Assessment Tips
            </h3>
            <ul className="text-blue-200 text-sm space-y-2">
              <li className="flex items-start gap-2">
                <CheckCircle2 size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Answer honestly - there are no right or wrong answers</span>
              </li>
              <li className="flex items-start gap-2">
                <Target size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Go with your first instinct rather than overthinking</span>
              </li>
              <li className="flex items-start gap-2">
                <HelpCircle size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>Hover over help icons for detailed explanations and examples</span>
              </li>
              <li className="flex items-start gap-2">
                <Sparkles size={16} className="text-blue-400 flex-shrink-0 mt-0.5" />
                <span>This assessment uses the authentic HMI methodology developed by Dr. John Kappas</span>
              </li>
            </ul>
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default EPAssessmentQuestionnaire;