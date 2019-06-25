import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fashionet/repositories/repositories.dart';
import 'package:meta/meta.dart';

// login state
@immutable
class VerificationState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  // bool get isFormValid => isFieldValueValid;

  VerificationState({
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory VerificationState.empty() {
    return VerificationState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory VerificationState.loading() {
    return VerificationState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory VerificationState.failure() {
    return VerificationState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory VerificationState.success() {
    return VerificationState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  // VerificationState update() {
  //   return copyWith(
  //     // // isEmailValid: isEmailValid,
  //     // // isFieldValueValid: isFieldValueValid,
  //     isSubmitting: false,
  //     isSuccess: false,
  //     isFailure: false,
  //   );
  // }

  VerificationState copyWith({
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
    String verificationId,
  }) {
    return VerificationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''VerificationState {
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,     
    }''';
  }
}

// login event
@immutable
abstract class VerificationEvent extends Equatable {
  VerificationEvent([List props = const []]) : super(props);
}

class VerifyPhoneNumberButtonPressed extends VerificationEvent {
  final String phoneNumber;

  VerifyPhoneNumberButtonPressed({@required this.phoneNumber})
      : super([phoneNumber]);

  @override
  String toString() => 'Submitted { phoneNumber: $phoneNumber }';
}

// login bloc
class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final UserRepository _userRepository;

  VerificationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  VerificationState get initialState => VerificationState.empty();

  void onVerifyPhoneNumberButtonPressed({@required String phoneNumber}) {
    dispatch(VerifyPhoneNumberButtonPressed(phoneNumber: phoneNumber));
  }

  @override
  Stream<VerificationState> mapEventToState(
    VerificationEvent event,
  ) async* {
    if (event is VerifyPhoneNumberButtonPressed) {
      yield* _mapVerifyPhoneNumberButtonPressedToState(
          phoneNumber: event.phoneNumber);
    }
  }

  Stream<VerificationState> _mapVerifyPhoneNumberButtonPressedToState(
      {@required String phoneNumber}) async* {
    yield VerificationState.loading();

    try {
      await _userRepository.verifyPhoneNumber(phoneNumber: phoneNumber);
      yield VerificationState.success();
    } catch (e) {
      yield VerificationState.failure();
    }
  }
}
