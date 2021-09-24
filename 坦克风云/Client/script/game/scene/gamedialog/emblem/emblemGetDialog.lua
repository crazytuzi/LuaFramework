--抽军徽的面板
emblemGetDialog=commonDialog:new()

function emblemGetDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.numCfg = nil
	nc.freeFlag = nil--当前是否显示为免费，刷新时需要重置按钮文字
	nc.freeFlagxitu = nil
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
	nc.childLayer = nil--获取面板的子面板
	nc.getTimeTick = nil--给后端发送抽取请求的等待时间
	--下次播放闪闪发光的动画的时间
	nc.nextBlingTick1=nil
	nc.nextBlingTick2=nil
	nc.background1=nil
	nc.background2=nil

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	spriteController:addTexture("public/allianceWar2/allianceWar2.png")
	return nc
end

function emblemGetDialog:initTableView()
	self.numCfg = emblemVoApi:getEquipNumCfg()
	self:initBg()
	self:initDesc()
	self:initR5Get()
	self:initGemGet()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
end

function emblemGetDialog:initDesc()
	local characterScale = 0.8
	local characterHeight = 0
	local characterLeft = -20
	local descHeight = 220 
	local selfAdapt = 100
	if G_getIphoneType() == G_iphoneX then
		descHeight = 250
		selfAdapt = 150
		characterScale = 0.8
		characterLeft = 0
	elseif G_getIphoneType() == G_iphone5 then
		selfAdapt = 130
	end
	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () do return end end)--"TaskHeaderBg.png",CCRect(20, 20, 10, 10)
	girlDescBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,descHeight))
	girlDescBg:setAnchorPoint(ccp(0.5,1))
	girlDescBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - selfAdapt)	
	self.bgLayer:addChild(girlDescBg)

	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
	girlImg:setScale(characterScale)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(characterLeft,girlDescBg:getPositionY() - girlDescBg:getContentSize().height +  characterHeight))
	self.bgLayer:addChild(girlImg)
 
	local descStr
	if(base.hexieMode==1)then
		descStr=getlocal("emblem_getDescHexie")
	else
		descStr=getlocal("emblem_getDesc")
	end
	local desTv, desLabel = G_LabelTableView(CCSizeMake(girlDescBg:getContentSize().width - 190, girlDescBg:getContentSize().height - 20),descStr,20,kCCTextAlignmentLeft)
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setPosition(ccp(170, 10))
	girlDescBg:addChild(desTv)
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(50)	
end

function emblemGetDialog:initBg()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local bigBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	bigBg:setScaleY((G_VisibleSizeHeight - 115)/bigBg:getContentSize().height)
	bigBg:setScaleX((G_VisibleSizeWidth - 40)/bigBg:getContentSize().width)
	bigBg:setAnchorPoint(ccp(0,0))
	bigBg:setPosition(ccp(20,25))
	self.bgLayer:addChild(bigBg)
end

