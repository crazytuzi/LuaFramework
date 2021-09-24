acOlympicGetRewardDialog =smallDialog:new()

function acOlympicGetRewardDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.lotsAward=nil
	self.particleS ={}
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acOlympicGetRewardDialog:init(callbackSure)

	local strSize2 = 22
	local strSize3 = 21
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =25
		strSize3 =23
	end
	self.dialogWidth=560
	self.dialogHeight=450
	local limitNum = 0.7
	if G_isIphone5() then
		limitNum =0.7
		self.dialogHeight = 400
	end
	local downHeight=self.dialogHeight*limitNum
	self.isTouch=nil
	local isHasNbAward = false
	local unSortTb = {}
	self.lotsAward,isHasNbAward,unSortTb,isNum =acOlympicVoApi:getAllCurAwardTb()------取配置奖励库

	acOlympicVoApi:showTip(unSortTb)

	local addW = 110
	local addH = 130
	local function nilFunc() end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
	self.bgLayer:addChild(spriteTitle,1)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
	self.bgLayer:addChild(spriteTitle1,1)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeInfor:setScale(1.2)
	spriteShapeInfor:setOpacity(230)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeInfor:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
    self.bgLayer:addChild(spriteShapeInfor)

    local CurEachAwardScoresTb,curAllScores,scoreLimit = acOlympicVoApi:getCurEachAwardScoresTb( )
    local sortNumScaleTb = {0.5,0.38,0.25,0.2}
    local biganScale = sortNumScaleTb[#self.lotsAward]
    local upStr = ""
    for i=1,3 do
    	if CurEachAwardScoresTb[i] >0 then
	    	upStr = upStr..getlocal("activity_olympic_color_"..i,{CurEachAwardScoresTb[i]})
	    end
    end

    local posH2 = 160
    local posH3 = 60
    if G_isIphone5() then
    	posH2 =150
    end
    for k,v in pairs(self.lotsAward) do
    	local icon,iconScale = G_getItemIcon(v,90,true,self.layerNum,nil,nil)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        icon:setAnchorPoint(ccp(0.5,0))
        local posW = self.dialogWidth*biganScale*k+(k-1)
        if #self.lotsAward ==2 and k ==2 then
        	posW = self.dialogWidth*(1-biganScale)
        end
        icon:setPosition(ccp(posW,posH2))
        self.bgLayer:addChild(icon)

        local num = GetTTFLabel("x"..v.num,25/iconScale)
        num:setAnchorPoint(ccp(1,0))
        num:setPosition(icon:getContentSize().width-5,5)
        icon:addChild(num)

        if acOlympicVoApi:IsFilck() ==true then
        	G_addRectFlicker(icon,2,2)
    		strs = G_showRewardTip({v},false,true)
			local paramTab={}
			paramTab.functionStr=acOlympicVoApi:getActiveName()
			paramTab.addStr="i_also_want"
		    local message={key="activity_olympic_chat",param={playerVoApi:getPlayerName(),getlocal("activity_olympic_title"),upStr,curAllScores,strs}}
		    chatVoApi:sendSystemMessage(message,paramTab)
        end
    end

    bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp:setAnchorPoint(ccp(0.5,0.5))
	bgSp:setPosition(ccp(self.dialogWidth*0.5,downHeight));
	bgSp:setScaleY(40/bgSp:getContentSize().height)
	bgSp:setOpacity(200)
	bgSp:setScaleX((self.dialogWidth+50)/bgSp:getContentSize().width)
	self.bgLayer:addChild(bgSp)

	local luckyStr = GetTTFLabel(getlocal("activity_wheelFortune4_reward"),strSize2)
    luckyStr:setAnchorPoint(ccp(0.5,0.5))
    luckyStr:setColor(G_ColorYellowPro)
    luckyStr:setPosition(ccp(self.dialogWidth*0.5,downHeight))
    self.bgLayer:addChild(luckyStr)

    upStr = upStr..getlocal("activity_olympic_getAwardLbUp",{curAllScores})
    if curAllScores >= scoreLimit then
    	 upStr =upStr..getlocal("activity_olympic_LargeAward")
	end

    local upLabel = GetTTFLabel(upStr,25)
    upLabel:setAnchorPoint(ccp(0.5,1))
    upLabel:setPosition(ccp(self.dialogWidth*0.5,downHeight+posH3))
    if curAllScores >= scoreLimit then
    	upLabel:setColor(G_ColorYellowPro)
    end
    self.bgLayer:addChild(upLabel)

	local function close()
		print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	local function showHandler(hd,fn,idx)

		local checkBorder = nil
		local bgSp = nil
		for k,v in pairs(self.lotsAward) do
			bgSp = tolua.cast(dialogBg:getChildByTag(k),"CCSprite")
			checkBorder = tolua.cast(bgSp:getChildByTag(k),"CCSprite")
			if k ==idx then
				checkBorder:setVisible(true)
			else
				checkBorder:setVisible(false)
			end
		end
	end

	 --确定
    local function sureHandler(tag,object)
    	-- print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		acOlympicVoApi:setAgainBuy(tag)
		if callbackSure ~=nil then
			-- print("callbackSure------~~~~~")
			callbackSure()
		end
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.3,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local sureItem2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,3,getlocal("activity_olympic_againBuy"),strSize3)
    local sureMenu2=CCMenu:createWithItem(sureItem2);
    sureMenu2:setPosition(ccp(dialogBg:getContentSize().width*0.7,70))
    sureMenu2:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu2)

    local noUse,needGems = acOlympicVoApi:getBuyTagAndGems( )
    local haveCost = playerVoApi:getGems()
    self.oneCostStr = GetTTFLabel(needGems,25)
    self.oneCostStr:setAnchorPoint(ccp(1,0))
    sureItem2:addChild(self.oneCostStr)
    self.oneCostStr:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon1:setAnchorPoint(ccp(0,0))
	sureItem2:addChild(self.gemIcon1,1)

	self.oneCostStr:setPosition(ccp(sureItem2:getContentSize().width*0.5+5,sureItem2:getContentSize().height*0.5+35))
	self.gemIcon1:setPosition(ccp(sureItem2:getContentSize().width*0.5+5,sureItem2:getContentSize().height*0.5+35))

	if needGems>haveCost then
    	self.oneCostStr:setColor(G_ColorRed)
    	sureItem2:setEnabled(false)
    else
    	self.oneCostStr:setColor(G_ColorYellowPro)
    end
    local function nilFunc() end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end


function acOlympicGetRewardDialog:dispose()
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.lotsAward =nil
end
function acOlympicGetRewardDialog:playParticles()
    --粒子效果
  self.particleS = {}
  local pX = nil
  local PY = nil
  for i=1,3 do
    pX = self.dialogWidth/2 + (i - 2) * 200
    PY = self.dialogHeight/2
    if i ~= 2 then
      PY = PY + 200
    end
    local p = CCParticleSystemQuad:create("public/SMOKE.plist")
    p.positionType = kCCPositionTypeFree
    p:setPosition(ccp(pX,PY))
    self.bgLayer:addChild(p,10)
    table.insert(self.particleS,p)
  end
  self.addParticlesTs = base.serverTime
end
function acOlympicGetRewardDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end
function acOlympicGetRewardDialog:close()
	self:removeParticles()
	acOlympicVoApi:setCurAwardTb()
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.lotsAward=nil
	self.particleS =nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end