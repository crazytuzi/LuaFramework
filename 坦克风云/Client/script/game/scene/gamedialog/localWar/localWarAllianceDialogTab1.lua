localWarAllianceDialogTab1={}

function localWarAllianceDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
	self.kingCity={}
	self.list={}

	return nc
end



function localWarAllianceDialogTab1:updateList()
	local selfAlliance=allianceVoApi:getSelfAlliance()
	local selfID
	if selfAlliance and selfAlliance.aid then
		selfID=selfAlliance.aid
	end
	
	local players=localWarFightVoApi:getPlayers()
	local battleMemNumTab={}
	for k,v in pairs(players) do
		if v and v.allianceID then
			if battleMemNumTab[v.allianceID] then
				battleMemNumTab[v.allianceID]=battleMemNumTab[v.allianceID]+1
			else
				battleMemNumTab[v.allianceID]=1
			end
		end
	end
	local cityList=localWarFightVoApi:getCityList()
	local occupiedNumTab={}
	local occupiedBaseNumTab={}
	for k,v in pairs(cityList) do
		if v and v.allianceID then
			if occupiedNumTab[v.allianceID] then
				occupiedNumTab[v.allianceID]=occupiedNumTab[v.allianceID]+1
			else
				occupiedNumTab[v.allianceID]=1
			end
			if v.cfg.type==1 then
				if occupiedBaseNumTab[v.allianceID] then
					occupiedBaseNumTab[v.allianceID]=occupiedBaseNumTab[v.allianceID]+1
				else
					occupiedBaseNumTab[v.allianceID]=1
				end
			end
		end
	end

	local kingCityData=localWarFightVoApi:getCity(localWarMapCfg.capitalID)
	local emptyStr=getlocal("alliance_info_content")
	self.kingCity={maxHp=kingCityData.cfg.hp,hp=kingCityData.hp,name=emptyStr,leaderName=emptyStr,battleMemNum=0,occupiedNum=0,occupiedBaseNum=0}
	local kingAllianceData=localWarFightVoApi:getDefenderAlliance()
	if kingAllianceData and kingAllianceData.id then
		if kingAllianceData.name and kingAllianceData.name~="" then
			self.kingCity.name=kingAllianceData.name
		end
		if kingAllianceData.commander and kingAllianceData.commander~="" then
			self.kingCity.leaderName=kingAllianceData.commander
		end
		self.kingCity.battleMemNum=battleMemNumTab[kingAllianceData.id] or 0
		self.kingCity.occupiedNum=occupiedNumTab[kingAllianceData.id] or 0
		self.kingCity.occupiedBaseNum=occupiedBaseNumTab[kingAllianceData.id] or 0
	end

	self.list={}
	local allianceList=localWarFightVoApi:getAllianceList()
	for k,v in pairs(allianceList) do
		if v and v.id then
			if kingAllianceData and kingAllianceData.id and kingAllianceData.id==v.id then
			else
				local itemData={name=emptyStr,leaderName=emptyStr,battleMemNum=0,occupiedNum=0}
				if v.name and v.name~="" then
					itemData.name=v.name
				end
				if v.commander and v.commander~="" then
					itemData.leaderName=v.commander
				end
				if battleMemNumTab[v.id] then
					itemData.battleMemNum=battleMemNumTab[v.id]
				end
				if occupiedNumTab[v.id] then
					itemData.occupiedNum=occupiedNumTab[v.id]
				end
				if occupiedBaseNumTab[v.id] then
					itemData.occupiedBaseNum=occupiedBaseNumTab[v.id]
				end
				-- local isDefeat=true
				-- local cityID=localWarMapCfg.baseCityID[side]
				-- if cityID then
				-- 	local cityData=localWarFightVoApi:getCity(cityID)
				-- 	if cityData and cityData.allianceID and cityData.allianceID==v.id then
				-- 		isDefeat=false
				-- 	end
				-- end
				-- itemData.isDefeat=isDefeat
				local isDefeat=false
				if itemData.occupiedBaseNum==nil or itemData.occupiedBaseNum==0 then
					isDefeat=true
				end
				local side=v.side
				if side and side<=4 then
					itemData.sortId=side
					if selfID and selfID==v.id then
						itemData.sortId=-1000
					else
						if isDefeat==true then
							itemData.sortId=side+10
						else
							if itemData.occupiedNum then
								itemData.sortId=side-5*itemData.occupiedNum
							end
						end
					end
				end
				table.insert(self.list,itemData)
			end
		end
	end
	if self.list and SizeOfTable(self.list)>0 then
		local function sortFunc(a,b)
			if a and b and a.sortId and b.sortId then
				return a.sortId<b.sortId
			end
		end
		table.sort(self.list,sortFunc)
	end

end

function localWarAllianceDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:updateList()
	self:initHeader()
	self:initTableView()
	return self.bgLayer
end

