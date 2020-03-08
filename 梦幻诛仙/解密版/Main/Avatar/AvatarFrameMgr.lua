local Lplus = require("Lplus")
local AvatarFrameMgr = Lplus.Class("AvatarFrameMgr")
local def = AvatarFrameMgr.define
local instance
def.field("number").curAvatartFrameId = 0
def.field("table").unlockAvatarFrameInfo = nil
def.field("table").newAvatarFrame = nil
def.static("=>", AvatarFrameMgr).Instance = function()
  if instance == nil then
    instance = AvatarFrameMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSyncAvatarFrameInfo", AvatarFrameMgr.OnSSyncAvatarFrameInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SNotifyAvatarFrameExpired", AvatarFrameMgr.OnSNotifyAvatarFrameExpired)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSetAvatarFrameSuccess", AvatarFrameMgr.OnSSetAvatarFrameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSetAvatarFrameFail", AvatarFrameMgr.OnSSetAvatarFrameFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SUseAvatarFrameUnlockItemSuccess", AvatarFrameMgr.OnSUseAvatarFrameUnlockItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SUseAvatarFrameUnlockItemFail", AvatarFrameMgr.OnSUseAvatarFrameUnlockItemFail)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AvatarFrameMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:resetAvatarFrameInfo()
  end)
end
def.method().resetAvatarFrameInfo = function(self)
  self.curAvatartFrameId = 0
  self.unlockAvatarFrameInfo = nil
  self.newAvatarFrame = nil
end
def.static("table").OnSSyncAvatarFrameInfo = function(p)
  warn("------OnSSyncAvatarFrameInfo:")
  instance.curAvatartFrameId = p.current_avatar_frame_id
  local info = {}
  for i, v in ipairs(p.unlocked_avatar_frame) do
    info[v.id] = v
  end
  instance.unlockAvatarFrameInfo = info
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, nil)
end
def.static("table").OnSNotifyAvatarFrameExpired = function(p)
  instance.curAvatartFrameId = p.current_avatar_frame_id
  if instance.unlockAvatarFrameInfo then
    for i, v in ipairs(p.expired_avatar_frame_ids) do
      instance.unlockAvatarFrameInfo[v] = nil
    end
  end
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, nil)
end
def.static("table").OnSSetAvatarFrameSuccess = function(p)
  instance.curAvatartFrameId = p.avatar_frame_id
  local cfg = AvatarFrameMgr.GetAvatarFrameCfg(p.avatar_frame_id)
  Toast(string.format(textRes.Avatar[104], cfg.name))
  instance:removeNewAvatarFrameId(p.avatar_frame_id)
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, nil)
end
def.static("table").OnSSetAvatarFrameFail = function(p)
  warn("!!!!!!!!!!OnSSetAvatarFrameFail:", p.retcode)
  local str = textRes.Avatar.setFrameFrameFail[p.record]
  if str then
    Toast(str)
  end
end
def.static("table").OnSUseAvatarFrameUnlockItemSuccess = function(p)
  warn("------OnSUseAvatarFrameUnlockItemSuccess:", p.avatar_frame_id, p.is_new)
  instance.unlockAvatarFrameInfo = instance.unlockAvatarFrameInfo or {}
  local info = {
    id = p.avatar_frame_id,
    expire_time = p.expire_time
  }
  instance.unlockAvatarFrameInfo[p.avatar_frame_id] = info
  local frameCfg = AvatarFrameMgr.GetAvatarFrameCfg(p.avatar_frame_id)
  if p.is_new > 0 then
    instance.newAvatarFrame = instance.newAvatarFrame or {}
    instance.newAvatarFrame[p.avatar_frame_id] = p.avatar_frame_id
    local useTimeStr = instance:getLeftTimeStr(p.avatar_frame_id)
    Toast(string.format(textRes.Avatar[102], frameCfg.name, useTimeStr))
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, nil)
  else
    local useTimeStr = instance:getLeftTimeStr(p.avatar_frame_id)
    Toast(string.format(textRes.Avatar[103], frameCfg.name, useTimeStr))
  end
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar_Frame, nil)
  warn("--------DispatchEvent Get_New_Avatar_Frame")
