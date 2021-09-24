worldWarDialogSubTab12={}
function worldWarDialogSubTab12:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.warStatus=nil
	self.sceneList={}
	self.layerList={}
	return nc
end

function worldWarDialogSubTab12:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	local function onGetSchedule()
		if(self.bgLayer)then
			self:initLayers()
		end
	end
	worldWarVoApi:getScheduleInfo(1,onGetSchedule)
	return self.bgLayer
end

function worldWarDialogSubTab12:initLayers()
	local posY=G_VisibleSizeHeight - 250
	local leftBtnPos=ccp(100,posY)
	local rightBtnPos=ccp(G_VisibleSizeWidth - 100,posY)
	local function onLeft()
		if(self.curPage==1)then
			self:switchLayer(#self.sceneList)
		else
			self:switchLayer(self.curPage - 1)
		end
	end
	local leftItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onLeft,11,nil,nil)
	local leftBtn=CCMenu:createWithItem(leftItem)
	leftBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	leftBtn:setPosition(100,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(leftBtn,1)
	local function onRight()
		if(self.curPage==#self.sceneList)then
			self:switchLayer(1)
		else
			self:switchLayer(self.curPage + 1)
		end
	end
	local rightItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onRight,11,nil,nil)
	rightItem:setRotation(180)
	local rightBtn=CCMenu:createWithItem(rightItem)
	rightBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	rightBtn:setPosition(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(rightBtn,1)

	for i=1,worldWarCfg.tmatchgroup do
		local scene=worldWarScheduleScene:new(1,i)
		local layer=scene:init(self.layerNum)
		self.sceneList[i]=scene
		self.layerList[i]=layer
		self.bgLayer:addChild(layer)
	end
	local scene=worldWarFinalScene:new(1)
	local layer=scene:init(self.layerNum)
	self.bgLayer:addChild(layer)
	table.insert(self.sceneList,scene)
	table.insert(self.layerList,layer)
	self.warStatus=worldWarVoApi:checkStatus()
	if(self.warStatus==30 + worldWarVoApi.tmatchDays)then
		self:switchLayer(#self.sceneList)
	else
		local signStatus=worldWarVoApi:getSignStatus()
		if(signStatus==nil or signStatus==2)then
			self:switchLayer(1)
		else
			local selfID=playerVoApi:getUid().."-"..base.curZoneID
			local battleList=worldWarVoApi:getBattleList(1)
			if(battleList[1] and #(battleList[1])>0)then
				for battleID,battleVo in pairs(battleList[1]) do
					if(battleVo.id1==selfID or battleVo.id2==selfID)then
						local groupID=worldWarVoApi:getGroupIDByBIDAndRID(1,battleID)
						self:switchLayer(groupID)
						return
					end
				end
			end
			self:switchLayer(1)
		end
	end
end

function worldWarDialogSubTab12:switchLayer(page)
	self.curPage=page
	for k,v in pairs(self.layerList) do
		if(k==page)then
			v:setVisible(true)
			v:setPositionX(0)
		else
			v:setVisible(false)
			v:setPositionX(999333)
		end
	end
end

function worldWarDialogSubTab12:tick()
	for k,v in pairs(self.sceneList) do
		if(v and v.tick)then
			v:tick()
		end
	end
end

function worldWarDialogSubTab12:dispose()
	if(self)then
		if(self.bgLayer)then
			self.bgLayer:removeFromParentAndCleanup(true)
		end
		self.layerNum=nil
		self.bgLayer=nil
	end
end