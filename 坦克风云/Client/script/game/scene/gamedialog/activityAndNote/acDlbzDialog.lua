acDlbzDialog=commonDialog:new()

function acDlbzDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.upHeight   = G_VisibleSizeHeight - 82
	nc.isIphone5  = G_isIphone5()
	nc.freeBtn    = nil
	nc.lotteryBtn = nil
	nc.curHxReward = {}
	nc.curRewardlist = {}
	nc.rewardTb = {}
	nc.getRewardTb = {}
	nc.getRewardSpTb = {}
	nc.poolPosTb = {}
	nc.isBegin = false
	nc.rewardOldPos = 0
	nc.specIdxTb = {[1]=1,[6]=6,[13]=13,[18]=18}
	return nc
end

function acDlbzDialog:dispose()
    if self.circelAc and self.circelAc.stop then
        self.circelAc:stop()
        self.circelAc = nil
    end
	self.awardTipBg = nil
	self.getAwardTip = nil
	self.specIdxTb = nil
	self.rewardOldPos = nil
	self.isBegin = nil
	self.poolPosTb = nil
	self.getRewardTb = nil
	self.getRewardSpTb = nil
	self.rewardTb = nil
	self.costLb = nil
	self.nowNumLb = nil
	self.curRewardlist = nil
	self.curHxReward   = nil
	self.upHeight      = nil
	self.isIphone5     = nil
	self.freeBtn       = nil
	self.lotteryBtn    = nil
	self.curPoolReward = nil
	self.addBigAward   = nil
	spriteController:removeTexture("public/acThfb.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removePlist("public/xsjx.plist")
    spriteController:removeTexture("public/xsjx.png")
    spriteController:removePlist("public/acDlbzImage.plist")
    spriteController:removeTexture("public/acDlbzImage.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/redFlicker.plist")
    spriteController:removeTexture("public/redFlicker.png")
end

-- function acDlbzDialog:doUserHandler()
-- end
function acDlbzDialog:initTableView(  )
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acydcz_images.plist")
    spriteController:addTexture("public/acydcz_images.png")
	spriteController:addPlist("public/acDlbzImage.plist")
    spriteController:addTexture("public/acDlbzImage.png")
	spriteController:addTexture("public/acThfb.png")
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addPlist("public/xsjx.plist")
    spriteController:addTexture("public/xsjx.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/redFlicker.plist")
    spriteController:addTexture("public/redFlicker.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self:initBackground()
	self:initLottery()

	self:initPoolAward()

	local function touchDialog()
		print("touchDialog~~~~now~~~~~~",self.isStop)
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
end

function acDlbzDialog:getBgOfTabPosY(tabIndex)
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
function acDlbzDialog:initBackground( )
	local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 82))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 82)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)

    local bgImage = CCSprite:createWithSpriteFrameName("acDlbg_panelBg.jpg")
    bgImage:setAnchorPoint(ccp(0.5, 1))
    bgImage:setPosition(G_VisibleSizeWidth * 0.5, self:getBgOfTabPosY(self.selectedTabIndex) + 100)
    clipper:addChild(bgImage)
	-- local function onLoadBackground(fn,webImage)
	-- 	if self and clipper and tolua.cast(clipper, "CCNode") then
 --            webImage:setAnchorPoint(ccp(0.5, 1))
 --            webImage:setPosition(G_VisibleSizeWidth * 0.5, self:getBgOfTabPosY(self.selectedTabIndex) + 80)
 --            clipper:addChild(webImage)
 --        end
 --        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	--     CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- end
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
 --    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	-- local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acDlbg_panelBg.jpg"),onLoadBackground)
	
	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    -- timeBg:setOpacity(150)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upHeight)
    self.bgLayer:addChild(timeBg,10)

	local vo=acDlbzVoApi:getAcVo()
	local timeStr=acDlbzVoApi:getTimer()
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
        acDlbzVoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(timeBg:getContentSize().width - 10,timeBg:getContentSize().height - 10))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	timeBg:addChild(infoBtn,3)

	local addPosY,subPosy = 125,190
	if G_getIphoneType() == G_iphone4 then
		addPosY = 130
		subPosy = 175
	end
	local strSize5 = G_isAsia() and 19 or 16
	local allNums , bName,bNum = acDlbzVoApi:getTipData()
	local photoUpLb = G_getRichTextLabel(getlocal("activity_dlbz_mUpTip", {allNums,bNum,bName}), {G_ColorWhite,G_ColorYellowPro2}, strSize5, 330, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)--GetTTFLabelWrap(getlocal("activity_dlbz_mUpTip",{allNums,bNum,bName}),23,CCSizeMake(330,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	-- photoUpLb:setColor(G_ColorYellowPro2)
	photoUpLb:setAnchorPoint(ccp(0.5,1))
	photoUpLb:setPosition(G_VisibleSizeWidth * 0.5 + 20,G_VisibleSizeHeight * 0.5 + addPosY - 3)
	self.bgLayer:addChild(photoUpLb,2)

	local photoUpBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    photoUpBg:setAnchorPoint(ccp(0.5,1))
    photoUpBg:setOpacity(100)
    photoUpBg:setContentSize(CCSizeMake(330,photoUpLb:getContentSize().height + 6))
    photoUpBg:setPosition(G_VisibleSizeWidth * 0.5 + 20,G_VisibleSizeHeight * 0.5 + addPosY)
    self.bgLayer:addChild(photoUpBg,1)

    photoUpLb:setRotation(7)
    photoUpBg:setRotation(7)

    local lastNum,roundNum = acDlbzVoApi:getLastNum( )
    local nowNumLb = GetTTFLabel(getlocal("activity_dlbz_nowNum",{lastNum}),strSize5)--,true)
    nowNumLb:setAnchorPoint(ccp(1,0.5))
    nowNumLb:setPosition(G_VisibleSizeWidth *0.5 + 140, G_VisibleSizeHeight * 0.5 - subPosy - 62)
    nowNumLb:setRotation(7)
    self.bgLayer:addChild(nowNumLb)
    self.nowNumLb = nowNumLb

    -- self:addAwardShowBtn()
    self:addExtraAwardBtn()
end

function acDlbzDialog:addAwardShowBtn()
    acDlbzVoApi:getCurExtraRewardToShow()
	local function openToShow(  )
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        print "==== openToShow ===="

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
		local descStr = getlocal("activity_dlbz_see_desc")
	    local titleStr = getlocal("activity_dlbz_see")
	    local awardNums = acDlbzVoApi:getExtraRewardTbNums()
	    local needTb = {"dlbzSee",titleStr,descStr,awardNums}
	    local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
	    sd:init()
	end 
 	local showBtn=GetButtonItem("acDlbzRewardIcon1.png","acDlbzRewardIcon2.png","acDlbzRewardIcon1.png",openToShow)
 	local showMenu=CCMenu:createWithItem(showBtn)
 	G_addRectFlicker(showBtn,showBtn:getContentSize().width / 80, showBtn:getContentSize().height / 80)
    showMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    showMenu:setPosition(G_VisibleSizeWidth * 0.5 - 100,G_VisibleSizeHeight * 0.5 + 15)
    self.bgLayer:addChild(showMenu)
end

function acDlbzDialog:addExtraAwardBtn()
    local showExtraAward,isChange,needNum = acDlbzVoApi:getCurExtraRewardToShow()
    if self.extraAwardBtn and isChange then
        if self.circelAc and self.circelAc.stop then
            self.circelAc:stop()
            self.circelAc = nil
        end
        self.extraLb = nil
        self.extraAwardBtn:removeFromParentAndCleanup(true)
        self.extraAwardBtn = nil
    elseif self.extraAwardBtn or not showExtraAward then
        if self.extraLb then
            local extraStr = (needNum and needNum > 0) and getlocal("activity_dlbz_snatchCanget",{needNum}) or getlocal("activity_vipAction_had")
            self.extraLb:setString(extraStr)
        end
        do return end
    end
    local function openToShow(  )
        PlayEffect(audioCfg.mouseClick)
        print "==== openToShow ===="

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local descStr = getlocal("activity_dlbz_see_desc")
        local titleStr = getlocal("activity_dlbz_see")
        local awardNums = acDlbzVoApi:getExtraRewardTbNums()
        local needTb = {"dlbzSee",titleStr,descStr,awardNums}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
    end 

    local icon,scale = G_getItemIcon(showExtraAward,90,false,self.layerNum,openToShow,nil)
    icon:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(icon)
    icon:setPosition(G_VisibleSizeWidth * 0.5 - 100,G_VisibleSizeHeight * 0.5 + 15)
    G_addRectFlicker(icon,icon:getContentSize().width / 80, icon:getContentSize().height / 80)
    icon:setRotation(8)
    self.extraAwardBtn = icon

    local numLb = GetTTFLabel("x" .. FormatNumber(showExtraAward.num),20)
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

    local addLbSize = G_isAsia() and 0 or 6
    local extraStr = (needNum and needNum > 0) and getlocal("activity_dlbz_snatchCanget",{needNum}) or getlocal("activity_vipAction_had")
    local extraLb = GetTTFLabel(extraStr,G_isAsia() and 21 or 19)
    extraLb:setAnchorPoint(ccp(0.5,1))
    if extraLb:getContentSize().width > 88 + addLbSize then
        extraLb:setScale((88 + addLbSize) /extraLb:getContentSize().width)
    end
    extraLb:setPosition(47,-1)
    icon:addChild(extraLb,1)
    self.extraLb = extraLb
    local extraLbBg = CCSprite:createWithSpriteFrameName("BlackBg.png")
    extraLbBg:setAnchorPoint(ccp(0.5,1))
    extraLbBg:setOpacity(150)
    extraLbBg:setScaleX((92 + addLbSize) /extraLbBg:getContentSize().width)
    extraLbBg:setScaleY( (extraLb:getContentSize().height + 2) /extraLbBg:getContentSize().height )
    extraLbBg:setPosition(47,1)
    icon:addChild(extraLbBg)

    local magnifierNode = CCNode:create()
    magnifierNode:setScale(0.35)
    magnifierNode:setAnchorPoint(ccp(0.5, 0.5))
    icon:addChild(magnifierNode)
    magnifierNode:setPosition(70,70)

    local circelCenter = getCenterPoint(magnifierNode)
    local radius, rt, rtimes = 5, 2, 2
    local magnifierSp = CCSprite:createWithSpriteFrameName("ydcz_magnifier.png")
    magnifierSp:setPosition(circelCenter)
    magnifierNode:addChild(magnifierSp)
    
    local acArr = CCArray:create()
    local moveTo = CCMoveTo:create(0.5, ccp(magnifierNode:getContentSize().width / 2, radius))
    local function rotateBy()
        G_requireLua("componet/CircleBy")
        self.circelAc = CircleBy:create(magnifierSp, rt, circelCenter, radius, rtimes)
    end
    local function removeRotateBy()
        if self.circelAc and self.circelAc.stop then
            self.circelAc:stop()
        end
    end
    local moveTo2 = CCMoveTo:create(0.5, ccp(magnifierNode:getContentSize().width / 2, magnifierNode:getContentSize().height / 2))
    local delay = CCDelayTime:create(1)
    acArr:addObject(moveTo)
    acArr:addObject(CCCallFunc:create(rotateBy))
    acArr:addObject(CCDelayTime:create(rt))
    acArr:addObject(CCCallFunc:create(removeRotateBy))
    acArr:addObject(moveTo2)
    acArr:addObject(delay)
    local seq = CCSequence:create(acArr)
    magnifierSp:runAction(CCRepeatForever:create(seq))

end

function acDlbzDialog:initLottery( )

	local cost=acDlbzVoApi:getLotteryCost()
	local btnPosY = G_getIphoneType() == G_iphone4 and 175 or 225
    local function lotteryHandler()
        self:lotteryHandler()
    end
    local pos = ccp(G_VisibleSizeWidth * 0.5,btnPosY)
    self.freeBtn=self:getLotteryBtn(1,pos,lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,pos,lotteryHandler,cost)

    local tipAddPosy = G_getIphoneType() == G_iphone4 and 4 or 0

    local getAwardTip = GetTTFLabelWrap(getlocal("activity_dlbz_getAwardTip"),G_isAsia() and 21 or 17,CCSizeMake(410,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)--,"Helvetica-bold")
    getAwardTip:setAnchorPoint(ccp(0.5,1))
    getAwardTip:setColor(G_ColorYellowPro2)
    getAwardTip:setPosition(pos.x,pos.y - self.lotteryBtn:getContentSize().height * 0.5 + tipAddPosy)
    self.bgLayer:addChild(getAwardTip,1)
    self.getAwardTip = getAwardTip

    local awardTipBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
    awardTipBg:setAnchorPoint(ccp(0.5,1))
    awardTipBg:setScaleX(370/awardTipBg:getContentSize().width)
    awardTipBg:setScaleY((getAwardTip:getContentSize().height + 4)/awardTipBg:getContentSize().height)
    awardTipBg:setPosition(pos.x - 5,pos.y - self.lotteryBtn:getContentSize().height * 0.5 + 4 + tipAddPosy)
    awardTipBg:setOpacity(120)
    self.bgLayer:addChild(awardTipBg)
    self.awardTipBg = awardTipBg
    -- self:refreshLotteryBtn()

    local logPosy = G_getIphoneType() == G_iphone4 and -40 or 10
    self:showLogBtn(self.bgLayer,btnPosY + 45,(self.freeBtn:getContentSize().width + G_VisibleSizeWidth) * 0.5 +50)
end
function acDlbzDialog:getLotteryBtn(num,pos,callback,cost)
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
    if cost then

        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,getlocal("snatchOneNums",{num}),btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),26)--,true)
        costLb:setAnchorPoint(ccp(1,0.5))
        -- costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        self.costLb = costLb
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        self.costIcon = costSp
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width * 0.5 + 5, lotteryBtn:getContentSize().height+costLb:getContentSize().height * 0.5 + 8)
        costSp:setPosition(lotteryBtn:getContentSize().width * 0.5 + 15,costLb:getPositionY())
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
function acDlbzDialog:showActionLayer(callback)
	self.isBegin = true
