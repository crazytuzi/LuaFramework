acNewYearDialog = commonDialog:new()

function acNewYearDialog:new(parent,layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index = self

	nc.activityType = {FIRST_AC = 1,SECOND_AC = 2,THIRD_AC = 3,FOURTH_AC = 4}
	nc.freeGiftBox = nil
	nc.chargeGiftBox = nil
	nc.getGoldBtn = nil
	nc.getGoldLabel = nil
	nc.chargeGoldLabel = nil
	nc.freeGiftLabel = nil
	nc.chargeGiftLable = nil
	nc.chargeGoldIcon = nil
    nc.freeGiftAni = nil
    nc.chargeGiftAni = nil
    nc.freeGiftLight = nil
    nc.chargeGiftLight = nil
    nc.priceBg1 = nil
    nc.priceBg2 = nil
    nc.chargeBtn = nil
    nc.confirmDialog = nil
    nc.isOpen = false
    nc.lastFreeRewardFlag = nil
    nc.lastChargeRewardFlag = nil
	nc.parent = parent
	nc.layerNum = layerNum
	return nc
end

function acNewYearDialog:initTableView()
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	self.panelLineBg:setVisible(false)
	self:initHead()
	self:initAcItems()
    self.isOpen = true
end

function acNewYearDialog:initHead()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

	local newyearHead = CCSprite:create("public/acNewYearHead.jpg")
	newyearHead:setAnchorPoint(ccp(0.5,1))
	newyearHead:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 80))
	self.bgLayer:addChild(newyearHead)

    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
	timeTitle:setAnchorPoint(ccp(0.5,1))
	timeTitle:setColor(G_ColorGreen)
	newyearHead:addChild(timeTitle,1)
	timeTitle:setPosition(ccp(newyearHead:getContentSize().width/2,newyearHead:getContentSize().height - 10))

	local timeStr = acNewYearVoApi:getTimeStr()
    local timeStrLabel = GetTTFLabel(timeStr,25)
	timeStrLabel:setAnchorPoint(ccp(0.5,1))
	newyearHead:addChild(timeStrLabel,1)
	timeStrLabel:setPosition(ccp(newyearHead:getContentSize().width/2,newyearHead:getContentSize().height - 40))


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

end

