local Lplus = require("Lplus")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftProtocols = require("Main.Aircraft.AircraftProtocols")
local AircraftInterface = Lplus.Class("AircraftInterface")
local def = AircraftInterface.define
def.static("=>", "number").GetCurAircraftItemId = function()
  local aircraftCfg = AircraftInterface.GetCurAircraftCfg()
  if aircraftCfg then
    return aircraftCfg.itemId
  else
    return 0
  end
end
def.static("number", "=>", "number").GetAircraftItemId = function(aircraftId)
  local aircraftCfg = AircraftData.Instance():GetAircraftCfg(aircraftId)
  if aircraftCfg then
    return aircraftCfg.itemId
  else
    return 0
  end
end
def.static("=>", "number").GetCurAircraftId = function()
  return AircraftData.Instance():GetCurrentAircraftId()
end
def.static("=>", "boolean").IsMountingAircraft = function()
  return AircraftData.Instance():GetCurrentAircraftId() > 0
end
def.static("=>", "table").GetCurAircraftCfg = function()
  return AircraftData.Instance():GetAircraftCfg(AircraftInterface.GetCurAircraftId())
end
def.static("=>", "number").GetCurAircraftColorId = function()
  local curAircraftInfo = AircraftData.Instance():GetCurrentAircraftInfo()
  if curAircraftInfo then
    return curAircraftInfo.colorId
  else
    return 0
  end
end
def.static("userdata", "number").CheckChatAircraft = function(roleId, aircraftId)
  if Int64.eq(roleId, _G.GetMyRoleID()) then
    local aircraftInfo = AircraftData.Instance():GetAircraftInfo(aircraftId)
    require("Main.Aircraft.ui.AircraftSharePanel").ShowPanel(aircraftInfo)
  else
    AircraftProtocols.SendCPacketInChat(roleId, aircraftId)
  end
end
def.static("number").OpenAircraftPanel = function(aircraftId)
  local FashionPanel = require("Main.Fashion.ui.FashionPanel")
  FashionPanel.Instance():ShowPanelNodeWithCfgId(FashionPanel.NodeId.Aircraft, aircraftId)
end
def.static("=>", "table").GetAllAircraftItemCfg = function()
  return AircraftData.Instance():_GetItemCfgs()
end
AircraftInterface.Commit()
return AircraftInterface
