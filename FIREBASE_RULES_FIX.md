# Firebase Rules Fix

## Firestore Rules (Copy to Firebase Console → Firestore → Rules)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write reports
    match /reports/{reportId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to access user data
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write comments
    match /comments/{commentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Storage Rules (Copy to Firebase Console → Storage → Rules)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /report_images/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Steps:
1. Go to Firebase Console
2. Firestore → Rules → Paste the Firestore rules above
3. Storage → Rules → Paste the Storage rules above
4. Click "Publish" for both

This should fix your permission errors!
