import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, onSnapshot, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { Search, MoreVertical, Shield, Ban, CheckCircle } from 'lucide-react';

export default function UsersList() {
    const [searchTerm, setSearchTerm] = useState('');
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Real-time listener for the users collection
        const q = query(collection(db, "users"));
        const unsubscribe = onSnapshot(q, (querySnapshot) => {
            const usersArray = [];
            querySnapshot.forEach((doc) => {
                usersArray.push({ ...doc.data(), id: doc.id });
            });
            setUsers(usersArray);
            setLoading(loading => false);
        });

        return () => unsubscribe();
    }, []);

    const toggleBanUser = async (userId, currentStatus) => {
        const userRef = doc(db, "users", userId);
        await updateDoc(userRef, {
            isDeactivated: !currentStatus
        });
    };

    const makeAdmin = async (userId) => {
        const userRef = doc(db, "users", userId);
        await updateDoc(userRef, {
            role: 'ADMIN'
        });
    };

    const filteredUsers = users.filter(u =>
        (u.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (u.location || '').toLowerCase().includes(searchTerm.toLowerCase())
    );

    if (loading) return <div className="p-8 text-white">Connecting to Milap Database...</div>;

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
                            <th className="p-4 font-medium">Location</th>
                            <th className="p-4 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-white/5">
                        {filteredUsers.map(user => (
                            <tr key={user.id} className="hover:bg-white/5 transition-colors">
                                <td className="p-4">
                                    <div className="flex items-center gap-3">
                                        <img src={user.photos?.[0] || 'https://via.placeholder.com/40'} className="w-10 h-10 rounded-full object-cover" alt="" />
                                        <div>
                                            <div className="font-bold text-white">{user.name}</div>
                                            <div className="text-sm text-gray-400">{user.id.substring(0, 8)}...</div>
                                        </div>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <span className={`px-2 py-1 rounded text-xs font-bold ${!user.isDeactivated ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500'}`}>
                                        {user.isDeactivated ? 'BANNED' : 'ACTIVE'}
                                    </span>
                                </td>
                                <td className="p-4">
                                    <div className="flex items-center gap-2">
                                        {user.isMilapGold && <Shield size={14} className="text-amber-400" />}
                                        <span className="text-sm font-medium text-gray-300">{user.role || 'USER'}</span>
                                    </div>
                                </td>
                                <td className="p-4 text-gray-400 text-sm">{user.location}</td>
                                <td className="p-4">
                                    <div className="flex gap-2">
                                        <button
                                            onClick={() => toggleBanUser(user.id, user.isDeactivated)}
                                            className="p-2 hover:bg-red-500/10 rounded-lg text-gray-400 hover:text-red-500 transition-colors"
                                            title={user.isDeactivated ? "Unban" : "Ban"}
                                        >
                                            <Ban size={18} />
                                        </button>
                                        <button
                                            onClick={() => makeAdmin(user.id)}
                                            className="p-2 hover:bg-primary/10 rounded-lg text-gray-400 hover:text-primary transition-colors"
                                            title="Promote to Admin"
                                        >
                                            <CheckCircle size={18} />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
