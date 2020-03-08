local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local JZJXMapData = Lplus.Class(CUR_CLASS_NAME)
local def = JZJXMapData.define
def.field("boolean").isAwarded = false
def.field("number").mapid = 0
def.field("table").progresses = nil
def.field("boolean").isDefeatBoss = false
def.method("table").RawSet = function(self, p)
  self.isAwarded = p.awarded == p.class.AWARDED
  self.mapid = p.mapid or 0
  self.progresses = p.processes
end
return JZJXMapData.Commit()
