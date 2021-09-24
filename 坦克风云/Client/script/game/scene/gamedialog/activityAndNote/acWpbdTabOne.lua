acWpbdTabOne={}
function acWpbdTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil

	nc.timeLb    = nil
	nc.isIphone5 = G_isIphone5()
	nc.isTodayFlag = acWpbdVoApi:isToday()
	nc.bgWidth   = 0
	nc.upPosY    = G_VisibleSizeHeight-160
	nc.upHeight  = 222--G_VisibleSizeHeight * 0.15
	nc.multiBgSpTb   = {}
	nc.tankSpTb      = {}
	nc.tankSpMask    = {}
	nc.tankRewardTb  = {}
	nc.showTankPosTb = {}
	nc.beishuTb 	 = {}
	nc.pointPosTb	 = {}
	nc.useBeiShuTb	 = {}
	nc.nowCheckedTb  = {{1,2,3},{4,5,6},{7,8,9},{10,11,12}}
	nc.url 		 = G_downloadUrl("active/".."acWpbdBg.jpg") or nil
	nc.isBegainAction = false
	nc.isBegainPoint  = false
	nc.isBegainChoseT = false

	nc.curGetRewardList = {}
	nc.curGetHxReward   = {}
	nc.curGetRate   = nil
	nc.curGetScore  = nil
	nc.curGetPool	= nil
	nc.ftNum        = nil       
	nc.pointLoopNum = nil
	nc.pointCount   = nil  
	nc.choseTLoopNum = nil
	nc.choseTLoopLNum = nil
    nc.choseTCount   = nil
    nc.curGetRewardId = nil
    nc.nowChecked = nil
    nc.checkBeginInNum = nil
    nc.checkEndInNum   = nil
    nc.isRandomPoint = false
    nc.randomPointUseNum = 1
    nc.isCanSHow = true
    nc.grayBorderSpTb = {}
    nc.tankSpMask2 = {}
	return nc
end
function acWpbdTabOne:dispose( )
	self.tankSpMask2 	= nil
	self.grayBorderSpTb = nil
	self.isCanSHow      = nil
	self.isRandomPoint  = nil
	self.randomPointUseNum  = nil

	self.checkBeginInNum = nil
	self.checkEndInNum   = nil
	self.nowCheckedTb   = nil
	self.nowChecked     = nil
	self.curGetRewardId = nil
	self.choseTLoopLNum = nil
	self.choseTLoopNum  = nil
	self.choseTCount    = nil
	self.ftNum          = nil       
	self.pointLoopNum     = nil
	self.pointCount       = nil  
	self.curGetPool		  = nil
	self.curGetRewardList = nil
	self.curGetHxReward   = nil
	self.curGetRate       = nil
	self.curGetScore      = nil

	self.useBeiShuTb    = nil
	self.isBegainPoint  = nil
	self.isBegainChoseT = nil
	self.isBegainAction = nil
	self.gemsLb         = nil
	self.getAwardMenu   = nil
	self.pointPosTb     = nil
	self.pointNode      = nil
	self.beishuTb       = nil
	self.tankRewardTb   = nil
	self.showTankPosTb  = nil
	self.multiBgSpTb    = nil
	self.tankSpMask     = nil 
	self.tankSpTb       = nil
	self.timeLb         = nil
	self.bgWidth        = nil
	self.upPosY         = nil
	self.upHeight       = nil
	self.tv             = nil
	self.bgWidth        = nil
	self.bgLayer        = nil
	self.parent         = nil
	self.isIphone5      = nil
end
function acWpbdTabOne:tick( )
    local isNotEnd=activityVoApi:isStart(acWpbdVoApi:getAcVo())
	if isNotEnd then
		if self and self.timeLb then
          self.timeLb:setString(acWpbdVoApi:getTimer( ))
        end

        if not self.isBegainAction then
			-- local radNum = math.random(1,6)
			-- if self.pointNode then
			-- 	self.pointNode:setRotation(self.pointPosTb[radNum])
			-- end
		end

        local todayFlag=acWpbdVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            acWpbdVoApi:setFirstFree(0)
            --重置免费次数
            self:refeshStatus()
        end
    else

	end
	
