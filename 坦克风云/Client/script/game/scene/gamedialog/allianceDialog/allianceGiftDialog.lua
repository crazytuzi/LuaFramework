allianceGiftDialog=commonDialog:new()

function allianceGiftDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum=layerNum
	nc.width = G_VisibleSizeWidth
	nc.height = G_VisibleSizeHeight - 80
	nc.getRewardTb      = {}
	nc.flickerTypeTb    = {}
	nc.curAllGiftTbNums = {}
	nc.refreshType = false
	return nc
end
function allianceGiftDialog:initTableView( )
	
end
function allianceGiftDialog:dispose()
	self.curAllGiftTbNums = nil
	self.flickerTypeTb    = nil
	self.getRewardTb      = nil
	self.sureBtn          = nil
	self.getBtn           = nil
	self.cellHeight       = nil
	self.curCellNums      = nil
	self.curGiftTbNums    = nil
	self.downTitleLb      = nil
	self.upHeight         = nil
	self.downHeight       = nil
	
	self.middleBg = nil	
	self.curNotGetGiftLb = nil
	self.curPerLb     = nil
	self.topTitle     = nil
	self.curLvlLb     = nil
	self.nextLvlLb    = nil
	self.loadingBar   = nil
	self.loadingBarBg = nil

	spriteController:removePlist("public/blueFilcker.plist")
	spriteController:removeTexture("public/blueFilcker.png")
	spriteController:removePlist("public/greenFlicker.plist")
	spriteController:removeTexture("public/greenFlicker.png")
	spriteController:removePlist("public/purpleFlicker.plist")
	spriteController:removeTexture("public/purpleFlicker.png")
	spriteController:removePlist("public/yellowFlicker.plist")
	spriteController:removeTexture("public/yellowFlicker.png")
	spriteController:removePlist("public/redFlicker.plist")
	spriteController:removeTexture("public/redFlicker.png")
end

function allianceGiftDialog:refresh(isInTick)
	if self.topTitle then
		self.topTitle:setString(getlocal("alliance_gift_title",{allianceGiftVoApi:getLevel()}))
	end

	local curLvl,nextLvl,curPerStr,curPerNum = allianceGiftVoApi:getExpData()
	if self.curLvlLb then
		self.curLvlLb:setString(getlocal("fightLevel",{curLvl}))
	end
	if nextLvl and self.nextLvlLb then
		self.nextLvlLb:setString(getlocal("fightLevel",{nextLvl}))
	elseif self.nextLvlLb then
		self.nextLvlLb:setVisible(false)
	end
	if self.curPerLb then
		self.curPerLb:setString(curPerStr)
	end
	if self.loadingBar then
		self.loadingBar:setPercentage(curPerNum or 100)
	end
	if self.downTitleLb then
		local curGiftTbNums,giftLimit = allianceGiftVoApi:getCurGiftNumsAndLimit( )
		self.curGiftTbNums = curGiftTbNums
		if self.curGiftTbNums > 0 then
			self.curCellNums = math.ceil(self.curGiftTbNums / 5)
		elseif SizeOfTable(self.getRewardTb) > 0 then
			self.curCellNums = math.ceil(SizeOfTable(self.getRewardTb) / 5)
		end

		self.downTitleLb:setString(getlocal("allianceGift_limit",{curGiftTbNums,giftLimit}))
		if self.curGiftTbNums >= giftLimit then
			self.downTitleLb:setColor(G_ColorRed)
		else
			self.downTitleLb:setColor(G_ColorYellowPro3)
		end
		if not isInTick then
			if curGiftTbNums > 0 or SizeOfTable(self.getRewardTb) == 0 then
				self:initNotAwardTip()
			elseif self.curNotGetGiftLb then
				self.curNotGetGiftLb:setVisible(false)
			end
		else
			if curGiftTbNums > 0 or SizeOfTable(self.getRewardTb) == 0 then
				if self.middleBg then
					self:initTableView2(self.middleBg)
			    end
			    if self.curNotGetGiftLb then
				    self.curNotGetGiftLb:setVisible(false)
				end
			end
		end
	end
	if self.getBtn then
		if  allianceGiftVoApi:getCurGiftNumsAndLimit() > 0 then
	    	self.getBtn:setEnabled(true)
	    else
	    	self.getBtn:setEnabled(false)
	    end
    end
