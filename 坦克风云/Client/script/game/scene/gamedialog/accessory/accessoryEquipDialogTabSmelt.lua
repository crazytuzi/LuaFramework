--配件改造的tab
accessoryEquipDialogTabSmelt={}

function accessoryEquipDialogTabSmelt:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	return nc
end

function accessoryEquipDialogTabSmelt:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	local posX,posY=self:initUp()
	posX,posY=self:initCenter(posX,posY)
	self:initDown(posX,posY)
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
	return self.bgLayer
end

function accessoryEquipDialogTabSmelt:initUp()
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local upBg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	upBg:setScale((G_VisibleSizeWidth - 42)/upBg:getContentSize().width)
	upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(upBg)
	local iconBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	iconBg:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(iconBg)
	local icon=accessoryVoApi:getAccessoryIcon(self.data.type,70,100)
	icon:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(icon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	self.rankLb1=GetTTFLabel(self.data.rank,30)
	self.rankLb1:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(self.rankLb1)
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
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width + 120,titleLb:getContentSize().height + 16))
	titleBg:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190)
	self.bgLayer:addChild(titleBg)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190)
	self.bgLayer:addChild(titleLb)

	local reduceLv
	if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
		reduceLv=0
	elseif(accessoryCfg.smeltReduceLv>self.data.lv)then
		reduceLv=self.data.lv
	else
		reduceLv=accessoryCfg.smeltReduceLv
	end
	self.oldReduceLv = reduceLv
	self.attTb=self.data:getAttWithSuccinct()
	self.nextLvAttTb=self.data:getAttByLvAndRank(self.data.lv - reduceLv,self.data.rank + 1)
	self.differenceTb={}
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v - self.attTb[k]
	end
	self.attTypeTb=self.data:getConfigData("attType")
	self.attEffectTb=accessoryCfg.attEffect
	
	posX,posY=240,G_VisibleSizeHeight - 250
	local rankStrLb = GetTTFLabel(getlocal("accessory_rank",{""}),strSize2)
	rankStrLb:setAnchorPoint(ccp(0,0))
	rankStrLb:setPosition(posX,posY)
	self.bgLayer:addChild(rankStrLb)

	self.rankLb=GetTTFLabel(self.data.rank,strSize2)
	self.rankLb:setAnchorPoint(ccp(0,0))
	self.rankLb:setPosition(rankStrLb:getPositionX()+rankStrLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.rankLb)

    self.upLb1=GetTTFLabel("    ↑ +1",strSize2)
	self.upLb1:setAnchorPoint(ccp(0,0))
	self.upLb1:setColor(G_ColorGreen)
	self.upLb1:setPosition(self.rankLb:getPositionX()+self.rankLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb1)

	posY=posY-35
	local lvLbStr = GetTTFLabel(getlocal("accessory_lv",{""}),strSize2)
	lvLbStr:setAnchorPoint(ccp(0,0))
	lvLbStr:setPosition(posX,posY)
	self.bgLayer:addChild(lvLbStr)

	self.lvLb=GetTTFLabel(self.data.lv,strSize2)
	self.lvLb:setAnchorPoint(ccp(0,0))
	self.lvLb:setPosition(lvLbStr:getPositionX()+lvLbStr:getContentSize().width,posY)
	self.bgLayer:addChild(self.lvLb)

    self.upLb2=GetTTFLabel("    ↓ -"..reduceLv,strSize2)
	self.upLb2:setAnchorPoint(ccp(0,0))
	self.upLb2:setColor(G_ColorRed)
	self.upLb2:setPosition(self.lvLb:getPositionX()+self.lvLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb2)

	local smeltMaxRank=accessoryVoApi:getSmeltMaxRank(self.data:getConfigData("quality"))
	local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[2] then
        smeltMaxRank = smeltMaxRank + upperLimitTb[2]
    end
	if(self.data.rank>=smeltMaxRank)then
		local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
		if upperLimitTb and upperLimitTb[1] then
	        roleMaxLevel = roleMaxLevel + upperLimitTb[1]
	    end
		if(self.data.lv>=roleMaxLevel)then
			self.upLb2:setString(" "..getlocal("donatePointMax"))
			self.upLb2:setColor(G_ColorYellowPro)
		else
			self.upLb2:setVisible(false)
		end
		self.upLb1:setString(" "..getlocal("donatePointMax"))
		self.upLb1:setColor(G_ColorYellowPro)
	end
	if(reduceLv<=0)then
	   self.upLb2:setVisible(false)
	end 

	self.attLbs={}
	self.effectLbs={}
	for k,v in pairs(self.attTypeTb) do
		posY=posY-35
		local effectStr
		local diffrenceStr
		if(self.attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",self.attTb[v]).."%"
			diffrenceStr=string.format("%.2f",self.differenceTb[v]).."%"
		else
			effectStr=self.attTb[v]
			diffrenceStr=self.differenceTb[v]
		end
		local attLb=GetTTFLabel(getlocal("accessory_attAdd_"..v,{""}),strSize2)
		attLb:setAnchorPoint(ccp(0,0))
		attLb:setPosition(posX,posY)
		self.bgLayer:addChild(attLb)

		local attNumLb = GetTTFLabel(effectStr,strSize2)
		attNumLb:setAnchorPoint(ccp(0,0))
		attNumLb:setPosition(attLb:getPositionX()+attLb:getContentSize().width,posY)
		self.bgLayer:addChild(attNumLb)
		self.effectLbs[k]=attNumLb

        local upLbTmp=GetTTFLabel("    ↑ +"..diffrenceStr,strSize2)
		upLbTmp:setColor(G_ColorGreen)
		upLbTmp:setAnchorPoint(ccp(0,0))
		upLbTmp:setPosition(attNumLb:getPositionX()+attNumLb:getContentSize().width,posY)
		self.attLbs[k]=upLbTmp
		self.bgLayer:addChild(upLbTmp)
		if(self.data.rank>=smeltMaxRank)then
			upLbTmp:setVisible(false)
		end
	end

	posY=posY-35
	local oldGs=self.data:getGS()

	local gsLbStr = GetTTFLabel(getlocal("accessory_gsAdd",{""}),strSize2)
	gsLbStr:setAnchorPoint(ccp(0,0))
	gsLbStr:setPosition(posX,posY)
	self.bgLayer:addChild(gsLbStr)

	self.gsLb=GetTTFLabel(oldGs,strSize2)
	self.gsLb:setAnchorPoint(ccp(0,0))
	self.gsLb:setPosition(gsLbStr:getPositionX()+gsLbStr:getContentSize().width,posY)
	self.bgLayer:addChild(self.gsLb)

	if(self.data.rank>=smeltMaxRank)then
		self.gsUpLb=GetTTFLabel("",strSize2)
		self.gsUpLb:setColor(G_ColorYellowPro)
	else
		local newGs=self.data:getGS(self.data.lv - reduceLv,self.data.rank + 1)
		self.gsUpLb=GetTTFLabel("    ↑ +"..(newGs - oldGs),strSize2)
		self.gsUpLb:setColor(G_ColorGreen)
	end
	self.gsUpLb:setAnchorPoint(ccp(0,0))
	self.gsUpLb:setPosition(self.gsLb:getPositionX() + self.gsLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.gsUpLb)

	local scale=upBg:getScale()
	return G_VisibleSizeWidth/2,G_VisibleSizeHeight - 288 - upBg:getContentSize().height/2*scale
end

function accessoryEquipDialogTabSmelt:initCenter(posX,posY)
	posY = posY - 20
	local costBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
	costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,40))
	costBg:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costBg)
	local costTitle=GetTTFLabel(getlocal("alien_tech_consume_material"),24,true)
	costTitle:setColor(G_ColorYellowPro)
	costTitle:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costTitle)
	self.needPropNumTb=accessoryVoApi:getSmeltPropNum(self.data)
	self.propLbs={}
	local unitWidth=(G_VisibleSizeWidth - 40)/4
	local startX=20
	local smeltMaxRank=accessoryVoApi:getSmeltMaxRank(self.data:getConfigData("quality"))
	local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[2] then
        smeltMaxRank = smeltMaxRank + upperLimitTb[2]
    end
	for i=1,4 do
		local function onClickPropIcon(object,fn,tag)
			local id=tag-518
			self:showPropSourceDialog(id)
		end
		local icon=GetBgIcon(accessoryCfg.propCfg["p"..i].icon,onClickPropIcon,nil,80,80)
		icon:setTag(518+i)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(startX + (i - 0.5)*unitWidth,posY - 80)
		self.bgLayer:addChild(icon)

		local str
		local hasProp=accessoryVoApi:getPropNums()["p"..i] or 0
		if(self.data.rank>=smeltMaxRank)then
			str=getlocal("donatePointMax")
		else
			str=FormatNumber(hasProp).." / "..FormatNumber(self.needPropNumTb["p"..i] or 0)
		end
		local propNumLb=GetTTFLabel(str,22)
		if(hasProp<self.needPropNumTb["p"..i])then
			propNumLb:setColor(G_ColorRed)
		else
			propNumLb:setColor(G_ColorGreen)
		end
		propNumLb:setPosition(startX + (i - 0.5)*unitWidth,posY - 145)
		self.bgLayer:addChild(propNumLb)
		self.propLbs[i]=propNumLb
	end
	return G_VisibleSizeWidth/2,posY - 170
