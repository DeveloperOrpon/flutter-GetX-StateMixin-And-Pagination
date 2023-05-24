import 'dart:developer';

import 'package:c_com_ui/page/categoryShimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

import '../controller/product_controller.dart';

class HomePage extends GetView<ProductController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("My E-Commerce App")),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshUser();
        },
        child: Column(
          children: [
            Obx(() => controller.categoryList.isNotEmpty
                ? SizedBox(
                    width: Get.width,
                    height: 80,
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categoryList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              controller.categoryWayProduct(
                                  controller.categoryList[index]);
                            },
                            child: Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.selectCategory.value ==
                                            controller.categoryList[index]
                                        ? Colors.red
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(controller.categoryList[index]
                                        .toUpperCase()),
                                  ),
                                )),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 8);
                        },
                      ),
                    ),
                  )
                : const CategoryLoadingShimmer()),
            Expanded(
              child: controller.obx(
                (state) {
                  return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state!.length,
                      itemBuilder: (context, index) {
                        if (index == state.length - 1) {
                          //when all data load in ui
                          log("LoadData");
                          controller.getProduct();
                          log("index $index state ${state.length}");
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: state[index].image!,
                            height: 100,
                            width: 100,
                            placeholder: (context, url) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey,
                            )
                                .animate(
                                  delay: 0.ms,
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(duration: const Duration(seconds: 1)),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          title: Text(state[index].title!),
                          subtitle: Text("\$${state[index].price}"),
                        );
                      });
                },
                onLoading: SkeletonListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