function acNewYearDialog:initAcItems()
    local scaleY = 0.8
    local height22 = 110
    local textScrollH = 80
    if(G_isIphone5()) then
       scaleY = 0.95
        height22 =150
       -- textScrollH = 120
    end
    local opscaleY = 1/scaleY
    local needSubHeight = 30
	local itemHeight = (G_VisibleSizeHeight - 240) / 4
	
    --第一个活动的页面
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
  
    
    local firstAcView = CCSprite:create("public/acNewYearItem.jpg")
	firstAcView:setAnchorPoint(ccp(0.5,1))
	firstAcView:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 210-needSubHeight))
    self.bgLayer:addChild(firstAcView,4)
    firstAcView:setScaleY(scaleY)
    local posY = G_VisibleSizeHeight - 210

    local titleBg1 = CCSprite:createWithSpriteFrameName("orangeMask.png")
    titleBg1:setAnchorPoint(ccp(0.5,1))
    titleBg1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 160))
    self.bgLayer:addChild(titleBg1)

    local acTitle1 = GetTTFLabelWrap(getlocal("activity_newyeargift_first_title"),22,CCSizeMake(360,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acTitle1:setAnchorPoint(ccp(0.5,0.5))
    acTitle1:setPosition(ccp(titleBg1:getContentSize().width/2,titleBg1:getContentSize().height/2))
    acTitle1:setColor(G_ColorYellow)
    titleBg1:addChild(acTitle1)

    local desTv1, desLabel1 = G_LabelTableView(CCSizeMake(firstAcView:getContentSize().width - 30, 70),getlocal("activity_newyeargift_first_content",{acNewYearVoApi:getPackageRewardTimeStr()}),20,kCCTextAlignmentLeft)
 	firstAcView:addChild(desTv1)
    desTv1:setPosition(ccp(20,180+needSubHeight))
    desTv1:setScaleY(opscaleY)
    desTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv1:setMaxDisToBottomOrTop(100)

    self.freeGiftLight = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.freeGiftLight:setScaleY(opscaleY)
    self.freeGiftLight:setPosition(ccp(firstAcView:getContentSize().width/4 * 1.4,70 + (self.freeGiftLight:getContentSize().height - 100)*opscaleY/2))
    firstAcView:addChild(self.freeGiftLight)
    print("freeGiftLight ========== "..self.freeGiftLight:getContentSize().height)

    local function touchFreeGiftBox()
    	self:touchFreeGiftBox()
    end
    self.freeGiftBox = self:createGiftBtn("friendBtn.png","friendBtnDOwn.png","friendBtnDOwn.png",touchFreeGiftBox,1,nil)
    self.freeGiftBox:setAnchorPoint(ccp(0.5,0.5))
    self.freeGiftBox:setScaleY(opscaleY)
    local freeGiftBoxMenu = CCMenu:createWithItem(self.freeGiftBox)
    freeGiftBoxMenu:setPosition(ccp(firstAcView:getContentSize().width/4 * 1.4,70 + (self.freeGiftBox:getContentSize().height + 10)*opscaleY/2))
    freeGiftBoxMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    firstAcView:addChild(freeGiftBoxMenu,1)

    print("freeGiftBox ======= ",self.freeGiftBox:getContentSize().height)
    print("freeGiftBoxMenu ======== ",freeGiftBoxMenu:getContentSize().height)

    local function touch()
        -- body
    end

    self.priceBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),touch)
    self.priceBg1:setContentSize(CCSizeMake(150,30))
    self.priceBg1:setAnchorPoint(ccp(0.5,1))
    self.priceBg1:setOpacity(150)
    self.priceBg1:setPosition(ccp(self.freeGiftBox:getContentSize().width/2,5))
    self.freeGiftBox:addChild(self.priceBg1,0)

    self.freeGiftLabel = GetTTFLabel(getlocal("daily_lotto_tip_2"),25)
    self.freeGiftLabel:setAnchorPoint(ccp(0.5,0.5))
    self.freeGiftLabel:setPosition(ccp(self.priceBg1:getContentSize().width/2,self.priceBg1:getContentSize().height/2))
    self.priceBg1:addChild(self.freeGiftLabel,1)



    -- self.freeGiftAni = CCParticleSystemQuad:create("public/acNewYearAni/kjl.plist")
    -- self.freeGiftAni.positionType=kCCPositionTypeFree
    -- self.freeGiftAni:setPosition(self.freeGiftBox:getContentSize().width/2,self.freeGiftBox:getContentSize().height/2)
    -- self.freeGiftBox:addChild(self.freeGiftAni)

    self.chargeGiftLight = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.chargeGiftLight:setScaleY(opscaleY)
    self.chargeGiftLight:setPosition(ccp(firstAcView:getContentSize().width/4 * 2.6,70 + (self.chargeGiftLight:getContentSize().height - 100)*opscaleY/2))
    firstAcView:addChild(self.chargeGiftLight)

 	local function touchChargeGiftBox()
    	self:touchChargeGiftBox()
    end
    self.chargeGiftBox = self:createGiftBtn("friendBtn.png","friendBtnDOwn.png","friendBtnDOwn.png",touchChargeGiftBox,1,nil)
    self.chargeGiftBox:setAnchorPoint(ccp(0.5,0.5))
    self.chargeGiftBox:setScaleY(opscaleY)
    local chargeGiftBoxMenu = CCMenu:createWithItem(self.chargeGiftBox)
    chargeGiftBoxMenu:setPosition(ccp(firstAcView:getContentSize().width/4 * 2.6,70 + (self.freeGiftBox:getContentSize().height + 10)*opscaleY/2))
    chargeGiftBoxMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    firstAcView:addChild(chargeGiftBoxMenu,1)

    self.priceBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),touch)
    self.priceBg2:setContentSize(CCSizeMake(150,30))
    self.priceBg2:setAnchorPoint(ccp(0.5,1))
    self.priceBg2:setOpacity(150)
    self.priceBg2:setPosition(ccp(self.chargeGiftBox:getContentSize().width/2,5))
    self.chargeGiftBox:addChild(self.priceBg2,0)

    self.chargeGiftLabel = GetTTFLabel(acNewYearVoApi:getChargeRewardsCost(),25)
    self.chargeGiftLabel:setAnchorPoint(ccp(0.5,0.5))
    self.chargeGiftLabel:setColor(G_ColorYellow)
    self.chargeGiftLabel:setPosition(ccp(self.priceBg2:getContentSize().width/2 - 15,self.priceBg2:getContentSize().height/2))
    self.priceBg2:addChild(self.chargeGiftLabel,1)

	self.chargeGoldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.chargeGoldIcon:setAnchorPoint(ccp(0.5,0.5))
	self.chargeGoldIcon:setPosition(ccp(self.priceBg2:getContentSize().width/2 + 35,self.priceBg2:getContentSize().height/2))
	self.priceBg2:addChild(self.chargeGoldIcon,1)

    -- self.chargeGiftAni = CCParticleSystemQuad:create("public/acNewYearAni/kjl.plist")
    -- self.chargeGiftAni.positionType=kCCPositionTypeFree
    -- self.chargeGiftAni:setPosition(self.chargeGiftBox:getContentSize().width/2,self.chargeGiftBox:getContentSize().height/2)
    -- self.chargeGiftBox:addChild(self.chargeGiftAni)

    --第二个活动的页面
    local secondAcView = CCSprite:create("public/acNewYearItem.jpg")
	secondAcView:setAnchorPoint(ccp(0.5,1))
	secondAcView:setPosition(ccp(G_VisibleSizeWidth/2,posY - itemHeight-needSubHeight))
    self.bgLayer:addChild(secondAcView,3)
    secondAcView:setScaleY(scaleY)
    posY = posY - itemHeight

    local titleBg2 = CCSprite:createWithSpriteFrameName("orangeMask.png")
    titleBg2:setAnchorPoint(ccp(0.5,1))
    titleBg2:setPosition(ccp(G_VisibleSizeWidth/2,firstAcView:getPositionY() - 195*scaleY))
    self.bgLayer:addChild(titleBg2,10)

    local acTitle2 = GetTTFLabelWrap(getlocal("activity_newyeargift_second_title"),22,CCSizeMake(360,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acTitle2:setAnchorPoint(ccp(0.5,0.5))
    acTitle2:setPosition(ccp(titleBg2:getContentSize().width/2,titleBg2:getContentSize().height/2))
    acTitle2:setColor(G_ColorYellow)
    titleBg2:addChild(acTitle2)


    local desTv2, desLabel2 = G_LabelTableView(CCSizeMake(430, textScrollH),getlocal("activity_newyeargift_second_content",{acNewYearVoApi:getCostGold(),acNewYearVoApi:getGiveGemsCount()}),20,kCCTextAlignmentLeft)
 	secondAcView:addChild(desTv2)
    -- desTv2:setPosition(ccp(20,100))
    desTv2:setPosition(ccp(20,height22))
    desTv2:setAnchorPoint(ccp(0,0))
    desTv2:setScaleY(opscaleY)
    desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv2:setMaxDisToBottomOrTop(100)

    local function onTouchReceiveBtn()
    	self:onTouchReceiveBtn()
    end
    self.getGoldBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png",onTouchReceiveBtn,nil,getlocal("daily_scene_get"),30)
    -- btnItem:setScale(0.6)
    self.getGoldBtn:setScaleY(opscaleY*0.9)
    self.getGoldBtn:setScaleX(0.9)
    local btnMenu2 = CCMenu:createWithItem(self.getGoldBtn)
    -- btnMenu2:setPosition(ccp(secondAcView:getContentSize().width-90,120))
    btnMenu2:setPosition(ccp(secondAcView:getContentSize().width - 90,155))
    btnMenu2:setTouchPriority(-(self.layerNum-1)*20-4)
    secondAcView:addChild(btnMenu2,1)

    local chargeStr = acNewYearVoApi:getCurChargeGold().."/"..acNewYearVoApi:getCostGold()
    self.chargeGoldLabel = GetTTFLabel(chargeStr,25)
    self.chargeGoldLabel:setAnchorPoint(ccp(0.5,0.5))
    self.chargeGoldLabel:setScaleY(opscaleY)
    self.chargeGoldLabel:setPosition(ccp(secondAcView:getContentSize().width - 90,btnMenu2:getPositionY() + self.getGoldBtn:getContentSize().height/2 + 20))
    secondAcView:addChild(self.chargeGoldLabel)

    self.getGoldLabel = GetTTFLabel(getlocal("activity_hadReward"),25)
    self.getGoldLabel:setColor(G_ColorGreen)
    self.getGoldLabel:setScaleY(opscaleY)
    self.getGoldLabel:setPosition(ccp(secondAcView:getContentSize().width - 90,(itemHeight - 70)/2 + 70))
    secondAcView:addChild(self.getGoldLabel)


    --第三个活动的页面
    local thirdAcView = CCSprite:create("public/acNewYearItem.jpg")
	thirdAcView:setAnchorPoint(ccp(0.5,1))
	thirdAcView:setPosition(ccp(G_VisibleSizeWidth/2,posY - itemHeight-needSubHeight))
    self.bgLayer:addChild(thirdAcView,2)
    thirdAcView:setScaleY(scaleY)
    posY = posY - itemHeight

    local titleBg3 = CCSprite:createWithSpriteFrameName("orangeMask.png")
    titleBg3:setAnchorPoint(ccp(0.5,1))
    titleBg3:setPosition(ccp(G_VisibleSizeWidth/2,secondAcView:getPositionY() - 195*scaleY))
    self.bgLayer:addChild(titleBg3,6)

    local acTitle3 = GetTTFLabelWrap(getlocal("activity_newyeargift_third_title"),22,CCSizeMake(360,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acTitle3:setAnchorPoint(ccp(0.5,0.5))
    acTitle3:setPosition(ccp(titleBg3:getContentSize().width/2,titleBg3:getContentSize().height/2))
    acTitle3:setColor(G_ColorYellow)
    titleBg3:addChild(acTitle3)

    local desTv3, desLabel3 = G_LabelTableView(CCSizeMake(430, 80),getlocal("activity_newyeargift_third_content"),20,kCCTextAlignmentLeft)

    -- desTv3:setPosition(ccp(20,100))
    desTv3:setPosition(ccp(20,height22))
    desTv3:setAnchorPoint(ccp(0,0))
    desTv3:setScaleY(opscaleY)
    desTv3:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv3:setMaxDisToBottomOrTop(100)
    thirdAcView:addChild(desTv3)

 	local function onTouchRechargeBtn()
    	self:onTouchRechargeBtn()
    end
    local btnItem3 = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnGraySmall_Down.png",onTouchRechargeBtn,nil,getlocal("recharge"),30)
    -- btnItem:setScale(0.6)
    btnItem3:setScaleY(opscaleY*0.9)
    btnItem3:setScaleX(0.9)
    self.chargeBtn = CCMenu:createWithItem(btnItem3)
    self.chargeBtn:setPosition(ccp(thirdAcView:getContentSize().width-90,155))
    self.chargeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    thirdAcView:addChild(self.chargeBtn,1)


    --第四个活动的页面
    local fourthAcView = CCSprite:create("public/acNewYearItem.jpg")
	fourthAcView:setAnchorPoint(ccp(0.5,1))
	fourthAcView:setPosition(ccp(G_VisibleSizeWidth/2,posY - itemHeight))
    self.bgLayer:addChild(fourthAcView,1)
    fourthAcView:setScaleY(scaleY)

    local titleBg4 = CCSprite:createWithSpriteFrameName("orangeMask.png")
    titleBg4:setAnchorPoint(ccp(0.5,1))
    titleBg4:setPosition(ccp(G_VisibleSizeWidth/2,thirdAcView:getPositionY() - 195*scaleY))
    self.bgLayer:addChild(titleBg4,6)

    local acTitle4 = GetTTFLabelWrap(getlocal("activity_newyeargift_fourth_title"),22,CCSizeMake(360,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acTitle4:setAnchorPoint(ccp(0.5,0.5))
    acTitle4:setPosition(ccp(titleBg4:getContentSize().width/2,titleBg4:getContentSize().height/2))
    acTitle4:setColor(G_ColorYellow)
    titleBg4:addChild(acTitle4)

    local desTv4, desLabel4 = G_LabelTableView(CCSizeMake(430, textScrollH),getlocal("activity_newyeargift_fourth_content",{acNewYearVoApi:getAddRate(),acNewYearVoApi:getAddCommandBook()}),20,kCCTextAlignmentLeft)
 	fourthAcView:addChild(desTv4)
    local height33 = 80
    if G_isIphone5() then
        height33 =120
    end
    desTv4:setPosition(ccp(20,height33))
    desTv4:setAnchorPoint(ccp(0,0))
    desTv4:setScaleY(opscaleY)
    desTv4:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv4:setMaxDisToBottomOrTop(100)

 	local function onTouchGoBtn()
    	self:onTouchGoBtn()
    end
    local btnItem4 = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnGraySmall_Down.png",onTouchGoBtn,nil,getlocal("activity_heartOfIron_goto"),30)
    -- btnItem:setScale(0.6)
    btnItem4:setScaleY(opscaleY*0.9)
    btnItem4:setScaleX(0.9)
    local btnMenu4 = CCMenu:createWithItem(btnItem4)
    btnMenu4:setPosition(ccp(fourthAcView:getContentSize().width-90,155))
    btnMenu4:setTouchPriority(-(self.layerNum-1)*20-4)
    fourthAcView:addChild(btnMenu4,1)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self:refreshAllGiftView()
end

function acNewYearDialog:onTouchRechargeBtn()
	vipVoApi:showRechargeDialog(self.layerNum+1)
    self:close()
end

function acNewYearDialog:onTouchGoBtn()
	local td = playerVoApi:showPlayerDialog(1,self.layerNum,true)
    td:tabClick(0)
    self:close()
end

function acNewYearDialog:onTouchReceiveBtn()
	local function rewardCallBack(fn,data)
        local ret,sData = base:checkServerData(data)
        print("ret ========================= ",ret)
        if ret == true then
	        if sData.data.newyeargift ~= nil then
          		print("更新元旦活动数据")
		        acNewYearVoApi:updateData(sData.data.newyeargift)
          		--更新玩家本地金币数
                local curGems = playerVoApi:getGems()
                print("领取前的金币数 ======= "..curGems)
                local giveGemsCount = acNewYearVoApi:getGiveGemsCount()
                print("giveGoldCount ========= "..giveGemsCount)
                curGems = curGems + giveGemsCount
                playerVoApi:setGems(curGems)
                print("领取后的金币数 ======= "..curGems)
                --显示领取金币成功的飘窗
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyeargift_getsuccess",{acNewYearVoApi:getGiveGemsCount()}),30)    
          		--刷新领取金币奖励活动的板子
          		self:refreshGiftView(self.activityType.SECOND_AC)
          	end
        end
	end
	socketHelper:newyeargiftRequest("reward",nil,rewardCallBack)
end

function acNewYearDialog:touchFreeGiftBox()
	local freeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.FREE_REWARD)
	if freeRewardFlag == acNewYearVoApi.flagConfig.REWARD_DISABLE then
        --弹出该礼包中的奖励列表
		print("免费礼包还不能领取")
		local content = {}
		local freeRewards = acNewYearVoApi:getFreeRewards()
		if freeRewards then
		    local rewardsDialog = acNewYearSmallDialog:new()
            local rewards = FormatItem(freeRewards,nil,true)
            local title = getlocal("activity_mingjiangzailin_canReward")
            local dialog = rewardsDialog:init("PanelPopup.png",CCSizeMake(550,650),nil,false,false,self.layerNum+1,rewards,title,nil,nil,true,false,nil)
            -- acNewYearSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,rewardList,title,desStr,nojilu)
                sceneGame:addChild(dialog,self.layerNum+1)
		end
	elseif freeRewardFlag == acNewYearVoApi.flagConfig.HAS_REWARD then
		print("您已经领取了该免费礼包")
	elseif freeRewardFlag == acNewYearVoApi.flagConfig.REWARD_ENABLE then
        print("您现在可以领取该免费礼包")
        local function getFreeRewards()
            local function rewardCallBack(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret == true then
                    if sData.data.newyeargift ~= nil then
                        print("更新元旦活动数据")
                        acNewYearVoApi:updateData(sData.data.newyeargift)
                        --获取免费免费礼包的奖品，并按照物品的index排序
                        local rewards = FormatItem(acNewYearVoApi:getFreeRewards(),nil,true)
                        for k,v in pairs(rewards) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
                        end
                        --显示获取到的奖励的飘窗
                        G_showRewardTip(rewards, true)
                        --刷新领取礼包奖励活动的板子
                        self:refreshGiftView(self.activityType.FIRST_AC)
                    end
                end
            end
            --发送领取付费礼包的协议
            socketHelper:newyeargiftRequest("gift",1,rewardCallBack)
        end

        --弹出该礼包中的奖励列表
        local content = {}
        local freeRewards = acNewYearVoApi:getFreeRewards()
        if freeRewards then
            local rewardsDialog = acNewYearSmallDialog:new()
            local rewards = FormatItem(freeRewards,nil,true)
            local title = getlocal("activity_mingjiangzailin_canReward")
            local dialog = rewardsDialog:init("PanelPopup.png",CCSizeMake(550,650),nil,false,false,self.layerNum+1,rewards,title,nil,nil,false,false,getFreeRewards)
            -- acNewYearSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,rewardList,title,desStr,nojilu)
                sceneGame:addChild(dialog,self.layerNum+1)
        end

	elseif freeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then
		--显示领取时间已过的飘窗
		print("该免费礼包的领取时间已过")
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyeargift_overtime"),30)	
	end
end

function acNewYearDialog:touchChargeGiftBox()
	local chargeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.CHARGE_REWARD)
	if chargeRewardFlag == acNewYearVoApi.flagConfig.REWARD_DISABLE then
		--弹出该礼包中的奖励列表
		print("付费礼包还不能领取")
        local content = {}
        local chargeRewards = acNewYearVoApi:getChargeRewards()
        if chargeRewards then
            local rewardsDialog = acNewYearSmallDialog:new()
            local rewards = FormatItem(chargeRewards,nil,true)
            local title = getlocal("activity_mingjiangzailin_canReward")
            local dialog = rewardsDialog:init("PanelPopup.png",CCSizeMake(550,650),nil,false,false,self.layerNum+1,rewards,title,nil,nil,true,false,nil)
            -- acNewYearSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,rewardList,title,desStr,nojilu,isGetRewards,isBuy,okCallBack)

                sceneGame:addChild(dialog,self.layerNum+1)
        end
	elseif chargeRewardFlag == acNewYearVoApi.flagConfig.HAS_REWARD then
		print("您已经领取了该付费礼包")
	elseif chargeRewardFlag == acNewYearVoApi.flagConfig.REWARD_ENABLE then
		print("您现在可以领取该付费礼包")
        local function getChargeRewards()
            local rewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.CHARGE_REWARD)
            if rewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then
                print("该付费礼包的领取时间已过")
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyeargift_overtime"),30)
                do return end
            end
            
            local function rewardCallBack(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret == true then
                    if sData.data.newyeargift ~= nil then
                        print("更新元旦活动数据")
                        acNewYearVoApi:updateData(sData.data.newyeargift)
                        --获取免费免费礼包的奖品，并按照物品的index排序
                        local rewards = FormatItem(acNewYearVoApi:getChargeRewards(),nil,true)
                        for k,v in pairs(rewards) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
                        end
                        --显示获取到的奖励的飘窗
                        G_showRewardTip(rewards, true)
                        --刷新领取礼包奖励活动的板子
                        self:refreshGiftView(self.activityType.FIRST_AC)

                        --更新玩家本地金币数
                        local curGems = playerVoApi:getGems()
                        print("领取前的金币数 ======= "..curGems)
                        local costGemsCount = acNewYearVoApi:getChargeRewardsCost()
                        print("costGemsCount ========= "..costGemsCount)
                        curGems = curGems - costGemsCount
                        playerVoApi:setGems(curGems)
                        print("领取后的金币数 ======= "..curGems)
                    end
                end
            end
            --判断金币是否足够
            local isEnough = acNewYearVoApi:isGemsEnough()
            if isEnough == true then
                --弹出二级确认弹窗
                local function onConfirm()
                    --发送领取礼包的协议
                    socketHelper:newyeargiftRequest("gift",2,rewardCallBack)     
                end
                self.confirmDialog = smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_newyeargift_confirmget",{acNewYearVoApi:getChargeRewardsCost()}),nil,self.layerNum+1)

            else
                --提示金币不足
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
            end
        end
        --弹出奖励列表
        local content = {}
        local chargeRewards = acNewYearVoApi:getChargeRewards()
        if chargeRewards then
            local rewardsDialog = acNewYearSmallDialog:new()
            local rewards = FormatItem(chargeRewards,nil,true)
            local title = getlocal("activity_mingjiangzailin_canReward")
            local dialog = rewardsDialog:init("PanelPopup.png",CCSizeMake(550,700),nil,false,false,self.layerNum+1,rewards,title,nil,nil,false,true,getChargeRewards)
                sceneGame:addChild(dialog,self.layerNum+1)
        end


	elseif chargeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then
		--显示领取时间已过的飘窗
		print("该付费礼包的领取时间已过")
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyeargift_overtime"),30)	
	end
end

function acNewYearDialog:resetTab()

end

function acNewYearDialog:refreshAllGiftView()
	self:refreshGiftView(self.activityType.FIRST_AC)
	self:refreshGiftView(self.activityType.SECOND_AC)
	self:refreshGiftView(self.activityType.THIRD_AC)
	self:refreshGiftView(self.activityType.FOURTH_AC)	
end

function acNewYearDialog:refreshGiftView(giftType)
	if giftType == self.activityType.FIRST_AC then
		local freeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.FREE_REWARD)
		local chargeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.CHARGE_REWARD)
        --记录一下当前的奖励领取状态
        self.lastFreeRewardFlag = freeRewardFlag
        self.lastChargeRewardFlag = chargeRewardFlag

        self.priceBg1:setPosition(ccp(self.freeGiftBox:getContentSize().width/2,5))
        self.priceBg2:setPosition(ccp(self.chargeGiftBox:getContentSize().width/2,5))
		if freeRewardFlag == acNewYearVoApi.flagConfig.REWARD_DISABLE then
			self.freeGiftBox:setEnabled(true)
			self.freeGiftLabel:setString(getlocal("daily_lotto_tip_2"))
			self.freeGiftLabel:setColor(G_ColorWhite)
            self.freeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.FREE_REWARD)
		elseif freeRewardFlag == acNewYearVoApi.flagConfig.HAS_REWARD then
			self.freeGiftBox:setEnabled(false)
			self.freeGiftLabel:setString(getlocal("activity_hadReward"))
			self.freeGiftLabel:setColor(G_ColorGreen)
    		self.priceBg1:setPosition(ccp(self.freeGiftBox:getContentSize().width/2,self.freeGiftBox:getContentSize().height/2))
            self.freeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.FREE_REWARD)
    	elseif freeRewardFlag == acNewYearVoApi.flagConfig.REWARD_ENABLE then
			self.freeGiftBox:setEnabled(true)
			self.freeGiftLabel:setString(getlocal("daily_lotto_tip_2"))
			self.freeGiftLabel:setColor(G_ColorWhite)
            self:playParticleAni(acNewYearVoApi.rewardType.FREE_REWARD)
            self.freeGiftLight:setVisible(true)
    	elseif freeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then
            self.freeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.FREE_REWARD)
		end

		if chargeRewardFlag == acNewYearVoApi.flagConfig.REWARD_DISABLE then
			self.chargeGiftBox:setEnabled(true)
			self.chargeGiftLabel:setString(acNewYearVoApi:getChargeRewardsCost())
    		self.chargeGiftLabel:setPosition(ccp(self.priceBg2:getContentSize().width/2 - 15,self.priceBg2:getContentSize().height/2))
			self.chargeGiftLabel:setColor(G_ColorWhite)
			self.chargeGoldIcon:setVisible(true)
            self.chargeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.CHARGE_REWARD)
		elseif chargeRewardFlag == acNewYearVoApi.flagConfig.HAS_REWARD then
			self.chargeGiftBox:setEnabled(false)
			self.chargeGiftLabel:setString(getlocal("activity_hadReward"))
			self.chargeGiftLabel:setColor(G_ColorGreen)
            self.chargeGiftLabel:setPosition(ccp(self.priceBg2:getContentSize().width/2,self.priceBg2:getContentSize().height/2))
    		self.priceBg2:setPosition(ccp(self.chargeGiftBox:getContentSize().width/2,self.chargeGiftBox:getContentSize().height/2))
			self.chargeGoldIcon:setVisible(false)
            self.chargeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.CHARGE_REWARD)
		elseif chargeRewardFlag == acNewYearVoApi.flagConfig.REWARD_ENABLE then
			self.chargeGiftBox:setEnabled(true)
			self.chargeGiftLabel:setString(acNewYearVoApi:getChargeRewardsCost())
    		self.chargeGiftLabel:setPosition(ccp(self.priceBg2:getContentSize().width/2 - 15,self.priceBg2:getContentSize().height/2))
			self.chargeGiftLabel:setColor(G_ColorWhite)
			self.chargeGoldIcon:setVisible(true)
            self.chargeGiftLight:setVisible(true)
            self:playParticleAni(acNewYearVoApi.rewardType.CHARGE_REWARD)
		elseif chargeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then
            self.chargeGiftLight:setVisible(false)
            self:removeParticleAni(acNewYearVoApi.rewardType.CHARGE_REWARD)
		end
	elseif giftType == self.activityType.SECOND_AC then
	    local chargeStr = acNewYearVoApi:getCurChargeGold().."/"..acNewYearVoApi:getCostGold()
		self.chargeGoldLabel:setString(chargeStr)
		local rewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.GOLD_REWARD)
		if rewardFlag == acNewYearVoApi.flagConfig.REWARD_DISABLE then
			self.getGoldBtn:setEnabled(false)
			self.chargeGoldLabel:setColor(G_ColorRed)
            self.getGoldLabel:setVisible(false)
		elseif rewardFlag == acNewYearVoApi.flagConfig.REWARD_ENABLE then
			self.getGoldBtn:setEnabled(true)
			self.chargeGoldLabel:setColor(G_ColorGreen)
            self.getGoldLabel:setVisible(false)
		elseif rewardFlag == acNewYearVoApi.flagConfig.HAS_REWARD then
			self.getGoldBtn:getParent():setVisible(false)
			self.chargeGoldLabel:setVisible(false)
			self.getGoldLabel:setVisible(true)
		end
	elseif giftType == self.activityType.THIRD_AC then
        local firstChargeFlag = acNewYearVoApi:hasFirstRecharge()
        if firstChargeFlag == true then
            self.chargeBtn:setVisible(false)
        else
            self.chargeBtn:setVisible(true)
        end
	elseif giftType == self.activityType.FOURTH_AC then

	end
