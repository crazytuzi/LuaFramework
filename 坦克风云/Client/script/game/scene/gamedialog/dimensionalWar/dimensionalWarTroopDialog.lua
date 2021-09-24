--异次元大战，战场中的部队面板
dimensionalWarTroopDialog=commonDialog:new()
function dimensionalWarTroopDialog:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index =self
	return nc
end

function dimensionalWarTroopDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function dimensionalWarTroopDialog:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 140),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(30,30)
	self.tv:setMaxDisToBottomOrTop(40)
	self.bgLayer:addChild(self.tv)
end

function dimensionalWarTroopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 6
	elseif fn=="tableCellSizeForIndex" then
		if(idx==0 or idx==2 or idx==4)then
			return CCSizeMake(G_VisibleSizeWidth - 60,45)
		elseif(idx==1)then
			return CCSizeMake(G_VisibleSizeWidth - 60,100)
		elseif(idx==3)then
			local buffNum=0
			if(dimensionalWarFightVoApi:getBuffData().add)then
				for k,v in pairs(dimensionalWarFightVoApi:getBuffData().add) do
					buffNum=buffNum + 1
				end
			end
			local buffHeight
			if(buffNum>0)then
				buffHeight=math.ceil(buffNum/5)*105
			else
				buffHeight=105
			end
			local debuffNum=0
			if(dimensionalWarFightVoApi:getBuffData().del)then
				for k,v in pairs(dimensionalWarFightVoApi:getBuffData().del) do
					debuffNum=debuffNum + 1
				end
			end
			local debuffHeight
			if(debuffNum>0)then
				debuffHeight=math.ceil(debuffNum/5)*105
			else
				debuffHeight=105
			end
			return CCSizeMake(G_VisibleSizeWidth - 60,buffHeight + debuffHeight)
		elseif(idx==5)then
			return CCSizeMake(G_VisibleSizeWidth - 60,550)
		end
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		if(idx==0 or idx==2 or idx==4)then
			local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,0,2,47),function ()end)
			titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,45))
			titleBg:setPosition((G_VisibleSizeWidth - 60)/2,45/2)
			cell:addChild(titleBg)
			local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
			lineSp:setScaleX((G_VisibleSizeWidth - 60)/lineSp:getContentSize().width)
			lineSp:setPosition((G_VisibleSizeWidth - 60)/2,2)
			cell:addChild(lineSp)
			local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
			lineSp:setScaleX((G_VisibleSizeWidth - 60)/lineSp:getContentSize().width)
			lineSp:setPosition((G_VisibleSizeWidth - 60)/2,43)
			cell:addChild(lineSp)
			local titleLb
			if(idx==0)then
				titleLb=GetTTFLabel(getlocal("state"),30)
			elseif(idx==2)then
				titleLb=GetTTFLabel(getlocal("help4_t1"),30)
			else
				titleLb=GetTTFLabel(getlocal("playerInfo"),30)
			end
			titleLb:setColor(G_ColorYellowPro)
			titleLb:setPosition((G_VisibleSizeWidth - 60)/2,22.5)
			cell:addChild(titleLb)
		elseif(idx==1)then
			self:initStatusCell(cell)
		elseif(idx==3)then
			self:initBuffCell(cell)
		elseif(idx==5)then
			self:initTroopCell(cell)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
		return true
	end
end

