local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenSkillPanel = import(".OpenSkillPanel")
local OpenSkillPanelGang = Lplus.Extend(OpenSkillPanel, CUR_CLASS_NAME)
local SkillPanel = require("Main.Skill.ui.SkillPanel")
local def = OpenSkillPanelGang.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = SkillPanel.NodeId.GangSkillNode
  return OpenSkillPanel.Operate(self, params)
end
return OpenSkillPanelGang.Commit()
