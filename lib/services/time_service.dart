import 'package:get/get.dart';
import 'package:ntp/ntp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class TimeService extends GetxService {
  final _offset = 0.obs;
  final isSynced = false.obs;

  // List of reliable NTP servers
  final List<String> _ntpServers = [
    'time.google.com',
    'time.cloudflare.com',
    'pool.ntp.org',
    'time.apple.com'
  ];

  @override
  void onInit() {
    super.onInit();
    syncTime();
    
    // Periodic re-sync every 10 minutes to prevent drift
    Timer.periodic(const Duration(minutes: 10), (_) => syncTime());
  }

  Future<void> syncTime() async {
    print("TIME SYNC: Starting multi-strategy synchronization...");
    
    // Strategy 1: NTP Sync (High Precision)
    for (String server in _ntpServers) {
      try {
        final offset = await NTP.getNtpOffset(
          localTime: DateTime.now(), 
          lookUpAddress: server,
          timeout: const Duration(seconds: 5),
        );
        _offset.value = offset;
        isSynced.value = true;
        print("TIME SYNC: Strategy NTP ($server) successful. Offset: $offset ms");
        return; // Success!
      } catch (e) {
        print("TIME SYNC: NTP $server failed. Trying next...");
      }
    }

    // Strategy 2: Firestore Server Fallback (Extremely Reliable)
    // Some mobile networks block UDP (port 123) used by NTP. 
    // We use Firestore's own server time as a fall-back.
    try {
      final docRef = FirebaseFirestore.instance.collection('system').doc('time_probe');
      
      // Write server timestamp
      await docRef.set({'probe': FieldValue.serverTimestamp()});
      
      // Immediately read it back
      final snap = await docRef.get();
      final Timestamp? serverTime = snap.data()?['probe'] as Timestamp?;
      
      if (serverTime != null) {
        final localNow = DateTime.now();
        final offset = serverTime.toDate().difference(localNow).inMilliseconds;
        _offset.value = offset;
        isSynced.value = true;
        print("TIME SYNC: Strategy Firestore successful. Offset: $offset ms");
      }
    } catch (e) {
      print("TIME SYNC: Strategy Firestore failed: $e");
    }
  }

  /// Returns the synchronized network time
  DateTime get now {
    return DateTime.now().add(Duration(milliseconds: _offset.value));
  }

  int get currentOffset => _offset.value;
}
