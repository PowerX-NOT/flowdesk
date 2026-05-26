import { useEffect, useState } from 'react';
import './styles/admin.css';
import AdminShell from './components/AdminShell';
import LoginPage from './pages/LoginPage';
import TasksPage from './pages/TasksPage';
import UsersPage from './pages/UsersPage';
import type { UserResponse } from './lib/types';
import { clearTokens, getAccessToken, me } from './lib/api';

type Page = 'users' | 'tasks';

export default function App() {
  const [user, setUser] = useState<UserResponse | null>(null);
  const [page, setPage] = useState<Page>('users');
  const [authLoading, setAuthLoading] = useState(true);

  useEffect(() => {
    async function init() {
      setAuthLoading(true);
      try {
        const access = getAccessToken();
        if (!access) {
          setUser(null);
          return;
        }
        const meUser = await me();
        if (meUser.role !== 'admin') {
          clearTokens();
          setUser(null);
          return;
        }
        setUser(meUser);
      } catch (e) {
        clearTokens();
        setUser(null);
      } finally {
        setAuthLoading(false);
      }
    }
    void init();
  }, []);

  if (authLoading) {
    return (
      <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center' }}>
        Loading...
      </div>
    );
  }

  if (!user) {
    return <LoginPage onLoggedIn={(u) => setUser(u)} />;
  }

  function handleLogout() {
    clearTokens();
    setUser(null);
    setPage('users');
  }

  return (
    <AdminShell
      page={page}
      onPageChange={setPage}
      userName={user.name}
      onLogout={handleLogout}
    >
      {page === 'users' ? <UsersPage /> : null}
      {page === 'tasks' ? <TasksPage /> : null}
    </AdminShell>
  );
}