end
function acWpbdTabOne:refeshStatus( )

	acWpbdVoApi:setMultiNum()
	acWpbdVoApi:setNowChecked()
	self.checkSp:setVisible(false)
	self:outerBoxTbShowCall()
	self:showBeishuCall()
	self:showAboutMenu()

	self.btnLb:setVisible(true)
	self.gemsLb:setVisible(false)
	self.gemIcon:setVisible(false)

	self.multiBgSpTb[1]:setVisible(true)
	self.multiBgSpTb[2]:setVisible(false)
	self.bottomTip:setString(getlocal("activity_wpbg_bottomTip1"))
	self.bottomTip:setColor(G_ColorWhite)
end
function acWpbdTabOne:init(layerNum)
	self.layerNum = layerNum
	self.bgLayer  = CCLayer:create()
	self.bgWidth  = self.bgLayer:getContentSize().width-40
	self:initUrl()
	self:addUpNeed()
	self:initMiddle()
	self:addBottomNeed()
	self:showStopActionPanel()
	
	return self.bgLayer
end
function acWpbdTabOne:initUrl( )
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer and icon and self.upPosY then
	        icon:setAnchorPoint(ccp(0.5,1))
	        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
	        icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
	        icon:setScaleY(self.upPosY/icon:getContentSize().height)
	        self.bgLayer:addChild(icon)
	    end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function acWpbdTabOne:addUpNeed( )
	local timeStrSize = G_isAsia() and 28 or 22
	local acLabel     = GetTTFLabel(acWpbdVoApi:getTimer(),22,"Helvetica-bold")
	local subHeight = self.isIphone5 and 45 or 30
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upPosY - subHeight))
    self.bgLayer:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acWpbdVoApi:showTipDia(1,self.layerNum + 1)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setScale(1)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-3)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth - 15,self.upPosY - 15))
    self.bgLayer:addChild(menuDesc,2)
