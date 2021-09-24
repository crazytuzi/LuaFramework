acOldReturnDialogTab3={}

function acOldReturnDialogTab3:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	return nc
end

function acOldReturnDialogTab3:init(layerNum)
	self.acVo=acOldReturnVoApi:getAcVo()
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	local bgSize=CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/2-62)
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(bgSize)
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,25))
	self.bgLayer:addChild(background)
	local function onClickBox()
		local index=playerVoApi:getPlayerLevel() - self.acVo.cfg.minlevel + 1
		if(index<1)then
			index=1
		end
		local awardTab=FormatItem(self.acVo.cfg.box[index],true)
		smallDialog:showRewardDialog("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,{},25,awardTab)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local chestIcon=LuaCCSprite:createWithSpriteFrameName("silverBox.png",onClickBox)
	chestIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	chestIcon:setScale(1.2)
	chestIcon:setPosition(ccp(G_VisibleSizeWidth/2,25 + bgSize.height*3/4 + 10))
	self.bgLayer:addChild(chestIcon)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,25 + bgSize.height/2 + 20))
	self.bgLayer:addChild(lineSp)
	local descTitle=GetTTFLabel(getlocal("activity_oldUserReturn_rewardTitle"),25)
	descTitle:setColor(G_ColorYellowPro)
	descTitle:setAnchorPoint(ccp(0.5,1))
	descTitle:setPosition(G_VisibleSizeWidth/2,25 + bgSize.height/2)
	self.bgLayer:addChild(descTitle)
	local desc=GetTTFLabelWrap(getlocal("activity_twolduserreturn_returnDesc",{self.acVo.cfg.sendday}),25,CCSizeMake(bgSize.width - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desc:setAnchorPoint(ccp(0.5,1))
	desc:setPosition(ccp(G_VisibleSizeWidth/2,25 + bgSize.height/2 - descTitle:getContentSize().height))
	self.bgLayer:addChild(desc)
	local function onGetReward()
        if(playerVoApi:getPlayerLevel()<10)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_lvNotEnough",{10}),30)
			do return end
        end
		if(acOldReturnVoApi:getUserType()~=1)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_cant1"),30)
			do return end
		end
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
    	    if(ret==true)then
    	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_twolduserreturn_back_success",{self.acVo.cfg.sendday}),30)
			    self.rewardMenuItem:setEnabled(false)
                acOldReturnVoApi:setUserRewardGot()
	        end
		end
		socketHelper:activityOldUserReturnTw("reward",1,callback)
	end
	self.rewardMenuItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,nil,nil,nil)
	if(acOldReturnVoApi:getUserType()==1 and acOldReturnVoApi:getUserRewardStatus()==1)then
		self.rewardMenuItem:setEnabled(false)
	end
	local rewardMenuBtn=CCMenu:createWithItem(self.rewardMenuItem)
	rewardMenuBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardMenuBtn:setPosition(ccp(G_VisibleSizeWidth/2,50))
	background:addChild(rewardMenuBtn)
	return self.bgLayer
end