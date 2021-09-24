acCzhkDialog=commonDialog:new()

function acCzhkDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum=layerNum

	nc.upPosY   = G_VisibleSizeHeight - 82
	nc.width    = G_VisibleSizeWidth
	nc.isIphone5  = G_isIphone5()
	nc.sideBgTb = {}
	nc.sideBgPosTb = {}
	nc.catchPos = ccp(G_VisibleSizeWidth * 2, G_VisibleSizeHeight *2)

	nc.totalR = {}
	nc.totalRnum = 0
	nc.totalRewardTb = {}
	nc.scaleTb = {0.19,0.5,0.81}
	nc.curRechItemTb = {}
	nc.isToday = acCzhkVoApi:isToday()
	return nc
end
function acCzhkDialog:dispose()
	self.midIsOverLb      = nil
	self.midRechargeItem  = nil
	self.curRechItemTb    = nil
	self.goldSp           = nil
	self.curDayRechargeLb = nil
	self.arrowUpSp        = nil
	self.scaleTb          = nil
	self.middlePanelSp    = nil
	self.totalRewardTb    = nil
	self.midTitle         = nil
	self.middleSpDownPosy = nil
	self.upRewardPosy     = nil
	self.totalR           = nil
	self.totalRnum        = nil
	self.selectSp         = nil
	self.catchPos         = nil
	self.sideBgTb         = nil
	self.sideBgPosTb      = nil
	self.width            = nil
	self.upPosY           = nil
	self.UpBgDownPosY     = nil
	self.upSideBgDownPosy = nil
	spriteController:removePlist("public/acCzhkImage.plist")--packsImage
    spriteController:removeTexture("public/acCzhkImage.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/addOtherImage.plist")
	spriteController:removeTexture("public/addOtherImage.png")
	spriteController:removePlist("public/rewardCenterImage.plist")
	spriteController:removeTexture("public/rewardCenterImage.png")
	spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz") 
    spriteController:removePlist("public/xsjx.plist")
	spriteController:removeTexture("public/xsjx.png")
	spriteController:removePlist("public/acCustomImage.plist")
    spriteController:removeTexture("public/acCustomImage.png")
end

function acCzhkDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end
function acCzhkDialog:getBgOfTabPosY(tabIndex)
    local offset = 0
    if tabIndex == 0 then
    	if G_getIphoneType() == G_iphone5 then
    		offset = - 140
    	elseif G_getIphoneType() == G_iphoneX then
    		offset = - 200
    	else --默认是 G_iphone4
    		offset = - 40
    	end
    elseif tabIndex == 1 then
    	offset = 170
    elseif tabIndex == 2 then
    	offset = 230
    end
    return G_VisibleSizeHeight + offset
end
function acCzhkDialog:doUserHandler()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/xsjx.plist")
    spriteController:addTexture("public/xsjx.png")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    spriteController:addPlist("public/acCzhkImage.plist")
    spriteController:addTexture("public/acCzhkImage.png")
    spriteController:addPlist("public/acThfb.plist")
	spriteController:addTexture("public/acThfb.png")
	spriteController:addPlist("public/packsImage.plist")
	spriteController:addTexture("public/packsImage.png")
	spriteController:addPlist("public/addOtherImage.plist")
	spriteController:addTexture("public/addOtherImage.png")
	spriteController:addPlist("public/rewardCenterImage.plist")
	spriteController:addTexture("public/rewardCenterImage.png")
	spriteController:addPlist("public/acCustomImage.plist")
    spriteController:addTexture("public/acCustomImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self:initBg()
    self:showTotalRewardBox()
    self:showMiddlePanel()
    self:showDownReward()
end
function acCzhkDialog:initBg( )
	local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 82))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 82)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)

	local function onLoadBackground(fn,webImage)
		if self and clipper and tolua.cast(clipper, "CCNode") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(G_VisibleSizeWidth * 0.5, self:getBgOfTabPosY(self.selectedTabIndex) + 100)
            clipper:addChild(webImage)
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acCzhkBg.jpg"),onLoadBackground)
	
	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    -- timeBg:setOpacity(150)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
    self.bgLayer:addChild(timeBg,10)

	local vo=acCzhkVoApi:getAcVo()
	local timeStr=acCzhkVoApi:getTimer()
	self.timeLb=GetTTFLabel(timeStr,25,"Helvetica-bold")
	self.timeLb:setColor(G_ColorYellowPro)
	self.timeLb:setAnchorPoint(ccp(0.5,1))
	self.timeLb:setPosition(ccp(timeBg:getContentSize().width * 0.5,timeBg:getContentSize().height - 12))
	timeBg:addChild(self.timeLb,2)

	local function showInfo()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acCzhkVoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(timeBg:getContentSize().width - 10,timeBg:getContentSize().height - 10))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	timeBg:addChild(infoBtn,3)

	local subHeight = self.isIphone5 and 15 or 5
	self.UpBgDownPosY = self.upPosY - timeBg:getContentSize().height - subHeight
