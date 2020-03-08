local Lplus = require("Lplus")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local FestivalUtility = require("Main.Festival.FestivalUtility")
local FestivalMgr = Lplus.Class("FestivalMgr")
local def = FestivalMgr.define
def.field("number").festivalAwardId = 0
def.field("number").nextFestivalAwardId = 0
def.field("boolean").isAwardReceived = false
local instance
def.static("=>", FestivalMgr).Instance = function()
  if instance == nil then
    instance = FestivalMgr()
  end
  return instance
end
def.method().Reset = function(self)
  self.festivalAwardId = 0
  self.nextFestivalAwardId = 0
  self.isAwardReceived = false
end
def.method("=>", "boolean").IsAwardAvailable = function(self)
  return self.festivalAwardId ~= 0 and self.isAwardReceived == false
end
def.static("table", "=>", "string").SelectFestivalName = function(serviceCfg)
  local festivalMgr = FestivalMgr.Instance()
  if festivalMgr:IsAwardAvailable() then
    local festivalCfg = FestivalUtility.GetFestivalCfgById(festivalMgr.festivalAwardId)
    if not festivalCfg then
      return ""
    end
    return festivalCfg.festivalName .. textRes.Festival[1]
  else
    return textRes.Festival[2]
  end
end
def.method().SetFestivalAwardFuncUIName = function(self)
  local serviceId = NPCServiceConst.FestivalAward
  local NPCInterface = require("Main.npc.NPCInterface").Instance()
  NPCInterface:RegisterNPCServiceCustomName(serviceId, FestivalMgr.SelectFestivalName)
end
def.static("number", "=>", "boolean").IsFestivalDescOpen = function(ServiceID)
  local festivalMgr = FestivalMgr.Instance()
  return festivalMgr.festivalAwardId ~= 0
end
def.method().SetFestivalDescOpenStatus = function(self)
  local serviceId = NPCServiceConst.FestivalDesc
  local NPCInterface = require("Main.npc.NPCInterface").Instance()
  NPCInterface:RegisterNPCServiceCustomCondition(serviceId, FestivalMgr.IsFestivalDescOpen)
end
def.method().SetFestivalNPCService = function(self)
  self:SetFestivalDescOpenStatus()
  self:SetFestivalAwardFuncUIName()
  self:NofifyFesitivalDataReady()
end
def.method().ReqFestivalInfo = function(self)
  local p = require("netio.protocol.mzm.gsp.festival.CFestivalInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number").PrepareFestivalNPCData = function(serviceId)
  local festivalMgr = FestivalMgr.Instance()
  festivalMgr:ReqFestivalInfo()
end
def.method().RegisterFestivalNPCWait = function(self)
  local NPCInterface = require("Main.npc.NPCInterface").Instance()
  local serviceId = NPCServiceConst.FestivalAward
  NPCInterface:RegisterNPCServiceCustomConditionWait(serviceId, FestivalMgr.PrepareFestivalNPCData)
end
def.method().NofifyFesitivalDataReady = function(self)
  local NPCInterface = require("Main.npc.NPCInterface").Instance()
  local serviceId = NPCServiceConst.FestivalAward
  NPCInterface:NPCServiceCustomConditionWaitReady(serviceId)
end
def.method().ReqNextFestivalInfo = function(self)
  local p = require("netio.protocol.mzm.gsp.festival.CNextFestivalInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("number").ReqTakeFestivalAward = function(self, id)
  local p = require("netio.protocol.mzm.gsp.festival.CTakeFestivalAwardReq").new(id)
  gmodule.network.sendProtocol(p)
end
def.method("table").SetFestivalState = function(self, data)
  self.festivalAwardId = data.festivalAwardid
  local festivalInfoRes = require("netio.protocol.mzm.gsp.festival.SFestivalInfoRes")
  self.isAwardReceived = data.awardState == festivalInfoRes.TAKED
end
def.method("table").SetNextFestivalId = function(self, data)
  self.nextFestivalAwardId = data.festivalAwardid
end
def.method("=>", "number").GetFestivalNPCId = function(self)
  return FestivalUtility.GetFestivalConstByName("festivalNpcid")
end
def.method().OnFestivalDescService = function(self)
  if self.festivalAwardId == 0 then
    return
  end
  local NPCId = self:GetFestivalNPCId()
  local festivalCfg = FestivalUtility.GetFestivalCfgById(self.festivalAwardId)
  if not festivalCfg then
    return
  end
  local festivalDesc = festivalCfg.festivalDesc
  FestivalUtility.FillNPCDialogContent(festivalDesc, NPCId)
end
def.method().OnFestivalAwardService = function(self)
  if self:IsAwardAvailable() then
    self:TakeFestivalAward()
  else
    self:SetNextFestivalNotice()
  end
end
def.method().TakeFestivalAward = function(self)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local festivalCfg = FestivalUtility.GetFestivalCfgById(self.festivalAwardId)
  if not festivalCfg then
    return
  end
  local levelLimit = festivalCfg.minLevel
  if levelLimit > 0 and heroLevel < levelLimit then
    local NPCId = self:GetFestivalNPCId()
    local content = string.format(textRes.Festival[7], levelLimit)
    FestivalUtility.FillNPCDialogContent(content, NPCId)
  else
    self:ReqTakeFestivalAward(self.festivalAwardId)
  end
end
def.method().SetNextFestivalNotice = function(self)
  local NPCId = self:GetFestivalNPCId()
  if self.nextFestivalAwardId == 0 then
    FestivalUtility.FillNPCDialogContent(textRes.Festival[4], NPCId)
    return
  end
  local nextFestivalCfg = FestivalUtility.GetFestivalCfgById(self.nextFestivalAwardId)
  if not nextFestivalCfg then
    return
  end
  local name = nextFestivalCfg.festivalName
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timecfg = TimeCfgUtils.GetTimeLimitCommonCfg(nextFestivalCfg.limitTime)
  local dateStr = string.format(textRes.Festival.TimeFormatter, timecfg.startYear, timecfg.startMonth, timecfg.startDay)
  local levelLimit = nextFestivalCfg.minLevel
  local levelStr = ""
  if levelLimit > 0 then
    levelStr = string.format(textRes.Festival[6], levelLimit)
  else
    levelStr = textRes.Festival[5]
  end
  local content = string.format(textRes.Festival[3], name, dateStr, levelStr)
  FestivalUtility.FillNPCDialogContent(content, NPCId)
end
return FestivalMgr.Commit()
