local Lplus = require("Lplus")
local AvatarInterface = Lplus.Class("AvatarInterface")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local ItemModule = require("Main.Item.ItemModule")
local def = AvatarInterface.define
local instance
def.field("number").curAvatarId = 0
def.field("number").curAttrAvatarId = 0
def.field("table").activeAvatarList = nil
def.field("table").newAvatarList = nil
local defaultAvatarConst = constant.CFactionDefaultAvatarConsts
def.const("table").DefaultAvatarId = {
  [OccupationEnum.GUI_WANG_ZONG] = {
    [SGenderEnum.MALE] = defaultAvatarConst.GuiwangMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.GuiwangFemaleDefaultAvatarId
  },
  [OccupationEnum.QIN_GYUN_MEN] = {
    [SGenderEnum.MALE] = defaultAvatarConst.QingyunMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.QingyunFemaleDefaultAvatarId
  },
  [OccupationEnum.TIAN_YIN_SI] = {
    [SGenderEnum.MALE] = defaultAvatarConst.TianyinMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.TianyinFemaleDefaultAvatarId
  },
  [OccupationEnum.FEN_XIANG_GU] = {
    [SGenderEnum.MALE] = defaultAvatarConst.FenxiangMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.FenxiangFemaleDefaultAvatarId
  },
  [OccupationEnum.HE_HUAN_PAI] = {
    [SGenderEnum.MALE] = defaultAvatarConst.HehuanMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.HehuanFemaleDefaultAvatarId
  },
  [OccupationEnum.SHENG_WU_JIAO] = {
    [SGenderEnum.MALE] = defaultAvatarConst.ShengwuMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.ShengwuFemaleDefaultAvatarId
  },
  [OccupationEnum.CANG_YU_GE] = {
    [SGenderEnum.MALE] = defaultAvatarConst.CangyuMaleDefaultAvatarId,
    [SGenderEnum.FEMALE] = defaultAvatarConst.CangyuFemaleDefaultAvatarId
  }
}
def.static("=>", AvatarInterface).Instance = function()
  if instance == nil then
    instance = AvatarInterface()
  end
  return instance
end
def.method().Reset = function(self)
  self.curAvatarId = 0
  self.curAttrAvatarId = 0
  self.activeAvatarList = {}
  self.newAvatarList = nil
end
def.static("number", "=>", "table").GetAvatarCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AVATAR_CFG, id)
  if record == nil then
    warn("!!!!!!!GetAvatarCfg is nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.name = record:GetStringValue("name")
  cfg.genderLimit = record:GetIntValue("genderLimit")
  cfg.factionLimit = record:GetIntValue("factionLimit")
  cfg.avatarId = record:GetIntValue("avatarId")
  cfg.description = record:GetStringValue("description")
  cfg.validPeriod = record:GetIntValue("validPeriod")
  cfg.unlockItemId = record:GetIntValue("unlockItemId")
  cfg.display = record:GetIntValue("display") ~= 0
  cfg.sort = record:GetIntValue("sort")
  cfg.attrs = {}
  local rec2 = record:GetStructValue("propertieStruct")
  local count = rec2:GetVectorSize("propertyList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("propertyList", i - 1)
    local propType = rec3:GetIntValue("propertyType")
    if propType > 0 then
      local value = rec3:GetIntValue("propertyValue")
      cfg.attrs[propType] = value
    end
  end
  return cfg
end
def.static("=>", "table").GetAllAvatarCfgList = function()
  local cfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AVATAR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local myProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local myOccupation = 0
  if myProp then
    myOccupation = myProp.occupation
  end
  local myGender = myProp.gender
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    local cfg = AvatarInterface.GetAvatarCfgById(id)
    if cfg and cfg.display and (cfg.factionLimit == 0 or cfg.factionLimit == myOccupation) and (cfg.genderLimit == 0 or cfg.genderLimit == myGender) then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local function comp(cfg1, cfg2)
    local unlock1 = instance:isUnlockAvatarId(cfg1.id)
    local unlock2 = instance:isUnlockAvatarId(cfg2.id)
    if unlock1 and unlock2 or not unlock1 and not unlock2 then
      return cfg1.sort < cfg2.sort
    elseif unlock1 then
      return true
    else
      return false
    end
  end
  table.sort(cfgList, comp)
  return cfgList
end
def.static("number", "=>", "table").GetAvatarUnlockCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AVATAR_UNLOCK_CFG, itemId)
  if record == nil then
    warn("!!!!!!!GetAvatarUnlockCfg is nil:", itemId)
    return nil
  end
  local cfg = {}
  cfg.itemId = itemId
  cfg.avatarId = record:GetIntValue("avatarId")
  cfg.duration = record:GetIntValue("duration")
  return cfg
end
def.static("number", "=>", "table").GetAvatar2UnlockItemCfg = function(avatarId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AVATAR_UNLOCK_ITEM_CFG, avatarId)
  if record == nil then
    warn("!!!!!!!GetAvatar2UnlockItemCfg is nil:", avatarId)
    return nil
  end
  local cfg = {}
  cfg.avatarId = avatarId
  cfg.items = {}
  local rec2 = record:GetStructValue("itemsStruct")
  local count = rec2:GetVectorSize("items")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("items", i - 1)
    local itemId = rec3:GetIntValue("itemId")
    local t = {}
    if itemId > 0 then
      t.itemId = itemId
      local duration = rec3:GetIntValue("duration")
      t.duration = duration
      table.insert(cfg.items, t)
    end
  end
  return cfg
end
def.method("number", "number", "=>", "number").getDefaultAvatarId = function(self, occupation, gender)
  local cfg = _G.GetOccupationCfg(occupation, gender)
  if cfg then
    return cfg.defaultAvatarId
  else
    warn("!!!!!!!!!not defaultAvatarId:", occupation, gender)
    return 0
  end
end
def.method("=>", "number").getCurAvatarId = function(self)
  if self.curAvatarId == 0 or not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
    return self:getSelfDefaultAvatarId()
  end
  return self.curAvatarId
end
def.method("=>", "number").getCurAvatarFrameId = function(self)
  return require("Main.Avatar.AvatarFrameMgr").Instance():getCurAvatarFrameId()
end
def.method("=>", "number").getSelfDefaultAvatarId = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp then
    return self:getDefaultAvatarId(heroProp.occupation, heroProp.gender)
  end
  return 0
end
def.method("table").addActiveAvatarId = function(self, info)
  self.activeAvatarList[info.avatar] = info
end
def.method("number").removeActiveAvatarId = function(self, id)
  self.activeAvatarList[id] = nil
end
def.method("=>", "table").getActiveAndEffectAvatarCfgList = function(self)
  local effectList = {}
  for i, v in pairs(self.activeAvatarList) do
    local avatarCfg = AvatarInterface.GetAvatarCfgById(i)
    for i, v in pairs(avatarCfg.attrs) do
      table.insert(effectList, avatarCfg)
      break
    end
  end
  return effectList
end
def.method("number").addNewAvatarId = function(self, id)
  self.newAvatarList = self.newAvatarList or {}
  self.newAvatarList[id] = id
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, nil)
end
def.method("number").removeNewAvatarId = function(self, id)
  if self.newAvatarList and self.newAvatarList[id] then
    self.newAvatarList[id] = nil
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, nil)
  end
