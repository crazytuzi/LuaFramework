showPrivateMineListPanel=commonDialog:new()

function showPrivateMineListPanel:new(gpsCallback)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.rawData       = {}
	self.lastTimeTb    = {}
	self.lastTimeStrTb = {}
	self.canTick       = false
	self.gpsCallback   = gpsCallback
	return nc
end
function showPrivateMineListPanel:dispose( )
	self.canTick       = nil
	self.lastTimeStrTb = nil
	self.lastTimeTb    = nil
	self.rawData       = nil

	spriteController:removePlist("public/nbSkill2.plist")
    spriteController:removeTexture("public/nbSkill2.png")
end

function showPrivateMineListPanel:doUserHandler()
	spriteController:addPlist("public/nbSkill2.plist")
    spriteController:addTexture("public/nbSkill2.png")
	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end
	if self.topforbidSp then
		self.topforbidSp:setVisible(false)
	end
	if self.bottomforbidSp then
		self.bottomforbidSp:setVisible(false)
	end

	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth * 0.5,5)
    self.bgLayer:addChild(panelBg,2)

	self:checkMineInfo()
end
function showPrivateMineListPanel:checkMineInfo(  )
	self.rawData = {}
	self.lastTimeTb = {}
	local privateRawTb = G_clone(privateMineVoApi:getPrivateMineList())
	local mapx,mapy=playerVoApi:getMapX(),playerVoApi:getMapY()
	local idx = 1
	for k,v in pairs(privateRawTb) do
		self.rawData[idx] = v
		self.rawData[idx].distance = math.floor(math.sqrt(math.pow(self.rawData[idx].x-playerVoApi:getMapX(),2)+ math.pow(self.rawData[idx].y-playerVoApi:getMapY(),2)))
		idx = idx + 1
	end

	local function sortCall(a,b)--时间排序
		return a.endTime > b.endTime			
	end
	table.sort(self.rawData,sortCall)

	local function sortCall2(a,b)--距离排序
		if a.endTime == b.endTime then
			return a.distance < b.distance
		else
			return a.endTime > b.endTime			
		end			
	end
	table.sort(self.rawData,sortCall2)
end

