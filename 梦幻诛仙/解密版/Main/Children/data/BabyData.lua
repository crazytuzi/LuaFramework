local Lplus = require("Lplus")
local BaseData = require("Main.Children.data.BaseData")
local BabyData = Lplus.Extend(BaseData, "BabyData")
local BabyPropertyEnum = require("consts.mzm.gsp.children.confbean.BabyPropertyEnum")
local BabyOperatorEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorEnum")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = BabyData.define
def.const("table").OperateCDTime = {
  [BabyOperatorEnum.SUCKLE] = constant.CChildrenConsts.baby_suckle_seconds,
  [BabyOperatorEnum.CHANGE_DIAPER] = constant.CChildrenConsts.baby_change_diaper_seconds,
  [BabyOperatorEnum.TICKLE] = constant.CChildrenConsts.baby_tickle_seconds,
  [BabyOperatorEnum.SLEEP] = constant.CChildrenConsts.baby_sleep_hours * 3600
}
def.field("number").propBaoshi = 0
def.field("number").propMood = 0
def.field("number").propClean = 0
def.field("number").propTired = 0
def.field("number").healthScore = 0
def.field("number").remainOperator = -1
def.field("userdata").remainSeconds = nil
def.field("boolean").bHasNanny = false
def.final("=>", BabyData).New = function()
  local BabyData = BabyData()
  return BabyData
end
def.override("table").RawSet = function(self, child)
  BaseData.RawSet(self, child)
  local BabyPeriodInfo = require("netio.protocol.mzm.gsp.children.BabyPeriodInfo")
  local babyPeriodInfo = UnmarshalBean(BabyPeriodInfo, child.child_period_info)
  self:SetBabyProperty(babyPeriodInfo.baby_property_info_map)
  self.healthScore = babyPeriodInfo.health_score
  self.remainOperator = babyPeriodInfo.remain_operator
  self.remainSeconds = babyPeriodInfo.remain_seconds
  self.bHasNanny = babyPeriodInfo.breed_type and babyPeriodInfo.breed_type == BabyPeriodInfo.BREED_TYPE_AUTO or false
end
def.method("table").SetBabyProperty = function(self, propertyMap)
  if propertyMap == nil then
    warn("baby prpperty is nil")
    return
  end
  self.propBaoshi = propertyMap[BabyPropertyEnum.BAO_SHI] or 0
  self.propMood = propertyMap[BabyPropertyEnum.MOOD] or 0
  self.propClean = propertyMap[BabyPropertyEnum.CLEAN] or 0
  self.propTired = propertyMap[BabyPropertyEnum.TIRED] or 0
end
def.method("=>", "number").GetBaoshiProperty = function(self)
  return self.propBaoshi
end
def.method("=>", "boolean").IsFullBaoshiProperty = function(self)
  return self.propBaoshi >= constant.CChildrenConsts.baby_max_bao_shi_value
end
def.method("=>", "number").GetMoodProperty = function(self)
  return self.propMood
end
def.method("=>", "boolean").IsFullMoodProperty = function(self)
  return self.propMood >= constant.CChildrenConsts.baby_max_moood_value
end
def.method("=>", "number").GetCleanProperty = function(self)
  return self.propClean
end
def.method("=>", "boolean").IsFullCleanProperty = function(self)
  return self.propClean >= constant.CChildrenConsts.baby_max_clean_value
end
def.method("=>", "number").GetTiredProperty = function(self)
  return self.propTired
end
def.method("=>", "boolean").IsFullTired = function(self)
  return self.propTired >= constant.CChildrenConsts.baby_max_tired_value
end
def.method("number").SetTireProperty = function(self, tired)
  self.propTired = tired
end
def.method("=>", "boolean").IsSleeping = function(self)
  return self.remainOperator == BabyOperatorEnum.SLEEP
end
def.method("=>", "boolean").HasRemainOperator = function(self)
  return self.remainOperator >= 0
end
def.method("number").SetRemainOperater = function(self, operator)
  self.remainOperator = operator
  self.remainSeconds = Int64.new(BabyData.OperateCDTime[operator])
end
def.method().RemoveRemainOperator = function(self)
  self.remainOperator = -1
  self.remainSeconds = nil
end
def.method("=>", "userdata").GetRemainOperatorSeconds = function(self)
  return self.remainSeconds
end
def.method("userdata").SetRemainOperatorSeconds = function(self, remainSeconds)
  self.remainSeconds = remainSeconds
end
def.method("=>", "number").GetHealthScore = function(self)
  return self.healthScore
end
def.method("=>", "boolean").IsFullHealthScore = function(self)
  return self.healthScore >= constant.CChildrenConsts.baby_to_childhood_need_health_value
end
def.method("=>", "boolean").IsHasNanny = function(self)
  return self.bHasNanny
end
def.method("boolean").SetHasNanny = function(self, bHas)
  self.bHasNanny = bHas
end
def.method("=>", "boolean").Tick = function(self)
  local dataChanged = false
  if self.remainSeconds ~= nil and Int64.gt(self.remainSeconds, 0) then
    self.remainSeconds = self.remainSeconds - 1
    dataChanged = true
  end
  local curTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  if t.sec == 0 and t.min == 0 then
    if not self.bHasNanny then
      self.propBaoshi = math.max(self.propBaoshi - constant.CChildrenConsts.baby_reduce_bao_shi_every_hour, 0)
      self.propMood = math.max(self.propMood - constant.CChildrenConsts.baby_max_moood_every_hour, 0)
      self.propClean = math.max(self.propClean - constant.CChildrenConsts.baby_reduce_clean_every_hour, 0)
    end
    if t.hour == 0 and self.propBaoshi >= constant.CChildrenConsts.baby_min_bao_shi_to_add_health and self.propMood >= constant.CChildrenConsts.baby_min_mood_value_to_add_health and self.propClean >= constant.CChildrenConsts.baby_min_clean_to_add_health then
      self.healthScore = math.min(self.healthScore + constant.CChildrenConsts.baby_health_value_add_value_one_day, constant.CChildrenConsts.baby_to_childhood_need_health_value)
    end
    dataChanged = true
  end
  return dataChanged
end
def.method().ClearData = function(self)
  self.propBaoshi = 0
  self.propMood = 0
  self.propClean = 0
  self.propTired = 0
  self.healthScore = 0
  self.remainOperator = -1
  self.remainSeconds = nil
  self.bHasNanny = false
end
BabyData.Commit()
return BabyData
