acZnkh2017Tab1 ={}
function acZnkh2017Tab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    return nc
end

function acZnkh2017Tab1:init()
	self.bgLayer=CCLayer:create()
	self:initHead()
	self:initBottom()
	return self.bgLayer
end

function acZnkh2017Tab1:initHead()
	-- local cfg=acZnkh2017VoApi:getActiveCfg()
 --    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210)
 --    local tabStr={" ",getlocal("activity_znkh2017_tip2"),getlocal("activity_znkh2017_tip1",{cfg.needMoney})," "}
 --    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,0.9,nil)
 	local addH=0
    local titlePosY=G_VisibleSizeHeight-160
	if G_isIphone5()==true then
		titlePosY=G_VisibleSizeHeight-180
		addH=-20
	end
	local titleNode=CCNode:create()
	titleNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,1))
	titleNode:setAnchorPoint(ccp(0.5,0.5))
	titleNode:setPosition(ccp(G_VisibleSizeWidth/2,titlePosY))
	self.bgLayer:addChild(titleNode)

	local haloSp=CCSprite:createWithSpriteFrameName("anniversaryHalo.png")
	haloSp:setAnchorPoint(ccp(0.5,1))
	haloSp:setScaleY(1.5)
	haloSp:setPosition(G_VisibleSizeWidth/2,-110)
	titleNode:addChild(haloSp)
	local ribbonSp1=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
	ribbonSp1:setPosition(G_VisibleSizeWidth/2,-140)
	titleNode:addChild(ribbonSp1)
	local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	lightSp:setPosition(G_VisibleSizeWidth/2,-70)
	titleNode:addChild(lightSp)
	local titleBg=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,0))
    titleBg:setScaleX(1.1)
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,-155))
    titleNode:addChild(titleBg)
	local timeLb1=GetTTFLabel(getlocal("activity_timeLabel"),25)
	timeLb1:setColor(G_ColorGreen)
	timeLb1:setPosition(G_VisibleSizeWidth/2,-160+addH)
	titleNode:addChild(timeLb1)
	local timeBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	timeBg:setPosition(G_VisibleSizeWidth/2,-200+addH)
	titleNode:addChild(timeBg)
	local timeStr=acZnkh2017VoApi:getTimeStr()
	local timeLb2=GetTTFLabel(timeStr,25)
	timeLb2:setColor(G_ColorYellowPro)
	timeLb2:setPosition(G_VisibleSizeWidth/2,-200+addH)
	titleNode:addChild(timeLb2)
	if(G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw")then
		local lb1=GetTTFLabel(getlocal("activity_anniversary_birthday1"),25)
		lb1:setColor(G_ColorYellowPro)
		lb1:setAnchorPoint(ccp(1,0.5))
		lb1:setPosition(G_VisibleSizeWidth/2-50,-115)
		titleNode:addChild(lb1)
		local sp1=CCSprite:createWithSpriteFrameName("crackerLight.png")
		sp1:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(sp1)
		local sp2=CCSprite:createWithSpriteFrameName("threenum.png")
		sp2:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(sp2)
		local lb2=GetTTFLabel(getlocal("activity_anniversary_birthday2"),25)
		lb2:setColor(G_ColorYellowPro)
		lb2:setAnchorPoint(ccp(0,0.5))
		lb2:setPosition(G_VisibleSizeWidth/2+50,-115)
		titleNode:addChild(lb2)
	else
		local lb=GetTTFLabel(getlocal("activity_anniversary_birthday"),strSize3)
		lb:setColor(G_ColorYellowPro)
		lb:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(lb)
	end
end

function acZnkh2017Tab1:initBottom()
	local addH=0
	local addBgH=0
	local cfg=acZnkh2017VoApi:getActiveCfg()
	local bottomPosY=40
	local bottomH=G_VisibleSizeHeight-380-bottomPosY
	if G_isIphone5()==true then
		bottomH=G_VisibleSizeHeight-450-bottomPosY
		addH=-20
		addBgH=30
	end
	local function nilFunc()
	end
	local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
	bottomBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,bottomH))
	bottomBg:setPosition(ccp(30,bottomPosY))
	bottomBg:setAnchorPoint(ccp(0,0))
	self.bgLayer:addChild(bottomBg)
	self.bottomBg=bottomBg

	local bottomSize=bottomBg:getContentSize()

	local smallTitleLb1=GetTTFLabel(getlocal("activity_znkh2017_tab1_title1"),25)
	smallTitleLb1:setColor(G_ColorYellowPro)
	smallTitleLb1:setAnchorPoint(ccp(0.5,0.5))
	smallTitleLb1:setPosition(ccp(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2+addH))
	bottomBg:addChild(smallTitleLb1,1)

	local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
	bottomBg:addChild(titleBg1)
	titleBg1:setPosition(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2+addH)
	titleBg1:setContentSize(CCSizeMake(smallTitleLb1:getContentSize().width+150,math.max(smallTitleLb1:getContentSize().height,50)))

	local sbBg1=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	bottomBg:addChild(sbBg1)
	sbBg1:setAnchorPoint(ccp(0.5,1))
	sbBg1:setContentSize(CCSizeMake(bottomSize.width-20,160+addBgH))
	sbBg1:setPosition(bottomSize.width/2,bottomSize.height-60+addH)

	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp1:setPosition(ccp(5,sbBg1:getContentSize().height/2))
	sbBg1:addChild(pointSp1)
	local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp2:setPosition(ccp(sbBg1:getContentSize().width-5,sbBg1:getContentSize().height/2))
	sbBg1:addChild(pointSp2)

	local sbSize1=sbBg1:getContentSize()

	local vipLevel=playerVoApi:getVipLevel() or 0
	local vipLvlb=GetTTFLabelWrap(getlocal("activity_znkh2017_vipLevel",{vipLevel}),25,CCSizeMake(sbBg1:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	vipLvlb:setAnchorPoint(ccp(0,0))
	vipLvlb:setPosition(20,10)
	sbBg1:addChild(vipLvlb)
	vipLvlb:setColor(G_ColorYellowPro)

	local headSpH=(sbSize1.height-(10+vipLvlb:getContentSize().height))/2+10+vipLvlb:getContentSize().height-5
	local function touchHeadSp()
	end
	local iconPic="znkh2017Icon.png"
	local iconItem=acZnkh2017VoApi:getPlayerIcon()
	if iconItem then
		iconPic=iconItem[1].pic
	end
	local headSp=playerVoApi:GetPlayerBgIcon(iconPic,touchHeadSp,nil,70,100)
	sbBg1:addChild(headSp)
	headSp:setAnchorPoint(ccp(0,0.5))
	headSp:setPosition(20,headSpH)

	local getHeadLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab1_des1",{cfg.needVip}),25,CCSizeMake(sbBg1:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	getHeadLb:setAnchorPoint(ccp(0,0.5))
	getHeadLb:setPosition(130,headSpH)
	sbBg1:addChild(getHeadLb)


	local titleBg2H=bottomSize.height-60-sbBg1:getContentSize().height-10
	local smallTitleLb2=GetTTFLabel(getlocal("activity_znkh2017_tab1_title2"),25)
	smallTitleLb2:setColor(G_ColorYellowPro)
	smallTitleLb2:setAnchorPoint(ccp(0.5,0.5))
	smallTitleLb2:setPosition(ccp(bottomSize.width/2,titleBg2H - smallTitleLb2:getContentSize().height/2+2*addH))
	bottomBg:addChild(smallTitleLb2,1)
	local  titleBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
	bottomBg:addChild(titleBg2)
	titleBg2:setPosition(bottomSize.width/2,titleBg2H - smallTitleLb2:getContentSize().height/2+2*addH)
	titleBg2:setContentSize(CCSizeMake(smallTitleLb2:getContentSize().width+150,math.max(smallTitleLb2:getContentSize().height,50)))

	local des2LbH=titleBg2H-50
	if G_isIphone5()==true then
		des2LbH=des2LbH-20
	end
	local des2Lb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab1_des2"),25,CCSizeMake(bottomSize.width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	des2Lb:setAnchorPoint(ccp(0,1))
	bottomBg:addChild(des2Lb)
	des2Lb:setPosition(20,des2LbH+2*addH)

	if vipLevel<cfg.needVip then
		-- 充值
		local function onRecharge()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
            activityAndNoteDialog:closeAllDialog()
	        vipVoApi:showRechargeDialog(self.layerNum-1)
		end
		local rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onRecharge,11,getlocal("recharge"),25,12)
		local rechargeBtn=CCMenu:createWithItem(rechargeItem)
		rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rechargeBtn:setPosition(sbSize1.width-90,45)
		sbBg1:addChild(rechargeBtn,1)
	else
		self.alreadyLb=GetTTFLabel(getlocal("activity_hadReward"),25)
		self.alreadyLb:setColor(G_ColorWhite)
		self.alreadyLb:setPosition(sbSize1.width-90,45)
		sbBg1:addChild(self.alreadyLb,1)

		if tonumber(acZnkh2017VoApi:getV())~=1 then
			--  领取头像奖励
			local function onGetR()
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				local function refreshFunc()
					self.getRBtn:setVisible(false)
					self.alreadyLb:setVisible(true)
					self.alreadyLb:setColor(G_ColorGray)
                  	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
				end
				acZnkh2017VoApi:socketZnkh2017(refreshFunc,1,nil,nil,nil)
			end
			local getRItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetR,11,getlocal("daily_scene_get"),25,12)
			local getRBtn=CCMenu:createWithItem(getRItem)
			getRBtn:setTouchPriority(-(self.layerNum-1)*20-4)
			getRBtn:setPosition(sbSize1.width-90,45)
			sbBg1:addChild(getRBtn,1)
			self.getRBtn=getRBtn
			self.alreadyLb:setVisible(false)
		else
			self.alreadyLb:setColor(G_ColorGray)
		end
	end

	local sbBg2H=des2LbH-des2Lb:getContentSize().height
	if G_isIphone5()==true then
		sbBg2H=sbBg2H-20
	end
	local sbBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	bottomBg:addChild(sbBg2)
	sbBg2:setAnchorPoint(ccp(0.5,1))
	sbBg2:setContentSize(CCSizeMake(bottomSize.width-20,sbBg2H-20+2*addH))
	sbBg2:setPosition(bottomSize.width/2,sbBg2H-10+2*addH)
	self.sbBg2=sbBg2
	self:initOrRefreshSbBg2()
