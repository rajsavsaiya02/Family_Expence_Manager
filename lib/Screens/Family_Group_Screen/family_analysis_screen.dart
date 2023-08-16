import 'package:flutter/material.dart';
import 'one_to_one_user_chat_screen.dart';

class FamilyGroupManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Family Chat Group",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.analytics,
              color: Colors.black,
            ),
            onPressed: () {
              // TODO: Implement analytics button action
            },
          ),

          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              // TODO: Implement settings button action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Family Members",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: 10, // replace with actual count of family members
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>{
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen()))
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                  "assets/profile.png"), // replace with actual image
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Family Member ${index + 1}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Group Chat",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  // onTap: (){
                  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupChatScreen()));
                  // },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analytics",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Messages",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "2,500",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Active Users",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "10",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pending Invitations",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "5",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement floating action button action
        },
        child: Icon(Icons.add),
      ),
    );
  }
}