--水晶消耗
function emblemGetDialog:initR5Get()
	local posY
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local background=CCSprite:create("public/emblem/emblem_get_bg2.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	background:setAnchorPoint(ccp(0.5,0))

	if(G_getIphoneType() == G_iphoneX) then
		posY=(G_VisibleSizeHeight - 70 - 220 - 55)/2 + 25
	elseif (G_getIphoneType == G_iphone5) then
		posY=(G_VisibleSizeHeight - 130 - 220 - 55)/2 + 25
	else 
		posY=(G_VisibleSizeHeight - 100 - 220 - 25)/2 + 25
	end 

	background:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(background,1)

	self.background1=background
	self.nextBlingTick1=base.serverTime + 1

	local tempBtnScale = 0.8
	local tempTextSize=24/tempBtnScale

	local bgSize=background:getContentSize()
	local tabLb
	if(base.hexieMode==1)then
		tabLb=GetTTFLabel(getlocal("emblem_draw_r5Hexie"),24,true)
	else
		tabLb=GetTTFLabel(getlocal("emblem_draw_r5"),24,true)
	end
	local tabSp=LuaCCScale9Sprite:createWithSpriteFrameName("RankBtnTab.png",CCRect(68,10,2,2),function ( ... )end)
	tabSp:setContentSize(CCSizeMake(tabLb:getContentSize().width + 40,48))
	tabSp:setAnchorPoint(ccp(0,0))
	tabSp:setPosition(G_VisibleSizeWidth/2 - bgSize.width/2 + 10,posY + bgSize.height - 3)
	self.bgLayer:addChild(tabSp)
	tabLb:setPosition(getCenterPoint(tabSp))
	tabSp:addChild(tabLb)
	local backgroundCenterY = bgSize.height/2 + posY
	local costOne = emblemVoApi:getEquipCost(2,1)-- 获取当前使用稀土抽取1次的消耗
	local oneBtnX = bgSize.width-170
	local oneBtnY = backgroundCenterY + 10
	local function getOneByMoney()
		self:btnClickToGet(2,1)	
	end
	if costOne > 0 then
		self.freeFlagxitu = 0
	else
		self.freeFlagxitu = 1
	end
	local btnStr
	if(base.hexieMode==1)then
		btnStr=getlocal("emblem_getBtnLbHexie",{self.numCfg[2][1]})
	else
		btnStr=getlocal("emblem_getBtnLb",{self.numCfg[2][1]})
	end
	self.freeBtnItemxitu=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getOneByMoney,nil,self.freeFlagxitu == 0 and btnStr or getlocal("daily_lotto_tip_2"),tempTextSize,6)
	self.freeBtnItemxitu:setScale(tempBtnScale)
	self.freeBtnItemxitu:setAnchorPoint(ccp(0,0))
	local oneBtn=CCMenu:createWithItem(self.freeBtnItemxitu)
	oneBtn:setAnchorPoint(ccp(0,0))
	oneBtn:setPosition(ccp(oneBtnX,oneBtnY))
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-7)
	self.bgLayer:addChild(oneBtn,2)

    local freexituTipSp=G_createTipSp(self.freeBtnItemxitu)
	self.freexituTipSp=freexituTipSp

	local iconGoldX = oneBtnX + 25
	self.freeIconxitu=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	local iconGoldY = oneBtnY + self.freeBtnItemxitu:getContentSize().height + self.freeIconxitu:getContentSize().height/2
	self.freeIconxitu:setAnchorPoint(ccp(0,0.5))
	self.freeIconxitu:setPosition(ccp(iconGoldX,iconGoldY))
	self.bgLayer:addChild(self.freeIconxitu,2)

	self.freeCostxitu=GetTTFLabel(FormatNumber(costOne),25)
	self.freeCostxitu:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGold() < costOne then
		self.freeCostxitu:setColor(G_ColorRed)
	else
		self.freeCostxitu:setColor(G_ColorYellowPro)
	end
	self.freeCostxitu:setPosition(ccp(iconGoldX + self.freeIconxitu:getContentSize().width,iconGoldY))
	self.bgLayer:addChild(self.freeCostxitu,2)
	self.freeCostxitu:setTag(21)
	if self.freeFlagxitu == 1 then
		local btnLb = tolua.cast(self.freeBtnItemxitu:getChildByTag(6),"CCLabelTTF")
		btnLb:setColor(G_ColorYellowPro)
		self.freeIconxitu:setVisible(false)
		self.freeCostxitu:setVisible(false)
		self.freexituTipSp:setVisible(true)
	end
	
	local manyBtnY = backgroundCenterY - bgSize.height/2 + 20
	local function getManyByMoney()
		self:btnClickToGet(2,2)
	end
	local btnStr
	if(base.hexieMode==1)then
		btnStr=getlocal("emblem_getBtnLbHexie",{self.numCfg[2][2]})
	else
		btnStr=getlocal("emblem_getBtnLb",{self.numCfg[2][2]})
	end
	local manyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getManyByMoney,nil,btnStr,tempTextSize)
	manyItem:setScale(tempBtnScale)
	manyItem:setAnchorPoint(ccp(0,0))
	local manyBtn=CCMenu:createWithItem(manyItem)
	manyBtn:setAnchorPoint(ccp(0,0))
	manyBtn:setPosition(ccp(oneBtnX,manyBtnY))
	manyBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	self.bgLayer:addChild(manyBtn,2)
	

	local iconGold2=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	local iconGoldY2 = manyBtnY + manyItem:getContentSize().height + iconGold2:getContentSize().height/2
	iconGold2:setAnchorPoint(ccp(0,0.5))
	iconGold2:setPosition(ccp(iconGoldX,iconGoldY2))
	self.bgLayer:addChild(iconGold2,2)
	
	local costMany = emblemVoApi:getEquipCost(2,2)-- 获取当前使用稀土抽取多次的消耗
	local costLbMany=GetTTFLabel(FormatNumber(costMany),25)
	costLbMany:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGold() < costMany then
		costLbMany:setColor(G_ColorRed)
	else
		costLbMany:setColor(G_ColorYellowPro)
	end
	costLbMany:setPosition(ccp(iconGoldX + iconGold2:getContentSize().width,iconGoldY2))
	self.bgLayer:addChild(costLbMany,2)
	costLbMany:setTag(22)
