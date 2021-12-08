import 'package:carousel_pro/carousel_pro.dart';
import 'package:ecommerce_store_admin/config/config.dart';
import 'package:ecommerce_store_admin/models/product.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/product_sku_dialog.dart';
import 'package:ecommerce_store_admin/widgets/product_detail.dart';
import 'package:ecommerce_store_admin/widgets/review_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'all_reviews_screen.dart';
import 'fullscreen_image_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  ProductDetailScreen({this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Widget> productImages = [];
  double rating;
  String discount;
  Sku _selectedSku;

  @override
  void initState() {
    _selectedSku = widget.product.skus[0];

    // discount = ((1 -
    //             (int.parse(_selectedSku.skuPrice) /
    //                 (int.parse(_selectedSku.skuMrp)))) *
    //         100)
    //     .round()
    //     .toString();

    rating = 0;

    if (widget.product.reviews.length == 0) {
    } else {
      if (widget.product.reviews.length > 0) {
        for (var review in widget.product.reviews) {
          rating = rating + double.parse(review.rating);
        }
        rating = rating / widget.product.reviews.length;
      }
    }

    if (widget.product.productImages.length == 0) {
      productImages.add(
        Center(
          child: Text(
            'No product image available',
            style: GoogleFonts.lora(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
      );
    } else {
      for (var item in widget.product.productImages) {
        productImages.add(
          Center(
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/icons/category_placeholder.png',
              image: item,
              fadeInDuration: Duration(milliseconds: 250),
              fadeInCurve: Curves.easeInOut,
              fadeOutDuration: Duration(milliseconds: 150),
              fadeOutCurve: Curves.easeInOut,
            ),
          ),
        );
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Column(children: <Widget>[
      Container(
        width: size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
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
                  'Product Details',
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
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              height: 240.0,
              width: size.width,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 180.0,
                      padding: const EdgeInsets.only(
                          bottom: 20.0, left: 16.0, right: 16.0, top: 10.0),
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    width: size.width,
                    child: Container(
                      height: 230.0,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15.0,
                            offset: Offset(1, 10.0),
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Carousel(
                          images: productImages,
                          dotSize: 4.0,
                          dotSpacing: 15.0,
                          dotColor: Colors.lightGreenAccent,
                          dotIncreasedColor: Colors.amber,
                          autoplayDuration: Duration(milliseconds: 3000),
                          autoplay: false,
                          showIndicator: true,
                          indicatorBgPadding: 5.0,
                          dotBgColor: Colors.transparent,
                          borderRadius: false,
                          animationDuration: Duration(milliseconds: 450),
                          animationCurve: Curves.easeInOut,
                          boxFit: BoxFit.contain,
                          dotVerticalPadding: 5.0,
                          dotPosition: DotPosition.bottomCenter,
                          noRadiusForIndicator: true,
                          onImageTap: (index) {
                            print('Tapped: $index');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageScreen(
                                  images: widget.product.productImages,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.product.name,
                      overflow: TextOverflow.clip,
                      style: GoogleFonts.lora(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.75),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.5),
                            onTap: () {
                              print('Wishlist');
                            },
                            child: Container(
                              width: 38.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.black.withOpacity(0.5),
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.5),
                            onTap: () {
                              print('Share');
                            },
                            child: Container(
                              width: 38.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                Icons.share,
                                color: Colors.black.withOpacity(0.5),
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.product.isDiscounted
                        ? '${Config().currency}${((1 - (widget.product.discount / 100)) * double.parse(_selectedSku.skuPrice)).toStringAsFixed(2)}'
                        : '${Config().currency}${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}',
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.lora(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.9),
                    ),
                  ),
                  widget.product.isDiscounted
                      ? Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${Config().currency}${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black54,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              '${widget.product.discount.toInt()}% off',
                              maxLines: 1,
                              style: GoogleFonts.lora(
                                fontSize: 14.0,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
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
                      selectedSku: _selectedSku,
                    );
                  },
                );

                if (res != null) {
                  setState(() {
                    _selectedSku = res;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.18),
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedSku.skuName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lora(
                          color: Colors.black.withOpacity(0.75),
                          fontSize: 14.0,
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
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _selectedSku.quantity > 0 ? 'Available' : 'Inavailable',
                    maxLines: 1,
                    style: GoogleFonts.lora(
                      fontSize: 15.0,
                      color: _selectedSku.quantity > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: 10.0,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     mainAxisSize: MainAxisSize.max,
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: <Widget>[
            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            //         decoration: BoxDecoration(
            //           color: Colors.green.shade300,
            //           borderRadius: BorderRadius.circular(7.0),
            //         ),
            //         child: Row(
            //           children: <Widget>[
            //             Text(
            //               'Unit:',
            //               maxLines: 1,
            //               style: GoogleFonts.lora(
            //                 fontSize: 14.0,
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.w500,
            //                 letterSpacing: 0.5,
            //               ),
            //             ),
            //             SizedBox(
            //               width: 10.0,
            //             ),
            //             // Text(
            //             //   widget.product.unitQuantity,
            //             //   maxLines: 1,
            //             //   style: GoogleFonts.lora(
            //             //     fontSize: 14.0,
            //             //     color: Colors.white,
            //             //     fontWeight: FontWeight.w500,
            //             //     letterSpacing: 0.5,
            //             //   ),
            //             // ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        'Fast Delivery',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lora(
                          fontSize: 13.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        'Easy cancellation',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lora(
                          fontSize: 13.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Description',
                    style: GoogleFonts.lora(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.product.description,
                    style: GoogleFonts.lora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Additional Information',
                    style: GoogleFonts.lora(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.product.additionalInfo.bestBefore.length == 0
                        ? '\u2022 Best before: NA'
                        : '\u2022 Best before: ${widget.product.additionalInfo.bestBefore}',
                    style: GoogleFonts.lora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.product.additionalInfo.manufactureDate.length == 0
                        ? '\u2022 Manufacture date: NA'
                        : '\u2022 Manufacture date: ${widget.product.additionalInfo.manufactureDate}',
                    style: GoogleFonts.lora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.product.additionalInfo.shelfLife.length == 0
                        ? '\u2022 Shelf life: NA'
                        : '\u2022 Shelf life: ${widget.product.additionalInfo.shelfLife}',
                    style: GoogleFonts.lora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.product.additionalInfo.brand.length == 0
                        ? '\u2022 Brand: NA'
                        : '\u2022 Brand: ${widget.product.additionalInfo.brand}',
                    style: GoogleFonts.lora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            // SizedBox(
            //   height: 5.0,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     mainAxisSize: MainAxisSize.min,
            //     children: <Widget>[
            //       Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: <Widget>[
            //           Expanded(
            //             child: Text(
            //               'Questions & Answers',
            //               style: GoogleFonts.lora(
            //                 fontSize: 16.0,
            //                 fontWeight: FontWeight.w600,
            //                 letterSpacing: 0.3,
            //               ),
            //             ),
            //           ),
            //           Container(
            //             height: 33.0,
            //             child: FlatButton(
            //               onPressed: () {
            //                 //post question
            //                 showPostQuestionPopup();
            //               },
            //               color: Theme.of(context).primaryColor,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius:
            //                     BorderRadius.circular(10.0),
            //               ),
            //               child: Text(
            //                 'Post Question',
            //                 style: GoogleFonts.lora(
            //                   color: Colors.white,
            //                   fontSize: 13.5,
            //                   fontWeight: FontWeight.w500,
            //                   letterSpacing: 0.3,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(
            //         height: 12.0,
            //       ),
            //       widget.product.queAndAns.length == 0
            //           ? Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Center(
            //                 child: Text(
            //                   'No questions found!',
            //                   textAlign: TextAlign.center,
            //                   overflow: TextOverflow.clip,
            //                   style: GoogleFonts.lora(
            //                     color:
            //                         Colors.black.withOpacity(0.7),
            //                     fontSize: 14.5,
            //                     fontWeight: FontWeight.w500,
            //                     letterSpacing: 0.3,
            //                   ),
            //                 ),
            //               ),
            //             )
            //           : Column(
            //               children: <Widget>[
            //                 ListView.separated(
            //                   shrinkWrap: true,
            //                   physics:
            //                       NeverScrollableScrollPhysics(),
            //                   padding: const EdgeInsets.only(
            //                       bottom: 10.0),
            //                   itemBuilder: (context, index) {
            //                     return QuestionAnswerItem(
            //                         widget.product.queAndAns[index]);
            //                   },
            //                   separatorBuilder: (context, index) {
            //                     return Divider();
            //                   },
            //                   itemCount:
            //                       widget.product.queAndAns.length > 3
            //                           ? 3
            //                           : widget.product.queAndAns.length,
            //                 ),
            //                 widget.product.queAndAns.length > 3
            //                     ? Column(
            //                         mainAxisSize: MainAxisSize.min,
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.start,
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.start,
            //                         children: <Widget>[
            //                           Divider(),
            //                           Container(
            //                             height: 36.0,
            //                             width: double.infinity,
            //                             child: FlatButton(
            //                               onPressed: () {
            //                                 //TODO: take to all questions screen
            //                                 Navigator.push(
            //                                   context,
            //                                   MaterialPageRoute(
            //                                     builder: (context) =>
            //                                         AllQuestionsScreen(
            //                                             widget.product
            //                                                 .queAndAns),
            //                                   ),
            //                                 );
            //                               },
            //                               color: Colors.transparent,
            //                               padding:
            //                                   const EdgeInsets.all(
            //                                       0),
            //                               shape:
            //                                   RoundedRectangleBorder(
            //                                 borderRadius:
            //                                     BorderRadius
            //                                         .circular(10.0),
            //                               ),
            //                               child: Container(
            //                                 alignment: Alignment
            //                                     .centerLeft,
            //                                 child: Text(
            //                                   'View All Questions',
            //                                   style: GoogleFonts
            //                                       .lora(
            //                                     color:
            //                                         Colors.black87,
            //                                     fontSize: 14.0,
            //                                     fontWeight:
            //                                         FontWeight.w500,
            //                                     letterSpacing: 0.3,
            //                                   ),
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                         ],
            //                       )
            //                     : SizedBox(),
            //               ],
            //             ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Divider(),
            // ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          // 'Reviews & Ratings',
                          'Ratings',
                          style: GoogleFonts.lora(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        height: 33.0,
                        child: FlatButton(
                          onPressed: () {},
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            'Rate Product',
                            style: GoogleFonts.lora(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              '${widget.product.reviews.length}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.lora(
                                color: Colors.green.shade700,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              'reviews',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.lora(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              widget.product.reviews.length == 0
                                  ? '0'
                                  : '${rating.toStringAsFixed(1)}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.lora(
                                color: Colors.green.shade700,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1.5),
                              child: Text(
                                '\u2605',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  widget.product.reviews.length == 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Center(
                            child: Text(
                              'No reviews found!',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.lora(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 10.0),
                              itemBuilder: (context, index) {
                                return ReviewItem(
                                  review: widget.product.reviews[index],
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount: widget.product.reviews.length > 3
                                  ? 3
                                  : widget.product.reviews.length,
                            ),
                            widget.product.reviews.length > 3
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Divider(),
                                      Container(
                                        height: 36.0,
                                        width: double.infinity,
                                        child: FlatButton(
                                          onPressed: () {
                                            //TODO: take to all reviews screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AllReviewsScreen(
                                                  widget.product.reviews,
                                                  rating,
                                                ),
                                              ),
                                            );
                                          },
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'View All Reviews',
                                              style: GoogleFonts.lora(
                                                color: Colors.black87,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ],
                        ),
                  // ProductDetailItem(
                  //   product: widget.product,
                  // ),
                  SizedBox(
                    height: 50.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    ]));
  }
}
