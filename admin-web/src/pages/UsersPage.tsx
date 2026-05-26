import { useEffect, useMemo, useState } from 'react';
import type { UserResponse } from '../lib/types';
import { adminDeleteUser, adminListUsers, ApiError } from '../lib/api';
import { IconRefresh, IconSearch, IconTrash } from '../components/Icons';

export default function UsersPage() {
  const [users, setUsers] = useState<UserResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  const params = useMemo(() => ({ limit: 200, skip: 0 }), []);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return users;
    return users.filter(
      (u) =>
        u.name.toLowerCase().includes(q) ||
        u.email.toLowerCase().includes(q) ||
        u.role.toLowerCase().includes(q),
    );
  }, [users, search]);

  const stats = useMemo(() => {
    const active = users.filter((u) => u.is_active).length;
    const admins = users.filter((u) => u.role === 'admin').length;
    const employees = users.filter((u) => u.role === 'employee').length;
    return { total: users.length, active, admins, employees };
  }, [users]);

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
    <div className="pageStack">
      <div className="statsRow">
        <div className="statCard accent">
          <div className="statCardLabel">Total users</div>
          <div className="statCardValue">{stats.total}</div>
          <div className="statCardHint">Registered accounts</div>
        </div>
        <div className="statCard success">
          <div className="statCardLabel">Active</div>
          <div className="statCardValue">{stats.active}</div>
          <div className="statCardHint">Can sign in</div>
        </div>
        <div className="statCard">
          <div className="statCardLabel">Employees</div>
          <div className="statCardValue">{stats.employees}</div>
          <div className="statCardHint">Standard role</div>
        </div>
        <div className="statCard warning">
          <div className="statCardLabel">Admins</div>
          <div className="statCardValue">{stats.admins}</div>
          <div className="statCardHint">Elevated access</div>
        </div>
      </div>

      <div className="panel">
        <div className="panelHeader">
          <div>
            <div className="panelTitle">All users</div>
            <div className="panelSubtitle">
              {filtered.length === users.length
                ? `${users.length} accounts`
                : `${filtered.length} of ${users.length} shown`}
            </div>
          </div>
          <div className="panelToolbar">
            <button
              type="button"
              className="btn secondary"
              onClick={() => void load()}
              disabled={loading}
            >
              <IconRefresh />
              Refresh
            </button>
          </div>
        </div>

        {error ? (
          <div style={{ padding: '16px 24px 0' }}>
            <div className="errorBanner">{error}</div>
          </div>
        ) : null}

        <div className="panelFilters">
          <div className="field grow">
            <div className="label">Search users</div>
            <div className="inputWrap">
              <IconSearch />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Name, email, or role…"
              />
            </div>
          </div>
        </div>

        <div className="panelBody">
          {loading ? (
            <div className="loadingBlock">
              <div className="spinner" />
              Loading users…
            </div>
          ) : filtered.length === 0 ? (
            <div className="emptyState">
              <div className="emptyStateTitle">No users found</div>
              <p>Try adjusting your search or refresh the list.</p>
            </div>
          ) : (
            <div className="tableWrap">
              <table>
                <thead>
                  <tr>
                    <th style={{ width: 72 }}>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th style={{ width: 120 }}>Role</th>
                    <th style={{ width: 110 }}>Status</th>
                    <th style={{ width: 100 }} />
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((u) => (
                    <tr key={u.id}>
                      <td className="tdMuted">#{u.id}</td>
                      <td className="tdName">{u.name}</td>
                      <td className="tdEmail">{u.email}</td>
                      <td>
                        <span className={`badge badgeRole ${u.role}`}>{u.role}</span>
                      </td>
                      <td>
                        <span className={u.is_active ? 'badge badgeActive' : 'badge badgeInactive'}>
                          {u.is_active ? 'Active' : 'Disabled'}
                        </span>
                      </td>
                      <td className="tdActions">
                        <button
                          className="btn danger iconOnly"
                          type="button"
                          title="Delete user"
                          onClick={() => void handleDelete(u.id)}
                        >
                          <IconTrash />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
