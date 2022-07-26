require"Lang"
EquipmentInfo = {}

local MAX_STAR_LEVEL = 5

local userData = nil
local initLayoutUI = nil

function EquipmentInfo.show(_tableParams)
    userData = _tableParams
    if userData == nil or userData.DictEquip_id == nil then
        cclog("EquipmentInfo.show(_tableParams) ====> param error: DictEquip_id=?")
        return
    end
    local dictEquipData = DictEquipment[tostring(userData.DictEquip_id)]
    local suitEquipData, redSuitEquipData = utils.getEquipSuit(tostring(userData.DictEquip_id))
    local uiLayout = nil
    if dictEquipData.equipQualityId >= StaticEquip_Quality.blue and suitEquipData then
        if UIEquipmentNew.Widget and UIEquipmentNew.Widget:getParent() then
            uiLayout = UIEquipmentNew.Widget:clone()
        else
            local node = cc.CSLoader:createNode("ui/ui_equipment_new.csb")
            if node == nil then
                cclog("-------------->>>  [ui_equipment_new.csb] load failed !!!!!")
                return
            end
            uiLayout = node:getChildren()[1]
            uiLayout:removeSelf()
            uiLayout:setName("ui_equipment_new_clone")
        end
    else
        if UIEquipmentInfo.Widget and UIEquipmentInfo.Widget:getParent() then
            uiLayout = UIEquipmentInfo.Widget:clone()
        else
            local node = cc.CSLoader:createNode("ui/ui_equipment_info.csb")
            if node == nil then
                cclog("-------------->>>  [ui_equipment_info.csb] load failed !!!!!")
                return
            end
            uiLayout = node:getChildren()[1]
            uiLayout:removeSelf()
            uiLayout:setName("ui_equipment_info_clone")
        end
    end
    if uiLayout then
        initLayoutUI(uiLayout, suitEquipData, redSuitEquipData)
        local rootWidget = uiLayout:getChildByName("image_basemap")
        rootWidget:setScale(0.1)
        UIManager.uiLayer:addChild(uiLayout, UIManager.getPopWindowCount() + 2)
        rootWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, dp.DIALOG_SCALE)))
    end
end

function EquipmentInfo.free()
    userData = nil
end

