import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/pages/profile_page.dart';
import 'package:grocery_store/pages/search_page.dart';
import 'package:grocery_store/pages/wishlist_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPage;
  CartCountBloc cartCountBloc;
  CartBloc cartBloc;
  int cartCount;
  NotificationBloc notificationBloc;

  @override
  void initState() {
    super.initState();

    cartCountBloc = BlocProvider.of<CartCountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);

    cartBloc.listen((state) {
      if (state is AddToCartInProgressState) {
        showSnackAdding('Adding to cart');
      }
      if (state is AddToCartCompletedState) {
        Navigator.pop(context);
        showSnack('Added to cart');
      }
    });

    _selectedPage = 0;
  }

  @override
  void dispose() {
    cartCountBloc.close();
    notificationBloc.close();
    super.dispose();
  }

  void showSnackAdding(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.cyan.shade600,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: true,
      duration: Duration(milliseconds: 10000),
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.cyan.shade600,
      messageText: Text(
        '$text',
        style: GoogleFonts.lora(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  void showSnack(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 1500),
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.lora(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        cartCountBloc.close();
        notificationBloc.close();
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        floatingActionButton: GestureDetector(
          onTap: () {
            if (FirebaseAuth.instance.currentUser == null) {
              Navigator.pushNamed(context, '/sign_in');
            } else {
              Navigator.pushNamed(context, '/cart');
            }
          },
          child: Container(
            width: 58.0,
            height: 58.0,
            child: BlocBuilder(
              cubit: cartCountBloc,
              builder: (context, state) {
                if (state is CartCountUpdateState) {
                  cartCount = state.cartCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 55.0,
                          height: 55.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            size: 25.0,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      cartCount > 0
                          ? Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: Container(
                                height: 21.0,
                                width: 21.0,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  color: Colors.amber,
                                ),
                                child: Text(
                                  '$cartCount',
                                  style: GoogleFonts.lora(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                }
                return Container(
                  width: 55.0,
                  height: 55.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 25.0,
                    color:Theme.of(context).primaryColorDark
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          height: Platform.isAndroid ? 60.0 : 85.0,
          width: size.width,
          child: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 6.0,
            color: Theme.of(context).primaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('Home');
                      _pageController.jumpToPage(
                        0,
                        // duration: Duration(milliseconds: 300),
                        // curve: Curves.easeInOut,
                      );
                      setState(() {
                        _selectedPage = 0;
                      });
                    },
                    child: Icon(
                      Icons.store,
                      size: 32.0,
                      color: _selectedPage == 0
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                // Expanded(
                //   child: GestureDetector(
                //     behavior: HitTestBehavior.translucent,
                //     onTap: () {
                //       print('Search');
                //       _pageController.jumpToPage(
                //         1,
                //         // duration: Duration(milliseconds: 300),
                //         // curve: Curves.easeInOut,
                //       );
                //       setState(() {
                //         _selectedPage = 1;
                //       });
                //     },
                //     child: Icon(
                //       Icons.search,
                //       size: 28.0,
                //       color: _selectedPage == 1
                //           ? Theme.of(context).primaryColor
                //           : Colors.black87,
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: size.width * 0.3,
                ),
                // Expanded(
                //   child: GestureDetector(
                //     behavior: HitTestBehavior.translucent,
                //     onTap: () {
                //       print('Wishlist');

                //       if (FirebaseAuth.instance.currentUser == null) {
                //         Navigator.pushNamed(context, '/sign_in');
                //       } else {
                //         _pageController.jumpToPage(2);
                //         setState(() {
                //           _selectedPage = 2;
                //         });
                //       }
                //     },
                //     child: Icon(
                //       Icons.favorite,
                //       size: 28.0,
                //       color: _selectedPage == 2
                //           ? Theme.of(context).primaryColor
                //           : Colors.black87,
                //     ),
                //   ),
                // ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('Profile');

                      _pageController.jumpToPage(
                        3,
                        // duration: Duration(milliseconds: 300),
                        // curve: Curves.easeInOut,
                      );
                      setState(() {
                        _selectedPage = 3;
                      });
                    },
                    child: Icon(
                      Icons.person,
                      size: 32.0,
                      color: _selectedPage == 3
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomePage(),
            SearchPage(),
            WishlistPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
