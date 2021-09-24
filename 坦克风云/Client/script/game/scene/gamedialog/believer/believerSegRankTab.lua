local believerSegRankTab ={}

function believerSegRankTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.bgLayer  = nil
    nc.layerNum = nil
    nc.subLbBgTb  = {}
    nc.subLbStrTb = {}
    nc.rankTvTitleStrTb = {getlocal("alliance_scene_rank"),getlocal("RankScene_name"),getlocal("serverwar_point")}
    nc.rankTvTitleLbTb  = {}
    nc.rankTvWidthScale = {0.23,0.5,0.77}
    nc.masterSegTb = {}
    nc.legendSegTb = {}
    nc.masterSegNum = 0
    nc.legendSegNum = 0
    nc.curSubTabLbTb  = {getlocal("believer_seg_5"),getlocal("believer_seg_4")}
    nc.believerCfg	= believerVoApi:getBelieverCfg()
    return nc;

end
function believerSegRankTab:dispose( )
	self.believerCfg = nil
	self.masterSegTb = nil
    self.legendSegTb = nil
    self.masterSegNum = nil
    self.legendSegNum = nil
	self.rankTvWidthScale = nil
	self.rankTvTitleStrTb = nil
	self.rankTvTitleLbTb  = nil
	self.subLbBgTb 		= nil
	self.subLbStrTb 	= nil
	self.curSubTabLbTb  = nil
	self.bgLayer = nil
	self.layerNum = nil
end

function believerSegRankTab:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum
    self.cellHeight1 = 125 -- 默认高度：title背景图 + 排名背景图 + 段位图标
    self.cellHeight2 = 114

    self:initSubTab()
    self:refreshRank(1)
    return self.bgLayer
end

