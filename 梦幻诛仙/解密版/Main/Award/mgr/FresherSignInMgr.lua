local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local FresherSignInMgr = Lplus.Extend(AwardMgrBase, "FresherSignInMgr")
local def = FresherSignInMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
def.field("table").awardBeforeSignInfo = nil
def.field("table").fillInfo = nil
def.field("boolean").hasNotifyMessage = false
def.field("table").signStatus = nil
local instance
def.static("=>", FresherSignInMgr).Instance = function()
  if instance == nil then
    instance = FresherSignInMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  local t = {
    SIGNED = 0,
    PASS_DUE = 1,
    CAN_SIGN = 2,
    UNOPEN = 3
  }
  self.signStatus = t
end
def.method().Reset = function(self)
  self.awardBeforeSignInfo = nil
end
def.method("table").SetFresherSignInInfo = function(self, data)
  self.hasNotifyMessage = false
  self.awardBeforeSignInfo = data
  if self.awardBeforeSignInfo == nil or self.awardBeforeSignInfo.awardedTimes == nil then
    return
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SIGN_BEFORE_CFG)
  local num = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  self.fillInfo = {}
  for i = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local item = {}
    item.day = record:GetIntValue("day")
    item.rewardid = record:GetIntValue("rewardid")
    if item.day == nil then
      warn("item")
    end
    if item.day > self.awardBeforeSignInfo.day then
      item.status = self.signStatus.UNOPEN
    elseif item.day == self.awardBeforeSignInfo.day then
      item.status = self.signStatus.CAN_SIGN
    else
      local signed = false
      for k, v in self.awardBeforeSignInfo.awardedTimes, nil, nil do
        if v == item.day then
          signed = true
          break
        end
      end
      if signed == true then
        item.status = self.signStatus.SIGNED
        self.hasNotifyMessage = true
      else
        item.status = self.signStatus.PASS_DUE
      end
    end
    self.fillInfo[i] = item
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.SIGN_BEFORE_UPDATE, nil)
end
def.method("number").updateFresherSignInInfo = function(self, day)
  if self.awardBeforeSignInfo == nil then
    return
  end
  table.insert(self.awardBeforeSignInfo.awardedTimes.day)
  self:SetFresherSignInInfo(self.awardBeforeSignInfo)
end
def.method("number").getFresherSignInAward = function(self, day)
  if self.awardBeforeSignInfo == nil then
    return
  end
  if day ~= self.awardBeforeSignInfo.day then
    return
  end
  local p = require("netio.protocol.mzm.gsp.signaward.CGetAwardbeforeSignReq").new(day)
  gmodule.network.sendProtocol(p)
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self.hasNotifyMessage
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.override("=>", "boolean").IsOpen = function(self)
  if self.awardBeforeSignInfo == nil then
    return false
  end
  return true
end
return FresherSignInMgr.Commit()
