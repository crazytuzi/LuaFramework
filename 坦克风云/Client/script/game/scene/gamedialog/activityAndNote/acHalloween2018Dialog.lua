--2018万圣节活动不给糖果就捣蛋
--author: Du Wei
acHalloween2018Dialog=commonDialog:new()

function acHalloween2018Dialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.upHeight  = G_VisibleSizeHeight - 82
	nc.isTodayFlag = true
	nc.awardBoxLbTb = {}
	nc.awardBoxBgAcTb = {}
	nc.awardBoxHadLbBgTb = {}
	nc.use4Posy = 0
	nc.use2Posy = 0
	nc.rewardDataTb = {}
	nc.rewardTb = {}
	nc.curRewardlist = {}
	nc.curPt         = {}
	nc.curPoint      = 0
	nc.curHxReward   = {}
	nc.rewardPos = 2
	nc.rewardOldPos = acHalloween2018VoApi:getoldRewardPos()
	nc.awardBoxTb = {}
	nc.awardBoxAcTb = {}
	nc.isIphone5 = G_isIphone5()
	return nc
end
function acHalloween2018Dialog:dispose()
	self.bottomAcSp1 = nil
	self.bottomAcSp2 = nil
	self.bottomAcSp3 = nil
	self.awardBoxAcTb = nil
	self.awardBoxTb = nil
	self.rewardPos = nil
	self.rewardDataTb = nil
	self.rewardTb = nil
	self.use2Posy = nil
	self.use4Posy = nil
	self.isTodayFlag = nil
	self.awardBoxLbTb = nil
	self.awardBoxBgAcTb = nil
	self.awardBoxHadLbBgTb = nil

	self.curRewardlist = nil
	self.curPt         = nil
	self.curPoint      = nil
	self.curHxReward   = nil

	spriteController:removePlist("public/acHalloween2018Image.plist")--trackingImage
    spriteController:removeTexture("public/acHalloween2018Image.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/redFlicker.plist")
    spriteController:removeTexture("public/redFlicker.png")
	spriteController:removePlist("public/packsImage.plist")
	spriteController:removeTexture("public/packsImage.plist")
end
function acHalloween2018Dialog:initTableView()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acHalloween2018Image.plist")
    spriteController:addTexture("public/acHalloween2018Image.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/redFlicker.plist")
    spriteController:addTexture("public/redFlicker.png")
	spriteController:addPlist("public/packsImage.plist")
	spriteController:addTexture("public/packsImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self:initBackground()
	-- self:initExtraReward()
	self:initRewardShow()
	self:initLottery()

	local function touchDialog()
		print("touchDialog~~~~now~~~~~~")
		if self.isStop then
			do return end
		end
		self:shwoGetReward()
	end
	self.tDialogHeight = 80
	self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
	self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
	self.touchDialog:setOpacity(0)
	self.touchDialog:setIsSallow(true) -- 点击事件透下去
	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
	self.bgLayer:addChild(self.touchDialog,99)

	local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgBottom.png", CCRect(34, 32, 2, 6), function ()end)
    bottomBg:setAnchorPoint(ccp(0.5, 0))
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bottomBg:getContentSize().height))
    bottomBg:setPosition(G_VisibleSizeWidth / 2, 0)
    self.bgLayer:addChild(bottomBg, 13)
end

function acHalloween2018Dialog:initBackground()
	local function onLoadBackground(fn,sprite)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCNode"))then
			sprite:setAnchorPoint(ccp(0,1))
			sprite:setPosition(0,G_VisibleSizeHeight - 82)
			self.bgLayer:addChild(sprite)
		end
	end
	local url = ""
	local version=acHalloween2018VoApi:getVersion()
	if tonumber(version)==2 then
		url = G_downloadUrl("active/acHalloween2018_ver2.jpg")
	else
		url = G_downloadUrl("active/acHalloween2018.jpg")
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local webImage=LuaCCWebImage:createWithURL(url,onLoadBackground)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    -- timeBg:setOpacity(150)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upHeight)
    self.bgLayer:addChild(timeBg,10)

	local vo=acHalloween2018VoApi:getAcVo()
	local timeStr=acHalloween2018VoApi:getTimer()
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
        acHalloween2018VoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(timeBg:getContentSize().width - 10,timeBg:getContentSize().height - 10))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	timeBg:addChild(infoBtn,3)

	self:showBoard()
end

function acHalloween2018Dialog:tick()
	if self.timeLb then
    	self.timeLb:setString(acHalloween2018VoApi:getTimer())
    end
    local isEnd=acHalloween2018VoApi:isEnd()
    if isEnd==false then
        local todayFlag=acHalloween2018VoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            acHalloween2018VoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
    end
end

