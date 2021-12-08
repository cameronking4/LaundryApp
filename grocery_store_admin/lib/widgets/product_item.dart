import 'package:ecommerce_store_admin/blocs/products_bloc/active_products_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/all_products_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/featured_products_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/inactive_products_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/products_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/trending_products_bloc.dart';
import 'package:ecommerce_store_admin/config/config.dart';
import 'package:ecommerce_store_admin/models/product.dart';
import 'package:ecommerce_store_admin/screens/product_screens/edit_product_screen.dart';
import 'package:ecommerce_store_admin/screens/product_screens/product_detail_screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dialogs/product_sku_dialog.dart';

class ProductItem extends StatefulWidget {
  final Size size;
  final Product product;
  final String productType;
  final AllProductsBloc allProductsBloc;
  final ActiveProductsBloc activeProductsBloc;
  final InactiveProductsBloc inactiveProductsBloc;
  final TrendingProductsBloc trendingProductsBloc;
  final FeaturedProductsBloc featuredProductsBloc;

  const ProductItem({
    @required this.size,
    @required this.product,
    this.allProductsBloc,
    this.activeProductsBloc,
    this.featuredProductsBloc,
    this.inactiveProductsBloc,
    this.trendingProductsBloc,
    this.productType,
  });

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  Sku selectedSku;

  @override
  void initState() {
    super.initState();
    selectedSku = widget.product.skus[0];
  }

  sendToEditProduct() async {
    bool isEdited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: widget.product),
      ),
    );
    if (isEdited != null) {
      if (isEdited) {
        switch (widget.productType) {
          case 'ALL_PRODUCTS':
            widget.allProductsBloc.add(GetAllProductsEvent());
            break;
          case 'ACTIVE_PRODUCTS':
            widget.activeProductsBloc.add(GetActiveProductsEvent());
            break;
          case 'INACTIVE_PRODUCTS':
            widget.inactiveProductsBloc.add(GetInactiveProductsEvent());
            break;
          case 'TRENDING_PRODUCTS':
            widget.trendingProductsBloc.add(GetTrendingProductsEvent());
            break;
          case 'FEATURED_PRODUCTS':
            widget.featuredProductsBloc.add(GetFeaturedProductsEvent());
            break;
          default:
        }
      }
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.red.shade500,
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
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
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
    return Container(
      width: widget.size.width,
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
                width: widget.size.width * 0.32,
                height: widget.size.width * 0.32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.0),
                  child: Center(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/icons/category_placeholder.png',
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
                        fontSize: 15.5,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedSku.skuName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.75),
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
                                  decoration: TextDecoration.lineThrough,
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
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Text(
          //   'Quantity: ${widget.product.quantity}',
          //   style: GoogleFonts.lora(
          //     color: Colors.black.withOpacity(0.75),
          //     fontSize: 15.0,
          //     fontWeight: FontWeight.w500,
          //     letterSpacing: 0.3,
          //   ),
          // ),
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
                    // //TODO: temp disabled
                    // showSnack(
                    //     'You\'re not a Primary admin.\nAction not allowed!',
                    //     context);
                    sendToEditProduct();
                  },
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  splashColor: Colors.white.withOpacity(0.4),
                  child: Text(
                    'Edit Service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
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
                    'User View',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.0,
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
    );
  }
}