end

--金币消耗
function emblemGetDialog:initGemGet()
	local posY
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local background=CCSprite:create("public/emblem/emblem_get_bg1.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	background:setAnchorPoint(ccp(0.5,0))

	if(G_getIphoneType() == G_iphoneX) then
		posY = 85
	elseif (G_getIphoneType == G_iphone5) then
		posY = 55
	else
		posY = 25
	end

	background:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(background,1)

	self.background2=background
	self.nextBlingTick2=base.serverTime + 1
	
	local bgSize=background:getContentSize()
	local tabLb
	if(base.hexieMode==1)then
		tabLb=GetTTFLabel(getlocal("emblem_draw_goldHexie"),24,true)
	else
		tabLb=GetTTFLabel(getlocal("emblem_draw_gold"),24,true)
	end
	local tabSp=LuaCCScale9Sprite:createWithSpriteFrameName("RankBtnTab.png",CCRect(68,10,2,2),function ( ... )end)
	tabSp:setContentSize(CCSizeMake(tabLb:getContentSize().width + 40,48))
	tabSp:setAnchorPoint(ccp(0,0))
	tabSp:setPosition(G_VisibleSizeWidth/2 - bgSize.width/2 + 10,posY + bgSize.height - 3)
	self.bgLayer:addChild(tabSp)
	tabLb:setPosition(getCenterPoint(tabSp))
	tabSp:addChild(tabLb)

	local tempBtnScale = 0.8
	local textSize=24/tempBtnScale
	local costOne = emblemVoApi:getEquipCost(1,1)---- 获取当前使用钻石抽取1次的消耗
	local function getOneByGem()
		self:btnClickToGet(1,1)
	end
	
	if costOne > 0 then
		self.freeFlag = 0
	else
		self.freeFlag = 1
	end
	local backgroundCenterY=posY + bgSize.height/2
	local oneBtnX = bgSize.width - 170
	local oneBtnY = backgroundCenterY + 10
	local btnStr
	if(base.hexieMode==1)then
		btnStr=getlocal("emblem_getBtnLbHexie",{self.numCfg[1][1]})
	else
		btnStr=getlocal("emblem_getBtnLb",{self.numCfg[1][1]})
	end
	self.freeBtnItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getOneByGem,nil,self.freeFlag == 0  and btnStr or getlocal("daily_lotto_tip_2"),textSize,6)
	self.freeBtnItem:setScale(tempBtnScale)
	self.freeBtnItem:setAnchorPoint(ccp(0,0))
	local oneBtn=CCMenu:createWithItem(self.freeBtnItem)
	oneBtn:setAnchorPoint(ccp(0,0))
	oneBtn:setPosition(ccp(oneBtnX,oneBtnY))
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(oneBtn,2)

    local freegoldTipSp=G_createTipSp(self.freeBtnItem)
	self.freegoldTipSp=freegoldTipSp

	local iconGoldX = oneBtnX + 25
	self.freeIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	local iconGoldY = oneBtnY + self.freeBtnItem:getContentSize().height + self.freeIcon:getContentSize().height/2
	self.freeIcon:setAnchorPoint(ccp(0,0.5))
	self.freeIcon:setPosition(ccp(iconGoldX,iconGoldY))
	self.bgLayer:addChild(self.freeIcon,2)
	
	
	self.freeCost=GetTTFLabel(tostring(costOne),25)
	self.freeCost:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGems() < costOne then
		self.freeCost:setColor(G_ColorRed)
	else
		self.freeCost:setColor(G_ColorYellowPro)
	end
	self.freeCost:setPosition(ccp(iconGoldX + self.freeIcon:getContentSize().width,iconGoldY))
	self.bgLayer:addChild(self.freeCost,2)
	self.freeCost:setTag(11)

	if self.freeFlag == 1 then
		local btnLb = tolua.cast(self.freeBtnItem:getChildByTag(6),"CCLabelTTF")
		btnLb:setColor(G_ColorYellowPro)
		self.freeIcon:setVisible(false)
		self.freeCost:setVisible(false)
		self.freegoldTipSp:setVisible(true)
	end

	local manyBtnY = backgroundCenterY - bgSize.height/2 + 20
	local function getManyByGem()
		self:btnClickToGet(1,2)
	end
	local btnStr
	if(base.hexieMode==1)then
		btnStr=getlocal("emblem_getBtnLbHexie",{self.numCfg[1][2]})
	else
		btnStr=getlocal("emblem_getBtnLb",{self.numCfg[1][2]})
	end
	self.manyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getManyByGem,2,btnStr,textSize)
	self.manyItem:setScale(tempBtnScale)
	self.manyItem:setAnchorPoint(ccp(0,0))
	local manyBtn=CCMenu:createWithItem(self.manyItem)
	manyBtn:setAnchorPoint(ccp(0,0))
	manyBtn:setPosition(ccp(oneBtnX,manyBtnY))
	manyBtn:setTouchPriority(-(self.layerNum-1)*20-6)
	self.bgLayer:addChild(manyBtn,2)
	if(self.freeFlag==1)then
		self.manyItem:setEnabled(false)
	else
		self.manyItem:setEnabled(true)
	end

	local iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
	local iconGoldY2 = manyBtnY + self.manyItem:getContentSize().height + iconGold2:getContentSize().height/2
	iconGold2:setAnchorPoint(ccp(0,0.5))
	iconGold2:setPosition(ccp(iconGoldX,iconGoldY2))
	self.bgLayer:addChild(iconGold2,2)
	
	local costMany = emblemVoApi:getEquipCost(1,2)---- 获取当前使用钻石抽取多次的消耗
	local costLbMany=GetTTFLabel(tostring(costMany),25)
	costLbMany:setAnchorPoint(ccp(0,0.5))
	if playerVoApi:getGems() < costMany then
		costLbMany:setColor(G_ColorRed)
	else
		costLbMany:setColor(G_ColorYellowPro)
	end
	
	costLbMany:setPosition(ccp(iconGoldX + iconGold2:getContentSize().width,iconGoldY2))
	self.bgLayer:addChild(costLbMany,2)
	costLbMany:setTag(12)
