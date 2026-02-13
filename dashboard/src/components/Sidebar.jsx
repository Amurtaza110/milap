import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Ticket, BarChart3, ShieldAlert, BadgeDollarSign, Terminal, LogOut } from 'lucide-react';

export default function Sidebar({ user }) {
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.removeItem('milap_user');
        navigate('/');
    };

    const MENU_ITEMS = [
        { label: 'Overview', path: '/dashboard', icon: LayoutDashboard, roles: ['ALL'] },
        { label: 'Tickets', path: '/dashboard/tickets', icon: Ticket, roles: ['SUPPORT', 'MANAGER', 'OWNER'] },
        { label: 'Users', path: '/dashboard/users', icon: Users, roles: ['SUPPORT', 'MANAGER', 'OWNER'] },
        { label: 'Campaigns', path: '/dashboard/marketing', icon: BarChart3, roles: ['MARKETING', 'OWNER'] },
        { label: 'Approvals', path: '/dashboard/approvals', icon: BadgeDollarSign, roles: ['MANAGER', 'OWNER'] },
        { label: 'Security', path: '/dashboard/security', icon: ShieldAlert, roles: ['MANAGER', 'OWNER'] },
        { label: 'Dev Tools', path: '/dashboard/dev', icon: Terminal, roles: ['DEVELOPER', 'OWNER'] },
    ];

    return (
        <div className="w-64 bg-surface border-r border-white/5 h-screen flex flex-col">
            <div className="p-6 border-b border-white/5">
                <h1 className="text-2xl font-black text-white tracking-tight">MILAP<span className="text-primary">+</span></h1>
                <div className="mt-2 flex items-center gap-2">
                    <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></div>
                    <span className="text-xs text-gray-400 uppercase tracking-wider">{user.role} VIEW</span>
                </div>
            </div>

            <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
                {MENU_ITEMS.filter(item => item.roles.includes('ALL') || item.roles.includes(user.role)).map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        end={item.path === '/dashboard'}
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${isActive
                                ? 'bg-primary text-white shadow-lg shadow-primary/20'
                                : 'text-gray-400 hover:bg-white/5 hover:text-white'
                            }`
                        }
                    >
                        <item.icon size={20} />
                        <span className="text-sm font-medium">{item.label}</span>
                    </NavLink>
                ))}
            </nav>

            <div className="p-4 border-t border-white/5">
                <button
                    onClick={handleLogout}
                    className="flex items-center gap-3 w-full px-4 py-3 text-red-400 hover:bg-red-500/10 rounded-xl transition-colors"
                >
                    <LogOut size={20} />
                    <span className="text-sm font-medium">Log out</span>
                </button>
            </div>
        </div>
    );
}
