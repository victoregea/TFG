import 'package:carcount/pages/create_trip_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final List<Map<String, dynamic>> trips = [];
  final List<Map<String, dynamic>> balances = [];

  Map<String, dynamic> usersInGroup = {};

  @override
  void initState() {
    super.initState();
    loadUsersAndTrips();
  }

  Future<void> loadUsersAndTrips() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection("Usuarios").get();
    final groupUsers = <String, dynamic>{};

    for (var doc in usersSnapshot.docs) {
      final userData = doc.data();
      final grupos = List.from(userData['Grupos'] ?? []);
      if (grupos.any((g) => g['GroupId'] == widget.groupId)) {
        groupUsers[doc.id] = userData;
      }
    }

    setState(() {
      usersInGroup = groupUsers;
    });

    await loadTrips(groupUsers);
  }

  Future<void> loadTrips(Map<String, dynamic> users) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Grupos")
        .doc(widget.groupId)
        .collection("Trayectos")
        .orderBy("fecha", descending: true)
        .get();

    final tripGroups = <String, List<Map<String, dynamic>>>{};

    for (var doc in snapshot.docs) {
      final trip = doc.data();
      final fecha = trip['fecha']?.substring(0, 10) ?? 'Sin fecha';

      final conductorId = trip['conductor'];
      final pasajeros = List<String>.from(trip['pasajeros'] ?? []);
      final usuarios = [conductorId, ...pasajeros];
      final costeTotal = (trip['coste'] ?? 0).toDouble();
      final costePorPersona = costeTotal / usuarios.length;

      // Balance interno por trayecto (solo si pasajero != conductor)
      for (final pasajero in pasajeros) {
        if (pasajero != conductorId) {
          balances.add({
            'from': pasajero,
            'to': conductorId,
            'amount': costePorPersona,
          });
        }
      }

      tripGroups[fecha] = tripGroups[fecha] ?? [];
      tripGroups[fecha]!.add({
        'title': trip['titulo'],
        'conductor': users[conductorId]?['Nombre de usuario'] ?? conductorId,
        'amount': '${trip['coste']?.toStringAsFixed(2) ?? "0.00"} €',
      });
    }

    final sortedTrips = tripGroups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final formattedTrips = sortedTrips
        .map((entry) => {'date': entry.key, 'items': entry.value})
        .toList();

    setState(() {
      trips.clear();
      trips.addAll(formattedTrips);
    });
  }

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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTripPage(
                groupId: widget.groupId,
                groupName: widget.groupName,
              ),
            ),
          );
          // Refrescar datos al volver de CreateTripPage
          setState(() {
            trips.clear();
            balances.clear();
          });
          await loadUsersAndTrips();
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
    if (balances.isEmpty) {
      return const Center(
        child:
            Text("No hay deudas registradas", style: TextStyle(fontSize: 16)),
      );
    }

    final currentUserId = FirebaseAuth.instance.currentUser!.email;
    final Map<String, double> netBalances = {};

    for (var balance in balances) {
      final from = balance['from'];
      final to = balance['to'];
      final amount = balance['amount'];

      final key = '$from|$to';
      final reverseKey = '$to|$from';

      if (netBalances.containsKey(reverseKey)) {
        netBalances[reverseKey] = netBalances[reverseKey]! - amount;
      } else {
        netBalances[key] = (netBalances[key] ?? 0) + amount;
      }
    }

    // Filtrar solo deudas netas > 0
    final filteredBalances =
        netBalances.entries.where((e) => e.value > 0).toList();

    if (filteredBalances.isEmpty) {
      return const Center(
        child: Text("No hay deudas pendientes", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(15),
      children: filteredBalances.map((entry) {
        final parts = entry.key.split('|');
        final from = parts[0];
        final to = parts[1];
        final amount = entry.value;

        final fromName = usersInGroup[from]?['Nombre de usuario'] ?? from;
        final toName = usersInGroup[to]?['Nombre de usuario'] ?? to;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: fromName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' debe a '),
                    TextSpan(
                      text: to == currentUserId ? '$toName (me)' : toName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "€ ${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
