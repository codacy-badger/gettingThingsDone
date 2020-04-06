import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/auth/login/login_barrel.dart';
import 'package:gtd/auth/login/login_form.dart';
import 'package:gtd/core/core_blocs/navigator_bloc.dart';
import 'package:gtd/core/repositories/remote/user_repository.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.pink[200]),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => {
                        BlocProvider.of<NavigatorBloc>(context)
                            .add(NavigatorAction.NavigatorActionPop)
                      },
                      child: Icon(Icons.arrow_back_ios, color: Colors.white),
                    )
                  ],
                ),
                SizedBox(height: (MediaQuery.of(context).size.height / 10) * 2),
                BlocProvider<LoginBloc>(
                  create: (context) =>
                      LoginBloc(userRepository: _userRepository),
                  child: LoginForm(userRepository: _userRepository),
                ),
              ],
            ),
          )),
    );
  }
}
