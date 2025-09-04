import 'package:flutter/material.dart';
import '../../features/automation/models/automation.dart';

class AutomationProvider extends ChangeNotifier {
  List<Automation> automations = [];

  AutomationProvider() {
    loadAutomations();
  }

  void loadAutomations() {
    // Mock data; replace with repository call in future
    automations = [
      Automation(
        id: '1',
        name: 'Evening Lights',
        trigger: Trigger(
          type: 'time',
          value: '18:00',
          description: 'Daily at 6:00 PM',
        ),
        action: AutomationAction(
          type: 'device_toggle',
          deviceId: '1',
          value: 'true',
          description: 'Turn on Living Room Light',
        ),
      ),
    ];
    notifyListeners();
  }

  void addAutomation(Automation automation) {
    automations.add(automation);
    notifyListeners();
    // In future: Save to database/API
  }

  void removeAutomation(String id) {
    automations.removeWhere((a) => a.id == id);
    notifyListeners();
    // In future: Delete from database/API
  }

  void toggleAutomation(String id, bool isEnabled) {
    final index = automations.indexWhere((a) => a.id == id);
    if (index != -1) {
      automations[index] = Automation(
        id: automations[index].id,
        name: automations[index].name,
        trigger: automations[index].trigger,
        condition: automations[index].condition,
        action: automations[index].action,
        isEnabled: isEnabled,
      );
      notifyListeners();
      // In future: Update in database/API
    }
  }
}
