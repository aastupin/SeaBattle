import Foundation

class GameController{
   let map_size: Int = 10;
   let delayInSeconds:Int = 3;
   var player_human:Player;
   var player_enemy:Player;
   let map_latters: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
   let ship_types: [Int] = [1, 1, 1, 1, 2, 2, 2, 3, 3, 4];
   let map_distance_between_maps: String = "       ";
   let map_distance_between_elem: String = " ";
   var isFinished:Bool = false;
   var current_x:Int = 0,current_y:Int = 0;
   var current_game_state:GameState = GameState.player_turn;
   var incorrectInput:Bool = false;
   var currentShotStatus:ShotStatus = ShotStatus.miss;
   var currentPlayer:Player?;

   init (type_player1:PlayerTypes, type_player2:PlayerTypes, name1:String, name2:String){
      player_human = Player(m_size: self.map_size, type: type_player1, ship_types:ship_types, name: name1);
      player_enemy = Player(m_size: self.map_size, type: type_player2, ship_types:ship_types, name: name2);
      player_human.setEnemy(enemy: player_enemy);
      player_enemy.setEnemy(enemy: player_human);
   }

   func drawMaps() {
      //print header
      drawHeaders();
      drawPlayerMaps();   
      print("");
   }

   func drawHeaders(){
      var header =  String(repeating:map_distance_between_elem, count: 3);
      for l in map_latters {
         header += l + map_distance_between_elem;
      }
      header += map_distance_between_maps;
      let secondMapOffset = header.count;
      header +=  String(repeating:map_distance_between_elem, count: 3);
      for l in map_latters {
         header += l + map_distance_between_elem;
      }
      let offset = String(repeating:" ", count: secondMapOffset-4-player_enemy.name.count);
      let names = TextColors.yellow.rawValue+player_enemy.name+" map"+offset+TextColors.red.rawValue+player_human.name+" map"+TextColors.default.rawValue;
      print (names);
      print (header);
   }

   func drawPlayerMaps(){
      //drawEnemy first
      for i in 0...map_size-1 {
         var line =  String(repeating:map_distance_between_elem, count: 1-Int((i+1)/10)) + String(i+1)+map_distance_between_elem;
         for j in 0...map_size-1 {
            if (player_enemy.map[i][j].elem==MapSymbol.ship){
               line += colorText(text:MapSymbol.free.rawValue) + map_distance_between_elem;
            } else {
               line += colorText(text:player_enemy.map[i][j].elem.rawValue) + map_distance_between_elem;
            }
         }
         line += map_distance_between_maps;
         line += String(repeating:map_distance_between_elem, count: 1-Int((i+1)/10))+String(i+1) + map_distance_between_elem;
         for j in 0...map_size-1 {
            line += colorText(text:player_human.map[i][j].elem.rawValue) + map_distance_between_elem;
         }
         print (line);
      }
   }

   func colorText(text:String)->(String){
      return getColorByText(t:text)+text+TextColors.default.rawValue;
   }
   func clearScreen(){
      system("cls");
   }
   func pressAnyKeyToExit(){
      system("echo Press any key to exit");
      system("pause>nul");
   }
   func getColorByText(t:String)->(String){
       return MapSymbolColor[t]!;
   }
   func coloredText(color:TextColors, text:String)->(String){
       return color.rawValue+text+TextColors.default.rawValue;
   }
   func startGame(){
      currentPlayer = player_human;
      while (true){
         if (isFinished){
            break;
         }
         clearScreen();
         game_controller.drawMaps();         
         switch current_game_state {
            case .player_turn:
               if (incorrectInput){
                  print (coloredText(color:TextColors.red, text:"Wrong input!"));  
               }
               print ("\(currentPlayer!.name) turn. Input a place in the format 'a1':");               
               let parsed_input = parseInput();
               if (parsed_input.0+parsed_input.1 == -1){
                  incorrectInput = true;
               } else {
                  current_x = parsed_input.1 - 1;
                  current_y = parsed_input.0;
                  incorrectInput = false;
                  current_game_state = GameState.player_shot;
                  currentShotStatus = currentPlayer!.doShot(x:current_x, y:current_y);
               }
            case .player_shot:
               print ("\(currentPlayer!.name) shoot in: \(map_latters[current_y])\(current_x+1)");
               current_game_state = GameState.player_turn;
               switch currentShotStatus {
                  case .miss:
                     print (coloredText(color:TextColors.red, text:"Missed.")+"Turn passed to "+coloredText(color:TextColors.yellow, text:"\(currentPlayer!.enemy!.name)"));
                     currentPlayer = currentPlayer!.enemy;
                  case .hit:
                     print (coloredText(color:TextColors.green, text:"HIT!")+" Shot again.");
                  case .kill:
                     print (coloredText(color:TextColors.green, text:"\(currentPlayer!.name)")+" killed the ship with a size \(currentPlayer!.enemy!.ships[currentPlayer!.enemy!.map[current_x][current_y].ship_index].size)");
                     if (currentPlayer!.enemy!.ships_alive_count==0){
                        current_game_state = GameState.game_finished;
                     }
                  case .again:
                     print ("You already shoot there. Shot again!");
               }
               sleep(second:delayInSeconds);
            case .game_finished:
                if (player_human.type == PlayerTypes.human && currentPlayer!.name != player_human.name){
                    print (coloredText(color:TextColors.red, text:"You lost."));
                }
                print (coloredText(color:TextColors.yellow, text:"\(currentPlayer!.name)")+" "+coloredText(color:TextColors.green, text:"WIN!"));
                isFinished = true;
                pressAnyKeyToExit();
                break;
         }
      }
   }
    func sleep(second:Int){
        system("ping 127.0.0.1 -n \(second) > nul");
    }
    func parseInput() -> (Int,Int){
        if (currentPlayer!.type == PlayerTypes.AI){ //AI is shooting
            let (xAI,yAI) = currentPlayer!.getAIShoot();
            print (xAI,yAI);
            return (xAI,yAI+1);
        } else {
            if let response = readLine(){
                if (response.count<2 || response.count>3){
                    return (-1,0);
                }
                let xChar:String = String(response.prefix(1));

                let startIndex = String.Index(utf16Offset: 1, in: response);
                let yChar:Int? = Int(String(response[startIndex...]));
                
                if (!map_latters.contains(xChar.lowercased())){
                    return (-1,0);
                }
                
                if (yChar==nil || yChar!<=0 || yChar!>10){
                    return (-1,0);
                }
                return (map_latters.firstIndex(of: xChar.lowercased())!,yChar!);
            }
        }
        return (-1,0);
    }
}