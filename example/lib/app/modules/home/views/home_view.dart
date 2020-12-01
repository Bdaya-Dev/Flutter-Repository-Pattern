import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bdaya_repository_pattern_example/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () async {
              await controller.clearData();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await controller.addTestData();
        },
      ),
      body: Obx(
        () {
          var list = controller.usersList.values.toList();
          return ListView.builder(
            itemBuilder: (context, index) {
              var item = list[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.dob.toString()),
              );
            },
            itemCount: list.length,
          );
        },
      ),
    );
  }
}
