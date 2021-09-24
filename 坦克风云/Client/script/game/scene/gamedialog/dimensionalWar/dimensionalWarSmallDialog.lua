--战场的小面板
dimensionalWarSmallDialog=smallDialog:new()
function dimensionalWarSmallDialog:new(type)
	local nc = {}
	setmetatable(nc,self)
	self.__index =self
	nc.type=type
	return nc
end

function dimensionalWarSmallDialog:init(layerNum,parent)
	self.isTouch=nil
	self.layerNum=layerNum
	self.dialogLayer=CCLayer:create()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	if(self.type==1 or self.type==2 or self.type==6)then
		self.dialogLayer:setTouchPriority(-(layerNum-1)*20-5)
	end
	self.dialogLayer:setBSwallowsTouches(true)
	if(self.type==1)then
		self:initOperate()
	elseif(self.type==2)then
		self.eventTickIndex=0
		self:initEvent()
	elseif(self.type==3)then
		spriteController:addTexture("public/dimensionalWar/dwPoster1.jpg")
		self:initZombie()
	elseif(self.type==4)then
		spriteController:addTexture("public/dimensionalWar/dwPoster2.jpg")
		self.pointTickIndex=0
		self.overTickIndex=0
		self:initGameOver()
	elseif(self.type==5)then
		spriteController:addTexture("public/dimensionalWar/dwPoster0.jpg")
		self.pointTickIndex=0
		self.surviverTickIndex=0
		self:initSurviverOver()
	elseif(self.type==6)then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
		spriteController:addTexture("public/serverWarLocal/sceneBg.jpg")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		self.loadingTickIndex=0
		self.loadingTextIndex=1
		self.loadingFastTickIndex=0
		self:initLoading()
	end
	self.dialogLayer:addChild(self.bgLayer,1)
	self:show()
	base:addNeedRefresh(self)
	if(parent)then
		parent:addChild(self.dialogLayer,5)
	else
		sceneGame:addChild(self.dialogLayer,self.layerNum)
	end
	return self.dialogLayer
end