end

function acCzhkDialog:showTotalRewardBox( )
	self.totalR,self.totalRnum = acCzhkVoApi:getTotalRewardData( )
	local rewardPosxTb = {self.width * 0.2, self.width * 0.5, self.width * 0.8}
	for i=1,3 do
		local function chooseHandle( object,fn,tag )
			print("tag--->>>",tag)
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

			if self.selectIdx == tag then
				do return end
			else
				self.selectIdx = tag
			end

			if self.selectSp and tag > 0 then
				self.selectSp:setPosition(self.sideBgPosTb[i])
			end

			if self.midTitle then
				local rCurData = self.totalR[self.selectIdx]
				local needDay = rCurData.needday
				local needGold = rCurData.needgold > 1 and rCurData.needgold or getlocal("anyStr")
				local rechargeDays = acCzhkVoApi:getRechargeDays(i)
				self.midTitle:setString(getlocal("activity_czhk_totalRewardTip",{needDay,needGold,rechargeDays,needDay}))
			
				for k,v in pairs(self.totalRewardTb) do
					if v then
						v:removeFromParentAndCleanup(true)
						self.totalRewardTb[k] = nil
					end
				end
				self:addCurTotalReward(rCurData)
				if self.midIsOverLb and self.midRechargeItem then
					if rechargeDays >= needDay then
				    	self.midIsOverLb:setVisible(true)
				    	self.midRechargeItem:setVisible(false)
				    else
				    	self.midIsOverLb:setVisible(false)
				    	self.midRechargeItem:setVisible(true)
					end
				end
			end

			if self.arrowUpSp then
				self.arrowUpSp:setPositionX(self.middlePanelSp:getContentSize().width * self.scaleTb[self.selectIdx])
			end
		end
		local sideBg = LuaCCSprite:createWithSpriteFrameName("transparentFramePic.png",chooseHandle)
		sideBg:setTag(i)
		sideBg:setTouchPriority(-(self.layerNum-1)*20-3)
		sideBgHeight = sideBg:getContentSize().height
		local pos = ccp(rewardPosxTb[i],self.UpBgDownPosY - sideBgHeight * 0.5)
		sideBg:setPosition(pos)
		self.bgLayer:addChild(sideBg,1)
		self.sideBgTb[i] = sideBg
		self.sideBgPosTb[i] = pos
		if not self.upSideBgDownPosy then
			self.upRewardPosy = self.UpBgDownPosY - sideBgHeight * 0.5
			self.upSideBgDownPosy = self.UpBgDownPosY - sideBgHeight - 15
		end

		if i == 1 then
			local selectSp = CCSprite:createWithSpriteFrameName("unColorBorder3.png")
			selectSp:setPosition(pos)
			self.bgLayer:addChild(selectSp)
			self.selectSp = selectSp
			self.selectIdx = i
		end

		local box = CCSprite:createWithSpriteFrameName(acCzhkVoApi:getGiftimg(i))
		box:setPosition(self.sideBgPosTb[i])
		self.bgLayer:addChild(box)
	end
end

