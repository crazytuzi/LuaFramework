acSmcjTask={}

function acSmcjTask:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.id       = 1
	nc.bgLayer  = nil
	nc.parent   = parent
	nc.tvH      = 190
	nc.taskData = {}
	-- nc.taskLbTb
	nc.goldAcBg = nil
	return nc
end
function acSmcjTask:dispose()
	base:removeFromNeedRefresh(self)
	self.aRpgTimer = nil
	self.bgLayer   = nil
	self.parent    = nil
	self.goldAcBg  = nil
	self.taskData  = nil
end
function acSmcjTask:init(layerNum,id,width,height)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.id=id
	self.taskData = acSmcjVoApi:getDailyTaskList(id)
	self.taskNum = SizeOfTable(self.taskData)
	self.version = 2
	self.titleStr2=getlocal("activity_chunjiepansheng_day" .. self.id .. "_ver" .. self.version)
	local num = acSmcjVoApi:getNumOfDay()
	if self.id+1>num then
		self.titleStr3=getlocal("activity_chunjiepansheng_day" .. 1 .. "_ver" .. self.version)
	else
		self.titleStr3=getlocal("activity_chunjiepansheng_day" .. self.id+1 .. "_ver" .. self.version)
	end
	if self.id-1==0 then
		self.titleStr1=getlocal("activity_chunjiepansheng_day" .. num .. "_ver" .. self.version)
	else
		self.titleStr1=getlocal("activity_chunjiepansheng_day" .. self.id-1 .. "_ver" .. self.version)
	end
	self.width,self.height = width,height
	self.cellHeight = 140
	self:initInfo(width,height)
	self:initTableView()
	return self.bgLayer
end

function acSmcjTask:initInfo(width,height)
	local strSize2 = 21
	local strSize3 = 25
	local strSize4 = 20
    if G_isAsia() then
        strSize2 =25
        strSize3 =30
        strSize4 =25
    end

	local widTh=G_VisibleSizeWidth * 0.5--width * 0.5 + 20
	local heiTh=height - 20
	local titleTb={
		{str=self.titleStr1,lbSize=strSize2,pos=ccp(widTh-200,heiTh)},
		{str=self.titleStr2,lbSize=strSize3,pos=ccp(widTh,heiTh + 12)},
		{str=self.titleStr3,lbSize=strSize2,pos=ccp(widTh+200,heiTh)}
				}

	for k,v in pairs(titleTb) do
		local titleLb=GetTTFLabel(v.str,v.lbSize)
		titleLb:setPosition(v.pos)
		titleLb:setColor(G_ColorYellowPro3)
		self.bgLayer:addChild(titleLb,1)
		if k~=2 then
			titleLb:setOpacity(180)
		else--if self.id == acSmcjVoApi:getNumOfDay() then
			local tipIcon = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
		    tipIcon:setAnchorPoint(ccp(1,1))
		    tipIcon:setPosition(widTh - 20,heiTh - 3)
		    self.bgLayer:addChild(tipIcon,991)
		    tipIcon:setScale(0.7)
		    local scoreNum = GetTTFLabel(acSmcjVoApi:getDayScore(self.id ).."/"..acSmcjVoApi:getCurDayLargeScore(self.id),24,true)
		    -- scoreNum:setColor(G_ColorYellowPro2)
		    scoreNum:setAnchorPoint(ccp(0,1))
		    scoreNum:setPosition(widTh - 20,heiTh - 2)
		    self.bgLayer:addChild(scoreNum,9991)
		end
	end
end

