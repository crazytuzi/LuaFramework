local Lplus = require("Lplus")
local ElementData = require("Data.ElementData")
local Expdef = require("Data.Expdef")
local Exptypes = require("Data.Exptypes")
local TransportHelper = Lplus.Class("TransportHelper")
do
  local def = TransportHelper.define
  def.static("number", "number", "=>", "dynamic", "number", "number").GetTransmitServiceTarget = function(npcTid, iOption)
    local npcEss = ElementData.getEssence(npcTid)
    if not npcEss then
      return nil, 0, 0
    end
    local serviceEss = ElementData.getEssence(npcEss.id_transmit_service)
    if not serviceEss then
      return nil, 0, 0
    end
    local option = serviceEss.targets[iOption]
    if option then
      if option.trans_condition == Expdef.TRANSMIT_CONDITION_ENUM.TRANSCONDITION_BETWEENWORLD then
        return option.id_scene, option.x, option.z
      elseif option.trans_condition == Expdef.TRANSMIT_CONDITION_ENUM.TRANSCONDITION_JUMPTO_OTHER_COUNTRY then
        return "other_country", option.x, option.z
      end
    end
    return nil, 0, 0
  end
  def.static("number", "=>", "dynamic", "number", "number").GetTransmitBoxTarget = function(transBoxTid)
    local transBoxEss = ElementData.getEssence(transBoxTid)
    if not transBoxEss then
      return nil, 0, 0
    end
    if transBoxEss.trans_condition == Expdef.TRANSMIT_CONDITION_ENUM.TRANSCONDITION_BETWEENWORLD then
      return transBoxEss.target_scene, transBoxEss.target_pos_x, transBoxEss.target_pos_z
    elseif transBoxEss.trans_condition == Expdef.TRANSMIT_CONDITION_ENUM.TRANSCONDITION_JUMPTO_OTHER_COUNTRY then
      return "other_country", transBoxEss.target_pos_x, transBoxEss.target_pos_z
    else
      return nil, 0, 0
    end
  end
  def.static("number", "=>", "string").GetTransportType = function(tid)
    local transEss, dataType = ElementData.getEssence(tid)
    if dataType == Exptypes.DATA_TYPE.DT_NPC_ESSENCE then
      return "transmit_npc"
    elseif dataType == Exptypes.DATA_TYPE.DT_TRANSMITBOX_ESSENCE then
      return "transmit_box"
    else
      return "invalid"
    end
  end
  def.static("number", "=>", "table").GetNPCTransmitService = function(npcTid)
    local npcEss = ElementData.getEssence(npcTid)
    if not npcEss then
      return nil
    end
    local serviceEss = ElementData.getEssence(npcEss.id_transmit_service)
    if not serviceEss then
      return nil
    end
    return serviceEss
  end
  local NPC_SERVICE_LIMIT_MASK = Expdef.NPC_SERVICE_LIMIT_MASK
  def.static("table", "table", "number", "=>", "function").MakeTransmitServiceValidator = function(npcEss, serviceEss, iOption)
    return function()
      local option = serviceEss.targets[iOption]
      local ECGame = require("Main.ECGame")
      local host = ECGame.Instance().m_HostPlayer
      local required_level = option.required_level
      if required_level ~= 0 and required_level > host.InfoData.Lv then
        return false
      end
      local bNationOK = false
      if not bNationOK and bit.band(npcEss.service_limit, NPC_SERVICE_LIMIT_MASK.NPC_SERVICE_LIMIT_ALL) ~= 0 then
        bNationOK = true
      end
      if not bNationOK and bit.band(npcEss.service_limit, NPC_SERVICE_LIMIT_MASK.NPC_SERVICE_LIMIT_SAME_NATION) ~= 0 and LuaTaskInterface.GetPlayerNation() == LuaTaskInterface.GetCurrentSceneNation() then
        bNationOK = true
      end
      if not bNationOK then
        return false
      end
      if host._dartinfo and host._dartinfo.ondart then
        return false
      end
      return true
    end
  end
  def.static("table", "=>", "function").MakeTransmitBoxValidator = function(ess)
    return function()
      local ECGame = require("Main.ECGame")
      local host = ECGame.Instance().m_HostPlayer
      local required_level = ess.level_req
      if required_level ~= 0 and required_level > host.InfoData.Lv then
        return false
      end
      return true
    end
  end
end
return TransportHelper.Commit()
