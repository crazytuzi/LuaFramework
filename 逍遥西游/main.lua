package.path = package.path .. ";./../launcher/?.lua;./launcher/?.lua"
print(" package.path:", package.path)
require("launcher")
require("game")
game.startup()
