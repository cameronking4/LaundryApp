import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/product_sku_dialog.dart';
import 'package:shimmer/shimmer.dart';

class ProductListItem extends StatefulWidget {
  final Product product;
  final CartBloc cartBloc;
  final User currentUser;
  ProductListItem({
    @required this.product,
    this.cartBloc,
    @required this.currentUser,
  });

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  Sku selectedSku;
  double rating;

  @override
  void initState() {
    super.initState();

    print(widget.product.skus[0].skuName);
    print(widget.product.skus[0].skuPrice);

    selectedSku = widget.product.skus[0];

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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Open Product');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              productId: widget.product.id,
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 1 / 1.7,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Center(
                          child: FadeInImage.assetNetwork(
                            placeholder:
                                'assets/icons/category_placeholder.png',
                            image: widget.product.productImages[0],
                            fadeInDuration: Duration(milliseconds: 250),
                            fadeInCurve: Curves.easeInOut,
                            fit: BoxFit.cover,
                            fadeOutDuration: Duration(milliseconds: 150),
                            fadeOutCurve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    ),
                    widget.product.trending
                        ? Container(
                            height: 25.0,
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.amberAccent,
                              period: Duration(milliseconds: 3000),
                              child: Text(
                                'Trending',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  // vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.product.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 7.0,
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
                                  fontSize: 13.0,
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
                      height: 6.0,
                    ),
                    selectedSku.quantity > 0
                        ? Row(
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
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              widget.product.isDiscounted
                                  ? Text(
                                      '${Config().currency}${selectedSku.skuPrice}',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lora(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.black54,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Out of Stock',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lora(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Flexible(
                    //   child: Container(
                    //     height: 32.0,
                    //     padding: EdgeInsets.symmetric(
                    //         horizontal: 12.0, vertical: 5.0),
                    //     decoration: BoxDecoration(
                    //       color: Colors.green.shade300,
                    //       borderRadius: BorderRadius.circular(7.0),
                    //     ),
                    //     child: Row(
                    //       children: <Widget>[
                    //         Text(
                    //           'Unit:',
                    //           maxLines: 1,
                    //           style: GoogleFonts.lora(
                    //             fontSize: 12.0,
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.w500,
                    //             letterSpacing: 0.5,
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: 5.0,
                    //         ),
                    //         Flexible(
                    //           child: Text(
                    //             '${widget.product.unitQuantity}',
                    //             maxLines: 1,
                    //             overflow: TextOverflow.ellipsis,
                    //             style: GoogleFonts.lora(
                    //               fontSize: 12.0,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w500,
                    //               letterSpacing: 0.5,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          widget.product.reviews.length == 0
                              ? '4.98 \u2605'
                              : '${rating.toStringAsFixed(1)} \u2605',
                          maxLines: 1,
                          style: GoogleFonts.lora(
                            fontSize: 10.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Material(
                        child: InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            print('Add to cart');
                            if (FirebaseAuth.instance.currentUser == null) {
                              Navigator.pushNamed(context, '/sign_in');
                              return;
                            }

                            if (selectedSku.quantity > 0) {
                              widget.cartBloc.add(
                                AddToCartEvent(
                                  {
                                    'productId': widget.product.id,
                                    'sku': selectedSku,
                                    'skuId': selectedSku.skuId,
                                    'quantity': selectedSku.quantity,
                                  },
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 38.0,
                            height: 35.0,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.01),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                width: 0.8,
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.black.withOpacity(0.7),
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