end
function acWpbdTabOne:addBottomNeed( )
	local bottomBgWidth,bottomBgHeight = 276,42
	local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("blackBtnBg.png",CCRect(15,15,2,2),function ()end)
	bottomBg:setContentSize(CCSizeMake(bottomBgWidth,bottomBgHeight))
	bottomBg:setAnchorPoint(ccp(0.5,0))
	bottomBg:setPosition(G_VisibleSizeWidth * 0.5,self.isIphone5 and 50 or 30)
	self.bgLayer:addChild(bottomBg,2)

	local nameStr = {getlocal("normal"),getlocal("daily_lotto_tip_6")}
	local multiBgTb = {"blueAdbBg.png","yellowAdbBg.png"}
	local colorTb = {ccc3(115,202,199),ccc3(216,208,39)}

	local function chooseMultiNumCall(hd,fn,idx)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		if idx == 2 then
			if acWpbdVoApi:getFirstFree() == 0 then
				acWpbdVoApi:warningShow(1)
				do return end
			end
		end
		local colorTb = {G_ColorWhite,G_ColorYellowPro2}
		for i=1,2 do
			if i == idx then
				self.multiBgSpTb[i]:setVisible(true)
				self.bottomTip:setString(getlocal("activity_wpbg_bottomTip"..idx))
				self.bottomTip:setColor(colorTb[i])
			else
				self.multiBgSpTb[i]:setVisible(false)
			end
		end
		self:changeMultiNum(idx)
	end 
	for i=1,2 do
		local bottomSmBg = LuaCCScale9Sprite:createWithSpriteFrameName("blackBtnBg.png",CCRect(15,15,2,2),chooseMultiNumCall)
		bottomSmBg:setContentSize(CCSizeMake(bottomBgWidth * 0.5,bottomBgHeight))
		bottomSmBg:setPosition(ccp(bottomBgWidth * (i==1 and 0.25 or 0.75),bottomBgHeight * 0.5))
		bottomSmBg:setTouchPriority(-(self.layerNum-1)*20-3)
		bottomSmBg:setTag(i)
		bottomSmBg:setOpacity(0)
		bottomBg:addChild(bottomSmBg)

		local multiBgSp = LuaCCSprite:createWithSpriteFrameName(multiBgTb[i],function()end);
		multiBgSp:setPosition(getCenterPoint(bottomSmBg))
		bottomSmBg:addChild(multiBgSp)
		self.multiBgSpTb[i] = multiBgSp

		local multiStr = GetTTFLabel(nameStr[i],G_isAsia() and 26 or 21)
		multiStr:setPosition(getCenterPoint(bottomSmBg))
		multiStr:setColor(colorTb[i])
		bottomSmBg:addChild(multiStr)
		if bottomBgWidth * 0.5 < multiStr:getContentSize().width then
			multiStr:setScale(bottomBgWidth * 0.5 /multiStr:getContentSize().width)
		end
	end

	local addPosY = G_isIphone5() and 60 or 30
	local bottomTipSiz3 = G_isIphone5() and 22 or 18
	local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),function()end)
	tipBg:setContentSize(CCSizeMake(self.bgWidth-40,25))
	tipBg:setOpacity(150)
	tipBg:setPosition(bottomBgWidth * 0.5, bottomBgHeight + addPosY)
	bottomBg:addChild(tipBg,1)

	local bottomTip = GetTTFLabelWrap(getlocal("activity_wpbg_bottomTip1"),bottomTipSiz3,CCSizeMake(self.bgWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	bottomTip:setPosition(bottomBgWidth * 0.5, bottomBgHeight + addPosY)
	bottomBg:addChild(bottomTip,2)
	self.bottomTip = bottomTip

	if not G_isIphone5() then
		local useLb = GetTTFLabel(getlocal("activity_wpbg_bottomTip1"),bottomTipSiz3)
		tipBg:setScaleX(useLb:getContentSize().width/tipBg:getContentSize().width)
	end

	if acWpbdVoApi:getMultiNum() == 1 then
		self.multiBgSpTb[2]:setVisible(false)
	else
		self.multiBgSpTb[1]:setVisible(false)
		self.bottomTip:setString(getlocal("activity_wpbg_bottomTip2"))
		self.bottomTip:setColor(G_ColorYellowPro2)
	end
end
function acWpbdTabOne:outerBoxTbShowCall(showIdx)
	if showIdx then
		for k,v in pairs(self.outerBoxTb) do
			local isSHow = false
			if k == showIdx then
				isSHow =true
			else
				isSHow = false
			end
			v:setVisible(isSHow)
		end
		local maskNumTb = {1,4,7,10}
		for k,v in pairs(self.tankSpMask) do
			if k < maskNumTb[showIdx] or k > maskNumTb[showIdx]+2 then
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
	else
		for k,v in pairs(self.outerBoxTb) do
			v:setVisible(false)
		end
		for k,v in pairs(self.tankSpMask) do
			v:setVisible(false)
		end
	end
end
function acWpbdTabOne:changeMultiNum(idx)
	acWpbdVoApi:setMultiNum(idx)
	self:showBeishuCall()
	local curGems = acWpbdVoApi:getCostGems()
	self.gemsLb:setString(curGems)
end

function acWpbdTabOne:initMiddle()
	--wpbdTurntable
	local middleBg = CCSprite:createWithSpriteFrameName("wpbdTurntable.png");
	middleBg:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY * 0.5 + (self.isIphone5 and 40 or 0))
	self.bgLayer:addChild(middleBg,2)
	self.middleBg = middleBg

	self.checkPosTb = {ccp(161,524),ccp(552,453),ccp(480,58),ccp(87,132)}
	self.outerBoxTb = {}
	local outerBoxPosTb = {ccp(319.5,523),ccp(551.5,293.5),ccp(319.5,60),ccp(87,293)}
	self.showTankPosTb  = {ccp(236,522.5),ccp(332,522.5),ccp(428,522.5),ccp(552,375.5),ccp(552,279.5),ccp(552,183.5),ccp(404,60.5),ccp(308,60.5),ccp(212,60.5),ccp(87,207.5),ccp(87,303.5),ccp(87,399.5)}

	local function checkCall(hd,fn,idx)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local nowChecked = acWpbdVoApi:getNowChecked()
        if acWpbdVoApi:getFirstFree() == 0 then
			acWpbdVoApi:warningShow(1)
			do return end
		end
        if nowChecked == nil or nowChecked ~= idx then
        	self.checkSp:setPosition(self.checkPosTb[idx])
        	self.checkSp:setVisible(true)
        	self:outerBoxTbShowCall(idx)

        	acWpbdVoApi:setNowChecked(idx)
        	for i=1,4 do
				if i ~= nowChecked then
					self.grayBorderSpTb[i]:setVisible(true)
				end
			end
        elseif nowChecked and nowChecked == idx then
        	self.checkSp:setVisible(false)
        	self:outerBoxTbShowCall()

        	acWpbdVoApi:setNowChecked()
			for i=1,4 do
				self.grayBorderSpTb[i]:setVisible(false)
			end
        end
        local curGems = acWpbdVoApi:getCostGems()
        self.gemsLb:setString(curGems)
	end
	for i=1,4 do
		local checkBg = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkCall)
		checkBg:setScale(0.85)
		checkBg:setTag(i)
		checkBg:setTouchPriority(-(self.layerNum-1)*20-3)
		checkBg:setPosition(self.checkPosTb[i])
		middleBg:addChild(checkBg)

		local graySp = GraySprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
		graySp:setPosition(getCenterPoint(checkBg))
		checkBg:addChild(graySp)
		self.grayBorderSpTb[i] = graySp
		-- self.grayBorderSpTb[i]:setVisible(false)

		local outerBox = LuaCCScale9Sprite:createWithSpriteFrameName("unColorBorder3.png",CCRect(62,62,1,1),function()end)
		outerBox:setContentSize(CCSizeMake(366,104))
		outerBox:setPosition(outerBoxPosTb[i])
		middleBg:addChild(outerBox)
		self.outerBoxTb[i] = outerBox
		if i%2 == 0 then
			self.outerBoxTb[i]:setRotation(90)
		end
	end
	self.checkSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	self.checkSp:setScale(0.85)
	middleBg:addChild(self.checkSp)

	
	self:showBeishuCall()
	self:showTankCall()
	self:initPoint()
	self:showAwardBtn()
	self:showLogBtn()

	local nowChecked = acWpbdVoApi:getNowChecked()
	if nowChecked then
		self.checkSp:setPosition(self.checkPosTb[nowChecked])
		self:outerBoxTbShowCall(nowChecked)
		for i=1,4 do
			if i ~= nowChecked then
				self.grayBorderSpTb[i]:setVisible(true)
			end
		end
	else
		for i=1,4 do
			self.grayBorderSpTb[i]:setVisible(false)
		end
		self.checkSp:setVisible(false)
		self:outerBoxTbShowCall()
	end
