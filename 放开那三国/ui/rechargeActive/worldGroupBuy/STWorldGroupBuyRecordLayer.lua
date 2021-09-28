STWorldGroupBuyRecordLayer = class("STWorldGroupBuyRecordLayer", function()
    return STLayer:create()
end)


function STWorldGroupBuyRecordLayer:create()
    local ret = STWorldGroupBuyRecordLayer:new()
    local bgSprite = ret:createBgSprite(true)
    ret:addChild(bgSprite)
    ret._layer = ret
    return ret
end

function STWorldGroupBuyRecordLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(620.0, 850.0))
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_5_12_12 = self:createSprite_5_12_12(isRootLayer)
    ret:addChild(Sprite_5_12_12)
    local backBtn = self:createBackBtn(isRootLayer)
    ret:addChild(backBtn)
    local Image_2_0_15_11 = self:createImage_2_0_15_11(isRootLayer)
    ret:addChild(Image_2_0_15_11)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createSprite_5_12_12(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_12_12")
    ret:setPosition(ccp(309.008, 844.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.4984)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title_12_10 = self:createTitle_12_10(isRootLayer)
    ret:addChild(title_12_10)
    if isRootLayer then
        self._Sprite_5_12_12 = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createTitle_12_10(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10285"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title_12_10")
    ret:setPosition(ccp(157.5, 30.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 228.0, 0.0))
    if isRootLayer then
        self._title_12_10 = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createBackBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("backBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setPosition(ccp(627.0, 874.0))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._backBtn = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createImage_2_0_15_11(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_15_11")
    ret:setContentSize(CCSizeMake(569.0, 745.0))
    ret:setPosition(ccp(310.0, 45.92))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local tableView = self:createTableView(isRootLayer)
    ret:addChild(tableView)
    if isRootLayer then
        self._Image_2_0_15_11 = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("tableView")
    ret:setContentSize(CCSizeMake(566.0, 726.0))
    ret:setInnerSize(CCSizeMake(566.0, 726.0))
    ret:setPosition(ccp(284.5, 8.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    local cell = self:createCell(isRootLayer)
    ret:addChild(cell)
    if isRootLayer then
        self._tableView = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(566.0, 144.0))
    ret:setPosition(ccp(0.0, 582.0))
    ret:setTouchEnabled(true)
    local cellBg = self:createCellBg(isRootLayer)
    ret:addChild(cellBg)
    if isRootLayer then
        self._cell = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/y_9s_bg.png", CCRectMake(27.0, 36.0, 28.0, 39.0))
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(554.0, 140.0))
    ret:setPosition(ccp(283.0, 72.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local cellTextBg = self:createCellTextBg(isRootLayer)
    ret:addChild(cellTextBg)
    local timeLabel = self:createTimeLabel(isRootLayer)
    ret:addChild(timeLabel)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createCellTextBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("cellTextBg")
    ret:setContentSize(CCSizeMake(532.0, 95.0))
    ret:setPosition(ccp(277.0, 13.92))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local textLabel = self:createTextLabel(isRootLayer)
    ret:addChild(textLabel)
    if isRootLayer then
        self._cellTextBg = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createTextLabel(isRootLayer)
    local ret = STLabel:create("2015-8-10 23", g_sFontName, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("textLabel")
    ret:setPosition(ccp(13.0, 83.5))
    ret:setAnchorPoint(ccp(0.0, 1.0))
    if isRootLayer then
        self._textLabel = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:createTimeLabel(isRootLayer)
    local ret = STLabel:create("2015-8-10 23", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("timeLabel")
    ret:setPosition(ccp(13.0, 121.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._timeLabel = ret
    end
    return ret
end

function STWorldGroupBuyRecordLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
