require "Core.Module.Common.Panel"
require "Core.Module.FightAlert.FightAlertNotes";

FightAlertPanel = class("FightAlertPanel", Panel);
FightAlertPanel.FLASHCOUNT = 4
function FightAlertPanel:New()
	self = { };
	setmetatable(self, { __index = FightAlertPanel });
	return self
end

function FightAlertPanel:IsFixDepth()
	return true;
end

function FightAlertPanel:GetUIOpenSoundName( )
    return ""
end 


function FightAlertPanel:_Init()
	self:_InitReference();
end

function FightAlertPanel:_InitReference()
	self._animator = UIUtil.GetChildByName(self._trsContent, "Animator", "imgFlash");
	if (self._animator) then
		self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0.2, -1, false);
		self._timer:Start();
	end
end

function FightAlertPanel:_OnTimerHandler()
	local info = self._animator:GetCurrentAnimatorStateInfo(0);
	if (info.normalizedTime >= FightAlertPanel.FLASHCOUNT) then
		self._timer:Stop();
		self._timer = nil;
		ModuleManager.SendNotification(FightAlertNotes.CLOSE_FIGHTALERT);
	end
end

function FightAlertPanel:_Dispose()
	if (self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
    self._animator = nil;
end