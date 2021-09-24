--抽军徽的面板
planeSkillGetDialog=commonDialog:new()

function planeSkillGetDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.numCfg = nil
	nc.freeFlag = nil--当前是否显示为免费，刷新时需要重置按钮文字
	nc.freeBtnItem = nil--刷新时需要重置按钮文字的按钮
	nc.freeBtnItemxitu = nil
	nc.freeIcon = nil
	nc.freeCost = nil

	nc.freeIconxitu = nil
	nc.freeCostxitu = nil

	nc.lastGetType = nil--上一次抽取的消费方式
	nc.lastGetIndex= nil--上一次抽取的index

	nc.addParticleTb=nil --添加的粒子
	nc.rewardLayer = nil --获取面板
	nc.getTimeTick = nil--给后端发送抽取请求的等待时间
	nc.costLbTb={}
	nc.showFlag=false
	nc.freeIconTb={}
	nc.freeBtnTb={}
	nc.freeTipSpTb={}
	nc.lotteryFlag=false

	return nc
end

function planeSkillGetDialog:initTableView()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
    spriteController:addTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
    if planeRefitVoApi:isOpen() == true then
    	spriteController:addPlist("public/planeRefitImages.plist")
        spriteController:addTexture("public/planeRefitImages.png")
    end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self.lotteryBgH=252
	self.numCfg = planeVoApi:getSkillNumCfg()
	self:initBg()
	self:initDesc()
	self:initR5Get()
	self:initGemGet()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

   	if otherGuideMgr.isGuiding and otherGuideMgr.curStep==34 then
	    otherGuideMgr:toNextStep()
    end
end

function planeSkillGetDialog:initDesc()
	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr={}
		for i=1,3 do
			table.insert(tabStr,getlocal("planeSkill_get_info_"..i))
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
	local infoItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	local infoBtn=CCMenu:createWithItem(infoItem)
	if planeRefitVoApi:isOpen() == true then
		infoBtn:setPosition(G_VisibleSizeWidth - 55, G_VisibleSizeHeight - 130)
	else
		infoBtn:setPosition(ccp(G_VisibleSizeWidth-85,400))
	end
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	local rect=CCSizeMake(100,100)
    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),showInfo)
    addTouchBg:setTouchPriority(-(self.layerNum-1)*20-4)
    addTouchBg:setContentSize(rect)
    addTouchBg:setOpacity(0)
    addTouchBg:setPosition(infoBtn:getPosition())
    self.bgLayer:addChild(addTouchBg)
	self.bgLayer:addChild(infoBtn)
	if planeRefitVoApi:isOpen() == true then
		local function onClickDecompose(tag, obj)
			if G_checkClickEnable() == false then
				do return end
			else
				base.setWaitTime = G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			planeVoApi:showBulkSaleDialog(self.layerNum + 1)
		end
		local decomposeItem = GetButtonItem("decomposeBtn.png", "decomposeBtn_Down.png", "decomposeBtn.png", onClickDecompose)
		local decomposeBtn = CCMenu:createWithItem(decomposeItem)
		decomposeBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		decomposeBtn:setPosition(G_VisibleSizeWidth - 55, 360)
		self.bgLayer:addChild(decomposeBtn)
	end
end

function planeSkillGetDialog:initBg()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
	local function nilFunc()
	end
	local lotteryBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),nilFunc)
	lotteryBg:setAnchorPoint(ccp(0.5,0))
	lotteryBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-26,self.lotteryBgH+40))
	lotteryBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
	self.bgLayer:addChild(lotteryBg)

	local actionBg=CCSprite:create("public/plane/planeSkillLotteryBg.jpg")
	actionBg:setAnchorPoint(ccp(0.5,1))
	actionBg:setPosition(G_VisibleSizeWidth/2,20 + self.panelLineBg:getContentSize().height)
	if G_getIphoneType() == G_iphoneX then
		actionBg:setScaleY(1.5)
	elseif G_getIphoneType() == G_iphone5 then
		actionBg:setScaleY(1.31)
	end
	self.bgLayer:addChild(actionBg)
	self.actionBg=actionBg
end

