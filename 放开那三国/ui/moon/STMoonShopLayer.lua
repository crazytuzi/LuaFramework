STMoonShopLayer = class("STMoonShopLayer", function()
    return STLayer:create()
end)


function STMoonShopLayer:create()
    local ret = STMoonShopLayer:new()
    ret._layer = ret
    return ret
end

function STMoonShopLayer:createCenterLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("centerLayer")
    ret:setContentSize(CCSizeMake(640.0, 669.0))
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setTouchEnabled(true)
    local girlSprite = self:createGirlSprite(isRootLayer)
    ret:addChild(girlSprite)
    local boxLayer = self:createBoxLayer(isRootLayer)
    ret:addChild(boxLayer)
    local goodsTableViewBg = self:createGoodsTableViewBg(isRootLayer)
    ret:addChild(goodsTableViewBg)
    local refreshBtn = self:createRefreshBtn(isRootLayer)
    ret:addChild(refreshBtn)
    local tipLabel = self:createTipLabel(isRootLayer)
    ret:addChild(tipLabel)
    local freeRefreshCountLabel = self:createFreeRefreshCountLabel(isRootLayer)
    ret:addChild(freeRefreshCountLabel)
    local titleSprite = self:createTitleSprite(isRootLayer)
    ret:addChild(titleSprite)
    if isRootLayer then
        self._centerLayer = ret
    end
    return ret
end

function STMoonShopLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/shop_bg.png", CCRectMake(18.0, 16.0, 19.0, 18.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(640.0, 669.0))
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STMoonShopLayer:createGirlSprite(isRootLayer)
    local ret = STSprite:create("images/moon/moon_shop_girl.png")
    ret:setName("girlSprite")
    ret:setPosition(ccp(-29.0, 334.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._girlSprite = ret
    end
    return ret
end

function STMoonShopLayer:createBoxLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("boxLayer")
    ret:setContentSize(CCSizeMake(0.0, 0.0))
    ret:setPosition(ccp(0.0, 575.34))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.86)
    ret:setTouchEnabled(true)
    local openBoxBtn = self:createOpenBoxBtn(isRootLayer)
    ret:addChild(openBoxBtn)
    local previewBtn = self:createPreviewBtn(isRootLayer)
    ret:addChild(previewBtn)
    local remainBoxTimesBg = self:createRemainBoxTimesBg(isRootLayer)
    ret:addChild(remainBoxTimesBg)
    if isRootLayer then
        self._boxLayer = ret
    end
    return ret
end

function STMoonShopLayer:createOpenBoxBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", nil, true)
    ret:setCapInsets(CCRectMake(52.0, 11.0, 43.0, 51.0))
    ret:setLabel(GetLocalizeStringBy("zz_116"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("openBoxBtn")
    ret:setContentSize(CCSizeMake(190.0, 73.0))
    ret:setPosition(ccp(108.0, -65.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._openBoxBtn = ret
    end
    return ret
end

function STMoonShopLayer:createPreviewBtn(isRootLayer)
    local ret = STButton:createWithImage("images/moon/moon_box_n.png", "images/moon/moon_box_h.png", nil, false)
    ret:setName("previewBtn")
    ret:setPosition(ccp(108.0, 21.65))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._previewBtn = ret
    end
    return ret
end

function STMoonShopLayer:createRemainBoxTimesBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/hui_bg.png", CCRectMake(0.0, 0.0, 209.0, 49.0))
    ret:setName("remainBoxTimesBg")
    ret:setContentSize(CCSizeMake(209.0, 49.0))
    ret:setPosition(ccp(108.0, -127.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local remainBoxTimesLabel = self:createRemainBoxTimesLabel(isRootLayer)
    ret:addChild(remainBoxTimesLabel)
    if isRootLayer then
        self._remainBoxTimesBg = ret
    end
    return ret
end

function STMoonShopLayer:createRemainBoxTimesLabel(isRootLayer)
    local ret = STLabel:create("10/10", g_sFontName, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("remainBoxTimesLabel")
    ret:setPosition(ccp(104.5, 24.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._remainBoxTimesLabel = ret
    end
    return ret
end

function STMoonShopLayer:createGoodsTableViewBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/9s_1.png", CCRectMake(32.0, 32.0, 35.0, 33.0))
    ret:setName("goodsTableViewBg")
    ret:setContentSize(CCSizeMake(438.0, 460.0))
    ret:setPosition(ccp(631.296, 551.1178))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.9864)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8238)
    ret:setAnchorPoint(ccp(1.0, 1.0))
    local goodsTableView = self:createGoodsTableView(isRootLayer)
    ret:addChild(goodsTableView)
    local Image_4 = self:createImage_4(isRootLayer)
    ret:addChild(Image_4)
    if isRootLayer then
        self._goodsTableViewBg = ret
    end
    return ret
end

function STMoonShopLayer:createGoodsTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("goodsTableView")
    ret:setContentSize(CCSizeMake(435.0, 440.0))
    ret:setInnerSize(CCSizeMake(435.0, 440.0))
    ret:setPosition(ccp(219.0, 230.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setTouchEnabled(true)
    local goodsCell = self:createGoodsCell(isRootLayer)
    ret:addChild(goodsCell)
    if isRootLayer then
        self._goodsTableView = ret
    end
    return ret
end

function STMoonShopLayer:createGoodsCell(isRootLayer)
    local ret = STScale9Sprite:create("images/reward/cell_back.png", CCRectMake(38.0, 40.0, 31.0, 44.0))
    ret:setName("goodsCell")
    ret:setContentSize(CCSizeMake(435.0, 146.0))
    ret:setPosition(ccp(217.5, 367.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local infoBg = self:createInfoBg(isRootLayer)
    ret:addChild(infoBg)
    local buyBtn = self:createBuyBtn(isRootLayer)
    ret:addChild(buyBtn)
    local restTimesLabel = self:createRestTimesLabel(isRootLayer)
    ret:addChild(restTimesLabel)
    local exchangeBtn = self:createExchangeBtn(isRootLayer)
    ret:addChild(exchangeBtn)
    if isRootLayer then
        self._goodsCell = ret
    end
    return ret
end

function STMoonShopLayer:createInfoBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/s9_3.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("infoBg")
    ret:setContentSize(CCSizeMake(279.0, 106.0))
    ret:setPosition(ccp(19.0, 73.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local goodsIcon = self:createGoodsIcon(isRootLayer)
    ret:addChild(goodsIcon)
    local goodsNameLabel = self:createGoodsNameLabel(isRootLayer)
    ret:addChild(goodsNameLabel)
    local costNameLabel = self:createCostNameLabel(isRootLayer)
    ret:addChild(costNameLabel)
    local curCountLabel = self:createCurCountLabel(isRootLayer)
    ret:addChild(curCountLabel)
    if isRootLayer then
        self._infoBg = ret
    end
    return ret
end

function STMoonShopLayer:createGoodsIcon(isRootLayer)
    local ret = STLayout:create()
    ret:setName("goodsIcon")
    ret:setContentSize(CCSizeMake(90.0, 90.0))
    ret:setPosition(ccp(58.0, 53.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(94.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._goodsIcon = ret
    end
    return ret
end

function STMoonShopLayer:createGoodsNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("goodsNameLabel")
    ret:setPosition(ccp(115.0, 81.0995))
    ret:setAnchorPoint(ccp(0.0, 0.5032))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._goodsNameLabel = ret
    end
    return ret
end

function STMoonShopLayer:createCostNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("costNameLabel")
    ret:setPosition(ccp(115.0, 51.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._costNameLabel = ret
    end
    return ret
end

function STMoonShopLayer:createCurCountLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_1854"), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("curCountLabel")
    ret:setPosition(ccp(115.0, 22.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._curCountLabel = ret
    end
    return ret
end

function STMoonShopLayer:createBuyBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_violet_n.png", "images/common/btn/btn_violet_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("zz_116"), g_sFontPangWa, 30, ccc3(255.0, 228.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("buyBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(362.0, 90.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._buyBtn = ret
    end
    return ret
end

function STMoonShopLayer:createRestTimesLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10244"), g_sFontName, 23)
    ret:setName("restTimesLabel")
    ret:setPosition(ccp(354.0, 46.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._restTimesLabel = ret
    end
    return ret
end

function STMoonShopLayer:createExchangeBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("yr_1008"), g_sFontPangWa, 30, ccc3(255.0, 228.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("exchangeBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(354.0, 90.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._exchangeBtn = ret
    end
    return ret
end

function STMoonShopLayer:createImage_4(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/9s_purple.png", CCRectMake(15.0, 9.0, 157.0, 12.0))
    ret:setName("Image_4")
    ret:setContentSize(CCSizeMake(251.0, 45.0))
    ret:setPosition(ccp(219.0, 460.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local curGodCardLabel = self:createCurGodCardLabel(isRootLayer)
    ret:addChild(curGodCardLabel)
    if isRootLayer then
        self._Image_4 = ret
    end
    return ret
end

function STMoonShopLayer:createCurGodCardLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10245"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("curGodCardLabel")
    ret:setPosition(ccp(125.5, 22.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._curGodCardLabel = ret
    end
    return ret
end

function STMoonShopLayer:createRefreshBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", nil, true)
    ret:setCapInsets(CCRectMake(55.0, 11.0, 43.0, 46.0))
    ret:setLabel(GetLocalizeStringBy("zz_111"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("refreshBtn")
    ret:setContentSize(CCSizeMake(202.0, 73.0))
    ret:setPosition(ccp(485.824, 46.4955))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.7591)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.0695)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._refreshBtn = ret
    end
    return ret
end

function STMoonShopLayer:createTipLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10247"), g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("tipLabel")
    ret:setPosition(ccp(10.176, 63.6888))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0159)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.0952)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 228.0, 255.0))
    if isRootLayer then
        self._tipLabel = ret
    end
    return ret
end

function STMoonShopLayer:createFreeRefreshCountLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("freeRefreshCountLabel")
    ret:setPosition(ccp(10.176, 33.45))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0159)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.05)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._freeRefreshCountLabel = ret
    end
    return ret
end

function STMoonShopLayer:createTitleSprite(isRootLayer)
    local ret = STSprite:create("images/moon/shop_name.png")
    ret:setName("titleSprite")
    ret:setPosition(ccp(320.0, 669.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    if isRootLayer then
        self._titleSprite = ret
    end
    return ret
end

function STMoonShopLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