function localWarAllianceDialogTab1:initHeader()
	local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
	headBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,220))
	headBg:setAnchorPoint(ccp(0.5,1))
	headBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
	self.bgLayer:addChild(headBg,1)

	local bgWidth=headBg:getContentSize().width
	local bgHeight=headBg:getContentSize().height

	-- local kingSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
	local kingSpPic=localWarMapCfg.cityCfg[localWarMapCfg.capitalID].icon
	local kingSp=CCSprite:createWithSpriteFrameName(kingSpPic)
	local spPosX=bgWidth-kingSp:getContentSize().width/2-80
	kingSp:setPosition(ccp(spPosX,bgHeight/2))
	kingSp:setScale(0.9)
	headBg:addChild(kingSp,1)
	local function nilFunc()
	end
	local scheduleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc)
	scheduleBg:setContentSize(CCSizeMake(200,40))
	scheduleBg:setPosition(getCenterPoint(kingSp))
	kingSp:addChild(scheduleBg,1)

	local lbPosX=15
	local posY=30
	local spaceY=35
	local kingAlliance=self.kingCity.name
	local kingAllianceLeader=self.kingCity.leaderName
	local defenderNum=self.kingCity.battleMemNum
	local occupiedNum=self.kingCity.occupiedNum
	local occupiedBaseNum=self.kingCity.occupiedBaseNum
	local curValue=self.kingCity.hp
	local totleValue=self.kingCity.maxHp
	local lbTab={
		{getlocal("local_war_king_city"),28,ccp(0,0.5),ccp(lbPosX,bgHeight-40),headBg,1,G_ColorYellowPro},
		{getlocal("local_war_alliance_belongs",{kingAlliance}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*3),headBg,1,G_ColorWhite},
		{getlocal("local_war_alliance_heads",{kingAllianceLeader}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*2),headBg,1,G_ColorWhite},
		{getlocal("local_war_alliance_defender",{defenderNum}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY),headBg,1,G_ColorWhite},
		{getlocal("local_war_alliance_occupied_area",{occupiedNum}),25,ccp(0,0.5),ccp(lbPosX,posY),headBg,1,G_ColorWhite},
		{getlocal("local_war_alliance_levee_value"),25,ccp(0.5,0.5),ccp(spPosX,posY),headBg,1,G_ColorWhite},
		{getlocal("scheduleChapter",{curValue,totleValue}),30,ccp(0.5,0.5),getCenterPoint(kingSp),kingSp,2,G_ColorYellowPro},
	}
	for k,v in pairs(lbTab) do
		local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
		local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
	end

	local hSpace=65
	if occupiedBaseNum and occupiedBaseNum>0 then
		for i=1,occupiedBaseNum do
			-- local baseSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
			local baseSp=CCSprite:createWithSpriteFrameName(localWarMapCfg.cityCfg["a1"].icon)
			baseSp:setScale(0.5)
			local bx=bgWidth-baseSp:getContentSize().width/2*0.6
			local by=(bgHeight-hSpace*2)/2+(i-1)*hSpace
			baseSp:setPosition(ccp(bx,by))
			headBg:addChild(baseSp,1)
		end
	end

end

function localWarAllianceDialogTab1:initTableView()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-420),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,30)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end
function localWarAllianceDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.list)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth-60,200)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local lbPosX=15
		local posY=30
		local spaceY=35
		local cityData=self.list[idx+1]
		local allianceName=cityData.name
		local allianceLeader=cityData.leaderName
		local battleMemNum=cityData.battleMemNum
		local occupiedNum=cityData.occupiedNum
		local occupiedBaseNum=cityData.occupiedBaseNum or 0
		local selfAlliance=allianceVoApi:getSelfAlliance()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		local hei=200-5
		local backSprie
		if idx==0 and selfAlliance and selfAlliance.name==allianceName then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
		else
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		end
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, hei))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setPosition(ccp(0,5))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)

		local bgWidth=backSprie:getContentSize().width
		local bgHeight=backSprie:getContentSize().height
		local lbTab={
			{allianceName,28,ccp(0,0.5),ccp(lbPosX,bgHeight-40),backSprie,1,G_ColorYellowPro},
			{getlocal("local_war_alliance_heads",{allianceLeader}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*2),backSprie,1,G_ColorWhite},
			{getlocal("local_war_alliance_battle_member_num",{battleMemNum}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY),backSprie,1,G_ColorWhite},
			{getlocal("local_war_alliance_occupied_area",{occupiedNum}),25,ccp(0,0.5),ccp(lbPosX,posY),backSprie,1,G_ColorWhite},
		}
		for k,v in pairs(lbTab) do
			local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
			local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
		end

		local midX=bgWidth-120
		local midY=bgHeight/2
		local spaceX=110
		local spaceY=80
		if occupiedBaseNum>0 then
			for i=1,occupiedBaseNum do
				local scale
				local bx
				local by
				-- local baseSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
				local baseSp=CCSprite:createWithSpriteFrameName(localWarMapCfg.cityCfg["a1"].icon)
				if occupiedBaseNum==1 then
					scale=1.2
					bx=midX
					by=midY
				elseif occupiedBaseNum==2 then
					scale=0.7
					bx=midX+(i-1.5)*spaceX
					by=midY
				elseif occupiedBaseNum==3 then
					scale=0.7
					if i==1 then
						bx=midX
						by=midY+spaceY/2
					else
						bx=midX+(i-2.5)*spaceX
						by=midY-spaceY/2
					end
				elseif occupiedBaseNum==4 then
					scale=0.7
					spaceY=85
					bx=midX-0.5*spaceX+((i-1)%2)*spaceX
					by=midY+spaceY/2-math.floor((i-1)/2)*spaceY
				end
				baseSp:setScale(scale)
				baseSp:setPosition(ccp(bx,by))
				backSprie:addChild(baseSp,1)
			end
		else --出局
			local function nilFunc()
			end
			local mask=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
			mask:setTouchPriority(-(self.layerNum-1)*20-2)
			local rect=CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height)
			mask:setContentSize(rect)
			mask:setOpacity(180)
			mask:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(mask,5)
			local outLb=GetTTFLabelWrap(getlocal("local_war_alliance_already_out"),25,CCSizeMake(mask:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			outLb:setPosition(getCenterPoint(mask))
			outLb:setColor(G_ColorRed)
			mask:addChild(outLb,1)
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

function localWarAllianceDialogTab1:refresh()

end

function localWarAllianceDialogTab1:tick()
	
end

function localWarAllianceDialogTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
	self.kingCity={}
	self.list={}
end
