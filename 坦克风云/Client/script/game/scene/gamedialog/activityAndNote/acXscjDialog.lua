acXscjDialog = commonDialog:new()

function acXscjDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.cellHight=100
    spriteController:addPlist("public/acXscjImage.plist")
    spriteController:addTexture("public/acXscjImage.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")
    spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    return nc
end

function acXscjDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acXscjDialog:initTableView()
	self.taskTb=acXscjVoApi:getReward()
	self.taskNum=SizeOfTable(self.taskTb)

    self.visivleCell=math.floor((G_VisibleSizeHeight - self.bgSpH-115-50-130)/self.cellHight)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - self.bgSpH-115-50-130),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,130)
	self.bgLayer:addChild(self.tv,3)
	self.tv:setMaxDisToBottomOrTop(80)

    self.recordP=self.tv:getRecordPoint()
    self:recordTv()
end

function acXscjDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.taskNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 60,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local lv=self.taskTb[idx+1].lv or 1
		local state=acXscjVoApi:taskState(lv,idx+1)
		local bgPic
		if state==1 then
			bgPic="ac_xscj_di2.png"
		elseif state==100 then
            bgPic="lightGreyBrownBg.png"
        else
			bgPic="ac_xscj_di1.png"
		end

		local background=LuaCCScale9Sprite:createWithSpriteFrameName(bgPic,CCRect(14,14,2,2),function () end)
		background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,self.cellHight-5))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,5))
		cell:addChild(background)

		local bsSize=background:getContentSize()

		
		local lvStr=getlocal("fightLevel",{lv})
		local lvLb=GetTTFLabel(lvStr,25)
		background:addChild(lvLb)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(20,bsSize.height/2)

		-- leftBtnGreen.png
		local arrowSp=CCSprite:createWithSpriteFrameName("pointYellowLight.png")
		-- arrowSp:setRotation(180)
		arrowSp:setPosition(110,bsSize.height/2)
		background:addChild(arrowSp)

		local reward=self.taskTb[idx+1].award
		local rewardItem=FormatItem(reward,nil,true)
		local starW=200
		for k,v in pairs(rewardItem) do
			local icon=G_getItemIcon(v,80,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(ccp(starW+(k-1)*80,bsSize.height/2))
			background:addChild(icon)

            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-10,3)
            icon:addChild(numLabel,1)
            numLabel:setScale(1/icon:getScale())
		end

        local index=state
        if index==100 then -- 已完成(已领取)
            -- local p1Sp=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
            -- background:addChild(p1Sp)
            -- p1Sp:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            -- p1Sp:setScale(0.6)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(desLb)
            desLb:setColor(G_ColorGray)
        elseif index==10 then -- 未完成
        	local desLb=GetTTFLabelWrap(getlocal("noReached"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(desLb)

        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function refreshFunc(rewardlist)
                        -- local recordPoint=self.tv:getRecordPoint()
                        -- self.tv:reloadData()
                        -- self.tv:recoverToRecordPoint(recordPoint)
                        self:recordTv()

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        G_showRewardTip(rewardItem,true)
                    end
                    acXscjVoApi:socketReward(lv,refreshFunc)
                
                end
            end
            local rewardItem=GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",rewardTiantang,nil,nil,25)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(rewardBtn)

            G_addFlicker(rewardItem,2,2,ccp(rewardItem:getContentSize().width/2,rewardItem:getContentSize().height/2))
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

function acXscjDialog:recordTv()

    for k,v in pairs(self.taskTb) do
        local recordNum=k
        if self.taskNum-self.visivleCell<=k then
            recordNum=self.taskNum-self.visivleCell
            self.tv:recoverToRecordPoint(self.recordP)
            local recordPoint=self.tv:getRecordPoint()
            local truePoint=ccp(recordPoint.x,recordPoint.y+self.cellHight*(recordNum-1))
            self.tv:recoverToRecordPoint(truePoint)
            break
        end
        local state=acXscjVoApi:taskState(v.lv,k)
        if state==1 or state==10 then
            self.tv:recoverToRecordPoint(self.recordP)
            local recordPoint=self.tv:getRecordPoint()
            local truePoint=ccp(recordPoint.x,recordPoint.y+self.cellHight*(recordNum-1))
            self.tv:recoverToRecordPoint(truePoint)
            break
        end
    end

    local recordPoint=self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end



function acXscjDialog:doUserHandler()

    local function addPlist()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addPlist)

	local bgSp=CCSprite:createWithSpriteFrameName("ac_xscj_bg.jpg")
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 90))
	self.bgLayer:addChild(bgSp)

	local bgSpSize=bgSp:getContentSize()
	self.bgSpH=bgSpSize.height

	local sp=CCSprite:createWithSpriteFrameName("zhu_ji_di_building.png")
	sp:setScale(0.5)
	sp:setPosition(ccp(100, bgSpSize.height/2))
	bgSp:addChild(sp,7)

	local posH=bgSpSize.height-10
	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
	actTime:setAnchorPoint(ccp(0.5,1))
	actTime:setPosition(ccp(bgSpSize.width/2+80,bgSpSize.height-10))
	bgSp:addChild(actTime)
	actTime:setColor(G_ColorYellowPro)

	posH=posH-actTime:getContentSize().height
	local acVo=acXscjVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(bgSpSize.width/2+80, posH))
    bgSp:addChild(timeLabel,1)
    timeLabel:setColor(G_ColorYellowPro)
    self.timeLb=timeLabel
    G_updateActiveTime(acVo,self.timeLb)

    local tabStr={" ",getlocal("activity_xscj_tip3"),getlocal("activity_xscj_tip2"),getlocal("activity_xscj_tip1")," "}
	G_addMenuInfo(bgSp,self.layerNum,ccp(bgSpSize.width-40,bgSpSize.height-40),tabStr,nil,nil,28)

	local desLabel = GetTTFLabelWrap(getlocal("activity_xscj_des"),28,CCSizeMake(G_VisibleSizeWidth-250, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	desLabel:setAnchorPoint(ccp(0,0.5))
	desLabel:setPosition(ccp(220, bgSpSize.height/2-30))
	bgSp:addChild(desLabel,5)

    local desLabelBg=CCSprite:createWithSpriteFrameName("blackGradualChange.png")
    desLabelBg:setAnchorPoint(ccp(0,0.5))
    local nScaleX=(desLabel:getContentSize().width+6)/desLabelBg:getContentSize().width
    desLabelBg:setScaleX(nScaleX)
    desLabelBg:setScaleY((desLabel:getContentSize().height+6)/desLabelBg:getContentSize().height)
    desLabelBg:setPosition(205,bgSpSize.height/2-30)
    bgSp:addChild(desLabelBg)

    for i=1,2 do
        local posY = i ==1 and desLabel:getPositionY()+desLabel:getContentSize().height/2+3 or desLabel:getPositionY()-desLabel:getContentSize().height/2-3
        local yellowLine = CCSprite:createWithSpriteFrameName("yellowLightPoint.png")
        yellowLine:setAnchorPoint(ccp(0,0.5))
        yellowLine:setScaleX((desLabel:getContentSize().width+6)/yellowLine:getContentSize().width)
        yellowLine:setScaleY(1.2)
        yellowLine:setPosition(ccp(205,posY))
        bgSp:addChild(yellowLine)      

        local yellowStar = CCSprite:createWithSpriteFrameName("yellowLightPointBg.png")
        yellowStar:setAnchorPoint(ccp(0,0.5))
        yellowStar:setPosition(205,yellowLine:getPositionY())
        yellowStar:setScaleY(0.9)
        bgSp:addChild(yellowStar)
    end

	local function click(hd,fn,idx)
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-self.bgSpH-90-120))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(20,120))
    self.bgLayer:addChild(tvBg,2)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height))
    tvBg:addChild(goldLineSprite1)

    local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]
    local lvStr=getlocal("fightLevel",{buildVo.level or 0})
    local currentLb=GetTTFLabelWrap(getlocal("current_level",{lvStr}),28,CCSizeMake(G_VisibleSizeWidth-80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    currentLb:setAnchorPoint(ccp(0,0.5))
    tvBg:addChild(currentLb)
    currentLb:setPosition(20,tvBg:getContentSize().height-50)

    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 25
    end
    local function rewardTiantang()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        activityAndNoteDialog:closeAllDialog()
        mainUI:changeToMyPort()
        require "luascript/script/game/scene/gamedialog/portbuilding/commanderCenterDialog"

        local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]
        local nowLevel=buildVo.level or 1
        local td=commanderCenterDialog:new(1)
        local bName=getlocal(buildingCfg[7].buildName)
        local tbArr={getlocal("building"),getlocal("shuoming")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..nowLevel..")",true)
        sceneGame:addChild(dialog,3)
    end
    local rewardItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardTiantang,nil,getlocal("activity_xscj_upgrade"),strSize2)
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    rewardBtn:setPosition(ccp(G_VisibleSizeWidth/2,70))
    self.bgLayer:addChild(rewardBtn)

end

function acXscjDialog:tick()
	local acVo = acXscjVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
    end
    if self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acXscjDialog:dispose()
	self.taskTb=nil
	self.taskNum=nil
	self.bgSpH=nil
    self.timeLb=nil
	spriteController:removePlist("public/acXscjImage.plist")
    spriteController:removeTexture("public/acXscjImage.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acMonthlySign.plist")
    spriteController:removeTexture("public/acMonthlySign.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
end