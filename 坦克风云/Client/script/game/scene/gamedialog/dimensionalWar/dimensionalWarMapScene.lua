--异次元战战场场景
dimensionalWarMapScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=1,
	isShow=false,
	chatBg=nil,
	tipTb={},
	moveMv=nil,
	moveX=nil,
	moveY=nil,
	smallDialog=nil,
	dialogType=nil,
	operateType=nil,
	explodeMv=nil,
	explodeType=nil,
	tipVisible=false,
	buffTb=nil,
	buyTb=nil,
	beginMask=nil,
	shakeTick=nil,
	zombieBorder=nil
}

function dimensionalWarMapScene:show(layerNum)
	local initNum=dimensionalWarVoApi:getInitBattleChatNum()
	if initNum<3 then
		dimensionalWarVoApi:setInitBattleChatNum(initNum+1)
		socketHelper:chatServerLogin(base.curUid,base.access_token,base.serverTime,true)
	end

	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initBackground()
	self:initFunctionBar()
	self:initMap()
	self:initChat()
	self:initPlayer()
	self.isShow=true
	self.showTime=base.serverTime
	base.pauseSync=true
	if(self.moveRound==nil)then
		self.moveRound=dimensionalWarFightVoApi:getMoveRound()
	end
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("dimensionalWar.battle",eventListener)
	local status=dimensionalWarFightVoApi:checkActionStatus()
	if(status==0)then
		self:checkShowExplode(status)
	end
end

function dimensionalWarMapScene:initBackground()
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)

	self:initTitle()
	spriteController:addTexture("public/dimensionalWar/dimensionalWarBg.jpg")
	local texture=spriteController:getTexture("public/dimensionalWar/dimensionalWarBg.jpg")
	self.background=CCSprite:createWithTexture(texture)
	self.background:setScaleX(G_VisibleSizeWidth/self.background:getContentSize().width)
	self.background:setScaleY((G_VisibleSizeHeight - 55 - 100)/self.background:getContentSize().height)
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setPosition(ccp(0,55))
	self.bgLayer:addChild(self.background)
end

