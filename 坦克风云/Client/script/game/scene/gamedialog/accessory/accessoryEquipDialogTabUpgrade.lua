--配件强化的tab
accessoryEquipDialogTabUpgrade={}

function accessoryEquipDialogTabUpgrade:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	nc.lastNumValue=0
	nc.costPropNum=0
	return nc
end

function accessoryEquipDialogTabUpgrade:init(layerNum)
	local strSize2 = 22
	local strSize3 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =22
    end
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local bg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	bg:setScale((G_VisibleSizeWidth - 42)/bg:getContentSize().width)
	bg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(bg)

	local iconBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	iconBg:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(iconBg)

	local function nilFun()
	end
	local icon=accessoryVoApi:getAccessoryIcon(self.data.type,70,100)
	icon:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(icon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	self.rankLb=GetTTFLabel(self.data.rank,30)
	self.rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(self.rankLb)
	rankTip:setScale(0.5)
	rankTip:setAnchorPoint(ccp(0,1))
	rankTip:setPosition(ccp(0,100))
	icon:addChild(rankTip)
	self.lvLb1=GetTTFLabel(getlocal("fightLevel",{self.data.lv}),20)
	self.lvLb1:setAnchorPoint(ccp(1,0))
	self.lvLb1:setPosition(ccp(85,5))
	icon:addChild(self.lvLb1)
	if(self.data.bind==1 and self.data:getConfigData("quality")>3 and base.accessoryTech==1)then
		local techTip=CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
		self.techLb=GetTTFLabel(self.data.techLv or 0,30)
		self.techLb:setPosition(getCenterPoint(techTip))
		techTip:addChild(self.techLb)
		techTip:setScale(0.5)
		techTip:setAnchorPoint(ccp(1,1))
		techTip:setPosition(ccp(98,100))
		icon:addChild(techTip)
	end
	--红配晋升开关开启 && 红色配件 && 已经绑定
	if base.redAccessoryPromote == 1 and self.data:getConfigData("quality") == 5 and self.data.bind == 1 then
		local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
		local promoteLvLb = GetTTFLabel(self.data.promoteLv or 0, 30)
		promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
		promoteLvBg:addChild(promoteLvLb)
		promoteLvBg:setScale(0.5)
		promoteLvBg:setAnchorPoint(ccp(0, 0))
		promoteLvBg:setPosition(ccp(0, 0))
		icon:addChild(promoteLvBg)
	end

	local nameLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name")),25,CCSizeMake(icon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX,posY - icon:getContentSize().height/2 - 10)
	self.bgLayer:addChild(nameLb)

	local titleLb=GetTTFLabel(getlocal("accessory_attChange"),24,true)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),nilFun)
	titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width + 120,titleLb:getContentSize().height + 16))
	titleBg:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190+5)
	self.bgLayer:addChild(titleBg)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190+5)
	self.bgLayer:addChild(titleLb)

	local attTb=self.data:getAttWithSuccinct()
	local differenceTb=self.data:getConfigData("lvGrow")
	local attTypeTb=self.data:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect
	
	posX,posY=235,G_VisibleSizeHeight - 250 + 15

	local lvlbStr = GetTTFLabel(getlocal("accessory_lv",{""}),strSize2)
	lvlbStr:setAnchorPoint(ccp(0,0))
	lvlbStr:setPosition(posX,posY)
	self.bgLayer:addChild(lvlbStr)

	self.lvLb=GetTTFLabel(self.data.lv,strSize2)
	self.lvLb:setAnchorPoint(ccp(0,0))
	self.lvLb:setPosition(posX+lvlbStr:getContentSize().width,posY)
	self.bgLayer:addChild(self.lvLb)

    self.upLb1=GetTTFLabel("    ↑ +1",strSize2)
	self.upLb1:setAnchorPoint(ccp(0,0))
	self.upLb1:setColor(G_ColorGreen)
	self.upLb1:setPosition(self.lvLb:getPositionX()+self.lvLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb1)
	local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
	local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[1] then
        roleMaxLevel = roleMaxLevel + upperLimitTb[1]
    end
	if(self.data.lv>=roleMaxLevel)then
		self.upLb1:setString(" "..getlocal("donatePointMax"))
		self.upLb1:setColor(G_ColorYellowPro)
	end
	self.attLbTb={}
	self.attUpLbTb={}

	for k,v in pairs(attTypeTb) do
		posY=posY-35
		local effectStr
		local diffrenceStr
		if(attEffectTb[v]==1)then
			effectStr=string.format("%.2f",attTb[v]).."%"
			diffrenceStr=differenceTb[k].."%"
		else
			effectStr=attTb[v]
			diffrenceStr=differenceTb[k]
		end
		local attLb=GetTTFLabel(getlocal("accessory_attAdd_"..v,{""}),strSize2)
		attLb:setAnchorPoint(ccp(0,0))
		attLb:setPosition(posX,posY)
		self.bgLayer:addChild(attLb)

		local attNumLb = GetTTFLabel(effectStr,strSize2)
		attNumLb:setAnchorPoint(ccp(0,0))
		attNumLb:setPosition(attLb:getPositionX()+attLb:getContentSize().width,posY)
		self.bgLayer:addChild(attNumLb)

		self.attLbTb[k]=attNumLb

        local upLbTmp=GetTTFLabel("    ↑ +"..diffrenceStr,strSize2)
		upLbTmp:setColor(G_ColorGreen)
		upLbTmp:setAnchorPoint(ccp(0,0))
		upLbTmp:setPosition(attNumLb:getPositionX()+attNumLb:getContentSize().width,posY)
		self.bgLayer:addChild(upLbTmp)
		self.attUpLbTb[k]=upLbTmp
		if(self.data.lv>=roleMaxLevel)then
			upLbTmp:setVisible(false)
		end
	end

	posY=posY-35
	local oldGs=self.data:getGS()

	local gsStrLb = GetTTFLabel(getlocal("accessory_gsAdd",{""}),strSize2)
	gsStrLb:setAnchorPoint(ccp(0,0))
	gsStrLb:setPosition(posX,posY)
	self.bgLayer:addChild(gsStrLb)

	self.gsLb=GetTTFLabel(oldGs,strSize2)
	self.gsLb:setAnchorPoint(ccp(0,0))
	self.gsLb:setPosition(gsStrLb:getPositionX()+gsStrLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.gsLb)

	if(self.data.lv>=roleMaxLevel)then
		self.gsUpLb=GetTTFLabel("",strSize2)
		self.gsUpLb:setColor(G_ColorYellowPro)
	else
		local newGs=self.data:getGS(self.data.lv + 1,self.data.rank)
		self.gsUpLb=GetTTFLabel("    ↑ +"..(newGs - oldGs),strSize2)
		self.gsUpLb:setColor(G_ColorGreen)
	end
	self.gsUpLb:setAnchorPoint(ccp(0,0))
	self.gsUpLb:setPosition(self.gsLb:getPositionX() + self.gsLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.gsUpLb)

	posY=posY-35

	local probabilityLbStr = GetTTFLabel(getlocal("tip_succeedRate2",{""}),strSize2)
	probabilityLbStr:setAnchorPoint(ccp(0,0))
	probabilityLbStr:setPosition(posX+2,posY)
	self.bgLayer:addChild(probabilityLbStr)
	self.probabilityLb=GetTTFLabel(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data).."%",strSize2)
	self.probabilityLb:setAnchorPoint(ccp(0,0))
	self.probabilityLb:setPosition(probabilityLbStr:getPositionX()+probabilityLbStr:getContentSize().width,posY)
	self.bgLayer:addChild(self.probabilityLb)
	--配件合成概率提高
	self:setRateAddLb(self.probabilityLb:getPositionX()+self.probabilityLb:getContentSize().width+30,posY)

	--强化失败返还资源提示
	local upgradeFailLb=GetTTFLabelWrap(getlocal("accessory_upgrade_fail_desc",{accessoryCfg.upgradeFailReturnResource*100}),strSize3,CCSizeMake(360,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	upgradeFailLb:setAnchorPoint(ccp(0,0.5))
	upgradeFailLb:setPosition(posX+2,posY-20)
	-- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
	-- 	upgradeFailLb:setPosition(posX,posY-15)
	-- else
	-- 	upgradeFailLb:setPosition(posX,posY-15)
	-- end
	self.bgLayer:addChild(upgradeFailLb)
	upgradeFailLb:setColor(G_ColorYellow)

	--yuandanxianli
	local vo =activityVoApi:getActivityVo("yuandanxianli")
	if vo and activityVoApi:isStart(vo) then
		  local today = acYuandanxianliVoApi:isStrengToday()
		  if today==false then
			self.isToday = today
			acYuandanxianliVoApi:updateStrengTime()
			acYuandanxianliVoApi:refreshCurStreng()
		  end
		local basisAc = accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data) * acYuandanxianliVoApi:getAccessStreng()
		if G_getCurChoseLanguage() =="ru" then
			posX = posX-180
			posY = posY -30
		end
		self.acYuandanTb=GetTTFLabel("+"..basisAc.."%",28)
		self.acYuandanTb:setAnchorPoint(ccp(0,0))
		self.bgLayer:addChild(self.acYuandanTb)
		if acYuandanxianliVoApi:isCanStreng() then
			local rateWidth = nil
			if self.addRateLb ==nil then
				rateWidth =0 
			else 
				rateWidth = self.addRateLb:getContentSize().width
			end
			self.acYuandanTb:setPosition(self.probabilityLb:getPositionX()+self.probabilityLb:getContentSize().width+rateWidth+40,posY)
			self.acYuandanTb:setColor(G_ColorRed)
			self.acYuandanTb:setVisible(true)
		else
			self.acYuandanTb:setVisible(false)
		end
	end

	local scale=bg:getScale()
	posY=G_VisibleSizeHeight - 288 - bg:getContentSize().height/2*scale - 20
	local costBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),nilFun)
	costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,40))
	costBg:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costBg)
	local costTitle=GetTTFLabel(getlocal("cost_resource"),24,true)
	costTitle:setColor(G_ColorYellowPro)
	costTitle:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costTitle)

	local px,px1,px2=100,250,440
	posY=posY - 80
	local goldIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
	goldIcon:setScale(80/goldIcon:getContentSize().width)
	goldIcon:setPosition(px,posY-20)
	self.bgLayer:addChild(goldIcon)
	local readyCostLb=GetTTFLabelWrap(getlocal("accessory_ready_cost"),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	readyCostLb:setPosition(ccp(px1,posY-20+30))
	self.bgLayer:addChild(readyCostLb)
	local currentNumLb=GetTTFLabelWrap(getlocal("accessory_current_num"),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	currentNumLb:setPosition(ccp(px2,posY-20+30))
	self.bgLayer:addChild(currentNumLb)
	local resourceStr
	local partID=tonumber(self.data:getConfigData("part"))
	local needResource=accessoryCfg["upgradeResource"..self.data:getConfigData("quality")][partID][self.data.lv+1]
	if(needResource~=nil)then
		needResource=needResource.gold
		-- resourceStr=FormatNumber(playerVoApi:getGold()).." / "..FormatNumber(needResource)
		resourceStr=FormatNumber(needResource)
	else
		needResource=0
		resourceStr=getlocal("alliance_lvmax")
	end
	self.resourceLb=GetTTFLabel(resourceStr,25)
	-- if(tonumber(needResource)>playerVoApi:getGold())then
	-- 	self.resourceLb:setColor(G_ColorRed)
	-- else
		self.resourceLb:setColor(G_ColorGreen)
	-- end
	self.resourceLb:setPosition(px1,posY-20-30)
	self.bgLayer:addChild(self.resourceLb)
	self.hasResourceLb=GetTTFLabel(FormatNumber(playerVoApi:getGold()),25)
	if(tonumber(needResource)>playerVoApi:getGold())then
		self.hasResourceLb:setColor(G_ColorRed)
	else
		self.hasResourceLb:setColor(G_ColorGreen)
	end
	self.hasResourceLb:setPosition(px2,posY-20-30)
	self.bgLayer:addChild(self.hasResourceLb)
	local function addResHandler( ... )
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		accessoryVoApi:showUpgradeBuyResDialog(self.layerNum+1)
	end
	local addResItem=GetButtonItem("sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png",addResHandler,nil,nil,28)
	local addResBtn=CCMenu:createWithItem(addResItem)
	addResBtn:setPosition(570,posY-20)
	addResBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(addResBtn)


	posY=posY - 120
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,60,60),function ( ... )end)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,posY - 5))
	downBg:setAnchorPoint(ccp(0,0))
	downBg:setPosition(30,30)
	self.bgLayer:addChild(downBg)
	local probabilityBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),nilFun)
	probabilityBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,36))
	probabilityBg:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(probabilityBg)
	local probabilityTitle=GetTTFLabel(getlocal("probabilityUp"),24,true)
	probabilityTitle:setColor(G_ColorYellowPro)
	probabilityTitle:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(probabilityTitle)

	posY=posY - 100+15
	local function onClickPropIcon()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		self:showPropSourceDialog()
	end
	icon=GetBgIcon(accessoryCfg.propCfg.p6.icon,onClickPropIcon,nil,80,80)
	icon:setTouchPriority(-(self.layerNum-1)*20-4)
	icon:setAnchorPoint(ccp(0,0.5))
	icon:setPosition(100-40,posY)
	self.bgLayer:addChild(icon)

	posX=450+20
	-- posY=posY - 50 - 15
	local readyCostLb1=GetTTFLabelWrap(getlocal("accessory_ready_cost"),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	readyCostLb1:setPosition(ccp(px1,posY+30))
	self.bgLayer:addChild(readyCostLb1)
	local currentNumLb1=GetTTFLabelWrap(getlocal("accessory_current_num"),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	currentNumLb1:setPosition(ccp(px2,posY+30))
	self.bgLayer:addChild(currentNumLb1)
	self.costPropNumLb=GetTTFLabel(0,25)
	self.costPropNumLb:setAnchorPoint(ccp(0.5,0.5))
	self.costPropNumLb:setPosition(px1,posY-30)
	self.bgLayer:addChild(self.costPropNumLb)
	self.costPropNumLb:setColor(G_ColorGreen)
	-- self.amuletLb=GetTTFLabel(getlocal("accessory_upgrade_amulet_num",{accessoryVoApi:getUpgradeProp()}),25)
	self.amuletLb=GetTTFLabel(accessoryVoApi:getUpgradeProp(),25)
	self.amuletLb:setAnchorPoint(ccp(0.5,0.5))
	self.amuletLb:setPosition(px2,posY-30)
	self.bgLayer:addChild(self.amuletLb)
	self.amuletLb:setColor(G_ColorGreen)

	posY=posY-45
	local function clickHandler( ... )
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		if self.addSuccessSp then
			if self.addSuccessSp:isVisible()==true then
				local num=0
				self.addSuccessSp:setVisible(false)
				self.maxAmuletNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data)
				self:updateLabel()
				-- if self.maskSp then
				-- 	self.maskSp:setPosition(ccp(999333,0))
				-- end
				self:resetMaskPos()

				-- self.lastNumValue=tostring(num)
				-- if self.numShowLb then
				-- 	self.numShowLb:setString(self.lastNumValue)
				-- end
				-- if self.numEditBox then
				-- 	self.numEditBox:setText(self.lastNumValue)
				-- end
				-- if self.costPropNumLb then
				-- 	self.costPropNumLb:setString(self.lastNumValue)
				-- end
				-- if self.probabilityLb then
				-- 	self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data)}))
				-- end
				-- self:setRateAddLb()
			else
				local isMulti=false
				if self.multiNumSp and self.multiNumSp:isVisible()==true then
					isMulti=true
				end
				local count=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,true,isMulti)
				local firstNum,costPropNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data,true,isMulti,count,true)
				local num=firstNum
				if isMulti==true then
					num=costPropNum
				end
				if num and num>0 then
					self.addSuccessSp:setVisible(true)
					self.maxAmuletNum=0--num
					self:updateLabel()
					-- -- if(num>=self.maxAmuletNum)then
					-- -- 	num=self.maxAmuletNum
					-- -- end
					-- self.lastNumValue=tostring(num)
					-- if self.numShowLb then
					-- 	self.numShowLb:setString(0)
					-- end
					-- if self.numEditBox then
					-- 	self.numEditBox:setText(0)
						-- if self.maskSp and self.numEditBox then
						-- 	local px,py=self.numEditBox:getPosition()
						-- 	self.maskSp:setPosition(ccp(px,py))
						-- end
						self:resetMaskPos()
					-- end
					-- if self.costPropNumLb then
					-- 	self.costPropNumLb:setString(self.lastNumValue)
					-- end
					-- if self.probabilityLb then
					-- 	self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(firstNum),self.data)}))
					-- end
					-- self:setRateAddLb()
				-- else
				-- 	local aVo=accessoryVoApi:getAccessoryByPart(self.tankID,self.partID)
				-- 	if aVo then
				-- 		local need=accessoryCfg["upgradeResource"..aVo:getConfigData("quality")][self.partID][aVo.lv+1]
				-- 		if(need==nil or aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
				-- 			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_lvmax"),30)
				-- 		else
				-- 			if accessoryVoApi:getUpgradeProp()==0 or (firstNum and accessoryVoApi:getUpgradeProp()<firstNum) then
				-- 				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success_err1"),30)
				-- 			else
				-- 				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgradePercent100"),30)
				-- 			end
				-- 		end
				-- 	end
				end
			end
		end
	end
    local clickBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),clickHandler)
	clickBg1:setContentSize(CCSizeMake(280,80))
    clickBg1:ignoreAnchorPointForPosition(false)
    clickBg1:setAnchorPoint(ccp(0,0.5))
    clickBg1:setTouchPriority(-(self.layerNum-1)*20-4)
	clickBg1:setPosition(ccp(40,posY-40))
    self.bgLayer:addChild(clickBg1)
    clickBg1:setOpacity(0)
	local addSuccessBg=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    -- addSuccessBg:setTouchPriority(-(self.layerNum-1)*20-4)
    addSuccessBg:setPosition(85,posY-40)
    self.bgLayer:addChild(addSuccessBg,2)
    self.addSuccessSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    self.addSuccessSp:setPosition(85,posY-40)
    self.bgLayer:addChild(self.addSuccessSp,3)
    self.addSuccessSp:setVisible(false)
    local addSuccessLb=GetTTFLabelWrap(getlocal("accessory_add_success_full"),25,CCSizeMake(220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    addSuccessLb:setAnchorPoint(ccp(0,0.5))
	addSuccessLb:setPosition(ccp(85+addSuccessBg:getContentSize().width-15,posY-40))
	self.bgLayer:addChild(addSuccessLb,3)

	local function callbackInput(fn,eB,str,type)
		if type==1 then  --检测文本内容变化
			if str=="" then
				self.lastNumValue="0"
				self.numShowLb:setString(self.lastNumValue)
				do return end
			end
			local strNum=tonumber(str)
			if strNum==nil then
				eB:setText(self.lastNumValue)
			else
				if strNum>=0 and (strNum)<=self.maxAmuletNum then
					self.lastNumValue=str
				else
					if(strNum<0)then
						eB:setText("0")
						self.lastNumValue="0"
					elseif (strNum)>self.maxAmuletNum then
						eB:setText(self.maxAmuletNum)
						self.lastNumValue=tostring(self.maxAmuletNum)
					end
				end
			end
			self.numShowLb:setString(self.lastNumValue)
			local count=1
			if self.multiNumSp and self.multiNumSp:isVisible()==true and self.count then
				count=self.count
				self.costPropNum=tonumber(self.lastNumValue)*count
			else
				self.costPropNum=tonumber(self.lastNumValue)
			end
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			self.numShowLb:setString(self.lastNumValue)
			self.probabilityLb:setString(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data).."%")
			self:setRateAddLb()
			if self.costPropNumLb then
				self.costPropNumLb:setString(self.costPropNum)
			end
		end
	end
	self.lastNumValue="0"
	-- if(self.data.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
	-- 	self.maxAmuletNum=0
	-- else
	-- 	local tmp=math.ceil((100-accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data))/accessoryCfg.amuletProbality)
	-- 	--vip合成几率加成
	-- 	local addRate=accessoryVoApi:getVipUpgradeAddRate()
	-- 	if addRate>0 then
	-- 		local basePercent=accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)
	-- 		local percent=basePercent*1+math.ceil(basePercent*addRate)
	-- 		if percent>100 then
	-- 			percent=100
	-- 		end
	-- 		tmp=math.ceil((100-percent)/accessoryCfg.amuletProbality)
	-- 	end

	-- 	if(tmp>accessoryVoApi:getUpgradeProp())then
	-- 		self.maxAmuletNum=accessoryVoApi:getUpgradeProp()
	-- 	else
	-- 		self.maxAmuletNum=tmp
	-- 	end
	-- end
	self.maxAmuletNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data)

	local numEditBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),nilFun)
	numEditBoxBg:setContentSize(CCSize(120,60))
	local showLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),nilFun)
	showLbBg:setContentSize(CCSize(120,60))
	showLbBg:setPosition(ccp(posX,posY-40))
	self.bgLayer:addChild(showLbBg)
	self.numShowLb=GetTTFLabel(self.lastNumValue,28)
	self.numShowLb:setAnchorPoint(ccp(0.5,0.5))
	self.numShowLb:setPosition(ccp(showLbBg:getContentSize().width/2,showLbBg:getContentSize().height/2))
	showLbBg:addChild(self.numShowLb)
	local numEditBox
	numEditBox=CCEditBox:createForLua(CCSize(120,60),numEditBoxBg,nil,nil,callbackInput)
	if G_isIOS()==true then
		numEditBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
	else
		numEditBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
	end
	numEditBox:setPosition(ccp(posX,posY-40))
	numEditBox:setText(0)
	numEditBox:setVisible(false)
	self.bgLayer:addChild(numEditBox)
	local function showEditBox()
		numEditBox:setText(self.lastNumValue)
		numEditBox:setVisible(true)
	end
	local numEditBoxBg2=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),showEditBox)
	numEditBoxBg2:setPosition(ccp(posX,posY-60))
	numEditBoxBg2:setContentSize(CCSize(120,60))
	numEditBoxBg2:setTouchPriority(-(self.layerNum-1)*20-4)
	numEditBoxBg2:setOpacity(0)
	self.bgLayer:addChild(numEditBoxBg2)
	self.numEditBox=numEditBox

	local function onDecrease()
		PlayEffect(audioCfg.mouseClick)

		local num=tonumber(self.lastNumValue)
		if(num>0)then
			num=num-1
			local count=1
			self.lastNumValue=tostring(num)
			self:updateLabel()
			-- self.numShowLb:setString(self.lastNumValue)
			-- numEditBox:setText(self.lastNumValue)
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data)}))
			-- self:setRateAddLb()
			-- local count=1
			-- if self.multiNumSp and self.multiNumSp:isVisible()==true and self.count then
			-- 	count=self.count
			-- end
			-- self.costPropNum=self.lastNumValue*count
			-- if self.costPropNumLb then
			-- 	self.costPropNumLb:setString(self.costPropNum)
			-- end
		end
	end
	local decreaseItem=GetButtonItem("sYellowSubBtn.png","sYellowSubBtn.png","sYellowSubBtn.png",onDecrease,nil,nil,28)
	local decreaseBtn=CCMenu:createWithItem(decreaseItem)
	decreaseBtn:setPosition(posX-100,posY-45)
	decreaseBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(decreaseBtn)

	local function onIcrease()
		PlayEffect(audioCfg.mouseClick)
		local num=tonumber(self.lastNumValue)
		if(num<self.maxAmuletNum)then
			num=num+1
			self.lastNumValue=tostring(num)
			self:updateLabel()
			-- self.numShowLb:setString(self.lastNumValue)
			-- numEditBox:setText(self.lastNumValue)
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data)}))
			-- self:setRateAddLb()
			-- local count=1
			-- if self.multiNumSp and self.multiNumSp:isVisible()==true and self.count then
			-- 	count=self.count
			-- end
			-- self.costPropNum=self.lastNumValue*count
			-- if self.costPropNumLb then
			-- 	self.costPropNumLb:setString(self.costPropNum)
			-- end
		else
			local addRate=accessoryVoApi:getVipUpgradeAddRate()
			local basePercent=accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)
			local addPercent=basePercent*addRate
			local rateValue = addPercent
			local moPrivilegeFlag, moPrivilegeValue
			if militaryOrdersVoApi then
				moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(5)
			end
			if moPrivilegeFlag == true and moPrivilegeValue then
				addPercent = rateValue + math.ceil(moPrivilegeValue * 100)
			end
			--元旦献礼活动每日前3次加概率
			local vo = activityVoApi:getActivityVo("yuandanxianli")
			if vo and activityVoApi:isStart(vo)== true then
				if acYuandanxianliVoApi:isCanStreng() then
					local acAccessStreng=acYuandanxianliVoApi:getAccessStreng()
					if acAccessStreng then
						addPercent=addPercent+basePercent*acAccessStreng
					end
				end
			end
			if((accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data)+addPercent)<100)then
				self:showPropSourceDialog()
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgradePercent100"),30)
			end
		end
	end
	local increaseItem=GetButtonItem("sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png",onIcrease,nil,nil,28)
	local increaseBtn=CCMenu:createWithItem(increaseItem)
	increaseBtn:setPosition(posX+100,posY-45)
	increaseBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(increaseBtn)
	local function touchLuaSpr()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
		local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
	    if upperLimitTb and upperLimitTb[1] then
	        roleMaxLevel = roleMaxLevel + upperLimitTb[1]
	    end
		if self.data.lv>=roleMaxLevel then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_lvmax"),30)
		elseif self.addSuccessSp and self.addSuccessSp:isVisible()==true then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_can_not_operate"),30)
		elseif self.multiNumSp and self.multiNumSp:isVisible()==true then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_multi_upgrade_err1"),30)
		end
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    self.maskSp:setTouchPriority(-(layerNum-1)*20-5)
    local rect=CCSizeMake(280,100)
    self.maskSp:setContentSize(rect)
    self.maskSp:setOpacity(0)
    self.bgLayer:addChild(self.maskSp,1)
    self:resetMaskPos()


	local function onClick(tag,object)
		PlayEffect(audioCfg.mouseClick)
		self:upgrade()
	end
	self.upgradeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClick,nil,getlocal("upgrade"),24/0.7)
	self.upgradeItem:setScale(0.7)
	self.upgradeItem:setAnchorPoint(ccp(0.5,0))
	local upgradeBtn=CCMenu:createWithItem(self.upgradeItem)
	upgradeBtn:setAnchorPoint(ccp(0.5,0))
	local btnY
	if(G_isIphone5())then
		btnY=75
	else
		btnY=35
	end
	upgradeBtn:setPosition(515,btnY)
	upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(upgradeBtn)
	if(accessoryVoApi:checkCanUpgrade(self.tankID,self.partID,self.data)==4)then
		self.upgradeItem:setEnabled(false)
	end
	local function refreshListener(event,data)
		for k,v in pairs(data.type) do
			if(v==4 or v==3)then
				self:refresh()
				break
			end
		end
	end
	self.refreshListener=refreshListener
	eventDispatcher:addEventListener("accessory.data.refresh",refreshListener)

	btnY=btnY+self.upgradeItem:getContentSize().height/2
	local function clickHandler1( ... )
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		-- local multiNumStr=getlocal("accessory_continuous_strengthen")
		if self.multiNumSp then
			if self.multiNumSp:isVisible()==true then
				self.multiNumSp:setVisible(false)
				self:updateLabel()
				-- if self.maskSp then
				-- 	self.maskSp:setPosition(ccp(999333,0))
				-- end
				self:resetMaskPos()
				-- self.count=1
				-- if self.multiNumLb then
				-- 	self.multiNumLb:setString(multiNumStr)
				-- end
				-- local count=1
				-- if self.multiNumSp and self.multiNumSp:isVisible()==true and self.count then
				-- 	count=self.count
				-- end
				-- self.costPropNum=self.lastNumValue*count
				-- if self.costPropNumLb then
				-- 	self.costPropNumLb:setString(self.costPropNum)
				-- end
			else
				local canUpgrade=self:checkUpgrade()
				if canUpgrade and canUpgrade==0 then
					self.multiNumSp:setVisible(true)
					self:updateLabel()
					-- if self.maskSp and self.numEditBox then
					-- 	local px,py=self.numEditBox:getPosition()
					-- 	self.maskSp:setPosition(ccp(px,py))
					-- end
					self:resetMaskPos()
					-- if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
					-- 	local firstNum,costPropNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data,true)
					-- 	if firstNum and firstNum<=0 then
					-- 		if self.maskSp and self.numEditBox then
					-- 			local px,py=self.numEditBox:getPosition()
					-- 			self.maskSp:setPosition(ccp(px,py))
					-- 		end
					-- 	end
					-- 	-- local curPercent=accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,firstNum,self.data)
					-- 	-- local basePercent=accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)
					-- 	-- local percent=curPercent
					-- 	-- local addRate=accessoryVoApi:getVipUpgradeAddRate()
					-- 	-- if addRate and addRate>0 then
					-- 	-- 	percent=percent+math.ceil(basePercent*addRate)
					-- 	-- end
					-- 	-- if percent>100 then
					-- 	-- else

					-- 	-- end
					-- end

					-- self.count=count
					-- if self.multiNumLb then
					-- 	multiNumStr=multiNumStr..getlocal("accessory_ready_number",{count})
					-- 	self.multiNumLb:setString(multiNumStr)
					-- end
				end
			end
		end
	end
	local clickBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),clickHandler1)
	clickBg2:setContentSize(CCSizeMake(330,80))
    clickBg2:ignoreAnchorPointForPosition(false)
    clickBg2:setAnchorPoint(ccp(0,0.5))
    clickBg2:setTouchPriority(-(self.layerNum-1)*20-4)
	clickBg2:setPosition(ccp(40,btnY))
    self.bgLayer:addChild(clickBg2)
    clickBg2:setOpacity(0)
	local multiNumBg=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    -- multiNumBg:setTouchPriority(-(self.layerNum-1)*20-4)
    multiNumBg:setPosition(85,btnY)
    self.bgLayer:addChild(multiNumBg,2)
    self.multiNumSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    self.multiNumSp:setPosition(85,btnY)
    self.bgLayer:addChild(self.multiNumSp,3)
    self.multiNumSp:setVisible(false)
    self.multiNumLb=GetTTFLabelWrap(getlocal("accessory_continuous_strengthen"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.multiNumLb:setAnchorPoint(ccp(0,0.5))
	self.multiNumLb:setPosition(ccp(85+multiNumBg:getContentSize().width-15,btnY))
	self.bgLayer:addChild(self.multiNumLb,3)
	self.multiNumLb:setColor(G_ColorBlue)

	local function dialogListener(event,data)
        self:setResLb()
    end
    self.dialogListener=dialogListener
    eventDispatcher:addEventListener("accessory.dialog.upgradeBuyRes",self.dialogListener)

	return self.bgLayer
end

--选择补至100%成功率和连续强化选项时 ui变化
function accessoryEquipDialogTabUpgrade:updateLabel()
	if self.multiNumSp and self.addSuccessSp then
		self.lastNumValue=tonumber(self.lastNumValue)
		local multiNumStr=getlocal("accessory_continuous_strengthen")
		if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
			local isMulti=false
			if self.multiNumSp and self.multiNumSp:isVisible()==true then
				isMulti=true
			end
			self.count=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,true,isMulti)
			local firstNum,costPropNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data,true,isMulti,self.count)
			if isMulti==true then
				-- self.count=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,true,isMulti)
				self.costPropNum=costPropNum
				if self.multiNumLb then
					multiNumStr=multiNumStr..getlocal("accessory_ready_number",{self.count})
					self.multiNumLb:setString(multiNumStr)
				end
			else
				-- self.count=1
				self.costPropNum=firstNum
				if self.multiNumLb then
					self.multiNumLb:setString(multiNumStr)
				end
			end
			self.lastNumValue=0
		else
			if self.multiNumSp and self.multiNumSp:isVisible()==true then
				self.count=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,nil,true)
				self.lastNumValue=0
				self.costPropNum=self.lastNumValue*self.count
				if self.costPropNum>accessoryVoApi:getUpgradeProp() then
					self.costPropNum=accessoryVoApi:getUpgradeProp()
				end
				if self.multiNumLb then
					multiNumStr=multiNumStr..getlocal("accessory_ready_number",{self.count})
					self.multiNumLb:setString(multiNumStr)
				end
			else
				self.count=1
				self.costPropNum=self.lastNumValue
				if self.multiNumLb then
					self.multiNumLb:setString(multiNumStr)
				end
			end
		end
		if self.numShowLb then
			self.numShowLb:setString(self.lastNumValue)
		end
		if self.numEditBox then
			self.numEditBox:setText(self.lastNumValue)
		end
		if self.costPropNumLb then
			self.costPropNumLb:setString(self.costPropNum)
		end
		self:setSuccessRateLb()
		self:setResLb()
	end