end
    
function acNewYearDialog:tick()
    local vo=acNewYearVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
	if acNewYearVoApi.needRefresh == true then
		print("刷新充值的金币数")
		self:refreshGiftView(self.activityType.SECOND_AC)
        self:refreshGiftView(self.activityType.THIRD_AC)
		acNewYearVoApi:cancelRefresh()
	end
    if self.isOpen == true then
        local freeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.FREE_REWARD)
        local chargeRewardFlag = acNewYearVoApi:getRewardFlag(acNewYearVoApi.rewardType.CHARGE_REWARD)

        -- print("freeRewardFlag ======= ",freeRewardFlag)
        -- print("lastFreeRewardFlag ======== ",self.lastFreeRewardFlag)
        -- print("chargeRewardFlag ======== ",chargeRewardFlag)
        -- print("lastChargeRewardFlag ======= ",self.lastChargeRewardFlag)

        if self.lastFreeRewardFlag ~= freeRewardFlag or self.lastChargeRewardFlag ~= chargeRewardFlag then
            -- print("奖励领取状态发生了变化")
            self:refreshGiftView(self.activityType.FIRST_AC)
            if freeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD or chargeRewardFlag == acNewYearVoApi.flagConfig.OVER_REWARD then      
                    -- print("dsjakdjfkajsdfkjdfkj1111111")
                if self.confirmDialog ~= nil then
                    -- print("dsjakdjfkajsdfkjdfkj2222222")
                    self.confirmDialog:close()
                    self.confirmDialog = nil
                    -- print("dsjakdjfkajsdfkjdfkj3333333")
                end
            end
        end

    end
