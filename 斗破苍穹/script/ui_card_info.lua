require"Lang"
UICardInfo = { }

local ui_pageView = nil
local ui_pageViewItem = nil

local instPlayerFormationId = nil
local friendFormation = nil
local _curInstPlayerCardId = nil
local _uiItem = nil
local _param = nil
local _dictCardId = nil
local _curPageViewIndex = -1
local pvCardData = nil
local netOrPvp = nil
local utilsOrPvp = nil

function UICardInfo.getCardJumpMap()
    if not UICardInfo.cardJumpMap then
        local map = { }
        for key, obj in pairs(DictCardJump) do
            map[obj.cardId] = obj
        end
        UICardInfo.cardJumpMap = map
    end

    return UICardInfo.cardJumpMap
end

local function cleanPageView(_isRelease)
    if _isRelease then
        if ui_pageViewItem and ui_pageViewItem:getReferenceCount() >= 1 then
            ui_pageViewItem:release()
            ui_pageViewItem = nil
        end
    else
        if ui_pageViewItem:getReferenceCount() == 1 then
            ui_pageViewItem:retain()
        end
    end
    if ui_pageView then
        ui_pageView:removeAllPages()
    end
    if ui_pageView then
        ui_pageView:removeAllChildren()
    end
    _curPageViewIndex = -1
end

local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.cardOutPartner then
        UIFriend.setup()
        UIManager.popScene()
        UILineup.setup()
    elseif code == StaticMsgRule.lockCard then
        UICardInfo.setup()
        UIManager.flushWidget(UIBagCard)
    end
end

local function getCardAttribute(_curCardLv, qualityId, starLevelId, dictCardData)
    local attributes = nil
    if _curInstPlayerCardId then
        attributes = utilsOrPvp.getCardAttribute(_curInstPlayerCardId)
    else
        attributes = { }
        attributes[StaticFightProp.wAttack] = formula.getCardGasAttack(_curCardLv, qualityId, starLevelId, dictCardData)
        attributes[StaticFightProp.wDefense] = formula.getCardGasDefense(_curCardLv, qualityId, starLevelId, dictCardData)
        attributes[StaticFightProp.fAttack] = formula.getCardSoulAttack(_curCardLv, qualityId, starLevelId, dictCardData)
        attributes[StaticFightProp.fDefense] = formula.getCardSoulDefense(_curCardLv, qualityId, starLevelId, dictCardData)
        attributes[StaticFightProp.blood] = formula.getCardBlood(_curCardLv, qualityId, starLevelId, dictCardData)
        attributes[StaticFightProp.dodge] = formula.getCardDodge(_curCardLv, dictCardData)
        attributes[StaticFightProp.hit] = formula.getCardHit(_curCardLv, dictCardData)
        attributes[StaticFightProp.crit] = formula.getCardCrit(_curCardLv, dictCardData)
        attributes[StaticFightProp.flex] = formula.getCardTenacity(_curCardLv, dictCardData)
    end
    return attributes
end

local function setBottomBtn(enabled)
    local btn_change = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_change")
    local btn_upgrade = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_upgrade")
    local btn_advance = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_advance")
    local btn_medicine = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_medicine")
    local btn_realm = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_realm")
    local btn_xiulian = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_xiulian")
    local friendBtnChange = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_change_bottom")
    -- 小伙伴更换按钮
    local friendBtnDown = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_down_bottom")
    -- 小伙伴卸下按钮
    local image_di_card = ccui.Helper:seekNodeByName(UICardInfo.Widget, "image_di_card")
    local btn_l = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_l")
    -- image_di_card:getChildByName("btn_l")
    local btn_r = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_r")
    -- image_di_card:getChildByName("btn_r")
    btn_change:setTouchEnabled(enabled)
    btn_change:setVisible(enabled)
    btn_medicine:setTouchEnabled(enabled)
    btn_medicine:setVisible(enabled)
    btn_upgrade:setTouchEnabled(enabled)
    btn_upgrade:setVisible(enabled)
    btn_advance:setTouchEnabled(enabled)
    btn_advance:setVisible(enabled)
    btn_realm:setTouchEnabled(enabled)
    btn_realm:setVisible(enabled)
    btn_xiulian:setTouchEnabled(enabled)
    btn_xiulian:setVisible(enabled)
    btn_l:setTouchEnabled(enabled)
    btn_l:setVisible(enabled)
    btn_r:setTouchEnabled(enabled)
    btn_r:setVisible(enabled)
    if _dictCardId == nil then
        if _uiItem == UIFriend or _uiItem == UIBagCard then
            enabled = true
            if _uiItem == UIFriend then
                friendBtnChange:setTitleText(Lang.ui_card_info1)
                friendBtnChange:setPositionX( 320 )
                friendBtnDown:setTitleText(Lang.ui_card_info2)
                friendBtnDown:setVisible( enabled and false )
            else
                friendBtnChange:setTitleText(Lang.ui_card_info3)
                friendBtnChange:setPositionX( 165 )
                friendBtnDown:setTitleText(Lang.ui_card_info4)
                friendBtnDown:setVisible( enabled and true )
            end
        elseif _uiItem == UILineup or _uiItem == UIArenaCheck then
            enabled = false
        end
    end
    friendBtnChange:setTouchEnabled(enabled)
    friendBtnChange:setVisible(enabled)
    friendBtnDown:setTouchEnabled(enabled)
   -- friendBtnDown:setVisible(enabled)
end

