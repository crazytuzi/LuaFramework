require"Lang"
UILineup = { }

local ui_topPanel = nil
local ui_scrollView = nil
local ui_iconItem = nil
local ui_sectorView = nil
local btn_soul = nil
local ui_bgPanel = nil

local ui_cardTouchPanel = nil
local ui_cardInfoItem = nil

local _curShowCardIndex = 1
local _activateLuckNum = 0 -- 激活缘分数
local _cardAnimations = nil
local _tempAttributes = nil
local _tempValueCount = nil

local _fightSoulData = nil

UILineup.friendState = 0
local _formation = nil
--最多的伙伴培养个数
local MAX_FRIEND_COUNT = 4

local _friendPosition = nil

local function getCardTitleId(titleDetailId)
    local titleId = tonumber(DictTitleDetail[tostring(titleDetailId)].titleId)
    --  cclog( "titleId :"..titleId )
    return titleId
end

local function isHintSoul(instFormationId)
    local _instFormationId = instFormationId
    local obj = nil
    obj = net.InstPlayerFormation[tostring(_instFormationId)]

    local instCardId = obj.int["3"]
    -- 卡牌实例ID
    local type = obj.int["4"]
    -- 阵型类型 1:主力,2:替补
    local dictCardId = obj.int["6"]
    -- 卡牌字典ID
    local instCardData = net.InstPlayerCard[tostring(instCardId)]
    -- 卡牌实例数据
    local dictCardData = DictCard[tostring(dictCardId)]
    -- 卡牌字典数据
    local qualityId = instCardData.int["4"]
    -- 品阶ID
    local starLevelId = instCardData.int["5"]
    -- 星级ID
    local titleDetailId = instCardData.int["6"]
    -- 具体称号ID
    local level = instCardData.int["9"]
    -- 等级
    local qualityId = 1
    local count = 0
    if net.InstPlayerFightSoul then
        for soulKey, soulValue in pairs(net.InstPlayerFightSoul) do
            --  cclog( " instCardId  "..instCardId.."  " .. soulValue.int[ "7" ] )
            if soulValue.int["7"] == instCardId then
                local pro = nil
                -- for key ,value in pairs ( DictFightSoulUpgradeProp ) do
                if qualityId < soulValue.int["4"] then
                    qualityId = soulValue.int["4"]
                end
                count = count + 1
                -- end
            end
        end
    end
    if count < getCardTitleId(titleDetailId) then
        qualityId = 6
    end
   -- cclog("qualityId :" .. qualityId .. "  " .. count)
    if _fightSoulData then
        for key, value in pairs(_fightSoulData) do
            if value.int["4"] < qualityId then
                return true
            end
        end
    end
    return false
end

