import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionsService {
  // Obtenir la date de début et de fin pour différents filtres
  static DateTime getTodayStart() {
    return DateTime.now().subtract(Duration(
      hours: DateTime.now().hour,
      minutes: DateTime.now().minute,
      seconds: DateTime.now().second,
      milliseconds: DateTime.now().millisecond,
      microseconds: DateTime.now().microsecond,
    ));
  }

  static DateTime getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  static DateTime getYesterdayStart() {
    return getTodayStart().subtract(Duration(days: 1));
  }

  static DateTime getYesterdayEnd() {
    final now = DateTime.now().subtract(Duration(days: 1));
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  static DateTime getMonthStart() {
    return DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  static DateTime getLastMonthStart() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  static DateTime getThisMonthEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999); // Le dernier jour du mois
  }

  static DateTime getThisMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1, 0, 0);
  }

  static DateTime getLastMonthEnd() {
    return DateTime(DateTime.now().year, DateTime.now().month, 1)
        .subtract(Duration(seconds: 1));
  }

  // Méthode pour obtenir les transactions filtrées par date
  static Stream<List<Map<String, dynamic>>> listenToTransactionsFiltered(
      String userId, String collection, DateTime startDate, DateTime endDate) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, dynamic>> transactionList = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Ajouter l'ID du document
        transactionList.add(data);
      });

      // Trier les transactions par date
      transactionList.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateA.compareTo(dateB); // Tri croissant par date
      });

      return transactionList;
    });
  }

  // Méthode pour calculer la somme des prix pour une collection donnée et un intervalle de temps
  static Stream<double> calculateTotalPrice(
      String userId, String collection, DateTime startDate, DateTime endDate) {
    return listenToTransactionsFiltered(userId, collection, startDate, endDate)
        .map((transactions) {
      return transactions.fold<double>(0, (sum, transaction) {
        return sum + ((transaction['price'] ?? 0) as num).toDouble(); // Additionne les prix
      });
    });
  }

  // Fonctions pour obtenir les totaux de prix par période pour chaque collection
  static Stream<double> todayIncomesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'incomes', // Collection des revenus
      getTodayStart(),
      getTodayEnd(),
    );
  }

  static Stream<double> todayExpensesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'expenses', // Collection des dépenses
      getTodayStart(),
      getTodayEnd(),
    );
  }

  static Stream<double> todayDebtsTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'debts', // Collection des dettes
      getTodayStart(),
      getTodayEnd(),
    );
  }

  static Stream<double> yesterdayIncomesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'incomes',
      getYesterdayStart(),
      getYesterdayEnd(),
    );
  }

  static Stream<double> yesterdayExpensesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'expenses',
      getYesterdayStart(),
      getYesterdayEnd(),
    );
  }

  static Stream<double> yesterdayDebtsTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'debts',
      getYesterdayStart(),
      getYesterdayEnd(),
    );
  }

  static Stream<double> thisMonthIncomesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'incomes',
      getMonthStart(),
      DateTime.now(),
    );
  }

  static Stream<double> thisMonthExpensesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'expenses',
      getMonthStart(),
      DateTime.now(),
    );
  }

  static Stream<double> thisMonthDebtsTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'debts',
      getMonthStart(),
      DateTime.now(),
    );
  }

  static Stream<double> lastMonthIncomesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'incomes',
      getLastMonthStart(),
      getLastMonthEnd(),
    );
  }

  static Stream<double> lastMonthExpensesTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'expenses',
      getLastMonthStart(),
      getLastMonthEnd(),
    );
  }

  static Stream<double> lastMonthDebtsTotal(String userId) {
    return calculateTotalPrice(
      userId,
      'debts',
      getLastMonthStart(),
      getLastMonthEnd(),
    );
  }
}
