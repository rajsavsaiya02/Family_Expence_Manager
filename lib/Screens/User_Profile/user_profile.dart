import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController controller = Get.put(UserController());
  String uploadedFileURL = "";
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('User Profile'),
          backgroundColor: primary,
          elevation: 5,
        ),
        body: Container(
          height: ScreenHeight(context),
          width: ScreenWidth(context),
          color: Colors.indigo.shade500,
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              getImage(),
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      controller.email,
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text('Balance : ₹ ${controller.currentBalance.value.toString()}',
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                  ])),
              Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 14.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: const StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.password_sharp,
                                          size: 36),
                                      const Text(
                                        '**************',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: controller.accessCode
                                                  .toString()));
                                          showTopTitleSnackBar(
                                              context,
                                              Icons.content_copy,
                                              "Security Code Copied");
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            fixedSize: const Size.square(50),
                                            backgroundColor: Colors.white,
                                            elevation: 3),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.content_copy,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Card(
                          elevation: 5,
                          shape: const StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.person, size: 48),
                                      Text(
                                        controller.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Card(
                          elevation: 5,
                          shape: const StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.phone, size: 40),
                                      Text(
                                        controller.phone.isNotEmpty
                                            ? controller.phone.toString() == " "
                                              ? "None"
                                              : controller.phone
                                            : "None",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Card(
                          elevation: 5,
                          shape: const StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.calendar_month_outlined,
                                          size: 38),
                                      Text(
                                        controller.dob.isNotEmpty
                                            ? controller.dob.toString() != " "
                                                ? DateFormat("MMMM dd, yyyy").format(DateTime.parse(controller.dob))
                                                : "None"
                                            : "None",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        )
        );
  }

  Widget getImage() {
    if (imageFile == null && (controller.photo_url.isEmpty || controller.photo_url == " ")) {
      return const Icon(Icons.account_circle, color: Colors.white, size: 180);
    } else if (controller.photo_url.isNotEmpty && imageFile == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: CachedNetworkImage(
          imageUrl: controller.photo_url,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            )),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) {
            print(error);
            return const Icon(Icons.error);
          }),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: imageFile != null ? Image.file(
          imageFile!,
          height: 180,
          width: 180,
          fit: BoxFit.fill,
        ) : Container(),
      );
    }
  }
}
