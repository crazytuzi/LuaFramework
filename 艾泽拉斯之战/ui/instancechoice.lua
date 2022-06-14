local instancechoice = class( "instancechoice", layout );

global_event.INSTANCECHOICE_SHOW = "INSTANCECHOICE_SHOW";
global_event.INSTANCECHOICE_HIDE = "INSTANCECHOICE_HIDE";
global_event.INSTANCECHOICE_UPDATE = "INSTANCECHOICE_UPDATE";

local max_chapter = 16
function instancechoice:ctor( id )
	instancechoice.super.ctor( self, id );
	--self:addEvent({ name = global_event.INSTANCECHOICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.INSTANCECHOICE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.INSTANCECHOICE_UPDATE, eventHandler = self.onUpdate});
	
	self.Chapter   =  nil
	self.Adventure   =  nil
	self.wnd  = {}
	self.curSelStafeMode = enum.Adventure_TYPE.NORMAL-- 普通
end

function instancechoice:Load()	
	if(self._loaded)then  return end
	
    self._view = engine.windowManager:CreateGUIWindow("DefaultWindow", "instancechoiceRootWindow"); 	
	self._view:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
	self._view:SetSize(LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(1, 0)));	
	
	
	self._maps = engine.windowManager:CreateGUIWindow("DefaultWindow", "instancechoiceMapWindow"); 	
	self._maps:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
	self._maps:SetSize(LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(1, 0)));	
	
    self._ChoiceView	= engine.LoadWindowFromXML(self._config.xml)
	self._ChoiceView:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
	self._view:AddChildWindow(self._maps)
	self._view:AddChildWindow(self._ChoiceView)
	self._ChoiceView:SetLevel(0)	
	  	
	self._loaded = true		
end	