function acHalloween2018Dialog:showBoard()
	local version=acHalloween2018VoApi:getVersion()
	local needHeight,clipperHeight = 50,340
	if G_getIphoneType() == G_iphone4 then
		needHeight,clipperHeight = 110,280
	end
	local clipperSize = CCSizeMake(350,clipperHeight)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, self.upHeight * 0.5 - needHeight)
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    clipper:setInverted(true)
    self.bgLayer:addChild(clipper,2)

    if version~=2 then
		local middleBorder = LuaCCScale9Sprite:createWithSpriteFrameName("acWsjBrownBorder.png",CCRect(15,15,1,1),function() end)
	    middleBorder:setContentSize(CCSizeMake(350,clipperHeight + 8))
	    middleBorder:setPosition(clipper:getPositionX(),clipper:getPositionY())
	    self.bgLayer:addChild(middleBorder,3)
    end
    
    local boardBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
    self.boardBg = boardBg
    boardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.upHeight))
    boardBg:setPosition(clipper:getContentSize().width * 0.5,clipper:getContentSize().height * 0.5 + needHeight)
    boardBg:setAnchorPoint(ccp(0.5,0.5));
    clipper:addChild(boardBg)
    boardBg:setOpacity(0)

    local startY=self.upHeight - 35
    local shortRope2Posy = 0
    local tipPosy = 0
	for i=1,4 do
		local board=CCSprite:createWithSpriteFrameName("acWsjBoard.png")
		board:setAnchorPoint(ccp(0.5,1))
		board:setPosition(G_VisibleSizeWidth/2,startY)
		board:setScaleY(1.25)
		boardBg:addChild(board)
		startY=startY - board:getContentSize().height * 1.25 * 0.86
		if i == 1 then
			shortRope2Posy = startY
			self:initExtraReward(board)
		elseif i == 2 then
			self.use2Posy = startY
		elseif i == 3 then
			self.use4Posy = startY
		elseif i == 4 then
			tipPosy = startY
		end
		if version==2 then
			board:setOpacity(0)
		end
	end
	if version~=2 then
		local ropePosxTb = { G_VisibleSizeWidth * 0.5 - 250 , G_VisibleSizeWidth * 0.5 + 250 }
		for i=1,2 do
			local rope1 = CCSprite:createWithSpriteFrameName("acWsjRope2.png")
			rope1:setAnchorPoint(ccp(0.5,1))
			rope1:setPosition(ropePosxTb[i],self.upHeight)
			boardBg:addChild(rope1,2)

			local rope2 = CCSprite:createWithSpriteFrameName("acWsjRope1.png")
			rope2:setAnchorPoint(ccp(0.5,1))
			rope2:setPosition(ropePosxTb[i],shortRope2Posy + 15)
			boardBg:addChild(rope2,2)
		end
	end
	local hxReward=acHalloween2018VoApi:getHexieReward()
	local strSize2 = G_isAsia() and 21 or 18
	local kCCTextPosx = kCCTextAlignmentLeft
	if G_getIphoneType() == G_iphone4 then
		strSize2 = strSize2 - 2
		kCCTextPosx = kCCTextAlignmentCenter
	end
	local bgWidth = 500
	local tipLb = GetTTFLabel(getlocal("activity_jsss_hexiePro",{hxReward.name}),strSize2,"Helvetica-bold")
	local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),function ()end)
	tipBg:setAnchorPoint(ccp(0.5,1))
	tipBg:setOpacity(100)
	if tipLb:getContentSize().width > bgWidth then
		tipBg:setContentSize(CCSizeMake(bgWidth,50))
		tipBg:setPosition(G_VisibleSizeWidth *0.5 - 40,tipPosy -20)
		tipLb = nil
	else
		tipBg:setContentSize(CCSizeMake(bgWidth,30))
		tipBg:setPosition(G_VisibleSizeWidth *0.5 - 40,tipPosy -25)
	end
	
	
	if not tipLb then
		tipLb = GetTTFLabelWrap(getlocal("activity_jsss_hexiePro",{hxReward.name}),strSize2,CCSizeMake(bgWidth - 8,0),kCCTextPosx,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		tipLb:setAnchorPoint(ccp(0,0.5))
		tipLb:setPosition(4,tipBg:getContentSize().height * 0.5)
	else
		tipLb:setAnchorPoint(ccp(0.5,0.5))
		tipLb:setPosition(getCenterPoint(tipBg))
	end
	tipLb:setColor(G_ColorYellowPro2)
	tipBg:addChild(tipLb)
	boardBg:addChild(tipBg,3)

	if G_getIphoneType() == G_iphone4 then
		tipBg:setPosition(G_VisibleSizeWidth * 0.5,shortRope2Posy)
	end

	self:showLogBtn(boardBg,tipPosy -20)
	self:showMiddle()
end

function acHalloween2018Dialog:addPumpkinSpAction(pumpkinSp)
		
	local bottomAcSp1 = CCSprite:createWithSpriteFrameName("acWsjPumpkinF_1.png")
	local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE
	bottomAcSp1:setBlendFunc(blendFunc)

	bottomAcSp1:setPosition(getCenterPoint(pumpkinSp))
	pumpkinSp:addChild(bottomAcSp1)
	self.bottomAcSp1 = bottomAcSp1
	self.bottomAcSp1:setVisible(false)
	local fadeIn=CCFadeIn:create(0.8)
    local fadeOut=CCFadeOut:create(0.8)
    local arr=CCArray:create()
    arr:addObject(fadeIn)
    arr:addObject(fadeOut)
    local seq = CCSequence:create(arr)
    local repeatForever=CCRepeatForever:create(seq)
    bottomAcSp1:runAction(repeatForever)

    local bottomAcSp2 = CCSprite:createWithSpriteFrameName("acWsjPumpkinF_2.png")
    local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE
	bottomAcSp2:setBlendFunc(blendFunc)
	bottomAcSp2:setPosition(getCenterPoint(pumpkinSp))
	pumpkinSp:addChild(bottomAcSp2)
	self.bottomAcSp2 = bottomAcSp2
	self.bottomAcSp2:setVisible(false)
	local fadeIn=CCFadeOut:create(0.8)
    local fadeOut=CCFadeIn:create(0.8)
    local arr=CCArray:create()
    arr:addObject(fadeIn)
    arr:addObject(fadeOut)
    local seq = CCSequence:create(arr)
    local repeatForever=CCRepeatForever:create(seq)
    bottomAcSp2:runAction(repeatForever)

    local bottomAcSp3 = CCSprite:createWithSpriteFrameName("acWsjPumpkinF_3.png")
    local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE
	bottomAcSp3:setBlendFunc(blendFunc)
	bottomAcSp3:setPosition(getCenterPoint(pumpkinSp))
	pumpkinSp:addChild(bottomAcSp3)
	self.bottomAcSp3 = bottomAcSp3
	self.bottomAcSp3:setVisible(false)
	local fadeIn=CCFadeOut:create(0.8)
    local fadeOut=CCFadeIn:create(0.8)
    local arr=CCArray:create()
    arr:addObject(fadeIn)
    arr:addObject(fadeOut)
    local seq = CCSequence:create(arr)
    local repeatForever=CCRepeatForever:create(seq)
    bottomAcSp3:runAction(repeatForever)

    self:refreshFaceAction()
end

function acHalloween2018Dialog:refreshFaceAction( )
	local nodata,pNum= acHalloween2018VoApi:getPercentScorePic()
	print("pNum===222>>>",pNum)
	if pNum >0 then

		self.bottomAcSp1:setVisible(true)
		if pNum == 3 then
			self.bottomAcSp2:setVisible(true)
			self.bottomAcSp3:setVisible(false)
		elseif pNum == 4 then
			self.bottomAcSp2:setVisible(false)
			self.bottomAcSp3:setVisible(true)
		end
	else
		self.bottomAcSp1:setVisible(false)
		self.bottomAcSp2:setVisible(false)
		self.bottomAcSp3:setVisible(false)
	end
	local curRecharge,topRecharge,isLock = acHalloween2018VoApi:getRechargeData( )
	if self.lockBg and self.lockBg2 then
		if isLock == false then
			self.lockBg:setVisible(false)
			self.lockSp:setVisible(false)
			self.lockBg2:setVisible(true)
			self.lockSp2:setVisible(true)
		else
			self.lockBg:setVisible(true)
			self.lockSp:setVisible(true)
			self.lockBg2:setVisible(false)
			self.lockSp2:setVisible(false)
		end
	end
end

function acHalloween2018Dialog:showMiddle()--acWsjPumpkinBg
	local pumpkinBg = CCSprite:createWithSpriteFrameName("acWsjPumpkinBg.png")
	pumpkinBg:setAnchorPoint(ccp(0.5,0))
	pumpkinBg:setPosition(G_VisibleSizeWidth *0.5,self.use4Posy-50)
	self.bgLayer:addChild(pumpkinBg,3)

	------:initWithSpriteFrameName("LegionCheckBtnUn.png")
	local usePic = acHalloween2018VoApi:getPercentScorePic()
	local sweetPic = usePic or "acWsjSweet1.png"
	local sweetSp = CCSprite:createWithSpriteFrameName(sweetPic)
	sweetSp:setPosition(getCenterPoint(pumpkinBg))
	pumpkinBg:addChild(sweetSp,2)
	if not usePic then
		sweetSp:setVisible(false)
	end
	self.sweetSp =sweetSp

	local pumpkinSp = CCSprite:createWithSpriteFrameName("acWsjPumpkinFace.png")
	pumpkinSp:setPosition(getCenterPoint(pumpkinBg))
	pumpkinBg:addChild(pumpkinSp,3)
	self.pumpkinSp = pumpkinSp

	local version=acHalloween2018VoApi:getVersion()
	if version==2 then
		pumpkinBg:setVisible(false)
	else
		self:addPumpkinSpAction(pumpkinSp)
	end

	local sweetLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("newblackFade.png",CCRect(29, 0, 2, 1),function ()end)
    sweetLbBg:setOpacity(150)
    sweetLbBg:setAnchorPoint(ccp(0.5,1))
    sweetLbBg:setContentSize(CCSizeMake(370,100))
    sweetLbBg:setPosition(G_VisibleSizeWidth *0.5-5,self.use2Posy + 52)
    self.bgLayer:addChild(sweetLbBg,3)

    -- local hxReward=acHalloween2018VoApi:getHexieReward()--activity_wsj2018_desc --"activity_jsss_hexiePro",{hxReward.name}
    local adaSize = G_isAsia() and 20 or 17
    if G_getCurChoseLanguage() == "ko" then
    	adaSize = 16
    end
    local descStr,sweetStr = "",""
    if version==1 then
    	descStr=getlocal("activity_wsj2018_desc")
    	sweetStr=getlocal("curSweet")
    elseif version==2 then
    	descStr=getlocal("activity_wsj2018_ver2_desc")
    	sweetStr=getlocal("curSweet_ver2")
    end
    local promptLb=GetTTFLabelWrap(descStr,adaSize,CCSize(sweetLbBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    local curSweetStr = GetTTFLabel(sweetStr,20,"Helvetica-bold")
    local realHeight = promptLb:getContentSize().height+curSweetStr:getContentSize().height+10
    if realHeight>sweetLbBg:getContentSize().height then
    	sweetLbBg:setContentSize(CCSizeMake(370,realHeight))
    end
    promptLb:setAnchorPoint(ccp(0.5,1))
    promptLb:setColor(G_ColorYellowPro2)
    promptLb:setPosition(sweetLbBg:getContentSize().width *0.5 + 5,sweetLbBg:getContentSize().height - 5)
    sweetLbBg:addChild(promptLb)

    curSweetStr:setAnchorPoint(ccp(0,0))
    sweetLbBg:addChild(curSweetStr)
    local realWidth = curSweetStr:getContentSize().width
    local curScore,topScore = acHalloween2018VoApi:getScore( )
    local curNumStr = GetTTFLabel(curScore.."/"..topScore,20,"Helvetica-bold")
	realWidth=realWidth+curNumStr:getContentSize().width+5
    curSweetStr:setPosition(sweetLbBg:getContentSize().width * 0.5-realWidth/2,5)

    local numLbPosX = curSweetStr:getPositionX()+curSweetStr:getContentSize().width
    if version==1 then
		local sweetPic = CCSprite:createWithSpriteFrameName("sweet_2.png")
	    sweetPic:setAnchorPoint(ccp(0,0))
	    sweetPic:setScale(0.5)
	    sweetPic:setPosition(numLbPosX+3,curSweetStr:getPositionY() - 10)
	    sweetLbBg:addChild(sweetPic)
	    realWidth = realWidth+sweetPic:getContentSize().width*sweetPic:getScale()+3
	    numLbPosX = sweetPic:getPositionX() + sweetPic:getContentSize().width*sweetPic:getScale()
    end
    curNumStr:setAnchorPoint(ccp(0,0))
    curNumStr:setPosition(numLbPosX,curSweetStr:getPositionY())
    sweetLbBg:addChild(curNumStr)
    self.curNumStr = curNumStr
end

function acHalloween2018Dialog:getGiftAward(idx)
	if G_checkClickEnable()==false then
        do return end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)

    local function awardBoxRefreshCallBack( )
    	self:refreshAwardBoxTbShow()
    end

    acHalloween2018VoApi:acHalloween2018SmallDialog(idx,self.layerNum+1,awardBoxRefreshCallBack)
end

function acHalloween2018Dialog:initExtraReward(boardBg)
	local version = acHalloween2018VoApi:getVersion()
	local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("acWsjBrownBottomFrame.png",CCRect(16,16,1,1),function() end)
	upBg:setContentSize(CCSizeMake(300,34))
	upBg:setAnchorPoint(ccp(0.5,1))
	upBg:setPosition(boardBg:getContentSize().width *0.5,boardBg:getContentSize().height - 35)
	boardBg:addChild(upBg)
	upBg:setScaleY(1/1.25)
	if version==2 then
		upBg:setOpacity(0)
	end

	local upLb = GetTTFLabel(getlocal("activity_mineExploreG_otherReward"),24,"Helvetica-bold")
	upLb:setPosition(getCenterPoint(upBg))
	upLb:setColor(G_ColorYellowPro2)
	upBg:addChild(upLb)
	if upLb:getContentSize().width > (upBg:getContentSize().width - 4) then
		upLb:setScale((upBg:getContentSize().width - 4)/upLb:getContentSize().width)
	end

	for i=1,4 do
		local function giftHandeler( )
			self:getGiftAward(i)
		end 
		local awardBox = LuaCCSprite:createWithSpriteFrameName("packs"..(i+2)..".png",giftHandeler)
		awardBox:setTouchPriority(-(self.layerNum-1)*20-3)
		awardBox:setAnchorPoint(ccp(0.5,0))
		awardBox:setPosition(boardBg:getContentSize().width * ((i-1)*0.2+0.21),50)
		boardBg:addChild(awardBox,3)
		awardBox:setScaleY(1/1.25)
		self.awardBoxTb[i] = awardBox
		self.awardBoxAcTb[i] = false
		self:addAwardBoxBgAction(awardBox,boardBg,i)

		local curNum,canNum = acHalloween2018VoApi:getUseNum(i)
		local awardBoxLb = GetTTFLabel(curNum.."/"..canNum,24)
		awardBoxLb:setPosition(awardBox:getPositionX()-5,awardBox:getPositionY() + 5)
		awardBoxLb:setAnchorPoint(ccp(0.5,1))
		boardBg:addChild(awardBoxLb,3)
		awardBoxLb:setScaleY(1/1.25)
		self.awardBoxLbTb[i] = awardBoxLb
		if curNum >= canNum then
			self.awardBoxLbTb[i]:setColor(G_ColorGreen)
			if acHalloween2018VoApi:getedAwardBoxTb(i) then
				self.awardBoxHadLbBgTb[i]:setVisible(true)
			else
				self.awardBoxBgAcTb[i]:setVisible(true)
				self.awardBoxAcTb[i] =true
				self:awardBoxAction( awardBox,self.awardBoxAcTb[i] )
			end
		else
			self.awardBoxLbTb[i]:setColor(G_ColorRed)
		end
	end
end

function acHalloween2018Dialog:refreshAwardBoxTbShow()
	for i=1,4 do
		local curNum,canNum = acHalloween2018VoApi:getUseNum(i)
		self.awardBoxLbTb[i]:setString(curNum.."/"..canNum)
		if curNum >= canNum then
			self.awardBoxLbTb[i]:setColor(G_ColorGreen)
			if acHalloween2018VoApi:getedAwardBoxTb(i) then
				self.awardBoxHadLbBgTb[i]:setVisible(true)
				self.awardBoxBgAcTb[i]:setVisible(false)
				self.awardBoxAcTb[i] =false
				self:awardBoxAction( self.awardBoxTb[i],self.awardBoxAcTb[i] )
			else
				self.awardBoxHadLbBgTb[i]:setVisible(false)
				self.awardBoxBgAcTb[i]:setVisible(true)

				if not self.awardBoxAcTb[i] then
					self.awardBoxAcTb[i] =true
					self:awardBoxAction( self.awardBoxTb[i],self.awardBoxAcTb[i] )
				end
			end
		else
			self.awardBoxHadLbBgTb[i]:setVisible(false)
			self.awardBoxBgAcTb[i]:setVisible(false)
			self.awardBoxLbTb[i]:setColor(G_ColorRed)
		end
	end
	if self.curNumStr then
		local curScore,topScore = acHalloween2018VoApi:getScore( )
		self.curNumStr:setString(curScore.."/"..topScore)
		local version = acHalloween2018VoApi:getVersion()
		if version~=2 then
			local usePic = acHalloween2018VoApi:getPercentScorePic()
			if usePic and self.sweetSp then
				-- self.sweetSp:initWithSpriteFrameName(usePic)
				local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(usePic)
				tolua.cast(self.sweetSp,"CCSprite"):setDisplayFrame(frame)
				self.sweetSp:setVisible(true)
			elseif self.sweetSp then
				self.sweetSp:setVisible(false)
			end

			self:refreshFaceAction()
		end
	end
end

function acHalloween2018Dialog:awardBoxAction( awardBox,isAction )
	if isAction then
		local time = 0.14
        local rotate1=CCRotateTo:create(time, 20)
        local rotate2=CCRotateTo:create(time, -20)
        local rotate3=CCRotateTo:create(time, 10)
        local rotate4=CCRotateTo:create(time, -10)
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
        awardBox:runAction(repeatForever)
	else
		awardBox:stopAllActions()
		awardBox:setRotation(0)
	end
end

function acHalloween2018Dialog:addAwardBoxBgAction(awardBox,boardBg,idx)
	
	local rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    rewardCenterBtnBg:setOpacity(0)
    rewardCenterBtnBg:setAnchorPoint(ccp(0.5,0.5))
    boardBg:addChild(rewardCenterBtnBg,1)
    rewardCenterBtnBg:setPosition(awardBox:getPositionX()-5,awardBox:getPositionY() + awardBox:getContentSize().height *0.4)
    rewardCenterBtnBg:setScaleY(1/1.25)
    rewardCenterBtnBg:setScale(0.6)
    self.awardBoxBgAcTb[idx] = rewardCenterBtnBg
    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
      realLight:setAnchorPoint(ccp(0.5,0.5))
      realLight:setScale(1.4)
      realLight:setPosition(getCenterPoint(rewardCenterBtnBg))
      rewardCenterBtnBg:addChild(realLight)  
      local roteSize = i ==1 and 360 or -360
      local rotate1=CCRotateBy:create(4, roteSize)
      local repeatForever = CCRepeatForever:create(rotate1)
      realLight:runAction(repeatForever)
    end
    rewardCenterBtnBg:setVisible(false)

    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    lbBg:setOpacity(200)
    lbBg:setContentSize(CCSizeMake(80,25))
    lbBg:setPosition(awardBox:getContentSize().width * 0.5 -5,awardBox:getContentSize().height *0.5)
    awardBox:addChild(lbBg,4)
    lbBg:setScale(0.9)
    local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),20)
    hasRewardLb:setPosition(getCenterPoint(lbBg))
    lbBg:addChild(hasRewardLb,5)
    self.awardBoxHadLbBgTb[idx] = lbBg
    self.awardBoxHadLbBgTb[idx]:setVisible(false)
