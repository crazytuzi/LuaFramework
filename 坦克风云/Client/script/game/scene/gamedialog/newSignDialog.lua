newSignDialog=commonDialog:new()

function newSignDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.upHeight   = G_VisibleSizeHeight - 82
	nc.checkInBtn         = nil
	nc.checkInAgainBtn    = nil
	nc.checkInAgainGoldTb = {}
	nc.checkInAgainNumStr = nil
	nc.addUpAwardTb = {}
	nc.addUpDayTb   = {}
	nc.addUpFgTb    = {}
	nc.addUpFlickTb = {}
	nc.isToday = newSignInVoApi:isToday( )
	nc.isMonth = G_getDate(base.serverTime).month
	nc.isMonth = nil
	return nc
end

function newSignDialog:dispose()
	self.secondDialog = nil
	self.thrivingSmallDialog = nil
	self.reSignLastDayNumStr = nil
	self.addUpFlickTb = nil
	self.addUpFgTb    = nil
	self.addUpDayTb   = nil
	self.addUpAwardTb = nil
	self.checkInAgainNumStr = nil
	self.checkInBtn         = nil
	self.checkInAgainBtn    = nil
	self.checkInAgainGold   = nil
	spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    self.isToday = nil
end

function newSignDialog:tick( )
	-- print("lastSignInMonth--->>>",newSignInVoApi:lastSignInMonth())
	if self.isToday ~= newSignInVoApi:isToday( ) then
		self.isToday = newSignInVoApi:isToday()
		self:refreshBtn()
	elseif not newSignInVoApi:lastSignInMonth( ) then

		self:nextMonthToRefreshData( )	
		self:refreshBtn()
		-- print("newSignInVoApi:getVer( )------in tick ----->>>>",newSignInVoApi:getVer( ))
	end
	
end

function newSignDialog:nextMonthToRefreshData( )
	if self.isMonth ~= G_getDate(base.serverTime).month and newSignInVoApi:lastSignInMonth( ) == false then
		self.isMonth = G_getDate(base.serverTime).month--
		newSignInVoApi:setCurMonTH( )
		if self.thrivingSmallDialog and self.thrivingSmallDialog.close then
			self.thrivingSmallDialog:close()
		end
		if self.secondDialog and self.secondDialog.close then
			self.secondDialog:close()
		end
		newSignInVoApi:changeVer( )
		newSignInVoApi:clearAll(true)
		newSignInVoApi:resetData()
	end
end

function newSignDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self:nextMonthToRefreshData()
    -- print("newSignInVoApi:getVer( )----->>>",newSignInVoApi:getVer( ))
end

