--kakao的好友数目奖励面板
friendDialogNewTabGF_Kakao={}

function friendDialogNewTabGF_Kakao:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	nc.layerNum=nil
	nc.parent=nil
	nc.friendsNum=0
	nc.curRewardList={}
	nc.nextRewardList={}
	nc.page=0
	nc.pageCellNum=20
	nc.cellTb={}			--将每个cell都存起来，用于异步加载图片回调的时候比较是否还是当前的cell
	return nc
end

function friendDialogNewTabGF_Kakao:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	local function requestListener(event,data)
		self:onInviteFriend(event,data)
	end
	self.requestListener=requestListener
	eventDispatcher:addEventListener("friend.onSendAppRequest",self.requestListener)
	self:getFriendsFromFB()
	return self.bgLayer
end

function friendDialogNewTabGF_Kakao:getFriendsFromFB()
	local function callback()
		self:onRefreshFriend()
	end
	friendVoApi:refreshFriend(callback)
end

function friendDialogNewTabGF_Kakao:onRefreshFriend()
	self.inviteData=friendVoApi:getInvitedFriendData()
	self:initDialog()
end

function friendDialogNewTabGF_Kakao:initDialog()
	self.contentLayer=CCLayer:create()
	self.bgLayer:addChild(self.contentLayer)
	local capInSet = CCRect(20, 20, 10, 10)
	local function nilFunc()
	end

	local tankIcon1=CCSprite:createWithSpriteFrameName("t10044_1.png")
	tankIcon1:setPosition(100,G_VisibleSizeHeight - 255)
	tankIcon1:setFlipX(true)
	self.contentLayer:addChild(tankIcon1)
	local tankIcon2=CCSprite:createWithSpriteFrameName("t10054_1.png")
	tankIcon2:setPosition(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 255)
	self.contentLayer:addChild(tankIcon2)

	self.inviteNumLb=GetTTFLabelWrap(getlocal("fb_friends_inviteNum",{self.inviteData.count}),25,CCSizeMake(G_VisibleSizeWidth - 350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	self.inviteNumLb:setAnchorPoint(ccp(0.5,1))
	self.inviteNumLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 215)
	self.contentLayer:addChild(self.inviteNumLb)

	self.inviteDescLb=GetTTFLabelWrap(getlocal("fb_friends_inviteAddPower"),25,CCSizeMake(G_VisibleSizeWidth - 350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	self.inviteDescLb:setColor(G_ColorYellow)
	self.inviteDescLb:setAnchorPoint(ccp(0.5,1))
	self.inviteDescLb:setPosition(G_VisibleSizeWidth/2,self.inviteNumLb:getPositionY() - self.inviteNumLb:getContentSize().height - 5)
	self.contentLayer:addChild(self.inviteDescLb)

	self:initInviteNumReward(capInSet,nilFunc)

	local friendsBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	friendsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,self.inviteBoxBg:getPositionY() - 75 - 115))
	friendsBg:setAnchorPoint(ccp(0,0))
	friendsBg:setPosition(30,115)
	self.contentLayer:addChild(friendsBg)

	self:initTableView(friendsBg)
	self:initForbidLayer()
end

function friendDialogNewTabGF_Kakao:initInviteNumReward(capInSet,nilFunc)
	self.inviteBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	self.inviteBoxBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,140))
	self.inviteBoxBg:setPosition(G_VisibleSizeWidth/2,self.inviteDescLb:getPositionY() - self.inviteDescLb:getContentSize().height - 5 - 70)
	self.contentLayer:addChild(self.inviteBoxBg)

	local function onShowInviteReward(object,fn,tag)
		if(tag)then
			local rewardIndex=tag - 100
			local rewardTb=FormatItem(friendCfg.kakaoReward[rewardIndex].reward)
			local str
			local tabStr = {"\n",G_showRewardTip(rewardTb,false,true),"\n"}
			local tabColor = {nil,G_ColorYellow,nil}
			local td=smallDialog:new()
			local dialog1=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
			sceneGame:addChild(dialog1,self.layerNum+1)
		end
	end
	local function onGetInviteReward(tag,object)
		if(tag)then
			local rewardIndex=tag - 200
			self:getInviteNumReward(rewardIndex)
		end
	end
	for i=1,4 do
		local posX=self.inviteBoxBg:getContentSize().width/8*(2*i - 1)
		local inviteBox=LuaCCSprite:createWithSpriteFrameName("Icon_novicePacks.png",onShowInviteReward)
		inviteBox:setScale(0.8)
		inviteBox:setPosition(posX,self.inviteBoxBg:getContentSize().height/2 + 20)
		inviteBox:setTag(100 + i)
		inviteBox:setTouchPriority(-(self.layerNum-1)*20-3)
		self.inviteBoxBg:addChild(inviteBox)
		if(self.inviteData.reward and string.find(self.inviteData.reward,i))then
			local lb=GetTTFLabel(getlocal("activity_hadReward"),25)
			lb:setColor(G_ColorGreen)
			lb:setPosition(posX,25)
			self.inviteBoxBg:addChild(lb)
		elseif(self.inviteData.count and tonumber(self.inviteData.count)>=friendCfg.kakaoReward[i].num)then
			local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetInviteReward,200 + i,getlocal("daily_scene_get"),25)
			rewardItem:setScale(0.6)
			local rewardMenu=CCMenu:createWithItem(rewardItem)
			rewardMenu:setPosition(posX,25)
			rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			self.inviteBoxBg:addChild(rewardMenu)
		else
			local lb=GetTTFLabel(getlocal("fb_friends_XXpeople",{friendCfg.kakaoReward[i].num}),25)
			lb:setPosition(posX,25)
			self.inviteBoxBg:addChild(lb)
		end
	end

