friendDialogNewTabGF={}

function friendDialogNewTabGF:new()
	local nc={}
	setmetatable(nc,self)
	
	nc.bgLayer=nil
	nc.layerNum=nil
	nc.parent=nil
	nc.friendsNum=0
	nc.curRewardList={}
	nc.nextRewardList={}
	self.__index=self
	return nc
end

function friendDialogNewTabGF:dispose( )
	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil
	self.friendsNum=nil
	self.curRewardList=nil
	self.nextRewardList=nil
end

function friendDialogNewTabGF:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:getFriendsFromFB()
	return self.bgLayer
end

function friendDialogNewTabGF:getFriendsFromFB()
	local function callback(dataJson)
		self:onGetFriends(dataJson)
	end
	friendVoApi:getFriendFromFB(callback)
end

function friendDialogNewTabGF:onGetFriends(dataJson)
	base:setWait()
	base:setNetWait()
	local friendsData
	if(dataJson and dataJson~="")then
		friendsData=G_Json.decode(dataJson)
	else
		friendsData={}
	end
	local num=0
	for k,v in pairs(friendsData) do
		num=num+1
	end
	self.friendsNum=num
	--kakao special code
	if(G_isKakao() or G_curPlatName()=="0")then
		friendVoApi:onRefreshFriendEnd(dataJson)
	end
	local function onGetMyInfo(data)
		self:onGetMyFBInfo(data)
	end
	playerVoApi:getPlatformInfo({fields="id,picture,name"},onGetMyInfo)
end

function friendDialogNewTabGF:onGetMyFBInfo(data)
	self.facebookID=data.id
	local function callback()
		self:initDialog()
		friendVoApi:refreshGift(nil)
	end
	friendVoApi:requestFriendNumRewardInfo(self.facebookID,callback)
end

function friendDialogNewTabGF:initDialog()
	local capInSet = CCRect(20, 20, 10, 10)
	local function nilFunc()
	end
	local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	descBg:setTouchPriority(-(self.layerNum-1)*20-1)
	descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,200))
	descBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-305))

	local descLb=GetTTFLabelWrap(getlocal("friend_friendNum_desc"),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(getCenterPoint(descBg))
	descBg:addChild(descLb)
	self.bgLayer:addChild(descBg)

	local friendNumBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",capInSet,nilFunc)
	friendNumBg:setTouchPriority(-(self.layerNum-1)*20-1)
	friendNumBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,40))
	friendNumBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-427))

	self.rewardBgHeight=(G_VisibleSizeHeight-450-120)/2
	self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.rewardBgHeight+50))
	self.rewardBg:setAnchorPoint(ccp(0.5,1))
	self.rewardBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-450))
	self.bgLayer:addChild(self.rewardBg)

	local centerX=self.rewardBg:getContentSize().width/2

	local curRewardLb=GetTTFLabel(getlocal("friend_curReward"),25)
	curRewardLb:setAnchorPoint(ccp(0,0.5))
	curRewardLb:setPosition(ccp(10,self.rewardBgHeight+30))
	self.rewardBg:addChild(curRewardLb)

	local function onGetReward()
		self:getReward()
	end
	self.rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetReward,nil,getlocal("daily_scene_get"),25)
	self.rewardItem:setScale(0.9)
	local rewardBtn=CCMenu:createWithItem(self.rewardItem)
	rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardBtn:setPosition(ccp(centerX,40))
	self.rewardBg:addChild(rewardBtn)

	self.nextRewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	self.nextRewardBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.nextRewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.rewardBgHeight-50))
	self.nextRewardBg:setAnchorPoint(ccp(0.5,1))
	self.nextRewardBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-505-self.rewardBgHeight))
	self.bgLayer:addChild(self.nextRewardBg)

	self:initRewards()

	self.friendNumLb=GetTTFLabel(getlocal("friend_friendNum",{self.friendsNum,self.curRewardCfg.num}),25)
	self.friendNumLb:setPosition(getCenterPoint(friendNumBg))
	friendNumBg:addChild(self.friendNumLb)
	self.bgLayer:addChild(friendNumBg)
end

function friendDialogNewTabGF:initRewards()
	for k,v in pairs(self.curRewardList) do
		v:removeFromParentAndCleanup(true)
	end
	self.curRewardList={}
	for k,v in pairs(self.nextRewardList) do
		v:removeFromParentAndCleanup(true)
	end
	self.nextRewardList={}

	local cfg,index=friendVoApi:getCurFriendsNumRewardCfg()
	self.curRewardCfg=cfg
	self.curRewardIndex=index
	if(self.curRewardCfg~=nil)then
		if(self.friendsNum>=self.curRewardCfg.num)then
			self.canReward=true
		else
			self.canReward=false
		end
	else
		self.curRewardCfg=friendCfg.totalReward[#friendCfg.totalReward]
		self.canReward=false
	end	

	local curReward=FormatItem(self.curRewardCfg.reward)
	local centerX=self.rewardBg:getContentSize().width/2
	local rewardLength=#curReward
	local iconWidth=(self.rewardBgHeight-20)/2
	for k,v in pairs(curReward) do
		local icon=G_getItemIcon(v,iconWidth,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		local posX=centerX+(k-(rewardLength+1)/2)*(iconWidth+5)
		icon:setPosition(ccp(posX,(self.rewardBgHeight+50)/2+10))
		self.curRewardList[k]=icon
		self.rewardBg:addChild(icon)
	end
	if(self.canReward)then
		self.rewardItem:setEnabled(true)
	else
		self.rewardItem:setEnabled(false)
	end

	if(self.nextRewardLb)then
		self.nextRewardLb:removeFromParentAndCleanup(true)
	end
	self.nextRewardCfg=friendVoApi:getNextFriendsNumRewardCfg()
	if(self.nextRewardCfg==nil)then
		local noNextLb=GetTTFLabel(getlocal("friend_maxNum"),30)
		noNextLb:setPosition(getCenterPoint(self.nextRewardBg))
		self.nextRewardBg:addChild(noNextLb)
	else
		self.nextRewardLb=GetTTFLabel(getlocal("friend_nextReward"),25)
		self.nextRewardLb:setAnchorPoint(ccp(0,0.5))
		self.nextRewardLb:setPosition(ccp(10,self.rewardBgHeight-70))
		self.nextRewardBg:addChild(self.nextRewardLb)

		local nextReward=FormatItem(self.nextRewardCfg.reward)
		rewardLength=#nextReward
		for k,v in pairs(nextReward) do
			local icon=G_getItemIcon(v,iconWidth,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			local posX=centerX+(k-(rewardLength+1)/2)*(iconWidth+5)
			icon:setPosition(ccp(posX,(self.rewardBgHeight-50)/2-20))
			self.nextRewardList[k]=icon
			self.nextRewardBg:addChild(icon)
		end
	end	
end

function friendDialogNewTabGF:getReward()
	local function callback()
		local reward=FormatItem(self.curRewardCfg.reward)
		G_showRewardTip(reward, true)
		self:initRewards()
		self.friendNumLb:setString(getlocal("friend_friendNum",{self.friendsNum,self.curRewardCfg.num}))
	end
	friendVoApi:getFriendNumReward(self.curRewardIndex,self.facebookID,callback)
end