end

function acHalloween2018Dialog:showLogBtn(boardBg,logBtnPosy)
	
	local function logHandler()
		print "logHandler~~~~~~~~~~~~~~~~~"
        local function showLog()
        	local version = acHalloween2018VoApi:getVersion()
	        local rewardLog=acHalloween2018VoApi:getRewardLog() or {}
	        if rewardLog and SizeOfTable(rewardLog)>0 then
	            local logList={}
	            for k,v in pairs(rewardLog) do
	                local num,reward,time,point=v.num,v.reward,v.time,v.point
	                local title = ""
	                if version==2 then
	                	title={getlocal("sweetAdd2_ver"..version,{num,point})}
	                else
	                	title={getlocal("sweetAdd2",{num,point})}
	                end
	                local content={{reward}}
	                local log={title=title,content=content,ts=time}
	                table.insert(logList,log)
	            end
	            local logNum=SizeOfTable(logList)
	            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
	            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
	        else
	            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
	        end
	    end
	    local rewardLog=acHalloween2018VoApi:getRewardLog()
	    if rewardLog then
	        showLog()
	    else
	        acHalloween2018VoApi:acHalloween2018Request("active.wsj2018.getlog",{},showLog)
	    end
    end
   
    local btnScale,priority = 0.8,-(self.layerNum-1)*20-3
    local logBtn,logMenu = G_createBotton(boardBg,ccp(G_VisibleSizeWidth - 20,logBtnPosy),nil,"bless_record.png","bless_record.png","bless_record.png",logHandler,btnScale,priority,nil,nil,ccp(1,1))


    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setOpacity(100)
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width * 0.5,15))
    logBg:setScale(1/logBtn:getScale())
    if G_getIphoneType() == G_iphone4 then
    	logBtn:setPositionY(logBtnPosy + 140)
    	logBtn:setScale(0.7)

    end
    logBtn:addChild(logBg)
    local strSize4 = G_isAsia() and 22 or 18
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize4,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)
end

