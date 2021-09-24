--加速道具使用数量选择小面板
speedUpPropSelectDialog=smallDialog:new()

function speedUpPropSelectDialog:new(pid,spType,spType2,callFun,closeFun)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=600
	nc.dialogHeight=550
	nc.speedType = spType--加速类型(建筑加速/科技加速/生产加速)
	nc.speedType1= spType2--若加速类型是建筑加速，这里是建筑id；若加速类型是科技加速，这里是科技id；若加速类型是生产加速，这里是舰船类型。
	nc.upgradeCallBack = callFun
	nc.closeCallBack = closeFun
	nc.canSpeedTime = nil--vip免费加速的时间
	nc.propId = pid--批量使用的道具的Id
	nc.needNum = nil--当前加速所需道具数量
	nc.selectNum = nil--当前选择使用道具数量
	nc.freeTsTip = nil
	nc.slider = nil
    nc.useItem = nil
    nc.addSp = nil
    nc.minusSp = nil
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	return nc
end

function speedUpPropSelectDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    -- self.bgLayer:setOpacity(120)
	self.dialogHeight =self:showContent()
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

	
	-- local titleLb=GetTTFLabel(getlocal("prop_use_type1"),30)
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 10 - titleLb:getContentSize().height/2))
	-- dialogBg:addChild(titleLb,1)

    local function touchLuaSpr()
         
    end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))

    self:tick()

	return self.dialogLayer
end