--水晶消耗
function planeSkillGetDialog:initR5Get()
	local bgWidth=(G_VisibleSizeWidth-70)/2
	local function nilFunc()
	end
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	background:setContentSize(CCSizeMake(bgWidth,self.lotteryBgH))
	background:setAnchorPoint(ccp(0,0))
	background:setPosition(ccp(30,50))
	self.bgLayer:addChild(background,2)
	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp1:setPosition(ccp(2,background:getContentSize().height/2))
	background:addChild(pointSp1)
	local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp2:setPosition(ccp(background:getContentSize().width-2,background:getContentSize().height/2))
	background:addChild(pointSp2)

	local tempScale = 0.7
	local tempBtnSize = 24/tempScale
	local tempBaseScale = 1/tempScale

	local bgSize=background:getContentSize()
	local costOne = planeVoApi:getSkillCost(2,1)-- 获取当前使用稀土抽取1次的消耗
	local function getOneByMoney()
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:btnClickToGet(2,1)	
	end
	local btnStr=getlocal("emblem_getBtnLb",{self.numCfg[2][1]})
	local freeBtnItemxitu=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getOneByMoney,nil,costOne>0 and btnStr or getlocal("daily_lotto_tip_2"),tempBtnSize,6)
	freeBtnItemxitu:setScale(tempScale)
	local oneBtn=CCMenu:createWithItem(freeBtnItemxitu)
	oneBtn:setPosition(ccp(bgSize.width/2,bgSize.height/2+45))
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-6)
	background:addChild(oneBtn,2)

	local freexituTipSp=G_createTipSp(freeBtnItemxitu)
	if costOne==0 then
		freexituTipSp:setVisible(true)
	end

	local freeIconxitu=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	freeIconxitu:setAnchorPoint(ccp(0,0.5))
	freeBtnItemxitu:addChild(freeIconxitu,2)

	local freeCostxitu=GetTTFLabel(FormatNumber(costOne),25)
	freeCostxitu:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGold()<costOne then
		freeCostxitu:setColor(G_ColorRed)
	else
		freeCostxitu:setColor(G_ColorYellowPro)
	end
	freeBtnItemxitu:addChild(freeCostxitu,2)
	freeCostxitu:setTag(21)
	freeIconxitu:setScale(tempBaseScale)
	freeCostxitu:setScale(tempBaseScale)
	local width1=(freeIconxitu:getContentSize().width+freeCostxitu:getContentSize().width)*tempBaseScale
	freeIconxitu:setPosition(ccp(freeBtnItemxitu:getContentSize().width/2-width1/2,freeBtnItemxitu:getContentSize().height+freeIconxitu:getContentSize().height/2*tempBaseScale))
	freeCostxitu:setPosition(ccp(freeIconxitu:getPositionX() + freeIconxitu:getContentSize().width * tempBaseScale,freeIconxitu:getPositionY()))
	
	local function getManyByMoney()
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:btnClickToGet(2,2)
	end
	local btnStr=getlocal("emblem_getBtnLb",{self.numCfg[2][2]})
	local manyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getManyByMoney,nil,btnStr,tempBtnSize)
	manyItem:setScale(tempScale)
	local manyBtn=CCMenu:createWithItem(manyItem)
	manyBtn:setPosition(ccp(bgSize.width/2,bgSize.height/2-75))
	manyBtn:setTouchPriority(-(self.layerNum-1)*20-6)
	background:addChild(manyBtn,2)
	
	local iconGold2=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	iconGold2:setAnchorPoint(ccp(0,0.5))
	manyItem:addChild(iconGold2,2)
	
	local costMany=planeVoApi:getSkillCost(2,2)-- 获取当前使用稀土抽取多次的消耗
	local costLbMany=GetTTFLabel(FormatNumber(costMany),25)
	costLbMany:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGold() < costMany then
		costLbMany:setColor(G_ColorRed)
	else
		costLbMany:setColor(G_ColorYellowPro)
	end
	manyItem:addChild(costLbMany,2)
	costLbMany:setTag(22)
	iconGold2:setScale(tempBaseScale)
	costLbMany:setScale(tempBaseScale)
	local width2=(iconGold2:getContentSize().width+costLbMany:getContentSize().width) * tempBaseScale
	iconGold2:setPosition(ccp(manyItem:getContentSize().width/2-width2/2,manyItem:getContentSize().height+iconGold2:getContentSize().height/2*tempBaseScale))
	costLbMany:setPosition(ccp(iconGold2:getPositionX() + iconGold2:getContentSize().width * tempBaseScale,iconGold2:getPositionY()))
	self.costLbTb[2]={freeCostxitu,costLbMany}
	self.freeIconTb[2]={freeIconxitu,iconGold2}
	self.freeBtnTb[2]={freeBtnItemxitu,manyItem}
	self.freeTipSpTb[2]=freexituTipSp