function dimensionalWarMapScene:initTitle()
	local function onShowTroops()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		--test data
		-- self:showLoading()
		dimensionalWarFightVoApi:showTroopDialog(self.layerNum + 2)
		--test end
	end
	local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,10,10),onShowTroops)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-5)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,100))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight))
	self.bgLayer:addChild(titleBg,3)
	local leftX=(G_VisibleSizeWidth/2 - 60)/2
	local statusTitle=GetTTFLabel(getlocal("dimensionalWar_myStatus"),25)
	statusTitle:setPosition(leftX,80)
	titleBg:addChild(statusTitle)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	local lineScale=(G_VisibleSizeWidth/2 - 80)/lineSp:getContentSize().width
	lineSp:setScaleX(lineScale)
	lineSp:setPosition(ccp(leftX,65))
	titleBg:addChild(lineSp)
	self.ecgSp=CCSprite:createWithSpriteFrameName("dwECG.png")
	self.ecgSp:setPosition(leftX/2 + 10,50)
	titleBg:addChild(self.ecgSp)
	if(dimensionalWarFightVoApi:getPlayerStatus()==0)then
		self.statusLb=GetTTFLabel(getlocal("dimensionalWar_status0"),25)
		self.ecgSp:setColor(G_ColorGreen)
	elseif(dimensionalWarFightVoApi:getPlayerStatus()==1)then
		self.statusLb=GetTTFLabel(getlocal("dimensionalWar_status1"),25)
		self.ecgSp:setColor(G_ColorGray)
	else
		self.statusLb=GetTTFLabel(getlocal("dimensionalWar_status2"),25)
		self.ecgSp:setColor(G_ColorGray)
	end
	self.statusLb:setPosition(leftX + 50,50)
	titleBg:addChild(self.statusLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(lineScale)
	lineSp:setPosition(ccp(leftX,35))
	titleBg:addChild(lineSp)
	self.energyLb=GetTTFLabel(getlocal("dimensionalWar_energy",{getlocal("scheduleChapter",{dimensionalWarFightVoApi:getEnergy(),userWarCfg.energyMax})}),22)
	self.energyLb:setPosition(leftX,20)
	titleBg:addChild(self.energyLb)
	local rightX=G_VisibleSizeWidth - (G_VisibleSizeWidth/2 - 60)/2
	self.roundLb=GetTTFLabel(getlocal("plat_war_cur_round",{dimensionalWarFightVoApi:getCurRound()}),25)
	self.roundLb:setPosition(rightX,80)
	titleBg:addChild(self.roundLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(lineScale)
	lineSp:setPosition(ccp(rightX,65))
	titleBg:addChild(lineSp)
	if(base.serverTime<dimensionalWarFightVoApi:getStartTime() or dimensionalWarFightVoApi:checkActionStatus()==1)then
		self.countDown=0
	else
		self.countDown=dimensionalWarFightVoApi:getCountDown()
	end
	self.countDownLb=GetTTFLabel(getlocal("dimensionalWar_countDown",{self.countDown}),25)
	self.countDownLb:setColor(G_ColorYellowPro)
	self.countDownLb:setPosition(rightX,50)
	titleBg:addChild(self.countDownLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(lineScale)
	lineSp:setPosition(ccp(rightX,35))
	titleBg:addChild(lineSp)
	self.surviverNumLb=GetTTFLabel(getlocal("dimensionalWar_surviverNum",{dimensionalWarFightVoApi:getSurvivers()}),22)
	self.surviverNumLb:setPosition(rightX,20)
	titleBg:addChild(self.surviverNumLb)
	local explodeBg=CCSprite:createWithSpriteFrameName("dwRoundBg.png")
	explodeBg:setAnchorPoint(ccp(0.5,1))
	explodeBg:setPosition(G_VisibleSizeWidth/2,100)
	titleBg:addChild(explodeBg)
	local explodeMv = CCParticleSystemQuad:create("public/dimensionalWar/dimensionalExplode.plist")
	explodeMv:setScale(0.9)
	explodeMv.positionType=kCCPositionTypeFree
	explodeMv:setPosition(G_VisibleSizeWidth/2,35)
	titleBg:addChild(explodeMv)
	self:initBuff()
end

function dimensionalWarMapScene:initBuff()
	if(self.buffTb)then
		for k,v in pairs(self.buffTb) do
			v=tolua.cast(v,"CCNode")
			if(v and v:getParent())then
				v:removeFromParentAndCleanup(true)
			end
		end
	end
	self.buffTb={}
	local buffData=dimensionalWarFightVoApi:getBuffData()
	local function sortFunc(a,b)
		return tonumber(RemoveFirstChar(a[1]))<tonumber(RemoveFirstChar(b[1]))
	end
	local effectTb={}
	if(buffData.add)then
		for k,v in pairs(buffData.add) do
			table.insert(effectTb,{k,v,1})
		end
	end
	table.sort(effectTb,sortFunc)
	local debuffTb={}
	if(buffData.del)then
		for k,v in pairs(buffData.del) do
			table.insert(debuffTb,{k,v,2})
		end
	end
	table.sort(debuffTb,sortFunc)
	for i=1,#debuffTb do
		table.insert(effectTb,debuffTb[i])
	end
	local flag=false
	for k,v in pairs(effectTb) do
		if(k<=4)then
			local effectIcon
			if(v[3]==2)then
				effectIcon=CCSprite:createWithSpriteFrameName("dwDebuff"..v[1]..".png")
			else
				effectIcon=CCSprite:createWithSpriteFrameName("dwBuff"..v[1]..".png")
			end
			effectIcon:setScale(50/effectIcon:getContentSize().width)
			effectIcon:setPosition(50 + (k - 1)*50,G_VisibleSizeHeight - 130)
			self.bgLayer:addChild(effectIcon,3)
			local lb=GetTTFLabel(v[2],30)
			lb:setAnchorPoint(ccp(1,0))
			lb:setPosition(effectIcon:getContentSize().width - 10,5)
			effectIcon:addChild(lb)
			table.insert(self.buffTb,effectIcon)
		else
			flag=true
		end
	end
	if(flag==true)then
		local buffIcon=CCSprite:createWithSpriteFrameName("pointPic.png")
		buffIcon:setPosition(50 + 4*50,G_VisibleSizeHeight - 130)
		self.bgLayer:addChild(buffIcon,3)
		table.insert(self.buffTb,buffIcon)
		for i=2,3 do
			local pointPic=CCSprite:createWithSpriteFrameName("pointPic.png")
			pointPic:setAnchorPoint(ccp(0,0))
			pointPic:setPosition((i - 1)*9,0)
			buffIcon:addChild(pointPic)
		end
	end
end

function dimensionalWarMapScene:initFunctionBar()
	local functionBarBg=CCSprite:createWithSpriteFrameName("dwFunctionBg.png")
	functionBarBg:setAnchorPoint(ccp(0,0))
	functionBarBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(functionBarBg,10)
	local functionBarBg2=CCSprite:createWithSpriteFrameName("dwFunctionBg.png")
	functionBarBg2:setFlipX(true)
	functionBarBg2:setAnchorPoint(ccp(1,0))
	functionBarBg2:setPosition(G_VisibleSizeWidth,0)
	self.bgLayer:addChild(functionBarBg2,10)
	local function onScout()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		dimensionalWarVoApi:showEventDialog(self.layerNum+1)
	end
	local scoutItem=GetButtonItem("dwFunctionBtn.png","dwFunctionBtn_down.png","dwFunctionBtn_down.png",onScout)
	local scoutSp=CCSprite:createWithSpriteFrameName("Office4.png")
	scoutSp:setScale(0.8)
	scoutSp:setPosition(scoutItem:getContentSize().width/2,scoutItem:getContentSize().height/2 + 15)
	scoutItem:addChild(scoutSp)
	local scoutBtn=CCMenu:createWithItem(scoutItem)
	scoutBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	scoutBtn:setPosition(ccp(70,70))
	self.bgLayer:addChild(scoutBtn,11)
	local scountLb=GetTTFLabel(getlocal("alliance_event_event"),25)
	scountLb:setPosition(ccp(70,30))
	self.bgLayer:addChild(scountLb,11)
	local function onExit()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local exitItem=GetButtonItem("dwFunctionBtn.png","dwFunctionBtn_down.png","dwFunctionBtn_down.png",onExit)
	local exitSp=CCSprite:createWithSpriteFrameName("IconReturn-.png")
	exitSp:setPosition(exitItem:getContentSize().width/2,exitItem:getContentSize().height/2 + 15)
	exitItem:addChild(exitSp)
	local exitBtn=CCMenu:createWithItem(exitItem)
	exitBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	exitBtn:setPosition(ccp(G_VisibleSizeWidth - 70,70))
	self.bgLayer:addChild(exitBtn,11)
	local exitLb=GetTTFLabel(getlocal("exit"),25)
	exitLb:setPosition(ccp(G_VisibleSizeWidth - 70,30))
	self.bgLayer:addChild(exitLb,11)
	local function onBuy(object,name,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(base.serverTime<dimensionalWarFightVoApi:getStartTime())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarLocal_battleNotStart"),30)
			do return end
		end
		if(tag and tag>0)then
			local buffIndex=tag - 200
			self:buySupport(buffIndex)
		end
	end
	self.buyTb={}
	local strSize2 = 17
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="cn" then
		strSize2 =25
	end
	for i=1,3 do
		local posX,key
		if(i==1)then
			posX=G_VisibleSizeWidth/2 - 115
			key="energy"
		elseif(i==2)then
			posX=G_VisibleSizeWidth/2
			key="troops"
		else
			posX=G_VisibleSizeWidth/2 + 115
			key="clearStatus"
		end
		local bg=LuaCCSprite:createWithSpriteFrameName("dwRoundBg.png",onBuy)
		bg:setTag(200 + i)
		bg:setTouchPriority(-(self.layerNum-1)*20-8)
		bg:setScale(100/bg:getContentSize().width)
		bg:setPosition(posX,80)
		self.bgLayer:addChild(bg,10)
		local lb=GetTTFLabel(getlocal("dimensionalWar_buff"..i),strSize2)
		lb:setAnchorPoint(ccp(0.5,0))
		lb:setPosition(posX,5)
		self.bgLayer:addChild(lb,10)
		local costBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
		costBg:setScaleX(120/costBg:getContentSize().width)
		costBg:setScaleY(40/costBg:getContentSize().height)
		costBg:setPosition(posX,45)
		self.bgLayer:addChild(costBg,11)
		local costIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
		costIcon:setPosition(posX - 12,45)
		self.bgLayer:addChild(costIcon,11)
		local costLb=GetTTFLabel(userWarCfg.support[key].cost["gems"],22)
		costLb:setPosition(posX + 12,45)
		self.bgLayer:addChild(costLb,11)
		local supportIcon=CCSprite:createWithSpriteFrameName("dwBuySupport"..i..".png")
		supportIcon:setScale(118/supportIcon:getContentSize().width)
		supportIcon:setPosition(getCenterPoint(bg))
		bg:addChild(supportIcon)
		local numBg=CCSprite:createWithSpriteFrameName("NumBg.png")
		numBg:setPosition(105,105)
		bg:addChild(numBg)
		local limitTime
		if(i==1)then
			limitTime=userWarCfg.support.energy.limit
		elseif(i==2)then
			limitTime=userWarCfg.support.troops.limit
		elseif(i==3)then
			limitTime=userWarCfg.support.clearStatus.limit
		end
		local leftTime=limitTime - dimensionalWarFightVoApi:getBuyTime(i)
		local leftLb=GetTTFLabel(leftTime,25)
		leftLb:setPosition(105,105)
		bg:addChild(leftLb)
		self.buyTb[i]=leftLb
	end
	self.zombieBorder=LuaCCScale9Sprite:createWithSpriteFrameName("dwZombieBorder.png",CCRect(49,49,2,2),function ( ... )end)
	if(dimensionalWarFightVoApi:getPlayerStatus()==1)then
		self.zombieBorder:setVisible(true)
	else
		self.zombieBorder:setVisible(false)
	end
	self.zombieBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.zombieBorder:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(self.zombieBorder,13)
end

function dimensionalWarMapScene:initMap()
	--摆格子
	local groundTexture=spriteController:getTexture("public/dimensionalWar/dimensionalWar.png")
	local groundBatchNode=CCSpriteBatchNode:createWithTexture(groundTexture,90)
	self.bgLayer:addChild(groundBatchNode,1)
	local function onClickGround(object,name,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(tag)then
			local y=tag%10
			local x=math.floor(tag/10)
			self:clickGround(x,y)
		end
	end
	local keyMap={"A","B","C","D","E","F"}
	local startX=30
	local startY=G_VisibleSizeHeight/2 + 250
	for i=1,5 do
		local lb=GetTTFLabel(i,28)
		lb:setColor(ccc3(0,252,255))
		lb:setPosition(15,startY - (i-1)*100 - 50)
		self.bgLayer:addChild(lb)
	end
	for k,v in pairs(keyMap) do
		local lb=GetTTFLabel(v,28)
		lb:setColor(ccc3(0,252,255))
		lb:setPosition(startX + (k-1)*100 + 50,startY + 20)
		self.bgLayer:addChild(lb)
	end

	local explodeLine=dimensionalWarFightVoApi:checkExplode()
	self.groundList={}
	for y,yv in pairs(dimensionalWarFightVoApi:getGroundList()) do
		self.groundList[y]={}
		for x,v in pairs(yv) do
			local groundIcon=LuaCCSprite:createWithSpriteFrameName("dwGround1.png",onClickGround)
			groundIcon:setTag(v.xIndex*10 + v.yIndex)
			groundIcon:setTouchPriority(-(self.layerNum-1)*20-2)
			groundIcon:setPosition(startX + (v.xIndex - 1)*100 + 50,startY - (v.yIndex - 1)*100 - 50)
			groundBatchNode:addChild(groundIcon)
			local explodeIcon=CCSprite:createWithSpriteFrameName("dwGround2.png")
			explodeIcon:setTag(1)
			explodeIcon:setPosition(50,50)
			groundIcon:addChild(explodeIcon)
			local selectIcon=CCSprite:createWithSpriteFrameName("dwGroundBg1.png")
			selectIcon:setTag(2)
			selectIcon:setPosition(50,50)
			selectIcon:setOpacity(0)
			groundIcon:addChild(selectIcon)
			local dangerousLv=self:getDangerousLv(v,explodeLine)
			for i=1,3 do
				local warningIcon=CCSprite:createWithSpriteFrameName("dwGroundBg"..i..".png")
				warningIcon:setTag(i)
				warningIcon:setPosition(50,50)
				if(i==dangerousLv)then
					warningIcon:setVisible(true)
				else
					warningIcon:setVisible(false)
				end
				selectIcon:addChild(warningIcon)
			end
			if(v.explode==2)then
				groundIcon:setOpacity(0)
				selectIcon:setVisible(false)
			elseif(v.explode==1)then
				if(self.explodeRound==nil or self.explodeRound<dimensionalWarFightVoApi:getCurRound())then
					self.explodeGround=groundIcon
					self.explodeRound=dimensionalWarFightVoApi:getCurRound()
					explodeIcon:setVisible(false)
					local pos=dimensionalWarFightVoApi:getPosition()
					if(x==pos[1] and y==pos[2])then
						groundIcon:setOpacity(0)
					else
						selectIcon:setVisible(false)
					end
				end
			else
				explodeIcon:setVisible(false)
				local pos=dimensionalWarFightVoApi:getPosition()
				if(x==pos[1] and y==pos[2])then
					groundIcon:setOpacity(0)
				else
					selectIcon:setVisible(false)
				end
			end
			self.groundList[y][x]=groundIcon
		end
	end
end

function dimensionalWarMapScene:initPlayer()
	local troopIcon=tolua.cast(self.bgLayer:getChildByTag(316),"CCSprite")
	local startX=30
	local startY=G_VisibleSizeHeight/2 + 250
	local pos=dimensionalWarFightVoApi:getPosition()
	local endX,endY=startX + (pos[1] - 1)*100 + 50,startY - (pos[2] - 1)*100 - 50
	if(troopIcon==nil)then
		troopIcon=CCSprite:createWithSpriteFrameName("dwTankIcon.png")
		troopIcon:setTag(316)
		local border=100
		local centerX=troopIcon:getContentSize().width/2
		local centerY=troopIcon:getContentSize().height/2
		local troopBorder=CCSprite:createWithSpriteFrameName("equipSelectedRect.png")
		troopBorder:setScale(100/troopBorder:getContentSize().width)
		troopBorder:setPosition(centerX,centerY)
		troopIcon:addChild(troopBorder)
		for i=1,4 do
			local arrow=CCSprite:createWithSpriteFrameName("dwArrow.png")
			arrow:setTag(i)
			local angle=90*(i - 1)
			arrow:setRotation(angle)
			local startX,startY=centerX + (border/2 + 20)*math.sin(math.rad(angle)),centerY + (border/2 + 20)*math.cos(math.rad(angle))
			arrow:setPosition(startX,startY)
			troopIcon:addChild(arrow)
			local arrowEx,arrowEy=centerX + (border/2 + 40)*math.sin(math.rad(angle)),centerY + (border/2 +40)*math.cos(math.rad(angle))
			local moveTo=CCMoveTo:create(0.3,ccp(arrowEx,arrowEy))
			local moveBack=CCMoveTo:create(0.3,ccp(startX,startY))
			local seq=CCSequence:createWithTwoActions(moveTo,moveBack)
			arrow:runAction(CCRepeatForever:create(seq))
		end
		troopIcon:setPosition(endX,endY)
		self.bgLayer:addChild(troopIcon,3)
	else
		troopIcon:stopAllActions()
		troopIcon:runAction(CCMoveTo:create(0.4,ccp(endX,endY)))
	end
	for i=1,4 do
		local arrow=tolua.cast(troopIcon:getChildByTag(i),"CCSprite")
		local nextX,nextY
		if(arrow)then
			if(i==1)then
				nextX=pos[1]
				nextY=pos[2] - 1
			elseif(i==2)then
				nextX=pos[1] + 1
				nextY=pos[2]
			elseif(i==3)then
				nextX=pos[1]
				nextY=pos[2] + 1
			else
				nextX=pos[1] - 1
				nextY=pos[2]
			end
			if(dimensionalWarFightVoApi:getGroundList()[nextY] and dimensionalWarFightVoApi:getGroundList()[nextY][nextX] and dimensionalWarFightVoApi:getGroundList()[nextY][nextX].explode~=2)then
				arrow:setVisible(true)
			else
				arrow:setVisible(false)
			end
		end
	end
end

--统一处理各种需要刷新地图的数据
function dimensionalWarMapScene:dealEvent(event,data)
	for k,event in pairs(data) do
		if(event=="map" or event=="position")then
			local explodeLine=dimensionalWarFightVoApi:checkExplode()
			for y,yv in pairs(dimensionalWarFightVoApi:getGroundList()) do
				for x,v in pairs(yv) do
					local groundIcon=self.groundList[y][x]
					local explodeIcon=tolua.cast(groundIcon:getChildByTag(1),"CCSprite")
					local selectIcon=tolua.cast(groundIcon:getChildByTag(2),"CCSprite")
					local dangerousLv=self:getDangerousLv(v,explodeLine)
					for i=1,3 do
						local warningIcon=tolua.cast(selectIcon:getChildByTag(i),"CCSprite")
						if(i==dangerousLv)then
							warningIcon:setVisible(true)
						else
							warningIcon:setVisible(false)
						end
					end
					if(v.explode==2)then
						groundIcon:setOpacity(0)
						selectIcon:setVisible(false)
						explodeIcon:setVisible(true)
					elseif(v.explode==1)then
						if(self.explodeRound==nil or self.explodeRound<dimensionalWarFightVoApi:getCurRound())then
							self.explodeGround=groundIcon
							self.explodeRound=dimensionalWarFightVoApi:getCurRound()
							explodeIcon:setVisible(false)
							local pos=dimensionalWarFightVoApi:getPosition()
							if(x==pos[1] and y==pos[2])then
								groundIcon:setOpacity(0)
							else
								selectIcon:setVisible(false)
							end
						end
					else
						explodeIcon:setVisible(false)
						local pos=dimensionalWarFightVoApi:getPosition()
						if(x==pos[1] and y==pos[2])then
							groundIcon:setOpacity(0)
							selectIcon:setVisible(true)
						else
							groundIcon:setOpacity(255)
							selectIcon:setVisible(false)
						end
					end
					self.groundList[y][x]=groundIcon
				end
			end
			if(event=="position")then
				self:initPlayer()
			end
		elseif(event=="survivers")then
			self.surviverNumLb:setString(getlocal("dimensionalWar_surviverNum",{dimensionalWarFightVoApi:getSurvivers()}))
		elseif(event=="playerstatus")then
			if(dimensionalWarFightVoApi:getPlayerStatus()==0)then
				self.statusLb:setString(getlocal("dimensionalWar_status0"))
				self.ecgSp:setColor(G_ColorGreen)
			elseif(dimensionalWarFightVoApi:getPlayerStatus()==1)then
				self.statusLb:setString(getlocal("dimensionalWar_status1"))
				self.ecgSp:setColor(G_ColorGray)
				self.zombieBorder:setVisible(true)
			else
				self.statusLb:setString(getlocal("dimensionalWar_status2"))
				self.ecgSp:setColor(G_ColorGray)
			end
		elseif(event=="buff")then
			self:initBuff()
		elseif(event=="energy")then
			self.energyLb:setString(getlocal("dimensionalWar_energy",{getlocal("scheduleChapter",{dimensionalWarFightVoApi:getEnergy(),userWarCfg.energyMax})}))
		elseif(event=="troop")then
		elseif(event=="buy")then
			for i=1,3 do
				local limitTime
				if(i==1)then
					limitTime=userWarCfg.support.energy.limit
				elseif(i==2)then
					limitTime=userWarCfg.support.troops.limit
				elseif(i==3)then
					limitTime=userWarCfg.support.clearStatus.limit
				end
				local leftTime=limitTime - dimensionalWarFightVoApi:getBuyTime(i)
				self.buyTb[i]:setString(leftTime)
			end
		elseif(event=="over")then
			self.isOver=true
			if(dimensionalWarFightVoApi:getPlayerStatus()==0)then
				self:showSurviveDialog()
			else
				self:showGameOverDialog()
			end
			self:close()
		elseif(event=="closeDialog")then
			if(self.dialogType==4 or self.dialogType==5)then
				self:close()
			elseif(self.dialogType==1)then
				self.smallDialog=nil
				self.dialogType=nil
				if(self.isShow and self.isOver~=true)then
					local status=dimensionalWarFightVoApi:checkActionStatus()
					if(status==0)then
						self:showLoading()
					end
				end
			elseif(self.smallDialog)then
				self.smallDialog=nil
				self.dialogType=nil
			end
		end
	end
end

function dimensionalWarMapScene:showTip(str,isExplode)
	local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,0,2,47),function ()end)
	local bgWidth,bgHeight=G_VisibleSizeWidth - 20,40
	tipBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(bgWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(bgWidth/2,bgHeight))
	tipBg:addChild(lineSp)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(bgWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(bgWidth/2,0))
	tipBg:addChild(lineSp)
	local tipLb=GetTTFLabel(str,25)
	if(isExplode)then
		tipLb:setTag(2)
	else
		tipLb:setTag(1)
	end
	tipLb:setAnchorPoint(ccp(0,0.5))
	tipLb:setPosition(bgWidth + 10,bgHeight/2)
	tipBg:addChild(tipLb)
	tipBg:setOpacity(0)
	tipBg:setAnchorPoint(ccp(0.5,0))
	tipBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 285)
	table.insert(self.tipTb,tipBg)
	tipBg:setVisible(false)
	self.bgLayer:addChild(tipBg,1)
end

function dimensionalWarMapScene:tipAction()
	if(self.tipTb[1]==nil or self.tipVisible)then
		do return end
	end
	self.tipVisible=true
	local tip=tolua.cast(self.tipTb[1],"LuaCCScale9Sprite")
	tip:setVisible(true)
	table.remove(self.tipTb,1)
	local fadeIn=CCFadeIn:create(0.3)
	local speed=150
	local isExplode=false
	local tipLb=tolua.cast(tip:getChildByTag(1),"CCLabelTTF")
	if(tipLb==nil)then
		tipLb=tolua.cast(tip:getChildByTag(2),"CCLabelTTF")
		isExplode=true
	end
	local time=(G_VisibleSizeWidth + tipLb:getContentSize().width)/speed
	local delay
	if(isExplode)then
		delay=CCDelayTime:create(dimensionalWarFightVoApi:getCountDown())
	else
		delay=CCDelayTime:create(time)
	end
	local fadeOut=CCFadeOut:create(0.3)
	local function onActionEnd()
		tipLb:stopAllActions()
		tip:removeFromParentAndCleanup(true)
		self.tipVisible=false
	end
	local callFunc=CCCallFunc:create(onActionEnd)
	local actionArr=CCArray:create()
	actionArr:addObject(fadeIn)
	actionArr:addObject(delay)
	actionArr:addObject(fadeOut)
	actionArr:addObject(callFunc)
	local seq=CCSequence:create(actionArr)
	tip:runAction(seq)
	local bgWidth,bgHeight=G_VisibleSizeWidth - 20,40
	local moveTo=CCMoveTo:create(time,ccp(-10 - tipLb:getContentSize().width,bgHeight/2))
	local function onMove()
		tipLb:setPositionX(bgWidth + 10)
	end
	local callFunc=CCCallFunc:create(onMove)
	local delay=CCDelayTime:create(2)
	local actionArr=CCArray:create()
	actionArr:addObject(moveTo)
	actionArr:addObject(callFunc)
	actionArr:addObject(delay)
	local seq=CCSequence:create(actionArr)
	tipLb:runAction(CCRepeatForever:create(seq))
end

function dimensionalWarMapScene:checkShowExplode(status)
	if(status==0)then
		if(self.explodeMv)then
			if(self.explodeType==2)then
				self.explodeMv:removeFromParentAndCleanup(true)
				self.explodeMv=nil
				self.explodeType=nil
			elseif(self.explodeType==1)then
				do return end
			end
		end
		local explodeLine=dimensionalWarFightVoApi:checkExplode()
		if(explodeLine==nil)then
			do return end
		end
		self.explodeType=1
		self.explodeMv=CCSprite:createWithSpriteFrameName("dwGroundWarning.png")
		self.explodeMv:setAnchorPoint(ccp(0,0))
		self.explodeMv:setOpacity(0)
		if(type(explodeLine)=="string")then
			local keyMap={["A"]=1,["B"]=2,["C"]=3,["D"]=4,["E"]=5,["F"]=6}
			local realLine=keyMap[explodeLine]
			for y,yv in pairs(dimensionalWarFightVoApi:getGroundList()) do
				for x,v in pairs(yv) do
					if(x==realLine and v.explode~=2)then
						local mv=CCSprite:createWithSpriteFrameName("dwGroundWarning.png")
						mv:setPosition(self.groundList[y][x]:getPosition())
						self.explodeMv:addChild(mv)
						local fadeTo1=CCFadeTo:create(0.4,100)
						local fadeTo2=CCFadeTo:create(0.4,255)
						local seq=CCSequence:createWithTwoActions(fadeTo1,fadeTo2)
						mv:runAction(CCRepeatForever:create(seq))
					end
				end
			end
		else
			for y,yv in pairs(dimensionalWarFightVoApi:getGroundList()) do
				if(y==explodeLine)then
					for x,v in pairs(yv) do
						if(v.explode~=2)then
							local mv=CCSprite:createWithSpriteFrameName("dwGroundWarning.png")
							mv:setPosition(self.groundList[y][x]:getPosition())
							self.explodeMv:addChild(mv)
							local fadeTo1=CCFadeTo:create(0.4,100)
							local fadeTo2=CCFadeTo:create(0.4,255)
							local seq=CCSequence:createWithTwoActions(fadeTo1,fadeTo2)
							mv:runAction(CCRepeatForever:create(seq))
						end
					end
				end
			end
		end
		self.bgLayer:addChild(self.explodeMv,2)
		self:showTip(getlocal("dimensionalWar_explodeWarning",{explodeLine}),true)
	elseif(status==1)then
		if(self.explodeMv)then
			if(self.explodeType==1)then
				self.explodeMv:removeFromParentAndCleanup(true)
				self.explodeMv=nil
				self.explodeType=nil
			elseif(self.explodeType==2)then
				do return end
			end
		end
		if(self.smallDialog or self.eventMask)then
			do return end
		end
		local explodeLine,pos=dimensionalWarFightVoApi:checkExplode()
		if(pos==nil)then
			do return end
		end
		self.explodeType=2
		self.explodeMv = CCParticleSystemQuad:create("public/dimensionalWar/dimensionalExplode.plist")
		self.explodeMv.positionType=kCCPositionTypeFree
		local groundIcon=self.groundList[pos[2]][pos[1]]
		self.explodeMv:setPosition(groundIcon:getPosition())
		local delay=CCDelayTime:create(2)
		local function onDelay()
			self.explodeMv:removeFromParentAndCleanup(true)
			self.explodeMv=nil
			self.explodeType=nil
			if(self.eventMask==nil)then
				self:showEventDialog()
			end
		end
		local callFunc=CCCallFunc:create(onDelay)
		local seq=CCSequence:createWithTwoActions(delay,callFunc)
		self.explodeMv:runAction(seq)
		self.bgLayer:addChild(self.explodeMv,2)
		if(self.explodeGround)then
			local explodeIcon=tolua.cast(self.explodeGround:getChildByTag(1),"CCSprite")
			local selectIcon=tolua.cast(self.explodeGround:getChildByTag(2),"CCSprite")
			self.explodeGround:setOpacity(0)
			selectIcon:setVisible(false)
			explodeIcon:setVisible(true)
		end
		self.shakeTick=0
	end
end

function dimensionalWarMapScene:initChat()
	local chatBg,chatMenu=G_initChat(self.bgLayer,self.layerNum,true,10000,10000,150,nil,0,3)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-2)
	chatBg:setIsSallow(true)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	self.chatBg=chatBg

	local function dialogListener(event,data)
        if self.chatBg then
			G_setLastChat(self.chatBg,false,10000,10000)
		end
    end
    self.dialogListener=dialogListener
    eventDispatcher:addEventListener("dimensionalWarMap.chat",self.dialogListener)
end

function dimensionalWarMapScene:clickGround(x,y)
	--不在行动阶段
	if(dimensionalWarFightVoApi:checkActionStatus()~=0)then
		do return end
	end
	--已经移动过了
	if(self.moveRound and self.moveRound>=dimensionalWarFightVoApi:getCurRound())then
		do return end
	end
	--第二次点击，确认行动
	if(self.moveX==x and self.moveY==y)then
		local function callback()
			self.moveX=nil
			self.moveY=nil
			if(self.moveMv)then
				self.moveMv:removeFromParentAndCleanup(true)
				self.moveMv=nil
			end
			self.moveRound=dimensionalWarFightVoApi:getCurRound()
			self:showOperateDialog()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_operateBegin"),30)
		end
		dimensionalWarFightVoApi:move(x,y,callback)
	else
		if(self.moveMv)then
			self.moveMv:removeFromParentAndCleanup(true)
			self.moveMv=nil
		end
		local pos=dimensionalWarFightVoApi:getPosition()
		if(x==pos[1] and y==pos[2])then
			local function onConfirm()
				self.moveRound=dimensionalWarFightVoApi:getCurRound()
				self:showOperateDialog()
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_operateBegin"),30)
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("dimensionalWar_stayConfirm"),nil,self.layerNum+1)
		else
			local xDis=math.abs(x - pos[1])
			local yDis=math.abs(y - pos[2])
			if(xDis + yDis<2)then
				local ground=dimensionalWarFightVoApi:getGroundList()[y][x]
				if(ground.explode==2)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_moveErr2"),30)
					do return end
				end
				local groundIcon=self.groundList[y][x]
				self.moveMv=CCSprite:createWithSpriteFrameName("dwTankIcon.png")
				local startX=30
				local startY=G_VisibleSizeHeight/2 + 250
				self.moveMv:setPosition(startX + (x - 1)*100 + 50,startY - (y - 1)*100 - 50)
				self.bgLayer:addChild(self.moveMv,3)
				self.moveMv:setOpacity(180)
				local fade1=CCFadeTo:create(0.8,80)
				local fade2=CCFadeTo:create(0.8,180)
				local seq=CCSequence:createWithTwoActions(fade1,fade2)
				self.moveMv:runAction(CCRepeatForever:create(seq))
				self.moveX=x
				self.moveY=y
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_moveErr1"),30)
			end
		end
	end
