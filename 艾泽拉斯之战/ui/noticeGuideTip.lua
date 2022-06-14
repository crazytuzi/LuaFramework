local noticeGuideTip = class( "noticeGuideTip", layout );

global_event.NOTICE_GUIDETIP_SHOW = "NOTICE_GUIDETIP_SHOW";
global_event.NOTICE_GUIDETIP_HIDE = "NOTICE_GUIDETIP_HIDE";

function noticeGuideTip:ctor( id )
	noticeGuideTip.super.ctor( self, id );
	self:addEvent({ name = global_event.NOTICE_GUIDETIP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.NOTICE_GUIDETIP_HIDE, eventHandler = self.onHide});
end

function noticeGuideTip:onShow(event)
	if self._show then
		return;
	end
			
	self:Show();
	self.notice_notice = self:Child( "noticeGuideTip-noticeGuideTip" );
	self:updateInfo(event);
	--uiaction.popup(self._view);
end

function noticeGuideTip:onHide(event)
	--uiaction.goback(self._view, self);
	self:Close();
	
	--scheduler.performWithDelayGlobal(function ()
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_CLOSE_NOTICEGUIDETIP })
	--end, 0.1);
end

function noticeGuideTip:updateInfo(event)
	
	self.notice_notice:SetText(event.tip);		
	self.callBack = event.callBack
	
	local ui = event.ui or "noticeGuideTip1.dlg"	
	
	if(event.newUi )then
		local _ui = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("noticeGuideTip_", ui); 
		self._view:AddChildWindow(_ui)
	end
	

end

function noticeGuideTip:noticeOK()
	self:onHide();
	function noticeHandleOK()
		if(self.callBack)	then
			self.callBack()
		end	
	end
	--uiaction.goback(self._view, self, noticeHandleOK);
end

return noticeGuideTip;
