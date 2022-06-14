local warninghint = class( "warninghint", layout );

global_event.WARNINGHINT_SHOW = "WARNINGHINT_SHOW";
global_event.WARNINGHINT_HIDE = "WARNINGHINT_HIDE";

function warninghint:ctor( id )
	warninghint.super.ctor( self, id );
	self:addEvent({ name = global_event.WARNINGHINT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.WARNINGHINT_HIDE, eventHandler = self.onHide});
	self.tips ={}
	self.tipTimeHandle = nil	
	
	self.winNumIndex  = 0
	self.wins = {}
	self.aliveWins = {}
end

function warninghint:getFreeWnd()
	self.winNumIndex = self.winNumIndex + 1
	self.wins[self.winNumIndex]	= LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("warninghint_"..self.winNumIndex, "warningHintItem.dlg");
	self.heightMove = self.heightMove or self.wins[self.winNumIndex]:GetPixelSize().y *1.5
	local pos =    LORD.UVector2(LORD.UDim(0, 0),LORD.UDim(0, 0))
	self.wins[self.winNumIndex]:SetPosition(pos)
	self.wins[self.winNumIndex]:SetUserData(self.winNumIndex)
	self._view:AddChildWindow(self.wins[self.winNumIndex])
	
	self.w = self.w or  self.wins[self.winNumIndex]:GetWidth();
	self.h = self.h or  self.wins[self.winNumIndex]:GetHeight();
	self.wins[self.winNumIndex].pos = self.wins[self.winNumIndex]:GetPosition()
	return self.wins[self.winNumIndex]
end

function warninghint:onShow(event)
	
 
	if(event.RESGET  and game.__________ENTER_GAME ~= true)then
		return 
	end
	
	if(event.RESGET)then ---资源获得提示类
		local layout1 = layoutManager.getUI("battlelose")
		local layout2 = layoutManager.getUI("BattleView")
		local layout3 = layoutManager.getUI("instancejiesuanView")
		local layout4 = layoutManager.getUI("battleprepare")
		local layout5 = layoutManager.getUI("sweep")
		
		if(  layout1:isShow() or  layout2:isShow() or  layout3:isShow() or layout4:isShow() or layout5:isShow())then
				 return 
		end
	end
	if(event and  event.tip)then
		if( type(event.tip) == "table")then
			for i,v in pairs (event.tip)do
				table.insert(self.tips,v)
			end
		else
			table.insert(self.tips,event.tip)
		end
	end	
		
	if self._show then
	else
		self:Show();
	end
	
	
	
	
		function warninghintflyEndFunc(args)	
				local window =  LORD.toWindowEventArgs(args).window 
				window:SetText("")
				for k,v in ipairs (self.aliveWins)do
					if(v:GetUserData() ==  window:GetUserData()	) then
						table.remove(self.aliveWins, k) 
						break;
					end
			   end	  
			  self._view:RemoveChildWindow(window)
			  engine.DestroyWindow(window)
			   if( table.nums(self.aliveWins) <=0)then
					self:onHide()
			   end
		end
	
		function warninghintrundisappearAction(w)
					w.showTime = nil
					w:removeEvent("UIActionEnd");
					local action = LORD.GUIAction:new();
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1),0, 500);
					w:playAction(action);
					w:subscribeEvent("UIActionEnd", "warninghintflyEndFunc");	
				
		end	
	
	
	function warninghint_tip_info_timeTick(dt)
		   if not self._show then
		   end
		 
		   for i,v in pairs (self.aliveWins)do
				 
				if(v.showTime)then
 
					v.showTime = v.showTime + dt 
					if(v.pop) then
					
						if(v.showTime <= 1 ) then
							--local pos =   v.pos
							---v:SetPosition( LORD.UVector2(pos.x,pos.y - LORD.UDim(0,    self.heightMove * v.showTime/1  )  ))
						else
							v.pop = false
							v.showTime = 0
						end
					else
						if(v.fadeout) then
 
							if(v.showTime <= 2 ) then
								v:SetAlpha(1 - v.showTime/2)
							else
								  self._view:RemoveChildWindow(v)
								  engine.DestroyWindow(v)
								  table.remove(self.aliveWins,i)
									if( table.nums(self.aliveWins) == 0) then
										self:onHide()
									end
								  break
							end	
					 
							
							
						
						elseif(v.showTime >= 3 ) then
							v.fadeout = true
							v.showTime = 0
			 
						end
					end
	 
				end
			end
		
	 
		
	end	
	if(self.tipTimeHandle == nil)then
		self.tipTimeHandle = scheduler.scheduleGlobal(warninghint_tip_info_timeTick,0)
	end			

	
	function ______listener(text)
			 self:processTip(text) 
	end 
	
	for i,v in ipairs(self.tips)do
		self:processTip(v) 
	end
	self.tips = {}	
end


function warninghint:getcreateTime()
		local createTime = 100
	   
	    if(#self.aliveWins and  self.aliveWins[#self.aliveWins] )then
			createTime = self.aliveWins[#self.aliveWins].createTime
		end
		return createTime
end


function warninghint:processTip(text)
			if( not  self._view)then
				return
			end
		
		 local wnd = self:getFreeWnd()	
		 wnd.pop = true
		 local posY = wnd.pos.y.offset
			   local action = LORD.GUIAction:new();
			   action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.8, 0.8, 0.8), 1, 0);
			   action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.1, 1.1, 1.1),1, 150);
			   action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1),1, 350);
			   wnd:playAction(action);
	 
	
		local num = #self.aliveWins
		local index = 1
		for i = num , 1 ,-1   do
				 local v = self.aliveWins[i]
				 if(v)then
					 local pos =   v:GetPosition()
					-- v.showTime = 0
					-- v.pop = true
					if( posY - pos.y.offset < self.heightMove * (index) )	then
						v:SetPosition( LORD.UVector2(pos.x,LORD.   UDim(0, posY) - LORD.UDim(0, self.heightMove*index) ))
					end	
					v.pos = v:GetPosition()
					index = index + 1
				end	
		 end
  
			  wnd:SetText( text)
			  wnd.showTime = 0
			 if(  table.nums(self.aliveWins ) >= 5)then
					 local win = self.aliveWins[1]
					if(win)then
						self._view:RemoveChildWindow(win)
						engine.DestroyWindow(win)
						table.remove(self.aliveWins,1)
					end
			 end
			 table.insert(self.aliveWins,wnd) 
 
end
 

function warninghint:onHide(event)
	self:Close();
	if(self.tipTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(self.tipTimeHandle)
		self.tipTimeHandle = nil
	end	
	self.winNumIndex  = 0
	self.wins = {}
	self.aliveWins = {}
	self.lastWnd = nil
 
end
return warninghint;
