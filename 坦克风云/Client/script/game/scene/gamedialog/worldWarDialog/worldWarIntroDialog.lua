--世界争霸说明面板
worldWarIntroDialog=commonDialog:new()

function worldWarIntroDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function worldWarIntroDialog:resetTab()
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 35))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 95))
end

function worldWarIntroDialog:initTableView()
	self.serverList={}
	for k,v in pairs(worldWarVoApi:getServerList()) do
		table.insert(self.serverList,v)
	end

	local posY=G_VisibleSizeHeight - 110
	local function nilFunc()
	end
	local titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20,20,10,10),nilFunc)
	titleBg1:setContentSize(CCSizeMake(titleBg1:getContentSize().width,45))
	titleBg1:setScaleX((G_VisibleSizeWidth - 60)/titleBg1:getContentSize().width)
	titleBg1:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(titleBg1)

	local title1=GetTTFLabel(getlocal("world_war_introTitle1"),25)
	title1:setColor(G_ColorYellowPro)
	title1:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(title1)

	local tv1Height=math.ceil((#(self.serverList))/2) * 80
	if(tv1Height>430)then
		tv1Height=430
	end
	local function callback1(...)
		return self:eventHandler1(...)
	end
	local hd=LuaEventHandler:createHandler(callback1)
	posY=posY - 25 - tv1Height
	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,tv1Height),nil)
	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv1:setPosition(30,posY)
	self.tv1:setMaxDisToBottomOrTop(20)
	self.bgLayer:addChild(self.tv1)

	posY = posY - 25
	local titleBg2=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20,20,10,10),nilFunc)
	titleBg2:setContentSize(CCSizeMake(titleBg2:getContentSize().width,45))
	titleBg2:setScaleX((G_VisibleSizeWidth - 60)/titleBg2:getContentSize().width)
	titleBg2:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(titleBg2)

	local title2=GetTTFLabel(getlocal("shuoming"),25)
	title2:setColor(G_ColorYellowPro)
	title2:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(title2)

	local descList={getlocal("serverwar_help_title1"),getlocal("world_war_introContent1"),getlocal("serverwar_help_title2"),getlocal("world_war_introContent2"),getlocal("world_war_introContent3"),getlocal("world_war_introTitle2"),getlocal("world_war_introContent4"),getlocal("BossBattle_ground"),getlocal("world_war_introContent5"),getlocal("serverwar_help_title3"),getlocal("world_war_introContent6"),getlocal("serverwar_help_title4"),getlocal("world_war_introContent7"),getlocal("award"),getlocal("world_war_introContent8")}
	self.descColorList={G_ColorGreen,nil,G_ColorGreen,nil,G_ColorRed,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
	self.descLbList={}
	for k,v in pairs(descList) do
		local lb=GetTTFLabelWrap(v,25,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.descLbList[k]=lb
	end
	local function callback2(...)
		return self:eventHandler2(...)
	end
	local hd=LuaEventHandler:createHandler(callback2)
	posY = posY - 25
	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,posY - 30),nil)
	self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv2:setPosition(30,30)
	self.tv2:setMaxDisToBottomOrTop(20)
	self.bgLayer:addChild(self.tv2)
end

function worldWarIntroDialog:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.ceil((#(self.serverList))/2)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,80)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function nilFunc()
		end
		for i=1,2 do
			if(self.serverList[idx*2 + i])then
				local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),nilFunc)
				nameBg:setContentSize(CCSizeMake(250,60))
				local posX
				if(i==1)then
					posX=(G_VisibleSizeWidth - 60)/4
				else
					posX=(G_VisibleSizeWidth - 60)*3/4
				end
				nameBg:setPosition(posX,40)
				local serverNameLb=GetTTFLabel(self.serverList[idx*2 + i][2],23)
				serverNameLb:setPosition(getCenterPoint(nameBg))
				nameBg:addChild(serverNameLb)
				cell:addChild(nameBg)
			end
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

function worldWarIntroDialog:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.descLbList
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,self.descLbList[idx + 1]:getContentSize().height + 10)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		cell:addChild(self.descLbList[idx + 1])
		self.descLbList[idx + 1]:setAnchorPoint(ccp(0,0.5))
		self.descLbList[idx + 1]:setPosition(0,(self.descLbList[idx + 1]:getContentSize().height + 10)/2)
		if(self.descColorList[idx + 1])then
			self.descLbList[idx + 1]:setColor(self.descColorList[idx + 1])
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