--操作面板
function dimensionalWarSmallDialog:initOperate()
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))

	local titleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 285)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("dimensionalWar_operateTime"),25)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 285)
	self.bgLayer:addChild(titleLb)
	local timeLb=GetTTFLabel(dimensionalWarFightVoApi:getCountDown(),32)
	timeLb:setTag(101)
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 230)
	self.bgLayer:addChild(timeLb)

	local blueBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwBlueBg.png",CCRect(64,10,64,42),function ( ... )end)
	blueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,350))
	blueBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(blueBg)

	local actions=dimensionalWarFightVoApi:getAction()
	local function onClickOperate(object,name,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local index=tag or 1
		self.operateType=actions[index]
		if(self.selectBorder)then
			self.selectBorder:removeFromParentAndCleanup(true)
		end
		self.selectBorder=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(50,50,20,20),function ( ... )end)
		self.selectBorder:setContentSize(CCSizeMake(165,306))
		local operateBg=tolua.cast(self.bgLayer:getChildByTag(tag),"CCSprite")
		if(operateBg)then
			self.selectBorder:setPosition(getCenterPoint(operateBg))
			operateBg:addChild(self.selectBorder)
		end
	end
	local function onInfo(object,name,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local index=tag or 1
		local operateType=actions[index]
		local td=smallDialog:new()
		local cfgKey
		if(operateType==101)then
			cfgKey="battle"
		else
			for k,v in pairs(userWarCfg.cardsName) do
				if(v==operateType)then
					cfgKey=k
					break
				end
			end
		end
		local energyStr,gemStr
		if(userWarCfg[cfgKey].cost["energy"])then
			energyStr=userWarCfg[cfgKey].cost["energy"]
		else
			energyStr=""
		end
		if(userWarCfg[cfgKey].cost["gems"])then
			gemStr=userWarCfg[cfgKey].cost["gems"]
		else
			gemStr=""
		end
		local param
		if(operateType==4)then
			param={gemStr}
		else
			param={energyStr,gemStr}
		end
		local tabStr = {" ",getlocal("dimensionalWar_operateDesc"..operateType,param)," "}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local length=#actions
	for i=1,length do
		local operateBg=LuaCCSprite:createWithSpriteFrameName("anniversaryBg.png",onClickOperate)
		operateBg:setTag(i)
		operateBg:setTouchPriority(-(self.layerNum-1)*20-6)
		operateBg:setPosition(40 + 560/length*(i - 1) + 560/length/2,G_VisibleSizeHeight/2)
		self.bgLayer:addChild(operateBg)
		local operateType=actions[i]
		local operateLb=GetTTFLabel(getlocal("dimensionalWar_operateAct"..operateType),25)
		operateLb:setPosition(operateBg:getContentSize().width/2,250)
		operateBg:addChild(operateLb)
		local icon=CCSprite:createWithSpriteFrameName("dwAction"..operateType..".png")
		icon:setPosition(getCenterPoint(operateBg))
		operateBg:addChild(icon,1)
		local infoIcon=LuaCCSprite:createWithSpriteFrameName("questionMark.png",onInfo)
		infoIcon:setTag(i)
		infoIcon:setTouchPriority(-(self.layerNum-1)*20-7)
		infoIcon:setPosition(160,300)
		operateBg:addChild(infoIcon,1)
		local rotate1=CCRotateTo:create(0.2,30)
		local rotate2=CCRotateTo:create(0.4,-30)
		local rotate3=CCRotateTo:create(0.2,0)
		local delay=CCDelayTime:create(0.5)
		local acArr=CCArray:create()
		acArr:addObject(rotate1)
		acArr:addObject(rotate2)
		acArr:addObject(rotate3)
		acArr:addObject(delay)
		local seq=CCSequence:create(acArr)
		infoIcon:runAction(CCRepeatForever:create(seq))
		local cfgKey
		if(operateType==101)then
			cfgKey="battle"
		else
			for k,v in pairs(userWarCfg.cardsName) do
				if(v==operateType)then
					cfgKey=k
					break
				end
			end
		end
		local energyStr
		if(userWarCfg[cfgKey].cost["energy"])then
			energyStr=getlocal("dimensionalWar_energy",{"-"..userWarCfg[cfgKey].cost["energy"]})
		end
		if(userWarCfg[cfgKey].cost["gems"])then
			local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			gemIcon:setPosition(operateBg:getContentSize().width/2 - 30,50)
			operateBg:addChild(gemIcon)
			local gemLb=GetTTFLabel(userWarCfg[cfgKey].cost["gems"],25)
			gemLb:setColor(G_ColorYellowPro)
			gemLb:setAnchorPoint(ccp(0,0.5))
			gemLb:setPosition(operateBg:getContentSize().width/2,50)
			operateBg:addChild(gemLb)
			if(energyStr)then
				local energyLb=GetTTFLabel(energyStr,25)
				energyLb:setColor(G_ColorRed)
				energyLb:setPosition(operateBg:getContentSize().width/2,40)
				operateBg:addChild(energyLb)
				gemIcon:setPosition(operateBg:getContentSize().width/2 - 30,70)
				gemLb:setPosition(operateBg:getContentSize().width/2,70)
			end
		elseif(energyStr)then
			local energyLb=GetTTFLabel(energyStr,25)
			energyLb:setColor(G_ColorRed)
			energyLb:setPosition(operateBg:getContentSize().width/2,50)
			operateBg:addChild(energyLb)
		end
	end
	local function onOperate()
		self:close()
	end
	local function onConfirm()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.operateType==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_operateSelect"),30)
			do return end
		end
		local cfgKey
		if(self.operateType==101)then
			cfgKey="battle"
		else
			for k,v in pairs(userWarCfg.cardsName) do
				if(v==self.operateType)then
					cfgKey=k
					break
				end
			end
		end
		if(userWarCfg[cfgKey].cost["gems"])then
			if userWarCfg[cfgKey].cost["gems"]>playerVoApi:getGems() then
				GemsNotEnoughDialog(nil,nil,userWarCfg[cfgKey].cost["gems"] - playerVoApi:getGems(),self.layerNum+1,userWarCfg[cfgKey].cost["gems"])
				do return end
			end
		end
		if(userWarCfg[cfgKey].cost["energy"] and userWarCfg[cfgKey].cost["energy"]>dimensionalWarFightVoApi:getEnergy())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_event_title7"),30)
			do return end
		end
		dimensionalWarFightVoApi:action(self.operateType,onOperate)
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-7)
	okBtn:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/4 - 50)
	self.bgLayer:addChild(okBtn)
	local descLb
	if(dimensionalWarFightVoApi:getPlayerStatus()==0)then
		descLb=GetTTFLabelWrap(getlocal("dimensionalWar_operateTimeOut",{getlocal("dimensionalWar_operateAct0")}),25,CCSizeMake(G_VisibleSizeWidth - 200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
	else
		descLb=GetTTFLabelWrap(getlocal("dimensionalWar_operateTimeOut",{getlocal("dimensionalWar_operateAct101")}),25,CCSizeMake(G_VisibleSizeWidth - 200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
	end
	descLb:setColor(G_ColorRed)
	descLb:setAnchorPoint(ccp(0.5,0))
	descLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/4 - 10)
	self.bgLayer:addChild(descLb)
end

--事件面板
function dimensionalWarSmallDialog:initEvent()
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setOpacity(180)
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))

	local titleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 285)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("dimensionalWar_eventTime"),25)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 285)
	self.bgLayer:addChild(titleLb)
	local timeLb=GetTTFLabel(dimensionalWarFightVoApi:getCountDown(),32)
	timeLb:setTag(101)
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 230)
	self.bgLayer:addChild(timeLb)

	local blueBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwBlueBg.png",CCRect(64,10,64,42),function ( ... )end)
	blueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,350))
	blueBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(blueBg)

	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return math.min(self.eventTickIndex + 1,#(dimensionalWarFightVoApi:getEvent()) + 1)
		elseif fn=="tableCellSizeForIndex" then
			if(idx + 1==self.eventTickIndex + 1)then
				return CCSizeMake(G_VisibleSizeWidth - 80,40)
			else
				local eventData=dimensionalWarFightVoApi:getEvent()[idx + 1]
				if(eventData)then
					local eventStr=eventData[1]
					local lb=GetTTFLabelWrap(eventStr,25,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					return CCSizeMake(G_VisibleSizeWidth - 80,lb:getContentSize().height + 10)
				else
					return CCSizeMake(G_VisibleSizeWidth - 80,40)
				end
			end
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			if(idx + 1==math.min(self.eventTickIndex + 1,#(dimensionalWarFightVoApi:getEvent()) + 1))then
				self.eventTickSp=CCSprite:createWithSpriteFrameName("pointPic.png")
				self.eventTickSp:setPosition((G_VisibleSizeWidth - 80)/2 - 10,20)
				cell:addChild(self.eventTickSp)
				for i=2,3 do
					local pointPic=CCSprite:createWithSpriteFrameName("pointPic.png")
					pointPic:setTag(i)
					pointPic:setOpacity(0)
					pointPic:setAnchorPoint(ccp(0,0))
					pointPic:setPosition((i - 1)*10,0)
					self.eventTickSp:addChild(pointPic)
				end
			else
				local eventData=dimensionalWarFightVoApi:getEvent()[idx + 1]
				if(eventData)then
					local eventStr=eventData[1]
					local eventColor
					if(eventData[2]==1)then
						eventColor=G_ColorYellowPro
					else
						eventColor=G_ColorWhite
					end
					local lb=GetTTFLabelWrap(eventStr,25,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					lb:setColor(eventColor)
					lb:setPosition((G_VisibleSizeWidth - 80)/2,(lb:getContentSize().height + 10)/2)
					cell:addChild(lb)
				end
			end
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	self.eventTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 80,300),nil)
	self.eventTv:setTag(102)
	self.eventTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	self.eventTv:setPosition(40,G_VisibleSizeHeight/2 - 150)
	self.eventTv:setMaxDisToBottomOrTop(40)
	self.bgLayer:addChild(self.eventTv)
end

--变僵尸的面板
function dimensionalWarSmallDialog:initZombie()
	local strSize2 = 20
	local needPosHeight = 30
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" then
		strSize2 =25
		needPosHeight =0
	end
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setOpacity(180)
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))

	local redBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwEndBg2.png",CCRect(0,0,126,126),function ()end)
	redBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight))
	redBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(redBg)

	local titleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 310)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("dimensionalWar_zombieTitle"),40)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 310)
	self.bgLayer:addChild(titleLb)
	local descLb=GetTTFLabelWrap(getlocal("dimensionalWar_zombieDesc"),25,CCSizeMake(G_VisibleSizeWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 220)
	self.bgLayer:addChild(descLb)
	local texture=spriteController:getTexture("public/dimensionalWar/dwPoster1.jpg")
	local poster=CCSprite:createWithTexture(texture)
	poster:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 40)
	poster:setScale(1.4)
	self.bgLayer:addChild(poster)
	local buffIcon=CCSprite:createWithSpriteFrameName("dwBuffb3.png")
	buffIcon:setScale(80/buffIcon:getContentSize().width)
	buffIcon:setPosition(100,G_VisibleSizeHeight/2 - 160+needPosHeight)
	self.bgLayer:addChild(buffIcon)
	local buffTitle=GetTTFLabel(getlocal("dimensionalWar_zombieGetBuff"),strSize2+3)
	buffTitle:setColor(G_ColorYellowPro)
	buffTitle:setAnchorPoint(ccp(0,0.5))
	buffTitle:setPosition(150,G_VisibleSizeHeight/2 - 160+needPosHeight)
	self.bgLayer:addChild(buffTitle)
	local buffDesc=GetTTFLabelWrap(dimensionalWarFightVoApi:getBuffDesc("b3",1),strSize2,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	buffDesc:setAnchorPoint(ccp(0.5,1))
	buffDesc:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 220+needPosHeight)
	self.bgLayer:addChild(buffDesc)
	local function onConfirm()
		self:close()
	end
	local returnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("dimensionalWar_returnBattle"),25)
	local returnBtn=CCMenu:createWithItem(returnItem)
	returnBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	returnBtn:setPosition(G_VisibleSizeWidth/2,60)
	self.bgLayer:addChild(returnBtn)