end

function dimensionalWarMapScene:showOperateDialog()
	if(self.smallDialog or self.layerNum==nil)then
		do return end
	end
	self.dialogType=1
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	--操作面板和loading面板不能挡住下面的操作条，所以层数和地图一样
	self.smallDialog:init(self.layerNum,self.bgLayer)
end

function dimensionalWarMapScene:showEventDialog()
	if(self.smallDialog or self.layerNum==nil)then
		do return end
	end
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_eventBegin"),30)
	self.dialogType=2
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	--事件面板不能挡住下面的操作条，所以层数和地图一样
	self.smallDialog:init(self.layerNum,self.bgLayer)
end

function dimensionalWarMapScene:showZombieDialog()
	if(self.smallDialog or self.layerNum==nil)then
		do return end
	end
	self.dialogType=3
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	self.smallDialog:init(self.layerNum + 1)
end

function dimensionalWarMapScene:showGameOverDialog()
	if(self.smallDialog)then
		self.smallDialog:close()
	end
	self.dialogType=4
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	self.smallDialog:init(self.layerNum + 1)
end

function dimensionalWarMapScene:showSurviveDialog()
	if(self.smallDialog)then
		self.smallDialog:close()
	end
	self.dialogType=5
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	self.smallDialog:init(self.layerNum + 1)
end