end

function acWpbdTabOne:showBeishuCall()
	local useBeiShuTb   = acWpbdVoApi:getBeiShuTb()
	self.useBeiShuTb = useBeiShuTb
	if SizeOfTable(self.beishuTb) == 0 then
		local beishuPosTb = {ccp(318.5,407),ccp(427,346),ccp(427,234),ccp(317.5,178),ccp(210.5,234),ccp(211,346)}
		for i=1,6 do
			local bsStr = GetTTFLabel(getlocal("rateAddNum",{useBeiShuTb[i]}),22)
			bsStr:setPosition(beishuPosTb[i])
			self.beishuTb[i] = bsStr
			self.middleBg:addChild(bsStr)
		end
	else
		for k,v in pairs(self.beishuTb) do
			self.beishuTb[k]:setString(getlocal("rateAddNum",{useBeiShuTb[k]}))

			local sca1 = CCScaleTo:create(0.3,1.5)
			local sca2 = CCScaleTo:create(0.2,1)
			local seq=CCSequence:createWithTwoActions(sca1,sca2)
			self.beishuTb[k]:runAction(seq)
		end
	end
end
function acWpbdTabOne:showTankCall(isAddAction)
	local borderColorTb = {["5.5"]="greenBorder.png",["6.5"]="blueBorder.png",["7.5"]="purpleBorder.png"}
	self.tankRewardTb = acWpbdVoApi:getRewardTb()

	if SizeOfTable(self.tankSpTb) > 0 then
		for k,v in pairs(self.tankSpTb) do
			v:removeFromParentAndCleanup(true)
		end
		self.tankSpTb = {}
	end
	for k,v in pairs(self.tankRewardTb) do
		local lbNameFontSize,nameSubPosY,desSize2,strPosx = 22,30,18,95
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,16,16
        end
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,v,nil,nil,nil,nil,true)
            return false
        end
        local icon,scale=G_getItemIcon(v,100,true,self.layerNum+1,showNewPropInfo)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-3)
        icon:setPosition(self.showTankPosTb[k])
        self.middleBg:addChild(icon)
        icon:setScale(80/icon:getContentSize().width)
        self.tankSpTb[k] = icon 

        local itemW=icon:getContentSize().width*scale
        local numLb=GetTTFLabel("x"..v.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(icon:getContentSize().width-5,5)
        numLb:setScale(1/icon:getScale())
        icon:addChild(numLb,1)

        local pic = borderColorTb[tostring(tankCfg[v.id].tankLevel)]
        local borderSp = CCSprite:createWithSpriteFrameName(pic)
        borderSp:setPosition(getCenterPoint(icon))
        icon:addChild(borderSp)
	end
	if SizeOfTable(self.tankSpMask) == 0 then
		for k,v in pairs(self.tankRewardTb) do
			local tankSpMask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	        tankSpMask:setContentSize(CCSizeMake(80,80))
	        tankSpMask:setPosition(self.showTankPosTb[k])
	        self.middleBg:addChild(tankSpMask,2)
	        self.tankSpMask[k] = tankSpMask
	        tankSpMask:setVisible(false)

	        local tankSpMask2 = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")--
	        tankSpMask2:setPosition(self.showTankPosTb[k])
	        tankSpMask2:setScale(0.7)
	        self.middleBg:addChild(tankSpMask2,2)
	        self.tankSpMask2[k] = tankSpMask2
	        tankSpMask2:setVisible(false)
		end
	end
	if not self.choseSp then
		self.choseSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
		self.choseSp:setPosition(self.showTankPosTb[1])
		self.middleBg:addChild(self.choseSp,2)
		self.choseSp:setVisible(false)
	end
end
function acWpbdTabOne:initPoint( )
	self.pointPosTb = {300,240,180,120,60,0}
	self.pointNode = CCNode:create()
	self.pointNode:setPosition(getCenterPoint(self.middleBg))
	self.middleBg:addChild(self.pointNode)
	self.pointNode:setVisible(false)

	local pointIcon = CCSprite:createWithSpriteFrameName("lightBluePoint.png")
	pointIcon:setPosition(-3,73)
	self.pointNode:addChild(pointIcon)
end
function acWpbdTabOne:showAwardBtn( )
	local middleBgWidth,middleBgHeight = self.middleBg:getContentSize().width,self.middleBg:getContentSize().height
	local function getAwardCall( )
        print "get Award~~~~~~~~~~~~~~"
        local needGems,multiNum,nowChecked = acWpbdVoApi:getCostGems()
		self.nowChecked = nowChecked > 0 and nowChecked or nil
		local isFree    = acWpbdVoApi:getFirstFree() == 0 and 1 or 0-- 1免费，0 不是
		needGems        = isFree == 1 and 0 or needGems

        local function realLottery(num,check,free)
        	local function callback(rewardlist,hxReward,getRate,getScore,rewardId,getPool)
        		if needGems and tonumber(needGems)>0 then
	                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(needGems))
	            end
	            if rewardlist and type(rewardlist)=="table" then
	                self.stopPanelSp:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
	                print("运行 动画~~~~~~~~")
	                self.randomPointUseNum = math.random(1,2)
	                -- print("self.randomPointUseNum=====>>>>",self.randomPointUseNum)
	                if self.randomPointUseNum == 1 then
	                	self.isRandomPoint =true
	                else
	                	self.isRandomPoint =false
	                end
	                self.curGetRewardList = rewardlist
	                self.curGetHxReward   = hxReward
	                self.curGetRate		  = getRate
	                self.curGetScore	  = getScore
	                self.curGetRewardId   = rewardId
	                -- self.curGetPool    = getPool

	                self.pointLoopNum = 0
	                self.pointCount = 0
	                self.pointNode:setRotation(0)
	                self.pointNode:setVisible(true)

	                if not self.nowChecked then
		                self.choseTLoopNum = 1
		                self.choseTCount   = 0
		                self.choseSp:setPosition(self.showTankPosTb[1])
		                self.tankSpMask[1]:setVisible(false)
		                self.choseSp:setVisible(true)

		                for i=2,SizeOfTable(self.tankSpMask) do
		                	self.tankSpMask[i]:setVisible(true)
		                end
		            else
		            	local choseInNum = self.nowCheckedTb[self.nowChecked][1]

		            	self.choseTLoopNum = choseInNum
		                self.choseTCount   = 0
		                self.choseSp:setPosition(self.showTankPosTb[choseInNum])
		                self.choseSp:setVisible(true)

		                self.checkBeginInNum = choseInNum
		                self.checkEndInNum   = choseInNum + 2
		            end

	                self.ftNum = 0--跑帧的时效
	                self.isBegainPoint  = true
	                self.isBegainChoseT = true
	                self.isBegainAction = true
	                self.isEndingPoint  = true
	            end
	            
        	end
        	local free = acWpbdVoApi:getFirstFree() == 0 and 1 or 0
        	acWpbdVoApi:acWpbdAwardRequest("reward",{num = num,check = check ,free = free},callback)
        end

        if playerVoApi:getGems()<needGems then
	        GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+2,needGems)
	        do return end
	    else
	    	local function sureClick()
	            realLottery(multiNum,nowChecked,isFree)
	        end
	        local function secondTipFunc(sbFlag)
	            local keyName=acWpbdVoApi:getActiveName()
	            local sValue=base.serverTime .. "_" .. sbFlag
	            G_changePopFlag(keyName,sValue)
	        end
	        if needGems and needGems>0 then
	            local keyName=acWpbdVoApi:getActiveName()
	            local modeStr = acWpbdVoApi:getMultiNum( ) == 1 and getlocal("normal") or getlocal("daily_lotto_tip_6")
	            local nowChecked = acWpbdVoApi:getNowChecked()
	            local sTipStr = getlocal("activity_wpbd_second",{needGems,modeStr}) 
	            if nowChecked and nowChecked > 0 then
	            	local typeTb = {getlocal("help4_t1_t1"),getlocal("help4_t1_t2"),getlocal("help4_t1_t3"),getlocal("help4_t1_t4")}
	            	sTipStr = getlocal("activity_wpbd_second2",{needGems,modeStr,typeTb[nowChecked]}) 
	            end
	            if G_isPopBoard(keyName) then
	                self.secondDialog=G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),sTipStr,true,sureClick,secondTipFunc)
	            else
	                sureClick()
	            end
	        else
	            sureClick()
	        end
	    end
    end
    local btnScale,priority = 1,-(self.layerNum-1)*20-3
    local getAwardBtn,getAwardMenu = G_createBotton(self.middleBg,ccp(middleBgWidth * 0.5,middleBgHeight * 0.5),{getlocal("daily_lotto_tip_2"),24},"blueButton.png","blueButton2.png","blueButton2.png",getAwardCall,btnScale,priority)
    self.getAwardMenu = getAwardMenu
    self.btnLb = tolua.cast(getAwardBtn:getChildByTag(101),"CCLabelTTF")

    local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    gemIcon:setPosition(middleBgWidth * 0.5-5,middleBgHeight * 0.5)
    gemIcon:setScale(0.85)
    gemIcon:setAnchorPoint(ccp(1,0.5))
    self.middleBg:addChild(gemIcon,2)
    self.gemIcon = gemIcon
    local curGems = acWpbdVoApi:getCostGems()
    local gemsLb = GetTTFLabel(curGems,22,"Helvetica-bold")
    gemsLb:setAnchorPoint(ccp(0,0.5))
    gemsLb:setPosition(middleBgWidth * 0.5 - 10,middleBgHeight * 0.5)
    self.middleBg:addChild(gemsLb,2)
    self.gemsLb = gemsLb

    self:showAboutMenu()
