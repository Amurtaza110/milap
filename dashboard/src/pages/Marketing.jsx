import React from 'react';
import { Send, BarChart3, Bell } from 'lucide-react';

export default function Marketing() {
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
                            Send Notification
                        </h3>

                        <div className="space-y-4">
                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Target Audience</label>
                                <select className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none">
                                    <option>All Users</option>
                                    <option>Gold Members Only</option>
                                    <option>Inactive (30+ days)</option>
                                </select>
                            </div>

                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Title</label>
                                <input type="text" className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none" placeholder="e.g. Weekend Flash Sale!" />
                            </div>

                            <div>
                                <label className="text-xs text-gray-500 uppercase block mb-2">Message</label>
                                <textarea rows={4} className="w-full bg-dark border border-white/10 rounded-lg p-3 text-white focus:border-primary outline-none resize-none" placeholder="Enter your message here..."></textarea>
                            </div>

                            <button className="w-full bg-primary hover:bg-pink-600 text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2 transition-colors">
                                <Send size={18} />
                                Send Blast
                            </button>
                        </div>
                    </div>
                </div>

                {/* Active Campaigns */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="bg-surface p-6 rounded-2xl border border-white/5">
                        <h3 className="text-lg font-bold text-white mb-6 flex items-center gap-2">
                            <BarChart3 className="text-green-500" size={20} />
                            Active Campaigns
                        </h3>

                        <div className="space-y-4">
                            {[1, 2].map(i => (
                                <div key={i} className="bg-dark p-4 rounded-xl border border-white/5 flex items-center gap-4">
                                    <div className="h-16 w-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg"></div>
                                    <div className="flex-1">
                                        <h4 className="font-bold text-white">Summer Music Festival Promo</h4>
                                        <p className="text-xs text-gray-400 mt-1">Running for 3 days • 12.5k Impressions</p>
                                        <div className="w-full bg-white/10 h-1.5 rounded-full mt-3 overflow-hidden">
                                            <div className="bg-green-500 h-full w-2/3"></div>
                                        </div>
                                    </div>
                                    <div className="text-right">
                                        <div className="text-xl font-bold text-white">4.2%</div>
                                        <div className="text-xs text-gray-400">CTR</div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-6">
                        <div className="bg-surface p-6 rounded-2xl border border-white/5 text-center">
                            <div className="text-4xl font-bold text-white mb-1">85%</div>
                            <div className="text-gray-400 text-xs uppercase">Open Rate</div>
                        </div>
                        <div className="bg-surface p-6 rounded-2xl border border-white/5 text-center">
                            <div className="text-4xl font-bold text-white mb-1">12k</div>
                            <div className="text-gray-400 text-xs uppercase">Daily Active Users</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
