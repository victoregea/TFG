import 'package:carcount/pages/create_trip_page.dart';
import 'package:flutter/material.dart';

class GroupInformationPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupInformationPage({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  State<GroupInformationPage> createState() => _GroupInformationPageState();
}

class _GroupInformationPageState extends State<GroupInformationPage> {
  int selectedIndex = 0;

  // Listas vacías por defecto
  final List<Map<String, dynamic>> trips = [];

  final List<Map<String, String>> balances = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title:
            Text(widget.groupName, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _tabButton("Trayectos", 0),
                        _tabButton("Balance", 1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child:
                  selectedIndex == 0 ? _buildTripsView() : _buildBalanceView(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2274A5),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTripPage(
                groupId: widget.groupId,
                groupName: widget.groupName,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2274A5) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripsView() {
    if (trips.isEmpty) {
      return const Center(
        child: Text(
          "No hay ningún trayecto registrado",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final group = trips[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['date'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ...group['items'].map<Widget>((trip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.directions_car,
                      color: Color(0xFFFFC857)),
                  title: Text(trip['title']),
                  subtitle: Text('Conductor: ${trip['conductor']}'),
                  trailing: Text(trip['amount'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }).toList()
          ],
        );
      },
    );
  }

  Widget _buildBalanceView() {
    // Si la lista de balances está vacía, no mostramos nada
    if (balances.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: balances.length,
      itemBuilder: (context, index) {
        final balance = balances[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                    text: '${balance['from']} ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: 'debe a '),
                TextSpan(
                    text: '${balance['to']} ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${balance['amount']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