function newSignDialog:doUserHandler()
	
	 local playerRank = playerVoApi:getRank()
	 -- print("playerRank=====>>>>",playerRank)
	 local honors = playerCfg.daily_honor[playerRank]
	 -- print("honors------>>>",honors)
	-- if self.titleLabel then
	-- 	self.titleLabel:setString("!!@@####")
	-- end
	spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
	spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")

	local upSubHeight = 30

	local checkInAgainNumStr = GetTTFLabel(getlocal("checkInAgainNum",{newSignInVoApi:getCheckInAgainNum()}),23,true)
	checkInAgainNumStr:setAnchorPoint(ccp(0,0.5))
	checkInAgainNumStr:setPosition(20,self.upHeight - upSubHeight)
	self.bgLayer:addChild(checkInAgainNumStr)
	self.checkInAgainNumStr = checkInAgainNumStr

	--newSignTip1
	local function showInfo()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        newSignInVoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	-- infoItem:setAnchorPoint(ccp(1,1))
	infoItem:setScale(0.7)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 35, self.upHeight - upSubHeight))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,3)

	local reSignLastDayNumStr = GetTTFLabel(getlocal("reSignLastDayNum",{newSignInVoApi:getReSignLastDayNum()}),23,true)
	reSignLastDayNumStr:setAnchorPoint(ccp(1,0.5))
	reSignLastDayNumStr:setPosition(G_VisibleSizeWidth - 70,self.upHeight - upSubHeight)
	self.bgLayer:addChild(reSignLastDayNumStr)
	self.reSignLastDayNumStr = reSignLastDayNumStr

	local exchangeEnabled = FuncSwitchApi:isEnabled("newSign_exchange")
	local posxTb = {0.19,0.5,0.81}
	local strTb = {getlocal("code_gift"),getlocal("signBtn"),getlocal("addSignBtn")}
	local btnName = {
						{"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png"},	
						{"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"},
						{"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png"},
					}
	
	for i=1,3 do

		local function btnCallBack( )

			print("i===>>>",i)
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        if i == 1 then
	        	if newSignInVoApi:isCanExchange() then--皮肤兑换入口
	        		self:close()
	        		activityAndNoteDialog:closeAllDialog()
	        		G_goToDialog2("dressUp",self.layerNum,nil)
	        	else
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{exteriorCfg.openlv}),30)
	        		do return end
	        	end
	        elseif i == 2 then
	        	local curSignReward = newSignInVoApi:getCurSignUse( )
	        	if curSignReward then
	        		local useCurTime = base.serverTime
		        	local function callBack( )
		        		self:addAwardNow(curSignReward)
		        		G_showRewardTip(curSignReward,true)
		        		self:refreshBtn()
		        	end
		        	newSignInVoApi:SocketCall(callBack,"sign",nil,useCurTime)
		        end
	        elseif i == 3 then
	        	local costNum = newSignInVoApi:getCheckInNeedGold()
	        	if playerVoApi:getGems()<costNum then
			        GemsNotEnoughDialog(nil,nil,costNum-playerVoApi:getGems(),self.layerNum+1,costNum)
			        do return end
			    end

	        	local function realSocket( )
	        		local curReSignReward = newSignInVoApi:getCurReSignUse( )
	        		if curReSignReward then
	        			local useCurTime = base.serverTime
		        		local function callBack( )
		        			self:addAwardNow(curReSignReward)
		        			playerVoApi:setGems(playerVoApi:getGems() - costNum)
		        			G_showRewardTip(curReSignReward,true)
			        		self:refreshBtn()
			        	end
			        	newSignInVoApi:SocketCall(callBack,"resign",nil,useCurTime)
			        end
	        	end

	        	local function sureClick()
		            realSocket()
		        end
		        local function secondTipFunc(sbFlag)
		            local keyName="newSign"
		            local sValue=base.serverTime .. "_" .. sbFlag
		            G_changePopFlag(keyName,sValue)
		        end
		        if costNum and costNum>0 then
		        	local keyName = "newSign"
		        	if G_isPopBoard(keyName) then
		        		desInfo = {nil,nil,kCCTextAlignmentCenter}
		                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("isCanCheckInAgain",{costNum}),true,sureClick,secondTipFunc,nil,desInfo)
	                else
		                sureClick()
		            end
		        end
	        end
		end 
		local downButton = GetButtonItem(btnName[i][1],btnName[i][2],btnName[i][3],btnCallBack,nil,strTb[i],28,10 + i)
		downButton:setAnchorPoint(ccp(0.5,0))
		downButton:setScale(0.9)
		local downMenu=CCMenu:createWithItem(downButton)
	    downMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    downMenu:setPosition(G_VisibleSizeWidth * posxTb[i],25)
	    self.bgLayer:addChild(downMenu,22)

	    if i == 2 then
	    	self.checkInBtn = downButton
	    	if newSignInVoApi:isToday( ) then
	    		self.checkInBtn:setEnabled(false)
	    	end
	    elseif i == 3 then
	    	self.checkInAgainBtn = downButton
		    
	    	local addPosy = 35
	    	local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
			goldIcon:setAnchorPoint(ccp(1,0.5))
			goldIcon:setPosition(G_VisibleSizeWidth * posxTb[i] - 5 , downButton:getContentSize().height + addPosy)
			goldIcon:setScale(0.9)
			self.bgLayer:addChild(goldIcon,22)
			self.checkInAgainGoldTb.goldIcon = goldIcon

			local needGold = GetTTFLabel(newSignInVoApi:getCheckInNeedGold(),24)
			needGold:setAnchorPoint(ccp(0,0.5))
			needGold:setPosition(G_VisibleSizeWidth * posxTb[i] - 5 , downButton:getContentSize().height + addPosy)
			self.bgLayer:addChild(needGold,22)
			self.checkInAgainGoldTb.needGold = needGold

			if newSignInVoApi:isToday( ) == false or newSignInVoApi:getCheckInAgainNum() == 0 or newSignInVoApi:curIsCheckInDays() then
				self.checkInAgainBtn:setEnabled(false)
				self.checkInAgainGoldTb.goldIcon:setVisible(false)
				self.checkInAgainGoldTb.needGold:setVisible(false)
			end
	    end
	    if exchangeEnabled == false then --兑换功能关闭的话需要调整按钮坐标
	    	if i == 1 then
	    		downMenu:setPosition(9999,9999)
	    		downMenu:setVisible(false)
	    	elseif i == 2 then
	    		downMenu:setPositionX(G_VisibleSizeWidth/2 - 140)
	    	elseif i == 3 then
	    		downMenu:setPositionX(G_VisibleSizeWidth/2 + 140)
	    	end
	    end
	end

	self:initAddUpCheckIn()
