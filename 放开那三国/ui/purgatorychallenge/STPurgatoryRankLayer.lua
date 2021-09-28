STPurgatoryRankLayer = class("STPurgatoryRankLayer", function()
    return STLayer:create()
end)


function STPurgatoryRankLayer:create()
    local ret = STPurgatoryRankLayer:new()
    local bgLayer = ret:createBgLayer(true)
    ret:addChild(bgLayer)
    ret._layer = ret
    return ret
end

function STPurgatoryRankLayer:createBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setTag(90.0)
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(127.0)
    local bgSprite = self:createBgSprite(isRootLayer)
    ret:addChild(bgSprite)
    if isRootLayer then
        self._bgLayer = ret
    end
    return ret
end

function STPurgatoryRankLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(630.0, 860.0))
    ret:setTag(91.0)
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local closeBtn = self:createCloseBtn(isRootLayer)
    ret:addChild(closeBtn)
    local multipleBtn = self:createMultipleBtn(isRootLayer)
    ret:addChild(multipleBtn)
    local innerBtn = self:createInnerBtn(isRootLayer)
    ret:addChild(innerBtn)
    local Sprite_5_10 = self:createSprite_5_10(isRootLayer)
    ret:addChild(Sprite_5_10)
    local Image_2_0_18 = self:createImage_2_0_18(isRootLayer)
    ret:addChild(Image_2_0_18)
    local Text_29 = self:createText_29(isRootLayer)
    ret:addChild(Text_29)
    local Text_12 = self:createText_12(isRootLayer)
    ret:addChild(Text_12)
    local Text_12_0 = self:createText_12_0(isRootLayer)
    ret:addChild(Text_12_0)
    local myInnerRankLabel = self:createMyInnerRankLabel(isRootLayer)
    ret:addChild(myInnerRankLabel)
    local myMultipleLabel = self:createMyMultipleLabel(isRootLayer)
    ret:addChild(myMultipleLabel)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STPurgatoryRankLayer:createCloseBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("closeBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setTag(94.0)
    ret:setPosition(ccp(639.988, 876.9982))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._closeBtn = ret
    end
    return ret
end

function STPurgatoryRankLayer:createMultipleBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/bg/button/ng_tab_n.png", "images/common/bg/button/ng_tab_h.png", nil, true)
    ret:setCapInsets(CCRectMake(31.0, 16.0, 3.0, 13.0))
    ret:setLabel(GetLocalizeStringBy("key_10254"), g_sFontPangWa, 28, ccc3(255.0, 255.0, 255.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("multipleBtn")
    ret:setContentSize(CCSizeMake(223.0, 43.0))
    ret:setTag(1.0)
    ret:setPosition(ccp(180.9995, 715.0))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._multipleBtn = ret
    end
    return ret
end

function STPurgatoryRankLayer:createInnerBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/bg/button/ng_tab_n.png", "images/common/bg/button/ng_tab_h.png", nil, true)
    ret:setCapInsets(CCRectMake(31.0, 11.0, 3.0, 21.0))
    ret:setLabel(GetLocalizeStringBy("key_10255"), g_sFontPangWa, 28, ccc3(255.0, 255.0, 255.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("innerBtn")
    ret:setContentSize(CCSizeMake(223.0, 43.0))
    ret:setTag(2.0)
    ret:setPosition(ccp(448.0039, 715.0))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._innerBtn = ret
    end
    return ret
end

function STPurgatoryRankLayer:createSprite_5_10(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_10")
    ret:setContentSize(CCSizeMake(315.0, 61.0))
    ret:setTag(92.0)
    ret:setPosition(ccp(315.0, 853.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title_14 = self:createTitle_14(isRootLayer)
    ret:addChild(title_14)
    if isRootLayer then
        self._Sprite_5_10 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createTitle_14(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10256"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title_14")
    ret:setTag(93.0)
    ret:setPosition(ccp(157.5, 30.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 228.0, 0.0))
    if isRootLayer then
        self._title_14 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createImage_2_0_18(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_18")
    ret:setContentSize(CCSizeMake(570.0, 634.0))
    ret:setTag(101.0)
    ret:setPosition(ccp(315.0, 83.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local tableView = self:createTableView(isRootLayer)
    ret:addChild(tableView)
    if isRootLayer then
        self._Image_2_0_18 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("tableView")
    ret:setContentSize(CCSizeMake(570.0, 610.0))
    ret:setInnerSize(CCSizeMake(570.0, 610.0))
    ret:setTag(113.0)
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

function STPurgatoryRankLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(570.0, 119.0))
    ret:setTag(92.0)
    ret:setPosition(ccp(0.0, 491.0))
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

function STPurgatoryRankLayer:createCellBg(isRootLayer)
    local ret = STSprite:create("images/match/first_bg.png")
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(565.0, 111.0))
    ret:setTag(93.0)
    ret:setPosition(ccp(285.0, 59.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local rankSprite = self:createRankSprite(isRootLayer)
    ret:addChild(rankSprite)
    local Sprite_5 = self:createSprite_5(isRootLayer)
    ret:addChild(Sprite_5)
    local headBg = self:createHeadBg(isRootLayer)
    ret:addChild(headBg)
    local Sprite_7 = self:createSprite_7(isRootLayer)
    ret:addChild(Sprite_7)
    local levelLabel = self:createLevelLabel(isRootLayer)
    ret:addChild(levelLabel)
    local playerNameLabel = self:createPlayerNameLabel(isRootLayer)
    ret:addChild(playerNameLabel)
    local Text_17_0_0 = self:createText_17_0_0(isRootLayer)
    ret:addChild(Text_17_0_0)
    local pointLabel = self:createPointLabel(isRootLayer)
    ret:addChild(pointLabel)
    local rankLabel = self:createRankLabel(isRootLayer)
    ret:addChild(rankLabel)
    local serverNameLabel = self:createServerNameLabel(isRootLayer)
    ret:addChild(serverNameLabel)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STPurgatoryRankLayer:createRankSprite(isRootLayer)
    local ret = STSprite:create("images/match/one.png")
    ret:setName("rankSprite")
    ret:setContentSize(CCSizeMake(42.0, 67.0))
    ret:setTag(94.0)
    ret:setPosition(ccp(53.0, 57.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._rankSprite = ret
    end
    return ret
end

function STPurgatoryRankLayer:createSprite_5(isRootLayer)
    local ret = STSprite:create("images/match/ming.png")
    ret:setName("Sprite_5")
    ret:setContentSize(CCSizeMake(41.0, 41.0))
    ret:setTag(95.0)
    ret:setPosition(ccp(112.0, 43.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_5 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createHeadBg(isRootLayer)
    local ret = STSprite:create("images/match/head_bg.png")
    ret:setName("headBg")
    ret:setContentSize(CCSizeMake(106.0, 107.0))
    ret:setTag(96.0)
    ret:setPosition(ccp(196.0, 55.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._headBg = ret
    end
    return ret
end

function STPurgatoryRankLayer:createSprite_7(isRootLayer)
    local ret = STSprite:create("images/common/lv.png")
    ret:setName("Sprite_7")
    ret:setContentSize(CCSizeMake(35.0, 18.0))
    ret:setTag(97.0)
    ret:setPosition(ccp(315.0, 83.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_7 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createLevelLabel(isRootLayer)
    local ret = STLabel:create("100", g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("levelLabel")
    ret:setTag(98.0)
    ret:setPosition(ccp(335.5, 84.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._levelLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createPlayerNameLabel(isRootLayer)
    local ret = STLabel:create("100", g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("playerNameLabel")
    ret:setTag(99.0)
    ret:setPosition(ccp(339.0, 51.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._playerNameLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createText_17_0_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10258"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_17_0_0")
    ret:setTag(101.0)
    ret:setPosition(ccp(522.0, 79.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_17_0_0 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createPointLabel(isRootLayer)
    local ret = STLabel:create("500", g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("pointLabel")
    ret:setTag(102.0)
    ret:setPosition(ccp(481.0, 34.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(112.0, 255.0, 24.0))
    if isRootLayer then
        self._pointLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createRankLabel(isRootLayer)
    local ret = STLabel:create("99", g_sFontPangWa, 35, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("rankLabel")
    ret:setTag(103.0)
    ret:setPosition(ccp(53.0, 57.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._rankLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createServerNameLabel(isRootLayer)
    local ret = STLabel:create("100", g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("serverNameLabel")
    ret:setTag(62.0)
    ret:setPosition(ccp(339.0, 20.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._serverNameLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createText_29(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10259"), g_sFontPangWa, 23)
    ret:setName("Text_29")
    ret:setTag(112.0)
    ret:setPosition(ccp(315.0, 52.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._Text_29 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createText_12(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10268"), g_sFontPangWa, 25)
    ret:setName("Text_12")
    ret:setTag(87.0)
    ret:setPosition(ccp(423.0, 796.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._Text_12 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createText_12_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10269"), g_sFontPangWa, 25)
    ret:setName("Text_12_0")
    ret:setTag(88.0)
    ret:setPosition(ccp(166.0, 796.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._Text_12_0 = ret
    end
    return ret
end

function STPurgatoryRankLayer:createMyInnerRankLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10096"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("myInnerRankLabel")
    ret:setTag(89.0)
    ret:setPosition(ccp(485.0, 796.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(112.0, 255.0, 24.0))
    if isRootLayer then
        self._myInnerRankLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:createMyMultipleLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10096"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("myMultipleLabel")
    ret:setTag(91.0)
    ret:setPosition(ccp(263.0, 796.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(112.0, 255.0, 24.0))
    if isRootLayer then
        self._myMultipleLabel = ret
    end
    return ret
end

function STPurgatoryRankLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