end
function acDlbzDialog:lotteryHandler()
	self.curRewardlist = {}
	self.curPt         = 0
	self.curPoint      = {}
	self.curHxReward   = {}
	self.curPoolReward ,self.addBigAward = {},{}
	self.isStop = false
    local function realLottery(num,cost)
        local function callback(rewardlist,hxReward,rewardPos,curPoolReward,addBigAward)
        	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
			self.curRewardlist = rewardlist
			self.curHxReward   = hxReward
			self.rewardPos	   = rewardPos
			self.curPoolReward = curPoolReward
			self.addBigAward   = addBigAward

			self.ftNum = 0
			self.pointCount = 0
            if rewardlist and type(rewardlist)=="table" then
                local function realShow()
                	if self.isStop then
                		do return end
                	end
                	-- self:shwoGetReward()--未加动画前 使用
                end
                self:showActionLayer(realShow)---加自己的动画
            end
            
        end
        -- print("num----free----->",num,freeFlag)
        acDlbzVoApi:acDlbzRequest("active.dlbz.reward",{},callback)
    end

    local costNum = acDlbzVoApi:getLotteryCost()
    local cost,num=0,1

    if playerVoApi:getGems()<costNum then
        GemsNotEnoughDialog(nil,nil,costNum-playerVoApi:getGems(),self.layerNum+1,costNum)
        do return end
    else
        local function sureClick()
        	-- print("cost---sureClick-->",cost)
            realLottery(num,costNum)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acDlbzVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if costNum and costNum>0 then
            local keyName=acDlbzVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{costNum}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end

