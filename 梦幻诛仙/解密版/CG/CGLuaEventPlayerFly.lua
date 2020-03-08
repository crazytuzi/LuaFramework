local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPlayer = require("Model.ECPlayer")
local ECGame = require("Main.ECGame")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local CGLuaEventPlayerFly = Lplus.Class("CGLuaEventPlayerFly")
local def = CGLuaEventPlayerFly.define
local s_inst
def.static("=>", CGLuaEventPlayerFly).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventPlayerFly()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecPlayer = dramaTable[dataTable.id]
  local isMe = true
  if dataTable.camType == 1 then
    isMe = false
  end
  ECGame.Instance().m_Fly3DCamComponent.orthographicSize = CG.Instance().srcFlyOrthographicSize / dataTable.scale
  if dataTable.flyType == 0 then
    ecPlayer:cgFlyUp(isMe, dataTable.riderResId)
  elseif dataTable.flyType == 1 then
    ecPlayer:cgFlyDown(isMe, dataTable.riderResId)
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  local ecPlayer = dramaTable[dataTable.id]
  if ecPlayer ~= nil then
    ecPlayer:Destroy()
  end
  ECGame.Instance().m_Fly3DCamComponent.orthographicSize = CG.Instance().srcFlyOrthographicSize
  require("Main.ECGame").Instance():ResetGroundLayer()
  require("Main.Fly.FlyModule").Instance():StopCloud("cg")
  ECGUIMan.Instance().m_hudCamera.orthographicSize = ECGame.Instance().m_2DWorldCam.orthographicSize
  warn("fly is over...")
end
CGLuaEventPlayerFly.Commit()
CG.RegEvent("CGLuaEventPlayerFly", CGLuaEventPlayerFly.Instance())
return CGLuaEventPlayerFly
