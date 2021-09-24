local believerBattleRankTab ={}

function believerBattleRankTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.bgLayer  = nil
    nc.layerNum = nil
    nc.subLbBgTb  = {}
    nc.subLbStrTb = {}
    nc.curSubTabLbTb  = {getlocal("believer_battleNumStr"),getlocal("believer_dmgRateNumStr")}
    nc.rankNeedStrTb  = {getlocal("rank"),getlocal("RankScene_name"),getlocal("ltzdz_segment"),getlocal("believer_battleNumStr")}
    nc.ranklistNameTb = {}
    nc.playerInfoTb   = {1000,1000}
    nc.rankNeedStrPosxScaleTb = {0.1,0.34,0.62,0.85}
    nc.tvWidth    = nil
    nc.cellHeight = 70
    nc.curTabTag  = nil
    nc.cellNum1   = 50
    nc.cellNum2   = 50
    nc.battleNumRankNums = 0
    nc.dmgRateRankNums   = 0 
    nc.battleNumRankTb   = {}
    nc.dmgRateRankTb     = {}
    nc.battleDataTb      = {}
    return nc;

end
function believerBattleRankTab:dispose( )
    self.battleDataTb      = nil
    self.battleNumRankNums = nil
    self.dmgRateRankNums   = nil
    self.battleNumRankTb   = nil
    self.dmgRateRankTb     = nil
	self.curTabTag		= nil
	self.playerInfoTb   = nil
    self.rankNeedStrTb           = nil
    self.rankNeedStrPosxScaleTb  = nil
    self.cellNum1,self.cellNum2  = nil,nil
	self.tvWidth,self.cellHeight = nil,nil
	self.subLbBgTb 		= nil
	self.subLbStrTb 	= nil
	self.curSubTabLbTb  = nil
	self.ranklistNameTb = nil
	self.bgLayer 				= nil
	self.layerNum 				= nil

end

function believerBattleRankTab:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    self:initSubTab()
    self:refreshRank(1)
    return self.bgLayer
end

function believerBattleRankTab:initSubTab()

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
    self.tvWidth = tvBg:getContentSize().width
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

function believerBattleRankTab:refreshRank(idx)
	self.curTabTag = idx
	for i=1,#self.rankNeedStrTb do
		if i < 4 then
			if not self.ranklistNameTb[i] then
				self.ranklistNameTb[i] = GetTTFLabelWrap(self.rankNeedStrTb[i],23,CCSizeMake(self.tvWidth * 0.25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				self.ranklistNameTb[i]:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[i],self.tvBg:getContentSize().height - 10 - self.ranklistNameTb[i]:getContentSize().height * 0.5))
				self.tvBg:addChild(self.ranklistNameTb[i])
				self.ranklistNameTb[i]:setColor(G_ColorGreen)
			end
		else
			if not self.ranklistNameTb[i] then
				self.ranklistNameTb[i] = GetTTFLabelWrap(self.rankNeedStrTb[i],23,CCSizeMake(self.tvWidth * 0.25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				self.ranklistNameTb[i]:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[i],self.tvBg:getContentSize().height - 10 - self.ranklistNameTb[i]:getContentSize().height * 0.5))
				self.tvBg:addChild(self.ranklistNameTb[i])
				self.ranklistNameTb[i]:setColor(G_ColorGreen)
			else
				if idx == 1 then
					self.ranklistNameTb[i]:setString(self.rankNeedStrTb[i])
				else
					self.ranklistNameTb[i]:setString(getlocal("believer_dmgRateNumStr"))
				end
			end
		end
	end

	if not self.topCellBg then
		self.topCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),function() end)
		self.topCellBg:setContentSize(CCSizeMake(self.tvWidth -10,self.cellHeight))
		self.topCellBg:setAnchorPoint(ccp(0.5,1))
		self.topCellBg:setPosition(ccp(self.tvWidth * 0.5,self.ranklistNameTb[4]:getPositionY() - self.ranklistNameTb[4]:getContentSize().height * 0.5 - 5))
		self.tvBg:addChild(self.topCellBg)
        self.topCellBgCenterPosy = self.topCellBg:getPositionY() - self.topCellBg:getContentSize().height * 0.5
        self.tableViewTopHeight  = self.topCellBg:getPositionY() - self.topCellBg:getContentSize().height
	end

    if idx == 1 then
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
    elseif idx == 2 then
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

    if (idx == 1 and self.battleNumRankNums == 0) or (idx == 2 and self.dmgRateRankNums == 0) then
        self:dealWithSelfData(false)
        do return end
    else
        self:dealWithSelfData(true)
    end

    --姓名
    if not self.playerFidAndName then
        local playerFidAndName = GetTTFLabelWrap(GetServerNameByID(base.curZoneID,true).."-"..playerVoApi:getPlayerName(),23,CCSizeMake(self.tvWidth * 0.28,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        playerFidAndName:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[2],self.topCellBgCenterPosy))
        self.tvBg:addChild(playerFidAndName)
        self.playerFidAndName = playerFidAndName

        if playerFidAndName:getContentSize().width > self.tvWidth * 0.28 then
            playerFidAndName:setScale((self.tvWidth * 0.28-4)/playerFidAndName:getContentSize().width)
        end
    end
    --排名
	local rankNum = self.playerInfoTb[idx] == 1000 and "100+" or self.playerInfoTb[idx]
	if not self.ranking then
		self.ranking = GetTTFLabel(rankNum,23)
		self.ranking:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[1],self.topCellBgCenterPosy))
		self.tvBg:addChild(self.ranking)
	else
		self.ranking:setString(rankNum)
	end
	if tonumber(rankNum) and rankNum < 4 then
		if self.rankTopSp then
			local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("top"..rankNum..".png")
            if frame then
                tolua.cast(self.rankTopSp,"CCSprite"):setDisplayFrame(frame)
                self.rankTopSp:setVisible(true)
            end
		else
			self.rankTopSp = CCSprite:createWithSpriteFrameName("top"..rankNum..".png")
            self.rankTopSp:setScale(0.8)
			self.rankTopSp:setPosition(getCenterPoint(self.ranking))
            self.ranking:addChild(self.rankTopSp)
		end
	elseif self.rankTopSp then
		self.rankTopSp:setVisible(false)
	end
    --段位
    local curGrade,curQueue = believerVoApi:getMySegment()
    if not self.segStr then
        self.segStr = GetTTFLabelWrap(believerVoApi:getSegmentName(curGrade,curQueue),23,CCSizeMake(self.tvWidth * 0.28,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.segStr:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[3],self.topCellBgCenterPosy))
        self.tvBg:addChild(self.segStr)
    else
        self.segStr:setString(believerVoApi:getSegmentName(curGrade,curQueue))
    end
    --战斗场次/平均战损率
    local battleTotalNums,dmg = believerVoApi:getBattleTotalNumsAndDmgRate()
    if idx == 1 then
        self.battleDataTb[1] = self.battleDataTb[1] or battleTotalNums
    else
        dmg = dmg > 0 and ((dmg/10).."%") or "-"
        self.battleDataTb[2] = self.battleDataTb[2] or dmg 
    end
    if not self.battleTotalNumsOrDmg then
        self.battleTotalNumsOrDmg = GetTTFLabel(self.battleDataTb[1],23)
        self.battleTotalNumsOrDmg:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[4],self.topCellBgCenterPosy))
        self.tvBg:addChild(self.battleTotalNumsOrDmg)
    else
        if idx == 1 then
            self.battleTotalNumsOrDmg:setString(self.battleDataTb[1])
        else
            if self.battleDataTb[2] then
                self.battleTotalNumsOrDmg:setString((self.battleDataTb[2]))
            end
        end
    end
