STTravelShopLayer = class("STTravelShopLayer", function()
    return STLayer:create()
end)


function STTravelShopLayer:create()
    local ret = STTravelShopLayer:new()
    local centerLayer = ret:createCenterLayer(true)
    ret:addChild(centerLayer)
    ret._layer = ret
    return ret
end

function STTravelShopLayer:createCenterLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("centerLayer")
    ret:setContentSize(CCSizeMake(640.0, 669.0))
    ret:setPosition(ccp(320.0, 180.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local flowerSprite = self:createFlowerSprite(isRootLayer)
    ret:addChild(flowerSprite)
    local titleSprite = self:createTitleSprite(isRootLayer)
    ret:addChild(titleSprite)
    local descBtn = self:createDescBtn(isRootLayer)
    ret:addChild(descBtn)
    local contentBgSprite = self:createContentBgSprite(isRootLayer)
    ret:addChild(contentBgSprite)
    if isRootLayer then
        self._centerLayer = ret
    end
    return ret
end

function STTravelShopLayer:createFlowerSprite(isRootLayer)
    local ret = STSprite:create("images/recharge/travel_shop/flower.png")
    ret:setName("flowerSprite")
    ret:setPosition(ccp(320.0, 669.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    if isRootLayer then
        self._flowerSprite = ret
    end
    return ret
end

function STTravelShopLayer:createTitleSprite(isRootLayer)
    local ret = STSprite:create("images/recharge/travel_shop/title.png")
    ret:setName("titleSprite")
    ret:setPosition(ccp(320.0, 662.31))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.99)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._titleSprite = ret
    end
    return ret
end

function STTravelShopLayer:createDescBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/card_active/btn_desc/btn_desc_n.png", "images/recharge/card_active/btn_desc/btn_desc_h.png", nil, false)
    ret:setName("descBtn")
    ret:setPosition(ccp(598.0231, 633.2994))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.9344)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.9466)
    ret:setScaleX(0.7)
    ret:setScaleY(0.7)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._descBtn = ret
    end
    return ret
end

function STTravelShopLayer:createContentBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/9s_1.png", CCRectMake(16.0, 16.0, 67.0, 65.0))
    ret:setName("contentBgSprite")
    ret:setContentSize(CCSizeMake(630.0, 533.0))
    ret:setPosition(ccp(320.0, 13.1124))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.0196)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local girlSprite = self:createGirlSprite(isRootLayer)
    ret:addChild(girlSprite)
    local zkdjSelectBtn = self:createZkdjSelectBtn(isRootLayer)
    ret:addChild(zkdjSelectBtn)
    local czyhSelectBtn = self:createCzyhSelectBtn(isRootLayer)
    ret:addChild(czyhSelectBtn)
    local pttqSelectBtn = self:createPttqSelectBtn(isRootLayer)
    ret:addChild(pttqSelectBtn)
    if isRootLayer then
        self._contentBgSprite = ret
    end
    return ret
end

