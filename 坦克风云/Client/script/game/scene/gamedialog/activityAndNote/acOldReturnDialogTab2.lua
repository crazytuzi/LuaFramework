acOldReturnDialogTab2={}

function acOldReturnDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	nc.layerNum=nil
	return nc
end

function acOldReturnDialogTab2:init(layerNum)
	self.acVo=acOldReturnVoApi:getAcVo()
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/2-62))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,25))
	self.bgLayer:addChild(background)

	local bgSize=background:getContentSize()

	local descLb=GetTTFLabelWrap(getlocal("activity_twolduserreturn_feed_reward",{self.acVo.cfg.shareReward}),25,CCSizeMake(bgSize.width - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(ccp(G_VisibleSizeWidth/2,25 + bgSize.height/2))
	self.bgLayer:addChild(descLb)
	local function onSendFeed()
		local function onFeedCallback()
			if(acOldReturnVoApi:getFeedRewardTime()<G_getWeeTs(base.serverTime))then
				local function onRequestEnd(fn,data)
					local ret,sData=base:checkServerData(data)
					if(ret==true)then
					    acOldReturnVoApi:setFeedRewardTime(base.serverTime)
					    playerVoApi:setGems(playerVoApi:getGems() + self.acVo.cfg.shareReward)
					    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_twolduserreturn_feed_success",{self.acVo.cfg.shareReward}),30)
					end
				end
				socketHelper:activityOldUserReturnTw("reward",3,onRequestEnd)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),30)
			end
		end
		G_sendFeed(5,onFeedCallback)
	end
	local feedItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onSendFeed,nil,getlocal("read_email_report_share"),25)
	local feedBtn=CCMenu:createWithItem(feedItem)
	feedBtn:setAnchorPoint(ccp(0.5,0))
	feedBtn:setPosition(ccp(G_VisibleSizeWidth/2,80))
	self.bgLayer:addChild(feedBtn)

	return self.bgLayer
end