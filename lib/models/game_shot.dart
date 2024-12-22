

class GameShotResponse {
  final String message;
  final bool sunkShip;
  final bool won;

  GameShotResponse({
    required this.message,
    required this.sunkShip,
    required this.won,
  });

  factory GameShotResponse.fromJson(Map<String, dynamic> json) {
    return GameShotResponse(
      message: json['message'],
      sunkShip: json['sunk_ship'],
      won: json['won'],
    );
  }
}
