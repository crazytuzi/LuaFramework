require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Message.MessageNotes"
require "Core.Module.Message.View.MessagePanel"
require "Core.Module.Message.View.NewFeaturePanel"
require "Core.Module.Message.View.OffLinePanel"


MessageMediator = Mediator:New();

function MessageMediator:OnRegister()
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_TIPS, MessageMediator.OnShowTips, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_NOTICE, MessageMediator.OnShowNotice, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_MARQUEE, MessageMediator.OnShowMarquee, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_PROPS, MessageMediator.OnShowProps, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_TRUMPET, MessageMediator.OnShowTrumpet, self);

	MessageManager.AddListener(PlayerManager, PlayerManager.SELFFIGHTCHANGE, MessageMediator.OnFightChg, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_ADDATTRS, MessageMediator.OnShowAddAttrs, self);
	MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_ALERT, MessageMediator.OnShowAlert, self);
	-- MessageManager.AddListener(MessageNotes, MessageNotes.ENV_SHOW_BUBBLING, MessageMediator.OnShowBubbling, self);
	
	
end
local notification = {
	MessageNotes.SHOW_NEW_SYS_TIP,
	MessageNotes.CLOSE_NEW_SYS_TIP,
	MessageNotes.CLOSE_MESSAGE_PANEL,
	MessageNotes.SHOW_OFFLINE_PANEL,
	MessageNotes.CLOSE_OFFLINE_PANEL,
	MessageNotes.UPDATE_OFFLINE_PANEL,	
};
function MessageMediator:_ListNotificationInterests()
	return notification
end

function MessageMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == MessageNotes.SHOW_NEW_SYS_TIP then
		if(self._newSysTipsPanel == nil) then
			self._newSysTipsPanel = PanelManager.BuildPanel(ResID.UI_NEWFEATUREPANEL, NewFeaturePanel, false, MessageNotes.CLOSE_NEW_SYS_TIP);			
		end
		self._newSysTipsPanel:ShowFeature(notification:GetBody());
	elseif notificationName == MessageNotes.CLOSE_NEW_SYS_TIP then
		if(self._newSysTipsPanel ~= nil) then
			PanelManager.RecyclePanel(self._newSysTipsPanel, ResID.UI_NEWFEATUREPANEL)
			self._newSysTipsPanel = nil
		end
	elseif notificationName == MessageNotes.CLOSE_MESSAGE_PANEL then
		self:ClosePanel();
		
	elseif notificationName == MessageNotes.SHOW_OFFLINE_PANEL then
		if(self._offLinePanel == nil) then
			self._offLinePanel = PanelManager.BuildPanel(ResID.UI_OFFLINEPANEL, OffLinePanel, false, MessageNotes.CLOSE_OFFLINE_DATA_PANEL);			
		end
	elseif notificationName == MessageNotes.CLOSE_OFFLINE_PANEL then
		self:CloseOffLinePanel();
		
		--添加坐骑窗口显示判断
		-- if(RideManager.GetIsRideExpired()) then
		-- 	ModuleManager.SendNotification(RideNotes.OPEN_RIDEEXPIRED)
		-- elseif RideManager.GetIsRideBecomeExpired() then
		-- 	ModuleManager.SendNotification(RideNotes.OPEN_RIDEBECOMEEXPIRED)			
		-- end
		ModuleManager.SendNotification(RideNotes.OPEN_RIDEREUSEPANEL)
	elseif notificationName == MessageNotes.UPDATE_OFFLINE_PANEL then
		if(self._offLinePanel ~= nil) then
			self._offLinePanel:UpdateDisplay()		
		end
	end
end

function MessageMediator:OnRemove()
	self:ClosePanel();
	self:CloseOffLinePanel();
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_TIPS, MessageMediator.OnShowTips);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_NOTICE, MessageMediator.OnShowNotice);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_MARQUEE, MessageMediator.OnShowMarquee);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_PROPS, MessageMediator.OnShowProps);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_TRUMPET, MessageMediator.OnShowTrumpet);

	MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFFIGHTCHANGE, MessageMediator.OnFightChg);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_ADDATTRS, MessageMediator.OnShowAddAttrs);
	MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_ALERT, MessageMediator.OnShowAlert);
	--MessageManager.RemoveListener(MessageNotes, MessageNotes.ENV_SHOW_BUBBLING, MessageMediator.OnShowBubbling);
	
end

 
function MessageMediator:CheckPanel()
	if(self._panel == nil) then
		self._panel = PanelManager.BuildPanel(ResID.UI_MESSAGPANEL, MessagePanel, false, MessageNotes.CLOSE_MESSAGE_PANEL);
		--        self._panel = PanelManager.BuildPanel(ResID.UI_MESSAGPANEL, MessagePanel);
	end
end

function MessageMediator:ClosePanel()
	if self._panel then
		PanelManager.RecyclePanel(self._panel, ResID.UI_MESSAGPANEL);
		self._panel = nil;
	end
end

function MessageMediator:CloseOffLinePanel()
	if(self._offLinePanel ~= nil) then
		PanelManager.RecyclePanel(self._offLinePanel, ResID.UI_OFFLINEPANEL)
		self._offLinePanel = nil
	end
end

--属性战斗力发送变化.
function MessageMediator:OnFightChg(data)
	 
	if data.notShow then
		return;
	end

	if(PlayerManager.CanShowFight() == false) then
		return 
	end
	
	self:CheckPanel();
	local power = data.change;
	
	if power > 0 then
		self._panel:UpdateFight(power);
	end
end
--显示提示
function MessageMediator:OnShowTips(data)
	self:CheckPanel();
	self._panel:ShowTips(data);
end
--显示公告
function MessageMediator:OnShowNotice(data)
	self:CheckPanel();
	self._panel:ShowNotice(data);
end
--显示跑马灯
function MessageMediator:OnShowMarquee(data)
	self:CheckPanel();
	self._panel:ShowMarquee(data);
end

function MessageMediator:OnShowProps(ds)
	self:CheckPanel();
	self._panel:ShowProps(ds);
end

function MessageMediator:OnShowTrumpet(data)
	self:CheckPanel();
	self._panel:ShowTrumpet(data);
end

function MessageMediator:OnShowAddAttrs(data)
	self:CheckPanel();
	self._panel:ShowAddAttr(data)
end

function MessageMediator:OnShowAlert(data)
	self:CheckPanel();
	self._panel:ShowAlert(data)
end