end

--死人的结算面板
function dimensionalWarSmallDialog:initGameOver()
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setOpacity(180)
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))

	local redBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwEndBg2.png",CCRect(0,0,126,126),function ()end)
	redBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight))
	redBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(redBg)

	local titleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	titleBg:setColor(ccc3(0,90,90))
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 330)
	self.bgLayer:addChild(titleBg)
	local titleLb1=GetTTFLabel("GAME OVER",30)
	titleLb1:setColor(G_ColorGray)
	titleLb1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 330)
	self.bgLayer:addChild(titleLb1)
	local titleLb2=GetTTFLabel(getlocal("dimensionalWar_overTitle"),25)
	titleLb2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 280)
	self.bgLayer:addChild(titleLb2)
	local texture=spriteController:getTexture("public/dimensionalWar/dwPoster2.jpg")
	local poster=CCSprite:createWithTexture(texture)
	poster:setScale(1.4)
	poster:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 80)
	self.bgLayer:addChild(poster)
	local titleLb2=GetTTFLabel(getlocal("alliance_war_stats"),28)
	titleLb2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 65)
	self.bgLayer:addChild(titleLb2)
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(15, 15, 10, 10),function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,210))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(30,G_VisibleSizeHeight/2 - 290)
	self.bgLayer:addChild(tvBg)
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return self.overTickIndex
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(G_VisibleSizeWidth - 80,40)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local result=dimensionalWarFightVoApi:getResult()
			local lb1,lb2
			if(idx==0)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_survive_round")..": "..(result.round1 or 0),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_zombieRound",{result.round2 or 0}),25)
			elseif(idx==1)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct0"),result.count.s or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct1"),result.count.d or 0}),25)
			elseif(idx==2)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct6"),result.count.h or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct2"),result.count.b or 0}),25)
			elseif(idx==3)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct3"),result.count.t1 or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct102"),result.count.t2 or 0}),25)
			elseif(idx==4)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("buffText"),result.count.up or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_debuff"),result.count.de or 0}),25)
			end
			if(lb1)then
				lb1:setAnchorPoint(ccp(0,0.5))
				lb1:setPosition(0,20)
				cell:addChild(lb1)
				lb2:setAnchorPoint(ccp(0,0.5))
				lb2:setPosition((G_VisibleSizeWidth - 80)/2,20)
				cell:addChild(lb2)
			end
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	self.overTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 80,200),nil)
	self.overTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.overTv:setPosition(40,G_VisibleSizeHeight/2 - 285)
	self.overTv:setMaxDisToBottomOrTop(40)
	self.bgLayer:addChild(self.overTv)
	local point1=tonumber(dimensionalWarFightVoApi:getResult().point1) or 0
	local point2=tonumber(dimensionalWarFightVoApi:getResult().point2) or 0
	local pointStr=point1 + point2
	local tmpStr=""
	for i=1,string.len(pointStr) do
		tmpStr=tmpStr.."0"
	end
	self.pointLb=GetTTFLabel(getlocal("serverwar_reward_point",{tmpStr}),30)
	self.pointLb:setColor(G_ColorYellowPro)
	self.pointLb:setPosition(G_VisibleSizeWidth/2,165)
	self.bgLayer:addChild(self.pointLb)
	local function onConfirm()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(G_VisibleSizeWidth/2,50)
	self.bgLayer:addChild(okBtn)