function acDlbzDialog:shwoGetReward( )
	self.isBegin = false
	self.isStop = true

    -- print("self.rewardPos===>>>",self.rewardPos)

    if self.specIdxTb and self.specIdxTb[self.rewardPos] then
		self.acFlicker:setScale(100 / self.acFlickerWidth)
	else
		self.acFlicker:setScale(80 / self.acFlickerWidth)	
	end
    self.acFlicker:setPosition(self.rewardTb[self.rewardPos]:getPositionX(),self.rewardTb[self.rewardPos]:getPositionY())

    self.rewardOldPos = 0

    local function delayCall( )
	    	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
		    local function showEndHandler()
		    	local function getEnd( )
		    		G_showRewardTip(self.curRewardlist,true)
		    		self:refreshLotteryBtn()
		    		self:addExtraAwardBtn()
		    	end

		    	if not self.addBigAward then
			        getEnd()
			    else
			    	local descStr = getlocal("activity_dlbz_bigAwardTip")
			    	if acDlbzVoApi:isAllAwardGetEnd( ) then
			    		descStr = getlocal("activity_dlbz_bigAwardEndTip")
			    	end
			    	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
			        local titleStr = getlocal("acDlbz_biggAwardStr")
			        local needTb = {"dlbz",titleStr,descStr,self.addBigAward,getEnd}
			        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
			        sd:init()
			    end
		    end
		    
		    if self.curHxReward then
		        table.insert(self.curRewardlist,1,self.curHxReward)
		    end
		    local titleStr=getlocal("activity_wheelFortune4_reward")
		    local titleStr2=""--getlocal("activity_tccx_total_score")..getlocal("sweetAdd",{self.curPoint})
		    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
		    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,self.curPoolReward,showEndHandler,titleStr,
		    	titleStr2,nil,nil,"dlbz")
	end
	local delayT = CCDelayTime:create(1)
	local delayCalll = CCCallFuncN:create(delayCall)
	local arr = CCArray:create()
	arr:addObject(delayT)
	arr:addObject(delayCalll)
	local seq = CCSequence:create(arr)
	self.acFlicker:runAction(seq)
	-- self.bgLayer:runAction(seq)
