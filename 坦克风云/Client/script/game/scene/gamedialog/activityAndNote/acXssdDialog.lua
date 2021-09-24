acXssdDialog = commonDialog:new()

function acXssdDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.isToday=true
    nc.cellHight=170
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acDouble11New_addImage.plist")
    spriteController:addTexture("public/acDouble11New_addImage.png")
    return nc
end

function acXssdDialog:resetTab()
    local acVo = acXssdVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acXssdVoApi:refreshClear()
        end
    end
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acXssdDialog:initTableView( )
    self.shop=acXssdVoApi:getShop()
    self.shopNum=SizeOfTable(self.shop)
    self.trueShop=acXssdVoApi:getSortShop()
    local function click(hd,fn,idx)
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-210-100-90))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(20,90))
    self.bgLayer:addChild(tvBg,2)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height))
    tvBg:addChild(goldLineSprite1)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 230-100-100),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,100)
	self.bgLayer:addChild(self.tv,3)
	self.tv:setMaxDisToBottomOrTop(80)

    local careLb=GetTTFLabelWrap(getlocal("activity_xssd_care"),25,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(careLb)
    careLb:setPosition(G_VisibleSizeWidth/2,60)
    careLb:setColor(G_ColorYellowPro)
end

-- 仿照全线突围活动 acQxtwVoApi:getCurrentTaskState()
function acXssdDialog:eventHandler(handler,fn,idx,cel)
    local strSize2 = 23
    local strSize3 = 20
    if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="de" then
        strSize2 = 18
        strSize3 = 20
    elseif G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 25
        strSize3 = 22
    end
	if fn=="numberOfCellsInTableView" then
		return self.shopNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 60,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,self.cellHight-10))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,5))
		cell:addChild(background)

        local bsSize=background:getContentSize()

        local id=self.trueShop[idx+1].id
        local acVo=acXssdVoApi:getAcVo()
        local reward=self.shop[id][5]
        local rewardItem=FormatItem(reward,nil,true)
        local nowCost=self.shop[id][4]
        local disCost=self.shop[id][3]
        local disNum=self.shop[id][2]
        local blog=acVo.b or {}
        local buyNum=blog[id] or 0
        local limit=self.shop[id][1]

        local priority=-(self.layerNum-1)*20-2
        if buyNum>=limit then
            local function showLimitTip()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1987"),30)
                end

            end
            local blackSp =LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),showLimitTip)
            blackSp:setContentSize(bsSize)
            blackSp:setTouchPriority(-(self.layerNum-1)*20-2)
            blackSp:setPosition(bsSize.width/2,bsSize.height/2)
            background:addChild(blackSp,10)
            priority=-(self.layerNum-1)*20-1
        end

        local starW=65
        local icon=G_getItemIcon(rewardItem[1],100,true,self.layerNum)
        icon:setTouchPriority(priority)
        icon:setPosition(ccp(starW,bsSize.height/2))
        background:addChild(icon)

        local numLabel=GetTTFLabel("x"..FormatNumber(rewardItem[1].num),25)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-10,3)
        icon:addChild(numLabel,1)
        numLabel:setScale(1/icon:getScale())

        if disNum~=0 then
            local clipper=CCClippingNode:create()
            clipper:setAnchorPoint(ccp(0.5,0.5))
            clipper:setContentSize(CCSizeMake(100,100))
            clipper:setPosition(starW,bsSize.height/2)
            background:addChild(clipper,1)

            local stencil=CCDrawNode:getAPolygon(CCSizeMake(100,100),1,1)
            clipper:setStencil(stencil)

            local redTiltBg = CCSprite:createWithSpriteFrameName("redTiltBg.png")
            -- icon:addChild(redTiltBg)
            redTiltBg:setPosition(25,75)
            redTiltBg:setRotation(-15)
            redTiltBg:setScale(0.8)
            clipper:addChild(redTiltBg)

            local disLb=GetTTFLabel(disNum*10 .. "%",22)
            redTiltBg:addChild(disLb)
            disLb:setScale(1/0.8)
            disLb:setPosition(redTiltBg:getContentSize().width/2,redTiltBg:getContentSize().height/2)
            disLb:setRotation(-30)

        end

        local lbW=130
        local nameLb=GetTTFLabel(rewardItem[1].name .. "(" .. buyNum .. "/" .. limit .. ")",strSize2)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(lbW,bsSize.height/2+40))
        background:addChild(nameLb)
        nameLb:setColor(G_ColorGreen)

        local desLb=GetTTFLabelWrap(getlocal(rewardItem[1].desc),strSize3,CCSizeMake(bsSize.width-130-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        desLb:setPosition(ccp(lbW,bsSize.height/2-30))
        background:addChild(desLb)

        local function rewardTiantang()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local gems=playerVoApi:getGems()
                if nowCost>gems then
                    local function onSure()
                        -- activityAndNoteDialog:closeAllDialog()
                    end
                    GemsNotEnoughDialog(nil,nil,nowCost-gems,self.layerNum+1,nowCost,onSure)
                    return
                end

                local function refreshFunc(rewardlist)
                    playerVoApi:setGems(playerVoApi:getGems()-nowCost)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)

                    for k,v in pairs(rewardItem) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end

                    G_showRewardTip(rewardItem,true)

                    self.trueShop=acXssdVoApi:getSortShop()
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)

                end
                acXssdVoApi:socketReward(id,refreshFunc)
            
            end
        end
        -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
        local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardTiantang,nil,getlocal("activity_loversDay_tab2"),25)
        -- rewardItem:setScale(0.8)
        local rewardBtn=CCMenu:createWithItem(rewardItem);
        rewardBtn:setTouchPriority(priority);
        rewardBtn:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2-30))
        background:addChild(rewardBtn)

        local costLb=GetTTFLabel(nowCost .. "  ",25)
        rewardItem:addChild(costLb)
        costLb:setPositionY(90)
        costLb:setColor(G_ColorYellowPro)

        local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
        rewardItem:addChild(goldIcon)
        goldIcon:setPositionY(90)

        G_setchildPosX(rewardItem,costLb,goldIcon)
        goldIcon:setPositionX(goldIcon:getPositionX()+5)
        costLb:setPositionX(costLb:getPositionX()+5)

        local disCostLb=GetTTFLabel(disCost,22)
        rewardItem:addChild(disCostLb)
        disCostLb:setColor(G_ColorRed)
        disCostLb:setPositionY(120)
        disCostLb:setPositionX(costLb:getPositionX())

        local line = CCSprite:createWithSpriteFrameName("redline.jpg")
        line:setScaleX((disCostLb:getContentSize().width  + 40) / line:getContentSize().width)
        line:setPosition(ccp(disCostLb:getContentSize().width/2,disCostLb:getContentSize().height/2))
        disCostLb:addChild(line)


		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function acXssdDialog:doUserHandler()

    local bgSp
    local function addPlist()
        bgSp = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
        bgSp:setAnchorPoint(ccp(0.5,0))
        -- bgSp:setScale(0.99)
    end
    G_addResource8888(addPlist)

    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setContentSize(CCSizeMake(bgSp:getContentSize().width,230))
    clipper:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95)
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(bgSp:getContentSize().width,230),1,1)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper,1)

    clipper:addChild(bgSp)
    bgSp:setPosition(clipper:getContentSize().width/2,-40)
    

	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function (...)end)
    headerSprie:setContentSize(CCSizeMake(bgSp:getContentSize().width,230))
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    headerSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
    self.bgLayer:addChild(headerSprie,1)
    headerSprie:setTouchPriority(160)

    local hs=headerSprie:getContentSize().height
    local ws=headerSprie:getContentSize().width
    hs=hs-10

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
	actTime:setAnchorPoint(ccp(0.5,1))
	actTime:setPosition(ccp(ws/2+10,hs))
	headerSprie:addChild(actTime)
	actTime:setColor(G_ColorGreen)

	hs=hs-actTime:getContentSize().height-5

	local tabStr={" ",getlocal("activity_xssd_tip2"),getlocal("activity_xssd_tip1")," "}
	G_addMenuInfo(headerSprie,self.layerNum,ccp(ws-60,hs-20),tabStr,nil,nil,28)

    local acVo=acXssdVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(ws/2+10, hs))
    headerSprie:addChild(timeLabel,1)
    self.timeLb=timeLabel
    G_updateActiveTime(acVo,self.timeLb)

    hs=hs-timeLabel:getContentSize().height-5

    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
    girlImg:setAnchorPoint(ccp(0,0))
    girlImg:setPosition(ccp(0,10))
    headerSprie:addChild(girlImg,2)
    local scale=200/girlImg:getContentSize().height
    girlImg:setScale(scale)

    local strSize4 = 20
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize4 = 25
    end
    local acDesLb=GetTTFLabelWrap(getlocal("activity_xssd_des"),strSize4,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    acDesLb:setAnchorPoint(ccp(0,0.5))
    headerSprie:addChild(acDesLb)
    acDesLb:setPosition(220,girlImg:getContentSize().height*scale/2-20)

end

function acXssdDialog:refreshTv()
    self.trueShop=acXssdVoApi:getSortShop()
    local recordPoint=self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

function acXssdDialog:tick()
    local acVo = acXssdVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acXssdVoApi:refreshClear()
            self:refreshTv()
        end
    else
        self:close()
        do return end
    end
    if self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acXssdDialog:dispose()
    self.timeLb=nil
	-- spriteController:removePlist("public/emblemSkillBg.plist")
 --    spriteController:removeTexture("public/emblemSkillBg.png")
    spriteController:removeTexture("public/serverWarLocal/sceneBg.jpg")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acDouble11New_addImage.plist")
    spriteController:removeTexture("public/acDouble11New_addImage.png")
end