end

function accessoryEquipDialogTabSmelt:initDown(posX,posY)
	local posY=posY - 30
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,60,60),function ( ... )end)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,posY - 5))
	downBg:setAnchorPoint(ccp(0,0))
	downBg:setPosition(30,30)
	self.bgLayer:addChild(downBg)
	local costBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
	costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,40))
	costBg:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costBg)
	local costTitle=GetTTFLabel(getlocal("accessory_smeltSafety"),24,true)
	costTitle:setColor(G_ColorYellowPro)
	costTitle:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(costTitle)
	local function onClickCheckBox(object,name,tag)
		if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_accessoryEvolution_propNotNeed"),30)
			do return end
		end
		local smeltMaxRank = accessoryVoApi:getSmeltMaxRank(self.data:getConfigData("quality"))
		local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
	    if upperLimitTb and upperLimitTb[2] then
	        smeltMaxRank = smeltMaxRank + upperLimitTb[2]
	    end
		if(self.data.rank>=smeltMaxRank)then
			do return end
		end
		if(tag==824)then
			self.useAmulet=false
			self.checkBoxFrameChecked:setPositionX(999333)
			self.checkBoxFrameChecked:setVisible(false)
			self.checkBoxFrameUnchecked:setPositionX(G_VisibleSizeWidth - 70)
			self.checkBoxFrameUnchecked:setVisible(true)
		else
			if(accessoryVoApi:getSmeltProp()>=accessoryVoApi:getSmeltAmuletNum(self.data))then
				self.useAmulet=true
				self.checkBoxFrameChecked:setPositionX(G_VisibleSizeWidth - 70)
				self.checkBoxFrameChecked:setVisible(true)
				self.checkBoxFrameUnchecked:setPositionX(999333)
				self.checkBoxFrameUnchecked:setVisible(false)
			end
		end
		self:refreshAttLbs()
	end
	local function onClickPropIcon()
		self:showPropSourceDialog(5)
	end
	local icon=GetBgIcon(accessoryCfg.propCfg["p5"].icon,onClickPropIcon,nil,80,80)
	icon:setTouchPriority(-(self.layerNum-1)*20-4)
	icon:setPosition(100,posY - 90)
	self.bgLayer:addChild(icon)

	self.amuletLb=GetTTFLabel(FormatNumber(accessoryVoApi:getSmeltProp()).." / "..FormatNumber(accessoryVoApi:getSmeltAmuletNum(self.data)),25)
	if(accessoryVoApi:getSmeltProp()>=accessoryVoApi:getSmeltAmuletNum(self.data))then
		self.amuletLb:setColor(G_ColorGreen)
	else
		self.amuletLb:setColor(G_ColorRed)
	end
	self.amuletLb:setPosition(100,posY - 145)
	self.bgLayer:addChild(self.amuletLb)

	self.checkBoxFrameUnchecked=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClickCheckBox)
	self.checkBoxFrameUnchecked:setTouchPriority(-(self.layerNum-1)*20-4)
	self.checkBoxFrameUnchecked:setScale(1.2)
	self.checkBoxFrameUnchecked:setPosition(G_VisibleSizeWidth - 70,posY - 90)
	self.checkBoxFrameUnchecked:setTag(823)
	self.bgLayer:addChild(self.checkBoxFrameUnchecked)
	self.checkBoxFrameChecked=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",onClickCheckBox)
	self.checkBoxFrameChecked:setTouchPriority(-(self.layerNum-1)*20-4)
	self.checkBoxFrameChecked:setScale(1.2)
	self.checkBoxFrameChecked:setPosition(999333,posY - 90)
	self.checkBoxFrameChecked:setTag(824)
	self.bgLayer:addChild(self.checkBoxFrameChecked)

	self.tipLb=GetTTFLabelWrap(getlocal("accessory_smelt_amulet_desc",{accessoryVoApi:getSmeltAmuletNum(self.data)}),25,CCSizeMake(G_VisibleSizeWidth - 150 - 110,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.tipLb:setAnchorPoint(ccp(0,1))
	self.tipLb:setPosition(150,posY - 50)
	self.bgLayer:addChild(self.tipLb)
	posY=posY-110

	local function onClick(tag,object)
		PlayEffect(audioCfg.mouseClick)
		self:smelt()
	end
	self.smeltItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClick,nil,getlocal("smelt"),24/0.7)
	self.smeltItem:setScale(0.7)
	self.smeltItem:setAnchorPoint(ccp(0.5,0))
	local smeltBtn=CCMenu:createWithItem(self.smeltItem)
	smeltBtn:setAnchorPoint(ccp(0.5,0))
	local btnY
	if(G_isIphone5())then
		btnY=75
	else
		btnY=35
	end
	smeltBtn:setPosition(self.bgLayer:getContentSize().width/2,btnY)
	smeltBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	if(accessoryVoApi:checkCanSmelt(self.tankID,self.partID,self.data)==3)then
		self.smeltItem:setEnabled(false)
	end
	local maxRank = accessoryVoApi:getSmeltMaxRank(self.data:getConfigData("quality"))
	local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[2] then
        maxRank = maxRank + upperLimitTb[2]
    end
	if(self.data.rank>=maxRank)then
		self.amuletLb:setVisible(false)
		self.tipLb:setString(getlocal("accessory_rank_max"))
	end
	self.bgLayer:addChild(smeltBtn)
end

function accessoryEquipDialogTabSmelt:refreshAttLbs()
	local reduceLv
	if(self.useAmulet)then		
		reduceLv=0
	else		
		if(accessoryCfg.smeltReduceLv>self.data.lv)then
			reduceLv=self.data.lv
		else
			reduceLv=accessoryCfg.smeltReduceLv
		end
	end
    self.upLb2:setString("    ↓ -"..reduceLv)
	if(reduceLv>0)then
		self.upLb2:setVisible(true)
	else
		self.upLb2:setVisible(false)
	end
	self.nextLvAttTb=self.data:getAttByLvAndRank(self.data.lv - reduceLv,self.data.rank + 1)
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v - self.attTb[k]
	end
	for k,v in pairs(self.attLbs) do
		local diffrenceStr
		local index=self.attTypeTb[k]
		if(self.attEffectTb[index]==1)then
			diffrenceStr=string.format("%.2f",self.differenceTb[index]).."%"
		else
			diffrenceStr=self.differenceTb[index]
		end
        v:setString("    ↑ +"..diffrenceStr)
	end
end

function accessoryEquipDialogTabSmelt:smelt()
	local reduceLv = 0
	if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
		reduceLv=0
	elseif(accessoryCfg.smeltReduceLv>self.data.lv)then
		reduceLv=self.data.lv
	else
		reduceLv=accessoryCfg.smeltReduceLv
	end
	local downLvStr = reduceLv > 0 and getlocal("accessory_lvDownTo",{self.data.lv - reduceLv}) or ""
	downLvStr = self.useAmulet and "" or downLvStr
	local canSmelt=accessoryVoApi:checkCanSmelt(self.tankID,self.partID,self.data)
	if(canSmelt==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9000"),30)
		do return end
	elseif(canSmelt>20 and canSmelt<30)then
		local rank=self.data.rank
		local needTb=accessoryCfg["smeltPropNum"..self.data:getConfigData("quality")][rank+1]
		local notEnoughTb={}
		for i=1,4 do
			local has=accessoryVoApi:getPropNums()["p"..i] or 0
			local needNum=needTb["p"..i]
			if(has<needNum)then
				local str=getlocal("accessory_smelt_p"..i)
				table.insert(notEnoughTb,str)
			end
		end
		local nameStr=table.concat(notEnoughTb,", ")
		local propID=canSmelt%20
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("prop_not_enough",{nameStr}),30)
		do return end
	elseif(canSmelt==3)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_rank_max"),30)
		do return end
	end
	local function callback(result,retProp)
		if retProp then
			local retItem=FormatItem(retProp)
			local num=FormatNumber(retItem[1].num)
			local retStr=getlocal("activity_pjgx_returnResourse",{num .. retItem[1].name})
			if downLvStr~="" then
				downLvStr=downLvStr .. "\n" .. retStr
			else
				downLvStr=downLvStr .. retStr
			end
			-- G_addPlayerAward(retItem[1].type,retItem[1].key,retItem[1].id,retItem[1].num,nil,true,nil)
			G_showRewardTip(retItem,true)
		end

		self:showChangeNum(downLvStr,reduceLv)

		-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_smelt_success").."\n"..downLvStr,30,nil,nil,nil,G_ColorYellowPro)
	end
	accessoryVoApi:smelt(self.tankID,self.partID,self.data,self.useAmulet,callback)
end

function accessoryEquipDialogTabSmelt:stopNumAction( )
	self.bgLayer:stopAllActions()
	self.lvLb:stopAllActions()
	self.gsLb:stopAllActions()
	self.rankLb:stopAllActions()
	
	self.lvLb:setScale(1)
	self.gsLb:setScale(1)
	self.rankLb:setScale(1)
	if self.attTypeTb == nil then
		self.attTypeTb=self.data:getConfigData("attType")
	end
	for k,v in pairs(self.attTypeTb) do
		self.effectLbs[k]:stopAllActions()
		self.effectLbs[k]:setScale(1)
	end
end

function accessoryEquipDialogTabSmelt:showChangeNum(showLvStr,reduceLv)
	self:stopNumAction()
	print("in showChangeNum----reduceLv,self.oldReduceLv,self.useAmulet-->",reduceLv,self.oldReduceLv,self.useAmulet)
	if reduceLv and self.oldReduceLv ~= reduceLv and (self.useAmulet ==false or self.useAmulet ==nil) then
		self.oldReduceLv = reduceLv
		G_showNumberScaleByAction(self.lvLb,0.15,1.2)
	end
	G_showNumberScaleByAction(self.gsLb,0.15,1.2)
	G_showNumberScaleByAction(self.rankLb,0.15,1.2)

	for k,v in pairs(self.attTypeTb) do
		G_showNumberScaleByAction(self.effectLbs[k],0.15,1.2)
	end
	local function callbackToShow( )
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_smelt_success").."\n"..showLvStr,30,nil,nil,nil,G_ColorYellowPro)
	end
	local callFunc=CCCallFunc:create(callbackToShow)
	local delay=CCDelayTime:create(0.8)
	local acArr=CCArray:create()
	acArr:addObject(delay)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.bgLayer:runAction(seq)
	
end

function accessoryEquipDialogTabSmelt:refresh()
	self.data=accessoryVoApi:getAccessoryByPart(self.tankID,self.partID)
	self.rankLb1:setString(self.data.rank)
	self.lvLb1:setString(getlocal("fightLevel",{self.data.lv}))
	if(self.techLb)then
		self.techLb:setString(self.data.techLv or 0)
	end
	if(accessoryVoApi:getSmeltProp()<accessoryVoApi:getSmeltAmuletNum(self.data))then
		self.useAmulet=false
		self.checkBoxFrameChecked:setPositionX(999333)
		self.checkBoxFrameChecked:setVisible(false)
		self.checkBoxFrameUnchecked:setPositionX(G_VisibleSizeWidth - 70)
		self.checkBoxFrameUnchecked:setVisible(true)
	end

	local reduceLv
	if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
		reduceLv=0
	elseif(self.useAmulet)then
		reduceLv=0
	else
		if(accessoryCfg.smeltReduceLv>self.data.lv)then
			reduceLv=self.data.lv
		else
			reduceLv=accessoryCfg.smeltReduceLv
		end
	end
	if(reduceLv>0)then
		self.upLb2:setVisible(true)
	else
		self.upLb2:setVisible(false)
	end		

	self.attTb=self.data:getAttWithSuccinct()
	self.nextLvAttTb=self.data:getAttByLvAndRank(self.data.lv - reduceLv,self.data.rank + 1)
	self.differenceTb={}
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v - self.attTb[k]
	end
	self.attTypeTb=self.data:getConfigData("attType")
	self.attEffectTb=accessoryCfg.attEffect

	self.lvLb:setString(self.data.lv)
    self.upLb2:setString("    ↓ -"..reduceLv)

    local smeltMaxRank=accessoryVoApi:getSmeltMaxRank(self.data:getConfigData("quality"))
    local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(self.data.type, self.data.promoteLv)
    if upperLimitTb and upperLimitTb[2] then
        smeltMaxRank = smeltMaxRank + upperLimitTb[2]
    end
	self.tipLb:setString(getlocal("accessory_smelt_amulet_desc",{accessoryVoApi:getSmeltAmuletNum(self.data)}))
	self.rankLb:setString(self.data.rank)
	if(self.data.rank>=smeltMaxRank)then
		local maxUpgradeLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
		if upperLimitTb and upperLimitTb[1] then
			maxUpgradeLv = maxUpgradeLv + upperLimitTb[1]
		end
		if(self.data.lv>=maxUpgradeLv)then
			self.upLb2:setString(" "..getlocal("donatePointMax"))
			self.upLb2:setPositionX(self.lvLb:getPositionX()+self.lvLb:getContentSize().width)
			self.upLb2:setColor(G_ColorYellowPro)
		else
			self.upLb2:setVisible(false)
		end
		self.upLb1:setString(" "..getlocal("donatePointMax"))
		self.upLb1:setPositionX(self.rankLb:getPositionX()+self.rankLb:getContentSize().width)
		self.upLb1:setColor(G_ColorYellowPro)

		self.amuletLb:setVisible(false)
		self.smeltItem:setEnabled(false)
		self.tipLb:setString(getlocal("accessory_rank_max"))
	end

	for k,v in pairs(self.attTypeTb) do
		local effectStr
		local diffrenceStr
		if(self.attEffectTb[v]==1)then
			effectStr=string.format("%.2f",self.attTb[v]).."%"
			diffrenceStr=string.format("%.2f",self.differenceTb[v]).."%"
		else
			effectStr=self.attTb[v]
			diffrenceStr=self.differenceTb[v]
		end
		self.effectLbs[k]:setString(effectStr)

        self.attLbs[k]:setString("    ↑ +"..diffrenceStr)
		self.attLbs[k]:setPositionX(self.effectLbs[k]:getPositionX()+self.effectLbs[k]:getContentSize().width)
		if(self.data.rank>=smeltMaxRank)then
			self.attLbs[k]:setVisible(false)
		end
	end
	local oldGs=self.data:getGS()
	self.gsLb:setString(oldGs)
	if(self.data.rank>=smeltMaxRank)then
		self.gsUpLb:setString("")
		self.gsUpLb:setColor(G_ColorYellowPro)
	else
		local newGs=self.data:getGS(self.data.lv - reduceLv,self.data.rank + 1)
		self.gsUpLb:setString("    ↑ +"..(newGs - oldGs))
	end

	self.needPropNumTb=accessoryVoApi:getSmeltPropNum(self.data)
	for i=1,4 do
		if(self.data.rank>=smeltMaxRank)then
			self.propLbs[i]:setString(getlocal("donatePointMax"))
		else
			local has=accessoryVoApi:getPropNums()["p"..i] or 0
			self.propLbs[i]:setString(FormatNumber(has).." / "..FormatNumber(self.needPropNumTb["p"..i]))
			if(has<self.needPropNumTb["p"..i])then
				self.propLbs[i]:setColor(G_ColorRed)
			end
		end
	end
	self.amuletLb:setString(FormatNumber(accessoryVoApi:getSmeltProp()).." / "..FormatNumber(accessoryVoApi:getSmeltAmuletNum(self.data)))
	if(accessoryVoApi:getSmeltProp()>=accessoryVoApi:getSmeltAmuletNum(self.data))then
		self.amuletLb:setColor(G_ColorGreen)
	else
		self.amuletLb:setColor(G_ColorRed)
	end
end

function accessoryEquipDialogTabSmelt:showPropSourceDialog(id)
	accessoryVoApi:showSourceDialog(3,id,self.layerNum+1)
end

function accessoryEquipDialogTabSmelt:dispose()
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
	self.bgLayer=nil
	self.layerNum=nil
end