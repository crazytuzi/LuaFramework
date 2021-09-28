STMoonFightResultLayer = class("STMoonFightResultLayer", function()
    return STLayer:create()
end)


function STMoonFightResultLayer:create()
    local ret = STMoonFightResultLayer:new()
    ret._layer = ret
    return ret
end

function STMoonFightResultLayer:createSmallWin(isRootLayer)
    local ret = STScale9Sprite:create("images/battle/report/bg.png", CCRectMake(85.0, 82.0, 18.0, 19.0))
    ret:setName("smallWin")
    ret:setContentSize(CCSizeMake(520.0, 450.0))
    ret:setTag(34.0)
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local smallWinShareBtn = self:createSmallWinShareBtn(isRootLayer)
    ret:addChild(smallWinShareBtn)
    local smallWinForceLayer = self:createSmallWinForceLayer(isRootLayer)
    ret:addChild(smallWinForceLayer)
    local smallWinNameLabel = self:createSmallWinNameLabel(isRootLayer)
    ret:addChild(smallWinNameLabel)
    local Sprite_8 = self:createSprite_8(isRootLayer)
    ret:addChild(Sprite_8)
    local smallWinConfirmBtn = self:createSmallWinConfirmBtn(isRootLayer)
    ret:addChild(smallWinConfirmBtn)
    local Image_7 = self:createImage_7(isRootLayer)
    ret:addChild(Image_7)
    if isRootLayer then
        self._smallWin = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinShareBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png", nil, true)
    ret:setCapInsets(CCRectMake(76.0, 11.0, 58.0, 49.0))
    ret:setLabel(GetLocalizeStringBy("key_2391"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("smallWinShareBtn")
    ret:setContentSize(CCSizeMake(200.0, 71.0071))
    ret:setTag(35.0)
    ret:setPosition(ccp(152.0, 67.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._smallWinShareBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinForceLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("smallWinForceLayer")
    ret:setContentSize(CCSizeMake(260.0, 30.0))
    ret:setTag(39.0)
    ret:setPosition(ccp(260.0, 330.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    local smallWinForceTitleSprite = self:createSmallWinForceTitleSprite(isRootLayer)
    ret:addChild(smallWinForceTitleSprite)
    if isRootLayer then
        self._smallWinForceLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinForceTitleSprite(isRootLayer)
    local ret = STSprite:create("images/common/cur_fight.png")
    ret:setName("smallWinForceTitleSprite")
    ret:setContentSize(CCSizeMake(123.0, 34.0))
    ret:setTag(37.0)
    ret:setPosition(ccp(0.0, -48.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(-1.6)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local smallWinFightForceLabel = self:createSmallWinFightForceLabel(isRootLayer)
    ret:addChild(smallWinFightForceLabel)
    if isRootLayer then
        self._smallWinForceTitleSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinFightForceLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("smallWinFightForceLabel")
    ret:setTag(38.0)
    ret:setPosition(ccp(123.0, 17.17))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(1.0)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.505)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._smallWinFightForceLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("smallWinNameLabel")
    ret:setTag(40.0)
    ret:setPosition(ccp(260.0, 359.0001))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._smallWinNameLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createSprite_8(isRootLayer)
    local ret = STSprite:create("images/common/line2.png")
    ret:setName("Sprite_8")
    ret:setContentSize(CCSizeMake(238.0, 38.0))
    ret:setTag(41.0)
    ret:setPosition(ccp(260.0, 311.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local smallWinStarLayer = self:createSmallWinStarLayer(isRootLayer)
    ret:addChild(smallWinStarLayer)
    if isRootLayer then
        self._Sprite_8 = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinStarLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("smallWinStarLayer")
    ret:setContentSize(CCSizeMake(29.0, 30.0))
    ret:setTag(43.0)
    ret:setPosition(ccp(119.0, 19.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._smallWinStarLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createStar(isRootLayer)
    local ret = STSprite:create("images/moon/star.png")
    ret:setName("star")
    ret:setContentSize(CCSizeMake(26.0, 26.0))
    ret:setTag(44.0)
    ret:setPosition(ccp(0.0, 15.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    if isRootLayer then
        self._star = ret
    end
    return ret
end

function STMoonFightResultLayer:createSmallWinConfirmBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png", nil, true)
    ret:setCapInsets(CCRectMake(76.0, 11.0, 58.0, 49.0))
    ret:setLabel(GetLocalizeStringBy("key_1061"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("smallWinConfirmBtn")
    ret:setContentSize(CCSizeMake(200.0, 71.0))
    ret:setTag(45.0)
    ret:setPosition(ccp(362.0, 67.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._smallWinConfirmBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createImage_7(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/9s_purple.png", CCRectMake(61.0, 9.0, 65.0, 12.0))
    ret:setName("Image_7")
    ret:setContentSize(CCSizeMake(400.0, 100.0))
    ret:setTag(142.0)
    ret:setPosition(ccp(260.0, 177.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local progressLabel = self:createProgressLabel(isRootLayer)
    ret:addChild(progressLabel)
    local tip = self:createTip(isRootLayer)
    ret:addChild(tip)
    if isRootLayer then
        self._Image_7 = ret
    end
    return ret
end

function STMoonFightResultLayer:createProgressLabel(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10237"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("progressLabel")
    ret:setTag(47.0)
    ret:setPosition(ccp(198.6, 70.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.4965)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.7)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._progressLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createTip(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_10238"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("tip")
    ret:setTag(46.0)
    ret:setPosition(ccp(200.0, 30.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.3)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._tip = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailure(isRootLayer)
    local ret = STScale9Sprite:create("images/battle/report/bg.png", CCRectMake(85.0, 82.0, 18.0, 19.0))
    ret:setName("failure")
    ret:setContentSize(CCSizeMake(520.0, 724.0))
    ret:setTag(48.0)
    ret:setPosition(ccp(320.0, 442.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.4604)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local failureNameLabel = self:createFailureNameLabel(isRootLayer)
    ret:addChild(failureNameLabel)
    local Sprite_8_16 = self:createSprite_8_16(isRootLayer)
    ret:addChild(Sprite_8_16)
    local failureConfirmBtn = self:createFailureConfirmBtn(isRootLayer)
    ret:addChild(failureConfirmBtn)
    local Image_8 = self:createImage_8(isRootLayer)
    ret:addChild(Image_8)
    local failureLeftFlowerSprite = self:createFailureLeftFlowerSprite(isRootLayer)
    ret:addChild(failureLeftFlowerSprite)
    local failureRightFlowerSprite = self:createFailureRightFlowerSprite(isRootLayer)
    ret:addChild(failureRightFlowerSprite)
    if isRootLayer then
        self._failure = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("failureNameLabel")
    ret:setTag(53.0)
    ret:setPosition(ccp(260.0, 634.0001))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._failureNameLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createSprite_8_16(isRootLayer)
    local ret = STSprite:create("images/common/line2.png")
    ret:setName("Sprite_8_16")
    ret:setContentSize(CCSizeMake(238.0, 38.0))
    ret:setTag(54.0)
    ret:setPosition(ccp(262.0, 597.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local failureStarLayer = self:createFailureStarLayer(isRootLayer)
    ret:addChild(failureStarLayer)
    if isRootLayer then
        self._Sprite_8_16 = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureStarLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("failureStarLayer")
    ret:setContentSize(CCSizeMake(29.0, 30.0))
    ret:setTag(55.0)
    ret:setPosition(ccp(119.0, 19.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._failureStarLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureConfirmBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png", nil, true)
    ret:setCapInsets(CCRectMake(76.0, 11.0, 58.0, 49.0))
    ret:setLabel(GetLocalizeStringBy("key_1061"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("failureConfirmBtn")
    ret:setContentSize(CCSizeMake(200.0, 71.0))
    ret:setTag(57.0)
    ret:setPosition(ccp(260.0, 67.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._failureConfirmBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createImage_8(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_ng_attr.png", CCRectMake(24.0, 24.0, 27.0, 27.0))
    ret:setName("Image_8")
    ret:setContentSize(CCSizeMake(460.0, 450.0))
    ret:setTag(60.0)
    ret:setPosition(ccp(264.992, 340.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5096)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local feedPetBtn = self:createFeedPetBtn(isRootLayer)
    ret:addChild(feedPetBtn)
    local failureForceLayer = self:createFailureForceLayer(isRootLayer)
    ret:addChild(failureForceLayer)
    local Text_19 = self:createText_19(isRootLayer)
    ret:addChild(Text_19)
    local Text_20 = self:createText_20(isRootLayer)
    ret:addChild(Text_20)
    local Text_22 = self:createText_22(isRootLayer)
    ret:addChild(Text_22)
    local strengthenHeroBtn = self:createStrengthenHeroBtn(isRootLayer)
    ret:addChild(strengthenHeroBtn)
    local strengthenEquipBtn = self:createStrengthenEquipBtn(isRootLayer)
    ret:addChild(strengthenEquipBtn)
    local formationBtn = self:createFormationBtn(isRootLayer)
    ret:addChild(formationBtn)
    local fightSoulBtn = self:createFightSoulBtn(isRootLayer)
    ret:addChild(fightSoulBtn)
    local trainStarBtn = self:createTrainStarBtn(isRootLayer)
    ret:addChild(trainStarBtn)
    if isRootLayer then
        self._Image_8 = ret
    end
    return ret
end

function STMoonFightResultLayer:createFeedPetBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/feed_pet_n.png", "images/common/feed_pet_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 16.0, 14.0))
    ret:setName("feedPetBtn")
    ret:setContentSize(CCSizeMake(121.0, 103.0))
    ret:setTag(334.0)
    ret:setPosition(ccp(230.0, 70.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._feedPetBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureForceLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("failureForceLayer")
    ret:setContentSize(CCSizeMake(260.0, 30.0))
    ret:setTag(50.0)
    ret:setPosition(ccp(230.0, 306.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    local failureForceTitleSprite = self:createFailureForceTitleSprite(isRootLayer)
    ret:addChild(failureForceTitleSprite)
    if isRootLayer then
        self._failureForceLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureForceTitleSprite(isRootLayer)
    local ret = STSprite:create("images/common/cur_fight.png")
    ret:setName("failureForceTitleSprite")
    ret:setContentSize(CCSizeMake(123.0, 34.0))
    ret:setTag(51.0)
    ret:setPosition(ccp(0.0, 15.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local failureFightForceLabel = self:createFailureFightForceLabel(isRootLayer)
    ret:addChild(failureFightForceLabel)
    if isRootLayer then
        self._failureForceTitleSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureFightForceLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("failureFightForceLabel")
    ret:setTag(52.0)
    ret:setPosition(ccp(123.0, 17.17))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(1.0)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.505)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._failureFightForceLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createText_19(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_3053"), g_sFontPangWa, 26, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_19")
    ret:setTag(61.0)
    ret:setPosition(ccp(246.0, 416.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_19 = ret
    end
    return ret
end

function STMoonFightResultLayer:createText_20(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_2265"), g_sFontPangWa, 26, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_20")
    ret:setTag(62.0)
    ret:setPosition(ccp(81.0, 342.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_20 = ret
    end
    return ret
end

function STMoonFightResultLayer:createText_22(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_1175"), g_sFontPangWa, 26, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("Text_22")
    ret:setTag(63.0)
    ret:setPosition(ccp(237.0, 378.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Text_22 = ret
    end
    return ret
end

function STMoonFightResultLayer:createStrengthenHeroBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/strengthen_hero_n.png", "images/common/strengthen_hero_h.png", nil, false)
    ret:setName("strengthenHeroBtn")
    ret:setContentSize(CCSizeMake(113.0, 108.0))
    ret:setTag(64.0)
    ret:setPosition(ccp(72.0, 198.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._strengthenHeroBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createStrengthenEquipBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/strengthen_arm_n.png", "images/common/strengthen_arm_h.png", nil, false)
    ret:setName("strengthenEquipBtn")
    ret:setContentSize(CCSizeMake(112.0, 105.0))
    ret:setTag(66.0)
    ret:setPosition(ccp(375.0, 198.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._strengthenEquipBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createFormationBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/change_formation_n.png", "images/common/change_formation_h.png", nil, false)
    ret:setName("formationBtn")
    ret:setContentSize(CCSizeMake(117.0, 101.0))
    ret:setTag(67.0)
    ret:setPosition(ccp(230.0, 198.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._formationBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createFightSoulBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/up_fightsoul_n.png", "images/common/up_fightsoul_h.png", nil, false)
    ret:setName("fightSoulBtn")
    ret:setContentSize(CCSizeMake(113.0, 102.0))
    ret:setTag(68.0)
    ret:setPosition(ccp(375.0, 70.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._fightSoulBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createTrainStarBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/train_star_n.png", "images/common/train_star_h.png", nil, false)
    ret:setName("trainStarBtn")
    ret:setContentSize(CCSizeMake(113.0, 107.0))
    ret:setTag(69.0)
    ret:setPosition(ccp(72.0, 70.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._trainStarBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureLeftFlowerSprite(isRootLayer)
    local ret = STSprite:create("images/god_weapon/flower.png")
    ret:setName("failureLeftFlowerSprite")
    ret:setContentSize(CCSizeMake(267.0, 27.0))
    ret:setTag(52.0)
    ret:setPosition(ccp(162.604, 634.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.3127)
    ret:setScaleX(0.7)
    ret:setScaleY(0.7)
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._failureLeftFlowerSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createFailureRightFlowerSprite(isRootLayer)
    local ret = STSprite:create("images/god_weapon/flower.png")
    ret:setName("failureRightFlowerSprite")
    ret:setContentSize(CCSizeMake(267.0, 27.0))
    ret:setTag(53.0)
    ret:setPosition(ccp(357.396, 634.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.6873)
    ret:setScaleX(-0.7)
    ret:setScaleY(0.7)
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._failureRightFlowerSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWin(isRootLayer)
    local ret = STScale9Sprite:create("images/battle/report/bg.png", CCRectMake(85.0, 82.0, 18.0, 19.0))
    ret:setName("bossWin")
    ret:setContentSize(CCSizeMake(520.0, 650.0))
    ret:setTag(70.0)
    ret:setPosition(ccp(330.0, 432.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5156)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.45)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local bossWinShareBtn = self:createBossWinShareBtn(isRootLayer)
    ret:addChild(bossWinShareBtn)
    local bossWinForceLayer = self:createBossWinForceLayer(isRootLayer)
    ret:addChild(bossWinForceLayer)
    local bossWinNameLabel = self:createBossWinNameLabel(isRootLayer)
    ret:addChild(bossWinNameLabel)
    local Sprite_8_22 = self:createSprite_8_22(isRootLayer)
    ret:addChild(Sprite_8_22)
    local bossWinConfirmBtn = self:createBossWinConfirmBtn(isRootLayer)
    ret:addChild(bossWinConfirmBtn)
    local Image_10 = self:createImage_10(isRootLayer)
    ret:addChild(Image_10)
    local bossWinLeftFlowerSprite = self:createBossWinLeftFlowerSprite(isRootLayer)
    ret:addChild(bossWinLeftFlowerSprite)
    local bossWinRightFlowerSprite = self:createBossWinRightFlowerSprite(isRootLayer)
    ret:addChild(bossWinRightFlowerSprite)
    if isRootLayer then
        self._bossWin = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinShareBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png", nil, true)
    ret:setCapInsets(CCRectMake(76.0, 11.0, 58.0, 49.0))
    ret:setLabel(GetLocalizeStringBy("key_2391"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("bossWinShareBtn")
    ret:setContentSize(CCSizeMake(200.0, 71.0071))
    ret:setTag(71.0)
    ret:setPosition(ccp(152.0, 67.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._bossWinShareBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinForceLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bossWinForceLayer")
    ret:setContentSize(CCSizeMake(260.0, 30.0))
    ret:setTag(72.0)
    ret:setPosition(ccp(260.0, 476.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    local bossWinForceTitleSprite = self:createBossWinForceTitleSprite(isRootLayer)
    ret:addChild(bossWinForceTitleSprite)
    if isRootLayer then
        self._bossWinForceLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinForceTitleSprite(isRootLayer)
    local ret = STSprite:create("images/common/cur_fight.png")
    ret:setName("bossWinForceTitleSprite")
    ret:setContentSize(CCSizeMake(123.0, 34.0))
    ret:setTag(73.0)
    ret:setPosition(ccp(0.0, -15.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(-0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    local bossWinFightForceLabel = self:createBossWinFightForceLabel(isRootLayer)
    ret:addChild(bossWinFightForceLabel)
    if isRootLayer then
        self._bossWinForceTitleSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinFightForceLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 23, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("bossWinFightForceLabel")
    ret:setTag(74.0)
    ret:setPosition(ccp(123.0, 17.17))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(1.0)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.505)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._bossWinFightForceLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("bossWinNameLabel")
    ret:setTag(75.0)
    ret:setPosition(ccp(260.0, 552.999))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._bossWinNameLabel = ret
    end
    return ret
end

function STMoonFightResultLayer:createSprite_8_22(isRootLayer)
    local ret = STSprite:create("images/common/line2.png")
    ret:setName("Sprite_8_22")
    ret:setContentSize(CCSizeMake(238.0, 38.0))
    ret:setTag(76.0)
    ret:setPosition(ccp(260.0, 497.9991))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local bossWinStarLayer = self:createBossWinStarLayer(isRootLayer)
    ret:addChild(bossWinStarLayer)
    if isRootLayer then
        self._Sprite_8_22 = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinStarLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bossWinStarLayer")
    ret:setContentSize(CCSizeMake(29.0, 30.0))
    ret:setTag(77.0)
    ret:setPosition(ccp(119.0, 19.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(0.0)
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._bossWinStarLayer = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinConfirmBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png", nil, true)
    ret:setCapInsets(CCRectMake(76.0, 11.0, 58.0, 49.0))
    ret:setLabel(GetLocalizeStringBy("key_1061"), g_sFontPangWa, 35, ccc3(255.0, 246.0, 0.0), 1, ccc3(0, 0, 0), type_stroke)
    ret:setName("bossWinConfirmBtn")
    ret:setContentSize(CCSizeMake(200.0, 71.0))
    ret:setTag(79.0)
    ret:setPosition(ccp(369.9995, 67.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._bossWinConfirmBtn = ret
    end
    return ret
end

function STMoonFightResultLayer:createImage_10(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/9s_1.png", CCRectMake(32.0, 32.0, 35.0, 33.0))
    ret:setName("Image_10")
    ret:setContentSize(CCSizeMake(470.0, 270.0))
    ret:setTag(82.0)
    ret:setPosition(ccp(260.0, 248.0001))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Image_11 = self:createImage_11(isRootLayer)
    ret:addChild(Image_11)
    local bossWinTableView = self:createBossWinTableView(isRootLayer)
    ret:addChild(bossWinTableView)
    if isRootLayer then
        self._Image_10 = ret
    end
    return ret
end

function STMoonFightResultLayer:createImage_11(isRootLayer)
    local ret = STScale9Sprite:create("images/common/astro_labelbg.png", CCRectMake(24.0, 11.0, 27.0, 13.0))
    ret:setName("Image_11")
    ret:setContentSize(CCSizeMake(170.0, 35.0))
    ret:setTag(83.0)
    ret:setPosition(ccp(235.0, 270.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Text_31 = self:createText_31(isRootLayer)
    ret:addChild(Text_31)
    if isRootLayer then
        self._Image_11 = ret
    end
    return ret
end

function STMoonFightResultLayer:createText_31(isRootLayer)
    local ret = STLabel:create(GetLocalizeStringBy("key_2882"), g_sFontName, 24)
    ret:setName("Text_31")
    ret:setTag(84.0)
    ret:setPosition(ccp(85.0, 18.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._Text_31 = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setBounceable(false)
    ret:setName("bossWinTableView")
    ret:setContentSize(CCSizeMake(470.0, 240.0))
    ret:setInnerSize(CCSizeMake(470.0, 240.0))
    ret:setTag(85.0)
    ret:setPosition(ccp(235.0, 10.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setBgColor(ccc3(150.0, 150.0, 255.0))
    ret:setBgOpacity(0.0)
    if isRootLayer then
        self._bossWinTableView = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinLeftFlowerSprite(isRootLayer)
    local ret = STSprite:create("images/god_weapon/flower.png")
    ret:setName("bossWinLeftFlowerSprite")
    ret:setContentSize(CCSizeMake(267.0, 27.0))
    ret:setTag(122.0)
    ret:setPosition(ccp(162.604, 553.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.3127)
    ret:setScaleX(0.7)
    ret:setScaleY(0.7)
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._bossWinLeftFlowerSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:createBossWinRightFlowerSprite(isRootLayer)
    local ret = STSprite:create("images/god_weapon/flower.png")
    ret:setName("bossWinRightFlowerSprite")
    ret:setContentSize(CCSizeMake(267.0, 27.0))
    ret:setTag(123.0)
    ret:setPosition(ccp(357.396, 553.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.6873)
    ret:setScaleX(-0.7)
    ret:setScaleY(0.7)
    ret:setAnchorPoint(ccp(1.0, 0.5))
    if isRootLayer then
        self._bossWinRightFlowerSprite = ret
    end
    return ret
end

function STMoonFightResultLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
