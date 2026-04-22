import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';

import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../appwrite_interface.dart';
import '../../localDB.dart';
import 'dart:async';

const String apiTestKey = 'test_vqlKZnJUaToSCsVrhYuGWxANmJC';
const String apiMasterKey = 'appl_siybJkwPJjYjLvxgxdVTiQsKVXd';

Future<void> initializeRevenueCat() async {
  // Platform-specific API keys
  String apiKey;
  if (Platform.isIOS) {
    apiKey = apiTestKey;
  } else if (Platform.isAndroid) {
    apiKey = apiTestKey;
  } else {
    throw UnsupportedError('(RC100)Platform not supported');
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));
  print('(RC101)${apiKey}');
}

Future<void> getCustomerInfo() async {
  CustomerInfo customerInfo = await Purchases.getCustomerInfo();
  final hasPro = customerInfo.entitlements.active.containsKey('airstudio Pro');
  print('(RC102)£${hasPro}....${customerInfo}');
}

Future<PaywallResult> getPaywallResult() async {
  final PaywallResult paywallResult = await RevenueCatUI.presentPaywall();
  return paywallResult;
}

class ContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaywallView(
        onDismiss: () {
          // Dismiss the paywall, e.g. remove the view, navigate to another screen.
        },
      ),
    );
  }
}

//...

Future<void> initPlatformState() async {
  try {
    print('(RC60)');
    await Purchases.setLogLevel(LogLevel.debug);
    print('(RC61)${apiMasterKey}');
    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(apiMasterKey);
      /*if (buildingForAmazon) {
      // use your preferred way to determine if this build is for Amazon store
      // checkout our MagicWeather sample for a suggestion
      configuration = AmazonConfiguration(<revenuecat_project_amazon_api_key>);
    }*/
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(apiMasterKey);
    }
    print('(RC62)${configuration}');

    await Purchases.configure(configuration);
    print('(RC63)${configuration}');
  } on Exception catch (e) {
    print('(RC64)${e}');
  }
}

Future<void> setRCuserId(String userId) async {
  await Purchases.configure(PurchasesConfiguration(apiMasterKey)..appUserID = userId);
}

Future<PaywallResult> presentPaywall() async {
  late PaywallResult paywallResult;
  try {
    print('(RC70)');
    paywallResult = await RevenueCatUI.presentPaywall();
    log('(RC71)Paywall result: $paywallResult');
  } on Exception catch (e) {
    print('(RC72)${e}');
  }
  return paywallResult;
}

void presentPaywallIfNeeded() async {
  final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
  log('Paywall result: $paywallResult');
}

Future<void> showCustomerInfo() async {
  try {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    print(
        '(RC81)${customerInfo}....${customerInfo.activeSubscriptions},,,,${customerInfo.entitlements}');
    print(
        '(RC82)${customerInfo.originalAppUserId}....${customerInfo.entitlements.active},,,,${customerInfo.activeSubscriptions}++++${customerInfo.allExpirationDates}');
    /* if (customerInfo.entitlements.all[<my_entitlement_identifier>].isActive) {
      // Grant user "pro" access
    }*/
  } on Exception catch (e) {
    print('(RC83)${e}');
  }
}

Future<void> setOriginalAppUserId() async {
  try {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    String? originalAppUserId = customerInfo.originalAppUserId;
    print(
        '(RC31)${originalAppUserId}....${customerInfo.activeSubscriptions},,,,${customerInfo.entitlements}+++${customerInfo}');
    if ((originalAppUserId != null) && (originalAppUserId != '')) {
      print(
          '(RC32)${originalAppUserId}....${customerInfo.entitlements},,,,${customerInfo.activeSubscriptions}++++${customerInfo.allExpirationDates}');
      await updateDocument(
          collection: usersRef,
          document: currentUser!.reference,
          data: {kUserOriginalAppUserId: originalAppUserId});
    }

    /* if (customerInfo.entitlements.all[<my_entitlement_identifier>].isActive) {
      // Grant user "pro" access
    }*/
  } on Exception catch (e) {
    print('(RC30)${e}');
  }
}

Future<List<Package>> getPackages() async {
late Offering? current;
try{
  final offerings = await Purchases.getOfferings();
  print('(RC110)${offerings}');
   current = offerings.current;
  if (current == null) return [];
} on Exception catch (e) {
print('(RC30)${e}');
}
  return current!.availablePackages;
}

// Each package gives you store-localized info:
// package.storeProduct.title        — "Premium Monthly"
// package.storeProduct.description  — "Unlock all features"
// package.storeProduct.priceString  — "$4.99"
// package.packageType               — monthly, annual, lifetime, etc.

Future<bool> purchase(Package package) async {
  try {
    final result = await Purchases.purchasePackage(package);
    // Check if the user now has premium access
    return result.customerInfo.entitlements.active.containsKey('premium');
  } on PlatformException catch (e) {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
      return false; // user cancelled, not an error
    }
    rethrow;
  }
}

Future<bool> isPremium() async {
  final customerInfo = await Purchases.getCustomerInfo();
  return customerInfo.entitlements.active.containsKey('premium');
}

void addRCListener() {
  Purchases.addCustomerInfoUpdateListener((customerInfo) {
    final isPremium = customerInfo.entitlements.active.containsKey('premium');
// Update your app state
  });
}

Future<bool> restorePurchases() async {
  final customerInfo = await Purchases.restorePurchases();
  return customerInfo.entitlements.active.containsKey('premium');
}

// After your user logs in
Future<void> loginRC() async {
  await Purchases.logIn('your-user-id');
}

// After your user logs out
Future<void> logoutRC() async {
  await Purchases.logOut();
}

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package> packages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOfferings();
  }

  Future<void> loadOfferings() async {
    final offerings = await Purchases.getOfferings();
    setState(() {
      packages = offerings.current?.availablePackages ?? [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (loading) return Center(child: CircularProgressIndicator());

    return Container(
      height: 500,
      child: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          final product = package.storeProduct;
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: Text(product.priceString),
            onTap: () async {
              try {
                final result = await Purchases.purchasePackage(package);
                if (result.customerInfo.entitlements.active.containsKey('premium')) {
                  Navigator.pop(context, true);
                }
              } on PlatformException {
                // Handle error
              }
            },
          );
        },
      ),
    );
  }
}
