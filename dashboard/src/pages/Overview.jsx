import React from 'react';
import { STATS } from '../data/mockData';
import { Users, Ticket, DollarSign, TrendingUp } from 'lucide-react';

const StatCard = ({ label, value, icon: Icon, color }) => (
    <div className="bg-surface p-6 rounded-2xl border border-white/5">
        <div className="flex items-center justify-between mb-4">
            <div className={`p-3 rounded-xl ${color} bg-opacity-20`}>
                <Icon size={24} className={color.replace('bg-', 'text-')} />
            </div>
            <span className="text-green-500 text-xs font-bold">+12%</span>
        </div>
        <h3 className="text-3xl font-bold text-white mb-1">{value}</h3>
        <p className="text-gray-400 text-xs uppercase tracking-wider">{label}</p>
    </div>
);

export default function Overview() {
    return (
        <div className="p-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard label="Total Users" value={STATS.activeUsers} icon={Users} color="bg-blue-500" />
                <StatCard label="Revenue (PKR)" value={STATS.revenue.toLocaleString()} icon={DollarSign} color="bg-green-500" />
                <StatCard label="Open Tickets" value={STATS.ticketsOpen} icon={Ticket} color="bg-orange-500" />
                <StatCard label="Gold Members" value={STATS.goldMembers} icon={TrendingUp} color="bg-purple-500" />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="bg-surface p-6 rounded-2xl border border-white/5 h-96 flex items-center justify-center text-gray-500 border-dashed">
                    Activity Chart Placeholder
                </div>
                <div className="bg-surface p-6 rounded-2xl border border-white/5 h-96 flex items-center justify-center text-gray-500 border-dashed">
                    Recent Transactions Placeholder
                </div>
            </div>
        </div>
    );
}