end

function believerBattleRankTab:initTableView(idx)
    if idx == 1 then
        self.battleNumRankNums,self.battleNumRankTb = believerVoApi:getBattleRankDataWithBattleNums()
        if self.battleNumRankNums == 0 then
            self:showNoDataTipDia(true)
            do return end
        end
        self:showNoDataTipDia(false)
        local function callBack(...)
           return self:eventHandler1(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tableViewTopHeight),nil)
        self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
        self.tv1:setPosition(ccp(0,0))
        self.tvBg:addChild(self.tv1)
        self.tv1:setMaxDisToBottomOrTop(120)
    elseif idx == 2 then 
        local function dmgRateRankCall( )----------------------- 需 要 先 向 后 台 请 求

            self.dmgRateRankNums,self.dmgRateRankTb = believerVoApi:getBattleRankDataWithDmgRateTb()
            if self.dmgRateRankNums == 0 then
                self:showNoDataTipDia(true)
                do return end
            end
            self:showNoDataTipDia(false)
            local function callBack(...)
               return self:eventHandler2(...)
            end
            local hd= LuaEventHandler:createHandler(callBack)
            self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tableViewTopHeight),nil)
            self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
            self.tv2:setPosition(ccp(0,0))
            self.tvBg:addChild(self.tv2)
            self.tv2:setMaxDisToBottomOrTop(120)    
        end 
        believerVoApi:socketRankInfo(3,dmgRateRankCall)
    end
end

