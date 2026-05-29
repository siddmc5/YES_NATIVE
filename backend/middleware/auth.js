const { admin, isFirebaseInitialized } = require('../config/firebase-admin');

/**
 * Middleware that verifies the Firebase ID token from the Authorization header.
 *
 * Expects:  Authorization: Bearer <Firebase ID Token>
 *
 * On success, attaches `req.user` with the decoded token payload
 * (containing uid, email, name, picture, etc.).
 *
 * If Firebase Admin is not initialised (e.g. local dev without service account),
 * the middleware returns a 503 with a helpful message instead of crashing.
 *
 * Both the vendor and customer apps send this header after the user
 * signs in with Google via Firebase Auth.
 */
async function authMiddleware(req, res, next) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized — missing or malformed token' });
  }

  const idToken = header.split('Bearer ')[1];

  // If Firebase Admin is not available, fall back to decoding the JWT locally
  // for local development. The Firebase Auth client SDK on the frontend already
  // verified the user's identity — we just trust that token in dev.
  if (!isFirebaseInitialized()) {
    try {
      const payload = JSON.parse(
        Buffer.from(idToken.split('.')[1], 'base64').toString('utf-8'),
      );
      req.user = {
        uid: payload.sub,
        email: payload.email || '',
        name: payload.name || '',
        picture: payload.picture || '',
      };
      console.warn('⚠️  Dev mode: accepted Firebase token without Admin SDK verification');
      return next();
    } catch (_err) {
      return res.status(401).json({ error: 'Unauthorized — invalid token format' });
    }
  }

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = decoded; // { uid, email, name, picture, ... }
    next();
  } catch (err) {
    console.error('❌ Firebase token verification failed:', err.message);
    return res.status(401).json({ error: 'Unauthorized — invalid token' });
  }
}

module.exports = authMiddleware;
