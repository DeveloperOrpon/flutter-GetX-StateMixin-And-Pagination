import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as Http;

import '../model/product_model.dart';

class ProductController extends GetxController
    with StateMixin<List<ProductModel>> {
  List<ProductModel> allProduct = <ProductModel>[];
  RxList<String> categoryList = RxList([]);
  RxnString selectCategory = RxnString();
  int loadLimitData = 14;
  @override
  void onInit() {
    getProduct();
    getCategory();
    log("End Init");
    super.onInit();
  }

  void refreshUser() {
    selectCategory.value = null;
    log('refresh');
    change([], status: RxStatus.loading());
    getProduct();
    getCategory();
  }

  categoryWayProduct(String categoryName) {
    selectCategory.value = categoryName;
    change([], status: RxStatus.loading());
    Future.delayed(
      const Duration(seconds: 1),
      () {
        List<ProductModel> filterProduct =
            allProduct.where((e) => e.category == categoryName).toList();
        change(filterProduct, status: RxStatus.success());
      },
    );
  }

  getCategory() async {
    var url = Uri.parse("https://fakestoreapi.com/products/categories");
    var response = await Http.get(url);
    if (response.statusCode == 200) {
      log("Get data");
      categoryList.value = json.decode(response.body).cast<String>().toList();
      //   if (categoryList.isEmpty) {
      //     change(null, status: RxStatus.empty());
      //   } else {
      //    change(CustomStateClass(categoryState: categoryList),
      //             status: RxStatus.success());
      //   }
      // } else {
      //   change(null,
      //       status:
      //           RxStatus.error('something went wrong: ${response.statusCode}'));
    }
  }

  getProduct() async {
    var url =
        Uri.parse("https://fakestoreapi.com/products?limit=$loadLimitData");
    log("Get data");
    var response = await Http.get(url);
    if (response.statusCode == 200) {
      List jsonResponseList =
          json.decode(response.body).cast<Map<String, dynamic>>().toList();
      allProduct =
          jsonResponseList.map((e) => ProductModel.fromJson(e)).toList();
      loadLimitData = loadLimitData * 2;
      change(allProduct, status: RxStatus.success());
    }
  }
}