end

function acDlbzDialog:refreshLotteryBtn( )
	local cost=acDlbzVoApi:getLotteryCost()
	if cost then
		self.costLb:setString(cost)
	end
	if self.freeBtn and self.lotteryBtn then
		if acDlbzVoApi:getCurReCount( ) == 0 then
			self.freeBtn:setVisible(true)
			self.lotteryBtn:setVisible(false)
		else
			self.freeBtn:setVisible(false)
			self.lotteryBtn:setVisible(true)
		end

		if acDlbzVoApi:isOver( ) then
			self.freeBtn:setVisible(false)
			self.lotteryBtn:setVisible(false)
			self.costLb:setVisible(false)
			self.costIcon:setVisible(false)
		end
	end
	if self.nowNumLb then
		local lastNum,roundNum = acDlbzVoApi:getLastNum( )
		self.nowNumLb:setString(getlocal("activity_dlbz_nowNum",{lastNum,roundNum}))
	end

	self.getRewardTb = acDlbzVoApi:getEndRewardTb()
	local poolTb = acDlbzVoApi:getPoolReward()

	if acDlbzVoApi:isOver() then
		if self.acFlicker then
			self.acFlicker:setVisible(false)
		end

		for k,v in pairs(poolTb) do
			if self.getRewardSpTb and self.getRewardSpTb[k] then
				self.getRewardSpTb[k]:setVisible(true)
			end
		end

		if self.nowNumLb then
			self.nowNumLb:setString(getlocal("activity_dlbz_isOver"))
		end

		if self.getAwardTip then
			self.getAwardTip:setVisible(false)
		end
		if self.awardTipBg then
			self.awardTipBg:setVisible(false)
		end
	else
		for i=1,SizeOfTable(poolTb) do
			if self.getRewardSpTb and self.getRewardSpTb[i] then
				local isVis = acDlbzVoApi:getEndRewardTb(i) and true or false
				self.getRewardSpTb[i]:setVisible(isVis)
			end
		end
		self.acFlicker:setPosition(self.poolPosTb[1])
		self.acFlicker:setScale(self.rewardTb[1]:getContentSize().height / self.acFlickerWidth)
	end
	