---------------------- 抽奖按钮 ----------------------
function acHalloween2018Dialog:initLottery( )

	local cost1,cost2=acHalloween2018VoApi:getLotteryCost()
	local btnPosY = self.isIphone5 and 50 or 40
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acHalloween2018VoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth/2+120,btnPosY),multiLotteryHandler,cost2,true)
    self:refreshLotteryBtn()
    self:tick()
end
function acHalloween2018Dialog:getLotteryBtn(num,pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=""
        if base.hexieMode==1 then
            btnStr=getlocal("activity_qxtw_buy",{num})
        else
            btnStr=getlocal("activity_customLottery_common_btn",{num})
        end
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+8)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acHalloween2018Dialog:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        if acHalloween2018VoApi:isEnd() ==false then
             local freeFlag=acHalloween2018VoApi:isFreeLottery()
             print("freeFlag------>",freeFlag)
            if freeFlag==1 then
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)
            end
        else
        	self.lotteryBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
            self.lotteryBtn:setVisible(true)
            self.freeBtn:setVisible(false)
            self.multiLotteryBtn:setEnabled(false)
        end
    end
end

function acHalloween2018Dialog:shwoGetReward( )
	self.beginAction = false
	self.isStop = true
	self:refreshLotteryBtn()
    self:refreshAwardBoxTbShow()

    -- print("self.rewardPos===>>>",self.rewardPos)
    self.acFlicker:setPosition(self.rewardTb[self.rewardPos]:getPositionX(),self.rewardTb[self.rewardPos]:getPositionY())
    self.rewardOldPos = self.rewardPos

    local function delayCall( )
			self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
		    local function showEndHandler()
		        G_showRewardTip(self.curRewardlist,true)
		    end
		    local lbkey = "sweetAdd"
		    local version = acHalloween2018VoApi:getVersion()
		    if version==2 then
				lbkey = "sweetAdd_ver"..version
		    end
		    local addStrTb
		    if self.curPt and SizeOfTable(self.curPt)>0 then
		        addStrTb={}
		        for k,v in pairs(self.curPt) do
		            local addStr=""
		            table.insert(addStrTb,getlocal(lbkey,{v or 0}))
		        end
		    end
		    if self.curHxReward then
		        table.insert(self.curRewardlist,1,self.curHxReward)
		        table.insert(addStrTb,1,"")
		    end
		    local titleStr=getlocal("activity_wheelFortune4_reward")
		    local titleStr2=getlocal("activity_tccx_total_score")..getlocal(lbkey,{self.curPoint})
		    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
		    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,self.curRewardlist,showEndHandler,titleStr,
		    	titleStr2,addStrTb,nil,"haloween2")
	end
	local delayT = CCDelayTime:create(1)
	local delayCalll = CCCallFuncN:create(delayCall)
	local arr = CCArray:create()
	arr:addObject(delayT)
	arr:addObject(delayCalll)
	local seq = CCSequence:create(arr)
	self.acFlicker:runAction(seq)


