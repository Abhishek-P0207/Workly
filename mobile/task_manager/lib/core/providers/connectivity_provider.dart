import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  
  return connectivityAsync.when(
    data: (results) {
      // Check if any connection is available
      return results.any((result) => 
        result != ConnectivityResult.none
      );
    },
    loading: () => true, // Assume online while checking
    error: (_, __) => false, // Assume offline on error
  );
});
