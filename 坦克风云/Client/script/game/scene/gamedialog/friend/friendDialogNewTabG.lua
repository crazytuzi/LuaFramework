friendDialogNewTabG={}

function friendDialogNewTabG:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil
	self.allSubTabs={}
	self.friendTab1=nil
	self.friendTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	return nc
end

function friendDialogNewTabG:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initTabs()
	self:tabSubClick(10)
	return self.bgLayer
end

function friendDialogNewTabG:initTabs()
	local tabIndex=0
	local tabTb={getlocal("friend_tab_friendReward"),getlocal("friend_tab_giftList")}
	for k,v in pairs(tabTb) do
		local tabBtnItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
		local function tabSubClick(idx)
			return self:tabSubClick(idx)
		end
		tabBtnItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
		tabBtnItem:addChild(lb)
		self.allSubTabs[k]=tabBtnItem
		local tabBtn=CCMenu:create()
		tabBtn:addChild(tabBtnItem)
		tabBtnItem:setTag(tabIndex+10)
		if k==1 then
			tabBtn:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
		else
			tabBtn:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
		end
		self.bgLayer:addChild(tabBtn)
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		tabIndex=tabIndex+1
	end
end

function friendDialogNewTabG:tabSubClick(idx)
	if self.selectedSubTabIndex == idx then
		return
	end
	self.selectedSubTabIndex=idx
	local type=idx-10+1
	for k,v in pairs(self.allSubTabs) do
		if k==type then
			v:setEnabled(false)
			self.curTab=type
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(type)
	if(idx==10 and self.friendTab1 and self.friendTab1.pageChange)then
		self.friendTab1:pageChange(0)
	elseif(idx==11 and self.friendTab2 and self.friendTab2.pageChange)then
		self.friendTab2:pageChange(0)
	end
end

function friendDialogNewTabG:switchTab(type)
	if type==nil then
		type=1
	end
	if type==1 then
		if self.friendTab1==nil then
			if(G_isKakao())then
				self.friendTab1=friendDialogNewTabGF_Kakao:new()
			else
				self.friendTab1=friendDialogNewTabGF:new()
			end
			self.layerTab1=self.friendTab1:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab1)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(0,0))
			self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
		end
	elseif type==2 then
		if self.friendTab2==nil then
			self.friendTab2=friendDialogNewTabGL:new()
			self.layerTab2=self.friendTab2:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
		end
	end
end

function friendDialogNewTabG:pageChange(p)
	if(self.selectedSubTabIndex==10 and self.friendTab1 and self.friendTab1.pageChange)then
		self.friendTab1:pageChange(p)
	elseif(self.selectedSubTabIndex==11 and self.friendTab2 and self.friendTab2.pageChange)then
		self.friendTab2:pageChange(p)
	end
end

function friendDialogNewTabG:dispose()
	if(self.friendTab1 and self.friendTab1.dispose)then
		self.friendTab1:dispose()
	end
	if(self.friendTab2 and self.friendTab2.dispose)then
		self.friendTab2:dispose()
	end
end