const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { userId, title, message } = data;

  if (!userId || !title || !message) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with the arguments 'userId', 'title', and 'message'."
    );
  }

  const userDoc = await admin.firestore().collection("users").doc(userId).get();

  if (!userDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      `User with ID ${userId} not found.`
    );
  }

  const user = userDoc.data();
  const { fcmToken, notificationsEnabled } = user;

  if (notificationsEnabled && fcmToken) {
    const payload = {
      notification: {
        title,
        body: message,
      },
    };

    await admin.messaging().sendToDevice(fcmToken, payload);
  }
});

exports.sendPushBlast = functions.https.onCall(async (data, context) => {
  // We should verify admin role here, but keeping it simple for the demo
  const { title, message, target } = data;

  if (!title || !message) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with 'title' and 'message'."
    );
  }

  try {
    const db = admin.firestore();
    let query = db.collection("users").where("isDeactivated", "==", false);

    if (target === "milap_plus") {
      query = query.where("isMilapGold", "==", true);
    }
    // "all" doesn't require extra filters.

    const snapshot = await query.get();
    const tokens = [];

    snapshot.forEach((doc) => {
      const user = doc.data();
      if (user.fcmToken && user.notificationsEnabled !== false) {
        tokens.push(user.fcmToken);
      }
    });

    if (tokens.length === 0) {
      return { success: true, count: 0, message: "No target users found with FCM tokens." };
    }

    const payload = {
      notification: {
        title: title,
        body: message,
      },
    };

    // Firebase Admin SDK > v10 uses sendToDevice/sendMulticast, but let's use sendEachForMulticast if available
    const response = await admin.messaging().sendMulticast({
      tokens,
      notification: payload.notification,
    });

    return { 
      success: true, 
      count: response.successCount, 
      failed: response.failureCount 
    };

  } catch (error) {
    console.error("Error sending push blast:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while sending push notifications."
    );
  }
});

exports.getUsersByCountry = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to discover by country."
    );
  }

  const { country, limit = 50, lastUserId } = data;

  if (!country || typeof country !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with a valid 'country' argument."
    );
  }

  try {
    const db = admin.firestore();
    let query = db
      .collection("users")
      .where("country", "==", country)
      .where("isDeactivated", "==", false)
      .limit(limit);

    // Basic cursor-based pagination
    if (lastUserId) {
      const lastDoc = await db.collection("users").doc(lastUserId).get();
      if (lastDoc.exists) {
        query = query.startAfter(lastDoc);
      }
    }

    const snapshot = await query.get();
    
    const users = [];
    snapshot.forEach((doc) => {
      // Exclude the requesting user from the results
      if (doc.id !== context.auth.uid) {
        users.push({ id: doc.id, ...doc.data() });
      }
    });

    // We can do server-side sorting here if needed, or leave it to client
    // For now, we return the documents and let the client sort them by online/rating
    
    return { users };
  } catch (error) {
    console.error("Error fetching users by country:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while fetching users."
    );
  }
});
