local Lplus = require("Lplus")
local MathHelper = require("Common.MathHelper")
local FabaoData = Lplus.Class("FabaoData")
local def = FabaoData.define
def.field("table").m_CurFabaoData = nil
def.field("table").m_CurLongJingData = nil
def.field("number").m_CurDisplayFabaoType = 0
local instance
def.static("=>", FabaoData).Instance = function()
  if nil == instance then
    instance = FabaoData()
  end
  return instance
end
def.method("table", "table", "number").SetAllData = function(self, fabaoData, longjingData, disFabaoType)
  self:SetDisplayFabaoType(disFabaoType)
  self:SetFabaoData(fabaoData)
  self:SetLongJingData(longjingData)
end
def.method("number").SetDisplayFabaoType = function(self, disFabaoType)
  self.m_CurDisplayFabaoType = disFabaoType
end
def.method("table").SetFabaoData = function(self, data)
  if nil == data then
    return
  end
  if nil == self.m_CurFabaoData then
    self.m_CurFabaoData = {}
  end
  for k, v in pairs(data) do
    self.m_CurFabaoData[k] = v
  end
end
def.method("table").SetLongJingData = function(self, longjingData)
  if nil == longjingData then
    return
  end
  if nil == self.m_CurLongJingData then
    self.m_CurLongJingData = {}
  end
  for k, v in pairs(longjingData) do
    self.m_CurLongJingData[k] = v.longjingItems
  end
end
def.method("table").RemoveFabao = function(self, typeSet)
  if nil == self.m_CurFabaoData then
    return
  end
  if nil == typeSet then
    return
  end
  for k, v in pairs(typeSet) do
    self.m_CurFabaoData[v] = nil
  end
end
def.method("table").ChangeFabaoData = function(self, fabaoChangeData)
  if nil == fabaoChangeData then
    return
  end
  local changeInfo = fabaoChangeData.changed
  local removeInfo = fabaoChangeData.removed
  if removeInfo then
    self:RemoveFabao(removeInfo)
  end
  if changeInfo then
    if nil == self.m_CurFabaoData then
      self.m_CurFabaoData = {}
    end
    for k, v in pairs(changeInfo) do
      self.m_CurFabaoData[k] = v
    end
  end
end
def.method("table").ChangeLongJingData = function(self, changeData)
  if nil == changeData then
    return
  end
  local totalChangeInfo = changeData.longJingChangeInfo.changed
  for k, v in pairs(totalChangeInfo) do
    local removeInfo = v.remPositions
    local changeInfo = v.changed
    if removeInfo and self.m_CurLongJingData and self.m_CurLongJingData[k] then
      for _, pos in pairs(removeInfo) do
        self.m_CurLongJingData[k][pos] = nil
      end
    end
    if changeInfo then
      if nil == self.m_CurLongJingData then
        self.m_CurLongJingData = {}
      end
      if nil == self.m_CurLongJingData[k] then
        self.m_CurLongJingData[k] = {}
      end
      for kpos, longjingInfo in pairs(changeInfo) do
        self.m_CurLongJingData[k][kpos] = longjingInfo
      end
    end
  end
end
def.method("=>", "table").GetAllFabaoData = function(self)
  return self.m_CurFabaoData
end
def.method("number", "=>", "table").GetFabaoByType = function(self, fabaoType)
  if nil == self.m_CurFabaoData then
    return nil
  end
  return self.m_CurFabaoData[fabaoType]
end
def.method("=>", "table").GetAllLongJingData = function(self)
  return self.m_CurLongJingData
end
def.method("number", "=>", "table").GetLongJingByType = function(self, fabaoType)
  if nil == self.m_CurLongJingData then
    return nil
  end
  return self.m_CurLongJingData[fabaoType]
end
def.method("number", "number", "=>", "table").GetLongJingByTypeAndPos = function(self, fabaoType, pos)
  if nil == self.m_CurLongJingData then
    return nil
  end
  if nil == self.m_CurLongJingData[fabaoType] then
    return nil
  end
  return self.m_CurLongJingData[fabaoType][pos]
end
def.method("=>", "number").GetDisplayFabaoType = function(self)
  return self.m_CurDisplayFabaoType
end
def.method("=>", "table").GetCurDisplayFabao = function(self)
  if nil == self.m_CurFabaoData then
    return nil
  end
  local disType = self:GetDisplayFabaoType()
  local fabaoData = self:GetFabaoByType(disType)
  local data = {}
  data.fabaoType = disType
  data.fabaoData = fabaoData
  return data
end
def.method("userdata", "=>", "boolean").IsWearOnFabao = function(self, uuid)
  if nil == self.m_CurFabaoData then
    return false
  end
  for fabaoType, fabaoInfo in pairs(self.m_CurFabaoData) do
    if fabaoInfo.uuid[1]:eq(uuid) then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean", "number").IsLongjingFullOnType = function(self, fabaoType)
  local longjingData = self:GetLongJingByType(fabaoType)
  if nil == longjingData then
    return false, 1
  end
  local longjingCount = MathHelper.CountTable(longjingData)
  if 0 == longjingCount then
    return false, 1
  end
  for i = 1, 3 do
    if nil == longjingData[i] then
      return false, i
    end
  end
  return true, 0
end
def.method("number", "=>", "boolean").IsLongjingEmptyOnType = function(self, fabaoType)
  local longjingData = self:GetLongJingByType(fabaoType)
  if nil == longjingData then
    return true
  end
  local longjingCount = MathHelper.CountTable(longjingData)
  if 0 == longjingCount then
    return true
  end
  for k, v in pairs(longjingData) do
    if nil ~= v then
      return false
    end
  end
  return true
end
def.method().Clear = function(self)
  self.m_CurFabaoData = nil
  self.m_CurLongJingData = nil
  self.m_CurDisplayFabaoType = 0
end
def.method().printfabaoInfo = function(self)
  warn("=========================start============================")
  if self.m_CurFabaoData then
    for k, v in pairs(self.m_CurFabaoData) do
      warn("fabaoData is ", k, " ", v.id)
    end
  else
    warn("cur fabao data is nil ~~~~~~~~~~~~")
  end
  warn("=====================================================")
  if self.m_CurLongJingData then
    for k, v in pairs(self.m_CurLongJingData) do
      warn("longjingData is ", k, " ", v)
      if v then
        for k1, v1 in pairs(v) do
          warn("           longjinginfo is : ", k1, " ", v1.id)
        end
      end
    end
  end
  warn("display fabao is ~~~~~ ", self.m_CurDisplayFabaoType)
  warn("==========================end===========================")
end
FabaoData.Commit()
return FabaoData
