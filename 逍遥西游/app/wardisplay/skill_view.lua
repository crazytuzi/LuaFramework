local CSkillView = class("CSkillView", function()
  return Widget:create()
end)
function CSkillView:ctor(aiID)
  self.m_DisplayAIID = aiID
end
return CSkillView
