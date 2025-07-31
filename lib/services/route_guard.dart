import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RouteGuard {
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static String? redirectLogic(BuildContext context, GoRouterState state) {
    final isLoggedIn = isAuthenticated();
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToLanding = state.matchedLocation == '/';

    // If user is logged in and trying to access login or landing page, redirect to home
    if (isLoggedIn && (isGoingToLogin || isGoingToLanding)) {
      return '/home';
    }

    // If user is not logged in and trying to access protected routes, redirect to login
    if (!isLoggedIn && !isGoingToLogin && !isGoingToLanding) {
      return '/login';
    }

    // Allow access
    return null;
  }
}