end

function acHalloween2018Dialog:fastTick( )
	if self.beginAction then
		self.ftNum = self.ftNum + 1

		if self.pointCount < 14 then
			if self.ftNum % 6 == 0 then
				self.pointCount = self.pointCount + 1
				
				self.acFlicker:setPosition(self.rewardTb[self.rewardOldPos]:getPositionX(),self.rewardTb[self.rewardOldPos]:getPositionY())
				self.rewardOldPos = self.rewardOldPos+1 > 14 and 1 or (self.rewardOldPos + 1)
			end
		else
			if self.ftNum % 10 == 0 then
				self.pointCount = self.pointCount + 1

				if self.rewardOldPos == self.rewardPos then
					self.beginAction = false
					self:shwoGetReward()
				else
					self.acFlicker:setPosition(self.rewardTb[self.rewardOldPos]:getPositionX(),self.rewardTb[self.rewardOldPos]:getPositionY())
					self.rewardOldPos = self.rewardOldPos+1 > 14 and 1 or (self.rewardOldPos + 1)
				end
			end
		end
	end
end
function acHalloween2018Dialog:showActionLayer(callback)
	self.beginAction = true
end

function acHalloween2018Dialog:lotteryHandler(multiFlag)
	self.curRewardlist = {}
	self.curPt         = 0
	self.curPoint      = {}
	self.curHxReward   = {}
	self.isStop = false
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        local function callback(pt,point,rewardlist,hxReward,rewardPos)
        	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
			self.curRewardlist = rewardlist
			self.curPt         = pt
			self.curPoint      = point
			self.curHxReward   = hxReward
			self.rewardPos	   = rewardPos

			self.ftNum = 0
			self.pointCount = 0
            if rewardlist and type(rewardlist)=="table" then
                local function realShow()
                	if self.isStop then
                		do return end
                	end
                	self:shwoGetReward()

                end
                self:showActionLayer(realShow)---加自己的动画
            end
            
        end
        local freeFlag=acHalloween2018VoApi:isFreeLottery()
        local useF = freeFlag == 1 and 0 or 1
        -- print("num----free----->",num,freeFlag)
        acHalloween2018VoApi:acHalloween2018Request("active.wsj2018.draw",{num=num,free=useF},callback)
    end

    local cost1,cost2=acHalloween2018VoApi:getLotteryCost()
    local cost,num=0,1
    if acHalloween2018VoApi:isToday()==false then
        acHalloween2018VoApi:resetFreeLottery()
    end
    local freeFlag=acHalloween2018VoApi:isFreeLottery()
    if cost1 and cost2 then
        if multiFlag==false and freeFlag==0 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acHalloween2018VoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        local function sureClick()
        	-- print("cost---sureClick-->",cost)
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acHalloween2018VoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acHalloween2018VoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end

