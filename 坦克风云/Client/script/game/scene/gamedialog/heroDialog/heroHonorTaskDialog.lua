--将领授勋详情面板
heroHonorTaskDialog=commonDialog:new()

function heroHonorTaskDialog:new(hero)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.data=hero
	nc.taskCfg=heroFeatCfg.heroQuest[hero.hid][hero.productOrder - heroFeatCfg.fusionLimit + 1]
	return nc
end

function heroHonorTaskDialog:resetForbidLayer()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30,G_VisibleSizeHeight - 115))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,15))
end

function heroHonorTaskDialog:initTableView()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	spriteController:addPlist("public/newDisplayImage.plist")
	spriteController:addTexture("public/newDisplayImage.png")
	local function honorListener(event,data)
		self:dealWithEvent(event,data)
	end
	self.honorListener=honorListener
	eventDispatcher:addEventListener("hero.honor",honorListener)
	self:initIcon()
	self:initTask()
end

function heroHonorTaskDialog:initIcon()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local upBg=CCSprite:create("public/vipHeadBg.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 215)
    upBg:setScaleY(1.35)
    self.bgLayer:addChild(upBg)
	local sbIcon=heroVoApi:getHeroIcon(self.data.hid,self.data.productOrder)
	sbIcon:setScale(0.75)
	sbIcon:setPosition(ccp(G_VisibleSizeWidth/4,G_VisibleSizeHeight - 180))
	self.bgLayer:addChild(sbIcon)
	local sbLv=GetTTFLabel(G_LV()..self.data.level.."/"..G_LV()..heroCfg.heroLevel[self.data.productOrder],22)
	sbLv:setColor(G_ColorYellowPro)
	sbLv:setPosition(ccp(G_VisibleSizeWidth/4,G_VisibleSizeHeight - 275))
	self.bgLayer:addChild(sbLv,1)
	local sbName=GetTTFLabel(getlocal(heroListCfg[self.data.hid].heroName),23)
	sbName:setPosition(ccp(G_VisibleSizeWidth/4,G_VisibleSizeHeight - 300))
	self.bgLayer:addChild(sbName,1)
	local sbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
	sbBg:setScaleX((sbName:getContentSize().width + 80)/120)
	sbBg:setScaleY(50/36)
	sbBg:setPosition(G_VisibleSizeWidth/4,G_VisibleSizeHeight - 285)
	self.bgLayer:addChild(sbBg)

	self.arrowTb={}
	for i=1,3 do
		local arrow=CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
		arrow:setPosition(ccp(G_VisibleSizeWidth/2 - 45 + 45*(i - 1),G_VisibleSizeHeight - 200))
		self.bgLayer:addChild(arrow)
		self.arrowTb[i]=arrow
		local arrow2=CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
		arrow2:setTag(101)
		arrow2:setPosition(21,21)
		arrow2:setOpacity(0)
		arrow:addChild(arrow2)
	end
	self.actionArrow=0
	local function onActionEnd()
		self.actionArrow=self.actionArrow + 1
		if(self.actionArrow>3)then
			self.actionArrow=1
		end
		local fadeOut=CCFadeOut:create(0.5)
		local delay=CCDelayTime:create(0.5)
		local callFunc=CCCallFunc:create(onActionEnd)
		local fadeIn=CCFadeIn:create(0.5)
		local acArr2=CCArray:create()
		acArr2:addObject(fadeIn)
		acArr2:addObject(delay)
		acArr2:addObject(fadeOut)
		local seq2=CCSequence:create(acArr2)
		local arrow2=tolua.cast(self.arrowTb[self.actionArrow]:getChildByTag(101),"CCSprite")
		arrow2:runAction(seq2)
		local acArr=CCArray:create()
		acArr:addObject(fadeOut)
		acArr:addObject(delay)
		acArr:addObject(callFunc)
		acArr:addObject(fadeIn)
		local seq=CCSequence:create(acArr)
		self.arrowTb[self.actionArrow]:runAction(seq)
	end
	onActionEnd()

	local nbIcon=heroVoApi:getHeroIcon(self.data.hid,self.data.productOrder + 1)
	nbIcon:setScale(0.75)
	nbIcon:setPosition(ccp(G_VisibleSizeWidth*3/4,G_VisibleSizeHeight - 180))
	self.bgLayer:addChild(nbIcon)
	local nbLv=GetTTFLabel(G_LV()..heroCfg.throuhHeroLevel[self.data.productOrder].."/"..G_LV()..heroCfg.heroLevel[self.data.productOrder + 1],22)
	nbLv:setColor(G_ColorYellowPro)
	nbLv:setPosition(ccp(G_VisibleSizeWidth*3/4,G_VisibleSizeHeight - 275))
	self.bgLayer:addChild(nbLv,1)
	local nbName=GetTTFLabel(getlocal(heroListCfg[self.data.hid].heroName),23)
	nbName:setPosition(ccp(G_VisibleSizeWidth*3/4,G_VisibleSizeHeight - 300))
	self.bgLayer:addChild(nbName,1)
	local nbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
	nbBg:setScaleX((nbName:getContentSize().width + 80)/120)
	nbBg:setScaleY(50/36)
	nbBg:setPosition(G_VisibleSizeWidth*3/4,G_VisibleSizeHeight - 285)
	self.bgLayer:addChild(nbBg)
end

function heroHonorTaskDialog:initTask()
	self.cellHeight=170
	local flag=false
	for k,v in pairs(self.taskCfg) do
		if(v[1]==self.data.taskID)then
			self.curStep=k
			flag=true
			break
		end
	end
	if(flag==false)then
		self.curStep=1
	end
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(30,30,40,40),function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 440))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(25,105)
	self.bgLayer:addChild(tvBg)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 450),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,110))
	self.bgLayer:addChild(self.tv)
	-- if(self.curStep and self.curStep>0)then
	-- 	self.tv:recoverToRecordPoint(ccp(0,(self.curStep - 1)*self.cellHeight))
	-- end
	local function onClick()
		self:clickBtn()
	end
	-- Alter@JNK
	local btnImageN = "newGreenBtn.png"
	local btnImageS = "newGreenBtn_down.png"
	local btnImageD = "newGreenBtn.png"
	if(heroVoApi:getCurrentHonorHero()~=nil and heroVoApi:getCurrentHonorHero().hid==self.data.hid)then
		if(self.curStep==#self.taskCfg and self.data.taskProceed>=self.taskCfg[#self.taskCfg][2])then
			self.taskBtnItem=GetButtonItem(btnImageN,btnImageS,btnImageD,onClick,nil,getlocal("hero_honor_doHonor"),25,518)
			local tb,isSuccessUpdate,propsTb=heroVoApi:getThrouhNeedPropIconBySid(self.data.hid,self.data.productOrder,self.layerNum + 1)
			self.taskBtnItem:setPositionX(-85)
			self.taskBtnItem:setScale(0.8)
			local function onCancel()
				self:cancelTask()
			end
			self.dropItem=GetButtonItem(btnImageN,btnImageS,btnImageD,onCancel,nil,getlocal("dailyTaskCancel"),25,518)
			self.dropItem:setPositionX(85)
			self.dropItem:setScale(0.8)
		else
			self.taskBtnItem=GetButtonItem(btnImageN,btnImageS,btnImageD,onClick,nil,getlocal("dailyTaskCancel"),25,518)
		end
	else
		self.taskBtnItem=GetButtonItem(btnImageN,btnImageS,btnImageD,onClick,nil,getlocal("daily_scene_get"),25,518)
	end
	self.taskBtn=CCMenu:createWithItem(self.taskBtnItem)
	self.taskBtn:setPosition(ccp(G_VisibleSizeWidth/2,60))
	self.taskBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.taskBtn)
	if(self.dropItem)then
		self.taskBtn:addChild(self.dropItem)
	end