end
def.static("table").OnSUseAvatarFrameUnlockItemFail = function(p)
  warn("!!!!!!!OnSUseAvatarFrameUnlockItemFail:", p.record)
  local str = textRes.Avatar.useAvatarFrameItemFail[p.record]
  if str then
    Toast(str)
  end
end
def.static("number", "=>", "table").GetAvatarFrameCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AVATAR_FRAME_CFG, id)
  if record == nil then
    warn("!!!!!!!GetAvatarFrameCfg is nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.genderLimit = record:GetIntValue("genderLimit")
  cfg.factionLimit = record:GetIntValue("factionLimit")
  cfg.avatarFrameId = record:GetIntValue("avatarFrameId")
  cfg.unlockItemId = record:GetIntValue("unlockItemId")
  cfg.description = record:GetStringValue("description")
  cfg.sort = record:GetIntValue("sort")
  cfg.display = record:GetIntValue("display") > 0
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
def.static("number", "=>", "table").GetAvatarFrameItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AVATAR_FRAME_ITEM_CFG, id)
  if record == nil then
    warn("!!!!!!GetAvatarFrameItemCfg:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.avatarFrameId = record:GetIntValue("avatarFrameId")
  cfg.duration = record:GetIntValue("duration")
  return cfg
end
def.static("=>", "table").GetAllAvatarCfgList = function()
  local cfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AVATAR_FRAME_CFG)
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
    local cfg = AvatarFrameMgr.GetAvatarFrameCfg(id)
    if cfg and cfg.display and (cfg.factionLimit == 0 or cfg.factionLimit == myOccupation) and (cfg.genderLimit == 0 or cfg.genderLimit == myGender) then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local function comp(cfg1, cfg2)
    local unlock1 = instance:isUnlockAvatarFrame(cfg1.id)
    local unlock2 = instance:isUnlockAvatarFrame(cfg2.id)
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
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR_FRAME then
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, nil)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR_FRAME) then
    return false
  end
  local level = require("Main.Hero.Interface").GetBasicHeroProp().level
  if level < constant.CAvatarFrameConsts.OPEN_LEVEL then
    return false
  end
  return true
end
def.method("=>", "number").getDefaultAvatarFrameId = function(self)
  return constant.CAvatarFrameConsts.DEFAULT_AVATAR_FRAME_ID
end
def.method("=>", "number").getCurAvatarFrameId = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR_FRAME) then
    return self:getDefaultAvatarFrameId()
  end
  if self.curAvatartFrameId == 0 then
    return self:getDefaultAvatarFrameId()
  end
  return self.curAvatartFrameId
end
def.method("number", "=>", "boolean").isUnlockAvatarFrame = function(self, id)
  if self:getDefaultAvatarFrameId() == id then
    return true
  end
  if self.unlockAvatarFrameInfo and self.unlockAvatarFrameInfo[id] then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").isNewAvatarFrame = function(self, id)
  if self.newAvatarFrame and self.newAvatarFrame[id] then
    return true
  end
  return false
end
def.method("number").removeNewAvatarFrameId = function(self, id)
  if self.newAvatarFrame and self.newAvatarFrame[id] then
    self.newAvatarFrame[id] = nil
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, nil)
  end
end
def.method("number", "=>", "string").getLeftTimeStr = function(self, id)
  if not self:isUnlockAvatarFrame(id) then
    return textRes.Avatar[11]
  end
  local frameCfg = AvatarFrameMgr.GetAvatarFrameCfg(id)
  if frameCfg then
    local frameItemCfg = AvatarFrameMgr.GetAvatarFrameItemCfg(frameCfg.unlockItemId)
    if frameItemCfg.duration > 0 then
      local info = self.unlockAvatarFrameInfo[id]
      if info then
        local endTime = info.expire_time
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
      else
        local days = math.floor(frameItemCfg.duration / 24)
        local hours = frameItemCfg.duration - days * 24
        return string.format(textRes.Avatar[9], days, hours)
      end
    end
  end
  return textRes.Avatar[8]
end
def.method("=>", "boolean").IsHaveNotifyMessage = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR_FRAME) then
    return false
  end
  if self.newAvatarFrame then
    for i, v in pairs(self.newAvatarFrame) do
      if v then
        return true
      end
    end
  end
  return false
end
return AvatarFrameMgr.Commit()
