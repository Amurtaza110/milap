import React, { useEffect, useState } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Overview from './Overview';
import Tickets from './Tickets';
import Users from './Users';
import Marketing from './Marketing';
import Approvals from './Approvals';
import Security from './Security';
import DevTools from './DevTools';

export default function Dashboard() {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const stored = localStorage.getItem('milap_user');
    if (!stored) {
      navigate('/');
    } else {
      setUser(JSON.parse(stored));
    }
  }, [navigate]);

  if (!user) return null;

  return (
    <div className="flex h-screen bg-dark text-white font-sans">
      <Sidebar user={user} />
      
      <main className="flex-1 overflow-y-auto">
        <header className="p-8 pb-0 flex justify-between items-end">
          <div>
            <h1 className="text-3xl font-bold text-white">Dashboard</h1>
            <p className="text-gray-400 mt-2">Welcome back, {user.name}</p>
          </div>
          <div className="flex gap-4">
            <button className="bg-surface border border-white/10 px-4 py-2 rounded-lg text-sm hover:bg-white/5 transition-colors">
              Last 7 Days
            </button>
            <button className="bg-primary text-white px-4 py-2 rounded-lg text-sm shadow-lg shadow-primary/20">
              Download Report
            </button>
          </div>
        </header>

        <Routes>
          <Route path="/" element={<Overview />} />
          <Route path="/tickets" element={<Tickets />} />
          <Route path="/users" element={<Users />} />
          <Route path="/marketing" element={<Marketing />} />
          <Route path="/approvals" element={<Approvals />} />
          <Route path="/security" element={<Security />} />
          <Route path="/dev" element={<DevTools />} />
        </Routes>
      </main>
    </div>
  );
}