end

--金币消耗
function planeSkillGetDialog:initGemGet()
	local bgWidth=(G_VisibleSizeWidth-70)/2
	local function nilFunc()
	end
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	background:setContentSize(CCSizeMake(bgWidth,self.lotteryBgH))
	background:setAnchorPoint(ccp(0,0))
	background:setPosition(ccp(30+bgWidth+10,50))
	self.bgLayer:addChild(background,2)
	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp1:setPosition(ccp(2,background:getContentSize().height/2))
	background:addChild(pointSp1)
	local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp2:setPosition(ccp(background:getContentSize().width-2,background:getContentSize().height/2))
	background:addChild(pointSp2)

	local bgSize=background:getContentSize()

	local tempScale = 0.7
	local tempBtnSize = 24/tempScale
	local tempBaseScale = 1/tempScale

	local costOne=planeVoApi:getSkillCost(1,1)---- 获取当前使用钻石抽取1次的消耗
	local function getOneByGem()
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:btnClickToGet(1,1)
	end
	
	local btnStr=getlocal("emblem_getBtnLb",{self.numCfg[1][1]})
	local freeBtnItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getOneByGem,nil,costOne>0  and btnStr or getlocal("daily_lotto_tip_2"),tempBtnSize,6)
	freeBtnItem:setScale(tempScale)
	local oneBtn=CCMenu:createWithItem(freeBtnItem)
	oneBtn:setPosition(ccp(bgSize.width/2,bgSize.height/2+45))
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-6)
	background:addChild(oneBtn,2)

	local freegoldTipSp=G_createTipSp(freeBtnItem)
	if costOne==0 then
		freegoldTipSp:setVisible(true)
	end

	local freeIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	freeIcon:setAnchorPoint(ccp(0,0.5))
	freeBtnItem:addChild(freeIcon,2)
	
	
	local freeCost=GetTTFLabel(tostring(costOne),25)
	freeCost:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGems() < costOne then
		freeCost:setColor(G_ColorRed)
	else
		freeCost:setColor(G_ColorYellowPro)
	end
	freeBtnItem:addChild(freeCost,2)
	freeCost:setTag(11)
	freeIcon:setScale(tempBaseScale)
	freeCost:setScale(tempBaseScale)
	local width1=(freeIcon:getContentSize().width+freeCost:getContentSize().width)*tempBaseScale
	freeIcon:setPosition(ccp(freeBtnItem:getContentSize().width/2-width1/2,freeBtnItem:getContentSize().height+freeIcon:getContentSize().height/2*tempBaseScale))
	freeCost:setPosition(ccp(freeIcon:getPositionX() + freeIcon:getContentSize().width * tempBaseScale,freeIcon:getPositionY()))

	local function getManyByGem()
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:btnClickToGet(1,2)
	end
	local btnStr=getlocal("emblem_getBtnLb",{self.numCfg[1][2]})
	local manyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getManyByGem,2,btnStr,tempBtnSize)
	manyItem:setScale(tempScale)
	local manyBtn=CCMenu:createWithItem(manyItem)
	manyBtn:setPosition(ccp(bgSize.width/2,bgSize.height/2-75))
	manyBtn:setTouchPriority(-(self.layerNum-1)*20-6)
	background:addChild(manyBtn,2)
	if(costOne==0)then
		local btnLb=tolua.cast(freeBtnItem:getChildByTag(6),"CCLabelTTF")
		btnLb:setColor(G_ColorYellowPro)
		freeIcon:setVisible(false)
		freeCost:setVisible(false)

		manyItem:setEnabled(false)
	else
		manyItem:setEnabled(true)
	end

	local iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold2:setAnchorPoint(ccp(0,0.5))
	manyItem:addChild(iconGold2,2)
	
	local costMany = planeVoApi:getSkillCost(1,2)---- 获取当前使用钻石抽取多次的消耗
	local costLbMany=GetTTFLabel(tostring(costMany),25)
	costLbMany:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGems() < costMany then
		costLbMany:setColor(G_ColorRed)
	else
		costLbMany:setColor(G_ColorYellowPro)
	end
	manyItem:addChild(costLbMany,2)
	costLbMany:setTag(12)
	iconGold2:setScale(tempBaseScale)
	costLbMany:setScale(tempBaseScale)
	local width2=(iconGold2:getContentSize().width+costLbMany:getContentSize().width)*tempBaseScale
	iconGold2:setPosition(ccp(manyItem:getContentSize().width/2-width2/2,manyItem:getContentSize().height+iconGold2:getContentSize().height/2*tempBaseScale))
	costLbMany:setPosition(ccp(iconGold2:getPositionX() + iconGold2:getContentSize().width * tempBaseScale,iconGold2:getPositionY()))
	self.costLbTb[1]={freeCost,costLbMany}
	self.freeIconTb[1]={freeIcon,iconGold2}
	self.freeBtnTb[1]={freeBtnItem,manyItem}
	self.freeTipSpTb[1]=freegoldTipSp
   	if otherGuideMgr.isGuiding and otherGuideMgr.curStep==34 then
	    otherGuideMgr:setGuideStepField(35,freeBtnItem,true)
    end