function dimensionalWarMapScene:showLoading()
	if(self.smallDialog or self.layerNum==nil)then
		do return end
	end
	self.dialogType=6
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
	self.smallDialog=dimensionalWarSmallDialog:new(self.dialogType)
	--操作面板和loading面板不能挡住下面的操作条，所以层数和地图一样
	self.smallDialog:init(self.layerNum,self.bgLayer)
end

function dimensionalWarMapScene:showMask()
	if(self.beginMask)then
		local countDownLb=tolua.cast(self.beginMask:getChildByTag(101),"CCLabelTTF")
		if(countDownLb)then
			countDownLb:setString(getlocal("second_num",{dimensionalWarFightVoApi:getStartTime() - base.serverTime}))
		end
		do return end
	end
	self.beginMask=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function ( ... )end)
	self.beginMask:setOpacity(180)
	self.beginMask:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.beginMask:setTouchPriority(-(self.layerNum-1)*20 - 7)
	self.beginMask:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(self.beginMask,9)
	local countDownTitle=GetTTFLabel(getlocal("serverwar_battleCountDown"),35)
	countDownTitle:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 30)
	self.beginMask:addChild(countDownTitle)
	local countDownLb=GetTTFLabel(getlocal("second_num",{dimensionalWarFightVoApi:getStartTime() - base.serverTime}),42)
	countDownLb:setColor(G_ColorYellowPro)
	countDownLb:setTag(101)
	countDownLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 30)
	self.beginMask:addChild(countDownLb)
