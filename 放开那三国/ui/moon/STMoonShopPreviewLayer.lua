STMoonShopPreviewLayer = class("STMoonShopPreviewLayer", function()
    return STLayer:create()
end)


function STMoonShopPreviewLayer:create()
    local ret = STMoonShopPreviewLayer:new()
    local bgLayer = ret:createBgLayer(true)
    ret:addChild(bgLayer)
    ret._layer = ret
    return ret
end

function STMoonShopPreviewLayer:createBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setTag(146.0)
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(127.0)
    local bgSprite = self:createBgSprite(isRootLayer)
    ret:addChild(bgSprite)
    if isRootLayer then
        self._bgLayer = ret
    end
    return ret
end

function STMoonShopPreviewLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(590.0, 650.0))
    ret:setTag(147.0)
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_5_12 = self:createSprite_5_12(isRootLayer)
    ret:addChild(Sprite_5_12)
    local closeBtn = self:createCloseBtn(isRootLayer)
    ret:addChild(closeBtn)
    local Image_2_0_15 = self:createImage_2_0_15(isRootLayer)
    ret:addChild(Image_2_0_15)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STMoonShopPreviewLayer:createSprite_5_12(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_12")
    ret:setContentSize(CCSizeMake(315.0, 61.0))
    ret:setTag(148.0)
    ret:setPosition(ccp(294.056, 644.0003))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.4984)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title_12 = self:createTitle_12(isRootLayer)
    ret:addChild(title_12)
    if isRootLayer then
        self._Sprite_5_12 = ret
    end
    return ret
end

function STMoonShopPreviewLayer:createTitle_12(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("djn_83"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title_12")
    ret:setTag(149.0)
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

function STMoonShopPreviewLayer:createCloseBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("closeBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setTag(150.0)
    ret:setPosition(ccp(603.0, 674.0))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._closeBtn = ret
    end
    return ret
end

function STMoonShopPreviewLayer:createImage_2_0_15(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_15")
    ret:setContentSize(CCSizeMake(540.0, 500.0))
    ret:setTag(157.0)
    ret:setPosition(ccp(295.0, 319.4179))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local itemTableView = self:createItemTableView(isRootLayer)
    ret:addChild(itemTableView)
    if isRootLayer then
        self._Image_2_0_15 = ret
    end
    return ret
end

function STMoonShopPreviewLayer:createItemTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("itemTableView")
    ret:setContentSize(CCSizeMake(520.0, 480.0))
    ret:setInnerSize(CCSizeMake(520.0, 480.0))
    ret:setTag(158.0)
    ret:setPosition(ccp(270.0, 250.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 150.0, 255.0))
    ret:setBgOpacity(0.0)
    if isRootLayer then
        self._itemTableView = ret
    end
    return ret
end

function STMoonShopPreviewLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