end

function accessoryEquipDialogTabUpgrade:checkUpgrade()
	local canUpgrade=accessoryVoApi:checkCanUpgrade(self.tankID,self.partID,self.data)
	if(canUpgrade==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9000"),30)
		-- do return end
	elseif(canUpgrade==4)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_lvmax"),30)
		-- do return end
	elseif(canUpgrade==3)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_lv_not_enough"),30)
		-- do return end
	elseif(canUpgrade==2)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
		-- do return end
	end
	return canUpgrade
end

function accessoryEquipDialogTabUpgrade:upgrade()
	local canUpgrade=self:checkUpgrade()
	if canUpgrade~=0 then
		do return end
	end
	-- local canUpgrade=accessoryVoApi:checkCanUpgrade(self.tankID,self.partID,self.data)
	-- if(canUpgrade==1)then
	-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("data_error_need_reopen"),30)
	-- 	do return end
	-- elseif(canUpgrade==4)then
	-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_lvmax"),30)
	-- 	do return end
	-- elseif(canUpgrade==3)then
	-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_lv_not_enough"),30)
	-- 	do return end
	-- elseif(canUpgrade==2)then
	-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
	-- 	do return end
	-- end

	-- local costResTb={}
	local numData,count
	if self.multiNumSp and self.multiNumSp:isVisible()==true then
		if self.count and self.count>0 then
			count=self.count
			numData={}
			local isAlwaysSuccess
			if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
				isAlwaysSuccess=true
				local firstNum,costPropNum,costTb=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data,isAlwaysSuccess,true,count)
				numData=costTb
			else
				for i=1,count do
					local num=tonumber(self.lastNumValue)*i
					local diffNum=num-tonumber(self.costPropNum)
					if diffNum>0 then
						table.insert(numData,tonumber(self.lastNumValue)-diffNum)
					else
						table.insert(numData,tonumber(self.lastNumValue))
					end
				end
			end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9033"),30)
			do return end
		end
	else
		numData=tonumber(self.costPropNum)
	end
	local function callback(result,sData,oldLv,usedResource)

		if sData and sData.data and sData.data.report then
			local content={}
			local showStrTb={}
			local upLv=oldLv or 0
			for k,v in pairs(sData.data.report) do
				if v and SizeOfTable(v)>0 then
					self:setAcPercent()

					local isVictory=v[1] or 0
					local costTb=v[2] or {}
					local needRes=0
					if costTb and costTb.gold then
						needRes=costTb.gold or 0
					end
					local propNum=v[3] or 0
					local returnTb=v[4] or {}
					local returnRes=0
					if returnTb and returnTb.gold then
						returnRes=returnTb.gold or 0
					end
					local reward={u={{gold=needRes,index=1}},e={{p6=propNum,index=2}}}
					local award=FormatItem(reward,nil,true)
					local reData={isVictory=isVictory,award=award,returnRes=returnRes}
					table.insert(content,reData)

					local numStr=getlocal("accessory_strengthen_num",{k})
					if isVictory==1 then
						upLv=upLv+1
						numStr=numStr..getlocal("accessory_strengthen_level_up",{upLv})
					else
						numStr=numStr..getlocal("fight_content_result_defeat")
					end
					table.insert(showStrTb,numStr)
				end
			end
			local isOneByOne=true
			accessoryVoApi:showRaidsRewardSmallDialog("TankInforPanel.png",CCSizeMake(550,700),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("accessory_strengthen_record"),content,nil,nil,self.layerNum+1,nil,isOneByOne,nil,showStrTb,nil,true)
		else
			self:setAcPercent()
			if(result==true)then
					self:showChangeNum()
			else
				self:stopNumAction()
				if usedResource and usedResource > 0 then
					local resNum = FormatNumber(usedResource)
					local recRescource = getlocal("returnResourse",{resNum})
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_fail").."\n"..recRescource,30,nil,nil,nil,G_ColorRed)
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_fail"),30,nil,nil,nil,G_ColorRed)
				end
				
			end
		end
		self:updateLabel()
		self:refresh()
		if self.count and self.count<=0 then
			if self.multiNumSp and self.multiNumSp:isVisible()==true then
				self.multiNumSp:setVisible(false)
			end
			if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
				self.addSuccessSp:setVisible(false)
			end
			self:updateLabel()
			self:resetMaskPos()
			self:refresh()
		end
	end
	accessoryVoApi:upgrade(self.tankID,self.partID,self.data,numData,callback,count)
