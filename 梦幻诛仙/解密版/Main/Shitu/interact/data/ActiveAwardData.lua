local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ActiveAwardData = Lplus.Class(CUR_CLASS_NAME)
local def = ActiveAwardData.define
def.field("userdata")._roleId = nil
def.field("number")._curActive = 0
def.field("number")._awardType = 0
def.field("number")._relationStartTime = 0
def.field("table")._fetchedAwardIdxs = nil
def.final("table", "=>", ActiveAwardData).New = function(p)
  if nil == p then
    return nil
  end
  local awardData = ActiveAwardData()
  awardData._roleId = p.role_id
  awardData._curActive = p.active_value
  if Int64.eq(awardData._roleId, _G.GetMyRoleID()) then
    awardData._awardType = constant.CShiTuActiveValueConsts.APPRENTICE_REWARD_ID
  else
    awardData._awardType = constant.CShiTuActiveValueConsts.MASTER_REWARD_ID
  end
  awardData._relationStartTime = p.relation_start_time
  awardData:UpdateFetchedInfo(p.award_active_index_id_set)
  return awardData
end
def.method().Release = function(self)
  self._roleId = nil
  self._curActive = 0
  self._awardType = 0
  self._relationStartTime = 0
  self._fetchedAwardIdxs = nil
end
def.method("number").UpdateActive = function(self, active)
  self._curActive = active
end
def.method("table").UpdateFetchedInfo = function(self, fetchedInfo)
  self._fetchedAwardIdxs = {}
  if fetchedInfo then
    for _, awardIdx in pairs(fetchedInfo) do
      table.insert(self._fetchedAwardIdxs, awardIdx)
    end
  end
end
def.method("table", "number", "number").UpdateAwardInfo = function(self, awardInfo)
  self:UpdateActive(awardInfo.active_value)
  self:UpdateFetchedInfo(awardInfo.award_active_index_id_set)
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self._roleId
end
def.method("=>", "number").GetCurActive = function(self)
  return self._curActive
end
def.method("=>", "number").GetAwardType = function(self)
  return self._awardType
end
def.method("=>", "number").GetApprenticeTime = function(self)
  return self._relationStartTime
end
def.method("=>", "table").GetFetchedAwardIdxs = function(self)
  return self._fetchedAwardIdxs
end
def.method("number", "=>", "boolean").IsAwardFetched = function(self, awardIndex)
  local result = false
  if self._fetchedAwardIdxs then
    for _, awardIdx in pairs(self._fetchedAwardIdxs) do
      if awardIdx == awardIndex then
        result = true
        break
      end
    end
  end
  return result
end
def.method("number", "=>", "boolean").CanFetchAward = function(self, awardIndex)
  local InteractData = require("Main.Shitu.interact.data.InteractData")
  local levelAwardCfg = InteractData.Instance():GetActiveLevelAwardCfg(self._awardType, _G.GetHeroProp().level)
  if levelAwardCfg then
    local result = false
    for _, awardCfg in pairs(levelAwardCfg) do
      if awardCfg.award_index == awardIndex then
        result = awardCfg.activite_value <= self:GetCurActive()
        break
      end
    end
    if result then
      return not self:IsAwardFetched(awardIndex)
    else
      return false
    end
  else
    warn(string.format("[ERROR][ActiveAwardData:CanFetchAward] levelAwardCfg nil for awardTypeId[%d], rolelevel[%d].", self._awardType, _G.GetHeroProp().level))
    return false
  end
end
return ActiveAwardData.Commit()
