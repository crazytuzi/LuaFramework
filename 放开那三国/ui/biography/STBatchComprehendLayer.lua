STBatchComprehendLayer = class("STBatchComprehendLayer", function()
    return STLayer:create()
end)


function STBatchComprehendLayer:create()
    local ret = STBatchComprehendLayer:new()
    local bgLayer = ret:createBgLayer(true)
    ret:addChild(bgLayer)
    ret._layer = ret
    return ret
end

function STBatchComprehendLayer:createBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setTag(17.0)
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(127.0)
    local bgSprite = self:createBgSprite(isRootLayer)
    ret:addChild(bgSprite)
    if isRootLayer then
        self._bgLayer = ret
    end
    return ret
end

function STBatchComprehendLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(630.0, 754.0))
    ret:setTag(18.0)
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_5 = self:createSprite_5(isRootLayer)
    ret:addChild(Sprite_5)
    local Button_1 = self:createButton_1(isRootLayer)
    ret:addChild(Button_1)
    local replaceButton = self:createReplaceButton(isRootLayer)
    ret:addChild(replaceButton)
    local comprehendButton = self:createComprehendButton(isRootLayer)
    ret:addChild(comprehendButton)
    local Image_2 = self:createImage_2(isRootLayer)
    ret:addChild(Image_2)
    local Image_2_0 = self:createImage_2_0(isRootLayer)
    ret:addChild(Image_2_0)
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STBatchComprehendLayer:createSprite_5(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5")
    ret:setContentSize(CCSizeMake(315.0, 61.0))
    ret:setTag(19.0)
    ret:setPosition(ccp(315.0, 747.0003))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local title = self:createTitle(isRootLayer)
    ret:addChild(title)
    if isRootLayer then
        self._Sprite_5 = ret
    end
    return ret
end

function STBatchComprehendLayer:createTitle(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10207"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("title")
    ret:setTag(20.0)
    ret:setPosition(ccp(157.5, 30.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 228.0, 0.0))
    if isRootLayer then
        self._title = ret
    end
    return ret
end

function STBatchComprehendLayer:createButton_1(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("Button_1")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setTag(21.0)
    ret:setPosition(ccp(640.0, 769.0))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._Button_1 = ret
    end
    return ret
end

function STBatchComprehendLayer:createReplaceButton(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 150.0, 73.0))
    ret:setLabel(GetLocalizeStringBy("lic_1513"), g_sFontPangWa, 35, ccc3(254.0, 219.0, 28.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("replaceButton")
    ret:setContentSize(CCSizeMake(198.0, 73.0))
    ret:setTag(23.0)
    ret:setPosition(ccp(199.0, 79.5))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._replaceButton = ret
    end
    return ret
end

function STBatchComprehendLayer:createComprehendButton(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", nil, true)
    ret:setCapInsets(CCRectMake(70.0, 30.0, 10.0, 13.0))
    ret:setLabel(GetLocalizeStringBy("key_10207"), g_sFontPangWa, 35, ccc3(254.0, 219.0, 28.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("comprehendButton")
    ret:setContentSize(CCSizeMake(198.0, 73.0))
    ret:setTag(22.0)
    ret:setPosition(ccp(431.0, 79.5))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._comprehendButton = ret
    end
    return ret
end

function STBatchComprehendLayer:createImage_2(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2")
    ret:setContentSize(CCSizeMake(570.0, 170.0))
    ret:setTag(24.0)
    ret:setPosition(ccp(316.512, 609.5971))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5024)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local curAwakenNameLabel = self:createCurAwakenNameLabel(isRootLayer)
    ret:addChild(curAwakenNameLabel)
    local curAwakenLabel = self:createCurAwakenLabel(isRootLayer)
    ret:addChild(curAwakenLabel)
    local curAwakenDescLabel = self:createCurAwakenDescLabel(isRootLayer)
    ret:addChild(curAwakenDescLabel)
    if isRootLayer then
        self._Image_2 = ret
    end
    return ret
end

function STBatchComprehendLayer:createCurAwakenNameLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10209"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("curAwakenNameLabel")
    ret:setTag(31.0)
    ret:setPosition(ccp(21.2165, 105.9704))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(228.0, 0.0, 255.0))
    if isRootLayer then
        self._curAwakenNameLabel = ret
    end
    return ret
end

function STBatchComprehendLayer:createCurAwakenLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_8083"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("curAwakenLabel")
    ret:setTag(33.0)
    ret:setPosition(ccp(285.0, 144.7767))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 255.0, 24.0))
    if isRootLayer then
        self._curAwakenLabel = ret
    end
    return ret
end

function STBatchComprehendLayer:createCurAwakenDescLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10210"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("curAwakenDescLabel")
    ret:setTag(34.0)
    ret:setPosition(ccp(26.2687, 75.6791))
    ret:setAnchorPoint(ccp(0.0, 1.0))
    if isRootLayer then
        self._curAwakenDescLabel = ret
    end
    return ret
end

function STBatchComprehendLayer:createImage_2_0(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0")
    ret:setContentSize(CCSizeMake(570.0, 380.0))
    ret:setTag(28.0)
    ret:setPosition(ccp(319.032, 319.4179))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5064)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local ListView_1 = self:createListView_1(isRootLayer)
    ret:addChild(ListView_1)
    local Sprite_6 = self:createSprite_6(isRootLayer)
    ret:addChild(Sprite_6)
    if isRootLayer then
        self._Image_2_0 = ret
    end
    return ret
end

function STBatchComprehendLayer:createListView_1(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("ListView_1")
    ret:setContentSize(CCSizeMake(570.0, 300.0))
    ret:setInnerSize(CCSizeMake(570.0, 300.0))
    ret:setTag(26.0)
    ret:setPosition(ccp(285.0, 160.018))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.4211)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 150.0, 255.0))
    ret:setBgOpacity(0.0)
    local cell = self:createCell(isRootLayer)
    ret:addChild(cell)
    if isRootLayer then
        self._ListView_1 = ret
    end
    return ret
end

function STBatchComprehendLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(570.0, 170.0))
    ret:setTag(35.0)
    ret:setPosition(ccp(0.0, 130.0))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    local checkButton = self:createCheckButton(isRootLayer)
    ret:addChild(checkButton)
    local Image_5 = self:createImage_5(isRootLayer)
    ret:addChild(Image_5)
    local awakenNameLabel = self:createAwakenNameLabel(isRootLayer)
    ret:addChild(awakenNameLabel)
    local awakenDescLabel = self:createAwakenDescLabel(isRootLayer)
    ret:addChild(awakenDescLabel)
    if isRootLayer then
        self._cell = ret
    end
    return ret
end

function STBatchComprehendLayer:createCheckButton(isRootLayer)
    local ret = STButton:createWithImage("images/common/checkbg.png", nil, nil, true)
    ret:setCapInsets(CCRectMake(15.0, 15.0, 4.0, 2.0))
    ret:setName("checkButton")
    ret:setContentSize(CCSizeMake(40.0, 40.0))
    ret:setTag(39.0)
    ret:setPosition(ccp(525.6365, 85.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._checkButton = ret
    end
    return ret
end

function STBatchComprehendLayer:createImage_5(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/astro_btnbg.png", CCRectMake(15.0, 11.0, 45.0, 13.0))
    ret:setName("Image_5")
    ret:setContentSize(CCSizeMake(470.0, 150.0))
    ret:setTag(36.0)
    ret:setPosition(ccp(16.6476, 85.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._Image_5 = ret
    end
    return ret
end

function STBatchComprehendLayer:createAwakenNameLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10209"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("awakenNameLabel")
    ret:setTag(41.0)
    ret:setPosition(ccp(31.2165, 118.9703))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(228.0, 0.0, 255.0))
    if isRootLayer then
        self._awakenNameLabel = ret
    end
    return ret
end

function STBatchComprehendLayer:createAwakenDescLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10210"), g_sFontName, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("awakenDescLabel")
    ret:setTag(42.0)
    ret:setPosition(ccp(32.5187, 90.9999))
    ret:setAnchorPoint(ccp(0.0, 1.0))
    if isRootLayer then
        self._awakenDescLabel = ret
    end
    return ret
end

function STBatchComprehendLayer:createSprite_6(isRootLayer)
    local ret = STSprite:create("images/common/red_line.png")
    ret:setName("Sprite_6")
    ret:setContentSize(CCSizeMake(308.0, 45.0))
    ret:setTag(29.0)
    ret:setPosition(ccp(285.0, 344.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local comprehendTimes = self:createComprehendTimes(isRootLayer)
    ret:addChild(comprehendTimes)
    if isRootLayer then
        self._Sprite_6 = ret
    end
    return ret
end

function STBatchComprehendLayer:createComprehendTimes(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10211"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("comprehendTimes")
    ret:setTag(30.0)
    ret:setPosition(ccp(154.0, 22.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(0.0, 228.0, 255.0))
    if isRootLayer then
        self._comprehendTimes = ret
    end
    return ret
end

function STBatchComprehendLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