function STTravelShopLayer:createGirlSprite(isRootLayer)
    local ret = STSprite:create("images/recharge/travel_shop/girl.png")
    ret:setName("girlSprite")
    ret:setPosition(ccp(315.0, 266.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._girlSprite = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("zkdjLayer")
    ret:setContentSize(CCSizeMake(630.0, 533.0))
    local yhczBtn = self:createYhczBtn(isRootLayer)
    ret:addChild(yhczBtn)
    local zkdjReceiveBtn = self:createZkdjReceiveBtn(isRootLayer)
    ret:addChild(zkdjReceiveBtn)
    local Text_10 = self:createText_10(isRootLayer)
    ret:addChild(Text_10)
    local zkdjProgressBgSprite = self:createZkdjProgressBgSprite(isRootLayer)
    ret:addChild(zkdjProgressBgSprite)
    local Text_11_0 = self:createText_11_0(isRootLayer)
    ret:addChild(Text_11_0)
    local goodsTableView = self:createGoodsTableView(isRootLayer)
    ret:addChild(goodsTableView)
    local Text_1 = self:createText_1(isRootLayer)
    ret:addChild(Text_1)
    local timeTipLabel = self:createTimeTipLabel(isRootLayer)
    ret:addChild(timeTipLabel)
    if isRootLayer then
        self._zkdjLayer = ret
    end
    return ret
end

function STTravelShopLayer:createYhczBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/travel_shop/czyh_n.png", "images/recharge/travel_shop/czyh_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 166.0, 50.0))
    ret:setName("yhczBtn")
    ret:setContentSize(CCSizeMake(196.0, 72.0))
    ret:setPosition(ccp(492.975, 484.0173))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.7825)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.9081)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._yhczBtn = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjReceiveBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(54.0, 11.0, 36.0, 51.0))
    ret:setLabel(GetLocalizeStringBy("lcyx_1945"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("zkdjReceiveBtn")
    ret:setContentSize(CCSizeMake(187.0, 73.0))
    ret:setPosition(ccp(492.975, 484.0173))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.7825)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.9081)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._zkdjReceiveBtn = ret
    end
    return ret
end

function STTravelShopLayer:createText_10(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10295"), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_10")
    ret:setPosition(ccp(14.994, 469.9994))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0238)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8818)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._Text_10 = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjProgressBgSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_barbg.png")
    ret:setName("zkdjProgressBgSprite")
    ret:setPosition(ccp(358.029, 425.0142))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5683)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7974)
    ret:setScaleX(0.8)
    ret:setScaleY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local zkdjProgressScrollView = self:createZkdjProgressScrollView(isRootLayer)
    ret:addChild(zkdjProgressScrollView)
    local zkdjProgressLabel = self:createZkdjProgressLabel(isRootLayer)
    ret:addChild(zkdjProgressLabel)
    if isRootLayer then
        self._zkdjProgressBgSprite = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjProgressScrollView(isRootLayer)
    local ret = STScrollView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setBounceable(false)
    ret:setName("zkdjProgressScrollView")
    ret:setContentSize(CCSizeMake(477.0, 25.0))
    ret:setInnerSize(CCSizeMake(477, 25))
    ret:setPosition(ccp(25.0, 35.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local zkdjProgressSprite = self:createZkdjProgressSprite(isRootLayer)
    ret:addChild(zkdjProgressSprite)
    if isRootLayer then
        self._zkdjProgressScrollView = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjProgressSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_bar.png")
    ret:setName("zkdjProgressSprite")
    if isRootLayer then
        self._zkdjProgressSprite = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjProgressLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("zkdjProgressLabel")
    ret:setPosition(ccp(265.0, 34.56))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.48)
    ret:setScaleX(1.25)
    ret:setScaleY(1.25)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._zkdjProgressLabel = ret
    end
    return ret
end

function STTravelShopLayer:createText_11_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10296"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_11_0")
    ret:setPosition(ccp(81.018, 422.9888))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.1286)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7936)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_11_0 = ret
    end
    return ret
end

function STTravelShopLayer:createGoodsTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("goodsTableView")
    ret:setContentSize(CCSizeMake(581.0, 352.0))
    ret:setInnerSize(CCSizeMake(581.0, 352.0))
    ret:setPosition(ccp(315.0, 213.9995))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.4015)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setTouchEnabled(true)
    local goodsCell = self:createGoodsCell(isRootLayer)
    ret:addChild(goodsCell)
    if isRootLayer then
        self._goodsTableView = ret
    end
    return ret
end

