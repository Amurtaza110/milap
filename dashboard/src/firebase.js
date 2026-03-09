import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyCFYFHnPDX9sB-qKC07UTdK_dkrfFDhXV0",
  authDomain: "milap-c7e70.firebaseapp.com",
  projectId: "milap-c7e70",
  storageBucket: "milap-c7e70.firebasestorage.app",
  messagingSenderId: "525175136608",
  appId: "1:525175136608:web:b94fd6f72fe0e2a499fe05",
  measurementId: "G-TJLXH681WZ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Export services for use in the dashboard
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
export const analytics = getAnalytics(app);
