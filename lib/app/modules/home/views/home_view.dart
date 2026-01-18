import 'package:chatapp/app/controllers/main_controller.dart';
import 'package:chatapp/app/widgets/user_list_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    var mainC = MainController.to;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chatty',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chats",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                    Icon(Icons.more_horiz)
                  ],
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.chatsStream(mainC.currentUser!.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var allChats = snapshot.data?.docs;
                    return Visibility(
                      visible: allChats != null,
                      replacement: Container(),
                      child: Column(
                        children: List.generate(
                          allChats?.length ?? 0,
                          (index) {
                            return StreamBuilder(
                              stream: controller.friendsStream(
                                  allChats?[index]["connection"]),
                              builder: (context, snapshot2) {
                                if (snapshot2.connectionState ==
                                    ConnectionState.active) {
                                  var data = snapshot2.data?.data();
                                  return Visibility(
                                    visible: data != null,
                                    child: InkWell(
                                      onTap: () {
                                        controller.updateReadChat(
                                          "${allChats?[index].id}",
                                          allChats?[index]["connection"],
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        child: UserListWidget(
                                          name: data?['name'] ?? '',
                                          imageUrl: data?["photoUrl"] ?? '',
                                          subText:
                                              "${allChats?[index]["last_message"]}",
                                          incomingChat:
                                              "${allChats?[index]["total_unread"]}",
                                          time:
                                              "${allChats?[index]["last_time"]}",
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                },
              ),
              SizedBox(height: 20)
            ],
          ),
        ));
  }
}
