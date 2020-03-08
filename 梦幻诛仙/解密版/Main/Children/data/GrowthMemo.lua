local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GrowthMemo = Lplus.Class(MODULE_NAME)
local BaseMemoUnit = require("Main.Children.memo_unit.BaseMemoUnit")
local def = GrowthMemo.define
local ChildOwner = Lplus.Class(MODULE_NAME .. ".ChildOwner")
do
  local def = ChildOwner.define
  def.field("userdata").m_id = nil
  def.field("string").m_name = ""
  def.static("userdata", "string", "=>", ChildOwner).new = function(id, name)
    local obj = ChildOwner()
    obj.m_id = id
    obj.m_name = name
    return obj
  end
  def.method("=>", "userdata").GetId = function(self)
    return self.m_id
  end
  def.method("=>", "string").GetName = function(self)
    return self.m_name
  end
end
ChildOwner.Commit()
def.const("table").ChildOwner = ChildOwner
def.field("userdata").m_childId = nil
def.field("table").m_childOwners = nil
def.field("table").m_memoUnits = nil
def.field("userdata").m_birthTime = nil
def.field("userdata").m_enterChildhoodTime = nil
def.field("userdata").m_enterAdultTime = nil
def.field("userdata").m_lastModifyTime = nil
def.final("userdata", "=>", GrowthMemo).new = function(childId)
  local memo = GrowthMemo()
  memo.m_childId = childId
  memo.m_lastModifyTime = Int64.new(0)
  return memo
end
def.method("=>", "userdata").GetChildId = function(self)
  return self.m_childId
end
def.method("=>", "table").GetChildOwners = function(self)
  return self.m_childOwners or {}
end
def.method("=>", "table").GetMemoUnits = function(self)
  return self.m_memoUnits or {}
end
def.method("=>", "userdata").GetBirthTime = function(self)
  return self.m_birthTime
end
def.method("=>", "userdata").GetEnterChildhoodTime = function(self)
  return self.m_enterChildhoodTime
end
def.method("=>", "userdata").GetEnterAdultTime = function(self)
  return self.m_enterAdultTime
end
def.method("table").SetChildOwners = function(self, childOwners)
  self.m_childOwners = childOwners
end
def.method(ChildOwner).AddChildOwner = function(self, childOwner)
  self.m_childOwners = self.m_childOwners or {}
  self.m_childOwners[#self.m_childOwners + 1] = childOwner
end
def.method("table").SetMemoUnits = function(self, memoUnits)
  self.m_memoUnits = memoUnits
end
def.method(BaseMemoUnit).AppendMemoUnit = function(self, memoUnit)
  self.m_memoUnits = self.m_memoUnits or {}
  self.m_memoUnits[#self.m_memoUnits + 1] = memoUnit
end
def.method("number", BaseMemoUnit).InsertMemoUnit = function(self, index, memoUnit)
  self.m_memoUnits = self.m_memoUnits or {}
  if index < 1 or index > #self.m_memoUnits + 1 then
    error(string.format("index invalid, [%d, %d] excpeted, got %d", 1, #self.m_memoUnits + 1, index))
  end
  self.m_memoUnits[#self.m_memoUnits + 1] = memoUnit
end
def.method("userdata").SetBirthTime = function(self, birthTime)
  self.m_birthTime = birthTime
end
def.method("userdata").SetEnterChildhoodTime = function(self, enterChildhoodTime)
  self.m_enterChildhoodTime = enterChildhoodTime
end
def.method("userdata").SetEnterAdultTime = function(self, enterAdultTime)
  self.m_enterAdultTime = enterAdultTime
end
def.method().UpdateModifyTime = function(self)
  self.m_lastModifyTime = Int64.new(_G.GetServerTime())
end
def.method("=>", "userdata").GetLastModifyTime = function(self)
  return self.m_lastModifyTime
end
return GrowthMemo.Commit()
