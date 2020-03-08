local Lplus = require("Lplus")
local HeroEnergyMgr = Lplus.Class("HeroEnergyMgr")
local HeroUtility = require("Main.Hero.HeroUtility")
local def = HeroEnergyMgr.define
local HeroUtility = require("Main.Hero.HeroUtility")
local EnergySourceDataFactory = require("Main.Hero.data.energy.EnergySourceDataFactory")
local NOT_SET = -1
def.field("number")._maxEnergyBase = NOT_SET
def.field("number")._maxEnergyStep = NOT_SET
def.field("number")._energyMaxAmountRate = NOT_SET
def.field("number")._energyNearlyFullRate = NOT_SET
def.field("number")._silverPerEnergy = NOT_SET
def.field("number")._energyItemUseLimit = NOT_SET
def.field("number")._energyWorkingCost = NOT_SET
def.field("table")._awardEnergyActivityMap = nil
def.const("table").consumeOPList = {
  require("Main.Hero.op.ConsumeEnergyWorking"),
  require("Main.Hero.op.ConsumeEnergyEnchanting")
}
local instance
def.static("=>", HeroEnergyMgr).Instance = function()
  if instance == nil then
    instance = HeroEnergyMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self._awardEnergyActivityMap = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroEnergyMgr.OnLeaveWorld)
end
def.method("table").SetAwardEnergyActivityMap = function(self, data)
  self._awardEnergyActivityMap = self._awardEnergyActivityMap or {}
  for k, v in pairs(data) do
    self._awardEnergyActivityMap[k] = v
  end
end
def.method("=>", "table").GetAwardEnergyActivityMap = function(self)
  return self._awardEnergyActivityMap
end
def.method("=>", "table").GetEnergySourceDataList = function(self)
  local cfgs = HeroUtility.GetAllVigorDescCfgs()
  local list = {}
  for k, cfg in pairs(cfgs) do
    local serverData = self._awardEnergyActivityMap[cfg.awardType]
    local data = EnergySourceDataFactory.Create(cfg)
    if serverData then
      data.awardedTimes = serverData.count
      data.awardedValue = serverData.vigor
    end
    table.insert(list, data)
  end
  return list
end
def.method("number", "number", "number", "=>", "number").CalcMaxAwardEnergy = function(self, awardType, awarded, remainCount)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local awardEnergyPerTimes = HeroUtility.GetAwardVigor(awardType, heroProp.level)
  local maxAwardEnergy = awarded + remainCount * awardEnergyPerTimes
  return maxAwardEnergy
end
def.method("=>", "table").GetConsumeEnergyList = function(self)
  local consumeItemDataList = {}
  for i, v in ipairs(HeroEnergyMgr.consumeOPList) do
    local consumeItemData = v.New()
    if consumeItemData:IsUnlock() then
      table.insert(consumeItemDataList, consumeItemData)
    end
  end
  self:SetLivingSkillConsumeOPs(consumeItemDataList)
  return consumeItemDataList
end
def.method("table").SetLivingSkillConsumeOPs = function(self, consumeItemDataList)
  local ConsumeEnergyLivingSkill = require("Main.Hero.op.ConsumeEnergyLivingSkill")
  local LivingSkillData = require("Main.Skill.data.LivingSkillData")
  local skillBagList = LivingSkillData.Instance():GetBagList()
  for k, v in pairs(skillBagList) do
    local consumeItemData = ConsumeEnergyLivingSkill.New(v)
    if consumeItemData:IsUnlock() then
      table.insert(consumeItemDataList, consumeItemData)
    end
  end
end
def.method("number", "=>", "number").GetRoleMaxEnergy = function(self, curLevel)
  local base = self:GetMaxEnergyBase()
  local step = self:GetMaxEnergyStep()
  return base + step * (curLevel - 1)
end
def.method("=>", "number").GetMaxEnergyBase = function(self)
  if self._maxEnergyBase == NOT_SET then
    self._maxEnergyBase = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_LIMIT")
  end
  return self._maxEnergyBase
end
def.method("=>", "number").GetMaxEnergyStep = function(self)
  if self._maxEnergyStep == NOT_SET then
    self._maxEnergyStep = HeroUtility.Instance():GetRoleCommonConsts("ADD_VIGOR_LIMIT_PERLV")
  end
  return self._maxEnergyStep
end
def.method("=>", "number").GetEnergyMaxAmountRate = function(self)
  if self._energyMaxAmountRate == NOT_SET then
    self._energyMaxAmountRate = HeroUtility.Instance():GetRoleCommonConsts("MORETHAN_VIGOR_LIMIT_MAX_VAL_RATE") / 10000 + 1
  end
  return self._energyMaxAmountRate
end
def.method("=>", "number").GetEnergyNearlyFullRate = function(self)
  if self._energyNearlyFullRate == NOT_SET then
    self._energyNearlyFullRate = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_REACH_LIMIT_TIP_RATE") / 10000
  end
  return self._energyNearlyFullRate
end
def.method("=>", "number").GetSilverPerEnergy = function(self)
  if self._silverPerEnergy == NOT_SET then
    self._silverPerEnergy = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_2_SILVER")
  end
  return self._silverPerEnergy
end
def.method("=>", "number").GetEnergyItemUseLimit = function(self)
  if self._energyItemUseLimit == NOT_SET then
    self._energyItemUseLimit = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_ITEM_USE_LIMIT_PERDAY")
  end
  return self._energyItemUseLimit
end
def.method("=>", "number").GetEnergyWorkingCost = function(self)
  if self._energyWorkingCost == NOT_SET then
    self._energyWorkingCost = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_WORK_COST")
  end
  return self._energyWorkingCost
end
def.method().EnergyWorking = function(self)
  self:C2S_CVigorWorkReq()
end
def.method().C2S_CVigorWorkReq = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CVigorWorkReq").new())
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance._awardEnergyActivityMap = {}
end
HeroEnergyMgr.Commit()
return HeroEnergyMgr