end

function acWpbdTabOne:fastTick( )

	if self.isBegainAction then
		self.ftNum = self.ftNum + 1

		if self.isBegainPoint then
			if self.pointCount < 24 then
				if self.ftNum % 5 == 0 then
					self.pointCount = self.pointCount + 1
					self.pointLoopNum = self.pointLoopNum + 1 > 6 and 1 or self.pointLoopNum + 1
					self.pointNode:setRotation(self.pointPosTb[self.pointLoopNum])
				end
			else
				if self.ftNum % 8 == 0 then
					self.pointCount = self.pointCount + 1
					self.pointLoopNum = self.pointLoopNum + 1 > 6 and 1 or self.pointLoopNum + 1
					self.pointNode:setRotation(self.pointPosTb[self.pointLoopNum])
					
					if self.curGetRate == self.useBeiShuTb[7 - self.pointLoopNum] then
						if self.isRandomPoint then
							self.isRandomPoint = false
						else
							self.isBegainPoint = false
							self.isEndingPoint = false
							self.beishuTb[7 - self.pointLoopNum]:setColor(G_ColorYellowPro2)
							self.beishuTb[7 - self.pointLoopNum]:setScale(1.3)
						end
					end	
				end
				
			end
		end

		if self.isBegainChoseT then
			if not self.nowChecked then
				if self.choseTCount < 12 then
					if self.ftNum %5 == 0 then
						self.choseTCount = self.choseTCount + 1
						self.choseTLoopLNum = self.choseTLoopNum 
						self.choseTLoopNum = self.choseTLoopNum + 1 > 12 and 1 or self.choseTLoopNum + 1
						self.choseSp:setPosition(self.showTankPosTb[self.choseTLoopNum])
						self.tankSpMask[self.choseTLoopNum]:setVisible(false)
						self.tankSpMask[self.choseTLoopLNum]:setVisible(true)
					end
				else
					if self.ftNum %8 == 0 then
						self.choseTCount = self.choseTCount + 1
						self.choseTLoopLNum = self.choseTLoopNum
						self.choseTLoopNum = self.choseTLoopNum + 1 > 12 and 1 or self.choseTLoopNum + 1
						self.choseSp:setPosition(self.showTankPosTb[self.choseTLoopNum])
						self.tankSpMask[self.choseTLoopNum]:setVisible(false)
						self.tankSpMask[self.choseTLoopLNum]:setVisible(true)
					end
					if self.curGetRewardId == self.tankRewardTb[self.choseTLoopNum].id then
						self.isBegainChoseT = false
					end
				end
			else
				if self.choseTCount < 10 then
					if self.ftNum %5 == 0 then
						self.choseTCount = self.choseTCount + 1
						self.choseTLoopNum = self.choseTLoopNum + 1 > self.checkEndInNum and self.checkBeginInNum or self.choseTLoopNum + 1
						self.choseSp:setPosition(self.showTankPosTb[self.choseTLoopNum])
					end
				else
					if self.ftNum %8 == 0 then
						self.choseTCount = self.choseTCount + 1
						self.choseTLoopNum = self.choseTLoopNum + 1 > self.checkEndInNum and self.checkBeginInNum or self.choseTLoopNum + 1
						self.choseSp:setPosition(self.showTankPosTb[self.choseTLoopNum])
					end
					if self.curGetRewardId == self.tankRewardTb[self.choseTLoopNum].id then
						self.isBegainChoseT = false
					end
				end
			end
		end

		if self.isBegainPoint == false and self.isBegainChoseT == false then
			if self.ftNum %60 == 0 then
				self.isBegainAction = false
				self.pointNode:setVisible(false)
				self.choseSp:setVisible(false)
				self.tankSpMask[self.choseTLoopNum]:setVisible(false)

				self:showAddCall()
				self.stopPanelSp:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
			end
		end
	end