end

function acDlbzDialog:showLogBtn(boardBg,logBtnPosy,logBtnPosx)
	local function logHandler()
		print "logHandler~~~~~~~~~~~~~~~~~"
        local function showLog()
	        local rewardLog=acDlbzVoApi:getRewardLog() or {}
	        if rewardLog and SizeOfTable(rewardLog)>0 then
	            local logList={}
	            for k,v in pairs(rewardLog) do
	                local rCount,reward,time=v.rCount,v.reward,v.time
	                local title={getlocal("snatchNumsIs",{rCount})}
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
	    local rewardLog=acDlbzVoApi:getRewardLog()
	    if rewardLog then
	        showLog()
	    else
	        acDlbzVoApi:acDlbzRequest("active.dlbz.getlog",{},showLog)
	    end
    end
   
    local btnScale,priority = 0.6,-(self.layerNum-1)*20-3
    local logBtn,logMenu = G_createBotton(boardBg,ccp(logBtnPosx,logBtnPosy),nil,"bless_record.png","bless_record.png","bless_record.png",logHandler,btnScale,priority,nil,nil,ccp(0,1))


    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setOpacity(50)
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width + 30,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width * 0.5,15))
    logBg:setScale(0.8/logBtn:getScale())

    logBtn:addChild(logBg)
    local strSize4 = G_isAsia() and 24 or 17
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize4,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--,"Helvetica-bold")
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)
end
------------------------------------------------------------------------------------------
function acDlbzDialog:initPoolAward()
	local poolTb = acDlbzVoApi:getPoolReward()
	local upPos = G_VisibleSizeHeight - 230
	if G_getIphoneType() == G_iphone4 then
		upPos = upPos + 20
	end
	
	local G_w,G_h = G_VisibleSizeWidth,G_VisibleSizeHeight
	local startPox = 40
	local basePosx,baseNum = 0.12,0.15

	local posxTb = {basePosx * G_w - 10, (basePosx + baseNum) * G_w + 3, (basePosx + baseNum*2) * G_w + 3, (basePosx + baseNum*3) * G_w + 3, (basePosx + baseNum*4) * G_w + 3, (basePosx + baseNum*5) * G_w + 15,
		(basePosx + baseNum*5) * G_w + 25,(basePosx + baseNum*5) * G_w + 25,(basePosx + baseNum*5) * G_w + 25,(basePosx + baseNum*5) * G_w + 25,(basePosx + baseNum*5) * G_w + 25,(basePosx + baseNum*5) * G_w + 25,
		(basePosx + baseNum*5) * G_w + 15, (basePosx + baseNum*4) * G_w + 3, (basePosx + baseNum*3) * G_w + 3, (basePosx + baseNum*2) * G_w + 3, (basePosx + baseNum) * G_w + 3, basePosx * G_w - 10, 
		basePosx * G_w - 20, basePosx * G_w - 20, basePosx * G_w - 20, basePosx * G_w - 20, basePosx * G_w - 20, basePosx * G_w - 20
					}
	local bsPosy2 = 133
	local bsPosy3 = 20
	local bsPosy4 = 5
    if G_getIphoneType() == G_iphoneX then
        bsPosy3 = 0
	elseif G_getIphoneType() == G_iphone4 then
		bsPosy2 = 115
		bsPosy3 = 20
		bsPosy4 = 10

	end

	local posyTb = {upPos - 10,upPos,upPos,upPos,upPos,upPos - 10,
					upPos - bsPosy2 ,upPos - bsPosy2 * 2 + bsPosy3,upPos - bsPosy2 * 3 + bsPosy3 * 2,upPos - bsPosy2 * 4 + bsPosy3 * 3,upPos - bsPosy2 * 5 + bsPosy3 * 4,upPos - bsPosy2 * 6 + bsPosy3 * 5,
					upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,upPos - bsPosy2 * 7 + bsPosy3 * 5 + bsPosy4,
					upPos - bsPosy2 * 6 + bsPosy3 * 5,upPos - bsPosy2 * 5 + bsPosy3 * 4,upPos - bsPosy2 * 4 + bsPosy3 * 3,upPos - bsPosy2 * 3 + bsPosy3 * 2,upPos - bsPosy2 * 2 + bsPosy3,upPos - bsPosy2 ,
					}

	self.getRewardTb = acDlbzVoApi:getEndRewardTb()

	for i=1,SizeOfTable(poolTb) do
		local item = poolTb[i]
		local function callback()
            local function closeFun() end 
			G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,nil,true)
		end
		local icon,scale=G_getItemIcon(item,80,false,self.layerNum,callback,nil)
		self.bgLayer:addChild(icon,3)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(posxTb[i],posyTb[i])
		self.poolPosTb[i] = ccp(posxTb[i],posyTb[i])
		self.rewardTb[i] = icon

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

		if self.specIdxTb[i] then
			icon:setScale(1)
			acDlbzVoApi:specicalMarkShow(icon,i)
		end

		local noChoseItSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
		noChoseItSp:setContentSize(CCSizeMake(icon:getContentSize().width - 4, icon:getContentSize().height - 4))
		noChoseItSp:setPosition(getCenterPoint(icon))
		noChoseItSp:setOpacity(240)
		icon:addChild(noChoseItSp,5)
		self.getRewardSpTb[i] = noChoseItSp

		if not acDlbzVoApi:getEndRewardTb(i) then
			noChoseItSp:setVisible(false)
		end


		
	end

	if self.rewardTb[1] then
		self.acFlicker = LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
		-- self.acFlicker:setContentSize(CCSizeMake(95,95))
		self.acFlickerWidth = self.acFlicker:getContentSize().width
		-- self.acFlicker:setScale(self.rewardTb[1]:getContentSize().height / self.acFlickerWidth)
		self.bgLayer:addChild(self.acFlicker,5)
		-- self.acFlicker:setPosition(self.poolPosTb[1])
	end

	self:refreshLotteryBtn()