function dimensionalWarTroopDialog:initStatusCell(cell)
	local statusLb=GetTTFLabel(getlocal("dimensionalWar_curStatus",{getlocal("dimensionalWar_status"..dimensionalWarFightVoApi:getPlayerStatus())}),25)
	statusLb:setAnchorPoint(ccp(0,0.5))
	statusLb:setPosition(ccp(0,75))
	cell:addChild(statusLb)
	local energyLb=GetTTFLabel(getlocal("dimensionalWar_energy",{dimensionalWarFightVoApi:getEnergy()}),25)
	energyLb:setAnchorPoint(ccp(0,0.5))
	energyLb:setPosition((G_VisibleSizeWidth - 60)/2,75)
	cell:addChild(energyLb)
	local fullTankTb=tankVoApi:getTanksTbByType(33)
	local curTankTb=dimensionalWarFightVoApi:getTroops()
	local percent
	if(curTankTb and curTankTb.troops)then
		local leftTank=0
		for k,v in pairs(curTankTb.troops) do
			if(v[2])then
				leftTank=leftTank + v[2]
			end
		end
		local totalTank=0
		for k,v in pairs(fullTankTb) do
			if(v[2])then
				totalTank=totalTank + v[2]
			end
		end
		percent=leftTank/totalTank
	else
		percent=0
	end
	local troopStr
	if(percent>=0.8)then
		troopStr=getlocal("dimensionalWar_troopStatus1")
	elseif(percent>=0.4)then
		troopStr=getlocal("dimensionalWar_troopStatus2")
	else
		troopStr=getlocal("dimensionalWar_troopStatus3")
	end
	local troopLb=GetTTFLabel(getlocal("dimensionalWar_troopStatus",{troopStr}),25)
	troopLb:setAnchorPoint(ccp(0,0.5))
	troopLb:setPosition(0,45)
	cell:addChild(troopLb)
	local pointLb=GetTTFLabel(getlocal("serverwar_reward_desc2",{dimensionalWarFightVoApi:getPoint()}),25)
	pointLb:setAnchorPoint(ccp(0,0.5))
	pointLb:setPosition((G_VisibleSizeWidth - 60)/2,45)
	cell:addChild(pointLb)
	local surviveRound,zombieRound
	if(dimensionalWarFightVoApi:getPlayerStatus()==0)then
		surviveRound=GetTTFLabel(getlocal("dimensionalWar_survive_round")..": "..(dimensionalWarFightVoApi:getCurRound() - 1),25)
		zombieRound=GetTTFLabel(getlocal("dimensionalWar_zombieRound",{0}),25)
		zombieRound:setVisible(false)
	elseif(dimensionalWarFightVoApi:getPlayerStatus()==1)then
		surviveRound=GetTTFLabel(getlocal("dimensionalWar_survive_round")..": "..(dimensionalWarFightVoApi:getZombieRound() - 1),25)
		zombieRound=GetTTFLabel(getlocal("dimensionalWar_zombieRound",{dimensionalWarFightVoApi:getCurRound() - dimensionalWarFightVoApi:getZombieRound()}),25)
	else
		surviveRound=GetTTFLabel(getlocal("dimensionalWar_survive_round")..": "..(dimensionalWarFightVoApi:getZombieRound() - 1),25)
		zombieRound=GetTTFLabel(getlocal("dimensionalWar_zombieRound",{dimensionalWarFightVoApi:getDieRound() - dimensionalWarFightVoApi:getZombieRound()}),25)
	end
	surviveRound:setAnchorPoint(ccp(0,0.5))
	surviveRound:setPosition(0,15)
	cell:addChild(surviveRound)
	zombieRound:setAnchorPoint(ccp(0,0.5))
	zombieRound:setPosition((G_VisibleSizeWidth - 60)/2,15)
	cell:addChild(zombieRound)
end

