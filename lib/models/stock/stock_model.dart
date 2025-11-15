class Stock {
  final String id;
  final String storeId;
  final String productId;
  final int totalQuantity;
  final List<PricingTier> pricing;
  final DateTime createdAt;
  final DateTime updatedAt;

  Stock({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.totalQuantity,
    required this.pricing,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['_id'],
      storeId: json['storeId'],
      productId: json['productId'],
      totalQuantity: json['totalQuantity'],
      pricing: (json['pricing'] as List)
          .map((item) => PricingTier.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'productId': productId,
      'totalQuantity': totalQuantity,
      'pricing': pricing.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PricingTier {
  final String tierName;
  final int quantityPerTier;
  final double pricePerTier;
  final int minimumOrder;

  PricingTier({
    required this.tierName,
    required this.quantityPerTier,
    required this.pricePerTier,
    required this.minimumOrder,
  });

  factory PricingTier.fromJson(Map<String, dynamic> json) {
    return PricingTier(
      tierName: json['tierName'],
      quantityPerTier: json['quantityPerTier'],
      pricePerTier: (json['pricePerTier'] as num).toDouble(),
      minimumOrder: json['minimumOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tierName': tierName,
      'quantityPerTier': quantityPerTier,
      'pricePerTier': pricePerTier,
      'minimumOrder': minimumOrder,
    };
  }
}