end

--玩家点击按钮后，往后台发送请求
function planeSkillGetDialog:btnClickToGet(costType,numIndex)
	self:disposeActionLayer()
	self:disposeRewardLayer()
	local cost =  planeVoApi:getSkillCost(costType,numIndex) -- 获取当前使用金币/水晶抽取1次/多次的消耗
	if cost > 0 then
		if costType == 1 and playerVoApi:getGems() < cost then
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			local function onGotoRecharge()
				-- if(self.rewardLayer)then
				-- 	-- self:disposeRewardLayer()
				-- end
				self:close()
			end
			local function onCancel()
				-- if(self.rewardLayer)then
				-- 	-- self:disposeRewardLayer()
				-- end
			end
			GemsNotEnoughDialog(nil,nil,cost - playerVoApi:getGems(),self.layerNum+2,cost,onGotoRecharge,onCancel)
			do return end
		elseif costType == 2 and playerVoApi:getGold() < cost then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage9101"),nil,self.layerNum+1) 
			-- self:disposeRewardLayer()
			do return end
		end
	end
	local num = planeVoApi:getSkillNumCfg()[costType][numIndex]
	self.lastGetType = costType
	self.lastGetIndex = numIndex

	
	local function callback(award)
		self.lotteryFlag=true
		self.getTimeTick = 1
		self:showGetReward(award, self.layerNum+1,numIndex,costType,cost)
		self:update()--刷新面板
	end
	local function lottery()
		planeVoApi:lotterySkill(costType,num,cost,callback)	
	end
	if costType==1 and cost>0 then
		local funcKey = "plane.oneLottery"
		if numIndex==2 then
			funcKey = "plane.tenLottery"
		end
		G_dailyConfirm(funcKey,getlocal("activity_slotMachine_getTip",{cost}),lottery,self.layerNum+1)
	else
		lottery()
	end
	if costType==1 and cost==0 and numIndex==1 then --金币抽免费
    	if otherGuideMgr.isGuiding and otherGuideMgr.curStep==35 then
	        otherGuideMgr:toNextStep()
	    end
    elseif costType==1 and numIndex==1 and cost>0 then --如果金币抽不是免费则结束教学
		planeVoApi:endPlaneGuide()
	end
end

function planeSkillGetDialog:showGetReward(item,layerNum,numIndex,costType,cost)
	self:showActionLayer(item,layerNum,numIndex,costType,cost)
end

