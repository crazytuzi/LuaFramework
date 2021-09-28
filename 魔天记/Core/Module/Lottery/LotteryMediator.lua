require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Lottery.LotteryNotes"
require "Core.Module.Lottery.View.LotteryPanel"
require "Core.Module.Lottery.View.LotteryResultPanel"
require "Core.Module.Lottery.View.LotteryPreviewPanel"


LotteryMediator = Mediator:New();
function LotteryMediator:OnRegister()
	
end

local notes = {
	LotteryNotes.OPEN_LOTTERYPANEL,
	LotteryNotes.CLOSE_LOTTERYPANEL,
	LotteryNotes.UPDATE_LOTTERYPANEL,
	
	LotteryNotes.OPEN_LOTTERYRESULTPANEL,
	LotteryNotes.CLOSE_LOTTERYRESULTPANEL,
	LotteryNotes.UPDATE_LOTTERYRESULTPANEL,
	
	LotteryNotes.OPEN_LOTTERYPREVIEWPANEL,
	LotteryNotes.CLOSE_LOTTERYPREVIEWPANEL,
	LotteryNotes.UPDATE_SCROLLVIEW,
}

function LotteryMediator:_ListNotificationInterests()
	return notes
end

function LotteryMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == LotteryNotes.OPEN_LOTTERYPANEL) then
		if(self._lotteryPanel == nil) then
			self._lotteryPanel = PanelManager.BuildPanel(ResID.UI_LOTTERYPANEL, LotteryPanel, true);
		end
		self._lotteryPanel:UpdatePanelInfo()
	elseif(notificationName == LotteryNotes.CLOSE_LOTTERYPANEL) then
		if(self._lotteryPanel ~= nil) then
			PanelManager.RecyclePanel(self._lotteryPanel, ResID.UI_LOTTERYPANEL)
			self._lotteryPanel = nil;
		end
	elseif(notificationName == LotteryNotes.UPDATE_LOTTERYPANEL) then
		if(self._lotteryPanel ~= nil) then
			self._lotteryPanel:UpdatePanelInfo()
		end
	elseif(notificationName == LotteryNotes.OPEN_LOTTERYRESULTPANEL) then
		if(self._lotteryResultPanel == nil) then
			self._lotteryResultPanel = PanelManager.BuildPanel(ResID.UI_LOTTERYRESULTPANEL, LotteryResultPanel);
		end
		
		self._lotteryResultPanel:UpdatePanel();
	elseif(notificationName == LotteryNotes.CLOSE_LOTTERYRESULTPANEL) then
		if(self._lotteryResultPanel ~= nil) then
			PanelManager.RecyclePanel(self._lotteryResultPanel, ResID.UI_LOTTERYRESULTPANEL)
			self._lotteryResultPanel = nil
		end
	elseif(notificationName == LotteryNotes.UPDATE_LOTTERYRESULTPANEL) then
		if(self._lotteryResultPanel ~= nil) then
			self._lotteryResultPanel:UpdatePanel();
		end
	elseif(notificationName == LotteryNotes.OPEN_LOTTERYPREVIEWPANEL) then
		if(self._lotteryPreviewPanel == nil) then
			self._lotteryPreviewPanel = PanelManager.BuildPanel(ResID.UI_LOTTERYPREVIEWPANEL, LotteryPreviewPanel);
		end
		
	elseif(notificationName == LotteryNotes.CLOSE_LOTTERYPREVIEWPANEL) then
		if(self._lotteryPreviewPanel ~= nil) then
			PanelManager.RecyclePanel(self._lotteryPreviewPanel, ResID.UI_LOTTERYPREVIEWPANEL)
			self._lotteryPreviewPanel = nil;
		end
	elseif(notificationName == LotteryNotes.UPDATE_SCROLLVIEW) then
		if(self._lotteryResultPanel) then			
			self._lotteryResultPanel:MoveNext()
		end
	end
end

function LotteryMediator:OnRemove()
	if(self._lotteryPanel ~= nil) then
		PanelManager.RecyclePanel(self._lotteryPanel, ResID.UI_LOTTERYPANEL)
		self._lotteryPanel = nil
	end
	
	if(self._lotteryResultPanel ~= nil) then
		PanelManager.RecyclePanel(self._lotteryResultPanel, ResID.UI_LOTTERYRESULTPANEL)
		self._lotteryResultPanel = nil
	end
	
	if(self._lotteryPreviewPanel ~= nil) then
		PanelManager.RecyclePanel(self._lotteryPreviewPanel, ResID.UI_LOTTERYPREVIEWPANEL)
		self._lotteryPreviewPanel = nil;
	end
end

