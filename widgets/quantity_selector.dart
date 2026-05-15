import 'package:flutter/material.dart';
import '../utils/colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final Function(int) onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
        ),
        Container(
          width: 45,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: quantity < maxQuantity ? () => onQuantityChanged(quantity + 1) : null,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onPressed != null ? AppColors.primary : Colors.grey.shade400,
        ),
      ),
    );
  }
}