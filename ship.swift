class Ship {
   var size: Int;
   var x: Int;
   var y: Int;
   var hp: Int;
   var direction: Direction;
   var x_end:Int;
   var y_end:Int;

   init (s:Int, x:Int, y:Int, direction:Direction){
      self.size = s;
      self.x = x;
      self.y = y;
      self.hp = s;
      self.direction = direction;
      switch direction {
         case .up:
            self.x_end = x;
            self.y_end = y-size+1;
         case .right:
            self.x_end = x+size-1;
            self.y_end = y;
      }
   }

   func printShip(){
      print("x: \(self.x) ,y: \(self.y) ,x_end: \(self.x_end) ,y_end: \(self.y_end)");
   }
}