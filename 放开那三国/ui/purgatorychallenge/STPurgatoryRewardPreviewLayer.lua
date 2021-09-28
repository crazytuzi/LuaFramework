STPurgatoryRewardPreviewLayer = class("STPurgatoryRewardPreviewLayer", function()
    return STLayer:create()
end)


function STPurgatoryRewardPreviewLayer:create()
    local ret = STPurgatoryRewardPreviewLayer:new()
    local bgLayer = ret:createBgLayer(true)
    ret:addChild(bgLayer)
    ret._layer = ret
    return ret
end

function STPurgatoryRewardPreviewLayer:createBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setTag(131.0)
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(127.0)
    local bgSprite = self:createBgSprite(isRootLayer)
    ret:addChild(bgSprite)
    if isRootLayer then
        self._bgLayer = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(630.0, 860.0))
    ret:setTag(132.0)
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local closeBtn = self:createCloseBtn(isRootLayer)
    ret:addChild(closeBtn)
    local Sprite_5_10_3 = self:createSprite_5_10_3(isRootLayer)
    ret:addChild(Sprite_5_10_3)
    local Image_2_0_18_9 = self:createImage_2_0_18_9(isRootLayer)
    ret:addChild(Image_2_0_18_9)
    local tipLabel = self:createTipLabel(isRootLayer)
    ret:addChild(tipLabel)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createCloseBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("closeBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setTag(133.0)
    ret:setPosition(ccp(639.988, 876.9982))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._closeBtn = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createSprite_5_10_3(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_10_3")
    ret:setContentSize(CCSizeMake(315.0, 61.0))
    ret:setTag(136.0)
    ret:setPosition(ccp(315.0, 853.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title_14_3 = self:createTitle_14_3(isRootLayer)
    ret:addChild(title_14_3)
    if isRootLayer then
        self._Sprite_5_10_3 = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createTitle_14_3(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10270"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title_14_3")
    ret:setTag(137.0)
    ret:setPosition(ccp(157.5, 30.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 228.0, 0.0))
    if isRootLayer then
        self._title_14_3 = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createImage_2_0_18_9(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_18_9")
    ret:setContentSize(CCSizeMake(570.0, 717.0))
    ret:setTag(138.0)
    ret:setPosition(ccp(315.0, 45.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local tableView = self:createTableView(isRootLayer)
    ret:addChild(tableView)
    if isRootLayer then
        self._Image_2_0_18_9 = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("tableView")
    ret:setContentSize(CCSizeMake(570.0, 695.0))
    ret:setInnerSize(CCSizeMake(570.0, 695.0))
    ret:setTag(139.0)
    ret:setPosition(ccp(285.0, 10.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setBgColor(ccc3(150.0, 150.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    local cell = self:createCell(isRootLayer)
    ret:addChild(cell)
    if isRootLayer then
        self._tableView = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(570.0, 200.0))
    ret:setTag(140.0)
    ret:setPosition(ccp(0.0, 495.0))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    local cellBg = self:createCellBg(isRootLayer)
    ret:addChild(cellBg)
    if isRootLayer then
        self._cell = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/reward/cell_back.png", CCRectMake(38.0, 40.0, 31.0, 44.0))
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(560.0, 200.0))
    ret:setTag(141.0)
    ret:setPosition(ccp(285.0, 99.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local innerBg = self:createInnerBg(isRootLayer)
    ret:addChild(innerBg)
    local titleBg = self:createTitleBg(isRootLayer)
    ret:addChild(titleBg)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createInnerBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/s9_3.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("innerBg")
    ret:setContentSize(CCSizeMake(500.0, 125.0))
    ret:setTag(142.0)
    ret:setPosition(ccp(21.896, 82.62))
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

function STPurgatoryRewardPreviewLayer:createRewardTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setName("rewardTableView")
    ret:setContentSize(CCSizeMake(480.0, 125.0))
    ret:setInnerSize(CCSizeMake(480.0, 125.0))
    ret:setTag(143.0)
    ret:setPosition(ccp(250.0, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setBgColor(ccc3(150.0, 150.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._rewardTableView = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createTitleBg(isRootLayer)
    local ret = STSprite:create("images/sign/sign_bottom.png")
    ret:setName("titleBg")
    ret:setContentSize(CCSizeMake(247.0, 55.0))
    ret:setTag(144.0)
    ret:setPosition(ccp(0.0, 200.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0)
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

function STPurgatoryRewardPreviewLayer:createRewardNameLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("djn_14"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("rewardNameLabel")
    ret:setTag(145.0)
    ret:setPosition(ccp(123.5, 27.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._rewardNameLabel = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:createTipLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10271"), g_sFontPangWa, 25, 1, ccc3(255, 255, 255), type_shadow)
    ret:setName("tipLabel")
    ret:setTag(159.0)
    ret:setPosition(ccp(315.0, 798.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tipLabel = ret
    end
    return ret
end

function STPurgatoryRewardPreviewLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