end

function friendDialogNewTabGF_Kakao:initTableView(friendsBg)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,friendsBg:getContentSize().height - 20),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(0,10))
	friendsBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(30)
	if(#friendVoApi.invitable_friends>self.pageCellNum)then
		eventDispatcher:dispatchEvent("dialog.friend.page",{r=1})
	else
		eventDispatcher:dispatchEvent("dialog.friend.page",{r=0})
	end
end

function friendDialogNewTabGF_Kakao:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.ceil(math.min(self.pageCellNum,#friendVoApi.invitable_friends)/4)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,180)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.cellTb[idx + 1]=cell
		for i=1,4 do
			local friendData = friendVoApi.invitable_friends[self.page*self.pageCellNum + idx*4 + i]
			if(friendData==nil)then
				break
			end
			local posX=(G_VisibleSizeWidth - 60)/8*(2*i - 1)
			local function onLoadIcon(fn,icon)
				icon:setPosition(ccp(posX,135))
				icon:setScaleX(85/icon:getContentSize().width)
				icon:setScaleY(85/icon:getContentSize().height)
				if(cell == self.cellTb[idx + 1])then
					cell:addChild(icon)
				end
			end
			if(friendData.picture~=nil and friendData.picture~="")then
				if(friendData.picture~="public/defaultFBIcon.jpg")then
					LuaCCWebImage:createWithURL(friendData.picture,onLoadIcon);
				else
					local icon=CCSprite:create(friendData.picture)
					icon:setPosition(posX,135)
					icon:setScaleX(85/icon:getContentSize().width)
					icon:setScaleY(85/icon:getContentSize().height)
					cell:addChild(icon,2)
				end
			end
			local btnStr
			if(self.inviteData.inviteds and string.find(self.inviteData.inviteds,friendData.id))then
				local checkIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
				checkIcon:setPosition(ccp(posX,135))
				cell:addChild(checkIcon,2)
				btnStr=getlocal("fb_friends_alreadyInvited")
			else
				btnStr=getlocal("friend_invite")
			end
			local nameLb=GetTTFLabelWrap(friendData.name,22,CCSizeMake((G_VisibleSizeWidth - 60)/4 - 5,25),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			nameLb:setPosition(posX,70)
			cell:addChild(nameLb)
			local function onInvite(tag,object)
				if(tag)then
					local friendIndex=tag - 1000
					self:inviteFriend(friendIndex)
				end
			end
			local inviteItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onInvite,1000 + self.page*self.pageCellNum + idx*4 + i,btnStr,25)
			if(self.inviteData.inviteds and string.find(self.inviteData.inviteds,friendData.id))then
				inviteItem:setEnabled(false)
			end
			if(friendData.supported_device==false)then
				inviteItem:setEnabled(false)
			end
			inviteItem:setScale(0.7)
			local inviteMenu=CCMenu:createWithItem(inviteItem)
			inviteMenu:setPosition(posX,30)
			inviteMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(inviteMenu)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function friendDialogNewTabGF_Kakao:initForbidLayer()
	local function forbidClick()
	end
	local capInSet = CCRect(20, 20, 10, 10)
	self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
	self.topforbidSp:setPosition(ccp(0,0))
	self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,115))
	self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	self.topforbidSp:setVisible(false)
	self.topforbidSp:setAnchorPoint(ccp(0,0))
	self.contentLayer:addChild(self.topforbidSp)
end

function friendDialogNewTabGF_Kakao:pageChange(p)
	local totalPage = math.ceil(#friendVoApi.invitable_friends/self.pageCellNum)
	if(self.page+p<0)then
		return
	elseif(self.page+p>=totalPage and totalPage>0)then
		return
	else
		self.page=self.page+p
		if(self.page>0)then
			eventDispatcher:dispatchEvent("dialog.friend.page",{l=1})
		else
			eventDispatcher:dispatchEvent("dialog.friend.page",{l=0})
		end
		if(self.page<math.ceil(#friendVoApi.invitable_friends/self.pageCellNum)-1)then
			eventDispatcher:dispatchEvent("dialog.friend.page",{r=1})
		else
			eventDispatcher:dispatchEvent("dialog.friend.page",{r=0})
		end
		if(self.tv~=nil)then
		   self.tv:reloadData()
		end
	end
end

function friendDialogNewTabGF_Kakao:getInviteNumReward(rewardIndex)
	friendVoApi:getInviteFriendReward('{"rewardIndex":'..rewardIndex..'}')
	self.inviteData=friendVoApi:getInvitedFriendData()
	self.inviteBoxBg:removeFromParentAndCleanup(true)
	local capInSet = CCRect(20, 20, 10, 10)
	local function nilFunc()
	end
	self:initInviteNumReward(capInSet,nilFunc)
end

function friendDialogNewTabGF_Kakao:inviteFriend(friendIndex)
	local friendData=friendVoApi.invitable_friends[friendIndex]
	if(friendData and friendData.id)then
		local function onConfirm()
			local tmpTb={}
			tmpTb["action"]="showSocialView"
			tmpTb["parms"]={}
			tmpTb["parms"]["uids"]=friendData.id
			tmpTb["parms"]["message"]=getlocal("feedDesc3")
			local cjson=G_Json.encode(tmpTb)
			G_accessCPlusFunction(cjson)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),friendData.name.."님에게 카카오톡으