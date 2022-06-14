local messagebox = class( "messagebox", layout );

global_event.MESSAGEBOX_SHOW = "MESSAGEBOX_SHOW";
global_event.MESSAGEBOX_HIDE = "MESSAGEBOX_HIDE";

function messagebox:ctor( id )
	messagebox.super.ctor( self, id );
	self:addEvent({ name = global_event.MESSAGEBOX_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MESSAGEBOX_HIDE, eventHandler = self.onHide});
end

function messagebox:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.messagebox_notice = self:Child( "messagebox-notice" );
	self.messagebox_error_scroll = LORD.toScrollPane(self:Child( "messagebox-error-scroll" ));
	self.messagebox_button_OK = self:Child( "messagebox-button-OK" );
	self.messagebox_error_scroll:init();
	
	function onMessageBoxOK()
		self:onOK();
	end
	
	self:updateInfo(event);
	
	self.messagebox_button_OK:subscribeEvent("ButtonClick", "onMessageBoxOK");
		
end

function messagebox:updateInfo(event)
	
	--[[
	local errorText = LORD.GUIWindowManager:Instance():CreateGUIWindow("StaticText", "notice-error-text");
	errorText:SetWidth(self.messagebox_error_scroll:GetWidth());
	errorText:SetProperty("TextWordWrap", "true");
	errorText:SetProperty("TextSelfAdaptHigh", "true");
	errorText:SetText(event.textInfo);
	self.messagebox_error_scroll:additem(errorText);
	--]]
	
	self.messagebox_notice:SetText(event.textInfo);
	
	self.callBack = event.callBack;
end

function messagebox:onHide(event)
	self:Close();
end

function messagebox:onOK(event)
	
	self:onHide();
	
	if(self.callBack)	then
		self.callBack()
	end
		
end

return messagebox;
