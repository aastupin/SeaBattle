#!/usr/bin/env xcrun swift
let arguments = CommandLine.arguments;
var player1type = PlayerTypes.human;
var player1name:String = "Player";
if (arguments.count > 1 && arguments[1]=="-AI"){
    player1type = PlayerTypes.AI;
    player1name = "AI2";
}
var game_controller = GameController(type_player1:player1type,type_player2:PlayerTypes.AI, name1:player1name, name2:"AI1");
game_controller.startGame();