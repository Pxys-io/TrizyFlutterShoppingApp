import 'dart:io';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'package:trizy_app/di/locator.dart';
import 'package:trizy_app/repositories/cart_repository.dart';
import 'package:trizy_app/repositories/products_repository.dart';
import 'package:trizy_app/routing/app_router.dart';
import 'package:trizy_app/theme/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trizy_app/utils/auth_check.dart';
import 'bloc/multistore_integration/multistore_integration_bloc.dart';
import 'bloc/multistore_integration/multistore_integration_event.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {

    /*
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
     */

    await dotenv.load();

    await setupLocator(); // Use await since setupLocator is now async

    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }

    setupStripeKey();
    await Stripe.instance.applySettings();

    await initializeApp();

    runApp(const MyApp());
  } catch (e) {
    print("Initialization error: $e");
  }
}

Future<void> initializeApp() async {
  final isUserAuthenticated = await isAuthenticated();

  if (isUserAuthenticated) {
    final cartRepository = getIt<CartRepository>();
    final productsRepository = getIt<ProductsRepository>();

    try {
      await Future.wait([
        cartRepository.getCartItemsAndSaveToLocal(),
        productsRepository.getLikedProductIdsAndSaveToLocal(),
      ]);
    } catch (e) {
      print("Error during app initialization: $e");
    }
  }
}

void setupStripeKey() {
  final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];

  if (publishableKey == null || publishableKey.isEmpty) {
    throw Exception("Stripe Publishable Key is not found in the .env file.");
  }
  Stripe.publishableKey = publishableKey;
  Stripe.merchantIdentifier = 'trizy-merchant';
  Stripe.urlScheme = 'trizy';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MultistoreIntegrationBloc _multistoreIntegrationBloc;

  @override
  void initState() {
    super.initState();
    _multistoreIntegrationBloc = GetIt.instance<MultistoreIntegrationBloc>();
    _multistoreIntegrationBloc.add(InitializeMultistore()); // Initialize global state
  }

  @override
  void dispose() {
    _multistoreIntegrationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();

    return BlocProvider<MultistoreIntegrationBloc>.value(
      value: _multistoreIntegrationBloc,
      child: MaterialApp.router(
        title: 'Trizy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryLightColor),
          useMaterial3: true,
        ),
        routerDelegate: appRouter.router.routerDelegate,
        routeInformationParser: appRouter.router.routeInformationParser,
        routeInformationProvider: appRouter.router.routeInformationProvider,
      ),
    );
  }
}