end
function allianceGiftDialog:doUserHandler()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    spriteController:addPlist("public/newAlliance.plist")
	spriteController:addPlist("public/believer/believerMain.plist")
	spriteController:addTexture("public/believer/believerMain.png")
	spriteController:addTexture("public/newAlliance.png")
--accessoryImage
	spriteController:addTexture("public/blueFilcker.png")
	spriteController:addTexture("public/greenFlicker.png")
	spriteController:addTexture("public/purpleFlicker.png")
	spriteController:addTexture("public/yellowFlicker.png")
	spriteController:addTexture("public/redFlicker.png")

	spriteController:addPlist("public/blueFilcker.plist")
	spriteController:addPlist("public/greenFlicker.plist")
	spriteController:addPlist("public/purpleFlicker.plist")
	spriteController:addPlist("public/yellowFlicker.plist")
	spriteController:addPlist("public/redFlicker.plist")
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


	self.panelLineBg:setVisible(false)
	self.panelShadeBg:setVisible(true)

	self:initUp()
	self:initDown()
end

function allianceGiftDialog:initUp( )
	local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
    upBg:setContentSize(CCSizeMake(self.width - 20, self.height * 0.15))
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setPosition(self.width * 0.5,self.height - 15)
    self.bgLayer:addChild(upBg)
    self.upHeight = upBg:getContentSize().height + 15

    local usePosy = upBg:getContentSize().height * 0.3

    local topTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    topTitleBg:setAnchorPoint(ccp(0.5,1))
    topTitleBg:setPosition(upBg:getContentSize().width * 0.5,upBg:getContentSize().height - 15)
    upBg:addChild(topTitleBg)

    local topTitle = GetTTFLabelWrap(getlocal("alliance_gift_title",{allianceGiftVoApi:getLevel()}), 24, CCSizeMake(self.width * 0.5, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    topTitle:setPosition(getCenterPoint(topTitleBg))
    topTitle:setColor(G_ColorYellowPro3)
    topTitleBg:addChild(topTitle)
    self.topTitle = topTitle

    local function showInfo()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        allianceGiftVoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,0.5))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(upBg:getContentSize().width - 20,usePosy))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	upBg:addChild(infoBtn,3)


	-- 进度条 --upBg:getContentSize().width * 0.7
	local curLvl,nextLvl,curPerStr,curPerNum = allianceGiftVoApi:getExpData()
	AddProgramTimer(upBg,ccp(upBg:getContentSize().width * 0.45,usePosy - 10),110,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",111)
	self.loadingBar = tolua.cast(upBg:getChildByTag(110),"CCProgressTimer")
	self.loadingBarBg = tolua.cast(upBg:getChildByTag(111),"CCSprite")
	self.loadingBarBg:setRotation(180)
	self.loadingBar:setRotation(180)
	self.loadingBar:setScaleX(1)
	self.loadingBarBg:setScaleX(1)
	self.loadingBar:setScaleY(1.1)
	self.loadingBarBg:setScaleY(1.1)
	self.loadingBar:setMidpoint(ccp(1,0))
	self.loadingBar:setPercentage(curPerNum or 100)
	local loadingBarHeight = self.loadingBarBg:getContentSize().height
	local loadingBarWidth = self.loadingBarBg:getContentSize().width

	local curLvlLb = GetTTFLabel(getlocal("fightLevel",{curLvl}),23)
	curLvlLb:setAnchorPoint(ccp(0,0))
	curLvlLb:setRotation(180)
	curLvlLb:setPosition(loadingBarWidth, 5)
	self.loadingBarBg:addChild(curLvlLb,99)
	self.curLvlLb = curLvlLb
	if nextLvl then
		local nextLvlLb = GetTTFLabel(getlocal("fightLevel",{nextLvl}),23)
		nextLvlLb:setAnchorPoint(ccp(1,0))
		nextLvlLb:setRotation(180)
		nextLvlLb:setPosition(0, 5)
		self.loadingBarBg:addChild(nextLvlLb,99)
		self.nextLvlLb = nextLvlLb
	end
	if curPerStr then
		local curPerLb = GetTTFLabel(curPerStr,23)
		curPerLb:setPosition(upBg:getContentSize().width * 0.45,usePosy - 10)--getCenterPoint(self.loadingBarBg))
		upBg:addChild(curPerLb,10)
		self.curPerLb = curPerLb
	end
