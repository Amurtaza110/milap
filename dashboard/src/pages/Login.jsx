import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { collection, query, where, getDocs } from 'firebase/firestore';

export default function Login() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            // Query the dedicated 'admins' collection
            const adminsRef = collection(db, "admins");
            const q = query(adminsRef, where("email", "==", email), where("password", "==", password));
            const querySnapshot = await getDocs(q);

            if (!querySnapshot.empty) {
                const adminDoc = querySnapshot.docs[0];
                const adminData = adminDoc.data();

                // Store Admin session
                localStorage.setItem('milap_admin', JSON.stringify({
                    id: adminDoc.id,
                    name: adminData.name || adminData.role,
                    role: adminData.role,
                    email: adminData.email
                }));

                navigate('/dashboard');
            } else {
                setError('Invalid Admin Credentials. Access Denied.');
            }
        } catch (e) {
            setError('System Error: ' + e.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-dark">
            <div className="bg-surface p-10 rounded-3xl border border-white/10 w-[450px] shadow-2xl relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary via-purple-500 to-blue-500"></div>

                <h1 className="text-4xl font-black text-white mb-2 text-center tracking-tighter">MILAP<span className="text-primary">+</span></h1>
                <p className="text-gray-500 text-center mb-10 text-xs uppercase tracking-[0.3em] font-bold">Admin Authority Portal</p>

                {error && <div className="bg-red-500/10 border border-red-500/20 text-red-500 p-4 rounded-xl mb-6 text-sm text-center font-medium">{error}</div>}

                <form onSubmit={handleLogin} className="space-y-6">
                    <div>
                        <label className="text-[10px] text-gray-500 uppercase tracking-widest block mb-2 font-bold">Professional Email</label>
                        <input
                            type="email"
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full bg-dark/50 border border-white/10 rounded-xl p-4 text-white focus:border-primary outline-none transition-all"
                            placeholder="name@milap.app"
                        />
                    </div>

                    <div>
                        <label className="text-[10px] text-gray-500 uppercase tracking-widest block mb-2 font-bold">Security Key</label>
                        <input
                            type="password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full bg-dark/50 border border-white/10 rounded-xl p-4 text-white focus:border-primary outline-none transition-all tracking-widest"
                            placeholder="••••••••"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-primary hover:bg-pink-600 text-white font-black py-4 rounded-xl transition-all mt-4 shadow-lg shadow-primary/20 disabled:opacity-50 uppercase text-xs tracking-widest"
                    >
                        {loading ? 'Authenticating...' : 'Enter Console'}
                    </button>
                </form>

                <div className="mt-10 pt-8 border-t border-white/5 text-center text-[10px] text-gray-600 uppercase tracking-widest">
                    Milap Internal Security Protocol v1.0
                </div>
            </div>
        </div>
    );
}