end

function acWpbdTabOne:showStopActionPanel( )
	
	local function StopActionCall()
		if self.isCanSHow and self.isBegainAction == true then
			self.isCanSHow = false

			self.isBegainPoint  = false
			self.isBegainChoseT = false
			self.isBegainAction = false
			
			
			if self.curGetRewardId then
				for i=1,12 do
					if self.curGetRewardId == self.tankRewardTb[i].id then
						self.choseSp:setPosition(self.showTankPosTb[i])
						if not self.nowChecked then
							local choseTLoopLNum = i + 1 > 12 and 1 or i + 1
							self.tankSpMask[i]:setVisible(false)
							self.tankSpMask[choseTLoopLNum]:setVisible(true)
							if self.choseTLoopNum and self.choseTLoopNum ~=i then
								self.tankSpMask[self.choseTLoopNum]:setVisible(true)
							end
						end
						do break end
					end
				end
			end

			if self.curGetRate and self.isEndingPoint then
				for i=1,6 do
					if self.curGetRate == self.useBeiShuTb[7 - i] then
						self.beishuTb[7 - i]:setColor(G_ColorYellowPro2)
						self.beishuTb[7 - i]:setScale(1.3)
						self.pointNode:setRotation(self.pointPosTb[i])
						do break end
					end
				end
			end

			local function awardPanelShowCall()
				self.pointNode:setVisible(false)
				self.choseSp:setVisible(false)
				self:showAddCall()
				self.stopPanelSp:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
				self.isCanSHow = true
			end
			local deT = CCDelayTime:create(1)
			local ffunc=CCCallFuncN:create(awardPanelShowCall)
	        local fseq=CCSequence:createWithTwoActions(deT,ffunc)
	        self.stopPanelSp:runAction(fseq)
	    end
	end
	self.tDialogHeight = 80
	self.stopPanelSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),StopActionCall);
	self.stopPanelSp:setTouchPriority(-(self.layerNum-1)*20-99)
	self.stopPanelSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))--G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
	self.stopPanelSp:setOpacity(0)
	self.stopPanelSp:setIsSallow(true) -- 点击事件透下去
	self.stopPanelSp:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
	self.bgLayer:addChild(self.stopPanelSp,99)
