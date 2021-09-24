--超级武器详细信息的小面板
superWeaponDetailSmallDialog=smallDialog:new()

function superWeaponDetailSmallDialog:new(weaponID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.weaponID=weaponID
	nc.dialogWidth=550
	nc.dialogHeight=835
	local data=superWeaponVoApi:getWeaponByID(weaponID)
	local attTb=data:getAtt()
	if(SizeOfTable(attTb)>6)then
		nc.dialogHeight=885
	end
	return nc
end

function superWeaponDetailSmallDialog:init(layerNum)
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")

    local function addPlist()
    	spriteController:addPlist("public/swYouhuaUI.plist")
	    spriteController:addTexture("public/swYouhuaUI.png")
    end
    G_addResource8888(addPlist)
    
    
	self.isTouch=nil
	self.layerNum=layerNum
	self.data=superWeaponVoApi:getWeaponByID(self.weaponID)
	self.unlockSlots=superWeaponVoApi:getUnlockSlot()
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function superWeaponDetailSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleStr=getlocal("playerInfo")
	local titleLb=GetTTFLabel(titleStr,32,true)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-10))
	dialogBg:addChild(titleLb,1)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)

  	local function onShare()
	    if G_checkClickEnable()==false then
	        do
	            return
	        end
	    end
	    PlayEffect(audioCfg.mouseClick)
	    local share=self:getShareData()
	    if share then
	     	local message=getlocal("mything",{getlocal("super_weapon_title_1")})..":".."【"..getlocal(self.data:getConfigData("name")).."】"
		    local tipStr=getlocal("send_share_sucess",{getlocal("super_weapon_title_1")})
	      	G_shareHandler(share,message,tipStr,self.layerNum+1)
	    end
  	end
	local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
	local shareBtn=CCMenu:createWithItem(shareItem)
	shareBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	shareBtn:setPosition(self.bgSize.width-80,self.bgSize.height-165)
	self.bgLayer:addChild(shareBtn)
end

function superWeaponDetailSmallDialog:initContent()

	local namePosX=200

	local weaponIcon=CCSprite:createWithSpriteFrameName(self.data:getConfigData("bigIcon"))
	weaponIcon:setAnchorPoint(ccp(0.5,0.5))
	weaponIcon:setScale(130/weaponIcon:getContentSize().width)
	weaponIcon:setPosition(ccp(namePosX/2,self.dialogHeight - 165))
	self.bgLayer:addChild(weaponIcon,1)

	local bottomBg=CCSprite:createWithSpriteFrameName("swTechLightBg.png")
	self.bgLayer:addChild(bottomBg)
	bottomBg:setPosition(ccp(namePosX/2,self.dialogHeight - 175))
	bottomBg:setScale(0.8)

	local upBg=CCSprite:createWithSpriteFrameName("swTechLight.png")
	self.bgLayer:addChild(upBg,3)
	upBg:setPosition(ccp(namePosX/2,self.dialogHeight - 175))
	upBg:setScale(0.8)
	upBg:setOpacity(180)

	local nameLbSize2 = 24
	local nameLbHeightNeed = 125
	local skillNameSize = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        nameLbHeightNeed = 125
        skillNameSize = 20
    end
	local nameLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name")),nameLbSize2,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(ccp(namePosX,self.dialogHeight - nameLbHeightNeed))
	self.bgLayer:addChild(nameLb)
	nameLb:setColor(superWeaponVoApi:getWeaponColorByQuality(self.data.id))


	local lvLb=GetTTFLabel(getlocal("fightLevel",{self.data.lv}),24,true)
	lvLb:setAnchorPoint(ccp(0,1))
	lvLb:setPosition(ccp(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height/2-15))
	self.bgLayer:addChild(lvLb)

	local expLb=GetTTFLabel(getlocal("super_weapon_exp"),25)
	expLb:setAnchorPoint(ccp(0,1))
	expLb:setPosition(ccp(nameLb:getPositionX(),lvLb:getPositionY()-lvLb:getContentSize().height))
	self.bgLayer:addChild(expLb)
	expLb:setVisible(false)
	local progressBg=CCSprite:createWithSpriteFrameName("TimeBg.png")
	progressBg:setScaleX((self.dialogWidth - 246)/progressBg:getContentSize().width)
	progressBg:setScaleY(0.9)
	progressBg:setAnchorPoint(ccp(0,0.5))
	progressBg:setPosition(ccp(namePosX,expLb:getPositionY()-expLb:getContentSize().height))
	self.bgLayer:addChild(progressBg)
	local expProgress=CCProgressTimer:create(CCSprite:createWithSpriteFrameName("AllXpBar.png"))
	expProgress:setScaleX((self.dialogWidth - 250)/expProgress:getContentSize().width)
	expProgress:setScaleY(0.9)
	expProgress:setType(kCCProgressTimerTypeBar)
	expProgress:setMidpoint(ccp(0,0))
	expProgress:setBarChangeRate(ccp(1,0))
	expProgress:setAnchorPoint(ccp(0,0.5))
	expProgress:setPosition(ccp(namePosX+2,progressBg:getPositionY()))
	local progressLb
	if(self.data.lv>=superWeaponCfg.maxLv)then
		expProgress:setPercentage(0)
		progressLb=GetTTFLabel(getlocal("alliance_lvmax"),20)
	else
		local expMax=superWeaponCfg.expCfg[self.data.lv]
		local expLast=superWeaponCfg.expCfg[self.data.lv - 1] or 0
		local expTotalNeed=expMax - expLast
		local expCurrent=self.data.exp - expLast
		expProgress:setPercentage(expCurrent/expTotalNeed*100)
		progressLb=GetTTFLabel(expCurrent.."/"..expTotalNeed,20)
	end
	progressLb:setPosition(ccp(namePosX + (self.dialogWidth - 220)/2,progressBg:getPositionY()))
	self.bgLayer:addChild(expProgress)
	self.bgLayer:addChild(progressLb)
	local function nilFunc( ... )
	end
	local size=self.dialogHeight - 270
	local attBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),nilFunc)
	attBg:setContentSize(CCSizeMake(self.dialogWidth - 30,size))
	attBg:setAnchorPoint(ccp(0,0))
	attBg:setPosition(ccp(15,15))
	self.bgLayer:addChild(attBg)
 
 	self.tvWidth,self.tvHeight=attBg:getContentSize().width,size-20
 	self.contentTvHeight = self:getContentTvHeight()
 	if self.tvHeight>self.contentTvHeight then
 		self.tvHeight=self.contentTvHeight
 	end

	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
 	local infoTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    infoTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    infoTv:setPosition(ccp((self.dialogWidth-self.tvWidth)/2,attBg:getPositionY()+size-self.tvHeight-10))
    if self.contentTvHeight>self.tvHeight then
	    infoTv:setMaxDisToBottomOrTop(120)
   	else
	    infoTv:setMaxDisToBottomOrTop(0)
    end
    self.bgLayer:addChild(infoTv,2)
