local Lplus = require("Lplus")
local OracleData = require("Main.Oracle.data.OracleData")
local OracleModule = require("Main.Oracle.OracleModule")
local OracleProtocols, OracleUtils
local OracleAllocation = Lplus.Class("OracleAllocation")
local def = OracleAllocation.define
def.const("number").SUCCESS = 0
def.const("number").FAILED_ALLOC_POINT_BELOW_ZERO = 1
def.const("number").FAILED_POINT_NOT_ENOUGH = 2
def.const("number").FAILED_OVER_MAX_POINT = 3
def.const("number").FAILED_ABOVE_LAYER_POINT_LACK = 4
def.const("number").FAILED_PRE_TALENT_POINT_LACK = 5
def.const("number").FAILED_AFFECT_BELOW_TALENTS = 6
def.field("number")._occupationId = 0
def.field("number")._oracleId = 0
def.field("table")._allocation = nil
def.field("number")._costPoints = 0
def.field("boolean")._bDirty = false
def.static("number", "table", "=>", OracleAllocation).Create = function(oracleId, allocation)
  OracleProtocols = require("Main.Oracle.OracleProtocols")
  OracleUtils = require("Main.Oracle.OracleUtils")
  local alloc = OracleAllocation()
  alloc:_Init(oracleId, allocation)
  return alloc
end
def.method("number", "table")._Init = function(self, oracleId, allocation)
  self._oracleId = oracleId
  self._occupationId = OracleData.Instance():GetOccupByOracleId(oracleId)
  self._allocation = {}
  self._costPoints = 0
  self._bDirty = false
  if allocation then
    for talentId, points in pairs(allocation) do
      self:_AllocatePoint(talentId, points)
    end
  end
end
def.method("number", "number")._AllocatePoint = function(self, talentId, points)
  local oldPoints = self._allocation[talentId] or 0
  if points <= 0 then
    self._allocation[talentId] = nil
  else
    self._allocation[talentId] = points
  end
  self._costPoints = self._costPoints + (points - oldPoints)
end
def.method("=>", OracleAllocation).Copy = function(self)
  return OracleAllocation.Create(self._oracleId, self._allocation)
end
def.method().Reset = function(self)
  warn("[OracleAllocation:Reset] Reset allocation, oracleid=", self._oracleId)
  local savedAlloc = OracleData.Instance():GetCurrentAllocation()
  if savedAlloc and savedAlloc:GetOracleId() == self._oracleId and not savedAlloc:IsEmpty() then
    OracleProtocols.SendCResetPlan(self._oracleId)
  else
    self._allocation = {}
    self._costPoints = 0
    self._bDirty = false
  end
end
def.method().Save = function(self)
  warn("[OracleAllocation:Save] Save allocation, oracleid=", self._oracleId)
  if OracleData.Instance():GetCurrentOracleId() == self._oracleId then
    OracleProtocols.SendCSavePlan(self._oracleId, self._allocation)
  else
    warn(string.format("[OracleAllocation:Save] Save Fail! self._oracleid [%d] ~= currentOracleId[%d].", self._oracleId, OracleData.Instance():GetCurrentOracleId()))
  end
end
def.method().Release = function(self)
  self._occupationId = 0
  self._oracleId = 0
  self._allocation = {}
  self._costPoints = 0
  self._bDirty = false
end
def.method("number", "boolean", "=>", "boolean").TryAllocatePoint = function(self, talentId, bToast)
  local point = 0
  if nil == self._allocation[talentId] then
    point = 1
  else
    point = self._allocation[talentId] + 1
  end
  if self:CheckAllocation(talentId, point, bToast) == OracleAllocation.SUCCESS then
    self:_AllocatePoint(talentId, point)
    self._bDirty = true
    return true
  else
    return false
  end
end
def.method("number", "boolean", "=>", "boolean").TryDeallocatePoint = function(self, talentId, bToast)
  local point = 0
  if nil == self._allocation[talentId] then
    point = -1
  else
    point = self._allocation[talentId] - 1
  end
  if self:CheckAllocation(talentId, point, bToast) == OracleAllocation.SUCCESS then
    self:_AllocatePoint(talentId, point)
    self._bDirty = true
    return true
  else
    return false
  end
