-- @Author hj
-- @time 2018-09-04
-- @Description 建筑装扮的板子

buildDecorateDialog = commonDialog:new()

function buildDecorateDialog:new( ... )
	local nc={
		-- 当前选择的页签，默认是已拥有
		curIndex = 2,
		tabItemList = {},
		showStatus = 0,
		spriteArr = {0,1,2},
		downPos = {ccp(120,100),ccp((G_VisibleSizeWidth-40)/2,100),ccp(G_VisibleSizeWidth-40-120,100)},
		-- downPos = {ccp(120,G_VisibleSizeHeight-90-300-60-10-50-100),ccp((G_VisibleSizeWidth-40)/2,G_VisibleSizeHeight-90-300-60-10-50-100-10),ccp(G_VisibleSizeWidth-40-120,G_VisibleSizeHeight-90-300-60-10-50-100)},
		downTwoPos = {ccp((G_VisibleSizeWidth-40)/3,G_VisibleSizeHeight-90-300-60-10-30-100),ccp((G_VisibleSizeWidth-40)*2/3,G_VisibleSizeHeight-90-300-60-10-30-100-10)},
		downOutPos = {ccp(-80,100),ccp(G_VisibleSizeWidth-40+80,100)},
		-- downOutPos = {ccp(-80,G_VisibleSizeHeight-90-300-60-10-50-100),ccp(G_VisibleSizeWidth-40+80,G_VisibleSizeHeight-90-300-60-10-50-100)},
		scaleDownTb = {0.5,0.8,0.5},
		fadeRateTb = {0.5,1,0.5},
		upPos = ccp((G_VisibleSizeWidth-40)/2,150),
		scaleUpTb = {0.8,1,0.8},
		upOutPos = {ccp(-200,150),ccp(G_VisibleSizeWidth+180,150)},
		displaySprTb = {},
		curDisplayIndex = 0,
		curchose = 1,
		upBg = nil,
		downBg = nil,
		skinSprTb = {},
		downFlag = 1,
		curDecorate 
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function buildDecorateDialog:doUserHandler( ... )

	spriteController:addPlist("public/reportyouhua.plist")
	spriteController:addTexture("public/reportyouhua.png")

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- spriteController:addPlist("public/skinFlash.plist")
	-- spriteController:addTexture("public/skinFlash.png")
	spriteController:addPlist("public/decorate_special.plist")
	spriteController:addTexture("public/decorate_special.png")
	spriteController:addPlist("public/acydcz_images.plist")
   	spriteController:addTexture("public/acydcz_images.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")

    local cost = {p={[exteriorCfg.changeItemNum]=1}}
    self.exchangeCost = FormatItem(cost)[1]

    if G_getIphoneType() == G_iphone4 then
    	self.adaH = 27
    	self.adaW = 25
    else
    	self.adaW = 0
    	self.adaH = 0
    end


	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end


	local function touchInfo()
        local tabStr={}
        for i=1,3 do
        	table.insert(tabStr,getlocal("decorateInfo"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-120),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,0.8,-(self.layerNum-1)*20-4,5)
	
	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
    self.bgLayer:addChild(tabLine,5)

    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
    buildDecorateVoApi:initSkinTb()

    for i=1,3 do
    	local strSize = 25
    	if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
    		strSize = 20
    	end
		local function touchInfo( ... )
				self:touchInfo(i)
		end
		local tabItem = G_createBotton(self.bgLayer,ccp(20+72.5+150*(i-1),G_VisibleSizeHeight-82-300-37),{getlocal("decorateTabitem"..i),strSize},"yh_ltzdzHelp_tab.png","yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png",touchInfo,1,-(self.layerNum-1)*20-2,nil,nil,nil,true)
		if self.curIndex == i then
			tabItem:setEnabled(false)
		end
		self.tabItemList[i] = tabItem
	end
	

	local function showDetail( ... )
		self:showDetail()
	end
	local detailBtn=LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png",showDetail)
	detailBtn:setScale((G_VisibleSizeWidth-30)/G_VisibleSizeWidth)
	detailBtn:setPosition(G_VisibleSizeWidth/2,30)
	detailBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.detailBtn = detailBtn
	self.bgLayer:addChild(detailBtn,6)
	
	for i=1,2 do
		local arrowSp=CCSprite:createWithSpriteFrameName("reportArrow.png")
		if i==1 then
		arrowSp:setPosition(150,detailBtn:getContentSize().height/2)
		else
		arrowSp:setPosition(detailBtn:getContentSize().width-150,detailBtn:getContentSize().height/2)
		arrowSp:setRotation(180)
		end
		detailBtn:addChild(arrowSp)
	end
	local detailLb=GetTTFLabelWrap(getlocal("decorateAllattr"),22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	detailLb:setPosition(getCenterPoint(detailBtn))
	detailLb:setColor(G_ColorYellowPro)
	detailBtn:addChild(detailLb)

	local function touchHandler()
		do return end
	end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    dialogBg:setContentSize(CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,G_VisibleSizeHeight-90-300-60-10-50-170))
    detailBtn:addChild(dialogBg)
    dialogBg:setTag(1016)
    dialogBg:setAnchorPoint(ccp(0.5,1))
    dialogBg:setPosition(ccp(detailBtn:getContentSize().width/2,0))
    dialogBg:setVisible(false)

    local worldBg = CCSprite:createWithSpriteFrameName("decorateBg.png")
    worldBg:setAnchorPoint(ccp(0.5,1))
    worldBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85))
    self.bgLayer:addChild(worldBg)

    --放大镜
	local magnifierNode=CCNode:create()
	magnifierNode:setAnchorPoint(ccp(0.5,0.5))
	magnifierNode:setPosition(ccp(9999,G_VisibleSizeHeight-90-150-50))
	magnifierNode:setTag(1016)
	self.bgLayer:addChild(magnifierNode,5)

	local function showInfo( ... )
		if G_checkClickEnable()==false then
        	do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:showInfo()

	end
	local circelCenter=getCenterPoint(magnifierNode)
	local radius,rt,rtimes=10,2,2
	local magnifierSp=LuaCCSprite:createWithSpriteFrameName("ydcz_magnifier.png",showInfo)
	magnifierSp:setTouchPriority(-(self.layerNum-1)*20-4)
	magnifierSp:setPosition(circelCenter)
	magnifierNode:addChild(magnifierSp)

	local acArr=CCArray:create()
	local moveTo=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,radius))
	local function rotateBy()
		G_requireLua("componet/CircleBy")
		self.circelAc=CircleBy:create(magnifierSp,rt,circelCenter,radius,rtimes)
	end
	local function removeRotateBy()
		if self.circelAc and self.circelAc.stop then
			self.circelAc:stop()
		end
	end
	local moveTo2=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,magnifierNode:getContentSize().height/2))
	local delay=CCDelayTime:create(1)
	acArr:addObject(moveTo)
	acArr:addObject(CCCallFunc:create(rotateBy))
	acArr:addObject(CCDelayTime:create(rt))
	acArr:addObject(CCCallFunc:create(removeRotateBy))
	acArr:addObject(moveTo2)
	acArr:addObject(delay)
	local seq=CCSequence:create(acArr)
	magnifierSp:runAction(CCRepeatForever:create(seq))


	local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("decorate_title.png",CCRect(200,15,1,1),function() end)
    nameBg:setAnchorPoint(ccp(0.5,1))
    nameBg:setContentSize(CCSizeMake(450,60))
    nameBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-80))
    self.bgLayer:addChild(nameBg)


	local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(self.bgLayer:getContentSize().width/2,(G_getIphoneType()==G_iphone4) and (self.bgLayer:getContentSize().height-630) or (self.bgLayer:getContentSize().height-90-270-300))
    self.bgLayer:addChild(titleBg,5)
    self.titleBg=titleBg

    local titleLb=GetTTFLabel(getlocal("decoratePrompt"),25,true)
    titleLb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
    titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)
    
    
    local tipLabel 
    local strSize = 20
    if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
    	strSize = 15
    	tipLabel=GetTTFLabelWrap(getlocal("decorateTip"),strSize,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    else
    	tipLabel= GetTTFLabel(getlocal("decorateTip"),strSize,true)
    end
    tipLabel:setAnchorPoint(ccp(0.5,0))
    tipLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,65))
    tipLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipLabel,5)
    self.tipLabel=tipLabel
	self:refreshSp()

    self.eventListener = function(event,data)
    	self:refreshSp()
    end
    eventDispatcher:addEventListener("buildDecorateDialog.refreshSp",self.eventListener)