end

--玩家点击按钮后，往后台发送请求
function emblemGetDialog:btnClickToGet(costType,numIndex)
	local cost =  emblemVoApi:getEquipCost(costType,numIndex) -- 获取当前使用金币/水晶抽取1次/多次的消耗
	if cost > 0 then
		if costType == 1 and playerVoApi:getGems() < cost then--水晶不足
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			local function onGotoRecharge()
				if(self.rewardLayer)then
					self:disposeRewardLayer()
				end
				self:close()
			end
			local function onCancel()
				if(self.rewardLayer)then
					self:disposeRewardLayer()
				end
			end
			GemsNotEnoughDialog(nil,nil,cost - playerVoApi:getGems(),self.layerNum+2,cost,onGotoRecharge,onCancel)
			do return end
		elseif costType == 2 and playerVoApi:getGold() < cost then -- 水晶不足
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage9101"),nil,self.layerNum+1) 
			self:disposeRewardLayer()
			do return end
		end
	end
	local num = emblemVoApi:getEquipNumCfg()[costType][numIndex]
	local hadTotalNum = emblemVoApi:getEquipTotalNum()
	if num > 0 and  hadTotalNum + num > 150 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_canNotGetMore_need"),30)
		self:disposeRewardLayer()
		do return end
	end
	self.lastGetType = costType
	self.lastGetIndex = numIndex

	
	local function callback(award)
		self.getTimeTick = 1
		self:showGetReward(award, self.layerNum+1)
		if(base.hexieMode==1)then
			local award=FormatItem(emblemCfg.mustReward1.reward)
			for k,v in pairs(award) do
				if(numIndex==2)then
					v.num=v.num*5
				end
			end
			G_showRewardTip(award, true)
		end
		self:update()--刷新面板
	end
	local function lottery()
		emblemVoApi:addEmblem(costType,num,callback)	
	end
	if costType==1 and cost>0 then
		local funcKey = "emblem.oneLottery"
		if numIndex==2 then
			funcKey = "emblem.tenLottery"
		end
		G_dailyConfirm(funcKey,getlocal("activity_slotMachine_getTip",{cost}),lottery,self.layerNum+1)
	else
		lottery()
	end
