import React from 'react';
import { Terminal, Database, Server, ToggleLeft } from 'lucide-react';

export default function DevTools() {
    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Developer Console</h2>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Realtime Logs */}
                <div className="bg-[#0D0D0D] rounded-xl border border-white/10 font-mono text-xs overflow-hidden h-96 flex flex-col">
                    <div className="bg-white/5 p-3 border-b border-white/5 flex items-center justify-between">
                        <span className="flex items-center gap-2 text-gray-400">
                            <Terminal size={14} /> Server Logs (Live)
                        </span>
                        <span className="flex h-2 w-2 rounded-full bg-green-500 animate-pulse"></span>
                    </div>
                    <div className="flex-1 p-4 overflow-y-auto space-y-2 text-gray-300">
                        <div><span className="text-blue-400">INFO</span> [AuthService] User login success: manager@milap.app</div>
                        <div><span className="text-blue-400">INFO</span> [Socket] Client connected: socket_id_x9s8</div>
                        <div><span className="text-yellow-400">WARN</span> [Payment] Gateway timeout notification received</div>
                        <div><span className="text-blue-400">INFO</span> [Cron] Cleanup job started</div>
                        <div><span className="text-red-500">ERROR</span> [Upload] Failed to resize image: EPIPE</div>
                        <div><span className="text-blue-400">INFO</span> [AuthService] Token refreshed</div>
                        {/* Mock logs */}
                        {Array(10).fill(0).map((_, i) => (
                            <div key={i} className="opacity-50">
                                <span className="text-gray-500">DEBUG</span> [Internal] Processing request #{2390 + i}
                            </div>
                        ))}
                    </div>
                </div>

                {/* Feature Flags & Config */}
                <div className="space-y-6">
                    <div className="bg-surface p-6 rounded-2xl border border-white/5">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <ToggleLeft className="text-primary" size={20} /> Feature Flags
                        </h3>
                        <div className="space-y-4">
                            <div className="flex items-center justify-between p-3 bg-dark rounded-xl">
                                <div>
                                    <div className="text-white text-sm font-bold">Global Voice Chat</div>
                                    <div className="text-gray-500 text-xs">Enable AgoraRTC services</div>
                                </div>
                                <div className="w-10 h-6 bg-primary rounded-full relative cursor-pointer">
                                    <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div>
                                </div>
                            </div>
                            <div className="flex items-center justify-between p-3 bg-dark rounded-xl">
                                <div>
                                    <div className="text-white text-sm font-bold">Maintenance Mode</div>
                                    <div className="text-gray-500 text-xs">Block all non-admin traffic</div>
                                </div>
                                <div className="w-10 h-6 bg-white/20 rounded-full relative cursor-pointer">
                                    <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="bg-surface p-6 rounded-2xl border border-white/5">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <Database className="text-blue-500" size={20} /> System Status
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="bg-dark p-3 rounded-xl">
                                <div className="text-gray-500 text-xs">CPU Usage</div>
                                <div className="text-white font-bold text-lg">12%</div>
                            </div>
                            <div className="bg-dark p-3 rounded-xl">
                                <div className="text-gray-500 text-xs">Memory</div>
                                <div className="text-white font-bold text-lg">1.2 GB</div>
                            </div>
                            <div className="bg-dark p-3 rounded-xl">
                                <div className="text-gray-500 text-xs">DB Connections</div>
                                <div className="text-white font-bold text-lg">34/100</div>
                            </div>
                            <div className="bg-dark p-3 rounded-xl">
                                <div className="text-gray-500 text-xs">Uptime</div>
                                <div className="text-white font-bold text-lg">14d 2h</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
