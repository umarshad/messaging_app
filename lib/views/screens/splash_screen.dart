import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:messaging_app/components/constants/lottie_constants.dart';
import 'package:messaging_app/components/constants/sized_box_extension.dart';
import 'package:messaging_app/services/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashServices = SplashServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashServices.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          100.ph,
          Lottie.asset(AppLotties.splashImg),
          150.ph,
          SizedBox(
            height: 80,
            width: 150,
            child: Lottie.asset(AppLotties.loaderImg),
          ),
        ],
      ),
    );
  }
}