end

--幸存者的结算面板
function dimensionalWarSmallDialog:initSurviverOver()
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setOpacity(180)
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))

	local blueBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwEndBg1.png",CCRect(0,0,126,126),function ()end)
	blueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight))
	blueBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(blueBg)

	local lightSp1=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	lightSp1:setAnchorPoint(ccp(0.5,0))
	lightSp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 310)
	self.bgLayer:addChild(lightSp1)
	local lightSp2=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	lightSp2:setAnchorPoint(ccp(0.5,1))
	lightSp2:setFlipY(true)
	lightSp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 310)
	self.bgLayer:addChild(lightSp2)

	local ribbonSp=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
	ribbonSp:setScale(1.2)
	ribbonSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 250)
	self.bgLayer:addChild(ribbonSp)

	local congratulateLb=GetTTFLabel(getlocal("congratulation"),40)
	congratulateLb:setColor(G_ColorYellowPro)
	congratulateLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 310)
	self.bgLayer:addChild(congratulateLb)

	local titleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 220)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("dimensionalWar_surviverTitle"),28)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 220)
	self.bgLayer:addChild(titleLb)
	local texture=spriteController:getTexture("public/dimensionalWar/dwPoster0.jpg")
	local poster=CCSprite:createWithTexture(texture)
	poster:setScale(1.4)
	poster:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 55)
	self.bgLayer:addChild(poster)
	local titleBg2=CCSprite:createWithSpriteFrameName("awBlueBg.png")
	titleBg2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 100)
	self.bgLayer:addChild(titleBg2)
	local titleLb2=GetTTFLabel(getlocal("alliance_war_stats"),28)
	titleLb2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 100)
	self.bgLayer:addChild(titleLb2)
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(15, 15, 10, 10), function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,210))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(30,G_VisibleSizeHeight/2 - 335)
	self.bgLayer:addChild(tvBg)
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return self.surviverTickIndex
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(G_VisibleSizeWidth - 80,40)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local result=dimensionalWarFightVoApi:getResult()
			local lb1,lb2
			if(idx==0)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_survive_round")..": "..(result.round1 or 0),28)
			elseif(idx==1)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct0"),result.count.s or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct1"),result.count.d or 0}),25)
			elseif(idx==2)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct6"),result.count.h or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct2"),result.count.b or 0}),25)
			elseif(idx==3)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct3"),result.count.t1 or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_operateAct101"),result.count.t2 or 0}),25)
			elseif(idx==4)then
				lb1=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("buffText"),result.count.up or 0}),25)
				lb2=GetTTFLabel(getlocal("dimensionalWar_actTime",{getlocal("dimensionalWar_debuff"),result.count.de or 0}),25)
			end
			if(lb1)then
				if(idx==0)then
					lb1:setPosition((G_VisibleSizeWidth - 80)/2,20)
				else
					lb1:setAnchorPoint(ccp(0,0.5))
					lb1:setPosition(5,20)
				end
				cell:addChild(lb1)
			end
			if(lb2)then
				lb2:setAnchorPoint(ccp(0,0.5))
				lb2:setPosition((G_VisibleSizeWidth - 80)/2,20)
				cell:addChild(lb2)
			end
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	self.surviverTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 80,200),nil)
	self.surviverTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.surviverTv:setPosition(40,G_VisibleSizeHeight/2 - 330)
	self.surviverTv:setMaxDisToBottomOrTop(40)
	self.bgLayer:addChild(self.surviverTv)
	local posY
	if(G_isIphone5())then
		posY=160
	else
		posY=120
	end
	local pointBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	pointBg:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(pointBg)
	local point1=tonumber(dimensionalWarFightVoApi:getResult().point1) or 0
	local point2=tonumber(dimensionalWarFightVoApi:getResult().point2) or 0
	local pointStr=point1 + point2
	local tmpStr=""
	for i=1,string.len(pointStr) do
		tmpStr=tmpStr.."0"
	end
	self.pointLb=GetTTFLabel(getlocal("serverwar_reward_point",{tmpStr}),30)
	self.pointLb:setColor(G_ColorYellowPro)
	self.pointLb:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(self.pointLb)
	local function onConfirm()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(G_VisibleSizeWidth/2,50)
	self.bgLayer:addChild(okBtn)
