local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local SkillPanelNodeBase = Lplus.Extend(TabNode, "SkillPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local def = SkillPanelNodeBase.define
def.field("number").m_funcType = 0
def.virtual().InitUI = function(self)
end
def.virtual("table", "table").OnSilverMoneyChanged = function(self)
end
def.virtual().OnSkillNotifyUpdate = function(self)
end
def.virtual("=>", "boolean").IsUnlock = function(self)
  return false
end
def.override().OnHide = function(self)
  self:MarkSkillFuncUnlockOutOfDate()
end
def.virtual("=>", "boolean").HasNotify = function(self)
  return self:IsSkillFuncJustUnlock()
end
def.method("number").SetFuncType = function(self, funcType)
  self.m_funcType = funcType
end
def.method("=>", "boolean").IsSkillFuncJustUnlock = function(self)
  return SkillModule.Instance():IsSkillFuncJustUnlock(self.m_funcType)
end
def.method().MarkSkillFuncUnlockOutOfDate = function(self)
  SkillModule.Instance():MarkNewSkillFuncOpen(self.m_funcType, false)
  require("Main.Skill.SkillMgr").Instance():CheckNotify()
end
SkillPanelNodeBase.Commit()
return SkillPanelNodeBase
