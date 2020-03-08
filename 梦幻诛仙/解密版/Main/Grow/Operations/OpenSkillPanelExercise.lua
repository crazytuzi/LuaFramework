local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenSkillPanel = import(".OpenSkillPanel")
local OpenSkillPanelExercise = Lplus.Extend(OpenSkillPanel, CUR_CLASS_NAME)
local SkillPanel = require("Main.Skill.ui.SkillPanel")
local def = OpenSkillPanelExercise.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = SkillPanel.NodeId.ExerciseSkillNode
  return OpenSkillPanel.Operate(self, params)
end
return OpenSkillPanelExercise.Commit()
