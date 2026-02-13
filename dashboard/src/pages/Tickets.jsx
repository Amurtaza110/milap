import React, { useState } from 'react';
import { TICKETS } from '../data/mockData';
import { MessageSquare, CheckCircle, Clock } from 'lucide-react';

export default function Tickets() {
    const [tickets, setTickets] = useState(TICKETS);
    const [filter, setFilter] = useState('ALL');

    const filteredTickets = filter === 'ALL' ? tickets : tickets.filter(t => t.status === filter);

    return (
        <div className="p-8">
            <header className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-bold text-white">Support Tickets</h2>
                <div className="flex gap-2">
                    {['ALL', 'OPEN', 'PENDING', 'RESOLVED'].map(f => (
                        <button
                            key={f}
                            onClick={() => setFilter(f)}
                            className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors ${filter === f ? 'bg-primary text-white' : 'bg-surface text-gray-400 hover:text-white'
                                }`}
                        >
                            {f}
                        </button>
                    ))}
                </div>
            </header>

            <div className="space-y-4">
                {filteredTickets.map(ticket => (
                    <div key={ticket.id} className="bg-surface p-6 rounded-xl border border-white/5 flex items-center justify-between hover:border-white/10 transition-colors">
                        <div className="flex items-center gap-4">
                            <div className={`p-3 rounded-full ${ticket.status === 'OPEN' ? 'bg-red-500/20 text-red-500' :
                                    ticket.status === 'PENDING' ? 'bg-orange-500/20 text-orange-500' :
                                        'bg-green-500/20 text-green-500'
                                }`}>
                                {ticket.status === 'OPEN' ? <MessageSquare size={20} /> :
                                    ticket.status === 'PENDING' ? <Clock size={20} /> :
                                        <CheckCircle size={20} />}
                            </div>
                            <div>
                                <h4 className="font-bold text-white">{ticket.issue}</h4>
                                <p className="text-sm text-gray-400">Reported by <span className="text-white">{ticket.user}</span> on {ticket.date}</p>
                            </div>
                        </div>

                        <button className="text-primary text-sm font-bold hover:underline">
                            View Details
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
}