end

function emblemGetDialog:showGetReward(item,layerNum)
	if(base.hexieMode==1)then
		local tmp={}
		for k,v in pairs(item) do
			if(v.type=="se")then
				table.insert(tmp,v)
			end
		end
		item=tmp
	end
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	if self.rewardLayer == nil then
		self.rewardLayer = CCLayer:create()
		sceneGame:addChild(self.rewardLayer,layerNum)

		local function callback()
		 
		end
		local sceneSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,6,6),function ()end)
		sceneSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		sceneSp:setAnchorPoint(ccp(0,0))
		sceneSp:setPosition(ccp(0,0))
		sceneSp:setTouchPriority(-(layerNum-1)*20-1)
		self.rewardLayer:addChild(sceneSp)
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		local bigBg=LuaCCSprite:createWithFileName("public/emblem/emblemBlackBg.jpg",callback)
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		bigBg:setAnchorPoint(ccp(0.5,0.5))
		bigBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		self.rewardLayer:addChild(bigBg)
		local fadeTo = CCFadeTo:create(1.5, 100)
		local fadeBack = CCFadeTo:create(1.5, 255)
		local acArr = CCArray:create()
		acArr:addObject(fadeTo)
		acArr:addObject(fadeBack)
		local seq = CCSequence:create(acArr)
		bigBg:runAction(CCRepeatForever:create(seq))
		
		
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGetBg.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 200))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS)
	end
	self:clearChildLayer()
	self.childLayer = CCLayer:create()
	self.rewardLayer:addChild(self.childLayer)
	self.addParticleTb = {}

	local function callback1()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS,10)
		table.insert(self.addParticleTb,particleS)
		local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
		particleS2:setPositionType(kCCPositionTypeFree)
		particleS2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS2:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS2,11)
		table.insert(self.addParticleTb,particleS2)
	end

	local function callback2()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS,12)
		table.insert(self.addParticleTb,particleS)
	end

	-- 抽奖的亮晶晶特效
	local function showBgParticle(parent,pos,equipID,order)
		if parent then
			local equipCfg = emblemVoApi:getEquipCfgById(equipID)
			local color = equipCfg.color
			local particleName = "public/emblem/emblemGet"..color..".plist"
			local starParticleS = CCParticleSystemQuad:create(particleName)
			starParticleS:setPosition(pos)
			parent:addChild(starParticleS,order)
			table.insert(self.addParticleTb,starParticleS)
		end
	end
	
	
	local callFunc1=CCCallFunc:create(callback1)
	local callFunc2=CCCallFunc:create(callback2)
	

	local acArr=CCArray:create()
	local function callback3()
		local titleBg = CCSprite:createWithSpriteFrameName("awTitleBg.png")
		titleBg:setScale(1.2)
		titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 80)
		self.childLayer:addChild(titleBg)
	
		local titleLb=GetTTFLabel(getlocal("congratulationsGet",{""}),strSize2,true)
		titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 73)
		self.childLayer:addChild(titleLb)

		local function callback31()
			local function ok( ... )
				self:disposeRewardLayer()
			end

			local tempBtnScale = 0.7
			local tempBtnSize = 24/tempBtnScale
			local btnName,btnNameDown
			if(self.lastGetType==1)then
				btnName="creatRoleBtn.png"
				btnNameDown="creatRoleBtn_Down.png"
			else
				btnName="newGreenBtn.png"
				btnNameDown="newGreenBtn_down.png"
			end
			local okItem=GetButtonItem(btnName,btnNameDown,btnNameDown,ok,nil,getlocal("coverFleetBack"),tempBtnSize)
			okItem:setScale(tempBtnScale)
			local okBtn=CCMenu:createWithItem(okItem)
			okBtn:setTouchPriority(-(layerNum-1)*20-2)
			okBtn:setAnchorPoint(ccp(1,0.5))
			okBtn:setPosition(ccp(G_VisibleSizeWidth/2-180,150))
			self.childLayer:addChild(okBtn,11)

			local function continueGet( ... )
				self:clearChildLayer()
				self:btnClickToGet(self.lastGetType,self.lastGetIndex)
			end

			local btnStr
			if(base.hexieMode==1)then
				btnStr=getlocal("emblem_getBtnLbHexie",{self.numCfg[self.lastGetType][self.lastGetIndex]})
			else
				btnStr=getlocal("emblem_getBtnLb",{self.numCfg[self.lastGetType][self.lastGetIndex]})
			end
			local conItem=GetButtonItem(btnName,btnNameDown,btnNameDown,continueGet,nil,btnStr,tempBtnSize)
			conItem:setScale(tempBtnScale)
			local conBtn=CCMenu:createWithItem(conItem)
			conBtn:setTouchPriority(-(layerNum-1)*20-2)
			conBtn:setAnchorPoint(ccp(0,0.5))
			conBtn:setPosition(ccp(G_VisibleSizeWidth/2+180,150))
			self.childLayer:addChild(conBtn,12)
			
			local iconX,iconY
			local iconImg
			if self.lastGetType == 1 then
				iconImg = "IconGold.png"
			elseif self.lastGetType == 2 then
				iconImg = "IconCrystal-.png"
			end
			local icon=CCSprite:createWithSpriteFrameName(iconImg)
			iconX = G_VisibleSizeWidth/2+135
			iconY = 205

			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(iconX,iconY))
			self.childLayer:addChild(icon)
			
			local cost = emblemVoApi:getEquipCost(self.lastGetType,self.lastGetIndex)---- 获取当前使用钻石/稀土抽取的消耗
			local costLb
			if self.lastGetType == 1 then
				costLb=GetTTFLabel(tostring(cost),25)
				if playerVoApi:getGems() < cost then
					costLb:setColor(G_ColorRed)
				else
					costLb:setColor(G_ColorYellowPro)
				end
			elseif self.lastGetType == 2 then
				costLb=GetTTFLabel(FormatNumber(cost),25)
				if playerVoApi:getGold() < cost then
					costLb:setColor(G_ColorRed)
				else
					costLb:setColor(G_ColorYellowPro)
				end
			end
			costLb:setAnchorPoint(ccp(0,0.5))
			costLb:setPosition(ccp(iconX + icon:getContentSize().width,iconY))
			self.childLayer:addChild(costLb)
		end
		local posCfg,iconSc
		if SizeOfTable(item)==1 and item[1].num==1 then
			posCfg = {{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+50}}
			iconSc= 1.2
		else
			posCfg = {
			{G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight/2 + 100 + 30},
			{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+250 + 30},
			{G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight/2+100 + 30},
			{G_VisibleSizeWidth/2-130,G_VisibleSizeHeight/2-120 + 30},
			{G_VisibleSizeWidth/2+130,G_VisibleSizeHeight/2-120 + 30}
			}
			iconSc= 1.2
		end

		local index = 1
		local equipIdTb = {}

		local function showItemInfo(tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			local eVo=emblemVoApi:getEquipVoByID(equipIdTb[tag])
			if(eVo)then
				emblemVoApi:showInfoDialog(eVo,layerNum + 1)
			end
		end
		for k,v in pairs(item) do
			for i=1,v.num do
				local mIcon
				if v.type == "se" then
					mIcon=emblemVoApi:getEquipIconNoBg(v.key,strSize2,nil,showItemInfo)
					mIcon:setTouchPriority(-(layerNum-1)*20-5)
					table.insert(equipIdTb,v.key)
				end
				mIcon:setTag(index)
				if mIcon then
					mIcon:setScale(0)
					mIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
					self.childLayer:addChild(mIcon,20+index)
					local ccMoveTo = CCMoveTo:create(0.2,CCPointMake(posCfg[index][1],posCfg[index][2]))
					local ccScaleTo = CCScaleTo:create(0.2,iconSc)
					local callFunc3=CCCallFuncN:create(callback31)
					local moveAndScaleArr=CCArray:create()
					moveAndScaleArr:addObject(ccMoveTo)
					moveAndScaleArr:addObject(ccScaleTo)
					local moveAndScaleSpawn=CCSpawn:create(moveAndScaleArr)
					local function addParticle(icon)
						local tag = icon:getTag()
						showBgParticle(self.childLayer,ccp(icon:getPosition()),equipIdTb[tag],10+tag)
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
	local callFunc3=CCCallFunc:create(callback3)
	local delay = CCDelayTime:create(0.5)
	acArr:addObject(callFunc1)
	acArr:addObject(delay)
	acArr:addObject(callFunc2)
	acArr:addObject(callFunc3)
	local seq=CCSequence:create(acArr)
	self.rewardLayer:runAction(seq)

end
function emblemGetDialog:tick()
	if(base.serverTime==G_getWeeTs(base.serverTime))then
		if(self.getTimeTick)then
			self:disposeRewardLayer()
		end
		self:update()
	end
	if self.getTimeTick then
		self.getTimeTick = self.getTimeTick + 1
		if self.getTimeTick > 7 then
			self:disposeRewardLayer()
		end
	end
	if(self.nextBlingTick1==base.serverTime and self.background1)then
		local blingSp=CCSprite:createWithSpriteFrameName("emblemBling.png")
		local posX=math.random(104,223)
		local posY=math.random(31,196)
		blingSp:setPosition(posX,posY)
		blingSp:setOpacity(0)
		self.background1:addChild(blingSp)
		local rotate=CCRotateBy:create(3,360)
		local fadeIn=CCFadeIn:create(0.5)
		local delay=CCDelayTime:create(2)
		local fadeOut=CCFadeOut:create(0.5)
		local arr1=CCArray:create()
		arr1:addObject(fadeIn)
		arr1:addObject(delay)
		arr1:addObject(fadeOut)
		local seq=CCSequence:create(arr1)
		local arr2=CCArray:create()
		arr2:addObject(seq)
		arr2:addObject(rotate)
		local spawn=CCSpawn:create(arr2)
		local function actionEnd()
			if(blingSp and blingSp.removeFromParentAndCleanup)then
				blingSp:removeFromParentAndCleanup(true)
			end
			if(self.nextBlingTick1)then
				self.nextBlingTick1=self.nextBlingTick1 + math.random(7,12)
			end
		end
		local callFunc=CCCallFunc:create(actionEnd)
		local seq=CCSequence:createWithTwoActions(spawn,callFunc)
		blingSp:runAction(seq)
	end
	if(self.nextBlingTick2==base.serverTime and self.background2)then
		local blingSp=CCSprite:createWithSpriteFrameName("emblemBling.png")
		local posX=math.random(90,226)
		local posY=math.random(56,183)
		blingSp:setPosition(posX,posY)
		blingSp:setOpacity(0)
		self.background2:addChild(blingSp)
		local rotate=CCRotateBy:create(3,360)
		local fadeIn=CCFadeIn:create(0.5)
		local delay=CCDelayTime:create(2)
		local fadeOut=CCFadeOut:create(0.5)
		local arr1=CCArray:create()
		arr1:addObject(fadeIn)
		arr1:addObject(delay)
		arr1:addObject(fadeOut)
		local seq=CCSequence:create(arr1)
		local arr2=CCArray:create()
		arr2:addObject(seq)
		arr2:addObject(rotate)
		local spawn=CCSpawn:create(arr2)
		local function actionEnd()
			if(blingSp and blingSp.removeFromParentAndCleanup)then
				blingSp:removeFromParentAndCleanup(true)
			end
			if(self.nextBlingTick2)then
				self.nextBlingTick2=self.nextBlingTick2 + math.random(7,12)
			end
		end
		local callFunc=CCCallFunc:create(actionEnd)
		local seq=CCSequence:createWithTwoActions(spawn,callFunc)
		blingSp:runAction(seq)
	end
end

--抽取一次后刷新显示
function emblemGetDialog:update()
    for index=1,2 do
	    for i=1,2 do
     		local lb=tolua.cast(self.bgLayer:getChildByTag(index * 10 + i),"CCLabelTTF")
			if(lb)then
				local cost = emblemVoApi:getEquipCost(index,i)-- 获取当前使用稀土/钻石第i次抽取的消耗
				
				if index == 1 then
					lb:setString(tostring(cost))
                    if playerVoApi:getGems() < cost then
						lb:setColor(G_ColorRed)
					else
						lb:setColor(G_ColorYellowPro)
					end

					if i == 1 and self.freeFlag == 1 and cost > 0 then
						self.freeFlag = 0
                        G_removeFlicker(self.freeBtnItem)
						local btnLb = tolua.cast(self.freeBtnItem:getChildByTag(6),"CCLabelTTF")
					    if btnLb then
					    	if(base.hexieMode==1)then
					    		btnLb:setString(getlocal("emblem_getBtnLbHexie",{self.numCfg[index][i]}))
					    	else
						    	btnLb:setString(getlocal("emblem_getBtnLb",{self.numCfg[index][i]}))
						    end
				            btnLb:setColor(G_ColorWhite)
					    end
					    self.freeIcon:setVisible(true)
						self.freeCost:setVisible(true)
						self.manyItem:setEnabled(true)
						self.freegoldTipSp:setVisible(false)
					elseif i==1 and self.freeFlag==0 and cost==0 then
						self.freeFlag=1
						local btnLb = tolua.cast(self.freeBtnItem:getChildByTag(6),"CCLabelTTF")
						btnLb:setString(getlocal("daily_lotto_tip_2"))
						btnLb:setColor(G_ColorYellowPro)
						self.freeIcon:setVisible(false)
						self.freeCost:setVisible(false)
						self.manyItem:setEnabled(false)
						self.freegoldTipSp:setVisible(true)
					end
                else
                	lb:setString(FormatNumber(cost))
					if playerVoApi:getGold() < cost then
						lb:setColor(G_ColorRed)
					else
						lb:setColor(G_ColorYellowPro)
					end
                     
                    if i == 1 and self.freeFlagxitu == 1 and cost > 0 then
                        self.freeFlagxitu = 0
                        G_removeFlicker(self.freeBtnItemxitu)
						local btnLb = tolua.cast(self.freeBtnItemxitu:getChildByTag(6),"CCLabelTTF")
					    if btnLb then
					    	if(base.hexieMode==1)then
					    		btnLb:setString(getlocal("emblem_getBtnLbHexie",{self.numCfg[index][i]}))
					    	else
						    	btnLb:setString(getlocal("emblem_getBtnLb",{self.numCfg[index][i]}))
						    end
				            btnLb:setColor(G_ColorWhite)
					    end
					    self.freeIconxitu:setVisible(true)
						self.freeCostxitu:setVisible(true)
						self.freexituTipSp:setVisible(false)
					end
					 
				end
			end
			lb = nil
     	end
    end
end

function emblemGetDialog:clearChildLayer()
	if self.addParticleTb then
		for k,v in pairs(self.addParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v = nil
			end	
		end
		self.addParticleTb = nil
	end
	
	if self.childLayer then
		self.childLayer:removeAllChildrenWithCleanup(true)
		self.childLayer:removeFromParentAndCleanup(true)
		self.childLayer = nil
	end
end

function emblemGetDialog:disposeRewardLayer()
	if self.addParticleTb then
		for k,v in pairs(self.addParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v = nil
			end	
		end
		self.addParticleTb = nil
	end
	if self.childLayer then
		self.childLayer:removeAllChildrenWithCleanup(true)
		self.childLayer:removeFromParentAndCleanup(true)
		self.childLayer = nil
	end
	if self.rewardLayer then
		self.rewardLayer:removeAllChildrenWithCleanup(true)				   
		self.rewardLayer:removeFromParentAndCleanup(true)
		self.rewardLayer = nil
	end
	self.getTimeTick = nil
end

function emblemGetDialog:dispose()
	self:disposeRewardLayer()
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBlackBg.jpg")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblem_get_bg1.jpg")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblem_get_bg2.jpg")
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
	self.numCfg = nil
	self.freeFlag = nil
	self.freeFlagxitu = nil
	self.freeBtnItem = nil
	self.freeBtnItemxitu = nil
	self.lastGetType = nil--上一次抽取的消费方式
	self.lastGetIndex= nil--上一次抽取的index
	self.nextBlingTick1=nil
	self.nextBlingTick2=nil
	self.background1=nil
	self.background2=nil
	self.freexituTipSp=nil
	self.freegoldTipSp=nil
end