end

function heroHonorTaskDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.taskCfg + 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local background
		if(idx<#self.taskCfg)then
			self:initTaskCell(idx + 1,cell)
		else
			self:initRewardCell(cell)
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

function heroHonorTaskDialog:initTaskCell(index,cell)
	local strSize2 = 19
	local needWidth = 15
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize2 =23
		needWidth=0
	elseif G_getCurChoseLanguage() =="de" then
		strSize2 =17
	end
	local titleBg=CCSprite:createWithSpriteFrameName("building_guild_namebg.png")
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(0,self.cellHeight)
	cell:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("hero_honor_taskTitle",{index}),strSize2)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(ccp(20-needWidth,self.cellHeight - 20))
	cell:addChild(titleLb,1)

	local taskID=self.taskCfg[index][1]
	local descLb=GetTTFLabelWrap(getlocal("hero_honor_taskDesc_"..taskID,{getlocal(heroListCfg[self.data.hid].heroName),self.taskCfg[index][2]}),22,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(10,self.cellHeight - 60))
	cell:addChild(descLb)

	local statusLb
	local statusLine
	if(index<self.curStep)then
		statusLb=GetTTFLabel(getlocal("hadCompleted"),23)
		statusLb:setColor(G_ColorYellowPro)
		statusLine=CCSprite:createWithSpriteFrameName("PointLineYellow.png")
	elseif(index==self.curStep)then
		if(self.data.taskProceed>=self.taskCfg[self.curStep][2])then
			statusLb=GetTTFLabel(getlocal("hadCompleted"),strSize2)
			statusLb:setColor(G_ColorYellowPro)
			statusLine=CCSprite:createWithSpriteFrameName("PointLineYellow.png")
		else
			if(heroVoApi:getCurrentHonorHero()==nil or heroVoApi:getCurrentHonorHero().hid~=self.data.hid)then
				statusLb=GetTTFLabel(getlocal("hero_honor_taskStatus1"),strSize2)
				statusLine=CCSprite:createWithSpriteFrameName("PointLineGreen.png")
			else
				local proceedStr,totalStr
				if(taskID=="t9")then
					if(self.data.taskProceed==nil or self.data.taskProceed==0)then
						proceedStr=heroFeatCfg.qualificationLevel[1][1] or 0
					else
						proceedStr=heroFeatCfg.qualificationLevel[self.data.taskProceed][1] or 0
					end
					totalStr=heroFeatCfg.qualificationLevel[self.taskCfg[self.curStep][2]][1] or 0
				else
					proceedStr=self.data.taskProceed
					totalStr=self.taskCfg[self.curStep][2]
				end
				statusLb=GetTTFLabel(getlocal("hero_honor_taskStatus2",{proceedStr,totalStr}),strSize2)
				statusLb:setColor(G_ColorGreen)
				statusLine=CCSprite:createWithSpriteFrameName("PointLineGreen.png")
			end
		end
	elseif(heroVoApi:getCurrentHonorHero()==nil or heroVoApi:getCurrentHonorHero().hid~=self.data.hid)then
		statusLb=GetTTFLabel(getlocal("hero_honor_taskStatus1"),strSize2)
		statusLine=CCSprite:createWithSpriteFrameName("PointLineGreen.png")
	end
	if(statusLb)then
		statusLb:setAnchorPoint(ccp(1,0.5))
		statusLb:setPosition(G_VisibleSizeWidth - 80+needWidth,self.cellHeight - 20)
		cell:addChild(statusLb)
	end
	if(statusLine)then
		statusLine:setFlipX(true)
		statusLine:setAnchorPoint(ccp(1,0.5))
		statusLine:setPosition(G_VisibleSizeWidth - 60,self.cellHeight - 40)
		cell:addChild(statusLine)
	end
	local line1=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line1:setColor(ccc3(7,24,12))
	line1:setScaleX((G_VisibleSizeWidth - 60)/line1:getContentSize().width)
	line1:setPosition((G_VisibleSizeWidth - 60)/2,0.5)
	cell:addChild(line1)
	local line2=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line2:setColor(ccc3(48,70,64))
	line2:setScaleX((G_VisibleSizeWidth - 60)/line2:getContentSize().width)
	line2:setPosition((G_VisibleSizeWidth - 60)/2,-0.5)
	cell:addChild(line2)
	return cell
