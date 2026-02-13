import React from 'react';
import { ShieldAlert, Lock, AlertTriangle } from 'lucide-react';

export default function Security() {
    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Security Center</h2>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-red-500/10 border border-red-500/20 p-6 rounded-2xl">
                    <ShieldAlert className="text-red-500 mb-4" size={32} />
                    <h3 className="text-2xl font-bold text-white">5</h3>
                    <p className="text-red-400 text-sm">Active Threats</p>
                </div>
                <div className="bg-surface border border-white/5 p-6 rounded-2xl">
                    <Lock className="text-green-500 mb-4" size={32} />
                    <h3 className="text-2xl font-bold text-white">Secure</h3>
                    <p className="text-gray-400 text-sm">System Status</p>
                </div>
                <div className="bg-surface border border-white/5 p-6 rounded-2xl">
                    <AlertTriangle className="text-orange-500 mb-4" size={32} />
                    <h3 className="text-2xl font-bold text-white">12</h3>
                    <p className="text-gray-400 text-sm">Flagged Accounts</p>
                </div>
            </div>

            <div className="bg-surface rounded-2xl border border-white/5 overflow-hidden">
                <div className="p-6 border-b border-white/5">
                    <h3 className="font-bold text-white">Recent Security Logs</h3>
                </div>
                <div className="divide-y divide-white/5">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className="p-4 flex items-center justify-between hover:bg-white/5 transition-colors">
                            <div className="flex items-center gap-4">
                                <div className="text-xs font-mono text-gray-500">10:4{i} AM</div>
                                <div>
                                    <div className="text-white text-sm font-medium">Excessive login attempts</div>
                                    <div className="text-xs text-gray-400">IP: 192.168.1.{i}4 • User: unknown</div>
                                </div>
                            </div>
                            <span className="bg-red-500/20 text-red-500 px-2 py-1 rounded text-[10px] font-bold">HIGH RISK</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
