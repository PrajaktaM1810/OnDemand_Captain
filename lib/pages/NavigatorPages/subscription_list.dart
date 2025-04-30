import 'package:flutter/material.dart';
import 'package:flutter_driver/functions/functions.dart';
import 'package:flutter_driver/pages/NavigatorPages/manual_payment_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class SubscriptionListScreen extends StatefulWidget {
  SubscriptionListScreen();

  @override
  _SubscriptionListScreenState createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<Map<String, dynamic>> subscriptionList = [];
  bool isLoading = true;
  bool _isClicked = false;

  Future<void> fetchSubscriptionList() async {
    setState(() {
      isLoading = true;
    });

    var result = await getSubscriptionList(userDetails['id']);

    setState(() {
      isLoading = false;
      if (result['status'] == 'success') {
        subscriptionList = result['data'];
      } else {
        subscriptionList = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSubscriptionList();
  }

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 150, color: Colors.white),
                  SizedBox(height: 10),
                  Container(height: 15, width: 100, color: Colors.white),
                  SizedBox(height: 5),
                  Container(height: 15, width: 200, color: Colors.white),
                  SizedBox(height: 5),
                  Container(height: 15, width: 180, color: Colors.white),
                  SizedBox(height: 10),
                  Container(height: 40, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          "Subscription Plans",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? buildShimmer()
          : subscriptionList.isNotEmpty
          ? ListView.builder(
        itemCount: subscriptionList.length,
        itemBuilder: (context, index) {
          var plan = subscriptionList[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['package_name'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.directions_car, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text("Vehicle Type: ${plan['vehicle_type']}",
                              style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.directions, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text("Total Rides: ${plan['total_rides']}",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text("Daily Ride Limit: ${plan['daily_ride_limit']}",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text("Duration: ${plan['duration_days']} days",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTapUp: plan['subscribed']
                                  ? null
                                  : (_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManualPaymentScreen(
                                      packageId: plan['id'],
                                      packageAmount: plan['price'].toString(),
                                    ),
                                  ),
                                );
                                setState(() {
                                  _isClicked = false;
                                });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: plan['subscribed'] ? Colors.grey : Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Subscribe",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Text(
                    "₹ ${plan['price']}",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          );
        },
      )
          : Center(child: Text("No subscription plan available")),
    );
  }
}