STWorldCarnivalBattleReportLayer = class("STWorldCarnivalBattleReportLayer", function()
    return STLayer:create()
end)


function STWorldCarnivalBattleReportLayer:create()
    local ret = STWorldCarnivalBattleReportLayer:new()
    local bgSprite = ret:createBgSprite(true)
    ret:addChild(bgSprite)
    ret._layer = ret
    return ret
end

function STWorldCarnivalBattleReportLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(600.0, 793.0))
    ret:setPosition(ccp(318.976, 479.04))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.4984)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.499)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_5_12 = self:createSprite_5_12(isRootLayer)
    ret:addChild(Sprite_5_12)
    local closeBtn = self:createCloseBtn(isRootLayer)
    ret:addChild(closeBtn)
    local Image_2_0_15 = self:createImage_2_0_15(isRootLayer)
    ret:addChild(Image_2_0_15)
    local leftNameLabel = self:createLeftNameLabel(isRootLayer)
    ret:addChild(leftNameLabel)
    local rightServerNameLabel = self:createRightServerNameLabel(isRootLayer)
    ret:addChild(rightServerNameLabel)
    local rightNameLabel = self:createRightNameLabel(isRootLayer)
    ret:addChild(rightNameLabel)
    local leftServerNameLabel = self:createLeftServerNameLabel(isRootLayer)
    ret:addChild(leftServerNameLabel)
    local vsSprite = self:createVsSprite(isRootLayer)
    ret:addChild(vsSprite)
    local confirmBtn = self:createConfirmBtn(isRootLayer)
    ret:addChild(confirmBtn)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createSprite_5_12(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_12")
    ret:setPosition(ccp(300.0, 786.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title_12 = self:createTitle_12(isRootLayer)
    ret:addChild(title_12)
    if isRootLayer then
        self._Sprite_5_12 = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createTitle_12(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("lcy_10052"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title_12")
    ret:setPosition(ccp(157.5, 30.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 228.0, 0.0))
    if isRootLayer then
        self._title_12 = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createCloseBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("closeBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setPosition(ccp(603.0, 823.0))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._closeBtn = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createImage_2_0_15(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_15")
    ret:setContentSize(CCSizeMake(555.0, 560.0))
    ret:setPosition(ccp(300.0, 390.42))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local reportTableView = self:createReportTableView(isRootLayer)
    ret:addChild(reportTableView)
    if isRootLayer then
        self._Image_2_0_15 = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createReportTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("reportTableView")
    ret:setContentSize(CCSizeMake(545.0, 539.0))
    ret:setInnerSize(CCSizeMake(545.0, 539.0))
    ret:setPosition(ccp(277.5, 280.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local reportCell = self:createReportCell(isRootLayer)
    ret:addChild(reportCell)
    if isRootLayer then
        self._reportTableView = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createReportCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("reportCell")
    ret:setContentSize(CCSizeMake(540.0, 210.0))
    ret:setPosition(ccp(0.0, 329.0))
    ret:setTouchEnabled(true)
    local cellBg = self:createCellBg(isRootLayer)
    ret:addChild(cellBg)
    if isRootLayer then
        self._reportCell = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/guild/battlereport/winbg.png", CCRectMake(54.0, 58.0, 11.0, 16.0))
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(540.0, 180.0))
    ret:setPosition(ccp(270.0, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local roundBg = self:createRoundBg(isRootLayer)
    ret:addChild(roundBg)
    local checkReportBtn = self:createCheckReportBtn(isRootLayer)
    ret:addChild(checkReportBtn)
    local cellVsSprite = self:createCellVsSprite(isRootLayer)
    ret:addChild(cellVsSprite)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createRoundBg(isRootLayer)
    local ret = STSprite:create("images/guild/battlereport/wintitle.png")
    ret:setName("roundBg")
    ret:setPosition(ccp(270.0, 191.0001))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    local roundLabel = self:createRoundLabel(isRootLayer)
    ret:addChild(roundLabel)
    if isRootLayer then
        self._roundBg = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createRoundLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 24)
    ret:setName("roundLabel")
    ret:setPosition(ccp(106.5, 21.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._roundLabel = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createCheckReportBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("key_2849"), g_sFontPangWa, 30, ccc3(255.0, 228.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("checkReportBtn")
    ret:setContentSize(CCSizeMake(160.0, 64.0))
    ret:setPosition(ccp(270.0, 41.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._checkReportBtn = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createCellVsSprite(isRootLayer)
    local ret = STSprite:create("images/arena/vs.png")
    ret:setName("cellVsSprite")
    ret:setPosition(ccp(270.0, 110.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._cellVsSprite = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createLeftNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("leftNameLabel")
    ret:setPosition(ccp(120.0, 735.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._leftNameLabel = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createRightServerNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("rightServerNameLabel")
    ret:setPosition(ccp(480.0, 706.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._rightServerNameLabel = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createRightNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("rightNameLabel")
    ret:setPosition(ccp(480.0, 735.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._rightNameLabel = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createLeftServerNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("leftServerNameLabel")
    ret:setPosition(ccp(120.0, 706.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._leftServerNameLabel = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createVsSprite(isRootLayer)
    local ret = STSprite:create("images/arena/vs.png")
    ret:setName("vsSprite")
    ret:setPosition(ccp(300.0, 723.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setScaleX(0.78)
    ret:setScaleY(0.78)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._vsSprite = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:createConfirmBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 150.0, 73.0))
    ret:setLabel(GetLocalizeStringBy("key_1061"), g_sFontPangWa, 35, ccc3(254.0, 219.0, 28.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("confirmBtn")
    ret:setContentSize(CCSizeMake(198.0, 73.0))
    ret:setPosition(ccp(300.0, 64.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._confirmBtn = ret
    end
    return ret
end

function STWorldCarnivalBattleReportLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
