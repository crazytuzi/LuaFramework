local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenSkillPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local SkillPanel = require("Main.Skill.ui.SkillPanel")
local def = OpenSkillPanel.define
def.field("number").nodeId = SkillPanel.NodeId.OccupationSkillNode
def.override("table", "=>", "boolean").Operate = function(self, params)
  SkillPanel.Instance():ShowPanel(self.nodeId)
  return false
end
return OpenSkillPanel.Commit()
