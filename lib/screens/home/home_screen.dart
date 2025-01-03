import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/model/homePageService/home_service.dart';
import 'package:sec_pro/screens/appoinment/appoinment_screen.dart';
import 'package:sec_pro/screens/profile/profile_screen.dart';
import 'package:sec_pro/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = '';
  String email = '';
  String phoneNumber = '';
  bool isLoading = true;
  List<HomeService> services=[];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadServices();
  }


  Future<void> _loadServices()async{
    try{
      final QuerySnapshot serviceSnapshot = await _firestore.collection('services').get();
      setState(() {
        services = serviceSnapshot.docs.map((doc){
          return HomeService.fromFirestore(doc.data() as Map<String,dynamic>);
        }).toList();
      });

    }catch(e){
      print("Error loading services:$e");

    }
  }
  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          email = currentUser.email ?? '';
        });

        final userData = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userData.exists) {
          final data = userData.data() ?? {};
          setState(() {
            userName = data['name'] ?? currentUser.email?.split('@')[0] ?? 'User';
            phoneNumber = data['phone']?.toString() ?? 'N/A';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userName = 'User';
        phoneNumber = 'N/A';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
  height: 200, // Set the desired height here
  child: DrawerHeader(
    decoration:const BoxDecoration(
      color: Color.fromARGB(255, 0, 10, 18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            child: ClipOval(
              child: Image.asset(
                "asset/scissor.jpeg",
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20), // Adjust spacing as needed
        Text(
          userName,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          email,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            letterSpacing: 0.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Phone: $phoneNumber',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            letterSpacing: 0.4,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ),
),



              ListTile(
                leading: const Icon(Icons.home),
                title: Text('Home',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.of(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: Text('Search',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen(),));
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text('Appoinment',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppoinmentScreen(),));
                },
              ),

               ListTile(
                leading: const Icon(Icons.person_2_outlined),
                title: Text('Profile',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(),));
                },
              ),

              ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text('Bookmarks',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.monetization_on),
                title: Text('Wallet',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.note_rounded),
                title: Text('Term & Condition',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.headset_mic),
                title: Text('Customer Care',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),


              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text('Logout',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],


          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, right: 15, left: 15),
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Hello, ",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: userName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                        color: const Color.fromRGBO(0, 76, 255, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                    ),
                  ],
                ),
              ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: services.isEmpty 
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true, // Makes the grid view take only the space it needs
                            physics: const NeverScrollableScrollPhysics(), // Disable grid view scroll
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8, // Adjust this value to control item height
                            ),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child:CircleAvatar(
                                        radius: 35,  
                                        child: ClipOval(
                                          child: Container(
                                            width: 70,  // Diameter should be 2x radius
                                            height: 70, // Diameter should be 2x radius
                                            child: Image.network(
                                              service.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.error),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    service.name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                  ),
                )


              
            ],
          ),
        ),
      ),
    );
  }
}
