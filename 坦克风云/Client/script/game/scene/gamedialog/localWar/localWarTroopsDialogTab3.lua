--区域战部队面板的增益buff页签
localWarTroopsDialogTab3={}
function localWarTroopsDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.bgLayer=nil
    nc.layerNum=nil
    nc.buffList=nil
    return nc
end

function localWarTroopsDialogTab3:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.buffList=self:getAllBuff()
    self:initTableView()
	local function eventListener(event,data)
        self:dealEvent(event,data)
    end
    self.eventListener=eventListener
    eventDispatcher:addEventListener("localWar.battle",eventListener)
    return self.bgLayer
end

function localWarTroopsDialogTab3:initTableView()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 210),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,40)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(40)
end

function localWarTroopsDialogTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.buffList
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(580,130)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function onClickCell(object,fn,tag)
			self:showBuffDesc(tag)
		end
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),onClickCell)
		background:setTag(idx + 1)
		background:setTouchPriority(-(self.layerNum-1)*20 - 2)
		background:setContentSize(CCSizeMake(580,120))
		background:setPosition(290,65)
		cell:addChild(background)
		local buffData=self.buffList[idx + 1]
		local icon
		if(buffData.enabled)then
			icon=CCSprite:createWithSpriteFrameName("localWarBuff"..buffData.type..".png")
		else
			icon=GraySprite:createWithSpriteFrameName("localWarBuff"..buffData.type..".png")
		end
		icon:setPosition(60,65)
		cell:addChild(icon)
		local titleLb=GetTTFLabel(getlocal("local_war_buffTitle"..buffData.type),28)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(120,100))
		cell:addChild(titleLb)
		local buffStr,buffColor
		if(buffData.enabled)then
			local buffStrTb={}
			for buffID,buffValue in pairs(buffData.buff) do
				local buffName=getlocal(buffEffectCfg[buffID].name)
				table.insert(buffStrTb,getlocal("accessory_addAtt",{buffName,(buffValue*100).."%%"}))
			end
			buffStr=table.concat(buffStrTb,", ")
			buffColor=G_ColorWhite
		else
			buffStr=getlocal("not_activated")
			buffColor=G_ColorRed
		end
		local desc=GetTTFLabelWrap(buffStr,25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desc:setColor(buffColor)
		desc:setAnchorPoint(ccp(0,0.5))
		desc:setPosition(120,50)
		cell:addChild(desc)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then        
	end
end

function localWarTroopsDialogTab3:dealEvent(event,data)
	if(data.type=="city" and self.tv and self.tv.reloadData)then
		self.buffList=self:getAllBuff()
		self.tv:reloadData()
	end
end

function localWarTroopsDialogTab3:getAllBuff()
	local buffList={}
	local selfAid=tonumber(playerVoApi:getPlayerAid())
	if(localWarVoApi:getOwnCityInfo()==nil or localWarVoApi:getOwnCityInfo().aid==nil or tonumber(localWarVoApi:getOwnCityInfo().aid)~=selfAid)then
		--进攻军团越多，进攻者会享受攻击血量加成
		if(localWarFightVoApi:getAllianceList())then
			local attackerNum=#(localWarFightVoApi:getAllianceList())
			if(attackerNum>0)then
				local percent=0.05*attackerNum
				table.insert(buffList,{type=1,enabled=true,buff={[100]=percent,[108]=percent}})
			else
				table.insert(buffList,{type=1,enabled=false,buff={}})
			end
		else
			table.insert(buffList,{type=1,enabled=false,buff={}})
		end
	else
		table.insert(buffList,{type=1,enabled=false,buff={}})
	end
	--连续占领王城，其他进攻军团有攻击血量加成
	if(localWarVoApi:getOwnCityInfo() and localWarVoApi:getOwnCityInfo().aid and tonumber(localWarVoApi:getOwnCityInfo().aid)>0 and selfAid~=tonumber(localWarVoApi:getOwnCityInfo().aid))then
		if(localWarVoApi:getOwnCityInfo().wcount)then
			local wcount=tonumber(localWarVoApi:getOwnCityInfo().wcount)
			if(wcount>0)then
				local percent=G_keepNumber(wcount/(wcount + 5),2)
				table.insert(buffList,{type=2,enabled=true,buff={[100]=percent,[108]=percent}})
			else
				table.insert(buffList,{type=2,enabled=false,buff={}})
			end
		end
	else
		table.insert(buffList,{type=2,enabled=false,buff={}})
	end
	--占领城市的buff
	local cityBuffList={}
	for k,v in pairs(localWarFightVoApi:getCityList()) do
		if(v.cfg.buffType and v.allianceID==selfAid)then
			if(cityBuffList[v.cfg.buffType])then
				for buffID,buffValue in pairs(v.cfg.buff) do
					cityBuffList[v.cfg.buffType][buffID]=cityBuffList[v.cfg.buffType][buffID] + buffValue
				end
			else
				cityBuffList[v.cfg.buffType]={}
				for buffID,buffValue in pairs(v.cfg.buff) do
					cityBuffList[v.cfg.buffType][buffID]=buffValue
				end
			end
		end
	end
	for buffType,buffData in pairs(cityBuffList) do
		table.insert(buffList,{type=2 + buffType,enabled=true,buff=buffData})
	end
	local function sortFunc(a,b)
		return a.type<b.type
	end
	table.sort(buffList,sortFunc)
	for i=3,5 do
		local flag=false
		for k,v in pairs(buffList) do
			if(v.type==i)then
				flag=true
				break
			end
		end
		if(flag==false)then
			table.insert(buffList,{type=i,enabled=false,buff={}})
		end
	end
	return buffList
end

function localWarTroopsDialogTab3:showBuffDesc(id)
	local function hideBuffDesc()
		if(self.buffLayer)then
			self.buffLayer:removeFromParentAndCleanup(true)
			self.buffLayer=nil
		end
	end
	if(self.buffLayer)then
		hideBuffDesc()
	end
	self.buffLayer=CCLayer:create()
	local mask=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,10,10),hideBuffDesc)
	mask:setTouchPriority(-(self.layerNum-1)*20 - 9)
	mask:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	mask:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.buffLayer:addChild(mask)
	local buffData=self.buffList[id]
	local descLb=GetTTFLabelWrap(getlocal("local_war_buffDesc"..buffData.type),25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local lbHeight=descLb:getContentSize().height
	local panelHeight=220 + lbHeight
	local panel=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),hideBuffDesc)
	panel:setContentSize(CCSizeMake(500,panelHeight))
	panel:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.buffLayer:addChild(panel)
	local icon=CCSprite:createWithSpriteFrameName("localWarBuff"..buffData.type..".png")
	icon:setPosition(80,panelHeight - 100)
	panel:addChild(icon)
	local nameLb=GetTTFLabel(getlocal("local_war_buffTitle"..buffData.type),28)
	nameLb:setColor(G_ColorYellowPro)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(150,panelHeight - 100)
	panel:addChild(nameLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(500/lineSp:getContentSize().width)
	lineSp:setPosition(250,panelHeight - 100 - 60)
	panel:addChild(lineSp)
	local descLb=GetTTFLabelWrap(getlocal("local_war_buffDesc"..buffData.type),25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(30,panelHeight - 100 - 60 - 10)
	panel:addChild(descLb)
	self.bgLayer:addChild(self.buffLayer,1)
end

function localWarTroopsDialogTab3:dispose()
	eventDispatcher:removeEventListener("localWar.battle",self.eventListener)
	self.tv=nil
	self.buffList=nil
end