end

function acNewYearDialog:playParticleAni(rewardType)
    local aniNode = nil
    local parentNode = nil
    if rewardType == acNewYearVoApi.rewardType.FREE_REWARD then
        self.freeGiftAni = CCParticleSystemQuad:create("public/acNewYearAni/kjl.plist")
        aniNode = self.freeGiftAni
        parentNode = self.freeGiftBox
    elseif rewardType == acNewYearVoApi.rewardType.CHARGE_REWARD then
        self.chargeGiftAni = CCParticleSystemQuad:create("public/acNewYearAni/kjl.plist")
        aniNode = self.chargeGiftAni
        parentNode = self.chargeGiftBox
    end
    if aniNode ~= nil and parentNode ~= nil then
        aniNode.positionType=kCCPositionTypeFree
        aniNode:setPosition(parentNode:getContentSize().width/2,parentNode:getContentSize().height/2)
        parentNode:addChild(aniNode)
    end
end

function acNewYearDialog:removeParticleAni(rewardType)
    if rewardType == acNewYearVoApi.rewardType.FREE_REWARD then
        if self.freeGiftAni ~= nil then
            self.freeGiftAni:removeFromParentAndCleanup(true)
            self.freeGiftAni = nil
        end
    elseif rewardType == acNewYearVoApi.rewardType.CHARGE_REWARD then
        if self.chargeGiftAni ~= nil then
            self.chargeGiftAni:removeFromParentAndCleanup(true)
            self.chargeGiftAni = nil
        end
    end
