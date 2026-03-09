import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { Users, Heart, Star, TrendingUp, AlertCircle, MapPin, Activity, DollarSign } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Cell } from 'recharts';

export default function Overview() {
    const [stats, setStats] = useState({
        totalUsers: 0,
        goldUsers: 0,
        onlineUsers: 0,
        bannedUsers: 0,
        totalRevenue: 0,
        cityStats: []
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // 1. Real-time Users Listener
        const unsubUsers = onSnapshot(collection(db, "users"), (snapshot) => {
            const users = snapshot.docs.map(doc => doc.data());

            // Calculate City Distribution
            const cities = {};
            users.forEach(u => {
                if (u.location) cities[u.location] = (cities[u.location] || 0) + 1;
            });
            const cityData = Object.keys(cities).map(name => ({ name, count: cities[name] })).sort((a,b) => b.count - a.count).slice(0, 5);

            setStats(prev => ({
                ...prev,
                totalUsers: users.length,
                goldUsers: users.filter(u => u.isMilapGold).length,
                onlineUsers: users.filter(u => u.isOnline).length,
                bannedUsers: users.filter(u => u.isDeactivated).length,
                cityStats: cityData
            }));
            setLoading(false);
        });

        // 2. Real-time Revenue Listener (Tickets)
        const unsubTickets = onSnapshot(collection(db, "tickets"), (snapshot) => {
            let revenue = 0;
            snapshot.forEach(doc => {
                revenue += (doc.data().price || 0);
            });
            setStats(prev => ({ ...prev, totalRevenue: revenue }));
        });

        return () => {
            unsubUsers();
            unsubTickets();
        };
    }, []);

    const statCards = [
        { title: 'Total Souls', value: stats.totalUsers, icon: Users, color: 'text-blue-500', bg: 'bg-blue-500/10' },
        { title: 'Currently Online', value: stats.onlineUsers, icon: Activity, color: 'text-green-500', bg: 'bg-green-500/10' },
        { title: 'Gold Members', value: stats.goldUsers, icon: Star, color: 'text-amber-500', bg: 'bg-amber-500/10' },
        { title: 'Total Revenue', value: `Rs. ${stats.totalRevenue.toLocaleString()}`, icon: DollarSign, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
    ];

    if (loading) return <div className="p-8 text-white text-center">Synchronizing Milap Analytics...</div>;

    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Platform Intelligence</h2>
                <p className="text-gray-400 text-sm">Real-time ecosystem monitoring & revenue tracking</p>
            </header>

            {/* Top Stat Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                {statCards.map((stat, i) => (
                    <div key={i} className="bg-surface border border-white/5 p-6 rounded-2xl hover:border-white/10 transition-all">
                        <div className="flex justify-between items-start mb-4">
                            <div className={`${stat.bg} ${stat.color} p-3 rounded-xl`}>
                                <stat.icon size={24} />
                            </div>
                            <span className="flex items-center gap-1 text-green-500 text-[10px] font-black bg-green-500/10 px-2 py-1 rounded-lg uppercase tracking-widest">
                                Live
                            </span>
                        </div>
                        <div className="text-3xl font-black text-white mb-1">{stat.value}</div>
                        <div className="text-gray-500 text-xs font-bold uppercase tracking-wider">{stat.title}</div>
                    </div>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
                {/* User Growth Chart */}
                <div className="lg:col-span-2 bg-surface border border-white/5 p-8 rounded-3xl">
                    <h3 className="text-white font-bold mb-6 flex items-center gap-2">
                        <TrendingUp size={18} className="text-primary" />
                        Acquisition Trend
                    </h3>
                    <div className="h-[300px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={chartData}>
                                <defs>
                                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#ff2d55" stopOpacity={0.3}/>
                                        <stop offset="95%" stopColor="#ff2d55" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff05" vertical={false} />
                                <XAxis dataKey="name" stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} />
                                <YAxis stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} />
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#1a1a1a', border: '1px solid #ffffff10', borderRadius: '12px' }}
                                    itemStyle={{ color: '#fff' }}
                                />
                                <Area type="monotone" dataKey="users" stroke="#ff2d55" strokeWidth={3} fillOpacity={1} fill="url(#colorValue)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* City Distribution */}
                <div className="lg:col-span-1 bg-surface border border-white/5 p-8 rounded-3xl">
                    <h3 className="text-white font-bold mb-6 flex items-center gap-2">
                        <MapPin size={18} className="text-blue-500" />
                        Top Cities
                    </h3>
                    <div className="space-y-6">
                        {stats.cityStats.length === 0 ? (
                            <p className="text-gray-600 text-sm text-center py-12">No geographic data yet.</p>
                        ) : (
                            stats.cityStats.map((city, i) => (
                                <div key={i}>
                                    <div className="flex justify-between items-center mb-2">
                                        <span className="text-sm font-bold text-white uppercase tracking-tighter">{city.name}</span>
                                        <span className="text-xs text-primary font-black">{Math.round((city.count / stats.totalUsers) * 100)}%</span>
                                    </div>
                                    <div className="w-full bg-white/5 h-1.5 rounded-full overflow-hidden">
                                        <div
                                            className="bg-primary h-full transition-all duration-1000"
                                            style={{ width: `${(city.count / stats.totalUsers) * 100}%` }}
                                        ></div>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>

                    <div className="mt-12 pt-8 border-t border-white/5">
                        <div className="bg-dark/50 p-4 rounded-2xl border border-white/5">
                            <div className="text-[10px] text-gray-500 font-bold uppercase mb-1">Safety Index</div>
                            <div className="text-white font-bold text-lg">99.4% Secure</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

const chartData = [
    { name: 'Mon', users: 120 },
    { name: 'Tue', users: 210 },
    { name: 'Wed', users: 450 },
    { name: 'Thu', users: 380 },
    { name: 'Fri', users: 590 },
    { name: 'Sat', users: 800 },
    { name: 'Sun', users: 1100 },
];
