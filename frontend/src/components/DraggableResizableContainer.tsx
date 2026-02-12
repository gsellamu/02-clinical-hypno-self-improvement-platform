// @ts-nocheck



import React, { useMemo } from "react";
import { useState, useEffect, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { XRApp } from './features/xr/XRApp';
import { ShambhalaRealm } from './components/ShambhalaRealm';
//import { CosmicSpiritualRealm } from './components/CosmicSpiritualRealm';
//import { DraggableResizableContainer } from './components/DraggableResizableContainer';
import * as THREE from 'three';
import guruImage from '../assets/Jeeth-Blessing.png';


// ==================== DRAGGABLE CONTAINER ====================
export function DraggableResizableContainer({ children }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [size, setSize] = useState({ width: 700, height: 600 });
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [resizeStart, setResizeStart] = useState({ x: 0, y: 0, width: 0, height: 0 });
  const containerRef = useRef(null);

  const handleMouseDown = (e) => {
    if (e.target.classList.contains('drag-handle') || e.target.closest('.drag-handle')) {
      setIsDragging(true);
      setDragStart({
        x: e.clientX - position.x,
        y: e.clientY - position.y
      });
      e.preventDefault();
    }
  };

  const handleResizeMouseDown = (e) => {
    e.stopPropagation();
    e.preventDefault();
    setIsResizing(true);
    const rect = containerRef.current.getBoundingClientRect();
    setResizeStart({
      x: e.clientX,
      y: e.clientY,
      width: rect.width,
      height: rect.height
    });
  };

  useEffect(() => {
    const handleMouseMove = (e) => {
      if (isDragging) {
        setPosition({
          x: e.clientX - dragStart.x,
          y: e.clientY - dragStart.y
        });
      } else if (isResizing) {
        const deltaX = e.clientX - resizeStart.x;
        const deltaY = e.clientY - resizeStart.y;
        setSize({
          width: Math.max(450, Math.min(1200, resizeStart.width + deltaX)),
          height: Math.max(400, Math.min(900, resizeStart.height + deltaY))
        });
      }
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      setIsResizing(false);
    };

    if (isDragging || isResizing) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      return () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [isDragging, isResizing, dragStart, resizeStart]);

  return (
    <div
      ref={containerRef}
      style={{
        position: 'fixed',
        left: `calc(50% + ${position.x}px)`,
        top: `calc(50% + ${position.y}px)`,
        transform: 'translate(-50%, -50%)',
        width: size.width,
        height: size.height,
        backgroundColor: 'rgba(10, 5, 30, 0.75)',
        backdropFilter: 'blur(50px)',
        borderRadius: '24px',
        boxShadow: '0 25px 50px -12px rgba(212, 175, 55, 0.4), 0 0 100px rgba(147, 112, 219, 0.3)',
        border: '2px solid rgba(212, 175, 55, 0.4)',
        overflow: 'hidden',
        zIndex: 1000,
        cursor: isDragging ? 'move' : 'default',
        userSelect: isDragging || isResizing ? 'none' : 'auto'
      }}
    >
      <div
        className="drag-handle"
        onMouseDown={handleMouseDown}
        style={{
          padding: '16px 20px',
          background: 'linear-gradient(135deg, rgba(255, 215, 0, 0.25), rgba(147, 112, 219, 0.25))',
          borderBottom: '2px solid rgba(212, 175, 55, 0.4)',
          cursor: 'move',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          gap: '16px'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flex: 1 }}>
          <div style={{
            width: '80px',
            height: '80px',
            borderRadius: '50%',
            overflow: 'hidden',
            border: '3px solid rgba(255, 215, 0, 0.8)',
            boxShadow: '0 0 50px rgba(255, 215, 0, 0.7), 0 0 100px rgba(147, 112, 219, 0.5)',
            position: 'relative'
          }}>
            <img 
              src={guruImage}
              alt="Swamy Jithendarji"
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover',
                objectPosition: 'center',
              }}
            />
            <div style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              background: 'radial-gradient(circle at 50% 20%, rgba(255, 215, 0, 0.3), transparent 50%)',
              pointerEvents: 'none'
            }} />
          </div>
          
          <div>
            <div style={{ 
              color: '#ffd700', 
              fontWeight: 'bold', 
              fontSize: '18px',
              textShadow: '0 0 25px rgba(255, 215, 0, 0.8)',
              marginBottom: '5px',
            }}>
              🕉️ Swamy Jithendarji
            </div>
            <div style={{
              color: '#d4af37',
              fontSize: '13px',
              fontStyle: 'italic',
              textShadow: '0 0 15px rgba(212, 175, 55, 0.5)',
              marginBottom: '2px'
            }}>
              Master Hypnotherapist & Spiritual Guide
            </div>
            <div style={{
              color: '#c9a0dc',
              fontSize: '11px',
              textShadow: '0 0 10px rgba(201, 160, 220, 0.4)'
            }}>
              Consciousness Transformation • Inner Shambhala
            </div>
          </div>
        </div>

        <button
          onClick={(e) => {
            e.stopPropagation();
            setPosition({ x: 0, y: 0 });
            setSize({ width: 700, height: 600 });
          }}
          style={{
            background: 'rgba(255, 215, 0, 0.2)',
            border: '1px solid rgba(255, 215, 0, 0.5)',
            borderRadius: '6px',
            color: '#ffd700',
            padding: '6px 12px',
            cursor: 'pointer',
            fontSize: '12px',
            fontWeight: '600',
            transition: 'all 0.2s',
            boxShadow: '0 0 10px rgba(255, 215, 0, 0.3)'
          }}
        >
          ↺ Reset
        </button>
      </div>

      <div style={{ 
        padding: '30px',
        height: 'calc(100% - 112px)',
        overflowY: 'auto',
      }}>
        {children}
      </div>

      <div
        onMouseDown={handleResizeMouseDown}
        style={{
          position: 'absolute',
          bottom: 0,
          right: 0,
          width: '30px',
          height: '30px',
          cursor: 'nwse-resize',
          background: 'linear-gradient(135deg, transparent 45%, rgba(255, 215, 0, 0.6) 50%, rgba(255, 215, 0, 0.8) 55%)',
          borderTopLeftRadius: '6px',
          zIndex: 1001
        }}
      />
    </div>
  );
}

