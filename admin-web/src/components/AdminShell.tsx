import type { ReactNode } from 'react';
import FlowDeskLogo from './FlowDeskLogo';
import { IconLogout, IconTasks, IconUsers } from './Icons';

type Page = 'users' | 'tasks';

const PAGE_META: Record<Page, { title: string; subtitle: string }> = {
  users: {
    title: 'Users',
    subtitle: 'Manage employee accounts and access',
  },
  tasks: {
    title: 'Tasks',
    subtitle: 'Monitor and update all team tasks',
  },
};

function initials(name?: string) {
  if (!name?.trim()) return 'A';
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
  return name.slice(0, 2).toUpperCase();
}

export default function AdminShell(props: {
  page: Page;
  onPageChange: (page: Page) => void;
  userName?: string;
  userEmail?: string;
  children: ReactNode;
  onLogout: () => void;
}) {
  const { page, onPageChange, userName, userEmail, children, onLogout } = props;
  const meta = PAGE_META[page];

  return (
    <div className="adminShell">
      <aside className="adminSidebar">
        <div className="adminBrand">
          <FlowDeskLogo size={44} />
          <div>
            <div className="adminBrandTitle">FlowDesk</div>
            <div className="adminBrandSubtitle">Admin Console</div>
          </div>
        </div>

        <div className="adminNavLabel">Menu</div>
        <nav className="adminNav">
          <button
            type="button"
            className={`adminNavButton ${page === 'users' ? 'active' : ''}`}
            onClick={() => onPageChange('users')}
          >
            <IconUsers />
            Users
          </button>
          <button
            type="button"
            className={`adminNavButton ${page === 'tasks' ? 'active' : ''}`}
            onClick={() => onPageChange('tasks')}
          >
            <IconTasks />
            Tasks
          </button>
        </nav>

        <div className="adminSidebarFooter">
          <div className="adminUserCard">
            <div className="adminUserAvatar" aria-hidden>
              {initials(userName)}
            </div>
            <div className="adminUserMeta">
              <div className="adminUserName">{userName ?? 'Admin'}</div>
              <div className="adminUserRole">{userEmail ?? 'Administrator'}</div>
            </div>
          </div>
          <button type="button" className="adminLogoutButton" onClick={onLogout}>
            <IconLogout />
            Sign out
          </button>
        </div>
      </aside>

      <div className="adminContent">
        <header className="adminTopBar">
          <div>
            <div className="adminTopBarTitle">{meta.title}</div>
            <div className="adminTopBarSubtitle">{meta.subtitle}</div>
          </div>
        </header>
        <main className="adminMain">{children}</main>
      </div>
    </div>
  );
}