end

function acZnkh2017Tab1:initOrRefreshSbBg2(flag)
	local sbBg2=self.sbBg2
	if flag then
		local posX,poxY=sbBg2:getPosition()
		local contentSize=sbBg2:getContentSize()
		sbBg2:removeFromParentAndCleanup(true)
		local function nilFunc()
		end
		sbBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
		self.bottomBg:addChild(sbBg2)
		sbBg2:setAnchorPoint(ccp(0.5,1))
		sbBg2:setContentSize(contentSize)
		sbBg2:setPosition(posX,poxY)
		self.sbBg2=sbBg2
	end
	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp1:setPosition(ccp(5,sbBg2:getContentSize().height/2))
	sbBg2:addChild(pointSp1)
	local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp2:setPosition(ccp(sbBg2:getContentSize().width-5,sbBg2:getContentSize().height/2))
	sbBg2:addChild(pointSp2)
	
	local cfg=acZnkh2017VoApi:getActiveCfg()

	local sbSize2=sbBg2:getContentSize()

	local day=acZnkh2017VoApi:getTheDayOfActive()
	local dailyReward=cfg.loginPrize[day] or cfg.loginPrize[#cfg.loginPrize]
	local rewardItem=FormatItem(dailyReward,nil,true)
	local flag=false
	if #rewardItem>3 then
		flag=true
	end
	for k,v in pairs(rewardItem) do
		local icon=G_getItemIcon(v,100,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		sbBg2:addChild(icon)
		if flag then
			if k>3 then
				icon:setPosition((k-1-3)*110+70,sbSize2.height/4)
			else
				icon:setPosition((k-1)*110+70,sbSize2.height/4*3)
			end
		else
			icon:setPosition((k-1)*110+70,sbSize2.height/2)
		end

		local numLb=GetTTFLabel("x" .. v.num,25)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(ccp(85,5))
		icon:addChild(numLb)
		numLb:setScale(1/numLb:getScale())
	end

	local function onGetReward()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local function refreshFunc()
			for k,v in pairs(rewardItem) do
	            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
            end
			acZnkh2017VoApi:showRewardDialog(rewardItem,self.layerNum)
			self:refreshDailyReward()

		end
		local day=acZnkh2017VoApi:getTheDayOfActive()
		acZnkh2017VoApi:socketZnkh2017(refreshFunc,2,day,nil,nil)
	end
	local rewardItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,11,nil,25,12)
	self.rewardBtn=CCMenu:createWithItem(rewardItem)
	self.rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.rewardBtn:setPosition(sbSize2.width-90,sbSize2.height/2)
	sbBg2:addChild(self.rewardBtn,1)

	self.rewardLb=GetTTFLabel(getlocal("activity_hadReward"),25)
	self.rewardLb:setColor(G_ColorWhite)
	self.rewardLb:setPosition(sbSize2.width-90,sbSize2.height/2)
	sbBg2:addChild(self.rewardLb,1)
	self:refreshDailyReward()
end

function acZnkh2017Tab1:refreshDailyReward()
	local flag=acZnkh2017VoApi:isGetDailyReward()
	if flag~=1 then
		self.rewardLb:setVisible(false)
		self.rewardBtn:setVisible(true)
	else
		self.rewardLb:setVisible(true)
		self.rewardLb:setColor(G_ColorGray)
		self.rewardBtn:setVisible(false)
	end
end

function acZnkh2017Tab1:addTV()
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acZnkh2017Tab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,200)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end


function acZnkh2017Tab1:refresh()
	self:initOrRefreshSbBg2(true)
	acZnkh2017VoApi:updateStateChanged()
end

function acZnkh2017Tab1:tick()
end

function acZnkh2017Tab1:dispose( )
    self.layerNum=nil
end