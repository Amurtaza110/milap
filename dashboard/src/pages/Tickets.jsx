import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, query, orderBy, doc, updateDoc } from 'firebase/firestore';
import { MessageSquare, CheckCircle, Clock, Filter } from 'lucide-react';

export default function Tickets() {
    const [tickets, setTickets] = useState([]);
    const [filter, setFilter] = useState('ALL');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Real-time listener for support tickets
        const q = query(collection(db, "support_tickets"), orderBy("timestamp", "desc"));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const ticketList = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setTickets(ticketList);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const updateTicketStatus = async (ticketId, newStatus) => {
        const ticketRef = doc(db, "support_tickets", ticketId);
        await updateDoc(ticketRef, {
            status: newStatus
        });
    };

    const filteredTickets = filter === 'ALL' ? tickets : tickets.filter(t => t.status === filter);

    if (loading) return <div className="p-8 text-white text-center">Opening Support Vault...</div>;

    return (
        <div className="p-8">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
                <div>
                    <h2 className="text-2xl font-bold text-white">Support Command</h2>
                    <p className="text-gray-500 text-sm">Manage real-time user concerns and app health</p>
                </div>
                <div className="flex bg-surface p-1 rounded-xl border border-white/5">
                    {['ALL', 'OPEN', 'PENDING', 'RESOLVED'].map(f => (
                        <button
                            key={f}
                            onClick={() => setFilter(f)}
                            className={`px-4 py-2 rounded-lg text-[10px] font-black tracking-widest transition-all ${filter === f ? 'bg-primary text-white shadow-lg' : 'text-gray-500 hover:text-white'
                                }`}
                        >
                            {f}
                        </button>
                    ))}
                </div>
            </header>

            <div className="grid grid-cols-1 gap-4">
                {filteredTickets.length === 0 ? (
                    <div className="bg-surface p-12 rounded-2xl border border-white/5 text-center text-gray-500 font-medium">
                        No concerns found in this category.
                    </div>
                ) : (
                    filteredTickets.map(ticket => (
                        <div key={ticket.id} className="bg-surface p-6 rounded-2xl border border-white/5 flex flex-col md:flex-row items-center justify-between hover:border-white/10 transition-all gap-6">
                            <div className="flex items-center gap-5 w-full">
                                <div className={`p-4 rounded-2xl ${ticket.status === 'OPEN' ? 'bg-red-500/10 text-red-500' :
                                        ticket.status === 'PENDING' ? 'bg-orange-500/10 text-orange-500' :
                                            'bg-green-500/10 text-green-500'
                                    }`}>
                                    {ticket.status === 'OPEN' ? <MessageSquare size={24} /> :
                                        ticket.status === 'PENDING' ? <Clock size={24} /> :
                                            <CheckCircle size={24} />}
                                </div>
                                <div className="flex-1">
                                    <h4 className="font-bold text-white text-lg">{ticket.issue}</h4>
                                    <div className="flex items-center gap-3 mt-1">
                                        <span className="text-xs text-gray-400 font-medium tracking-tight">Reported by <span className="text-primary">{ticket.userName || 'Anonymous'}</span></span>
                                        <span className="text-gray-700">•</span>
                                        <span className="text-xs text-gray-500">{new Date(ticket.timestamp).toLocaleDateString()}</span>
                                    </div>
                                </div>
                            </div>

                            <div className="flex items-center gap-3 w-full md:w-auto">
                                <select
                                    value={ticket.status}
                                    onChange={(e) => updateTicketStatus(ticket.id, e.target.value)}
                                    className="bg-dark border border-white/10 text-white text-xs font-bold rounded-xl px-4 py-3 outline-none focus:border-primary"
                                >
                                    <option value="OPEN">MARK AS OPEN</option>
                                    <option value="PENDING">MARK AS PENDING</option>
                                    <option value="RESOLVED">MARK AS RESOLVED</option>
                                </select>
                                <button className="bg-white/5 hover:bg-white/10 p-3 rounded-xl text-gray-400 hover:text-white transition-all">
                                    <Filter size={18} />
                                </button>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