function instancechoice:onShow(event)
	self.__stage = event.stage
	self.notips = event.notips or false
	
	self.toNewStage = event.toNewStage or false
	if(event.toNewStage)then
		self.Chapter   =  nil
		self.Adventure   =  nil
	end
	
	
	if self._show then
		return;
	end
    self.ChapterUi = {}
	self:Show();
	
	self.instancechoice_close = self:Child( "instancechoice-close" );
	
	function on_instancechoice_close_click()
		self:onHide()
	end	
	
	self.instancechoice_close:subscribeEvent("ButtonClick", "on_instancechoice_close_click");	
	
	function on_instancechoice_Normal(args)	
		if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
			return
		end	
		self.__stage = nil
		local clickImage = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if(clickImage:IsSelected())then		
			self.curSelStafeMode = enum.Adventure_TYPE.NORMAL -- 普通
			
			--self:updateCurChapter()
			self.Chapter  = nil
			self:upDate()
		end
		
	end	
	function on_instancechoice_Elite(args)
		if(self.curSelStafeMode == enum.Adventure_TYPE.ELITE)then
			return
		end	
		self.__stage = nil
		local clickImage = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if(clickImage:IsSelected())then		
			self.curSelStafeMode = enum.Adventure_TYPE.ELITE  
			--self:updateCurChapter()
			self.Chapter  = nil
			self:upDate()
		end
	end	
	
	self.instancechoice_star = self:Child( "instancechoice-star" );
	function on_instancechoice_star_up()
		eventManager.dispatchEvent( { name = global_event.CHAPTERAWARD_SHOW, chapter = self.Chapter,curSelStafeMode = self.curSelStafeMode})	
	end	
 
	self.instancechoice_star:subscribeEvent("WindowTouchUp", "on_instancechoice_star_up");	
	self.instancechoice_star_num = self:Child( "instancechoice-star-num" );
	self.instancechoice_style1 = LORD.toRadioButton(self:Child( "instancechoice-style1" ));
	self.instancechoice_style2 = LORD.toRadioButton(self:Child( "instancechoice-style2" ));
	
	self.instancechoice_style1:subscribeEvent("RadioStateChanged", "on_instancechoice_Normal");		
	self.instancechoice_style2:subscribeEvent("RadioStateChanged", "on_instancechoice_Elite");		
	
	self.instancechoice_chapter = self:Child( "instancechoice-chapter" );
	self.instancechoice_left = self:Child( "instancechoice-left" );
	self.instancechoice_right = self:Child( "instancechoice-right" );
	
	function on_instancechoice_chapter()
		eventManager.dispatchEvent({name = global_event.QUICK_MAP_SHOW, chapter = self.Chapter,curSelStafeMode = self.curSelStafeMode})
	end	
	
	self.instancechoice_chapter:subscribeEvent("ButtonClick", "on_instancechoice_chapter");		
	
	function instancechoice_left_click()
		
		self.Chapter = self.Chapter - 1		
		
		local minChapter = 1		
		if(self.Chapter  < minChapter)then
			self.Chapter = minChapter
		end			
 
		self.instancechoice_left:SetEnabled(self.Chapter > minChapter)
		self:moveTo(0)	

	end

	function instancechoice_right_click()
		self.Chapter = self.Chapter + 1		
		local zones = dataManager.instanceZonesData
		local maxChapter = # (zones:getAllChapter() )	
		if(maxChapter > max_chapter)then
			maxChapter = max_chapter
		end	
		if(self.Chapter  >    maxChapter)then
			self.Chapter = maxChapter
		end		
		self.instancechoice_right:SetEnabled(self.Chapter < maxChapter)
			
		self:moveTo(1)
	end
	self.instancechoice_left:subscribeEvent("ButtonClick", "instancechoice_left_click");	
	self.instancechoice_right:subscribeEvent("ButtonClick", "instancechoice_right_click");	
		 
	self:upDate()
	
	
	-- test action
	if self._view then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, -720, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 0, 0);
		action:addKeyFrame(LORD.Vector3(0, 50, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 400);
		action:addKeyFrame(LORD.Vector3(0, -50, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 600);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 700);
		self._view:playAction(action);
	end
	
end

function instancechoice:upDate()
 
	if(self.__stage)then
		self.Chapter = self.__stage:getChapter():getId()
		self.curSelStafeMode = 	self.__stage:getType()
	elseif(self.__prestage)then
			if(self.Chapter == self.__prestage:getChapter():getId())then
				self.__stage = 	self.__prestage
				self.__prestage = nil
			end
	end	
	
	if self._show == false then
		return
	end
	--print("upDate")
	local zones = dataManager.instanceZonesData
	
	
	if(self.Adventure == nil)then self.Adventure = 1 end
	
	if(self.Chapter == nil)then 
		if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL) then
			self.Chapter =   zones:getCurNormalProgressChapter()  
		else
			self.Chapter =   zones:getCurEliteProgressChapter()  
		end
	
	end
	
	--  加载前后2章，共计3章 的ui 

	local maxChapter = # (zones:getAllChapter() )
	local minChapter = 1
	if(self.Chapter + 1  <    maxChapter)then
		maxChapter  = self.Chapter + 1
	end
	if(self.Chapter - 1 > minChapter)then
		minChapter = self.Chapter - 1
	end
	
	local xpos = LORD.UDim(0, 0)
	local ypos = LORD.UDim(0, 0)
	
	for _,v in pairs (self.wnd) do
		self._maps:RemoveChildWindow(v)	
		v.used = false		
	end
 
	if(maxChapter>max_chapter)then
		maxChapter  = max_chapter
	end
	self.__addWnd = {}
	self._maps:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
	
	
	for i = minChapter, maxChapter do
		local map  =  self:getWndForCache("instancemap"..i..".dlg",i)			
		local width = map:GetWidth()		
		xpos = 	 LORD.UDim(0, 0 + (i - self.Chapter) * self._view:GetPixelSize().x )	
		map:SetPosition(LORD.UVector2(xpos, ypos));
		self._maps:AddChildWindow(map)
		xpos = xpos + width		
		table.insert(self.__addWnd,map)
	end
	
 
 
	for i = #self.wnd ,1, -1  do
		local v = self.wnd[i]
		if(v.used == false )then		
			engine.windowManager:DestroyGUIWindow(v)
			table.remove(self.wnd,i)
		end
	end	
 
	 
	
    self:updateCurChapter()
	
	self.instancechoice_left:SetEnabled(self.Chapter > minChapter)
	self.instancechoice_right:SetEnabled(self.Chapter < maxChapter)


