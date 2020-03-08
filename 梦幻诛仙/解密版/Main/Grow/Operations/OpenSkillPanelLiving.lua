local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenSkillPanel = import(".OpenSkillPanel")
local OpenSkillPanelLiving = Lplus.Extend(OpenSkillPanel, CUR_CLASS_NAME)
local SkillPanel = require("Main.Skill.ui.SkillPanel")
local def = OpenSkillPanelLiving.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = SkillPanel.NodeId.LivingSkillNode
  return OpenSkillPanel.Operate(self, params)
end
return OpenSkillPanelLiving.Commit()