function believerBattleRankTab:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.battleNumRankNums > self.cellNum1 then
            return self.cellNum1 + 1
        else
            return self.battleNumRankNums
        end
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local backSprie
        if idx == 50 and self.cellNum1 == 50 then
            local function cellClick(hd,fn,idx)
                self.cellNum1 = 100
                local recordPoint = self.tv1:getRecordPoint()
                self.tv1:reloadData()
                recordPoint.y=(50 - self.battleNumRankNums + 1)*self.cellHeight+recordPoint.y
                self.tv1:recoverToRecordPoint(recordPoint)
            end
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie:setContentSize(CCSizeMake(self.tvWidth - 10,self.cellHeight))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setTag(idx)
            cell:addChild(backSprie,1)
            backSprie:setPosition(ccp(5,0))
            local moreLabel=GetTTFLabel(getlocal("showMore2"),24)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            
            return cell
        elseif self.battleNumRankTb[idx + 1] then
            local cellBgName,capSet = "RankItemBg.png",CCRect(40, 40, 10, 10)
            if idx < 3 then
                cellBgName,capSet = "rank"..(idx+1).."ItemBg.png" ,CCRect(20, 20, 10, 10)
            end
            local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName(cellBgName,capSet,function () end)
            cellBgSp:setContentSize(CCSizeMake(self.tvWidth - 10,self.cellHeight))
            cellBgSp:setAnchorPoint(ccp(0,0))
            cell:addChild(cellBgSp)
            cellBgSp:setPosition(ccp(5,0))

            local personInfo = self.battleNumRankTb[idx + 1]
            -- print("#personInfo===>>>>",#personInfo,personInfo[1],personInfo[2],personInfo[3],personInfo[4])
            for i=1,#personInfo do
                local showLb = GetTTFLabelWrap(personInfo[i],23,CCSizeMake(self.tvWidth * 0.28,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                showLb:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[i],self.cellHeight*0.5))
                cell:addChild(showLb)
                if showLb:getContentSize().width > self.tvWidth * 0.28 then
                    showLb:setScale((self.tvWidth * 0.28-4)/showLb:getContentSize().width)
                end
                if i == 2 and GetServerNameByID(base.curZoneID,true).."-"..playerVoApi:getPlayerName() == personInfo[i] then
                    self.playerInfoTb[self.curTabTag] = idx + 1
                    self.battleDataTb[1] = personInfo[4]
                end
            end
            if idx < 3 then
                rankSp=CCSprite:createWithSpriteFrameName("top"..(idx+1)..".png")
                rankSp:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[1],self.cellHeight*0.5))
                rankSp:setScale(0.8)
                cell:addChild(rankSp)
            end
        end

        return cell
    end
end

function believerBattleRankTab:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.dmgRateRankNums > self.cellNum2 then
            return self.cellNum2 + 1
        else
            return self.dmgRateRankNums
        end
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local backSprie
        if idx == 50 and self.cellNum2 == 50 then
            local function cellClick(hd,fn,idx)
                self.cellNum2 = 100
                local recordPoint = self.tv2:getRecordPoint()
                self.tv2:reloadData()
                recordPoint.y=(50 - self.dmgRateRankNums + 1)*self.cellHeight+recordPoint.y
                self.tv2:recoverToRecordPoint(recordPoint)
            end
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie:setContentSize(CCSizeMake(self.tvWidth,self.cellHeight))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setTag(idx)
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMore2"),24)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            
            return cell
        elseif self.dmgRateRankTb[idx + 1] then
            local cellBgName,capSet = "RankItemBg.png",CCRect(40, 40, 10, 10)
            if idx < 3 then
                cellBgName,capSet = "rank"..(idx+1).."ItemBg.png" ,CCRect(20, 20, 10, 10)
            end
            local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName(cellBgName,capSet,function () end)
            cellBgSp:setContentSize(CCSizeMake(self.tvWidth - 10,self.cellHeight))
            cellBgSp:setAnchorPoint(ccp(0,0))
            cell:addChild(cellBgSp)
            cellBgSp:setPosition(ccp(5,0))

            local personInfo = self.dmgRateRankTb[idx + 1]
            for i=1,4 do
                local showLb = GetTTFLabelWrap(personInfo[i],23,CCSizeMake(self.tvWidth * 0.28,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                showLb:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[i],self.cellHeight*0.5))
                cell:addChild(showLb)
                if showLb:getContentSize().width > self.tvWidth * 0.28 then
                    showLb:setScale((self.tvWidth * 0.28-4)/showLb:getContentSize().width)
                end

                if i == 2 and GetServerNameByID(base.curZoneID,true).."-"..playerVoApi:getPlayerName() == personInfo[i] then
                    self.playerInfoTb[self.curTabTag] = idx + 1
                    self.battleDataTb[2] = personInfo[4]
                end
            end
            if idx < 3 then
                rankSp=CCSprite:createWithSpriteFrameName("top"..(idx+1)..".png")
                rankSp:setPosition(ccp(self.tvWidth * self.rankNeedStrPosxScaleTb[1],self.cellHeight*0.5))
                rankSp:setScale(0.8)
                cell:addChild(rankSp)
            end

        end
        return cell
    end
end

function believerBattleRankTab:showNoDataTipDia(useType)
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
function believerBattleRankTab:dealWithSelfData(useType)
    self.topCellBg:setVisible(useType)--背景
    if self.playerFidAndName then--名字
        self.playerFidAndName:setVisible(useType)
    end
    if self.ranking then--排名
        self.ranking:setVisible(useType)
    end
    if self.rankTopSp then--前三排名
        self.rankTopSp:setVisible(useType)
    end
    if self.segStr then--段位
        self.segStr:setVisible(useType)
    end
    if self.battleTotalNumsOrDmg then--相关数据
        self.battleTotalNumsOrDmg:setVisible(useType)
    end
end
return believerBattleRankTab