import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, doc, setDoc, deleteDoc, updateDoc } from 'firebase/firestore';
import { ShieldAlert, UserPlus, Trash2, Key, Mail, ShieldCheck } from 'lucide-react';

export default function Security() {
    const [admins, setAdmins] = useState([]);
    const [currentUser, setCurrentUser] = useState(null);
    const [loading, setLoading] = useState(true);

    // Form state for new employee
    const [newEmail, setNewEmail] = useState('');
    const [newPass, setNewPass] = useState('');
    const [newRole, setNewRole] = useState('SUPPORT');

    useEffect(() => {
        const stored = JSON.parse(localStorage.getItem('milap_admin'));
        setCurrentUser(stored);

        // Real-time listener for admins
        const unsubscribe = onSnapshot(collection(db, "admins"), (snapshot) => {
            const adminList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setAdmins(adminList);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const addEmployee = async (e) => {
        e.preventDefault();
        if (currentUser.role !== 'OWNER') return alert("Only OWNER can manage staff");

        try {
            const adminId = newEmail.split('@')[0].toLowerCase();
            await setDoc(doc(db, "admins", adminId), {
                email: newEmail,
                password: newPass,
                role: newRole,
                name: adminId.toUpperCase()
            });
            setNewEmail('');
            setNewPass('');
            alert("Employee added successfully!");
        } catch (e) {
            alert("Error adding employee: " + e.message);
        }
    };

    const removeEmployee = async (id) => {
        if (currentUser.role !== 'OWNER') return alert("Access Denied");
        if (window.confirm("Are you sure you want to remove this employee?")) {
            await deleteDoc(doc(db, "admins", id));
        }
    };

    const updateCredentials = async (id, newEmail, newPass) => {
        if (currentUser.role !== 'OWNER') return alert("Access Denied");
        const adminRef = doc(db, "admins", id);
        await updateDoc(adminRef, {
            email: newEmail,
            password: newPass
        });
        alert("Credentials updated!");
    };

    if (loading) return <div className="p-8 text-white">Accessing Security Vault...</div>;

    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Staff & Security Management</h2>
                <p className="text-gray-400 text-sm mt-1">Manage organizational credentials and access levels</p>
            </header>

            {currentUser.role === 'OWNER' ? (
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Add Staff Form */}
                    <div className="lg:col-span-1">
                        <div className="bg-surface p-6 rounded-2xl border border-white/5 sticky top-8">
                            <h3 className="text-lg font-bold text-white mb-6 flex items-center gap-2">
                                <UserPlus className="text-primary" size={20} />
                                Add New Staff
                            </h3>
                            <form onSubmit={addEmployee} className="space-y-4">
                                <div>
                                    <label className="text-[10px] text-gray-500 uppercase font-bold block mb-2">Staff Email</label>
                                    <input
                                        value={newEmail} onChange={e => setNewEmail(e.target.value)}
                                        className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white outline-none focus:border-primary"
                                        placeholder="user@milap.app" required
                                    />
                                </div>
                                <div>
                                    <label className="text-[10px] text-gray-500 uppercase font-bold block mb-2">Security Key</label>
                                    <input
                                        value={newPass} onChange={e => setNewPass(e.target.value)}
                                        className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white outline-none focus:border-primary"
                                        placeholder="••••••••" required
                                    />
                                </div>
                                <div>
                                    <label className="text-[10px] text-gray-500 uppercase font-bold block mb-2">Access Role</label>
                                    <select
                                        value={newRole} onChange={e => setNewRole(e.target.value)}
                                        className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white outline-none"
                                    >
                                        <option value="SUPPORT">SUPPORT</option>
                                        <option value="MARKETING">MARKETING</option>
                                    </select>
                                </div>
                                <button type="submit" className="w-full bg-primary py-3 rounded-xl font-bold text-white uppercase text-xs tracking-widest mt-4">
                                    Register Employee
                                </button>
                            </form>
                        </div>
                    </div>

                    {/* Staff List */}
                    <div className="lg:col-span-2">
                        <div className="bg-surface border border-white/5 rounded-2xl overflow-hidden">
                            <table className="w-full text-left">
                                <thead className="bg-white/5 text-gray-400 text-xs uppercase tracking-widest font-bold">
                                    <tr>
                                        <th className="p-4">Employee</th>
                                        <th className="p-4">Role</th>
                                        <th className="p-4">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-white/5">
                                    {admins.map(admin => (
                                        <tr key={admin.id} className="hover:bg-white/5 transition-colors">
                                            <td className="p-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-white/5 rounded-lg flex items-center justify-center">
                                                        <Mail size={18} className="text-gray-400" />
                                                    </div>
                                                    <div>
                                                        <div className="text-sm font-bold text-white">{admin.email}</div>
                                                        <div className="text-xs text-gray-500">Key: {admin.password}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="p-4">
                                                <span className={`px-2 py-1 rounded text-[10px] font-black ${
                                                    admin.role === 'OWNER' ? 'bg-amber-500/10 text-amber-500' : 'bg-blue-500/10 text-blue-500'
                                                }`}>
                                                    {admin.role}
                                                </span>
                                            </td>
                                            <td className="p-4">
                                                {admin.role !== 'OWNER' && (
                                                    <button onClick={() => removeEmployee(admin.id)} className="p-2 text-gray-500 hover:text-red-500 transition-colors">
                                                        <Trash2 size={18} />
                                                    </button>
                                                )}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            ) : (
                <div className="bg-surface border border-white/5 p-12 rounded-3xl text-center">
                    <ShieldCheck size={64} className="mx-auto text-green-500/20 mb-6" />
                    <h3 className="text-xl font-bold text-white mb-2">Internal Security Operational</h3>
                    <p className="text-gray-500 text-sm max-w-md mx-auto">Your access level is currently monitored. Staff management is restricted to the Platform Owner only.</p>
                </div>
            )}
        </div>
    );
}