function planeSkillGetDialog:showActionLayer(item,layerNum,numIndex,costType,cost)
	if self.actionLayer then
		do return end
	end
	local function touchHandler()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.shadeLayer==nil or self.showFlag==false then
			self:disposeActionLayer()
			self:showRewardLayer(item,layerNum,numIndex,costType,cost)
		end
	end
	local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),touchHandler)
	actionLayer:setAnchorPoint(ccp(0.5,0))
	actionLayer:setOpacity(0)
	actionLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	-- actionLayer:setNoSallowArea(CCRect(G_VisibleSizeWidth-120,G_VisibleSizeHeight-70,120,70))
	actionLayer:setPosition(G_VisibleSizeWidth/2,0)
	actionLayer:setTouchPriority(-(self.layerNum-1)*20-8)
	self.bgLayer:addChild(actionLayer,5)
	self.actionLayer=actionLayer

	local clipperW=self.actionBg:getContentSize().width*self.actionBg:getScaleX()
	local clipperH=self.actionBg:getContentSize().height*self.actionBg:getScaleY()
	local clipperSize=CCSizeMake(clipperW,clipperH)
    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setContentSize(clipperSize)
    clipper:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-80)
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil)
    self.actionLayer:addChild(clipper)

	local planeSp=CCSprite:createWithSpriteFrameName("lotteryPlane.png")
	planeSp:setPosition(-planeSp:getContentSize().width/2-20,clipperSize.height-330)
	planeSp:setScale(1.5)
	clipper:addChild(planeSp)
	local moveTo=CCMoveTo:create(0.7,ccp(clipperSize.width+planeSp:getContentSize().width/2+50,clipperSize.height+80))
	planeSp:runAction(moveTo)
	local function showFire(target,px,py)
		if target==nil then
			do return end
		end
	  	local fireSp=CCSprite:createWithSpriteFrameName("sprayFire1.png")
	  	local spcArr=CCArray:create()
	   	for kk=2,3 do
	        local nameStr="sprayFire"..kk..".png"
	        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        spcArr:addObject(frame)
	   	end
		local animation=CCAnimation:createWithSpriteFrames(spcArr)
		animation:setDelayPerUnit(0.15)
		local animate=CCAnimate:create(animation)
		fireSp:setAnchorPoint(ccp(0.5,0.5))
		fireSp:setPosition(ccp(px,py))
		fireSp:setScale(1/1.5)
		planeSp:addChild(fireSp)
		fireSp:runAction(animate)
	end
	showFire(planeSp,20,10)
	showFire(planeSp,40,10)

	local function playFire()
		local fireCfg
		if numIndex==1 then
			fireCfg={
				{200,G_VisibleSizeHeight-500,0.8,0},				
				{400,G_VisibleSizeHeight-400,0.6,0.3},
				{500,G_VisibleSizeHeight-330,0.5,0.6},
			}
		else
			fireCfg={
				{200,G_VisibleSizeHeight-500,0.8,0},
				{380,G_VisibleSizeHeight-500,0.8,0.3},
				{400,G_VisibleSizeHeight-400,0.6,0.5},
				{420,G_VisibleSizeHeight-300,0.5,0.8},
				{500,G_VisibleSizeHeight-330,0.5,1},
				{580,G_VisibleSizeHeight-200,0.4,1.5}
			}
		end
		for k,cfg in pairs(fireCfg) do
			local px=cfg[1]
			local py=cfg[2]
			local scale=cfg[3]
			local delayTime=cfg[4]
		  	local fireSp=CCSprite:createWithSpriteFrameName("plane_bigShells_1.png")
		  	local spcArr=CCArray:create()
		   	for kk=2,16 do
		        local nameStr="plane_bigShells_"..kk..".png"
		        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		        spcArr:addObject(frame)
		   	end
			local animation=CCAnimation:createWithSpriteFrames(spcArr)
			animation:setDelayPerUnit(0.08)
			local animate=CCAnimate:create(animation)
			fireSp:setAnchorPoint(ccp(0.5,0.5))
			fireSp:setPosition(ccp(px,py))
			fireSp:setScale(scale)
			self.actionLayer:addChild(fireSp)
			local delayAction=CCDelayTime:create(delayTime)
			local seq=CCSequence:createWithTwoActions(delayAction,animate)
			fireSp:runAction(seq)
		end
	end

	self.addParticleTb={}
	local function callback1()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGetBg.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 200))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.actionLayer:addChild(particleS)
		table.insert(self.addParticleTb,particleS)
	end

	local function callback2()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+160))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.actionLayer:addChild(particleS,10)
		table.insert(self.addParticleTb,particleS)
		local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
		particleS2:setPositionType(kCCPositionTypeFree)
		particleS2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+160))
		particleS2:setAutoRemoveOnFinish(true) -- 自动移除
		self.actionLayer:addChild(particleS2,11)
		table.insert(self.addParticleTb,particleS2)
	end

	local function callback3()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+160))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.actionLayer:addChild(particleS,12)
		table.insert(self.addParticleTb,particleS)
	end
	local function showReward()
		self:showRewardLayer(item,layerNum,numIndex,costType,cost)
	end
	local acArr=CCArray:create()
	local delay=CCDelayTime:create(0.7)
	local callFunc=CCCallFunc:create(playFire)
	local time=2
	if numIndex==1 then
		time=1.5
	end
	local delay1=CCDelayTime:create(time)
	local callFunc1=CCCallFunc:create(callback1)
	local callFunc2=CCCallFunc:create(callback2)
	local callFunc3=CCCallFunc:create(callback3)
	local callFunc4=CCCallFunc:create(showReward)
	acArr:addObject(delay)
	acArr:addObject(callFunc)
	acArr:addObject(delay1)
	acArr:addObject(callFunc1)
	acArr:addObject(callFunc2)
	local delay2=CCDelayTime:create(0.5)
	acArr:addObject(delay2)
	acArr:addObject(callFunc3)
	acArr:addObject(callFunc4)
	local seq=CCSequence:create(acArr)
	self.actionLayer:runAction(seq)