end

function dimensionalWarMapScene:checkShowEventMask(startTime)
	if(self.eventMask)then
		local countDownLb=tolua.cast(self.eventMask:getChildByTag(101),"CCLabelTTF")
		if(countDownLb)then
			countDownLb:setString(getlocal("second_num",{startTime + userWarCfg.roundAccountTime - base.serverTime}))
		end
		do return end
	end
	if(self.smallDialog and (self.dialogType==3 or self.dialogType==4 or self.dialogType==5))then
		do return end
	end
	self.eventMask=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function ( ... )end)
	self.eventMask:setOpacity(180)
	self.eventMask:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.eventMask:setTouchPriority(-(self.layerNum-1)*20 - 7)
	self.eventMask:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:addChild(self.eventMask,9)
	local countDownTitle=GetTTFLabel(getlocal("dimensionalWar_eventMaskCD"),35)
	countDownTitle:setColor(G_ColorYellowPro)
	countDownTitle:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 30)
	self.eventMask:addChild(countDownTitle)
	local countDownLb=GetTTFLabel(getlocal("second_num",{startTime + userWarCfg.roundAccountTime - base.serverTime}),42)
	countDownLb:setTag(101)
	countDownLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 30)
	self.eventMask:addChild(countDownLb)
	local countDownDesc=GetTTFLabelWrap(getlocal("dimensionalWar_eventMaskDesc"),30,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	countDownDesc:setAnchorPoint(ccp(0.5,1))
	countDownDesc:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 60)
	self.eventMask:addChild(countDownDesc)
