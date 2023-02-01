import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liber/bloc/auth_bloc/auth_bloc.dart';
import 'package:liber/di/injectable.dart';
import 'package:liber/screen/authed/singing_screen.dart';
import 'package:liber/screen/profile/other/other_profile.dart';
import 'package:liber/screen/profile/user/user_profile.dart';

void main() async {
  await configureDependencies(GetIt.instance);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.robotoSerifTextTheme()),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt.get<AuthBloc>()),
        ],
        child: const OtherProfileScreen()//SingInScreen(),
      ),
    );
  }
}