end

function planeSkillGetDialog:showRewardLayer(item,layerNum,numIndex,costType,cost)
    if self.rewardLayer then
    	do return end
    end
	local strSize2=22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2=28
    end
	local function touchHandler()
		if self.shadeLayer and self.showFlag==true then
			self:disposeActionLayer()
			self:disposeRewardLayer()
		end
	end
	local rewardLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),touchHandler)
	rewardLayer:setAnchorPoint(ccp(0.5,0))
	rewardLayer:setOpacity(0)
	rewardLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	rewardLayer:setNoSallowArea(CCRect(G_VisibleSizeWidth-120,G_VisibleSizeHeight-70,120,70))
	rewardLayer:setPosition(G_VisibleSizeWidth/2,0)
	rewardLayer:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(rewardLayer,5)
	self.rewardLayer=rewardLayer
	self.rewardParticleTb={}
	-- 抽奖的亮晶晶特效
	local function showBgParticle(parent,pos,sid,order)
		if parent then
			local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
			local color=gcfg.color or 1
			local particleName="public/emblem/emblemGet"..color..".plist"
			local starParticleS=CCParticleSystemQuad:create(particleName)
			starParticleS:setPosition(pos)
			parent:addChild(starParticleS,order)
			table.insert(self.rewardParticleTb,starParticleS)
		end
	end

	local function showReward()
		if self.shadeLayer then
			do return end
		end
		local function touchHandler()
		end
		local clipperW=self.actionBg:getContentSize().width*self.actionBg:getScaleX()
		local clipperH=self.actionBg:getContentSize().height*self.actionBg:getScaleY()
		local shadeLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),touchHandler)
		shadeLayer:setOpacity(120)
		shadeLayer:setAnchorPoint(ccp(0.5,1))
		shadeLayer:setTouchPriority(-(self.layerNum-1)*20-3)
		shadeLayer:setContentSize(CCSizeMake(clipperW,clipperH))
		shadeLayer:setPosition(self.actionBg:getPosition())
		self.shadeLayer=shadeLayer
		self.rewardLayer:addChild(shadeLayer,1)
		local function showEnd()
		    self:disposeActionLayer()
			self.showFlag=true
		end
		local posCfg,iconSc
		if SizeOfTable(item)==1 and item[1].num==1 then
			posCfg = {{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+160}}
			iconSc= 1.2
		else
			posCfg = {
			{G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight/2 + 100 + 70},
			{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+250 + 70},
			{G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight/2+100 + 70},
			{G_VisibleSizeWidth/2-130,G_VisibleSizeHeight/2-120 + 70},
			{G_VisibleSizeWidth/2+130,G_VisibleSizeHeight/2-120 + 70}
			}
			iconSc= 1.2
		end

		local index = 1
		local skillIdTb = {}

		local function showItemInfo(tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			-- local eVo=planeVoApi:getEquipVoByID(skillIdTb[tag])
			-- if(eVo)then
			-- 	planeVoApi:showInfoDialog(eVo,layerNum + 1)
			-- end
		end
		for k,v in pairs(item) do
			for i=1,v.num do
				local mIcon
				if v.type == "pl" then
					-- mIcon=planeVoApi:getSkillIcon(v.key,nil,showItemInfo,v.num,2)
					mIcon=planeVoApi:getSkillIcon(v.key,100,showItemInfo,v.num)
					mIcon:setTouchPriority(-(layerNum-1)*20-5)
					-- 装备名称
					local nameStr,descStr,typeStr,privilegeStr,colorStr=planeVoApi:getSkillInfoById(v.key,true)
					local skillNameLb=GetTTFLabelWrap(nameStr,25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					skillNameLb:setAnchorPoint(ccp(0.5,1))
					skillNameLb:setPosition(ccp(mIcon:getContentSize().width/2,-5))
					mIcon:addChild(skillNameLb,2)
					local scfg,gcfg=planeVoApi:getSkillCfgById(v.key)
					local color=planeVoApi:getColorByQuality(gcfg.color)
					skillNameLb:setColor(color)

					table.insert(skillIdTb,v.key)
				end
				mIcon:setTag(index)
				if mIcon then
					mIcon:setScale(0)
					mIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
					self.rewardLayer:addChild(mIcon,20+index)
					local ccMoveTo = CCMoveTo:create(0.2,CCPointMake(posCfg[index][1],posCfg[index][2]))
					local ccScaleTo = CCScaleTo:create(0.2,iconSc)
					local callFunc3=CCCallFuncN:create(showEnd)
					local moveAndScaleArr=CCArray:create()
					moveAndScaleArr:addObject(ccMoveTo)
					moveAndScaleArr:addObject(ccScaleTo)
					local moveAndScaleSpawn=CCSpawn:create(moveAndScaleArr)
					local function addParticle(icon)
						local tag = icon:getTag()
						showBgParticle(self.rewardLayer,ccp(icon:getPosition()),skillIdTb[tag],10+tag)
					end
					local callFunParticle = CCCallFuncN:create(addParticle)
					local iconAcArr=CCArray:create()
					iconAcArr:addObject(moveAndScaleSpawn)
					iconAcArr:addObject(callFunParticle)
					index = index + 1
					if index > SizeOfTable(posCfg) then
						index = 1
						iconAcArr:addObject(callFunc3)
					end  
					local seq=CCSequence:create(iconAcArr)
					mIcon:runAction(seq)
				end
			end
		end
	end
	local acArr=CCArray:create()
	local callFunc=CCCallFunc:create(showReward)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.rewardLayer:runAction(seq)
end
function planeSkillGetDialog:tick()
	if(base.serverTime==G_getWeeTs(base.serverTime))then
		if(self.getTimeTick)then
			self:disposeActionLayer()
			self:disposeRewardLayer()
		end
		self:update()
	end
	if self.getTimeTick then
		self.getTimeTick = self.getTimeTick + 1
		if self.getTimeTick > 7 then
			self:disposeActionLayer()
			self:disposeRewardLayer()
		end
	end
end

--抽取一次后刷新显示
function planeSkillGetDialog:update()
    for index=1,2 do
    	local freeIcon=self.freeIconTb[index][1]
    	local oneBtn=self.freeBtnTb[index][1]
    	local manyBtn=self.freeBtnTb[index][2]
    	local lbTb=self.costLbTb[index]
    	local freeTipSp=tolua.cast(self.freeTipSpTb[index],"CCSprite")
    	local own=0
    	if index==1 then
    		own=playerVoApi:getGems()
    	else
    		own=playerVoApi:getGold()
    	end
	    for i=1,2 do
	    	local lotteryBtn=self.freeBtnTb[index][i]
	    	local costIcon=self.freeIconTb[index][i]
	    	local lb=lbTb[i]
     		lb=tolua.cast(lb,"CCLabelTTF")
			if(lb)then
				local cost=planeVoApi:getSkillCost(index,i)-- 获取当前使用稀土/钻石第i次抽取的消耗
				if index==2 then
					lb:setString(tostring(FormatNumber(cost)))
				else
					lb:setString(tostring(cost))
				end
	          	if own<cost then
					lb:setColor(G_ColorRed)
				else
					lb:setColor(G_ColorYellowPro)
				end
				if index==1 and i==1 then
					local btnLb=tolua.cast(oneBtn:getChildByTag(6),"CCLabelTTF")	
					if cost==0 then
						if btnLb then
							btnLb:setString(getlocal("daily_lotto_tip_2"))
							btnLb:setColor(G_ColorYellowPro)
						end
						freeIcon:setVisible(false)
						lb:setVisible(false)
						manyBtn:setEnabled(false)
						if freeTipSp then
							freeTipSp:setVisible(true)
						end
					else
						if btnLb then
							btnLb:setString(getlocal("emblem_getBtnLb",{self.numCfg[index][i]}))
			            	btnLb:setColor(G_ColorWhite)
						end
						lb:setString(tostring(cost))
					    freeIcon:setVisible(true)
				    	lb:setVisible(true)
			    		manyBtn:setEnabled(true)
						if freeTipSp then
							freeTipSp:setVisible(false)
						end
					end
				else
					local btnLb=tolua.cast(lotteryBtn:getChildByTag(6),"CCLabelTTF")
					if btnLb then
						btnLb:setString(getlocal("emblem_getBtnLb",{self.numCfg[index][i]}))
		            	btnLb:setColor(G_ColorWhite)
					end
					local width=costIcon:getContentSize().width+lb:getContentSize().width
					costIcon:setPositionX(lotteryBtn:getContentSize().width/2-width/2)
					lb:setPositionX(costIcon:getPositionX()+costIcon:getContentSize().width)
				end		
			end
     	end
    end
end

function planeSkillGetDialog:disposeRewardLayer()
	if self.rewardParticleTb then
		for k,v in pairs(self.rewardParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v = nil
			end	
		end
		self.rewardParticleTb=nil
	end
	if self.rewardLayer then
		self.rewardLayer:stopAllActions()
		self.rewardLayer:removeFromParentAndCleanup(true)
		self.rewardLayer=nil
		self.shadeLayer=nil
	end
	self.getTimeTick=nil
	self.showFlag=false
end

function planeSkillGetDialog:disposeActionLayer()
	if self.addParticleTb then
		for k,v in pairs(self.addParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v=nil
			end	
		end
		self.addParticleTb=nil
	end
	if self.actionLayer then
		self.actionLayer:stopAllActions()
		self.actionLayer:removeFromParentAndCleanup(true)
		self.actionLayer=nil
	end
end

function planeSkillGetDialog:dispose()
	if self.lotteryFlag==true then
		eventDispatcher:dispatchEvent("plane.skillbag.refresh")
		self.lotteryFlag=false
	end
	self:disposeActionLayer()
	self:disposeRewardLayer()
    spriteController:removePlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
    spriteController:removeTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
	self.numCfg = nil
	self.freeFlag = nil
	self.freeBtnItem = nil
	self.freeBtnItemxitu = nil
	self.lastGetType = nil--上一次抽取的消费方式
	self.lastGetIndex= nil--上一次抽取的index
    self.costLbTb={}
	self.showFlag=false
	self.freeIconTb={}
	self.freeBtnTb={}
	self.freeTipSpTb={}
	self.rewardParticleTb=nil
 	if otherGuideMgr.isGuiding and otherGuideMgr.curStep==36 then
	    otherGuideMgr:toNextStep()
    end
    if planeRefitVoApi:isOpen() == true then
    	spriteController:removePlist("public/planeRefitImages.plist")
    	spriteController:removeTexture("public/planeRefitImages.png")
    end
end