local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGLuaEventControlInGameObj = Lplus.Class("CGLuaEventControlInGameObj")
local def = CGLuaEventControlInGameObj.define
local s_inst
def.static("=>", CGLuaEventControlInGameObj).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventControlInGameObj()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  if CG.Instance().isInArtEditor then
    eventObj:Finish()
    return
  end
  local action = dataTable.action
  local object = dataTable.object
  if action == 1 then
    if object == 0 then
      local hostPlayer = ECGame.Instance().m_HostPlayer
      hostPlayer:SetCullingVisible(false, true)
      hostPlayer:EnablePate(false)
    end
  elseif action == 0 and object == 0 then
    local hostPlayer = ECGame.Instance().m_HostPlayer
    hostPlayer:SetCullingVisible(true, true)
    hostPlayer:EnablePate(true)
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  if CG.Instance().isInArtEditor then
    return
  end
  local object = dataTable.object
  if object == 0 then
    local hostPlayer = ECGame.Instance().m_HostPlayer
    if hostPlayer then
      hostPlayer:SetCullingVisible(true, true)
      hostPlayer:EnablePate(true)
    end
  end
end
CGLuaEventControlInGameObj.Commit()
CG.RegEvent("CGLuaEventControlInGameObj", CGLuaEventControlInGameObj.Instance())
return CGLuaEventControlInGameObj
