acKfczTabThree = {}

function acKfczTabThree:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	return nc
end

function acKfczTabThree:init()
	self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function acKfczTabThree:initUI()
    local descLb1 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab2_desc3", {acKfczVoApi:getYN()}), 22, CCSizeMake(G_VisibleSizeWidth - 110, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb1:setAnchorPoint(ccp(0, 0.5))
    descLb1:setPosition(20, G_VisibleSizeHeight - 230)
    self.bgLayer:addChild(descLb1)
    local descLb2 = GetTTFLabelWrap(getlocal("activity_znkh2018_tab3_desc1"), 22, CCSizeMake(G_VisibleSizeWidth - 110, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    descLb2:setAnchorPoint(ccp(0, 0.5))
    descLb2:setPosition(20, descLb1:getPositionY() - descLb1:getContentSize().height / 2 - 20 - descLb2:getContentSize().height / 2)
    self.bgLayer:addChild(descLb2)

    local fontSize = 22
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 26, descLb2:getPositionY() - descLb2:getContentSize().height / 2 - 70))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, descLb2:getPositionY() - descLb2:getContentSize().height / 2 - 50)
    self.bgLayer:addChild(tvBg)
    
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, 45))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
    tvBg:addChild(tvTitleBg)
    
    local titleLb1 = GetTTFLabel(getlocal("numberTextStr"), fontSize, true)
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
    local myLabel4 = GetTTFLabel(tostring(acKfczVoApi:getYN()), fontSize)
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
    
    self.rankData = acKfczVoApi:getLucky()
    self.cellNum = SizeOfTable(self.rankData or {})
    self.tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - myCellHeight - 5)
    local hd = LuaEventHandler:createHandler(function(...) return self:tvCallBack(...) end)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setPosition(3, 3)
    tvBg:addChild(self.tv, 1)

    if self.cellNum <= 0 then
		local notDataLabel = GetTTFLabel(getlocal("serverWarLocal_noData"), 25)
		notDataLabel:setColor(G_ColorGray)
		notDataLabel:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height / 2 - 50)
		tvBg:addChild(notDataLabel)
	end
end

function acKfczTabThree:tvCallBack(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 50)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = self.tvSize.width, 50
        if (index + 1)%2 ~= 0 then
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
            cellBg:setContentSize(CCSizeMake(cellW, cellH))
            cellBg:setPosition(cellW / 2, cellH / 2)
            cell:addChild(cellBg)
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
        label1:setPosition(cellW * 0.10, cellH / 2)
        label2:setPosition(cellW * 0.30, cellH / 2)
        label3:setPosition(cellW * 0.55, cellH / 2)
        label4:setPosition(cellW * 0.85, cellH / 2)
        cell:addChild(label1)
        cell:addChild(label2)
        cell:addChild(label3)
        cell:addChild(label4)
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function acKfczTabThree:dispose()
	self = nil
end