end

-- 初始化背景
function buildDecorateDialog:initBg( ... )
	

	local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,300))
	upBg:setAnchorPoint(ccp(0.5,1))
	upBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-90))
	upBg:setOpacity(0)
	self.upBg = upBg
	self.bgLayer:addChild(upBg,4)

	local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-90-300-60-10-40))
	downBg:setAnchorPoint(ccp(0.5,0))
	downBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,50))
	self.downBg = downBg
	self.bgLayer:addChild(downBg)


end

function buildDecorateDialog:touchInfo(idx)

	if self.curIndex ~= idx then
		if idx == 1 and #buildDecorateVoApi:getLockSkinTb() == 0 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("decorateUnlockAll"),30)
			return
		end

		self.curIndex = idx
		for k,v in pairs(self.tabItemList) do
			if v and tolua.cast(v,"CCMenuItemSprite") then
				if k ~= self.curIndex then
					v:setEnabled(true)
				else
					v:setEnabled(false)
				end
			end
		end
		self:refreshSp()
	end
end

function buildDecorateDialog:moveDown(direction)
	self.downFlag = 0
	if direction > 0 then
		for k,v in pairs(self.spriteArr) do
			local skinSp = tolua.cast(self.skinSprTb[v],"LuaCCSprite")
			if k ~= 1 then
				if skinSp then
					local topScale = self.scaleDownTb[k-1]
					if skinSp.skinId and skinSp.skinId =="b11" or skinSp.skinId =="b12" then
						topScale = 0.5
					elseif skinSp.skinId =="b13" then
						topScale = 0.4
					end
					local function endCallback( ... )
						self:resetArr(direction)
						self:refreshSp(true)
						self.downFlag = 1
					end
					if k == 2 then
						self:runAction(self.downPos[k-1],topScale,self.fadeRateTb[k-1],0.5,skinSp,endCallback)
					else
						self:runAction(self.downPos[k-1],topScale,self.fadeRateTb[k-1],0.5,skinSp)
					end
				end
			else
				local function endCallback( ... )
					skinSp:setPosition(self.downOutPos[2])
					self:runAction(self.downPos[3],self.scaleDownTb[1],self.fadeRateTb[1],0.25,skinSp)
				end
				self:runAction(self.downOutPos[1],self.scaleDownTb[1],self.fadeRateTb[1],0.25,skinSp,endCallback)
			end
		end
	else
		for k,v in pairs(self.spriteArr) do
			local skinSp = tolua.cast(self.skinSprTb[v],"LuaCCSprite")
			if k ~= 3 then
				if skinSp then
					local topScale = self.scaleDownTb[k+1]
					if skinSp.skinId and skinSp.skinId =="b11" or skinSp.skinId =="b12" then
						topScale = 0.5
					elseif skinSp.skinId =="b13" then
						topScale = 0.4
					end
					local function endCallback( ... )
						self:resetArr(direction)
						self:refreshSp(true)
						self.downFlag = 1
					end
					if k == 2 then
						self:runAction(self.downPos[k+1],topScale,self.fadeRateTb[k+1],0.5,skinSp,endCallback)
					else
						self:runAction(self.downPos[k+1],topScale,self.fadeRateTb[k+1],0.5,skinSp)
					end
				end
			else
				local  function endCallback( ... )
					skinSp:setPosition(self.downOutPos[1])
					self:runAction(self.downPos[1],self.scaleDownTb[1],self.fadeRateTb[1],0.25,skinSp)
				end
				if skinSp then
					self:runAction(self.downOutPos[2],self.scaleDownTb[1],self.fadeRateTb[1],0.25,skinSp,endCallback)
				end
			end
		end
	end

end

function buildDecorateDialog:runAction(targetPos,targetScale,fadeRate,time,sp,endhandle)
	
	local acArr = CCArray:create()
	local moveTo = CCMoveTo:create(time,targetPos)
	local scaleTo = CCScaleTo:create(time,targetScale)
	local fateTo = CCFadeTo:create(time,255*fadeRate)

	acArr:addObject(moveTo)
	acArr:addObject(scaleTo)
	acArr:addObject(fateTo)

	local spawn = CCSpawn:create(acArr)
	local function callBack( ... )
		if endhandle then
			endhandle()
		end
	end
	local callfunc = CCCallFunc:create(callBack)
	local seq = CCSequence:createWithTwoActions(spawn,callfunc)
	sp:runAction(seq)
end



