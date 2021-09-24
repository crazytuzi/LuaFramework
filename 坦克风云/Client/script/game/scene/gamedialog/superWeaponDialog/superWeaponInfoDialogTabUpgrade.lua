--超级武器强化的tab
superWeaponInfoDialogTabUpgrade={}
function superWeaponInfoDialogTabUpgrade:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.selectedID=nil
	nc.selectedAtt=nil
	nc.expertLayer=nil
	nc.cellHeight=120
	nc.pinFlag=true
	local function addPlist()
		spriteController:addPlist("public/armorMatrix.plist")
	    spriteController:addTexture("public/armorMatrix.png")
	    spriteController:addPlist("public/swYouhuaUI.plist")
	    spriteController:addTexture("public/swYouhuaUI.png")
	end
	G_addResource8888(addPlist)
	
	return nc
end

function superWeaponInfoDialogTabUpgrade:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	local function onDataChange(event,data)
		self.isStrenth=true
		if self.pinFlag==false then
			self.pinFlag=true
			self.isStrenth=false
		end
		self:refresh()
	end
	eventDispatcher:addEventListener("superweapon.data.info",onDataChange)
	self.eventListener=onDataChange
	self:initList()
	self:initUpgrade()
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("super_weapon_upgradeInfo"),"\n"}
		local tabColor ={G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 30,G_VisibleSizeHeight - 320))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,2)
	return self.bgLayer
end

function superWeaponInfoDialogTabUpgrade:initList()
	self.weaponList={}
	self.weaponIconList={}
	for k,v in pairs(superWeaponVoApi:getWeaponList()) do
		table.insert(self.weaponList,v)
	end
	if(#self.weaponList==0)then
		do return end
	end

	-- 展示列表，获得未获得的全展示

	local function isExist(weaponList,id)
		for k,v in pairs(weaponList) do
			if v.id==id then
				return true
			end
		end
		return false
	end
	self.newShowList={}
	for k,v in pairs(superWeaponCfg.weaponCfg) do
		if isExist(self.weaponList,k) then
			table.insert(self.newShowList,{id=k,sid=v.sid})
		else
			table.insert(self.newShowList,{id=k,sid=v.sid+1000})
		end
	end

	local function sortShowList(a,b)
		return a.sid<b.sid
	end
	table.sort(self.newShowList, sortShowList)


	local function sortFunc(a,b)
		local id1=tonumber(string.sub(a.id,2))
		local id2=tonumber(string.sub(b.id,2))
		return id1<id2
	end
	table.sort(self.weaponList,sortFunc)
	local addH=12
	if(self.tvBg==nil)then
		local function nilFunc( ... )
		end
		self.tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
		self.tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50,self.cellHeight-10))
		self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight -237+addH))
		self.bgLayer:addChild(self.tvBg)
	end
	if(self.tv)then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
		local index
		for k,v in pairs(self.weaponList) do
			if(v.id==self.selectedID)then
				index=k
				break
			end
		end
		if(index)then
			self:switchWeapon(index,true)
		end
	else
		self.selectedID=self.weaponList[1].id
		local function callback(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callback)
		self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 70,self.cellHeight),nil)
		self.tv:setAnchorPoint(ccp(0,0))
		self.tv:setPosition(ccp(35,G_VisibleSizeHeight - 302+addH+7))
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		self.tv:setMaxDisToBottomOrTop(80)
		self.bgLayer:addChild(self.tv,1)
		local pageLeft=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
		pageLeft:setPosition(ccp(20,G_VisibleSizeHeight - 240+addH))
		self.bgLayer:addChild(pageLeft,1)
		local pageRight=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
		pageRight:setFlipX(true)
		pageRight:setPosition(ccp(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 240+addH))
		self.bgLayer:addChild(pageRight,1)
	end
end

function superWeaponInfoDialogTabUpgrade:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		-- return SizeOfTable(self.weaponList)
		return SizeOfTable(self.newShowList)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.cellHeight,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()


		local id=self.newShowList[idx + 1].id
		local data=self.weaponList[idx + 1]
		local function onClick(object,fn,tag)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				if data then
					local index=tag - 100 + 1
					self:switchWeapon(index,false)
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_noHad"),30)
				end
			end
		end
		local icon = LuaCCSprite:createWithSpriteFrameName(superWeaponCfg.weaponCfg[id].icon,onClick)
		icon:setTag(100 + idx)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		icon:setScale(100/icon:getContentSize().height)
		-- icon:setAnchorPoint(ccp(0,0))
		icon:setPosition(self.cellHeight/2,self.cellHeight/2)
		cell:addChild(icon)
		self.weaponIconList[idx + 1]=icon

		if not data then
			icon:setOpacity(0)
			local jianyinSp=CCSprite:createWithSpriteFrameName("silhouette_" .. id .. ".png")
			icon:addChild(jianyinSp)
			jianyinSp:setPosition(icon:getContentSize().width/2,icon:getContentSize().height/2)
		end

		local blackSp
		local function nilFunc()
	    end
	    blackSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	    blackSp:setTouchPriority(-(self.layerNum-1)*20-1)
	    local rect=CCSizeMake(100,100)
	    blackSp:setContentSize(rect)
	    blackSp:setOpacity(180)
	    -- blackSp:setAnchorPoint(ccp(0,0))
	    blackSp:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
	    icon:addChild(blackSp,2)
	    blackSp:setTag(99)
		


		if data and (self.selectedID==data.id)then
			blackSp:setVisible(false)
			icon:setScale(self.cellHeight/icon:getContentSize().width)
			if(self.selectedSp)then
				self.selectedSp:removeFromParentAndCleanup(true)
			end
			local frames=CCArray:create()
			for i=1,20 do
				local nameStr = "RotatingEffect"..i..".png"
				local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				frames:addObject(frame)
			end
			local pBAnimation = CCAnimation:createWithSpriteFrames(frames,0.05)
			local pBAnimate = CCAnimate:create(pBAnimation)
			self.selectedSp = CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
			self.selectedSp:runAction(CCRepeatForever:create(pBAnimate))
			self.selectedSp:setScale(icon:getContentSize().width/self.selectedSp:getContentSize().width)
			self.selectedSp:setPosition(getCenterPoint(icon))
			self.selectedSp:setVisible(false)
			icon:addChild(self.selectedSp)
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

function superWeaponInfoDialogTabUpgrade:switchWeapon(index,forceRefresh)
	if(forceRefresh==false and self.weaponList[index].id==self.selectedID)then
		do return end
	end
	if(self and self.selectedSp and self.weaponIconList[index])then
		if(self.selectedID~=self.weaponList[index].id)then
			self.selectedAtt=nil
			self.selectedID=self.weaponList[index].id
			self.selectedSp:removeFromParentAndCleanup(false)
			self.selectedSp:setPosition(getCenterPoint(self.weaponIconList[index]))
			self.weaponIconList[index]:addChild(self.selectedSp)
			self.selectedSp:setVisible(false)

			for k,v in pairs(self.weaponIconList) do
				local child=tolua.cast(v:getChildByTag(99),"LuaCCScale9Sprite")
				if k==index then
					v:setScale(self.cellHeight/v:getContentSize().width)
					child:setVisible(false)
				else
					v:setScale(100/v:getContentSize().width)
					child:setVisible(true)
				end
			end
		end
		self.attBtnTb=nil
		self:initUpgrade(index)
	end
