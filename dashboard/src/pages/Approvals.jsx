import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, doc, updateDoc, getDoc } from 'firebase/firestore';
import { CheckCircle, XCircle, DollarSign, ExternalLink, UserCircle, Image as ImageIcon } from 'lucide-react';

export default function Approvals() {
    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Real-time listener for verification requests
        const unsubscribe = onSnapshot(collection(db, "verification_requests"), (snapshot) => {
            const reqs = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setRequests(reqs.filter(r => r.status === 'pending'));
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const handleApproval = async (request, approved) => {
        try {
            // 1. Update Request Status
            const reqRef = doc(db, "verification_requests", request.id);
            await updateDoc(reqRef, {
                status: approved ? 'approved' : 'rejected',
                adminComment: approved ? 'Verified by Admin' : 'ID documents were unclear.'
            });

            // 2. If approved, update User profile with verified badge
            if (approved) {
                const userRef = doc(db, "users", request.userId);
                await updateDoc(userRef, {
                    isVerified: true
                });
            }

            alert(approved ? "User Verified Successfully!" : "Request Rejected.");
        } catch (e) {
            console.error(e);
            alert("Action failed. Check console.");
        }
    };

    if (loading) return <div className="p-8 text-white">Loading Approvals Queue...</div>;

    return (
        <div className="p-8">
            <header className="mb-8">
                <h2 className="text-2xl font-bold text-white">Approvals & Verification</h2>
                <p className="text-gray-400 text-sm">Review identity documents and verify users</p>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Pending Requests List */}
                <div className="lg:col-span-2">
                    <h3 className="text-lg font-bold text-gray-400 mb-4 uppercase text-xs tracking-wider">Pending Verifications ({requests.length})</h3>

                    {requests.length === 0 ? (
                        <div className="bg-surface p-12 rounded-2xl border border-white/5 text-center">
                            <CheckCircle className="mx-auto mb-4 text-green-500/20" size={48} />
                            <p className="text-gray-500 font-medium">All clear! No pending verification requests.</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 gap-4">
                            {requests.map(req => (
                                <div key={req.id} className="bg-surface p-6 rounded-2xl border border-white/5 hover:border-white/10 transition-all">
                                    <div className="flex flex-col md:flex-row gap-6">
                                        {/* User Info */}
                                        <div className="flex items-start gap-4 min-w-[200px]">
                                            <img src={req.userPhoto} className="w-12 h-12 rounded-full object-cover border-2 border-primary/20" alt="" />
                                            <div>
                                                <h4 className="font-bold text-white leading-tight">{req.userName}</h4>
                                                <p className="text-xs text-gray-500 mt-1">UID: {req.userId.substring(0, 8)}</p>
                                                <span className="inline-block mt-3 px-2 py-1 bg-blue-500/10 text-blue-500 rounded text-[10px] font-bold tracking-widest">VERIFICATION</span>
                                            </div>
                                        </div>

                                        {/* Document Preview (IDs) */}
                                        <div className="flex-1 flex gap-3">
                                            {[req.idFrontUrl, req.idBackUrl, req.selfieUrl].map((url, i) => (
                                                <a key={i} href={url} target="_blank" rel="noreferrer" className="group relative h-24 w-1/3 bg-black rounded-xl overflow-hidden border border-white/5">
                                                    <img src={url} className="w-full h-full object-cover opacity-60 group-hover:opacity-100 transition-opacity" alt="" />
                                                    <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 bg-black/40 transition-all">
                                                        <ExternalLink size={16} className="text-white" />
                                                    </div>
                                                </a>
                                            ))}
                                        </div>

                                        {/* Actions */}
                                        <div className="flex md:flex-col gap-2 justify-center">
                                            <button
                                                onClick={() => handleApproval(req, true)}
                                                className="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-xl font-bold text-xs transition-all flex items-center gap-2 shadow-lg shadow-green-500/20"
                                            >
                                                <CheckCircle size={16} /> VERIFY
                                            </button>
                                            <button
                                                onClick={() => handleApproval(req, false)}
                                                className="bg-white/5 hover:bg-red-500 text-white hover:text-white px-6 py-3 rounded-xl font-bold text-xs transition-all flex items-center gap-2"
                                            >
                                                <XCircle size={16} /> REJECT
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* System Integrity / Payments */}
                <div className="lg:col-span-1">
                    <h3 className="text-lg font-bold text-gray-400 mb-4 uppercase text-xs tracking-wider">Gateway Integrity</h3>
                    <div className="bg-surface p-6 rounded-2xl border border-white/5 space-y-6">
                        <div className="flex items-center gap-4">
                            <div className="p-3 bg-green-500/10 rounded-xl text-green-500">
                                <DollarSign size={24} />
                            </div>
                            <div>
                                <h4 className="text-xl font-bold text-white">PKR Operational</h4>
                                <p className="text-xs text-gray-500">Easypaisa & JazzCash Live</p>
                            </div>
                        </div>

                        <div className="pt-6 border-t border-white/5">
                            <div className="flex justify-between items-center mb-4">
                                <span className="text-sm text-gray-400">Monthly Revenue</span>
                                <span className="text-sm font-bold text-white">Rs. 45,200</span>
                            </div>
                            <div className="w-full bg-white/5 h-2 rounded-full overflow-hidden">
                                <div className="bg-primary h-full w-[65%] shadow-[0_0_10px_#ff2d55]"></div>
                            </div>
                        </div>

                        <button className="w-full bg-white/5 hover:bg-white/10 text-white text-xs font-bold py-4 rounded-xl transition-all border border-white/5">
                            DOWNLOAD FINANCIAL REPORT
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
