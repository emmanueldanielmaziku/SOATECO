import 'package:flutter/material.dart';
import 'dart:math';


class GooglePayService {

  static const String _baseUrl = 'https://payments.googleapis.com';

 
  static const String _merchantId =
      '12345678901234567890';
  static const String _merchantName = 'SOATECO Student Portal';
  static const String _environment =
      'TEST';
  static Future<bool> isGooglePayAvailable() async {
    try {

      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      debugPrint('Google Pay not available: $e');
      return false;
    }
  }

  /// Process payment with Google Pay
  static Future<GooglePayResult> payWithGooglePay({
    required BuildContext context,
    required double amount,
    required String description,
    required String campaignId,
  }) async {
    try {
      // Check if Google Pay is available
      final isAvailable = await isGooglePayAvailable();
      if (!isAvailable) {
        return GooglePayResult(
          success: false,
          errorMessage: 'Google Pay is not available on this device',
          transactionId: null,
        );
      }

      // Show payment confirmation dialog
      final confirmed = await _showPaymentConfirmationDialog(
        context,
        amount,
        description,
      );

      if (!confirmed) {
        return GooglePayResult(
          success: false,
          errorMessage: 'Payment cancelled by user',
          transactionId: null,
        );
      }

      // Process payment
      final result = await _processPayment(amount, description, campaignId);

      return result;
    } catch (e) {
      return GooglePayResult(
        success: false,
        errorMessage: 'Payment failed: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Show payment confirmation dialog
  static Future<bool> _showPaymentConfirmationDialog(
    BuildContext context,
    double amount,
    String description,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Google Pay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPaymentRow('Amount:', 'TSh ${amount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildPaymentRow('Description:', description),
                const SizedBox(height: 8),
                _buildPaymentRow('Payment Method:', 'Google Pay (Sandbox)'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a sandbox payment. No real money will be charged.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue[700],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pay with Google Pay'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Build payment detail row
  static Widget _buildPaymentRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Process the actual payment
  static Future<GooglePayResult> _processPayment(
    double amount,
    String description,
    String campaignId,
  ) async {
    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate a unique transaction ID
      final transactionId = _generateTransactionId();

    
      final success =
          Random().nextDouble() > 0.1;

      if (success) {
        return GooglePayResult(
          success: true,
          errorMessage: null,
          transactionId: transactionId,
          amount: amount,
          timestamp: DateTime.now(),
        );
      } else {
        return GooglePayResult(
          success: false,
          errorMessage: 'Payment declined by bank',
          transactionId: transactionId,
        );
      }
    } catch (e) {
      return GooglePayResult(
        success: false,
        errorMessage: 'Payment processing failed: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Generate a unique transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'GP_${timestamp}_$random';
  }

  /// Validate payment amount
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 1000000;
  }

  /// Get Google Pay environment info
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'environment': _environment,
      'merchantId': _merchantId,
      'merchantName': _merchantName,
      'baseUrl': _baseUrl,
    };
  }
}



class GooglePayResult {
  final bool success;
  final String? errorMessage;
  final String? transactionId;
  final double? amount;
  final DateTime? timestamp;

  GooglePayResult({
    required this.success,
    this.errorMessage,
    this.transactionId,
    this.amount,
    this.timestamp,
  });

  @override
  String toString() {
    return 'GooglePayResult(success: $success, errorMessage: $errorMessage, transactionId: $transactionId)';
  }
}


class GooglePayPaymentRequest {
  final double amount;
  final String currency;
  final String description;
  final String merchantId;
  final String merchantName;
  final String environment;

  GooglePayPaymentRequest({
    required this.amount,
    this.currency = 'TZS',
    required this.description,
    this.merchantId = GooglePayService._merchantId,
    this.merchantName = GooglePayService._merchantName,
    this.environment = GooglePayService._environment,
  });

  Map<String, dynamic> toJson() {
    return {
      'apiVersion': 2,
      'apiVersionMinor': 0,
      'allowedPaymentMethods': [
        {
          'type': 'CARD',
          'parameters': {
            'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
            'allowedCardNetworks': ['MASTERCARD', 'VISA'],
          },
          'tokenizationSpecification': {
            'type': 'PAYMENT_GATEWAY',
            'parameters': {
              'gateway': 'example',
              'gatewayMerchantId': merchantId,
            },
          },
        },
      ],
      'merchantInfo': {
        'merchantName': merchantName,
        'merchantId': merchantId,
      },
      'transactionInfo': {
        'totalPriceStatus': 'FINAL',
        'totalPriceLabel': 'Total',
        'totalPrice': amount.toString(),
        'currencyCode': currency,
        'countryCode': 'TZ',
      },
    };
  }
}
