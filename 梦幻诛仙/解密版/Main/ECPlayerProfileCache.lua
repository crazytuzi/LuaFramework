local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayerProfileCache = Lplus.Class("ECPlayerProfileCache")
local def = ECPlayerProfileCache.define
local l_instance
def.static("=>", ECPlayerProfileCache).Instance = function()
  if l_instance == nil then
    l_instance = ECPlayerProfileCache()
  end
  return l_instance
end
def.method("string").SearchAllInfo = function(self, id)
  local pb_helper = require("PB.pb_helper")
  local m = pb_helper.NewCmd("npt_get_player_profile")
  m.roleid = id
  m.get_profile_mask = ECPlayerProfileCache.GET_PROFILE_MASK.GET_ALL
  pb_helper.Send(m)
end
def.method("string").SearchSnsInfo = function(self, id)
  local pb_helper = require("PB.pb_helper")
  local m = pb_helper.NewCmd("npt_get_player_profile")
  m.roleid = id
  m.get_profile_mask = ECPlayerProfileCache.GET_PROFILE_MASK.GET_SNS
  pb_helper.Send(m)
end
def.method("string").SearchEquipInfo = function(self, id)
  local pb_helper = require("PB.pb_helper")
  local m = pb_helper.NewCmd("npt_get_player_profile")
  m.roleid = id
  m.get_profile_mask = ECPlayerProfileCache.GET_PROFILE_MASK.GET_EQUIP
  pb_helper.Send(m)
end
def.method("string").SearchPropertyInfo = function(self, id)
  local pb_helper = require("PB.pb_helper")
  local m = pb_helper.NewCmd("npt_get_player_profile")
  m.roleid = id
  m.get_profile_mask = ECPlayerProfileCache.GET_PROFILE_MASK.GET_PROPERTY
  pb_helper.Send(m)
end
def.method("string", "number").SearchPlayerInfo = function(self, id, mask)
  local pb_helper = require("PB.pb_helper")
  local m = pb_helper.NewCmd("npt_get_player_profile")
  m.roleid = id
  m.get_profile_mask = mask
  pb_helper.Send(m)
end
def.method("table").SearchFightCapacity = function(self, idList)
  if #idList > 0 then
    local pb_helper = require("PB.pb_helper")
    local net_common = require("PB.net_common")
    local gp_get_list_info = net_common.gp_get_list_info
    local msg = gp_get_list_info()
    for i = 1, #idList do
      msg.player_list:append(idList[i])
    end
    pb_helper.Send(msg)
  end
end
local msg2SnsInfo = function(msg)
  local snsinfo = msg.snsinfo
  local SnsInfo = require("Protocol.RPCData.SnsInfo")
  local oct = Octets.Octets()
  oct:replace(snsinfo)
  local os = OctetsStream.OctetsStream2(oct)
  local p = SnsInfo()
  p:Unmarshal(os)
  return p
end
local msg2Equipment = function(msg)
  local equipments = msg.equipments
  local RpcDataVector = require("Protocol.RPCData.RpcDataVector")
  local GRoleInventory = require("Protocol.RPCData.GRoleInventory")
  local equipData = RpcDataVector.new(GRoleInventory)()
  local oct = Octets.Octets()
  oct:replace(equipments)
  local os = OctetsStream.wrap(oct)
  equipData:Unmarshal(os)
  local EquipData = {}
  local ECInventory = require("Inventory.ECInventory")
  for i = 1, #equipData.m_vec do
    local data = equipData.m_vec[i].data:getBytes()
    local item = ECInventory.CreateItem(equipData.m_vec[i].id, equipData.m_vec[i].expire_date, 0, 1)
    item:SetItemInfo(data, string.len(data))
    EquipData[equipData.m_vec[i].pos] = item
  end
  return EquipData
end
def.method("table", "number").Respond = function(self, msg, mask)
  local id = msg.roleid
  self.mPlayerInfo[id] = self.mPlayerInfo[id] or {}
  if mask == ECPlayerProfileCache.GET_PROFILE_MASK.GET_ALL then
    self.mPlayerInfo[id].snsinfo = msg2SnsInfo(msg)
    self.mPlayerInfo[id].property = msg.property
    self.mPlayerInfo[id].equipments = msg2Equipment(msg)
    self.mPlayerInfo[id].others = msg.others
  elseif mask == ECPlayerProfileCache.GET_PROFILE_MASK.GET_SNS then
    self.mPlayerInfo[id].snsinfo = msg2SnsInfo(msg)
  elseif mask == ECPlayerProfileCache.GET_PROFILE_MASK.GET_EQUIP then
    self.mPlayerInfo[id].equipments = msg2Equipment(msg)
  elseif mask == ECPlayerProfileCache.GET_PROFILE_MASK.GET_PROPERTY then
    self.mPlayerInfo[id].others = msg.others
  end
end
def.method("table").RespondFightCapacity = function(self, msg)
  for i = 1, #msg.new_id do
    self.mFightCapacity[msg.new_id[i]] = msg.fightcapacity[i]
  end
end
def.method("string", "=>", "table").TryGetSnsInfo = function(self, id)
  if not self.mPlayerInfo[id] then
    return nil
  else
    return self.mPlayerInfo[id].snsinfo
  end
end
def.method("string", "=>", "table").TryGetProperty = function(self, id)
  if not self.mPlayerInfo[id] then
    return nil
  else
    return self.mPlayerInfo[id].property
  end
end
def.method("string", "=>", "table").TryGetEquipments = function(self, id)
  if not self.mPlayerInfo[id] then
    return nil
  else
    return self.mPlayerInfo[id].equipments
  end
end
def.method("string", "=>", "table").TryGetOthers = function(self, id)
  if not self.mPlayerInfo[id] then
    return nil
  else
    return self.mPlayerInfo[id].others
  end
end
def.method("number", "=>", "number").TryGetFightCapacity = function(self, new_id)
  return self.mFightCapacity[new_id] or 0
end
def.method("string", "table").UpdateBaseInfo = function(self, id, info)
  self.mPlayerInfo[id] = self.mPlayerInfo[id] or {}
  self.mPlayerInfo[id].baseinfo = info
end
def.method("string", "=>", "table").TryGetBaseInfo = function(self, id)
  if not self.mPlayerInfo[id] then
    return nil
  else
    return self.mPlayerInfo[id].baseinfo
  end
end
def.method("string", "=>", "table").TryGetGenderAndProfInfo = function(self, id)
  local baseinfo = self:TryGetBaseInfo(id)
  local snsinfo = self:TryGetSnsInfo(id)
  if baseinfo and snsinfo then
    local info = {}
    info.prof = snsinfo.profile.profession
    info.gender = snsinfo.gender
    info.level = snsinfo.profile.level
    info.vip = baseinfo.vip
    return info
  elseif baseinfo then
    local info = baseinfo
    info.level = 0
    return info
  elseif snsinfo then
    local info = {}
    info.gender = snsinfo.gender
    info.prof = snsinfo.profile.profession
    info.level = snsinfo.profile.level
    info.vip = 0
    return info
  else
    return nil
  end
end
def.field("table").mFightCapacity = function()
  return {}
end
def.field("table").mPlayerInfo = function()
  return {}
end
def.const("table").GET_PROFILE_MASK = {
  GET_ALL = 0,
  GET_SNS = 1,
  GET_EQUIP = 2,
  GET_PROPERTY = 4
}
ECPlayerProfileCache.Commit()
return ECPlayerProfileCache
