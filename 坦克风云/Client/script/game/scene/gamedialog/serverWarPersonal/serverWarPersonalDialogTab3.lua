require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogSubTab31"
require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogSubTab32"
require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogSubTab33"
serverWarPersonalDialogTab3={}

function serverWarPersonalDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=0
	self.serverWarDialog=nil

	self.subTab1=nil
	self.subTab2=nil
	self.subTab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil

	self.hSpace=50

    return nc
end


function serverWarPersonalDialogTab3:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
		   lb:setTag(31)
		   
		   
	   		local numHeight=25
			local iconWidth=36
			local iconHeight=36
	   		local newsNumLabel = GetTTFLabel("0",numHeight)
	   		newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
	   		newsNumLabel:setTag(11)
	   	    local capInSet1 = CCRect(17, 17, 1, 1)
	   	    local function touchClick()
	   	    end
	        local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
			if newsNumLabel:getContentSize().width+10>iconWidth then
				iconWidth=newsNumLabel:getContentSize().width+10
			end
	        newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	   		newsIcon:ignoreAnchorPointForPosition(false)
	   		newsIcon:setAnchorPoint(CCPointMake(1,0.5))
	        newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
	        newsIcon:addChild(newsNumLabel,1)
			newsIcon:setTag(10)
	   		newsIcon:setVisible(false)
		    tabBtnItem:addChild(newsIcon)
		   
		   --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
		   lockSp:setAnchorPoint(CCPointMake(0,0.5))
		   lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
		   lockSp:setScaleX(0.7)
		   lockSp:setScaleY(0.7)
		   tabBtnItem:addChild(lockSp,3)
		   lockSp:setTag(30)
		   lockSp:setVisible(false)
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn)


end

function serverWarPersonalDialogTab3:resetTab()
	self.allTabs={}
	for i=1,3 do
		table.insert(self.allTabs,getlocal("serverwar_shop_tab"..i))
	end
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==2 then
            tabBtnItem:setPosition(394,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         -- elseif index==3 then
         --    tabBtnItem:setPosition(540,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
end


function serverWarPersonalDialogTab3:init(layerNum,serverWarDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.serverWarDialog=serverWarDialog

    self:resetTab()
    self:initDesc()
    self:getDataByType()

    return self.bgLayer
end

function serverWarPersonalDialogTab3:initDesc()
	local myPointDescLb=GetTTFLabel(getlocal("serverwar_my_point"),28)
	myPointDescLb:setColor(G_ColorGreen)
	myPointDescLb:setAnchorPoint(ccp(0,0.5))
	myPointDescLb:setPosition(ccp(30,G_VisibleSizeHeight-180-self.hSpace))
	self.bgLayer:addChild(myPointDescLb)
	self.myPointLb=GetTTFLabel(serverWarPersonalVoApi:getPoint(),28)
	self.myPointLb:setAnchorPoint(ccp(0,0.5))
	self.myPointLb:setPosition(ccp(40+myPointDescLb:getContentSize().width,G_VisibleSizeHeight-180-self.hSpace))
	self.bgLayer:addChild(self.myPointLb)
end

function serverWarPersonalDialogTab3:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
	-- self:resetForbidLayer()
	self:getDataByType(self.selectedTabIndex+1)
end

function serverWarPersonalDialogTab3:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.subTab1==nil)then
			self.subTab1=serverWarPersonalDialogSubTab31:new()
			self.layerTab1=self.subTab1:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab1)
			if(self.selectedTabIndex==0)then
				self:switchTab(1)
			end
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.subTab2==nil)then
			self.subTab2=serverWarPersonalDialogSubTab32:new()
			self.layerTab2=self.subTab2:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab2)
			if(self.selectedTabIndex==1)then
				self:switchTab(2)
			end
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.subTab3==nil)then
			local function getScheduleInfoCallback()
				local function formatPointDetailCallback()
					self.subTab3=serverWarPersonalDialogSubTab33:new()
					self.layerTab3=self.subTab3:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab3)
					if(self.selectedTabIndex==2)then
						self:switchTab(3)
					end
				end
				serverWarPersonalVoApi:formatPointDetail(formatPointDetailCallback)
			end
			serverWarPersonalVoApi:getScheduleInfo(getScheduleInfoCallback)
		else
			self:switchTab(3)
		end
	end
end

function serverWarPersonalDialogTab3:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,3 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
end

function serverWarPersonalDialogTab3:doUserHandler()
	if self and self.myPointLb then
		self.myPointLb:setString(serverWarPersonalVoApi:getPoint())
	end
end

function serverWarPersonalDialogTab3:tick()
	for i=1,3 do
		if self["subTab"..i]~=nil and self["subTab"..i].tick then
			self["subTab"..i]:tick()
		end
	end
	self:doUserHandler()
end

function serverWarPersonalDialogTab3:refresh()

end

function serverWarPersonalDialogTab3:dispose()
	for i=1,3 do
		if (self["subTab"..i]~=nil and self["subTab"..i].dispose) then
			self["subTab"..i]:dispose()
		end
	end

	self.subTab1=nil
	self.subTab2=nil
	self.subTab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=nil
	self.hSpace=nil
end






