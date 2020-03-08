local Lplus = require("Lplus")
local InstanceConfigChange = Lplus.Class("InstanceNotify.InstanceConfigChange")
do
  local def = InstanceConfigChange.define
  def.field("number").tid = 0
  def.static("number", "=>", InstanceConfigChange).new = function(tid)
    local obj = InstanceConfigChange()
    obj.tid = tid
    return obj
  end
end
InstanceConfigChange.Commit()
local InstanceHeroTrial = Lplus.Class("InstanceNotify.InstanceHeroTrial")
do
  local def = InstanceHeroTrial.define
  def.field("number").hero = 0
  def.field("number").remains = 0
  def.static("number", "number", "=>", InstanceHeroTrial).new = function(hero, remains)
    local obj = InstanceHeroTrial()
    obj.hero = hero
    obj.remains = remains
    return obj
  end
end
InstanceHeroTrial.Commit()
return {InstanceConfigChange = InstanceConfigChange, InstanceHeroTrial = InstanceHeroTrial}