end	

function instancechoice:updateCurChapter() 
	
	eventManager.dispatchEvent( { name = global_event.CHAPTERAWARD_UPDATE, chapter = self.Chapter,curSelStafeMode = self.curSelStafeMode})	
	local zones = dataManager.instanceZonesData	
	local curChapter = zones:getAllChapter()[self.Chapter]	
	local Adventure = curChapter:getAdventure()
	
	---章节奖励领了 就不显示了
	--self.instancechoice_star:SetVisible( not curChapter:haveAward(self.curSelStafeMode))
	
	
	self.instancechoice_chapter:SetText(curChapter:getName())
	local num ,all = curChapter:getPerfectProcess(self.curSelStafeMode)
	local pro =  num.."/"..all
	self.instancechoice_star_num:SetText(pro)
	
	
	--self.instancechoice_star:SetEnabled(num >= all )
	
	for k,v in pairs (self.ChapterUi) do
		self.ChapterUi[k].button:removeEvent("ButtonClick");		
	end		
		
	self.ChapterUi = {}
	
	function onclickStage(args)
		local window = LORD.toWindowEventArgs(args).window;
		local windowname = window:GetName();
		local Adventureid = window:GetUserData()		
		local stage = zones:getStageWithAdventureID(Adventureid,self.curSelStafeMode)		
		eventManager.dispatchEvent({name = global_event.INSTANCEINFOR_SHOW,stage = stage })
	end			
	
	for i =1,#Adventure do  
		self.ChapterUi[i] = {}
		local buttonName = string.format("instancemap%d-%02d", self.Chapter,i) 		
		--print(buttonName)
		self.ChapterUi[i].button    = self:Child(buttonName)		
		self.ChapterUi[i].button:subscribeEvent("ButtonClick", "onclickStage");				
		self.ChapterUi[i].star = {} 
		for k =1,3 do
			local starName = string.format("instancemap%d-%02d-star%d", self.Chapter,i,k) 
			self.ChapterUi[i].star[k]    = self:Child(starName)
			self.ChapterUi[i].star[k]:SetVisible(false)  
			self.ChapterUi[i].button:SetEnabled(true)
		end			
	end
 
	for i =1,#Adventure do  	
			local stage = zones:getStageWithAdventureID(Adventure[i],self.curSelStafeMode)
			local star = stage:getVisStarNum()
			for k =1,star  do			
				self.ChapterUi[i].star[k]:SetVisible(true)  
			end		
			self.ChapterUi[i].button:SetUserData(stage:getAdventureID())		
			self.ChapterUi[i].button:SetEnabled(stage:isEnable())	
		 
			if(self.__stage and self.__stage:getId() == stage:getId())then
				self:addArrowTip(i)
			else
				self:delArrowTip(i)
			end	
				
	end
	
	if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
		self.instancechoice_style1:SetSelected(true)
	elseif(self.curSelStafeMode == enum.Adventure_TYPE.ELITE)then
		self.instancechoice_style2:SetSelected(true)	
	end

end	

function instancechoice:delArrowTip(i) 
	if(self.notips)then
		return
	end
	local index = i
	do
		self.ChapterUi[index].button:SetEffectName("")	
		return	
	end	

end	