end

function dimensionalWarSmallDialog:initLoading()
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.bgLayer:setOpacity(200)
	self.bgLayer:setAnchorPoint(ccp(0,0))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth,0))
	self.bgLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))
	local loadingTexture=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
	local loadingBg=CCSprite:createWithTexture(loadingTexture)
	loadingBg:setColor(ccc3(220,220,220))
	loadingBg:setScale(G_VisibleSizeWidth/loadingBg:getContentSize().width)
	loadingBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(loadingBg)
	local tankBg=CCSprite:createWithSpriteFrameName("dwLoading4.png")
	tankBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(tankBg)
	self.tankSp1=CCSprite:createWithSpriteFrameName("dwLoading2.png")
	self.tankSp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(self.tankSp1)
	self.tankSp2=CCSprite:createWithSpriteFrameName("dwLoading3.png")
	self.tankSp2:setVisible(false)
	self.tankSp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(self.tankSp2)
	for i=1,4 do
		local wheelSp=CCSprite:createWithSpriteFrameName("dwLoading1.png")
		wheelSp:setPosition(G_VisibleSizeWidth/2 - 32 + 16*(i - 1) + 8,G_VisibleSizeHeight/2 - 22)
		self.bgLayer:addChild(wheelSp)
		local rotateBy=CCRotateBy:create(0.4,-360)
		wheelSp:runAction(CCRepeatForever:create(rotateBy))
	end
	local roundPoint=CCSprite:createWithSpriteFrameName("dwLoading5.png")
	roundPoint:setAnchorPoint(ccp(-3.8,0.5))
	roundPoint:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(roundPoint)
	local rotateBy=CCRotateBy:create(1,360)
	roundPoint:runAction(CCRepeatForever:create(rotateBy))
	local progressBg=CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
	progressBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 70))
	self.bgLayer:addChild(progressBg)
	self.progress=CCSprite:createWithSpriteFrameName("platWarProgress1.png")
	self.progress=CCProgressTimer:create(self.progress)
	self.progress:setType(kCCProgressTimerTypeBar)
	self.progress:setMidpoint(ccp(0,0))
	self.progress:setBarChangeRate(ccp(1,0))
	self.progress:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 70))
	self.bgLayer:addChild(self.progress)
	local countDown=dimensionalWarFightVoApi:getCountDown()
	local percent=(userWarCfg.roundTime - countDown)/userWarCfg.roundTime*100
	self.progress:setPercentage(percent)
	self.txtTb={getlocal("dimensionalWar_loadingTxt1"),getlocal("dimensionalWar_loadingTxt2")}
	local tmpTb={}
	for i=3,10 do
		table.insert(tmpTb,getlocal("dimensionalWar_loadingTxt"..i))
	end
	while #tmpTb>0 do
		math.randomseed(os.time())
		local random = math.random(1,#tmpTb)
		local str=table.remove(tmpTb,random)
		table.insert(self.txtTb,str)
	end
	local txtBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,0,2,47),function ()end)
	txtBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,50))
	txtBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 130)
	self.bgLayer:addChild(txtBg)
	self.loadingTxt=GetTTFLabel(self.txtTb[1],25)
	self.loadingTxt:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 130)
	self.bgLayer:addChild(self.loadingTxt)
