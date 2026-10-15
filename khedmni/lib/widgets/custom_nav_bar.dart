import 'package:flutter/material.dart';

const Color kPrimaryDarkBlue = Color(0xFF1D3557);

class CustomNavBar extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Widget _buildProfileIcon(bool isSelected) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.transparent,
          width: 2,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/leena.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStandardIcon(IconData icon, bool isSelected) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isSelected ? 1.15 : 1.0,
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double boxWidth = 70;
    const double boxHeight = 60;

    // Adjust alignments based on the number of icons if needed, 
    // but keeping it simple for 3 icons as per original code.
    // Dynamic alignment calculation
    final double range = 1.7; // Range from -0.85 to 0.85
    final double step = icons.length > 1 ? range / (icons.length - 1) : 0;
    
    final alignments = List.generate(icons.length, (index) {
      return Alignment(-0.85 + (step * index), 0);
    });

    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔵 Animated blue background box
          AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: alignments.length > selectedIndex ? alignments[selectedIndex] : Alignment.center,
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                color: kPrimaryDarkBlue,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // 🔘 Icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: icons.asMap().entries.map((entry) {
              int index = entry.key;
              bool isSelected = index == selectedIndex;

              Widget iconWidget = index == icons.length - 1
                  ? _buildProfileIcon(isSelected)
                  : _buildStandardIcon(entry.value, isSelected);

              return GestureDetector(
                onTap: () => onItemTapped(index),
                child: SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: Center(child: iconWidget),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