end

function dimensionalWarMapScene:buySupport(buffIndex)
	local limitTime,costGem,cantFlag,buyStr
	local oldEnerge=dimensionalWarFightVoApi:getEnergy()
	if(buffIndex==1)then
		limitTime=userWarCfg.support.energy.limit
		costGem=userWarCfg.support.energy.cost["gems"]
		if(dimensionalWarFightVoApi:getEnergy()>=userWarCfg.energyMax)then
			cantFlag=true
		elseif(dimensionalWarFightVoApi:getEnergy() + userWarCfg.support.energy.addEnergy>userWarCfg.energyMax)then
			buyStr=getlocal("dimensionalWar_buyBuffConfirm1",{costGem,userWarCfg.support.energy.addEnergy}).."\n"..getlocal("dimensionalWar_buyBuffConfirm1_1",{dimensionalWarFightVoApi:getEnergy() + userWarCfg.support.energy.addEnergy - userWarCfg.energyMax})
		else
			buyStr=getlocal("dimensionalWar_buyBuffConfirm1",{costGem,userWarCfg.support.energy.addEnergy})
		end
	elseif(buffIndex==2)then
		limitTime=userWarCfg.support.troops.limit
		costGem=userWarCfg.support.troops.cost["gems"]
		local totalTank=0
		local fullTankTb=tankVoApi:getTanksTbByType(33)
		for k,v in pairs(fullTankTb) do
			if(v[2])then
				totalTank=totalTank + v[2]
			end
		end
		local leftTank=0
		local curTankTb=dimensionalWarFightVoApi:getTroops()
		if(curTankTb and curTankTb.troops)then
			for k,v in pairs(curTankTb.troops) do
				if(v[2])then
					leftTank=leftTank + v[2]
				end
			end
		end
		if(leftTank>=totalTank)then
			cantFlag=true
		else
			buyStr=getlocal("dimensionalWar_buyBuffConfirm2",{costGem})
		end
	elseif(buffIndex==3)then
		limitTime=userWarCfg.support.clearStatus.limit
		costGem=userWarCfg.support.clearStatus.cost["gems"]
		local buffData=dimensionalWarFightVoApi:getBuffData()
		if(buffData.del and SizeOfTable(buffData.del)>0)then
			buyStr=getlocal("dimensionalWar_buyBuffConfirm3",{costGem})
		else
			cantFlag=true
		end
	end
	local buyTime=dimensionalWarFightVoApi:getBuyTime(buffIndex)
	if(buyTime>=limitTime)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage14004"),30)
		do return end
	end
	if(cantFlag)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_buyBuffCant"..buffIndex),30)
		do return end
	end
	if costGem>playerVoApi:getGems() then
		GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
	else
		local function onConfirm()
			local function callback()
				local buyTime=dimensionalWarFightVoApi:getBuyTime(buffIndex)
				local leftTime=limitTime - buyTime
				if(buffIndex==1)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_buyBuffOver"..buffIndex,{dimensionalWarFightVoApi:getEnergy() - oldEnerge,leftTime}),30)
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_buyBuffOver"..buffIndex,{leftTime}),30)
				end
			end
			dimensionalWarFightVoApi:buy(buffIndex,callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),buyStr,nil,self.layerNum+1)
	end			
