// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import run_demo from "./demo";
import $ from "jquery"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

 import socket from "./socket"

 function start()
 {
 	let root = document.getElementById('root');
 	if(root)
 	{
      //console.log(sessionStorage.getItem(player_name));
   		let channel = socket.channel("game:" + sessionStorage.getItem("id"), {});
   		run_demo(root, channel, sessionStorage.getItem(name));

   	}
   	if(document.getElementById('index-page'))
   	{
      $(".btn").click(start_click)
   		//  $('.btn').click(() => {
   		//  	sessionStorage.setItem(name, $('#game-input').val())
     	// });
   	}
 }

 function start_click(ev)
 {
   let btn = $(ev.target);
   let id = btn.data('id');
   sessionStorage.setItem("id", id)
   $('.game-input').each( (_, bb) => {
     if (id == $(bb).data('id')) {
       sessionStorage.setItem(name, $(bb).val())
     }
   });
 }

 // Use jQuery to delay until page loaded.
 $(start());
