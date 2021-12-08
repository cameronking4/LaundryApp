import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store_delivery/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store_delivery/blocs/manage_delivery_bloc/assigned_delivery_orders_bloc.dart';
import 'package:grocery_store_delivery/blocs/manage_delivery_bloc/completed_delivery_orders_bloc.dart';
import 'package:grocery_store_delivery/blocs/manage_delivery_bloc/manage_delivery_bloc.dart';
import 'package:grocery_store_delivery/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store_delivery/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:grocery_store_delivery/blocs/user_bloc/user_bloc.dart';
import 'package:grocery_store_delivery/screens/home_screen.dart';

import 'blocs/previous_orders_bloc/previous_orders_bloc.dart';
import 'repositories/authentication_repository.dart';
import 'repositories/user_data_repository.dart';
import 'screens/sign_in_screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final UserDataRepository userDataRepository = UserDataRepository();
  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AssignedDeliveryOrdersBloc>(
          create: (context) => AssignedDeliveryOrdersBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CompletedDeliveryOrdersBloc>(
          create: (context) => CompletedDeliveryOrdersBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<ManageDeliveryBloc>(
          create: (context) => ManageDeliveryBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<PreviousOrdersBloc>(
          create: (context) => PreviousOrdersBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Wash App Driver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColorDark: Color(0xFF123938),
        primaryColor: Color(0xFF38C2B0),
        accentColor: Colors.amber,
        backgroundColor: Color(0xFF1C6158),
        canvasColor: Color(0xFFFFFFDF)
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/sign_in': (context) => SignInScreen(),
      },
    );
  }
}
