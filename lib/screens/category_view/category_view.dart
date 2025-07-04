import 'package:conexion/models/category_model/category_model.dart';
import 'package:conexion/widgets/top_titles/top_titles.dart';
import 'package:flutter/material.dart';
import '../../constants/routes.dart';
import '../../firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import '../../models/product_model/product_model.dart';
import '../../models/service_model/service_model.dart';
import '../product_detail/product_details.dart';

class CategoryView extends StatefulWidget {
  final CategoryModel categoryModel;

  const CategoryView({super.key, required this.categoryModel});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  List<ProductModel> productModelList = [];
  List<ServiceModel> serviceModelList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });

    productModelList = await FirebaseFirestoreHelper.instance.getCategoryViewProduct(widget.categoryModel.id);
    serviceModelList = await FirebaseFirestoreHelper.instance.getCategoryViewService(widget.categoryModel.id);

    productModelList.shuffle();
    serviceModelList.shuffle();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: Container(
          height: 100,
          width: 100,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight * 1),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  const BackButton(),
                  Text(
                    widget.categoryModel.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            productModelList.isEmpty && serviceModelList.isEmpty
                ? const Center(child: Text("Sin productos o servicios"))
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: productModelList.length + serviceModelList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 30,
                  childAspectRatio: 0.7,
                  crossAxisCount: 2,
                ),
                itemBuilder: (ctx, index) {
                  if (index < productModelList.length) {
                    ProductModel singleProduct = productModelList[index];
                    return buildItem(singleProduct.name, singleProduct.image, singleProduct.price, () {
                      Routes.instance.push(
                        widget: ProductDetails(singleProduct: singleProduct),
                        context: context,
                      );
                    });
                  } else {
                    ServiceModel singleService = serviceModelList[index - productModelList.length];
                    return buildItem(singleService.name, singleService.image, singleService.price, () {
                      // Acción al presionar servicio (podría ser una pantalla de detalles)
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildItem(String name, String image, double price, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Image.network(
            image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.broken_image, size: 100, color: Colors.grey);
            },
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("price: \\${price}"),
          const SizedBox(height: 30),
          SizedBox(
            height: 45,
            width: 120,
            child: OutlinedButton(
              onPressed: onTap,
              child: const Text("Ver"),
            ),
          ),
        ],
      ),
    );
  }
}
