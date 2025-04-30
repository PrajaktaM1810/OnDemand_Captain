import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/NavigatorPages/subscription_list.dart';
import 'package:lottie/lottie.dart';
import '../../functions/functions.dart';

class ManualPaymentScreen extends StatefulWidget {
  final int packageId;
  final String packageAmount;

  const ManualPaymentScreen({
    super.key,
    required this.packageId,
    required this.packageAmount,
  });

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final TextEditingController _transactionIdController = TextEditingController();
  String? qrCodeUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  Future<void> _fetchQrCode() async {
    String qrUrl = await getQrCodeImg();
    if (mounted) {
      setState(() {
        qrCodeUrl = qrUrl;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_transactionIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the transaction ID")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int userId = userDetails['id'];
    String response = await subscribePackage(userId, widget.packageId, _transactionIdController.text,widget.packageAmount);

    setState(() {
      _isLoading = false;
    });

    _showResponseDialog(response);
  }

  void _showResponseDialog(String response) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: SizedBox(
          width: 120,
          height: 120,
          child: Lottie.asset(
            jsonResponse['success']
                ? 'assets/success.json'
                : 'assets/fail.json',
            fit: BoxFit.contain,
          ),
        ),
        content: Text(
          jsonResponse['success'] ? "Package Subscribed" : jsonResponse['message'],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionListScreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 350,
              width: 350,
              child: qrCodeUrl != null && qrCodeUrl != 'failure' && qrCodeUrl != 'logout' && qrCodeUrl != 'no internet'
                  ? Image.network(qrCodeUrl!, fit: BoxFit.contain)
                  : const Center(child: Text("Loading Image..")),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _transactionIdController,
                decoration: const InputDecoration(
                  labelText: "Transaction ID",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                )
                    : const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
