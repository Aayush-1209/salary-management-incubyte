import React from 'react';
import './Spinner.css';

export function Spinner({ className = '' }: { className?: string }) {
  return <div className={`spinner ${className}`}></div>;
}