end
--活动页面关闭时的资源释放处理
function acNewYearDialog:dispose()
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acNewYearHead.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acNewYearItem.jpg")    
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
	self.activityType = nil
    self.freeGiftBox = nil
    self.chargeGiftBox = nil
    self.getGoldBtn = nil
    self.getGoldLabel = nil
    self.chargeGoldLabel = nil
    self.freeGiftLabel = nil
    self.chargeGiftLable = nil
    self.chargeGoldIcon = nil
    self.freeGiftAni = nil
    self.chargeGiftAni = nil
    self.freeGiftLight = nil
    self.chargeGiftLight = nil
    self.priceBg1 = nil
    self.priceBg2 = nil
    self.chargeBtn = nil
    self.confirmDialog = nil
    self.isOpen = false
    self.lastFreeRewardFlag = nil
    self.lastChargeRewardFlag = nil
end

function acNewYearDialog:createGiftBtn(selectNName,selectSName,selectDName,handler,menuItemTag,menuLabelText,labelsize,lbTag)

     local selectN = CCSprite:createWithSpriteFrameName(selectNName);
    local selectS = CCSprite:createWithSpriteFrameName(selectSName);
    local selectD = CCSprite:createWithSpriteFrameName(selectDName);
           
    local menuItem3 = CCMenuItemSprite:create(selectN,selectS,selectD);
    if menuItemTag~=nil then
        menuItem3:setTag(menuItemTag)
    end
    
    
    if menuLabelText~=nil then
        
        local titleLb=GetTTFLabelWrap(menuLabelText,labelsize,CCSizeMake(menuItem3:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        if lbTag~=nil then
            titleLb:setTag(lbTag)
        end
        titleLb:setPosition(ccp(menuItem3:getContentSize().width/2,menuItem3:getContentSize().height/2))
        menuItem3:addChild(titleLb,6)

    end
    
    
    menuItem3:registerScriptTapHandler(handler)

    
    return menuItem3;
end