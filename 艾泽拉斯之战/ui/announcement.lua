local announcement = class( "announcement", layout );

global_event.ANNOUNCEMENT_SHOW = "ANNOUNCEMENT_SHOW";
global_event.ANNOUNCEMENT_HIDE = "ANNOUNCEMENT_HIDE";

function announcement:ctor( id )
	announcement.super.ctor( self, id );
	self:addEvent({ name = global_event.ANNOUNCEMENT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ANNOUNCEMENT_HIDE, eventHandler = self.onHide});
	self.tips ={}
end

function announcement:onShow(event)
	
	local r = event.record
	
	if(r)then
		table.insert(self.tips,  { text = "^00FF00"..r:getContent(),num = 0 })
	end
	
	if self._show then
		return;
	end
	
--	table.insert(self.tips, { text = "^00FF00".."他希望王思聪稳重一点。但儿子向他吐槽被人紧盯的痛苦，又进入高调的循环。"})
	if(self.tipTimeHandle)then
		return 
	end
 
	self:Show();

	self.announcement_text = self:Child( "announcement-text" );
	self.flyTime = 0
	
	self.viewwidth =  self._view:GetWidth()  
	self.iniyPos = 	self.iniyPos  or self.announcement_text:GetPosition()
	self.width = nil -- LORD.UDim(0, 0.5)
	local moveDis = 0
	function announcement_tip_info_timeTick(dt)
		local t = self.tips[1]
		if(t ~= nil )then
		
			self.announcement_text:SetText(t.text)
			if(self.width  == nil)then
				local font = self.announcement_text:GetFont();
				self.width = font:GetTextExtent(t.text);
				if(self.width < 	self.viewwidth.offset )	then
					self.width  = 	self.viewwidth.offset
				end
			end

			local prePos = self.announcement_text:GetPosition()
			moveDis = moveDis +  dt * 40
			if(  moveDis  >  self.width  )then
				t.num = t.num or 0
				t.num = t.num + 1
				if(t.num >=1 )then
					table.remove(self.tips,1)
				end
				self.width  = nil
				self.announcement_text:SetPosition(self.iniyPos)	
				moveDis = 0 
			else
				local x = prePos.x -  LORD.UDim(0, dt * 40)
				local pos = LORD.UVector2(x, prePos.y)
				self.announcement_text:SetPosition(pos)	
			end

		else
			self:onHide()
		end
	
	end
 
	if(self.tipTimeHandle == nil)then
		self.tipTimeHandle = scheduler.scheduleGlobal(announcement_tip_info_timeTick,0)
	end		
end

function announcement:onHide(event)
	self:Close();
	self.tips ={}
	if(self.tipTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(self.tipTimeHandle)
		self.tipTimeHandle = nil
	end	
end

return announcement;
