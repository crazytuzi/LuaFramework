local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPlayer = require("Model.ECPlayer")
local ECGame = require("Main.ECGame")
local EC = require("Types.Vector3")
local CGLuaEventPlayerAutoRotate = Lplus.Class("CGLuaEventPlayerAutoRotate")
local def = CGLuaEventPlayerAutoRotate.define
local s_inst
def.static("=>", CGLuaEventPlayerAutoRotate).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventPlayerAutoRotate()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecPlayer = dramaTable[dataTable.id]
  local tw = ecPlayer.m_model:GetComponent("TweenRotation")
  if tw == nil then
    tw = ecPlayer.m_model:AddComponent("TweenRotation")
  end
  tw.value = Quaternion.Euler(EC.Vector3.new(0, dataTable.FromfAngle, 0))
  tw:SetStartToCurrentValue()
  TweenRotation.Begin(ecPlayer.m_model, dataTable.useTime, Quaternion.Euler(EC.Vector3.new(0, dataTable.TofAngle, 0)))
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
end
CGLuaEventPlayerAutoRotate.Commit()
CG.RegEvent("CGLuaEventPlayerAutoRotate", CGLuaEventPlayerAutoRotate.Instance())
return CGLuaEventPlayerAutoRotate
