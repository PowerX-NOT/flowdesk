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
    <div className="loginPage">
      <section className="loginHero">
        <div className="loginHeroMark" />
        <h1 className="loginHeroTitle">Manage your team from one place</h1>
        <p className="loginHeroText">
          FlowDesk Admin gives you full visibility into users and tasks across your organization.
        </p>
        <div className="loginHeroFeatures">
          <div className="loginHeroFeature">User management &amp; access control</div>
          <div className="loginHeroFeature">Task oversight with live status updates</div>
          <div className="loginHeroFeature">Secure admin-only access</div>
        </div>
      </section>

      <section className="loginPanel">
        <div className="loginCard">
          <h2 className="loginCardTitle">Welcome back</h2>
          <p className="loginCardSubtitle">Sign in with your admin account</p>

          {error ? <div className="errorBanner" style={{ marginBottom: 20 }}>{error}</div> : null}

          <form className="loginForm" onSubmit={handleSubmit}>
            <div className="field">
              <label className="label" htmlFor="email">
                Email address
              </label>
              <input
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@company.com"
                autoComplete="email"
                type="email"
                required
              />
            </div>

            <div className="field">
              <label className="label" htmlFor="password">
                Password
              </label>
              <input
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                type="password"
                autoComplete="current-password"
                required
              />
            </div>

            <button className="btn" type="submit" disabled={loading}>
              {loading ? 'Signing in…' : 'Sign in to dashboard'}
            </button>
          </form>
        </div>
      </section>
    </div>
  );
}
