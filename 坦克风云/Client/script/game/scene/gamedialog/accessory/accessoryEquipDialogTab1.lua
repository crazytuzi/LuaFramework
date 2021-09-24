accessoryEquipDialogTab1={}

function accessoryEquipDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil

	return nc
end

function accessoryEquipDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent

	local function nilFun()
	end

	local icon=accessoryVoApi:getAccessoryIcon(self.parent.aVo.type,70,100,nil)
	icon:setAnchorPoint(ccp(0,1))
	icon:setPosition(50,self.bgLayer:getContentSize().height-190)
	self.bgLayer:addChild(icon)

	local nameLb=GetTTFLabelWrap(getlocal(self.parent.aVo:getConfigData("name")),25,CCSizeMake(icon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX+icon:getContentSize().width/2,posY-icon:getContentSize().height)
	self.bgLayer:addChild(nameLb)

	local attTb=self.parent.aVo:getAtt()
	local differenceTb=self.parent.aVo:getConfigData("lvGrow")
	local attTypeTb=self.parent.aVo:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect
	
	posX,posY=200,self.bgLayer:getContentSize().height-215
	self.rankLb=GetTTFLabel(getlocal("accessory_rank",{self.parent.aVo.rank}),25)
	self.rankLb:setAnchorPoint(ccp(0,0))
	self.rankLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.rankLb)

	posY=posY-35
	self.lvLb=GetTTFLabel(getlocal("accessory_lv",{self.parent.aVo.lv}),25)
	self.lvLb:setAnchorPoint(ccp(0,0))
	self.lvLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.lvLb)

    self.upLb1=GetTTFLabel("    ↑ +1",25)
	self.upLb1:setAnchorPoint(ccp(0,0))
	self.upLb1:setColor(G_ColorGreen)
	self.upLb1:setPosition(posX+self.lvLb:getContentSize().width,posY)
	self.bgLayer:addChild(self.upLb1)
	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		self.upLb1:setVisible(false)
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}).." ("..getlocal("donatePointMax")..")")
	end
	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}).." ("..getlocal("donatePointMax")..")")
	end
	self.attLbTb={}
	self.attUpLbTb={}

	for k,v in pairs(attTypeTb) do
		posY=posY-35
		local effectStr
		local diffrenceStr
		if(attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",attTb[k]).."%%"
			diffrenceStr=differenceTb[k].."%"
		else
			effectStr=attTb[k]
			diffrenceStr=differenceTb[k]
		end
		local attLb=GetTTFLabel(getlocal("accessory_attAdd_"..v,{effectStr}),25)
		attLb:setAnchorPoint(ccp(0,0))
		attLb:setPosition(posX,posY)
		self.bgLayer:addChild(attLb)
		self.attLbTb[k]=attLb

        local upLbTmp=GetTTFLabel("    ↑ +"..diffrenceStr,25)
		upLbTmp:setColor(G_ColorGreen)
		upLbTmp:setAnchorPoint(ccp(0,0))
		upLbTmp:setPosition(posX+attLb:getContentSize().width,posY)
		self.bgLayer:addChild(upLbTmp)
		self.attUpLbTb[k]=upLbTmp
		if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
			upLbTmp:setVisible(false)
		end
	end

	posY=posY-35
	self.probabilityLb=GetTTFLabel(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)}),25)
	self.probabilityLb:setAnchorPoint(ccp(0,0))
	self.probabilityLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.probabilityLb)



