accessoryEquipDialogTab2={}

function accessoryEquipDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil

	self.useAmulet=false

	return nc
end

function accessoryEquipDialogTab2:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	local posX,posY=self:initUp()
	posX,posY=self:initCenter(posX,posY)
	self:initDown(posX,posY)
	return self.bgLayer
end

function accessoryEquipDialogTab2:initUp()
	local icon=accessoryVoApi:getAccessoryIcon(self.parent.aVo.type,70,100,nil)
	icon:setAnchorPoint(ccp(0,1))
	icon:setPosition(50,self.bgLayer:getContentSize().height-190)
	self.bgLayer:addChild(icon)

	local nameLb=GetTTFLabelWrap(getlocal(self.parent.aVo:getConfigData("name")),25,CCSizeMake(icon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX+icon:getContentSize().width/2,posY-icon:getContentSize().height)
	self.bgLayer:addChild(nameLb)

	local reduceLv
	if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
		reduceLv=0
	elseif(accessoryCfg.smeltReduceLv>self.parent.aVo.lv)then
		reduceLv=self.parent.aVo.lv
	else
		reduceLv=accessoryCfg.smeltReduceLv
	end
	self.attTb=self.parent.aVo:getAtt()
	self.nextLvAttTb=self.parent.aVo:getAttByLvAndRank(self.parent.aVo.lv-reduceLv,self.parent.aVo.rank+1)
	self.differenceTb={}
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v-self.attTb[k]
	end
	self.attTypeTb=self.parent.aVo:getConfigData("attType")
	self.attEffectTb=accessoryCfg.attEffect
	
	posX,posY=200,self.bgLayer:getContentSize().height-215
	self.rankLb=GetTTFLabel(getlocal("accessory_rank",{self.parent.aVo.rank}),25)
	self.rankLb:setAnchorPoint(ccp(0,0))
	self.rankLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.rankLb)

    self.upLb1=GetTTFLabel("    ↑ +1",25)
	self.upLb1:setAnchorPoint(ccp(0,0))
	self.upLb1:setColor(G_ColorGreen)
	self.upLb1:setPosition(posX+self.rankLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb1)

	posY=posY-35
	self.lvLb=GetTTFLabel(getlocal("accessory_lv",{self.parent.aVo.lv}),25)
	self.lvLb:setAnchorPoint(ccp(0,0))
	self.lvLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.lvLb)
	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}).." ("..getlocal("donatePointMax")..")")
	end

    self.upLb2=GetTTFLabel("    ↓ -"..reduceLv,25)
	self.upLb2:setAnchorPoint(ccp(0,0))
	self.upLb2:setColor(G_ColorRed)
	self.upLb2:setPosition(posX+self.lvLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb2)
	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		self.upLb1:setVisible(false)
		self.upLb2:setVisible(false)
		self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}).." ("..getlocal("donatePointMax")..")")
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
			effectStr=string.format("%.2f",self.attTb[k]).."%%"
			diffrenceStr=string.format("%.2f",self.differenceTb[k]).."%"
		else
			effectStr=self.attTb[k]
			diffrenceStr=self.differenceTb[k]
		end
		local attLb=GetTTFLabel(getlocal("accessory_attAdd_"..v,{effectStr}),25)
		attLb:setAnchorPoint(ccp(0,0))
		attLb:setPosition(posX,posY)
		self.bgLayer:addChild(attLb)
		self.effectLbs[k]=attLb

        local upLbTmp=GetTTFLabel("    ↑ +"..diffrenceStr,25)
		upLbTmp:setColor(G_ColorGreen)
		upLbTmp:setAnchorPoint(ccp(0,0))
		upLbTmp:setPosition(posX+attLb:getContentSize().width,posY)
		self.attLbs[k]=upLbTmp
		self.bgLayer:addChild(upLbTmp)
		if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
			upLbTmp:setVisible(false)
		end
	end

	posY=posY-32
	self.gsLb=GetTTFLabel(getlocal("accessory_gsAdd",{self.parent.aVo:getGS()}),28)
	self.gsLb:setColor(G_ColorGreen)
	self.gsLb:setAnchorPoint(ccp(0,0))
	self.gsLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.gsLb)

	local tmpY=nameLb:getPositionY()-20
	if(tmpY<posY)then
		posY=tmpY
	end
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2,posY-30)
	lineSp:setScaleY(3)
	lineSp:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp:getContentSize().width)
	self.bgLayer:addChild(lineSp)

	return lineSp:getPosition()
