import type { ReactNode } from 'react';

type Page = 'users' | 'tasks';

export default function AdminShell(props: {
  page: Page;
  onPageChange: (page: Page) => void;
  userName?: string;
  children: ReactNode;
  onLogout: () => void;
}) {
  const { page, onPageChange, userName, children, onLogout } = props;

  return (
    <div className="adminShell">
      <aside className="adminSidebar">
        <div className="adminBrand">
          <div className="adminBrandMark" />
          <div className="adminBrandText">
            <div className="adminBrandTitle">FlowDesk</div>
            <div className="adminBrandSubtitle">Admin Dashboard</div>
          </div>
        </div>

        <nav className="adminNav">
          <button
            type="button"
            className={`adminNavButton ${page === 'users' ? 'active' : ''}`}
            onClick={() => onPageChange('users')}
          >
            Users
          </button>
          <button
            type="button"
            className={`adminNavButton ${page === 'tasks' ? 'active' : ''}`}
            onClick={() => onPageChange('tasks')}
          >
            Tasks
          </button>
        </nav>

        <div className="adminSidebarFooter">
          <div className="adminUserName">{userName ?? 'Admin'}</div>
          <button type="button" className="adminLogoutButton" onClick={onLogout}>
            Logout
          </button>
        </div>
      </aside>

      <main className="adminMain">{children}</main>
    </div>
  );
}