function dimensionalWarTroopDialog:initBuffCell(cell)
	local function sortFunc(a,b)
		return tonumber(RemoveFirstChar(a[1]))<tonumber(RemoveFirstChar(b[1]))
	end
	local buffTb={}
	if(dimensionalWarFightVoApi:getBuffData().add)then
		for k,v in pairs(dimensionalWarFightVoApi:getBuffData().add) do
			table.insert(buffTb,{k,v})
		end
	end
	local debuffTb={}
	if(dimensionalWarFightVoApi:getBuffData().del)then
		for k,v in pairs(dimensionalWarFightVoApi:getBuffData().del) do
			table.insert(debuffTb,{k,v})
		end
	end
	table.sort(buffTb,sortFunc)
	table.sort(debuffTb,sortFunc)
	local buffHeight=math.max(math.ceil((#buffTb)/5)*105,105)
	local debuffHeight=math.max(math.ceil((#debuffTb)/5)*105,105)
	local totalHeight=buffHeight + debuffHeight

	local function onClickBuff(object,fn,tag)
		if(tag and buffTb[tag])then
			local buffID=buffTb[tag][1]
			self:showBuffDesc(buffID,1)
		end
	end
	for k,v in pairs(buffTb) do
		local effectIcon=LuaCCSprite:createWithSpriteFrameName("dwBuff"..v[1]..".png",onClickBuff)
		effectIcon:setTag(k)
		effectIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		local xIndex=(k - 1)%5
		local yIndex=math.ceil(k/5)
		effectIcon:setPosition(110 + xIndex*105,totalHeight - (yIndex - 1)*105 - 52.5)
		cell:addChild(effectIcon)
		local lb=GetTTFLabel(v[2],25)
		lb:setAnchorPoint(ccp(1,0))
		lb:setPosition(effectIcon:getContentSize().width - 10,10)
		effectIcon:addChild(lb)
	end
	local upArrow=CCSprite:createWithSpriteFrameName("dwArrow1.png")
	upArrow:setPosition(30,totalHeight - buffHeight/2)
	cell:addChild(upArrow)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX((G_VisibleSizeWidth - 60)/lineSp:getContentSize().width)
	lineSp:setPosition((G_VisibleSizeWidth - 60)/2,totalHeight - buffHeight)
	cell:addChild(lineSp)

	local function onClickDebuff(object,fn,tag)
		if(tag and debuffTb[tag])then
			local debuffID=debuffTb[tag][1]
			self:showBuffDesc(debuffID,2)
		end
	end
	for k,v in pairs(debuffTb) do
		local effectIcon=LuaCCSprite:createWithSpriteFrameName("dwDebuff"..v[1]..".png",onClickDebuff)
		effectIcon:setTag(k)
		effectIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		local xIndex=(k - 1)%5
		local yIndex=math.ceil(k/5)
		effectIcon:setPosition(110 + xIndex*105,debuffHeight - (yIndex - 1)*105 - 52.5)
		cell:addChild(effectIcon)
		local lb=GetTTFLabel(v[2],25)
		lb:setAnchorPoint(ccp(1,0))
		lb:setPosition(effectIcon:getContentSize().width - 10,10)
		effectIcon:addChild(lb)
	end
	local downArrow=CCSprite:createWithSpriteFrameName("dwArrow2.png")
	downArrow:setPosition(30,debuffHeight/2)
	cell:addChild(downArrow)
end

function dimensionalWarTroopDialog:showBuffDesc(id,type)
	local function onHide()
		if(self.buffLayer)then
			self.buffLayer:removeFromParentAndCleanup(true)
			self.buffLayer=nil
		end
	end
	if(self.buffLayer)then
		onHide()
	end
	local layerNum=self.layerNum + 1
	self.buffLayer=CCLayer:create()
	self.bgLayer:addChild(self.buffLayer,2)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.buffLayer:addChild(touchDialogBg)
	local buffDesc=GetTTFLabelWrap(dimensionalWarFightVoApi:getBuffDesc(id,type),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	local height=buffDesc:getContentSize().height
	local totalHeight=height + 30 + 20 + 100 + 80
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	dialogBg:setContentSize(CCSizeMake(500,totalHeight))
	dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.buffLayer:addChild(dialogBg)
	local buffIcon,buffName,dataTb
	if(type==1)then
		buffIcon=CCSprite:createWithSpriteFrameName("dwBuff"..id..".png")
		buffName=GetTTFLabelWrap(getlocal("dimensionalWar_buffName"..id),30,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		dataTb=dimensionalWarFightVoApi:getBuffData().add or {}
	else
		buffIcon=CCSprite:createWithSpriteFrameName("dwDebuff"..id..".png")
		buffName=GetTTFLabelWrap(getlocal("dimensionalWar_debuffName"..id),30,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		dataTb=dimensionalWarFightVoApi:getBuffData().del or {}
	end
	buffIcon:setPosition(90,totalHeight - 90)
	dialogBg:addChild(buffIcon)
	buffName:setColor(G_ColorYellowPro)
	buffName:setAnchorPoint(ccp(0,1))
	buffName:setPosition(160,totalHeight - 40)
	dialogBg:addChild(buffName)
	local timeLb=GetTTFLabel(getlocal("dimensionalWar_buffTime",{dataTb[id] or 0}),25)
	timeLb:setAnchorPoint(ccp(0,0))
	timeLb:setPosition(160,totalHeight - 140)
	dialogBg:addChild(timeLb)
	local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(15, 15, 10, 10),onHide)
	descBg:setContentSize(CCSizeMake(440,height + 30))
	descBg:setAnchorPoint(ccp(0.5,1))
	descBg:setPosition(250,totalHeight - 160)
	dialogBg:addChild(descBg)
	buffDesc:setAnchorPoint(ccp(0,0.5))
	buffDesc:setPosition(50,totalHeight - 160 - 15 - height/2)
	dialogBg:addChild(buffDesc)
end

function dimensionalWarTroopDialog:initTroopCell(cell)
	local totalHeight=550
	local lbNum1=GetTTFLabel(getlocal("player_leader_troop_num",{playerVoApi:getTroopsLvNum()}),26)
	lbNum1:setAnchorPoint(ccp(0,0.5))
	lbNum1:setPosition(ccp(50,totalHeight - 50))
	cell:addChild(lbNum1,1)	
	local lbNum2 = GetTTFLabel("+"..playerVoApi:getExtraTroopsNum(),26)
	lbNum2:setColor(G_ColorGreen)
	lbNum2:setAnchorPoint(ccp(0,0.5))
	lbNum2:setPosition(ccp(lbNum1:getPositionX() + lbNum1:getContentSize().width + 5,totalHeight - 50))
	cell:addChild(lbNum2,1)

	local troopBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	troopBg:setOpacity(0)
	troopBg:setAnchorPoint(ccp(0,0))
	cell:addChild(troopBg)
	local heroBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	heroBg:setOpacity(0)
	heroBg:setAnchorPoint(ccp(0,0))
	cell:addChild(heroBg)
	heroBg:setPositionX(999333)
	heroBg:setVisible(false)
	local aitroopsBg = nil
	if base.AITroopsSwitch==1 then
		aitroopsBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		aitroopsBg:setOpacity(0)
		aitroopsBg:setAnchorPoint(ccp(0,0))
		cell:addChild(aitroopsBg)
		aitroopsBg:setPositionX(999333)
		aitroopsBg:setVisible(false)
	end

	local function onSwitch(object,fn,tag)
		if(tag==1)then
			troopBg:setPositionX(999333)
			troopBg:setVisible(false)
			if base.AITroopsSwitch==1 then
				aitroopsBg:setPositionX(0)
				aitroopsBg:setVisible(true)
				heroBg:setPositionX(999333)
				heroBg:setVisible(false)
			else
				heroBg:setPositionX(0)
				heroBg:setVisible(true)
			end
		elseif (tag==2) then
			troopBg:setPositionX(0)
			troopBg:setVisible(true)
			heroBg:setPositionX(999333)
			heroBg:setVisible(false)
			if aitroopsBg then
				aitroopsBg:setPositionX(999333)
				aitroopsBg:setVisible(false)
			end
		elseif (tag==3) then
			troopBg:setPositionX(999333)
			troopBg:setVisible(false)
			heroBg:setPositionX(0)
			heroBg:setVisible(true)
			if aitroopsBg then
				aitroopsBg:setPositionX(999333)
				aitroopsBg:setVisible(false)
			end
		end
	end
	local switchTankPic, switchHeroPic, switchAIPic = "changeRole1.png", "changeRole2.png", "smt_switchAI.png"
    if base.AITroopsSwitch == 1 then
        switchTankPic, switchHeroPic = "smt_switchTank.png", "smt_switchHero.png"
    end
	local switchIcon=LuaCCSprite:createWithSpriteFrameName(switchTankPic,onSwitch)
	switchIcon:setTag(1)
	switchIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	switchIcon:setPosition(G_VisibleSizeWidth - 60 - 50,totalHeight - 50)
	troopBg:addChild(switchIcon)
	local switchIcon=LuaCCSprite:createWithSpriteFrameName(switchHeroPic,onSwitch)
	switchIcon:setTag(2)
	switchIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	switchIcon:setPosition(G_VisibleSizeWidth - 60 - 50,totalHeight - 50)
	heroBg:addChild(switchIcon)
	if base.AITroopsSwitch==1 then
		local aiSwitchSp=LuaCCSprite:createWithSpriteFrameName(switchAIPic,onSwitch)
		aiSwitchSp:setTag(3)
		aiSwitchSp:setTouchPriority(-(self.layerNum-1)*20-2)
		aiSwitchSp:setPosition(G_VisibleSizeWidth - 60 - 50,totalHeight - 50)
		aitroopsBg:addChild(aiSwitchSp)
	end

	local fullTankTb=tankVoApi:getTanksTbByType(33)
	local curTankTb=dimensionalWarFightVoApi:getTroops().troops
	local curHeroTb=dimensionalWarFightVoApi:getTroops().hero
	local curAITroopsTb=dimensionalWarFightVoApi:getTroops().aitroops
	local tskinList = dimensionalWarFightVoApi:getTroops().skin --坦克皮肤数据
	for k,v in pairs(fullTankTb) do
		if(curTankTb[k]==nil)then
			curTankTb={}
		end
		if(v[1] and v[2] and curTankTb[k][1]==nil)then
			curTankTb[k][1]=v[1]
			curTankTb[k][2]=0
		end
	end
	for i=1,6 do
		local tankBg
		if(fullTankTb[i] and fullTankTb[i][2] and fullTankTb[i][2]>0)then
			tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ()end)
			tankBg:setContentSize(CCSizeMake(282,118))
			local tankID=fullTankTb[i][1]
			local skinId = tskinList[tankSkinVoApi:convertTankId(tankID)]
			local tankIcon=tankVoApi:getTankIconSp(tankID,skinId,nil,false)--CCSprite:createWithSpriteFrameName(tankCfg[tankID].icon)
			tankIcon:setScale(100/tankIcon:getContentSize().width)
			tankIcon:setPosition(55,59)
			if G_pickedList(tankID) ~= tankID then
				local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
				pickedIcon:setPosition(tankIcon:getContentSize().width*0.7,tankIcon:getContentSize().height*0.5 - 10)
				tankIcon:addChild(pickedIcon)
			end
			tankBg:addChild(tankIcon)
			local tankName=GetTTFLabelWrap(getlocal(tankCfg[tankID].name),25,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			tankName:setAnchorPoint(ccp(0,1))
			tankName:setPosition(110,108)
			tankBg:addChild(tankName)
			local leftNum=tonumber(curTankTb[i][2]) or 0
			local numLb=GetTTFLabel(leftNum.."/"..fullTankTb[i][2],25)
			numLb:setAnchorPoint(ccp(0,0.5))
			numLb:setPosition(110,23)
			tankBg:addChild(numLb)
		else
			tankBg=CCSprite:createWithSpriteFrameName("emptyTank.png")
			local posIcon=CCSprite:createWithSpriteFrameName("tankPos"..i..".png")
			posIcon:setPosition(getCenterPoint(tankBg))
			tankBg:addChild(posIcon)
		end
		local heroLb
		if(curHeroTb[i] and curHeroTb[i]~=0 and curHeroTb[i]~="0")then
			local tmpData=Split(curHeroTb[i],"-")
			local heroID,heroRank,heroLv=tmpData[1],tmpData[2],tmpData[3]
			if(heroID and heroRank and heroLv)then
				heroLb=GetTTFLabel(heroVoApi:getHeroName(heroID).." "..getlocal("fightLevel",{heroLv}),23)
			else
				heroLb=GetTTFLabel(getlocal("fight_content_null"),23)
			end
		else
			heroLb=GetTTFLabel(getlocal("fight_content_null"),23)
		end
		if(i<4)then
			heroLb:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 15)
			tankBg:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 90)
		else
			heroLb:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 15)
			tankBg:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 90)
		end
		troopBg:addChild(heroLb)
		troopBg:addChild(tankBg)
	end

	for i=1,6 do
		local heroBg1
		if(curHeroTb[i] and curHeroTb[i]~=0 and curHeroTb[i]~="0")then
			heroBg1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ()end)
			heroBg1:setContentSize(CCSizeMake(282,118))
			local tmpData=Split(curHeroTb[i],"-")
			local heroID,heroRank,heroLv=tmpData[1],tmpData[2],tmpData[3]
			local adjutants = heroAdjutantVoApi:decodeAdjutant(curHeroTb[i])
			local heroIcon=heroVoApi:getHeroIcon(heroID,heroRank,true,nil,nil,nil,nil,{adjutants=adjutants})
			heroIcon:setScale(80/heroIcon:getContentSize().width)
			heroIcon:setPosition(55,59)
			heroBg1:addChild(heroIcon)
			local heroName=GetTTFLabelWrap(heroVoApi:getHeroName(heroID).." "..getlocal("fightLevel",{heroLv}),25,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			heroName:setAnchorPoint(ccp(0,0.5))
			heroName:setPosition(110,59)
			heroBg1:addChild(heroName)
		else
			heroBg1=CCSprite:createWithSpriteFrameName("emptyHero.png")
			local posIcon=CCSprite:createWithSpriteFrameName("tankPos"..i..".png")
			posIcon:setPosition(getCenterPoint(heroBg1))
			heroBg1:addChild(posIcon)
		end
		local tankLb
		if(fullTankTb[i] and fullTankTb[i][2] and fullTankTb[i][2]>0)then
			tankLb=GetTTFLabel(getlocal(tankCfg[fullTankTb[i][1]].name).." ("..curTankTb[i][2]..")",23)
		else
			tankLb=GetTTFLabel(getlocal("fight_content_null"),23)
		end
		if(i<4)then
			tankLb:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 15)
			heroBg1:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 90)
		else
			tankLb:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 15)
			heroBg1:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 90)
		end
		heroBg:addChild(tankLb)
		heroBg:addChild(heroBg1)
	end
    if base.AITroopsSwitch == 1 then
		for i=1,6 do
			local bgSp
			if(curAITroopsTb[i] and tonumber(curAITroopsTb[i])~=0 and curAITroopsTb[i]~="")then
				bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ()end)
				bgSp:setContentSize(CCSizeMake(282,118))

	 			local atid, lv, grade, strength
	 			local aitVo=AITroopsVoApi:getTroopsById(curAITroopsTb[i])
	 			if aitVo then
	 				atid, lv, grade, strength = aitVo.id, aitVo.lv, aitVo.grade, aitVo:getTroopsStrength()
	 			end
	            if atid and lv and grade and strength then
	            	local spWidth = 80
		            local aitroopsIconSp = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade)
		            aitroopsIconSp:setScale(spWidth / aitroopsIconSp:getContentSize().width)
		            aitroopsIconSp:setPosition(55,59)
		            bgSp:addChild(aitroopsIconSp)
	                --AI部队名称显示
				    local nameStr,color=AITroopsVoApi:getAITroopsNameStr(atid)
				    local troopsNameLb = GetTTFLabelWrap(nameStr,22,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
				    troopsNameLb:setAnchorPoint(ccp(0,0.5))
				    troopsNameLb:setColor(color)
				    troopsNameLb:setPosition(aitroopsIconSp:getPositionX()+spWidth/2+10,aitroopsIconSp:getPositionY()+spWidth/2-troopsNameLb:getContentSize().height/2)
				    bgSp:addChild(troopsNameLb)

				    --AI部队强度显示
				    local strengthLb = GetTTFLabel(strength,22)
				    strengthLb:setAnchorPoint(ccp(0,0.5))
				    strengthLb:setPosition(troopsNameLb:getPositionX(),aitroopsIconSp:getPositionY()-spWidth/2+strengthLb:getContentSize().height/2)
				    bgSp:addChild(strengthLb)
	            end
			else
				bgSp=CCSprite:createWithSpriteFrameName("emptyTank.png")
				local posIcon=CCSprite:createWithSpriteFrameName("tankPos"..i..".png")
				posIcon:setPosition(getCenterPoint(bgSp))
				bgSp:addChild(posIcon)
			end
			local tankLb
			if(fullTankTb[i] and fullTankTb[i][2] and fullTankTb[i][2]>0)then
				tankLb=GetTTFLabel(getlocal(tankCfg[fullTankTb[i][1]].name).." ("..curTankTb[i][2]..")",23)
			else
				tankLb=GetTTFLabel(getlocal("fight_content_null"),23)
			end
			if(i<4)then
				tankLb:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 15)
				bgSp:setPosition((G_VisibleSizeWidth - 60)*3/4,totalHeight - 95 - (i - 1)*150 - 90)
			else
				tankLb:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 15)
				bgSp:setPosition((G_VisibleSizeWidth - 60)/4,totalHeight - 95 - (i - 4)*150 - 90)
			end
			aitroopsBg:addChild(tankLb)
			aitroopsBg:addChild(bgSp)
		end
    end
end