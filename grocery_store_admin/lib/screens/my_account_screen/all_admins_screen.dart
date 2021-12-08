import 'package:ecommerce_store_admin/blocs/manage_users_bloc/all_users_bloc.dart';
import 'package:ecommerce_store_admin/blocs/manage_users_bloc/block_user_bloc.dart';
import 'package:ecommerce_store_admin/blocs/manage_users_bloc/manage_users_bloc.dart';
import 'package:ecommerce_store_admin/blocs/my_account_bloc/all_admins_bloc.dart';
import 'package:ecommerce_store_admin/blocs/my_account_bloc/deactivate_admin_bloc.dart';
import 'package:ecommerce_store_admin/blocs/my_account_bloc/my_account_bloc.dart';
import 'package:ecommerce_store_admin/models/admin.dart';
import 'package:ecommerce_store_admin/models/user.dart';
import 'package:ecommerce_store_admin/widgets/common_admin_item.dart';
import 'package:ecommerce_store_admin/widgets/common_user_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AllAdminsScreen extends StatefulWidget {
  @override
  _AllAdminsScreenState createState() => _AllAdminsScreenState();
}

class _AllAdminsScreenState extends State<AllAdminsScreen>
    with SingleTickerProviderStateMixin {
  List<Admin> allAdmins;
  AllAdminsBloc allAdminsBloc;
  DeactivateAdminBloc deactivateAdminBloc;

  @override
  void initState() {
    super.initState();

    allAdminsBloc = BlocProvider.of<AllAdminsBloc>(context);
    deactivateAdminBloc = BlocProvider.of<DeactivateAdminBloc>(context);

    allAdmins = [];

    allAdminsBloc.add(GetAllAdminsEvent());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
                              color: Colors.white,
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
                      'All Admins',
                      style: GoogleFonts.lora(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder(
              cubit: allAdminsBloc,
              buildWhen: (previous, current) {
                if (current is GetAllAdminsCompletedState ||
                    current is GetAllAdminsInProgressState ||
                    current is GetAllAdminsFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllAdminsInProgressState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                  //TODO: ADD SHIMMER
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    itemBuilder: (context, index) {
                      // return Shimmer.fromColors(
                      //   period: Duration(milliseconds: 800),
                      //   baseColor: Colors.grey.withOpacity(0.5),
                      //   highlightColor: Colors.black.withOpacity(0.5),
                      //   child: ShimmerAdminItem(size: size),
                      // );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 15.0,
                      );
                    },
                    itemCount: 5,
                  );
                }
                if (state is GetAllAdminsFailedState) {
                  return Center(
                    child: Text(
                      'Failed to load admins!',
                      style: GoogleFonts.lora(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                if (state is GetAllAdminsCompletedState) {
                  if (state.admins != null) {
                    allAdmins = [];

                    if (state.admins.length == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SvgPicture.asset(
                            'assets/images/empty_prod.svg',
                            width: size.width * 0.6,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'No admins found!',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.lora(
                              color: Colors.black.withOpacity(0.7),
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
                    } else {
                      allAdmins = state.admins;

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                        itemBuilder: (context, index) {
                          return CommonAdminItem(
                            size: size,
                            admin: allAdmins[index],
                            allAdminsBloc: allAdminsBloc,
                            deactivateAdminBloc: deactivateAdminBloc,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 16.0,
                          );
                        },
                        itemCount: allAdmins.length,
                      );
                    }
                  }
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