end

function allianceGiftDialog:initDown( )
	self.middleHeight = self.height - self.upHeight - 160

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setContentSize(CCSizeMake(self.width - 30, self.middleHeight))
	middleBg:setPosition(self.width * 0.5,self.height - self.upHeight - 10)
	self.middleBg = middleBg
	self.bgLayer:addChild(middleBg)
	local middleWidth = middleBg:getContentSize().width
	self.middleWidth = middleWidth
	local curGiftTbNums,giftLimit = allianceGiftVoApi:getCurGiftNumsAndLimit( )
	self.curGiftTbNums = curGiftTbNums
	local titleTb = {getlocal("allianceGift_limit",{curGiftTbNums,giftLimit}),G_isAsia() and 24 or 20,G_ColorYellowPro3}--allianceGift_limit

	local titleBg,downTitleLb,downTitleHeight = G_createNewTitle(titleTb,CCSizeMake(360,0),true,true,"Helvetica-bold")
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(middleWidth * 0.5,self.middleHeight - 15)
	middleBg:addChild(titleBg)
	self.downTitleLb = downTitleLb

	if self.curGiftTbNums >= giftLimit then
		self.downTitleLb:setColor(G_ColorRed)
	else
		self.downTitleLb:setColor(G_ColorYellowPro3)
	end
	self.curAllGiftTbNums = allianceGiftVoApi:getCurGiftTb( )
	self.tvHeight   = self.middleHeight - downTitleHeight - 20
	self.tvWidth    = middleWidth
	self.cellHeight = 125
	self:initTableView2(middleBg)
	self:initBtn()
end

function allianceGiftDialog:initNotAwardTip( )
	if not self.curNotGetGiftLb then
		local curNotGetGiftLb = GetTTFLabelWrap(getlocal("curNotGetGift"),30,CCSizeMake(self.tvWidth*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	    curNotGetGiftLb:setAnchorPoint(ccp(0.5,0.5))
	    curNotGetGiftLb:setPosition(getCenterPoint(self.middleBg))
	    self.middleBg:addChild(curNotGetGiftLb)
	    self.curNotGetGiftLb = curNotGetGiftLb
	    curNotGetGiftLb:setColor(G_ColorGray)
	else
		self.curNotGetGiftLb:setVisible(true)
	end
end

function allianceGiftDialog:initTableView2(parentBg)
	if self.curGiftTbNums == 0 then
		self:initNotAwardTip()
		do return end
	else
		self.curCellNums = math.ceil(self.curGiftTbNums / 5)
	end
	------------------------------------------------
 	if not self.tv then
		local function callBack(...)
	        return self:eventHandler(...)
	    end
	    local hd=LuaEventHandler:createHandler(callBack)
	    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight - 2),nil)
	    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	    self.tv:setPosition(ccp(0,2))
	    parentBg:addChild(self.tv,2)
	    self.tv:setMaxDisToBottomOrTop(100)	
	else
		local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
	end
end

function allianceGiftDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.curCellNums * (self.cellHeight + 25))--self.tvHeight - 4 + 50) 
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local curGiftTb = allianceGiftVoApi:formatCurGiftTb( )
        local useNum = SizeOfTable(self.getRewardTb)
        local initIdx = 1
        if useNum == 0 then
	        for j=1,self.curCellNums do
	        	for i=1,5 do
	        		if initIdx <= self.curGiftTbNums and curGiftTb[initIdx] then
	        			local posx = self.tvWidth*((i-1)*0.2+0.1)--signPropBg1
	        			local thisTb = curGiftTb[initIdx]
			        	local icon = thisTb.icon
			        	local iconBg = thisTb.iconbg
			        	local flicker = thisTb.flicker
			        	local lvStr = "Lv."..thisTb.grade
			        	local nameStr = getlocal(thisTb.name)
			        	self.flickerTypeTb[initIdx] = flicker

			        	local iconSp = GetBgIcon(icon,nil,iconBg,70,100)
			        	local scale = (self.cellHeight - 20) / iconSp:getContentSize().height
			        	iconSp:setScale(scale)
			        	iconSp:setPosition(posx,(self.cellHeight + 25) * self.curCellNums - self.cellHeight * 0.5 - (j-1) * self.cellHeight - (j-1) * 25)
			        	cell:addChild(iconSp)

			        	local numLb=GetTTFLabel(lvStr,22)
		                numLb:setAnchorPoint(ccp(1,0))
		                numLb:setPosition(iconSp:getContentSize().width - 5,5)
		                iconSp:addChild(numLb,2)
		                local scaleNum = 0.9/scale
		                numLb:setScale(scaleNum)

		                local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")--LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
		                numBg:setAnchorPoint(ccp(1,0))
		                numBg:setScaleX((numLb:getContentSize().width + 2 ) * scaleNum / numBg:getContentSize().width)
		                numBg:setScaleY((numLb:getContentSize().height + 2) * scaleNum / numBg:getContentSize().height)
		                numBg:setPosition(ccp(iconSp:getContentSize().width - 5 ,5))
		                numBg:setOpacity(150)
		                iconSp:addChild(numBg,1) 

		                local strSize2 = G_getCurChoseLanguage() == "ko" and 13 or 18

		                local iconName = GetTTFLabel(nameStr,G_isAsia() and strSize2 or 12,true)
		                iconName:setAnchorPoint(ccp(0.5,1))
		                iconName:setPosition(iconSp:getPositionX(),iconSp:getPositionY() - self.cellHeight * 0.5 + 5)
		                cell:addChild(iconName)

		                if flicker ~= "no" then
			                G_addRectFlicker2(iconSp,nil,nil,initIdx,flicker,nil,nil,true)
			            end

			        	initIdx = initIdx + 1
			        end
		        end
		    end
		end

	    local initIdx2 = 1
	    local useNum = SizeOfTable(self.getRewardTb)
	    for j=1,self.curCellNums do
	    	for i=1,5 do
	    		if initIdx2 <= useNum and self.getRewardTb[initIdx2] then
	    			local posx = self.tvWidth*((i-1)*0.2+0.1)--signPropBg1
	    			local reward = self.getRewardTb[initIdx2]
	    			local function showNewReward( )
	    				if G_checkClickEnable()==false then
				            do return end
				        else
				            base.setWaitTime=G_getCurDeviceMillTime()
				        end
		                G_showNewPropInfo(self.layerNum+2,true,nil,nil,reward,nil,nil,nil)
		            end
	    			local icon,scale=G_getItemIcon(reward,self.cellHeight - 20,true,self.layerNum,showNewReward)
	                icon:setTouchPriority(-(self.layerNum-1)*20-3)

	                icon:setPosition(posx,(self.cellHeight + 25) * self.curCellNums - self.cellHeight * 0.5 - (j-1) * self.cellHeight - (j-1) * 25)
	                cell:addChild(icon)

	                local numLb=GetTTFLabel("×"..FormatNumber(reward.num),22)
	                numLb:setAnchorPoint(ccp(1,0))
	                numLb:setPosition(icon:getContentSize().width - 5,5)
	                icon:addChild(numLb,2)
	                numLb:setScale(0.9/scale)

	                local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
	                numBg:setAnchorPoint(ccp(1,0))
	                numBg:setScaleX((numLb:getContentSize().width + 2 ) / numBg:getContentSize().width)
	                numBg:setScaleY((numLb:getContentSize().height - 2) / numBg:getContentSize().height)
	                numBg:setPosition(ccp(icon:getContentSize().width - 5 ,5))
	                numBg:setOpacity(250)
	                icon:addChild(numBg,1) 

	                local flicker = (self.flickerTypeTb and self.flickerTypeTb[initIdx2])  and self.flickerTypeTb[initIdx2] or "no"
	                if flicker ~= "no" then
		                G_addRectFlicker2(icon,nil,nil,initIdx2,flicker,nil,nil,true)
		            end
	                initIdx2 = initIdx2 + 1
	    		end
	    	end
	    end


        return cell
    end