function believerSegRankTab:initSubTab()

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setPosition(ccp(10,20))
    tvBg:setAnchorPoint(ccp(0,0))
    self.tvBg = tvBg
    self.bgLayer:addChild(tvBg)
    local subTabHeight = nil

	local function selectSubTabCall(object,name,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.subTabBgDown then
        	self.subTabBgDown:setPosition(ccp(self.subLbBgTb[tag]:getPositionX(),self.subLbBgTb[tag]:getPositionY()))
        end
        self:refreshRank(tag)
    end

    for i=1,2 do
            local subTabBg = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab.png",selectSubTabCall)
            subTabBg:setTag(i)
            subTabBg:setAnchorPoint(ccp(0,0))
            subTabBg:setTouchPriority(-(self.layerNum-1)*20-3)
            self.subLbBgTb[i] = subTabBg

            local subTabStr = GetTTFLabelWrap(self.curSubTabLbTb[i],23,CCSizeMake(subTabBg:getContentSize().width -4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            self.subLbStrTb[i] = subTabStr
            if not subTabHeight then
            	subTabHeight = subTabBg:getContentSize().height
            end
    end
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - subTabHeight - 180 - 20))
    self.tvWidth,self.tvHeight = tvBg:getContentSize().width,tvBg:getContentSize().height
    for i=1,2 do
    		self.subLbBgTb[i]:setPosition(ccp(10 + (i-1) * self.subLbBgTb[i]:getContentSize().width + (i-1)*5,tvBg:getContentSize().height))
    		tvBg:addChild(self.subLbBgTb[i])

    		self.subLbStrTb[i]:setPosition(ccp(self.subLbBgTb[i]:getPositionX() + self.subLbBgTb[i]:getContentSize().width*0.5,self.subLbBgTb[i]:getPositionY() + self.subLbBgTb[i]:getContentSize().height*0.5))
    		tvBg:addChild(self.subLbStrTb[i],2)
    end
    if self.subTabBgDown == nil then
        self.subTabBgDown = CCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab_down.png")
        self.subTabBgDown:setAnchorPoint(ccp(0,0))
        tvBg:addChild(self.subTabBgDown,1)
        self.subTabBgDown:setPosition(ccp(self.subLbBgTb[1]:getPositionX(),self.subLbBgTb[1]:getPositionY()))--容错
    end
end

function believerSegRankTab:refreshRank(idx)
	self:initTvTitle(idx)

	if idx == 2 then
		self:showNoDataTipDia(false)
        if self.tv1 then
            self.tv1:setPosition(ccp(0,0))
            self.tv1:setVisible(true)
        else
            self:initTableView(idx)
        end
        if self.tv2 then
            self.tv2:setPosition(ccp(G_VisibleSizeWidth*2,0))
            self.tv2:setVisible(false)
        end
    elseif idx == 1 then
        if self.tv2 then
            self.tv2:setPosition(ccp(0,0))
            self.tv2:setVisible(true)
        else
            self:initTableView(idx)
        end
        if self.tv1 then
            self.tv1:setPosition(ccp(G_VisibleSizeWidth*2,0))
            self.tv1:setVisible(false)
        end
    end
end
function believerSegRankTab:initTvTitle(idx)
	if idx == 2 then
		for i=1,3 do
			if not self.rankTvTitleLbTb[i] then
				local titleLb = GetTTFLabelWrap(self.rankTvTitleStrTb[i],25,CCSizeMake(self.tvWidth * 0.2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		        titleLb:setPosition(ccp(self.tvWidth * self.rankTvWidthScale[i],self.tvHeight - 20 - titleLb:getContentSize().height*0.5))
		        titleLb:setColor(G_ColorGreen)
		        self.tvBg:addChild(titleLb,1)
		        self.rankTvTitleLbTb[i] = titleLb
			else
				self.rankTvTitleLbTb[i]:setVisible(true)
			end
		end
	else
		for i=1,3 do
			if self.rankTvTitleLbTb[i] then
				self.rankTvTitleLbTb[i]:setVisible(false)
			end
		end
	end
end

function believerSegRankTab:initTableView(idx)
    if idx == 2 then
        self.masterSegNum,self.masterSegTb = believerVoApi:getMasterSegTb( )
        self.cellAddHeight = 50
        local function callBack(...)
           return self:eventHandler1(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight - 60),nil)
        self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
        self.tv1:setPosition(ccp(0,0))
        self.tvBg:addChild(self.tv1)
        self.tv1:setMaxDisToBottomOrTop(120)
    elseif idx == 1 then 
    	local function legendRankCall( )----------------------- 需 要 先 向 后 台 请 求
	        self.legendSegNum,self.legendSegTb = believerVoApi:getLegendSegTb()
	        if self.legendSegNum == 0 then
	            self:showNoDataTipDia(true)
	            do return end
	        end
	        self:showNoDataTipDia(false)
	        local function callBack(...)
	           return self:eventHandler2(...)
	        end
	        local hd= LuaEventHandler:createHandler(callBack)
	        self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
	        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	        self.tv2:setPosition(ccp(0,0))
	        self.tvBg:addChild(self.tv2)
	        self.tv2:setMaxDisToBottomOrTop(120)   
        end 
        believerVoApi:socketRankInfo(4,legendRankCall) 
    end
end

function believerSegRankTab:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.believerCfg.seasonReward[SizeOfTable(self.believerCfg.seasonReward) - 1])
    elseif fn=="tableCellSizeForIndex" then
    	local cellHeight = (self.masterSegTb[tostring(idx+1)] and SizeOfTable(self.masterSegTb[tostring(idx+1)]) > 0) and (SizeOfTable(self.masterSegTb[tostring(idx+1)]) * 50 + self.cellHeight1 - 45) + 10 or self.cellHeight1 + 10 + self.cellAddHeight
        return CCSizeMake(self.tvWidth,cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local segNum = SizeOfTable(self.believerCfg.seasonReward[SizeOfTable(self.believerCfg.seasonReward) - 1])
        local cellHeight = (self.masterSegTb[tostring(idx+1)] and SizeOfTable(self.masterSegTb[tostring(idx+1)]) > 0) and (SizeOfTable(self.masterSegTb[tostring(idx+1)]) * 50 + self.cellHeight1 - 45) + 10 or self.cellHeight1 + 10 + self.cellAddHeight
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
        backSprie:setContentSize(CCSizeMake(self.tvWidth,cellHeight))
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setOpacity(0)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)

        	local i = idx + 1
    		local titleSp = CCSprite:createWithSpriteFrameName("believerRankTitle.png")
    		titleSp:setAnchorPoint(ccp(0.5,1))
    		titleSp:setPosition(ccp(self.tvWidth*0.5,cellHeight - 15))
    		backSprie:addChild(titleSp,1)

    		local segSp = believerVoApi:getSegmentIcon(4,segNum + 1 - i)
    		segSp:setScale(0.35)
		    segSp:setPosition(ccp(self.tvWidth * 0.5,cellHeight - 2))
		    segSp:setAnchorPoint(ccp(0.5,1))
		    backSprie:addChild(segSp,2)

		    local rankBg =LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png",CCRect(18,21,1,1),function () end)
	        rankBg:setContentSize(CCSizeMake(self.tvWidth - 20, cellHeight - titleSp:getContentSize().height - 5))
	        rankBg:setPosition(ccp(self.tvWidth*0.5,titleSp:getPositionY() - titleSp:getContentSize().height + 5))
	        rankBg:setAnchorPoint(ccp(0.5,1))
	        backSprie:addChild(rankBg)

	        if self.masterSegTb[tostring(idx+1)] and SizeOfTable(self.masterSegTb[tostring(idx+1)]) > 0 then
	        	local curSegNum,curSegInfo = SizeOfTable(self.masterSegTb[tostring(idx+1)]),self.masterSegTb[tostring(idx+1)]
	        	local rankbgWidth,rankBgHeight = rankBg:getContentSize().width,rankBg:getContentSize().height
	        	local rankInfoBgHeight = (rankBgHeight-4) /curSegNum  - 4
	        	local wScale = {0.21,0.5,0.78}
	        	for i=1,curSegNum do
	        		local rankInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function () end)
	        		rankInfoBg:setAnchorPoint(ccp(0.5,1))
	        		-- rankInfoBg:setOpacity(0)
	        		rankInfoBg:setContentSize(CCSizeMake(rankbgWidth - 18,rankInfoBgHeight))
	        		local rankInfoBgWidht = rankInfoBg:getContentSize().width
	        		rankInfoBg:setPosition(ccp(rankbgWidth *0.5,rankBgHeight - rankInfoBgHeight*(i-1) - 4*(i-1) - 4))
	        		rankBg:addChild(rankInfoBg)

	        		local rankNumStr = GetTTFLabel(curSegInfo[i][3],23)
	        		rankNumStr:setPosition(ccp(rankInfoBgWidht * wScale[1],rankInfoBgHeight * 0.5))
	        		rankInfoBg:addChild(rankNumStr)

	        		local playerNameStr = GetTTFLabel(GetServerNameByID(curSegInfo[i][4],true).."-"..curSegInfo[i][1],23)
	        		playerNameStr:setPosition(ccp(rankInfoBgWidht * wScale[2],rankInfoBgHeight * 0.5))
	        		rankInfoBg:addChild(playerNameStr)

	        		local scoreNumStr = GetTTFLabel(curSegInfo[i][2],23)
	        		scoreNumStr:setPosition(ccp(rankInfoBgWidht * wScale[3],rankInfoBgHeight * 0.5))
	        		rankInfoBg:addChild(scoreNumStr)

	        		if i < 4 then
				        rankSp=CCSprite:createWithSpriteFrameName("top"..i..".png")
				        rankSp:setPosition(getCenterPoint(rankNumStr))
				        rankSp:setScale(0.55)
				        rankNumStr:addChild(rankSp)
				    end
	        	end

	        else
	        	local noBodyTipStr = GetTTFLabelWrap(getlocal("dimensionalWar_no_rank_show"),24,CCSizeMake(self.tvWidth - 24,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	        	noBodyTipStr:setPosition(getCenterPoint(rankBg))
	        	rankBg:addChild(noBodyTipStr)
	        end

        return cell
    end
end

function believerSegRankTab:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
            return self.legendSegNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight2)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

	    local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),function () end)
	    cellBgSp:setContentSize(CCSizeMake(self.tvWidth - 10,self.cellHeight2))
	    cellBgSp:setAnchorPoint(ccp(0,0))
	    cell:addChild(cellBgSp)
	    cellBgSp:setPosition(ccp(5,0))
	    --排行 -- 头像 -- 头像框 --段位 --
	    local personInfo = self.legendSegTb[idx + 1]
	    --排行
	    local rankIdxLb = GetTTFLabel(personInfo[1],24)
	    rankIdxLb:setPosition(ccp(40,self.cellHeight2*0.5))
	    cellBgSp:addChild(rankIdxLb)
	    --头像--头像框
	    local picName=playerVoApi:getPersonPhotoName(personInfo[2])
	    local playerIcon = playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,iconSize,personInfo[3])
	    local playerIconSizeScale = self.cellHeight2*0.85/playerIcon:getContentSize().width
	    playerIcon:setScale(playerIconSizeScale)
	    playerIcon:setPosition(ccp(playerIcon:getContentSize().width*playerIconSizeScale * 0.5 + 80,self.cellHeight2*0.5))
	    local lbPosx = playerIcon:getContentSize().width * playerIconSizeScale + 95
	    cellBgSp:addChild(playerIcon)
	    --个人信息
	    local iidx = 1
	    for i=5,#personInfo do -- 
	    	local lb = GetTTFLabel(personInfo[i],20)
	    	lb:setAnchorPoint(ccp(0,0.5))
	    	lb:setPosition(ccp(lbPosx,self.cellHeight2 - 20 - 25 * (iidx-1)))
	    	cellBgSp:addChild(lb)
	    	iidx = iidx + 1
	    end

	    local segSp = believerVoApi:getSegmentIcon(5,nil,100)
	    segSp:setPosition(ccp(self.tvWidth * 0.82,self.cellHeight2 * 0.5))
	    cellBgSp:addChild(segSp)

	    if idx < 3 then
	        rankSp=CCSprite:createWithSpriteFrameName("top"..(idx+1)..".png")
	        rankSp:setScale(0.8)
	        rankSp:setPosition(getCenterPoint(rankIdxLb))
	        rankIdxLb:addChild(rankSp)
	    end

        return cell
    end
end



function believerSegRankTab:showNoDataTipDia(useType)
    if useType then
        if self.noDataTip then
            self.noDataTip:setVisible(true)
            self.noDataTip:setPositionX(self.tvBg:getContentSize().width*0.5)
        else
            self.noDataTip = GetTTFLabelWrap(getlocal("activity_getRich_norank"),40,CCSizeMake(self.tvWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            self.noDataTip:setPosition(getCenterPoint(self.tvBg))
            self.noDataTip:setColor(G_ColorGray)
            self.tvBg:addChild(self.noDataTip)
        end
    else
        if self.noDataTip then
            self.noDataTip:setVisible(false)
            self.noDataTip:setPositionX(G_VisibleSizeWidth * 2)
        end
    end
end
return believerSegRankTab