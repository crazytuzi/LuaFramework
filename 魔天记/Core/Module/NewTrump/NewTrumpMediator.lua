require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.NewTrump.NewTrumpNotes"
require "Core.Module.NewTrump.View.NewTrumpPanel"
require "Core.Module.NewTrump.View.NewTrumpActivePanel"
require "Core.Module.NewTrump.View.NewTrumpNoticePanel"
require "Core.Module.NewTrump.View.MobaoActivePanel"
require "Core.Module.NewTrump.View.MobaoNoticePanel"

NewTrumpMediator = Mediator:New();
local notes =
{
	NewTrumpNotes.OPEN_NEWTRUMPPANEL,
	NewTrumpNotes.CLOSE_NEWTRUMPPANEL,
	NewTrumpNotes.UPDATE_NEWTRUMPPANEL,
	NewTrumpNotes.UPDATE_NEWTRUMPSELECTREFINEINFO,
	NewTrumpNotes.OPEN_NEWTRUMPACTIVEPANEL,
	NewTrumpNotes.CLOSE_NEWTRUMPACTIVEPANEL,
	NewTrumpNotes.OPEN_NEWTRUMPNOTICEPANEL,
	NewTrumpNotes.CLOSE_NEWTRUMPNOTICEPANEL,
	NewTrumpNotes.SHOW_REFINEEFFECT
    ,NewTrumpNotes.OPEN_MOBAO_NOTICE 
    ,NewTrumpNotes.CLOSE_MOBAO_NOTICE
    ,NewTrumpNotes.OPEN_MOBAO_ACTIVE 
    ,NewTrumpNotes.CLOSE_MOBAO_ACTIVE
}
function NewTrumpMediator:OnRegister()
	
end

function NewTrumpMediator:_ListNotificationInterests()
	return notes
end

function NewTrumpMediator:_HandleNotification(notification)
	local name = notification:GetName()
	if(name == NewTrumpNotes.OPEN_NEWTRUMPPANEL) then
		if(self._newTrumpPanel == nil) then
			self._newTrumpPanel = PanelManager.BuildPanel(ResID.UI_NewTrumpPanel, NewTrumpPanel, true)
		end
		local tab = notification:GetBody();
		self._newTrumpPanel:OpenSubPanel(tab);
	elseif(name == NewTrumpNotes.CLOSE_NEWTRUMPPANEL) then
		if(self._newTrumpPanel ~= nil) then
			PanelManager.RecyclePanel(self._newTrumpPanel, ResID.UI_NewTrumpPanel)
			self._newTrumpPanel = nil
		end
	elseif(name == NewTrumpNotes.SHOW_REFINEEFFECT) then	 
		if(self._newTrumpPanel ~= nil) then		 
			self._newTrumpPanel:PlayUIEffect(notification:GetBody())
		end
	elseif(name == NewTrumpNotes.UPDATE_NEWTRUMPPANEL) then
		if(self._newTrumpPanel ~= nil) then
			self._newTrumpPanel:UpdatePanel()
		end
	elseif(name == NewTrumpNotes.UPDATE_NEWTRUMPSELECTREFINEINFO) then
		if(self._newTrumpPanel ~= nil) then
			self._newTrumpPanel:UpdateTrumpSelectRefineInfo()
		end
	elseif(name == NewTrumpNotes.OPEN_NEWTRUMPACTIVEPANEL) then
		if(self._newTrumpActivePanel == nil) then
			self._newTrumpActivePanel = PanelManager.BuildPanel(ResID.UI_NewTrumpActivePanel, NewTrumpActivePanel, false, NewTrumpNotes.CLOSE_NEWTRUMPACTIVEPANEL)
			self._newTrumpActivePanel:UpdatePanel(notification:GetBody())
		end
	elseif(name == NewTrumpNotes.CLOSE_NEWTRUMPACTIVEPANEL) then
		if(self._newTrumpActivePanel ~= nil) then
			PanelManager.RecyclePanel(self._newTrumpActivePanel, ResID.UI_NewTrumpActivePanel)
			self._newTrumpActivePanel = nil
		end
	elseif(name == NewTrumpNotes.OPEN_NEWTRUMPNOTICEPANEL) then
		if(self._newTrumpNoticePanel == nil) then
			self._newTrumpNoticePanel = PanelManager.BuildPanel(ResID.UI_NewTrumpNoticePanel, NewTrumpNoticePanel, false, NewTrumpNotes.CLOSE_NEWTRUMPNOTICEPANEL)
		end
		self._newTrumpNoticePanel:UpdatePanel(notification:GetBody())
	elseif(name == NewTrumpNotes.CLOSE_NEWTRUMPNOTICEPANEL) then
		if(self._newTrumpNoticePanel ~= nil) then
			PanelManager.RecyclePanel(self._newTrumpNoticePanel, ResID.UI_NewTrumpNoticePanel)
			self._newTrumpNoticePanel = nil
		end

	elseif(name == NewTrumpNotes.OPEN_MOBAO_NOTICE) then
		if(self._mobaoNoticePanel == nil) then
			self._mobaoNoticePanel = PanelManager.BuildPanel(ResID.UI_MOBAO_NOTICE, MobaoNoticePanel, false, NewTrumpNotes.CLOSE_MOBAO_NOTICE)
		end
		self._mobaoNoticePanel:UpdatePanel(notification:GetBody())
	elseif(name == NewTrumpNotes.CLOSE_MOBAO_NOTICE) then
		if(self._mobaoNoticePanel ~= nil) then
			PanelManager.RecyclePanel(self._mobaoNoticePanel, ResID.UI_MOBAO_NOTICE)
			self._mobaoNoticePanel = nil
		end
	elseif(name == NewTrumpNotes.OPEN_MOBAO_ACTIVE) then
		if(self._mobaoActivePanel == nil) then
			self._mobaoActivePanel = PanelManager.BuildPanel(ResID.UI_MOBAO_ACTIVE, MobaoActivePanel, false, NewTrumpNotes.CLOSE_MOBAO_ACTIVE)
		end
		self._mobaoActivePanel:UpdatePanel(notification:GetBody())
	elseif(name == NewTrumpNotes.CLOSE_MOBAO_ACTIVE) then
		if(self._mobaoActivePanel ~= nil) then
			PanelManager.RecyclePanel(self._mobaoActivePanel, ResID.UI_MOBAO_ACTIVE)
			self._mobaoActivePanel = nil
		end
	end
end

function NewTrumpMediator:OnRemove()
	
end