function STTravelShopLayer:createGoodsCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("goodsCell")
    ret:setContentSize(CCSizeMake(581.0, 297.0))
    ret:setPosition(ccp(0.0, 55.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._goodsCell = ret
    end
    return ret
end

function STTravelShopLayer:createGoodsSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/s9_3.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("goodsSprite")
    ret:setContentSize(CCSizeMake(163.0, 281.0))
    ret:setPosition(ccp(0.0, 148.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local goodsIcon = self:createGoodsIcon(isRootLayer)
    ret:addChild(goodsIcon)
    local newPriceLabel = self:createNewPriceLabel(isRootLayer)
    ret:addChild(newPriceLabel)
    local buyGoodsBtn = self:createBuyGoodsBtn(isRootLayer)
    ret:addChild(buyGoodsBtn)
    local oldPriceLabel = self:createOldPriceLabel(isRootLayer)
    ret:addChild(oldPriceLabel)
    local remainBuyCountLabel = self:createRemainBuyCountLabel(isRootLayer)
    ret:addChild(remainBuyCountLabel)
    if isRootLayer then
        self._goodsSprite = ret
    end
    return ret
end

function STTravelShopLayer:createGoodsIcon(isRootLayer)
    local ret = STLayout:create()
    ret:setName("goodsIcon")
    ret:setContentSize(CCSizeMake(90.0, 90.0))
    ret:setPosition(ccp(81.5, 220.49))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(94.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._goodsIcon = ret
    end
    return ret
end

function STTravelShopLayer:createNewPriceLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("newPriceLabel")
    ret:setPosition(ccp(25.0, 106.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._newPriceLabel = ret
    end
    return ret
end

function STTravelShopLayer:createBuyGoodsBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("zz_116"), g_sFontName, 25, ccc3(255.0, 255.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("buyGoodsBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(81.5, 65.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._buyGoodsBtn = ret
    end
    return ret
end

function STTravelShopLayer:createOldPriceLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("oldPriceLabel")
    ret:setPosition(ccp(25.0, 135.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._oldPriceLabel = ret
    end
    return ret
end

function STTravelShopLayer:createRemainBuyCountLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18)
    ret:setName("remainBuyCountLabel")
    ret:setPosition(ccp(25.0, 24.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 0.0, 0.0))
    if isRootLayer then
        self._remainBuyCountLabel = ret
    end
    return ret
end

function STTravelShopLayer:createText_1(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10297"), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_1")
    ret:setPosition(ccp(14.994, 498.6748))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0238)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.9356)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._Text_1 = ret
    end
    return ret
end

function STTravelShopLayer:createTimeTipLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("timeTipLabel")
    ret:setPosition(ccp(315.0, 21.32))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.04)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._timeTipLabel = ret
    end
    return ret
end

function STTravelShopLayer:createCzyhFinishLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("czyhFinishLayer")
    ret:setContentSize(CCSizeMake(630.0, 533.0))
    ret:setPosition(ccp(0.0, 1.0))
    local Text_10_0 = self:createText_10_0(isRootLayer)
    ret:addChild(Text_10_0)
    local czyhBtn = self:createCzyhBtn(isRootLayer)
    ret:addChild(czyhBtn)
    local tipBg = self:createTipBg(isRootLayer)
    ret:addChild(tipBg)
    local Text_11_0_0 = self:createText_11_0_0(isRootLayer)
    ret:addChild(Text_11_0_0)
    local czyh1ProgressBgSprite = self:createCzyh1ProgressBgSprite(isRootLayer)
    ret:addChild(czyh1ProgressBgSprite)
    local remainTimeTipLabel = self:createRemainTimeTipLabel(isRootLayer)
    ret:addChild(remainTimeTipLabel)
    local czyhReceiveBtn = self:createCzyhReceiveBtn(isRootLayer)
    ret:addChild(czyhReceiveBtn)
    if isRootLayer then
        self._czyhFinishLayer = ret
    end
    return ret
end

function STTravelShopLayer:createText_10_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10295"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_10_0")
    ret:setPosition(ccp(315.0, 410.9963))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7711)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_10_0 = ret
    end
    return ret
end

function STTravelShopLayer:createCzyhBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/travel_shop/czyh_n.png", "images/recharge/travel_shop/czyh_h.png", nil, true)
    ret:setCapInsets(CCRectMake(54.0, 11.0, 82.0, 50.0))
    ret:setName("czyhBtn")
    ret:setContentSize(CCSizeMake(196.0, 72.0))
    ret:setPosition(ccp(315.0, 78.9906))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.1482)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._czyhBtn = ret
    end
    return ret
end

function STTravelShopLayer:createTipBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("tipBg")
    ret:setContentSize(CCSizeMake(480.0, 147.0))
    ret:setPosition(ccp(315.0, 202.007))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.379)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local payProgressLabel = self:createPayProgressLabel(isRootLayer)
    ret:addChild(payProgressLabel)
    local payTipLabel = self:createPayTipLabel(isRootLayer)
    ret:addChild(payTipLabel)
    local congratulationsLabel = self:createCongratulationsLabel(isRootLayer)
    ret:addChild(congratulationsLabel)
    if isRootLayer then
        self._tipBg = ret
    end
    return ret
end

function STTravelShopLayer:createPayProgressLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("payProgressLabel")
    ret:setPosition(ccp(240.0, 44.1))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.3)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._payProgressLabel = ret
    end
    return ret
end

function STTravelShopLayer:createPayTipLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("payTipLabel")
    ret:setPosition(ccp(240.0, 73.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._payTipLabel = ret
    end
    return ret
end

function STTravelShopLayer:createCongratulationsLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10298"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("congratulationsLabel")
    ret:setPosition(ccp(240.0, 102.9))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._congratulationsLabel = ret
    end
    return ret
end

function STTravelShopLayer:createText_11_0_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10296"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_11_0_0")
    ret:setPosition(ccp(91.0, 475.0096))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8912)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_11_0_0 = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh1ProgressBgSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_barbg.png")
    ret:setName("czyh1ProgressBgSprite")
    ret:setPosition(ccp(368.0, 479.0071))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8987)
    ret:setScaleX(0.8)
    ret:setScaleY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local czyh1ProgressScrollView = self:createCzyh1ProgressScrollView(isRootLayer)
    ret:addChild(czyh1ProgressScrollView)
    local czyh1ProgressLabel = self:createCzyh1ProgressLabel(isRootLayer)
    ret:addChild(czyh1ProgressLabel)
    if isRootLayer then
        self._czyh1ProgressBgSprite = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh1ProgressScrollView(isRootLayer)
    local ret = STScrollView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setBounceable(false)
    ret:setName("czyh1ProgressScrollView")
    ret:setContentSize(CCSizeMake(477.0, 25.0))
    ret:setInnerSize(CCSizeMake(477, 25))
    ret:setPosition(ccp(25.0, 35.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local czyh1ProgressSprite = self:createCzyh1ProgressSprite(isRootLayer)
    ret:addChild(czyh1ProgressSprite)
    if isRootLayer then
        self._czyh1ProgressScrollView = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh1ProgressSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_bar.png")
    ret:setName("czyh1ProgressSprite")
    if isRootLayer then
        self._czyh1ProgressSprite = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh1ProgressLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("czyh1ProgressLabel")
    ret:setPosition(ccp(265.0, 33.84))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.47)
    ret:setScaleX(1.25)
    ret:setScaleY(1.25)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._czyh1ProgressLabel = ret
    end
    return ret
end

function STTravelShopLayer:createRemainTimeTipLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18)
    ret:setName("remainTimeTipLabel")
    ret:setPosition(ccp(315.0, 22.0129))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.0413)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(231.0, 166.0, 137.0))
    if isRootLayer then
        self._remainTimeTipLabel = ret
    end
    return ret
