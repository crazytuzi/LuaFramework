require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Countdown.CountdownNotes"
require "Core.Module.Countdown.View.CountdownTimePanel"
require "Core.Module.Countdown.View.CountdownBarPanel"

CountdownMediator = Mediator:New();
function CountdownMediator:OnRegister()
	
end

function CountdownMediator:_ListNotificationInterests()
	return {
		[1] = CountdownNotes.OPEN_COUNTDONWNTIMENPANEL,
		[2] = CountdownNotes.CLOSE_COUNTDOWNTIMENPANEL,
		[3] = CountdownNotes.OPEN_COUNTDOWNBARNPANEL,
		[4] = CountdownNotes.CLOSE_COUNTDOWNBARNPANEL
	};
end

--[[    ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDONWNTIMENPANEL , {
    time = 20,
    title = "倒计时：",
    handler = function() self:_OnClickSignup() end;
    suspend = function() return self:_CheckTime() end
    })
]]
function CountdownMediator:_HandleNotification(notification)
	if notification:GetName() == CountdownNotes.OPEN_COUNTDONWNTIMENPANEL then
		if(self._timePanel == nil) then
			local data = notification:GetBody();
			if(data and data.time) then
				self._timePanel = PanelManager.BuildPanel(ResID.UI_COUNTDOWNTIMEPANEL, CountdownTimePanel, false);
				self._timePanel:SetData(data)
			end
		end
	elseif notification:GetName() == CountdownNotes.CLOSE_COUNTDOWNTIMENPANEL then
		if(self._timePanel ~= nil) then
			PanelManager.RecyclePanel(self._timePanel)
			self._timePanel = nil
		end
		
	elseif notification:GetName() == CountdownNotes.OPEN_COUNTDOWNBARNPANEL then
		if(self._barPanel == nil) then
			self._barPanel = PanelManager.BuildPanel(ResID.UI_COUNTDOWNBARPANEL, CountdownBarPanel, false, CountdownNotes.CLOSE_COUNTDOWNBARNPANEL);		
		end
		
		if(self._barPanel) then
			local data = notification:GetBody();
			if(data and data.time) then			
				self._barPanel:SetData(data)
			end
		end
	elseif notification:GetName() == CountdownNotes.CLOSE_COUNTDOWNBARNPANEL then
		if(self._barPanel ~= nil) then
			PanelManager.RecyclePanel(self._barPanel)
			self._barPanel = nil
		end
	end
end

function CountdownMediator:OnRemove()
	
end

