import React, { useState } from 'react';
import { db } from '../firebase';
import { collection, addDoc, getDocs, query, where } from 'firebase/firestore';
import { Send, BarChart3, Bell } from 'lucide-react';

export default function Marketing() {
    const [title, setTitle] = useState('');
    const [message, setMessage] = useState('');
    const [target, setTarget] = useState('All Users');
    const [loading, setLoading] = useState(false);

    const sendBlast = async () => {
        if (!title || !message) return alert("Please fill title and message");

        setLoading(true);
        try {
            // Fetch target users
            let q = query(collection(db, "users"));
            if (target === 'Gold Members Only') {
                q = query(collection(db, "users"), where("isMilapGold", "==", true));
            }

            const snapshot = await getDocs(q);
            const batch = [];

            snapshot.forEach((userDoc) => {
                const notiRef = collection(db, "notifications");
                batch.push(addDoc(notiRef, {
                    receiverId: userDoc.id,
                    type: 'system',
                    title: title,
                    message: message,
                    timestamp: Date.now(),
                    isRead: false,
                    senderId: 'ADMIN'
                }));
            });

            await Promise.all(batch);
            alert(`Blast sent to ${snapshot.size} users!`);
            setTitle('');
            setMessage('');
        } catch (e) {
            console.error(e);
            alert("Failed to send blast");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Marketing & Campaigns</h2>
                <p className="text-gray-400 text-sm mt-1">Manage notifications and promoted events</p>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Push Notification Composer */}
                <div className="lg:col-span-1">
                    <div className="bg-surface p-6 rounded-2xl border border-white/5">
                        <h3 className="text-lg font-bold text-white mb-6 flex items-center gap-2">
                            <Bell className="text-primary" size={20} />
                            Send In-App Notification
                        </h3>

                        <div className="space-y-4">
                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Target Audience</label>
                                <select
                                    value={target}
                                    onChange={(e) => setTarget(e.target.value)}
                                    className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none"
                                >
                                    <option>All Users</option>
                                    <option>Gold Members Only</option>
                                </select>
                            </div>

                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Title</label>
                                <input
                                    type="text"
                                    value={title}
                                    onChange={(e) => setTitle(e.target.value)}
                                    className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none"
                                    placeholder="e.g. Weekend Flash Sale!"
                                />
                            </div>

                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Message</label>
                                <textarea
                                    rows={4}
                                    value={message}
                                    onChange={(e) => setMessage(e.target.value)}
                                    className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none resize-none"
                                    placeholder="Enter your message here..."
                                ></textarea>
                            </div>

                            <button
                                onClick={sendBlast}
                                disabled={loading}
                                className="w-full bg-primary hover:bg-pink-600 text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2 transition-colors disabled:opacity-50"
                            >
                                <Send size={18} />
                                {loading ? 'Sending...' : 'Send Blast'}
                            </button>
                        </div>
                    </div>
                </div>

                {/* Performance Stats */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="grid grid-cols-2 gap-6">
                        <div className="bg-surface p-6 rounded-2xl border border-white/5 text-center">
                            <div className="text-4xl font-bold text-white mb-1">Live</div>
                            <div className="text-gray-400 text-xs uppercase tracking-widest">System Status</div>
                        </div>
                        <div className="bg-surface p-6 rounded-2xl border border-white/5 text-center">
                            <div className="text-4xl font-bold text-white mb-1">0$</div>
                            <div className="text-gray-400 text-xs uppercase tracking-widest">Backend Cost</div>
                        </div>
                    </div>
                    <div className="bg-surface p-8 rounded-2xl border border-white/5">
                        <h3 className="text-white font-bold mb-4">Marketing Tips</h3>
                        <p className="text-gray-400 text-sm leading-relaxed">
                            Sending system notifications will appear instantly in the user's notification tab. Use this to promote new events, announce Gold updates, or alert users about profile boosts.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