function buildDecorateDialog:resetArr(direction)
	for k,v in pairs(self.spriteArr) do
		if (v + direction) > (#self.skinSprTb) then
			self.spriteArr[k] = (v + direction)%(#self.skinSprTb)
		elseif v + direction < 1 then
			self.spriteArr[k] = #self.skinSprTb
		else
			self.spriteArr[k] = v + direction
		end

	end

	self.curchose = self.spriteArr[2]
end

-- function buildDecorateDialog:moveUp(direction)

-- 	self.upFlag = 0
-- 	if direction > 0 then
-- 		local forwardIndex = (self.curDisplayIndex-1+(#self.displaySprTb))%(#self.displaySprTb)
-- 		local beSp = tolua.cast(self.displaySprTb[forwardIndex+1],"LuaCCSprite") 
-- 		local displaySp = tolua.cast(self.displaySprTb[self.curDisplayIndex+1],"LuaCCSprite") 
-- 		if displaySp and beSp then
-- 			local function endCallback( ... )
-- 				self.upFlag = 1
-- 				self.curDisplayIndex = forwardIndex
-- 			end
-- 			self:runAction(self.upOutPos[2],self.scaleUpTb[1],0.5,displaySp,endCallback)
-- 			beSp:setPosition(self.upOutPos[1])
-- 			beSp:setScale(self.scaleUpTb[1])
-- 			self:runAction(self.upPos,self.scaleUpTb[2],0.5,beSp)
-- 		end
-- 	else
-- 		local forwardIndex = (self.curDisplayIndex+1)%(#self.displaySprTb)
-- 		local afSp = tolua.cast(self.displaySprTb[forwardIndex+1],"LuaCCSprite") 
-- 		local displaySp = tolua.cast(self.displaySprTb[self.curDisplayIndex+1],"LuaCCSprite") 
-- 		if displaySp and afSp then
-- 			local function endCallback( ... )
-- 				self.upFlag = 1
-- 				self.curDisplayIndex = forwardIndex
-- 			end
-- 			self:runAction(self.upOutPos[1],self.scaleUpTb[1],0.5,displaySp,endCallback)
-- 			afSp:setPosition(self.upOutPos[2])
-- 			afSp:setScale(self.scaleUpTb[3])
-- 			self:runAction(self.upPos,self.scaleUpTb[2],0.5,afSp)
-- 		end
-- 	end

-- end

function buildDecorateDialog:showInfo( ... )
	local detaiTb = {}
	local skinTb 
	local nowLevel 
	if self.curIndex == 1 then
		skinTb = buildDecorateVoApi:getLockSkinTb()
		nowLevel = 0
		self.lastSkinTb,self.lastSkinLv=skinTb,nowLevel
	elseif self.curIndex == 2 then
		skinTb = buildDecorateVoApi:getHasSkinTb()
		nowLevel = skinTb[self.curchose].nowLevel
		self.lastSkinTb,self.lastSkinLv=skinTb,nowLevel
	elseif self.curIndex == 3 then
		skinTb = self.lastSkinTb
		nowLevel = self.lastSkinLv
	end
	if skinTb then
		local choseTb = skinTb[self.curchose]
		if choseTb.timeLimit > 0 or (type(choseTb.experienceTimer) == "number" and choseTb.experienceTimer > 0) then --策划约定，当是限时皮肤时直接取最大值
			nowLevel = choseTb.lvMax
		end

		for k,v in pairs(choseTb.attType) do 
			table.insert(detaiTb,{nowLevel=nowLevel,lvMax=choseTb.lvMax,value=choseTb.value[k],type=v,experienceTimer=choseTb.experienceTimer})
		end
		local addStr = getlocal("decorateSmallDesc",{buildDecorateVoApi:getSkinName(exteriorCfg.exteriorLit[choseTb.id])})
		require "luascript/script/game/scene/gamedialog/attributeStarSmallDialog"
		local sd = attributeStarSmallDialog:new(self.layerNum+1)
		sd:init(detaiTb,addStr)
	end
end

-- 刷新精灵上下的
function buildDecorateDialog:refreshSp(isnotfirst)
	self:refreshExchange()
	if self.curIndex==3 then
		if self.downBg then
			self.downBg:setVisible(false)
			self.downBg:setPositionX(99999)
			self.titleBg:setVisible(false)
			self.tipLabel:setVisible(false)
		end
		do return end
	end
	if self.upBg and self.downBg then
		self.upBg:removeFromParentAndCleanup(true)
		self.upBg = nil
		self.downBg:removeFromParentAndCleanup(true)
		self.downBg = nil
	end
	self.titleBg:setVisible(true)
	self.tipLabel:setVisible(true)

	self:initBg()
	self.skinSprTb = {}

	local skinTb 
	if self.curIndex == 1 then
		skinTb = buildDecorateVoApi:getLockSkinTb()
		if not isnotfirst then
			self.curchose = 1
			self:initSpriteArr(self.curchose,#skinTb)
		end
		self.lastSkinTb,self.lastSkinLv=skinTb,0
	else
		skinTb = buildDecorateVoApi:getHasSkinTb()
		local nowUse = buildDecorateVoApi:getNowUse()
		for k,v in pairs(skinTb) do
			if isnotfirst then
				
			elseif v.id == nowUse then
				self.curchose = k
				self:initSpriteArr(k,#skinTb)
			end
		end
		local nowLevel = skinTb[self.curchose].nowLevel
		self.lastSkinTb,self.lastSkinLv=skinTb,nowLevel
	end

	if #skinTb == 1 then
		self:oneSkin(skinTb)
	elseif  #skinTb == 2 then
		self:twoSkin(skinTb)
	else
		self:threeMore(skinTb)
	end

	-- 下方的属性
	local detailInfo = skinTb[self.curchose]

	if detailInfo then
		self:refreshAttr(detailInfo)
	end
	local function touchHandler( ... )
		-- body
	end

	if tolua.cast(self.bgLayer:getChildByTag(1016),"CCNode") then
		tolua.cast(self.bgLayer:getChildByTag(1016),"CCNode"):setPosition(ccp(420,G_VisibleSizeHeight-90-150-50))
	end

	local imgStr = buildDecorateVoApi:getSkinImg(detailInfo.id)		
	local displaySp = LuaCCSprite:createWithSpriteFrameName(imgStr,touchHandler)
	displaySp:setAnchorPoint(ccp(0.5,0.5))
	displaySp:setPosition(self.upPos)
	if detailInfo.id == "b11" or detailInfo.id == "b12" then
		displaySp:setScale(0.5)
		displaySp:setPositionY(displaySp:getPositionY() - 25)
	elseif detailInfo.id =="b13" then
		displaySp:setScale(0.4)
		displaySp:setPositionY(displaySp:getPositionY() - 25)
	end
	buildDecorateVoApi:playSkinAction(detailInfo.id,displaySp)

	self.upBg:addChild(displaySp)

	self:refeshLb(detailInfo.id,detailInfo)
	if self.curIndex ~= 1 then
		self:refreshStar(skinTb[self.curchose].nowLevel,skinTb[self.curchose].lvMax)
	end
end

function buildDecorateDialog:refreshExchange()
	if self.curIndex==3 then
		if self.exchangeLayer==nil then
			local lcWidth,lcHeight = G_VisibleSizeWidth-40,G_VisibleSizeHeight-90-300-60-10-40
			local exchangeLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
			exchangeLayer:setContentSize(CCSizeMake(lcWidth,lcHeight))
			exchangeLayer:setAnchorPoint(ccp(0.5,0))
			exchangeLayer:setPosition(ccp(self.bgLayer:getContentSize().width/2,50))
			self.bgLayer:addChild(exchangeLayer)
			self.exchangeLayer=exchangeLayer

			--拥有碎片
			local costId = tonumber(RemoveFirstChar(exteriorCfg.changeItemNum))
			local num = bagVoApi:getItemNumId(costId)
			local tipStr,tipFontSize = getlocal("buildSkinFlagNumStr",{num}),22
			local fragLb = GetTTFLabelWrap(tipStr,tipFontSize,CCSize(lcWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			fragLb:setAnchorPoint(ccp(0,0.5))
			fragLb:setPosition(40,lcHeight-fragLb:getContentSize().height/2-10)
			fragLb:setColor(G_ColorYellowPro)
			self.fragLb=fragLb
			exchangeLayer:addChild(fragLb)
			local tempLb = GetTTFLabel(tipStr,tipFontSize)
			local realWidth = tempLb:getContentSize().width
			if realWidth>fragLb:getContentSize().width then
				realWidth=fragLb:getContentSize().width
			end
			--碎片图标
			local fragIconSp = CCSprite:createWithSpriteFrameName("skinFragSmall.png")
			fragIconSp:setPosition(fragLb:getPositionX()+realWidth+fragIconSp:getContentSize().width/2+5,fragLb:getPositionY())
			exchangeLayer:addChild(fragIconSp)

			local  lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),function() end)
            lineSp:setPosition(lcWidth/2,fragLb:getPositionY()-fragLb:getContentSize().height/2-10)
            lineSp:setContentSize(CCSizeMake(lcWidth - 50,lineSp:getContentSize().height))
            exchangeLayer:addChild(lineSp)

			self.tvWidth,self.tvHeight = lcWidth,lcHeight-fragLb:getContentSize().height-40
			self.shopTvCellH=120
			if G_isIOS()==false then
				self.shopTvCellH=140
			end
			self.exchangeList=buildDecorateVoApi:getExchangeList()
			self.exnum=SizeOfTable(self.exchangeList)
			local function callBack(...)
			   return self:shopEventHandler(...)
			end
			local hd= LuaEventHandler:createHandler(callBack)
			self.shopTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
			self.shopTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
			self.shopTv:setPosition(ccp((lcWidth-self.tvWidth)/2,10))
			exchangeLayer:addChild(self.shopTv,2)
			self.shopTv:setMaxDisToBottomOrTop(120)
		end
		self.exchangeLayer:setVisible(true)
		self.exchangeLayer:setPositionX(self.bgLayer:getContentSize().width/2)
		local costId = tonumber(RemoveFirstChar(exteriorCfg.changeItemNum))
		local num = bagVoApi:getItemNumId(costId)
		self.fragLb:setString(getlocal("buildSkinFlagNumStr",{num}))
	else
		if self.exchangeLayer and tolua.cast(self.exchangeLayer,"LuaCCScale9Sprite") then
			self.exchangeLayer:setPositionX(99999)
			self.exchangeLayer:setVisible(false)
		end
	end
end

function buildDecorateDialog:shopEventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.exnum
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvWidth,self.shopTvCellH)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local iconWidth,cellHeight = 80,self.shopTvCellH
		local nameFontSize,descFontSize = 22,20
		if G_isIOS()==false then
			descFontSize=18
		end
		local item = self.exchangeList[idx+1]
		local eid = item.id
		local itemCfg=buildDecorateVoApi:getExchangeCfg(eid)
		local exchangeItem = FormatItem(itemCfg.reward)[1]
		local namePosX = 110
		local function showPropInfo()
			
		end
		local exchangeSp = G_getItemIcon(exchangeItem,100,true,self.layerNum,showPropInfo,self.tv)
		exchangeSp:setAnchorPoint(ccp(0,0.5))
		exchangeSp:setScale(iconWidth/exchangeSp:getContentSize().width)
		exchangeSp:setPosition(20,cellHeight/2)
		cell:addChild(exchangeSp)

		local  nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function ()end)
		nameBg:setAnchorPoint(ccp(0,1))
		nameBg:setPosition(namePosX,cellHeight-10)
		nameBg:setContentSize(CCSizeMake(self.tvWidth-250,32))
		cell:addChild(nameBg)

		--名称
		local nameLb = GetTTFLabelWrap(exchangeItem.name,nameFontSize,CCSizeMake(nameBg:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(15,nameBg:getContentSize().height/2)
		nameLb:setColor(G_ColorYellowPro)
		nameBg:addChild(nameLb)

		--描述
		local descLb = GetTTFLabelWrap(getlocal(exchangeItem.desc),descFontSize,CCSizeMake(self.tvWidth-280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(namePosX+15,nameBg:getPositionY()-nameBg:getContentSize().height-5)
		cell:addChild(descLb)

		local flag = false --已拥有的标识
		if exchangeItem.type=="b" or (exchangeItem.type=="p" and propCfg[exchangeItem.key] and propCfg[exchangeItem.key].useGetExterior) then
			local bid
			if exchangeItem.type=="b" then
				bid=exchangeItem.key
			else
				bid=propCfg[exchangeItem.key].useGetExterior[1]
			end
			if buildDecorateVoApi:judgeHas(bid)==true and buildDecorateVoApi:isSkinExpire(bid)==false then
				flag = true
				local ownLb = GetTTFLabelWrap(getlocal("decorateTabitem2"),descFontSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				ownLb:setPosition(self.tvWidth-80,cellHeight/2)
				cell:addChild(ownLb)
			end
		end
		if flag == false then
			--兑换
			local btnScale,priority = 0.6,-(self.layerNum-1)*20-2
			local function exchangeHandler()
				local costId = exteriorCfg.changeItemNum
				local num = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(costId)))
				if num<itemCfg.price then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("decorate_exchange_lack"),30)
					do return end
				end
				local function realExchange(count)
					local function exchangeCallBack(fn,data)
						local ret,sData = base:checkServerData(data)
						if ret==true then
							
							-- print("costId----itemCfg.price----->>>>",costId,itemCfg.price,count)
							count = count or 1
							if costId then
								bagVoApi:useItemNumId(tonumber(RemoveFirstChar(costId)),itemCfg.price * count)
							end
							if exchangeItem.type=="b" then --兑换的是基地装扮
								if sData.data and sData.data.ext then
									buildDecorateVoApi:unlockSkin(exchangeItem.key)
								end
							else
								
								G_addPlayerAward(exchangeItem.type,exchangeItem.key,exchangeItem.id,count)
							end
							self:refreshExchange()
							if self.shopTv then
						        local recordPoint=self.shopTv:getRecordPoint()
			                    self.shopTv:reloadData()
			                    self.shopTv:recoverToRecordPoint(recordPoint)
							end
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),30)
						end
					end
					socketHelper:baseDecorateExchange(eid,count,exchangeCallBack)
				end
				
				if exchangeItem.type=="b" then
					local function confirm()
						realExchange()						
					end
					G_showSecondConfirm(self.layerNum+1,false,true,getlocal("dialog_title_prompt"),getlocal("decorate_frag_exchangeTip",{itemCfg.price,exchangeItem.name}),false,confirm)
				else --道具可以批量兑换
					local limitNum = math.floor(num/itemCfg.price)
					local cost = {p={[exteriorCfg.changeItemNum]=itemCfg.price}}
					local costTb = FormatItem(cost)
					local function buyCallBack(count)
						realExchange(count)
					end
  					shopVoApi:showBatchBuyPropSmallDialog(exchangeItem.key,self.layerNum+1,buyCallBack,getlocal("code_gift"),limitNum,nil,costTb)
				end
			end
			local exchangeItem,exchangeMenu=G_createBotton(cell,ccp(self.tvWidth-80,40),{getlocal("code_gift"),22},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",exchangeHandler,btnScale,priority)
			--价格
			local costSp = CCSprite:createWithSpriteFrameName("skinFragSmall.png")
			costSp:setAnchorPoint(ccp(0,0.5))
			cell:addChild(costSp)

			local costLb = GetTTFLabel(itemCfg.price,descFontSize)
			costLb:setAnchorPoint(ccp(0,0.5))
			cell:addChild(costLb)
			local twidth = costSp:getContentSize().width+costLb:getContentSize().width+5
			costSp:setPosition(exchangeMenu:getPositionX()-twidth/2,exchangeMenu:getPositionY()+40)
			costLb:setPosition(costSp:getPositionX()+costSp:getContentSize().width*costSp:getScale()+5,costSp:getPositionY())
		end

		if (idx+1)~=self.exnum then
			local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
	        lineSp:setPosition(self.tvWidth/2,1)
	        lineSp:setContentSize(CCSizeMake(self.tvWidth-60,2))
	        cell:addChild(lineSp)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
	end
end

function buildDecorateDialog:initSpriteArr(k,length)
	self.spriteArr[2] = k

	if k+1 > length then
		self.spriteArr[3] = (k+1)%length
	else
		self.spriteArr[3] = k+1
	end

	if k-1 < 1 then
		self.spriteArr[1] = length
	else
		self.spriteArr[1] = k-1
	end
end

-- 单一适配
function buildDecorateDialog:oneSkin(skinTb)

	local function touchHandler( ... )
	end
	local imgStr = buildDecorateVoApi:getSkinImg(skinTb[self.curchose].id)	
	local skinSp = LuaCCSprite:createWithSpriteFrameName(imgStr,touchHandler)
	skinSp:setScale(0.8)
	skinSp:setAnchorPoint(ccp(0.5,0.5))
	skinSp:setPosition(ccp((G_VisibleSizeWidth-40)/2,G_VisibleSizeHeight-90-300-40-10-50-100-10))
	self.downBg:addChild(skinSp)

end

-- 
function buildDecorateDialog:twoSkin(skinTb)

	for k,v in pairs(skinTb) do
		local function touchHandler()

			if G_checkClickEnable()==false then
            	do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
			if self.curchose ~= k then
				self.curchose = k
    			self:choseAction(v.id)
			end
		end
		local imgStr = buildDecorateVoApi:getSkinImg(v.id)		
		local skinSp= LuaCCSprite:createWithSpriteFrameName(imgStr,touchHandler)

		skinSp:setAnchorPoint(ccp(0.5,0.5))
		self.skinSprTb[k] = skinSp

		if v.id == "b1" or v.id == "b3" or v.id == "b2" or v.id =="b11" or v.id =="b12" or v.id =="b13" then
			skinSp:setPosition(self.downTwoPos[k].x,self.downTwoPos[k].y-23)
		else
			skinSp:setPosition(self.downTwoPos[k])
		end


		skinSp:setTouchPriority(-(self.layerNum-1)*20-4)
		self.downBg:addChild(skinSp)

		if k ~= self.curchose then
			skinSp:setScale(0.7)
			skinSp:setOpacity(255*0.5)
			if v.id == "b11" or v.id == "b12" then
				skinSp:setScale(0.5)
			elseif v.id == "b13" then
				skinSp:setScale(0.4)
			end
		else
			skinSp:setScale(0.8)
			if v.id == "b11" or v.id == "b12" then
				skinSp:setScale(0.5)
			elseif v.id == "b13" then
				skinSp:setScale(0.4)
			end
		end
	end

end


function buildDecorateDialog:choseAction( skinId)
	local sSize =  0.8
	if skinId then
		if skinId =="b11" or skinId =="b12" then
			sSize = 0.5
		elseif  skinId =="b13" then
			sSize = 0.4
		end	
	end
    local acArr = CCArray:create()
    local scaleTo=CCScaleTo:create(0.3,sSize)
    local fadeTo=CCFadeTo:create(0.3,255)
    
    acArr:addObject(scaleTo)
    acArr:addObject(fadeTo)
    local spawn = CCSpawn:create(acArr)

    local function callBack( ... )
		self:refreshSp(true)
    end
	local callfunc = CCCallFunc:create(callBack)
    local seq = CCSequence:createWithTwoActions(spawn,callfunc)

    self.skinSprTb[self.curchose]:runAction(seq)

end

function buildDecorateDialog:threeMore(skinTb)

	local clipper=CCClippingNode:create()
	clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,200))
	clipper:setAnchorPoint(ccp(0.5,1))
	clipper:setPosition((G_VisibleSizeWidth-40)/2,self.downBg:getContentSize().height)

	local stencil=CCDrawNode:getAPolygon(CCSizeMake(G_VisibleSizeWidth-170,200),1,1)
	stencil:setPosition(ccp(65,0))
	clipper:setStencil(stencil) 
	self.downBg:addChild(clipper,10)

	for k,v in pairs(skinTb) do
		local function touchHandler()

			if G_checkClickEnable()==false then
            	do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        for kk,vv in pairs(self.spriteArr) do
	        	if vv == k then
					if kk < 2 then
						self:moveDown(-1)
					elseif kk > 2 then
						self:moveDown(1)
					else

					end
	        	end
	        end
		end

		local imgStr
		-- if v.specialFlag and v.specialFlag == 1 then
		-- 	imgStr = v.baseSp
		-- else
		imgStr = buildDecorateVoApi:getSkinImg(v.id)				
		-- end
		local skinSp = LuaCCSprite:createWithSpriteFrameName(imgStr,touchHandler)
		
		clipper:addChild(skinSp)

		skinSp:setAnchorPoint(ccp(0.5,0.5))
		self.skinSprTb[k] = skinSp
		skinSp:setTouchPriority(-(self.layerNum-1)*20-4)
		skinSp.skinId = v.id
		if k ~= self.curchose then
			skinSp:setScale(0.5)
			skinSp:setOpacity(255*0.5)
			if v.id =="b11" or v.id == "b12" then
				skinSp:setScale(0.4)
			elseif v.id =="b13" then
				skinSp:setScale(0.35)
			end
		else
			skinSp:setScale(0.8)
			if v.id =="b11" or v.id == "b12" then
				skinSp:setScale(0.6)
			elseif v.id == "b13" then
				skinSp:setScale(0.5)
			end
		end

		skinSp:setPosition(ccp(9999,20))
		for kk,vv in pairs(self.spriteArr) do
			if vv ==  k then
				skinSp:setPosition(self.downPos[kk])
			end
		end
	end

	local function leftHandler( ... )
		if self.spriteArr[1] < 1 or not self.spriteArr[1] then
			do return end
		else
			if self.downFlag == 1 then
				self:moveDown(-1)
			end
		end
	end

	local function rightHandler( ... )
		if self.spriteArr[3] > #skinTb or not self.spriteArr[3] then
			do return end
		else
			if self.downFlag == 1 then
				self:moveDown(1)
			end
		end
	end

	local leftArrowDown = G_createBotton(self.downBg,ccp(30,self.downBg:getContentSize().height-110),nil,"leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",leftHandler,0.8,-(self.layerNum-1)*20-2)
	local rightArrowDown = G_createBotton(self.downBg,ccp(self.downBg:getContentSize().width-30,self.downBg:getContentSize().height-110),nil,"leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",rightHandler,0.8,-(self.layerNum-1)*20-2)
	rightArrowDown:setRotation(180)	

	local leftTouch = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), leftHandler)
	leftTouch:setContentSize(CCSizeMake(65,200))
	leftTouch:setAnchorPoint(ccp(0,1))
	leftTouch:setPosition(ccp(0,self.downBg:getContentSize().height))
	leftTouch:setTouchPriority(-(self.layerNum-1)*20-4)
	leftTouch:setVisible(false)
	self.downBg:addChild(leftTouch)
	local rightTouch = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), rightHandler)
	rightTouch:setContentSize(CCSizeMake(65,200))
	rightTouch:setAnchorPoint(ccp(1,1))
	rightTouch:setPosition(ccp(self.downBg:getContentSize().width,self.downBg:getContentSize().height))
	rightTouch:setTouchPriority(-(self.layerNum-1)*20-4)
	rightTouch:setVisible(false)
	self.downBg:addChild(rightTouch)

    local moveTo=CCMoveBy:create(0.5,ccp(-20,0))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(moveTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)

    local moveTo2=CCMoveBy:create(0.5,ccp(20,0))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(moveTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)

    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
    leftArrowDown:runAction(CCRepeatForever:create(seq))


    local moveTo=CCMoveBy:create(0.5,ccp(20,0))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(moveTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)

    local moveTo2=CCMoveTo:create(0.5,ccp(-20,0))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(moveTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)

    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
	rightArrowDown:runAction(CCRepeatForever:create(seq))

