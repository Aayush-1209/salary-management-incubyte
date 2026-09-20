import React from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { LayoutDashboard, Users, Building2 } from 'lucide-react';
import './Layout.css';

export function Layout() {
  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="sidebar-header">
          <div className="logo-icon">
            <Building2 size={24} color="var(--brand-primary)" />
          </div>
          <h1 className="logo-text">Acme HR</h1>
        </div>
        
        <nav className="sidebar-nav">
          <NavLink 
            to="/" 
            className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
            end
          >
            <LayoutDashboard size={20} />
            <span>Dashboard</span>
          </NavLink>
          
          <NavLink 
            to="/employees" 
            className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
          >
            <Users size={20} />
            <span>Employees</span>
          </NavLink>
        </nav>
      </aside>
      
      <main className="main-content">
        <header className="main-header">
          <div className="header-user">
            <div className="avatar">HR</div>
            <span>HR Manager</span>
          </div>
        </header>
        <div className="page-content">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