end

function accessoryEquipDialogTabUpgrade:stopNumAction( )
	self.bgLayer:stopAllActions()
	self.lvLb:stopAllActions()
	self.gsLb:stopAllActions()
	self.probabilityLb:stopAllActions()
	self.lvLb:setScale(1)
	self.gsLb:setScale(1)
	self.probabilityLb:setScale(1)
	local attTypeTb=self.data:getConfigData("attType")
	for k,v in pairs(attTypeTb) do
		self.attLbTb[k]:stopAllActions()
		self.attLbTb[k]:setScale(1)
	end
end

function accessoryEquipDialogTabUpgrade:showChangeNum( )
	self:stopNumAction()
	G_showNumberScaleByAction(self.lvLb,0.15,1.2)
	G_showNumberScaleByAction(self.gsLb,0.15,1.2)
	G_showNumberScaleByAction(self.probabilityLb,0.15,1.2)
	local attTypeTb=self.data:getConfigData("attType")
	for k,v in pairs(attTypeTb) do
		G_showNumberScaleByAction(self.attLbTb[k],0.15,1.2)
	end
	local function callbackToShow( )
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success"),30,nil,nil,nil,G_ColorYellowPro)
	end
	local callFunc=CCCallFunc:create(callbackToShow)
	local delay=CCDelayTime:create(0.8)
	local acArr=CCArray:create()
	acArr:addObject(delay)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.bgLayer:runAction(seq)
	
