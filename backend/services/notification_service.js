const admin = require('firebase-admin');

/**
 * Sends a push notification using Firebase Cloud Messaging (FCM).
 * @param {string} token - The FCM registration token of the target device.
 * @param {string} title - The notification title.
 * @param {string} body - The notification body text.
 * @param {object} data - Optional extra data payload.
 */
async function sendPushNotification(token, title, body, data = {}) {
  if (!token) return;
  
  try {
    const message = {
      notification: {
        title,
        body,
      },
      data,
      token,
    };
    
    // Only attempt to send if Firebase app is initialized
    if (admin.apps.length > 0) {
      const response = await admin.messaging().send(message);
      console.log('✅ Successfully sent push notification:', response);
    } else {
      console.log('⚠️  Firebase not initialized. Cannot send notification.');
    }
  } catch (error) {
    console.error('❌ Error sending push notification:', error.message);
  }
}

module.exports = {
  sendPushNotification,
};
