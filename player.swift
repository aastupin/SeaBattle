class Player {
   var map_size: Int;
   var type: PlayerTypes;
   var map: [[MapField]] = [];
   var ships: [Ship] = [];
   var ship_types: [Int] = [];
   var showSheeps: Bool = false;
   var enemy: Player?;
   var name:String;
   var ships_alive_count:Int;
   var recomendationsForAI:[[Int]] = [];

   init (m_size:Int, type: PlayerTypes, ship_types: [Int], name:String){
      self.map_size = m_size;
      self.type = type;
      self.map = Array(repeating: Array(repeating: MapField(elem: MapSymbol.free, ship_index: -1, status: Cell.free), count: m_size), count: m_size);
      self.recomendationsForAI = Array(repeating: Array(repeating: 1, count: m_size), count: m_size);
      self.ship_types = ship_types;
      if (type == PlayerTypes.human){
         showSheeps = true;
      }
      self.enemy = nil;
      self.name = name;
      self.ships_alive_count = ship_types.count;
      placeShips();
   }

   func setEnemy(enemy:Player){
      self.enemy = enemy;
   }

   func placeShips(){      
      print ("generating ships for player: \(name)...");
      let maxAttempts:Int = 50;
      var allSheepsPlaced = false;
      while (allSheepsPlaced == false){
         for size in ship_types {
            var attempts:Int = 0;
            var isFit:Bool = false;
            repeat {
               attempts+=1;
               var picked_coordinates:[String] = [];
               var isNewCoordinates = false;

               var x_random:Int, y_random:Int, direction_random:Direction;
               repeat{
                  x_random = Int.random(in: 0...map_size-1);
                  y_random = Int.random(in: 0...map_size-1);
                  direction_random = Direction.allCases.randomElement()!;                  
                  let coords:String = String(x_random)+String(y_random)+String(direction_random.rawValue);
                  if (!picked_coordinates.contains(coords)){
                     isNewCoordinates = true;
                     picked_coordinates.append(coords);
                  }
               } while (isNewCoordinates==false);
               
               let new_ship = Ship (s:size, x:x_random, y:y_random, direction:direction_random);
               isFit = shipIsFitted(ship:new_ship);
               if (isFit){
                  saveShip(ship:new_ship);
               }
               //new_ship.printShip();
               //print (isFit);
               
            } while isFit==false && attempts < maxAttempts;
            if (attempts == maxAttempts){//bad random, we need a new attemp to place ships
               break;
            }
         }
         if (ships.count<ship_types.count){//we did not place all ships
            removeShips();
         } else {
            allSheepsPlaced = true;
         }
      }
    }
    func getAIShoot()->(Int,Int){
      return getMaxElementIndeces(arr:recomendationsForAI);         
    }
    func updateRecomendations(status:ShotStatus, x:Int, y:Int){  
      recomendationsForAI[x][y] = 0;     
      if (self.type == PlayerTypes.AI){
         if (status == ShotStatus.kill){
            if (fieldInMap(x:x-1,y:y)) { recomendationsForAI[x-1][y] = 0; }
            if (fieldInMap(x:x+1,y:y)) { recomendationsForAI[x+1][y] = 0; }
            if (fieldInMap(x:x,y:y-1)) { recomendationsForAI[x][y-1] = 0; }
            if (fieldInMap(x:x,y:y+1)) { recomendationsForAI[x][y+1] = 0; }

            
            if (fieldInMap(x:x-1,y:y-1)) { recomendationsForAI[x-1][y-1] = 0; }
            if (fieldInMap(x:x-1,y:y+1)) { recomendationsForAI[x-1][y+1] = 0; }
            if (fieldInMap(x:x+1,y:y-1)) { recomendationsForAI[x+1][y-1] = 0; }
            if (fieldInMap(x:x+1,y:y+1)) { recomendationsForAI[x+1][y+1] = 0; }  

            for i in 0...map_size-1 {
               for j in 0...map_size-1 {
                  if (recomendationsForAI[i][j] > 1){
                     recomendationsForAI[i][j] = 0;
                  }
               }
            }
         } else
         if (status == ShotStatus.hit){            
            if (fieldInMap(x:x-1,y:y) && recomendationsForAI[x-1][y] != 0) { recomendationsForAI[x-1][y] += 1; }
            if (fieldInMap(x:x+1,y:y) && recomendationsForAI[x+1][y] != 0) { recomendationsForAI[x+1][y] += 1; }
            if (fieldInMap(x:x,y:y-1) && recomendationsForAI[x][y-1] != 0) { recomendationsForAI[x][y-1] += 1; }
            if (fieldInMap(x:x,y:y+1) && recomendationsForAI[x][y+1] != 0) { recomendationsForAI[x][y+1] += 1; }

            if (fieldInMap(x:x-1,y:y-1)) { recomendationsForAI[x-1][y-1] = 0; }
            if (fieldInMap(x:x-1,y:y+1)) { recomendationsForAI[x-1][y+1] = 0; }
            if (fieldInMap(x:x+1,y:y-1)) { recomendationsForAI[x+1][y-1] = 0; }
            if (fieldInMap(x:x+1,y:y+1)) { recomendationsForAI[x+1][y+1] = 0; }            
         }
      }
    }
    func shipIsFitted(ship: Ship)->Bool{
      //check borders
      if (ship.x_end>map_size-1 || ship.y_end<0){
         return false;
      }

      for i in max(ship.x-1,0)...min(ship.x_end+1,map_size-1) {
         for j in max(ship.y_end-1,0)...min(ship.y+1,map_size-1) {
            if ([Cell.ship, Cell.near_ship].contains(map[i][j].status)){
               return false;            
            }
         }
      }

      return true;
   }

   func saveShip(ship:Ship){
      ships.append(ship);
      let current_ship_index = ships.count-1;
      for i in max(ship.x-1,0)...min(ship.x_end+1,map_size-1) {
         for j in max(ship.y_end-1,0)...min(ship.y+1,map_size-1) {
            map[i][j]=MapField(elem: MapSymbol.free, ship_index:current_ship_index, status:Cell.near_ship);
         }
      }
      for i in ship.x...ship.x_end {
         for j in ship.y_end...ship.y {
            map[i][j]=MapField(elem: MapSymbol.ship, ship_index:current_ship_index, status:Cell.ship);
         }
      }
   }

   func removeShips(){
      ships.removeAll();
      map = Array(repeating: Array(repeating: MapField(elem: MapSymbol.free, ship_index: -1, status: Cell.free), count: map_size), count: map_size);
   }

   func doShot(x:Int, y:Int)->(ShotStatus){      
      switch self.enemy!.map[x][y].status {
         case .free, .near_ship:
            self.enemy!.map[x][y].status = Cell.shot;
            self.enemy!.map[x][y].elem = MapSymbol.shot;
            updateRecomendations(status:ShotStatus.miss, x:x, y:y);
            return ShotStatus.miss;
         case .ship:
            let shotRes = self.enemy!.hitByEnemy(x:x,y:y);
            updateRecomendations(status:shotRes, x:x, y:y);
            return shotRes;
         case .shot, .killed:
            updateRecomendations(status:ShotStatus.miss, x:x, y:y);
            return ShotStatus.again;
      }
   }

   func hitByEnemy(x:Int, y:Int)->(ShotStatus){
      let ship_index = map[x][y].ship_index;
      ships[ship_index].hp -= 1;
      map[x][y].elem = MapSymbol.killed;
      map[x][y].status = Cell.killed;
      if (ships[ship_index].hp==0){ //killed
         for i in max(ships[ship_index].x-1,0)...min(ships[ship_index].x_end+1,map_size-1) {
            for j in max(ships[ship_index].y_end-1,0)...min(ships[ship_index].y+1,map_size-1) {
               if (map[i][j].status == Cell.near_ship){
                  map[i][j].elem = MapSymbol.shot;
                  map[i][j].status = Cell.shot;
               }
            }
         }
         ships_alive_count -= 1;
         return ShotStatus.kill;
      }
      return ShotStatus.hit;
   } 

   func getMaxElementIndeces(arr:[[Int]])->(Int,Int){    
      let flatArr = arr.flatMap{$0};
      let maxValue = flatArr.max()!;
      var availiableHits:[Int] = [];
      for (index, value) in flatArr.enumerated() {
         if (value == maxValue){
            availiableHits.append(index);
         }
      } 
      //let index = flatArr.firstIndex(of: maxValue);
      let index = availiableHits.randomElement();
      return (index! % map_size, Int(index!/map_size));
   }
   func fieldInMap(x:Int,y:Int)->Bool{
      if (x<0 || x>=map_size || y<0 || y>=map_size){
         return false;
      }
      return true;
   }
}