acKfczTabTwo = {}

function acKfczTabTwo:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	return nc
end

function acKfczTabTwo:init()
	self.bgLayer = CCLayer:create()
    self:initUI()
    self:tabBtnClick(1)
    return self.bgLayer
end

function acKfczTabTwo:initUI()
	local tabLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 3, 1, 1), function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5, 0.8))
    tabLine:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 220)
    self.bgLayer:addChild(tabLine)
    self.allTabBtn = {}
    local tabBtn = CCMenu:create()
    for i = 1, 3 do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 0))
        tabBtnItem:setPosition((tabLine:getPositionX() - tabLine:getContentSize().width / 2) + (i - 1) * (tabBtnItem:getContentSize().width + 2), tabLine:getPositionY())
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)
        
        local titleStr = getlocal("activity_kfcz_tab2_title" .. i)
        local lb = GetTTFLabelWrap(titleStr, 24, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
        tabBtnItem:addChild(lb, 1)
        
        local function tabClick(idx)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            return self:tabBtnClick(idx)
        end
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabBtn[i] = tabBtnItem
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(tabBtn)
    
    local descLb1 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_desc1", {acKfczVoApi:getDN()}), 22, CCSizeMake(G_VisibleSizeWidth - 110, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb1:setAnchorPoint(ccp(0, 0.5))
    descLb1:setPosition(20, G_VisibleSizeHeight - 280)
    self.bgLayer:addChild(descLb1)
    self.descLb1 = descLb1
    local descLb2 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_desc2", {acKfczVoApi:getRankRecharge()}), 22, CCSizeMake(G_VisibleSizeWidth - 110, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb2:setAnchorPoint(ccp(0, 0.5))
    descLb2:setPosition(20, descLb1:getPositionY() - descLb1:getContentSize().height / 2 - 20 - descLb2:getContentSize().height / 2)
    self.bgLayer:addChild(descLb2)
    self.descLb2 = descLb2
    
    local fontSize = 22
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 26, descLb2:getPositionY() - descLb2:getContentSize().height / 2 - 100))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, descLb2:getPositionY() - descLb2:getContentSize().height / 2 - 50)
    self.bgLayer:addChild(tvBg)
    self.tvBg = tvBg
    
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, 45))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
    tvBg:addChild(tvTitleBg)

    self.tvTitleBgWidth = tvTitleBg:getContentSize().width
    self.lbPosXPer = { {0.10, 0.30, 0.55, 0.85}, {0.15, 0.43, 0.73, 3} }
    
    local titleLb1 = GetTTFLabel(getlocal("rank"), fontSize, true)
    local titleLb2 = GetTTFLabel(getlocal("serverwar_server_name"), fontSize, true)
    local titleLb3 = GetTTFLabel(getlocal("RankScene_name"), fontSize, true)
    local titleLb4 = GetTTFLabel(getlocal("activity_RewardingBack_rechargeGold"), fontSize, true)
    titleLb1:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][1], tvTitleBg:getContentSize().height / 2)
    titleLb2:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][2], tvTitleBg:getContentSize().height / 2)
    titleLb3:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][3], tvTitleBg:getContentSize().height / 2)
    titleLb4:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][4], tvTitleBg:getContentSize().height / 2)
    titleLb1:setColor(G_ColorYellowPro)
    titleLb2:setColor(G_ColorYellowPro)
    titleLb3:setColor(G_ColorYellowPro)
    titleLb4:setColor(G_ColorYellowPro)
    tvTitleBg:addChild(titleLb1)
    tvTitleBg:addChild(titleLb2)
    tvTitleBg:addChild(titleLb3)
    tvTitleBg:addChild(titleLb4)
    self.titleLb1 = titleLb1
    self.titleLb2 = titleLb2
    self.titleLb3 = titleLb3
    self.titleLb4 = titleLb4

    --自己的排名
    local myCellHeight = 50
    local myLabelPosY = tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - myCellHeight / 2 - 5 / 2
    local myLabel1 = GetTTFLabel(getlocal("ladderRank_noRank"), fontSize)
    local myLabel2 = GetTTFLabel(tostring(base.curZoneID), fontSize)
    local myLabel3 = GetTTFLabel(playerVoApi:getPlayerName(), fontSize)
    local myLabel4 = GetTTFLabel(tostring(acKfczVoApi:getDN()), fontSize)
    myLabel1:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][1], myLabelPosY)
    myLabel2:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][2], myLabelPosY)
    myLabel3:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][3], myLabelPosY)
    myLabel4:setPosition(tvTitleBg:getContentSize().width * self.lbPosXPer[1][4], myLabelPosY)
    myLabel1:setColor(G_ColorYellowPro)
    myLabel2:setColor(G_ColorYellowPro)
    myLabel3:setColor(G_ColorYellowPro)
    myLabel4:setColor(G_ColorYellowPro)
    tvBg:addChild(myLabel1)
    tvBg:addChild(myLabel2)
    tvBg:addChild(myLabel3)
    tvBg:addChild(myLabel4)
    self.myLabel1 = myLabel1
    self.myLabel2 = myLabel2
    self.myLabel3 = myLabel3
    self.myLabel4 = myLabel4
    
    self:initCellData()
    self.tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - myCellHeight - 5)
    local hd = LuaEventHandler:createHandler(function(...) return self:tvCallBack(...) end)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setPosition(3, 3)
    tvBg:addChild(self.tv, 1)
    
    local tipLabel = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_refreshTip"), fontSize, CCSizeMake(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipLabel:setAnchorPoint(ccp(0.5, 1))
    tipLabel:setPosition(G_VisibleSizeWidth / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10)
    tipLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipLabel)
    self.tipLabel = tipLabel

    self.initTimer = base.serverTime
