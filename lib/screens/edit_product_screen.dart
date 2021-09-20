import 'package:flutter/material.dart';

import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _product = Product(id: '', title: '', description: '', price: 0.0, imageUrl: '');

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if (!_validateImageUrl(_imageController.text))
        return;
      setState(() {});
    }
  }
  
  bool _validateImageUrl(String imageUrl) {
    var isValid = true;
    if((!imageUrl.startsWith('http') && !imageUrl.startsWith('https')) ||
        (!imageUrl.endsWith('.png') && !imageUrl.endsWith('.jpg') && !imageUrl.endsWith('.jpeg')))
      isValid = false;
    return isValid;
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageController.dispose();
    _imageFocusNode.dispose();
    _imageFocusNode.removeListener(_updateImage);
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid)
      return;
    _form.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: <Widget>[
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (newValue) {
                  _product = Product(id: '', title: newValue!,
                      description: _product.description, price: _product.price,
                      imageUrl: _product.imageUrl);
                },
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Please provide a value';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descFocusNode);
                },
                onSaved: (newValue) {
                  _product = Product(id: '', title: _product.title,
                      description: _product.description, price: double.parse(newValue!),
                      imageUrl: _product.imageUrl);
                },
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Please enter a price';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  final price = double.parse(value);
                  if (price <= 0)
                    return 'Price must be a positive number';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descFocusNode,
                onSaved: (newValue) {
                  _product = Product(id: '', title: _product.title,
                      description: newValue!, price: _product.price,
                      imageUrl: _product.imageUrl);
                },
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Please provide a value';
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.only(top: 8.0, right: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey
                      )
                    ),
                    child: _imageController.text.isEmpty
                      ? Text('Enter an url')
                      : FittedBox(
                      child: Image.network(_imageController.text, fit: BoxFit.cover,),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image url'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageController,
                      focusNode: _imageFocusNode,
                      onEditingComplete: () {
                        if (!_validateImageUrl(_imageController.text))
                          return;
                        setState(() {});
                      },
                      onFieldSubmitted: (value) {
                        _saveForm();
                      },
                      onSaved: (newValue) {
                        _product = Product(id: '', title: _product.title,
                            description: _product.description, price: _product.price,
                            imageUrl: newValue!);
                      },
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Image cant be empty';
                        if (!value.startsWith('http') && !value.startsWith('https'))
                          return 'Enter a valid url';
                        if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg'))
                          return 'Enter a valid image url';
                        return null;
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
