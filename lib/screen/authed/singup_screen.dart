import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:liber/bloc/auth_bloc/auth_bloc.dart';
import 'package:liber/bloc/auth_bloc/auth_state.dart';
import 'package:liber/core/constant/color.dart';
import 'package:liber/core/constant/divider.dart';
import 'package:liber/core/constant/font.dart';
import 'package:liber/data/models/authed/singup_request.dart';
import 'package:liber/widgets/edit_text.dart';
import 'package:liber/widgets/sliver_box.dart';

import '../../widgets/loading_dialog.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({Key? key}) : super(key: key);

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  final mRequest = SingUpRequest();
  final bloc = GetIt.instance.get<AuthBloc>();
  bool isAllowPop = true;

  @override
  Widget build(BuildContext context) {
    /// request data
    final query = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kDarked,
      body: BlocProvider<AuthBloc>(
        create: (_) => bloc,
        child: CustomScrollView(
          slivers: [
            _titleSingUp(query, context),

            /// form sing up information
            _singUpForm(query, context),
          ],
        ),
      ),
    );
  }

  SliverBox _singUpForm(MediaQueryData query, BuildContext context) {
    return SliverBox(
      maxHeight: query.size.height * .7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefault),
        child: Column(
          children: [
            ///auth state
            BlocListener<AuthBloc, IAuthState>(
              bloc: bloc,
              listener: (context, state) {
                if (state is SingUpSuccess) {
                  ///go to home screen
                  Navigator.pop(context);
                }

                if(state is SingUpFailed){
                  Navigator.pop(context);
                }
              },
              child: const SizedBox(),
            ),

            /// edit username
            BlocBuilder<AuthBloc, IAuthState>(builder: (context, state) {
              if (state is ValidTextField) {
                return _editTextBloc(query, state);
              }
              return _editTextBloc(
                  query,
                  ValidTextField(
                      request: mRequest, confirmPW: true, mPW: true));
            }),

            /// sex
            BlocBuilder<AuthBloc, IAuthState>(
              builder: (context, state) {
                if (state is SelectSexState) {
                  mRequest.sex = state.isMale ? 2 : 1;
                  return _checkBoxSex(context, state.isMale);
                }
                return _checkBoxSex(context, mRequest.sex == 1 ? false : true);
              },
            ),

            /// btn sing up
            GestureDetector(
              onTap: () async {
                loadingDialog(context: context);

                ///call register
                bloc.register(mRequest);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: kDefault * 2),
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefault, vertical: kDefault / 2),
                decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: BorderRadius.circular(kDefault),
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(5.0, 5.0),
                          color: kGreen.withOpacity(kOpacity),
                          blurRadius: 5.0)
                    ]),
                child: Text(
                  "Sing Up Now",
                  textAlign: TextAlign.center,
                  style: kFontMedium(context)?.copyWith(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _editTextBloc(MediaQueryData query, ValidTextField state) {
    return Column(
      children: [
        EditText(
          width: query.size.width * .8,
          height: query.size.height * .05,
          onTextChange: (value) => mRequest.email = value,
          label: "Email",
          inputType: TextInputType.emailAddress,
          validator: (value) {
            return !RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch("$value")
                ? null
                : "Invalid Email Format";
          },
        ),
        EditText(
          width: query.size.width * .8,
          height: query.size.height * .05,
          label: "Username",
          error: state.request?.userName == "" && state.request?.isCall == false
              ? "Please Enter Username"
              : null,
          onTextChange: (value) => mRequest.userName = value,
        ),
        EditText(
          width: query.size.width * .8,
          height: query.size.height * .05,
          label: "Alias name",
          onTextChange: (value) => mRequest.aliasName = value,
        ),
        EditText(
          width: query.size.width * .8,
          height: query.size.height * .05,
          onTextChange: (value) => mRequest.phoneNumber = value,
          label: "Call Phone Number",
          inputType: TextInputType.number,
        ),
        EditText(
            width: query.size.width * .8,
            height: query.size.height * .05,
            label: "Password",
            validator: (value) {
              return "$value".length < 6
                  ? "Please Enter Password 6 Character"
                  : null;
            },
            error: state.request?.isValidPassword() == 0 &&
                    state.request?.isCall == true
                ? null
                : state.request?.isValidPassword() == 0 &&
                        state.request?.isCall == false
                    ? null
                    : "Password Invalid",
            isPassword: state.mPW,
            icon: state.mPW
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            iconTab: () =>
                bloc.visiblePW(!state.mPW, state.confirmPW, mRequest),
            inputType: TextInputType.visiblePassword,
            onTextChange: (value) => mRequest.password = value,
            formatter: [LengthLimitingTextInputFormatter(6)]),
        EditText(
          width: query.size.width * .8,
          height: query.size.height * .05,
          label: "Confirm Password",
          validator: (value) {
            return "$value".length < 6
                ? "Please Enter Password 6 Character"
                : null;
          },
          error: state.request?.isValidPassword() == 0 &&
                  state.request?.isCall == true
              ? null
              : state.request?.isValidPassword() == 0 &&
                      state.request?.isCall == false
                  ? null
                  : "Password Invalid",
          isPassword: state.confirmPW,
          icon: state.confirmPW
              ? const Icon(Icons.visibility_off)
              : const Icon(Icons.visibility),
          iconTab: () => bloc.visiblePW(state.mPW, !state.confirmPW, mRequest),
          inputType: TextInputType.visiblePassword,
          onTextChange: (value) => mRequest.confirmPassword = value,
          formatter: [LengthLimitingTextInputFormatter(6)],
        ),
      ],
    );
  }

  Row _checkBoxSex(BuildContext context, bool isMale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Male",
            style: kFontSmall(context)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        InkWell(
          onTap: () => context.read<AuthBloc>().selectSex(true),
          child: Container(
              margin: const EdgeInsets.symmetric(
                  vertical: kDefault * 1.5, horizontal: kDefault),
              width: kHeight - 10,
              height: kHeight - 10,
              decoration: const BoxDecoration(
                  color: kDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kDarked, offset: Offset(0, 5.0), blurRadius: 5.0)
                  ]),
              child: TweenAnimationBuilder<double>(
                tween: isMale
                    ? Tween<double>(begin: 0.0, end: 1.0)
                    : Tween<double>(begin: 1.0, end: 0.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                      opacity: value,
                      duration: const Duration(milliseconds: 800),
                      child: child);
                },
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.grey),
              )),
        ),
        Text("Free Male",
            style: kFontSmall(context)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        InkWell(
          onTap: () => context.read<AuthBloc>().selectSex(false),
          child: Container(
              margin: const EdgeInsets.symmetric(
                  vertical: kDefault * 1.5, horizontal: kDefault),
              width: kHeight - 10,
              height: kHeight - 10,
              decoration: const BoxDecoration(
                  color: kDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kDarked, offset: Offset(0, 5.0), blurRadius: 5.0)
                  ]),
              child: TweenAnimationBuilder<double>(
                tween: isMale
                    ? Tween<double>(begin: 1.0, end: 0.0)
                    : Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                      opacity: value,
                      duration: const Duration(milliseconds: 800),
                      child: child);
                },
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.grey),
              )),
        ),
      ],
    );
  }

  SliverBox _titleSingUp(MediaQueryData query, BuildContext context) {
    return SliverBox(
      maxHeight: query.size.height * .3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefault),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: query.size.height * .12),
            Text("Sing Up Page\n".toUpperCase(),
                style: kFontMedium(context)?.copyWith(
                    color: Colors.grey, fontWeight: FontWeight.w700)),
            Text("Create Your Account Here.",
                style: kFontH6(context)?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefault * 2),
              child: Row(
                children: [
                  Text(
                    "Already A Account?   ",
                    style: kFontSmall(context)?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Sing In",
                      style: kFontMedium(context)?.copyWith(
                          color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