--配件合成概率提高
	self:setRateAddLb(posX+self.probabilityLb:getContentSize().width+30,posY)
	--yuandanxianli
	local vo =activityVoApi:getActivityVo("yuandanxianli")
	if vo and activityVoApi:isStart(vo) then
		  local today = acYuandanxianliVoApi:isStrengToday()
		  if today==false then
			self.isToday = today
			acYuandanxianliVoApi:updateStrengTime()
			acYuandanxianliVoApi:refreshCurStreng()
		  end
		local basisAc = accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo) * acYuandanxianliVoApi:getAccessStreng()
		if G_getCurChoseLanguage() =="ru" then
			posX = posX-180
			posY = posY -30
		end
		self.acYuandanTb=GetTTFLabel("+"..basisAc.."%",25)
		self.acYuandanTb:setAnchorPoint(ccp(0,0))
		self.bgLayer:addChild(self.acYuandanTb)
		if acYuandanxianliVoApi:isCanStreng() then
			local rateWidth = nil
			if self.addRateLb ==nil then
				rateWidth =0 
			else 
				rateWidth = self.addRateLb:getContentSize().width
			end
			self.acYuandanTb:setPosition(posX+self.probabilityLb:getContentSize().width+rateWidth+40,posY)
			self.acYuandanTb:setColor(G_ColorRed)
		end
	end

	posY=posY-40
	self.gsLb=GetTTFLabel(getlocal("accessory_gsAdd",{self.parent.aVo:getGS()}),28)
	self.gsLb:setColor(G_ColorGreen)
	self.gsLb:setAnchorPoint(ccp(0,0))
	self.gsLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.gsLb)

	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2,posY-60)
	lineSp:setScaleY(3)
	lineSp:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp:getContentSize().width)
	self.bgLayer:addChild(lineSp)
	posY=lineSp:getPositionY()

	local function onClickPropIcon()
		self:showPropSourceDialog()
	end
	icon=GetBgIcon(accessoryCfg.propCfg.p6.icon,onClickPropIcon,nil,80,80)
	icon:setTouchPriority(-(self.layerNum-1)*20-4)
	icon:setAnchorPoint(ccp(0,1))
	icon:setPosition(100,posY-50)
	self.bgLayer:addChild(icon)

	posX=400
	posY=posY-60
	self.amuletLb=GetTTFLabel(getlocal("accessory_upgrade_amulet_num",{accessoryVoApi:getUpgradeProp()}),25)
	self.amuletLb:setAnchorPoint(ccp(0.5,0))
	self.amuletLb:setPosition(posX,posY)
	self.bgLayer:addChild(self.amuletLb)

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
				if strNum>=0 and strNum<=self.maxAmuletNum then
					self.lastNumValue=str
				else
					if(strNum<0)then
						eB:setText("0")
						self.lastNumValue="0"
					elseif strNum>self.maxAmuletNum then
						eB:setText(self.maxAmuletNum)
						self.lastNumValue=tostring(self.maxAmuletNum)
					end
				end
			end
			self.numShowLb:setString(self.lastNumValue)
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			self.numShowLb:setString(self.lastNumValue)
			self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,tonumber(self.lastNumValue),self.parent.aVo)}))
			self:setRateAddLb()
		end
	end
	self.lastNumValue="0"
	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		print("∑∑1")
		self.maxAmuletNum=0
	else
		local tmp=math.ceil((100-accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo))/accessoryCfg.amuletProbality)
		--vip合成几率加成
		local addRate=accessoryVoApi:getVipUpgradeAddRate()
		if addRate>0 then
			local basePercent=accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)
			local percent=basePercent*1+math.ceil(basePercent*addRate)
			if percent>100 then
				percent=100
			end
			tmp=math.ceil((100-percent)/accessoryCfg.amuletProbality)
			print("∑∑2",tmp)
		end

		if(tmp>accessoryVoApi:getUpgradeProp())then
			print("∑∑accessoryVoApi:getUpgradeProp()",accessoryVoApi:getUpgradeProp())
			self.maxAmuletNum=accessoryVoApi:getUpgradeProp()
		else
			print("∑∑3")
			self.maxAmuletNum=tmp
		end
	end
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

	local function onDecrease()
		PlayEffect(audioCfg.mouseClick)
		local num=tonumber(self.lastNumValue)
		if(num>0)then
			num=num-1
			self.lastNumValue=tostring(num)
			self.numShowLb:setString(self.lastNumValue)
			numEditBox:setText(self.lastNumValue)
			self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,tonumber(self.lastNumValue),self.parent.aVo)}))
			self:setRateAddLb()
		end
	end
	local decreaseItem=GetButtonItem("lessBtn.png","lessBtn.png","lessBtn.png",onDecrease,nil,nil,28)
	local decreaseBtn=CCMenu:createWithItem(decreaseItem)
	decreaseBtn:setPosition(posX-120,posY-45)
	decreaseBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(decreaseBtn)

	local function onIcrease()
		PlayEffect(audioCfg.mouseClick)
		local num=tonumber(self.lastNumValue)
		if(num<self.maxAmuletNum)then
			num=num+1
			self.lastNumValue=tostring(num)
			self.numShowLb:setString(self.lastNumValue)
			numEditBox:setText(self.lastNumValue)
			self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,tonumber(self.lastNumValue),self.parent.aVo)}))
			self:setRateAddLb()
		else
			local addRate=accessoryVoApi:getVipUpgradeAddRate()
			local addPercent=math.ceil(accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)*addRate)
			if((accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,tonumber(self.lastNumValue),self.parent.aVo)+addPercent)<100)then
				self:showPropSourceDialog()
			end
		end
	end
	local increaseItem=GetButtonItem("moreBtn.png","moreBtn.png","moreBtn.png",onIcrease,nil,nil,28)
	local increaseBtn=CCMenu:createWithItem(increaseItem)
	increaseBtn:setPosition(posX+120,posY-45)
	increaseBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(increaseBtn)

	posY=posY-100
	local resourceStr
	local partID=tonumber(self.parent.aVo:getConfigData("part"))
	local needResource=accessoryCfg["upgradeResource"..self.parent.aVo:getConfigData("quality")][partID][self.parent.aVo.lv+1]
	if(needResource~=nil)then
		needResource=needResource.gold
		resourceStr=getlocal("accessory_upgrade_resource_owned",{FormatNumber(playerVoApi:getGold())}).." / "..getlocal("accessory_upgrade_resource_need",{FormatNumber(needResource)})
	else
		needResource=0
		resourceStr=getlocal("alliance_lvmax")
	end
	self.resourceLb=GetTTFLabelWrap(resourceStr,28,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	if(tonumber(needResource)>playerVoApi:getGold())then
		self.resourceLb:setColor(G_ColorRed)
	else
		self.resourceLb:setColor(G_ColorGreen)
	end
	self.resourceLb:setAnchorPoint(ccp(0.5,1))
	self.resourceLb:setPosition(self.bgLayer:getContentSize().width/2,posY)
	self.bgLayer:addChild(self.resourceLb)

	local function onClick(tag,object)
		PlayEffect(audioCfg.mouseClick)
		self:upgrade()
	end
	self.upgradeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,nil,getlocal("upgrade"),28)
	self.upgradeItem:setAnchorPoint(ccp(0.5,0))
	local upgradeBtn=CCMenu:createWithItem(self.upgradeItem)
	upgradeBtn:setAnchorPoint(ccp(0.5,0))
	local btnY
	if(G_isIphone5())then
		btnY=75
	else
		btnY=30
	end
	upgradeBtn:setPosition(self.bgLayer:getContentSize().width/2,btnY)
	upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(upgradeBtn)
	if(accessoryVoApi:checkCanUpgrade(self.parent.tankID,self.parent.partID,self.parent.aVo)==4)then
		self.upgradeItem:setEnabled(false)
	end
	return self.bgLayer
