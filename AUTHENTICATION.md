# Authentication System Documentation

## Overview
This application implements a dual authentication system:
- **Teachers**: Login using `real_name` + `password`
- **Students**: Login using Google Sign-In only

## Features Implemented

### 1. User Model (`lib/models/user_model.dart`)
- Complete Firestore integration with user data structure
- Auto-generation of anonymous names for students
- User type differentiation (Teacher = 1, Student = 0)

### 2. Authentication Service (`lib/services/auth_service.dart`)
- **`signInWithRealNameAndPassword()`**: For teacher login
- **`signInWithGoogle()`**: For student login with auto-registration
- **`getCurrentUserData()`**: Get user data from Firestore
- **`signOut()`**: Complete logout including Google Sign-In
- Automatic user creation for new Google sign-ins

### 3. Route Protection (`lib/services/route_guard.dart`)
- Automatic redirection based on authentication status
- Prevents unauthenticated access to protected routes
- Redirects logged-in users away from login page

### 4. Updated Login Page (`lib/pages/login_page.dart`)
- Real authentication instead of demo mode
- Validation for real_name (not email) and password
- Error handling with user-friendly messages
- Automatic navigation on successful login

### 5. Logout Component (`lib/widgets/logout_button.dart`)
- Confirmation dialog before logout
- Proper cleanup of both Firebase Auth and Google Sign-In

## Database Structure

The Firestore `users` collection contains documents with these fields:

```dart
{
  "anonymous_name": "Anonim1234",    // Auto-generated for students
  "created_at": Timestamp,
  "email": "user@example.com",       // From Google or auto-generated
  "google_id": "google_uid_here",    // For Google sign-in users
  "id": 1,                          // Incremental user ID
  "is_blocked": false,
  "password": "password123",         // For teachers only
  "real_name": "John Doe",
  "rejected_reports_count": 0,
  "total_points": 0,
  "updated_at": Timestamp,
  "user_type": 0                    // 0=Student, 1=Teacher
}
```

## Usage

### For Teacher Login:
1. Enter `real_name` in the username field
2. Enter `password`
3. System validates against Firestore and creates/uses Firebase Auth account

### For Student Login:
1. Click "Continue With Google"
2. Complete Google Sign-In
3. System auto-creates student account if first login
4. Generates anonymous name automatically

### Route Protection:
- Unauthenticated users are redirected to `/login`
- Authenticated users are redirected from `/login` to `/home`
- All routes except `/` and `/login` require authentication

## Security Features

1. **Password Validation**: Teachers must have valid credentials in Firestore
2. **Account Blocking**: Blocked users cannot login
3. **Route Guards**: Prevent unauthorized access
4. **Auto-logout**: Google Sign-In is properly cleared on logout
5. **Email Generation**: Auto-generates email for teachers without one

## Testing

To test the authentication system:

1. **Teacher Login**: Create a user in Firestore with:
   - `user_type: 1`
   - `real_name: "Test Teacher"`
   - `password: "test123"`

2. **Student Login**: Use any Google account - will auto-create student profile

3. **Route Protection**: Try accessing `/home` without logging in

## Error Handling

The system handles various error scenarios:
- Invalid credentials
- Blocked accounts
- Network errors
- Google Sign-In cancellation
- Firestore connection issues

All errors are displayed to users with helpful messages via SnackBars.
