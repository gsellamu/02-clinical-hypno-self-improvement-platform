/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        calm: {
          50: '#f0fdf4',
          100: '#dcfce7',
          500: '#22c55e',
          600: '#16a34a',
        },
        depth: {
          50: '#f5f3ff',
          500: '#8b5cf6',
          700: '#6d28d9',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Montserrat', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

/* 

**Save the file** - Vite will auto-reload and the warning will disappear!

---

## 🥽 STEP 2: Test in Quest 3

### **Which URL to Use?**

Try **both URLs** and see which one works:

1. **First try:** `http://10.0.0.5:5173`
2. **If that doesn't work:** `http://172.18.224.1:5173`

**Usually `10.0.0.5` is your Wi-Fi network**, so try that first!

---

### **On Your Quest 3:**

1. **Put on headset**
2. **Press Oculus button** → Open menu
3. **Open "Browser"** app
4. **Type in address bar:**
```
   http://10.0.0.5:5173
```
5. **Press Enter/Go**

**You should see the HMI Platform homepage!**

---

## 🎮 STEP 3: Enter VR Mode

1. **Click:** `🚀 Enter Virtual Reality` button
2. **Look at TOP LEFT** corner
3. **Click:** "Enter VR" button
4. **Quest prompts:** "Enter VR?" → Click **"Enter VR"**

**🎉 YOU'RE IN VR! 🎉**

---

## 🌟 What You Should Experience

### **Soft Room (Default):**
- Warm golden lighting
- Floating particles
- Text: "🧠 HMI Hypnotherapy"
- Circular rug on floor
- Glowing sphere ahead

### **Bottom Panel (3 Buttons):**
- 🏠 **Soft Room** (blue - currently selected)
- 🌲 **Nature**
- ☁️ **Floating**

**Point controller and click to switch environments!**

---

## 📊 Check Performance

**Look at top-left corner:**

*/

FPS: 85-90 / 90
FrameTime: 11-12
