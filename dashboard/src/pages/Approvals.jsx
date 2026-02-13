import React from 'react';
import { CheckCircle, XCircle, DollarSign, ExternalLink } from 'lucide-react';

const REQUESTS = [
    { id: 1, type: 'VERIFICATION', user: 'Fatima Ali', detail: 'CNIC Provided', time: '2 mins ago' },
    { id: 2, type: 'REFUND', user: 'John Smith', detail: 'Event Cancelled - 5000 PKR', time: '1 hour ago' },
    { id: 3, type: 'VERIFICATION', user: 'Cool Dudes Band', detail: 'Artist Profile', time: '3 hours ago' },
];

export default function Approvals() {
    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Approvals & Payments</h2>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {/* Pending Requests */}
                <div>
                    <h3 className="text-lg font-bold text-gray-400 mb-4 uppercase text-xs tracking-wider">Pending Actions</h3>
                    <div className="space-y-4">
                        {REQUESTS.map(req => (
                            <div key={req.id} className="bg-surface p-5 rounded-xl border border-white/5 hover:border-white/10 transition-colors">
                                <div className="flex justify-between items-start mb-3">
                                    <span className={`px-2 py-1 rounded text-[10px] font-bold ${req.type === 'REFUND' ? 'bg-orange-500/10 text-orange-500' : 'bg-blue-500/10 text-blue-500'
                                        }`}>
                                        {req.type}
                                    </span>
                                    <span className="text-xs text-gray-500">{req.time}</span>
                                </div>
                                <h4 className="font-bold text-white mb-1">{req.user}</h4>
                                <p className="text-sm text-gray-400 mb-4">{req.detail}</p>

                                <div className="flex gap-2">
                                    <button className="flex-1 bg-green-500/10 text-green-500 hover:bg-green-500/20 py-2 rounded-lg font-bold text-xs transition-colors flex items-center justify-center gap-2">
                                        <CheckCircle size={14} /> APPROVE
                                    </button>
                                    <button className="flex-1 bg-red-500/10 text-red-500 hover:bg-red-500/20 py-2 rounded-lg font-bold text-xs transition-colors flex items-center justify-center gap-2">
                                        <XCircle size={14} /> REJECT
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Payment Gateway Status */}
                <div>
                    <h3 className="text-lg font-bold text-gray-400 mb-4 uppercase text-xs tracking-wider">Gateway Status</h3>
                    <div className="bg-surface p-6 rounded-2xl border border-white/5 mb-6">
                        <div className="flex items-center gap-4 mb-6">
                            <div className="p-3 bg-green-500/20 rounded-xl text-green-500">
                                <DollarSign size={24} />
                            </div>
                            <div>
                                <h4 className="text-2xl font-bold text-white">98.2%</h4>
                                <p className="text-xs text-gray-400">Success Rate (Last 24h)</p>
                            </div>
                        </div>

                        <div className="space-y-3">
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-400">EasyPaisa</span>
                                <span className="text-green-500 font-bold">OPERATIONAL</span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-400">JazzCash</span>
                                <span className="text-green-500 font-bold">OPERATIONAL</span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-400">Card Payments (Stripe)</span>
                                <span className="text-yellow-500 font-bold">DEGRADED</span>
                            </div>
                        </div>

                        <button className="w-full mt-6 bg-white/5 hover:bg-white/10 text-white text-sm font-bold py-3 rounded-xl transition-colors flex items-center justify-center gap-2">
                            <ExternalLink size={16} />
                            View Stripe Dashboard
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