end
def.method("number", "number", "boolean", "=>", "number").CheckAllocation = function(self, talentId, point, bToast)
  local result = OracleAllocation.SUCCESS
  local reason = textRes.Oracle.ALLOCATION_SUCCESS
  if point < 0 then
    result = OracleAllocation.FAILED_ALLOC_POINT_BELOW_ZERO
    reason = textRes.Oracle.ALLOCATION_POINT_BELOW_ZERO
  elseif 0 >= self:GetRestPoints() and point > self:GetTalentPoints(talentId) then
    result = OracleAllocation.FAILED_POINT_NOT_ENOUGH
    reason = textRes.Oracle.ERROR_POINT_NOT_ENOUGH
  elseif point > OracleUtils.GetTalentMaxPoint(talentId) then
    result = OracleAllocation.FAILED_OVER_MAX_POINT
    reason = textRes.Oracle.ALLOCATION_OVER_TALENT_MAX_POINT
  elseif OracleUtils.GetTalentAboveLayerPoint(talentId) > self:_GetAboveLayerPoints(talentId) then
    result = OracleAllocation.FAILED_ABOVE_LAYER_POINT_LACK
    reason = string.format(textRes.Oracle.ALLOCATION_ABOVE_LAYER_POINT_LACK, OracleUtils.GetTalentAboveLayerPoint(talentId))
  elseif not self:_IsPreTalentPointsEnough(talentId) then
    result = OracleAllocation.FAILED_PRE_TALENT_POINT_LACK
    reason = textRes.Oracle.ALLOCATION_PRE_TALENT_POINT_LACK
  elseif self:_AffectBelowTalentspoint(talentId, point) then
    result = OracleAllocation.FAILED_AFFECT_BELOW_TALENTS
    reason = textRes.Oracle.ALLOCATION_AFFECT_BELOW_TALENTS
  end
  if OracleAllocation.SUCCESS ~= result and bToast then
    Toast(reason)
  end
  return result
end
def.method("number", "number", "=>", "boolean")._AffectBelowTalentspoint = function(self, talentId, newPoints)
  local result = false
  local curPoints = self:GetTalentPoints(talentId)
  if newPoints < curPoints then
    local curTalentCfg = OracleData.Instance():GetTalentCfg(talentId)
    if curTalentCfg then
      local belowTalentCfg
      for tId, tPt in pairs(self._allocation) do
        if tPt > 0 then
          belowTalentCfg = OracleData.Instance():GetTalentCfg(tId)
          if belowTalentCfg then
            if belowTalentCfg.previousTalents[talentId] and newPoints < belowTalentCfg.previousTalents[talentId] then
              warn(string.format("[DlgOracle:_AffectBelowTalentspoint] talent[%d] relies on talent[%d] at least [%d] points.", tId, talentId, belowTalentCfg.previousTalents[talentId]))
              result = true
              break
            else
              if belowTalentCfg.layer > curTalentCfg.layer and 0 < belowTalentCfg.previousPoint and self:_GetAboveLayerPoints(tId) + newPoints - curPoints < belowTalentCfg.previousPoint then
                warn(string.format("[DlgOracle:_AffectBelowTalentspoint] talent[%d] relies on above layers at least [%d] points.", tId, belowTalentCfg.previousPoint))
                result = true
            end
            else
              else
                warn("[DlgOracle:_AffectBelowTalentspoint] talentcfg nil for talentId:", tId)
              end
              else
                warn("[DlgOracle:_AffectBelowTalentspoint] talentcfg nil for talentId:", talentId)
              end
            end
        end
      end
  end
  return result
end
def.method("=>", "number").GetOccupation = function(self)
  return self._occupationId
end
def.method("=>", "number").GetOracleId = function(self)
  return self._oracleId
end
def.method("=>", "table").GetAllocation = function(self)
  return self._allocation
end
def.method("=>", "number").GetCostPoints = function(self)
  return self._costPoints