function acSmcjTask:initTableView( )
	local function callback( ... )
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    local tvHeight = self.height - 70 - self.cellHeight
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.width - 4,tvHeight),nil)
    self.tv:setPosition(ccp(14,17))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    ----------------------------------------------------------------------------------------------------------------
    local rechrLinePosy = tvHeight + 17
    local strSize2 = G_isAsia() and 22 or 17
    local addPosx = 12
    local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
	bottomLine:setContentSize(CCSizeMake(self.width - 10,bottomLine:getContentSize().height))
	bottomLine:setRotation(180)
	bottomLine:setPosition(ccp(self.width * 0.5 + addPosx, rechrLinePosy ))
	self.bgLayer:addChild(bottomLine,1)

	local showbg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    showbg:setContentSize(CCSizeMake(self.width - 10,self.cellHeight))
    showbg:setAnchorPoint(ccp(0.5,0))
    showbg:setPosition(ccp(self.width * 0.5 + addPosx, rechrLinePosy))
    self.bgLayer:addChild(showbg)

	local dailyRechargeAwardTb,limitNum,limintGold = acSmcjVoApi:getDailyRechargeNeedData(self.id)
	local canGetNum,lastRechrage = acSmcjVoApi:getDailyRechargeCanGetNum(self.id,limintGold)
	local getNum = acSmcjVoApi:getCurRechageRewardGetNum(self.id)
	-- local icon = CCSprite:createWithSpriteFrameName("acSmcjIcon_gb.png")
 --    icon:setAnchorPoint(ccp(0,0.5))

 --    icon:setPosition(10 + addPosx,rechrLinePosy + 70)
 --    self.bgLayer:addChild(icon)	
 	local titleVar2 = limitNum - getNum <= 0 and getlocal("getItOver") or getlocal("lastGetNum",{limitNum - getNum})
 	if G_getCurChoseLanguage() == "ja" then
	 	strSize2 = strSize2 - 3
	 end
	local titleLb = GetTTFLabelWrap(getlocal("activity_chunjiepansheng_gbs_title", {limintGold,titleVar2}),strSize2,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setColor(G_ColorYellowPro2)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(15 + addPosx,rechrLinePosy + 100)
	self.bgLayer:addChild(titleLb,2)

    -- local midPosx = titleLb:getContentSize().width + 15 + addPosx

    -- local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
    -- nameBg:setContentSize(CCSizeMake(440,34))
    -- nameBg:setAnchorPoint(ccp(0,1))
    -- nameBg:setPosition(midPosx,icon:getPositionY() + icon:getContentSize().height * 0.5)
    -- self.bgLayer:addChild(nameBg)
    local subHeight = G_isAsia() and 0 or 20
	
    local awardTb = FormatItem(dailyRechargeAwardTb.reward,nil,true) 
    local posxTb = {65,215,380,520}
    for k,v in pairs(awardTb) do
    	local function callback()
			G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil,nil,true)
		end
		-- print("k---v.name-->>",k,v.name,v.type,v.etype)
		local icon,scale=G_getItemIcon(v,70,false,self.layerNum,callback,nil)
		self.bgLayer:addChild(icon,3)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(90 + (k-1) * 85 - 20,rechrLinePosy + 45)

		local numLb = GetTTFLabel("x" .. FormatNumber(v.num),20)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb,4)
		numLb:setPosition(icon:getContentSize().width-5, 5)
		numLb:setScale(1/scale)

		local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,3)
    end


	local function goTiantang()
		if G_checkClickEnable()==false then
		    do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		G_goToDialog2("gb",4,true,useIdx)
	end
	local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("activity_continueRecharge_dayRecharge"),28)
	goItem:setScale(0.6)
	self.goItem = goItem
	local goBtn=CCMenu:createWithItem(goItem);
	goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	goItem:setAnchorPoint(ccp(1,0.5))
	goBtn:setPosition(self.width - 15 + addPosx,rechrLinePosy + self.cellHeight * 0.3)
	self.bgLayer:addChild(goBtn)

	local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(1,0.5))
	goldIcon:setPosition(self.width -7 + addPosx , rechrLinePosy + 100 - subHeight)--rechrLinePosy + self.cellHeight * 0.62)
	goldIcon:setScale(0.9)
	self.bgLayer:addChild(goldIcon)

	local curTaskKey = acSmcjVoApi:getTaskKey(self.id,1)
	local curFinshNum = acSmcjVoApi:getTaskData(self.id,curTaskKey)
	local rechargedStr = GetTTFLabel(getlocal("activity_baifudali_totalMoney")..curFinshNum,20,true)
	rechargedStr:setAnchorPoint(ccp(1,0.5))
	rechargedStr:setColor(G_ColorYellowPro2)
	rechargedStr:setPosition(goldIcon:getPositionX() - goldIcon:getContentSize().width + 5,goldIcon:getPositionY() )
	self.bgLayer:addChild(rechargedStr,2)
	self.rechargedStr = rechargedStr

    local endAt = GetTTFLabel(getlocal("serverwarteam_all_end"),G_isAsia() and 22 or 19,true)
	endAt:setPosition(self.width - 80 + addPosx, rechrLinePosy + 60 - subHeight)
	endAt:setColor(G_ColorRed)
	self.bgLayer:addChild(endAt,22)
	self.endAt = endAt
	endAt:setVisible(false)

	local notAt = GetTTFLabel(getlocal("not_open"),G_isAsia() and 22 or 19,true)
	notAt:setColor(G_ColorGreen)
	notAt:setPosition(self.width - 80 + addPosx, rechrLinePosy + 60 - subHeight)
	self.bgLayer:addChild(notAt,22)
	self.notAt = notAt
	notAt:setVisible(false)

	local overAt = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),G_isAsia() and 22 or 19,true)
	overAt:setColor(G_ColorYellowPro)
	overAt:setPosition(self.width - 80 + addPosx, rechrLinePosy + 60 - subHeight)
	self.bgLayer:addChild(overAt,22)
	self.overAt = overAt
	overAt:setVisible(false)


    if acSmcjVoApi:getNumDayOfActive() > self.id then -- 过期
    	goItem:setVisible(false)
    	endAt:setVisible(true)	
    elseif acSmcjVoApi:getNumDayOfActive() < self.id then -- 未到
    	goItem:setVisible(false)
    	notAt:setVisible(true)
    elseif limitNum - getNum <= 0 then
    	goItem:setVisible(false)
    	overAt:setVisible(true)
    end
    -- if not self.goldAcBg then
    	-- self:initGoldAcBg(giftSp,goldIsRec)
    -- end
