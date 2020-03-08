local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Top3Info = Lplus.Class(CUR_CLASS_NAME)
local def = Top3Info.define
def.field("number")._season = 0
def.field("boolean")._bTied1st = false
def.field("table")._corpsList = nil
def.final("table", "=>", Top3Info).New = function(p)
  local node = Top3Info()
  if p then
    node:_Init(p)
  end
  return node
end
def.method().Release = function(self)
  self._season = 0
  self._bTied1st = false
  self._corpsList = nil
end
def.method("table")._Init = function(self, p)
  self._season = p.session
  self._corpsList = {}
  self._bTied1st = self:_CheckIsTied1st(p)
  if self._bTied1st then
    self._corpsList[1] = p.second_place_corps[1]
    if self._corpsList[1] then
      self._corpsList[1].corps_rank = 2
    end
    self._corpsList[2] = p.second_place_corps[2]
    if self._corpsList[2] then
      self._corpsList[2].corps_rank = 2
    end
    self._corpsList[3] = p.third_place_corps[1]
    if self._corpsList[3] then
      self._corpsList[3].corps_rank = 3
    end
  else
    self._corpsList[1] = p.champion_corps[1]
    if self._corpsList[1] then
      self._corpsList[1].corps_rank = 1
    end
    self._corpsList[2] = p.second_place_corps[1]
    if self._corpsList[2] then
      self._corpsList[2].corps_rank = 2
    end
    self._corpsList[3] = p.third_place_corps[1]
    if self._corpsList[3] then
      self._corpsList[3].corps_rank = 3
    end
  end
end
def.method("table", "=>", "boolean")._CheckIsTied1st = function(self, top3Info)
  local result = false
  if top3Info and top3Info.second_place_corps and #top3Info.second_place_corps > 1 then
    return true
  end
  return result
end
def.method("=>", "boolean").IsTied1st = function(self)
  return self._bTied1st
end
def.method("=>", "number").GetSeason = function(self)
  return self._season
end
def.method("number", "=>", "table").GetCorpsBriefByIdx = function(self, idx)
  return self._corpsList[idx]
end
def.method("=>", "table").GetCorpsBriefList = function(self)
  return self._corpsList
end
return Top3Info.Commit()