end

function newSignDialog:refreshBtn( )
	-- print("reSignLastDayNumStr---->>>",self.reSignLastDayNumStr)
	if self.reSignLastDayNumStr then
		-- print("reSignLastDayNumStr---->>>>",newSignInVoApi:getReSignLastDayNum())
		self.reSignLastDayNumStr:setString(getlocal("reSignLastDayNum",{newSignInVoApi:getReSignLastDayNum()}))
	end
	if self.checkInBtn then
		if newSignInVoApi:isToday( ) then
			self.checkInBtn:setEnabled(false)
		else
			self.checkInBtn:setEnabled(true)
		end
	end
	-- print(" in refreshBtn")
	if self.checkInAgainBtn and self.checkInAgainGoldTb.goldIcon and self.checkInAgainGoldTb.needGold then
		if newSignInVoApi:isToday( ) == false or newSignInVoApi:getCheckInAgainNum() == 0 or newSignInVoApi:curIsCheckInDays() then
			self.checkInAgainBtn:setEnabled(false)
			self.checkInAgainGoldTb.goldIcon:setVisible(false)
			self.checkInAgainGoldTb.needGold:setVisible(false)
		else
			self.checkInAgainBtn:setEnabled(true)
			self.checkInAgainGoldTb.goldIcon:setVisible(true)
			self.checkInAgainGoldTb.needGold:setVisible(true)
			self.checkInAgainGoldTb.needGold:setString(newSignInVoApi:getCheckInNeedGold())
		end
		self.checkInAgainNumStr:setString(getlocal("checkInAgainNum",{newSignInVoApi:getCheckInAgainNum()}))
	end
	self:refreshAddUpData()

	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function newSignDialog:initAddUpCheckIn( )--累计签到奖励
	self.width = G_VisibleSizeWidth - 30
	self.downHeight = 200
	local addUpBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    addUpBg:setContentSize(CCSizeMake(self.width,self.downHeight))
    addUpBg:setAnchorPoint(ccp(0.5,0))
    addUpBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,130))
    self.bgLayer:addChild(addUpBg)

    local titleTb = {getlocal("addUpCheckInAward"),G_isAsia() and 24 or 19,G_ColorYellowPro2}
    local titleBg,titleLb,titleHeight = G_createNewTitle(titleTb,CCSizeMake(250,0),nil,true,"Helvetica-bold")
    addUpBg:addChild(titleBg)
    titleBg:setPosition(self.width * 0.5, self.downHeight - titleHeight - 10)

    self.addUpAwardTb = newSignInVoApi:getAddUpCheckInAwardTb()

    for i=1,4 do
    	local fAward = self.addUpAwardTb[i].reward[1]
    	local posx = self.width*((i-1)*0.25+0.125)
    	-- print("fAward---->>>",fAward.name,fAward.icon)
    	local function callback()
			-- G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil,nil,true)
			local rewardType = 1 --1 不能领取 2 可领取 3 已领取
			local needDay     = self.addUpAwardTb[i].needday
			local curSignTime = newSignInVoApi:getSignTimes() 
			if curSignTime >= needDay then
				rewardType = 2
				if newSignInVoApi:isRtb(i) then
					rewardType = 3
				end
			end
			local function refreshAddUpDataNow( )
				G_showRewardTip(self.addUpAwardTb[i].reward,true)
				self:refreshAddUpData()
			end 
			self.thrivingSmallDialog = newSignInVoApi:addUpAwardSmallDialog(i,self.layerNum+1, refreshAddUpDataNow, self.addUpAwardTb[i].reward, rewardType ,self.isToday,self.isMonth)
		end
		local icon,scale=G_getItemIcon(fAward,100,false,self.layerNum,callback,nil)
		addUpBg:addChild(icon,1)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(posx, self.downHeight * 0.49)

		local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
		fangdajinSp:setAnchorPoint(ccp(1,0))
		fangdajinSp:setPosition(icon:getContentSize().width * 0.9,2)
		icon:addChild(fangdajinSp)

		local needDay     = self.addUpAwardTb[i].needday
		local curSignTime = newSignInVoApi:getSignTimes() 
		local isEnough    = false
		if curSignTime >= needDay then
			curSignTime = needDay
			isEnough    = true
		end
		local addUpDay = GetTTFLabel(getlocal("dayTypeStr",{curSignTime,needDay}),23)
		addUpDay:setPosition(posx, 26)
		addUpDay:setColor(isEnough and G_ColorGreen or G_ColorRed)
		addUpBg:addChild(addUpDay)
		self.addUpDayTb[i] = addUpDay

		local fgSp =  LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1),function ()end)
		fgSp:setContentSize(CCSizeMake(102,102))
		fgSp:setPosition(icon:getPosition())
		addUpBg:addChild(fgSp,2)
		local checkIcon = CCSprite:createWithSpriteFrameName("IconCheck.png")
		checkIcon:setPosition(getCenterPoint(fgSp))
		fgSp:addChild(checkIcon)

		self.addUpFgTb[i] = fgSp

		local rectFlick = G_addRectFlicker2(icon,1.2,1.2,3,"y",nil,55)

		self.addUpFlickTb[i] = rectFlick

		if not newSignInVoApi:isRtb(i) then
			self.addUpFgTb[i]:setVisible(false)
			if not isEnough then
				self.addUpFlickTb[i]:setVisible(false)
			end
		else
			self.addUpFlickTb[i]:setVisible(false)
		end
    end