end

function acSmcjTask:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		 return self.taskNum
  	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.width,self.cellHeight)
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local curTaskKey = acSmcjVoApi:getTaskKey(self.id,idx + 1)
		local curTaskUseIdx = SizeOfTable(self.taskData["t"..idx + 1])
		local needNum = self.taskData["t"..idx + 1][curTaskUseIdx].needNum
		-- print("curTaskKey====>>>>",curTaskKey)
		local curFinshNum = acSmcjVoApi:getTaskData(self.id,curTaskKey)
		local usePer = acSmcjVoApi:getPercentage(curFinshNum, self.taskData["t"..idx + 1],curTaskUseIdx)
		local curColor = curFinshNum >= needNum and G_ColorYellowPro3 or G_ColorYellowRed

		local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
        bottomLine:setContentSize(CCSizeMake(self.width - 10,bottomLine:getContentSize().height))
        bottomLine:setRotation(180)
        bottomLine:setPosition(ccp(self.width * 0.5, 0))
        cell:addChild(bottomLine,1)

        local iconName = acSmcjVoApi:getIconSp(self.id,idx + 1)
        local icon = CCSprite:createWithSpriteFrameName(iconName)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(10,self.cellHeight * 0.5)
        -- icon:setScale(0.9)
        cell:addChild(icon)

        local midPosx = icon:getContentSize().width + 15

        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
        nameBg:setContentSize(CCSizeMake(440,34))
        nameBg:setAnchorPoint(ccp(0,1))
        nameBg:setPosition(midPosx,icon:getPositionY() + icon:getContentSize().height * 0.5)
        cell:addChild(nameBg)

        local strSize2 = G_isAsia() and 22 or 17
        local lbKey = curTaskKey == "gb" and "gba" or curTaskKey
        local showNum = curFinshNum > needNum and needNum or curFinshNum
        local taskTitleStr = ""
        if lbKey=="hy" then
        	taskTitleStr=getlocal("activity_smcz_"..lbKey.."_title", {curFinshNum,needNum})
        else
        	taskTitleStr=getlocal("activity_chunjiepansheng_"..lbKey.."_title", {curFinshNum,needNum})
       	end
        local titleLb = GetTTFLabelWrap(taskTitleStr,strSize2,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        titleLb:setColor(G_ColorYellowPro2)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(10,nameBg:getContentSize().height *0.5)
		nameBg:addChild(titleLb,2)


		local function goTiantang()
			if G_checkClickEnable()==false then
			    do return end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			local typeName = curTaskKey
			typeName = typeName =="gba" and "gb" or typeName--heroM
			typeName = typeName =="bc" and "cn" or typeName
			typeName = (typeName =="ua" or typeName=="ta") and "armor" or typeName
			typeName = (typeName =="uh" or typeName=="th") and "heroM" or typeName
			typeName = typeName =="pr" and "tp" or typeName
			typeName = ( typeName == "ac" or typeName == "ai1" or typeName == "ai2" ) and "aiTroop" or typeName
			typeName = ( typeName == "st" or typeName == "sj" ) and "emblemTroop" or typeName
			-- print("goto=====>>>>typeName=====>>>>>",typeName)
			local useIdx = nil
			if curTaskKey == "st" then
				useIdx = 2
			elseif curTaskKey == "sj" then
				useIdx = 1
			end
			G_goToDialog2(typeName,4,true,useIdx)
		end
		local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),31)
		goItem:setScale(0.6)
		local goBtn=CCMenu:createWithItem(goItem);
		goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
		goItem:setAnchorPoint(ccp(1,0.5))
		goBtn:setPosition(self.width - 15,self.cellHeight * 0.42)
		cell:addChild(goBtn)

		local whiId =  acSmcjVoApi:getNumDayOfActive()
		if whiId > self.id then -- 过期
	    	goItem:setVisible(false)
	    	local endAt = GetTTFLabel(getlocal("serverwarteam_all_end"),G_isAsia() and 22 or 19,true)
	    	endAt:setPosition(self.width - 80,self.cellHeight * 0.44)
	    	endAt:setColor(G_ColorRed)
	    	cell:addChild(endAt,22)
	    elseif whiId < self.id then -- 未到
	    	goItem:setVisible(false)
	    	local notAt = GetTTFLabel(getlocal("not_open"),G_isAsia() and 22 or 19,true)
	    	notAt:setColor(G_ColorGreen)
	    	notAt:setPosition(self.width - 80,self.cellHeight * 0.44)
	    	cell:addChild(notAt,22)
	    elseif curFinshNum >= needNum then
	    	goItem:setVisible(false)
	    	local notAt = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),G_isAsia() and 22 or 19,true)
	    	notAt:setColor(G_ColorYellowPro)
	    	notAt:setPosition(self.width - 80,self.cellHeight * 0.44)
	    	cell:addChild(notAt,22)
	    end

		local percentStr=""
		local per=usePer -- tonumber(curFinshNum)/tonumber(needNum) * 100

	    local aRgsTimerWidth, aRgsTimerHeight = 300, 25
	    local aRgsTimerPosX, aRgsTimerPosY = 220, icon:getPositionY() - icon:getContentSize().height * 0.35
	    local aRpgTimer = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png"))
	    aRpgTimer:setMidpoint(ccp(0, 1))
	    aRpgTimer:setBarChangeRate(ccp(1, 0))
	    aRpgTimer:setType(kCCProgressTimerTypeBar)
	    aRpgTimer:setScaleX((aRgsTimerWidth + 6) / aRpgTimer:getContentSize().width)
	    aRpgTimer:setScaleY((aRgsTimerHeight + 6) / aRpgTimer:getContentSize().height)
	    local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
	    progressBarBg:setContentSize(CCSizeMake(aRgsTimerWidth + 6, aRgsTimerHeight))
	    progressBarBg:setAnchorPoint(ccp(0, 0.5))
	    progressBarBg:setPosition(midPosx, aRgsTimerPosY)
	    aRpgTimer:setPosition(getCenterPoint(progressBarBg))
	    progressBarBg:addChild(aRpgTimer)
	    cell:addChild(progressBarBg)
	    aRpgTimer:setPercentage(per)

	    local cellData = self.taskData["t"..idx + 1]
	    local cellDataNum = SizeOfTable(cellData)
	    local smallFontSize = 20
	    local giftSize = 60
	    local lineColor = ccc3(84, 84, 84)
	    local cellPosxTb = {{300}, {100,200,300}}

	    for k = 1, cellDataNum do
	        local giftPic = "packs4.png"
	        local giftSp
	        local posxTb = cellDataNum == 1 and cellPosxTb[1] or cellPosxTb[2]
            local function showReward()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local function refreshUICallback( ... )
					self:refreshUI()
				end
				local needUseNum = tonumber(cellData[k].needNum)
				local isHad = acSmcjVoApi:getCurTst(self.id,curTaskKey,k)
				acSmcjVoApi:dailyTaskRewardSmallDialog(k,self.layerNum + 1,refreshUICallback, cellData[k].reward,curFinshNum, needUseNum,isHad,curTaskKey,self.id,cellData[k].score)
            end
            giftSp = LuaCCSprite:createWithSpriteFrameName(giftPic, showReward)
            giftSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
	        giftSp:setScale(0.5)
	        giftSp:setPosition( posxTb[k] + midPosx, aRgsTimerPosY + giftSize * 0.5 + aRgsTimerHeight * 0.5 - 10)
	        cell:addChild(giftSp,22)
	        local needUseNum = tonumber(cellData[k].needNum)
	        local needUseNumStr = GetTTFLabel(needUseNum, smallFontSize)
	        needUseNumStr:setPosition(giftSp:getPositionX(), aRgsTimerPosY - needUseNumStr:getContentSize().height * 0.5 - aRgsTimerHeight * 0.5)
	        cell:addChild(needUseNumStr)
	        -- print("curFinshNum====needUseNum--->>>>",curFinshNum,needUseNum)
	        local canGet = curFinshNum >= needUseNum and true or false
	        if canGet then
	            needUseNumStr:setColor(G_ColorYellowPro)
	        else
	            needUseNumStr:setColor(G_ColorRed)
	        end

            local lineSp = CCSprite:createWithSpriteFrameName("reportWhiteLine.png")
            lineSp:setScaleX((aRgsTimerHeight - 3) / lineSp:getContentSize().width)
            lineSp:setPosition(posxTb[k], progressBarBg:getContentSize().height * 0.5)
            lineSp:setRotation(90)
            lineSp:setColor(lineColor)
            progressBarBg:addChild(lineSp, 3)

            if cellDataNum == k then
            	lineSp:setVisible(false)
            end

            -- local isHad = acSmcjVoApi:getCurTst(self.id,curTaskKey,k)
            -- self:initTvBoxBgAc(canGet,isHad,giftSp,cell)
	    end

		return cell
	end
