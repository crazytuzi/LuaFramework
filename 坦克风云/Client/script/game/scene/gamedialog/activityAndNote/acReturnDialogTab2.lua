acReturnDialogTab2={}

function acReturnDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	return nc
end

function acReturnDialogTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/2-62))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,25))

	local bgSize=background:getContentSize()

	local chestName=GetTTFLabel(getlocal("activity_oldUserReturn_stayReward"),25)
	chestName:setAnchorPoint(ccp(0,1))
	chestName:setPosition(ccp(20,bgSize.height-20))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)

	local chestIcon=CCSprite:createWithSpriteFrameName("CommonBox.png")
	chestIcon:setAnchorPoint(ccp(0,0.5))
	chestIcon:setPosition(20,bgSize.height*3/4)
	background:addChild(chestIcon)

	local chestDesc=GetTTFLabelWrap(getlocal("activity_oldUserReturn_stayRewardDesc"),23,CCSizeMake(420, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	chestDesc:setAnchorPoint(ccp(0,0.5))
	chestDesc:setPosition(ccp(170,bgSize.height*3/4))
	background:addChild(chestDesc)

	local minPosY
	local iconY=chestIcon:getPositionY()-chestIcon:getContentSize().height/2
	local lbY=chestDesc:getPositionY()-chestDesc:getContentSize().height/2
	if(iconY>lbY)then
		minPosY=lbY
	else
		minPosY=iconY
	end

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),function () end)
	tvBg:setContentSize(CCSizeMake(bgSize.width-40,minPosY-120))
	tvBg:setAnchorPoint(ccp(0.5,1))
	tvBg:setPosition(ccp(bgSize.width/2,minPosY-10))
	background:addChild(tvBg)

	self.tvHeight=tvBg:getContentSize().height-20
	self.rewardTb=FormatItem(activityCfg.oldUserReturn.serverreward.box2)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	local tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width-40,self.tvHeight),nil)
	tv:setPosition(ccp(20,10))
	tv:setMaxDisToBottomOrTop(100)
	tvBg:addChild(tv)

	local function onGetReward()
        if(playerVoApi:getPlayerLevel()<10)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_lvNotEnough",{10}),30)
			do return end
        end
		if(acReturnVoApi:getUserType()~=0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_cant2"),30)
			do return end
		end
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
    	    if(ret==true)then
    	    	local reward=activityCfg.oldUserReturn.serverreward.box2
			    rewardTb=FormatItem(reward,true)
			    for k,v in pairs(rewardTb) do
      				G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
			    end
			    G_showRewardTip(rewardTb, true)
			    accessoryVoApi.dataNeedRefresh=true
			    acReturnVoApi:setUserRewardGot()
			    self.rewardMenuItem:setEnabled(false)
	        end
		end
		socketHelper:activeReturnGetReward(1,callback)
	end
	self.rewardMenuItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,nil,nil,nil)
	self.rewardMenuItem:setAnchorPoint(ccp(0.5,0))
	if(acReturnVoApi:getUserType()==0 and acReturnVoApi:getUserRewardStatus()==1)then
		self.rewardMenuItem:setEnabled(false)
	end
	local rewardMenuBtn=CCMenu:createWithItem(self.rewardMenuItem)
	rewardMenuBtn:setAnchorPoint(ccp(0.5,0))
	rewardMenuBtn:setPosition(ccp(bgSize.width/2,10))
	background:addChild(rewardMenuBtn)

	self.bgLayer:addChild(background)

	return self.bgLayer
end

function acReturnDialogTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.rewardTb
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake((G_VisibleSizeWidth-80)/4,self.tvHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local capInSet = CCRect(20, 20, 10, 10);
		local function onClick()
			propInfoDialog:create(sceneGame,self.rewardTb[idx+1],self.layerNum+1)
		end
		local chestIcon=G_getItemIcon(self.rewardTb[idx+1],100,false,self.layerNum,onClick)
		chestIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		chestIcon:setAnchorPoint(ccp(0,0.5))
		chestIcon:setPosition(0,self.tvHeight/2)
		local numLb=GetTTFLabel("x"..self.rewardTb[idx+1].num,20)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(ccp(chestIcon:getContentSize().width-5,5))
		chestIcon:addChild(numLb)
		cell:addChild(chestIcon)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end