initLayoutUI = function(_uiLayout, _suitEquipData, _redSuitEquipData)
    local _isSuitEquip = _suitEquipData and true or false
    local rootWidget = _uiLayout:getChildByName("image_basemap")
    local btn_close = rootWidget:getChildByName("btn_close")
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            rootWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create( function()
                EquipmentInfo.free()
                UIManager.uiLayer:removeChild(_uiLayout)
            end )))
        end
    end)
    rootWidget:getChildByName("btn_change"):setVisible(false)
    rootWidget:getChildByName("btn_unload"):setVisible(false)
    rootWidget:getChildByName("btn_intensify"):setVisible(false)
    rootWidget:getChildByName("btn_inlay"):setVisible(false)
    rootWidget:getChildByName("btn_clean"):setVisible(false)

    local ui_infoPanel = rootWidget:getChildByName("image_basecolour")
    local ui_equipQualityBg = ccui.Helper:seekNodeByName(ui_infoPanel, "image_base_name")
    local ui_equipName = ui_equipQualityBg:getChildByName("text_name")
    local ui_equipIcon = ccui.Helper:seekNodeByName(ui_infoPanel, "image_equipment")
    local ui_equipLevel = ui_equipQualityBg:getChildByName("text_lv")
    local ui_equipQuality = ccui.Helper:seekNodeByName(ui_infoPanel, "text_number_quality")
    local ui_equipPropPanel = ccui.Helper:seekNodeByName(ui_infoPanel, "image_base_property")
    local ui_equipDescribe = ccui.Helper:seekNodeByName(ui_infoPanel, "text_describe")

    local dictEquipData = DictEquipment[tostring(userData.DictEquip_id)]
    local _equipLv = 1
    local _equipQualityId = dictEquipData.equipQualityId
    ui_equipName:setString(dictEquipData.name)
    if userData.isRedEquip then
        _equipQualityId = StaticEquip_Quality.golden
        ui_equipIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.RedbigUiId)].fileName)
    else
        ui_equipIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.bigUiId)].fileName)
    end
    ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, _equipQualityId, dp.QualityImageType.middle, true))
    ui_equipLevel:setString("LV" .. _equipLv)
    ui_equipQuality:setString(tostring(dictEquipData.qualityLevel))
    ui_equipDescribe:setString(dictEquipData.description)

    if _equipQualityId == StaticEquip_Quality.white or _equipQualityId == StaticEquip_Quality.green then
        ui_equipIcon:getParent():getChildByName("text_title"):setVisible(false)
        for i = 1, MAX_STAR_LEVEL do
            ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(false)
        end
    else
        ui_equipIcon:getParent():getChildByName("text_title"):setVisible(true)
        for i = 1, MAX_STAR_LEVEL do
            ui_equipIcon:getParent():getChildByName("image_star" .. i):loadTexture("ui/star02.png")
            ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(true)
            if i > 3 and _equipQualityId == StaticEquip_Quality.blue then
                ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(false)
            end
        end
    end

    local equipPropData = { }
    local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
    for key, obj in pairs(propData) do
        equipPropData[key] = utils.stringSplit(obj, "_") -- [1]:fightPropId, [2]:initValue, [3]:addValue
    end
    local propIndex, spaceH = 1, 3
    local equipPropItem = ui_equipPropPanel:getChildByName("text_base_property" .. propIndex)
    local x, y = equipPropItem:getPosition()
    local childs = ui_equipPropPanel:getChildren()
    for i = 1, #childs do
        if i ~= propIndex then
            ui_equipPropPanel:removeChild(childs[i], true)
        end
    end
    for key, obj in pairs(equipPropData) do
        local equipProp
        if key == propIndex then
            equipProp = equipPropItem
        else
            equipProp = equipPropItem:clone()
            ui_equipPropPanel:addChild(equipProp)
        end
        equipProp:setTextColor(cc.c4b(0, 255, 255, 255))
        equipProp:setPosition(cc.p(x, y))
        y = y - equipProp:getContentSize().height - spaceH
        local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])

        equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. formula.getEquipAttribute(_equipLv, initValue, addValue))
    end
    y = y + equipPropItem:getContentSize().height + spaceH

    local isContain = function(dictFightPropId)
        for key, obj in pairs(equipPropData) do
            if dictFightPropId == tonumber(obj[1]) then
                return true
            end
        end
    end

    -- 灵攻,斗攻,灵防,斗防,生命,暴击,闪避,命中,韧性
    local tempDictFightProp = { }
    for key, obj in pairs(DictFightProp) do
        local index = #tempDictFightProp + 1
        if obj.id == StaticFightProp.blood then -- 血
            index = 5
        elseif obj.id == StaticFightProp.wAttack then -- 物攻
            index = 2
        elseif obj.id == StaticFightProp.fAttack then -- 法攻
            index = 1
        elseif obj.id == StaticFightProp.dodge then -- 闪避
            index = 7
        elseif obj.id == StaticFightProp.crit then -- 暴击
            index = 6
        elseif obj.id == StaticFightProp.hit then -- 命中
            index = 8
        elseif obj.id == StaticFightProp.flex then -- 韧性
            index = 9
        elseif obj.id == StaticFightProp.wDefense then -- 物防
            index = 4
        elseif obj.id == StaticFightProp.fDefense then -- 法防
            index = 3
        end
        if index <= 5 then
            tempDictFightProp[index] = obj
        end
    end

    for key, obj in pairs(tempDictFightProp) do
        if not isContain(obj.id) then
            local equipProp = equipPropItem:clone()
            ui_equipPropPanel:addChild(equipProp)
            equipProp:setTextColor(cc.c4b(255, 255, 255, 255))
            y = y - equipProp:getContentSize().height - spaceH
            equipProp:setPosition(cc.p(x, y))
            equipProp:setString(obj.name .. "：0")
        end
    end

    if _isSuitEquip then
        local ui_scrollView = ccui.Helper:seekNodeByName(ui_infoPanel, "view")
        local ui_inlayPanel = ui_scrollView:getChildByName("image_equipment_di")
        local ui_suitEquipPanel = ui_scrollView:getChildByName("image_equipment_new")
        ui_inlayPanel:setVisible(false)
        ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getInnerContainerSize().width, ui_scrollView:getInnerContainerSize().height - ui_inlayPanel:getContentSize().height))
        ccui.Helper:seekNodeByName(ui_suitEquipPanel, "image_base_di_info"):getChildByName("text_hint"):setString(_suitEquipData.name)
        local suitEquipTable = utils.stringSplit(_suitEquipData.suitEquipIdList, ";")
        for i = 1, 4 do
            local dictEquipData = DictEquipment[tostring(suitEquipTable[i])]
            local ui_frame = ccui.Helper:seekNodeByName(ui_suitEquipPanel, "image_frame_gem"..i)
            local ui_icon = ui_frame:getChildByName("image_gem")
            ccui.Helper:seekNodeByName(ui_frame, "text_gem_name"):setString(dictEquipData.name)
            ui_frame:setTouchEnabled(false)
            if userData.isRedEquip then
                ui_frame:loadTexture(utils.getQualityImage(dp.Quality.equip, StaticEquip_Quality.golden, dp.QualityImageType.small))
                ui_icon:loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
            else
                ui_frame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small))
                ui_icon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
            end
            ui_frame:getChildByName("image_lv"):setVisible(false)
        end
        for i = 2, 4 do
            local item = ccui.Helper:seekNodeByName(ui_suitEquipPanel, "image_number" .. i)
            item:getChildByName("text_number"):setTextColor(cc.c4b(0, 255, 255, 255))

            local propTable = utils.stringSplit(_suitEquipData[string.format("suit%dNumProp", i)], ";")
            for key, value in pairs(propTable) do
                local data = utils.stringSplit(value, "_")
                local imgProp = item:getChildByName("text_property" .. key)
                imgProp:setTextColor(cc.c4b(0, 255, 255, 255))
                if tonumber(data[2]) < 1 then
                    imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" ..(tonumber(data[2]) * 100) .. "%")
                else
                    imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" .. data[2])
                end
            end
        end
        for i = 1, 11 do
            local item = ccui.Helper:seekNodeByName(ui_suitEquipPanel, "image_star" .. i)
            local titleLabel = item:getChildByName("text_number")
            local propTable = nil
            if i <= 5 then
                if _equipQualityId == StaticEquip_Quality.blue and i >= 4 then
                    item:setVisible(false)
                end
                titleLabel:setString(string.format(Lang.EquipmentInfo1, i))
                titleLabel:setTextColor(cc.c4b(0, 255, 255, 255))
                propTable = utils.stringSplit(_suitEquipData[string.format("suit%dStarProp", i)], ";")
            else
                if _redSuitEquipData then
                    titleLabel:setString(string.format(Lang.EquipmentInfo2, i - 6))
                    titleLabel:setTextColor(cc.c4b(0, 255, 255, 255))
                    propTable = utils.stringSplit(_redSuitEquipData[string.format("Redsuit%dStarProp", i - 6)], ";")
                else
                    item:setVisible(false)
                end
            end
            if item:isVisible() then
                for textKey = 1, 2 do
                    local ui_property = item:getChildByName("text_property" .. textKey)
                    if propTable and propTable[textKey] then
                        local data = utils.stringSplit(propTable[textKey], "_")
                        if tonumber(data[2]) < 1 then
					        ui_property:setString(DictFightProp[tostring(data[1])].name .. "+" ..(tonumber(data[2]) * 100) .. "%")
				        else
					        ui_property:setString(DictFightProp[tostring(data[1])].name .. "+" .. data[2])
				        end
                        ui_property:setTextColor(cc.c4b(0, 255, 255, 255))
                        ui_property:setVisible(true)
                    else
                        ui_property:setVisible(false)
                    end
                end
            end
        end
    else
        local ui_image_equipment_di = ccui.Helper:seekNodeByName(ui_infoPanel, "image_equipment_di")
        for i = 1, 4 do
            ui_inlayItems = ccui.Helper:seekNodeByName(ui_image_equipment_di, "image_frame_gem" .. i)
            ui_inlayItems:setTouchEnabled(false)
            ui_inlayItems:loadTexture("ui/low_small_white.png")
            ui_inlayItems:getChildByName("image_gem"):loadTexture("ui/mg_suo.png")
            ccui.Helper:seekNodeByName(ui_inlayItems, "text_gem_name"):setVisible(false)
            ui_inlayItems:getChildByName("text_gem_property"):setVisible(false)
        end
    end
end

return EquipmentInfo
