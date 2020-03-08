local Lplus = require("Lplus")
local ServerInterface = Lplus.Class("ServerInterface")
local ServerModule = require("Main.Server.ServerModule")
local ServerLevelData = require("Main.Server.data.ServerLevelData")
local def = ServerInterface.define
def.static("=>", ServerLevelData).GetServerLevelInfo = function()
  return ServerModule.Instance():GetServerLevelInfo()
end
return ServerInterface.Commit()
