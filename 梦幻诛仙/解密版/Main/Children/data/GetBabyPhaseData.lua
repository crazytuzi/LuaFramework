local Lplus = require("Lplus")
local GetBabyPhaseData = Lplus.Class("GetBabyPhaseData")
local SGetBreedInfo = require("netio.protocol.mzm.gsp.children.SSyncBreedInfo")
local def = GetBabyPhaseData.define
local instance
def.const("number").COUPLE_PHASE_NUMBER = 4
def.const("table").COUPLE_PHASE_SOCRE = {
  constant.CChildrenConsts.prepare_pregnant_need_score,
  1,
  constant.CChildrenConsts.give_birth_need_score,
  1
}
def.const("number").SINGLE_PHASE_SCORE = constant.CChildrenConsts.single_children_need_score
def.field("number").breed_state = SGetBreedInfo.NO_BREED
def.field("number").score = 0
def.field("number").step = 0
def.field("userdata").remainGiveBirthTime = nil
def.static("=>", GetBabyPhaseData).Instance = function()
  if instance == nil then
    instance = GetBabyPhaseData()
  end
  return instance
end
def.method("table").RawSet = function(self, p)
  self.breed_state = p.breed_state
  self.score = p.score
  self.step = p.step
  self.remainGiveBirthTime = p.remain_give_birth_seconds
end
def.method("=>", "boolean").IsBreeding = function(self)
  return self.breed_state ~= SGetBreedInfo.NO_BREED
end
def.method("=>", "boolean").IsCoupleBreeding = function(self)
  return self.breed_state == SGetBreedInfo.COUPLE_BREED
end
def.method("=>", "boolean").IsSingleBreeding = function(self)
  return self.breed_state == SGetBreedInfo.SINGLE_BREED
end
def.method("=>", "number").GetCurrentBreedStep = function(self)
  return self.step
end
def.method("=>", "number").GetCurrentBreedScore = function(self)
  return self.score
end
def.method("=>", "userdata").GetRemainGiveBirthTime = function(self)
  return self.remainGiveBirthTime
end
def.method("userdata").SetRemainGiveBirthTime = function(self, remainTime)
  self.remainGiveBirthTime = remainTime
end
def.method().Tick = function(self)
  if self.remainGiveBirthTime ~= nil and Int64.gt(self.remainGiveBirthTime, 0) then
    self.remainGiveBirthTime = self.remainGiveBirthTime - 1
  end
end
def.method().ClearData = function(self)
  self.breed_state = SGetBreedInfo.NO_BREED
  self.score = 0
  self.step = 0
  self.remainGiveBirthTime = nil
end
GetBabyPhaseData.Commit()
return GetBabyPhaseData