end

function accessoryEquipDialogTabUpgrade:setAcPercent()
	local vo = activityVoApi:getActivityVo("yuandanxianli")
	if vo and activityVoApi:isStart(vo)== true then
		if acYuandanxianliVoApi:isCanStreng() then
			acYuandanxianliVoApi:setCurStreng()	   --yuandanxianli
			if acYuandanxianliVoApi:isCanStreng()==false then
				if self.acYuandanTb then
					self.acYuandanTb:setVisible(false)
				end
			end
		else
			if self.acYuandanTb then
				self.acYuandanTb:setVisible(false)
			end
		end
	end
end


function accessoryEquipDialogTabUpgrade:refresh()
	self.data=accessoryVoApi:getAccessoryByPart(self.tankID,self.partID)
	local attTb=self.data:getAttWithSuccinct()
	local differenceTb=self.data:getConfigData("lvGrow")
	local attTypeTb=self.data:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect

	self.rankLb:setString(self.data.rank)
	self.lvLb1:setString(getlocal("fightLevel",{self.data.lv}))
	if(self.techLb)then
		self.techLb:setString(self.data.techLv or 0)
	end
	-- self.lvLb:setString(getlocal("accessory_lv",{self.data.lv}))
	self.lvLb:setString(self.data.lv)
	
	local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
	local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[1] then
        roleMaxLevel = roleMaxLevel + upperLimitTb[1]
    end
	if(self.data.lv>=roleMaxLevel)then
		self.upLb1:setString(" "..getlocal("donatePointMax"))
		self.upLb1:setPositionX(self.lvLb:getPositionX()+self.lvLb:getContentSize().width)
		self.upLb1:setColor(G_ColorYellowPro)
	else
		self.upLb1:setString("")
	end
	
	

	for k,v in pairs(attTypeTb) do
		local effectStr
		local diffrenceStr
		if(attEffectTb[v]==1)then
			effectStr=string.format("%.2f",attTb[v]).."%"
			diffrenceStr=differenceTb[k].."%"
		else
			effectStr=attTb[v]
			diffrenceStr=differenceTb[k]
		end
		self.attLbTb[k]:setString(effectStr)
		
        self.attUpLbTb[k]:setString("    ↑ +"..diffrenceStr)
		self.attUpLbTb[k]:setPositionX(self.attLbTb[k]:getPositionX()+self.attLbTb[k]:getContentSize().width)
		if(self.data.lv>=roleMaxLevel)then
			self.attUpLbTb[k]:setVisible(false)
		end
	end

	-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)}))
	self:setSuccessRateLb()
	
	
	local vo = activityVoApi:getActivityVo("yuandanxianli")
	if vo and activityVoApi:isStart(vo)== true then
		if acYuandanxianliVoApi:isCanStreng() then
			local basisAc = accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data,false) * acYuandanxianliVoApi:getAccessStreng()
			if self.acYuandanTb then
				self.acYuandanTb:setString("+"..basisAc.."%")
				self.acYuandanTb:setVisible(true)
			end
		else
			if self.acYuandanTb then
				self.acYuandanTb:setVisible(false)
			end
		end
   end

	self:setRateAddLb()
	local oldGs=self.data:getGS()
	self.gsLb:setString(oldGs)
	
	if(self.data.lv>=roleMaxLevel)then
		self.gsUpLb:setString("")
		-- self.gsUpLb:setColor(G_ColorYellowPro)
	else
		local newGs=self.data:getGS(self.data.lv + 1,self.data.rank)
		self.gsUpLb:setString("    ↑ +"..(newGs - oldGs))
	end
	-- self.amuletLb:setString(getlocal("accessory_upgrade_amulet_num",{accessoryVoApi:getUpgradeProp()}))
	self.amuletLb:setString(accessoryVoApi:getUpgradeProp())

	self.lastNumValue="0"
	self.numShowLb:setString("0")

	if(self.data.lv>=roleMaxLevel)then
		self.maxAmuletNum=0
	else
		local tmp=math.ceil((100-accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data))/accessoryCfg.amuletProbality)
		--vip合成几率加成
		local addRate=accessoryVoApi:getVipUpgradeAddRate()
		if addRate>0 then
			local basePercent=accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)
			local percent=basePercent*1+basePercent*addRate
			if percent>100 then
				percent=100
			end
			tmp=math.ceil((100-percent)/accessoryCfg.amuletProbality)
		end

		if(tmp>accessoryVoApi:getUpgradeProp())then
			self.maxAmuletNum=accessoryVoApi:getUpgradeProp()
		else
			self.maxAmuletNum=tmp
		end
	end

	-- local resourceStr
	-- local partID=tonumber(self.data:getConfigData("part"))
	-- local needResource=accessoryCfg["upgradeResource"..self.data:getConfigData("quality")][partID][self.data.lv+1]
	-- if(needResource~=nil)then
	-- 	needResource=needResource.gold
	-- 	-- resourceStr=FormatNumber(playerVoApi:getGold()).." / "..FormatNumber(needResource)
	-- 	resourceStr=FormatNumber(needResource)
	-- else
	-- 	resourceStr=getlocal("alliance_lvmax")
	-- 	needResource=0
	-- end
	-- self.resourceLb:setString(resourceStr)
	-- self.hasResourceLb:setString(FormatNumber(playerVoApi:getGold()))
	-- if(tonumber(needResource)>playerVoApi:getGold())then
	-- 	self.hasResourceLb:setColor(G_ColorRed)
	-- else
	-- 	self.hasResourceLb:setColor(G_ColorGreen)
	-- end
	self:setResLb()

	if(accessoryVoApi:checkCanUpgrade(self.tankID,self.partID,self.data)==4)then
		self.upgradeItem:setEnabled(false)
	else
		self.upgradeItem:setEnabled(true)
	end
