import 'package:book_adapter/data/book_item.dart';
import 'package:book_adapter/data/failure.dart';
import 'package:book_adapter/service/firebase_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firebaseControllerProvider = Provider<FirebaseController>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirebaseController(firebaseService);
});

/// Provider to easily get access to the user stream from [FirebaseService]
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final firebaseController = ref.read(firebaseControllerProvider);
  return firebaseController.authStateChange;
});

class FirebaseController {
  FirebaseController(this._firebaseService);
  final FirebaseService _firebaseService;

  // Authentication

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<User?> get authStateChange => _firebaseService.authStateChange;
 
  /// Attempts to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the stream [authStateChange]
  ///
  /// **Important**: You must enable Email & Password accounts in the Auth
  /// section of the Firebase console before being able to use them.
  ///
  /// Returns an [Either]
  /// 
  /// Right [UserCredential] is returned if successful
  /// 
  /// Left [FirebaseFailure] maybe returned with the following error code:
  /// - **invalid-email**:
  ///  - Returned if the email address is not valid.
  /// - **user-disabled**:
  ///  - Returned if the user corresponding to the given email has been disabled.
  /// - **user-not-found**:
  ///  - Returned if there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Returned if the password is invalid for the given email, or the account
  ///    corresponding to the email does not have a password set.
  /// 
  /// Left [Failure] may also be returned with only the failure message
  /// - **Email cannot be empty**
  ///  - Returned if the email address is empty
  /// - **Password cannot be empty**
  ///  - Returned if the password field is empty
  /// - **Password cannot be less than six characters**
  ///  - Returned if the password is less than six characters
  Future<Either<Failure, User>> signIn({required String email, required String password}) async {
    // Guards, return Failure object with reason for failure
    // The message should be displayed to the user
    if (email.isEmpty) {
      return Left(Failure('Email cannot be empty'));
    } else if (password.isEmpty) {
      return Left(Failure('Password cannot be empty'));
    } else if (password.length < 6) {
      return Left(Failure('Password cannot be less than six characters'));
    }

    final res = await _firebaseService.signIn(email: email, password: password);

    // If sign in failed, return the failure object
    // If sign in is successful, return the user object in case the caller cares
    return res.fold(
      (failure) => Left(failure),
      (userCred) {
        final User? user = userCred.user;
        if (user == null) {
          return Left(Failure('Sign In Failed, User is NULL'));
        }
        return Right(user);
      },
    );
  }

  
 
  /// Tries to create a new user account with the given email address and
  /// password.
  ///
  /// Returns an [Either]
  /// 
  /// Right [UserCredential] is returned if successful
  /// 
  /// Left [FirebaseFailure] maybe returned with the following error code:
  /// - **email-already-in-use**:
  ///  - Returned if there already exists an account with the given email address.
  /// - **invalid-email**:
  ///  - Returned if the email address is not valid.
  /// - **operation-not-allowed**:
  ///  - Returned if email/password accounts are not enabled. Enable
  ///    email/password accounts in the Firebase Console, under the Auth tab.
  /// - **weak-password**:
  ///  - Returned if the password is not strong enough.
  /// 
  /// Left [Failure] may also be returned with only the failure message
  /// - **Email cannot be empty**
  ///  - Returned if the email address is empty
  /// - **Password cannot be empty**
  ///  - Returned if the password field is empty
  /// - **Password cannot be less than six characters**
  ///  - Returned if the password is less than six characters
  Future<Either<Failure, User>> signUp({required String email, required String password}) async {
    // Guards, return Failure object with reason for failure
    // The message should be displayed to the user
    if (email.isEmpty) {
      return Left(Failure('Email cannot be empty'));
    } else if (password.isEmpty) {
      return Left(Failure('Password cannot be empty'));
    } else if (password.length < 6) {
      return Left(Failure('Password cannot be less than six characters'));
    }

    final res = await _firebaseService.signUp(email: email, password: password);

    // If sign up failed, return the failure object
    // If sign up is successful, return the user object in case the caller cares
    return res.fold(
      (failure) => Left(failure),
      (userCred) {
        final User? user = userCred.user;
        if (user == null) {
          return Left(Failure('Sign Up Failed, User is NULL'));
        }

        // TODO: Upload user data to database here

        return Right(user);
      },
    );
  }

  /// Signs out the current user.
  ///
  /// If successful, it also update the stream [authStateChange]
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  // Database
  /// WIP
  /// 
  /// Get a list of books from the user's database
  Future<Either<Failure, List<BookItem>>> getBooks() async {
    return _firebaseService.getBooks();
  }
}