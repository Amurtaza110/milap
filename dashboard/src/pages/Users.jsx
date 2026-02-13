import React, { useState } from 'react';
import { USERS } from '../data/mockData'; // Reusing USERS for now, would be a separate list in real app
import { Search, MoreVertical, Shield, Ban } from 'lucide-react';

const MOCK_Users = [
    { id: 1, name: 'Ali Khan', email: 'ali@example.com', status: 'ACTIVE', role: 'USER', joinDate: '2023-01-15' },
    { id: 2, name: 'Sara Ahmed', email: 'sara@example.com', status: 'ACTIVE', role: 'GOLD', joinDate: '2023-02-20' },
    { id: 3, name: 'Spam Bot', email: 'bot@spam.com', status: 'BANNED', role: 'USER', joinDate: '2023-10-01' },
];

export default function UsersList() {
    const [searchTerm, setSearchTerm] = useState('');

    const filteredUsers = MOCK_Users.filter(u =>
        u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        u.email.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="p-8">
            <header className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-bold text-white">User Management</h2>
                <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                        type="text"
                        placeholder="Search users..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="bg-surface border border-white/10 rounded-xl pl-10 pr-4 py-2 text-white focus:border-primary outline-none w-64"
                    />
                </div>
            </header>

            <div className="bg-surface border border-white/5 rounded-2xl overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-white/5 text-gray-400 text-xs uppercase tracking-wider">
                        <tr>
                            <th className="p-4 font-medium">User</th>
                            <th className="p-4 font-medium">Status</th>
                            <th className="p-4 font-medium">Role</th>
                            <th className="p-4 font-medium">Joined</th>
                            <th className="p-4 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-white/5">
                        {filteredUsers.map(user => (
                            <tr key={user.id} className="hover:bg-white/5 transition-colors">
                                <td className="p-4">
                                    <div>
                                        <div className="font-bold text-white">{user.name}</div>
                                        <div className="text-sm text-gray-400">{user.email}</div>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <span className={`px-2 py-1 rounded text-xs font-bold ${user.status === 'ACTIVE' ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500'
                                        }`}>
                                        {user.status}
                                    </span>
                                </td>
                                <td className="p-4">
                                    <div className="flex items-center gap-2">
                                        {user.role === 'GOLD' && <Shield size={14} className="text-amber-400" />}
                                        <span className="text-sm font-medium text-gray-300">{user.role}</span>
                                    </div>
                                </td>
                                <td className="p-4 text-gray-400 text-sm">{user.joinDate}</td>
                                <td className="p-4">
                                    <button className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-white">
                                        <MoreVertical size={18} />
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
