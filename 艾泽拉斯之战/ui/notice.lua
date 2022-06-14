local notice = class( "notice", layout );

global_event.NOTICE_SHOW = "NOTICE_SHOW";
global_event.NOTICE_HIDE = "NOTICE_HIDE";

function notice:ctor( id )
	notice.super.ctor( self, id );
	self:addEvent({ name = global_event.NOTICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.NOTICE_HIDE, eventHandler = self.onHide});
end

function notice:onShow(event)
	if self._show then
		return;
	end
			
	self:Show();

	self.notice_close = self:Child( "notice-close" );
	self.notice_notice = self:Child( "notice-notice" );
	self.notice_button_OK = self:Child( "notice-button-OK" );
	self.notice_close:subscribeEvent("ButtonClick", "onClickNoticeClose");
	self.notice_button_OK:subscribeEvent("ButtonClick", "onClicNoticeOK");

	self.notice_error_scroll = LORD.toScrollPane(self:Child("notice-error-scroll"));
	self.notice_error_scroll:init();
	
	function onClickNoticeClose()
		self:onHide();
	end
	
	function onClicNoticeOK()
		self:noticeOK();
	end
	
	-- event 是个table，包含的数据有data, textInfo, messageType
	-- 
	
	self:updateInfo(event);
	
	uiaction.popup(self._view);
end

function notice:onHide(event)
	--self:Close();
	uiaction.goback(self._view, self);
end

function notice:updateInfo(event)
	
	self.messageType = event.messageType;
	self.data = event.data;
		
	if self.messageType == enum.MESSAGE_BOX_TYPE.ERROR then
		
		local oldErrorText = LORD.GUIWindowManager:Instance():GetGUIWindow("notice-error-text");
		if oldErrorText then
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(oldErrorText);
			oldErrorText = nil;
		end
		
		local errorText = LORD.GUIWindowManager:Instance():CreateGUIWindow("StaticText", "notice-error-text");
		errorText:SetWidth(self.notice_error_scroll:GetWidth());
		errorText:SetProperty("TextWordWrap", "true");
		errorText:SetProperty("TextSelfAdaptHigh", "true");
		errorText:SetText(event.textInfo);
		self.notice_error_scroll:additem(errorText);
	else
		self.notice_notice:SetText(event.textInfo);
		--self.notice_button_OK:SetText("确定");			
		
	end
	self.callBack = event.callBack
end

function notice:noticeOK()
	
	--self:onHide();
	
	function noticeHandleOK()
		if self.messageType == enum.MESSAGE_BOX_TYPE.CANCEL_LEVEL_UP_BUILDING then
			-- 取消升级建筑的提示
			sendUpgradeBuild(1, self.data);
		elseif self.messageType == enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND then
			-- 钻石不足
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});		
		end
		
		if(self.callBack)	then
			self.callBack()
		end	
	end
	
	uiaction.goback(self._view, self, noticeHandleOK);
	
end

return notice;
