worldWarDialogTab3={}

function worldWarDialogTab3:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.subTabs={}
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	self.tab3=nil
	self.layerTab3=nil
	self.curTab=1
	self.hSpace=50
	self.myPointLb=nil
	self.callbackNum=0
	return nc
end

function worldWarDialogTab3:init(layerNum,parent)
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab31"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab32"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab33"
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initDesc()
	self:initSubTab()
	return self.bgLayer
end

function worldWarDialogTab3:initDesc()
	local myPointDescLb=GetTTFLabel(getlocal("serverwar_my_point"),28)
	myPointDescLb:setColor(G_ColorGreen)
	myPointDescLb:setAnchorPoint(ccp(0,0.5))
	myPointDescLb:setPosition(ccp(30,G_VisibleSizeHeight-180-self.hSpace))
	self.bgLayer:addChild(myPointDescLb)
	self.myPointLb=GetTTFLabel(worldWarVoApi:getPoint(),28)
	self.myPointLb:setAnchorPoint(ccp(0,0.5))
	self.myPointLb:setPosition(ccp(40+myPointDescLb:getContentSize().width,G_VisibleSizeHeight-180-self.hSpace))
	self.bgLayer:addChild(self.myPointLb)
end

function worldWarDialogTab3:initSubTab()
	local tabStr={getlocal("world_war_sub_title31"),getlocal("world_war_sub_title32"),getlocal("world_war_sub_title33")}
	for k,v in pairs(tabStr) do
		local subTabBtn=CCMenu:create()
		local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		subTabItem:setAnchorPoint(ccp(0,0))
		local function tabSubClick(idx)
			return self:switchSubTab(idx,true)
		end
		subTabItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,20,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
		subTabItem:addChild(lb)
		self.subTabs[k]=subTabItem
		subTabBtn:addChild(subTabItem)
		subTabItem:setTag(k)
		subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+9)+30,self.bgLayer:getContentSize().height-210))
		subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(subTabBtn)
	end
	self:switchSubTab(1)
end

function worldWarDialogTab3:switchSubTab(type,isEffect)
	if isEffect==false then
	else
		PlayEffect(audioCfg.mouseClick)
	end
	if type==nil then
		type=1
	end
	for k,v in pairs(self.subTabs) do
		if k==type then
			v:setEnabled(false)
			self.curTab=type
		else
			v:setEnabled(true)
		end
	end

	if(type==1)then
		local function callback1()
			if(self.tab1==nil)then
				self.tab1=worldWarDialogSubTab31:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1,1)
			end
		end
		worldWarVoApi:getShopInfo(callback1)
	elseif(type==2)then
		local function callback2()
			if(self.tab2==nil)then
				self.tab2=worldWarDialogSubTab32:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2,1)
			end
		end
		worldWarVoApi:getShopInfo(callback2)
	elseif(type==3)then
		local function callback3()
			if(self.tab3==nil)then
				self.tab3=worldWarDialogSubTab33:new()
				self.layerTab3=self.tab3:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab3,1)
			end
		end
		worldWarVoApi:formatPointDetail(callback3)
	end

	for i=1,3 do
		if self["layerTab"..i] then
			if i==type then
				self["layerTab"..i]:setPositionX(0)
				self["layerTab"..i]:setVisible(true)
			else
				self["layerTab"..i]:setPositionX(999333)
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
	

	-- if self.parent then
	-- 	self.parent.selectSubTab3=type
	-- 	if self.parent.resetForbidLayer then
	-- 		self.parent:resetForbidLayer()
	-- 	end
	-- end
end

-- function worldWarDialogTab3:closeDialog()
-- 	if self.parent and self.parent.close then
-- 		self.parent:close()
-- 	end
-- end

function worldWarDialogTab3:doUserHandler()
	local flag=worldWarVoApi:getPointDetailFlag()
    local detailExpireTime=worldWarVoApi:getDetailExpireTime()
    -- print("detailExpireTime",detailExpireTime)
    -- print("base.serverTime",base.serverTime)
    if (self.callbackNum<3 and ((detailExpireTime and detailExpireTime>0 and base.serverTime>=detailExpireTime) or flag==-1)) then
        local function callback()
            self.callbackNum=0
            worldWarVoApi:setPointDetailFlag(0)
        end
        worldWarVoApi:setPointDetailFlag(-1)
        worldWarVoApi:formatPointDetail(callback)
        self.callbackNum=self.callbackNum+1
    -- elseif flag==0 then
    --     worldWarVoApi:setPointDetailFlag(1)
    end
    if self and self.myPointLb then
		self.myPointLb:setString(worldWarVoApi:getPoint())
	end
end

function worldWarDialogTab3:tick()
	for i=1,3 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
    end
    self:doUserHandler()
end

function worldWarDialogTab3:dispose()
	if(self.tab1)then
		self.tab1:dispose()
	end
	if(self.tab2)then
		self.tab2:dispose()
	end
	if(self.tab3)then
		self.tab3:dispose()
	end
	self.subTabs={}
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	self.tab3=nil
	self.layerTab3=nil
	self.curTab=1
	self.myPointLb=nil
	self.callbackNum=0
end