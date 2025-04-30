import 'package:flutter/material.dart';
import 'package:flutter_driver/functions/functions.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestList extends StatefulWidget {
  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> acceptedRequests = [];
  List<Map<String, dynamic>> confirmedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];
  List<Map<String, dynamic>> betUpdateRequests = [];
  List<Map<String, dynamic>> completedTrips = [];

  bool isLoading = true;
  String? selectedStatus;
  TextEditingController _fareController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = 'pending';
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final getHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${bearerToken[0].token}',
      };
      print('GET Request Headers: $getHeaders');

      final pendingResponse = await http.get(
        Uri.parse('https://admin.nxtdig.in/api/v1/request/getAvailableRequestsForDriver'),
        headers: getHeaders,
      );
      print('GET Response Body: ${pendingResponse.body}');

      final postHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${bearerToken[0].token}',
      };
      final postBody = {'driver_id': userDetails['id'].toString()};
      print('POST Request Headers: $postHeaders');
      print('POST Request Body: $postBody');

      final userRequestsResponse = await http.post(
        Uri.parse('https://admin.nxtdig.in/api/v1/request/getUserDriverRequests'),
        headers: postHeaders,
        body: json.encode(postBody),
      );
      print('POST Response Body: ${userRequestsResponse.body}');

      if (pendingResponse.statusCode == 200 && userRequestsResponse.statusCode == 200) {
        final pendingData = (json.decode(pendingResponse.body)['data'] as List).cast<Map<String, dynamic>>();
        final userRequestsData = (json.decode(userRequestsResponse.body)['data'] as List).cast<Map<String, dynamic>>();

        for (var request in pendingData) {
          if (request['user'] != null) {
            request['user_name'] = request['user']['name'];
            request['user_contact'] = request['user']['mobile'];
          }
        }

        for (var request in userRequestsData) {
          if (request['user'] != null) {
            request['user_name'] = request['user']['name'];
            request['user_contact'] = request['user']['mobile'];
          }
        }

        setState(() {
          pendingRequests = pendingData;
          acceptedRequests = userRequestsData.where((req) => req['status'] == 'accepted').toList();
          confirmedRequests = userRequestsData.where((req) => req['status'] == 'confirmed').toList();
          rejectedRequests = userRequestsData.where((req) => req['status'] == 'rejected' && req['reject_count'] == 3).toList();
          betUpdateRequests = userRequestsData.where((req) => req['status'] == 'rejected' && (req['reject_count'] == null || req['reject_count'] < 3)).toList();
          completedTrips = userRequestsData.where((req) => req['status'] == 'completed').toList();

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error in _fetchRequests: $e');
    }
  }

  Future<void> _acceptRide(Map<String, dynamic> request, String fare) async {
    bool isProcessing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('=== REQUEST DETAILS ===');
      print('URL: https://admin.nxtdig.in/api/v1/request/updateDriverRequestStatus');
      print('Headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${bearerToken[0].token}',
      }}');
      print('Request Body: ${{
        'driver_id': userDetails['id'].toString(),
        'request_id': request['id'].toString(),
        'status': 'accepted',
        'expected_fare': fare,
      }}');
      final response = await http.post(
        Uri.parse('https://admin.nxtdig.in/api/v1/request/updateDriverRequestStatus'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${bearerToken[0].token}',
        },
        body: json.encode({
          'driver_id': userDetails['id'].toString(),
          'request_id': request['id'].toString(),
          'status': 'accepted',
          'expected_fare': fare,
        }),
      );

      print('=== RESPONSE DETAILS ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      Navigator.pop(context);

      if (response.statusCode == 200) {
        print('Request accepted successfully');
        _fetchRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ride accepted successfully")),
        );
      } else {
        print('Failed to accept ride. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept ride")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error accepting ride: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting ride")),
      );
    }
  }

  void _showFareInputDialog(Map<String, dynamic> request) {
    _fareController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Expected Fare"),
          content: TextField(
            controller: _fareController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter fare amount",
              border: OutlineInputBorder(),
              counterText: "",
            ),
            maxLength: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_fareController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _acceptRide(request, _fareController.text);
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Rent Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusButton('Pending', 'pending'),
                    _buildStatusButton('Accepted', 'accepted'),
                    _buildStatusButton('Confirmed', 'confirmed'),
                    _buildStatusButton('Fare Update', 'bet_update'),
                    _buildStatusButton('Rejected', 'rejected'),
                    _buildStatusButton('Completed', 'completed'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildContentForStatus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status) {
    final isSelected = selectedStatus == status;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF0D47A1)),
          color: isSelected ? null : Colors.white,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Color(0xFF0D47A1),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          onPressed: () {
            setState(() {
              selectedStatus = status;
            });
          },
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildContentForStatus() {
    switch (selectedStatus) {
      case 'pending':
        return _buildRequestListContent(pendingRequests, "pending");
      case 'accepted':
        return _buildRequestListContent(acceptedRequests, "accepted");
      case 'confirmed':
        return _buildRequestListContent(confirmedRequests, "confirmed");
      case 'bet_update':
        return _buildRequestListContent(betUpdateRequests, "fare update");
      case 'rejected':
        return _buildRequestListContent(rejectedRequests, "rejected");
      case 'completed':
        return _buildRequestListContent(completedTrips, "completed");
      default:
        return _buildRequestListContent(pendingRequests, "pending");
    }
  }

  Widget _buildRequestListContent(List<Map<String, dynamic>> requests, String status) {
    return isLoading ? _buildShimmerLoader() :
    requests.isEmpty ? _buildEmptyMessage("No ${status} request") :
    _buildRequestList(requests, status: status);
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> list, {required String status}) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(list[index], status: status);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data, {required String status}) {
    Color statusColor = Colors.grey;
    if (status == "pending") statusColor = Colors.orange;
    else if (status == "accepted") statusColor = Colors.blue;
    else if (status == "confirmed") statusColor = Colors.green;
    else if (status == "rejected" || status == "bet_update") statusColor = Colors.red;
    else if (status == "completed") statusColor = Colors.green;

    final endDate = DateTime.parse(data['end_date']);
    final today = DateTime.now();
    final isDateValid = endDate.isAfter(today) ||
        (endDate.year == today.year &&
            endDate.month == today.month &&
            endDate.day == today.day);
    final showStatusButton = isDateValid && (status == "accepted" || status == "confirmed");

    String formatDate(String date) {
      final parsedDate = DateTime.parse(date);
      return "${parsedDate.day} ${_monthName(parsedDate.month)} ${parsedDate.year}";
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      elevation: 0.4,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Icon(Icons.directions_car, size: 18),
                SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${data['vehicle_type']}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    if (data['vehicle_number'] != null && data['vehicle_number'].toString().isNotEmpty)
                      Text("${data['vehicle_number']}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ]),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status == "bet_update" ? "REJECTED" : status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            SizedBox(height: 8),
            if (data['from_location'] != null && data['from_location'].toString().isNotEmpty)
              Row(children: [
                Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                SizedBox(width: 4),
                Text("From: ${data['from_location']}", style: TextStyle(fontSize: 14)),
              ]),
            if (data['to_location'] != null && data['to_location'].toString().isNotEmpty)
              Row(children: [
                Icon(Icons.flag, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text("To: ${data['to_location']}", style: TextStyle(fontSize: 14)),
              ]),
            if (data['note'] != null && data['note'].toString().isNotEmpty) ...[
              SizedBox(height: 6),
              Row(children: [
                Icon(Icons.note, size: 16, color: Colors.blueGrey),
                SizedBox(width: 4),
                Expanded(child: Text("Requirement: ${data['note']}", style: TextStyle(fontSize: 13))),
              ]),
            ],
            if (data['night_stay'] == "true" || data['food_option'] == "true") ...[
              SizedBox(height: 6),
              Row(
                children: [
                  if (data['night_stay'] == "true")
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            value: true,
                            onChanged: null,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Text("Night Stay", style: TextStyle(fontSize: 13)),
                        SizedBox(width: 10),
                      ],
                    ),
                  if (data['food_option'] == "true")
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            value: true,
                            onChanged: null,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Text("Food Option", style: TextStyle(fontSize: 13)),
                      ],
                    ),
                ],
              ),
            ],
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Start: ${formatDate(data['start_date'])}", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Text("End: ${formatDate(data['end_date'])}", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  if (status != "pending" && data['expected_fare'] != null)
                    Text("₹${data['expected_fare']}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (data['user_name'] != null && data['user_name'].toString().isNotEmpty && data['user_contact'] != null && data['user_contact'].toString().isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Name: ${data['user_name']}", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Text("Contact: ${data['user_contact']}", style: TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            SizedBox(height: 10),
            if (status == "pending" || status == "bet_update")
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _showFareInputDialog(data);
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      status == "pending" ? "Accept Ride" : "Update Fare",
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
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 3,
        itemBuilder: (_, __) => Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 20,
                      color: Colors.white,
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    Spacer(),
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fareController.dispose();
    super.dispose();
  }
}