end

function dimensionalWarSmallDialog:tick()
	if self:isClosed()==true then
		do return end
	end
	if(self.type==1)then
		local countDown=dimensionalWarFightVoApi:getCountDown()
		local timeLb=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
		timeLb:setString(countDown)
	elseif(self.type==2)then
		local countDown=dimensionalWarFightVoApi:getCountDown()
		local timeLb=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
		timeLb:setString(countDown)
		if(self.eventTickIndex<#(dimensionalWarFightVoApi:getEvent()) + 1)then
			self.eventTickIndex=self.eventTickIndex + 1
			self.eventTv:reloadData()
			if(self.eventTv:getContentSize().height>300)then
				self.eventTv:recoverToRecordPoint(ccp(0,0))
			else
				self.eventTv:recoverToRecordPoint(ccp(0,300 - self.eventTv:getContentSize().height))
			end
		end
		if(self.eventTickSp and self.eventTickSp.getParent and self.eventTickSp:getParent())then
			local tmp=base.serverTime%3
			if(tmp==0)then
				for i=2,3 do
					local pointPic=tolua.cast(self.eventTickSp:getChildByTag(i),"CCSprite")
					pointPic:setOpacity(0)
				end
			elseif(tmp==1)then
				local pointPic=tolua.cast(self.eventTickSp:getChildByTag(2),"CCSprite")
				pointPic:setOpacity(255)
				local pointPic=tolua.cast(self.eventTickSp:getChildByTag(3),"CCSprite")
				pointPic:setOpacity(0)
			else
				local pointPic=tolua.cast(self.eventTickSp:getChildByTag(2),"CCSprite")
				pointPic:setOpacity(255)
				local pointPic=tolua.cast(self.eventTickSp:getChildByTag(3),"CCSprite")
				pointPic:setOpacity(255)
			end
		end
	elseif(self.type==4)then
		if(self.overTickIndex<5)then
			self.overTickIndex=self.overTickIndex + 1
			self.overTv:reloadData()
			if(self.overTv:getContentSize().height>200)then
				self.overTv:recoverToRecordPoint(ccp(0,0))
			else
				self.overTv:recoverToRecordPoint(ccp(0,200 - self.overTv:getContentSize().height))
			end
		end
	elseif(self.type==5)then
		if(self.surviverTickIndex<5)then
			self.surviverTickIndex=self.surviverTickIndex + 1
			self.surviverTv:reloadData()
			if(self.surviverTv:getContentSize().height>200)then
				self.surviverTv:recoverToRecordPoint(ccp(0,0))
			else
				self.surviverTv:recoverToRecordPoint(ccp(0,200 - self.surviverTv:getContentSize().height))
			end
		end
	elseif(self.type==6)then
		self.loadingTickIndex=self.loadingTickIndex + 1
		if(self.loadingTickIndex%4==0)then
			self.loadingTextIndex=self.loadingTextIndex + 1
			if(self.loadingTextIndex>10)then
				self.loadingTextIndex=1
			end
			local fadeOut=CCFadeOut:create(0.5)
			local function onFadeOut()
				self.loadingTxt:setString(self.txtTb[self.loadingTextIndex])
			end
			local callFunc=CCCallFunc:create(onFadeOut)
			local fadeIn=CCFadeIn:create(0.5)
			local acArr=CCArray:create()
			acArr:addObject(fadeOut)
			acArr:addObject(callFunc)
			acArr:addObject(fadeIn)
			local seq=CCSequence:create(acArr)
			if(self.loadingTxt and tolua.cast(self.loadingTxt,"CCLabelTTF"))then
				self.loadingTxt:runAction(seq)
			end
		end
		local countDown=dimensionalWarFightVoApi:getCountDown()
		local percent=(userWarCfg.roundTime - countDown)/userWarCfg.roundTime*100
		if(self.progress and tolua.cast(self.progress,"CCProgressTimer"))then
			self.progress:setPercentage(percent)
		end
		local status=dimensionalWarFightVoApi:checkActionStatus()
		if(status==1)then
			if(self and self.close)then
				self:close()
			end
		end
	end
end

function dimensionalWarSmallDialog:fastTick()
	if self and self:isClosed()==true then
		do return end
	end
	if((self.type==4 or self.type==5) and self.pointLb)then
		local point1=tonumber(dimensionalWarFightVoApi:getResult().point1) or 0
		local point2=tonumber(dimensionalWarFightVoApi:getResult().point2) or 0
		local pointStr=point1 + point2
		if(self.pointTickIndex<100)then
			local tmpStr=""
			local strlen=string.len(pointStr)
			for i=1,strlen do
				tmpStr=tmpStr..math.random(0,9)
			end
			self.pointLb:setString(getlocal("serverwar_reward_point",{tmpStr}))
		else
			self.pointLb:setString(getlocal("serverwar_reward_point",{pointStr}))
		end
		if(self.pointTickIndex)then
			self.pointTickIndex=self.pointTickIndex + 1
		end
	elseif(self.type==6)then
		self.loadingFastTickIndex=self.loadingFastTickIndex + 1
		if(self.loadingFastTickIndex%20==0)then
			if(self.tankSp1:isVisible())then
				self.tankSp1:setVisible(false)
				self.tankSp2:setVisible(true)
			else
				self.tankSp1:setVisible(true)
				self.tankSp2:setVisible(false)
			end
		end
	end
end

function dimensionalWarSmallDialog:dispose()
	self.loadingTxt=nil
	self.progress=nil
	base:removeFromNeedRefresh(self)
	eventDispatcher:dispatchEvent("dimensionalWar.battle",{"closeDialog"})
	spriteController:removeTexture("public/dimensionalWar/dwPoster0.jpg")
	spriteController:removeTexture("public/dimensionalWar/dwPoster1.jpg")
	spriteController:removeTexture("public/dimensionalWar/dwPoster2.jpg")
	spriteController:removeTexture("public/serverWarLocal/sceneBg.jpg")
end