function instancechoice:addArrowTip(i) 
	
	if(self.notips)then
		return
	end
	
	--self.ChapterUi[i]:AddChildWindow()	
	--SetPosition(self.ChapterUi[i]:GetPosition())
	local index = i
	do
		self.ChapterUi[index].button:SetEffectName("wuyao_gongji03.effect")	
		return	
	end	

	local ypos = LORD.UDim(0, 0)
	local space = 10
	function arrorTimeTick(dt)	
		local pos = self.ChapterUi[index].button:GetPosition()
		pos.y   = pos.y + ypos		
		
		if(not self.__stage)then					
			if(self.arrowHandle)then
				scheduler.unscheduleGlobal(self.arrowHandle) 
				self.arrowHandle = nil
			end					
		end	
		
		ypos.offset  = ypos.offset +  space*0.01 
		if(ypos.offset >= 2)then		
			space = -space
		elseif(ypos.offset <= -2)then	
			space = -space	
		end			
  		self.ChapterUi[index].button:SetPosition(pos)			
	end	
	if(self.arrowHandle == nil)then
		self.arrowHandle = scheduler.scheduleUpdateGlobal(arrorTimeTick)
	end	
end	
function instancechoice:getWndForCache(name,index) 
	--print(index)
	--dump(self.wnd)
 
	for _,v in pairs (self.wnd) do
		 --print("---"..v:GetUserData())
		 if(v:GetUserData() == index)then
		  v.used = true 	
		  return v
		 end
	end				
	local  w  =  engine.LoadWindowFromXML(name)
	table.insert(self.wnd,w)
	w:SetUserData(index)		
	w.used = true 	
	if(self.Chapter ~= index)then
		return w
	end		
	return w
end	

function instancechoice:onmoveChapter(dt) 
	
	    local speed = -2000
		local step = 1
		local start = 1
		local endl =  table.nums(self.__addWnd)
		local maxDis = self._view:GetPixelSize().x 
		
		if(self.toRight == 0 )then
			speed = - speed						
		end
	
		local ypos = LORD.UDim(0, 0)			
		self.moveDis = self.moveDis or 0	
		self.moveDis = self.moveDis + dt*speed	
		--[[
		if(math.abs(self.moveDis) > maxDis)then		
			if(self.toRight == 0) then
				self.moveDis =  maxDis
			else
				self.moveDis = -maxDis
			end				
		end
		]]--
		local xpos = LORD.UDim(0, self.moveDis)		
		
		self._maps:SetPosition(LORD.UVector2(xpos, LORD.UDim(0, 0)));
		
		--[[
		for i = start,endl,step do		
			 local v = self.__addWnd[i]
			 v:SetPosition(LORD.UVector2(xpos, ypos));
			 local width = v:GetWidth()
			 xpos = xpos + width	
		end
		]]--
		--print(maxDis)
		--print(self.moveDis)
		if( math.abs(self.moveDis) >=  maxDis)then
				scheduler.unscheduleGlobal(self.moveChapter) 
				self.moveChapter = nil	
				self.moveDis = 0	
				--print("move to update")
				self:upDate()								
		end
		
end



function instancechoice:moveTo(left) -- 0表示左 1表示右

	if(self.__stage)then
		self.__prestage = self.__stage
	end
	self.__stage = nil
	self.moveDis = 0	
	self.toRight = left
	if(self.moveChapter)then
		scheduler.unscheduleGlobal(self.moveChapter) 
		self.moveChapter = nil
	end
	self.moveChapter =  scheduler.scheduleUpdateGlobal(handler(self,self.onmoveChapter))	
	--print("moveTo")
end 

function instancechoice:onUpdate(event)
	if(event.chapter)then
		self.Chapter = event.chapter
	end
	self:upDate()
 
end

function instancechoice:onHide(event)
	self:Close();
	self.wnd = {}
	
	if(self.moveChapter)then
		scheduler.unscheduleGlobal(self.moveChapter) 
		self.moveChapter = nil
	end
	
	if(self.arrowHandle)then
		scheduler.unscheduleGlobal(self.arrowHandle) 
		self.arrowHandle = nil
	end
 	self.__stage  = nil
	eventManager.dispatchEvent({name = global_event.CHAPTERAWARD_HIDE })
end

return instancechoice;
