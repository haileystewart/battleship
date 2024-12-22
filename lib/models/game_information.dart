class GameInformationResponse {
  final int id;
  final int status;
  final int position;
  final int turn;
  final String player1;
  final String? player2;
  final List<String> ships;
  final List<String> wrecks;
  final List<String> shots;
  final List<String> sunk;

  GameInformationResponse({
    required this.id,
    required this.status,
    required this.position,
    required this.turn,
    required this.player1,
    this.player2,
    required this.ships,
    required this.wrecks,
    required this.shots,
    required this.sunk,
  });

  factory GameInformationResponse.fromJson(Map<String, dynamic> json) {
    return GameInformationResponse(
      id: json['id'],
      status: json['status'],
      position: json['position'],
      turn: json['turn'],
      player1: json['player1'],
      player2: json['player2'],
      ships: List<String>.from(json['ships']),
      wrecks: List<String>.from(json['wrecks']),
      shots: List<String>.from(json['shots']),
      sunk: List<String>.from(json['sunk']),
    );
  }
}