function showPrivateMineListPanel:initTableView( )
	self.cellWidth = G_VisibleSizeWidth-20 - 10
	self.cellHeight = 170

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    self.bgLayer:addChild(tvBg,5)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-250))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,100))

    local tipPosy = (G_VisibleSizeHeight - 82  - (tvBg:getPositionY() + tvBg:getContentSize().height)) * 0.5 + (tvBg:getPositionY() + tvBg:getContentSize().height)
    local strSize2 = G_isAsia() and 22 or 16
    local refreshTipStr = GetTTFLabelWrap(getlocal("privateMineSearchTip"),strSize2,CCSizeMake(440,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    refreshTipStr:setAnchorPoint(ccp(0.5,0.5))
    refreshTipStr:setPosition(G_VisibleSizeWidth * 0.5, tipPosy)
    self.bgLayer:addChild(refreshTipStr,10)

    local function touchInfo()
        local tabStr={getlocal("privateMineTip_1",{privateMineCfg.refreshNum,privateMineCfg.keepTime/60}),getlocal("privateMineTip_2"),getlocal("privateMineTip_3",{privateMineCfg.queueNumMax}),getlocal("privateMineTip_4"),}
        -- for i=3,4 do
        -- 	table.insert(tabStr,getlocal("privateMineTip_"..i))
        -- end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,tipPosy),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,0.8,-(self.layerNum-1)*20-4,5)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-250),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(10,100))
    self.bgLayer:addChild(self.tv,5)
    self.tv:setMaxDisToBottomOrTop(80)

    local function refreshCallBack()
    	local isCanRefresh,refreshTime = privateMineVoApi:isCanSearchPrivateMine( )
    	if not isCanRefresh then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("socketErrorTip",{refreshTime}),30)
			do return end
		else--refreshSucc
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("refreshSucc"),30)
		end
		privateMineVoApi:setSearchLastTime(base.serverTime)	

		local function refreshTableView( )
			self:refreshTableView()
		end 
		satelliteSearchVoApi:mapWorldSearch("map.worldsearch.privatemine",nil,nil,refreshTableView)	
	end
	local btnScale,priority = 0.88,-(self.layerNum-1)*20-4
	local refreshBtn,refreshMenu = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth * 0.5,20),{getlocal("dailyTaskFlush")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",refreshCallBack,btnScale,priority,5,nil,ccp(0.5,0))	
	self.isCanRefresh = true 
	self.canTick =true
end

function showPrivateMineListPanel:refreshTableView( )
	self.canTick = false
	self:checkMineInfo()
	self.tv:reloadData()
	self.canTick = true
end

function showPrivateMineListPanel:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        	return SizeOfTable(self.rawData)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.cellWidth + 10,self.cellHeight + 10)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()

		local mineDataTb        = self.rawData[idx + 1]
		local lvStr             = mineDataTb.level
		local minePosx,minePosy = mineDataTb.x,mineDataTb.y
		local mineDistanceStr   = mineDataTb.distance
		local ishasStr          = mineDataTb.flag == 1 and getlocal("yes") or getlocal("no")
		local lastTime          = mineDataTb.endTime >= base.serverTime and mineDataTb.endTime - base.serverTime or 0
		self.lastTimeTb[idx + 1]  = lastTime
		local timeStr           = GetTimeStr(self.lastTimeTb[idx + 1],true)

        local backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),function() end)
        backSprite:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight))
        backSprite:setAnchorPoint(ccp(0,0))
        backSprite:setPosition(5,5)
        cell:addChild(backSprite)
        local mineIcon,mineStr = G_getMineIconAndName(tonumber(mineDataTb.type),self.layerNum,nil,ccp(0.5,0))
        mineIcon:setPosition(ccp(30 + mineIcon:getContentSize().width * 0.5,50))
        backSprite:addChild(mineIcon)
        local mineLv = GetTTFLabel(getlocal("fightLevel",{lvStr}),22)
        mineLv:setPosition(mineIcon:getPositionX(),45)
        mineLv:setAnchorPoint(ccp(0.5,1))
        backSprite:addChild(mineLv)

        local leftPos = mineIcon:getPositionX() + 100 * 0.5 + 10

        local mineNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function() end)
	    mineNameBg:setContentSize(CCSizeMake(self.cellWidth - leftPos - 100 ,32))
	    mineNameBg:setAnchorPoint(ccp(0,1))
	    backSprite:addChild(mineNameBg)
	    mineNameBg:setPosition(ccp(leftPos,50 + 100))

	    local strSize2 = G_isAsia() and 22 or 17
	    local mineName = GetTTFLabelWrap(mineStr.." ( "..getlocal("privateMineName").." )",strSize2,CCSizeMake(mineNameBg:getContentSize().width - 50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	    mineName:setAnchorPoint(ccp(0,0.5))
	    mineName:setColor(G_ColorYellowPro3)
	    mineName:setPosition(15 , mineNameBg:getContentSize().height *0.5)
	    mineNameBg:addChild(mineName)

	    local downPosx = mineNameBg:getPositionX() + 15
	    local downPosy = mineNameBg:getPositionY() - mineNameBg:getContentSize().height - 15
	    local posName = GetTTFLabel(getlocal("search_base_report_desc_4",{minePosx,minePosy}),21)
	    posName:setAnchorPoint(ccp(0,1))
	    posName:setPosition(downPosx,downPosy)
	    backSprite:addChild(posName)

	    local distanceLb = GetTTFLabel(getlocal("distanceStr",{mineDistanceStr}).."KM",21)
	    distanceLb:setAnchorPoint(ccp(0,1))
	    distanceLb:setPosition(downPosx,downPosy - posName:getContentSize().height - 5)
	    backSprite:addChild(distanceLb)

	    local mineIsOccupied = GetTTFLabel(getlocal("mineIsOccupiedStr",{ishasStr}),21)
	    mineIsOccupied:setAnchorPoint(ccp(0,1))
	    mineIsOccupied:setPosition(downPosx,distanceLb:getPositionY() - distanceLb:getContentSize().height - 5)
	    backSprite:addChild(mineIsOccupied)

	    if mineDataTb.flag == 1 then
	    	local occupiedPicPosx = mineIsOccupied:getPositionX() + mineIsOccupied:getContentSize().width + 5
	    	local occupiedPic = CCSprite:createWithSpriteFrameName("iconLevelPriFlag.png")
	    	occupiedPic:setAnchorPoint(ccp(0,0.5))
	    	occupiedPic:setPosition(occupiedPicPosx,mineIsOccupied:getPositionY() - mineIsOccupied:getContentSize().height * 0.5)
	    	backSprite:addChild(occupiedPic)
	    end

	    local lastTime = GetTTFLabel(timeStr,22,true)
	    lastTime:setAnchorPoint(ccp(1,0.5))
	    lastTime:setColor(G_ColorYellowPro3)
	    lastTime:setPosition(self.cellWidth - 15, 50 + 100 - mineNameBg:getContentSize().height * 0.5)
	    backSprite:addChild(lastTime)
	    self.lastTimeStrTb[idx + 1] = lastTime

		
		local function goToPrivateMine()
			self.canTick = false
			self:close()
			pos = {tonumber(minePosx),tonumber(minePosy)}
			if mainUI.miniMap then
				local miniMapSize=mainUI.miniMap:getContentSize()
				local posX=pos[1]/G_maxMapx*miniMapSize.width
				local posY=miniMapSize.height-pos[2]/G_maxMapy*miniMapSize.height
				if mainUI.laskPSp then
					mainUI.laskPSp:setPosition(posX,posY)
				end
				worldScene:focus(pos[1],pos[2],true)
			end			
	    end
	    local btnScale,priority = 1,-(self.layerNum-1)*20-3
	    local logBtn,logMenu = G_createBotton(backSprite,ccp(self.cellWidth - 30,20),nil,"worldBtnSearch.png","worldBtnSearch_Down.png","worldBtnPosition_Down.png",goToPrivateMine,btnScale,priority,nil,nil,ccp(1,0))	    
        return cell
    end
end

function showPrivateMineListPanel:tick( )
	if self.canTick and self.lastTimeTb and SizeOfTable(self.lastTimeTb) > 0 then
		local ishasZeroT = false
		for idx=1,SizeOfTable(self.lastTimeTb) do
			self.lastTimeTb[idx]  = self.lastTimeTb[idx] - 1 >= 0 and self.lastTimeTb[idx] - 1 or 0
			local timeStr           = GetTimeStr(self.lastTimeTb[idx],true)	
			self.lastTimeStrTb[idx]:setString(timeStr)
			if self.lastTimeTb[idx] - 1 <= 0 and not ishasZeroT then
				ishasZeroT = true
			end
		end
		if ishasZeroT then
			self:refreshTableView()
		end
	end
end