end

function superWeaponInfoDialogTabUpgrade:initUpgrade(index)
	local strSize2 = 18
	local strSize3 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
     	strSize2 = 25
     	strSize3 = 28
	end
	if(index==nil)then
		index=1
	end
	local centerW=110
	local data=self.weaponList[index]
	if(self.upgradeLayer)then
		self.upgradeLayer:removeFromParentAndCleanup(true)
	end
	self.upgradeLayer=CCLayer:create()
	self.bgLayer:addChild(self.upgradeLayer)
	if(#self.weaponList==0)then
		local noLb=GetTTFLabelWrap(getlocal("super_weapon_noWeapon"),33,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noLb:setColor(G_ColorGray)
		noLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
		self.upgradeLayer:addChild(noLb)
		do return end
	end
	local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
	blueBg:setScaleX((G_VisibleSizeWidth - 44)/blueBg:getContentSize().width)
	blueBg:setAnchorPoint(ccp(0.5,1))
	blueBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 275))
	self.upgradeLayer:addChild(blueBg)

	local nameH=G_VisibleSizeHeight - 310
	local namePosX=150
	local curNameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),24,CCSizeMake(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
	curNameLb:setAnchorPoint(ccp(0.5,1))
	curNameLb:setPosition(ccp(namePosX,nameH))
	self.upgradeLayer:addChild(curNameLb,1)
	curNameLb:setColor(superWeaponVoApi:getWeaponColorByQuality(self.selectedID))

	local lvH=nameH-curNameLb:getContentSize().height
	local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24,true)
	self.upgradeLayer:addChild(lvLb)
	lvLb:setAnchorPoint(ccp(0.5,1))
	lvLb:setPosition(namePosX,lvH)


	local function nilFunc( ... )
	end
	local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png", CCRect(20, 20, 10, 10),nilFunc)
	nameBg:setContentSize(CCSizeMake(curNameLb:getContentSize().width + 30,curNameLb:getContentSize().height + 20))
	nameBg:setPosition(ccp(namePosX,G_VisibleSizeHeight - 345))
	self.upgradeLayer:addChild(nameBg)
	nameBg:setVisible(false)

	local function onShowDetail()
		local data=superWeaponVoApi:getWeaponByID(self.selectedID)
		if(data)then
			superWeaponVoApi:showWeaponDetailDialog(data.id,self.layerNum + 1)
		end
	end
	local icon=LuaCCSprite:createWithSpriteFrameName(data:getConfigData("bigIcon"),onShowDetail)
	icon:setTouchPriority(-(self.layerNum-1)*20-2)
	icon:setScale(160/icon:getContentSize().width)
	icon:setPosition(ccp(namePosX,G_VisibleSizeHeight - 460))
	self.upgradeLayer:addChild(icon)

	-- 添加详细数据按钮
	local detailLb = GetTTFLabel(getlocal("super_weapon_detail_info"),20)
	local detailItem = CCMenuItemLabel:create(detailLb)
	detailItem:registerScriptTapHandler(onShowDetail)

	local function actionArrow(flag)
		local scale1=1
		local scale2=2
		if flag==1 then
			scale1=1
			scale2=2
		end
		local acArr1=CCArray:create()
		local mvBy1=CCMoveBy:create(1,ccp(20*flag,0))
		-- local scaleTo=CCScaleTo:create(1,scale1)
		acArr1:addObject(mvBy1)
		-- acArr1:addObject(scaleTo)
		local spawn1=CCSpawn:create(acArr1)

		local acArr2=CCArray:create()
		local mvBy2=CCMoveBy:create(1,ccp(-20*flag,0))
		-- local scaleTo2=CCScaleTo:create(1,scale2)
		acArr2:addObject(mvBy2)
		-- acArr2:addObject(scaleTo2)
		local spawn2=CCSpawn:create(acArr2)

		local acArr=CCArray:create()
		acArr:addObject(spawn1)
		acArr:addObject(spawn2)
		local seq=CCSequence:create(acArr)
		local repeatForever=CCRepeatForever:create(seq)
		return repeatForever
	end
	local smallArrowY=detailLb:getContentSize().height/2
	local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
	smallArrowSp1:setAnchorPoint(ccp(1,0.5))
    smallArrowSp1:setPosition(ccp(-25,smallArrowY))
    detailLb:addChild(smallArrowSp1)
    -- smallArrowSp1:setScale(2)
    smallArrowSp1:runAction(actionArrow(1))

    local smallArrowSp11=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
	smallArrowSp11:setAnchorPoint(ccp(1,0.5))
    smallArrowSp11:setPosition(ccp(-40,smallArrowY))
    detailLb:addChild(smallArrowSp11)
    -- smallArrowSp11:setScale(2)
    smallArrowSp11:runAction(actionArrow(1))

    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
	smallArrowSp2:setAnchorPoint(ccp(0,0.5))
    smallArrowSp2:setPosition(ccp(detailLb:getContentSize().width+35,smallArrowY))
    detailLb:addChild(smallArrowSp2)
    smallArrowSp2:setRotation(180)
    -- smallArrowSp2:setScale(2)
    smallArrowSp2:runAction(actionArrow(-1))

    local smallArrowSp22=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
	smallArrowSp22:setAnchorPoint(ccp(0,0.5))
    smallArrowSp22:setPosition(ccp(detailLb:getContentSize().width+50,smallArrowY))
    detailLb:addChild(smallArrowSp22)
    smallArrowSp22:setRotation(180)
    -- smallArrowSp22:setScale(2)
    smallArrowSp22:runAction(actionArrow(-1))

	-- local detailItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onShowDetail,2,getlocal("super_weapon_detail_info"),25)
	-- detailItem:setScale(0.9)
	local detailBtn=CCMenu:createWithItem(detailItem)
	detailBtn:setPosition(ccp(namePosX,G_VisibleSizeHeight-435-135))
	detailBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.upgradeLayer:addChild(detailBtn)


	local att=data:getUpgradeAtt()
	local attLimit=data:getUpgradeLimit()
	if(self.selectedAtt==nil)then
		self.selectedAtt=1
	end
	local selectedAttKey=data:getConfigData("att")[self.selectedAtt]
	--初始化属性五边形或六边形
	local shapeBg
	--图标的位置
	local attIconPos
	--顶点的位置
	local attLimitPointPos
	--进度点的配置
	local attPointPos={}
	local centerPoint
	if(#att==5)then
		shapeBg=CCSprite:createWithSpriteFrameName("superWeapon_upgrade5.png")
		attIconPos={ccp(430,G_VisibleSizeHeight - 327),ccp(300,G_VisibleSizeHeight - 430),ccp(360,G_VisibleSizeHeight - 573),ccp(500,G_VisibleSizeHeight - 573),ccp(560,G_VisibleSizeHeight - 430)}
		attLimitPointPos={ccp(430,G_VisibleSizeHeight - 363),ccp(339,G_VisibleSizeHeight - 430),ccp(373,G_VisibleSizeHeight - 538),ccp(487,G_VisibleSizeHeight - 538),ccp(521,G_VisibleSizeHeight - 430)}
		centerPoint=ccp(430,G_VisibleSizeHeight - 458)
		shapeBg:setPosition(ccp(437,G_VisibleSizeHeight - 450))
	else
		shapeBg=CCSprite:createWithSpriteFrameName("superWeapon_upgrade6.png")
		attIconPos={ccp(350,G_VisibleSizeHeight - 335),ccp(295,G_VisibleSizeHeight - 455),ccp(350,G_VisibleSizeHeight - 575),ccp(510,G_VisibleSizeHeight - 575),ccp(565,G_VisibleSizeHeight - 455),ccp(510,G_VisibleSizeHeight - 335)}
		attLimitPointPos={ccp(380,G_VisibleSizeHeight - 370),ccp(333,G_VisibleSizeHeight - 455),ccp(380,G_VisibleSizeHeight - 540),ccp(480,G_VisibleSizeHeight - 540),ccp(527,G_VisibleSizeHeight - 455),ccp(480,G_VisibleSizeHeight - 370)}
		centerPoint=ccp(430,G_VisibleSizeHeight - 455)
		shapeBg:setPosition(ccp(429,G_VisibleSizeHeight - 455))
	end
	if(G_isIphone5())then
		nameBg:setPositionY(nameBg:getPositionY() - 20)
		curNameLb:setPositionY(curNameLb:getPositionY() - 20)
		lvLb:setPositionY(lvLb:getPositionY() - 20)
		icon:setPositionY(icon:getPositionY() - 30)
		detailBtn:setPositionY(detailBtn:getPositionY() - 35)
		centerPoint=ccp(centerPoint.x,centerPoint.y - 20)
		for k,v in pairs(attIconPos) do
			attIconPos[k]=ccp(attIconPos[k].x,attIconPos[k].y - 20)
			attLimitPointPos[k]=ccp(attLimitPointPos[k].x,attLimitPointPos[k].y - 20)
		end
		shapeBg:setPositionY(shapeBg:getPositionY() - 20)
	end
	-- for k,v in pairs(attLimitPointPos) do
	-- 	local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- 	lineWhite:setPosition(attLimitPointPos[k])
	-- 	self.upgradeLayer:addChild(lineWhite,5)
	-- end
	-- local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- lineWhite:setPosition(centerPoint)
	-- self.upgradeLayer:addChild(lineWhite,5)
	self.upgradeLayer:addChild(shapeBg)
	self.attBtnTb={}
	local function onClickAtt(object,fn,tag)
		for k,v in pairs(self.attBtnTb) do
			local tagTmp=v:getTag()
			if(tagTmp~=tag+1024)then
				v:setScale(50/v:getContentSize().width)
				local maxLb=tolua.cast(v:getChildByTag(99),"CCLabelTTF")
				maxLb:setScale(1/v:getScale())
			else
				v:setScale(65/v:getContentSize().width)
				local maxLb=tolua.cast(v:getChildByTag(99),"CCLabelTTF")
				maxLb:setScale(1/v:getScale())
				if(self.selectedAttSp and tolua.cast(self.selectedAttSp,"CCSprite"))then
					self.selectedAttSp:setPosition(attIconPos[k])
				else
					self.selectedAttSp=CCSprite:createWithSpriteFrameName("skillIconBg.png")
					self.selectedAttSp:setScale(70/self.selectedAttSp:getContentSize().width)
					self.selectedAttSp:setPosition(attIconPos[k])
					self.upgradeLayer:addChild(self.selectedAttSp,1)
				end
			end
		end
		self.selectedAtt=tag - 1024
		local selectedAttKey=data:getConfigData("att")[self.selectedAtt]
		local upgradeBg=tolua.cast(self.upgradeLayer:getChildByTag(100),"LuaCCScale9Sprite")
		if(upgradeBg)then
			local attIcon=tolua.cast(upgradeBg:getChildByTag(105),"CCLabelTTF")
			local posX,posY=attIcon:getPosition()
			attIcon:removeFromParentAndCleanup(true)
			attIcon=CCSprite:createWithSpriteFrameName(buffEffectCfg[selectedAttKey].icon)
			if(attIcon)then
				attIcon:setTag(105)
				attIcon:setScale(80/attIcon:getContentSize().width)
				attIcon:setAnchorPoint(ccp(0.5,0.5))
				attIcon:setPosition(posX,posY)
				-- if(G_isIphone5())then
				-- 	attIcon:setPosition(ccp(centerW,upgradeBg:getContentSize().height - 100))
				-- else
				-- 	attIcon:setPosition(ccp(centerW,upgradeBg:getContentSize().height - 65))
				-- end
				upgradeBg:addChild(attIcon)
			end
			local value,limit,grow,addvalue
			if(selectedAttKey<200)then
				value=G_keepNumber(att[self.selectedAtt]*100,1)
				limit=G_keepNumber(attLimit[self.selectedAtt]*100,2)
				grow=G_keepNumber(data:getConfigData("upgradeGrow")[selectedAttKey]*100,1)
				if value>=limit then
					addvalue=value
				else
					addvalue=value+grow
				end
				value=value .. "%"
				limit=limit .. "%"
				grow=grow .. "%"
				addvalue=addvalue .. "%"
			else
				value=att[self.selectedAtt]
				limit=attLimit[self.selectedAtt]
				grow=data:getConfigData("upgradeGrow")[selectedAttKey]
				if value>=limit then
					addvalue=value
				else
					addvalue=value+grow
				end
			end
			local attNameLb=tolua.cast(upgradeBg:getChildByTag(101),"CCLabelTTF")
			attNameLb:setString(getlocal(buffEffectCfg[selectedAttKey].name))
			local testLb = GetTTFLabel(getlocal(buffEffectCfg[selectedAttKey].name),24)
			if testLb:getContentSize().width > 150 then
				attNameLb:setFontSize(18)
			else
				attNameLb:setFontSize(24)
			end
			-- local attValueLb=tolua.cast(upgradeBg:getChildByTag(102),"CCLabelTTF")
			-- attValueLb:setString(getlocal("super_weapon_add_value",{value}))
			local valueLb=tolua.cast(upgradeBg:getChildByTag(151),"CCLabelTTF")
			valueLb:setString(value)
			local addValueLb=tolua.cast(upgradeBg:getChildByTag(152),"CCLabelTTF")
			addValueLb:setString(addvalue)
			local limitValueLb=tolua.cast(upgradeBg:getChildByTag(103),"CCLabelTTF")
			limitValueLb:setString(limit)
			-- local attGrowLb=tolua.cast(upgradeBg:getChildByTag(104),"CCLabelTTF")
			-- attGrowLb:setString(getlocal("super_weapon_add_rebuild",{grow}))
			local originCost=superWeaponCfg.growCost[(data.upgradeList[self.selectedAtt] or 0) + 1]
			local originLb=tolua.cast(upgradeBg:getChildByTag(303),"CCLabelTTF")
			originLb:setString(FormatNumber(originCost))
			local lineDelete=tolua.cast(upgradeBg:getChildByTag(304),"CCSprite")
			if(lineDelete)then
				lineDelete:setScaleX((originCostLb:getContentSize().width + 10)/lineDelete:getContentSize().width)
			end
			self.rebuildCost=originCost
			local rebuildCostLb=tolua.cast(upgradeBg:getChildByTag(301),"CCLabelTTF")
			local rebuildCostIcon=tolua.cast(upgradeBg:getChildByTag(302),"CCSprite")
			if(superWeaponVoApi:getExpertList()["m1"] and superWeaponVoApi:getExpertList()["m1"]>0)then
				self.rebuildCost=math.ceil(self.rebuildCost*(1 - superWeaponCfg.masterRand[1]))
				rebuildCostLb:setPositionX(280 + originCostLb:getContentSize().width/2 + 10)
				rebuildCostLb:setString(FormatNumber(self.rebuildCost))
				rebuildCostIcon:setPositionX(rebuildCostLb:getPositionX() + rebuildCostLb:getContentSize().width + 5)
			else
				rebuildCostLb:setString(FormatNumber(self.rebuildCost))
				rebuildCostIcon:setPositionX(280 + originCostLb:getContentSize().width/2 + 10)
			end
		end
	end
	for k,v in pairs(att) do
		local attKey=data:getConfigData("att")[k]
		local attBtn=CCSprite:createWithSpriteFrameName(buffEffectCfg[attKey].icon2)
		if(k==self.selectedAtt)then
			attBtn:setScale(65/attBtn:getContentSize().width)
			if(self.selectedAttSp and tolua.cast(self.selectedAttSp,"CCSprite"))then
				self.selectedAttSp:setPosition(attIconPos[k])
			else
				self.selectedAttSp=CCSprite:createWithSpriteFrameName("skillIconBg.png")
				self.selectedAttSp:setScale(70/self.selectedAttSp:getContentSize().width)
				self.selectedAttSp:setPosition(attIconPos[k])
				self.upgradeLayer:addChild(self.selectedAttSp,1)
			end
		else
			attBtn:setScale(50/attBtn:getContentSize().width)
		end
		attBtn:setTag(2048 + k)
		-- attBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		attBtn:setPosition(attIconPos[k])
		self.upgradeLayer:addChild(attBtn,2)
		self.attBtnTb[k]=attBtn

		local attBtn2=LuaCCSprite:createWithSpriteFrameName(buffEffectCfg[attKey].icon2,onClickAtt)
		self.upgradeLayer:addChild(attBtn2,3)
		attBtn2:setPosition(attIconPos[k])
		attBtn2:setScale(90/attBtn2:getContentSize().width)
		attBtn2:setTouchPriority(-(self.layerNum-1)*20-2)
		attBtn2:setTag(1024 + k)
		attBtn2:setVisible(false)

		-- 属性达到当前最大值，添加max显示
		local maxLb=GetTTFLabel(getlocal("donatePointMax"),22)
		attBtn:addChild(maxLb)
		maxLb:setScale(1/attBtn:getScale())
		maxLb:setAnchorPoint(ccp(0.5,1))
		maxLb:setPosition(attBtn:getContentSize().width/2,20)
		maxLb:setColor(G_ColorBlack)
		maxLb:setTag(99)
		maxLb:setVisible(false)

		local space=2
		local mCenterP=maxLb:getContentSize()
		local maxMTb={ccp(mCenterP.width/2+2,mCenterP.height/2),ccp(mCenterP.width/2,mCenterP.height/2+2),ccp(mCenterP.width/2-1,mCenterP.height/2),ccp(mCenterP.width/2,mCenterP.height/2-2)}
		for k,v in pairs(maxMTb) do
			local mLb=GetTTFLabel(getlocal("donatePointMax"),22)
			maxLb:addChild(mLb)
			mLb:setPosition(v)
			if k<4 then
				mLb:setColor(G_ColorBlack)
			else
				mLb:setColor(G_ColorYellowPro)
			end
		end

		if(att[k]>=attLimit[k])then
			maxLb:setVisible(true)
		end

		local limitPos=attLimitPointPos[k]
		-- local percent=v/superWeaponCfg.attLimitCfg[attKey]
		-- 默认有0.1 防止初始是一个点
		local percent=v/(superWeaponCfg.attLimitCfg[attKey]/0.9)+0.1
		attPointPos[k]=ccp((limitPos.x - centerPoint.x)*percent + centerPoint.x,(limitPos.y - centerPoint.y)*percent + centerPoint.y)
	end
	local num=#attPointPos
	for k,v in pairs(attPointPos) do
		local targetPos
		if(k==num)then
			targetPos=attPointPos[1]
		else
			targetPos=attPointPos[k + 1]
		end
		local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
		lineWhite:setScaleX((self:distance(targetPos,v) + 1)/lineWhite:getContentSize().width)
		lineWhite:setColor(ccc3(0,249,124))
		lineWhite:setScaleY(2)
		local angle
		if(targetPos.x==v.x)then
			angle=90
		else
			angle=math.deg(math.atan((targetPos.y - v.y)/(targetPos.x - v.x)))
		end		
		lineWhite:setRotation(-angle)
		lineWhite:setPosition(ccp((targetPos.x + v.x)/2,(targetPos.y + v.y)/2))
		self.upgradeLayer:addChild(lineWhite)
	end



	local isLongSize
	if(G_isIphone5())then
		isLongSize=true
	else
		isLongSize=false
	end
	local upgradeSize
	if(isLongSize)then
		upgradeSize=CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 680)
	else
		upgradeSize=CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 645)
	end

	blueBg:setScaleY((G_VisibleSizeHeight - 300 - upgradeSize.height)/blueBg:getContentSize().height)
	local upgradeBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(10,10,80,80),nilFunc)
	upgradeBg:setTag(100)
	upgradeBg:setContentSize(upgradeSize)
	upgradeBg:setAnchorPoint(ccp(0.5,0))
	upgradeBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.upgradeLayer:addChild(upgradeBg)
	upgradeBg:setOpacity(0)

	local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(ccp(0,0))
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(upgradeBg:getContentSize().width,upgradeBg:getContentSize().height),1,1)
    clipper:setStencil(stencil) --遮罩
    upgradeBg:addChild(clipper)

    local totalI=math.ceil(upgradeBg:getContentSize().width/200)
    local totalJ=math.ceil(upgradeBg:getContentSize().height/200)
  	for j=1,totalJ do
  		for i=1,totalI do
  			local spBg=CCSprite:createWithSpriteFrameName("amMainBg.png")
  			spBg:setAnchorPoint(ccp(0,0))
  			spBg:setPosition((i-1)*200,(j-1)*199)
  			clipper:addChild(spBg)
  		end
  	end


	local bottomLineSp1=CCSprite:createWithSpriteFrameName("amBottomLine.png")
    bottomLineSp1:setPosition(ccp(upgradeBg:getContentSize().width/2,upgradeBg:getContentSize().height))
    upgradeBg:addChild(bottomLineSp1,1)

    local bottomLineSp2=CCSprite:createWithSpriteFrameName("amBottomLine.png")
    bottomLineSp2:setPosition(ccp(upgradeBg:getContentSize().width/2,0))
    upgradeBg:addChild(bottomLineSp2,1)

	local amChangeBg1=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg1:setScaleX(upgradeBg:getContentSize().width/amChangeBg1:getContentSize().width)
    amChangeBg1:setScaleY(upgradeBg:getContentSize().height/2/amChangeBg1:getContentSize().height)
    amChangeBg1:setAnchorPoint(ccp(0.5,1))
    amChangeBg1:setPosition(ccp(upgradeBg:getContentSize().width/2,upgradeBg:getContentSize().height))
    upgradeBg:addChild(amChangeBg1)

    local amChangeBg2=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg2:setRotation(180)
    amChangeBg2:setScaleX(upgradeBg:getContentSize().width/amChangeBg2:getContentSize().width)
    amChangeBg2:setScaleY(upgradeBg:getContentSize().height/2/amChangeBg2:getContentSize().height)
    amChangeBg2:setAnchorPoint(ccp(0.5,1))
    amChangeBg2:setPosition(ccp(upgradeBg:getContentSize().width/2,0))
    upgradeBg:addChild(amChangeBg2)

	local sbBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	upgradeBg:addChild(sbBg)
	sbBg:setContentSize(CCSizeMake(200,upgradeSize.height-20))
	sbBg:setPosition(110,upgradeSize.height/2-3)
	if (isLongSize) then
		sbBg:setContentSize(CCSizeMake(200,upgradeSize.height-80))
	end

	local subH=15
	if (isLongSize) then
		subH=50
	else
		subH=15
	end
	
	if G_getIphoneType() == G_iphoneX then
		subH = 80
	end
	if(buffEffectCfg[selectedAttKey].icon and buffEffectCfg[selectedAttKey].icon~="")then
		local attIcon=CCSprite:createWithSpriteFrameName(buffEffectCfg[selectedAttKey].icon)
		if(attIcon)then
			attIcon:setTag(105)
			attIcon:setScale(80/attIcon:getContentSize().width)
			attIcon:setAnchorPoint(ccp(0.5,0.5))
			if(isLongSize)then
				attIcon:setPosition(ccp(centerW,upgradeSize.height - 100-subH))
			else
				attIcon:setPosition(ccp(centerW,upgradeSize.height - 75-subH))
			end
			upgradeBg:addChild(attIcon)

			if self.isStrenth then
				-- local iconSize=attIcon:getContentSize()
			 --    local equipLine1 = CCParticleSystemQuad:create("public/hero/equipLine.plist")
			 --    equipLine1:setPosition(ccp(iconSize.width/2,10))
			 --    attIcon:addChild(equipLine1,3)
			 --    local function removeLine1( ... )
			 --        if equipLine1 then
			 --            equipLine1:stopAllActions()
			 --            equipLine1:removeFromParentAndCleanup(true)
			 --            equipLine1=nil
			 --            self.isPlaying=false
			 --            if callback then
			 --                callback()
			 --            end
			 --        end
			 --    end
			 --    local mvTo1=CCMoveTo:create(0.35,ccp(iconSize.width/2,100))
			 --    local fc1= CCCallFunc:create(removeLine1)
			 --    local carray1=CCArray:create()
			 --    carray1:addObject(mvTo1)
			 --    carray1:addObject(fc1)
			 --    local seq1 = CCSequence:create(carray1)
			 --    equipLine1:runAction(seq1)


			 --    local equipStar1 = CCParticleSystemQuad:create("public/hero/equipStar.plist")
			 --    equipStar1:setPosition(ccp(iconSize.width/2,10))
			 --    attIcon:addChild(equipStar1,3)
			 --    equipStar1:setAutoRemoveOnFinish(true) 

			 --    local function removeLine2( ... )
			 --        if equipStar1 then
			 --            equipStar1:stopAllActions()
			 --            equipStar1:removeFromParentAndCleanup(true)
			 --            equipStar1=nil
			            
			 --        end
			 --    end
			 --    local mvTo2=CCMoveTo:create(0.5,ccp(iconSize.width/2,100))
			 --    local fc2= CCCallFunc:create(removeLine2)
			 --    local carray2=CCArray:create()
			 --    carray2:addObject(mvTo2)
			 --    carray2:addObject(fc2)
			 --    local seq2 = CCSequence:create(carray2)
			 --    equipStar1:runAction(seq2)
			end
		end
	end
	local attNameLb=GetTTFLabelWrap(getlocal(buffEffectCfg[selectedAttKey].name),24,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	attNameLb:setTag(101)
	attNameLb:setAnchorPoint(ccp(0.5,1))

	local posWidth = 100
	if G_getCurChoseLanguage() =="ar" then
		posWidth =80
	end
	if(isLongSize)then
		attNameLb:setPosition(centerW,upgradeSize.height - 150-subH)
	else
		attNameLb:setPosition(ccp(centerW,upgradeSize.height - 120-subH))
	end
	
	upgradeBg:addChild(attNameLb)
	local value,limit,grow,addvalue
	if(selectedAttKey<200)then
		value=G_keepNumber(att[self.selectedAtt]*100,1)
		limit=G_keepNumber(attLimit[self.selectedAtt]*100,1)
		grow=G_keepNumber(data:getConfigData("upgradeGrow")[selectedAttKey]*100,1)
		if value>=limit then
			addvalue=value
		else
			addvalue=value+grow
		end
		value=value .. "%"
		limit=limit .. "%"
		grow=grow .. "%"
		addvalue=addvalue .. "%"
	else
		value=att[self.selectedAtt]
		limit=attLimit[self.selectedAtt]
		grow=data:getConfigData("upgradeGrow")[selectedAttKey]
		if value>=limit then
			addvalue=value
		else
			addvalue=value+grow
		end
	end

	local arrowH=attNameLb:getPositionY()-attNameLb:getContentSize().height-20
	local arrowSp=CCSprite:createWithSpriteFrameName("heroArrowRight.png")
	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	arrowSp:setScale(0.8)
	arrowSp:setPosition(centerW,arrowH)
	upgradeBg:addChild(arrowSp)

	local valueLb=GetTTFLabel(value,20)
	upgradeBg:addChild(valueLb)
	valueLb:setAnchorPoint(ccp(1,0.5))
	valueLb:setPosition(centerW-arrowSp:getContentSize().width/2*arrowSp:getScale()-10,arrowH)
	-- valueLb:setColor(G_ColorGreen)
	valueLb:setTag(151)

	local addValueLb=GetTTFLabel(addvalue,20)
	upgradeBg:addChild(addValueLb)
	addValueLb:setAnchorPoint(ccp(0,0.5))
	addValueLb:setPosition(centerW+arrowSp:getContentSize().width/2*arrowSp:getScale()+10,arrowH)
	addValueLb:setColor(G_ColorGreen)
	addValueLb:setTag(152)

	if self.isStrenth then
	    local function ScaleAction()
			local scaleTo1 = CCScaleTo:create(0.15,2)
		    local scaleTo2 = CCScaleTo:create(0.15,1)
		    local carray=CCArray:create()
		    carray:addObject(scaleTo1)
		    carray:addObject(scaleTo2)
		    local seq=CCSequence:create(carray)
		    return seq
		end
		valueLb:runAction(ScaleAction())
		addValueLb:runAction(ScaleAction())
		self.isStrenth=false
	end

	local limitH=arrowH-20
	-- super_weapon_streng_limit
	local strSize4 = 20
	if G_getCurChoseLanguage() =="de" then
		strSize4 = 17
	end
	local attLimitLb=GetTTFLabelWrap(getlocal("super_weapon_streng_limit"),strSize4,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	-- attLimitLb:setTag(103)
	attLimitLb:setAnchorPoint(ccp(0.5,1))
	attLimitLb:setPosition(ccp(centerW,limitH))
	upgradeBg:addChild(attLimitLb)

	limitH=limitH-attLimitLb:getContentSize().height
	local limitValueLb=GetTTFLabel(limit,20)
	limitValueLb:setAnchorPoint(ccp(0.5,1))
	upgradeBg:addChild(limitValueLb)
	limitValueLb:setPosition(centerW,limitH)
	limitValueLb:setColor(G_ColorYellowPro)
	limitValueLb:setTag(103)



	-- local attValueLb=GetTTFLabelWrap(getlocal("super_weapon_add_value",{value}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- attValueLb:setTag(102)
	-- attValueLb:setAnchorPoint(ccp(0,1))
	-- attValueLb:setPosition(ccp(10,upgradeSize.height - 160))
	-- upgradeBg:addChild(attValueLb)
	-- attValueLb:setVisible(false)

	-- local attGrowLb=GetTTFLabelWrap(getlocal("super_weapon_add_rebuild",{grow}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- attGrowLb:setTag(104)
	-- attGrowLb:setAnchorPoint(ccp(0,1))
	-- attGrowLb:setPosition(ccp(10,upgradeSize.height - 160 - attValueLb:getContentSize().height - 10 - attLimitLb:getContentSize().height - 10))
	-- upgradeBg:addChild(attGrowLb)
	-- attGrowLb:setVisible(false)
	-- local lineWhite=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- lineWhite:setColor(ccc3(0,199,131))
	-- lineWhite:setRotation(90)
	-- lineWhite:setScaleX((upgradeSize.height - 10)/lineWhite:getContentSize().width)
	-- lineWhite:setPosition(ccp(212,upgradeSize.height/2))
	-- upgradeBg:addChild(lineWhite)
	

	local function showExpert(object,fn,tag)
		local expertType=tag%100
		self:showExpert(expertType)
	end
	local adaptHeight = 100
	local adaptHeight1 = 190
	if G_getIphoneType() == G_iphoneX then
		adaptHeight = 130
		adaptHeight1 = 270
	end
	local expertIcon1=LuaCCSprite:createWithSpriteFrameName("WarBuffNetget.png",showExpert)
	expertIcon1:setTag(101)
	expertIcon1:setTouchPriority(-(self.layerNum-1)*20-2)
	expertIcon1:setScale(70/expertIcon1:getContentSize().width)
	expertIcon1:setPosition(ccp(280,upgradeSize.height - adaptHeight))
	upgradeBg:addChild(expertIcon1,1)
	local expertName1=GetTTFLabel(getlocal("super_weapon_expert1"),24,true)
	expertName1:setColor(G_ColorYellowPro)
	expertName1:setAnchorPoint(ccp(0,0.5))
	expertName1:setPosition(ccp(325,upgradeSize.height - adaptHeight + 22))
	upgradeBg:addChild(expertName1,1)
	local expertTimes1=GetTTFLabelWrap(getlocal("arena_numLeft",{superWeaponVoApi:getExpertList()["m1"] or 0}),20,CCSizeMake(195,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	expertTimes1:setAnchorPoint(ccp(0,0.5))
	expertTimes1:setPosition(ccp(325,upgradeSize.height - adaptHeight - 22))
	upgradeBg:addChild(expertTimes1,1)

	local times1Bg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	upgradeBg:addChild(times1Bg)
	times1Bg:setAnchorPoint(ccp(0,0.5))
	times1Bg:setContentSize(CCSizeMake(expertTimes1:getContentSize().width+10,math.min(expertTimes1:getContentSize().height+5,40)))
	times1Bg:setPosition(320,upgradeSize.height - adaptHeight - 10)
	times1Bg:setVisible(false)

	local expertAddBtn1=LuaCCSprite:createWithSpriteFrameName("sYellowAddBtn.png",showExpert)
	expertAddBtn1:setTag(201)
	expertAddBtn1:setTouchPriority(-(self.layerNum-1)*20-2)
	expertAddBtn1:setAnchorPoint(ccp(0,0.5))
	expertAddBtn1:setPosition(ccp(325 + expertTimes1:getContentSize().width,upgradeSize.height - adaptHeight))
	upgradeBg:addChild(expertAddBtn1)

	local expertIcon2=LuaCCSprite:createWithSpriteFrameName("WarBuffStatistician.png",showExpert)
	expertIcon2:setTag(102)
	expertIcon2:setTouchPriority(-(self.layerNum-1)*20-2)
	expertIcon2:setScale(70/expertIcon2:getContentSize().width)
	expertIcon2:setPosition(ccp(280,upgradeSize.height - adaptHeight1))
	upgradeBg:addChild(expertIcon2,1)
	local expertName2=GetTTFLabel(getlocal("super_weapon_expert2"),24,true)
	expertName2:setColor(G_ColorYellowPro)
	expertName2:setAnchorPoint(ccp(0,0.5))
	expertName2:setPosition(ccp(325,upgradeSize.height - adaptHeight1 + 22))
	upgradeBg:addChild(expertName2,1)
	local expertTimes2=GetTTFLabelWrap(getlocal("arena_numLeft",{superWeaponVoApi:getExpertList()["m2"] or 0}),20,CCSizeMake(195,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	expertTimes2:setAnchorPoint(ccp(0,0.5))
	expertTimes2:setPosition(ccp(325,upgradeSize.height - adaptHeight1 - 22))
	upgradeBg:addChild(expertTimes2,1)

	local times2Bg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	upgradeBg:addChild(times2Bg)
	times2Bg:setAnchorPoint(ccp(0,0.5))
	times2Bg:setContentSize(CCSizeMake(expertTimes1:getContentSize().width+10,math.min(expertTimes1:getContentSize().height+5,40)))
	times2Bg:setPosition(320,upgradeSize.height - adaptHeight1 - 10)
	times2Bg:setVisible(false)

	local expertAddBtn2=LuaCCSprite:createWithSpriteFrameName("sYellowAddBtn.png",showExpert)
	expertAddBtn2:setTag(202)
	expertAddBtn2:setTouchPriority(-(self.layerNum-1)*20-2)
	expertAddBtn2:setAnchorPoint(ccp(0,0.5))
	expertAddBtn2:setPosition(ccp(325 + expertTimes2:getContentSize().width,upgradeSize.height - adaptHeight1))
	upgradeBg:addChild(expertAddBtn2)

	local ownProps=GetTTFLabel(getlocal("ownedGem",{FormatNumber(superWeaponVoApi:getPropList()["p1"] or 0)}),20)
	ownProps:setTag(300)
	ownProps:setAnchorPoint(ccp(0.5,1))
	local adaptH = 25
	if G_getIphoneType() == G_iphoneX then
		adaptH = 55
	end
	ownProps:setPosition(ccp(380,math.min(expertIcon2:getPositionY() - 40,expertTimes2:getPositionY() - expertTimes1:getContentSize().height/2) -  adaptH))
	upgradeBg:addChild(ownProps)
	local propIcon=CCSprite:createWithSpriteFrameName("superWeaponP1_2.png")
	propIcon:setScale(0.4)
	propIcon:setAnchorPoint(ccp(0.5,1))
	propIcon:setPosition(ccp(410 + ownProps:getContentSize().width/2,ownProps:getPositionY() + 5))
	upgradeBg:addChild(propIcon)

	local rebuildCostIcon=CCSprite:createWithSpriteFrameName("superWeaponP1_2.png")
	rebuildCostIcon:setTag(302)
	rebuildCostIcon:setAnchorPoint(ccp(0,0.5))
	rebuildCostIcon:setScale(0.4)
	upgradeBg:addChild(rebuildCostIcon)
	local originCost=superWeaponCfg.growCost[(data.upgradeList[self.selectedAtt] or 0) + 1]
	originCostLb=GetTTFLabel(FormatNumber(originCost),20)
	originCostLb:setTag(303)
	originCostLb:setPosition(ccp(280,120))
	upgradeBg:addChild(originCostLb)
	local lineDelete=CCSprite:createWithSpriteFrameName("lineWhite.png")
	lineDelete:setTag(304)
	lineDelete:setScaleX((originCostLb:getContentSize().width + 10)/lineDelete:getContentSize().width)
	lineDelete:setPosition(ccp(280,120))
	upgradeBg:addChild(lineDelete)
	self.rebuildCost=originCost
	local rebuildCostLb
	if(superWeaponVoApi:getExpertList()["m1"] and superWeaponVoApi:getExpertList()["m1"]>0)then
		self.rebuildCost=math.ceil(self.rebuildCost*(1 - superWeaponCfg.masterRand[1]))
		rebuildCostLb=GetTTFLabel(FormatNumber(self.rebuildCost),25)
		rebuildCostLb:setAnchorPoint(ccp(0,0.5))
		rebuildCostLb:setPosition(ccp(280 + originCostLb:getContentSize().width/2 + 10,120))
		rebuildCostLb:setVisible(true)
		lineDelete:setVisible(true)
		rebuildCostIcon:setPosition(ccp(rebuildCostLb:getPositionX() + rebuildCostLb:getContentSize().width + 5,120))
	else
		rebuildCostLb=GetTTFLabel(FormatNumber(self.rebuildCost),25)
		rebuildCostLb:setVisible(false)
		lineDelete:setVisible(false)
		rebuildCostIcon:setPosition(ccp(280 + originCostLb:getContentSize().width/2 + 10,120))
	end	
	rebuildCostLb:setColor(G_ColorYellowPro)
	rebuildCostLb:setTag(301)
	upgradeBg:addChild(rebuildCostLb)
	local function onRebuild()
		if(att[self.selectedAtt]>=attLimit[self.selectedAtt])then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage121"),30)
			do return end
		end
		if(superWeaponVoApi:getPropList()["p1"]==nil or superWeaponVoApi:getPropList()["p1"]<self.rebuildCost)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9033"),30)
			do return end
		end
		local function callback(processTb)
			local critical=processTb[1]
			if(critical==nil)then
				critical=1
			end
			local str
			local valueAdd
			local selectedAttKey=data:getConfigData("att")[self.selectedAtt]
			if(selectedAttKey<200)then
				valueAdd=G_keepNumber(data:getConfigData("upgradeGrow")[selectedAttKey]*100*critical,1).."%%"
			else
				valueAdd=data:getConfigData("upgradeGrow")[selectedAttKey]*critical
			end
			if(critical==1)then
				str=getlocal("super_weapon_rebuildNoCritical",{getlocal(buffEffectCfg[selectedAttKey].name),valueAdd})
			else
				str=getlocal("super_weapon_rebuildCritical",{critical,getlocal(buffEffectCfg[selectedAttKey].name),valueAdd})
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
			-- self.attBtnTb[k]
		end
		superWeaponVoApi:rebuild(self.selectedID,self.selectedAtt,1,callback)
	end
	local rebuildItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onRebuild,2,getlocal("super_weapon_rebuild"),24/0.7,101)
	rebuildItem:setScale(0.7)
	local btnLb = rebuildItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local rebuildBtn=CCMenu:createWithItem(rebuildItem)
	rebuildBtn:setPosition(ccp(320,60))
	rebuildBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	upgradeBg:addChild(rebuildBtn)
	local function onRebuildAuto()
		if(att[self.selectedAtt]>=attLimit[self.selectedAtt])then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage121"),30)
			do return end
		end
		if(superWeaponVoApi:getPropList()["p1"]==nil or superWeaponVoApi:getPropList()["p1"]<self.rebuildCost)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9033"),30)
			do return end
		end
		local function callback(processTb)
			self:showAutoUpgradeDialog(processTb)
		end
		superWeaponVoApi:rebuild(self.selectedID,self.selectedAtt,2,callback)
	end
	local rebuildAutoItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onRebuildAuto,2,getlocal("super_weapon_rebuildAuto"),24/0.7,101)
	rebuildAutoItem:setScale(0.7)
	local btnLb = rebuildAutoItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local rebuildAutoBtn=CCMenu:createWithItem(rebuildAutoItem)
	rebuildAutoBtn:setPosition(ccp(495,60))
	rebuildAutoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	upgradeBg:addChild(rebuildAutoBtn)

	--如果是iPhone4的尺寸就缩一下
	if(isLongSize==false)then
		-- attValueLb:setPositionY(upgradeSize.height - 110)
		-- attLimitLb:setPositionY(upgradeSize.height - 110 - attValueLb:getContentSize().height - 5)
		-- attGrowLb:setPositionY(upgradeSize.height - 110 - attValueLb:getContentSize().height - 5 - attLimitLb:getContentSize().height)
		expertIcon1:setPositionY(upgradeSize.height - 55)
		expertIcon2:setPositionY(upgradeSize.height - 135)
		expertName1:setPositionY(upgradeSize.height - 40+5)
		expertName2:setPositionY(upgradeSize.height - 130+14)
		expertTimes1:setPositionY(upgradeSize.height - 40 - 35)
		times1Bg:setPositionY(upgradeSize.height - 40 - 35)
		expertTimes2:setPositionY(upgradeSize.height - 130 - 25)
		times2Bg:setPositionY(upgradeSize.height - 130 - 25)
		rebuildCostIcon:setPositionY(90)
		originCostLb:setPositionY(90)
		lineDelete:setPositionY(90)
		rebuildCostLb:setPositionY(90)
		expertAddBtn1:setPositionY(upgradeSize.height - 40 - 10)
		expertAddBtn2:setPositionY(upgradeSize.height - 130 - 10)
		ownProps:setPositionY(math.min(expertIcon2:getPositionY() - 40,expertTimes2:getPositionY() - expertTimes1:getContentSize().height/2))
		propIcon:setPositionY(ownProps:getPositionY() + 5)
		rebuildBtn:setPositionY(40)
		rebuildAutoBtn:setPositionY(40)
	end
end

function superWeaponInfoDialogTabUpgrade:distance(pos1,pos2)
	return math.sqrt((pos2.x - pos1.x)*(pos2.x - pos1.x) + (pos2.y - pos1.y)*(pos2.y - pos1.y))
end

function superWeaponInfoDialogTabUpgrade:showExpert(type)
	if(self.expertLayer)then
		self.expertLayer:removeFromParentAndCleanup(true)
		self.expertLayer=nil
	end
	local layerNum=self.layerNum + 1
	self.expertLayer=CCLayer:create()
	self.bgLayer:addChild(self.expertLayer,3)
	local function onHide()
		if(self and self.expertLayer)then
			self.expertLayer:removeFromParentAndCleanup(true)
			self.expertLayer=nil
		end
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.expertLayer:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	dialogBg:setContentSize(CCSizeMake(570,400))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.expertLayer:addChild(dialogBg,1)
	local titleLb=GetTTFLabel(getlocal("super_weapon_expert"..type),28)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(285,350))
	dialogBg:addChild(titleLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(285,320))
	dialogBg:addChild(lineSp)
	local descLb=GetTTFLabelWrap(getlocal("super_weapon_expertDesc"..type),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(285,220)
	dialogBg:addChild(descLb)
	local expertTb={}
	local function sortFunc(a,b)
		return a[1]<b[1]
	end
	for time,cost in pairs(superWeaponCfg.master[type]) do
		table.insert(expertTb,{time,cost})
	end
	table.sort(expertTb,sortFunc)
	local priceLb1=GetTTFLabel(expertTb[1][2],25)
	priceLb1:setPosition(ccp(180,120))
	dialogBg:addChild(priceLb1)
	local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	gemIcon:setPosition(ccp(220,120))
	dialogBg:addChild(gemIcon)
	local function onBuy1()
		if(playerVoApi:getGems()<expertTb[1][2])then
			GemsNotEnoughDialog(nil,nil,expertTb[1][2]-playerVoApi:getGems(),layerNum+1,expertTb[1][2])
			do return end
		end
		local function callback()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
			playerVoApi:setGems(playerVoApi:getGems() - expertTb[1][2])
			onHide()
		end
		local function confirmBuy()
			self.pinFlag=false
			superWeaponVoApi:buyExpert(type,expertTb[1][1],callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmBuy,getlocal("dialog_title_prompt"),getlocal("super_weapon_expertConfirm",{expertTb[1][2],expertTb[1][1],getlocal("super_weapon_expert"..type)}),nil,layerNum+1)
	end
	local buyItem1=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onBuy1,2,getlocal("super_weapon_expertBuy",{expertTb[1][1]}),24/0.7,101)
	buyItem1:setScale(0.7)
	local btnLb = buyItem1:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local buyBtn1=CCMenu:createWithItem(buyItem1)
	buyBtn1:setPosition(ccp(200,60))
	buyBtn1:setTouchPriority(-(layerNum-1)*20-2)
	dialogBg:addChild(buyBtn1)
	local priceLb2=GetTTFLabel(expertTb[2][2],25)
	priceLb2:setPosition(ccp(350,120))
	dialogBg:addChild(priceLb2)
	local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	gemIcon:setPosition(ccp(390,120))
	dialogBg:addChild(gemIcon)
	local function onBuy2()
		if(playerVoApi:getGems()<expertTb[2][2])then
			GemsNotEnoughDialog(nil,nil,expertTb[2][2]-playerVoApi:getGems(),layerNum+1,expertTb[2][2])
			do return end
		end
		local function callback()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
			playerVoApi:setGems(playerVoApi:getGems() - expertTb[2][2])
			onHide()
		end
		local function confirmBuy()
			self.pinFlag=false
			superWeaponVoApi:buyExpert(type,expertTb[2][1],callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmBuy,getlocal("dialog_title_prompt"),getlocal("super_weapon_expertConfirm",{expertTb[2][2],expertTb[2][1],getlocal("super_weapon_expert"..type)}),nil,layerNum+1)
	end
	local buyItem2=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onBuy2,2,getlocal("super_weapon_expertBuy",{expertTb[2][1]}),24/0.7,101)
	buyItem2:setScale(0.7)
	local btnLb = buyItem2:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local buyBtn2=CCMenu:createWithItem(buyItem2)
	buyBtn2:setPosition(ccp(370,60))
	buyBtn2:setTouchPriority(-(layerNum-1)*20-2)
	dialogBg:addChild(buyBtn2)
end

function superWeaponInfoDialogTabUpgrade:showAutoUpgradeDialog(processTb)
	local factContentHeight = SizeOfTable(processTb) * 40
	local data=superWeaponVoApi:getWeaponByID(self.selectedID)
	local selectedAttKey=data:getConfigData("att")[self.selectedAtt]
	if(self.autoLayer)then
		if(self.playingAuto)then
			self.autoLayer:stopAllActions()
		end
		self.autoLayer:removeFromParentAndCleanup(true)
	end
	local layerNum=self.layerNum + 1
	self.autoLayer=CCLayer:create()
	self.bgLayer:addChild(self.autoLayer,4)
	self.playingAuto=false
	local function nilFunc()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.autoLayer:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	dialogBg:setContentSize(CCSizeMake(570,600))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.autoLayer:addChild(dialogBg,1)
	local autoCell
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return 1
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(570, factContentHeight)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			autoCell=cell
			return cell
		elseif fn=="ccTouchBegan" then
			self.isMoved=false
			return true
		elseif fn=="ccTouchMoved" then
			self.isMoved=true
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(570,440),nil)
	tv:setAnchorPoint(ccp(0,0))
	tv:setPosition(ccp(0,120))
	tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv:setMaxDisToBottomOrTop(30)
	dialogBg:addChild(tv)
	local function onClose()
		if(self.playingAuto and self.autoLayer)then
			self.autoLayer:stopAllActions()
		end
		if(self.autoLayer)then
			self.autoLayer:removeFromParentAndCleanup(true)
			self.autoLayer=nil
		end
	end
	local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClose,nil,getlocal("confirm"),24/0.8,101)
	okItem:setScale(0.8)
	local btnLb = okItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(layerNum-1)*20-4)
	okBtn:setPosition(ccp(570/2,60))
	dialogBg:addChild(okBtn)
	self.playingAuto=true
	local function onEnd()
		self.playingAuto=false
	end
	local acArr=CCArray:create()
	local callFunc=CCCallFunc:create(onEnd)
	for k,v in pairs(processTb) do
		local function onDelay()
			local critical=processTb[k]
			if(critical==nil)then
				critical=1
			end
			local str
			local valueAdd
			if(selectedAttKey<200)then
				valueAdd=G_keepNumber(data:getConfigData("upgradeGrow")[selectedAttKey]*100*critical,1).."%%"
			else
				valueAdd=data:getConfigData("upgradeGrow")[selectedAttKey]*critical
			end
			if(critical==1)then
				str=getlocal("super_weapon_rebuildNoCritical",{getlocal(buffEffectCfg[selectedAttKey].name),valueAdd})
			else
				str=getlocal("super_weapon_rebuildCritical",{critical,getlocal(buffEffectCfg[selectedAttKey].name),valueAdd})
			end
			local posWidth = 30
			local strSize2 = 25
			if G_getCurChoseLanguage() =="ar" then
				posWidth =10
				strSize2 =20
			end
			local lb=GetTTFLabel(str,strSize2)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(ccp(posWidth,factContentHeight - 40 * (k - 1)))
			autoCell:addChild(lb)

			if tv:getRecordPoint().y < 0 and 40 * k > 440 then
				tv:recoverToRecordPoint(ccp(0, tv:getRecordPoint().y + 40))
			end
		end
		local delayFunc=CCCallFunc:create(onDelay)
		local delay=CCDelayTime:create(0.5)
		acArr:addObject(delay)
		acArr:addObject(delayFunc)
	end
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
    self.autoLayer:runAction(seq)
end

function superWeaponInfoDialogTabUpgrade:refresh()
	self:initList()
end

function superWeaponInfoDialogTabUpgrade:dispose()
	eventDispatcher:removeEventListener("superweapon.data.info",self.eventListener)
	if(self.autoLayer)then
		self.autoLayer:stopAllActions()
	end
	self.playingAuto=false
	self.selectedID=nil
	self.selectedAtt=nil
	self.expertLayer=nil
	spriteController:removePlist("public/armorMatrix.plist")
    spriteController:removeTexture("public/armorMatrix.png")
    spriteController:removePlist("public/swYouhuaUI.plist")
    spriteController:removeTexture("public/swYouhuaUI.png")
end