end

--获取地块的危险程度
--param groundVo: 地块的数据
--param explodeLine: 本回合要爆炸哪条线
--return: 1 or 2 or 3,数字越大危险度越高
function dimensionalWarMapScene:getDangerousLv(groundVo,explodeLine)
	local keyMap={"A","B","C","D","E","F"}
	local a
	if(explodeLine==groundVo.yIndex or explodeLine==keyMap[groundVo.xIndex])then
		a=1
	else
		a=0
	end
	local l=groundVo.surviver
	local m=groundVo.zombie
	local n=groundVo.trap
	local result=80*a + 3*l + 7*m + 2*n
	if(result>100)then
		return 3
	elseif(result>20)then
		return 2
	else
		return 1
	end
end

function dimensionalWarMapScene:tick()
	if self.chatBg then
		G_setLastChat(self.chatBg,false,10000,10000)
	end
	if(base.serverTime<dimensionalWarFightVoApi:getStartTime())then
		self:showMask()
		do return end
	elseif(self.beginMask)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_battleBegin"),30)
		self.beginMask:removeFromParentAndCleanup(true)
		self.beginMask=nil
		self:showTip(getlocal("dimensionalWar_action"))
	end
	if(self.countDown==0)then
		local status=dimensionalWarFightVoApi:checkActionStatus()
		self:checkShowExplode(status)
		if(status==0)then
			local curRound=dimensionalWarFightVoApi:getCurRound()
			if curRound > userWarCfg.roundMax and self.isOver == nil then
				if not self.sWaitTime then
					self.sWaitTime = 1
				else
					self.sWaitTime = self.sWaitTime + 1
				end
				if self.sWaitTime == 3 then--backstage21104
					if(self.smallDialog and self.dialogType==2)then
						self.smallDialog:close()
					end
					if(self.eventMask)then
						self.eventMask:removeFromParentAndCleanup(true)
						self.eventMask=nil
					end
					local function closeHandle( )
						if G_checkClickEnable()==false then
							do return end
						else
							base.setWaitTime=G_getCurDeviceMillTime()
						end
						PlayEffect(audioCfg.mouseClick)
						self:close()
					end 
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage21104"),nil,self.layerNum + 1,nil,closeHandle)
				end
				do return end
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_roundBegin",{curRound}),30)
			self.countDown=dimensionalWarFightVoApi:getCountDown()
			self.roundLb:setString(getlocal("plat_war_cur_round",{curRound}))
			self:showTip(getlocal("dimensionalWar_action"))
			if(self.smallDialog and self.dialogType==2)then
				self.smallDialog:close()
			end
			if(self.eventMask)then
				self.eventMask:removeFromParentAndCleanup(true)
				self.eventMask=nil
			end
		else
			if(self.smallDialog and self.dialogType==1)then
				self.smallDialog:close()
			else
				local countDown=dimensionalWarFightVoApi:getCountDown()
				if(dimensionalWarFightVoApi:getCurRound()==dimensionalWarFightVoApi:getZombieRound() and countDown<5 and status==1)then
					if(self.smallDialog and self.dialogType==2)then
						self.smallDialog:close()
					end				
					self:showZombieDialog()
				end
			end
			local curRound=dimensionalWarFightVoApi:getCurRound()
			local startTime=dimensionalWarFightVoApi:getStartTime() + (curRound - 1)*(userWarCfg.roundTime + userWarCfg.roundAccountTime) + userWarCfg.roundTime
			if(self.showTime>=startTime)then
				self:checkShowEventMask(startTime)
			else
				if(self.eventMask==nil and self.explodeType==nil and self.smallDialog==nil and dimensionalWarFightVoApi:getPlayerStatus()<2)then
					self:showEventDialog()
				end
			end
		end
		self.moveX=nil
		self.moveY=nil
		if(self.moveMv)then
			self.moveMv:removeFromParentAndCleanup(true)
			self.moveMv=nil
		end
	else
		self.countDown=self.countDown - 1
		self.countDownLb:setString(getlocal("dimensionalWar_countDown",{self.countDown}))
		self:tipAction()
		if(self.moveRound==dimensionalWarFightVoApi:getCurRound() and self.smallDialog==nil)then
			if(dimensionalWarFightVoApi:getActionRound()==nil or dimensionalWarFightVoApi:getActionRound()<dimensionalWarFightVoApi:getCurRound())then
				self:showOperateDialog()
			else
				self:showLoading()
			end
		end
	end
	if(dimensionalWarFightVoApi:getPlayerStatus()==1 and self.zombieBorder:isVisible()==false)then
		self.zombieBorder:setVisible(true)
	end
