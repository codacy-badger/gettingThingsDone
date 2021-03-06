import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gtd/auth/register/register_barrel.dart';
import 'package:gtd/core/repositories/remote/user_repository.dart';
import 'package:gtd/core/validators/login_validators.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<RegisterState> transformEvents(
    Stream<RegisterEvent> events,
    Stream<RegisterState> Function(RegisterEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password);
    } else if (event is PasswordConfirmed) {
      yield* _mapPasswordConfirmedToState(event.password, event.passwordConfirmed);
    }
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: AuthValidators.isValidEmail(email),
    );
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: AuthValidators.isValidPassword(password),
    );
  }

    Stream<RegisterState> _mapPasswordConfirmedToState(String password, String confirmPassword) async* {
    yield state.update(
      isPasswordTheSame: AuthValidators.isPasswordTheSame(password, confirmPassword),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String email,
    String password,
  ) async* {
    yield RegisterState.loading();
    try {
      await _userRepository.signUp(
        email: email,
        password: password,
      );
      yield RegisterState.success();
    } catch (error) {
      if (error.code == "ERROR_EMAIL_ALREADY_IN_USE") {
        yield RegisterState.emailInUse();
      } else {
        yield RegisterState.failure();
      }
    }
  }
}
