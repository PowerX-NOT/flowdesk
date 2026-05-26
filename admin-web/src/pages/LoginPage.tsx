import { useState, type FormEvent } from 'react';
import type { UserResponse } from '../lib/types';
import { clearTokens, login } from '../lib/api';

export default function LoginPage(props: { onLoggedIn: (user: UserResponse) => void }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      clearTokens();
      const user = await login(email.trim(), password);
      if (user.role !== 'admin') {
        throw new Error('You are not an admin.');
      }
      props.onLoggedIn(user);
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Login failed';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="loginWrap">
      <div className="loginCard">
        <div className="cardHeader">
          <div>
            <div className="cardTitle">Admin Login</div>
            <div className="cardSubtitle">Manage users and tasks</div>
          </div>
        </div>

        {error ? <div className="errorBanner">{error}</div> : null}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div className="field">
            <div className="label">Email</div>
            <input
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@company.com"
              autoComplete="email"
            />
          </div>

          <div className="field">
            <div className="label">Password</div>
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              type="password"
              autoComplete="current-password"
            />
          </div>

          <button className="btn" type="submit" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </form>
      </div>
    </div>
  );
}