end
def.method("=>", "number").GetRestPoints = function(self)
  local totalPoints = OracleData.Instance():GetTotalPoints() or 0
  local costPoints = self:GetCostPoints() or 0
  local restPoints = math.max(0, totalPoints - costPoints)
  return restPoints
end
def.method("number", "=>", "number").GetTalentPoints = function(self, talentId)
  return self._allocation[talentId] or 0
end
def.method("number", "=>", "number").GetTalentSkillId = function(self, talentId)
  local talentPoint = self:GetTalentPoints(talentId)
  return OracleUtils.GetSkillIdByTalentPoint(talentId, talentPoint)
end
def.method("number", "=>", "table").GetTalentSkillCfg = function(self, talentId)
  local talentPoint = self:GetTalentPoints(talentId)
  return OracleUtils.GetTalentSkillCfg(talentId, talentPoint)
end
def.method("number", "=>", "boolean").IsTalentFull = function(self, talentId)
  return self:GetTalentPoints(talentId) >= OracleUtils.GetTalentMaxPoint(talentId)
end
def.method("number", "=>", "boolean").IsTalentOpen = function(self, talentId)
  local result = true
  if OracleUtils.GetTalentAboveLayerPoint(talentId) > self:_GetAboveLayerPoints(talentId) then
    result = false
  elseif not self:_IsPreTalentPointsEnough(talentId) then
    result = false
  end
  return result
end
def.method("number", "=>", "number")._GetAboveLayerPoints = function(self, talentId)
  local result = 0
  local talentCfg = OracleData.Instance():GetTalentCfg(talentId)
  local oracleCfg = talentCfg and OracleData.Instance():GetOracleCfg(talentCfg.oracleId) or nil
  if talentCfg and oracleCfg then
    for _, tid in ipairs(oracleCfg.talents) do
      local tcfg = OracleData.Instance():GetTalentCfg(tid)
      if tcfg and tcfg.layer < talentCfg.layer then
        result = result + self:GetTalentPoints(tid)
      end
    end
  else
    error("[OracleAllocation:_GetAboveLayerPoints] Failed! talentCfg or oracleCfg nil for talentid:", talentId)
  end
  return result
end
def.method("number", "=>", "boolean")._IsPreTalentPointsEnough = function(self, talentId)
  local result = true
  local talentCfg = OracleData.Instance():GetTalentCfg(talentId)
  if talentCfg then
    if talentCfg.previousTalents then
      for preTalentId, preTalentPt in pairs(talentCfg.previousTalents) do
        if preTalentPt > self:GetTalentPoints(preTalentId) then
          warn(string.format("[OracleAllocation:_IsPreTalentPointsEnough] previous talents of [%d] not enough:previous talent[%d] current point[%d] < need point[%d].", talentId, preTalentId, self:GetTalentPoints(preTalentId), preTalentPt))
          result = false
          break
        end
      end
    end
  else
    error("[OracleAllocation:_IsPreTalentPointsEnough] Failed! talentCfg nil for talentid:", talentId)
  end
  return result
end
def.method("=>", "boolean").IsDirty = function(self)
  return self._bDirty
end
def.method("=>", "boolean").IsEmpty = function(self)
  return self:GetCostPoints() <= 0
end
def.method("=>", "boolean").NeedSave = function(self)
  return self:IsDirty() and self._oracleId == OracleData.Instance():GetCurrentOracleId()
end
def.method("=>", "boolean").IsPreview = function(self)
  return self._oracleId ~= OracleData.Instance():GetCurrentOracleId() or nil == OracleData.Instance():GetCurrentAllocation()
end
def.method("number", "=>", "boolean").CanReducePoint = function(self, talentId)
  local result = false
  if self._oracleId ~= OracleData.Instance():GetCurrentOracleId() or nil == OracleData.Instance():GetCurrentAllocation() then
    result = true
  else
    local localPt = self._allocation[talentId] or 0
    local savedAlloc = OracleData.Instance():GetCurrentAllocation()
    local savedPt = savedAlloc and savedAlloc:GetTalentPoints(talentId) or 0
    result = localPt > savedPt
  end
  return result
end
OracleAllocation.Commit()
return OracleAllocation
