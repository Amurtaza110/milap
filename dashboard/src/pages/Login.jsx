import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { USERS } from '../data/mockData';

export default function Login() {
    const [email, setEmail] = useState('');
    const [pin, setPin] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleLogin = (e) => {
        e.preventDefault();
        const user = USERS.find(u => u.email === email && u.pin === pin);

        if (user) {
            localStorage.setItem('milap_user', JSON.stringify(user));
            navigate('/dashboard');
        } else {
            setError('Invalid credentials. Try support@milap.app / 1234');
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-dark">
            <div className="bg-surface p-8 rounded-2xl border border-white/10 w-96 shadow-2xl">
                <h1 className="text-3xl font-bold text-primary mb-2 text-center">MILAP+</h1>
                <p className="text-gray-400 text-center mb-8 text-sm tracking-widest">ADMIN DASHBOARD</p>

                {error && <div className="bg-red-500/10 text-red-500 p-3 rounded mb-4 text-sm text-center">{error}</div>}

                <form onSubmit={handleLogin} className="space-y-4">
                    <div>
                        <label className="text-xs text-gray-500 uppercase tracking-wider block mb-2">Email Access</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none transition-colors"
                            placeholder="role@milap.app"
                        />
                    </div>

                    <div>
                        <label className="text-xs text-gray-500 uppercase tracking-wider block mb-2">Security Pin</label>
                        <input
                            type="password"
                            value={pin}
                            onChange={(e) => setPin(e.target.value)}
                            className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none transition-colors tracking-widest text-center"
                            placeholder="••••"
                            maxLength={4}
                        />
                    </div>

                    <button
                        type="submit"
                        className="w-full bg-primary hover:bg-pink-600 text-white font-bold py-3 rounded-lg transition-all mt-4"
                    >
                        AUTHENTICATE
                    </button>
                </form>

                <div className="mt-8 pt-6 border-t border-white/5 text-center">
                    <p className="text-xs text-gray-600">Restricted Access only.</p>
                </div>
            </div>
        </div>
    );
}