end

function accessoryEquipDialogTab1:upgrade()
	local canUpgrade=accessoryVoApi:checkCanUpgrade(self.parent.tankID,self.parent.partID,self.parent.aVo)
	if(canUpgrade==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("data_error_need_reopen"),30)
		do return end
	elseif(canUpgrade==4)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_lvmax"),30)
		do return end
	elseif(canUpgrade==3)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_lv_not_enough"),30)
		do return end
	elseif(canUpgrade==2)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
		do return end
	end
	local function callback(result)
		if(result==true)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success"),30)
			self.parent.needRefresh=true
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_fail"),30)
		end
		local vo = activityVoApi:getActivityVo("yuandanxianli")
		if vo and activityVoApi:isStart(vo)== true then
			if acYuandanxianliVoApi:isCanStreng() then
				acYuandanxianliVoApi:setCurStreng()	   --yuandanxianli
			end
		end
		self:refresh()
	end
	accessoryVoApi:upgrade(self.parent.tankID,self.parent.partID,self.parent.aVo,tonumber(self.lastNumValue),callback)
end

function accessoryEquipDialogTab1:refresh()
	local attTb=self.parent.aVo:getAtt()
	local differenceTb=self.parent.aVo:getConfigData("lvGrow")
	local attTypeTb=self.parent.aVo:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect
	
	self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}))
	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		self.upLb1:setVisible(false)
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}).." ("..getlocal("donatePointMax")..")")
	else
		self.lvLb:setString(getlocal("accessory_lv",{self.parent.aVo.lv}))
	end
	if(self.parent.aVo.rank>=accessoryCfg.smeltMaxRank)then
		self.rankLb:setString(getlocal("accessory_rank",{self.parent.aVo.rank}).." ("..getlocal("donatePointMax")..")")
	end

	for k,v in pairs(attTypeTb) do
		local effectStr
		local diffrenceStr
		if(attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",attTb[k]).."%%"
			diffrenceStr=differenceTb[k].."%"
		else
			effectStr=attTb[k]
			diffrenceStr=differenceTb[k]
		end
		self.attLbTb[k]:setString(getlocal("accessory_attAdd_"..v,{effectStr}))
        self.attUpLbTb[k]:setString("    ↑ +"..diffrenceStr)
		self.attUpLbTb[k]:setPositionX(self.attLbTb[k]:getPositionX()+self.attLbTb[k]:getContentSize().width)
		if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
			self.attUpLbTb[k]:setVisible(false)
		end
	end

	self.probabilityLb:setString(getlocal("tip_succeedRate",{accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)}))
	
	
	local vo = activityVoApi:getActivityVo("yuandanxianli")
	if vo and activityVoApi:isStart(vo)== true then
		if acYuandanxianliVoApi:isCanStreng() then
			local basisAc = accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo) * acYuandanxianliVoApi:getAccessStreng()
			self.acYuandanTb:setString("+"..basisAc.."%")
		else
			self.acYuandanTb:setVisible(false)
		end
   end

	self:setRateAddLb()
	self.gsLb:setString(getlocal("accessory_gsAdd",{self.parent.aVo:getGS()}))
	self.amuletLb:setString(getlocal("accessory_upgrade_amulet_num",{accessoryVoApi:getUpgradeProp()}))

	self.lastNumValue="0"
	self.numShowLb:setString("0")

	if(self.parent.aVo.lv>=playerVoApi:getMaxLvByKey("roleMaxLevel"))then
		self.maxAmuletNum=0
	else
		local tmp=math.ceil((100-accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo))/accessoryCfg.amuletProbality)
		--vip合成几率加成
		local addRate=accessoryVoApi:getVipUpgradeAddRate()
		if addRate>0 then
			local basePercent=accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)
			local percent=basePercent*1+math.ceil(basePercent*addRate)
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

	local resourceStr
	local partID=tonumber(self.parent.aVo:getConfigData("part"))
	local needResource=accessoryCfg["upgradeResource"..self.parent.aVo:getConfigData("quality")][partID][self.parent.aVo.lv+1]
	if(needResource~=nil)then
		needResource=needResource.gold
		resourceStr=getlocal("accessory_upgrade_resource_owned",{FormatNumber(playerVoApi:getGold())}).." / "..getlocal("accessory_upgrade_resource_need",{FormatNumber(needResource)})
	else
		resourceStr=getlocal("alliance_lvmax")
		needResource=0
	end
	self.resourceLb:setString(resourceStr)
	if(tonumber(needResource)>playerVoApi:getGold())then
		self.resourceLb:setColor(G_ColorRed)
	else
		self.resourceLb:setColor(G_ColorGreen)
	end

	if(accessoryVoApi:checkCanUpgrade(self.parent.tankID,self.parent.partID,self.parent.aVo)==4)then
		self.upgradeItem:setEnabled(false)
	else
		self.upgradeItem:setEnabled(true)
	end
end

function accessoryEquipDialogTab1:setRateAddLb(posX,posY)
	--配件合成概率提高
	local addRate=accessoryVoApi:getVipUpgradeAddRate()
	if self.probabilityLb and addRate>0 then
		local addRateStr="+"..math.ceil(accessoryVoApi:getUpgradeProbability(self.parent.tankID,self.parent.partID,0,self.parent.aVo)*addRate).."%"
		if self.addRateLb==nil then
			self.addRateLb=GetTTFLabel(addRateStr,25)
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

function accessoryEquipDialogTab1:showPropSourceDialog()
	accessoryVoApi:showSourceDialog(3,6,self.layerNum+1)
end

function accessoryEquipDialogTab1:dispose()
	self.probabilityLb=nil
	self.numShowLb=nil
	self.lastNumValue=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.parent=nil
	self.maxAmuletNum=nil

	self=nil
end



