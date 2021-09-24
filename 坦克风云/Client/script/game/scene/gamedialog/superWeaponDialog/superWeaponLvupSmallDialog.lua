-- 超级武器进阶时候的小面板
superWeaponLvupSmallDialog=smallDialog:new()

function superWeaponLvupSmallDialog:new(weaponID,propNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.weaponID=weaponID
	nc.propNum=propNum
	nc.dialogWidth=550
	nc.dialogHeight=750
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    local function addPlist()
    	spriteController:addPlist("public/swYouhuaUI.plist")
	    spriteController:addTexture("public/swYouhuaUI.png")
    end
    G_addResource8888(addPlist)
	return nc
end

function superWeaponLvupSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self.data=superWeaponVoApi:getWeaponByID(self.weaponID)
	if(superWeaponCfg.skillLvl[self.data.lv]==superWeaponCfg.skillLvl[self.data.lv - 1])then
		self.dialogHeight = 610
	end
	local attTb=self.data:getAtt()
	if(SizeOfTable(attTb)>6)then
		self.dialogHeight=math.min(G_VisibleSizeHeight,self.dialogHeight + 85)
	end
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function superWeaponLvupSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	-- local titLbSize = 19
	-- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
	-- 	titLbSize =25
	-- end
	local titileName=getlocal("equip_upgrade_success") -- 标题
	local titleLb=GetTTFLabelWrap(titileName,28,CCSizeMake(self.dialogWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 40 - titleLb:getContentSize().height/2))
	dialogBg:addChild(titleLb,1)

	-- panelTitleBg
	local  titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
	dialogBg:addChild(titleBg)
	titleBg:setPosition(self.dialogWidth/2,self.dialogHeight - 40 - titleLb:getContentSize().height/2)
	titleBg:setContentSize(CCSizeMake(300,math.max(titleLb:getContentSize().height,50)))
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function superWeaponLvupSmallDialog:initContent()

	local weaponIconY=self.dialogHeight - 170+20
	local namePosX=200
	local weaponIcon=CCSprite:createWithSpriteFrameName(self.data:getConfigData("bigIcon"))
	weaponIcon:setScale(130/weaponIcon:getContentSize().width)
	weaponIcon:setPosition(ccp(namePosX/2,self.dialogHeight - 170))
	self.bgLayer:addChild(weaponIcon,1)

	local bottomBg=CCSprite:createWithSpriteFrameName("swTechLightBg.png")
	self.bgLayer:addChild(bottomBg)
	bottomBg:setPosition(ccp(namePosX/2,self.dialogHeight - 185))

	local upBg=CCSprite:createWithSpriteFrameName("swTechLight.png")
	self.bgLayer:addChild(upBg,3)
	upBg:setPosition(ccp(namePosX/2,self.dialogHeight - 185))
	upBg:setOpacity(180)

	-- 描述1，描述2，描述3
	local des1,des2,des3
	local weaponName=getlocal(self.data:getConfigData("name")) -- 武器名字
	local lv=self.data.lv -- 武器等阶
	des1=getlocal("super_weapon_lvup_des1",{weaponName,lv})
	des2=getlocal("super_weapon_lvup_des2")
	des3=getlocal("super_weapon_lvup_des3",{self.propNum})

	local posTb={{weaponIconY+50,des1},{weaponIconY,des2},{weaponIconY-50,des3}}
	for k,v in pairs(posTb) do
		local pointSp=CCSprite:createWithSpriteFrameName("circleSelect.png")
		self.bgLayer:addChild(pointSp)
		pointSp:setPosition(namePosX,v[1])
		pointSp:setAnchorPoint(ccp(0,1))

		local desLb=G_getRichTextLabel(v[2],{nil,G_ColorGreen,nil},22,self.dialogWidth-namePosX-50,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
		-- GetTTFLabelWrap(v[2],22,CCSizeMake(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		desLb:setAnchorPoint(ccp(0,1))
		desLb:setPosition(namePosX+30,v[1])
		self.bgLayer:addChild(desLb)
	end

	if(superWeaponCfg.skillLvl[self.data.lv]~=superWeaponCfg.skillLvl[self.data.lv - 1])then
		local skillH=self.dialogHeight - 310
		-- 技能提升
		local skillTitleLb=GetTTFLabel(getlocal("super_weapon_skill_upgrade"),25)
		skillTitleLb:setAnchorPoint(ccp(0,0.5))
		skillTitleLb:setPosition(ccp(25,skillH))
		self.bgLayer:addChild(skillTitleLb,1)

		local function nilFunc()
		end
		local  skillTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105, 16, 1, 1),nilFunc)
		self.bgLayer:addChild(skillTitleBg)
		skillTitleBg:setAnchorPoint(ccp(0,0.5))
		skillTitleBg:setPosition(15,skillH)
		skillTitleBg:setContentSize(CCSizeMake(self.dialogWidth-60,40))

		-- local blueBg=CCSprite:createWithSpriteFrameName("awBlueBg.png")
		-- self.bgLayer:addChild(blueBg)
		-- blueBg:setPosition(ccp(self.dialogWidth/2,skillH))
		-- blueBg:setScale(0.6)


		local result,ifHasSuitEffect,ifHasSkillEffect=superWeaponVoApi:getSuitList(self.weaponID)
	    local lvParamStr = ""
	    if ifHasSkillEffect==true then
	    	lvParamStr="(+1)"
	    end
		local skillLv=superWeaponCfg.skillLvl[self.data.lv]
		local skillName=getlocal(abilityCfg[self.data:getConfigData("skillID")][skillLv].name).." "..getlocal("fightLevel",{skillLv})..lvParamStr

		local cfg=abilityCfg[self.data:getConfigData("skillID")][skillLv]
		if ifHasSkillEffect==true then
			cfg=abilityCfg[self.data:getConfigData("skillID")][skillLv+1]
		end
		local v1=cfg.value1
		local v2=cfg.value2
		local v3=cfg.SpTop
		if(v1 and v1<1)then
			v1=G_keepNumber(v1*100,0).."%%"
		end
		if(v2 and v2<1)then
			v2=G_keepNumber(v2*100,0).."%%"
		end
		local skillStr=getlocal(cfg.desc,{v1,v2,v3})

		skillH=skillH-40
		local skillNameLb=GetTTFLabel(skillName,22)
		skillNameLb:setColor(G_ColorYellowPro)
		skillNameLb:setAnchorPoint(ccp(0,0.5))
		skillNameLb:setPosition(ccp(20,skillH))
		self.bgLayer:addChild(skillNameLb)

		skillH=skillH-20
		local skillDesLb=GetTTFLabelWrap(skillStr,22,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		skillDesLb:setAnchorPoint(ccp(0,1))
		skillDesLb:setPosition(20,skillH)
		self.bgLayer:addChild(skillDesLb)
	end
	




	-- --初始化属性五边形或六边形
	-- local att=self.data:getAtt()
	-- local attLimit=self.data:getUpgradeLimit()
	-- local shapeBg
	-- --图标的位置
	-- local attIconPos
	-- --顶点的位置
	-- local attLimitPointPos
	-- --进度点的配置
	-- local attPointPos={}
	-- local centerPoint
	-- if(SizeOfTable(att)==5)then
	-- 	shapeBg=CCSprite:createWithSpriteFrameName("superWeapon_upgrade5.png")
	-- 	attIconPos={ccp(360,self.dialogHeight - 127),ccp(230,self.dialogHeight - 230),ccp(290,self.dialogHeight - 373),ccp(430,self.dialogHeight - 373),ccp(490,self.dialogHeight - 230)}
	-- 	attLimitPointPos={ccp(360,self.dialogHeight - 163),ccp(269,self.dialogHeight - 230),ccp(303,self.dialogHeight - 338),ccp(417,self.dialogHeight - 338),ccp(451,self.dialogHeight - 230)}
	-- 	centerPoint=ccp(360,self.dialogHeight - 258)
	-- 	shapeBg:setPosition(ccp(367,self.dialogHeight - 250))
	-- else
	-- 	shapeBg=CCSprite:createWithSpriteFrameName("superWeapon_upgrade6.png")
	-- 	attIconPos={ccp(280,self.dialogHeight - 135),ccp(225,self.dialogHeight - 255),ccp(280,self.dialogHeight - 375),ccp(440,self.dialogHeight - 375),ccp(495,self.dialogHeight - 255),ccp(440,self.dialogHeight - 135)}
	-- 	attLimitPointPos={ccp(310,self.dialogHeight - 170),ccp(263,self.dialogHeight - 255),ccp(310,self.dialogHeight - 340),ccp(410,self.dialogHeight - 340),ccp(457,self.dialogHeight - 255),ccp(410,self.dialogHeight - 170)}
	-- 	centerPoint=ccp(360,self.dialogHeight - 255)
	-- 	shapeBg:setPosition(ccp(359,self.dialogHeight - 255))
	-- end
	-- -- for k,v in pairs(attLimitPointPos) do
	-- -- 	local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- -- 	lineWhite:setPosition(attLimitPointPos[k])
	-- -- 	self.bgLayer:addChild(lineWhite,5)
	-- -- end
	-- -- local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- -- lineWhite:setPosition(centerPoint)
	-- -- self.bgLayer:addChild(lineWhite,5)
	-- self.bgLayer:addChild(shapeBg)
	-- for k,v in pairs(attLimit) do
	-- 	local attKey=self.data:getConfigData("att")[k]
	-- 	local attBtn=CCSprite:createWithSpriteFrameName(buffEffectCfg[attKey].icon2)
	-- 	attBtn:setScale(65/attBtn:getContentSize().width)
	-- 	attBtn:setPosition(attIconPos[k])
	-- 	self.bgLayer:addChild(attBtn,1)
	-- 	local limitPos=attLimitPointPos[k]
	-- 	local percent=v/superWeaponCfg.attLimitCfg[attKey]
	-- 	attPointPos[k]=ccp((limitPos.x - centerPoint.x)*percent + centerPoint.x,(limitPos.y - centerPoint.y)*percent + centerPoint.y)
	-- end
	-- local num=#attPointPos
	-- for k,v in pairs(attPointPos) do
	-- 	local targetPos
	-- 	if(k==num)then
	-- 		targetPos=attPointPos[1]
	-- 	else
	-- 		targetPos=attPointPos[k + 1]
	-- 	end
	-- 	local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- 	lineWhite:setScaleX((self:distance(targetPos,v) + 1)/lineWhite:getContentSize().width)
	-- 	lineWhite:setColor(ccc3(44,230,249))
	-- 	local angle
	-- 	if(targetPos.x==v.x)then
	-- 		angle=90
	-- 	else
	-- 		angle=math.deg(math.atan((targetPos.y - v.y)/(targetPos.x - v.x)))
	-- 	end		
	-- 	lineWhite:setRotation(-angle)
	-- 	lineWhite:setPosition(ccp((targetPos.x + v.x)/2,(targetPos.y + v.y)/2))
	-- 	self.bgLayer:addChild(lineWhite)
	-- end

	local att=self.data:getAtt()
	local attLimit=self.data:getUpgradeLimit()
	local posY = self.dialogHeight - 310
	if(superWeaponCfg.skillLvl[self.data.lv]~=superWeaponCfg.skillLvl[self.data.lv - 1])then
		posY = self.dialogHeight - 450
	end
	local tab1Lb=GetTTFLabel(getlocal("attribute_add"),25)
	tab1Lb:setAnchorPoint(ccp(0,0.5))
	tab1Lb:setPosition(ccp(25,posY))
	self.bgLayer:addChild(tab1Lb,1)

	-- panelSubTitleBg
	local function nilFunc()
	end
	local  tab1Bg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105, 16, 1, 1),nilFunc)
	self.bgLayer:addChild(tab1Bg)
	tab1Bg:setAnchorPoint(ccp(0,0.5))
	tab1Bg:setPosition(15,posY)
	tab1Bg:setContentSize(CCSizeMake(self.dialogWidth-60,40))

	-- local blueBg=CCSprite:createWithSpriteFrameName("awBlueBg.png")
	-- self.bgLayer:addChild(blueBg)
	-- blueBg:setPosition(ccp(self.dialogWidth/2,posY))
	-- blueBg:setScale(0.6)

	-- local tab1=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
	-- tab1:setScaleX((tab1Lb:getContentSize().width + 20)/tab1:getContentSize().width)
	-- tab1:setAnchorPoint(ccp(0,1))
	-- tab1:setPosition(ccp(10,posY))
	-- self.bgLayer:addChild(tab1)
	posY = posY - 25
	local attMap={}
	for attKey,v in pairs(att) do
		table.insert(attMap,attKey)
	end
	local function sortFunc(a,b)
		for k,v in pairs(buffOrderCfg) do
			if(v==a)then
				return true
			elseif(v==b)then
				return false
			end
		end
		return true
	end
	table.sort(attMap,sortFunc)
	local tmpData=superWeaponVo:new(self.data.id)
	for k,v in pairs(self.data) do
		tmpData[k]=v
	end
	tmpData.lv=self.data.lv - 1
	local oldAtt
	if(tmpData.lv>0)then
		oldAtt=tmpData:getAtt()
	else
		oldAtt={}
		for k,v in pairs(att) do
			oldAtt[k]=0
		end
	end
	for k,v in pairs(attMap) do
		local iconY
		local iconX
		if(k<4)then
			iconY=posY - 40
			iconX=20 + (k - 1)*170
		elseif(k<7)then
			iconY=posY - 120
			iconX=20 + (k - 4)*170
		else
			iconY=posY - 205
			iconX=20 + (k - 7)*170
		end
		local attKey=v
		if(buffEffectCfg[attKey].icon and buffEffectCfg[attKey].icon~="")then
			local icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[attKey].icon)
			if(icon)then
				icon:setScale(60/icon:getContentSize().width)
				icon:setAnchorPoint(ccp(0,0.5))
				icon:setPosition(ccp(iconX,iconY))
				self.bgLayer:addChild(icon)
			end
		end
		local nameLb=GetTTFLabel(getlocal(buffEffectCfg[attKey].name),22)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(iconX + 63,iconY + 15))
		self.bgLayer:addChild(nameLb)
		local value
		if(attKey<200)then
			value=(oldAtt[attKey]*100).."%"
		else
			value=oldAtt[attKey]
		end
		local valueLb=GetTTFLabel(value,22/1.2)
		valueLb:setAnchorPoint(ccp(0,0.5))
		valueLb:setPosition(ccp(iconX + 83,iconY - 15))
		self.bgLayer:addChild(valueLb)
		local function onScaleEnd()
			local newValue
			if(attKey<200)then
				newValue=G_keepNumber(att[attKey]*100,1).."%"
			else
				newValue=att[attKey]
			end
			valueLb:setString(newValue)
			valueLb:setColor(G_ColorYellowPro)
		end
		local callFunc=CCCallFunc:create(onScaleEnd)
		local delay=CCDelayTime:create(0.5)
		local scaleTo1=CCScaleTo:create(0.7, 1.2)
		-- local scaleTo2=CCScaleTo:create(0.4, 1)
		local acArr=CCArray:create()
		acArr:addObject(delay)
		acArr:addObject(scaleTo1)
		-- acArr:addObject(scaleTo2)
		acArr:addObject(callFunc)
		local seq=CCSequence:create(acArr)
		valueLb:runAction(seq)
	end
	-- posY=posY - 175
	-- if(SizeOfTable(att)>6)then
	-- 	posY=posY - 85
	-- end
	-- if(superWeaponCfg.skillLvl[self.data.lv]~=superWeaponCfg.skillLvl[self.data.lv - 1])then
	-- 	local tab2Lb=GetTTFLabel(getlocal("heroSkillUpdate"),22)
	-- 	tab2Lb:setAnchorPoint(ccp(0,1))
	-- 	tab2Lb:setPosition(ccp(20,posY - 10))
	-- 	self.bgLayer:addChild(tab2Lb,1)
	-- 	local tab2=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
	-- 	tab2:setScaleX((tab2Lb:getContentSize().width + 20)/tab2:getContentSize().width)
	-- 	tab2:setAnchorPoint(ccp(0,1))
	-- 	tab2:setPosition(ccp(10,posY))
	-- 	self.bgLayer:addChild(tab2)
	-- 	posY=posY - tab2:getContentSize().height - 10
	-- 	local skillLv=superWeaponCfg.skillLvl[self.data.lv]
	-- 	local nameLb=GetTTFLabel(getlocal(abilityCfg[self.data:getConfigData("skillID")][skillLv].name),25)
	-- 	nameLb:setAnchorPoint(ccp(0,1))
	-- 	nameLb:setPosition(ccp(20,posY - 10))
	-- 	self.bgLayer:addChild(nameLb)
	-- 	local lvLb=GetTTFLabel(getlocal("fightLevel",{skillLv}),25)
	-- 	lvLb:setAnchorPoint(ccp(0,1))
	-- 	lvLb:setPosition(ccp(20,posY - 35))
	-- 	self.bgLayer:addChild(lvLb)
	-- end
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",close,nil,getlocal("confirm"),25)
	okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(ccp(self.dialogWidth/2,60))
	self.bgLayer:addChild(okBtn)
end

function superWeaponLvupSmallDialog:distance(pos1,pos2)
	return math.sqrt((pos2.x - pos1.x)*(pos2.x - pos1.x) + (pos2.y - pos1.y)*(pos2.y - pos1.y))
end

function superWeaponLvupSmallDialog:dispose()
	self.data=nil
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("public/swYouhuaUI.plist")
    spriteController:removeTexture("public/swYouhuaUI.png")
end