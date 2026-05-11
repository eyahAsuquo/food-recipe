import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe/providers/cart_provider.dart';
import 'package:food_recipe/screens/order_success.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String _selectedPayment = 'card';
  bool _isPlacingOrder = false;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalAmount;
    final shipping = subtotal >= 50 ? 0.0 : 4.99;
    final tax = subtotal * 0.08;
    final total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: isLast
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isPlacingOrder = true);
                              // Capture navigator before any async gap
                              final nav = Navigator.of(context);
                              await Future.delayed(
                                  const Duration(seconds: 2));
                              if (!mounted) return;
                              await cart.clearCart();
                              nav.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const OrderSuccessPage(),
                                ),
                              );
                            }
                          }
                        : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(isLast ? 'Place Order' : 'Continue'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: [
            // ── Step 1: Shipping ──────────────────────────────────
            Step(
              title: const Text(
                'Shipping Info',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Where should we deliver?'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  _buildField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter your phone' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _addressCtrl,
                    label: 'Street Address',
                    icon: Icons.location_on_outlined,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildField(
                          controller: _cityCtrl,
                          label: 'City',
                          icon: Icons.location_city_outlined,
                          validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: _zipCtrl,
                          label: 'ZIP',
                          icon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Step 2: Payment ───────────────────────────────────
            Step(
              title: const Text(
                'Payment',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('How would you like to pay?'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  // Payment method selection
                  _PaymentOption(
                    label: 'Credit / Debit Card',
                    icon: Icons.credit_card,
                    value: 'card',
                    groupValue: _selectedPayment,
                    onChanged: (v) =>
                        setState(() => _selectedPayment = v!),
                  ),
                  _PaymentOption(
                    label: 'PayPal',
                    icon: Icons.account_balance_wallet_outlined,
                    value: 'paypal',
                    groupValue: _selectedPayment,
                    onChanged: (v) =>
                        setState(() => _selectedPayment = v!),
                  ),
                  _PaymentOption(
                    label: 'Cash on Delivery',
                    icon: Icons.money_outlined,
                    value: 'cod',
                    groupValue: _selectedPayment,
                    onChanged: (v) =>
                        setState(() => _selectedPayment = v!),
                  ),
                  if (_selectedPayment == 'card') ...[
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _cardNumberCtrl,
                      label: 'Card Number',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.length < 12
                          ? 'Enter valid card number'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _expiryCtrl,
                            label: 'MM/YY',
                            icon: Icons.date_range_outlined,
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _cvvCtrl,
                            label: 'CVV',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (v) =>
                                v!.length < 3 ? 'Invalid CVV' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Step 3: Review ────────────────────────────────────
            Step(
              title: const Text(
                'Review Order',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Confirm your order details'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items summary
                  ...cart.cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.title} x${item.quantity}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _OrderRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
                  _OrderRow(
                    label: 'Shipping',
                    value: shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
                  ),
                  _OrderRow(
                    label: 'Tax (8%)',
                    value: '\$${tax.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 24),
                  _OrderRow(
                    label: 'Total',
                    value: '\$${total.toStringAsFixed(2)}',
                    bold: true,
                    color: const Color(0xFF6C63FF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEEDFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  selected ? const Color(0xFF6C63FF) : Colors.grey[500],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? const Color(0xFF6C63FF)
                    : Colors.grey[700],
              ),
            ),
            const Spacer(),
            // Custom selection indicator (replaces deprecated Radio)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _OrderRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: bold ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 18 : 14,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
