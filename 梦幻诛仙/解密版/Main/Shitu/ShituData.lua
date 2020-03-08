local Lplus = require("Lplus")
local ShituData = Lplus.Class("ShituData")
local ShituRoleList = require("Main.Shitu.data.ShituRoleList")
local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
local def = ShituData.define
local instance
def.field("table")._master = nil
def.field(ShituRoleList)._apprenticeList = nil
def.field(ShituRoleList)._classmateList = nil
def.field("number")._isChushiState = ShiTuConst.NO_CHU_SHI
def.field("table")._currentSession = nil
def.field("table")._receivedAward = nil
def.field("number")._currentPayRespectTimes = 0
def.static("=>", ShituData).Instance = function()
  if instance == nil then
    instance = ShituData()
    instance._apprenticeList = ShituRoleList.new()
    instance._classmateList = ShituRoleList.new()
    instance._receivedAward = {}
  end
  return instance
end
def.method("=>", "table").GetMaster = function(self)
  return self._master
end
def.method("table").SetMaster = function(self, master)
  self._master = master
end
def.method("=>", "boolean").HasMaster = function(self)
  return self._master ~= nil and not Int64.eq(self._master.roleId, 0)
end
def.method("number").SetChushiState = function(self, chushiState)
  self._isChushiState = chushiState
end
def.method("=>", "boolean").IsChushi = function(self)
  return self._isChushiState == ShiTuConst.YES_CHU_SHI
end
def.method("number").SetPayRespectTimes = function(self, times)
  self._currentPayRespectTimes = times
end
def.method("=>", "number").GetPayRespectTimes = function(self)
  return self._currentPayRespectTimes
end
def.method().AddPayRespectTimes = function(self)
  self._currentPayRespectTimes = self._currentPayRespectTimes + 1
end
def.method().ResetPayRespectTimes = function(self)
  self._currentPayRespectTimes = 0
end
def.method("=>", "boolean").HasPayRespectTimes = function(self)
  if not self:HasMaster() then
    return false
  end
  if self:IsChushi() then
    return false
  end
  return self._currentPayRespectTimes < constant.ShiTuConsts.payRespectMaxTimes
end
def.method("table").SetNowApprentice = function(self, apprenticeList)
  self._apprenticeList:SetNowList(apprenticeList)
end
def.method("table").AddApprentice = function(self, role)
  self._apprenticeList:AddRoleToNowList(role)
end
def.method("table").AddChushiApprentice = function(self, chushiList)
  self._apprenticeList:AddRoleListToChushiList(chushiList)
end
def.method("userdata").RemoveNowApprenticeById = function(self, id)
  self._apprenticeList:RemoveRoleFromNowList(id)
end
def.method("=>", "number").GetNowApprenticeCount = function(self)
  return self._apprenticeList:GetNowListCount()
end
def.method("=>", "number").GetChushiApprenticeCount = function(self)
  return self:GetTotalApprenticeNum() - self:GetNowApprenticeCount()
end
def.method("number", "=>", "table").GetApprenticeByIdx = function(self, idx)
  return self._apprenticeList:GetRoleByIdx(idx)
end
def.method("userdata", "=>", "table").GetNowApprenticeById = function(self, roleId)
  return self._apprenticeList:GetNowRoleById(roleId)
end
def.method("number").SetTotalApprenticeNum = function(self, num)
  self._apprenticeList:SetActualTotalRoleCount(num)
end
def.method("=>", "number").GetTotalApprenticeNum = function(self)
  return self._apprenticeList:GetActualTotalRoleCount()
end
def.method("number").ChangeTotalApprenticeNum = function(self, delta)
  local preCnt = self._apprenticeList:GetActualTotalRoleCount()
  self._apprenticeList:SetActualTotalRoleCount(preCnt + delta)
end
def.method("=>", "number").GetCurrentCachedApprenticeCount = function(self)
  return self._apprenticeList:GetTotalCachedRoleCount()
end
def.method("=>", "number").GetNextCacheApprenticePos = function(self)
  return self._apprenticeList:GetChushiListCount()
end
def.method("=>", "boolean").HasNotCachedApprenticeData = function(self)
  return self:GetCurrentCachedApprenticeCount() < self:GetTotalApprenticeNum()
end
def.method().ClearCurrentCachedChushiApprentice = function(self)
  self._apprenticeList:ClearChushiList()
end
def.method("table").SetNowClassmates = function(self, classmates)
  self._classmateList:SetNowList(classmates)
end
def.method("table").AddChushiClassmates = function(self, classmates)
  self._classmateList:AddRoleListToChushiList(classmates)
end
def.method("=>", "number").GetNowClassmateCount = function(self)
  return self._classmateList:GetNowListCount()
end
def.method("=>", "number").GetCurrentCachedClassmateCount = function(self)
  return self._classmateList:GetTotalCachedRoleCount()
end
def.method("number", "=>", "table").GetClassmateByIdx = function(self, idx)
  return self._classmateList:GetRoleByIdx(idx)
end
def.method("=>", "number").GetNextClassmatePos = function(self)
  return self._classmateList:GetChushiListCount()
end
def.method("number").SetTotalClassmateCount = function(self, cnt)
  self._classmateList:SetActualTotalRoleCount(cnt)
end
def.method("=>", "number").GetTotalClassmateCount = function(self)
  return self._classmateList:GetActualTotalRoleCount()
end
def.method("=>", "boolean").HasNotCachedClassmateData = function(self)
  return self:GetCurrentCachedClassmateCount() < self:GetTotalClassmateCount()
end
def.method().ClearCurrentCachedClassmate = function(self)
  self._classmateList:ClearData()
end
def.method("table").SetCurrentSession = function(self, p)
  local session = {}
  session.masterRoleId = p.masterRoleId
  session.masterRoleName = p.masterRoleName
  session.sessionid = p.sessionid
  self._currentSession = session
end
def.method("=>", "table").GetCurrentSession = function(self)
  return self._currentSession
end
def.method().ClearSession = function(self)
  self._currentSession = nil
end
def.method().ClearData = function(self)
  self._master = nil
  self._apprenticeList:ClearData()
  self._classmateList:ClearData()
  self._currentSession = nil
  self._receivedAward = {}
end
def.method("table").SetReceivedAward = function(self, awards)
  for k, v in pairs(awards) do
    self._receivedAward[v] = v
  end
end
def.method("number", "=>", "boolean").HasReceiveAward = function(self, awardId)
  return self._receivedAward[awardId] ~= nil
end
def.method("number").ReceiveNewAward = function(self, awardId)
  self._receivedAward[awardId] = awardId
end
def.method("userdata", "=>", "boolean").IsShituRelationWithPlayer = function(self, roleId)
  return self:IsMyMaster(roleId) or self:IsMyApprentice(roleId)
end
def.method("userdata", "=>", "boolean").IsMyMaster = function(self, roleId)
  return self._master ~= nil and self._master.roleId == roleId
end
def.method("userdata", "=>", "boolean").IsMyApprentice = function(self, roleId)
  local roles = self._apprenticeList:GetNowRoleList()
  for i = 1, #roles do
    if roles[i].roleId == roleId then
      return true
    end
  end
  return false
end
ShituData.Commit()
return ShituData
