class GameStartResponse {
  final int id;
  final int player;
  final bool matched;

  GameStartResponse({
    required this.id,
    required this.player,
    required this.matched,
  });

  factory GameStartResponse.fromJson(Map<String, dynamic> json) {
    return GameStartResponse(
      id: json['id'],
      player: json['player'],
      matched: json['matched'],
    );
  }
}
