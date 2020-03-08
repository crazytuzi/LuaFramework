local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPlayer = require("Model.ECPlayer")
local ECGame = require("Main.ECGame")
local EC = require("Types.Vector3")
local CGLuaEventCameraSlow = Lplus.Class("CGLuaEventCameraSlow")
local def = CGLuaEventCameraSlow.define
local s_inst
def.static("=>", CGLuaEventCameraSlow).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventCameraSlow()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecPlayer = dramaTable[dataTable.id]
  Time.timeScale = dataTable.scale
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  Time.timeScale = 1
  print("timeScale over")
end
CGLuaEventCameraSlow.Commit()
CG.RegEvent("CGLuaEventCameraSlow", CGLuaEventCameraSlow.Instance())
return CGLuaEventCameraSlow
