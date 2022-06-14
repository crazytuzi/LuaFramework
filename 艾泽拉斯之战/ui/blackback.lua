
local blackbackclass = class("blackbackclass",layout)

global_event.BLACKBACK_UI_SHOW = "BLACKBACK_UI_SHOW";
global_event.BLACKBACK_UI_HIDE = "BLACKBACK_UI_HIDE";
global_event.BLACKBACK_UI_UPDATE_LEVEL = "BLACKBACK_UI_UPDATE_LEVEL";

function blackbackclass:ctor( id )
	 blackbackclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.BLACKBACK_UI_SHOW, eventHandler = self.onshow})				
	 self:addEvent({ name = global_event.BLACKBACK_UI_HIDE, eventHandler = self.onHide})
	 self:addEvent({ name = global_event.BLACKBACK_UI_UPDATE_LEVEL, eventHandler = self.onUpdateLevel})
end	

function blackbackclass:onshow(event)
	 
	 --dump(event);
	 	
	if self._show then	 	
		-- 如果已经显示了就只是修改层级
		self:updateLevelAndView(event.level);	 		
		return;
	end
	
	 self:Show();
	
	self.blackback_blur = LORD.toStaticImage(self:Child("blackback-blur"));
	self.blackback_mask = LORD.toStaticImage(self:Child("blackback-mask"));
	
	 self:updateLevelAndView(event.level);
	 
	 function onClickCloseOwnerWindow()
	 	local topBackView = layoutManager.getTopBackView();
	 	if topBackView then
	 		topBackView:onHide();
	 	end
	 end
	 	 
	 self._view:subscribeEvent("WindowTouchUp", "onClickCloseOwnerWindow");
	 
end

function blackbackclass:onHide(event)

	if self._view then
		LORD.toStaticImage(self._view):setBlur(false);
	end
	
	self:Close();
end

function blackbackclass:onUpdateLevel(event)
	self:updateLevelAndView(event.level);
end

function blackbackclass:updateLevelAndView(level)
	if self._view then
		self._view:SetLevel(level);
	end
end

return blackbackclass