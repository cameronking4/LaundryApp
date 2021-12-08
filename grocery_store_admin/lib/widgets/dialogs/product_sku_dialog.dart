import 'package:ecommerce_store_admin/config/config.dart';
import 'package:ecommerce_store_admin/models/product.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class ProductSkuDialog extends StatefulWidget {
  final Product product;
  final Sku selectedSku;

  ProductSkuDialog({@required this.product, this.selectedSku});

  @override
  _ReportProductDialogState createState() => _ReportProductDialogState();
}

class _ReportProductDialogState extends State<ProductSkuDialog> {
  final TextEditingController controller = TextEditingController();
  int selectedValue;
  String reportDescription;
  Sku _selectedSku;

  @override
  void initState() {
    super.initState();

    _selectedSku = widget.selectedSku;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      elevation: 5.0,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Text(
                'Choose hamper size',
                style: GoogleFonts.lora(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                widget.product.name,
                style: GoogleFonts.lora(
                  color: Colors.black87,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            Container(
              child: ListView.separated(
                itemCount: widget.product.skus.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSku = widget.product.skus[index];
                      });
                      Navigator.pop(context, _selectedSku);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.product.skus[index] == _selectedSku
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 7),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.product.isDiscounted
                                    ? '${widget.product.skus[index].skuName}'
                                    : '${widget.product.skus[index].skuName}',
                                style: GoogleFonts.lora(
                                  color:
                                      widget.product.skus[index] == _selectedSku
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(0.7),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              Text(
                                widget.product.isDiscounted
                                    ? '  -  ${Config().currency}${((1 - (widget.product.discount / 100)) * double.parse(widget.product.skus[index].skuPrice)).toStringAsFixed(2)}  '
                                    : '  -  ${Config().currency}${double.parse(widget.product.skus[index].skuPrice).toStringAsFixed(2)}  ',
                                style: GoogleFonts.lora(
                                  color:
                                      widget.product.skus[index] == _selectedSku
                                          ? Colors.white
                                          : Colors.black.withOpacity(0.75),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              widget.product.isDiscounted
                                  ? Text(
                                      '${Config().currency}${double.parse(widget.product.skus[index].skuPrice).toStringAsFixed(2)}',
                                      style: GoogleFonts.lora(
                                        color: widget.product.skus[index] ==
                                                _selectedSku
                                            ? Colors.white.withOpacity(0.75)
                                            : Colors.black.withOpacity(0.55),
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          widget.product.skus[index].quantity == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Out of Stock',
                                    style: GoogleFonts.lora(
                                      color: widget.product.skus[index] ==
                                              _selectedSku
                                          ? Colors.red.shade200
                                          : Colors.red.withOpacity(0.75),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
