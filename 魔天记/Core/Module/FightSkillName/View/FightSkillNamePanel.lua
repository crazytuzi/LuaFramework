require "Core.Module.Common.Panel"

FightSkillNamePanel = class("FightSkillNamePanel", Panel);

function FightSkillNamePanel:New()
	self = { };
	setmetatable(self, { __index = FightSkillNamePanel });
	return self
end

function FightSkillNamePanel:IsFixDepth()
	return true;
end

function FightSkillNamePanel:GetUIOpenSoundName( )
    return ""
end 


function FightSkillNamePanel:_Init()    
	self:_InitReference();
end

function FightSkillNamePanel:IsPopup()
    return false
end

function FightSkillNamePanel:_InitReference()
    self._txtSkillName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtSkillName");
	self._animator = UIUtil.GetChildByName(self._trsContent, "Animator", "txtSkillName");
--	if (self._animator) then
--		self._timer = FixedTimer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
--		self._timer:Start();
--	end
end

function FightSkillNamePanel:SetSkillName(name)
    if (self._txtSkillName) then
        self._txtSkillName.text = name;
        self._animator:Play("start")
    end
end

function FightSkillNamePanel:_OnTimerHandler()
	local info = self._animator:GetCurrentAnimatorStateInfo(0);
	if (info.normalizedTime >= 1) then
		self._timer:Stop();
		self._timer = nil;
		ModuleManager.SendNotification(FightAlertNotes.CLOSE_FIGHTALERT);
	end
end

function FightSkillNamePanel:_Dispose()
	if (self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
    self._txtSkillName = nil;
	self._animator = nil;
end