end

function heroHonorTaskDialog:initRewardCell(cell)
	local descLb=GetTTFLabelWrap(getlocal("hero_honor_propDesc"),25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	descLb:setColor(G_ColorYellowPro)
	descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setPosition(ccp((G_VisibleSizeWidth - 60)/2,self.cellHeight - 15))
	cell:addChild(descLb)

	local tb,isSuccessUpdate,propsTb=heroVoApi:getThrouhNeedPropIconBySid(self.data.hid,self.data.productOrder,self.layerNum + 1)
	local length=SizeOfTable(tb)
	local realHeight=self.cellHeight - 5 - descLb:getContentSize().height
	for i=1,length do
		local icon = tb[i]
		icon:setAnchorPoint(ccp(0.5,0.5))
		icon:setPosition(ccp((G_VisibleSizeWidth - 60)*i/(length + 1),realHeight/2))
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(icon)
	end
	self.propEnough=isSuccessUpdate
end

function heroHonorTaskDialog:clickBtn()
	if(heroVoApi:getCurrentHonorHero()~=nil and heroVoApi:getCurrentHonorHero().hid~=self.data.hid)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("hero_honor_otherTaskDoing"),30)
		do return end
	end
	local function callback()
		self:refreshData()
	end
	if(heroVoApi:getCurrentHonorHero()==nil)then
		heroVoApi:acceptHonorTask(self.data.hid,callback)
	elseif(heroVoApi:getCurrentHonorHero().hid==self.data.hid)then
		if(self.curStep==#self.taskCfg and self.data.taskProceed>=self.taskCfg[#self.taskCfg][2])then
			self:checkWakeUp()
		else
			self:cancelTask()
		end
	end
end

function heroHonorTaskDialog:cancelTask()
	local function callback()
		self:refreshData()
	end
	local function onConfirm()
		heroVoApi:dropHonorTask(self.data.hid,callback)
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("hero_honor_dropTaskConfirm"),nil,self.layerNum+1)
end

