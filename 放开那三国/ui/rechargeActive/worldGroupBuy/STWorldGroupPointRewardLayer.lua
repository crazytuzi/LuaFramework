STWorldGroupPointRewardLayer = class("STWorldGroupPointRewardLayer", function()
    return STLayer:create()
end)


function STWorldGroupPointRewardLayer:create()
    local ret = STWorldGroupPointRewardLayer:new()
    local bgSprite = ret:createBgSprite(true)
    ret:addChild(bgSprite)
    ret._layer = ret
    return ret
end

function STWorldGroupPointRewardLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(620.0, 850.0))
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setScaleY(1.0518)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_5_12_12 = self:createSprite_5_12_12(isRootLayer)
    ret:addChild(Sprite_5_12_12)
    local backBtn = self:createBackBtn(isRootLayer)
    ret:addChild(backBtn)
    local Image_2_0_15_11 = self:createImage_2_0_15_11(isRootLayer)
    ret:addChild(Image_2_0_15_11)
    local Text_28 = self:createText_28(isRootLayer)
    ret:addChild(Text_28)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createSprite_5_12_12(isRootLayer)
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

function STWorldGroupPointRewardLayer:createTitle_12_10(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10286"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
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

function STWorldGroupPointRewardLayer:createBackBtn(isRootLayer)
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

function STWorldGroupPointRewardLayer:createImage_2_0_15_11(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_15_11")
    ret:setContentSize(CCSizeMake(569.0, 745.0))
    ret:setPosition(ccp(310.0, 53.9202))
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

function STWorldGroupPointRewardLayer:createTableView(isRootLayer)
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

function STWorldGroupPointRewardLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(570.0, 200.0))
    ret:setPosition(ccp(0.0, 526.0))
    ret:setTouchEnabled(true)
    local cellBg = self:createCellBg(isRootLayer)
    ret:addChild(cellBg)
    if isRootLayer then
        self._cell = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/reward/cell_back.png", CCRectMake(38.0, 49.0, 31.0, 30.0))
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(560.0, 200.0))
    ret:setPosition(ccp(285.0, 99.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local innerBg = self:createInnerBg(isRootLayer)
    ret:addChild(innerBg)
    local receiveBtn = self:createReceiveBtn(isRootLayer)
    ret:addChild(receiveBtn)
    local receivedSprite = self:createReceivedSprite(isRootLayer)
    ret:addChild(receivedSprite)
    local titleBg = self:createTitleBg(isRootLayer)
    ret:addChild(titleBg)
    local progressLabel = self:createProgressLabel(isRootLayer)
    ret:addChild(progressLabel)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createInnerBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/s9_3.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("innerBg")
    ret:setContentSize(CCSizeMake(395.0, 125.0))
    ret:setPosition(ccp(21.896, 81.62))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0391)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local rewardTableView = self:createRewardTableView(isRootLayer)
    ret:addChild(rewardTableView)
    if isRootLayer then
        self._innerBg = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createRewardTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setName("rewardTableView")
    ret:setContentSize(CCSizeMake(371.0, 125.0))
    ret:setInnerSize(CCSizeMake(371.0, 125.0))
    ret:setPosition(ccp(197.5, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._rewardTableView = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createReceiveBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", "images/common/btn/btn_blue_hui.png", true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("lcy_10026"), g_sFontPangWa, 30, ccc3(255.0, 228.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("receiveBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(480.0, 88.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._receiveBtn = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createReceivedSprite(isRootLayer)
    local ret = STSprite:create("images/sign/receive_already.png")
    ret:setName("receivedSprite")
    ret:setPosition(ccp(480.0, 88.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._receivedSprite = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createTitleBg(isRootLayer)
    local ret = STScale9Sprite:create("images/sign/sign_bottom.png", CCRectMake(81.0, 18.0, 85.0, 19.0))
    ret:setName("titleBg")
    ret:setContentSize(CCSizeMake(359.0, 55.0))
    ret:setPosition(ccp(0.0, 200.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.0, 1.0))
    local rewardNameLabel = self:createRewardNameLabel(isRootLayer)
    ret:addChild(rewardNameLabel)
    if isRootLayer then
        self._titleBg = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createRewardNameLabel(isRootLayer)
    local ret = STLabel:create("text", g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("rewardNameLabel")
    ret:setPosition(ccp(179.5, 29.7))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.54)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._rewardNameLabel = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createProgressLabel(isRootLayer)
    local ret = STLabel:create("progress", g_sFontName, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("progressLabel")
    ret:setPosition(ccp(411.502, 166.5347))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._progressLabel = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:createText_28(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10287"), g_sFontName, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_28")
    ret:setPosition(ccp(310.0, 37.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._Text_28 = ret
    end
    return ret
end

function STWorldGroupPointRewardLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