end

function allianceGiftDialog:initBtn( )
	self.downHeight = self.height - self.upHeight - self.middleHeight

	local function btnCallBack()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function socketCallback(rewardTb)
        	self.curAllGiftTbNums = allianceGiftVoApi:getCurGiftTb( )
        	self.getRewardTb = rewardTb
        	if SizeOfTable(self.getRewardTb) > 0 then
        		self:refresh()
        		if self.tv then
			        self.tv:reloadData()
			    end
			    if self.getBtn then
			    	self.getBtn:setVisible(false)
			    	self.getBtn:setEnabled(false)
			    end
			    if self.sureBtn then
			    	self.sureBtn:setVisible(true)
			    	self.sureBtn:setEnabled(true)
			    end
        	end
        end 

        allianceGiftVoApi:socketRec(socketCallback)
	end 
	local downButton = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",btnCallBack,nil,getlocal("alien_tech_acceptAll"),28,123)
	downButton:setScale(0.9)
	local downMenu=CCMenu:createWithItem(downButton)
    downMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    downMenu:setPosition(self.width * 0.5,self.downHeight * 0.5)
    self.bgLayer:addChild(downMenu)

    self.getBtn = downButton
    if allianceGiftVoApi:getCurGiftNumsAndLimit() == 0 then
    	self.getBtn:setEnabled(false)
    end

    local function sureCallback( )
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self.sureBtn:setVisible(false)
        self.sureBtn:setEnabled(false)
        self.getBtn:setVisible(true)
        self.getRewardTb = {}
        self.flickerTypeTb = {}
        if self.tv then
			local recordPoint = self.tv:getRecordPoint()
	        self.tv:reloadData()
	        self.tv:recoverToRecordPoint(recordPoint)
	    end
	    self:initNotAwardTip()
    end 
    local sureButton = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureCallback,nil,getlocal("confirm"),28,123)
	sureButton:setScale(0.9)
	local sureMenu=CCMenu:createWithItem(sureButton)
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    sureMenu:setPosition(self.width * 0.5,self.downHeight * 0.5)
    self.bgLayer:addChild(sureMenu)
    self.sureBtn = sureButton
    self.sureBtn:setVisible(false)
end

-- function allianceGiftDialog:test( )
-- 	local reward = allianceGiftCfg.gradeGift.list[8].reward
-- 	print("reward--->>",reward,SizeOfTable(reward))
-- 	local formatTb = FormatItem(reward)
-- 	print('formatTb--->>',SizeOfTable(formatTb))

-- 	for k,v in pairs(formatTb) do
-- 		local function showNewReward( )
-- 			if G_checkClickEnable()==false then
-- 	            do return end
-- 	        else
-- 	            base.setWaitTime=G_getCurDeviceMillTime()
-- 	        end
--             G_showNewPropInfo(self.layerNum+2,true,nil,nil,v,nil,nil,nil)
--         end
-- 		local icon,scale=G_getItemIcon(v,self.cellHeight - 20,true,self.layerNum,showNewReward)
--         icon:setTouchPriority(-(self.layerNum-1)*20-3)
-- 	end
-- end



function allianceGiftDialog:tick()
	if self.refreshType ~= allianceGiftVoApi:getRefreshType( ) and SizeOfTable(self.getRewardTb) == 0 then
		allianceGiftVoApi:setRefreshType(false)
		self.curAllGiftTbNums = allianceGiftVoApi:getCurGiftTb( )
		self.getRewardTb = {}
        self.flickerTypeTb = {}
        self:refresh(true)
	end
end