end

function acSmcjTask:refreshUI( )
	print " in refreshUI~~~~~~~~~~~~~"
	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acSmcjTask:refreshGoldRecharged()
	local dailyRechargeAwardTb,limitNum,limintGold = acSmcjVoApi:getDailyRechargeNeedData(self.id)
	local canGetNum,lastRechrage = acSmcjVoApi:getDailyRechargeCanGetNum(self.id,limintGold)
	local getNum = acSmcjVoApi:getCurRechageRewardGetNum(self.id)

	self.endAt:setVisible(false)
	self.notAt:setVisible(false)
	self.overAt:setVisible(false)
	if acSmcjVoApi:getNumDayOfActive() > self.id then -- 过期
    	self.goItem:setVisible(false)
    	self.endAt:setVisible(true)	
    elseif acSmcjVoApi:getNumDayOfActive() < self.id then -- 未到
    	self.goItem:setVisible(false)
    	self.notAt:setVisible(true)
    elseif limitNum - getNum <= 0 then
    	self.goItem:setVisible(false)
    	self.overAt:setVisible(true)
    else
    	self.goItem:setVisible(true)
    	self.endAt:setVisible(false)
    	self.notAt:setVisible(false)
    	self.overAt:setVisible(false)
    end
end
function acSmcjTask:initGoldAcBg(friend,goldIsRec)
	-- print(" goldIsRec ==>>",goldIsRec)
	if goldIsRec then
			if not self.goldAcBg then
				local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
			    lightSp:setAnchorPoint(ccp(0.5,0.5))
			    lightSp:setPosition(friend:getPosition())
			    self.bgLayer:addChild(lightSp,4)
			    lightSp:setScale(0.4)
			    self.goldAcBg = lightSp
			else
				self.goldAcBg:setVisible(true)
			end
            local time = 0.1--0.07
	        local rotate1=CCRotateTo:create(time, 30)
	        local rotate2=CCRotateTo:create(time, -30)
	        local rotate3=CCRotateTo:create(time, 20)
	        local rotate4=CCRotateTo:create(time, -20)
	        local rotate5=CCRotateTo:create(time, 0)
	        local delay=CCDelayTime:create(1)
	        local acArr=CCArray:create()
	        acArr:addObject(rotate1)
	        acArr:addObject(rotate2)
	        acArr:addObject(rotate3)
	        acArr:addObject(rotate4)
	        acArr:addObject(rotate5)
	        acArr:addObject(delay)
	        local seq=CCSequence:create(acArr)
	        local repeatForever=CCRepeatForever:create(seq)
	        friend:runAction(repeatForever)
	else
		if self.goldAcBg then
			self.goldAcBg:setVisible(false)
			friend:stopAllActions()
			friend:setRotation(0)
		end
	end
end
function acSmcjTask:initTvBoxBgAc(canGet,isHad,giftSp,cell)
	if canGet and isHad == false then
		local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
	    lightSp:setAnchorPoint(ccp(0.5,0.5))
	    lightSp:setPosition(giftSp:getPosition())
	    cell:addChild(lightSp,4)
	    lightSp:setScale(0.4)

	    local time = 0.1--0.07
        local rotate1=CCRotateTo:create(time, 30)
        local rotate2=CCRotateTo:create(time, -30)
        local rotate3=CCRotateTo:create(time, 20)
        local rotate4=CCRotateTo:create(time, -20)
        local rotate5=CCRotateTo:create(time, 0)
        local delay=CCDelayTime:create(1)
        local acArr=CCArray:create()
        acArr:addObject(rotate1)
        acArr:addObject(rotate2)
        acArr:addObject(rotate3)
        acArr:addObject(rotate4)
        acArr:addObject(rotate5)
        acArr:addObject(delay)
        local seq=CCSequence:create(acArr)
        local repeatForever=CCRepeatForever:create(seq)
        giftSp:runAction(repeatForever)
	end
end