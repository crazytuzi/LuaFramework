STFormationLayer = class("STFormationLayer", function()
    return STLayer:create()
end)


function STFormationLayer:create()
    local ret = STFormationLayer:new()
    local bgSprite = ret:createBgSprite(true)
    ret:addChild(bgSprite)
    local centerLayer = ret:createCenterLayer(true)
    ret:addChild(centerLayer)
    local topBg = ret:createTopBg(true)
    ret:addChild(topBg)
    local bottomBg = ret:createBottomBg(true)
    ret:addChild(bottomBg)
    ret._layer = ret
    return ret
end

function STFormationLayer:createBgSprite(isRootLayer)
    local ret = STSprite:create("images/formation/formationbg.jpg")
    ret:setName("bgSprite")
    ret:setPosition(ccp(320.0, 480.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._bgSprite = ret
    end
    return ret
end

function STFormationLayer:createCenterLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("centerLayer")
    ret:setContentSize(CCSizeMake(640.0, 650.0))
    ret:setPosition(ccp(320.0, 118.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    local centerTableView = self:createCenterTableView(isRootLayer)
    ret:addChild(centerTableView)
    if isRootLayer then
        self._centerLayer = ret
    end
    return ret
end

function STFormationLayer:createCenterTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setBounceable(false)
    ret:setName("centerTableView")
    ret:setContentSize(CCSizeMake(640.0, 650.0))
    ret:setInnerSize(CCSizeMake(640.0, 650.0))
    ret:setPosition(ccp(320.0, 325.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._centerTableView = ret
    end
    return ret
end

function STFormationLayer:createTopBg(isRootLayer)
    local ret = STSprite:create("images/formation/topbg.png")
    ret:setName("topBg")
    ret:setPosition(ccp(320.0, 926.7456))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    local Sprite_2 = self:createSprite_2(isRootLayer)
    ret:addChild(Sprite_2)
    local Sprite_2_0 = self:createSprite_2_0(isRootLayer)
    ret:addChild(Sprite_2_0)
    local changeWarcraftBtn = self:createChangeWarcraftBtn(isRootLayer)
    ret:addChild(changeWarcraftBtn)
    local changeFormationBtn = self:createChangeFormationBtn(isRootLayer)
    ret:addChild(changeFormationBtn)
    local optionTableView = self:createOptionTableView(isRootLayer)
    ret:addChild(optionTableView)
    if isRootLayer then
        self._topBg = ret
    end
    return ret
end

function STFormationLayer:createSprite_2(isRootLayer)
    local ret = STSprite:create("images/formation/btn_left.png")
    ret:setName("Sprite_2")
    ret:setPosition(ccp(23.424, 72.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.0366)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_2 = ret
    end
    return ret
end

function STFormationLayer:createSprite_2_0(isRootLayer)
    local ret = STSprite:create("images/formation/btn_right.png")
    ret:setName("Sprite_2_0")
    ret:setPosition(ccp(530.816, 72.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.8294)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_2_0 = ret
    end
    return ret
end

function STFormationLayer:createChangeWarcraftBtn(isRootLayer)
    local ret = STButton:createWithImage("images/warcraft/warcraft_n.png", "images/warcraft/warcraft_h.png", nil, false)
    ret:setName("changeWarcraftBtn")
    ret:setPosition(ccp(588.8, 72.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.92)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._changeWarcraftBtn = ret
    end
    return ret
end

function STFormationLayer:createChangeFormationBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/btn_deploy_n.png", "images/formation/btn_deploy_h.png", nil, false)
    ret:setName("changeFormationBtn")
    ret:setPosition(ccp(588.8, 72.5))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.92)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._changeFormationBtn = ret
    end
    return ret
end

function STFormationLayer:createOptionTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionHorizontal)
    ret:setName("optionTableView")
    ret:setContentSize(CCSizeMake(455.0, 100.0))
    ret:setInnerSize(CCSizeMake(455.0, 100.0))
    ret:setPosition(ccp(50.0, 72.5))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._optionTableView = ret
    end
    return ret
end

function STFormationLayer:createSprite_20(isRootLayer)
    local ret = STSprite:create("images/main/menu/menu_bg.png")
    ret:setName("Sprite_20")
    if isRootLayer then
        self._Sprite_20 = ret
    end
    return ret
end

function STFormationLayer:createBottomBg(isRootLayer)
    local ret = STSprite:create("images/formation/bottombg.png")
    ret:setName("bottomBg")
    ret:setPosition(ccp(320.0, 204.9878))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local heroLevelLabel = self:createHeroLevelLabel(isRootLayer)
    ret:addChild(heroLevelLabel)
    local Sprite_22 = self:createSprite_22(isRootLayer)
    ret:addChild(Sprite_22)
    local tempLabel_1 = self:createTempLabel_1(isRootLayer)
    ret:addChild(tempLabel_1)
    local tempLabel_2 = self:createTempLabel_2(isRootLayer)
    ret:addChild(tempLabel_2)
    local tempLabel_3 = self:createTempLabel_3(isRootLayer)
    ret:addChild(tempLabel_3)
    local tempLabel_4 = self:createTempLabel_4(isRootLayer)
    ret:addChild(tempLabel_4)
    local tempLabel_5 = self:createTempLabel_5(isRootLayer)
    ret:addChild(tempLabel_5)
    local tempLabel_6 = self:createTempLabel_6(isRootLayer)
    ret:addChild(tempLabel_6)
    local heroQualityLabel = self:createHeroQualityLabel(isRootLayer)
    ret:addChild(heroQualityLabel)
    local phyAttTitleLabel = self:createPhyAttTitleLabel(isRootLayer)
    ret:addChild(phyAttTitleLabel)
    local magAttTitleLabel = self:createMagAttTitleLabel(isRootLayer)
    ret:addChild(magAttTitleLabel)
    local phyDefTitleLabel = self:createPhyDefTitleLabel(isRootLayer)
    ret:addChild(phyDefTitleLabel)
    local magDefTitleLabel = self:createMagDefTitleLabel(isRootLayer)
    ret:addChild(magDefTitleLabel)
    local phyAttValueLabel = self:createPhyAttValueLabel(isRootLayer)
    ret:addChild(phyAttValueLabel)
    local magDefValueLabel = self:createMagDefValueLabel(isRootLayer)
    ret:addChild(magDefValueLabel)
    local phyDefValueLabel = self:createPhyDefValueLabel(isRootLayer)
    ret:addChild(phyDefValueLabel)
    local magAttValueLabel = self:createMagAttValueLabel(isRootLayer)
    ret:addChild(magAttValueLabel)
    local equipBtn = self:createEquipBtn(isRootLayer)
    ret:addChild(equipBtn)
    local fightSoulBtn = self:createFightSoulBtn(isRootLayer)
    ret:addChild(fightSoulBtn)
    local godWeaponBtn = self:createGodWeaponBtn(isRootLayer)
    ret:addChild(godWeaponBtn)
    local onekeybg = self:createOnekeybg(isRootLayer)
    ret:addChild(onekeybg)
    local heroNameBg = self:createHeroNameBg(isRootLayer)
    ret:addChild(heroNameBg)
    local itemLayer = self:createItemLayer(isRootLayer)
    ret:addChild(itemLayer)
    local titleLayer = self:createTitleLayer(isRootLayer)
    ret:addChild(titleLayer)
    local bottomSwallowTouchLayer = self:createBottomSwallowTouchLayer(isRootLayer)
    ret:addChild(bottomSwallowTouchLayer)
    if isRootLayer then
        self._bottomBg = ret
    end
    return ret
end

function STFormationLayer:createHeroLevelLabel(isRootLayer)
    local ret = STLabel:create("1/5", g_sFontPangWa, 21, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("heroLevelLabel")
    ret:setPosition(ccp(100.0, 181.35))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.93)
    ret:setAnchorPoint(ccp(0.0, 1.0))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._heroLevelLabel = ret
    end
    return ret
end

function STFormationLayer:createSprite_22(isRootLayer)
    local ret = STSprite:create("images/common/line2.png")
    ret:setName("Sprite_22")
    ret:setPosition(ccp(175.0, 107.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.55)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local Sprite_21 = self:createSprite_21(isRootLayer)
    ret:addChild(Sprite_21)
    if isRootLayer then
        self._Sprite_22 = ret
    end
    return ret
end

function STFormationLayer:createSprite_21(isRootLayer)
    local ret = STSprite:create("images/formation/text.png")
    ret:setName("Sprite_21")
    ret:setPosition(ccp(119.0, 19.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._Sprite_21 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_1(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_1")
    ret:setPosition(ccp(68.0, 68.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.35)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_1 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_2(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_2")
    ret:setPosition(ccp(175.0, 68.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.35)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_2 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_3(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_3")
    ret:setPosition(ccp(280.0, 68.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.35)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_3 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_4(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_4")
    ret:setPosition(ccp(68.0, 39.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_4 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_5(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_5")
    ret:setPosition(ccp(175.0, 39.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_5 = ret
    end
    return ret
end

function STFormationLayer:createTempLabel_6(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontName, 23)
    ret:setName("tempLabel_6")
    ret:setPosition(ccp(280.0, 39.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._tempLabel_6 = ret
    end
    return ret
end

function STFormationLayer:createHeroQualityLabel(isRootLayer)
    local ret = STLabel:create("99", g_sFontName, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("heroQualityLabel")
    ret:setPosition(ccp(470.0, 113.1))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.58)
    ret:setAnchorPoint(ccp(0.0, 1.0))
    ret:setColor(ccc3(255.0, 246.0, 0.0))
    if isRootLayer then
        self._heroQualityLabel = ret
    end
    return ret
end

function STFormationLayer:createPhyAttTitleLabel(isRootLayer)
    local ret = STLabel:create("生命:", g_sFontName, 23)
    ret:setName("phyAttTitleLabel")
    ret:setPosition(ccp(380.0, 68.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.35)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._phyAttTitleLabel = ret
    end
    return ret
end

function STFormationLayer:createMagAttTitleLabel(isRootLayer)
    local ret = STLabel:create("攻击:", g_sFontName, 23)
    ret:setName("magAttTitleLabel")
    ret:setPosition(ccp(517.0, 68.25))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.35)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._magAttTitleLabel = ret
    end
    return ret
end

function STFormationLayer:createPhyDefTitleLabel(isRootLayer)
    local ret = STLabel:create("物防:", g_sFontName, 23)
    ret:setName("phyDefTitleLabel")
    ret:setPosition(ccp(380.0, 39.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._phyDefTitleLabel = ret
    end
    return ret
end

function STFormationLayer:createMagDefTitleLabel(isRootLayer)
    local ret = STLabel:create("法防:", g_sFontName, 23)
    ret:setName("magDefTitleLabel")
    ret:setPosition(ccp(517.0, 39.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.2)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setColor(ccc3(120.0, 37.0, 0.0))
    if isRootLayer then
        self._magDefTitleLabel = ret
    end
    return ret
end

function STFormationLayer:createPhyAttValueLabel(isRootLayer)
    local ret = STLabel:create("99999", g_sFontName, 22)
    ret:setName("phyAttValueLabel")
    ret:setPosition(ccp(410.0, 66.3))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.34)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 0.0, 0.0))
    if isRootLayer then
        self._phyAttValueLabel = ret
    end
    return ret
end

function STFormationLayer:createMagDefValueLabel(isRootLayer)
    local ret = STLabel:create("99999", g_sFontName, 22)
    ret:setName("magDefValueLabel")
    ret:setPosition(ccp(547.0, 37.05))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.19)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 0.0, 0.0))
    if isRootLayer then
        self._magDefValueLabel = ret
    end
    return ret
end

function STFormationLayer:createPhyDefValueLabel(isRootLayer)
    local ret = STLabel:create("99999", g_sFontName, 22)
    ret:setName("phyDefValueLabel")
    ret:setPosition(ccp(410.0, 37.05))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.19)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 0.0, 0.0))
    if isRootLayer then
        self._phyDefValueLabel = ret
    end
    return ret
end

function STFormationLayer:createMagAttValueLabel(isRootLayer)
    local ret = STLabel:create("99999", g_sFontName, 22)
    ret:setName("magAttValueLabel")
    ret:setPosition(ccp(547.0, 66.3))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.34)
    ret:setAnchorPoint(ccp(0.0, 0.5))
    ret:setColor(ccc3(0.0, 0.0, 0.0))
    if isRootLayer then
        self._magAttValueLabel = ret
    end
    return ret
end

function STFormationLayer:createEquipBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_equip_n.png", "images/common/btn/btn_equip_h.png", nil, false)
    ret:setName("equipBtn")
    ret:setPosition(ccp(272.0, 156.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.425)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._equipBtn = ret
    end
    return ret
end

function STFormationLayer:createFightSoulBtn(isRootLayer)
    local ret = STButton:createWithImage("images/common/btn/btn_fightSoul_n.png", "images/common/btn/btn_fightSoul_h.png", nil, false)
    ret:setName("fightSoulBtn")
    ret:setPosition(ccp(336.0, 156.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.525)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._fightSoulBtn = ret
    end
    return ret
end

function STFormationLayer:createGodWeaponBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/god_n.png", "images/formation/god_h.png", nil, false)
    ret:setName("godWeaponBtn")
    ret:setPosition(ccp(403.2, 156.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.63)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.8)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._godWeaponBtn = ret
    end
    return ret
end

function STFormationLayer:createOnekeybg(isRootLayer)
    local ret = STSprite:create("images/formation/onekeybg.png")
    ret:setName("onekeybg")
    ret:setPosition(ccp(535.0, 156.9299))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local onekeyStrengthenBtn = self:createOnekeyStrengthenBtn(isRootLayer)
    ret:addChild(onekeyStrengthenBtn)
    local changeOnekeyBtn = self:createChangeOnekeyBtn(isRootLayer)
    ret:addChild(changeOnekeyBtn)
    local onekeyEquipBtn = self:createOnekeyEquipBtn(isRootLayer)
    ret:addChild(onekeyEquipBtn)
    if isRootLayer then
        self._onekeybg = ret
    end
    return ret
end

function STFormationLayer:createOnekeyStrengthenBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/onekey_strengthen_n.png", "images/formation/onekey_strengthen_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 98.0, 18.0))
    ret:setName("onekeyStrengthenBtn")
    ret:setContentSize(CCSizeMake(128.0, 40.0))
    ret:setPosition(ccp(72.0, 26.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._onekeyStrengthenBtn = ret
    end
    return ret
end

function STFormationLayer:createChangeOnekeyBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/change_onekey_n.png", "images/formation/change_onekey_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 12.0, 18.0))
    ret:setName("changeOnekeyBtn")
    ret:setContentSize(CCSizeMake(42.0, 40.0))
    ret:setPosition(ccp(160.0, 26.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._changeOnekeyBtn = ret
    end
    return ret
end

function STFormationLayer:createOnekeyEquipBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/onekey_equip_n.png", "images/formation/onekey_equip_h.png", nil, true)
    ret:setCapInsets(CCRectMake(15.0, 11.0, 98.0, 18.0))
    ret:setName("onekeyEquipBtn")
    ret:setContentSize(CCSizeMake(128.0, 40.0))
    ret:setPosition(ccp(72.0, 26.0))
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._onekeyEquipBtn = ret
    end
    return ret
end

function STFormationLayer:createHeroNameBg(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg/bg_9s_2.png", CCRectMake(0.0, 0.0, 111.0, 32.0))
    ret:setName("heroNameBg")
    ret:setContentSize(CCSizeMake(240.0, 40.0))
    ret:setPosition(ccp(320.0, 195.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    local changeHeroBtn = self:createChangeHeroBtn(isRootLayer)
    ret:addChild(changeHeroBtn)
    local fashionBtn = self:createFashionBtn(isRootLayer)
    ret:addChild(fashionBtn)
    local heroNameLabel = self:createHeroNameLabel(isRootLayer)
    ret:addChild(heroNameLabel)
    local developupBtn = self:createDevelopupBtn(isRootLayer)
    ret:addChild(developupBtn)
    local extendLayer = self:createExtendLayer(isRootLayer)
    ret:addChild(extendLayer)
    if isRootLayer then
        self._heroNameBg = ret
    end
    return ret
end

function STFormationLayer:createChangeHeroBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/changehero/changehero_n.png", "images/formation/changehero/changehero_h.png", nil, false)
    ret:setName("changeHeroBtn")
    ret:setPosition(ccp(211.2, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.88)
    if isRootLayer then
        self._changeHeroBtn = ret
    end
    return ret
end

function STFormationLayer:createFashionBtn(isRootLayer)
    local ret = STButton:createWithImage("images/formation/fashion_n.png", "images/formation/fashion_h.png", nil, false)
    ret:setName("fashionBtn")
    ret:setPosition(ccp(206.4, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.86)
    if isRootLayer then
        self._fashionBtn = ret
    end
    return ret
end

function STFormationLayer:createHeroNameLabel(isRootLayer)
    local ret = STLabel:create("Text Label", g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    ret:setName("heroNameLabel")
    ret:setPosition(ccp(120.0, 20.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setPercentPositionYEnabled(true)
    ret:setPercentPositionY(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._heroNameLabel = ret
    end
    return ret
end

function STFormationLayer:createDevelopupBtn(isRootLayer)
    local ret = STButton:createWithImage("images/develop/developup_btn_n.png", "images/develop/developup_btn_h.png", nil, false)
    ret:setName("developupBtn")
    ret:setPosition(ccp(120.0, 92.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    if isRootLayer then
        self._developupBtn = ret
    end
    return ret
end

function STFormationLayer:createExtendLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("extendLayer")
    ret:setContentSize(CCSizeMake(60.0, 60.0))
    ret:setPosition(ccp(-6.0, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(-0.025)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._extendLayer = ret
    end
    return ret
end

function STFormationLayer:createItemLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("itemLayer")
    ret:setContentSize(CCSizeMake(640.0, 470.0))
    ret:setPosition(ccp(320.0, 199.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._itemLayer = ret
    end
    return ret
end

function STFormationLayer:createFightSoul9Sprite(isRootLayer)
    local ret = STScale9Sprite:create("images/common/bg_down.png", CCRectMake(44.0, 33.0, 46.0, 9.0))
    ret:setName("fightSoul9Sprite")
    ret:setContentSize(CCSizeMake(134.0, 400.0))
    ret:setPosition(ccp(105.0, 285.0))
    ret:setAnchorPoint(ccp(0.5, 0.5))
    local fightSoulTableView = self:createFightSoulTableView(isRootLayer)
    ret:addChild(fightSoulTableView)
    local swallowTouchLayer = self:createSwallowTouchLayer(isRootLayer)
    ret:addChild(swallowTouchLayer)
    local downArrowSprite = self:createDownArrowSprite(isRootLayer)
    ret:addChild(downArrowSprite)
    local upArrowSprite = self:createUpArrowSprite(isRootLayer)
    ret:addChild(upArrowSprite)
    if isRootLayer then
        self._fightSoul9Sprite = ret
    end
    return ret
end

function STFormationLayer:createFightSoulTableView(isRootLayer)
    local ret = STTableView:create()
    ret:setDirection(kCCScrollViewDirectionVertical)
    ret:setName("fightSoulTableView")
    ret:setContentSize(CCSizeMake(106.0, 360.0))
    ret:setInnerSize(CCSizeMake(106.0, 360.0))
    ret:setPosition(ccp(65.0, 8.0))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._fightSoulTableView = ret
    end
    return ret
end

function STFormationLayer:createSwallowTouchLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("swallowTouchLayer")
    ret:setContentSize(CCSizeMake(106.0, 360.0))
    ret:setPosition(ccp(65.0, 8.0))
    ret:setAnchorPoint(ccp(0.5, 0.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._swallowTouchLayer = ret
    end
    return ret
end

function STFormationLayer:createDownArrowSprite(isRootLayer)
    local ret = STSprite:create("images/common/xiajiao.png")
    ret:setName("downArrowSprite")
    ret:setPosition(ccp(67.0, 0.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._downArrowSprite = ret
    end
    return ret
end

function STFormationLayer:createUpArrowSprite(isRootLayer)
    local ret = STSprite:create("images/common/xiajiao.png")
    ret:setName("upArrowSprite")
    ret:setPosition(ccp(67.0, 379.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setScaleY(-1.0)
    ret:setAnchorPoint(ccp(0.5, 0.0))
    if isRootLayer then
        self._upArrowSprite = ret
    end
    return ret
end

function STFormationLayer:createTitleLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("titleLayer")
    ret:setContentSize(CCSizeMake(308.0, 57.0))
    ret:setPosition(ccp(320.0, 663.0))
    ret:setPercentPositionXEnabled(true)
    ret:setPercentPositionX(0.5)
    ret:setAnchorPoint(ccp(0.5, 1.0))
    ret:setBgColor(ccc3(150.0, 200.0, 255.0))
    ret:setBgOpacity(102.0)
    if isRootLayer then
        self._titleLayer = ret
    end
    return ret
end

function STFormationLayer:createBottomSwallowTouchLayer(isRootLayer)
    local ret = STLayout:create()
    ret:setName("bottomSwallowTouchLayer")
    ret:setContentSize(CCSizeMake(640.0, 195.0))
    ret:setTouchEnabled(true)
    if isRootLayer then
        self._bottomSwallowTouchLayer = ret
    end
    return ret
end

function STFormationLayer:getMemberNodeByName(name)
    return self["_" .. name]
end
