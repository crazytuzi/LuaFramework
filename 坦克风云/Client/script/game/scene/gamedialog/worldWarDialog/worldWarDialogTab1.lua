worldWarDialogTab1={}

function worldWarDialogTab1:new()
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
	self.tab4=nil
	self.layerTab4=nil
	self.curTab=1

	return nc
end

function worldWarDialogTab1:init(layerNum,parent)
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab11"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab12"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab13"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab14"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarScheduleScene"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarFinalScene"
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTankjianianhua.plist")
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initSubTab()
	return self.bgLayer
end

function worldWarDialogTab1:initSubTab()
	local tabStr={getlocal("world_war_sub_title11"),getlocal("world_war_sub_title12"),getlocal("world_war_sub_title13"),getlocal("world_war_sub_title14")}
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

		local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
		tipSp:setAnchorPoint(CCPointMake(1,0.5))
		tipSp:setPosition(ccp(subTabItem:getContentSize().width,subTabItem:getContentSize().height-15));
		tipSp:setTag(101);
		tipSp:setVisible(false)
		subTabItem:addChild(tipSp)
	end
	self:switchSubTab(1)
end

function worldWarDialogTab1:setIconTipVisibleByIdx(isVisible,idx)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem = self.subTabs[idx]
    if tabBtnItem then
	    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
	    local tipSp=temTabBtnItem:getChildByTag(101)
	    if tipSp~=nil then
	        if tipSp:isVisible()~=isVisible then
	            tipSp:setVisible(isVisible)
	        end
	    end
	end
end

function worldWarDialogTab1:switchSubTab(type,isEffect)
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
		if(self.tab1==nil)then
			self.tab1=worldWarDialogSubTab11:new()
			self.layerTab1=self.tab1:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab1,1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			self.tab2=worldWarDialogSubTab12:new()
			self.layerTab2=self.tab2:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab2,1)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			self.tab3=worldWarDialogSubTab13:new()
			self.layerTab3=self.tab3:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab3,1)
		end
	elseif(type==4)then
		local function formatRankListHandler()
			if(self.tab4==nil)then
				self.tab4=worldWarDialogSubTab14:new()
				self.layerTab4=self.tab4:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab4,1)
			end
		end
		worldWarVoApi:formatRankList(1,formatRankListHandler)
	end

	for i=1,4 do
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
end

function worldWarDialogTab1:refresh()

end

function worldWarDialogTab1:tick()
	for i=1,4 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
        if i==1 then
        	local initFlag=worldWarVoApi:getInitFlag()
			if self and initFlag and initFlag==1 then
				local isShow=worldWarVoApi:isShowBetRewardTip()
				self:setIconTipVisibleByIdx(isShow,i)
			end
        end
    end
end

function worldWarDialogTab1:dispose()
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acTankjianianhua.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acTankjianianhua.pvr.ccz")
	if(self.tab1)then
		self.tab1:dispose()
	end
	if(self.tab2)then
		self.tab2:dispose()
	end
	if(self.tab3)then
		self.tab3:dispose()
	end
	if(self.tab4)then
		self.tab4:dispose()
	end
	self.subTabs={}
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	self.tab3=nil
	self.layerTab3=nil
	self.tab4=nil
	self.layerTab4=nil
	self.curTab=1
end
