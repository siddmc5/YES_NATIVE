const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

/**
 * Initialise the Firebase Admin SDK.
 *
 * Reads the service account key file specified in the
 * FIREBASE_SERVICE_ACCOUNT_PATH environment variable.
 *
 * ── Setup ────────────────────────────────────────────────────────────────
 * 1. Go to Firebase Console → Project Settings → Service Accounts.
 * 2. Click "Generate new private key" and download the JSON file.
 * 3. Save it as `config/firebase-service-account.json`.
 * 4. Set FIREBASE_SERVICE_ACCOUNT_PATH in .env accordingly.
 * ─────────────────────────────────────────────────────────────────────────
 */
function initFirebaseAdmin() {
  if (admin.apps.length > 0) return admin; // Already initialised

  let serviceAccount;

  // 1. Try reading from environment variable (for Render/Cloud)
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    try {
      serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
      console.log('✅ Loaded Firebase credentials from environment variable');
    } catch (err) {
      console.error('❌ Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON:', err.message);
      return null;
    }
  } 
  // 2. Fallback to local file path
  else {
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (!serviceAccountPath) {
      console.warn('⚠️ FIREBASE_SERVICE_ACCOUNT_PATH not set in .env');
      return null;
    }

    const resolvedPath = path.resolve(__dirname, '..', serviceAccountPath);

    if (!fs.existsSync(resolvedPath)) {
      console.warn(`⚠️ Firebase service account file not found at: ${resolvedPath}`);
      return null;
    }

    serviceAccount = require(resolvedPath);
    console.log('✅ Loaded Firebase credentials from local file');
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  console.log('✅ Firebase Admin SDK initialised');
  return admin;
}

// Export a flag to check if Firebase Admin is available
function isFirebaseInitialized() {
  return admin.apps.length > 0;
}

module.exports = { initFirebaseAdmin, admin, isFirebaseInitialized };
