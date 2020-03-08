local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local CGEventPlayFx = Lplus.Class("CGEventPlayFx")
local def = CGEventPlayFx.define
local s_inst
def.static("=>", CGEventPlayFx).Instance = function()
  if not s_inst then
    s_inst = CGEventPlayFx()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local fxRes
  fxRes = dataTable.resourcePath
  if dataTable.resourceID > 0 then
    local eff = GetEffectRes(dataTable.resourceID)
    if eff then
      fxRes = eff.path
    end
  end
  local go = eventObj.gameObject
  local fx = ECFxMan.Instance():Play(fxRes, go.position, go.rotation, dataTable.time, false, -1)
  if not dramaTable.changeCameraAttach then
    fx:SetLayer(ClientDef_Layer.Player)
    fx.position = Map2DPosTo3D(fx.position.x, fx.position.y)
  end
  local ecModel = ECModel.new(0)
  ecModel.m_model = fx
  ecModel.m_bUncache = true
  dataTable.model = ecModel
  dramaTable[dataTable.id] = ecModel
  if 0 >= dataTable.time then
    eventObj:Finish()
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  if not dataTable.model then
    return
  end
  local fx = dataTable.model.m_model
  if not fx.isnil then
    ECFxMan.Instance():Stop(fx)
  end
  dataTable.model = nil
  dramaTable[dataTable.id] = nil
  dataTable.isFinished = true
end
CGEventPlayFx.Commit()
CG.RegEvent("CGLuaEventPlayFx", CGEventPlayFx.Instance())
return CGEventPlayFx