function acCzhkDialog:showMiddlePanel()
	local middlePanelSp = LuaCCScale9Sprite:createWithSpriteFrameName("brownBgPic.png",CCRect(16,16,1,1),function ()end)
	middlePanelSp:setAnchorPoint(ccp(0.5,1))
	middlePanelSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,160))
	middlePanelSp:setPosition(G_VisibleSizeWidth * 0.5, self.upSideBgDownPosy)
	self.bgLayer:addChild(middlePanelSp,1)
	self.middlePanelSp = middlePanelSp
	self.middleSpDownPosy = self.upSideBgDownPosy - middlePanelSp:getContentSize().height

	local lineSp = CCSprite:createWithSpriteFrameName("lineWhite.png")
	lineSp:setScaleX((G_VisibleSizeWidth - 60) / lineSp:getContentSize().width)
	lineSp:setPosition(middlePanelSp:getContentSize().width * 0.5, middlePanelSp:getContentSize().height * 0.67)
	lineSp:setColor(ccc3(146,129,102))--G_VisibleSizeWidth - 60
	middlePanelSp:addChild(lineSp)

	local rCurData = self.totalR[self.selectIdx]
	local needDay = rCurData.needday
	local needGold = rCurData.needgold > 1 and rCurData.needgold or getlocal("anyStr")
	local rechargeDays = acCzhkVoApi:getRechargeDays(self.selectIdx)
	local title1 = GetTTFLabel(getlocal("activity_czhk_totalRewardTip",{needDay,needGold,rechargeDays,needDay}),G_isAsia() and 23 or 18,true)
	title1:setAnchorPoint(ccp(0,0.5))
	title1:setColor(G_ColorYellowPro3)
	title1:setPosition(middlePanelSp:getContentSize().width * 0.06,middlePanelSp:getContentSize().height * 0.82)
	middlePanelSp:addChild(title1)
	self.midTitle = title1
	self:addCurTotalReward(rCurData)

	local arrowUpSp = CCSprite:createWithSpriteFrameName("lightBrownPointPic.png")
	arrowUpSp:setAnchorPoint(ccp(0.5,0))
	arrowUpSp:setPosition(self.middlePanelSp:getContentSize().width * self.scaleTb[1],self.middlePanelSp:getContentSize().height - 2)
	middlePanelSp:addChild(arrowUpSp)
	self.arrowUpSp = arrowUpSp

	local function goTiantang()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("recharge"),33)
    goItem:setScale(0.7)
    self.midRechargeItem = goItem
    local goBtn=CCMenu:createWithItem(goItem);
    goBtn:setTouchPriority(-(self.layerNum-1)*20-3);
    goBtn:setPosition(middlePanelSp:getContentSize().width * 0.87,middlePanelSp:getContentSize().height * 0.35)
    middlePanelSp:addChild(goBtn)
	
    self.midIsOverLb = GetTTFLabel(getlocal("activity_vipAction_had"),G_isAsia() and 24 or 20,true)
	self.midIsOverLb:setPosition(middlePanelSp:getContentSize().width * 0.87,middlePanelSp:getContentSize().height * 0.35)
	middlePanelSp:addChild(self.midIsOverLb)
	self.midIsOverLb:setVisible(false)
    if rechargeDays >= needDay then
    	self.midIsOverLb:setVisible(true)
    	self.midRechargeItem:setVisible(false)
	end

    local curDayRechargeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg2.png",CCRect(84,25,1,1),function ()end)
    curDayRechargeBg:setContentSize(CCSizeMake(330,50))
    curDayRechargeBg:setAnchorPoint(ccp(0.5,1))
    curDayRechargeBg:setPosition(self.width * 0.5,self.middleSpDownPosy - 5)
    self.bgLayer:addChild(curDayRechargeBg)
    local curDayRechargeLb = GetTTFLabel(getlocal("curRechargeStr",{acCzhkVoApi:getCurRecharge()}),23)
    curDayRechargeLb:setPosition(curDayRechargeBg:getContentSize().width * 0.5 - 10,curDayRechargeBg:getContentSize().height *0.5)
    curDayRechargeBg:addChild(curDayRechargeLb)
    self.curDayRechargeLb = curDayRechargeLb
    local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp:setAnchorPoint(ccp(0,0.5))
    goldSp:setPosition(curDayRechargeLb:getPositionX() + curDayRechargeLb:getContentSize().width * 0.5,curDayRechargeBg:getContentSize().height *0.5)
    curDayRechargeBg:addChild(goldSp)
    self.goldSp = goldSp

end
function acCzhkDialog:showCurRecharge(newValue)
	if self.curDayRechargeLb then
		self.curDayRechargeLb:setString(getlocal("curRechargeStr",{newValue or acCzhkVoApi:getCurRecharge()}))
		if self.goldSp then
			self.goldSp:setPositionX(self.curDayRechargeLb:getPositionX() + self.curDayRechargeLb:getContentSize().width * 0.5)
		end
	end
end
function acCzhkDialog:addCurTotalReward(rCurData)
	local rewardTb = rCurData.reward
	for k,v in pairs(rewardTb) do
		local item = v
		local function callback()
            local function closeFun() end 
			G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,nil,true)
		end
		local icon,scale=G_getItemIcon(item,90,false,self.layerNum,callback,nil)
		self.middlePanelSp:addChild(icon,3)
		icon:setTouchPriority(-(self.layerNum-1)*20-3)
		icon:setPosition(self.middlePanelSp:getContentSize().width * 0.06 + 90 * (k - 1) + 45 + 20 * (k-1), self.middlePanelSp:getContentSize().height * 0.35)
		self.totalRewardTb[k] = icon

		local numLb = GetTTFLabel("x" .. FormatNumber(item.num),20)
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
end

