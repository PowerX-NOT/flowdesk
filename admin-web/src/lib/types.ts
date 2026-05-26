export type UserRole = 'employee' | 'admin' | string;

export type TaskPriority = 'low' | 'medium' | 'high' | string;
export type TaskStatus = 'pending' | 'in_progress' | 'completed' | string;

export interface UserResponse {
  id: number;
  name: string;
  email: string;
  role: UserRole;
  is_active: boolean;
}

export interface TokenResponse {
  access_token: string;
  refresh_token?: string | null;
  token_type: string;
}

export interface TaskResponse {
  id: number;
  title: string;
  description?: string | null;
  priority: TaskPriority;
  status: TaskStatus;
  due_date?: string | null;
  owner_id: number;
  created_at: string;
  updated_at: string;
}