end

function accessoryEquipDialogTab2:initCenter(posX,posY)
	posX=200
	posY=posY-20
	self.needPropNumTb=accessoryVoApi:getSmeltPropNum(self.parent.aVo)
	self.propLbs={}
	for i=1,3 do
		local function onClickPropIcon(object,fn,tag)
			local id=tag-518
			self:showPropSourceDialog(id)
		end
		local icon=GetBgIcon(accessoryCfg.propCfg["p"..i].icon,onClickPropIcon,nil,80,80)
		icon:setTag(518+i)
		icon:setAnchorPoint(ccp(0,0))
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(100-40,posY-icon:getContentSize().height-10)
		self.bgLayer:addChild(icon)
		posY=icon:getPositionY()

		local propNameLb=GetTTFLabel(getlocal(accessoryCfg.propCfg["p"..i].name),25)
		propNameLb:setAnchorPoint(ccp(0,1))
		propNameLb:setPosition(posX,posY+70)
		propNameLb:setColor(G_ColorGreen)
		self.bgLayer:addChild(propNameLb)

		local str
		if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
			str=getlocal("accessory_rank_max")
		else
			str=getlocal("propOwned").." "..accessoryVoApi:getPropNums()["p"..i].."/"..getlocal("donateRequest").." "..self.needPropNumTb["p"..i]
		end

		local propNumLb=GetTTFLabel(str,25)
		if(accessoryVoApi:getPropNums()["p"..i]<self.needPropNumTb["p"..i])then
			propNumLb:setColor(G_ColorRed)
		end
		propNumLb:setAnchorPoint(ccp(0,1))
		propNumLb:setPosition(posX,posY+40)
		self.bgLayer:addChild(propNumLb)
		self.propLbs[i]=propNumLb
	end
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2,posY-20)
	lineSp:setScaleY(3)
	lineSp:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp:getContentSize().width)
	self.bgLayer:addChild(lineSp)
	return lineSp:getPosition()
end

