local tip_info = class( "tip_info", layout );

global_event.TIP_INFO_SHOW = "TIP_INFO_SHOW";
global_event.TIP_INFO_HIDE = "TIP_INFO_HIDE";

function tip_info:ctor( id )
	tip_info.super.ctor( self, id );
	self:addEvent({ name = global_event.TIP_INFO_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.TIP_INFO_HIDE, eventHandler = self.onHide});
	self.tips ={}
	self.tipTimeHandle = nil	
end




function tip_info:onShow(event)
	self:Show();
	table.remove(self.tips,1)
	self.tip_info = self:Child( "tip_info" );
	table.insert(self.tips,event.tip)
	
	--self.tip_info:SetText("")
	self.iniyPos = 	self.iniyPos  or self.tip_info:GetPosition()
	self.flyTime = 0
	--	self.tip_info:SetText(self.tips[1])
	self.height = self._view:GetHeight() * LORD.UDim(0, 0.5)---策划要求移动半个控件高度
	self.tip_info:SetPosition(self.iniyPos )
	function tip_info_timeTick(dt)
		
		if sceneManager.battlePlayer() then
			local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
			dt = dt * rate;
		end
		
		local text = self.tips[1]
		
		if(text ~= nil )then
		
			self.tip_info:SetText(text)
			local prePos = self.tip_info:GetPosition()
			local y = prePos.y -   self.height * LORD.UDim(0, dt/0.5)
			self.flyTime = self.flyTime  + dt
		 
			if(self.flyTime  >= 1.2 )then
				table.remove(self.tips,1)
				self:onHide()
				
				self.flyTime = 0
			else
				if(self.flyTime  <= 0.5 )then
					local pos = LORD.UVector2(prePos.x, y)
					self.tip_info:SetPosition(pos)
				end
			end
		else
			self:onHide()
		end
	end		

	if(self.tipTimeHandle == nil)then
		self.tipTimeHandle = scheduler.scheduleGlobal(tip_info_timeTick,0)
	end	
end

function tip_info:onHide(event)
	self:Close();
	self.tips = {}
	if(self.tipTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(self.tipTimeHandle)
		self.tipTimeHandle = nil
	end	
	
end

return tip_info;
