import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smarthome_mobile/core/constants/app_constants.dart';

class MqttService {
  late MqttServerClient client;
  final Function(String, bool) onDeviceStatusChanged;
  final Function(String, Map<String, dynamic>)? onDeviceStateChanged;
  final Set<String> _stateSubscriptions = <String>{};

  MqttService({
    required this.onDeviceStatusChanged,
    this.onDeviceStateChanged,
  }) {
    client = MqttServerClient(AppConstants.mqttBrokerHost, "appClient");
    client.port = 1883;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
  }

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final topic = c[0].topic;

      print('Received message: $payload from topic: $topic');

      if (topic.endsWith('/system')) {
        try {
          final data = jsonDecode(payload);
          if (data.containsKey('online')) {
            final deviceTopicBase = topic.replaceAll('/system', '');
            onDeviceStatusChanged(deviceTopicBase, data['online']);
          }
        } catch (e) {
          print('Error decoding mqtt message: $e');
        }
      } else if (topic.endsWith('/state')) {
        // Forward state updates to consumers (e.g., DeviceProvider)
        try {
          final data = jsonDecode(payload);
          if (data is Map<String, dynamic>) {
            final deviceTopicBase = topic.replaceAll('/state', '');
            onDeviceStateChanged?.call(deviceTopicBase, data);
          } else {
            // If payload isn't a map, ignore gracefully
            print('State payload is not a JSON object: $data');
          }
        } catch (e) {
          print('Error decoding mqtt state message: $e');
        }
      }
    });
  }

  void subscribeToTopics(List<String> topics) {
    for (var topic in topics) {
      final systemTopic = '$topic/system';
      print('Subscribing to $systemTopic');
      client.subscribe(systemTopic, MqttQos.atLeastOnce);
    }
  }

  void unsubscribeFromTopics(List<String> topics) {
    for (var topic in topics) {
      final systemTopic = '$topic/system';
      print('Unsubscribing from $systemTopic');
      client.unsubscribe(systemTopic);
    }
  }

  // Per-device state topic management (subscribe when opening detail page)
  void subscribeToStateTopic(String topicBase) {
    final stateTopic = '$topicBase/state';
  _stateSubscriptions.add(topicBase);
    if (!isConnected) {
      print('MQTT not connected; cannot subscribe to $stateTopic now');
      return;
    }
    print('Subscribing to $stateTopic');
    client.subscribe(stateTopic, MqttQos.atLeastOnce);
  }

  void unsubscribeFromStateTopic(String topicBase) {
    final stateTopic = '$topicBase/state';
  _stateSubscriptions.remove(topicBase);
    if (!isConnected) {
      // If not connected, nothing to unsubscribe
      return;
    }
    print('Unsubscribing from $stateTopic');
    client.unsubscribe(stateTopic);
  }

  void onConnected() {
    print('Connected to MQTT broker');
    // Restore state topic subscriptions requested previously
    for (final base in _stateSubscriptions) {
      final stateTopic = '$base/state';
      client.subscribe(stateTopic, MqttQos.atLeastOnce);
    }
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe to $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void disconnect() {
    client.disconnect();
  }
}
