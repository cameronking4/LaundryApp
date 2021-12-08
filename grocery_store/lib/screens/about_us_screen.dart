import 'dart:io';

import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/add_address_screen.dart';
import 'package:grocery_store/screens/all_cards_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/address_item.dart';
import '../config/config.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutUsScreen extends StatefulWidget {
  final User currentUser;

  const AboutUsScreen({this.currentUser});

  @override
  State<StatefulWidget> createState() => AboutUsScreenState();
  }
  

class AboutUsScreenState extends State<AboutUsScreen> {
  AccountBloc accountBloc;
  GroceryUser user;
  TextEditingController mobileNoController;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String mobileNo, email, name;
  bool inProgress;
  bool isUpdated;

  var image;
  File selectedProfileImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).primaryColorDark,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'About Us',
                      style: GoogleFonts.lora(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder(
              cubit: accountBloc,
              buildWhen: (previous, current) {
                if (current is GetAccountDetailsInProgressState ||
                    current is GetAccountDetailsFailedState ||
                    current is GetAccountDetailsCompletedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAccountDetailsInProgressState) {
                  //TODO: add shimmmer
                  return Center(child: CircularProgressIndicator());
                }
                if (state is GetAccountDetailsFailedState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/banners/retry.svg',
                        width: size.width * 0.6,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Failed to get account details!',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.lora(
                          color: Colors.black.withOpacity(0.9),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  );
                }
                if (state is GetAccountDetailsCompletedState) {
                  user = state.user;

                  return ListView(
                    padding: const EdgeInsets.only(top: 20.0),
                    shrinkWrap: true,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black.withOpacity(0.05),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 0.0),
                              blurRadius: 15.0,
                              spreadRadius: 2.0,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Welcome!',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Divider(),
                            SizedBox(
                              height: 5.0,
                            ),
                            Center(
                                    child: Text(
                                      'Since our opening, we have tailored our laundry pick up and drop off process to meet the needs of the community. We are committed to delivering eco-friendly, clean & quality laundry/dry cleaning services with incomparable customer care! Our goal is to help you take back your time.\n\nStarting at just \$25/week, we will pick up, wash, fold and return your laundry within 24 hours!\n\nWe pick up on Mondays, Wednesdays and Fridays between 10am & 2pm. So what are you waiting for? Sign up for our services TODAY, and take back your time, because your time is the ultimate luxury!',
                                      style: GoogleFonts.lora(
                                        color: Colors.black87,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black.withOpacity(0.05),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 0.0),
                              blurRadius: 15.0,
                              spreadRadius: 2.0,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'FAQ: Can I recieve a delivery if I am not home?',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Divider(),
                            SizedBox(
                              height: 5.0,
                            ),
                            Center(
                                    child: Text(
                                      'If you are not available during our delivery window, you can notify us when you schedule your pick up and drop off by designating where you would like your order to be left. Please note that we are not liable for laundry after it has been delivered to your preferred location. In addition, while we do offer personless pickup and delivery options, we require that you be available for your first pickup so that we may go through the onboarding process with you. \n\nIf you opt to utilize Wash and Drop for pickup or delivery, we ask you to consider that our Concierge has access to a safe place to pick up and deliver your clothes. Typically, this means you can buzz us into your apartment building remotely or you can provide a door code, but every situation is different. If you don’t feel comfortable with your items or deliveries being left there, please don’t select it as your Wash and Drop location!',
                                      style: GoogleFonts.lora(
                                        color: Colors.black87,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        height: 50.0,
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 0.0),
                              blurRadius: 15.0,
                              spreadRadius: 2.0,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),
                        child: FlatButton(
                          onPressed: () {
                            launchURL("http://mywashup.com");
                          },
                          color: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            children: <Widget>[
                               SizedBox(
                                width: 25.0,
                              ),
                              Icon(
                                Icons.web,
                                color: Colors.black.withOpacity(0.8),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Learn More (view website)',
                                style: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        height: 45.0,
                        width: size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: FlatButton(
                          onPressed: () {
                            //update
                            launchURL("http://instagram.com/mywashup");
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            ' + Follow Us on Instagram',
                            style: GoogleFonts.lora(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

 Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
 }
