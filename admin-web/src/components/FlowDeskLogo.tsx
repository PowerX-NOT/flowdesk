import { useId } from 'react';

type FlowDeskLogoProps = {
  size?: number;
  className?: string;
};

/** App-icon style: gradient squircle + clipboard check (matches FlowDesk brand mockups) */
export default function FlowDeskLogo({ size = 44, className = '' }: FlowDeskLogoProps) {
  const gradId = useId().replace(/:/g, '');

  return (
    <svg
      className={`flowDeskLogo ${className}`.trim()}
      width={size}
      height={size}
      viewBox="0 0 48 48"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="FlowDesk"
    >
      <defs>
        <linearGradient id={gradId} x1="6" y1="4" x2="42" y2="44" gradientUnits="userSpaceOnUse">
          <stop stopColor="#9B8AF8" />
          <stop offset="0.45" stopColor="#7C6EF0" />
          <stop offset="1" stopColor="#5C6BC0" />
        </linearGradient>
      </defs>
      <rect width="48" height="48" rx="13" fill={`url(#${gradId})`} />
      <g
        stroke="#fff"
        strokeWidth="2.35"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      >
        <path d="M17 14h14v2.2h2.4a2.4 2.4 0 0 1 2.4 2.4v15.6a2.4 2.4 0 0 1-2.4 2.4H14.6a2.4 2.4 0 0 1-2.4-2.4V18.6a2.4 2.4 0 0 1 2.4-2.4H17V14z" />
        <path d="M19.2 25.2 22.2 28.2 29.8 20.2" strokeWidth="2.6" />
      </g>
    </svg>
  );
}