end

function superWeaponDetailSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.tvWidth,self:getContentTvHeight())
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
 	
 		local cellHeight=self:getContentTvHeight()
 	 	local tabPosX,tabFontPosX,tabFontSize = 10,10,24
 		local skillBg=CCSprite:createWithSpriteFrameName("building_guild_namebg.png")
		skillBg:setAnchorPoint(ccp(0,1))
		skillBg:setPosition(tabPosX,cellHeight)
		cell:addChild(skillBg)

		local skillTitleLb=GetTTFLabel(getlocal("super_weapon_skill"),tabFontSize,true)
		skillTitleLb:setAnchorPoint(ccp(0,0.5))
		skillTitleLb:setPosition(ccp(tabFontPosX,skillBg:getContentSize().height/2))
		skillBg:addChild(skillTitleLb,1)

		local lbPosX = 10
		local posY = cellHeight-40-10
		local nameLb,descLb,powerUpDescLb = self:getSuperWeaponSkillContent()
		nameLb:setPosition(lbPosX,posY)
		cell:addChild(nameLb)

		descLb:setPosition(lbPosX,nameLb:getPositionY()-nameLb:getContentSize().height)
		cell:addChild(descLb)

		powerUpDescLb:setPosition(lbPosX,descLb:getPositionY()-descLb:getContentSize().height)
		cell:addChild(powerUpDescLb)

		posY=posY-nameLb:getContentSize().height-descLb:getContentSize().height-powerUpDescLb:getContentSize().height-10

		local attTabSp=CCSprite:createWithSpriteFrameName("building_guild_namebg.png")
		attTabSp:setAnchorPoint(ccp(0,1))
		attTabSp:setPosition(tabPosX,posY)
		cell:addChild(attTabSp)

		local attTabLb=GetTTFLabel(getlocal("attribute_add"),tabFontSize,true)
		attTabLb:setAnchorPoint(ccp(0,0.5))
		attTabLb:setPosition(ccp(tabFontPosX,attTabSp:getContentSize().height/2))
		attTabSp:addChild(attTabLb,1)

		posY=posY-40-10
		local index = 1
		local attTb=self.data:getAtt()
		for k,v in pairs(self.attMap) do
			local iconY
			local iconX
			if(index<4)then
				iconY=posY - 30
				iconX=lbPosX + (index - 1)*170
			elseif(index<7)then
				iconY=posY - 105
				iconX=lbPosX + (index - 4)*170
			elseif(index < 10)then
				iconY=posY - 180
				iconX=lbPosX + (index - 7)*170
			else
				iconY=posY - 255
				iconX=lbPosX + (index - 10)*170
			end
			local attKey=v
			if(buffEffectCfg[attKey].icon and buffEffectCfg[attKey].icon~="")then
				local icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[attKey].icon)
				if(icon)then
					icon:setScale(60/icon:getContentSize().width)
					icon:setAnchorPoint(ccp(0,0.5))
					icon:setPosition(ccp(iconX,iconY))
					cell:addChild(icon)
				end
			end
			local nameLbSize = 20
			local needWidtPos = 60
		    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		        nameLbSize =20
		        needWidtPos =67
		    elseif G_getCurChoseLanguage() =="de" then
		    	nameLbSize = 15
		    end
			local nameLb=GetTTFLabelWrap(getlocal(buffEffectCfg[attKey].name),nameLbSize,CCSizeMake(105,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			nameLb:setAnchorPoint(ccp(0,0.5))
			nameLb:setPosition(ccp(iconX + needWidtPos,iconY + 20))
			cell:addChild(nameLb)
			local value
			local bufNumNeed = self.bufNumTb[attKey] or 0
			if(attKey<200)then
				local bufNum = attTb[attKey] or 0
				value=G_keepNumber( (bufNum + bufNumNeed )*100,1).."%"
			else
				value=attTb[attKey]
			end
			local valueLb=GetTTFLabel(value,20)
			valueLb:setAnchorPoint(ccp(0,0.5))
			valueLb:setPosition(ccp(iconX + needWidtPos,iconY - 20))
			cell:addChild(valueLb)
			index=index + 1
		end
		local srow = math.ceil(SizeOfTable(self.attMap)/3)
		posY=posY - srow*60-(srow-1)*15 - 10
	
		if(SizeOfTable(self.data.slots)>0)then
			local tabSp=CCSprite:createWithSpriteFrameName("building_guild_namebg.png")
			tabSp:setAnchorPoint(ccp(0,1))
			tabSp:setPosition(tabPosX,posY)
			cell:addChild(tabSp)

			local tabLb=GetTTFLabel(getlocal("super_weapon_title_4"),tabFontSize)
			tabLb:setAnchorPoint(ccp(0,0.5))
			tabLb:setPosition(ccp(tabFontPosX,tabSp:getContentSize().height/2))
			tabSp:addChild(tabLb,1)

			posY = posY - tabSp:getContentSize().height - 10
			local index=1
			for k,v in pairs(self.data.slots) do
				local crystalVo=superWeaponVoApi:getCrystalVoByCid(v)
				local function clickIconHandler( ... )
	                smallDialog:showCrystalInfoDilaog(crystalVo:getNameAndLevel(),crystalVo:getIconSp(touchLuaSpr),crystalVo:getAtt(),self.layerNum+1,-1,nil,crystalVo:getLevel())
	            end
				sp=crystalVo:getIconSp(clickIconHandler)
				sp:setScale(80/sp:getContentSize().height)
				sp:setAnchorPoint(ccp(0,1))
				sp:setPosition(ccp(lbPosX+(index - 1)*90,posY))
				sp:setTouchPriority(-(self.layerNum-1)*20-3)
				cell:addChild(sp)
				local lvLb=GetTTFLabel(getlocal("fightLevel",{crystalVo:getLevel()}),25)
				lvLb:setAnchorPoint(ccp(1,0))
				lvLb:setPosition(ccp(sp:getContentSize().width - 5,5))
				sp:addChild(lvLb)

				index=index + 1
			end
		end

        return cell
    elseif fn=="ccTouchBegan" then
        isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function superWeaponDetailSmallDialog:getContentTvHeight()
	if self.contentTvHeight==nil then
		local height = (40+10)*2
		local nameLb,descLb,powerUpDescLb=self:getSuperWeaponSkillContent()
		height=height+nameLb:getContentSize().height+descLb:getContentSize().height+powerUpDescLb:getContentSize().height+10

		local attMap=self:getAttMap()

		local srow = math.ceil(SizeOfTable(attMap)/3)
		height=height+srow*60+(srow-1)*15+10
	
		if(SizeOfTable(self.data.slots)>0)then
			height=height+40+80+10
		end
		self.contentTvHeight = height
	end
	return self.contentTvHeight
end

function superWeaponDetailSmallDialog:getSuperWeaponSkillContent()
	local result,ifHasSuitEffect,ifHasSkillEffect,bufNumTb=superWeaponVoApi:getSuitList(self.weaponID)
	self.bufNumTb=bufNumTb
	local fontSize = 20
    local lvParamStr = ""
    if ifHasSkillEffect==true then
    	lvParamStr="(+1)"
    end

	local skillLv=superWeaponCfg.skillLvl[self.data.lv]
	local skillName=GetTTFLabel(getlocal(abilityCfg[self.data:getConfigData("skillID")][skillLv].name).." "..getlocal("fightLevel",{skillLv})..lvParamStr,fontSize)
	skillName:setColor(G_ColorYellowPro)
	skillName:setAnchorPoint(ccp(0,1))

	local cfg=abilityCfg[self.data:getConfigData("skillID")][skillLv]
	if ifHasSkillEffect==true then
		cfg=abilityCfg[self.data:getConfigData("skillID")][skillLv+1]
	end
	local v1=cfg.value1
	local v2=cfg.value2
	local v3=cfg.SpTop
	if(v1 and v1<1)then
		-- v1=G_keepNumber(v1*100,0).."%%"
		v1=(v1*100).."%%"
	end
	if(v2 and v2<1)then
		-- v2=G_keepNumber(v2*100,0).."%%"
		v2=(v2*100).."%%"
	end
	local skillStr=getlocal(cfg.desc,{v1,v2,v3})
	local skillDesc=GetTTFLabelWrap(skillStr,fontSize,CCSizeMake(self.tvWidth - 55,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	skillDesc:setAnchorPoint(ccp(0,1))

	local skillPowerUpDesc=GetTTFLabelWrap(getlocal("super_weapon_powerUpDesc"),fontSize,CCSizeMake(self.tvWidth - 55,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	skillPowerUpDesc:setAnchorPoint(ccp(0,1))

	return skillName,skillDesc,skillPowerUpDesc
end

function superWeaponDetailSmallDialog:getAttMap()
	local attMap={}
	local attTb=self.data:getAtt()
	for attKey,v in pairs(attTb) do
		if attKey~="first"or attKey~="antifirst" then
			table.insert(attMap,attKey)
		end
	end
	
	for k,v in pairs(self.bufNumTb) do
		local isHas = false
		for m,n in pairs(attMap) do
			if n == k then
				isHas = true
			end
		end
		if isHas == false and k~="first"and k~="antifirst" then
			table.insert(attMap,k)
		end
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
	self.attMap=attMap
	return self.attMap
end

function superWeaponDetailSmallDialog:getShareData()
	if self.data and self.attMap then
		local share={}
		share.stype=3 --超级武器分享类型
		share.name=playerVoApi:getPlayerName()
		share.id=self.weaponID --超级武器id
		share.lv=self.data.lv --超级武器等级
		local result,ifHasSuitEffect,ifHasSkillEffect,bufNumTb=superWeaponVoApi:getSuitList(self.weaponID)
	    local ef=0
	    if ifHasSkillEffect==true then
	    	ef=1
	    end
		share.s={superWeaponCfg.skillLvl[self.data.lv],ef} --技能
		local property={}
		local attTb=self.data:getAtt()
		for k,v in pairs(self.attMap) do
			property[k]={}
			property[k][1]=v
			local value=0
			local bufNumNeed = bufNumTb[v] or 0
			if(v<200)then
				local bufNum = attTb[v] or 0
				value=G_keepNumber( (bufNum + bufNumNeed) *100,1).."%"
			else
				value=attTb[v]
			end
			property[k][2]=value
		end
		local slots={}
		if(SizeOfTable(self.data.slots)>0)then
			local idx=1
			for k,v in pairs(self.data.slots) do
				local crystalVo=superWeaponVoApi:getCrystalVoByCid(v)
				local colorType=crystalVo:getColorType()
				local level=crystalVo:getLevel()
				local slot={v,colorType,level}
				slots[idx]=slot
				idx=idx+1
			end
		end
		share.p=property --属性加成
		share.slots=slots --能量结晶

	    return share
	end
	return nil
end

function superWeaponDetailSmallDialog:dispose()
	self.attMap=nil
	self.data=nil
	spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/swYouhuaUI.plist")
    spriteController:removeTexture("public/swYouhuaUI.png")
end