end

function accessoryEquipDialogTabUpgrade:setSuccessRateLb()
	if self.multiNumSp and self.multiNumSp:isVisible()==true then
		if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
			local count=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,true,true)
			local firstNum,costPropNum=accessoryVoApi:successNeedPropNum(self.tankID,self.partID,self.data,true,true,count)
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(firstNum),self.data)}))
			self.probabilityLb:setString(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(firstNum),self.data).."%")
		else
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.costPropNum),self.data)}))
			self.probabilityLb:setString(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.costPropNum),self.data).."%")
		end
	else
		if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.costPropNum),self.data)}))
			self.probabilityLb:setString(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.costPropNum),self.data).."%")
		else
			-- self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data)}))
			self.probabilityLb:setString(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,tonumber(self.lastNumValue),self.data).."%")
		end
	end
	
	self:setRateAddLb()
end

function accessoryEquipDialogTabUpgrade:setResLb()
	local resourceStr
	local partID=tonumber(self.data:getConfigData("part"))
	local needResource=accessoryCfg["upgradeResource"..self.data:getConfigData("quality")][partID][self.data.lv+1]
	if(needResource~=nil)then
		needResource=needResource.gold
		-- resourceStr=FormatNumber(playerVoApi:getGold()).." / "..FormatNumber(needResource)
		if self.multiNumSp and self.multiNumSp:isVisible()==true then
			local isAlwaysSuccess
			if self.addSuccessSp and self.addSuccessSp:isVisible()==true then
				isAlwaysSuccess=true
			end
			local count,costRes=accessoryVoApi:canUpgradeNum(self.tankID,self.partID,self.data,isAlwaysSuccess,true)
			needResource=costRes
		end
		resourceStr=FormatNumber(needResource)
	else
		resourceStr=getlocal("alliance_lvmax")
		needResource=0
	end
	if self.resourceLb then
		self.resourceLb:setString(resourceStr)
	end
	if self.hasResourceLb then
		self.hasResourceLb:setString(FormatNumber(playerVoApi:getGold()))
		if(tonumber(needResource)>playerVoApi:getGold())then
			self.hasResourceLb:setColor(G_ColorRed)
		else
			self.hasResourceLb:setColor(G_ColorGreen)
		end
	end
