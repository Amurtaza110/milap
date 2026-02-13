export const USERS = [
    { email: 'support@milap.app', pin: '1234', role: 'SUPPORT', name: 'Support Agent' },
    { email: 'manager@milap.app', pin: '1234', role: 'MANAGER', name: 'Connect Manager' },
    { email: 'marketing@milap.app', pin: '1234', role: 'MARKETING', name: 'Marketing Lead' },
    { email: 'dev@milap.app', pin: '1234', role: 'DEVELOPER', name: 'Dev Team' },
    { email: 'owner@milap.app', pin: '1234', role: 'OWNER', name: 'Super Admin' },
];

export const TICKETS = [
    { id: 1, user: 'Ali Khan', issue: 'Payment failed for Gold status', status: 'OPEN', date: '2023-10-25' },
    { id: 2, user: 'Sara Ahmed', issue: 'Reported abusive behavior in Room #42', status: 'PENDING', date: '2023-10-24' },
    { id: 3, user: 'John Doe', issue: 'App crashing on splash screen', status: 'RESOLVED', date: '2023-10-23' },
];

export const STATS = {
    activeUsers: 1450,
    goldMembers: 320,
    revenue: 450000,
    ticketsOpen: 12,
};
