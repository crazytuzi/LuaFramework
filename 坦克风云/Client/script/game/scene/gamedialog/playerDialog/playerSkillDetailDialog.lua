--技能升级详情的面板
playerSkillDetailDialog=commonDialog:new()

function playerSkillDetailDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.data=data
	nc.targetLv=nil
	return nc
end

function playerSkillDetailDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)

	self.canUpgrade=skillVoApi:checkCanUpgrade(self.data.sid)
	self:initUp()
	if(self.canUpgrade~=3)then
		self:initDown()
	end
end

function playerSkillDetailDialog:initUp()
	local upBgSize
	if(self.canUpgrade~=3)then
		upBgSize=CCSizeMake(G_VisibleSizeWidth - 30,270)
	else
		upBgSize=CCSizeMake(G_VisibleSizeWidth - 30,G_VisibleSizeHeight - 125)
	end
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
	upBg:setTag(101)
	upBg:setContentSize(upBgSize)
	upBg:setAnchorPoint(ccp(0.5,1))
	upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 95)
	self.bgLayer:addChild(upBg)
	local upTitleSp=CCSprite:createWithSpriteFrameName("nbSkillTitle1.png")
	upTitleSp:setAnchorPoint(ccp(0.5,1))
	upTitleSp:setPosition(upBgSize.width/2,upBgSize.height)
	upBg:addChild(upTitleSp,1)
	local curBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	curBg:setPosition(upBgSize.width/2,upBgSize.height - 40)
	upBg:addChild(curBg)
	local curLb=GetTTFLabel(getlocal("current_attribute"),24)
	curLb:setColor(G_ColorYellowPro)
	curLb:setPosition(getCenterPoint(curBg))
	curBg:addChild(curLb)
	local skillIcon=skillVoApi:getSkillIconById(self.data.sid)
	skillIcon:setAnchorPoint(ccp(0,0.5))
	skillIcon:setPosition(20,upBgSize.height - 130)
	upBg:addChild(skillIcon)
	local nameStr=getlocal(skillVoApi:getSkillNameById(self.data.sid))
	if(self.data.lv>0)then
		nameStr=nameStr.." "..getlocal("fightLevel",{self.data.lv})
	end
	local nameFontSize,smallFontSize = 22,20
	local nameLb=GetTTFLabel(nameStr,nameFontSize,true)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(140,skillIcon:getPositionY()+skillIcon:getContentSize().height/2)
	upBg:addChild(nameLb)
	if(self.data.cfg.needTankType and self.data.cfg.needTankNum)then
		local tankStr
		if(self.data.cfg.needTankType==1)then
			tankStr=getlocal("tanke")
		elseif(self.data.cfg.needTankType==2)then
			tankStr=getlocal("jianjiche")
		elseif(self.data.cfg.needTankType==4)then
			tankStr=getlocal("zixinghuopao")
		else
			tankStr=getlocal("huojianche")
		end
		local conditionLb=GetTTFLabelWrap(getlocal("nbSkill_effectiveCondition",{self.data.cfg.needTankNum,tankStr}),smallFontSize,CCSizeMake(upBgSize.width - 155,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		conditionLb:setColor(G_ColorYellowPro)
		conditionLb:setAnchorPoint(ccp(0,1))
		conditionLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height-15)
		upBg:addChild(conditionLb)
	end
	local descLb
	if(self.data.lv>0)then
		local addValue1,addValue2=skillVoApi:getSkillAddPerStrById(self.data.sid)
		if(addValue1)then
			addValue1=string.gsub(addValue1,"%%","%%%%")
		end
		if(addValue2)then
			addValue2=string.gsub(addValue2,"%%","%%%%")
		end
		descLb=GetTTFLabelWrap(getlocal(self.data.cfg.description1,{addValue1,addValue2}),nameFontSize,CCSizeMake(upBgSize.width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	else
		descLb=GetTTFLabelWrap(getlocal("nbSkill_skillNotGet"),nameFontSize,CCSizeMake(upBgSize.width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	end
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(20,skillIcon:getPositionY()-skillIcon:getContentSize().height/2-15)
	upBg:addChild(descLb)
	if(self.canUpgrade==3)then
		local maxLb=GetTTFLabel(getlocal("alliance_lvmax"),24)
		maxLb:setColor(G_ColorGreen)
		maxLb:setPosition(upBgSize.width/2,descLb:getPositionY() - descLb:getContentSize().height - 50)
		upBg:addChild(maxLb)
	end
end

function playerSkillDetailDialog:initDown()
	local downBgSize=CCSizeMake(G_VisibleSizeWidth - 30,G_VisibleSizeHeight - 405)
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
	downBg:setTag(102)
	downBg:setContentSize(downBgSize)
	downBg:setAnchorPoint(ccp(0.5,0))
	downBg:setPosition(G_VisibleSizeWidth/2,25)
	self.bgLayer:addChild(downBg)
	local downTitleSp=CCSprite:createWithSpriteFrameName("nbSkillTitle2.png")
	downTitleSp:setAnchorPoint(ccp(0.5,1))
	downTitleSp:setPosition(downBgSize.width/2,downBgSize.height)
	downBg:addChild(downTitleSp,1)
	local nextBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	nextBg:setPosition(downBgSize.width/2,downBgSize.height - 40)
	downBg:addChild(nextBg)
	local nextLb=GetTTFLabel(getlocal("upgradeEffectStr"),24)
	nextLb:setColor(G_ColorYellowPro)
	nextLb:setPosition(getCenterPoint(nextBg))
	nextBg:addChild(nextLb)

	local nameFontSize,smallFontSize = 22,20
	local skillIcon=skillVoApi:getSkillIconById(self.data.sid)
	skillIcon:setAnchorPoint(ccp(0,0.5))
	skillIcon:setPosition(20,downBgSize.height - 130)
	downBg:addChild(skillIcon)
	self.nextNameLb=GetTTFLabel(getlocal(skillVoApi:getSkillNameById(self.data.sid)).." "..getlocal("fightLevel",{self.data.lv + 1}),nameFontSize,true)
	self.nextNameLb:setAnchorPoint(ccp(0,1))
	self.nextNameLb:setPosition(140,skillIcon:getPositionY()+skillIcon:getContentSize().height/2)
	downBg:addChild(self.nextNameLb)
	if(self.data.cfg.needTankType and self.data.cfg.needTankNum)then
		local tankStr
		if(self.data.cfg.needTankType==1)then
			tankStr=getlocal("tanke")
		elseif(self.data.cfg.needTankType==2)then
			tankStr=getlocal("jianjiche")
		elseif(self.data.cfg.needTankType==4)then
			tankStr=getlocal("zixinghuopao")
		else
			tankStr=getlocal("huojianche")
		end
		local conditionLb=GetTTFLabelWrap(getlocal("nbSkill_effectiveCondition",{self.data.cfg.needTankNum,tankStr}),smallFontSize,CCSizeMake(downBgSize.width - 155,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		conditionLb:setColor(G_ColorYellowPro)
		conditionLb:setAnchorPoint(ccp(0,1))
		conditionLb:setPosition(self.nextNameLb:getPositionX(),self.nextNameLb:getPositionY()-self.nextNameLb:getContentSize().height-15)
		downBg:addChild(conditionLb)
	end
	local addValue1,addValue2=skillVoApi:getSkillAddPerStrById(self.data.sid,self.data.lv + 1)
	if(addValue1)then
		addValue1=string.gsub(addValue1,"%%","%%%%")
	end
	if(addValue2)then
		addValue2=string.gsub(addValue2,"%%","%%%%")
	end
	self.nextDescLb=GetTTFLabelWrap(getlocal(self.data.cfg.description1,{addValue1,addValue2}),nameFontSize,CCSizeMake(downBgSize.width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.nextDescLb:setAnchorPoint(ccp(0,1))
	self.nextDescLb:setPosition(skillIcon:getPositionX(),skillIcon:getPositionY()-skillIcon:getContentSize().height/2-15)
	downBg:addChild(self.nextDescLb)
	local posY=self.nextDescLb:getPositionY() - self.nextDescLb:getContentSize().height - 20
	if(self.canUpgrade==0)then
		local costLb=GetTTFLabel(getlocal("heroUpgradeCost"),24)
		costLb:setColor(G_ColorGreen)
		costLb:setAnchorPoint(ccp(0,1))
		costLb:setPosition(ccp(30,posY))
		downBg:addChild(costLb)
		posY=posY - costLb:getContentSize().height - 10

		local upLv,upProp=skillVoApi:getSkillUpLv(self.data.sid)
		local propTb=FormatItem({p=upProp})
		local costLbTb={}
		local itemSize = 80
		for k,v in pairs(propTb) do
			local propIcon=G_getItemIcon(v,100,false)
			propIcon:setScale(itemSize/propIcon:getContentSize().width)
			propIcon:setAnchorPoint(ccp(0,0.5))
			propIcon:setPosition(30 + 280*(k - 1),posY - 50)
			downBg:addChild(propIcon)
			local propName=GetTTFLabelWrap(getlocal("vip_tequanlibao_geshihua",{v.name,FormatNumber(v.num)}),smallFontSize,CCSizeMake(190,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			propName:setAnchorPoint(ccp(0,0.5))
			propName:setPosition(115 + 280*(k - 1),posY - 30)
			downBg:addChild(propName)
			local ownLb=GetTTFLabel(getlocal("ownedPropNum",{FormatNumber(bagVoApi:getItemNumId(v.id))}),smallFontSize)
			ownLb:setAnchorPoint(ccp(0,0.5))
			ownLb:setPosition(115 + 280*(k - 1),posY - 70)
			downBg:addChild(ownLb)
			costLbTb[tonumber(v.id)]=propName
		end
		posY=posY - 90
		if(upLv>1)then
			local upLvBg=CCSprite:createWithSpriteFrameName("proBar_n2.png")
			upLvBg:setScaleX(80/upLvBg:getContentSize().width)
			upLvBg:setPosition(70,150)
			downBg:addChild(upLvBg)
			local upLvLb=GetTTFLabel(upLv,22)
			upLvLb:setPosition(70,150)
			downBg:addChild(upLvLb)
			local function sliderTouch(handler,object)
				local count = math.floor(object:getValue())
				upLvLb:setString(count)
				self.targetLv=count + self.data.lv
				local propTb={}
				for i=1,count do
					local lvRequireTb=skillVoApi:getPropRequireByIdAndLv(self.data.sid,self.data.lv + i)
					for pid,pNum in pairs(lvRequireTb) do
						if(propTb[pid]==nil)then
							propTb[pid]=pNum
						else
							propTb[pid]=propTb[pid] + pNum
						end
					end
				end
				for pid,pNum in pairs(propTb) do
					local pNumID=tonumber(RemoveFirstChar(pid))
					if(costLbTb[pNumID])then
						costLbTb[pNumID]:setString(getlocal("vip_tequanlibao_geshihua",{getlocal(propCfg[pid].name),FormatNumber(pNum)}))
					end
				end
				if(self.nextNameLb)then
					self.nextNameLb:setString(getlocal(skillVoApi:getSkillNameById(self.data.sid)).." "..getlocal("fightLevel",{self.targetLv}))
				end
				if(self.nextDescLb)then
					local addValue1,addValue2=skillVoApi:getSkillAddPerStrById(self.data.sid,self.targetLv)
					if(addValue1)then
						addValue1=string.gsub(addValue1,"%%","%%%%")
					end
					if(addValue2)then
						addValue2=string.gsub(addValue2,"%%","%%%%")
					end
					self.nextDescLb:setString(getlocal(self.data.cfg.description1,{addValue1,addValue2}))
				end
			end
			local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png")
			local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png")
			local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png")
			local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
			slider:setTouchPriority(-(self.layerNum-1)*20-2)
			slider:setIsSallow(true)
			slider:setMinimumValue(1)
			slider:setMaximumValue(upLv)
			slider:setValue(upLv)
			slider:setPosition(ccp(364,150))
			slider:setTag(99)
			downBg:addChild(slider)
			local function touchAdd()
				slider:setValue(slider:getValue()+1)
			end  
			local function touchMinus()
				if slider:getValue()-1>0 then
					slider:setValue(slider:getValue()-1)
				end
			end  
			local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
			addSp:setTouchPriority(-(self.layerNum-1)*20-3)  
			addSp:setPosition(ccp(575,150))
			downBg:addChild(addSp)
			local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
			minusSp:setTouchPriority(-(self.layerNum-1)*20-3)
			minusSp:setPosition(ccp(151,150))
			downBg:addChild(minusSp)
		else
			self.targetLv=self.data.lv + 1
		end
		local function onUpgrade()
			if(self.targetLv)then
				local function callback()
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("skillLevelUp",{getlocal(skillVoApi:getSkillNameById(self.data.sid)),self.data.lv}),28)
					self:refresh()
					eventDispatcher:dispatchEvent("player.skill.change")
				end
				skillVoApi:upgrade(self.data.sid,self.targetLv,callback)
			end
		end
		local btnScale = 0.8
		local upgradeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onUpgrade,nil,getlocal("upgradeBuild"),25/btnScale)
		upgradeItem:setScale(btnScale)
		local upgradeBtn=CCMenu:createWithItem(upgradeItem)
		upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
		upgradeBtn:setPosition(downBgSize.width/2,60)
		downBg:addChild(upgradeBtn)
	else
		local tvHeight=posY - 20
		self:initTvContent(tvHeight)
		local function callback(...)
			return self:eventHandler(...)
		end
		local hd=LuaEventHandler:createHandler(callback)
		local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(downBgSize.width,tvHeight),nil)
		tv:setTableViewTouchPriority(-(self.layerNum-1)*20 - 4)
		tv:setPosition(ccp(0,posY - tvHeight))
		tv:setMaxDisToBottomOrTop(0)
		downBg:addChild(tv)
		tv:recoverToRecordPoint(ccp(0,tvHeight - self.tvHeight))
	end
end

function playerSkillDetailDialog:initTvContent(maxHeight)
	local nameFontSize,smallFontSize = 22,20
	local btnScale = 0.64
	local height=0
	local downBgSize=CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 390)
	self.tvSpTb={}
	local needTitle=GetTTFLabelWrap(getlocal("nbSkill_needSkillLv"),nameFontSize,CCSizeMake(downBgSize.width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	needTitle:setColor(G_LowfiColorRed2)
	needTitle:setAnchorPoint(ccp(0,1))
	needTitle:setPosition(20,maxHeight - height)
	table.insert(self.tvSpTb,needTitle)
	height=height + needTitle:getContentSize().height + 5

	local lvNeed=skillVoApi:getLvRequireByIdAndLv(self.data.sid)
	if(playerVoApi:getPlayerLevel()<lvNeed)then
		local lvNeedLb=GetTTFLabel(getlocal("playerLevel")..": "..getlocal("fightLevel",{lvNeed}),nameFontSize)
		lvNeedLb:setColor(G_LowfiColorRed2)
		lvNeedLb:setAnchorPoint(ccp(0,0.5))
		lvNeedLb:setPosition(30,maxHeight - height - 30)
		table.insert(self.tvSpTb,lvNeedLb)
		local sp=CCSprite:createWithSpriteFrameName("IconFault.png")
		sp:setPosition(downBgSize.width/2 + 100,maxHeight - height - 30)
		table.insert(self.tvSpTb,sp)
		height=height + sp:getContentSize().height + 5
	end
	local needSkillID=self.data.cfg.needSkillID
	if(needSkillID)then
		local flag=true
		for sid,paramTb in pairs(needSkillID) do
			local preSkill=skillVoApi:getAllSkills()[sid]
			local needLv=(self.data.lv + 1)*paramTb[1] + paramTb[2]
			if(preSkill.lv<needLv)then
				flag=false
				break
			end
		end
		if(flag==false)then
			local needSkillID=self.data.cfg.needSkillID
			local preSkillTb={}
			for sid,paramTb in pairs(needSkillID) do
				local preSkill=skillVoApi:getAllSkills()[sid]
				local needLv=(self.data.lv + 1)*paramTb[1] + paramTb[2]
				table.insert(preSkillTb,{preSkill,needLv})
			end
			local function sortFunc(a,b)
				return a[1].cfg.sid<b[1].cfg.sid
			end
			table.sort(preSkillTb,sortFunc)
			for k,v in pairs(preSkillTb) do
				local tmpY=maxHeight - height - (k - 1)*80 - 40
				local icon=skillVoApi:getSkillIconById(v[1].sid)
				icon:setScale(60/icon:getContentSize().width)
				icon:setAnchorPoint(ccp(0,0.5))
				icon:setPosition(30,tmpY)
				table.insert(self.tvSpTb,icon)
				local nameLb=GetTTFLabelWrap(getlocal(skillVoApi:getSkillNameById(v[1].sid)).." "..getlocal("fightLevel",{v[2]}),smallFontSize,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(110,tmpY)
				table.insert(self.tvSpTb,nameLb)
				local sp,showGoto
				if(v[1].lv>=v[2])then
					nameLb:setColor(G_ColorGreen)
					sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
					showGoto=false
				else
					nameLb:setColor(G_LowfiColorRed2)
					sp=CCSprite:createWithSpriteFrameName("IconFault.png")
					showGoto=true
				end
				sp:setPosition(downBgSize.width/2 + 100,tmpY)
				table.insert(self.tvSpTb,sp)
				if(showGoto)then
					local function onGoto()
						self:close()
						local td=playerSkillDetailDialog:new(v[1])
						local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("heroSkillUpdate"),true,self.layerNum)
						sceneGame:addChild(dialog,self.layerNum)
					end
					local gotoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGoto,nil,getlocal("activity_heartOfIron_goto"),24/btnScale)
					gotoItem:setScale(btnScale)
					local gotoBtn=CCMenu:createWithItem(gotoItem)
					gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
					gotoBtn:setPosition(downBgSize.width - 100,tmpY)
					table.insert(self.tvSpTb,gotoBtn)
				end
			end
			height=height + #preSkillTb*80
		end
	end
	if(self.canUpgrade==5)then
		local relationSid
		for k,sid in pairs(self.data.cfg.relationSkill) do
			local tmpY=maxHeight - height - (k - 1)*80 - 40
			if(sid~=self.data.sid and skillVoApi:getAllSkills()[sid].lv>0 and skillVoApi:getAllSkills()[sid].lv<skillVoApi:getSkillMaxLv(sid))then
				local icon=skillVoApi:getSkillIconById(sid)
				icon:setScale(60/icon:getContentSize().width)
				icon:setAnchorPoint(ccp(0,0.5))
				icon:setPosition(30,maxHeight - height - 40)
				table.insert(self.tvSpTb,icon)
				local nameLb=GetTTFLabel(getlocal(skillVoApi:getSkillNameById(sid)).." "..getlocal("fightLevel",{skillVoApi:getSkillMaxLv(sid)}),smallFontSize)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(110,maxHeight - height - 40)
				table.insert(self.tvSpTb,nameLb)
				local sp=CCSprite:createWithSpriteFrameName("IconFault.png")
				sp:setPosition(downBgSize.width/2 + 100,maxHeight - height - 40)
				table.insert(self.tvSpTb,sp)
				local function onGoto()
					self:close()
					local td=playerSkillDetailDialog:new(skillVoApi:getAllSkills()[sid])
					local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("heroSkillUpdate"),true,self.layerNum)
					sceneGame:addChild(dialog,self.layerNum)
				end
				local gotoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGoto,nil,getlocal("activity_heartOfIron_goto"),24/btnScale)
				gotoItem:setScale(btnScale)
				local gotoBtn=CCMenu:createWithItem(gotoItem)
				gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
				gotoBtn:setPosition(downBgSize.width - 100,tmpY)
				table.insert(self.tvSpTb,gotoBtn)
				height=height + 80
			end
		end
	end

	local upProp=skillVoApi:getPropRequireByIdAndLv(self.data.sid)
	local propTb=FormatItem({p=upProp})
	local costLbTb={}
	local itemSize=60
	for k,v in pairs(propTb) do
		local propIcon=G_getItemIcon(v,100,false)
		propIcon:setScale(itemSize/propIcon:getContentSize().width)
		propIcon:setAnchorPoint(ccp(0,0.5))
		propIcon:setPosition(30,maxHeight - height - 40)
		table.insert(self.tvSpTb,propIcon)
		local propName=GetTTFLabel(getlocal("vip_tequanlibao_geshihua",{v.name,FormatNumber(v.num)}),smallFontSize)
		propName:setAnchorPoint(ccp(0,0.5))
		propName:setPosition(110,maxHeight - height - 20)
		table.insert(self.tvSpTb,propName)
		local ownNum=bagVoApi:getItemNumId(v.id)
		local ownLb=GetTTFLabel(getlocal("ownedPropNum",{FormatNumber(ownNum)}),smallFontSize)
		if(ownNum<v.num)then
			ownLb:setColor(G_LowfiColorRed2)
		end
		ownLb:setAnchorPoint(ccp(0,0.5))
		ownLb:setPosition(110,maxHeight - height - 60)
		table.insert(self.tvSpTb,ownLb)
		if(v.id==19 and ownNum<v.num)then
			local function onBuy()
				local costGems=playerSkillCfg.getPropList.p19.costGem
				if(playerVoApi:getGems()<costGems)then
					local str=getlocal("buyItemGemNotEnough",{playerSkillCfg.getPropList.p19.getNum,v.name,costGems,playerVoApi:getGems(),costGems - playerVoApi:getGems()})
					GemsNotEnoughDialog(nil,str)
					do return end
				end
				confirmStr=getlocal("buyConfirm",{costGems,playerSkillCfg.getPropList.p19.getNum,getlocal(propCfg["p19"].name)})
				local pid="p19"
				local function onConfirm()
					local function callback()
						self:refresh()
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),28)
						eventDispatcher:dispatchEvent("player.skill.change")
					end
					skillVoApi:changeProp(pid,callback)
				end
				local sd=smallDialog:new()
				sd:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),confirmStr,nil,self.layerNum+1)
			end
			local buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onBuy,nil,getlocal("buy"),24/btnScale)
			buyItem:setScale(btnScale)
			local buyBtn=CCMenu:createWithItem(buyItem)
			buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
			buyBtn:setPosition(downBgSize.width - 100,maxHeight - height - 40)
			table.insert(self.tvSpTb,buyBtn)
		end
		height=height + 80
	end
	if(height>maxHeight)then
		for k,v in pairs(self.tvSpTb) do
			v:setPositionY(v:getPositionY() + height - maxHeight)
		end
	end
	self.tvHeight=math.max(height,maxHeight)
end

function playerSkillDetailDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 50,self.tvHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		for k,v in pairs(self.tvSpTb) do
			cell:addChild(v)
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

function playerSkillDetailDialog:refresh()
	local upBg=tolua.cast(self.bgLayer:getChildByTag(101),"CCScale9Sprite")
	if(upBg)then
		upBg:removeFromParentAndCleanup(true)
	end
	self.tvSpTb={}
	self.targetLv=nil
	self.tvHeight=nil
	self.nextNameLb=nil
	self.nextDescLb=nil
	local downBg=tolua.cast(self.bgLayer:getChildByTag(102),"CCScale9Sprite")
	if(downBg)then
		downBg:removeFromParentAndCleanup(true)
	end
	self.canUpgrade=skillVoApi:checkCanUpgrade(self.data.sid)
	self:initUp()
	if(self.canUpgrade~=3)then
		self:initDown()
	end
end

function playerSkillDetailDialog:dispose()
	self.targetLv=nil
end