end

function newSignDialog:refreshAddUpData()
	if self.addUpAwardTb then
		for i=1,4 do
			local needDay     = self.addUpAwardTb[i].needday
			local curSignTime = newSignInVoApi:getSignTimes() 
			local isEnough    = false
			if curSignTime >= needDay then
				curSignTime = needDay
				isEnough    = true
			end
			self.addUpDayTb[i]:setString(getlocal("dayTypeStr",{curSignTime,needDay}))
			self.addUpDayTb[i]:setColor(isEnough and G_ColorGreen or G_ColorRed)

			if not newSignInVoApi:isRtb(i) then
				self.addUpFgTb[i]:setVisible(false)
				if not isEnough then
					self.addUpFlickTb[i]:setVisible(false)
				else
					self.addUpFlickTb[i]:setVisible(true)
				end
			else
				self.addUpFgTb[i]:setVisible(true)
				self.addUpFlickTb[i]:setVisible(false)
			end
		end
	end
end

function newSignDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
	self.tvHeight = G_VisibleSizeHeight - self.downHeight - 280
	local tvPosy = self.downHeight + 135
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setContentSize(CCSizeMake(self.width,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(15,tvPosy))
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.width - 4,self.tvHeight - 4),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(17,tvPosy + 2))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(100)
end

function newSignDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
		local spWidth = (self.width - 4)/5
        return CCSizeMake(self.width - 4,spWidth * 7)--self.tvHeight - 4 + 50) 
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local curMonthDays = G_getMonthDay()
        local verNums = curMonthDays % 5 == 0 and curMonthDays / 5 or curMonthDays / 5 + 1
        local spWidth = (self.width - 4)/5

        local curSignData = newSignInVoApi:getCurSignData()
        
        local initIdx = 1
        local curSignedTimes = newSignInVoApi:getSignTimes()
        for j=1,verNums do
        	for i=1,5 do
        		if initIdx <= curMonthDays then
        			local useIdx = initIdx
        			local reward = curSignData[initIdx].reward
        			local vipNum = curSignData[initIdx].vip
		        	local posx = (self.width-4)*((i-1)*0.2+0.1)--signPropBg1
		        	local smabg = LuaCCScale9Sprite:createWithSpriteFrameName("signPropBg1.png",CCRect(21,5,1,1),function() end)
		        	smabg:setContentSize(CCSizeMake(spWidth,spWidth))
		        	smabg:setPosition(posx,spWidth * 7 - spWidth * 0.5 - (j-1) * spWidth)
		        	cell:addChild(smabg)

		        	local function callback()
				        PlayEffect(audioCfg.mouseClick)
				        local isSB = vipNum > 0 and true or false
						isSB = playerVoApi:getVipLevel() >= vipNum and isSB or false
						local function refreshAddUpDataNow( )
							local beishu = isSB and 2 or 1
							local newUseAward = G_clone(reward)
							for k,v in pairs(newUseAward) do
								v.num = v.num * beishu 
							end
							G_showRewardTip(newUseAward,true)
							self:refreshBtn()
						end 
						--rewardtype 1 不能领取 2 可领取 3 已领取
						local rewardType = 1
						if useIdx <= curSignedTimes then
							rewardType = 3
						elseif useIdx == curSignedTimes + 1 and  not newSignInVoApi:isToday( ) then
							rewardType = 2
						end
						self.thrivingSmallDialog = newSignInVoApi:signNowSmallDialog(useIdx,self.layerNum+1, refreshAddUpDataNow, reward, rewardType,isSB ,self.isToday,self.isMonth)
					end
					local icon,scale=G_getItemIcon(reward[1],85,false,self.layerNum,callback,nil)
					smabg:addChild(icon,1)
					icon:setTouchPriority(-(self.layerNum-1)*20-3)
					icon:setIsSallow(true)
					icon:setPosition(spWidth * 0.5, spWidth * 0.58)

					local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
					fangdajinSp:setAnchorPoint(ccp(1,0))
					fangdajinSp:setPosition(icon:getContentSize().width -2 ,2)
					icon:addChild(fangdajinSp)

					local dayStr = GetTTFLabel(getlocal("checkInDayStr",{initIdx}),19)
					dayStr:setAnchorPoint(ccp(0.5,0))
					dayStr:setPosition(spWidth * 0.5,3)
					smabg:addChild(dayStr,1)

					
					if vipNum > 0 then
						-- print("vipNum--->>>",vipNum)
						local iconHeight = icon:getContentSize().height 
						local vipSp = CCSprite:createWithSpriteFrameName("Vip"..vipNum..".png")
						vipSp:setAnchorPoint(ccp(0.5,1))
						vipSp:setPosition(3,iconHeight + 5)
						icon:addChild(vipSp,3)
						vipSp:setScale(1/scale)
						vipSp:setScale(0.6)

						local vipBg = LuaCCScale9Sprite:createWithSpriteFrameName("vipDoubleBg.png",CCRect(13,20,1,1),function() end)
						vipBg:setPosition(3,iconHeight)
						vipBg:setAnchorPoint(ccp(0.5,1))
						vipBg:setScale(1/scale)
						icon:addChild(vipBg,2)
						local AwardNum = GetTTFLabel("x"..2,16,true)
						AwardNum:setPosition(vipBg:getContentSize().width * 0.5,vipBg:getContentSize().height * 0.35)
						vipBg:addChild(AwardNum)

					end

					if initIdx <= curSignedTimes then
						local fgSp =  LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1),function ()end)
						fgSp:setContentSize(CCSizeMake(spWidth,spWidth))
						fgSp:setPosition(getCenterPoint(smabg))
						fgSp:setOpacity(200)
						smabg:addChild(fgSp,5)
						local checkIcon = CCSprite:createWithSpriteFrameName("IconCheck.png")
						checkIcon:setPosition(getCenterPoint(fgSp))
						fgSp:addChild(checkIcon)
					elseif initIdx == curSignedTimes + 1 then
						local smabg2 = LuaCCScale9Sprite:createWithSpriteFrameName("signPropBg2.png",CCRect(21,5,1,1),function() end)
			        	smabg2:setContentSize(CCSizeMake(spWidth,spWidth))
			        	smabg2:setPosition(getCenterPoint(smabg))
			        	smabg:addChild(smabg2)

			        	local isSB = vipNum > 0 and true or false
						isSB = playerVoApi:getVipLevel() >= vipNum and isSB or false

			        	if not newSignInVoApi:isToday( ) then
			        		G_addRectFlicker2(icon,1.1,1.1,3,"y",nil,1)
			        		newSignInVoApi:setCurSignsbType(isSB)
			        		newSignInVoApi:setCurSignUse(reward)
			        	else
			        		newSignInVoApi:setCurSignUse()
			        		if newSignInVoApi:getCheckInAgainNum( ) > 0 then
			        			newSignInVoApi:setCurSignsbType(isSB)
			        			newSignInVoApi:setCurReSignUse(reward)
			        		else
			        			newSignInVoApi:setCurReSignUse()
			        			newSignInVoApi:setCurSignsbType()
		        			end	
			        	end
					end

					initIdx = initIdx + 1
		        end
	        end	
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


function newSignDialog:addAwardNow(newAward)
	local beishu = newSignInVoApi:getCurSignsbType( ) and 2 or 1
	local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值

    --vip特权，奖励翻倍
    -- local vipPrivilegeSwitch=base.vipPrivilegeSwitch
    local rewardPercent=1
    -- if(vipPrivilegeSwitch and vipPrivilegeSwitch.vsr==1)then
    --     if(playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.dailySign and playerCfg.vipRelatedCfg.dailySign[2] and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
    --         rewardPercent=playerCfg.vipRelatedCfg.dailySign[2]
    --     end
    -- end

    for k,v in pairs(newAward) do
        -- print("v.name , v.num ====>>>",v.name,v.num)
        if v.key=="honors" then
            if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                local gems = playerVoApi:convertGems(2,tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
                playerVoApi:setValue("gold",playerVoApi:getGold()+gems * beishu)
            else            
                playerVoApi:setValue("honors",playerVoApi:getHonors()+tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent * beishu)
            end
        end
        if v.key=="gems" then
            playerVoApi:setValue("gems",playerVoApi:getGems()+tonumber(v.num)*rewardPercent)
        end
        if v.id and v.id>0 then
            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
        end
    end

end
