acOldReturnDialogTab1={}

function acOldReturnDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	nc.layerNum=nil
	return nc
end

function acOldReturnDialogTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.acVo=acOldReturnVoApi:getAcVo()
	self:initStay()
	self:initAllServerReturn()
	return self.bgLayer
end

function acOldReturnDialogTab1:initStay()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/4-52))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/4+15))

	local bgSize=background:getContentSize()

	local chestIcon=CCSprite:createWithSpriteFrameName("item_baoxiang_05.png")
	chestIcon:setPosition(70,bgSize.height/2)
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(100,100)

	local chestName=GetTTFLabel(getlocal("activity_twolduserreturn_stayChest"),25)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)
    
    local textSize = 23
    if G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="ru" then
        textSize = 20
    end
    local reward=self.acVo.cfg.staybehindreward[1]
    local rewardTb=FormatItem(reward,true)
    local rewardStr=""
    for k,v in pairs(rewardTb) do
    	rewardStr=rewardStr..v.name.."x"..v.num..","
    end
    rewardStr=string.sub(rewardStr,1,string.len(rewardStr) - 1)
	local chestDesc =G_LabelTableView(CCSizeMake(350, 150),getlocal("activity_twolduserreturn_stayDesc",{rewardStr}),textSize,kCCTextAlignmentLeft)
	chestDesc:setMaxDisToBottomOrTop(30)
    chestDesc:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	--local chestDesc=GetTTFLabelWrap(getlocal("activity_oldUserReturn_rewardDesc"),textSize,CCSizeMake(440, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setAnchorPoint(ccp(0,0.5))
	chestDesc:setPosition(ccp(130,bgSize.height*0.2-20))
	background:addChild(chestDesc)

	local function onGetReward()
        if(playerVoApi:getPlayerLevel()<self.acVo.cfg.minlevel)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_lvNotEnough",{self.acVo.cfg.minlevel}),30)
			do return end
        end
		if(acOldReturnVoApi:getUserType()~=0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_cant2"),30)
			do return end
		end
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
    	    if(ret==true)then
    	    	local reward=sData.data.reward
			    local rewardTb=FormatItem(reward,true)
			    for k,v in pairs(rewardTb) do
      				G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
			    end
			    G_showRewardTip(rewardTb, true)
			    accessoryVoApi.dataNeedRefresh=true
			    acOldReturnVoApi:setUserRewardGot()
			    self.rewardMenuItem1:setEnabled(false)
	        end
		end
		socketHelper:activityOldUserReturnTw("reward",1,callback)
	end
	self.rewardMenuItem1=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,nil,nil,nil)
	self.rewardMenuItem1:setAnchorPoint(ccp(1,0))
	if(acOldReturnVoApi:getUserType()==0 and acOldReturnVoApi:getUserRewardStatus()==1)then
		self.rewardMenuItem1:setEnabled(false)
	end
	local rewardMenuBtn=CCMenu:createWithItem(self.rewardMenuItem1)
	rewardMenuBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardMenuBtn:setAnchorPoint(ccp(1,0))
	rewardMenuBtn:setPosition(ccp(bgSize.width-5,5))
	background:addChild(rewardMenuBtn)

	self.bgLayer:addChild(background)
end

function acOldReturnDialogTab1:initAllServerReturn()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/4-20))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,25))

	local bgSize=background:getContentSize()

	local reward=FormatItem(self.acVo.cfg.totalreward)
	local chestIcon=G_getItemIcon(reward[1],100,true,self.layerNum+1)
	chestIcon:setScale(100/chestIcon:getContentSize().width)
	chestIcon:setPosition(70,bgSize.height/2)
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(100,100)
	local leftX=chestIcon:getPositionX()-iconSize.width/2

	local chestName=GetTTFLabelWrap(getlocal("activity_twolduserreturn_returnReward"),25,CCSizeMake(background:getContentSize().width-leftX,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(leftX,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)

	local hasReturned=GetTTFLabel(getlocal("activity_oldUserReturn_totalReturn",{acOldReturnVoApi:getServerReturnNum()}),23)
	hasReturned:setAnchorPoint(ccp(0,0))
	hasReturned:setPosition(ccp(leftX,(chestIcon:getPositionY()-iconSize.height/2)/2+2))
	background:addChild(hasReturned)

	local canGet=GetTTFLabel(getlocal("canReward")..": "..acOldReturnVoApi:getServerRewardCanGet(),23)
	canGet:setAnchorPoint(ccp(0,1))
	canGet:setPosition(ccp(leftX,(chestIcon:getPositionY()-iconSize.height/2)/2))
	background:addChild(canGet)
    
    local textSize = 23
    if G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="ru" then
        textSize = 20
    end

	local chestDesc=GetTTFLabelWrap(getlocal("activity_twolduserreturn_returnAllDesc",{reward[1].name,reward[1].num}),textSize,CCSizeMake(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setAnchorPoint(ccp(0,1))
	chestDesc:setPosition(ccp(130,bgSize.height/2+55))
	background:addChild(chestDesc)

	local function onGetReward()
        if(playerVoApi:getPlayerLevel()<10)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_oldUserReturn_lvNotEnough",{10}),30)
			do return end
        end
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
    	    if(ret==true)then
			    for k,v in pairs(reward) do
      				G_addPlayerAward(v.type, v.key, v.id,tonumber(acOldReturnVoApi:getServerRewardCanGet()))
			    end
			    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("active_lottery_reward_tank",{reward[1].name," x"..acOldReturnVoApi:getServerRewardCanGet()}),30)
                acOldReturnVoApi:setServerRewardGot()
                canGet:setString(getlocal("canReward")..": "..acOldReturnVoApi:getServerRewardCanGet())
                self.rewardMenuItem2:setEnabled(false)
	        end
		end
		socketHelper:activityOldUserReturnTw("reward",2,callback)
	end
	self.rewardMenuItem2=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,nil,nil,nil)
	self.rewardMenuItem2:setAnchorPoint(ccp(1,0))
	if(acOldReturnVoApi:getServerRewardCanGet()<=0)then
		self.rewardMenuItem2:setEnabled(false)
	end
	local rewardMenuBtn=CCMenu:createWithItem(self.rewardMenuItem2)
	rewardMenuBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardMenuBtn:setAnchorPoint(ccp(1,0))
	rewardMenuBtn:setPosition(ccp(bgSize.width-5,5))
	background:addChild(rewardMenuBtn)

	self.bgLayer:addChild(background)
end