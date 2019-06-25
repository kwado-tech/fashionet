import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  String _verificationId;

  UserRepository({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<bool> isSignedIn() async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser != null ? true : false;
  }

  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).phoneNumber ?? '';
  }

  Future<String> verifyPhoneNumber({@required String phoneNumber}) async {
    // String _verificationId;

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential);

      print('Received phone auth credential: $phoneAuthCredential');
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('Please check your phone for the verification code.');

      _verificationId = verificationId;
      print('PhoneCodeSent $_verificationId');
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    print(phoneNumber);

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

    // return '_verificationId';
    return _verificationId;
  }

  Future<void> logInWithPhoneNumber({@required String verificationCode}) async {
    // print('$_verificationId');

    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: verificationCode,
      );

      final FirebaseUser user =
          await _firebaseAuth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);

      user != null
          ? print('Successfully signed in, uid: ' + user.uid)
          : print('Sign in failed');
    } catch (e) {
      print(e.toString());
      // throw(e.toString());
    }
  }

  Future<void> signout() {
    return Future.wait([
      _firebaseAuth.signOut(),
    ]);
  }
}
