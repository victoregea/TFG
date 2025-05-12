import 'package:carcount/pages/group_information.dart';
import 'package:flutter/material.dart';

class Groups extends StatelessWidget {
  final String name;
  final String groupId;

  const Groups({
    super.key,
    required this.name,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupInformationPage(
              groupName: name,
              groupId: groupId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
        padding: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.time_to_leave_sharp,
              color: Color(0xFF2274A5),
              size: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}