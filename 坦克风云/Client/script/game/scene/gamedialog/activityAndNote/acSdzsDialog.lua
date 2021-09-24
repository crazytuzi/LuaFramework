acSdzsDialog = commonDialog:new()

function acSdzsDialog:new()
    local nc={
    	cellHight=110,
    	rewardCfg=nil,
    	refreshFlag=true,
        numLb=nil,
	}
    setmetatable(nc,self)
    self.__index=self
    spriteController:addPlist("public/acXscjImage.plist")
    spriteController:addTexture("public/acXscjImage.png")
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acSdzsImages.plist")
    spriteController:addTexture("public/acSdzsImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    return nc
end

function acSdzsDialog:resetTab()
	self.panelLineBg:setVisible(false)
end

function acSdzsDialog:initTableView()
	self.taskTb=acSdzsVoApi:getNeedTimes()
	self.taskNum=SizeOfTable(self.taskTb)
	self.rewardCfg=acSdzsVoApi:getRewardCfg()
	if G_isIphone5() then
		self.cellHight=130
	end
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-self.bgSpH-90-120),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,0)
	self.bgLayer:addChild(self.tv,3)
	self.tv:setMaxDisToBottomOrTop(0)
end

function acSdzsDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.taskNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth-60,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local attackNum=acSdzsVoApi:getAttackNum()
		local flag=acSdzsVoApi:checkIfReward(idx+1)
		local bgPic
		if flag==1 then
			bgPic="ac_xscj_di1.png"
		elseif flag==2 then
			bgPic="ac_xscj_di2.png"
		else
			bgPic="lightGreyBrownBg.png"
		end
		local spaceH=5
		if G_isIphone5() then
			spaceH=15
		end
		local background=LuaCCScale9Sprite:createWithSpriteFrameName(bgPic,CCRect(14,14,2,2),function () end)
		background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,self.cellHight-spaceH))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,5))
		cell:addChild(background)

		local bsSize=background:getContentSize()
		local num=self.taskTb[idx+1] or 1
    	local numStr=getlocal("purifying_num",{num})
		local numLb=GetTTFLabel(numStr,25)
		background:addChild(numLb)
		numLb:setAnchorPoint(ccp(0,0.5))
		numLb:setPosition(20,bsSize.height/2)

		local arrowSp=CCSprite:createWithSpriteFrameName("pointYellowLight.png")
		arrowSp:setPosition(110,bsSize.height/2)
		background:addChild(arrowSp)

		local rewardlist=self.rewardCfg[idx+1]
		local starW=200
		for k,v in pairs(rewardlist) do
			local icon=G_getItemIcon(v,90,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(ccp(starW+(k-1)*100,bsSize.height/2))
			background:addChild(icon)

            local numLb=GetTTFLabel("x"..FormatNumber(v.num),24)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/icon:getScale())
            numLb:setPosition(ccp(icon:getContentSize().width-5,5))
            icon:addChild(numLb,4)

            -- if acSdzsVoApi:isAddFlicker(v.key) then
            --     G_addRectFlicker2(icon,1.3,1.3,2,"p")
            -- end
		end

        if flag==3 then -- 已完成(已领取)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLb:setColor(G_ColorGray)
            desLb:setPosition(ccp(background:getContentSize().width-60,background:getContentSize().height/2))
            background:addChild(desLb)
        elseif flag==1 then -- 未完成
    	    local function goHandler()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    activityAndNoteDialog:closeAllDialog()
                    mainUI:changeToWorld()
                end
            end
            local goItem=GetButtonItem("taskGoto.png","taskGoto_down.png","taskGoto_down.png",goHandler,nil,nil,25)
            local goBtn=CCMenu:createWithItem(goItem);
            goBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            goBtn:setPosition(ccp(background:getContentSize().width-60,background:getContentSize().height/2))
            background:addChild(goBtn)
        else -- 可领取
            local function rewardHandler()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function rewardCallBack(fn,data)
		                local ret,sData=base:checkServerData(data)
		                if ret==true then
		                	acSdzsVoApi:updateData(sData.data.sdzs)
	                       	for k,v in pairs(rewardlist) do
	                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
	                        end
	            		
                         	local recordPoint=self.tv:getRecordPoint()
	                        self.tv:reloadData()
	                        self.tv:recoverToRecordPoint(recordPoint)

	                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
	                        G_showRewardTip(rewardlist,true)
	                        acSdzsVoApi:afterGetReward()
		                end
                    end
                    local tid=idx+1
                    socketHelper:sdzsGetTaskReward(tid,rewardCallBack)
                end
            end
            local rewardItem=GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",rewardHandler,nil,nil,25)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width-60,background:getContentSize().height/2))
            background:addChild(rewardBtn)
		    G_addFlicker(rewardItem,2,2)
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

