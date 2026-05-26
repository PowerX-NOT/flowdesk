import { useEffect, useMemo, useState } from 'react';
import type { UserResponse } from '../lib/types';
import { adminDeleteUser, adminListUsers, ApiError } from '../lib/api';

export default function UsersPage() {
  const [users, setUsers] = useState<UserResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const params = useMemo(() => ({ limit: 200, skip: 0 }), []);

  async function load() {
    setLoading(true);
    setError(null);
    try {
      const list = await adminListUsers(params);
      setUsers(list);
    } catch (e) {
      const msg =
        e instanceof ApiError
          ? e.detail ?? e.message
          : e instanceof Error
            ? e.message
            : 'Failed to load users';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function handleDelete(userId: number) {
    const confirmed = window.confirm('Delete this user? This cannot be undone.');
    if (!confirmed) return;
    setError(null);
    try {
      await adminDeleteUser(userId);
      await load();
    } catch (e) {
      const msg =
        e instanceof ApiError
          ? e.detail ?? e.message
          : e instanceof Error
            ? e.message
            : 'Delete failed';
      setError(msg);
    }
  }

  return (
    <div className="card">
      <div className="cardHeader">
        <div>
          <div className="cardTitle">Users</div>
          <div className="cardSubtitle">All employee accounts (admin only)</div>
        </div>
        <div className="cardSubtitle">{users.length ? `${users.length} total` : null}</div>
      </div>

      {error ? <div className="errorBanner">{error}</div> : null}
      {loading ? <div style={{ color: '#C3C7D4' }}>Loading...</div> : null}

      <div className="tableWrap">
        <table>
          <thead>
            <tr>
              <th style={{ width: 90 }}>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th style={{ width: 120 }}>Role</th>
              <th style={{ width: 120 }}>Active</th>
              <th style={{ width: 120 }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.id}>
                <td>{u.id}</td>
                <td>{u.name}</td>
                <td>{u.email}</td>
                <td>{u.role}</td>
                <td>{u.is_active ? 'Active' : 'Disabled'}</td>
                <td>
                  <button className="btn danger" type="button" onClick={() => void handleDelete(u.id)}>
                    Delete
                  </button>
                </td>
              </tr>
            ))}
            {users.length === 0 && !loading ? (
              <tr>
                <td colSpan={6} style={{ color: '#C3C7D4', padding: 18 }}>
                  No users found.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}