function heroHonorTaskDialog:checkWakeUp()
	if(self.propEnough)then
		local function callback()
			self:showWakeUpMovie()

			--授勋发公告
			local nameStr=getlocal(heroListCfg[self.data.hid].heroName)
			local message
			local heroVo=heroVoApi:getHeroByHid(self.data.hid)
			if(heroVo.productOrder==heroFeatCfg.fusionLimit + 1)then
				message={key="hero_honor_chat_message",param={playerVoApi:getPlayerName(),nameStr}}
			else
				message={key="hero_honor_chat_message2",param={playerVoApi:getPlayerName(),nameStr,heroVo.productOrder - heroFeatCfg.fusionLimit,heroVo.productOrder}}
			end
            chatVoApi:sendSystemMessage(message)
		end
		heroVoApi:wakeUp(self.data.hid,callback)
	else
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9033"),30)
	end
end

--显示NB的授勋动画
function heroHonorTaskDialog:showWakeUpMovie()
	if(self.mvLayer)then
		do return end
	end
	local heroVo=heroVoApi:getHeroByHid(self.data.hid)
	self.mvLayer=CCLayer:create()
	self.bgLayer:addChild(self.mvLayer,3)
	--黑色的遮罩
	local function nilFunc( ... )
	end
	local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	maskSp:setTouchPriority(-(self.layerNum-1)*20-7)
	maskSp:setOpacity(180)
	maskSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	maskSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.mvLayer:addChild(maskSp)

	--将领的头像阴影
	local heroImageStr ="ship/Hero_Icon/"..heroListCfg[self.data.hid].heroIcon
	if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
		heroImageStr ="ship/Hero_Icon_Cartoon/"..heroListCfg[self.data.hid].heroIcon
	end
	local iconShadow=CCSprite:create(heroImageStr)
	iconShadow:setColor(ccc3(0,0,0))
	iconShadow:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 300))
	self.mvLayer:addChild(iconShadow,2)

	--依次显示几道闪电
	local acArr=CCArray:create()
	local function showlightning1()
		local lightning01 = CCParticleSystemQuad:create("public/hero/lightning01.plist")
		lightning01.positionType=kCCPositionTypeFree
		lightning01:setScale(1.5)
		lightning01:setPosition(ccp(G_VisibleSizeWidth/2 + 30,G_VisibleSizeHeight - 200))
		self.mvLayer:addChild(lightning01)
		PlayEffect(audioCfg.tank_hit_4)
	end
	local lightningCallFunc1=CCCallFunc:create(showlightning1)
	acArr:addObject(lightningCallFunc1)

	local lightningDelay2=CCDelayTime:create(0.2)
	acArr:addObject(lightningDelay2)
	local function showlightning2()
		local lightning02 = CCParticleSystemQuad:create("public/hero/lightning02.plist")
		lightning02.positionType=kCCPositionTypeFree
		lightning02:setScale(1.5)
		lightning02:setPosition(ccp(G_VisibleSizeWidth/2 - 30,G_VisibleSizeHeight - 200))
		self.mvLayer:addChild(lightning02)
		PlayEffect(audioCfg.tank_hit_2)
	end
	local lightningCallFunc2=CCCallFunc:create(showlightning2)
	acArr:addObject(lightningCallFunc2)

	local lightningDelay3=CCDelayTime:create(0.5)
	acArr:addObject(lightningDelay3)
	local function showlightning3()
		local lightning03 = CCParticleSystemQuad:create("public/hero/lightning03.plist")
		lightning03.positionType=kCCPositionTypeFree
		lightning03:setPosition(ccp(100,G_VisibleSizeHeight - 300))
		self.mvLayer:addChild(lightning03)
		PlayEffect(audioCfg.tank_hit_4)
	end
	local lightningCallFunc3=CCCallFunc:create(showlightning3)
	acArr:addObject(lightningCallFunc3)

	local lightningDelay4=CCDelayTime:create(0.5)
	acArr:addObject(lightningDelay4)
	local function showlightning4()
		local lightning04 = CCParticleSystemQuad:create("public/hero/lightning04.plist")
		lightning04.positionType=kCCPositionTypeFree
		lightning04:setRotation(180)
		lightning04:setPosition(ccp(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 300))
		self.mvLayer:addChild(lightning04)
		PlayEffect(audioCfg.tank_hit_4)
	end
	local lightningCallFunc4=CCCallFunc:create(showlightning4)
	acArr:addObject(lightningCallFunc4)

	--闪电闪完了之后有光从上面打下来
	local function showLightAndHero()
		for i=1,9 do
			local light = CCParticleSystemQuad:create("public/hero/sun.plist")
			light:setRotation(-60 - 6*i)
			light:setScaleY(0.2)
			light.positionType=kCCPositionTypeFree
			light:setPosition(ccp(G_VisibleSizeWidth/2 - 40 + 7.5*i,G_VisibleSizeHeight))
			self.mvLayer:addChild(light)
			local scale=CCScaleTo:create(0.5,4,0.5)
			light:runAction(scale)
		end
		--头像, 边框, 背景, 绶带, 星星都是分别加上来, 因为有优先级的问题
		local iconBg=LuaCCSprite:createWithSpriteFrameName("heroHeadBG.png",nilFunc)
		iconBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 300))
		self.mvLayer:addChild(iconBg,1)
		local icon=CCSprite:create(heroImageStr)
		icon:setOpacity(0)
		icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 300))
		self.mvLayer:addChild(icon,2)
		local iconBorder=CCSprite:createWithSpriteFrameName("heroHead"..heroVo.productOrder..".png")
		iconBorder:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 300))
		self.mvLayer:addChild(iconBorder,2)
		local starBg=CCSprite:createWithSpriteFrameName("heroBg.png")
		starBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370))
		self.mvLayer:addChild(starBg,2)

		--头像上面盖着的黑影逐渐消失, 头像逐渐出现
		local fadeOut=CCFadeOut:create(0.5)
		iconShadow:runAction(fadeOut)
		local fadeIn=CCFadeIn:create(0.5)
		icon:runAction(fadeIn)
	end
	local lightCallFunc=CCCallFunc:create(showLightAndHero)
	acArr:addObject(lightCallFunc)

	local lightningDelay5=CCDelayTime:create(0.5)
	acArr:addObject(lightningDelay5)
	local function showlightning5()
		local lightning05 = CCParticleSystemQuad:create("public/hero/lightning05.plist")
		lightning05.positionType=kCCPositionTypeFree
		lightning05:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 280))
		self.mvLayer:addChild(lightning05)
		PlayEffect(audioCfg.tank_hit_1)
	end
	local lightningCallFunc5=CCCallFunc:create(showlightning5)
	acArr:addObject(lightningCallFunc5)


	--五颗星星打上来
	for i=1,5 do
		local starDelay
		if(i==1)then
			starDelay=CCDelayTime:create(0.5)
		else
			starDelay=CCDelayTime:create(0.3)
		end
		acArr:addObject(starDelay)
		local function showStar()
			local star
			if(heroVo.productOrder==6 and i==3)then
				star=CCSprite:createWithSpriteFrameName("heroStar.png")
			else
				star=CCSprite:createWithSpriteFrameName("StarIcon.png")
			end
			star:setScale(0.2)
			star:setPosition(ccp(G_VisibleSizeWidth*i/6,G_VisibleSizeHeight - 400))
			self.mvLayer:addChild(star,2)
			local starAcArr=CCArray:create()
			--先变大
			local bigger=CCScaleTo:create(0.2,4)
			starAcArr:addObject(bigger)
			--一边变小一边飞向绶带
			local moveTo=CCMoveTo:create(0.5,ccp(G_VisibleSizeWidth/2 - 99 + i*33,G_VisibleSizeHeight - 370))
			local smaller=CCScaleTo:create(0.5,1)
			local spawnArr=CCArray:create()
			spawnArr:addObject(moveTo)
			spawnArr:addObject(smaller)
			local spawn=CCSpawn:create(spawnArr)
			starAcArr:addObject(spawn)
			--到达目标, 火花打出来
			local function showSpark()
				PlayEffect(audioCfg.battle_star)
				local spark=CCParticleSystemQuad:create("public/hero/Star.plist")
				spark:setScale(0.7)
				spark.positionType=kCCPositionTypeFree
				spark:setPosition(ccp(G_VisibleSizeWidth/2 - 99 + i*33,G_VisibleSizeHeight - 365))
				self.mvLayer:addChild(spark,2)
			end
			local sparkCallFunc=CCCallFunc:create(showSpark)
			starAcArr:addObject(sparkCallFunc)
			local starSeq=CCSequence:create(starAcArr)
			star:runAction(starSeq)
		end
		local starCallFunc=CCCallFunc:create(showStar)
		acArr:addObject(starCallFunc)
	end

	local function showTipFunc()
		local str = getlocal("hero_honor_honorSuccess")
		if playerVoApi:getSwichOfGXH() and heroVo.productOrder<=heroFeatCfg.fusionLimit2[1] then
			str = str .. "\n" .. getlocal("jiesuo_hero_icon")
		end
		local tip=GetTTFLabelWrap(str,35,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		tip:setColor(G_ColorYellowPro)
		tip:setAnchorPoint(ccp(0.5,1))
		tip:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 450))
		tip:setScale(0.2)
		self.mvLayer:addChild(tip,1)
		local scale=CCScaleTo:create(0.5,1)
		tip:runAction(scale)
	end
	local showTipFunc=CCCallFunc:create(showTipFunc)
	acArr:addObject(showTipFunc)

	local showSkillDelay=CCDelayTime:create(0.3)
	local function showSkillFunc()
		local rect = CCRect(0, 0, 50, 50)
		local capInSet = CCRect(20, 20, 10, 10)
		local function nilFunc(...)
		end
		local height=250
		local skillBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		skillBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, height))
		skillBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 680))
		self.mvLayer:addChild(skillBg)
		local sid=heroVoApi:getUsedRealiseSkill(self.data.hid)[heroVo.productOrder - heroFeatCfg.fusionLimit][1]
		local icon = CCSprite:create(heroVoApi:getSkillIconBySid(sid))
		icon:setPosition(ccp(70,height/2))
		skillBg:addChild(icon)
		local lvStr,value,isMax,level = heroVoApi:getHeroHonorSkillLvAndValue(self.data.hid,sid,self.data.productOrder)
		local greSize=22
		local firstSize =27
		local secHeiPos = height - 100
		local thrHeiPos = height - 170
		if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" then
			greSize=27
			firstSize=32
			secHeiPos =height -80
			thrHeiPos =height - 180
		end
		local lbTB={
			{str=getlocal("hero_honor_getHonorSkill"),size=firstSize,pos={(G_VisibleSizeWidth - 60)/2,height - 10},aPos={0.5,1},align=kCCTextAlignmentCenter,vAlign=kCCVerticalTextAlignmentTop,widthSize=450},
			{str=getlocal(heroSkillCfg[sid].name)..lvStr,size=greSize,pos={140,secHeiPos},aPos={0,0.5},color=heroVoApi:getSkillColorByLv(level),align=kCCTextAlignmentLeft,vAlign=kCCVerticalTextAlignmentTop,widthSize=350},
			{str=getlocal(heroSkillCfg[sid].des,{value}),size=23,pos={140,thrHeiPos},aPos={0,0.5},align=kCCTextAlignmentLeft,vAlign=kCCVerticalTextAlignmentTop,widthSize=350},
		}
		for k,v in pairs(lbTB) do
			local strLb=GetTTFLabelWrap(v.str,v.size,CCSizeMake(v.widthSize,0),v.align,v.vAlign)
			strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
			if v.color then
				strLb:setColor(v.color)
			end
			strLb:setPosition(ccp(v.pos[1],v.pos[2]))
			skillBg:addChild(strLb)
		end
		skillBg:setScale(0.2)
		local scale=CCScaleTo:create(0.5,1)
		skillBg:runAction(scale)
	end
	local showSkillCallFunc=CCCallFunc:create(showSkillFunc)
	acArr:addObject(showSkillCallFunc)

	--显示确认按钮和授勋技能
	local showBtnDelay=CCDelayTime:create(2)
	acArr:addObject(showBtnDelay)
	local function showBtn()
		local function onConfirm()
			self.taskBtnItem:setEnabled(false)
			self.mvLayer:stopAllActions()
			self.mvLayer:removeFromParentAndCleanup(true)
			self.mvLayer=nil
			self:close()
		end
		local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25,518)
		local okBtn=CCMenu:createWithItem(okItem)
		okBtn:setPosition(ccp(G_VisibleSizeWidth/2,60))
		okBtn:setTouchPriority(-(self.layerNum-1)*20-8)
		self.mvLayer:addChild(okBtn)
	end
	local showBtnCallFunc=CCCallFunc:create(showBtn)
	acArr:addObject(showBtnCallFunc)

	local sequence=CCSequence:create(acArr)
	self.mvLayer:runAction(sequence)
