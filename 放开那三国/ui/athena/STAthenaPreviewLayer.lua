STAthenaPreviewLayer = class("STAthenaPreviewLayer", function()
    return STLayer:create()
end)


function STAthenaPreviewLayer:create()
    local ret = STAthenaPreviewLayer:new()
    local bgLayer = ret:createBgLayer(true)
    ret:addChild(bgLayer)
    ret._layer = ret
    return ret
end

function STAthenaPreviewLayer:createBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(204.0)
    ret:setTouchEnabled(true)
    local bgSprite = self:createBgSprite(isRootLayer)
    ret:addChild(bgSprite)
    if isRootLayer then
        self._bgLayer = ret
    end
    return ret
end

function STAthenaPreviewLayer:createBgSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/viewbg1.png", CCRectMake(100.0, 80.0, 13.0, 11.0))
    ret:setName("bgSprite")
    ret:setContentSize(CCSizeMake(620.0, 650.0))
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

function STAthenaPreviewLayer:createSprite_5_12_12(isRootLayer)
    local ret = STSprite:create("images/formation/changeformation/titlebg.png")
    ret:setName("Sprite_5_12_12")
    ret:setPosition(ccp(309.008, 644.0003))
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

function STAthenaPreviewLayer:createTitle_12_10(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10248"), g_sFontPangWa, 33, 1, ccc3(0, 0, 0), type_shadow)
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

function STAthenaPreviewLayer:createBackBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", nil, true)
    ret:setCapInsets(CCRectMake(0.0, 0.0, 77.0, 77.0))
    ret:setName("backBtn")
    ret:setContentSize(CCSizeMake(77.0, 77.0))
    ret:setPosition(ccp(627.0, 674.0))
    ret:setAnchorPoint(ccp(1.0, 1.0))
    if isRootLayer then
        self._backBtn = ret
    end
    return ret
end

function STAthenaPreviewLayer:createImage_2_0_15_11(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(30.0, 30.0, 15.0, 15.0))
    ret:setName("Image_2_0_15_11")
    ret:setContentSize(CCSizeMake(569.0, 545.0))
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

function STAthenaPreviewLayer:createTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("tableView")
    ret:setContentSize(CCSizeMake(566.0, 526.0))
    ret:setInnerSize(CCSizeMake(566.0, 526.0))
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

function STAthenaPreviewLayer:createCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("cell")
    ret:setContentSize(CCSizeMake(566.0, 190.0))
    ret:setPosition(ccp(0.0, 336.0))
    ret:setTouchEnabled(true)
    local cellBg = self:createCellBg(isRootLayer)
    ret:addChild(cellBg)
    if isRootLayer then
        self._cell = ret
    end
    return ret
end

function STAthenaPreviewLayer:createCellBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/change_bg.png", CCRectMake(49.0, 40.0, 22.0, 44.0))
    ret:setName("cellBg")
    ret:setContentSize(CCSizeMake(566.0, 143.0))
    ret:setPosition(ccp(283.0, 78.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local icon = self:createIcon(isRootLayer)
    ret:addChild(icon)
    local Sprite_4 = self:createSprite_4(isRootLayer)
    ret:addChild(Sprite_4)
    local descLabel = self:createDescLabel(isRootLayer)
    ret:addChild(descLabel)
    local nameLabel = self:createNameLabel(isRootLayer)
    ret:addChild(nameLabel)
    local normalSprite = self:createNormalSprite(isRootLayer)
    ret:addChild(normalSprite)
    local angerSprite = self:createAngerSprite(isRootLayer)
    ret:addChild(angerSprite)
    local Image_6 = self:createImage_6(isRootLayer)
    ret:addChild(Image_6)
    local floorNameLabel = self:createFloorNameLabel(isRootLayer)
    ret:addChild(floorNameLabel)
    local awakeSprite = self:createAwakeSprite(isRootLayer)
    ret:addChild(awakeSprite)
    if isRootLayer then
        self._cellBg = ret
    end
    return ret
end

function STAthenaPreviewLayer:createIcon(isRootLayer)
    local ret = STLayout:create()
    ret:setName("icon")
    ret:setContentSize(CCSizeMake(93.0, 93.0))
    ret:setPosition(ccp(101.5, 71.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(102.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._icon = ret
    end
    return ret
end

function STAthenaPreviewLayer:createSprite_4(isRootLayer)
    local ret = STSprite:create("images/common/line01.png")
    ret:setName("Sprite_4")
    ret:setPosition(ccp(352.0, 94.0))
    ret:setScaleX(3.0)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_4 = ret
    end
    return ret
end

function STAthenaPreviewLayer:createDescLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 18)
    ret:setName("descLabel")
    ret:setPosition(ccp(231.5, 80.0))
    ret:setAnchorPoint(ccp(0.0, 1.0))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._descLabel = ret
    end
    return ret
end

function STAthenaPreviewLayer:createNameLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10249"), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("nameLabel")
    ret:setPosition(ccp(230.0, 114.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(228.0, 0.0, 255.0))
    if isRootLayer then
        self._nameLabel = ret
    end
    return ret
end

function STAthenaPreviewLayer:createNormalSprite(isRootLayer)
    local ret = STSprite:create("images/hero/info/normal.png")
    ret:setName("normalSprite")
    ret:setPosition(ccp(201.0, 65.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_12 = self:createText_12(isRootLayer)
    ret:addChild(Text_12)
    if isRootLayer then
        self._normalSprite = ret
    end
    return ret
end

function STAthenaPreviewLayer:createText_12(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("zz_78"), g_sFontName, 20)
    ret:setName("Text_12")
    ret:setPosition(ccp(18.5, 17.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_12 = ret
    end
    return ret
end

function STAthenaPreviewLayer:createAngerSprite(isRootLayer)
    local ret = STSprite:create("images/hero/info/anger.png")
    ret:setName("angerSprite")
    ret:setPosition(ccp(201.0, 65.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_12_2_0 = self:createText_12_2_0(isRootLayer)
    ret:addChild(Text_12_2_0)
    if isRootLayer then
        self._angerSprite = ret
    end
    return ret
end

function STAthenaPreviewLayer:createText_12_2_0(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("zz_54"), g_sFontName, 20)
    ret:setName("Text_12_2_0")
    ret:setPosition(ccp(18.5, 17.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_12_2_0 = ret
    end
    return ret
end

function STAthenaPreviewLayer:createImage_6(isRootLayer)
    local ret = STScale9Sprite:create("images/common/b_name_bg.png", CCRectMake(8.0, 15.0, 2.0, 16.0))
    ret:setName("Image_6")
    ret:setContentSize(CCSizeMake(230.0, 46.0))
    ret:setPosition(ccp(4.0, 148.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._Image_6 = ret
    end
    return ret
end

function STAthenaPreviewLayer:createFloorNameLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10250"), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("floorNameLabel")
    ret:setPosition(ccp(20.376, 152.3665))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.036)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0655)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._floorNameLabel = ret
    end
    return ret
end

function STAthenaPreviewLayer:createAwakeSprite(isRootLayer)
    local ret = STSprite:create("images/hero/info/awake.png")
    ret:setName("awakeSprite")
    ret:setPosition(ccp(201.0, 65.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_12_2 = self:createText_12_2(isRootLayer)
    ret:addChild(Text_12_2)
    if isRootLayer then
        self._awakeSprite = ret
    end
    return ret
end

function STAthenaPreviewLayer:createText_12_2(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("fqq_053"), g_sFontName, 20)
    ret:setName("Text_12_2")
    ret:setPosition(ccp(18.5, 17.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_12_2 = ret
    end
    return ret
end

function STAthenaPreviewLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