local function setScrollViewFocus(isJumpTo)
    local childs = ui_scrollView:getChildren()
    for key, obj in pairs(childs) do
        local ui_focus = obj:getChildByName("image_choose")
        if _curShowCardIndex == key then
            ui_focus:setVisible(true)

            local contaniner = ui_scrollView:getInnerContainer()
            local w =(contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
            local dt
            if w == 0 then
                dt = 0
            else
                dt =(obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
                if dt < 0 then
                    dt = 0
                end
            end
            if isJumpTo then
                ui_scrollView:jumpToPercentHorizontal(dt * 100)
            else
                ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
            end

        else
            ui_focus:setVisible(false)
        end
    end
end

local function isHint(_equipTypeId, _instId)
    if _instId then
        if net.InstPlayerEquip then
            local _equipId = net.InstPlayerEquip[tostring(_instId)].int["4"]
            local _equipAdvanceId = net.InstPlayerEquip[tostring(_instId)].int["8"]
            local _equipQualityId = (_equipAdvanceId >= 1000) and DictEquipAdvancered[tostring(_equipAdvanceId)].equipQualityId or DictEquipment[tostring(_equipId)].equipQualityId
            for key, obj in pairs(net.InstPlayerEquip) do
                if _equipTypeId == obj.int["3"] and _instId ~= obj.int["1"] and obj.int["6"] == 0 then
                    local _tempEquipQualityId = (obj.int["8"] >= 1000) and DictEquipAdvancered[tostring(obj.int["8"])].equipQualityId or DictEquipment[tostring(obj.int["4"])].equipQualityId
                    if _tempEquipQualityId > _equipQualityId then
                        return true
                    end
                end
            end
        end
        return false
    else
        if net.InstPlayerEquip then
            for key, obj in pairs(net.InstPlayerEquip) do
                if _equipTypeId == obj.int["3"] and obj.int["6"] == 0 then
                    return true
                end
            end
        end
        return false
    end
end

local function isMagicHint(_magicType, _instId)
    if _instId then
        if net.InstPlayerMagic then
            local _magicId = net.InstPlayerMagic[tostring(_instId)].int["3"]
            local _magicQualityId = DictMagic[tostring(_magicId)].magicQualityId
            for key, obj in pairs(net.InstPlayerMagic) do
                if _magicType == obj.int["4"] and _instId ~= obj.int["1"] and obj.int["8"] == 0 and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then
                    local _tempMagicQualityId = DictMagic[tostring(obj.int["3"])].magicQualityId
                    if _tempMagicQualityId < _magicQualityId then
                        return true
                    end
                end
            end
        end
        return false
    else
        if net.InstPlayerMagic then
            for key, obj in pairs(net.InstPlayerMagic) do
                if _magicType == obj.int["4"] and obj.int["8"] == 0 and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then
                    return true
                end
            end
        end
        return false
    end
end

local function setCardEquipInfo(touchEnabled, _instFormationId, instCardId)
    local ui_btnWeapon = ui_bgPanel:getChildByName("image_weapon")
    -- 武器
    local ui_btnCorselet = ui_bgPanel:getChildByName("image_corselet")
    -- 护甲
    local ui_btnHelm = ui_bgPanel:getChildByName("image_helm")
    -- 头盔
    local ui_btnNecklace = ui_bgPanel:getChildByName("image_necklace")
    -- 饰品
    local ui_treasurePanel = ui_bgPanel:getChildByName("image_di_treasure")
    local ui_btnTreasure = ui_treasurePanel:getChildByName("image_frame_treasure")
    -- 法宝
    local ui_gongfaPanel = ui_bgPanel:getChildByName("image_di_gongfa")
    local ui_btnGongfa = ui_gongfaPanel:getChildByName("image_frame_gongfa")
    -- 功法

    ui_btnWeapon:setTag(0)
    ui_btnWeapon:loadTexture("ui/low_small_white.png")
    local ui_weaponIcon = ui_btnWeapon:getChildByName("image_weapon")
    -- 武器图标
    ui_btnWeapon:getChildByName("image_lv"):setVisible(false)
    ui_btnWeapon:getChildByName("image_hint"):setVisible(false)
    ui_btnWeapon:getChildByName("image_star"):setVisible(false)
    ui_btnWeapon:getChildByName("image_jinglian"):setVisible(false)
    ui_weaponIcon:loadTexture("ui/frame_tianjia.png")
    local ui_weaponName = ccui.Helper:seekNodeByName(ui_btnWeapon, "text_name_weapon")
    ui_weaponName:setString(Lang.ui_lineup1)

    ui_btnCorselet:setTag(0)
    ui_btnCorselet:loadTexture("ui/low_small_white.png")
    local ui_corseletIcon = ui_btnCorselet:getChildByName("image_corselet")
    -- 护甲图标
    ui_btnCorselet:getChildByName("image_lv"):setVisible(false)
    ui_btnCorselet:getChildByName("image_hint"):setVisible(false)
    ui_btnCorselet:getChildByName("image_star"):setVisible(false)
    ui_btnCorselet:getChildByName("image_jinglian"):setVisible(false)
    ui_corseletIcon:loadTexture("ui/frame_tianjia.png")
    local ui_corseletName = ccui.Helper:seekNodeByName(ui_btnCorselet, "text_name_corselet")
    ui_corseletName:setString(Lang.ui_lineup2)

    ui_btnHelm:setTag(0)
    ui_btnHelm:loadTexture("ui/low_small_white.png")
    local ui_helmIcon = ui_btnHelm:getChildByName("image_helm")
    -- 头盔图标
    ui_btnHelm:getChildByName("image_lv"):setVisible(false)
    ui_btnHelm:getChildByName("image_hint"):setVisible(false)
    ui_btnHelm:getChildByName("image_star"):setVisible(false)
    ui_btnHelm:getChildByName("image_jinglian"):setVisible(false)
    ui_helmIcon:loadTexture("ui/frame_tianjia.png")
    local ui_helmName = ccui.Helper:seekNodeByName(ui_btnHelm, "text_name_helm")
    ui_helmName:setString(Lang.ui_lineup3)

    ui_btnNecklace:setTag(0)
    ui_btnNecklace:loadTexture("ui/low_small_white.png")
    local ui_necklaceIcon = ui_btnNecklace:getChildByName("image_necklace")
    -- 饰品图标
    ui_btnNecklace:getChildByName("image_lv"):setVisible(false)
    ui_btnNecklace:getChildByName("image_hint"):setVisible(false)
    ui_btnNecklace:getChildByName("image_star"):setVisible(false)
    ui_btnNecklace:getChildByName("image_jinglian"):setVisible(false)
    ui_necklaceIcon:loadTexture("ui/frame_tianjia.png")
    local ui_necklaceName = ccui.Helper:seekNodeByName(ui_btnNecklace, "text_name_necklace")
    ui_necklaceName:setString(Lang.ui_lineup4)

    ui_btnTreasure:setTag(0)
    ui_btnTreasure:loadTexture("ui/gold_d.png")
    local ui_treasureIcon = ui_treasurePanel:getChildByName("image_treasure")
    -- 法宝图标
    ui_treasurePanel:getChildByName("image_lv"):setVisible(false)
    ui_treasurePanel:getChildByName("image_hint"):setVisible(false)
    ui_treasureIcon:loadTexture("ui/frame_tianjia.png")
    local ui_treasureName = ccui.Helper:seekNodeByName(ui_treasurePanel, "text_name_treasure")
    ui_treasureName:setString(Lang.ui_lineup5)

    ui_btnGongfa:setTag(0)
    ui_btnGongfa:loadTexture("ui/gold_d.png")
    local ui_gongfaIcon = ui_gongfaPanel:getChildByName("image_gongfa")
    -- 功法图标
    ui_gongfaPanel:getChildByName("image_lv"):setVisible(false)
    ui_gongfaPanel:getChildByName("image_hint"):setVisible(false)
    ui_gongfaIcon:loadTexture("ui/frame_tianjia.png")
    local ui_gongfaName = ccui.Helper:seekNodeByName(ui_gongfaPanel, "text_name_gongfa")
    ui_gongfaName:setString(Lang.ui_lineup6)

    if _instFormationId and net.InstPlayerEquip then
        ui_btnWeapon:getChildByName("image_hint"):setVisible(isHint(StaticEquip_Type.equip))
        ui_btnCorselet:getChildByName("image_hint"):setVisible(isHint(StaticEquip_Type.outerwear))
        ui_btnHelm:getChildByName("image_hint"):setVisible(isHint(StaticEquip_Type.pants))
        ui_btnNecklace:getChildByName("image_hint"):setVisible(isHint(StaticEquip_Type.necklace))
    end
    utils.addFrameParticle(ui_corseletIcon, false)
    utils.addFrameParticle(ui_helmIcon, false)
    utils.addFrameParticle(ui_necklaceIcon, false)
    utils.addFrameParticle(ui_weaponIcon, false)

    if net.InstPlayerEquipBox then
        for _ipebKey, _ipebObj in pairs(net.InstPlayerEquipBox) do
            if _instFormationId == _ipebObj.int["3"] then
                local getJLQualityImage = function(_ipebInstData)
                    local _jlQualityImage = nil
                    if _ipebInstData and #_ipebInstData > 0 then
                        local _perfectLvStr = ""
                        for _iii, _ooo in pairs(_ipebInstData) do
                            local _tempOOO = utils.stringSplit(_ooo, "_")
                            local _lvId = tonumber(_tempOOO[1])
                            local _state = tonumber(_tempOOO[2]) --0可精炼 1普通 2优良 3完美
                            if _state == 3 then
                                _perfectLvStr = _perfectLvStr .. _lvId
                                if _lvId % 5 == 0 then
                                    local _tempStr = ""
                                    for _i = 1, _lvId do
                                        _tempStr = _tempStr .. _i
                                    end
                                    if _perfectLvStr == _tempStr then
                                        if _lvId == 5 then
                                            _jlQualityImage = "ui/qx_green.png"
                                        elseif _lvId == 10 then
                                            _jlQualityImage = "ui/qx_blue.png"
                                        elseif _lvId == 15 then
                                            _jlQualityImage = "ui/qx_purple.png"
                                        elseif _lvId == 20 then
                                            _jlQualityImage = "ui/qx_red.png"
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return _jlQualityImage
                end

                --武器
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["4"], ";"))
                if _jlImage then
                    ui_btnWeapon:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnWeapon:getChildByName("image_jinglian"):setVisible(true)
                end
                --护甲
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["5"], ";"))
                if _jlImage then
                    ui_btnCorselet:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnCorselet:getChildByName("image_jinglian"):setVisible(true)
                end
                --头盔
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["6"], ";"))
                if _jlImage then
                    ui_btnHelm:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnHelm:getChildByName("image_jinglian"):setVisible(true)
                end
                --饰品
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["7"], ";"))
                if _jlImage then
                    ui_btnNecklace:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnNecklace:getChildByName("image_jinglian"):setVisible(true)
                end
                break
            end
        end
    end

    if _instFormationId and net.InstPlayerLineup then
        if not UILineup.friendState then
        else
            for key, obj in pairs(net.InstPlayerLineup) do
                if _instFormationId == obj.int["3"] then
                    local equipTypeId = obj.int["4"]
                    -- 装备类型Id
                    local instEquipId = obj.int["5"]
                    -- 装备实例Id
                    local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
                    -- 装备实例数据
                    local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                    -- 装备字典数据
                    local equipLevel = instEquipData.int["5"]
                    -- 装备等级

                local equipAdvanceId = instEquipData.int["8"]
                -- 装备进阶字典ID
                local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
                -- 装备进阶字典表

                    local qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small)
                    local qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipData.equipQualityId)
                    local _isShowHint = isHint(equipTypeId, instEquipId)
                    if equipTypeId == StaticEquip_Type.outerwear then
                        -- 护甲
                        ui_btnCorselet:setTag(instEquipId)


                    ui_corseletIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)


                        ui_btnCorselet:getChildByName("image_lv"):setVisible(true)
                        ui_btnCorselet:getChildByName("image_hint"):setVisible(_isShowHint)
                        ccui.Helper:seekNodeByName(ui_btnCorselet, "text_lv"):setString(tostring(equipLevel))
                        if dictEquipAdvanceData then
                            ui_btnCorselet:getChildByName("image_star"):setVisible(true)
                            ui_btnCorselet:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                            qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small)
                            qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipAdvanceData.equipQualityId)
                        end
                        ui_btnCorselet:loadTexture(qualityImage)
                        ui_btnCorselet:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
                        local suitEquipData = utils.getEquipSuit(tostring(instEquipData.int["4"]))
                        -- if suitEquipData then
                        utils.addFrameParticle(ui_corseletIcon, suitEquipData)
                        -- end
                        ui_corseletName:setString(dictEquipData.name)
                    elseif equipTypeId == StaticEquip_Type.pants then
                        -- 头盔
                        ui_btnHelm:setTag(instEquipId)


                    ui_helmIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)


                        ui_btnHelm:getChildByName("image_lv"):setVisible(true)
                        ui_btnHelm:getChildByName("image_hint"):setVisible(_isShowHint)
                        ccui.Helper:seekNodeByName(ui_btnHelm, "text_lv"):setString(tostring(equipLevel))
                        if dictEquipAdvanceData then
                            ui_btnHelm:getChildByName("image_star"):setVisible(true)
                            ui_btnHelm:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                            qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipAdvanceData.equipQualityId)
                            qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small)
                        end
                        ui_btnHelm:loadTexture(qualityImage)
                        ui_btnHelm:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
                        local suitEquipData = utils.getEquipSuit(tostring(instEquipData.int["4"]))
                        -- if suitEquipData then
                        utils.addFrameParticle(ui_helmIcon, suitEquipData)
                        -- end
                        ui_helmName:setString(dictEquipData.name)
                    elseif equipTypeId == StaticEquip_Type.necklace then
                        -- 饰品
                        ui_btnNecklace:setTag(instEquipId)


                    ui_necklaceIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)


                        ui_btnNecklace:getChildByName("image_lv"):setVisible(true)
                        ui_btnNecklace:getChildByName("image_hint"):setVisible(_isShowHint)
                        ccui.Helper:seekNodeByName(ui_btnNecklace, "text_lv"):setString(tostring(equipLevel))
                        if dictEquipAdvanceData then
                            ui_btnNecklace:getChildByName("image_star"):setVisible(true)
                            ui_btnNecklace:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                            qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipAdvanceData.equipQualityId)
                            qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small)
                        end
                        ui_btnNecklace:loadTexture(qualityImage)
                        ui_btnNecklace:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
                        local suitEquipData = utils.getEquipSuit(tostring(instEquipData.int["4"]))
                        -- if suitEquipData then
                        utils.addFrameParticle(ui_necklaceIcon, suitEquipData)
                        -- end
                        ui_necklaceName:setString(dictEquipData.name)
                    elseif equipTypeId == StaticEquip_Type.ring then
                        -- 戒指
                        --[[
					    ui_btnRing:setTag(instEquipId)
					    ui_btnRing:loadTextures(qualityImage, qualityImage)
					    ui_ringIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
					    ui_ringIcon:getChildByName("image_lv"):setVisible(true)
					    ccui.Helper:seekNodeByName(ui_ringIcon, "label_lv"):setString(tostring(equipLevel))
					    ]]
                    elseif equipTypeId == StaticEquip_Type.equip then
                        -- 武器
                        ui_btnWeapon:setTag(instEquipId)


                    ui_weaponIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)


                        ui_btnWeapon:getChildByName("image_lv"):setVisible(true)
                        ui_btnWeapon:getChildByName("image_hint"):setVisible(_isShowHint)
                        ccui.Helper:seekNodeByName(ui_btnWeapon, "text_lv"):setString(tostring(equipLevel))
                        if dictEquipAdvanceData then
                            ui_btnWeapon:getChildByName("image_star"):setVisible(true)
                            ui_btnWeapon:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                            qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipAdvanceData.equipQualityId)
                            qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small)
                        end
                        ui_btnWeapon:loadTexture(qualityImage)
                        ui_btnWeapon:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
                        local suitEquipData = utils.getEquipSuit(tostring(instEquipData.int["4"]))
                        -- if suitEquipData then
                        utils.addFrameParticle(ui_weaponIcon, suitEquipData)
                        -- end
                        ui_weaponName:setString(dictEquipData.name)
                    elseif equipTypeId == StaticEquip_Type.cloak then
                        -- 法宝
                        --[[
					    ui_btnTreasure:setTag(instEquipId)
					    ui_btnTreasure:loadTextures(qualityImage, qualityImage)
					    ui_treasureIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
					    ui_treasureIcon:getChildByName("image_lv"):setVisible(true)
					    ccui.Helper:seekNodeByName(ui_treasureIcon, "label_lv"):setString(tostring(equipLevel))
					    ]]
                    end
                end
            end
        end
    end
    if _instFormationId and net.InstPlayerMagic then
        ui_treasurePanel:getChildByName("image_hint"):setVisible(isMagicHint(dp.MagicType.treasure))
        ui_gongfaPanel:getChildByName("image_hint"):setVisible(isMagicHint(dp.MagicType.gongfa))
        local _magicCount = 0
        for key, obj in pairs(net.InstPlayerMagic) do
            if instCardId == obj.int["8"] then
                _magicCount = _magicCount + 1
                local instMagicId = obj.int["1"]
                local dictMagicId = obj.int["3"]
                local magicType = obj.int["4"]
                local magicQualityId = obj.int["5"]
                local magicLv = DictMagicLevel[tostring(obj.int["6"])].level
                local dictMagicData = DictMagic[tostring(dictMagicId)]
                local frameImg = nil
                if magicQualityId == StaticMagicQuality.HJ then
                    frameImg = "ui/gold_d.png"
                elseif magicQualityId == StaticMagicQuality.XJ then
                    frameImg = "ui/gold_c.png"
                elseif magicQualityId == StaticMagicQuality.DJ then
                    frameImg = "ui/gold_b.png"
                elseif magicQualityId == StaticMagicQuality.TJ then
                    frameImg = "ui/gold_a.png"
                end
                if magicType == dp.MagicType.treasure then
                    ui_btnTreasure:setTag(instMagicId)
                    ui_btnTreasure:loadTexture(frameImg)
                    ui_treasureIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.smallUiId)].fileName)
                    ui_treasurePanel:getChildByName("image_lv"):setVisible(true)
                    ui_treasurePanel:getChildByName("image_hint"):setVisible(isMagicHint(dp.MagicType.treasure, instMagicId))
                    ui_treasurePanel:getChildByName("image_lv"):getChildByName("text_lv"):setString(tostring(magicLv))
                    ui_treasureName:setString(dictMagicData.name)
                elseif magicType == dp.MagicType.gongfa then
                    ui_btnGongfa:setTag(instMagicId)
                    ui_btnGongfa:loadTexture(frameImg)
                    ui_gongfaIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.smallUiId)].fileName)
                    ui_gongfaPanel:getChildByName("image_lv"):setVisible(true)
                    ui_gongfaPanel:getChildByName("image_hint"):setVisible(isMagicHint(dp.MagicType.gongfa, instMagicId))
                    ui_gongfaPanel:getChildByName("image_lv"):getChildByName("text_lv"):setString(tostring(magicLv))
                    ui_gongfaName:setString(dictMagicData.name)
                end
                if _magicCount >= 2 then
                    break
                end
            end
        end
    end
    if touchEnabled then
        local function eventLogic(_instEquipId, _equipTypeId, isMagic)
            if _instEquipId > 0 then
                if isMagic then
                    UIGongfaInfo.setInstMagicId(_instEquipId)
                    UIManager.pushScene("ui_gongfa_info")
                else
                    local instEquipData = net.InstPlayerEquip[tostring(_instEquipId)]
                    local dictEquipId = instEquipData.int["4"]
                    -- 装备字典ID		
                    local dictEquipData = DictEquipment[tostring(dictEquipId)]
                    -- 装备字典表
                    local suitEquipData = utils.getEquipSuit(tostring(dictEquipId))

                    if dictEquipData.equipQualityId >= 3 and suitEquipData then
                        UIEquipmentNew.setEquipInstId(_instEquipId)
                        UIManager.pushScene("ui_equipment_new")
                    else
                        UIEquipmentInfo.setEquipInstId(_instEquipId)
                        UIManager.pushScene("ui_equipment_info")
                    end
                end
            else
                local isErrorDialog = true
                if isMagic then
                    if net.InstPlayerMagic then
                        for key, obj in pairs(net.InstPlayerMagic) do
                            if obj.int["8"] == 0 and _equipTypeId == obj.int["4"] and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then
                                isErrorDialog = false
                                break
                            end
                        end
                    end
                else
                    if net.InstPlayerEquip then
                        for key, obj in pairs(net.InstPlayerEquip) do
                            if obj.int["6"] == 0 and _equipTypeId == obj.int["3"] then
                                isErrorDialog = false
                                break
                            end
                        end
                    end
                end
                if isErrorDialog then
                    if isMagic then
                        if _equipTypeId == dp.MagicType.treasure then
                            UIManager.showToast(Lang.ui_lineup7)
                        elseif _equipTypeId == dp.MagicType.gongfa then
                            UIManager.showToast(Lang.ui_lineup8)
                        end
                    else
                        UIManager.showToast(Lang.ui_lineup9 .. DictEquipType[tostring(_equipTypeId)].name .. "！")
                    end
                else
                    if isMagic then
                        local sendData = {
                            header = StaticMsgRule.putOn,
                            msgdata =
                            {
                                int =
                                {
                                    instPlayerMagicId = 0,
                                    instPlayerCardId = instCardId,
                                    type = _equipTypeId,
                                }
                            }
                        }
                        if _equipTypeId == dp.MagicType.treasure then
                            UIBagGongFaList.setOperateType(UIBagGongFaList.OperateType.fabaoEquip, sendData)
                        elseif _equipTypeId == dp.MagicType.gongfa then
                            UIBagGongFaList.setOperateType(UIBagGongFaList.OperateType.gongfaEquip, sendData)
                        end
                        UIManager.pushScene("ui_bag_gongfa_list")
                    else
                        UIBagEquipmentSell.setEquipType(_equipTypeId)
                        UIBagEquipmentSell.setInstCardId(instCardId)
                        UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.Add)
                        UIManager.pushScene("ui_bag_equipment_sell")
                    end
                end
            end
        end
        local function btnEquipEvent(sender, eventType)
            if eventType == ccui.TouchEventType.moved then
                local movePos = sender:getTouchMovePosition()
                local beganPos = sender:getTouchBeganPosition()
                UILineup.touchMoveDir = cc.pSub(movePos, beganPos)
            elseif eventType == ccui.TouchEventType.canceled then
                if UILineup.touchMoveDir then
                    local instEquipId = sender:getTag()
                    if math.abs(UILineup.touchMoveDir.y) > math.abs(UILineup.touchMoveDir.x) then
                        if instEquipId > 0 then
                            if sender == ui_btnGongfa or sender == ui_btnTreasure then
                                local instMagicId = instEquipId
                                local instMagicData = net.InstPlayerMagic[tostring(instMagicId)]
                                local instCardId = instMagicData.int["8"]
                                local magicType = instMagicData.int["4"]

                                if UILineup.touchMoveDir.y > 0 then
                                    local sendData = {
                                        header = StaticMsgRule.putOn,
                                        msgdata =
                                        {
                                            int =
                                            {
                                                instPlayerMagicId = 0,
                                                instPlayerCardId = instCardId,
                                                type = magicType,
                                            }
                                        }
                                    }
                                    if magicType == dp.MagicType.treasure then
                                        UIBagGongFaList.setOperateType(UIBagGongFaList.OperateType.fabaoEquip, sendData)
                                    elseif magicType == dp.MagicType.gongfa then
                                        UIBagGongFaList.setOperateType(UIBagGongFaList.OperateType.gongfaEquip, sendData)
                                    end
                                    UIManager.pushScene("ui_bag_gongfa_list")
                                else
                                    UIGongfaIntensify.setInstMagicId(instMagicData.int["1"])
                                    UIManager.pushScene("ui_gongfa_intensify")
                                end
                                return
                            end

                            local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
                            local equipCardInstId = instEquipData.int["6"]
                            local equipTypeId = instEquipData.int["3"]
                            if UILineup.touchMoveDir.y > 0 then
                                UIBagEquipmentSell.setEquipType(equipTypeId)
                                UIBagEquipmentSell.setInstCardId(equipCardInstId)
                                UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.Change)
                                UIManager.pushScene("ui_bag_equipment_sell")
                            else
                                local function refreshInfo()
                                    if _tempAttributes then
                                        local _tempAtts = { }
                                        local attributes = utils.getCardAttribute(equipCardInstId)
                                        _tempAtts[1] = math.floor(attributes[StaticFightProp.blood]) - math.floor(_tempAttributes[StaticFightProp.blood])
                                        _tempAtts[2] = math.floor(attributes[StaticFightProp.wAttack]) - math.floor(_tempAttributes[StaticFightProp.wAttack])
                                        _tempAtts[3] = math.floor(attributes[StaticFightProp.wDefense]) - math.floor(_tempAttributes[StaticFightProp.wDefense])
                                        _tempAtts[4] = math.floor(attributes[StaticFightProp.fAttack]) - math.floor(_tempAttributes[StaticFightProp.fAttack])
                                        _tempAtts[5] = math.floor(attributes[StaticFightProp.fDefense]) - math.floor(_tempAttributes[StaticFightProp.fDefense])
                                        _tempValueCount = 1
                                        UILineup.getPropNum(1, ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"), _tempAtts)
                                    end
                                    UILineup.setCardProp(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
                                    if ui_sectorView then
                                        ui_sectorView:setTouchEnabled(true)
                                    end
                                end

                                function netSendData()
                                    local sendData = {
                                        header = StaticMsgRule.quickStrengthen,
                                        msgdata =
                                        {
                                            int =
                                            {
                                                instPlayerEquipId = instEquipId
                                            }
                                        }
                                    }
                                    netSendPackage(sendData, refreshInfo, refreshInfo, true)
                                end
                                AudioEngine.playEffect("sound/strengthen.mp3")
                                UILineup.Widget:removeChildByName("action")
                                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, sender:getPositionX() - UIManager.screenSize.width / 2, sender:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData, nil, nil, 0.3, false)
                            end
                        end
                    elseif UILineup.touchMoveDir.x > 0 then
                        if sender == ui_btnWeapon then
                            local ui_equips = { ui_btnWeapon, ui_btnCorselet, ui_btnHelm, ui_btnNecklace, ui_btnTreasure, ui_btnGongfa }
                            local equipTypes = { StaticEquip_Type.equip, StaticEquip_Type.outerwear, StaticEquip_Type.pants, StaticEquip_Type.necklace, dp.MagicType.treasure, dp.MagicType.gongfa }

                            local function checkEquip(i)
                                if i > #equipTypes then return end

                                local instEquipId = ui_equips[i]:getTag()
                                local equipType = equipTypes[i]

                                if instEquipId > 0 then
                                    checkEquip(i + 1)
                                else
                                    if ui_equips[i] == ui_btnGongfa or ui_equips[i] == ui_btnTreasure then
                                        local magic
                                        if net.InstPlayerMagic then
                                            for key, obj in pairs(net.InstPlayerMagic) do
                                                if obj.int["8"] == 0 and equipType == obj.int["4"] and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then
                                                    if not magic or DictMagic[tostring(magic.int["3"])].grade < DictMagic[tostring(obj.int["3"])].grade then
                                                        magic = obj
                                                    end
                                                end
                                            end
                                        end
                                        if not magic then
                                            UIManager.showToast(string.format(Lang.ui_lineup10, equipType == dp.MagicType.treasure and Lang.ui_lineup11 or Lang.ui_lineup12))
                                        else
                                            local sendData = {
                                                header = StaticMsgRule.putOn,
                                                msgdata =
                                                {
                                                    int =
                                                    {
                                                        instPlayerMagicId = magic.int["1"],
                                                        instPlayerCardId = instCardId,
                                                        type = equipType,
                                                    }
                                                }
                                            }
                                            netSendPackage(sendData, function(pack)
                                                AudioEngine.playEffect("sound/putOn.mp3")
                                                UILineup.setup()
                                                UIGuidePeople.isGuide(nil, UIBagGongFaList)
                                                checkEquip(i + 1)
                                            end )
                                        end
                                        return
                                    end

                                    local equip = nil
                                    if net.InstPlayerEquip then
                                        for key, obj in pairs(net.InstPlayerEquip) do
                                            if obj.int["6"] == 0 and equipType == obj.int["3"] then
                                                if not equip or DictEquipment[tostring(equip.int["4"])].qualityLevel < DictEquipment[tostring(obj.int["4"])].qualityLevel then
                                                    equip = obj
                                                end
                                            end
                                        end
                                    end
                                    if not equip then
                                        UIManager.showToast(Lang.ui_lineup13 .. DictEquipType[tostring(equipType)].name .. "！")
                                        checkEquip(i + 1)
                                    else
                                        local sendData = {
                                            header = StaticMsgRule.addEquipment,
                                            msgdata =
                                            {
                                                int =
                                                {
                                                    instPlayerEquipId = equip.int["1"],
                                                    instPlayerCardId = instCardId,
                                                    equipTypeId = equipType,
                                                    operate = UIBagEquipmentSell.OperateType.Add
                                                }
                                            }
                                        }
                                        netSendPackage(sendData, function(pack)
                                            AudioEngine.playEffect("sound/putOn.mp3")
                                            UILineup.setup()
                                            checkEquip(i + 1)
                                        end )
                                    end
                                end
                            end

                            checkEquip(1)
                        end
                    end
                end
                UILineup.touchMoveDir = nil
            elseif eventType == ccui.TouchEventType.ended then
                UILineup.touchMoveDir = nil
                if sender == ui_btnWeapon then
                    -- 武器
                    eventLogic(ui_btnWeapon:getTag(), StaticEquip_Type.equip)
                elseif sender == ui_btnCorselet then
                    -- 护甲
                    eventLogic(ui_btnCorselet:getTag(), StaticEquip_Type.outerwear)
                elseif sender == ui_btnHelm then
                    -- 头盔
                    eventLogic(ui_btnHelm:getTag(), StaticEquip_Type.pants)
                elseif sender == ui_btnNecklace then
                    -- 饰品
                    eventLogic(ui_btnNecklace:getTag(), StaticEquip_Type.necklace)
                elseif sender == ui_btnTreasure then
                    -- 法宝
                    eventLogic(ui_btnTreasure:getTag(), dp.MagicType.treasure, true)
                elseif sender == ui_btnGongfa then
                    -- 功法
                    eventLogic(ui_btnGongfa:getTag(), dp.MagicType.gongfa, true)
                end
            end
        end
        ui_btnWeapon:addTouchEventListener(btnEquipEvent)
        ui_btnCorselet:addTouchEventListener(btnEquipEvent)
        ui_btnHelm:addTouchEventListener(btnEquipEvent)
        ui_btnNecklace:addTouchEventListener(btnEquipEvent)
        ui_btnTreasure:addTouchEventListener(btnEquipEvent)
        ui_btnGongfa:addTouchEventListener(btnEquipEvent)
        if UIGuidePeople.guideStep == guideInfo["20B10"].step then
            if ui_btnTreasure:getTag() == 0 then
                UIGuidePeople.isGuide(ui_btnTreasure, UILineup)
            end
        else
            if ui_btnWeapon:getTag() == 0 or ui_btnWeapon:getTag() > 0 then
                UIGuidePeople.isGuide(ui_btnWeapon, UILineup)
            end
        end

    end
    ui_btnWeapon:setTouchEnabled(touchEnabled)
    ui_btnCorselet:setTouchEnabled(touchEnabled)
    ui_btnHelm:setTouchEnabled(touchEnabled)
    ui_btnNecklace:setTouchEnabled(touchEnabled)
    ui_btnTreasure:setTouchEnabled(touchEnabled)
    ui_btnGongfa:setTouchEnabled(touchEnabled)

end

function UILineup.setCardProp(_instFormationId)
    local ui_cardName = ui_bgPanel:getChildByName("text_name")
    -- 卡牌名称
    local ui_bench = ui_bgPanel:getChildByName("image_bu")
    -- ‘补’
    --- ///-----> 卡牌属性栏
    local ui_cardLevel = ui_bgPanel:getChildByName("text_lv")
    -- 卡牌等级
    local ui_cardBlood = ui_bgPanel:getChildByName("text_blood")
    -- 卡牌血量
    local ui_gasAttack = ui_bgPanel:getChildByName("text_attack_gas")
    -- 物攻
    local ui_gasDefense = ui_bgPanel:getChildByName("text_defense_gas")
    -- 物防
    local ui_soulAttack = ui_bgPanel:getChildByName("text_defense_soul")
    -- 法攻
    local ui_soulDefense = ui_bgPanel:getChildByName("text_life")
    -- 法防
    --- ///-----> 卡牌阵营栏
    -- local ui_campLabel = ui_propPanel:getChildByName("image_camp") --阵营标签
    --- //------> 卡牌称号
    local ui_cardTitleBg = ui_bgPanel:getChildByName("image_title")
    -- 卡牌称号背景
    local ui_cardTitle = ui_bgPanel:getChildByName("text_title")
    -- 卡牌称号
    --- ///-----> 卡牌标签栏
    local ui_cardLabel1 = ui_bgPanel:getChildByName("text_label2")
    -- 职业标签
    local ui_cardLabel2 = ui_bgPanel:getChildByName("text_label1")
    -- 类型标签
    -- local ui_cardLabel3 = ui_propPanel:getChildByName("image_label3") --描述标签
    -- ///------> 异火栏
    local ui_firePanel = ui_bgPanel:getChildByName("image_di_fire")
    --- ///-----> 缘分栏
    local ui_lucks = { }
    -- 缘分
    for i = 1, 6 do
        ui_lucks[i] = ui_bgPanel:getChildByName("text_luck" .. i)
        ui_lucks[i]:setTextColor(cc.c4b(51, 25, 4, 255))
        ui_lucks[i]:setString("")
        ui_lucks[i]:setTouchEnabled(false)
    end
    local ui_luckPanel = ui_bgPanel:getChildByName("panel_luck")
    --- ///-----> 技能栏
    -- local ui_skillNames = {} --技能名称
    -- for i = 1, 3 do
    -- 	ui_skillNames[i] = ui_propPanel:getChildByName("text_skill" .. i)
    -- 	ui_skillNames[i]:setTextColor(cc.c4b(51, 25, 4, 255))
    -- 	ui_skillNames[i]:setString("")
    -- 	ui_skillNames[i]:setTouchEnabled(false)
    -- end
    --- ///-----> 小伙伴
    local ui_friend = ui_bgPanel:getChildByName("image_friend")
    -- 小伙伴

    if _instFormationId and _instFormationId > 0 then
        ui_friend:setVisible(false)
        ui_cardName:setVisible(true)
        ui_bench:setVisible(true)
        -- ui_campLabel:setVisible(true)
        ui_cardTitleBg:setVisible(true)
        ui_cardTitle:setVisible(true)
        ui_cardLabel1:setVisible(true)
        ui_cardLabel2:setVisible(true)
        -- ui_cardLabel3:setVisible(true)
        ui_firePanel:setVisible(true)
        ui_luckPanel:setTouchEnabled(true)
        local obj = nil

        obj = net.InstPlayerFormation[tostring(_instFormationId)]

        local instCardId = obj.int["3"]
        -- 卡牌实例ID
        local type = obj.int["4"]
        -- 阵型类型 1:主力,2:替补
        local dictCardId = obj.int["6"]
        -- 卡牌字典ID
        local instCardData = net.InstPlayerCard[tostring(instCardId)]
        -- 卡牌实例数据
        local dictCardData = DictCard[tostring(dictCardId)]
        -- 卡牌字典数据
        local qualityId = instCardData.int["4"]
        -- 品阶ID
        local starLevelId = instCardData.int["5"]
        -- 星级ID
        local titleDetailId = instCardData.int["6"]
        -- 具体称号ID
        local level = instCardData.int["9"]
        -- 等级
        local isAwake = instCardData.int["18"]
        -- 是否已觉醒 0-未觉醒 1-觉醒

        ui_cardName:setString((isAwake == 1 and Lang.ui_lineup14 or "") .. dictCardData.name)
        ui_cardName:setTextColor(utils.getQualityColor(qualityId))
        if type == 2 then
            ui_bench:setVisible(true)
        else
            ui_bench:setVisible(false)
        end
        ui_cardLevel:setString(Lang.ui_lineup15 .. level)
        local attributes = utils.getCardAttribute(instCardId)
        _tempAttributes = utils.getCardAttribute(instCardId)
        ui_cardBlood:setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：" .. math.floor(attributes[StaticFightProp.blood]))
        ui_gasAttack:setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：" .. math.floor(attributes[StaticFightProp.wAttack]))
        ui_gasDefense:setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：" .. math.floor(attributes[StaticFightProp.wDefense]))
        ui_soulAttack:setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：" .. math.floor(attributes[StaticFightProp.fAttack]))
        ui_soulDefense:setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：" .. math.floor(attributes[StaticFightProp.fDefense]))
        -- ui_campLabel:getChildByName("text_label1"):setString(dictCardData.camp)
        local dictTitleDetailData = DictTitleDetail[tostring(titleDetailId)]
        ui_cardTitleBg:loadTexture(utils.getTitleQualityImage(DictTitle[tostring(dictTitleDetailData.titleId)]))
        ui_cardTitle:setString(dictTitleDetailData.description)
        ui_cardTitle:enableOutline(cc.c4b(85, 52, 19, 255), 2)
        ui_cardLabel1:setString(DictCardType[tostring(dictCardData.cardTypeId)].name)
        ui_cardLabel2:setString(DictFightType[tostring(dictCardData.fightTypeId)].name)
        -- if string.len(dictCardData.nickname) > 0 then
        -- 	ui_cardLabel3:getChildByName("text_label3"):setString(dictCardData.nickname)
        -- 	ui_cardLabel3:setVisible(true)
        -- else
        -- 	ui_cardLabel3:setVisible(false)
        -- end
        if UILineup.friendState == 1 then
            ui_firePanel:setVisible(false)
        else
            local _equipFireInstData = utils.getEquipFireInstData(instCardId)
            for _i, _obj in pairs(dp.FireEquipGrid) do
                local ui_fireIcon = ui_firePanel:getChildByName("image_fire" .. _i)
                local ui_fireState = ui_firePanel:getChildByName("image_kuang_fire" .. _i):getChildByName("image_state")
                ui_fireState:setVisible(false)
                ui_fireIcon:setTouchEnabled(false)
                local _gridState = 0
                -- 0.上锁, 1.开启
                if qualityId >= _obj.qualityId then
                    if qualityId == _obj.qualityId then
                        if starLevelId >= _obj.starLevelId then
                            _gridState = 1
                        end
                    else
                        _gridState = 1
                    end
                end
                if _gridState == 0 then
                    ui_fireIcon:loadTexture("ui/mg_suo.png")
                elseif _gridState == 1 then
                    ui_fireIcon:loadTexture("ui/frame_tianjia.png")
                    ui_fireIcon:setTouchEnabled(true)
                end
                local InstPlayerYFire = _equipFireInstData[_i]
                if InstPlayerYFire then
                    local _dictYFireData = DictYFire[tostring(InstPlayerYFire.int["3"])]
                    ui_fireIcon:loadTexture("image/fireImage/" .. DictUI[tostring(_dictYFireData.smallUiId)].fileName)
                    local _fireState = utils.getEquipFireState(InstPlayerYFire.int["1"])
                    if _fireState == 1 then
                        ui_fireState:loadTexture("ui/fire_wang.png")
                    elseif _fireState == 2 then
                        ui_fireState:loadTexture("ui/fire_bao.png")
                    end
                    ui_fireState:setVisible(true)
                    ui_fireIcon:setTouchEnabled(true)
                end
                ui_fireIcon:addTouchEventListener( function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if InstPlayerYFire then
                            local _showIndex = 1
                            local fireData = { }
                            for _keyYF, _objYF in pairs(DictYFire) do
                                fireData[#fireData + 1] = _objYF
                            end
                            utils.quickSort(fireData, function(obj1, obj2) if obj1.rank < obj2.rank then return true end end)
                            for _keyYF, _objYF in pairs(fireData) do
                                if _objYF.id == InstPlayerYFire.int["3"] then
                                    _showIndex = _keyYF
                                    break
                                end
                            end
                            fireData = nil
                            UIFire.show( { showIndex = _showIndex })
                        else
                            UIFire.show()
                        end
                    end
                end )
            end
        end

        if isHintSoul(_instFormationId) then
            utils.addImageHint(true, btn_soul, 100, 20, 20, 100)
        else
            utils.addImageHint(false, btn_soul, 100, 20, 20, 100)
        end

        setCardEquipInfo(true, _instFormationId, instCardId)

        local cardLucks = { }
        for key, obj in pairs(DictCardLuck) do
            if obj.cardId == dictCardId then
                cardLucks[#cardLucks + 1] = obj
            end
        end
        utils.quickSort(cardLucks, function(obj1, obj2) if obj1.id > obj2.id then return end return false end)
        --[[
		local function onTouchLuckLabel(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				-- UILineupDialog.showDialog(cardLucks)
			end
		end
		]]
        for key, obj in pairs(cardLucks) do
            ui_lucks[key]:setString(obj.name)
            if UILineup.friendState == 1 then
                if utils.isCardLuck(obj, _instFormationId) then
                    ui_lucks[key]:setTextColor(cc.c4b(0, 68, 255, 255))
                    obj.color = cc.c3b(0, 68, 255)
                else
                    ui_lucks[key]:setTextColor(cc.c4b(51, 25, 4, 255))
                    obj.color = nil
                end
            else
                if utils.isCardLuck(obj, _instFormationId) then
                    ui_lucks[key]:setTextColor(cc.c4b(0, 68, 255, 255))
                    obj.color = cc.c3b(0, 68, 255)
                else
                    ui_lucks[key]:setTextColor(cc.c4b(51, 25, 4, 255))
                    obj.color = nil
                end
            end
            -- ui_lucks[key]:setTouchEnabled(true)
            -- ui_lucks[key]:addTouchEventListener(onTouchLuckLabel)
        end
        ui_luckPanel:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UILineupDialog.show(cardLucks)
            end
        end )
        if #cardLucks == 0 then
            for kye, obj in pairs(ui_lucks) do
                obj:setString(Lang.ui_lineup16)
            end
            ui_luckPanel:setTouchEnabled(false)
        end
        --[[
		local skillData = {SkillManager[dictCardData.skillOne], SkillManager[dictCardData.skillTwo], SkillManager[dictCardData.skillThree]}
		local skillOpenLv = {tonumber(StaticQuality.white), tonumber(StaticQuality.blue), tonumber(StaticQuality.purple)}
		local function onTouchSkillLabel(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				UILineupDialog.showDialog(skillData)
			end
		end
		for key, obj in pairs(ui_skillNames) do
			if skillData[key] then
				obj:setString(skillData[key].name)
				if qualityId >= skillOpenLv[key] then
					obj:setTextColor(cc.c4b(0, 128, 0, 255))
				end
				obj:setTouchEnabled(true)
				obj:addTouchEventListener(onTouchSkillLabel)
			end
		end
		--]]
        btn_soul:setVisible(true)
        ui_bgPanel:getChildByName("btn_qixia"):setVisible(true)
        ui_bgPanel:getChildByName("btn_wing"):setVisible(true)
        ui_bgPanel:getChildByName("btn_intensify"):setVisible(true)
        ui_bgPanel:getChildByName("btn_friend"):setVisible(true)
        ui_bgPanel:getChildByName("btn_field"):setVisible(true)
    else
        btn_soul:setVisible(false)
        ui_bgPanel:getChildByName("btn_qixia"):setVisible(false)
        ui_bgPanel:getChildByName("btn_wing"):setVisible(false)
        ui_bgPanel:getChildByName("btn_intensify"):setVisible(false)
        ui_bgPanel:getChildByName("btn_friend"):setVisible(true)
        ui_bgPanel:getChildByName("btn_field"):setVisible(false)
        setCardEquipInfo(false)
        ui_cardName:setVisible(false)
        ui_bench:setVisible(false)
        -- ui_campLabel:setVisible(false)
        ui_cardTitleBg:setVisible(false)
        ui_cardTitle:setVisible(false)
        ui_cardLabel1:setVisible(false)
        ui_cardLabel2:setVisible(false)
        -- ui_cardLabel3:setVisible(false)
        ui_firePanel:setVisible(false)
        ui_luckPanel:setTouchEnabled(false)
        ui_cardLevel:setString(Lang.ui_lineup17)
        ui_cardBlood:setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：0")
        ui_gasAttack:setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：0")
        ui_gasDefense:setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：0")
        ui_soulAttack:setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：0")
        ui_soulDefense:setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：0")
        if _instFormationId == 0 then
            ui_friend:setScale(0.1)
            ui_friend:setVisible(true)
            ui_friend:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
            ui_friend:getChildByName("label_luck_number"):setString(tostring(_activateLuckNum))
            -- ui_friend:getChildByName("label_fight_add"):setString(tostring(0))
        else
            ui_friend:setVisible(false)
        end
    end
end

function UILineup.getPropNum(_index, ui_cardIcon, _propValues)
    if _index <= 5 and _propValues[_index] > 0 then
        local _panelImg, _numImg = "ui/ui_anim2Effect10.png", "ui/ui_anim2Effect8.png"
        if _index == 1 then
            _panelImg = "ui/ui_anim2Effect10.png"
            _numImg = "ui/ui_anim2Effect8.png"
        elseif _index >= 2 and _index <= 3 then
            _panelImg = "ui/ui_anim2Effect11.png"
            _numImg = "ui/ui_anim2Effect6.png"
        else
            _panelImg = "ui/ui_anim2Effect9.png"
            _numImg = "ui/ui_anim2Effect7.png"
        end
        local panel = ccui.ImageView:create(_panelImg)
        local propImg = ccui.ImageView:create("ui/ui_anim2Effect" .. _index .. ".png")
        propImg:setAnchorPoint(1, 0.5)
        propImg:setPosition(0, panel:getContentSize().height / 2)
        panel:addChild(propImg)
        local num = ccui.TextAtlas:create()
        num:setProperty("0123456789", _numImg, 25, 36, "0")
        num:setAnchorPoint(0, 0.5)
        num:setString(tostring(_propValues[_index]))
        num:setPosition(panel:getContentSize().width, panel:getContentSize().height / 2)
        panel:addChild(num)

        -- panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 100)
        panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 200 + _tempValueCount *(panel:getContentSize().height + 5))
        _tempValueCount = _tempValueCount + 1
        ui_cardIcon:addChild(panel)
        -- _index = _index + 1
        panel:setScale(0.8)
        -- panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.3,cc.p(0, 60)), cc.ScaleTo:create(0.3, 0.9), cc.FadeTo:create(0.3, 0)), cc.CallFunc:create(function()
        panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.8, cc.p(0, 60)), cc.FadeTo:create(0.8, 0)), cc.CallFunc:create( function()
            panel:removeAllChildren()
            panel:removeFromParent()
            if _index <= 5 then
                -- 		getPropNum(_index + 1, ui_cardIcon, _propValues)
            else
                _index = 1
            end
        end )))
    end

    if _index > 5 then

    else
        UILineup.getPropNum(_index + 1, ui_cardIcon, _propValues)
    end