function acHalloween2018Dialog:initRewardShow( )
	self.rewardDataTb = acHalloween2018VoApi:getRewardTb( )
	local G_w,G_h = G_VisibleSizeWidth,G_VisibleSizeHeight
	local basePosx,baseNum = 0.14,0.18
	local posxTb = {basePosx * G_w, (basePosx + baseNum) * G_w, (basePosx + baseNum*2) * G_w, (basePosx + baseNum*3) * G_w, (basePosx + baseNum*4) * G_w, (basePosx + baseNum*4) * G_w, (basePosx + baseNum*4) * G_w, (basePosx + baseNum*4) * G_w, (basePosx + baseNum*3) * G_w, (basePosx + baseNum*2) * G_w, (basePosx + baseNum) * G_w, basePosx * G_w, basePosx * G_w, basePosx * G_w,}

	local baPosy1 = 110
	local bsPosy2 = 50
	local bsPosy3 = 50
	if G_getIphoneType() == G_iphone4 then
		bsPosy2,bsPosy3 = 40,40
	end
	local posyTb = {self.use2Posy + baPosy1, self.use2Posy + baPosy1, self.use2Posy + baPosy1, self.use2Posy + baPosy1, self.use2Posy + baPosy1, self.use2Posy - bsPosy2, self.use2Posy - bsPosy2 * 2 - bsPosy3 * 2, self.use2Posy - bsPosy2 * 3 - bsPosy3 * 4, self.use2Posy - bsPosy2 * 3 - bsPosy3 * 4, self.use2Posy - bsPosy2 * 3 - bsPosy3 * 4, self.use2Posy - bsPosy2 * 3 - bsPosy3 * 4, self.use2Posy - bsPosy2 * 3 - bsPosy3 * 4, self.use2Posy - bsPosy2 * 2 - bsPosy3 * 2, self.use2Posy - bsPosy2, }

	local flickerTb = acHalloween2018VoApi:getFlickTb( )
	for i=1, SizeOfTable(self.rewardDataTb) do--acHalloween2018VoApi:specicalMarkShow(icon,key)

		local item = self.rewardDataTb[i]
		local function callback()
			local function closeFun( )
			end  
			if item.clockItemId then
				local curRecharge,topRecharge,isLock = acHalloween2018VoApi:getRechargeData( )

				local sureStr = isLock and getlocal("recharge") or getlocal("unlockNow")
				local refStr = getlocal("deblocking_conditionWithRecharge",{curRecharge > topRecharge and topRecharge or curRecharge,topRecharge})
				local refStrColor = isLock and G_ColorRed or G_ColorYellowPro2
				local specialUse = {wsj2018={[1]=refStr,[2]=isLock,[3]=refStrColor},hasAni=false,useBgSp=2,useBgSpSize={},useSureOrCancleBtn=6,sureBtnStr=sureStr,cancleBtnStr=""}
				G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,specialUse,true)
			else
				G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,nil,true)
			end
		end
		local icon,scale=G_getItemIcon(item,85,false,self.layerNum,callback,nil)
		self.bgLayer:addChild(icon,3)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(posxTb[i],posyTb[i])
		self.rewardTb[i] = icon

		if flickerTb[tostring(i)] then
			acHalloween2018VoApi:specicalMarkShow(icon,i)
		end

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb,1)
		numLb:setPosition(icon:getContentSize().width-5, 5)
		numLb:setScale(1/scale)
		local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg)

		if item.clockItemId then
			local curRecharge,topRecharge,isLock = acHalloween2018VoApi:getRechargeData( )
			local lockBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
			lockBg:setContentSize(CCSizeMake(icon:getContentSize().width - 4, icon:getContentSize().height - 4))
			lockBg:setPosition(getCenterPoint(icon))
			lockBg:setOpacity(200)
			icon:addChild(lockBg)
			self.lockBg = lockBg

			local lockSp=CCSprite:createWithSpriteFrameName("aitroops_lock.png")
			lockSp:setAnchorPoint(ccp(1,1))
			icon:addChild(lockSp,2)
			lockSp:setPosition(icon:getContentSize().width - 5, icon:getContentSize().height - 3)
			lockSp:setScale(0.5)
			self.lockSp = lockSp
			if not isLock then
				self.lockBg:setVisible(false)
				lockSp:setVisible(false)
			end
		elseif i == 8 then
			local lockBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
			lockBg2:setContentSize(CCSizeMake(icon:getContentSize().width - 4, icon:getContentSize().height - 4))
			lockBg2:setPosition(getCenterPoint(icon))
			lockBg2:setOpacity(200)
			icon:addChild(lockBg2)
			lockBg2:setVisible(false)
			self.lockBg2 = lockBg2

			local lockSp2=CCSprite:createWithSpriteFrameName("aitroops_lock.png")
			lockSp2:setAnchorPoint(ccp(1,1))
			icon:addChild(lockSp2,2)
			lockSp2:setPosition(icon:getContentSize().width - 5, icon:getContentSize().height - 3)
			lockSp2:setScale(0.5)
			lockSp2:setVisible(false)
			self.lockSp2 = lockSp2
			local curRecharge,topRecharge,isLock = acHalloween2018VoApi:getRechargeData( )
			if not isLock then
				self.lockBg2:setVisible(true)
				self.lockSp2:setVisible(true)
			end
		end
	end

	self.acFlicker = LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
	self.acFlicker:setContentSize(CCSizeMake(95,95))
	self.bgLayer:addChild(self.acFlicker,5)
	self.acFlicker:setPosition(self.rewardTb[self.rewardPos]:getPositionX(),self.rewardTb[self.rewardPos]:getPositionY())
end