end


function buildDecorateDialog:refreshAttr(detailInfo)
	self.timeLb = nil
	self.endTimer = nil

	local nowLevel 
	local maxLevel 
	local lvLimit 
	local timeStr 
	local endTimer --限时皮肤的结束时间戳

	-- if not detailInfo.specialFlag then
	nowLevel = detailInfo.nowLevel
	maxLevel = detailInfo.lvMax
	lvLimit = detailInfo.timeLimit --配置约定，当传入0时默认皮肤使用期限为永久，大于0时是限时皮肤拥有时长
	timeStr = buildDecorateVoApi:getTimeStr(lvLimit)
	endTimer = detailInfo.endTimer or 0
	-- end

	local strSize = 20

	if G_isAsia() == false then
		strSize = 18
	end
	local btSize  = 25
	if G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage == "ar" then
		btSize = 18
	end
	if self.curIndex == 1 then
		local function getHandler( ... )
			-- 有跳转
			if detailInfo.skip then
				-- 有多版本的支持
				if detailInfo.ver then
					if activityVoApi:getVoApiByType(detailInfo.skip) and activityVoApi:getVoApiByType(detailInfo.skip).getVersion then
						local acVoApi = activityVoApi:getVoApiByType(detailInfo.skip)
						local version = acVoApi:getVersion()
						local jumpFlag = 0
						for k,v in pairs(detailInfo.ver) do
							if v == version then
								local acVo = activityVoApi:getActivityVo(detailInfo.skip)
								if activityVoApi:isStart(acVo)==true then
									activityAndNoteDialog:closeAllDialog()
							    	jump_assignActivity(acVo)
							    	jumpFlag = 1
							    end
							end
						end
						if jumpFlag == 0 then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_notstart"),30)
						end
					else
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_notstart"),30)
					end
				else
					local acVo = activityVoApi:getActivityVo(detailInfo.skip)
					if activityVoApi:isStart(acVo)==true then
						activityAndNoteDialog:closeAllDialog()
				    	jump_assignActivity(acVo)
			    	else
				    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_notstart"),30)
				    end
			    end
			elseif detailInfo.id=="b10" then --发射基地装扮跳转
				if exerWarVoApi:isOpen()==0 then
					activityAndNoteDialog:closeAllDialog()
				end
				exerWarVoApi:showExerWarDialog(self.layerNum)
			end
		end
		local getbutton = G_createBotton(self.downBg,ccp(self.downBg:getContentSize().width/2,(G_getIphoneType()==G_iphone4) and 80 or 100),{getlocal("decorateGet"),btSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getHandler,0.8,-(self.layerNum-1)*20-2)
		for k,v in pairs(detailInfo.attType) do
			local valueStr = detailInfo.value[k][nowLevel] < 1 and tostring(detailInfo.value[k][nowLevel]*100).."%" or detailInfo.value[k][nowLevel]
			-- 类型为5特殊处理
			local adaWidth = 0
			if v == 5 then
				valueStr = math.floor(valueStr/60)
				adaWidth = 100
			end
			local attstr = "+"..valueStr
			if v == 9 then --受到戏谑攻击 
				attstr = getlocal("text_zerobattleDamage")
			end
			if type(detailInfo.experienceTimer) == "number" and detailInfo.experienceTimer > 0 then --体验皮肤
				attstr = "+0"
			end
			local attrLabel = GetTTFLabelWrap(getlocal("decorateAttr"..v),strSize,CCSizeMake(220+adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			local valueLabel = GetTTFLabelWrap(attstr,strSize,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			attrLabel:setAnchorPoint(ccp(0,0.5))
			valueLabel:setAnchorPoint(ccp(0,0.5))
			attrLabel:addChild(valueLabel)
			valueLabel:setPosition(ccp(attrLabel:getContentSize().width,attrLabel:getContentSize().height/2))
			attrLabel:setPosition(ccp(self.downBg:getContentSize().width/2-120-adaWidth,self.downBg:getContentSize().height-((G_getIphoneType()==G_iphone4) and 275 or 300)-(k-1)*40+self.adaH))
			self.downBg:addChild(attrLabel)
			if v == 9 and G_isGermany() == true then --德国不显示戏谑技能
				attrLabel:setVisible(false)
				valueLabel:setVisible(false)
			end
		end
	else
		local function useHandler( ... )
			local nowUse = buildDecorateVoApi:getNowUse()
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then
					if sData.data and sData.data.ext then
						buildDecorateVoApi:useSkin(detailInfo.id)
						self:refreshSp(true)
						worldBaseVoApi:changeMySkinInfo(detailInfo.id)
						worldScene:changeBaseSkin()
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("decorateUseSucess"),30)
						if detailInfo.id == "b11" or detailInfo.id == "b12"  or nowUse == "b11" or nowUse =="b12" or detailInfo.id =="b13" or nowUse == "b13" then
							local data={btype=7}
			                eventDispatcher:dispatchEvent("baseBuilding.build.refresh",data)
			            end
					end     
				end
			end
			socketHelper:buildDecorateUse(detailInfo.id,callback)
		end
		local function upgradeHandler( ... )
			if bagVoApi:getItemNumId(tonumber(RemoveFirstChar(exteriorCfg.upgradeCostItem))) >= detailInfo.upgradeCost[nowLevel] then
				local function callback(fn,data)
					local ret,sData = base:checkServerData(data)
					if ret==true then
						if sData.data and sData.data.ext then
							buildDecorateVoApi:upgradeSkin(detailInfo.id)
							bagVoApi:useItemNumId(tonumber(RemoveFirstChar(exteriorCfg.upgradeCostItem)),detailInfo.upgradeCost[nowLevel])
							self:refreshSp(true)
							if detailInfo.id == "b5" then
								-- 刷新一下世界地图上面进度条显示
								goldMineVoApi:getGatherResList()
							end
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("decorateUpSucess"),30)
						end     
					end
				end
				socketHelper:buildDecorateUpgrade(detailInfo.id,callback)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notenoughprop"),30)
			end
		end

		-- if not detailInfo.specialFlag then

			local useButton = G_createBotton(self.downBg,ccp(self.downBg:getContentSize().width*2/3+60,(G_getIphoneType()==G_iphone4) and 80 or 100),{getlocal("use"),btSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",useHandler,0.8,-(self.layerNum-1)*20-2)
			local upgradeButton = G_createBotton(self.downBg,ccp(self.downBg:getContentSize().width*1/3-60,(G_getIphoneType()==G_iphone4) and 80 or 100),{getlocal("upgradeBuild"),btSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHandler,0.8,-(self.layerNum-1)*20-2)

			-- if buildDecorateVoApi:isSpecialDaySkin() ~= false  then
			-- 	useButton:setEnabled(false)
			-- else
				if detailInfo.useStatus and detailInfo.useStatus == 1 then
					useButton:setEnabled(false)
					local btnLabel = tolua.cast(useButton:getChildByTag(101),"CCLabelTTF")
					if btnLabel then
						btnLabel:setString(getlocal("decorateUse"))
					end
				end
			-- end

			if nowLevel == maxLevel then
				upgradeButton:setEnabled(false)
				local btnLabel = tolua.cast(upgradeButton:getChildByTag(101),"CCLabelTTF")
				if btnLabel then
					btnLabel:setString(getlocal("decorateMax"))
				end
			else
				local item = GetItembyPid(exteriorCfg.upgradeCostItem)[1]
		        local function showNewPropInfo()
		       		G_showNewPropInfo(self.layerNum+1,true,true,nil,item,true)
		   		end
		        local consumeSp,scale=G_getItemIcon(item,60,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
				consumeSp:setTouchPriority(-(self.layerNum-1)*20-4)
				consumeSp:setPosition(ccp(self.downBg:getContentSize().width*1/3-110-self.adaW,(G_getIphoneType()==G_iphone4) and 140 or 180))
				self.downBg:addChild(consumeSp)
				
				for i=1,2 do
					local colorTb 
					if detailInfo.upgradeCost[nowLevel] <= bagVoApi:getItemNumId(tonumber(RemoveFirstChar(exteriorCfg.upgradeCostItem))) then
						colorTb= {nil,G_ColorGreen,nil}
					else
						colorTb = {nil,G_ColorRed,nil}
					end
					local descStr = getlocal("decorateNumPrompt",{bagVoApi:getItemNumId(tonumber(RemoveFirstChar(exteriorCfg.upgradeCostItem))),detailInfo.upgradeCost[nowLevel]})
					local numLb = G_getRichTextLabel(descStr,colorTb,25,300,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					numLb:setAnchorPoint(ccp(0,1))
					local adaW = 0
					if G_getCurChoseLanguage() == "ar" then
						adaW = 260
					end
					numLb:setPosition(ccp(consumeSp:getContentSize().width+10-adaW,consumeSp:getContentSize().height/2+10))
					consumeSp:addChild(numLb)
				end
			end
			for k,v in pairs(detailInfo.attType) do
				-- 小于1则认为加的是百分比属性
				local valueStr = detailInfo.value[k][nowLevel] < 1 and tostring(detailInfo.value[k][nowLevel]*100).."%" or detailInfo.value[k][nowLevel]
				local adaWidth = 0
				if v == 5 then
					valueStr = math.floor(valueStr/60)
					adaWidth = 100
				end
				local attstr = "+"..valueStr
				if v == 9 then --受到戏谑攻击 
					attstr = getlocal("text_zerobattleDamage")
				end
				if type(detailInfo.experienceTimer) == "number" and detailInfo.experienceTimer > 0 then --体验皮肤
					attstr = "+0"
				end
				local attrLabel = GetTTFLabelWrap(getlocal("decorateAttr"..v),strSize,CCSizeMake(220+adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
				local valueLabel = GetTTFLabelWrap(attstr,strSize,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
				attrLabel:setAnchorPoint(ccp(0,0.5))
				valueLabel:setAnchorPoint(ccp(0,0.5))
				attrLabel:addChild(valueLabel)
				valueLabel:setPosition(ccp(attrLabel:getContentSize().width,attrLabel:getContentSize().height/2))
				self.downBg:addChild(attrLabel)
				if v == 9 and G_isGermany() == true then --德国不显示戏谑技能
					attrLabel:setVisible(false)
					valueLabel:setVisible(false)
				end
				if nowLevel < maxLevel then
					local adaW = 0
					if G_getCurChoseLanguage() == "ar" then
						adaW = 100
					end
					attrLabel:setPosition(ccp(self.downBg:getContentSize().width/2-150-adaW-adaWidth,self.downBg:getContentSize().height-((G_getIphoneType()==G_iphone4) and 275 or 300)-(k-1)*40+self.adaH))
					local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
					arrowSp:setAnchorPoint(ccp(1,0.5))
					arrowSp:setPosition(ccp(attrLabel:getContentSize().width+80+adaW/2,attrLabel:getContentSize().height/2))
					attrLabel:addChild(arrowSp)
					local valueStr = detailInfo.value[k][nowLevel+1] < 1 and tostring(detailInfo.value[k][nowLevel+1]*100).."%" or detailInfo.value[k][nowLevel+1]
					if v == 5 then
						valueStr = math.floor(valueStr/60)
					end
					local attstr = "+"..valueStr
					local nextAttrLabel = GetTTFLabelWrap(attstr,strSize,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
					nextAttrLabel:setAnchorPoint(ccp(1,0.5))
					nextAttrLabel:setPosition(ccp(attrLabel:getContentSize().width+160+adaW/4,attrLabel:getContentSize().height/2))
					nextAttrLabel:setColor(G_ColorGreen)
					attrLabel:addChild(nextAttrLabel)
				else
					attrLabel:setPosition(ccp(self.downBg:getContentSize().width/2-120-adaWidth,self.downBg:getContentSize().height-((G_getIphoneType()==G_iphone4) and 275 or 300)-(k-1)*40+self.adaH))
				end
			end
		-- else
		-- 	local useButton = G_createBotton(self.downBg,ccp(self.downBg:getContentSize().width*2/3+60,100),{getlocal("use"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",useHandler,0.8,-(self.layerNum-1)*20-2)
		-- 	useButton:setEnabled(false)
		-- 	local btnLabel = tolua.cast(useButton:getChildByTag(101),"CCLabelTTF")
		-- 	if btnLabel then
		-- 		btnLabel:setString(getlocal("decorateUse"))
		-- 	end
		-- 	local valueLabel = GetTTFLabelWrap(getlocal("activeSkinNoAttr"),strSize,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		-- 	valueLabel:setAnchorPoint(ccp(0.5,0.5))
		-- 	valueLabel:setPosition(ccp(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height-300+5+self.adaH))
		-- 	valueLabel:setColor(G_ColorGreen)
		-- 	self.downBg:addChild(valueLabel)
		-- end

		if lvLimit > 0 or (type(detailInfo.experienceTimer) == "number" and detailInfo.experienceTimer > 0) then --策划约定，当是限时皮肤时直接取最大值
			if endTimer <= base.serverTime then --该皮肤已过期
				timeStr = getlocal("expireDesc")
			else
				timeStr = G_formatActiveDate(endTimer - base.serverTime)
			end
			self.endTimer = endTimer
		end
	end

	--[[]
	-- 富文本没有加粗的方法 所以创建两次达到加粗的效果
	for i=1,2 do
		local colorTb = {nil,G_ColorGreen,nil}
		-- if detailInfo.specialFlag then
		-- 	if detailInfo.specialFlag == 1 then
		-- 		timeStr = getlocal("wjsSkinTimeLimit")
		-- 	end
		-- end
		local descLb,lbHeight = G_getRichTextLabel(getlocal("decorateTimeLimit",{timeStr}),colorTb,strSize,300,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0.5,1))
		local attNum = detailInfo.attType and #detailInfo.attType or 1
		descLb:setPosition(ccp(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height-300-attNum*40+10-self.adaH/2))
		self.downBg:addChild(descLb)
	end
	--]]

	local timeLimitLb = GetTTFLabel(getlocal("use_deadline"), strSize, true)
	local timeLb = GetTTFLabel(timeStr, strSize, true)
	timeLimitLb:setAnchorPoint(ccp(0, 1))
	timeLb:setAnchorPoint(ccp(0, 1))
	timeLb:setColor(G_ColorGreen)
	local attNum = detailInfo.attType and #detailInfo.attType or 1
	timeLimitLb:setPosition((self.downBg:getContentSize().width - (timeLimitLb:getContentSize().width + timeLb:getContentSize().width)) / 2, self.downBg:getContentSize().height-((G_getIphoneType()==G_iphone4) and 230 or 300)-attNum*40+10-self.adaH/2)
	timeLb:setPosition(timeLimitLb:getPositionX() + timeLimitLb:getContentSize().width, timeLimitLb:getPositionY())
	self.downBg:addChild(timeLimitLb)
	self.downBg:addChild(timeLb)
	if self.curIndex ~= 1 then
		self.timeLb = timeLb
	end
end

function buildDecorateDialog:showDetail( ... )
	if self.downFlag == 1 then
		if self.detailBtn and tolua.cast(self.detailBtn,"LuaCCSprite") then 
			self.downFlag = 0
			if self.showStatus == 0 then
				self:getAllAttr()
				local function moveCallback( ... )
					local dialogBg = self.detailBtn:getChildByTag(1016)
					dialogBg:setVisible(true)
					dialogBg:setPosition(ccp(self.detailBtn:getContentSize().width/2,0))
					local move = CCMoveTo:create(0.25,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-90-300-60-10-50-150))
					local function callBack( ... )
						self.showStatus = 1
						self.downFlag = 1
					end
					local callfunc = CCCallFunc:create(callBack)
					local seque = CCSequence:createWithTwoActions(move,callfunc)
					self.detailBtn:runAction(seque)
				end
				self:buttonAction(moveCallback)
			else
				local function moveCallback( ... )
					local dialogBg = self.detailBtn:getChildByTag(1016)
					local acArr = CCArray:create()
					local move = CCMoveTo:create(0.25,ccp(G_VisibleSizeWidth/2,30))
					local function callBack( ... )
						self.showStatus = 0
						dialogBg:setVisible(false)
						self.downFlag = 1
					end
					local callfunc = CCCallFunc:create(callBack)
					acArr:addObject(move)
					acArr:addObject(callfunc)
					local seque=CCSequence:create(acArr)
					self.detailBtn:runAction(seque)
				end
				self:buttonAction(moveCallback)
			end
		end
	end
end

function buildDecorateDialog:attEventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        -- return CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,G_VisibleSizeHeight-90-300-60-10-50-170-30)
        local attrTb = buildDecorateVoApi:getAllAttr()
        return CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,SizeOfTable(attrTb) * 50)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local attrTb = buildDecorateVoApi:getAllAttr()
        -- cell:setContentSize(CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,G_VisibleSizeHeight-90-300-60-10-50-170-30))
        cell:setContentSize(CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,SizeOfTable(attrTb) * 50))
		for k,v in pairs(attrTb) do

			local strSize = 22
			if G_isAsia() == false then
				strSize = 18
			end
			local value = (v.value ~= 0 and v.value < 1) and tostring(v.value*100).."%" or v.value
			local attstr = "+"..value
			if v.id == 9 then --受到戏谑攻击 
				attstr = getlocal("text_zerobattleDamage")
			end
			local numLabel = GetTTFLabel(attstr,strSize,true)
			numLabel:setAnchorPoint(ccp(0,0.5))
			numLabel:setPosition(ccp(500,cell:getContentSize().height-20-(k-1)*50))
			cell:addChild(numLabel)

			local attrLabel = GetTTFLabelWrap(getlocal("decorateAttr"..v.id),strSize,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			attrLabel:setAnchorPoint(ccp(0,0.5))
			local adaW = 0
			if G_getCurChoseLanguage() == "ar" then
				adaW = 100
			end
			attrLabel:setPosition(ccp(150-adaW,cell:getContentSize().height-20-(k-1)*50))
			cell:addChild(attrLabel)
			if v.id == 9 and G_isGermany() == true then --德国不显示戏谑技能
				numLabel:setVisible(false)
				attrLabel:setVisible(false)
			end
		end
        return cell
    elseif fn=="ccTouchBegan" then
    	return true
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end
end

function buildDecorateDialog:getAllAttr()

	local dialogBg = self.detailBtn:getChildByTag(1016)
	if dialogBg then
		dialogBg:removeFromParentAndCleanup(true)
	end
	local function touchHandler()
		do return end
	end

	dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()
		if self.attTv and self.attTv:getIsScrolled() == false then
			self:showDetail()
		end
	end)
    dialogBg:setContentSize(CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,G_VisibleSizeHeight-90-300-60-10-50-170))
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-4)
    self.detailBtn:addChild(dialogBg)
    dialogBg:setTag(1016)
    dialogBg:setAnchorPoint(ccp(0.5,1))
    dialogBg:setPosition(ccp(self.detailBtn:getContentSize().width/2,0))
    dialogBg:setVisible(false)

	local function callBack( ... )
    	return self:attEventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.attTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake((G_VisibleSizeWidth-40)/(G_VisibleSizeWidth-30)*G_VisibleSizeWidth,G_VisibleSizeHeight-90-300-60-10-50-170-30),nil)
	self.attTv:setPosition(ccp(0,15))
	self.attTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.attTv:setMaxDisToBottomOrTop(120)
	dialogBg:addChild(self.attTv)

end


function buildDecorateDialog:buttonAction(endCallback)

	if not endCallback then
		do return end
	end
	if not self.detailBtn then
		do return end
	end
	local scaleSmall = CCScaleTo:create(0.1,0.9)
	local delay = CCDelayTime:create(0.1)
	local scaleBig = CCScaleTo:create(0.1,(G_VisibleSizeWidth-30)/G_VisibleSizeWidth)
	local acArr = CCArray:create()
	acArr:addObject(scaleSmall)
	acArr:addObject(delay)
	acArr:addObject(scaleBig)
	local seque=CCSequence:create(acArr)
	local callFunc = CCCallFunc:create(endCallback)
	local seq = CCSequence:createWithTwoActions(seque,callFunc)
	self.detailBtn:runAction(seq)

end

function buildDecorateDialog:refreshStar(starNum,maxLevel)
	if self.upBg then
		local backSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
		backSpire:setContentSize(CCSizeMake(40*maxLevel,40))
		backSpire:setAnchorPoint(ccp(0.5,0))
		backSpire:setPosition(ccp(self.upBg:getContentSize().width/2,10))
		backSpire:setOpacity(0)
		self.upBg:addChild(backSpire)
		for i=1,maxLevel do
			local starSp
			if i <= starNum then
				starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
			else
				starSp = CCSprite:createWithSpriteFrameName("starIconEmpty.png")
			end
			starSp:setAnchorPoint(ccp(0,0.5))
			starSp:setPosition(ccp(2+40*(i-1),20))
			backSpire:addChild(starSp)
		end
	end
end

function buildDecorateDialog:refeshLb(bid,detailInfo)
	if self.upBg then
		-- local str  = "decorateCityName"..bid
		-- if not detailInfo.specialFlag then
		-- 	str = "decorateCityName"..bid
		-- else
		-- 	str = detailInfo.extrName
		-- end
		local titleLb = GetTTFLabel(buildDecorateVoApi:getSkinName(detailInfo),25,true)
		titleLb:setAnchorPoint(ccp(0.5,1))
		titleLb:setPosition(ccp(self.upBg:getContentSize().width/2,self.upBg:getContentSize().height-10))
		self.upBg:addChild(titleLb)
	end
end




function buildDecorateDialog:tick( ... )
	if self then
		if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
			if type(self.endTimer) == "number" then
				if self.endTimer <= base.serverTime then --该皮肤已过期
					self.timeLb:setString(getlocal("expireDesc"))
				else
					self.timeLb:setString(G_formatActiveDate(self.endTimer - base.serverTime))
				end
			end
		end
	end
end

function buildDecorateDialog:dispose( ... )
	eventDispatcher:removeEventListener("buildDecorateDialog.refreshSp",self.eventListener)
	self.eventListener = nil
	-- body
	spriteController:removePlist("public/reportyouhua.plist")
	-- spriteController:removePlist("public/skinFlash.plist")
	spriteController:removePlist("public/decorate_special.plist")
	spriteController:removeTexture("public/reportyouhua.png")
	-- spriteController:removeTexture("public/skinFlash.png")
	spriteController:removeTexture("public/decorate_special.png")
	spriteController:removePlist("public/youhuaUI3.plist")
	spriteController:removePlist("public/acydcz_images.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removeTexture("public/acydcz_images.png")
	if self.circelAc and self.circelAc.stop then
		self.circelAc:stop()
		self.circelAc=nil
	end    
	self.exchangeCost =nil
	self.lastSkinTb = nil
	self.lastSkinLv = nil
end