end

local function intensifyInfo(_instFormationId)
    local ui_btnWeapon = ui_bgPanel:getChildByName("image_weapon")
    -- 武器
    local ui_btnCorselet = ui_bgPanel:getChildByName("image_corselet")
    -- 护甲
    local ui_btnHelm = ui_bgPanel:getChildByName("image_helm")
    -- 头盔
    local ui_btnNecklace = ui_bgPanel:getChildByName("image_necklace")
    -- 饰品

    local obj = nil
--    if UILineup.friendState == 1 then
--        obj = _formation[ _instFormationId ]
--    else
        obj = net.InstPlayerFormation[tostring(_instFormationId)]
--    end
    local instCardId = obj.int["3"]
    -- 卡牌实例ID

    local _play1, _play2, _play3, _play4 = false, false, false, false
    local countIndex = 0
    local equipId = { 0, 0, 0, 0 }
    if _instFormationId and net.InstPlayerLineup then
        for key, obj in pairs(net.InstPlayerLineup) do
            if _instFormationId == obj.int["3"] then
                local equipTypeId = obj.int["4"]
                -- 装备类型Id
                local instEquipId = obj.int["5"]
                -- 装备实例Id
                local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
                -- 装备实例数据
                local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                -- 装备字典数据

                if equipTypeId == StaticEquip_Type.outerwear then
                    -- 护甲
                    _play2 = true
                    if countIndex < 2 then
                        countIndex = 2
                    end
                    equipId[2] = instEquipId
                elseif equipTypeId == StaticEquip_Type.pants then
                    -- 头盔
                    _play3 = true
                    if countIndex < 3 then
                        countIndex = 3
                    end
                    equipId[3] = instEquipId
                elseif equipTypeId == StaticEquip_Type.necklace then
                    -- 饰品
                    _play4 = true
                    if countIndex < 4 then
                        countIndex = 4
                    end
                    equipId[4] = instEquipId
                elseif equipTypeId == StaticEquip_Type.ring then
                    -- 戒指

                elseif equipTypeId == StaticEquip_Type.equip then
                    -- 武器
                    _play1 = true
                    if countIndex < 1 then
                        countIndex = 1
                    end
                    equipId[1] = instEquipId
                end
            end
        end
    end
    local _strengthIndex = 0

    local function reSetEnabled(index)
        if countIndex > index then
            return true
        end
        return false
    end

    local function refreshInfo()
        if _tempAttributes then
            local _tempAtts = { }
            local attributes = utils.getCardAttribute(instCardId)
            _tempAtts[1] = math.floor(attributes[StaticFightProp.blood]) - math.floor(_tempAttributes[StaticFightProp.blood])
            _tempAtts[2] = math.floor(attributes[StaticFightProp.wAttack]) - math.floor(_tempAttributes[StaticFightProp.wAttack])
            _tempAtts[3] = math.floor(attributes[StaticFightProp.wDefense]) - math.floor(_tempAttributes[StaticFightProp.wDefense])
            _tempAtts[4] = math.floor(attributes[StaticFightProp.fAttack]) - math.floor(_tempAttributes[StaticFightProp.fAttack])
            _tempAtts[5] = math.floor(attributes[StaticFightProp.fDefense]) - math.floor(_tempAttributes[StaticFightProp.fDefense])
            _tempValueCount = 1
            UILineup.getPropNum(1, ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"), _tempAtts)
        end
        UILineup.setCardProp(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
        if not reSetEnabled(_strengthIndex) then
            if ui_sectorView then
                ui_sectorView:setTouchEnabled(true)
            end
        end
    end

    local function netCallbackFunc3(data)
        --     if data then

        -- 	    if tonumber(data.header) == StaticMsgRule.quickStrengthen then
        -- UIManager.flushWidget(UILineup)
        refreshInfo()
        -- 		end
        --     end
    end
    function netSendData3()
        local sendData = {
            header = StaticMsgRule.quickStrengthen,
            msgdata =
            {
                int =
                {
                    instPlayerEquipId = equipId[_strengthIndex]
                }
            }
        }
        -- UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc3, netCallbackFunc3, true)
    end
    local function callBackAll3(index)

        if index <= 3 then
            if _play4 then
                _strengthIndex = 4
                -- AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnNecklace:getPositionX() - UIManager.screenSize.width / 2, ui_btnNecklace:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData3, nil, nil, 0.3, reSetEnabled(4))
                return true
            end
        end
    end


    local function netCallbackFunc2(data)
        --     if data then
        -- 	    if tonumber(data.header) == StaticMsgRule.quickStrengthen then
        -- UIManager.flushWidget(UILineup)
        refreshInfo()
        callBackAll3(_strengthIndex)
        -- 		end
        --     end
    end
    function netSendData2()
        local sendData = {
            header = StaticMsgRule.quickStrengthen,
            msgdata =
            {
                int =
                {
                    instPlayerEquipId = equipId[_strengthIndex]
                }
            }
        }
        -- UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc2, netCallbackFunc2, true)
    end
    local function callBackAll2(index)

        if index <= 2 then
            if _play3 then
                _strengthIndex = 3
                --   AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnHelm:getPositionX() - UIManager.screenSize.width / 2, ui_btnHelm:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData2, nil, nil, 0.3, reSetEnabled(3))
                return true
            end
        end

        if index <= 3 then
            if _play4 then
                _strengthIndex = 4
                --  AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnNecklace:getPositionX() - UIManager.screenSize.width / 2, ui_btnNecklace:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData2, nil, nil, 0.3, reSetEnabled(4))
                return true
            end
        end
    end


    local function netCallbackFunc1(data)
        --    if data then
        -- 	    if tonumber(data.header) == StaticMsgRule.quickStrengthen then
        -- UIManager.flushWidget(UILineup)
        refreshInfo()
        callBackAll2(_strengthIndex)
        -- 		end
        --    end
    end
    function netSendData1()

        local sendData = {
            header = StaticMsgRule.quickStrengthen,
            msgdata =
            {
                int =
                {
                    instPlayerEquipId = equipId[_strengthIndex]
                }
            }
        }
        -- UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc1, netCallbackFunc1, true)
    end
    local function callBackAll1(index)
        -- cclog( "-----------------------> " .. index )
        if index <= 1 then
            if _play2 then
                _strengthIndex = 2
                --  AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnCorselet:getPositionX() - UIManager.screenSize.width / 2, ui_btnCorselet:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData1, nil, nil, 0.3, reSetEnabled(2))
                return true
            end
        end

        if index <= 2 then
            if _play3 then
                _strengthIndex = 3
                --  AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnHelm:getPositionX() - UIManager.screenSize.width / 2, ui_btnHelm:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData1, nil, nil, 0.3, reSetEnabled(3))
                return true
            end
        end

        if index <= 3 then
            if _play4 then
                _strengthIndex = 4
                -- AudioEngine.playEffect("sound/strengthen.mp3")	
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnNecklace:getPositionX() - UIManager.screenSize.width / 2, ui_btnNecklace:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData1, nil, nil, 0.3, reSetEnabled(4))
                return true
            end
        end
    end



    local function netCallbackFunc(data)
        --  if data then
        --    if tonumber(data.header) == StaticMsgRule.quickStrengthen then
        -- UIManager.flushWidget(UILineup)
        refreshInfo()
        callBackAll1(_strengthIndex)
        -- 	end
        --  end
    end
    function netSendData()
        local sendData = {
            header = StaticMsgRule.quickStrengthen,
            msgdata =
            {
                int =
                {
                    instPlayerEquipId = equipId[_strengthIndex]
                }
            }
        }
        -- 	UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc, netCallbackFunc, true)
    end
    local function callBackAll(index)
        if index <= 0 then
            if _play1 then
                _strengthIndex = 1
                AudioEngine.playEffect("sound/strengthen.mp3")
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnWeapon:getPositionX() - UIManager.screenSize.width / 2, ui_btnWeapon:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData, nil, nil, 0.3, reSetEnabled(1))
                return true
            end
        end
        if index <= 1 then
            if _play2 then
                _strengthIndex = 2
                AudioEngine.playEffect("sound/strengthen.mp3")
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnCorselet:getPositionX() - UIManager.screenSize.width / 2, ui_btnCorselet:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData, nil, nil, 0.3, reSetEnabled(2))
                return true
            end
        end

        if index <= 2 then
            if _play3 then
                _strengthIndex = 3
                AudioEngine.playEffect("sound/strengthen.mp3")
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnHelm:getPositionX() - UIManager.screenSize.width / 2, ui_btnHelm:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData, nil, nil, 0.3, reSetEnabled(3))
                return true
            end
        end

        if index <= 3 then
            if _play4 then
                _strengthIndex = 4
                AudioEngine.playEffect("sound/strengthen.mp3")
                utils.playArmature(15, "ui_anim15_2", UILineup.Widget, ui_btnNecklace:getPositionX() - UIManager.screenSize.width / 2, ui_btnNecklace:getPositionY() - UIManager.screenSize.height / 2 + 40, netSendData, nil, nil, 0.3, reSetEnabled(4))
                return true
            end
        end
    end
    callBackAll(0)

