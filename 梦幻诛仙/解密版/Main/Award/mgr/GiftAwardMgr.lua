local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local GiftAwardMgr = Lplus.Class(CUR_CLASS_NAME)
local def = GiftAwardMgr.define
local instance
def.static("=>", GiftAwardMgr).Instance = function()
  if instance == nil then
    instance = GiftAwardMgr()
  end
  return instance
end
def.field("table").m_canDrawAwards = nil
def.method().Init = function(self)
  self.m_canDrawAwards = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SCanGetGifts", GiftAwardMgr.OnSCanGetGifts)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SGetGiftRep", GiftAwardMgr.OnSGetGiftRep)
  require("Main.Award.GiftAwardHandlers.init")
end
def.method("number", "=>", "table").GetGiftAwardInfo = function(self, useType)
  local awardInfo = self.m_canDrawAwards[useType]
  if awardInfo == nil then
    return nil
  end
  return awardInfo
end
def.method("number", "=>", "table").GetGiftAwardCfg = function(self, useType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GIFT_AWARD_CFG, useType)
  if record == nil then
    warn("GetGiftAwardCfg(" .. useType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.useType = record:GetIntValue("useType")
  cfg.global = record:GetIntValue("global")
  cfg.awardType = record:GetIntValue("awardType")
  cfg.giftId = record:GetIntValue("giftId")
  cfg.maxCount = record:GetIntValue("maxCount")
  cfg.desc = record:GetStringValue("desc")
  cfg.link = record:GetStringValue("link")
  return cfg
end
def.method("number", "=>", "boolean").CanDraw = function(self, useType)
  if self.m_canDrawAwards[useType] == nil then
    warn(string.format("draw giftAward failed: useType=%d not exist", useType))
    return false
  end
  local awardInfo = self:GetGiftAwardInfo(useType)
  local awardCfg = self:GetGiftAwardCfg(useType)
  if awardInfo.useCount >= awardCfg.maxCount then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").DrawAward = function(self, useType)
  if not self:CanDraw(useType) then
    return false
  end
  print("draw giftAward", useType)
  local p = require("netio.protocol.mzm.gsp.award.CGetGiftReq").new(useType)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSCanGetGifts = function(p)
  print("OnSCanGetGifts p.useTypeInfo", p.useTypeInfo)
  instance.m_canDrawAwards = {}
  for useType, useCount in pairs(p.useTypeInfo) do
    local awardInfo = {useType = useType, useCount = useCount}
    instance.m_canDrawAwards[useType] = awardInfo
  end
end
def.static("table").OnSGetGiftRep = function(p)
  print("OnSGetGiftRep p.useType, p.alCount ", p.useType, p.alCount)
  if instance.m_canDrawAwards[p.useType] == nil then
    warn(string.format("OnSGetGiftRep failed!: useType=%d not exist", p.useType))
    return
  end
  local awardInfo = instance.m_canDrawAwards[p.useType]
  awardInfo.useCount = p.alCount
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_GIFT_AWARD_SUCCESS, {
    useType = p.useType
  })
end
return GiftAwardMgr.Commit()