end

function dimensionalWarMapScene:fastTick()
	if(self.shakeTick)then
		self.shakeTick=self.shakeTick + 1
		if(self.shakeTick>40)then
			self.bgLayer:setPosition(0,0)
			self.shakeTick=nil
		else
			local rndx=5 - (deviceHelper:getRandom()/100)*10
			local rndy=5 - (deviceHelper:getRandom()/100)*10
			self.bgLayer:setPosition(ccp(rndx,rndy))
		end
	end
end

function dimensionalWarMapScene:close()
	self.isShow=false
	if(self.smallDialog and self.dialogType~=4 and self.dialogType~=5)then
		self.smallDialog:close()
		self.smallDialog=nil
	end
	self.bgLayer:stopAllActions()
	for k,v in pairs(self.tipTb) do
		if(v.stopAllActions)then
			v:stopAllActions()
		end
	end
	self.tipTb={}
	base:removeFromNeedRefresh(self)
	self.layerNum=nil
	self.chatBg=nil
	self.groundList=nil
	self.moveMv=nil
	self.moveX=nil
	self.moveY=nil
	self.smallDialog=nil
	self.dialogType=nil
	self.operateType=nil
	self.explodeMv=nil
	self.explodeType=nil
	self.tipVisible=false
	self.buffTb=nil
	self.buyTb=nil
	self.beginMask=nil
	self.shakeTick=nil
	self.groundList=nil
	base.pauseSync=false
	self.explodeRound=nil
	self.zombieBorder=nil
	self.moveRound=nil
	self.eventMask=nil
	self.isOver=nil
	eventDispatcher:removeEventListener("dimensionalWar.battle",self.eventListener)
	self.eventListener=nil
	eventDispatcher:removeEventListener("dimensionalWarMap.chat",self.dialogListener)
	self.dialogListener=nil
	spriteController:removeTexture("public/dimensionalWar/dimensionalWarBg.jpg")
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
end