import 'dart:io';
import 'package:ecommerce_store_admin/blocs/inventory_bloc/all_categories_bloc.dart';
import 'package:ecommerce_store_admin/blocs/inventory_bloc/inventory_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/edit_product_bloc.dart';
import 'package:ecommerce_store_admin/blocs/products_bloc/products_bloc.dart';
import 'package:ecommerce_store_admin/config/config.dart';
import 'package:ecommerce_store_admin/models/category.dart';
import 'package:ecommerce_store_admin/models/product.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/add_sku_dialog.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/deleted_dialog.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/edit_sku_dialog.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/processing_dialog.dart';
import 'package:ecommerce_store_admin/widgets/dialogs/product_added_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({@required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AllCategoriesBloc allCategoriesBloc;
  EditProductBloc editProductBloc;
  List<Category> categories;
  List categoryNames;
  List subcategoryNames;
  String _selectedCategory;
  String _selectedSubCategory;
  int index;
  var image;
  List productImages;
  List newProductImages;
  bool isEditing;
  bool isDeleting;
  Map<dynamic, dynamic> product = Map();
  bool isFirst;
    bool inStock, isListed, isFeatured, isDiscounted;
    double discountPer;
    List skusList;

    
  @override
  void initState() {
    super.initState();

    categories = [];
    subcategoryNames = [];
    productImages = [];
    newProductImages = [];
    isEditing = false;
    isDeleting = false;
    isFirst = true;
    inStock = false;
    isListed = false;
    isFeatured = false;
    isDiscounted = false;
    skusList = List();

    allCategoriesBloc = BlocProvider.of<AllCategoriesBloc>(context);
    editProductBloc = BlocProvider.of<EditProductBloc>(context);

    allCategoriesBloc.listen((state) {
      print('ALL CATEGORIES SCREEN :: $state');
    });

    editProductBloc.listen((state) {
      if (state is EditProductInProgressState) {
        //in progress
        showUpdatingDialog('Updating product..\nPlease wait!');
      }
      if (state is EditProductFailedState) {
        //failed
        if (isEditing) {
          Navigator.pop(context);
          showSnack('Failed to update the product!', context);
          isEditing = false;
        }
      }
      if (state is EditProductCompletedState) {
        //completed
        if (isEditing) {
          isEditing = false;
          Navigator.pop(context);
          showProductEditedDialog();
        }
      }
      if (state is DeleteProductInProgressState) {
        //in progress
        showUpdatingDialog('Deleting product..\nPlease wait!');
      }
      if (state is DeleteProductFailedState) {
        //failed
        if (isDeleting) {
          Navigator.pop(context);
          showSnack('Failed to delete the product!', context);
          isDeleting = false;
        }
      }
      if (state is DeleteProductCompletedState) {
        //completed
        if (isDeleting) {
          isDeleting = false;
          Navigator.pop(context);
          showDeletedProductDialog();
        }
      }
    });

    allCategoriesBloc.add(GetAllCategoriesEvent());

    product.putIfAbsent('category', () => widget.product.category);
    product.putIfAbsent('subCategory', () => widget.product.subCategory);
    product.putIfAbsent('category', () => widget.product.category);

    inStock = widget.product.inStock;
    isListed = widget.product.isListed;
    isFeatured = widget.product.featured;

    for (var item in widget.product.skus) {
      skusList.add({
        'skuPrice': item.skuPrice,
        'skuName': item.skuName,
        'quantity': item.quantity,
        'skuId': item.skuId,
      });
    }

    product.putIfAbsent('isDiscounted', () => widget.product.isDiscounted);
    product.putIfAbsent('discount', () => widget.product.discount);

    isDiscounted = widget.product.isDiscounted;

    discountPer = double.parse(widget.product.discount.toString());
  }

  updateProduct() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (skusList.isEmpty) {
        showSnack('Please add SKU\'s to proceed!', context);
        return;
      }

      print(skusList.length);
      print(skusList);

      if (_selectedCategory != null &&
          _selectedSubCategory != null &&
          (productImages.length > 0 || newProductImages.length > 0)) {
        product.putIfAbsent('productImages', () => productImages);
        product.putIfAbsent('newProductImages', () => newProductImages);
        product.putIfAbsent('id', () => widget.product.id);
        product.putIfAbsent('inStock', () => inStock);
        product.putIfAbsent('isListed', () => isListed);
        product.putIfAbsent('featured', () => isFeatured);

        product.update(
          'discount',
          (e) => discountPer ?? 0,
          ifAbsent: () => discountPer ?? 0,
        );
        product.update(
          'isDiscounted',
          (e) => isDiscounted,
          ifAbsent: () => isDiscounted,
        );

        product.update(
          'skus',
          (e) => skusList,
          ifAbsent: () => skusList,
        );

        editProductBloc.add(EditProductEvent(product));
        isEditing = true;
      } else {
        showSnack('Please fill all the details!', context);
      }
    }
  }

  showUpdatingDialog(String message) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: message,
        );
      },
    );
  }

  showProductEditedDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: 'Product updated successfully!',
        );
      },
    );

    if (res == 'ADDED') {
      //added
      Navigator.pop(context, true);
    }
  }

  Future showAddSKUDialog() async {
    Map skuMap = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddSKUDialog();
      },
    );

    if (skuMap != null) {
      //add to list
      setState(() {
        skusList.add(skuMap);
      });
    }

    print(skusList);
  }

  Future showEditSKUDialog(int index, Map sku) async {
    Map skuMap = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EditSKUDialog(skuMap: sku);
      },
    );

    if (skuMap != null) {
      //add to list
      setState(() {
        skusList.removeAt(index);
        skusList.insert(index, skuMap);
      });
    }

    print(skusList);
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

  Future cropImage(context) async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        maxHeight: 400,
        maxWidth: 400,
        compressQuality: 50,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        newProductImages.add(croppedFile);
      });
    } else {
      //not croppped

    }
  }

  showDeleteProductDialog() async {
    bool res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeleteConfirmDialog(
          message: 'Do you want to delete this product?',
        );
      },
    );

    if (res == true) {
      //delete
      editProductBloc.add(DeleteProductEvent(widget.product.id));
      isDeleting = true;
    }
  }

  showDeletedProductDialog() async {
    bool res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeletedDialog(
          message: 'Deleted the product!',
        );
      },
    );

    if (res == true) {
      //deleted
      Navigator.pop(context, true);
    }
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
                      'Edit Service',
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
              cubit: allCategoriesBloc,
              buildWhen: (previous, current) {
                if (current is GetAllCategoriesCompletedState ||
                    current is GetAllCategoriesInProgressState ||
                    current is GetAllCategoriesFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllCategoriesInProgressState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is GetAllCategoriesFailedState) {
                  return Center(
                    child: Text(
                      'Failed to load!',
                      style: GoogleFonts.lora(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (state is GetAllCategoriesCompletedState) {
                  categories = state.categories;

                  if (isFirst) {
                    _selectedCategory = widget.product.category;
                    _selectedSubCategory = widget.product.subCategory;

                    for (var i = 0; i < categories.length; i++) {
                      if (categories[i].categoryName == _selectedCategory) {
                        index = i;
                        break;
                      }
                    }

                    productImages = widget.product.productImages;

                    isFirst = false;
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return 'Product name is required';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                product.update(
                                  'name',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              initialValue: widget.product.name,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Product name',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15.0),
                                  labelText: 'Select a category',
                                  labelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14.5,
                                    fontFamily: 'lora',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                // isEmpty: _selectedCategory == null,
                                child: DropdownButton<String>(
                                    underline: SizedBox(
                                      height: 0,
                                    ),
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    isDense: true,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.5,
                                      fontFamily: 'lora',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: categories
                                        .map((e) => DropdownMenuItem(
                                              child: Text(e.categoryName),
                                              value: e.categoryName,
                                            ))
                                        .toList(),
                                    onChanged: (String category) {
                                      setState(() {
                                        _selectedCategory = category;

                                        product.update(
                                          'category',
                                          (oldVal) => _selectedCategory,
                                          ifAbsent: () => _selectedCategory,
                                        );

                                        _selectedSubCategory = null;

                                        for (var i = 0;
                                            i < categories.length;
                                            i++) {
                                          if (categories[i].categoryName ==
                                              _selectedCategory) {
                                            index = i;
                                            break;
                                          }
                                        }
                                      });
                                    }),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _selectedCategory != null
                                ? Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 5.0, bottom: 5.0),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Select a sub-category',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14.5,
                                              fontFamily: 'lora',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                          ),
                                          isEmpty: _selectedSubCategory == null,
                                          child: DropdownButton<String>(
                                              underline: SizedBox(
                                                height: 0,
                                              ),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.5,
                                                fontFamily: 'lora',
                                                fontWeight: FontWeight.w500,
                                              ),
                                              value: _selectedSubCategory,
                                              isExpanded: true,
                                              isDense: true,
                                              items: categories[index]
                                                  .subCategories
                                                  .map((e) => DropdownMenuItem(
                                                        child: Text(
                                                            e.subCategoryName),
                                                        value:
                                                            e.subCategoryName,
                                                      ))
                                                  .toList(),
                                              onChanged: (String newVal) {
                                                setState(() {
                                                  _selectedSubCategory = newVal;
                                                });

                                                product.update(
                                                  'subCategory',
                                                  (oldVal) =>
                                                      _selectedSubCategory,
                                                  ifAbsent: () =>
                                                      _selectedSubCategory,
                                                );
                                              }),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'SKU\'s',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                            Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          //add sub category
                                          showAddSKUDialog();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
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
                              height: 5.0,
                            ),
                            Divider(),
                            SizedBox(
                              height: 5.0,
                            ),
                            skusList.length == 0
                                ? Center(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          'No SKU\'s added',
                                          style: GoogleFonts.lora(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                6.0,
                                              ),
                                              child: Material(
                                                color: Colors.green,
                                                child: InkWell(
                                                  splashColor: Colors.white
                                                      .withOpacity(0.4),
                                                  onTap: () {
                                                    //edit sku
                                                    showEditSKUDialog(
                                                      index,
                                                      skusList[index],
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                6.0,
                                              ),
                                              child: Material(
                                                color: Colors.red,
                                                child: InkWell(
                                                  splashColor: Colors.white
                                                      .withOpacity(0.4),
                                                  onTap: () {
                                                    //remove image
                                                    setState(() {
                                                      skusList.removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Colors.white,
                                                      size: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.all(0.0),
                                        title: Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ${skusList[index]['skuName']}',
                                              style: GoogleFonts.lora(
                                                color: Colors.black87,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            skusList[index]['quantity'] <
                                                    Config().lowInventoryNo
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.red,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 1),
                                                    child: Text(
                                                      'Low Qty',
                                                      style:
                                                          GoogleFonts.lora(
                                                        color: Colors.white,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '   Price: ${Config().currency}${skusList[index]['skuPrice']}',
                                              style: GoogleFonts.lora(
                                                color: Colors.black87,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '   Quantity: ${skusList[index]['quantity']}',
                                              style: GoogleFonts.lora(
                                                color: Colors.black87,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 5.0,
                                      );
                                    },
                                    itemCount: skusList.length),
                            // TextFormField(
                            //   textAlignVertical: TextAlignVertical.center,
                            //   validator: (String val) {
                            //     if (val.trim().isEmpty) {
                            //       return 'Unit quantity is required';
                            //     }
                            //     return null;
                            //   },
                            //   onSaved: (val) {
                            //     product.update(
                            //       'unitQuantity',
                            //       (oldVal) => val.trim(),
                            //       ifAbsent: () => val.trim(),
                            //     );
                            //   },
                            //   initialValue: widget.product.unitQuantity,
                            //   enableInteractiveSelection: false,
                            //   style: GoogleFonts.lora(
                            //     color: Colors.black,
                            //     fontSize: 14.5,
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.5,
                            //   ),
                            //   textInputAction: TextInputAction.done,
                            //   keyboardType: TextInputType.text,
                            //   textCapitalization: TextCapitalization.words,
                            //   decoration: InputDecoration(
                            //     contentPadding:
                            //         EdgeInsets.symmetric(horizontal: 15.0),
                            //     helperStyle: GoogleFonts.lora(
                            //       color: Colors.black.withOpacity(0.65),
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     errorStyle: GoogleFonts.lora(
                            //       fontSize: 13.0,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     hintStyle: GoogleFonts.lora(
                            //       color: Colors.black54,
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     labelText: 'Unit quantity (eg. 1kg, 500gm)',
                            //     labelStyle: GoogleFonts.lora(
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12.0),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15.0,
                            // ),
                            // TextFormField(
                            //   textAlignVertical: TextAlignVertical.center,
                            //   validator: (String val) {
                            //     if (val.trim().isEmpty) {
                            //       return 'Price is required';
                            //     }
                            //     return null;
                            //   },
                            //   onSaved: (val) {
                            //     product.update(
                            //       'price',
                            //       (oldVal) => val.trim(),
                            //       ifAbsent: () => val.trim(),
                            //     );
                            //   },
                            //   initialValue: widget.product.price,
                            //   enableInteractiveSelection: false,
                            //   style: GoogleFonts.lora(
                            //     color: Colors.black,
                            //     fontSize: 14.5,
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.5,
                            //   ),
                            //   textInputAction: TextInputAction.done,
                            //   keyboardType: TextInputType.number,
                            //   decoration: InputDecoration(
                            //     contentPadding:
                            //         EdgeInsets.symmetric(horizontal: 15.0),
                            //     helperStyle: GoogleFonts.lora(
                            //       color: Colors.black.withOpacity(0.65),
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     errorStyle: GoogleFonts.lora(
                            //       fontSize: 13.0,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     hintStyle: GoogleFonts.lora(
                            //       color: Colors.black54,
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     labelText: 'Price',
                            //     labelStyle: GoogleFonts.lora(
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12.0),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15.0,
                            // ),
                            // TextFormField(
                            //   textAlignVertical: TextAlignVertical.center,
                            //   validator: (String val) {
                            //     if (val.trim().isEmpty) {
                            //       return 'MRP is required';
                            //     }
                            //     return null;
                            //   },
                            //   onSaved: (val) {
                            //     product.update(
                            //       'ogPrice',
                            //       (oldVal) => val.trim(),
                            //       ifAbsent: () => val.trim(),
                            //     );
                            //   },
                            //   initialValue: widget.product.ogPrice,
                            //   enableInteractiveSelection: false,
                            //   style: GoogleFonts.lora(
                            //     color: Colors.black,
                            //     fontSize: 14.5,
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.5,
                            //   ),
                            //   textInputAction: TextInputAction.done,
                            //   keyboardType: TextInputType.number,
                            //   decoration: InputDecoration(
                            //     contentPadding:
                            //         EdgeInsets.symmetric(horizontal: 15.0),
                            //     helperStyle: GoogleFonts.lora(
                            //       color: Colors.black.withOpacity(0.65),
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     errorStyle: GoogleFonts.lora(
                            //       fontSize: 13.0,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     hintStyle: GoogleFonts.lora(
                            //       color: Colors.black54,
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     labelText: 'MRP',
                            //     labelStyle: GoogleFonts.lora(
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12.0),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15.0,
                            // ),
                            // TextFormField(
                            //   textAlignVertical: TextAlignVertical.center,
                            //   validator: (String val) {
                            //     if (val.trim().isEmpty) {
                            //       return 'Quantity is required';
                            //     }
                            //     return null;
                            //   },
                            //   onSaved: (val) {
                            //     product.update(
                            //       'quantity',
                            //       (oldVal) => int.parse(val.trim().toString()),
                            //       ifAbsent: () =>
                            //           int.parse(val.trim().toString()),
                            //     );
                            //   },
                            //   initialValue: widget.product.quantity.toString(),
                            //   enableInteractiveSelection: false,
                            //   style: GoogleFonts.lora(
                            //     color: Colors.black,
                            //     fontSize: 14.5,
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.5,
                            //   ),
                            //   textInputAction: TextInputAction.done,
                            //   keyboardType: TextInputType.number,
                            //   decoration: InputDecoration(
                            //     contentPadding:
                            //         EdgeInsets.symmetric(horizontal: 15.0),
                            //     helperStyle: GoogleFonts.lora(
                            //       color: Colors.black.withOpacity(0.65),
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     errorStyle: GoogleFonts.lora(
                            //       fontSize: 13.0,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     hintStyle: GoogleFonts.lora(
                            //       color: Colors.black54,
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     labelText: 'Quantity',
                            //     labelStyle: GoogleFonts.lora(
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12.0),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return 'Description is required';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                product.update(
                                  'description',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              initialValue: widget.product.description,
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.start,
                              textInputAction: TextInputAction.newline,
                              minLines: 3,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Description',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Product Images',
                                style: GoogleFonts.lora(
                                  color: Colors.black87,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            productImages.length > 0
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(0.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                          mainAxisSpacing: 15.0,
                                          crossAxisSpacing: 15.0,
                                        ),
                                        shrinkWrap: true,
                                        itemCount: productImages.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Center(
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        'assets/icons/category_placeholder.png',
                                                    image: widget.product
                                                        .productImages[index],
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: 150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5.0,
                                                right: 5.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    6.0,
                                                  ),
                                                  child: Material(
                                                    color: Colors.red,
                                                    child: InkWell(
                                                      splashColor: Colors.white
                                                          .withOpacity(0.4),
                                                      onTap: () {
                                                        //remove image
                                                        setState(() {
                                                          productImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 28.0,
                                                        height: 28.0,
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            newProductImages.length > 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Newly Added Images',
                                          style: GoogleFonts.lora(
                                            color: Colors.black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(0.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                          mainAxisSpacing: 15.0,
                                          crossAxisSpacing: 15.0,
                                        ),
                                        shrinkWrap: true,
                                        itemCount: newProductImages.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Center(
                                                  child: Image.file(
                                                      newProductImages[index]),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5.0,
                                                right: 5.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    6.0,
                                                  ),
                                                  child: Material(
                                                    color: Colors.red,
                                                    child: InkWell(
                                                      splashColor: Colors.white
                                                          .withOpacity(0.4),
                                                      onTap: () {
                                                        //remove image
                                                        setState(() {
                                                          newProductImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 28.0,
                                                        height: 28.0,
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              height: 45.0,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: FlatButton(
                                onPressed: () {
                                  //add product
                                  cropImage(context);
                                },
                                color: Colors.green.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Add Image',
                                      style: GoogleFonts.lora(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Do you want to discount this product?',
                                style: GoogleFonts.lora(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Is Discounted?',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: isDiscounted,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      isDiscounted = val;
                                      product.update(
                                        'isDiscounted',
                                        (_) => val,
                                        ifAbsent: () => val,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            isDiscounted
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      TextFormField(
                                        validator: (String val) {
                                          if (val.trim().isEmpty) {
                                            return 'Discount is required';
                                          }
                                          if (double.parse(
                                                  val.trim().toString()) ==
                                              0) {
                                            return 'Discount should be greater than 0';
                                          }
                                          return null;
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        onSaved: (val) {
                                          discountPer =
                                              double.parse(val.trim());
                                        },
                                        initialValue:
                                            widget.product.discount.toString(),
                                        style: GoogleFonts.lora(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          helperStyle: GoogleFonts.lora(
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          errorStyle: GoogleFonts.lora(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          hintStyle: GoogleFonts.lora(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          labelText: 'Discount %',
                                          labelStyle: GoogleFonts.lora(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Additional Information (Optional)',
                                style: GoogleFonts.lora(
                                  color: Colors.black87,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                product.update(
                                  'bestBefore',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              initialValue:
                                  widget.product.additionalInfo.bestBefore,
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Max Weight',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                product.update(
                                  'brand',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              initialValue: widget.product.additionalInfo.brand,
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Pick-Up window',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                product.update(
                                  'manufactureDate',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              initialValue:
                                  widget.product.additionalInfo.manufactureDate,
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Delivery ETA',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                product.update(
                                  'shelfLife',
                                  (oldVal) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              initialValue:
                                  widget.product.additionalInfo.shelfLife,
                              enableInteractiveSelection: false,
                              style: GoogleFonts.lora(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.lora(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.lora(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.lora(
                                  color: Colors.black54,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Addtnl Info',
                                labelStyle: GoogleFonts.lora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Available',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: inStock,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      inStock = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Active product',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: isListed,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      isListed = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Featured product',
                                    style: GoogleFonts.lora(
                                      color: Colors.black87,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: isFeatured,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      isFeatured = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              height: 45.0,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: FlatButton(
                                onPressed: () {
                                  //update product
                                  updateProduct();
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.update,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Update Product',
                                      style: GoogleFonts.lora(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              height: 45.0,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: FlatButton(
                                onPressed: () {
                                  //delete
                                  showDeleteProductDialog();
                                },
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Delete Product',
                                      style: GoogleFonts.lora(
                                        color: Colors.red,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                          ],
                        ),
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