function acSdzsDialog:doUserHandler()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function tmpFunc( ... )
    end
    local panelLineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),tmpFunc)
   	panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
   	panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-90))
   	self.bgLayer:addChild(panelLineBg)

	local bgSp=CCSprite:createWithSpriteFrameName("ac_sdzs_bg.jpg")
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 90))
	self.bgLayer:addChild(bgSp)

	local bgSpSize=bgSp:getContentSize()
	self.bgSpH=bgSpSize.height

	local posH=bgSpSize.height-10
	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
	actTime:setAnchorPoint(ccp(0.5,1))
	actTime:setPosition(ccp(bgSpSize.width/2,bgSpSize.height-10))
	bgSp:addChild(actTime)
	actTime:setColor(G_ColorYellowPro)

	posH=posH-actTime:getContentSize().height-10
	local acVo=acSdzsVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(bgSpSize.width/2, posH))
    bgSp:addChild(timeLabel,1)
    self.timeLb=timeLabel
    G_updateActiveTime(acVo,self.timeLb)

 --    local tabStr={" ",getlocal("activity_xscj_tip3"),getlocal("activity_xscj_tip2"),getlocal("activity_xscj_tip1")," "}
	-- G_addMenuInfo(bgSp,self.layerNum,ccp(bgSpSize.width-40,bgSpSize.height-40),tabStr,nil,nil,28)
    local desTv, desLabel = G_LabelTableView(CCSizeMake(bgSp:getContentSize().width-60, 120),getlocal("activity_sdzs_desc"),25,kCCTextAlignmentLeft)
    bgSp:addChild(desTv,5)
    desTv:setPosition(ccp(20,bgSpSize.height/2-120))
    desTv:setAnchorPoint(ccp(0,0))
    -- backSprie:setTouchPriority(-(self.layerNum-1) * 20 - 4)
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    desTv:setMaxDisToBottomOrTop(100)

	-- local desLabel = GetTTFLabelWrap(getlocal("activity_sdzs_desc"),25,CCSizeMake(bgSpSize.width-40, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- desLabel:setAnchorPoint(ccp(0,1))
	-- desLabel:setPosition(ccp(20,bgSpSize.height/2-30))
	-- bgSp:addChild(desLabel,5)

	local function click(hd,fn,idx)
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-self.bgSpH-160))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(20,30))
    self.bgLayer:addChild(tvBg,2)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height))
    tvBg:addChild(goldLineSprite1)

    local attackNum=acSdzsVoApi:getAttackNum()
    local numStr=getlocal("purifying_num",{attackNum})
    local promptLb=GetTTFLabel(getlocal("attack_player_num"),28)
    promptLb:setAnchorPoint(ccp(0,0.5))
    tvBg:addChild(promptLb)
    promptLb:setPosition(20,tvBg:getContentSize().height-50)

    local numLb=GetTTFLabel(numStr,28)
    numLb:setAnchorPoint(ccp(0,0.5))
    tvBg:addChild(numLb)
    numLb:setPosition(promptLb:getPositionX()+promptLb:getContentSize().width,promptLb:getPositionY())
    self.numLb=numLb

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setScaleX((G_VisibleSizeWidth-80)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(tvBg:getContentSize().width/2,70))
    tvBg:addChild(lineSp,5)

	local tipStr=getlocal("activity_sdzs_tip")
	local tipLb=GetTTFLabelWrap(tipStr,28,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	tipLb:setAnchorPoint(ccp(0.5,1))
	tipLb:setPosition(ccp(tvBg:getContentSize().width/2,50))
	tipLb:setColor(G_ColorYellowPro)
	tvBg:addChild(tipLb,5)
end

function acSdzsDialog:tick()
	local acVo=acSdzsVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
        do return end
    end
    local todayFlag=acSdzsVoApi:isToday()
    if todayFlag==false and self.refreshFlag==true then
    	acSdzsVoApi:clearTaskData()
        acSdzsVoApi:afterGetReward()
    	if self.tv then
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
    	end
        if self.numLb then
            local attackNum=acSdzsVoApi:getAttackNum()
            local numStr=getlocal("purifying_num",{attackNum})
            self.numLb:setString(numStr)
        end
    	self.refreshFlag=false
    end
    if todayFlag==true then
    	self.refreshFlag=true
    end
    if self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSdzsDialog:dispose()
	self.taskTb=nil
	self.taskNum=nil
	self.bgSpH=nil
	self.cellHight=110
	self.rewardCfg=nil
	self.refreshFlag=true
    self.numLb=nil
    self.timeLb=nil
	spriteController:removePlist("public/acXscjImage.plist")
    spriteController:removeTexture("public/acXscjImage.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("public/acSdzsImages.plist")
    spriteController:removeTexture("public/acSdzsImages.png")
   	spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
end