end

local guideindex = nil
local friendIndex = nil
local function setItemData(obj, iconItem, cardInfoItem, index, isFriend)
    local ui_focus = iconItem:getChildByName("image_choose")
    -- 光标图片
    local ui_cardSmallIcon = iconItem:getChildByName("image_warrior")
    -- 小头像
    local ui_bench = ui_cardSmallIcon:getChildByName("image_bu")
    -- ‘补’
    local ui_cardBg = cardInfoItem:getChildByName("image_frame_card")
    -- 卡牌背景图
    local ui_cardIcon = ui_cardBg:getChildByName("image_warrior")
    -- 卡牌大图标
    local ui_cardAptitude = ui_cardBg:getChildByName("image_zz")
    -- 卡牌资质
    local ui_cardAptitudeLabel = ui_cardAptitude:getChildByName("label_zz")
    -- 卡牌资质标签
    -- local ui_cardLevel = ccui.Helper:seekNodeByName(ui_cardBg, "label_lv") --卡牌等级
    -- local ui_cardTitle = ccui.Helper:seekNodeByName(ui_cardBg, "text_title") --卡牌称号
    local ui_starImgs = { }
    for i = 1, 5 do
        ui_starImgs[i] = ui_cardBg:getChildByName("image_star" .. i)
        ui_starImgs[i]:setVisible(false)
        ui_starImgs[i]:loadTexture("ui/jj01.png")
    end

    if index == _curShowCardIndex then
        ui_focus:setVisible(true)
    else
        ui_focus:setVisible(false)
    end
    local function iconItemEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            _curShowCardIndex = index
            setScrollViewFocus()
            ui_sectorView:scrollToIndex(index)
        end
    end
    iconItem:addTouchEventListener(iconItemEvent)

    if obj then
        ui_cardBg:setTag(obj.int["1"])
        local instCardId = obj.int["3"]
        -- 卡牌实例ID
        local type = obj.int["4"]
        -- 阵型类型 1:主力,2:替补
        local dictCardId = obj.int["6"]
        -- 卡牌字典ID
        if net.InstPlayerWing then
            for key, value in pairs(net.InstPlayerWing) do
                if value.int["6"] == instCardId then
                    local actionName = DictWing[tostring(value.int["3"])].actionName
                    if actionName and actionName ~= "" then
                        utils.addArmature(ui_cardBg, 54 + value.int["5"], actionName, ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2, 0)
                    else
                        utils.addArmature(ui_cardBg, 54 + value.int["5"], "0" .. value.int["5"] .. DictWing[tostring(value.int["3"])].sname, ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2, 0)
                    end
                    break
                end
            end
        end
        local instCardData = net.InstPlayerCard[tostring(instCardId)]
        -- 卡牌实例数据
        local dictCardData = DictCard[tostring(dictCardId)]
        -- 卡牌字典数据
        local qualityId = instCardData.int["4"]
        -- 品阶ID
        local starLevelId = instCardData.int["5"]
        -- 星级ID
        -- local titleDetailId = instCardData.int["6"] --具体称号ID
        -- local level = instCardData.int["9"] --等级
        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒

        local qualityImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
        iconItem:loadTextures(qualityImage, qualityImage)
        ui_cardSmallIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
        if type == 2 then
            ui_bench:setVisible(true)
        else
            ui_bench:setVisible(false)
        end

        ui_cardAptitude:setVisible(true)
        ui_cardAptitudeLabel:setString(tostring(dictCardData.nickname))

        ui_cardBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))

        ui_cardIcon:setVisible(false)
        local cardAnim, cardAnimName
        if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
            cardAnim, cardAnimName = ActionManager.getCardAnimation(isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles,(index == _curShowCardIndex) and 1 or 2)
        else
            cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName,(index == _curShowCardIndex) and 1 or 2)
        end
        cardAnim:setPosition(cc.p(ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2))
        ui_cardBg:addChild(cardAnim)
        _cardAnimations[obj.int["1"]] = { cardAnim, cardAnimName }

        local _startIndex, _endIndex, _curIndex = 0, -1, 0
        local maxStarLevel = DictQuality[tostring(qualityId)].maxStarLevel
        if maxStarLevel == 1 then
            _startIndex = 3
            _endIndex = 3
        elseif maxStarLevel == 2 then
            _startIndex = 3
            _endIndex = 4
        elseif maxStarLevel == 3 then
            _startIndex = 2
            _endIndex = 4
        elseif maxStarLevel == 4 then
            _startIndex = 2
            _endIndex = 5
        elseif maxStarLevel == 5 then
            _startIndex = 1
            _endIndex = 5
        end
        for i = _startIndex, _endIndex do
            _curIndex = _curIndex + 1
            if DictStarLevel[tostring(starLevelId)].level >= _curIndex then
                ui_starImgs[i]:loadTexture("ui/jj02.png")
            end
            ui_starImgs[i]:setVisible(true)
        end
        --[[
		for i = 1, 5 do
			local ui_starImg = ccui.Helper:seekNodeByName(ui_cardBg, "image_star" .. i)
			if DictStarLevel[tostring(starLevelId)].level >= i then
				ui_starImg:setVisible(true)
			else
				ui_starImg:setVisible(false)
			end
		end
		--]]

        local cardLucks = { }
        for key, objDcl in pairs(DictCardLuck) do
            if objDcl.cardId == dictCardId then
                cardLucks[#cardLucks + 1] = objDcl
            end
        end
        for key, dictLuck in pairs(cardLucks) do
            if UILineup.friendState == 1 then
                if utils.isCardLuckNew(dictLuck, obj.int["3"]) then
                    _activateLuckNum = _activateLuckNum + 1
                end
            else
                if utils.isCardLuck(dictLuck, obj.int["1"]) then
                    _activateLuckNum = _activateLuckNum + 1
                end
            end
        end

    else
        ui_bench:setVisible(false)
        iconItem:loadTextures("ui/card_small_white.png", "ui/card_small_white.png")
        -- local ui_baseInfo = ui_cardBg:getChildByName("image_base_info")
        -- ui_baseInfo:setVisible(false)
        ui_cardIcon:setVisible(false)
        ui_cardAptitude:setVisible(false)
        if isFriend then
            ui_cardBg:setTag(0)
            ui_cardSmallIcon:loadTexture("ui/xhb.png")
            ui_cardBg:loadTexture("ui/pai_friend.png")
            ui_cardIcon:setVisible(false)
            if not friendIndex then
                friendIndex = index
            end
        else
            utils.addImageHint(true, ui_cardSmallIcon, index, 0, 0)
            ui_cardBg:setTag(-1)
            ui_cardSmallIcon:loadTexture("ui/frame_tianjia.png")
            ui_cardBg:loadTexture("ui/pai_bei.png")
            ui_cardIcon:loadTexture("ui/pai_beizi.png")
            ui_cardIcon:setPosition(cc.p(ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 4))
            if not guideindex then
                guideindex = index
            end
        end
    end
end

local function setCardAnimation(sender, _animIndex)
    if sender and _animIndex and _cardAnimations and _cardAnimations[_animIndex] then
        local ui_cardAnim = _cardAnimations[_animIndex][1]
        if sender:getRotation() >= -5 and sender:getRotation() <= 5 then
            ui_cardAnim:getAnimation():play(_cardAnimations[_animIndex][2] .. "_1")
        else
            ui_cardAnim:getAnimation():play(_cardAnimations[_animIndex][2] .. "_2")
        end
    end
end
local function changeBtnFriend( btn )
    if UILineup.friendState == 0 then
        UILineup.friendState = 1
        btn:loadTextureNormal( "ui/lineup_up.png" )
        btn:loadTexturePressed( "ui/lineup_up.png" )
    elseif UILineup.friendState == 1 then
        UILineup.friendState = 0
        btn:loadTextureNormal( "ui/lineup_friend.png" )
        btn:loadTexturePressed( "ui/lineup_friend.png" )
    end
end
function UILineup.init()
    ui_topPanel = ccui.Helper:seekNodeByName(UILineup.Widget, "base_cardchoose")
    local btn_embattle = ui_topPanel:getChildByName("btn_embattle")
    -- 布阵按钮
    ui_scrollView = ccui.Helper:seekNodeByName(ui_topPanel, "view_warrior")
    ui_iconItem = ui_scrollView:getChildByName("btn_base_warrior"):clone()
    ui_bgPanel = ccui.Helper:seekNodeByName(UILineup.Widget, "basemap")
    ui_cardTouchPanel = ui_bgPanel:getChildByName("panel_choose")
    ui_cardTouchPanel:setVisible(true)
    ui_cardTouchPanel:setTouchEnabled(false)
    ui_cardInfoItem = ui_cardTouchPanel:getChildByName("image_base_card"):clone()
    local btn_recommend = ui_bgPanel:getChildByName("btn_recommend")
    -- 推荐组合按钮
    local btn_intensify = ui_bgPanel:getChildByName("btn_intensify")
    -- 强化大师
    btn_soul = ui_bgPanel:getChildByName("btn_soul")
    -- 斗魂
    local btn_wing = ui_bgPanel:getChildByName("btn_wing")
    -- 翅膀

    local btn_friend = ui_bgPanel:getChildByName("btn_friend") --伙伴培养
    local btn_field = ui_bgPanel:getChildByName("btn_field") --结界


    local btn_qixia = ui_bgPanel:getChildByName("btn_qixia") --器匣

    -- TODO  功能未开启，暂时隐藏
    local btn_friend = ui_bgPanel:getChildByName("btn_friend") --伙伴培养
    btn_friend:setVisible(false)
    local btn_field = ui_bgPanel:getChildByName("btn_field") --结界
    btn_field:setVisible(false)

    local function embattleEvent(sender, eventType)
        if eventType == ccui.TouchEventType.canceled then
            if sender == btn_intensify and ui_sectorView then
                ui_sectorView:setTouchEnabled(true)
            end
        elseif eventType == ccui.TouchEventType.began then
            if sender == btn_intensify and ui_sectorView then
                ui_sectorView:setTouchEnabled(false)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if sender == btn_embattle then
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UILineupEmbattle.setUIParam(true)
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UILineupEmbattleOld.setUIParam(true)
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
            elseif sender == btn_recommend then
                UIManager.pushScene("ui_lineup_recommend")
            elseif sender == btn_intensify then
                --                if ui_sectorView then
                --                     ui_sectorView:setTouchEnabled( true )
                --                end
                if net.InstPlayer.int["4"] < 15 then
                    UIManager.showToast(Lang.ui_lineup18)
                else
                    intensifyInfo(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
                end
            elseif sender == btn_wing then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level then
                    UIManager.showToast(Lang.ui_lineup19 .. DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level .. Lang.ui_lineup20)
                else
                    UIWingInfo.setData(_curShowCardIndex - 1)
                    UIManager.pushScene("ui_wing_info")
                end
            elseif sender == btn_soul then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level
                local lootOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == openLv then
                            lootOpen = true
                            break;
                        end
                    end
                end
                if lootOpen then
                    UISoulInstall.setType(UISoulInstall.type.LINEUP, _curShowCardIndex - 1)
                    UIManager.pushScene("ui_soul_install")
                else
                    UIManager.showToast(Lang.ui_lineup21 .. DictBarrier[tostring(openLv)].name)
                    return
                end

            elseif sender == btn_friend then
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    changeBtnFriend( btn_friend )
                    UILineup.free()
                    _curShowCardIndex = 1
                    UILineup.setup()
                else
                    UIManager.showToast( Lang.ui_lineup22 .. DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level .. Lang.ui_lineup23 )
                end
            elseif sender == btn_field then
                if net.InstPlayer.int["4"] >= DictEnchantment[ "1" ].needLevel then
                    UIManager.pushScene( "ui_field" )
                else
                    UIManager.showToast( Lang.ui_lineup24 .. DictEnchantment[ "1" ].needLevel .. Lang.ui_lineup25 )
                end
            elseif sender == btn_qixia then
--                ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag()
                UILineupQixia.show({curShowCardIndex = _curShowCardIndex})

            end
        end

    end
    btn_embattle:setPressedActionEnabled(true)
    btn_embattle:addTouchEventListener(embattleEvent)
    btn_recommend:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_recommend:setPressedActionEnabled(true)
    btn_recommend:addTouchEventListener(embattleEvent)
    btn_intensify:setPressedActionEnabled(true)
    btn_intensify:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_intensify:addTouchEventListener(embattleEvent)
    btn_soul:setPressedActionEnabled(true)
    btn_soul:addTouchEventListener(embattleEvent)
    btn_wing:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_wing:setPressedActionEnabled(true)
    btn_wing:addTouchEventListener(embattleEvent)

    btn_friend:setPressedActionEnabled( true )
    btn_friend:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_friend:addTouchEventListener(embattleEvent)
    btn_field:setPressedActionEnabled( true )
    btn_field:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_field:addTouchEventListener(embattleEvent)

    btn_qixia:setPressedActionEnabled(true)
    btn_qixia:setLocalZOrder(ui_scrollView:getLocalZOrder() + 1)
    btn_qixia:addTouchEventListener(embattleEvent)

    --[[
	local glView = cc.Director:getInstance():getOpenGLView()
	local size = glView:getFrameSize()
	if (size.width == 640 and size.height == 1136) then
		ui_topPanel:setPosition(cc.p(ui_topPanel:getPositionX(), size.height - UINotice.Widget:getContentSize().height - ui_topPanel:getContentSize().height / 2))
		ui_bgPanel:setScale(1)
		ui_bgPanel:setPosition(cc.p(size.width / 2, ui_bgPanel:getPositionY() + ui_bgPanel:getPositionY() * 0.1))
		ui_cardTouchPanel:setContentSize(cc.size(ui_cardTouchPanel:getContentSize().width, ui_topPanel:getWorldPosition().y - ui_cardTouchPanel:getWorldPosition().y))
		ui_cardInfoItem:setPosition(cc.p(ui_cardInfoItem:getPositionX(), ui_cardInfoItem:getPositionY() + 30))
	end
	]]
end
local function getFriendInfo()
    local _DictPartnerLuck = {}
    for key, obj in pairs(DictPartnerLuckPos) do
        _DictPartnerLuck[#_DictPartnerLuck + 1] = obj
    end
    utils.quickSort(_DictPartnerLuck, function(obj1, obj2) if obj1.id > obj2.id then return true end return false end)
    local playerLevel = net.InstPlayer.int["4"] --玩家等级
    local practiceValue = UIAllianceSkill.getPracticeValue() --联盟修炼值
    local friendInfo = {}
	for i = 1 , (#_DictPartnerLuck) do
        local _dictPartnerLuckData = _DictPartnerLuck[i]
        if _dictPartnerLuckData then
            local _isOpen = false
            if _dictPartnerLuckData.isAuto == 0 then --非自动
                if net.InstPlayerPartnerLuckPos then
                    for _k, _o in pairs(net.InstPlayerPartnerLuckPos) do
                        if _dictPartnerLuckData.id == _o.int["3"] then
                            _isOpen = true
                            break
                        end
                    end
                end
            else
                if _dictPartnerLuckData.type == 1 then
                    if playerLevel >= _dictPartnerLuckData.value then
                        _isOpen = true
                    end
                elseif _dictPartnerLuckData.type == 2 then
                    if practiceValue >= _dictPartnerLuckData.value then
                        _isOpen = true
                    end
                end
            end
            if _isOpen then
                friendInfo[ #friendInfo + 1 ] = i
            else
                if _dictPartnerLuckData.type == 1 then
                            
                end
            end
        else
            
        end
	end
    return friendInfo
end
function UILineup.setup()
    if net.InstPlayerFightSoul then
        _fightSoulData = { }
        for key, value in pairs(net.InstPlayerFightSoul) do
            if value.int["4"] ~= 5 and DictFightSoul[tostring(value.int["3"])].isExpFightSoul == 0 and value.int["7"] == 0 then
                table.insert(_fightSoulData, value)
            end
        end
    end
    local btn_intensify = ui_bgPanel:getChildByName("btn_intensify")
    -- 强化大师
    if net.InstPlayer.int["4"] < 15 then
        btn_intensify:setVisible(false)
    else
        btn_intensify:setVisible(true)
    end
    if ui_iconItem:getReferenceCount() == 1 then
        ui_iconItem:retain()
    end
    ui_scrollView:removeAllChildren()
    if ui_cardInfoItem:getReferenceCount() == 1 then
        ui_cardInfoItem:retain()
    end
    ui_cardTouchPanel:removeAllChildren()
    _activateLuckNum = 0
    local innerWidth, space = 0, 15
    if UILineup.friendState == 1 then
        if net.InstPlayerFormation then
            local dictData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
            local countItem = dictData.inTeamCard + dictData.benchCard
            if _curShowCardIndex > MAX_FRIEND_COUNT then
                _curShowCardIndex = MAX_FRIEND_COUNT
            end
            _formation = {}
	        if net.InstPlayerFormation then
		        for key, obj in pairs(net.InstPlayerFormation) do
                    if obj.int["4"] == 3 then
                        table.insert( _formation , obj )
             --           _formation[tostring(obj.int["1"])] = obj
                         
                    end
		        end
	        end
            local function compareFunc(obj1, obj2)
                if obj1.int["5"] > obj2.int["5"] then
                    return true
                end
                return false
            end
            utils.quickSort(_formation, compareFunc)

            _cardAnimations = { }
            ui_sectorView = cc.SectorView:create(ui_cardTouchPanel, _curShowCardIndex)
            if UIGuidePeople.guideFlag then
                ui_sectorView:setTouchEnabled(false)
            end
            _friendPosition = getFriendInfo() --获取小伙伴个数
            local function isIn( position )--位置上是否有了卡牌
                for key , value in pairs( _formation ) do
                    if  value.int["10"] == position then
                        return key
                    end
                end
                return nil
            end
            for i = 1 , MAX_FRIEND_COUNT do
                local isCard = isIn( i )
                print( i , " " , isCard )
                if isCard then 
                    local obj = _formation[ isCard ]   
                    local iconItem = ui_iconItem:clone()
                    ui_scrollView:addChild(iconItem)
                    innerWidth = innerWidth + iconItem:getContentSize().width + space

                    local cardInfoItem = ui_cardInfoItem:clone()
                    ui_sectorView:addChild(cardInfoItem)             
                    setItemData(obj, iconItem, cardInfoItem, i)
                 else
                    local iconItem = ui_iconItem:clone()
                    ui_scrollView:addChild(iconItem)
                    innerWidth = innerWidth + iconItem:getContentSize().width + space

                    local cardInfoItem = ui_cardInfoItem:clone()
                    ui_sectorView:addChild(cardInfoItem) 
                    setItemData(nil, iconItem, cardInfoItem, i)
                 end
            end
--            for i = 1 , ( #_friendPosition ) do
--                local isCard = isIn( _friendPosition[ i ] )
--                print( i , " " , isCard )
--                if isCard then 
--                    local obj = _formation[ isCard ]   
--                    local iconItem = ui_iconItem:clone()
--                    ui_scrollView:addChild(iconItem)
--                    innerWidth = innerWidth + iconItem:getContentSize().width + space

--                    local cardInfoItem = ui_cardInfoItem:clone()
--                    ui_sectorView:addChild(cardInfoItem)             
--                    setItemData(obj, iconItem, cardInfoItem, i)
--                 else
--                    local iconItem = ui_iconItem:clone()
--                    ui_scrollView:addChild(iconItem)
--                    innerWidth = innerWidth + iconItem:getContentSize().width + space

--                    local cardInfoItem = ui_cardInfoItem:clone()
--                    ui_sectorView:addChild(cardInfoItem) 
--                    setItemData(nil, iconItem, cardInfoItem, i)
--                 end
--            end

            UILineup.reset = nil
            local function resetIndex()
                if _curShowCardIndex ~= 1 then
                    UILineup.reset = true
                    _curShowCardIndex = 1
                    setScrollViewFocus()
                    ui_sectorView:scrollToIndex(_curShowCardIndex)
                end
            end
            UIGuidePeople.isGuide(resetIndex, UILineup)
            UILineup.setCardProp(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
            local function sectorViewEvent(sender, eventType)
                local instFormationId = sender:getChildByName("image_frame_card"):getTag()
                _curShowCardIndex = ui_sectorView:getCurItemIndex()
                if eventType == ccui.SectorViewEventType.onTurning then

                    setCardAnimation(sender, instFormationId)
                    setScrollViewFocus()
                elseif eventType == ccui.SectorViewEventType.onUplift then
                    AudioEngine.playEffect("sound/lineup.mp3")
                    setCardAnimation(sender, instFormationId)
                    UILineup.setCardProp(instFormationId)
                    local param = { }
                    param[1] = 3
                    param[2] = sender
                    UIGuidePeople.isGuide(param, UILineup)
                elseif eventType == ccui.SectorViewEventType.onClick then
                    if UILineup.Widget:isEnabled() or UIGuidePeople.guideFlag then
                        if instFormationId > 0 then
                            if UILineup.friendState == 1 then
                                UICardInfo.setUIParam(UILineup, { net.InstPlayerFormation[tostring(instFormationId)].int["3"] })
                            elseif UILineup.friendState == 0 then
                                UICardInfo.setUIParam(UILineup, instFormationId)
                            end
                            UIManager.pushScene("ui_card_info")
                        elseif instFormationId == 0 then
                            UIManager.pushScene("ui_friend")
                        else
                            if UILineup.friendState == 1 then
                                UICardChange.setUIParam(UICardChange.OperateType.Friend2 , _curShowCardIndex )
                            elseif UILineup.friendState == 0 then
                                UICardChange.setUIParam(UICardChange.OperateType.Lineup)
                            end
                            UIManager.pushScene("ui_card_change")
                        end
                    end
                end
            end
            ui_sectorView:addEventListener(sectorViewEvent)
            local param = { }
            param[1] = 2
            param[2] = sectorViewEvent
            UIGuidePeople.isGuide(param, UILineup)
            local lockItem = ui_iconItem:clone()
            lockItem:getChildByName("image_choose"):setVisible(false)
            lockItem:loadTextures("ui/card_small_white.png", "ui/card_small_white.png")
            local ui_cardSmallIcon = lockItem:getChildByName("image_warrior")
            -- 小头像
            ui_cardSmallIcon:loadTexture("ui/mg_suo.png")
            local ui_bench = ui_cardSmallIcon:getChildByName("image_bu")
            -- ‘补’
            ui_bench:setVisible(false)
            ui_scrollView:addChild(lockItem)
            local function lockEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local tempDictLevelProp = { }
                    for key, obj in pairs(DictLevelProp) do
                        tempDictLevelProp[obj.id] = obj
                    end
                    utils.quickSort(tempDictLevelProp, function(obj1, obj2) if obj1.id > obj2.id then return true end return false end)
                    for key, obj in pairs(tempDictLevelProp) do
                        if obj.inTeamCard + obj.benchCard > countItem then
                            UIManager.showToast(obj.id .. Lang.ui_lineup26)
                            break
                        end
                    end
                end
            end
            lockItem:addTouchEventListener(lockEvent)
            innerWidth = innerWidth + lockItem:getContentSize().width + space
        end
    else
        if net.InstPlayerFormation then
            local dictData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
            local countItem = dictData.inTeamCard + dictData.benchCard
            if _curShowCardIndex > countItem then
                _curShowCardIndex = countItem
            end
            local formation1, formation2 = { }, { }
            for key, obj in pairs(net.InstPlayerFormation) do
                if obj.int["4"] == 1 then
                    -- 主力
                    formation1[#formation1 + 1] = obj
                elseif obj.int["4"] == 2 then
                    -- 替补
                    formation2[#formation2 + 1] = obj
                end
            end
            local function compareFunc(obj1, obj2)
                if obj1.int["1"] > obj2.int["1"] then
                    return true
                end
                return false
            end
        
            utils.quickSort(formation1, compareFunc)
            utils.quickSort(formation2, compareFunc)
            _cardAnimations = { }

            ui_sectorView = cc.SectorView:create(ui_cardTouchPanel, _curShowCardIndex)
            if UIGuidePeople.guideFlag then
                ui_sectorView:setTouchEnabled(false)
            end
            for i = 1, countItem + 1 do
                local obj = nil
                if formation1[i] then
                    obj = formation1[i]
                elseif formation2[i - #formation1] then
                    obj = formation2[i - #formation1]
                end

                local iconItem = ui_iconItem:clone()
                ui_scrollView:addChild(iconItem)
                innerWidth = innerWidth + iconItem:getContentSize().width + space

                local cardInfoItem = ui_cardInfoItem:clone()
                ui_sectorView:addChild(cardInfoItem)
                if i > countItem then
                    setItemData(obj, iconItem, cardInfoItem, i, true)
                else
                    setItemData(obj, iconItem, cardInfoItem, i)
                end
            end
            UILineup.reset = nil
            local function resetIndex()
                if UIGuidePeople.guideStep == guideInfo["18B1"].step then
                    for i = 1, countItem do
                        local obj = nil
                        if formation1[i] then
                            obj = formation1[i]
                        elseif formation2[i - #formation1] then
                            obj = formation2[i - #formation1]
                        end
                        local flag = false
                        if net.InstPlayerLineup then
                            for _key, _obj in pairs(net.InstPlayerLineup) do
                                if obj and obj.int["1"] == _obj.int["3"] and _obj.int["4"] == StaticEquip_Type.equip then
                                    flag = true
                                end
                            end
                        end
                        if flag == false then
                            _curShowCardIndex = i
                            break
                        end
                    end
                    setScrollViewFocus()
                    ui_sectorView:scrollToIndex(_curShowCardIndex)
                else
                    if _curShowCardIndex ~= 1 then
                        UILineup.reset = true
                        _curShowCardIndex = 1
                        setScrollViewFocus()
                        ui_sectorView:scrollToIndex(_curShowCardIndex)
                    end
                end
            end
            UIGuidePeople.isGuide(resetIndex, UILineup)
            UILineup.setCardProp(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
            local function sectorViewEvent(sender, eventType)
                local instFormationId = sender:getChildByName("image_frame_card"):getTag()
                _curShowCardIndex = ui_sectorView:getCurItemIndex()
                if eventType == ccui.SectorViewEventType.onTurning then

                    setCardAnimation(sender, instFormationId)
                    setScrollViewFocus()
                elseif eventType == ccui.SectorViewEventType.onUplift then
                    AudioEngine.playEffect("sound/lineup.mp3")
                    setCardAnimation(sender, instFormationId)
                    UILineup.setCardProp(instFormationId)
                    local param = { }
                    param[1] = 3
                    param[2] = sender
                    UIGuidePeople.isGuide(param, UILineup)
                elseif eventType == ccui.SectorViewEventType.onClick then
                    if UILineup.Widget:isEnabled() or UIGuidePeople.guideFlag then
                        if instFormationId > 0 then
                            UICardInfo.setUIParam(UILineup, instFormationId)
                            UIManager.pushScene("ui_card_info")
                        elseif instFormationId == 0 then
                            UIManager.pushScene("ui_friend")
                        else
                            UICardChange.setUIParam(UICardChange.OperateType.Lineup)
                            UIManager.pushScene("ui_card_change")
                        end
                    end
                end
            end
            ui_sectorView:addEventListener(sectorViewEvent)
            local param = { }
            param[1] = 2
            param[2] = sectorViewEvent
            UIGuidePeople.isGuide(param, UILineup)
            local lockItem = ui_iconItem:clone()
            lockItem:getChildByName("image_choose"):setVisible(false)
            lockItem:loadTextures("ui/card_small_white.png", "ui/card_small_white.png")
            local ui_cardSmallIcon = lockItem:getChildByName("image_warrior")
            -- 小头像
            ui_cardSmallIcon:loadTexture("ui/mg_suo.png")
            local ui_bench = ui_cardSmallIcon:getChildByName("image_bu")
            -- ‘补’
            ui_bench:setVisible(false)
            ui_scrollView:addChild(lockItem)
            local function lockEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local tempDictLevelProp = { }
                    for key, obj in pairs(DictLevelProp) do
                        tempDictLevelProp[obj.id] = obj
                    end
                    utils.quickSort(tempDictLevelProp, function(obj1, obj2) if obj1.id > obj2.id then return true end return false end)
                    for key, obj in pairs(tempDictLevelProp) do
                        if obj.inTeamCard + obj.benchCard > countItem then
                            UIManager.showToast(obj.id .. Lang.ui_lineup27)
                            break
                        end
                    end
                end
            end
            lockItem:addTouchEventListener(lockEvent)
            innerWidth = innerWidth + lockItem:getContentSize().width + space
        end
    end
    if innerWidth < ui_scrollView:getContentSize().width then
        innerWidth = ui_scrollView:getContentSize().width
    end
    ui_scrollView:setInnerContainerSize(cc.size(innerWidth, ui_scrollView:getContentSize().height))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if prevChild then
            childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
        else
            childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
        end
        prevChild = childs[i]
    end
    if (UIGuidePeople.guideStep or UIGuidePeople.levelStep) and(guideindex or friendIndex) then
        if guideindex then
            if UIGuidePeople.levelStep == guideInfo["10_6"].step then
                _curShowCardIndex = guideindex
            end
            setScrollViewFocus(true)
            local param = { }
            param[1] = 4
            param[2] = childs[guideindex]
            UIGuidePeople.isGuide(param, UILineup)
        end
        if UIGuidePeople.levelStep and friendIndex and net.InstPlayer.int["4"] == 26 then
            --- 引导小伙伴 上方图标
            _curShowCardIndex = friendIndex
            setScrollViewFocus(true)
            local _param = { }
            _param[1] = 7
            _param[2] = childs[friendIndex]
            UIGuidePeople.isGuide(_param, UILineup)
        end
    end
    UILineup.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        setScrollViewFocus(true)
    end )))
    UIMenu.showLineupHint()
    local param = { }
    param[1] = 5
    param[2] = ui_sectorView:getItem(cc.SectorView:getCurItemIndex())

    local btn_friend = ui_bgPanel:getChildByName("btn_friend") --伙伴培养
    if UILineup.friendState == 1 then
        btn_friend:loadTextureNormal( "ui/lineup_up.png" )
        btn_friend:loadTexturePressed( "ui/lineup_up.png" )
    elseif UILineup.friendState == 0 then
        btn_friend:loadTextureNormal( "ui/lineup_friend.png" )
        btn_friend:loadTexturePressed( "ui/lineup_friend.png" )
    end

    UIGuidePeople.isGuide(param, UILineup)
end

function UILineup.free()
    guideindex = nil
    friendIndex = nil
    ui_sectorView:setTouchEnabled( false )
    ui_sectorView = nil
    if _cardAnimations then
        for key, obj in pairs(_cardAnimations) do
            obj[1]:getAnimation():stop()
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/card_action/" .. obj[2] .. "/" .. obj[2] .. ".ExportJson")
            ccs.ArmatureDataManager:getInstance():removeArmatureData(obj[1]:getAnimation():getCurrentMovementID())
        end
    end
    _tempAttributes = nil
    _tempValueCount = nil
    _fightSoulData = nil
    UILineup.touchMoveDir = nil
    _formation = nil
    _friendPosition = nil
 --   _curShowCardIndex = 1
end

function UILineup.setSectorViewEnabled(enable)
    if UILineup.Widget and UILineup.Widget:getParent() and ui_sectorView then
        ui_sectorView:setTouchEnabled(enable)
    end
end

function UILineup.isHint(_equipTypeId, _instId)
    return isHint(_equipTypeId, _instId)
end

function UILineup.isMagicHint(_magicType, _instId)
    return isMagicHint(_magicType, _instId)
end

function UILineup.checkImageHint()
    if net.InstPlayerFormation then
        local dictData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
        local countItem = dictData.inTeamCard + dictData.benchCard

        local formation1, formation2 = { }, { }
        for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 1 then
                -- 主力
                formation1[#formation1 + 1] = obj
            elseif obj.int["4"] == 2 then
                -- 替补
                formation2[#formation2 + 1] = obj
            end
        end
        if countItem > #formation1 + #formation2 then
            return true
        end
    end
    return false
end

function UILineup.toWingInfo()
    -- UIWingInfo.setData( _curShowCardIndex - 1 )
    UIManager.pushScene("ui_wing_info")
end