end
def.method("number", "=>", "boolean").isNewGetAvatar = function(self, id)
  if self.newAvatarList and self.newAvatarList[id] then
    return true
  end
  return false
end
def.method("=>", "boolean").isHaveNewAvatar = function(self)
  local curLevel = 0
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    warn("!!!!!!!!getCurAvatarId heroProp is nil")
    curLevel = heroProp.level
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) and curLevel < constant.CAvatarConsts.OPEN_LEVEL then
    return false
  end
  if self.newAvatarList then
    for i, v in pairs(self.newAvatarList) do
      return true
    end
  end
  return false
end
def.method("=>", "boolean").isAvatarNotify = function(self)
  local flag = self:isHaveNewAvatar()
  if flag then
    return true
  end
  flag = require("Main.Avatar.AvatarFrameMgr").Instance():IsHaveNotifyMessage()
  if flag then
    return true
  end
  local ChatBubbleMgr = require("Main.Chat.ChatBubble.ChatBubbleMgr")
  flag = ChatBubbleMgr.IsShowRedDot()
  if flag then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").isOwnAttrAvatarId = function(self, id)
  local avatarCfg = AvatarInterface.GetAvatarCfgById(id)
  if avatarCfg then
    for i, v in pairs(avatarCfg.attrs) do
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").isUnlockAvatarId = function(self, id)
  if id == self:getSelfDefaultAvatarId() then
    return true
  end
  if self.activeAvatarList and self.activeAvatarList[id] then
    return true
  end
  return false
end
def.method("number", "=>", "table").getUnlockAvatarInfo = function(self, id)
  if self.activeAvatarList then
    return self.activeAvatarList[id]
  end
  return nil
end
def.method("number", "=>", "number").getUnlockItemIdNum = function(self, avatarId)
  local unlockItemCfg = AvatarInterface.GetAvatar2UnlockItemCfg(avatarId)
  local num = 0
  for i, v in ipairs(unlockItemCfg.items) do
    local ownNum = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, v.itemId)
    num = num + ownNum
  end
  return num
end
def.method("number", "=>", "string").getLeftTimeStr = function(self, id)
  if not self:isUnlockAvatarId(id) then
    return textRes.Avatar[11]
  end
  local avatarCfg = AvatarInterface.GetAvatarCfgById(id)
  if avatarCfg then
    local info = self.activeAvatarList[id]
    if info then
      local endTime = Int64.ToNumber(info.expire_time)
      if endTime == 0 then
        return textRes.Avatar[8]
      end
      local curTime = _G.GetServerTime()
      if endTime >= curTime then
        local leftTime = endTime - curTime
        local days = math.floor(leftTime / 86400)
        local hours = math.floor((leftTime - days * 86400) / 3600)
        if days > 0 or hours > 0 then
          return string.format(textRes.Avatar[9], days, hours)
        else
          return textRes.Avatar[10]
        end
      else
        return textRes.Avatar[10]
      end
    end
  end
  return textRes.Avatar[8]
end
return AvatarInterface.Commit()
