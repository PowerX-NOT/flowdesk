import { useEffect, useMemo, useState } from 'react';
import type { TaskResponse, TaskStatus } from '../lib/types';
import { ApiError, adminDeleteTask, adminListTasks, adminUpdateTaskStatus } from '../lib/api';
import { IconRefresh, IconSearch, IconTrash } from '../components/Icons';

const STATUS_FILTERS: Array<{ label: string; value: TaskStatus | '' }> = [
  { label: 'All', value: '' },
  { label: 'Pending', value: 'pending' },
  { label: 'In progress', value: 'in_progress' },
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

function formatStatus(status: string) {
  return status.replace(/_/g, ' ');
}

function priorityClass(priority: string) {
  const p = priority.toLowerCase();
  if (p === 'high') return 'badge badgePriority high';
  if (p === 'low') return 'badge badgePriority low';
  return 'badge badgePriority';
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

  const stats = useMemo(() => {
    const pending = tasks.filter((t) => t.status === 'pending').length;
    const inProgress = tasks.filter((t) => t.status === 'in_progress').length;
    const completed = tasks.filter((t) => t.status === 'completed').length;
    return { total: tasks.length, pending, inProgress, completed };
  }, [tasks]);

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
    <div className="pageStack">
      <div className="statsRow">
        <div className="statCard accent">
          <div className="statCardLabel">Total tasks</div>
          <div className="statCardValue">{stats.total}</div>
          <div className="statCardHint">In current view</div>
        </div>
        <div className="statCard">
          <div className="statCardLabel">Pending</div>
          <div className="statCardValue">{stats.pending}</div>
          <div className="statCardHint">Not started</div>
        </div>
        <div className="statCard warning">
          <div className="statCardLabel">In progress</div>
          <div className="statCardValue">{stats.inProgress}</div>
          <div className="statCardHint">Being worked on</div>
        </div>
        <div className="statCard success">
          <div className="statCardLabel">Completed</div>
          <div className="statCardValue">{stats.completed}</div>
          <div className="statCardHint">Done</div>
        </div>
      </div>

      <div className="panel">
        <div className="panelHeader">
          <div>
            <div className="panelTitle">All tasks</div>
            <div className="panelSubtitle">
              {tasks.length} {tasks.length === 1 ? 'task' : 'tasks'}
              {status ? ` · ${formatStatus(status)}` : ''}
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
            <div className="label">Search tasks</div>
            <div className="inputWrap">
              <IconSearch />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search by title…"
              />
            </div>
          </div>
          <div className="field">
            <div className="label">Filter by status</div>
            <div className="chipRow">
              {STATUS_FILTERS.map((opt) => (
                <button
                  key={opt.value || 'all'}
                  type="button"
                  className={`chip ${status === opt.value ? 'active' : ''}`}
                  onClick={() => setStatus(opt.value)}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="panelBody">
          {loading ? (
            <div className="loadingBlock">
              <div className="spinner" />
              Loading tasks…
            </div>
          ) : tasks.length === 0 ? (
            <div className="emptyState">
              <div className="emptyStateTitle">No tasks found</div>
              <p>Try a different search or status filter.</p>
            </div>
          ) : (
            <div className="tableWrap">
              <table>
                <thead>
                  <tr>
                    <th style={{ width: 72 }}>ID</th>
                    <th>Title</th>
                    <th style={{ width: 90 }}>Owner</th>
                    <th style={{ width: 100 }}>Priority</th>
                    <th style={{ width: 220 }}>Status</th>
                    <th style={{ width: 120 }}>Due date</th>
                    <th style={{ width: 80 }} />
                  </tr>
                </thead>
                <tbody>
                  {tasks.map((t) => (
                    <tr key={t.id}>
                      <td className="tdMuted">#{t.id}</td>
                      <td className="tdName">{t.title}</td>
                      <td className="tdMuted">#{t.owner_id}</td>
                      <td>
                        <span className={priorityClass(t.priority)}>{t.priority}</span>
                      </td>
                      <td>
                        <div className="statusCell">
                          <span className={statusClass(t.status)}>{formatStatus(t.status)}</span>
                          <select
                            className="compact"
                            value={t.status}
                            aria-label={`Change status for ${t.title}`}
                            onChange={(e) => void updateStatus(t.id, e.target.value as TaskStatus)}
                          >
                            <option value="pending">Pending</option>
                            <option value="in_progress">In progress</option>
                            <option value="completed">Completed</option>
                          </select>
                        </div>
                      </td>
                      <td className="tdMuted">{t.due_date ?? '—'}</td>
                      <td className="tdActions">
                        <button
                          className="btn danger iconOnly"
                          type="button"
                          title="Delete task"
                          onClick={() => void handleDelete(t.id)}
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