end

function acDlbzDialog:fastTick( )
	
	if self.isBegin then
		self.ftNum = self.ftNum + 1

		if self.pointCount < 24 then
			if self.ftNum % 5 == 0 then
				self.pointCount = self.pointCount + 1
				
				
				self.rewardOldPos = self.rewardOldPos+1 > 24 and 1 or (self.rewardOldPos + 1)
				self.acFlicker:setPosition(self.poolPosTb[self.rewardOldPos])
				if self.specIdxTb and self.specIdxTb[self.rewardOldPos] then
					self.acFlicker:setScale(100 / self.acFlickerWidth)
				else
					self.acFlicker:setScale(80 / self.acFlickerWidth)	
				end
			end
		else
			if self.ftNum % 8 == 0 then
				self.pointCount = self.pointCount + 1

				if self.rewardOldPos == self.rewardPos then
					self.beginAction = false

						if self.specIdxTb and self.specIdxTb[self.rewardOldPos] then
							self.acFlicker:setScale(100 / self.acFlickerWidth)
						else
							self.acFlicker:setScale(80 / self.acFlickerWidth)	
						end

					self:shwoGetReward()
				else
					
					self.rewardOldPos = self.rewardOldPos+1 > 24 and 1 or (self.rewardOldPos + 1)
					self.acFlicker:setPosition(self.poolPosTb[self.rewardOldPos])
						if self.specIdxTb and self.specIdxTb[self.rewardOldPos] then
							self.acFlicker:setScale(100 / self.acFlickerWidth)
						else
							self.acFlicker:setScale(80 / self.acFlickerWidth)	
						end
				end
			end
		end

	end
end

function acDlbzDialog:tick()
	if self.timeLb then
    	self.timeLb:setString(acDlbzVoApi:getTimer())
    end
    local isEnd=acDlbzVoApi:isEnd()
    if isEnd==true then
        self:close()
    end
end