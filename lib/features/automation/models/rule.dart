import 'dart:convert';

class Rule {
  final String id;
  final String name;
  final Conditions conditions;
  final List<RuleAction> actions;
  final bool enabled;
  final String? ownerId;

  Rule({
    required this.id,
    required this.name,
    required this.conditions,
    required this.actions,
    required this.enabled,
    this.ownerId,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      conditions: json['conditions'] is String
          ? Conditions.fromJson(jsonDecode(json['conditions']))
          : Conditions.fromJson(json['conditions']),
      actions: json['actions'] is String
          ? (jsonDecode(json['actions']) as List)
              .map((action) => RuleAction.fromJson(action))
              .toList()
          : (json['actions'] as List)
              .map((action) => RuleAction.fromJson(action))
              .toList(),
      enabled: json['enabled'] ?? false,
      ownerId: json['owner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'conditions': conditions.toJson(),
      'actions': actions.map((action) => action.toJson()).toList(),
      'enabled': enabled,
      'owner_id': ownerId,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'operator': operator,
      'children': children.map((child) => child.toJson()).toList(),
    };
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
  final String? device_id;
  final double? min_change;

  ConditionChild({
    required this.type,
    this.op,
    this.value,
    this.key,
    this.device_id,
    this.min_change,
  });

  factory ConditionChild.fromJson(Map<String, dynamic> json) {
    return ConditionChild(
      type: json['type'],
      op: json['op'],
      value: json['value'],
      key: json['key'],
      device_id: json['device_id']?.toString(),
      min_change: json['min_change']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
    };

    if (op != null) json['op'] = op;
    if (value != null) json['value'] = value;
    if (key != null) json['key'] = key;
    if (device_id != null) json['device_id'] = device_id;
    if (min_change != null) json['min_change'] = min_change;

    return json;
  }

  @override
  String toString() {
    return 'ConditionChild{type: $type, op: $op, value: $value, key: $key, device_id: $device_id, min_change: $min_change}';
  }
}

class RuleAction {
  final String action;
  final Map<String, dynamic> params;
  final String device_id;

  RuleAction({
    required this.action,
    required this.params,
    required this.device_id,
  });

  factory RuleAction.fromJson(Map<String, dynamic> json) {
    return RuleAction(
      action: json['action'],
      params: json['params'],
      device_id: json['device_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'params': params,
      'device_id': device_id,
    };
  }

  @override
  String toString() {
    return 'RuleAction{action: $action, params: $params, device_id: $device_id}';
  }
}