end

function acWpbdTabOne:showAddCall( )--显示奖励，给自己添加奖励，刷新坦克展示，清楚得到奖励的相关数据
	self.isBegainAction = false
	local showAwardTip = G_clone(self.curGetRewardList)

	local function showClose()

		G_showRewardTip(showAwardTip,true)
		self.isTodayFlag = acWpbdVoApi:isToday()
		self:showAboutMenu()

		if not self.nowChecked then
			for i=1,SizeOfTable(self.tankSpMask) do
				self.tankSpMask[i]:setVisible(false)
			end
		end
		for k,v in pairs(self.beishuTb) do
			v:setColor(G_ColorWhite)
			v:setScale(1)
		end
		self:showChangeTankAction()
		self:showTankCall(true)

	    self.curGetRate		  = nil
	    self.curGetScore	  = nil
	end

	acWpbdVoApi:showRewardSmallPanel(self.layerNum,self.curGetRewardList,self.curGetRate,self.curGetScore,showClose)
end
function acWpbdTabOne:showChangeTankAction( )
	for i=1,12 do
		self.tankSpMask2[i]:setVisible(true)
          local pzArr=CCArray:create()
		  for kk=1,20 do
		      local nameStr="bgFire_"..kk..".png"
		      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		      pzArr:addObject(frame)
		  end
		  local animation=CCAnimation:createWithSpriteFrames(pzArr)
		  animation:setDelayPerUnit(0.05)
		  local animate=CCAnimate:create(animation)
	      self.tankSpMask2[i]:runAction(animate)

		    local function animationVisCall( )
	    		self.tankSpMask2[i]:setVisible(false)
		    end 
		    local visCall2 = CCCallFunc:create(animationVisCall)
		    local delayTime2 = CCDelayTime:create(1)
		    local arr = CCArray:create()
		    arr:addObject(delayTime2)
		    arr:addObject(visCall2)
		    local seq = CCSequence:create(arr)
		    self.tankSpMask[i]:runAction(seq)
	end
