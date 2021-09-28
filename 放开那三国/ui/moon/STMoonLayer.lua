STMoonLayer = class("STMoonLayer", function()
    return STLayer:create()
end)


function STMoonLayer:create()
    local ret = STMoonLayer:new()
    local copyBg = ret:createCopyBg(true)
    ret:addChild(copyBg)
    local copyLand = ret:createCopyLand(true)
    ret:addChild(copyLand)
    local bossBgLayer = ret:createBossBgLayer(true)
    ret:addChild(bossBgLayer)
    local bossLayer = ret:createBossLayer(true)
    ret:addChild(bossLayer)
    local topSprite = ret:createTopSprite(true)
    ret:addChild(topSprite)
    local bottom = ret:createBottom(true)
    ret:addChild(bottom)
    ret._layer = ret
    return ret
end

function STMoonLayer:createCopyBg(isRootLayer)
    local ret = STSprite:create("Default/Sprite.png")
    ret:setName("copyBg")
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._copyBg = ret
    end
    return ret
end

function STMoonLayer:createCopyLand(isRootLayer)
    local ret = STSprite:create("images/moon/land/land1/land.png")
    ret:setName("copyLand")
    ret:setPosition(ccp(320.0, 422.4))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.44)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._copyLand = ret
    end
    return ret
end