function speedUpPropSelectDialog:showContent()
    local fontSize = 25
    local sliderY = 210 + 40

	local leftTime
    if self.speedType == 1 then
    	leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
    elseif self.speedType == 2 then
    	leftTime = technologyVoApi:leftTime(self.speedType1)
    elseif self.speedType == 3 then
    	leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    elseif self.speedType == 4 then
    	leftTime = tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    end

    local hadNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(self.propId)))
    local pCfg = propCfg[self.propId]
    local spTime = pCfg.useTimeDecrease--当前道具可加速时间
    if base.fs  == 1 and (self.speedType == 1 or self.speedType == 2) then
        self.canSpeedTime=playerVoApi:getFreeTime()
        if leftTime > self.canSpeedTime then
            leftTime = leftTime - self.canSpeedTime
        else
            leftTime = 0
        end
    end

    self.needNum=math.ceil(leftTime/spTime)
    self.selectNum = math.floor(leftTime/spTime)

    if self.needNum > hadNum then
      self.needNum = hadNum
    end

    if self.needNum < 1 then
        self.needNum = 1
    end
    
    if self.selectNum > hadNum then
      self.selectNum = hadNum
    end

    if self.selectNum < 1 then
    	self.selectNum = 1
    end

    local totalLb = GetTTFLabelWrap("",fontSize,CCSizeMake(self.dialogWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(totalLb)

    local  m_numLb=GetTTFLabel("",fontSize)
    self.bgLayer:addChild(m_numLb)

    --玩家自行设定次数 start
    local function sliderTouch(handler,object)
        if newGuidMgr:isNewGuiding() == true then
            do
                return
            end
        end
        -- print("object:getValue()",object:getValue())
        local count = math.floor(object:getValue())
        m_numLb:setString(getlocal("propInfoNum",{getlocal("scheduleChapter",{count,self.needNum})}))

        local leftTime
        if self.speedType == 1 then
            leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
        elseif self.speedType == 2 then
            leftTime = technologyVoApi:leftTime(self.speedType1)
        elseif self.speedType == 3 then
            leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        elseif self.speedType == 4 then
            leftTime = tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        end
        if base.fs == 1 and self.canSpeedTime then
            if leftTime > self.canSpeedTime then
                leftTime = leftTime - self.canSpeedTime
            else
                leftTime = 0
            end
        end
        if (count * spTime)>=leftTime then
            local totalStr=getlocal("speedUpProp_exceed",{GetTimeStr(count * spTime)})
            local isOverFlow,isStopAutoUpgrade=self:isTimeOverFlow(self.propId)
            print("isOverFlow,isStopAutoUpgrade",isOverFlow,isStopAutoUpgrade)
            if isOverFlow==true and isStopAutoUpgrade==true then
                totalStr=totalStr..getlocal("building_auto_upgrade_quick")
            end
            totalLb:setString(totalStr)
            totalLb:setColor(G_ColorRed)
            if self.freeTsTip then
                self.freeTsTip:setString(getlocal("speedUpProp_freeAccelerate"))
                self.freeTsTip:setColor(G_ColorYellowPro)
            end
        else
            totalLb:setString(getlocal("speedUpProp_total",{GetTimeStr(count * spTime)}))
            totalLb:setColor(G_ColorWhite)
            if self.freeTsTip then
                self.freeTsTip:setString(getlocal("speedUpProp_freeTip",{GetTimeStr(leftTime-(count * spTime))}))
                self.freeTsTip:setColor(G_ColorWhite)
            end
        end
    end

    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png")
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png")
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png")
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
    self.slider:setTouchPriority(-(self.layerNum-1)*20-2)
    self.slider:setIsSallow(true)
    
    self.slider:setMinimumValue(1)
    
    self.slider:setMaximumValue(self.needNum)
    
    self.slider:setValue(self.selectNum)
    self.slider:setPosition(ccp(300,sliderY))
    self.bgLayer:addChild(self.slider,6)

    local function touchAdd()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self.slider:setValue(self.slider:getValue()+1)
    end
    
    local function touchMinus()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if self.slider:getValue()>1 then
            self.slider:setValue(self.slider:getValue()-1)
        end
    end

    local function touchHander()
    end
    local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
    bgSp:setContentSize(CCSizeMake(450,45))
    bgSp:setPosition(self.dialogWidth/2,sliderY)
    self.bgLayer:addChild(bgSp,1)
    
    self.addSp=CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
    self.addSp:setPosition(ccp(490,sliderY))
    self.bgLayer:addChild(self.addSp,6)
    -- self.addSp:setTouchPriority(-(self.layerNum-1)*20-3)

    local rect=CCSizeMake(50,45)
    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchAdd)
    addTouchBg:setTouchPriority(-(self.layerNum-1)*20-3)
    addTouchBg:setContentSize(rect)
    addTouchBg:setOpacity(0)
    addTouchBg:setPosition(ccp(490,sliderY))
    self.bgLayer:addChild(addTouchBg,2)
    
    self.minusSp=CCSprite:createWithSpriteFrameName("ProduceTankIconLess.png")
    self.minusSp:setPosition(ccp(110,sliderY))
    self.bgLayer:addChild(self.minusSp,6)
    -- self.minusSp:setTouchPriority(-(self.layerNum-1)*20-3)

    local minusTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchMinus)
    minusTouchBg:setTouchPriority(-(self.layerNum-1)*20-3)
    minusTouchBg:setContentSize(rect)
    minusTouchBg:setOpacity(0)
    minusTouchBg:setPosition(ccp(110,sliderY))
    self.bgLayer:addChild(minusTouchBg,2)
    
    --玩家自行设定次数 end

    local function useHandler()
        PlayEffect(audioCfg.mouseClick)
        local selectTimes = math.floor(self.slider:getValue())
        if self.upgradeCallBack then
            self.upgradeCallBack(selectTimes)
        end
        self:close()
    end

    self.useItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",useHandler,nil,getlocal("use"),fontSize,10)
    local useMenu=CCMenu:createWithItem(self.useItem)
    useMenu:setPosition(ccp(self.dialogWidth*0.5,70))
    useMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(useMenu)

    totalLb:setPosition(self.dialogWidth/2, 140 + 30)
   

    sliderY = sliderY + 60

    m_numLb:setPosition(self.dialogWidth/2,sliderY)

    sliderY = sliderY + 40
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale((self.dialogWidth-80)/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,sliderY))
	self.bgLayer:addChild(lineSp)

    sliderY = sliderY + 80
    local lbName=GetTTFLabelWrap(getlocal(pCfg.name),26,CCSizeMake(self.dialogWidth - 180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbName:setAnchorPoint(ccp(0,1))
    lbName:setPosition(160,sliderY + 50)
    self.bgLayer:addChild(lbName)
    local labelColor=G_getLbColorByPid(self.propId)
    lbName:setColor(labelColor)

    local rewardTb={p={}}
    rewardTb.p[self.propId]=1
    local reward=FormatItem(rewardTb) or {}
    local sprite
    if reward[1] then
        sprite=G_getItemIcon(reward[1],100)
    else
        sprite = CCSprite:createWithSpriteFrameName(pCfg.icon)
    end
    sprite:setAnchorPoint(ccp(0.5,0.5))
    sprite:setPosition(100,sliderY)
    self.bgLayer:addChild(sprite,2)
    
    local lbDescription=GetTTFLabelWrap(getlocal(pCfg.description),22,CCSize(self.dialogWidth - 180, 100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbDescription:setAnchorPoint(ccp(0,1))
    lbDescription:setPosition(160,sliderY+30-lbName:getContentSize().height)
    self.bgLayer:addChild(lbDescription,2)

    if base.fs == 1 and self.canSpeedTime then
    	sliderY = sliderY + 80
    	local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp2:setScale((self.dialogWidth-80)/lineSp2:getContentSize().width)
		lineSp2:setPosition(ccp(self.dialogWidth/2,sliderY))
		self.bgLayer:addChild(lineSp2)

    	sliderY = sliderY + 50

	    local waitFreeTime = 0
	    if leftTime > self.canSpeedTime then
	       waitFreeTime = leftTime - self.canSpeedTime
	    end

	    local count = math.floor(self.slider:getValue())
        local showTime=waitFreeTime-(count*spTime)
        local lbColor,freeTsStr=G_ColorWhite,""
        if showTime>0 then
            freeTsStr=getlocal("speedUpProp_freeTip",{GetTimeStr(showTime)})
        else
            freeTsStr=getlocal("speedUpProp_freeAccelerate")
            lbColor=G_ColorYellowPro
        end
	    self.freeTsTip = GetTTFLabelWrap(freeTsStr,24,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    self.freeTsTip:setAnchorPoint(ccp(0.5,0.5))
	    self.freeTsTip:setPosition(ccp(self.dialogWidth/2,sliderY))
	    self.bgLayer:addChild(self.freeTsTip)
        self.freeTsTip:setColor(lbColor)

	    sliderY =  sliderY + 60
	else
		sliderY = sliderY + 100
	end
    return sliderY + 10
end

function speedUpPropSelectDialog:tick()
	local leftTime
    if self.speedType == 1 then
    	leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
    elseif self.speedType == 2 then
    	leftTime = technologyVoApi:leftTime(self.speedType1)
    elseif self.speedType == 3 then
    	leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    elseif self.speedType == 4 then
    	leftTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    end
    if leftTime and leftTime > 0 then
        local pCfg = propCfg[self.propId]
        local spTime = pCfg.useTimeDecrease--当前道具可加速时间
        if self.freeTsTip then
            if base.fs == 1 and self.canSpeedTime then
                if leftTime > self.canSpeedTime then
                    leftTime = leftTime - self.canSpeedTime
                else
                    leftTime = 0
                end
            end
            if leftTime > 0 then
                -- self.freeTsTip:setString(getlocal("speedUpProp_freeTip",{GetTimeStr(leftTime)}))
                local count = math.floor(self.slider:getValue())
                if (leftTime>count*spTime) then
                    self.freeTsTip:setString(getlocal("speedUpProp_freeTip",{GetTimeStr(leftTime-(count*spTime))}))
                    self.freeTsTip:setColor(G_ColorWhite)
                else
                    self.freeTsTip:setString(getlocal("speedUpProp_freeAccelerate"))
                    self.freeTsTip:setColor(G_ColorYellowPro)
                end
            else
                self.freeTsTip:setString(getlocal("speedUpProp_freeAccelerate"))
                self.freeTsTip:setColor(G_ColorYellowPro)
                local lb=tolua.cast(self.useItem:getChildByTag(10),"CCLabelTTF")
                if(lb)then
                    lb:setString(getlocal("freeAccelerate"))
                end
            end
        end

        local hadNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(self.propId)))
        local needNum = 0
        if leftTime > 0 then
            needNum = math.ceil(leftTime/spTime)
        end

        if needNum > hadNum then
          needNum = hadNum
        end

        if self.needNum ~= needNum then
        	self.needNum = needNum
        	if needNum == 0 then
                self.slider:setMinimumValue(0)
                self.slider:setValue(0)
                self.slider:setMaximumValue(0)
            else
                self.slider:setMaximumValue(needNum)
                if self.selectNum > needNum then
                    self.selectNum=needNum
                    self.slider:setValue(needNum)
                end
    	    end
        end
    else
        self:close()
    end    
end

function speedUpPropSelectDialog:isTimeOverFlow(pid)
    local isOverFlow,isStopAutoUpgrade=false
    if pid and propCfg[pid] then
        local leftTime
        if self.speedType == 1 then
            leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
        elseif self.speedType == 2 then
            leftTime = technologyVoApi:leftTime(self.speedType1)
        elseif self.speedType == 3 then
            leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        elseif self.speedType == 4 then
            leftTime = tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        end
        if leftTime then
            local useTimeDecrease=propCfg[pid].useTimeDecrease
            local count = math.floor(self.slider:getValue())
            if leftTime<(useTimeDecrease*count) then
                isOverFlow=true
            end
        end
    end
    if self.speedType == 1 and base.autoUpgrade==1 and buildingVoApi:getAutoUpgradeBuilding()==1 and buildingVoApi:getAutoUpgradeExpire()-base.serverTime>0 then
        isStopAutoUpgrade=true
    end
    return isOverFlow,isStopAutoUpgrade
end

function speedUpPropSelectDialog:dispose()
	if self.closeCallBack then
		self.closeCallBack()
	end
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.speedType = nil--加速类型(建筑加速/科技加速/生产加速)
	self.speedType1= nil--若加速类型是建筑加速，这里是建筑类型；若加速类型是科技加速，这里是科技类型；若加速类型是生产加速，这里是舰船类型。
	self.upgradeCallBack = nil
	self.closeCallBack = nil
	self.canSpeedTime = nil--vip免费加速的时间
	self.propId = nil
	self.needNum = nil
	self.selectNum = nil
	self.freeTsTip = nil
	self.slider = nil
    self.useItem = nil
    self.addSp = nil
    self.minusSp = nil
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    self = nil
end