import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:liber/bloc/auth_bloc/auth_bloc.dart';
import 'package:liber/bloc/auth_bloc/auth_state.dart';
import 'package:liber/core/constant/color.dart';
import 'package:liber/core/constant/constant.dart';
import 'package:liber/core/constant/divider.dart';
import 'package:liber/core/constant/font.dart';
import 'package:liber/data/models/authed/singing_request.dart';
import 'package:liber/screen/authed/singup_screen.dart';
import 'package:liber/widgets/edit_text.dart';
import 'package:liber/widgets/loading_dialog.dart';

import '../../widgets/sliver_box.dart';

class SingInScreen extends StatefulWidget {
  const SingInScreen({Key? key}) : super(key: key);

  @override
  State<SingInScreen> createState() => _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen> {
  final mRequest = SingInRequest();

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return Scaffold(
        backgroundColor: kDarked,
        body: CustomScrollView(
          slivers: [
            _titleSingIn(query, context),
            _singInForm(context, query),
          ],
        ));
  }

  SliverBox _singInForm(BuildContext context, MediaQueryData query) {
    return SliverBox(
        maxHeight: query.size.height * .72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefault),
          child: Column(
            children: [

              ///auth state
              ///login
              BlocListener<AuthBloc,IAuthState>(
                bloc: context.read<AuthBloc>(),
                listener: (context, state) {
                  if(state is SingInSuccess){
                    ///close dialog
                    Navigator.pop(context);
                    ///go to home screen
                  }
                  if (state is SingInFailed){
                    print("SingInFailed");
                    ///close dialog
                    Navigator.pop(context);
                  }
                },
                child: const SizedBox(),
              ) ,
              /// social authentication
              Padding(
                padding: EdgeInsets.only(top: query.size.height * .08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: kHeight - 10,
                      height: kHeight - 10,
                      decoration: const BoxDecoration(
                          color: kDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: kDarked,
                                offset: Offset(0, 5.0),
                                blurRadius: 5.0)
                          ]),
                      child: CachedNetworkImage(
                        imageUrl:
                            kGIcon,
                        memCacheHeight: (kHeight - 10).toInt(),
                        memCacheWidth: (kHeight - 10).toInt(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: kDefault),
                      padding: const EdgeInsets.all(kDefault / 5),
                      width: kHeight - 10,
                      height: kHeight - 10,
                      decoration: const BoxDecoration(
                          color: kDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: kDarked,
                                offset: Offset(0, 5.0),
                                blurRadius: 5.0)
                          ]),
                      child: CachedNetworkImage(
                        imageUrl:
                            kFIcon,
                        memCacheHeight: (kHeight - 10).toInt(),
                        memCacheWidth: (kHeight - 10).toInt(),
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: query.size.height * .04),

              /// text email
              EditText(
                width: query.size.width * .8,
                height: query.size.height * .05,
                label: "Email",
                onTextChange: (value) => mRequest.email = value,
                inputType: TextInputType.emailAddress,
              ),

              const SizedBox(height: kDefault),

              ///password
              EditText(
                width: query.size.width * .8,
                height: query.size.height * .05,
                label: "Password",
                isPassword: true,
                onTextChange: (value) => mRequest.password = value,
                inputType: TextInputType.visiblePassword,
              ),

              /// btn sing in
              GestureDetector(
                onTap: () {
                  loadingDialog(context: context);
                  context.read<AuthBloc>().singIn(mRequest);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: kDefault * 4),
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
                    "Sing In Now",
                    textAlign: TextAlign.center,
                    style: kFontMedium(context)?.copyWith(
                        fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "Your Not Have Account",
                    style: kFontSmall(context)?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SingUpScreen())),
                      child: Text(
                        "   Create Now.",
                        style: kFontMedium(context)?.copyWith(
                            color: Colors.orange, fontWeight: FontWeight.w700),
                      ))
                ],
              )
            ],
          ),
        ));
  }

  SliverBox _titleSingIn(MediaQueryData query, BuildContext context) {
    return SliverBox(
      maxHeight: query.size.height * .22,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: query.size.height * .06),
          Text("    Your AnyThing",
              style: kFontDisplay(context)?.copyWith(
                color: Colors.grey.withOpacity(.23),
                fontWeight: FontWeight.bold,
              )),
          Text(
            "\n   Sing In \n\n       Your Account.".toUpperCase(),
            style: kFontH5(context)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