function STMoonLayer:createLand1(isRootLayer)
    local ret = STSprite:create("images/moon/land/land1/land_7.png")
    ret:setName("land1")
    ret:setPosition(ccp(136.0, 475.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._land1 = ret
    end
    return ret
end

function STMoonLayer:createButton1(isRootLayer)
    local ret = STButton:createWithImage("images/moon/head_bg.png", nil, nil, false)
    ret:setName("button1")
    ret:setPosition(ccp(139.0, 487.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name1 = self:createName1(isRootLayer)
    ret:addChild(name1)
    if isRootLayer then
        self._button1 = ret
    end
    return ret
end

function STMoonLayer:createName1(isRootLayer)
    local ret = STLabel:create("name", g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name1")
    ret:setPosition(ccp(35.5, -10.65))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(-0.15)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._name1 = ret
    end
    return ret
end

function STMoonLayer:createBossBgLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bossBgLayer")
    ret:setContentSize(CCSizeMake(640.0, 960.0))
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(0.0, 0.0, 0.0))
    ret:setBgOpacity(153.0)
    if isRootLayer then
        self._bossBgLayer = ret
    end
    return ret
end

function STMoonLayer:createBossLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bossLayer")
    ret:setContentSize(CCSizeMake(0.0, 0.0))
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(102.0)
    if isRootLayer then
        self._bossLayer = ret
    end
    return ret
end

function STMoonLayer:createTopSprite(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/copy_top_bg.png", CCRectMake(18.0, 16.0, 19.0, 18.0))
    ret:setName("topSprite")
    ret:setContentSize(CCSizeMake(640.0, 93.0))
    ret:setPosition(ccp(320.0, 960.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    local moonShopBtn = self:createMoonShopBtn(isRootLayer)
    ret:addChild(moonShopBtn)
    local backBtn = self:createBackBtn(isRootLayer)
    ret:addChild(backBtn)
    local tallyBtn = self:createTallyBtn(isRootLayer)
    ret:addChild(tallyBtn)
    local nameLightSprite = self:createNameLightSprite(isRootLayer)
    ret:addChild(nameLightSprite)
    local Sprite_4 = self:createSprite_4(isRootLayer)
    ret:addChild(Sprite_4)
    local copyTvRightSp = self:createCopyTvRightSp(isRootLayer)
    ret:addChild(copyTvRightSp)
    local copyTvLeftSp = self:createCopyTvLeftSp(isRootLayer)
    ret:addChild(copyTvLeftSp)
    local attackCountLayer = self:createAttackCountLayer(isRootLayer)
    ret:addChild(attackCountLayer)
    if isRootLayer then
        self._topSprite = ret
    end
    return ret
end

function STMoonLayer:createMoonShopBtn(isRootLayer)
    local ret = STButton:createWithImage("images/moon/moon_shop_n.png", "images/moon/moo_shop_h.png", nil, false)
    ret:setName("moonShopBtn")
    ret:setPosition(ccp(477.0, 48.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._moonShopBtn = ret
    end
    return ret
end

function STMoonLayer:createBackBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/close_btn_n.png", "images/common/close_btn_h.png", nil, false)
    ret:setName("backBtn")
    ret:setPosition(ccp(585.0, 48.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._backBtn = ret
    end
    return ret
end

function STMoonLayer:createTallyBtn(isRootLayer)
    local ret = STButton:createWithImage("images/moon/tally_n.png", "images/moon/tally_h.png", nil, false)
    ret:setName("tallyBtn")
    ret:setPosition(ccp(365.0, 49.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._tallyBtn = ret
    end
    return ret
end

function STMoonLayer:createNameLightSprite(isRootLayer)
    local ret = STSprite:create("images/moon/purple.png")
    ret:setName("nameLightSprite")
    ret:setPosition(ccp(133.0, 17.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local nameSprite = self:createNameSprite(isRootLayer)
    ret:addChild(nameSprite)
    if isRootLayer then
        self._nameLightSprite = ret
    end
    return ret
end

function STMoonLayer:createNameSprite(isRootLayer)
    local ret = STSprite:create("images/moon/copy_title/qianlongyuan.png")
    ret:setName("nameSprite")
    ret:setPosition(ccp(77.5, 24.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._nameSprite = ret
    end
    return ret
end

function STMoonLayer:createSprite_4(isRootLayer)
    local ret = STSprite:create("images/moon/copy_item_bg.png")
    ret:setName("Sprite_4")
    ret:setPosition(ccp(320.0, 35.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    local copyTabelView = self:createCopyTabelView(isRootLayer)
    ret:addChild(copyTabelView)
    if isRootLayer then
        self._Sprite_4 = ret
    end
    return ret
end

function STMoonLayer:createCopyTabelView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setBounceable(false)
    ret:setName("copyTabelView")
    ret:setContentSize(CCSizeMake(610.0, 165.0))
    ret:setInnerSize(CCSizeMake(610.0, 165.0))
    ret:setPosition(ccp(321.0, 14.0))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local copyCell = self:createCopyCell(isRootLayer)
    ret:addChild(copyCell)
    if isRootLayer then
        self._copyTabelView = ret
    end
    return ret
end

function STMoonLayer:createCopyCell(isRootLayer)
    local ret = STLayout:create()
    ret:setName("copyCell")
    ret:setContentSize(CCSizeMake(610.0, 165.0))
    ret:setTouchEnabled(true)
    local btn1 = self:createBtn1(isRootLayer)
    ret:addChild(btn1)
    local btn2 = self:createBtn2(isRootLayer)
    ret:addChild(btn2)
    local btn3 = self:createBtn3(isRootLayer)
    ret:addChild(btn3)
    local btn5 = self:createBtn5(isRootLayer)
    ret:addChild(btn5)
    local btn4 = self:createBtn4(isRootLayer)
    ret:addChild(btn4)
    if isRootLayer then
        self._copyCell = ret
    end
    return ret
end

function STMoonLayer:createBtn1(isRootLayer)
    local ret = STButton:createWithImage("images/moon/copy_item/jiaxu_1.png", "images/moon/copy_item/jiaxu_2.png", nil, false)
    ret:setName("btn1")
    ret:setPosition(ccp(74.0, 82.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name1_bg = self:createName1_bg(isRootLayer)
    ret:addChild(name1_bg)
    if isRootLayer then
        self._btn1 = ret
    end
    return ret
end

function STMoonLayer:createName1_bg(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/name_bg.png", CCRectMake(36.0, 8.0, 39.0, 10.0))
    ret:setName("name1_bg")
    ret:setContentSize(CCSizeMake(111.0, 26.0))
    ret:setPosition(ccp(77.0, 33.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name1_label = self:createName1_label(isRootLayer)
    ret:addChild(name1_label)
    if isRootLayer then
        self._name1_bg = ret
    end
    return ret
end

function STMoonLayer:createName1_label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10239"), g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name1_label")
    ret:setPosition(ccp(55.5, 13.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._name1_label = ret
    end
    return ret
end

function STMoonLayer:createBtn2(isRootLayer)
    local ret = STButton:createWithImage("images/moon/copy_item/caoren_1.png", "images/moon/copy_item/caoren_2.png", nil, false)
    ret:setName("btn2")
    ret:setPosition(ccp(178.0, 82.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name2_bg = self:createName2_bg(isRootLayer)
    ret:addChild(name2_bg)
    if isRootLayer then
        self._btn2 = ret
    end
    return ret
end

function STMoonLayer:createName2_bg(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/name_bg.png", CCRectMake(36.0, 8.0, 39.0, 10.0))
    ret:setName("name2_bg")
    ret:setContentSize(CCSizeMake(111.0, 26.0))
    ret:setPosition(ccp(99.0, 137.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name2_label = self:createName2_label(isRootLayer)
    ret:addChild(name2_label)
    if isRootLayer then
        self._name2_bg = ret
    end
    return ret
end

function STMoonLayer:createName2_label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10239"), g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name2_label")
    ret:setPosition(ccp(55.5, 13.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._name2_label = ret
    end
    return ret
end

function STMoonLayer:createBtn3(isRootLayer)
    local ret = STButton:createWithImage("images/moon/copy_item/dingyuan_1.png", "images/moon/copy_item/dingyuan_2.png", nil, false)
    ret:setName("btn3")
    ret:setPosition(ccp(303.0, 82.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name3_bg = self:createName3_bg(isRootLayer)
    ret:addChild(name3_bg)
    if isRootLayer then
        self._btn3 = ret
    end
    return ret
end

function STMoonLayer:createName3_bg(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/name_bg.png", CCRectMake(36.0, 8.0, 39.0, 10.0))
    ret:setName("name3_bg")
    ret:setContentSize(CCSizeMake(111.0, 26.0))
    ret:setPosition(ccp(102.0, 33.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name3_label = self:createName3_label(isRootLayer)
    ret:addChild(name3_label)
    if isRootLayer then
        self._name3_bg = ret
    end
    return ret
end

function STMoonLayer:createName3_label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10239"), g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name3_label")
    ret:setPosition(ccp(55.5, 13.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._name3_label = ret
    end
    return ret
end

function STMoonLayer:createBtn5(isRootLayer)
    local ret = STButton:createWithImage("images/moon/copy_item/caocao_1.png", "images/moon/copy_item/caocao_2.png", nil, false)
    ret:setName("btn5")
    ret:setPosition(ccp(533.0, 82.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name5_bg = self:createName5_bg(isRootLayer)
    ret:addChild(name5_bg)
    if isRootLayer then
        self._btn5 = ret
    end
    return ret
end

function STMoonLayer:createName5_bg(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/name_bg.png", CCRectMake(36.0, 8.0, 39.0, 10.0))
    ret:setName("name5_bg")
    ret:setContentSize(CCSizeMake(111.0, 26.0))
    ret:setPosition(ccp(87.0, 33.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name5_label = self:createName5_label(isRootLayer)
    ret:addChild(name5_label)
    if isRootLayer then
        self._name5_bg = ret
    end
    return ret
end

function STMoonLayer:createName5_label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10239"), g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name5_label")
    ret:setPosition(ccp(55.5, 13.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._name5_label = ret
    end
    return ret
end

function STMoonLayer:createBtn4(isRootLayer)
    local ret = STButton:createWithImage("images/moon/copy_item/caoren_1.png", "images/moon/copy_item/caoren_2.png", nil, false)
    ret:setName("btn4")
    ret:setPosition(ccp(428.0, 82.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name4_bg = self:createName4_bg(isRootLayer)
    ret:addChild(name4_bg)
    if isRootLayer then
        self._btn4 = ret
    end
    return ret
end

function STMoonLayer:createName4_bg(isRootLayer)
    local ret = STScale9Sprite:create("images/moon/name_bg.png", CCRectMake(36.0, 8.0, 39.0, 10.0))
    ret:setName("name4_bg")
    ret:setContentSize(CCSizeMake(111.0, 26.0))
    ret:setPosition(ccp(103.0, 137.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local name4_label = self:createName4_label(isRootLayer)
    ret:addChild(name4_label)
    if isRootLayer then
        self._name4_bg = ret
    end
    return ret
end

function STMoonLayer:createName4_label(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10239"), g_sFontPangWa, 18, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("name4_label")
    ret:setPosition(ccp(55.5, 13.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._name4_label = ret
    end
    return ret
end

function STMoonLayer:createCopyTvRightSp(isRootLayer)
    local ret = STSprite:create("images/common/arrow_right.png")
    ret:setName("copyTvRightSp")
    ret:setPosition(ccp(640.0, -86.0))
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._copyTvRightSp = ret
    end
    return ret
end

function STMoonLayer:createCopyTvLeftSp(isRootLayer)
    local ret = STSprite:create("images/common/arrow_left.png")
    ret:setName("copyTvLeftSp")
    ret:setPosition(ccp(0.0, -86.0))
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._copyTvLeftSp = ret
    end
    return ret
end

function STMoonLayer:createHighAttackCountLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("highAttackCountLayer")
    ret:setContentSize(CCSizeMake(301.0, 50.0))
    ret:setPosition(ccp(159.0, -272.5))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local highAttackCountLabel = self:createHighAttackCountLabel(isRootLayer)
    ret:addChild(highAttackCountLabel)
    local highAddAttackCountBtn = self:createHighAddAttackCountBtn(isRootLayer)
    ret:addChild(highAddAttackCountBtn)
    if isRootLayer then
        self._highAttackCountLayer = ret
    end
    return ret
end

function STMoonLayer:createHighAttackCountLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10347"), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("highAttackCountLabel")
    ret:setPosition(ccp(0.0, 25.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._highAttackCountLabel = ret
    end
    return ret
end

function STMoonLayer:createHighAddAttackCountBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png", nil, false)
    ret:setName("highAddAttackCountBtn")
    ret:setPosition(ccp(245.0, 25.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._highAddAttackCountBtn = ret
    end
    return ret
end

function STMoonLayer:createAttackCountLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("attackCountLayer")
    ret:setContentSize(CCSizeMake(301.0, 50.0))
    ret:setPosition(ccp(159.0, -226.27))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    local attackCountLabel = self:createAttackCountLabel(isRootLayer)
    ret:addChild(attackCountLabel)
    local addAttackCountBtn = self:createAddAttackCountBtn(isRootLayer)
    ret:addChild(addAttackCountBtn)
    if isRootLayer then
        self._attackCountLayer = ret
    end
    return ret
end

function STMoonLayer:createAttackCountLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10348"), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("attackCountLabel")
    ret:setPosition(ccp(0.0, 25.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._attackCountLabel = ret
    end
    return ret
end

function STMoonLayer:createAddAttackCountBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png", nil, false)
    ret:setName("addAttackCountBtn")
    ret:setPosition(ccp(245.0, 25.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._addAttackCountBtn = ret
    end
    return ret
end

function STMoonLayer:createBottom(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bgng_lefttimes.png", CCRectMake(10.0, 10.0, 13.0, 13.0))
    ret:setName("bottom")
    ret:setContentSize(CCSizeMake(640.0, 129.0))
    ret:setPosition(ccp(320.0, 5.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local Image_7 = self:createImage_7(isRootLayer)
    ret:addChild(Image_7)
    local dropTableView = self:createDropTableView(isRootLayer)
    ret:addChild(dropTableView)
    local dropTvRightSp = self:createDropTvRightSp(isRootLayer)
    ret:addChild(dropTvRightSp)
    local dropTvLeftSp = self:createDropTvLeftSp(isRootLayer)
    ret:addChild(dropTvLeftSp)
    local progressLabel = self:createProgressLabel(isRootLayer)
    ret:addChild(progressLabel)
    local bossControlLayer = self:createBossControlLayer(isRootLayer)
    ret:addChild(bossControlLayer)
    if isRootLayer then
        self._bottom = ret
    end
    return ret
end

function STMoonLayer:createImage_7(isRootLayer)
    local ret = STScale9Sprite:create("images/common/astro_labelbg.png", CCRectMake(24.0, 11.0, 27.0, 13.0))
    ret:setName("Image_7")
    ret:setContentSize(CCSizeMake(179.0, 35.0))
    ret:setPosition(ccp(320.0, 126.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_8 = self:createText_8(isRootLayer)
    ret:addChild(Text_8)
    if isRootLayer then
        self._Image_7 = ret
    end
    return ret
end

function STMoonLayer:createText_8(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10240"), g_sFontPangWa, 20, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_8")
    ret:setPosition(ccp(89.5, 17.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_8 = ret
    end
    return ret
end

function STMoonLayer:createDropTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setName("dropTableView")
    ret:setContentSize(CCSizeMake(604.0, 100.0))
    ret:setInnerSize(CCSizeMake(604.0, 100.0))
    ret:setPosition(ccp(320.0, 10.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._dropTableView = ret
    end
    return ret
end

function STMoonLayer:createDropTvRightSp(isRootLayer)
    local ret = STSprite:create("images/common/arrow_right.png")
    ret:setName("dropTvRightSp")
    ret:setPosition(ccp(640.0, 58.05))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.45)
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._dropTvRightSp = ret
    end
    return ret
end

function STMoonLayer:createDropTvLeftSp(isRootLayer)
    local ret = STSprite:create("images/common/arrow_left.png")
    ret:setName("dropTvLeftSp")
    ret:setPosition(ccp(0.0, 58.05))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.45)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._dropTvLeftSp = ret
    end
    return ret
end

function STMoonLayer:createProgressLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10242"), g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("progressLabel")
    ret:setPosition(ccp(623.5, 157.0))
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._progressLabel = ret
    end
    return ret
end

function STMoonLayer:createBossControlLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bossControlLayer")
    ret:setContentSize(CCSizeMake(640.0, 680.0))
    ret:setTouchEnabled(true)
    local attackBossBtn = self:createAttackBossBtn(isRootLayer)
    ret:addChild(attackBossBtn)
    local sweepBtn = self:createSweepBtn(isRootLayer)
    ret:addChild(sweepBtn)
    if isRootLayer then
        self._bossControlLayer = ret
    end
    return ret
end

function STMoonLayer:createChangeBossBtn(isRootLayer)
    local ret = STButton:createWithImage("images/moon/high.png", "images/moon/high.png", nil, false)
    ret:setName("changeBossBtn")
    ret:setPosition(ccp(571.9991, 218.9999))
    ret:setScaleX(0.8)
    ret:setScaleY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._changeBossBtn = ret
    end
    return ret
end

function STMoonLayer:createAttackBossBtn(isRootLayer)
    local ret = STButton:createWithImage("images/forge/fight_n.png", "images/forge/fight_h.png", nil, false)
    ret:setName("attackBossBtn")
    ret:setPosition(ccp(316.0, 243.0))
    ret:setScaleX(0.8)
    ret:setScaleY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._attackBossBtn = ret
    end
    return ret
end

function STMoonLayer:createSweepBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", "images/common/btn/btn_blue_hui.png", true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 89.0, 42.0))
    ret:setLabel(GetLocalizeStringBy("key_10368"), g_sFontPangWa, 30, ccc3(255.0, 228.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("sweepBtn")
    ret:setContentSize(CCSizeMake(119.0, 64.0))
    ret:setPosition(ccp(572.0, 296.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._sweepBtn = ret
    end
    return ret
end

function STMoonLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
