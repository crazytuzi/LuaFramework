local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = Lplus.Class(CUR_CLASS_NAME)
local def = RankListData.define
def.field("number")._rankType = 0
def.field("table")._rankList = nil
def.final("number", "=>", RankListData).New = function(type)
  local listData = RankListData()
  listData._rankType = type
  listData._rankList = {}
  return listData
end
def.method().Release = function(self)
  self._rankType = 0
  self._rankList = nil
end
def.method("table").UnmarshalProtocol = function(self, p)
  warn(string.format("[RankListData:UnmarshalProtocol] Unmarshal from [%d] to [%d].", p.from, p.to))
  self._rankList = self._rankList or {}
  local curCount = self:GetCount()
  if curCount > p.to then
    for rank = p.to + 1, curCount do
      self._rankList[rank] = nil
    end
  end
  for rank = p.from, p.to do
    local index = rank - p.from + 1
    self._rankList[rank] = p.point_race_ranks[index]
  end
end
def.method("=>", "number").GetCount = function(self)
  return self._rankList and #self._rankList or 0
end
def.method("number", "=>", "table").GetData = function(self, index)
  return self._rankList and self._rankList[index] or nil
end
return RankListData.Commit()