end

function accessoryEquipDialogTabUpgrade:setRateAddLb(posX,posY)
	--配件合成概率提高
	local addRate=accessoryVoApi:getVipUpgradeAddRate()
	if self.probabilityLb and addRate>0 then
		local rateValue = math.floor(accessoryVoApi:getUpgradeProbability(self.tankID,self.partID,0,self.data)*addRate)
		local moPrivilegeFlag, moPrivilegeValue
		if militaryOrdersVoApi then
			moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(5)
		end
		if moPrivilegeFlag == true and moPrivilegeValue then
			rateValue = rateValue + math.ceil(moPrivilegeValue * 100)
		end
		local addRateStr="+"..rateValue.."%"
		if self.addRateLb==nil then
			self.addRateLb=GetTTFLabel(addRateStr,28)
			self.addRateLb:setAnchorPoint(ccp(0,0))
			self.bgLayer:addChild(self.addRateLb)
			self.addRateLb:setColor(G_ColorRed)
		end
		self.addRateLb:setVisible(true)
		self.addRateLb:setString(addRateStr)
		if posX and posY then

			self.addRateLb:setPosition(posX,posY)
		end
	elseif self.addRateLb then
		self.addRateLb:setVisible(false)
	end
end

function accessoryEquipDialogTabUpgrade:showPropSourceDialog()
	accessoryVoApi:showSourceDialog(3,6,self.layerNum+1)
end

function accessoryEquipDialogTabUpgrade:resetMaskPos()
	if self.maskSp then
		local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
		local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
	    if upperLimitTb and upperLimitTb[1] then
	        roleMaxLevel = roleMaxLevel + upperLimitTb[1]
	    end
		if (self.data.lv>=roleMaxLevel) or (self.addSuccessSp and self.addSuccessSp:isVisible()==true) or (self.multiNumSp and self.multiNumSp:isVisible()==true) then
			if self.numEditBox then
				local px,py=self.numEditBox:getPosition()
				self.maskSp:setPosition(ccp(px,py))
			end
		else
			self.maskSp:setPosition(ccp(999333,0))
		end
	end
end

function accessoryEquipDialogTabUpgrade:dispose()
	eventDispatcher:removeEventListener("accessory.dialog.upgradeBuyRes",self.dialogListener)
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
	end
	self.probabilityLb=nil
	self.numShowLb=nil
	self.lastNumValue=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil
	self.maxAmuletNum=nil
	self.multiNumSp=nil
	self.multiNumLb=nil
	self.numEditBox=nil
	self.addSuccessSp=nil
end