end

function acKfczTabTwo:initCellData()
	if self.selectedTabBtnIndex == 1 then
    	self.rankData = acKfczVoApi:getDRank()
    elseif self.selectedTabBtnIndex == 2 then
    	self.rankData = acKfczVoApi:getYRank()
    else
        self.rankData = acKfczVoApi:getKeep()
    end
    self.cellNum = SizeOfTable(self.rankData or {})
    if self.cellNum <= 0 then
    	if self.notDataLabel == nil then
    		local notLabelStr = getlocal("serverWarLocal_noData")
    		if acKfczVoApi:isRewardTime() == true then
    			notLabelStr = getlocal("activity_znkh2018_tab2_endTips")
    		end
    		self.notDataLabel = GetTTFLabelWrap(notLabelStr, 25, CCSizeMake(self.tvBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    		self.notDataLabel:setColor(G_ColorGray)
    		self.notDataLabel:setPosition(self.tvBg:getContentSize().width / 2, self.tvBg:getContentSize().height / 2 - 50)
    		self.tvBg:addChild(self.notDataLabel)
    	end
    else
    	if self.notDataLabel and tolua.cast(self.notDataLabel, "CCNode") then
    		self.notDataLabel:removeFromParentAndCleanup(true)
    		self.notDataLabel = nil
    	end
    end
end

function acKfczTabTwo:tvCallBack(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
    	return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 50)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = self.tvSize.width, 50
        local rankSp
        if (index + 1) > 3 or self.selectedTabBtnIndex == 3 then
	        if (index + 1)%2 ~= 0 then
	            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
	            cellBg:setContentSize(CCSizeMake(cellW, cellH))
	            cellBg:setPosition(cellW / 2, cellH / 2)
	            cell:addChild(cellBg)
	        end
	    else
	    	local cellBg = CCSprite:createWithSpriteFrameName("top_" .. (index + 1) .. ".png")
	    	cellBg:setPosition(cellW / 2, cellH / 2)
	    	cell:addChild(cellBg)
	    	rankSp = CCSprite:createWithSpriteFrameName("top" .. (index + 1) .. ".png")
	    end
	    local data = self.rankData[index + 1]
	    if tonumber(data[1]) == playerVoApi:getUid() then
	    	if self.myLabel1 and tolua.cast(self.myLabel1, "CCLabelTTF") then
	    		local myLabel1 = tolua.cast(self.myLabel1, "CCLabelTTF")
	    		myLabel1:setString(tostring(index + 1))
	    	end
	    	if self.myLabel4 and tolua.cast(self.myLabel4, "CCLabelTTF") then
	    		local myLabel4 = tolua.cast(self.myLabel4, "CCLabelTTF")
	    		myLabel4:setString(tostring(data[4] or 0))
	    	end
	    end
        local fontSize = 22
        local label1 = GetTTFLabel(tostring(index + 1), fontSize)
        local label2 = GetTTFLabel(tostring(data[2] or 0), fontSize)
        local label3 = GetTTFLabel(data[3] or "", fontSize)
        local label4 = GetTTFLabel(tostring(data[4] or 0), fontSize)
        if self.selectedTabBtnIndex == 3 then
            label1:setPosition(cellW * self.lbPosXPer[2][1], cellH / 2)
            label2:setPosition(cellW * self.lbPosXPer[2][2], cellH / 2)
            label3:setPosition(cellW * self.lbPosXPer[2][3], cellH / 2)
            label4:setPosition(cellW * self.lbPosXPer[2][4], cellH / 2)
            label4:setVisible(false)
        else
            label1:setPosition(cellW * self.lbPosXPer[1][1], cellH / 2)
            label2:setPosition(cellW * self.lbPosXPer[1][2], cellH / 2)
            label3:setPosition(cellW * self.lbPosXPer[1][3], cellH / 2)
            label4:setPosition(cellW * self.lbPosXPer[1][4], cellH / 2)
        end
        cell:addChild(label1)
        cell:addChild(label2)
        cell:addChild(label3)
        cell:addChild(label4)
        if self.selectedTabBtnIndex ~= 3 and (index + 1) <= acKfczVoApi:getRankNum() then
            label1:setColor(G_ColorYellowPro)
            label2:setColor(G_ColorYellowPro)
            label3:setColor(G_ColorYellowPro)
            label4:setColor(G_ColorYellowPro)
        end
        if rankSp then
        	rankSp:setScale((cellH - 6) / rankSp:getContentSize().height)
        	rankSp:setPosition(label1:getPosition())
        	cell:addChild(rankSp)
        end
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function acKfczTabTwo:tabBtnClick(idx)
    if self.allTabBtn == nil then
        do return end
    end
    for k, v in pairs(self.allTabBtn) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabBtnIndex = idx
        else
            v:setEnabled(true)
        end
    end
    self:onTabBtnClick(idx)
end

function acKfczTabTwo:onTabBtnClick(idx)
	if self.descLb1 and tolua.cast(self.descLb1, "CCLabelTTF") then
		local descLb1 = tolua.cast(self.descLb1, "CCLabelTTF")
		if idx == 1 then
			descLb1:setString(getlocal("activity_znkh2018_tab2_desc1", {acKfczVoApi:getDN()}))
		elseif idx == 2 then
			descLb1:setString(getlocal("activity_znkh2018_tab2_desc3", {acKfczVoApi:getYN()}))
        else
            descLb1:setString(getlocal("activity_kfcz_tab2_desc1"))
		end
	end
    if self.descLb2 and tolua.cast(self.descLb2, "CCLabelTTF") then
        local descLb2 = tolua.cast(self.descLb2, "CCLabelTTF")
        if idx == 3 then
            descLb2:setString(getlocal("activity_kfcz_tab2_desc2"))
        else
            descLb2:setString(getlocal("activity_znkh2018_tab2_desc2", {acKfczVoApi:getRankRecharge()}))
        end
    end

    for i = 1, 4 do
        if self["titleLb" .. i] and tolua.cast(self["titleLb" .. i], "CCLabelTTF") then
            local titleLb = tolua.cast(self["titleLb" .. i], "CCLabelTTF")
            if i == 1 then
                if idx == 3 then
                    titleLb:setString(getlocal("numberTextStr"))
                else
                    titleLb:setString(getlocal("rank"))
                end
            elseif i == 4 then
                if idx == 3 then
                    titleLb:setVisible(false)
                else
                    titleLb:setVisible(true)
                end
            end
            if idx == 3 then
                titleLb:setPositionX(self.tvTitleBgWidth * self.lbPosXPer[2][i])
            else
                titleLb:setPositionX(self.tvTitleBgWidth * self.lbPosXPer[1][i])
            end
        end
        if self["myLabel" .. i] and tolua.cast(self["myLabel" .. i], "CCLabelTTF") then
            local myLabel = tolua.cast(self["myLabel" .. i], "CCLabelTTF")
            if i == 1 then
                myLabel:setString(getlocal("ladderRank_noRank"))
            elseif i == 4 then
                if idx == 1 then
                    myLabel:setString(tostring(acKfczVoApi:getDN()))
                else
                    myLabel:setString(tostring(acKfczVoApi:getYN()))
                end
                if idx == 3 then
                    myLabel:setVisible(false)
                else
                    myLabel:setVisible(true)
                end
            end
            if idx == 3 then
                myLabel:setPositionX(self.tvTitleBgWidth * self.lbPosXPer[2][i])
            else
                myLabel:setPositionX(self.tvTitleBgWidth * self.lbPosXPer[1][i])
            end
        end
    end

	if self.tipLabel and tolua.cast(self.tipLabel, "CCLabelTTF") then
		local tipLabel = tolua.cast(self.tipLabel, "CCLabelTTF")
		if idx == 1 then
			tipLabel:setVisible(true)
		else
			tipLabel:setVisible(false)
		end
	end

	self:initCellData()
	if self.tv then
		self.tv:reloadData()
	end
end

function acKfczTabTwo:tick()
	if self and self.initTimer then
		if base.serverTime - self.initTimer >= 30 * 60 then
			self.initTimer = base.serverTime
			acKfczVoApi:requestRankData(function()
				--刷新列表数据
				if self.selectedTabBtnIndex == 1 then
					self:onTabBtnClick(self.selectedTabBtnIndex)
				end
			end)
		end
	end
end

function acKfczTabTwo:dispose()
	self = nil
end