end

function heroHonorTaskDialog:refreshData()
	self.data=heroVoApi:getHeroByHid(self.data.hid)
	local flag=false
	for k,v in pairs(self.taskCfg) do
		if(v[1]==self.data.taskID)then
			self.curStep=k
			flag=true
			break
		end
	end
	if(flag==false)then
		self.curStep=1
	end
	-- if(self.data.productOrder==5)then
	-- 	self.taskBtnItem:setEnabled(false)
	-- 	return
	-- end
	self.tv:reloadData()
	-- if(self.curStep and self.curStep>0)then
	-- 	self.tv:recoverToRecordPoint(ccp(0,(self.curStep - 1)*self.cellHeight))
	-- end
	if(heroVoApi:getCurrentHonorHero()~=nil and heroVoApi:getCurrentHonorHero().hid==self.data.hid)then
		if(self.curStep==#self.taskCfg and self.data.taskProceed>=self.taskCfg[#self.taskCfg][2])then
			tolua.cast(self.taskBtnItem:getChildByTag(518),"CCLabelTTF"):setString(getlocal("hero_honor_doHonor"))
			self.taskBtnItem:setPositionX(-85)
			if(self.dropItem==nil)then
				local function onCancel()
					self:cancelTask()
				end
				self.dropItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onCancel,nil,getlocal("dailyTaskCancel"),25,518)
				self.dropItem:setPositionX(85)
				self.taskBtn:addChild(self.dropItem)
			end
		else
			tolua.cast(self.taskBtnItem:getChildByTag(518),"CCLabelTTF"):setString(getlocal("dailyTaskCancel"))
			self.taskBtnItem:setPositionX(0)
			if(self.dropItem)then
				self.dropItem:removeFromParentAndCleanup(true)
				self.dropItem=nil
			end
		end
	else
		tolua.cast(self.taskBtnItem:getChildByTag(518),"CCLabelTTF"):setString(getlocal("daily_scene_get"))
		self.taskBtnItem:setPositionX(0)
		if(self.dropItem)then
			self.dropItem:removeFromParentAndCleanup(true)
			self.dropItem=nil
		end
	end
end

function heroHonorTaskDialog:dealWithEvent(event,data)
	if(data.type=="update")then
		self:refreshData()
	elseif(data.type=="accept")then
		if(data.hid==self.data.hid)then
			self:refreshData()
		end
	end
end

function heroHonorTaskDialog:dispose()
	if(self.mvLayer)then
		self.mvLayer:stopAllActions()
	end
	eventDispatcher:removeEventListener("hero.honor",self.honorListener)
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/vipHeadBg.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	spriteController:removePlist("public/newDisplayImage.plist")
	spriteController:removeTexture("public/newDisplayImage.png")
end