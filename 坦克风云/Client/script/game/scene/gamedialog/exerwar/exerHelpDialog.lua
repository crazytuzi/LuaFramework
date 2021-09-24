exerHelpDialog = {}

function exerHelpDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    return nc
end

function exerHelpDialog:initTableView()
    self.bgLayer = CCLayer:create()

    self.textData = {{6, {nil, nil, {exerWarVoApi:getWinNum()}}}, 1, {7, {nil, nil, nil, nil, nil, nil, {exerWarVoApi:getWinNum(1)}}}, {6, {nil, {exerWarVoApi:getWinNum(1)}}}, {5, {nil, {exerWarVoApi:getAccessoryPercent()}}}, 3}
    self.cellHeightTb = {}
    local num = SizeOfTable(self.textData)

    local tvSize = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 195)
    local function getCellSize(idx, cellNum)
        if self.cellHeightTb[idx + 1] then
            do return CCSizeMake(tvSize.width, self.cellHeightTb[idx + 1]) end
        end
        local height = 0
        local titleBg = CCSprite:createWithSpriteFrameName("panelSubTitleBg.png")
        height = height + titleBg:getContentSize().height
        height = height + 10
        local textCount = 0
        local data = self.textData[idx + 1]
        local isHaveParams
        if type(data) == "table" then
            textCount = data[1]
            isHaveParams = true
        else
            textCount = data
        end
        for i = 1, textCount do
            local params
            if isHaveParams and type(data[2]) == "table" and data[2][i] then
                params = data[2][i]
            end
            local descStr = getlocal("exerwar_helpTitle" .. (idx + 1) .. "Desc" .. i, params)
            local descLb = GetTTFLabelWrap(descStr, 24, CCSizeMake(tvSize.width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            height = height + descLb:getContentSize().height
        end
        height = height + 10
        self.cellHeightTb[idx + 1] = height
        return CCSizeMake(tvSize.width, height)
    end
    local tv = G_createTableView(tvSize, num, getCellSize, function(...) self:tvCallback(...) end)
    tv:setPosition(0, 100)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(tv)
end

function exerHelpDialog:tvCallback(cell, cellSize, idx, cellNum)
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
    titleBg:setContentSize(CCSizeMake(cellSize.width - 100, titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0, 1))
    titleBg:setPosition(15, cellSize.height)
    cell:addChild(titleBg)
    local titleLb = GetTTFLabel(getlocal("exerwar_helpTitle" .. (idx + 1)), 22, true)
    titleLb:setAnchorPoint(ccp(0, 0.5))
    titleLb:setPosition(15, titleBg:getContentSize().height / 2)
    titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)
    local posY = titleBg:getPositionY() - titleBg:getContentSize().height - 10
    local textCount = 0
    local data = self.textData[idx + 1]
    local isHaveParams
    if type(data) == "table" then
        textCount = data[1]
        isHaveParams = true
    else
        textCount = data
    end
    for i = 1, textCount do
        local params
        if isHaveParams and type(data[2]) == "table" and data[2][i] then
            params = data[2][i]
        end
        local descStr = getlocal("exerwar_helpTitle" .. (idx + 1) .. "Desc" .. i, params)
        local descLb = GetTTFLabelWrap(descStr, 24, CCSizeMake(cellSize.width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0, 1))
        descLb:setPosition(25, posY)
        cell:addChild(descLb)
        posY = posY - descLb:getContentSize().height
    end
end

function exerHelpDialog:tick()
end

function exerHelpDialog:dispose()
    self = nil
end
