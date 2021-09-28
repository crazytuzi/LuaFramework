require "Core.Module.Common.Panel"
require "Core.Module.Pet.PetNotes"

SkillTipPanel = class("SkillTipPanel", Panel);
function SkillTipPanel:New()
	self = {};
	setmetatable(self, {__index = SkillTipPanel});
	return self
end


function SkillTipPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SkillTipPanel:GetUIOpenSoundName()
	return ""
end

function SkillTipPanel:_InitReference()
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._txtGet = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtGet")
	self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "icon")
end

function SkillTipPanel:_InitListener()
	
end

function SkillTipPanel:_Dispose()
	self:_DisposeReference();
end

function SkillTipPanel:_DisposeReference()
	
end

--d:{ icon_id, name, desc, getDes}
function SkillTipPanel:UpdatePanel(d)
	self._imgIcon.spriteName = d.icon_id
	self._txtName.text = d.name
	self._txtDes.text = d.desc
	self._txtGet.text = d.getDes
end

function SkillTipPanel:_OnClickMask()
	ModuleManager.SendNotification(MainUINotes.CLOSE_SKILL_TIP_PANEL)
end

