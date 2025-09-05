class Rule {
  final String id;
  final String name;
  final Conditions conditions;
  final List<RuleAction> actions;
  final bool enabled;
  final String ownerId;

  Rule({
    required this.id,
    required this.name,
    required this.conditions,
    required this.actions,
    required this.enabled,
    required this.ownerId,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'],
      name: json['name'],
      conditions: Conditions.fromJson(json['conditions']),
      actions: (json['actions'] as List)
          .map((action) => RuleAction.fromJson(action))
          .toList(),
      enabled: json['enabled'],
      ownerId: json['owner_id'],
    );
  }

  @override
  String toString() {
    return 'Rule{id: $id, name: $name, enabled: $enabled, ownerId: $ownerId, conditions: $conditions, actions: $actions}';
  }
}

class Conditions {
  final String operator;
  final List<ConditionChild> children;

  Conditions({required this.operator, required this.children});

  factory Conditions.fromJson(Map<String, dynamic> json) {
    return Conditions(
      operator: json['operator'],
      children: (json['children'] as List)
          .map((child) => ConditionChild.fromJson(child))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Conditions{operator: $operator, children: $children}';
  }
}

class ConditionChild {
  final String type;
  final String? op;
  final dynamic value;
  final String? key;
  final String? deviceId;
  final double? minChange;

  ConditionChild({
    required this.type,
    this.op,
    this.value,
    this.key,
    this.deviceId,
    this.minChange,
  });

  factory ConditionChild.fromJson(Map<String, dynamic> json) {
    return ConditionChild(
      type: json['type'],
      op: json['op'],
      value: json['value'],
      key: json['key'],
      deviceId: json['device_id'],
      minChange: json['min_change']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'ConditionChild{type: $type, op: $op, value: $value, key: $key, deviceId: $deviceId, minChange: $minChange}';
  }
}

class RuleAction {
  final String action;
  final Map<String, dynamic> params;
  final String deviceId;

  RuleAction({
    required this.action,
    required this.params,
    required this.deviceId,
  });

  factory RuleAction.fromJson(Map<String, dynamic> json) {
    return RuleAction(
      action: json['action'],
      params: json['params'],
      deviceId: json['device_id'],
    );
  }

  @override
  String toString() {
    return 'RuleAction{action: $action, params: $params, deviceId: $deviceId}';
  }
}
