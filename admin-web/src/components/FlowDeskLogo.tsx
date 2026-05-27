import { useId } from 'react';

type FlowDeskLogoProps = {
  size?: number;
  className?: string;
};

/** Gradient squircle + circle check mark (FlowDesk app icon) */
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
        <linearGradient id={gradId} x1="4" y1="24" x2="44" y2="24" gradientUnits="userSpaceOnUse">
          <stop stopColor="#A995F5" />
          <stop offset="1" stopColor="#7056EB" />
        </linearGradient>
      </defs>
      <rect width="48" height="48" rx="13" fill={`url(#${gradId})`} />
      <g
        stroke="#FFFFFF"
        fill="none"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="2.5"
      >
        <path d="M34 23.08V24a10 10 0 1 1-5.93-9.14" />
        <path d="M34 16 24 26.01 21 23.01" />
      </g>
    </svg>
  );
}