end
function acWpbdTabOne:showAboutMenu( )
    if self == nil or self.gemsLb == nil then
        return
    end

	if acWpbdVoApi:getFirstFree() == 1 then
    	self.btnLb:setVisible(false)
    	self.gemsLb:setVisible(true)
    	self.gemIcon:setVisible(true)
    else
    	self.gemsLb:setVisible(false)
    	self.gemIcon:setVisible(false)
    end
end

function acWpbdTabOne:showLogBtn( )
	
	local function logHandler()
		print "logHandler~~~~~~~~~~~~~~~~~"
        local function showLog(isHasLog)
	        local rewardLog=acWpbdVoApi:getRewardLog() or {}	        
	        if isHasLog or (rewardLog and SizeOfTable(rewardLog)>0) then
	            local logList={}
	            for k,v in pairs(rewardLog) do
	                local num,reward,time=v.num,v.reward,v.time
	                local scoreNum = acWpbdVoApi:getAwardScore(num)
	                local rate = acWpbdVoApi:getCurRateInLog(reward[2]) 
	                local titleLb = num == 1 and getlocal("activity_wpbd_logTip1",{rate,scoreNum}) or getlocal("activity_wpbd_logTip2",{rate,scoreNum})
	                local title = {titleLb}

	                local content={{reward}}
	                local log={title=title,content=content,ts=time}
	                table.insert(logList,log)
	            end
	            local logNum=SizeOfTable(logList)
	            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
	            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",
	            								CCSizeMake(550,G_VisibleSizeHeight-300),
	            								CCRect(130, 50, 1, 1),
	            								{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},
	            								logList,false,self.layerNum+1,nil,true,10,true,true)
	        else
	            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
	        end
	    end
	    local rewardLog=acWpbdVoApi:getRewardLog()
	    if rewardLog and SizeOfTable(rewardLog) > 0 then
	        showLog(true)
	    else
	        acWpbdVoApi:acWpbdAwardRequest("getlog",{},showLog)
	    end

        
    end
   
    local btnScale,priority = 0.8,-(self.layerNum-1)*20-3
    local logBtn,logMenu = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth - 20,50),nil,"bless_record.png","bless_record.png","bless_record.png",logHandler,btnScale,priority,nil,nil,ccp(1,0))


    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width * 0.5,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local strSize4 = G_isAsia() and 22 or 20
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize4,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)
end