local function pageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
        _curPageViewIndex = sender:getCurPageIndex()
        local _cardData = nil
        if pvCardData then
            local id = sender:getPage(_curPageViewIndex):getTag()
            for key, obj in pairs(pvCardData) do
                if id == tonumber(obj.dictId) then
                    _cardData = obj
                    break
                end
            end
        end
        if _cardData then
            local image_basecolour = ccui.Helper:seekNodeByName(UICardInfo.Widget, "image_basecolour")
            local ui_expBar = image_basecolour:getChildByName("image_exp"):getChildByName("bar_exp")
            local ui_expBarLabel = ui_expBar:getChildByName("text_exp")
            local ui_cardInfoPanel = image_basecolour:getChildByName("view")
            local ui_titlePanel = ui_cardInfoPanel:getChildByName("image_base_title")
            local ui_title = ccui.Helper:seekNodeByName(ui_titlePanel, "text_title")
            local ui_qualityPanel = ui_cardInfoPanel:getChildByName("image_base_quality")
            local ui_quality = ccui.Helper:seekNodeByName(ui_qualityPanel, "text_title")
            local ui_propPanel = ui_cardInfoPanel:getChildByName("image_property")
            local ui_skillPanel = ui_cardInfoPanel:getChildByName("image_skill")
            local ui_skillAwakenPanel = ui_cardInfoPanel:getChildByName("image_skill_glod")
            local ui_skillRedPanel = ui_cardInfoPanel:getChildByName("image_skill_red")
            local ui_luckPanel = ui_cardInfoPanel:getChildByName("image_luck")
            local ui_descPanel = ui_cardInfoPanel:getChildByName("image_info")
            local ui_desc = ui_descPanel:getChildByName("text_info")
            local image_wing = ccui.Helper:seekNodeByName(UICardInfo.Widget, "image_wing")

            ui_skillAwakenPanel:setVisible(false)
            ui_skillRedPanel:setVisible(false)
            ui_title:enableOutline(cc.c4b(85, 52, 19, 255), 2)
            ui_quality:enableOutline(cc.c4b(85, 52, 19, 255), 2)

            local dictCardData = DictCard[tostring(_cardData.dictId)]

            local btn_info = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_info")
            btn_info:setVisible(UICardInfo.getCardJumpMap()[tonumber(_cardData.dictId)] ~= nil)
            if btn_info:isVisible() and not btn_info:getChildByName("particle1") then
                utils.addFrameParticle(btn_info, true)
            end

            local _curCardLv = 1
            local _qualityId = dictCardData.qualityId
            local _starLevelId = dictCardData.starLevelId

            local cardLucks = { }
            for k, objDcl in pairs(DictCardLuck) do
                if objDcl.cardId == dictCardData.id then
                    cardLucks[#cardLucks + 1] = objDcl
                end
            end
            utils.quickSort(cardLucks, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
            local cardWingLucks = nil
            for key, value in pairs(DictWingLuck) do
                if value.cardId == dictCardData.id then
                    cardWingLucks = value
                    break
                end
            end
            for key = 1, 6 do
                ui_luckPanel:getChildByName("text_name_luck" .. key):setString("")
                ui_luckPanel:getChildByName("text_luck" .. key):setString("")
            end
            for key = 1, 3 do
                image_wing:getChildByName("text_name_wing" .. key):setString("")
                image_wing:getChildByName("text_wing" .. key):setString("")
            end
            local skillOpenLv = { tonumber(StaticQuality.green), tonumber(StaticQuality.blue), tonumber(StaticQuality.purple) }
            if _cardData.instId and _cardData.instId > 0 then
                local instCardData = netOrPvp.InstPlayerCard[tostring(_cardData.instId)]
                _qualityId = instCardData.int["4"]
                _starLevelId = instCardData.int["5"]
                _curCardLv = instCardData.int["9"]
                local isTeam = instCardData.int["10"]
                local isLock = instCardData.int["15"]
                local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
                ui_expBar:setPercent(utils.getPercent(instCardData.int["8"], DictCardExp[tostring(_curCardLv)].exp))
                ui_expBarLabel:setString("EXP：" .. instCardData.int["8"] .. "/" .. DictCardExp[tostring(_curCardLv)].exp)
                local dictTitleDetailData = DictTitleDetail[tostring(instCardData.int["6"])]
                ui_title:setString(dictTitleDetailData.description)
                if isAwake == 1 then
                    local skillData = SkillManager[dictCardData.awakeSkill]
                    ui_skillAwakenPanel:getChildByName("text_name_skill_glod"):setString(skillData.name .. "：")
                    ui_skillAwakenPanel:getChildByName("text_skill_glod"):setString(skillData.desc())
                    ui_skillAwakenPanel:setVisible(true)
                end

                _curInstPlayerCardId = _cardData.instId
                if isTeam == 1 then
                    for key, obj in pairs(netOrPvp.InstPlayerFormation) do
                        if dictCardData.id == obj.int["6"] then
                            instPlayerFormationId = obj.int["1"]
                            break
                        end
                    end
                end

                local isFriend
                if _uiItem == UILineup or _uiItem == UIArenaCheck or _uiItem == UIFriend then
                    if _uiItem == UIFriend then
                        isFriend = true
                    end
                else
                    if isTeam == 1 then
                        isFriend = true
                        for key, obj in pairs(netOrPvp.InstPlayerFormation) do
                            if dictCardData.id == obj.int["6"] then
                                instPlayerFormationId = obj.int["1"]
                                isFriend = false
                                break
                            end
                        end
                    end
                end

                if _uiItem ~= UIFriend then
                    local friendBtnChange = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_change_bottom")
                    -- 小伙伴更换按钮
                    local friendBtnDown = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_down_bottom")
                    -- 小伙伴卸下按钮
                    if isTeam == 1 then
                        friendBtnChange:setTitleText(Lang.ui_card_info5)
                    end
                    if isLock == 0 then
                        friendBtnDown:setTitleText(Lang.ui_card_info6)
                    elseif isLock == 1 then
                        friendBtnDown:setTitleText(Lang.ui_card_info7)
                    end
                end
                local skillData = { SkillManager[dictCardData.skillOne], SkillManager[dictCardData.skillTwo], SkillManager[dictCardData.skillThree] }
                if isAwake == 1 then
                    local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                    skillData = { SkillManager[tonumber(_tempNewSkillIds[1])], SkillManager[tonumber(_tempNewSkillIds[2])], SkillManager[tonumber(_tempNewSkillIds[3])] }
                end

                if dictCardData.id == 88 then
                    ui_skillRedPanel:setVisible(true)
                    local skillData1 = (isAwake == 1) and skillData or { SkillManager[1618], SkillManager[1619], SkillManager[1620] }
                    local skillOpenLv1 = { tonumber(StaticQuality.red), tonumber(StaticQuality.red), tonumber(StaticQuality.red) }
                    for key, obj in pairs(skillData1) do
                        local ui_skillName = ui_skillRedPanel:getChildByName("text_name_skill" .. key)
                        local ui_skillDesc = ui_skillRedPanel:getChildByName("text_skill" .. key)
                        local ui_openImage = ui_skillRedPanel:getChildByName("text_skill" .. key .. "_open")
                        ui_skillName:setString(obj.name .. "：")
                        ui_skillDesc:setString(obj.desc())
                        if _qualityId >= skillOpenLv1[key] or((_qualityId == StaticQuality.white or _qualityId == StaticQuality.green) and key < #skillData1) then
                            ui_skillName:setTextColor(cc.c4b(2, 99, 2, 255))
                            ui_skillDesc:setTextColor(cc.c4b(2, 99, 2, 255))
                            if ui_openImage then
                                ui_openImage:setVisible(false)
                            end
                        elseif _qualityId == StaticQuality.white or _qualityId == StaticQuality.green then
                            ui_skillName:setString("")
                            ui_skillDesc:setString("")
                            if ui_openImage then
                                ui_openImage:setVisible(false)
                            end
                        else
                            ui_skillName:setTextColor(cc.c4b(125, 122, 121, 255))
                            ui_skillDesc:setTextColor(cc.c4b(125, 122, 121, 255))
                            if ui_openImage then
                                ui_openImage:setVisible(true)
                            end
                        end
                    end
                end

                for key, obj in pairs(skillData) do
                    local ui_skillName = ui_skillPanel:getChildByName("text_name_skill" .. key)
                    local ui_skillDesc = ui_skillPanel:getChildByName("text_skill" .. key)
                    local ui_openImage = ui_skillPanel:getChildByName("text_skill" .. key .. "_open")
                    ui_skillName:setString(obj.name .. "：")
                    ui_skillDesc:setString(obj.desc())
                    if dictCardData.id == 88 and _qualityId >= StaticQuality.red then
                        ui_skillName:setTextColor(cc.c4b(125, 122, 121, 255))
                        ui_skillDesc:setTextColor(cc.c4b(125, 122, 121, 255))
                        if ui_openImage then
                            ui_openImage:setVisible(false)
                        end
                    elseif _qualityId >= skillOpenLv[key] or((_qualityId == StaticQuality.white or _qualityId == StaticQuality.green) and key < #skillData) then
                        ui_skillName:setTextColor(cc.c4b(2, 99, 2, 255))
                        ui_skillDesc:setTextColor(cc.c4b(2, 99, 2, 255))
                        if ui_openImage then
                            ui_openImage:setVisible(false)
                        end
                    elseif _qualityId == StaticQuality.white or _qualityId == StaticQuality.green then
                        ui_skillName:setString("")
                        ui_skillDesc:setString("")
                        if ui_openImage then
                            ui_openImage:setVisible(false)
                        end
                    else
                        ui_skillName:setTextColor(cc.c4b(125, 122, 121, 255))
                        ui_skillDesc:setTextColor(cc.c4b(125, 122, 121, 255))
                        if ui_openImage then
                            ui_openImage:setVisible(true)
                        end
                    end
                end

                for key, obj in pairs(cardLucks) do
                    local ui_luckNmae = ui_luckPanel:getChildByName("text_name_luck" .. key)
                    local ui_luckDesc = ui_luckPanel:getChildByName("text_luck" .. key)
                    ui_luckNmae:setString(obj.name .. "：")
                    ui_luckDesc:setString(obj.description)
                    ui_luckNmae:setTextColor(cc.c4b(139, 69, 19, 255))
                    ui_luckDesc:setTextColor(cc.c4b(139, 69, 19, 255))
                    local isLuck
                    if isTeam == 1 then
                        if isFriend then
                            isLuck = utilsOrPvp.isCardLuck(obj, nil, true)
                        else
                            isLuck = utilsOrPvp.isCardLuck(obj, instPlayerFormationId)
                        end
                    end
                    if isLuck then
                        ui_luckNmae:setTextColor(cc.c4b(2, 99, 2, 255))
                        ui_luckDesc:setTextColor(cc.c4b(2, 99, 2, 255))
                    end
                end
                if cardWingLucks then
                    local wingLucks = utils.stringSplit(cardWingLucks.lucks, ";")
                    local wingDes = utils.stringSplit(cardWingLucks.description, "#")
                    local _wingObj = nil
                    if netOrPvp.InstPlayerWing then
                        for key, value in pairs(netOrPvp.InstPlayerWing) do
                            if value.int["6"] == _cardData.instId then
                                _wingObj = value
                                break
                            end
                        end
                    end
                    for i = 1, 3 do
                        local wingLuckName = image_wing:getChildByName("text_name_wing" .. i)
                        if i == 1 then
                            wingLuckName:setString(Lang.ui_card_info8 .. wingDes[i])
                        elseif i == 2 then
                            wingLuckName:setString(Lang.ui_card_info9 .. wingDes[i])
                        elseif i == 3 then
                            wingLuckName:setString(Lang.ui_card_info10 .. wingDes[i])
                        end
                        local str = ""
                        if i == 3 then
                            str = Lang.ui_card_info11 .. DictWing[tostring(wingLucks[3])].description .. Lang.ui_card_info12
                        else
                            -- cclog( "wingLucks[ i ]  :" .. wingLucks[ i ] )
                            if tonumber(wingLucks[i]) == 1 then
                                str = Lang.ui_card_info13
                            elseif tonumber(wingLucks[i]) == 2 then
                                str = Lang.ui_card_info14
                            elseif tonumber(wingLucks[i]) == 3 then
                                str = Lang.ui_card_info15
                            end
                        end
                        local wingCondition = image_wing:getChildByName("text_wing" .. i)
                        wingCondition:setString(str)
                        wingLuckName:setTextColor(cc.c4b(139, 69, 19, 255))
                        wingCondition:setVisible(true)
                        if _wingObj then
                            if i < 3 and tonumber(wingLucks[i]) <= _wingObj.int["5"] then
                                wingLuckName:setTextColor(cc.c4b(2, 99, 2, 255))
                                wingCondition:setVisible(false)
                            elseif i == 3 and(tonumber(wingLucks[i]) == _wingObj.int["3"] or _wingObj.int["3"] >= 5) then
                                wingLuckName:setTextColor(cc.c4b(2, 99, 2, 255))
                                wingCondition:setVisible(false)
                            end
                        end
                    end
                end
            else
                ui_expBar:setPercent(0)
                ui_expBarLabel:setString("EXP：0/" .. DictCardExp[tostring(_curCardLv)].exp)
                ui_title:setString(DictTitleDetail[tostring(dictCardData.titleDetailId)].description)
                local skillData = { SkillManager[dictCardData.skillOne], SkillManager[dictCardData.skillTwo], SkillManager[dictCardData.skillThree] }

                if dictCardData.id == 88 then
                    ui_skillRedPanel:setVisible(true)
                    local skillData1 = { SkillManager[1618], SkillManager[1619], SkillManager[1620] }
                    local skillOpenLv1 = { tonumber(StaticQuality.red), tonumber(StaticQuality.red), tonumber(StaticQuality.red) }
                    for key, obj in pairs(skillData1) do
                        local ui_skillName = ui_skillRedPanel:getChildByName("text_name_skill" .. key)
                        local ui_skillDesc = ui_skillRedPanel:getChildByName("text_skill" .. key)
                        local ui_openImage = ui_skillRedPanel:getChildByName("text_skill" .. key .. "_open")
                        ui_skillName:setString(obj.name .. "：")
                        ui_skillDesc:setString(obj.desc())
                        if _qualityId >= skillOpenLv1[key] or((_qualityId == StaticQuality.white or _qualityId == StaticQuality.green) and key < #skillData1) then
                            ui_skillName:setTextColor(cc.c4b(2, 99, 2, 255))
                            ui_skillDesc:setTextColor(cc.c4b(2, 99, 2, 255))
                            if ui_openImage then
                                ui_openImage:setVisible(false)
                            end
                        elseif _qualityId == StaticQuality.white or _qualityId == StaticQuality.green then
                            ui_skillName:setString("")
                            ui_skillDesc:setString("")
                            if ui_openImage then
                                ui_openImage:setVisible(false)
                            end
                        else
                            ui_skillName:setTextColor(cc.c4b(125, 122, 121, 255))
                            ui_skillDesc:setTextColor(cc.c4b(125, 122, 121, 255))
                            if ui_openImage then
                                ui_openImage:setVisible(true)
                            end
                        end
                    end
                end

                for key, obj in pairs(skillData) do
                    local ui_skillName = ui_skillPanel:getChildByName("text_name_skill" .. key)
                    local ui_skillDesc = ui_skillPanel:getChildByName("text_skill" .. key)
                    local ui_openImage = ui_skillPanel:getChildByName("text_skill" .. key .. "_open")
                    ui_skillName:setString(obj.name .. "：")
                    ui_skillDesc:setString(obj.desc())
                    if key < #skillData or _qualityId >= skillOpenLv[key] then
                        ui_skillName:setTextColor(cc.c4b(2, 99, 2, 255))
                        ui_skillDesc:setTextColor(cc.c4b(2, 99, 2, 255))
                        if ui_openImage then
                            ui_openImage:setVisible(false)
                        end
                    elseif _qualityId == StaticQuality.white or _qualityId == StaticQuality.green then
                        ui_skillName:setString("")
                        ui_skillDesc:setString("")
                        if ui_openImage then
                            ui_openImage:setVisible(false)
                        end
                    else
                        ui_skillName:setTextColor(cc.c4b(125, 122, 121, 255))
                        ui_skillDesc:setTextColor(cc.c4b(125, 122, 121, 255))
                        if ui_openImage then
                            ui_openImage:setVisible(true)
                        end
                    end
                end
                for key, obj in pairs(cardLucks) do
                    local ui_luckNmae = ui_luckPanel:getChildByName("text_name_luck" .. key)
                    local ui_luckDesc = ui_luckPanel:getChildByName("text_luck" .. key)
                    ui_luckNmae:setString(obj.name .. "：")
                    ui_luckDesc:setString(obj.description)
                    ui_luckNmae:setTextColor(cc.c4b(139, 69, 19, 255))
                    ui_luckDesc:setTextColor(cc.c4b(139, 69, 19, 255))
                end
                local cardWingLucks = nil
                for key, value in pairs(DictWingLuck) do
                    if value.cardId == dictCardData.id then
                        cardWingLucks = value
                        break
                    end
                end
                if cardWingLucks then
                    local wingLucks = utils.stringSplit(cardWingLucks.lucks, ";")
                    local wingDes = utils.stringSplit(cardWingLucks.description, "#")
                    for i = 1, 3 do
                        local wingLuckName = image_wing:getChildByName("text_name_wing" .. i)
                        if i == 1 then
                            wingLuckName:setString(Lang.ui_card_info16 .. wingDes[i])
                        elseif i == 2 then
                            wingLuckName:setString(Lang.ui_card_info17 .. wingDes[i])
                        elseif i == 3 then
                            wingLuckName:setString(Lang.ui_card_info18 .. wingDes[i])
                        end
                        local str = ""
                        if i == 3 then
                            str = Lang.ui_card_info19 .. DictWing[tostring(wingLucks[3])].description .. Lang.ui_card_info20
                        else
                            -- cclog( "wingLucks[ i ]  :" .. wingLucks[ i ] )
                            if tonumber(wingLucks[i]) == 1 then
                                str = Lang.ui_card_info21
                            elseif tonumber(wingLucks[i]) == 2 then
                                str = Lang.ui_card_info22
                            elseif tonumber(wingLucks[i]) == 3 then
                                str = Lang.ui_card_info23
                            end
                        end
                        local wingCondition = image_wing:getChildByName("text_wing" .. i)
                        wingCondition:setString(str)
                        wingLuckName:setTextColor(cc.c4b(139, 69, 19, 255))
                        wingCondition:setVisible(true)
                    end
                end
            end

            ui_quality:setString(DictQuality[tostring(_qualityId)].name .. DictStarLevel[tostring(_starLevelId)].name)
            ui_propPanel:getChildByName("text_lv"):setString(Lang.ui_card_info24 .. _curCardLv)
            local attribute = getCardAttribute(_curCardLv, _qualityId, _starLevelId, dictCardData)
            ui_propPanel:getChildByName("text_property5"):setString(
            DictFightProp[tostring(StaticFightProp.blood)].name .. "：" .. math.floor(attribute[StaticFightProp.blood])
            )
            -- 生命
            ui_propPanel:getChildByName("text_property1"):setString(
            DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：" .. math.floor(attribute[StaticFightProp.wAttack])
            )
            -- 物攻
            ui_propPanel:getChildByName("text_property6"):setString(
            DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：" .. math.floor(attribute[StaticFightProp.wDefense])
            )
            -- 物防
            ui_propPanel:getChildByName("text_property2"):setString(
            DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：" .. math.floor(attribute[StaticFightProp.fAttack])
            )
            -- 法攻
            ui_propPanel:getChildByName("text_property7"):setString(
            DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：" .. math.floor(attribute[StaticFightProp.fDefense])
            )
            -- 法防
            -- for key, obj in pairs(DictFightProp) do
            -- 	ui_propPanel:getChildByName("text_property" .. key):setString(obj.name .. "：" .. math.floor(attribute[tonumber(key)]))
            -- end
            ui_desc:setString(dictCardData.description)

            local innerContainerH = 0
            innerContainerH = innerContainerH + ui_titlePanel:getContentSize().height
            innerContainerH = innerContainerH + ui_propPanel:getContentSize().height
            if ui_skillAwakenPanel:isVisible() then
                innerContainerH = innerContainerH + ui_skillAwakenPanel:getContentSize().height
                innerContainerH = innerContainerH + 30
            end
            innerContainerH = innerContainerH + ui_skillPanel:getContentSize().height
            if ui_skillRedPanel:isVisible() then
                innerContainerH = innerContainerH + ui_skillRedPanel:getContentSize().height
                innerContainerH = innerContainerH + 40
            end
            innerContainerH = innerContainerH + ui_luckPanel:getContentSize().height
            innerContainerH = innerContainerH + image_wing:getContentSize().height
            innerContainerH = innerContainerH + ui_descPanel:getContentSize().height
            innerContainerH = innerContainerH + 540
            ui_cardInfoPanel:setInnerContainerSize(cc.size(ui_cardInfoPanel:getInnerContainerSize().width, innerContainerH))
            ui_titlePanel:setPositionY(innerContainerH - 10 - ui_titlePanel:getContentSize().height / 2)
            ui_qualityPanel:setPositionY(ui_titlePanel:getPositionY())
            ui_propPanel:setPositionY(ui_titlePanel:getBottomBoundary() - ui_propPanel:getContentSize().height / 2 - 60)
            if ui_skillAwakenPanel:isVisible() then
                ui_skillAwakenPanel:setPositionY(ui_propPanel:getBottomBoundary() - ui_skillAwakenPanel:getContentSize().height / 2 - 40)
                ui_skillPanel:setPositionY(ui_skillAwakenPanel:getBottomBoundary() - ui_skillPanel:getContentSize().height / 2 - 60)
            else
                ui_skillPanel:setPositionY(ui_propPanel:getBottomBoundary() - ui_skillPanel:getContentSize().height / 2 - 70)
            end
            if ui_skillRedPanel:isVisible() then
                ui_skillRedPanel:setPositionY(ui_skillPanel:getBottomBoundary() - ui_skillRedPanel:getContentSize().height / 2 - 40)
                ui_luckPanel:setPositionY(ui_skillRedPanel:getBottomBoundary() - ui_luckPanel:getContentSize().height / 2 - 120)
            else
                ui_luckPanel:setPositionY(ui_skillPanel:getBottomBoundary() - ui_luckPanel:getContentSize().height / 2 - 120)
            end
            image_wing:setPositionY(ui_luckPanel:getBottomBoundary() - image_wing:getContentSize().height / 2 - 110)
            ui_descPanel:setPositionY(image_wing:getBottomBoundary() - ui_descPanel:getContentSize().height / 2 - 110)

            local btn_advance = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_advance")
            if _qualityId == StaticQuality.purple and DictStarLevel[tostring(_starLevelId)].level == 5 then
                btn_advance:loadTextures("ui/tunshi.png", "ui/tunshi.png")
            else
                btn_advance:loadTextures("ui/jinjie.png", "ui/jinjie.png")
            end


            local dictCardId = nil
            if _dictCardId then
                dictCardId = tonumber(_dictCardId)
            elseif _curInstPlayerCardId then
                dictCardId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
            end            
            local btn_pieces = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_pieces")
            if dictCardId and DictCard[tostring(dictCardId)].qualityId >= StaticQuality.blue and DictCard[tostring(dictCardId)].isCash == 1 then             
                btn_pieces:setVisible(true) --TODO 万能碎片暂时屏蔽
            else
                btn_pieces:setVisible(false)
            end
        end

    end
end

local function getLineupData()
    local cardData = { }
    if friendFormation then
        local playerPartner = {}
	    if net.InstPlayerFormation then
		    for key, obj in pairs(net.InstPlayerFormation) do
                if obj.int["4"] == 3 and obj.int["10"] > 0 then
                    table.insert( playerPartner , obj )
                end
		    end
	    end
        local function compareFunc(obj1, obj2)
            if obj1.int["10"] > obj2.int["10"] then
                return true
            end
            return false
        end
        utils.quickSort(playerPartner, compareFunc)
        for key, obj in pairs(playerPartner) do             
            if obj then
                if cardData[key] == nil then
                    cardData[key] = { }
                end
                cardData[key].dictId = obj.int[ "6" ]
                cardData[key].instId = obj.int[ "3" ]
                cardData[key].instFormationId = obj.int["1"]
            end
        end
    else
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
        for i = 1,(#formation1 + #formation2) do
            local obj = nil
            if formation1[i] then
                obj = formation1[i]
            elseif formation2[i - #formation1] then
                obj = formation2[i - #formation1]
            end
            if obj then
                if cardData[i] == nil then
                    cardData[i] = { }
                end
                cardData[i].dictId = obj.int["6"]
                cardData[i].instId = obj.int["3"]
                cardData[i].instFormationId = obj.int["1"]
            end
        end
    end
    return cardData
end

function UICardInfo.init()
    local btn_info = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_info")
    local btn_pieces = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_pieces")
    local btn_close = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_close")
    local btn_change = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_change")
    local btn_upgrade = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_upgrade")
    local btn_advance = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_advance")
    local btn_medicine = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_medicine")
    local btn_realm = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_realm")
    local btn_xiulian = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_xiulian")
    local friendBtnChange = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_change_bottom")
    -- 小伙伴更换按钮
    local friendBtnDown = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_down_bottom")
    -- 小伙伴卸下按钮
    local image_di_card = ccui.Helper:seekNodeByName(UICardInfo.Widget, "image_di_card")
    local btn_l = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_l")
    -- image_di_card:getChildByName("btn_l")
    local btn_r = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_r")
    -- image_di_card:getChildByName("btn_r")

    btn_close:setPressedActionEnabled(true)
    btn_pieces:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    btn_upgrade:setPressedActionEnabled(true)
    btn_advance:setPressedActionEnabled(true)
    btn_medicine:setPressedActionEnabled(true)
    btn_realm:setPressedActionEnabled(true)
    btn_xiulian:setPressedActionEnabled(true)
    friendBtnChange:setPressedActionEnabled(true)
    friendBtnDown:setPressedActionEnabled(true)
    btn_l:setPressedActionEnabled(true)
    btn_r:setPressedActionEnabled(true)

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_info then
                if _dictCardId then
                    UICardSoulInfo.dictCardId = tonumber(_dictCardId)
                elseif _curInstPlayerCardId then
                    UICardSoulInfo.dictCardId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
                end
                if UICardSoulInfo.dictCardId then
                    UIManager.pushScene("ui_card_soul_info")
                end
            elseif sender == btn_pieces then
                local dictCardId = nil
                if _dictCardId then
                    dictCardId = tonumber(_dictCardId)
                elseif _curInstPlayerCardId then
                    dictCardId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
                end
                if dictCardId then
                    UICardPieces.show({ cardId = dictCardId })
                end
            elseif sender == btn_change then
                if netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"] == 154 then
                    UIManager.showToast("新手引导期间萧炎不可下阵")
                else
                    if UILineup.friendState == 1 then
                        UICardChange.setUIParam(UICardChange.OperateType.Lineup2, instPlayerFormationId)
                    else
                        UICardChange.setUIParam(UICardChange.OperateType.Lineup, instPlayerFormationId)
                    end
                    UIManager.pushScene("ui_card_change")
                end
            elseif sender == btn_upgrade then
                UICardUpgrade.setInstPlayerCardId(UICardInfo, _curInstPlayerCardId, pvCardData)
                UIManager.pushScene("ui_card_upgrade")
                -- UIManager.replaceScene("ui_card_upgrade")
            elseif sender == btn_advance then
                local instCardData = net.InstPlayerCard[tostring(_curInstPlayerCardId)]
                local _curCaridDictId = instCardData.int["3"]
                local _curCardQualityId = instCardData.int["4"]
                local _curStarLevelId = instCardData.int["5"]
                if _curCaridDictId ~= 154 and(_curCardQualityId == StaticQuality.white or _curCardQualityId == StaticQuality.green) then
                    UIManager.showToast((_curCardQualityId == StaticQuality.white and Lang.ui_card_info25 or Lang.ui_card_info26) .. Lang.ui_card_info27)
                    -- elseif _curCardQualityId == StaticQuality.purple and _curStarLevelId == DictQuality[tostring(StaticQuality.purple)].maxStarLevel + 1 then
                    -- 	UIManager.showToast("该卡牌已进阶至顶级！")
                else
                    UICardAdvance.setInstPlayerCardId(UICardInfo, _curInstPlayerCardId)
                    UIManager.pushScene("ui_card_advance")
                    -- UIManager.replaceScene("ui_card_advance")
                end
            elseif sender == btn_medicine then
                local instCardData = net.InstPlayerCard[tostring(_curInstPlayerCardId)]
                local _curCardQualityId = instCardData.int["4"]
                if _curCardQualityId == StaticQuality.white then
                    UIManager.showToast(Lang.ui_card_info28)
                    return
                else
                    local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.pill)].level
                    if net.InstPlayer.int["4"] < openLv then
                        UIManager.showToast(Lang.ui_card_info29 .. openLv .. Lang.ui_card_info30)
                        return
                    end
                    UIMedicine.setCurCardLv(instCardData.int["9"])
                    UIMedicine.InstPlayerConstells(instCardData.string["13"])
                    UIManager.pushScene("ui_medicine")
                    -- UIManager.replaceScene("ui_medicine")
                end
            elseif sender == btn_realm then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.state)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_card_info31 .. openLv .. Lang.ui_card_info32)
                    return
                end
                --如果称号大于等于斗尊
                if net.InstPlayerCard[tostring(_curInstPlayerCardId)].int["6"] >= 71 then
                    UICardJingjieN.show({ InstPlayerCard_id = _curInstPlayerCardId })
                else
                    UICardJingJie.show( { InstPlayerCard_id = _curInstPlayerCardId })
                end
            elseif sender == btn_xiulian then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.train)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_card_info33 .. openLv .. Lang.ui_card_info34)
                    return
                end
                UICardRealm.setUIParam(_curInstPlayerCardId)
                UIManager.pushScene("ui_card_realm")
                -- UIManager.replaceScene("ui_card_realm")
            elseif sender == friendBtnChange then
                if _uiItem == UIFriend then
                    UICardChange.setUIParam(UICardChange.OperateType.Friend, { _param[2] })
                    UIManager.pushScene("ui_card_change")
                elseif _uiItem == UIBagCard then
                    UIManager.popAllScene()
                    UIManager.hideWidget("ui_team_info")
                    UIManager.showWidget("ui_lineup")
                end
            elseif sender == friendBtnDown then
                if _uiItem == UIFriend then
                    local sendData = {
                        header = StaticMsgRule.cardOutPartner,
                        msgdata =
                        {
                            int =
                            {
                                instPlayerPartnerId = _param[3],
                            }
                        }
                    }
                    UIManager.showLoading()
                    netSendPackage(sendData, netCallbackFunc)
                elseif _uiItem == UIBagCard then
                    local sendData = {
                        header = StaticMsgRule.lockCard,
                        msgdata =
                        {
                            int =
                            {
                                instPlayerCardId = _curInstPlayerCardId,
                            }
                        }
                    }
                    UIManager.showLoading()
                    netSendPackage(sendData, netCallbackFunc)
                end
            elseif sender == btn_l then
                local index = ui_pageView:getCurPageIndex() -1
                if index < 0 then
                    index = 0
                end
                ui_pageView:scrollToPage(index)
            elseif sender == btn_r then
                local index = ui_pageView:getCurPageIndex() + 1
                if index > #ui_pageView:getPages() then
                    index = #ui_pageView:getPages()
                end
                ui_pageView:scrollToPage(index)
            end
        end
    end

    btn_info:addTouchEventListener(btnTouchEvent)
    btn_pieces:addTouchEventListener(btnTouchEvent)
    btn_close:addTouchEventListener(btnTouchEvent)
    btn_change:addTouchEventListener(btnTouchEvent)
    btn_upgrade:addTouchEventListener(btnTouchEvent)
    btn_advance:addTouchEventListener(btnTouchEvent)
    btn_medicine:addTouchEventListener(btnTouchEvent)
    btn_realm:addTouchEventListener(btnTouchEvent)
    btn_xiulian:addTouchEventListener(btnTouchEvent)
    friendBtnChange:addTouchEventListener(btnTouchEvent)
    friendBtnDown:addTouchEventListener(btnTouchEvent)
    btn_l:addTouchEventListener(btnTouchEvent)
    btn_r:addTouchEventListener(btnTouchEvent)

    ui_pageView = ccui.Helper:seekNodeByName(UICardInfo.Widget, "view_page")
    ui_pageViewItem = ui_pageView:getChildByName("panel"):clone()

    btn_l:setLocalZOrder(ui_pageView:getLocalZOrder() + 1)
    btn_r:setLocalZOrder(ui_pageView:getLocalZOrder() + 1)
    btn_info:setLocalZOrder(ui_pageView:getLocalZOrder() + 1)
    btn_pieces:setLocalZOrder(ui_pageView:getLocalZOrder() + 1)
end

function UICardInfo.setup()
    UIGuidePeople.isGuide(nil, UICardInfo)
    cleanPageView()

    local _pageIndex, _tempCardId = 0, 0
    if _dictCardId then
        setBottomBtn(false)
        pvCardData = { }
        if pvCardData[1] == nil then
            pvCardData[1] = { }
        end
        pvCardData[1].dictId = _dictCardId
        _tempCardId = pvCardData[1].dictId
    elseif _uiItem == UILineup or _uiItem == UIArenaCheck then
        if friendFormation and not instPlayerFormationId then
            _curInstPlayerCardId = friendFormation[1]
        else
            _curInstPlayerCardId = netOrPvp.InstPlayerFormation[tostring(instPlayerFormationId)].int["3"]
         end
        setBottomBtn(_uiItem == UILineup)
        pvCardData = getLineupData()
        _tempCardId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
    else
        setBottomBtn(false)
        pvCardData = { }
        if pvCardData[1] == nil then
            pvCardData[1] = { }
        end
        pvCardData[1].dictId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
        pvCardData[1].instId = _curInstPlayerCardId
        _tempCardId = pvCardData[1].dictId
    end

    local btn_info = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_info")
    btn_info:setVisible((_tempCardId and UICardInfo.getCardJumpMap()[_tempCardId]) ~= nil)
    if btn_info:isVisible() and not btn_info:getChildByName("particle1") then
        utils.addFrameParticle(btn_info, true)
    end

    if pvCardData then
        for key, obj in pairs(pvCardData) do
            local pageViewItem = ui_pageViewItem:clone()
            pageViewItem:setTag(obj.dictId)
            if _tempCardId == obj.dictId then
                _pageIndex = key - 1
            end
            local dictCardData = DictCard[tostring(obj.dictId)]
            if dictCardData then
                local qualityId = dictCardData.qualityId
                local _isAwake = 0
                if obj.instId and obj.instId > 0 then
                    local instCardData = netOrPvp.InstPlayerCard[tostring(obj.instId)]
                    qualityId = instCardData.int["4"]
                    _isAwake = instCardData.int["18"]
                end
                pageViewItem:getChildByName("image_property"):loadTexture(utils.getCardTypeImage(dictCardData.cardTypeId))
                local ui_nameBgImg = pageViewItem:getChildByName("image_di_name")
                local middleImg = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true)
                ui_nameBgImg:loadTexture(middleImg)
                ui_nameBgImg:getChildByName("text_name"):setString((_isAwake == 1 and Lang.ui_card_info35 or "") .. dictCardData.name)
                ccui.Helper:seekNodeByName(ui_nameBgImg, "AtlasLabel_36"):setString(tostring(dictCardData.nickname))
                local ui_cardImg = pageViewItem:getChildByName("image_card")
                if netOrPvp.InstPlayerWing then
                    for key, value in pairs(netOrPvp.InstPlayerWing) do
                        if value.int["6"] == obj.instId then
                            local actionName = DictWing[tostring(value.int["3"])].actionName
                            if actionName and actionName ~= "" then
                                utils.addArmature(pageViewItem, 54 + value.int["5"], actionName, pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2, 0, ui_cardImg:getScale())
                            else
                                utils.addArmature(pageViewItem, 54 + value.int["5"], "0" .. value.int["5"] .. DictWing[tostring(value.int["3"])].sname, pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2, 0, ui_cardImg:getScale())
                            end
                            break
                        end
                    end
                end
                ui_cardImg:setVisible(false)
                local cardAnim, cardAnimName
                if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
                    cardAnim, cardAnimName = ActionManager.getCardAnimation(_isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles)
                else
                    cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
                end
                cardAnim:setScale(ui_cardImg:getScale())
                cardAnim:setPosition(cc.p(pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2))
                pageViewItem:addChild(cardAnim)
            end
            ui_pageView:addPage(pageViewItem)
        end
        ui_pageView:addEventListener(pageViewEvent)
    end

    ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        ui_pageView:scrollToPage(_pageIndex)
    end )))

    local dictCardId = nil
    if _dictCardId then
        dictCardId = tonumber(_dictCardId)
    elseif _curInstPlayerCardId then
        dictCardId = netOrPvp.InstPlayerCard[tostring(_curInstPlayerCardId)].int["3"]
    end
    local btn_pieces = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_pieces")

    if dictCardId and DictCard[tostring(dictCardId)].qualityId >= StaticQuality.blue and DictCard[tostring(dictCardId)].isCash == 1 then
        btn_pieces:setVisible(true) --TODO 万能碎片暂时屏蔽
    else
        btn_pieces:setVisible(false)
    end
end

function UICardInfo.setUIParam(uiItem, param)
    _uiItem = uiItem
    _param = param
    netOrPvp = net
    utilsOrPvp = utils
    friendFormation = nil
    if _uiItem == UILineup or _uiItem == UIArenaCheck then
        if type( param ) == "table" then
            friendFormation = param
            instPlayerFormationId = nil
        else
            friendFormation = nil
            instPlayerFormationId = param
        end
        _curInstPlayerCardId = nil
        netOrPvp = _uiItem == UILineup and net or pvp
        utilsOrPvp = _uiItem == UILineup and utils or pvp
    elseif _uiItem == UIFriend then
        _curInstPlayerCardId = _param[1]
    else
        _curInstPlayerCardId = param
    end
end

function UICardInfo.setDictCardId(dictCardId)
    _dictCardId = dictCardId
    _curInstPlayerCardId = nil
    netOrPvp = net
    utilsOrPvp = utils
end

function UICardInfo.free()
    UIGuidePeople.isGuide(nil, UICardInfo)
    _dictCardId = nil
    cleanPageView(true)
    pvCardData = nil
  --  netOrPvp = nil
 --   utilsOrPvp = nil
 --   friendFormation = nil
end