function acCzhkDialog:showDownReward( )
	local picTb = {"silverSidePic.png","goldenSidePic.png"}
	local bgRect = CCRect(140,73,1,1)
	local anTb = {ccp(1,0),ccp(0,0)}
	local posxTb = {self.width * 0.5 - 14,self.width * 0.5 + 14}
	local posxTb2 = {self.width * 0.25, self.width * 0.75}
	local posy = self.isIphone5 and 60 or 20

	local girlTb = {"charater_beautyGirl.png","acci_person_2.png"}
	local girlScaleTb = {1.3,1.05}


	for i=1,2 do
		local thisDayTb = acCzhkVoApi:getThisDayRewardData( )
	    local reward = thisDayTb[i].reward
	    local limitNum = thisDayTb[i].needgold
	    local rNum = SizeOfTable(reward)
	    local posYTb = {0.5}

		local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName(picTb[i],bgRect,function ()end)
		bgSp:setAnchorPoint(anTb[i])
		bgSp:setContentSize(CCSizeMake(280,220))
		bgSp:setPosition(posxTb[i],posy)
		self.bgLayer:addChild(bgSp,5)

		local isOverLb = GetTTFLabel(getlocal("activity_vipAction_had"),G_isAsia() and 24 or 17,true)
		isOverLb:setPosition(bgSp:getContentSize().width * 0.5,bgSp:getContentSize().height * 0.18)
		bgSp:addChild(isOverLb)

		local function goTiantang()
	        if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        activityAndNoteDialog:closeAllDialog()
	        vipVoApi:showRechargeDialog(self.layerNum+1)
	    end
	    local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("recharge"),33)
	    goItem:setScale(0.7)
	    local goBtn=CCMenu:createWithItem(goItem);
	    goBtn:setTouchPriority(-(self.layerNum-1)*20-3);
	    goBtn:setPosition(bgSp:getContentSize().width * 0.5,bgSp:getContentSize().height * 0.18)
	    bgSp:addChild(goBtn)
	    self.curRechItemTb[i] = goItem

	    if acCzhkVoApi:isOverCurRecharge(i,limitNum) then
	    	self.curRechItemTb[i]:setVisible(false)
	    end

	    -- print("rNum--.>",rNum)
	    if rNum > 1 then
	    	posYTb = rNum == 3 and {0.24,0.5,0.76} or {0.34,0.64}
	    end
	    for k,v in pairs(reward) do
	    	local item = v
			local function callback()
	            local function closeFun() end 
				G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,nil,true)
			end
			local icon,scale=G_getItemIcon(item,85,false,self.layerNum,callback,nil)
			bgSp:addChild(icon)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			icon:setPosition(bgSp:getContentSize().width * posYTb[k], bgSp:getContentSize().height * 0.52)

			local numLb = GetTTFLabel("x" .. FormatNumber(item.num),20)
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

	    local addPosx = G_isAsia() and 0 or 55
	    local addPosy = G_isAsia() and 0 or 5

	    local redSideSp = CCSprite:createWithSpriteFrameName("redSlashPic.png")
	    redSideSp:setPosition(bgSp:getContentSize().width * 0.5 + 3,bgSp:getContentSize().height * 0.78)
	    bgSp:addChild(redSideSp)
	    local limitLb = GetTTFLabel(getlocal("thisDayRechargeStr",{limitNum}),G_isAsia() and 22 or 19)
	    limitLb:setAnchorPoint(ccp(1,0.5))
	    limitLb:setRotation(-5)
	    limitLb:setPosition(redSideSp:getContentSize().width * 0.7 + addPosx,redSideSp:getContentSize().height * 0.69 + addPosy)
	    redSideSp:addChild(limitLb)
	    local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	    goldSp:setAnchorPoint(ccp(0,0.5))
	    -- goldSp:setRotation(5)
	    goldSp:setPosition(redSideSp:getContentSize().width * 0.7 + addPosx + 2,redSideSp:getContentSize().height * 0.69 + 2 + addPosy)
		redSideSp:addChild(goldSp)


		--darkLight
		local darkLightSp = CCSprite:createWithSpriteFrameName("darkLight.png")
	    darkLightSp:setPosition(posxTb2[i], posy + 300)
	    darkLightSp:setScale(2.2)
	    self.bgLayer:addChild(darkLightSp)

	    local girlImg = CCSprite:createWithSpriteFrameName(girlTb[i])
	    girlImg:setScale(girlScaleTb[i])
	    girlImg:setPosition(posxTb2[i], posy + 260)
	    if i == 2 then
	    	girlImg:setAnchorPoint(ccp(0.5,0))
	    	girlImg:setPositionY(posy + 205)
	    end
	    self.bgLayer:addChild(girlImg,1)
	end

end

function acCzhkDialog:tick()
	if self.timeLb then
    	self.timeLb:setString(acCzhkVoApi:getTimer())
    end
    if self.isToday ~= acCzhkVoApi:isToday() then
    	self.isToday = acCzhkVoApi:isToday()
    	self:showCurRecharge(0)
    	for i=1,2 do
    		if  self.curRechItemTb[i] then
    			self.curRechItemTb[i]:setVisible(true)
				self.curRechItemTb[i]:setEnabled(true)
			end
    	end
    end

    local isEnd=acCzhkVoApi:isEnd()
    if isEnd==true then
        self:close()
    end
end

