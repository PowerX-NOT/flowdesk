import { useEffect, useMemo, useState } from 'react';
import type { TaskResponse, TaskStatus } from '../lib/types';
import { ApiError, adminDeleteTask, adminListTasks, adminUpdateTaskStatus } from '../lib/api';

const STATUS_OPTIONS: Array<{ label: string; value: TaskStatus | '' }> = [
  { label: 'All', value: '' },
  { label: 'Pending', value: 'pending' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Completed', value: 'completed' },
];

function statusClass(status: string) {
  switch (status) {
    case 'pending':
      return 'statusPill statusPending';
    case 'in_progress':
      return 'statusPill statusInProgress';
    case 'completed':
      return 'statusPill statusCompleted';
    default:
      return 'statusPill';
  }
}

export default function TasksPage() {
  const [tasks, setTasks] = useState<TaskResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<TaskStatus | ''>('');

  const params = useMemo(() => {
    return {
      limit: 300,
      skip: 0,
      search: search.trim() ? search.trim() : undefined,
      status: status ? status : undefined,
    };
  }, [search, status]);

  async function load() {
    setLoading(true);
    setError(null);
    try {
      const list = await adminListTasks(params);
      setTasks(list);
    } catch (e) {
      const msg =
        e instanceof ApiError
          ? e.detail ?? e.message
          : e instanceof Error
            ? e.message
            : 'Failed to load tasks';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.status, params.search]);

  async function updateStatus(taskId: number, nextStatus: TaskStatus) {
    setError(null);
    try {
      await adminUpdateTaskStatus(taskId, nextStatus);
      await load();
    } catch (e) {
      const msg =
        e instanceof ApiError
          ? e.detail ?? e.message
          : e instanceof Error
            ? e.message
            : 'Update failed';
      setError(msg);
    }
  }

  async function handleDelete(taskId: number) {
    const confirmed = window.confirm('Delete this task? This cannot be undone.');
    if (!confirmed) return;
    setError(null);
    try {
      await adminDeleteTask(taskId);
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
          <div className="cardTitle">Tasks</div>
          <div className="cardSubtitle">All tasks in the system</div>
        </div>
        <div className="cardSubtitle">{tasks.length ? `${tasks.length} tasks` : null}</div>
      </div>

      {error ? <div className="errorBanner">{error}</div> : null}

      <div className="fieldRow" style={{ marginBottom: 14 }}>
        <div className="field">
          <div className="label">Search</div>
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by title..."
          />
        </div>
        <div className="field">
          <div className="label">Status</div>
          <select value={status} onChange={(e) => setStatus(e.target.value as TaskStatus | '')}>
            {STATUS_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {loading ? <div style={{ color: '#C3C7D4' }}>Loading...</div> : null}

      <div className="tableWrap">
        <table>
          <thead>
            <tr>
              <th style={{ width: 90 }}>ID</th>
              <th>Title</th>
              <th style={{ width: 90 }}>Owner</th>
              <th style={{ width: 120 }}>Priority</th>
              <th style={{ width: 160 }}>Status</th>
              <th style={{ width: 140 }}>Due</th>
              <th style={{ width: 120 }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {tasks.map((t) => (
              <tr key={t.id}>
                <td>{t.id}</td>
                <td>{t.title}</td>
                <td>{t.owner_id}</td>
                <td>
                  <span className="statusPill">{t.priority}</span>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <span className={statusClass(t.status)}>{t.status}</span>
                    <select
                      value={t.status}
                      onChange={(e) => void updateStatus(t.id, e.target.value as TaskStatus)}
                      style={{ minWidth: 160 }}
                    >
                      <option value="pending">pending</option>
                      <option value="in_progress">in_progress</option>
                      <option value="completed">completed</option>
                    </select>
                  </div>
                </td>
                <td>{t.due_date ?? '-'}</td>
                <td>
                  <button className="btn danger" type="button" onClick={() => void handleDelete(t.id)}>
                    Delete
                  </button>
                </td>
              </tr>
            ))}
            {tasks.length === 0 && !loading ? (
              <tr>
                <td colSpan={7} style={{ color: '#C3C7D4', padding: 18 }}>
                  No tasks found.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}