function accessoryEquipDialogTab2:initDown(posX,posY)
	local function onClickCheckBox(object,name,tag)
		if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_accessoryEvolution_propNotNeed"),30)
			do return end
		end
		if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
			do return end
		end
		if(tag==824)then
			self.useAmulet=false
			self.checkBoxFrameChecked:setPositionX(999333)
			self.checkBoxFrameChecked:setVisible(false)
			self.checkBoxFrameUnchecked:setPositionX(145)
			self.checkBoxFrameUnchecked:setVisible(true)
		else
			if(accessoryVoApi:getSmeltProp()>=accessoryVoApi:getSmeltAmuletNum(self.parent.aVo))then
				self.useAmulet=true
				self.checkBoxFrameChecked:setPositionX(145)
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
	icon:setAnchorPoint(ccp(0,1))
	icon:setPosition(100-40,posY-20)
	self.bgLayer:addChild(icon)

	self.checkBoxFrameUnchecked=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClickCheckBox)
	self.checkBoxFrameUnchecked:setAnchorPoint(ccp(0,1))
	self.checkBoxFrameUnchecked:setTouchPriority(-(self.layerNum-1)*20-4)
	self.checkBoxFrameUnchecked:setPosition(145,posY-30)
	self.checkBoxFrameUnchecked:setTag(823)
	self.bgLayer:addChild(self.checkBoxFrameUnchecked)
	self.checkBoxFrameChecked=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",onClickCheckBox)
	self.checkBoxFrameChecked:setAnchorPoint(ccp(0,1))
	self.checkBoxFrameChecked:setTouchPriority(-(self.layerNum-1)*20-4)
	self.checkBoxFrameChecked:setPosition(999333,posY-30)
	self.checkBoxFrameChecked:setTag(824)
	self.bgLayer:addChild(self.checkBoxFrameChecked)

	self.needLb=GetTTFLabel(getlocal("accessory_need_smelt_amulet_num",{accessoryVoApi:getSmeltAmuletNum(self.parent.aVo)}),25)
	self.needLb:setAnchorPoint(ccp(0,1))
	self.needLb:setPosition(200,posY-25)
	self.needLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(self.needLb)

	self.ownLb=GetTTFLabel(getlocal("ownedPropNum",{accessoryVoApi:getSmeltProp()}),25)
	self.ownLb:setAnchorPoint(ccp(0,1))
	self.ownLb:setPosition(200,posY-55)
	self.bgLayer:addChild(self.ownLb)

	local tipLb=GetTTFLabelWrap(getlocal("accessory_smelt_amulet_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	tipLb:setAnchorPoint(ccp(0,1))
	tipLb:setPosition(60,posY-105)
	tipLb:setColor(G_ColorRed)
	self.bgLayer:addChild(tipLb)
	posY=posY-110

	local tmpStr
	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		tmpStr=""
	else
		tmpStr=getlocal("accessory_smelt_p4_owned",{FormatNumber(accessoryVoApi:getPropNums()["p4"])}).." / "..getlocal("accessory_smelt_p4_need",{FormatNumber(self.needPropNumTb.p4)})
	end

	local textSize = 28
	if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
		textSize=23
	end
	self.prop4Lb=GetTTFLabelWrap(tmpStr,textSize,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.prop4Lb:setAnchorPoint(ccp(0.5,1))
	if(accessoryVoApi:getPropNums()["p4"]>=self.needPropNumTb.p4)then
		self.prop4Lb:setColor(G_ColorGreen)
	else
		self.prop4Lb:setColor(G_ColorRed)
	end
	self.prop4Lb:setPosition(self.bgLayer:getContentSize().width/2,posY-tipLb:getContentSize().height+5)
	self.bgLayer:addChild(self.prop4Lb)

	local function onClick(tag,object)
		PlayEffect(audioCfg.mouseClick)
		self:smelt()
	end
	self.smeltItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,nil,getlocal("smelt"),28)
	self.smeltItem:setAnchorPoint(ccp(0.5,0))
	local smeltBtn=CCMenu:createWithItem(self.smeltItem)
	smeltBtn:setAnchorPoint(ccp(0.5,0))
	local btnY
	if(G_isIphone5())then
		btnY=75
	else
		btnY=30
	end
	smeltBtn:setPosition(self.bgLayer:getContentSize().width/2,btnY)
	smeltBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	if(accessoryVoApi:checkCanSmelt(self.parent.tankID,self.parent.partID,self.parent.aVo)==3)then
		self.smeltItem:setEnabled(false)
	end
	self.bgLayer:addChild(smeltBtn)
end

function accessoryEquipDialogTab2:refreshAttLbs()
	local reduceLv
	if(self.useAmulet)then		
		reduceLv=0
	else		
		if(accessoryCfg.smeltReduceLv>self.parent.aVo.lv)then
			reduceLv=self.parent.aVo.lv
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
	self.nextLvAttTb=self.parent.aVo:getAttByLvAndRank(self.parent.aVo.lv-reduceLv,self.parent.aVo.rank+1)
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v-self.attTb[k]
	end
	for k,v in pairs(self.attLbs) do
		local diffrenceStr
		if(self.attEffectTb[tonumber(self.attTypeTb[k])]==1)then
			diffrenceStr=string.format("%.2f",self.differenceTb[k]).."%"
		else
			diffrenceStr=self.differenceTb[k]
		end
        v:setString("    ↑ +"..diffrenceStr)
	end
end

function accessoryEquipDialogTab2:smelt()
	local canSmelt=accessoryVoApi:checkCanSmelt(self.parent.tankID,self.parent.partID,self.parent.aVo)
	if(canSmelt==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("data_error_need_reopen"),30)
		do return end
	elseif(canSmelt>20 and canSmelt<30)then
		local rank=self.parent.aVo.rank
		local needTb=accessoryCfg["smeltPropNum"..self.parent.aVo:getConfigData("quality")][rank+1]
		local notEnoughTb={}
		for i=1,4 do
			local has=accessoryVoApi:getPropNums()["p"..i]
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
	local function callback(result)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_smelt_success"),30)
		self:refresh()
		self.parent.needRefresh=true
	end
	accessoryVoApi:smelt(self.parent.tankID,self.parent.partID,self.parent.aVo,self.useAmulet,callback)
end

function accessoryEquipDialogTab2:refresh()

	if(accessoryVoApi:getSmeltProp()<accessoryVoApi:getSmeltAmuletNum(self.parent.aVo))then
		self.useAmulet=false
		self.checkBoxFrameChecked:setPositionX(999333)
		self.checkBoxFrameChecked:setVisible(false)
		self.checkBoxFrameUnchecked:setPositionX(145)
		self.checkBoxFrameUnchecked:setVisible(true)
	end

	local reduceLv
	if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
		reduceLv=0
	elseif(self.useAmulet)then
		reduceLv=0
	else
		if(accessoryCfg.smeltReduceLv>self.parent.aVo.lv)then
			reduceLv=self.parent.aVo.lv
		else
			reduceLv=accessoryCfg.smeltReduceLv
		end
	end
	if(reduceLv>0)then
		self.upLb2:setVisible(true)
	else
		self.upLb2:setVisible(false)
	end		

	self.attTb=self.parent.aVo:getAtt()
	self.nextLvAttTb=self.parent.aVo:getAttByLvAndRank(self.parent.aVo.lv-reduceLv,self.parent.aVo.rank+1)
	self.differenceTb={}
	for k,v in pairs(self.nextLvAttTb) do
		self.differenceTb[k]=v-self.attTb[k]
	end
	self.attTypeTb=self.parent.aVo:getConfigData("attType")
	self.attEffectTb=accessoryCfg.attEffect

	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}).." ("..getlocal("donatePointMax")..")")
	else
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}))
	end
    self.upLb2:setString("    ↓ -"..reduceLv)

	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		self.upLb1:setVisible(false)
		self.upLb2:setVisible(false)
		self.needLb:setVisible(false)
		self.ownLb:setVisible(false)
		self.smeltItem:setEnabled(false)
		self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}).." ("..getlocal("donatePointMax")..")")
	else
		self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}))
	end

	for k,v in pairs(self.attTypeTb) do
		local effectStr
		local diffrenceStr
		if(self.attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",self.attTb[k]).."%%"
			diffrenceStr=string.format("%.2f",self.differenceTb[k]).."%"
		else
			effectStr=self.attTb[k]
			diffrenceStr=self.differenceTb[k]
		end
		self.effectLbs[k]:setString(getlocal("accessory_attAdd_"..v,{effectStr}))

        self.attLbs[k]:setString("    ↑ +"..diffrenceStr)
		self.attLbs[k]:setPositionX(self.effectLbs[k]:getPositionX()+self.effectLbs[k]:getContentSize().width)
		if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
			self.attLbs[k]:setVisible(false)
		end
	end
	self.gsLb:setString(getlocal("accessory_gsAdd",{self.parent.aVo:getGS()}))

	self.needPropNumTb=accessoryVoApi:getSmeltPropNum(self.parent.aVo)
	for i=1,3 do
		if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
			self.propLbs[i]:setString(getlocal("accessory_rank_max"))
		else
			self.propLbs[i]:setString(getlocal("propOwned").." "..accessoryVoApi:getPropNums()["p"..i].."/"..getlocal("donateRequest").." "..self.needPropNumTb["p"..i])
			if(accessoryVoApi:getPropNums()["p"..i]<self.needPropNumTb["p"..i])then
				self.propLbs[i]:setColor(G_ColorRed)
			end
		end
	end

	self.needLb:setString(getlocal("accessory_need_smelt_amulet_num",{accessoryVoApi:getSmeltAmuletNum(self.parent.aVo)}))
	self.ownLb:setString(getlocal("ownedPropNum",{accessoryVoApi:getSmeltProp()}))
	local tmpStr
	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		tmpStr=""
	else
		tmpStr=getlocal("accessory_smelt_p4_owned",{FormatNumber(accessoryVoApi:getPropNums()["p4"])}).." / "..getlocal("accessory_smelt_p4_need",{FormatNumber(self.needPropNumTb.p4)})
	end
	self.prop4Lb:setString(tmpStr)
	if(accessoryVoApi:getPropNums()["p4"]>=self.needPropNumTb.p4)then
		self.prop4Lb:setColor(G_ColorGreen)
	else
		self.prop4Lb:setColor(G_ColorRed)
	end
end

function accessoryEquipDialogTab2:showPropSourceDialog(id)
	accessoryVoApi:showSourceDialog(3,id,self.layerNum+1)
end

function accessoryEquipDialogTab2:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil

	self=nil
end