end

function STTravelShopLayer:createCzyhReceiveBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(54.0, 11.0, 36.0, 51.0))
    ret:setLabel(GetLocalizeStringBy("lcyx_1945"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("czyhReceiveBtn")
    ret:setContentSize(CCSizeMake(187.0, 73.0))
    ret:setPosition(ccp(315.0, 78.9906))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.1482)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._czyhReceiveBtn = ret
    end
    return ret
end

function STTravelShopLayer:createPttqLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("pttqLayer")
    ret:setContentSize(CCSizeMake(630.0, 533.0))
    local Sprite_3 = self:createSprite_3(isRootLayer)
    ret:addChild(Sprite_3)
    local pttqLine1Label = self:createPttqLine1Label(isRootLayer)
    ret:addChild(pttqLine1Label)
    local pttqLine2Label = self:createPttqLine2Label(isRootLayer)
    ret:addChild(pttqLine2Label)
    local rewardTableView = self:createRewardTableView(isRootLayer)
    ret:addChild(rewardTableView)
    local buyCountBg = self:createBuyCountBg(isRootLayer)
    ret:addChild(buyCountBg)
    if isRootLayer then
        self._pttqLayer = ret
    end
    return ret
end

function STTravelShopLayer:createSprite_3(isRootLayer)
    local ret = STSprite:create("images/guild_boss_copy/bottom_bg.png")
    ret:setName("Sprite_3")
    ret:setPosition(ccp(315.0, 533.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setScaleX(3.94)
    ret:setScaleY(-2.51)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._Sprite_3 = ret
    end
    return ret
end

function STTravelShopLayer:createPttqLine1Label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10299"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("pttqLine1Label")
    ret:setPosition(ccp(280.0, 483.4843))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.9071)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._pttqLine1Label = ret
    end
    return ret
end

function STTravelShopLayer:createPttqLine2Label(isRootLayer)
    local ret = STLabel:create("Text  Label", g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("pttqLine2Label")
    ret:setPosition(ccp(280.0, 442.4966))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8302)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._pttqLine2Label = ret
    end
    return ret
end

function STTravelShopLayer:createRewardTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("rewardTableView")
    ret:setContentSize(CCSizeMake(575.0, 374.0))
    ret:setInnerSize(CCSizeMake(575.0, 374.0))
    ret:setPosition(ccp(315.0, 196.9968))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.3696)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setTouchEnabled(true)
    local pttqCell = self:createPttqCell(isRootLayer)
    ret:addChild(pttqCell)
    if isRootLayer then
        self._rewardTableView = ret
    end
    return ret
end

function STTravelShopLayer:createPttqCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("pttqCell")
    ret:setContentSize(CCSizeMake(575.0, 158.0))
    ret:setPosition(ccp(0.0, 216.0))
    ret:setTouchEnabled(true)
    local pttqCellBg = self:createPttqCellBg(isRootLayer)
    ret:addChild(pttqCellBg)
    if isRootLayer then
        self._pttqCell = ret
    end
    return ret
end

function STTravelShopLayer:createPttqCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/change_bg.png", CCRectMake(44.0, 48.0, 21.0, 28.0))
    ret:setName("pttqCellBg")
    ret:setContentSize(CCSizeMake(575.0, 153.0))
    ret:setPosition(ccp(0.0, 79.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local itemIcon = self:createItemIcon(isRootLayer)
    ret:addChild(itemIcon)
    local receiveTipLabel = self:createReceiveTipLabel(isRootLayer)
    ret:addChild(receiveTipLabel)
    local receiveBtn = self:createReceiveBtn(isRootLayer)
    ret:addChild(receiveBtn)
    if isRootLayer then
        self._pttqCellBg = ret
    end
    return ret
end

function STTravelShopLayer:createItemIcon(isRootLayer)
    local ret = STLayout:create()
    ret:setName("itemIcon")
    ret:setContentSize(CCSizeMake(90.0, 90.0))
    ret:setPosition(ccp(97.0, 88.5))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(94.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._itemIcon = ret
    end
    return ret
end

function STTravelShopLayer:createReceiveTipLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 20)
    ret:setName("receiveTipLabel")
    ret:setPosition(ccp(180.0, 76.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5032))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._receiveTipLabel = ret
    end
    return ret
end

function STTravelShopLayer:createReceiveBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", "images/common/btn/btn_blue_hui.png", true)
    ret:setCapInsets(CCRectMake(15.0, 21.0, 89.0, 27.0))
    ret:setLabel(GetLocalizeStringBy("lcyx_1945"), g_sFontPangWa, 25, ccc3(255.0, 255.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("receiveBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(487.0, 76.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._receiveBtn = ret
    end
    return ret
end

function STTravelShopLayer:createBuyCountBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_9s_8.png", CCRectMake(22.0, 15.0, 12.0, 25.0))
    ret:setName("buyCountBg")
    ret:setContentSize(CCSizeMake(228.0, 79.0))
    ret:setPosition(ccp(136.0, 445.0017))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8349)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Image_3 = self:createImage_3(isRootLayer)
    ret:addChild(Image_3)
    if isRootLayer then
        self._buyCountBg = ret
    end
    return ret
end

function STTravelShopLayer:createImage_3(isRootLayer)
    local ret = STScale9Sprite:create("images/recharge/travel_shop/bg_1.png", CCRectMake(37.0, 13.0, 41.0, 15.0))
    ret:setName("Image_3")
    ret:setContentSize(CCSizeMake(214.0, 41.0))
    ret:setPosition(ccp(114.0, 83.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_4 = self:createText_4(isRootLayer)
    ret:addChild(Text_4)
    if isRootLayer then
        self._Image_3 = ret
    end
    return ret
end

function STTravelShopLayer:createText_4(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10300"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_4")
    ret:setPosition(ccp(107.0, 24.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_4 = ret
    end
    return ret
end

function STTravelShopLayer:createCzyhUnfinishedLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("czyhUnfinishedLayer")
    ret:setContentSize(CCSizeMake(630.0, 533.0))
    ret:setPosition(ccp(10.0, -10.0))
    local Text_10_0 = self:createText_10_0(isRootLayer)
    ret:addChild(Text_10_0)
    local goBuyBtn = self:createGoBuyBtn(isRootLayer)
    ret:addChild(goBuyBtn)
    local Text_5 = self:createText_5(isRootLayer)
    ret:addChild(Text_5)
    local Text_6 = self:createText_6(isRootLayer)
    ret:addChild(Text_6)
    local Image_2 = self:createImage_2(isRootLayer)
    ret:addChild(Image_2)
    local Text_11_0_0 = self:createText_11_0_0(isRootLayer)
    ret:addChild(Text_11_0_0)
    local czyh2ProgressBgSprite = self:createCzyh2ProgressBgSprite(isRootLayer)
    ret:addChild(czyh2ProgressBgSprite)
    if isRootLayer then
        self._czyhUnfinishedLayer = ret
    end
    return ret
end

function STTravelShopLayer:createText_10_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10295"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_10_0")
    ret:setPosition(ccp(315.0, 410.9963))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7711)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_10_0 = ret
    end
    return ret
end

function STTravelShopLayer:createGoBuyBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(54.0, 11.0, 36.0, 51.0))
    ret:setLabel(GetLocalizeStringBy("key_10301"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("goBuyBtn")
    ret:setContentSize(CCSizeMake(187.0, 73.0))
    ret:setPosition(ccp(315.0, 65.9854))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.1238)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._goBuyBtn = ret
    end
    return ret
end

function STTravelShopLayer:createText_5(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10302"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_5")
    ret:setPosition(ccp(315.0, 333.0184))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.6248)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_5 = ret
    end
    return ret
end

function STTravelShopLayer:createText_6(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10303"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_6")
    ret:setPosition(ccp(315.0, 296.9876))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5572)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_6 = ret
    end
    return ret
end

function STTravelShopLayer:createImage_2(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("Image_2")
    ret:setContentSize(CCSizeMake(480.0, 147.0))
    ret:setPosition(ccp(315.0, 190.0145))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.3565)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_3 = self:createText_3(isRootLayer)
    ret:addChild(Text_3)
    local Text_3_0 = self:createText_3_0(isRootLayer)
    ret:addChild(Text_3_0)
    if isRootLayer then
        self._Image_2 = ret
    end
    return ret
end

function STTravelShopLayer:createText_3(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10304"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_3")
    ret:setPosition(ccp(240.0, 47.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_3 = ret
    end
    return ret
end

function STTravelShopLayer:createText_3_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10305"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_3_0")
    ret:setPosition(ccp(240.0, 96.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_3_0 = ret
    end
    return ret
end

function STTravelShopLayer:createText_11_0_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10296"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_11_0_0")
    ret:setPosition(ccp(91.0, 475.0096))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8912)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_11_0_0 = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh2ProgressBgSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_barbg.png")
    ret:setName("czyh2ProgressBgSprite")
    ret:setPosition(ccp(368.0, 479.0071))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8987)
    ret:setScaleX(0.8)
    ret:setScaleY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local czyh2ProgressScrollView = self:createCzyh2ProgressScrollView(isRootLayer)
    ret:addChild(czyh2ProgressScrollView)
    local czyh2ProgressLabel = self:createCzyh2ProgressLabel(isRootLayer)
    ret:addChild(czyh2ProgressLabel)
    if isRootLayer then
        self._czyh2ProgressBgSprite = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh2ProgressScrollView(isRootLayer)
    local ret = STScrollView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setBounceable(false)
    ret:setName("czyh2ProgressScrollView")
    ret:setContentSize(CCSizeMake(477.0, 25.0))
    ret:setInnerSize(CCSizeMake(477, 25))
    ret:setPosition(ccp(25.0, 35.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local czyh2ProgressSprite = self:createCzyh2ProgressSprite(isRootLayer)
    ret:addChild(czyh2ProgressSprite)
    if isRootLayer then
        self._czyh2ProgressScrollView = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh2ProgressSprite(isRootLayer)
    local ret = STSprite:create("images/astrology/astro_bar.png")
    ret:setName("czyh2ProgressSprite")
    if isRootLayer then
        self._czyh2ProgressSprite = ret
    end
    return ret
end

function STTravelShopLayer:createCzyh2ProgressLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("czyh2ProgressLabel")
    ret:setPosition(ccp(265.0, 33.84))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.47)
    ret:setScaleX(1.25)
    ret:setScaleY(1.25)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._czyh2ProgressLabel = ret
    end
    return ret
end

function STTravelShopLayer:createZkdjSelectBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/travel_shop/tab_n.png", "images/recharge/travel_shop/tab_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 166.0, 31.0))
    ret:setLabel(GetLocalizeStringBy("key_10306"), g_sFontPangWa, 24, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("zkdjSelectBtn")
    ret:setContentSize(CCSizeMake(196.0, 53.0))
    ret:setPosition(ccp(119.7, 533.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.19)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._zkdjSelectBtn = ret
    end
    return ret
end

function STTravelShopLayer:createCzyhSelectBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/travel_shop/tab_n.png", "images/recharge/travel_shop/tab_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 166.0, 31.0))
    ret:setLabel(GetLocalizeStringBy("key_10307"), g_sFontPangWa, 24, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("czyhSelectBtn")
    ret:setContentSize(CCSizeMake(196.0, 53.0))
    ret:setPosition(ccp(315.0, 533.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._czyhSelectBtn = ret
    end
    return ret
end

function STTravelShopLayer:createPttqSelectBtn(isRootLayer)
    local ret = STButton:createWithImage("images/recharge/travel_shop/tab_n.png", "images/recharge/travel_shop/tab_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 166.0, 31.0))
    ret:setLabel(GetLocalizeStringBy("key_10308"), g_sFontPangWa, 24, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("pttqSelectBtn")
    ret:setContentSize(CCSizeMake(196.0, 53.0))
    ret:setPosition(ccp(510.3, 533.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.81)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._pttqSelectBtn = ret
    end
    return ret
end

function STTravelShopLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
