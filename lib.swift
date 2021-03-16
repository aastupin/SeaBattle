enum Direction: Int, CaseIterable {
    case up = 0
    case right = 1
}

enum Cell: Int{
   case free = 0
   case ship = 1
   case near_ship = 2
   case shot = 3
   case killed = 4
}
enum ShotStatus {
   case miss, hit, kill, again
}
enum PlayerTypes: Int{
   case human = 0
   case AI = 1
}

enum GameState: Int{
   case player_turn = 0
   case player_shot = 1
   case game_finished = 2
}


enum MapSymbol: String {
   case ship = "#"
   case shot = "*"
   case free = " "
   case killed = "X"
}

struct MapField {
   var elem: MapSymbol;
   var ship_index: Int;
   var status: Cell; 
}

let CLR = "\u{001B}";

enum TextColors:String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;91m"//31 91
    case green = "\u{001B}[0;92m"//32 92
    case yellow = "\u{001B}[0;93m"//33 93
    case blue = "\u{001B}[0;94m"//34 94
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

let MapSymbolColor: [String:String] = [
    MapSymbol.ship.rawValue : TextColors.yellow.rawValue,
    MapSymbol.shot.rawValue : TextColors.blue.rawValue,
    MapSymbol.free.rawValue : TextColors.black.rawValue,
    MapSymbol.killed.rawValue : TextColors.red.rawValue,
];
