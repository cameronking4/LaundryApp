import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_store_admin/blocs/messages_bloc/all_messages_bloc.dart';
import 'package:ecommerce_store_admin/blocs/messages_bloc/messages_bloc.dart';
import 'package:ecommerce_store_admin/config/config.dart';
import 'package:ecommerce_store_admin/models/product.dart';
import 'package:ecommerce_store_admin/screens/product_screens/product_detail_screen.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/product_sku_dialog.dart';
import 'package:ecommerce_store_admin/widgets/message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ViewMessagesScreen extends StatefulWidget {
  final Product product;
  final MessagesBloc messagesBloc;

  const ViewMessagesScreen({this.product, this.messagesBloc});

  @override
  _ViewMessagesScreenState createState() => _ViewMessagesScreenState();
}

class _ViewMessagesScreenState extends State<ViewMessagesScreen> {
  bool isPosted;
  Sku selectedSku;

  @override
  void initState() {
    super.initState();

    selectedSku = widget.product.skus[0];
    isPosted = false;

    widget.messagesBloc.listen((state) {
      print('MESSAGES STATE :: $state');
    });
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
                            if (isPosted) {
                              Navigator.pop(context, true);
                            } else {
                              Navigator.pop(context);
                            }
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
                      'Messages',
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
            child: ListView(
              padding: const EdgeInsets.all(0.0),
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: size.width,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: size.width * 0.32,
                            height: size.width * 0.32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11.0),
                              child: Center(
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/icons/category_placeholder.png',
                                  image: widget.product.productImages[0],
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration(milliseconds: 250),
                                  fadeInCurve: Curves.easeInOut,
                                  fadeOutDuration: Duration(milliseconds: 150),
                                  fadeOutCurve: Curves.easeInOut,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '${widget.product.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lora(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    //show sku dialog
                                    var res = await showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return ProductSkuDialog(
                                          product: widget.product,
                                          selectedSku: selectedSku,
                                        );
                                      },
                                    );

                                    if (res != null) {
                                      setState(() {
                                        selectedSku = res;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      // color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${selectedSku.skuName}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lora(
                                              color: Colors.black
                                                  .withOpacity(0.75),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: Colors.black.withOpacity(0.75),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 7.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      widget.product.isDiscounted
                                          ? '${Config().currency}${((1 - (widget.product.discount / 100)) * double.parse(selectedSku.skuPrice)).toStringAsFixed(2)}'
                                          : '${Config().currency}${double.parse(selectedSku.skuPrice).toStringAsFixed(2)}',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lora(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withOpacity(0.9),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    widget.product.isDiscounted
                                        ? Text(
                                            '${Config().currency}${double.parse(selectedSku.skuPrice).toStringAsFixed(2)}',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lora(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.black54,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : SizedBox(),
                                    // SizedBox(
                                    //   width: 10.0,
                                    // ),
                                    // Text(
                                    //   '${Config().currency}${selectedSku.skuMrp}',
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: GoogleFonts.lora(
                                    //     decoration: TextDecoration.lineThrough,
                                    //     color: Colors.black54,
                                    //     fontSize: 14.0,
                                    //     fontWeight: FontWeight.w500,
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   width: 15.0,
                                    // ),
                                    // Text(
                                    //   '$discount% off',
                                    //   maxLines: 1,
                                    //   style: GoogleFonts.lora(
                                    //     fontSize: 14.0,
                                    //     color: Colors.green.shade700,
                                    //     fontWeight: FontWeight.w500,
                                    //     letterSpacing: 0.5,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Category: ${widget.product.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lora(
                          color: Colors.black.withOpacity(0.75),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        'Quantity: ${selectedSku.quantity}',
                        style: GoogleFonts.lora(
                          color: Colors.black.withOpacity(0.75),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: widget.product,
                                    ),
                                  ),
                                );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(
                                    width: 1.0,
                                    color: Colors.black.withOpacity(0.4),
                                    style: BorderStyle.solid),
                              ),
                              child: Text(
                                'Product Details',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'MESSAGES',
                    style: GoogleFonts.lora(
                      color: Colors.black87,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MessageItem(
                      questionAnswer: widget.product.queAndAns[index],
                      size: size,
                      messagesBloc: widget.messagesBloc,
                      productId: widget.product.id,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 16.0,
                    );
                  },
                  itemCount: widget.product.queAndAns.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
