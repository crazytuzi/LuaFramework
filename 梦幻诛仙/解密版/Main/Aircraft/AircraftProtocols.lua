local Lplus = require("Lplus")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local AircraftProtocols = Lplus.Class("AircraftProtocols")
local def = AircraftProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.SSyncAircraftInfo", AircraftProtocols.OnSSyncAircraftInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.SAircraftNormalRes", AircraftProtocols.OnSAircraftNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.SPutOnAircraftSuccess", AircraftProtocols.OnSPutOnAircraftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.STakeOffAircraftSuccess", AircraftProtocols.OnSTakeOffAircraftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.SDyeAircraftSuccess", AircraftProtocols.OnSDyeAircraftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.aircraft.SUseAircraftItemSuccess", AircraftProtocols.OnSUseAircraftItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SPacketInChatInfo", AircraftProtocols.OnSPacketInChatInfo)
end
def.static("table").OnSSyncAircraftInfo = function(p)
  warn("[AircraftProtocols:OnSSyncAircraftInfo] On SSyncAircraftInfo, p.current_aircraft_cfg_id:", p.current_aircraft_cfg_id)
  if p.own_aircraft_map then
    for aircraftId, info in pairs(p.own_aircraft_map) do
      AircraftData.Instance():AddAircraft(aircraftId, info.dye_color_id, false)
    end
  end
  AircraftData.Instance():SetCurrentAircraft(p.current_aircraft_cfg_id, false)
  Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_INFO_CHANGE, nil)
end
def.static("table").OnSAircraftNormalRes = function(p)
  warn("[AircraftProtocols:OnSAircraftNormalRes] On SAircraftNormalRes! p.ret:", p.ret)
  local errString = textRes.Aircraft.SAircraftNormalRes[p.ret]
  if errString then
    Toast(errString)
  end
end
def.static("number").SendCPutOnAircraft = function(cfgId)
  warn("[AircraftProtocols:SendCRecallFriendReq] Send CPutOnAircraft:", cfgId)
  local p = require("netio.protocol.mzm.gsp.aircraft.CPutOnAircraft").new(cfgId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPutOnAircraftSuccess = function(p)
  warn("[AircraftProtocols:OnSPutOnAircraftSuccess] On SPutOnAircraftSuccess:", p.aircraft_cfg_id)
  AircraftData.Instance():SetCurrentAircraft(p.aircraft_cfg_id, true)
end
def.static().SendCTakeOffAircraft = function()
  warn("[AircraftProtocols:SendCTakeOffAircraft] Send CTakeOffAircraft.")
  local p = require("netio.protocol.mzm.gsp.aircraft.CTakeOffAircraft").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSTakeOffAircraftSuccess = function(p)
  warn("[AircraftProtocols:OnSTakeOffAircraftSuccess] On STakeOffAircraftSuccess.")
  AircraftData.Instance():SetCurrentAircraft(0, true)
end
def.static("number", "number", "number", "number", "userdata").SendCDyeAircraft = function(aircraftId, colorId, useYBFlag, needYB, haveYB)
  warn("[AircraftProtocols:SendCDyeAircraft] Send CDyeAircraft:", aircraftId, colorId, useYBFlag, needYB, haveYB)
  local p = require("netio.protocol.mzm.gsp.aircraft.CDyeAircraft").new(aircraftId, colorId, useYBFlag, needYB, haveYB)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSDyeAircraftSuccess = function(p)
  warn("[AircraftProtocols:OnSDyeAircraftSuccess] On SDyeAircraftSuccess:", p.aircraft_cfg_id, p.dye_color_id)
  AircraftData.Instance():DyeAircraft(p.aircraft_cfg_id, p.dye_color_id)
  Toast(textRes.Aircraft.AIRCRAFT_DYE_SUCC)
end
def.static("userdata").SendCUseAircraftItem = function(uuid)
  warn("[AircraftProtocols:SendCUseAircraftItem] Send CUseAircraftItem:", uuid and Int64.tostring(uuid))
  local p = require("netio.protocol.mzm.gsp.aircraft.CUseAircraftItem").new(uuid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSUseAircraftItemSuccess = function(p)
  warn("[AircraftProtocols:OnSUseAircraftItemSuccess] On SUseAircraftItemSuccess:", p.add_aircraft_cfg_id)
  AircraftData.Instance():AddAircraft(p.add_aircraft_cfg_id, 0, true)
  local AircraftGetPanel = require("Main.Aircraft.ui.AircraftGetPanel")
  AircraftGetPanel.ShowPanel(p.add_aircraft_cfg_id)
end
def.static("userdata", "number").SendCPacketInChat = function(roleId, aircraftId)
  warn("[AircraftProtocols:SendCPacketInChat] Send CPacketInChat:", roleId and Int64.tostring(roleId), aircraftId)
  local packInfo = require("netio.protocol.mzm.gsp.chat.PacketInfo").new(Int64.new(aircraftId))
  local CPacketInChat = require("netio.protocol.mzm.gsp.chat.CPacketInChat").new(roleId, ChatConsts.CONTENT_PACKET_AIRCRAFT, packInfo)
  gmodule.network.sendProtocol(CPacketInChat)
end
def.static("table").OnSPacketInChatInfo = function(p)
  warn("[AircraftProtocols:OnSPacketInChatInfo] On SPacketInChatInfo.")
  if p.packettype == ChatConsts.CONTENT_PACKET_AIRCRAFT then
    local AircraftDataInfo = require("netio.protocol.mzm.gsp.aircraft.AircraftDataInfo")
    local aircraftData = UnmarshalBean(AircraftDataInfo, p.checkInfo)
    if aircraftData then
      local AircraftInfo = require("Main.Aircraft.data.AircraftInfo")
      local aircraftInfo = AircraftInfo.New(aircraftData.aircraft_cfg_id, aircraftData.dye_color_id)
      require("Main.Aircraft.ui.AircraftSharePanel").ShowPanel(aircraftInfo)
    end
  end
end
AircraftProtocols.Commit()
return AircraftProtocols
