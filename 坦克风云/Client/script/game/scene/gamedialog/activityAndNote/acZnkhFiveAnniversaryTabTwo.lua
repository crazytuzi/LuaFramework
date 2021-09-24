acZnkhFiveAnniversaryTabTwo = {}

function acZnkhFiveAnniversaryTabTwo:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    return nc
end

function acZnkhFiveAnniversaryTabTwo:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    self:tabBtnClick(1)
    return self.bgLayer
end

function acZnkhFiveAnniversaryTabTwo:initUI()
    local tabLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 3, 1, 1), function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5, 0.8))
    tabLine:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 220)
    self.bgLayer:addChild(tabLine)
    self.allTabBtn = {}
    local tabBtn = CCMenu:create()
    for i = 1, 2 do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 0))
        tabBtnItem:setPosition((tabLine:getPositionX() - tabLine:getContentSize().width / 2) + (i - 1) * (tabBtnItem:getContentSize().width + 2), tabLine:getPositionY())
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)
        
        local titleStr = getlocal("activity_znkh2018_tab2_title" .. i)
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
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("activity_znkh2018_tab1_tipsDesc1", {acZnkhFiveAnniversaryVoApi:getRankNum()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc2", {acZnkhFiveAnniversaryVoApi:getRankRecharge()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc3", {acZnkhFiveAnniversaryVoApi:getLuckyNum()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc4"), 
            getlocal("activity_znkh2018_tab1_tipsDesc5"), 
            getlocal("activity_znkh2018_tab1_tipsDesc6"), 
            getlocal("activity_znkh2018_tab1_tipsDesc7"), 
        }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(G_VisibleSizeWidth - 10 - infoBtn:getContentSize().width / 2, G_VisibleSizeHeight - 300))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(infoMenu)
    
    local descLb1 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_desc1", {acZnkhFiveAnniversaryVoApi:getDN()}), 22, CCSizeMake(G_VisibleSizeWidth - infoBtn:getContentSize().width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb1:setAnchorPoint(ccp(0, 0.5))
    descLb1:setPosition(20, G_VisibleSizeHeight - 280)
    self.bgLayer:addChild(descLb1)
    self.descLb1 = descLb1
    local descLb2 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_desc2", {acZnkhFiveAnniversaryVoApi:getRankRecharge()}), 22, CCSizeMake(G_VisibleSizeWidth - infoBtn:getContentSize().width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb2:setAnchorPoint(ccp(0, 0.5))
    descLb2:setPosition(20, descLb1:getPositionY() - descLb1:getContentSize().height / 2 - 20 - descLb2:getContentSize().height / 2)
    self.bgLayer:addChild(descLb2)
    
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
    
    local titleLb1 = GetTTFLabel(getlocal("rank"), fontSize, true)
    local titleLb2 = GetTTFLabel(getlocal("serverwar_server_name"), fontSize, true)
    local titleLb3 = GetTTFLabel(getlocal("RankScene_name"), fontSize, true)
    local titleLb4 = GetTTFLabel(getlocal("activity_RewardingBack_rechargeGold"), fontSize, true)
    titleLb1:setPosition(tvTitleBg:getContentSize().width * 0.10, tvTitleBg:getContentSize().height / 2)
    titleLb2:setPosition(tvTitleBg:getContentSize().width * 0.30, tvTitleBg:getContentSize().height / 2)
    titleLb3:setPosition(tvTitleBg:getContentSize().width * 0.55, tvTitleBg:getContentSize().height / 2)
    titleLb4:setPosition(tvTitleBg:getContentSize().width * 0.85, tvTitleBg:getContentSize().height / 2)
    titleLb1:setColor(G_ColorYellowPro)
    titleLb2:setColor(G_ColorYellowPro)
    titleLb3:setColor(G_ColorYellowPro)
    titleLb4:setColor(G_ColorYellowPro)
    tvTitleBg:addChild(titleLb1)
    tvTitleBg:addChild(titleLb2)
    tvTitleBg:addChild(titleLb3)
    tvTitleBg:addChild(titleLb4)

    --自己的排名
    local myCellHeight = 50
    local myLabelPosY = tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - myCellHeight / 2 - 5 / 2
    local myLabel1 = GetTTFLabel(getlocal("ladderRank_noRank"), fontSize)
    local myLabel2 = GetTTFLabel(tostring(base.curZoneID), fontSize)
    local myLabel3 = GetTTFLabel(playerVoApi:getPlayerName(), fontSize)
    local myLabel4 = GetTTFLabel(tostring(acZnkhFiveAnniversaryVoApi:getDN()), fontSize)
    myLabel1:setPosition(tvTitleBg:getContentSize().width * 0.10, myLabelPosY)
    myLabel2:setPosition(tvTitleBg:getContentSize().width * 0.30, myLabelPosY)
    myLabel3:setPosition(tvTitleBg:getContentSize().width * 0.55, myLabelPosY)
    myLabel4:setPosition(tvTitleBg:getContentSize().width * 0.85, myLabelPosY)
    myLabel1:setColor(G_ColorYellowPro)
    myLabel2:setColor(G_ColorYellowPro)
    myLabel3:setColor(G_ColorYellowPro)
    myLabel4:setColor(G_ColorYellowPro)
    tvBg:addChild(myLabel1)
    tvBg:addChild(myLabel2)
    tvBg:addChild(myLabel3)
    tvBg:addChild(myLabel4)
    self.myLabel1 = myLabel1
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

function acZnkhFiveAnniversaryTabTwo:initCellData()
	if self.selectedTabBtnIndex == 1 then
    	self.rankData = acZnkhFiveAnniversaryVoApi:getDRank()
    else
    	self.rankData = acZnkhFiveAnniversaryVoApi:getYRank()
    end
    self.cellNum = SizeOfTable(self.rankData or {})
    if self.cellNum <= 0 then
    	if self.notDataLabel == nil then
    		local notLabelStr = getlocal("serverWarLocal_noData")
    		if acZnkhFiveAnniversaryVoApi:isRewardTime() == true then
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

function acZnkhFiveAnniversaryTabTwo:tvCallBack(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
    	return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 50)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = self.tvSize.width, 50
        local rankSp
        if (index + 1) > 3 then
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
	    if data[1] == playerVoApi:getUid() then
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
        label1:setPosition(cellW * 0.10, cellH / 2)
        label2:setPosition(cellW * 0.30, cellH / 2)
        label3:setPosition(cellW * 0.55, cellH / 2)
        label4:setPosition(cellW * 0.85, cellH / 2)
        cell:addChild(label1)
        cell:addChild(label2)
        cell:addChild(label3)
        cell:addChild(label4)
        if (index + 1) <= acZnkhFiveAnniversaryVoApi:getRankNum() then
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

function acZnkhFiveAnniversaryTabTwo:tabBtnClick(idx)
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

function acZnkhFiveAnniversaryTabTwo:onTabBtnClick(idx)
	if self.descLb1 and tolua.cast(self.descLb1, "CCLabelTTF") then
		local descLb1 = tolua.cast(self.descLb1, "CCLabelTTF")
		if idx == 1 then
			descLb1:setString(getlocal("activity_znkh2018_tab2_desc1", {acZnkhFiveAnniversaryVoApi:getDN()}))
		else
			descLb1:setString(getlocal("activity_znkh2018_tab2_desc3", {acZnkhFiveAnniversaryVoApi:getYN()}))
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
	if self.myLabel1 and tolua.cast(self.myLabel1, "CCLabelTTF") then
		local myLabel1 = tolua.cast(self.myLabel1, "CCLabelTTF")
		myLabel1:setString(getlocal("ladderRank_noRank"))
	end
	if self.myLabel4 and tolua.cast(self.myLabel4, "CCLabelTTF") then
		local myLabel4 = tolua.cast(self.myLabel4, "CCLabelTTF")
		if idx == 1 then
			myLabel4:setString(tostring(acZnkhFiveAnniversaryVoApi:getDN()))
		else
			myLabel4:setString(tostring(acZnkhFiveAnniversaryVoApi:getYN()))
		end
	end
	self:initCellData()
	if self.tv then
		self.tv:reloadData()
	end
end

function acZnkhFiveAnniversaryTabTwo:tick()
	if self and self.initTimer then
		if base.serverTime - self.initTimer >= 30 * 60 then
			self.initTimer = base.serverTime
			acZnkhFiveAnniversaryVoApi:requestRankData(function()
				--刷新列表数据
				if self.selectedTabBtnIndex == 1 then
					self:onTabBtnClick(self.selectedTabBtnIndex)
				end
			end)
		end
	end
end

function acZnkhFiveAnniversaryTabTwo:dispose()
	self.initTimer = nil
	self.notDataLabel = nil
    self = nil
end