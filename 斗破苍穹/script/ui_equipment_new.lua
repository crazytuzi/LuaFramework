require"Lang"
UIEquipmentNew = { }

local ui_equipQualityBg = nil -- 装备品质背景图
local ui_equipName = nil -- 装备名字
local ui_equipIcon = nil -- 装备图标
local ui_equipLevel = nil -- 装备等级
local ui_equipQuality = nil -- 装备品质
local ui_equipPropPanel = nil -- 属性面板
local ui_inlayItems = { }
local ui_equipDescribe = nil -- 装备描述
local MAX_STAR_LEVEL = 5 --最大星级

local btn_change = nil
local btn_unload = nil
local btn_intensify = nil
local btn_clean = nil
local btn_inlay = nil

local _dictEquipId = nil
local _dictEquipData = nil
local _equipInstId = nil
local _equipTypeId = nil
local _equipQualityId = nil
local _equipCardInstId = nil

local _isPvp = false

local function netCallbackFunc(data)
    AudioEngine.playEffect("sound/putDown.mp3")
    UIManager.popAllScene()
    UILineup.setup()
end

function UIEquipmentNew.init()
       
    local ui_infoPanel = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "image_basecolour")
    ui_equipQualityBg = ccui.Helper:seekNodeByName(ui_infoPanel, "image_base_name")
    ui_equipName = ui_equipQualityBg:getChildByName("text_name")
    ui_equipIcon = ccui.Helper:seekNodeByName(ui_infoPanel, "image_equipment")
    ui_equipLevel = ui_equipQualityBg:getChildByName("text_lv")
    ui_equipQuality = ccui.Helper:seekNodeByName(ui_infoPanel, "text_number_quality")
    ui_equipPropPanel = ccui.Helper:seekNodeByName(ui_infoPanel, "image_base_property")
    ui_equipDescribe = ccui.Helper:seekNodeByName(ui_infoPanel, "text_describe")

    local btn_close = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_close")
    btn_change = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_change")
    -- 更换按钮
    btn_unload = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_unload")
    -- 卸下按钮
    btn_intensify = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_intensify")
    -- 强化按钮
    btn_clean = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_clean")
    -- 进阶按钮
    btn_inlay = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_inlay")
    -- 镶嵌按钮
    btn_close:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    btn_unload:setPressedActionEnabled(true)
    btn_intensify:setPressedActionEnabled(true)
    btn_clean:setPressedActionEnabled(true)
    btn_inlay:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_change then
                -- 更换
                if _equipTypeId and _equipCardInstId then
                    UIBagEquipmentSell.setEquipType(_equipTypeId)
                    UIBagEquipmentSell.setInstCardId(_equipCardInstId)
                    UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.Change)
                    UIManager.pushScene("ui_bag_equipment_sell")
                end
            elseif sender == btn_unload then
                -- 卸下
                local sendData = {
                    header = StaticMsgRule.putOffEquip,
                    msgdata =
                    {
                        int =
                        {
                            instPlayerCardId = _equipCardInstId,
                            instPlayerEquipId = _equipInstId,
                        }
                    }
                }
                UIManager.showLoading()
                netSendPackage(sendData, netCallbackFunc)
            elseif sender == btn_intensify then
                -- 强化
                UIEquipmentIntensify.setEquipInstId(_equipInstId)
                UIManager.pushScene("ui_equipment_intensify")
                -- UIManager.replaceScene("ui_equipment_intensify")
                UIGuidePeople.isGuide(nil, UIEquipmentIntensify)
            elseif sender == btn_clean then
                -- 进阶
                local instEquipData = net.InstPlayerEquip[tostring(_equipInstId)]
                local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
	            local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
	            local dictEquipAdvanceData = DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表             
                if _equipQualityId == StaticEquip_Quality.white or _equipQualityId == StaticEquip_Quality.green then
                    UIManager.showToast((_equipQualityId == StaticEquip_Quality.white and Lang.ui_equipment_new1 or Lang.ui_equipment_new2) .. Lang.ui_equipment_new3)
                elseif _equipQualityId == StaticEquip_Quality.golden or (dictEquipAdvanceData and dictEquipAdvanceData.starLevel == 5 and dictEquipData.equipQualityId == StaticEquip_Quality.purple) then
                    UIEquipmentAdvance.show({ InstPlayerEquip_id = _equipInstId})
                else
                    UIEquipmentClean.show( { InstPlayerEquip_id = _equipInstId },2)
                end
            elseif sender == btn_inlay or sender == ui_inlayItems[1] or sender == ui_inlayItems[2] or sender == ui_inlayItems[3] or sender == ui_inlayItems[4] then
                -- 镶嵌
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.inly)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_equipment_new4 .. openLv .. Lang.ui_equipment_new5)
                    return
                end
                UIGemInlay.setEquipInstId(_equipInstId)
                UIManager.pushScene("ui_gem_inlay")
                -- UIManager.replaceScene("ui_gem_inlay")
            end
        end
    end
    btn_close:addTouchEventListener(btnTouchEvent)
    btn_change:addTouchEventListener(btnTouchEvent)
    btn_unload:addTouchEventListener(btnTouchEvent)
    btn_intensify:addTouchEventListener(btnTouchEvent)
    btn_clean:addTouchEventListener(btnTouchEvent)
    btn_inlay:addTouchEventListener(btnTouchEvent)
    local ui_image_equipment_di = ccui.Helper:seekNodeByName(ui_infoPanel, "image_equipment_di")
    for i = 1, 4 do
        ui_inlayItems[i] = ccui.Helper:seekNodeByName(ui_image_equipment_di, "image_frame_gem" .. i)
        ui_inlayItems[i]:setTouchEnabled(true)
        ui_inlayItems[i]:addTouchEventListener(btnTouchEvent)
    end
end

local function setBottomBtn(enabled)
    btn_change:setVisible(enabled)
    btn_unload:setVisible(enabled)
    btn_intensify:setVisible(enabled)
    btn_clean:setVisible(enabled)
    btn_inlay:setVisible(enabled)
    btn_change:setTouchEnabled(enabled)
    btn_unload:setTouchEnabled(enabled)
    btn_intensify:setTouchEnabled(enabled)
    btn_clean:setTouchEnabled(enabled)
    btn_inlay:setTouchEnabled(enabled)
end



function UIEquipmentNew.setup()
    if _isPvp and _equipInstId and pvp.InstPlayerEquip then
        setBottomBtn(false)
        local instEquipData = pvp.InstPlayerEquip[tostring(_equipInstId)]
        _equipTypeId = instEquipData.int["3"]
        -- 装备类型ID
        local dictEquipId = instEquipData.int["4"]
        -- 装备字典ID
        local equipLv = instEquipData.int["5"]
        -- 装备等级
        _equipCardInstId = instEquipData.int["6"]
        -- 装备上卡牌ID
        local equipAdvanceId = instEquipData.int["8"]
        -- 装备进阶字典ID
        local dictEquipData = DictEquipment[tostring(dictEquipId)]
        -- 装备字典表
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
        -- 装备进阶字典表
        
        local equipAdvanceData = { }
        for key, obj in pairs(DictEquipAdvance) do
            if _equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
                equipAdvanceData[#equipAdvanceData + 1] = obj
            end
        end
        utils.quickSort(equipAdvanceData, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
        if UIArenaCheck.playerId and UIArenaCheck.playerId < 1000000 then
            if equipAdvanceId == 0 and(not dictEquipAdvanceData) then
                dictEquipAdvanceData = equipAdvanceData[1]
            end
            for i = 1, 5 do
                local ui_starImg = ui_equipIcon:getParent():getChildByName("image_star" .. i)
                if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
                    ui_starImg:loadTexture("ui/star01.png")
                else
                    ui_starImg:loadTexture("ui/star02.png")
                end
                if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
                    ui_starImg:setVisible(false)
                else
                    ui_starImg:setVisible(true)
                end
            end
        else
            for i = 1, 5 do
                local ui_starImg = ui_equipIcon:getParent():getChildByName("image_star" .. i)
                ui_starImg:loadTexture("ui/star02.png")
            end
        end
        _equipQualityId = dictEquipAdvanceData.equipQualityId
        ui_equipName:setString(dictEquipData.name)
        ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.middle, true))
        ui_equipIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedbigUiId or dictEquipData.bigUiId)].fileName)
        ui_equipLevel:setString("LV" .. equipLv)
        ui_equipQuality:setString(tostring(dictEquipData.qualityLevel))


        local equipPropData = { }
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
            equipPropData[key] = utils.stringSplit(obj, "_")
            -- [1]:fightPropId, [2]:initValue, [3]:addValue
        end

        local propIndex, spaceH = 1, 0
        local equipPropItem = ui_equipPropPanel:getChildByName("text_base_property" .. propIndex)
        -- local ui_property_bian = ui_equipPropPanel:getChildByName("image_property_bian")
        local x, y = equipPropItem:getPosition()
        local childs = ui_equipPropPanel:getChildren()
        for i = 1, #childs do
            -- if i ~= propIndex and childs[i] ~= ui_property_bian then
            if i ~= propIndex then
                ui_equipPropPanel:removeChild(childs[i], true)
            end
        end

        local attribs = utils.getEquipAttribute(_equipInstId, false, true)
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

            -- 		equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. formula.getEquipAttribute(equipLv, initValue, addValue))
            equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
        end
        y = y + equipPropItem:getContentSize().height + spaceH
        -- ui_property_bian:setPosition(cc.p(ui_property_bian:getPositionX(), y))

        local function isContain(dictFightPropId)
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
            if obj.id == StaticFightProp.blood then
                -- 血
                index = 5
            elseif obj.id == StaticFightProp.wAttack then
                -- 物攻
                index = 2
            elseif obj.id == StaticFightProp.fAttack then
                -- 法攻
                index = 1
            elseif obj.id == StaticFightProp.wDefense then
                -- 物防
                index = 4
            elseif obj.id == StaticFightProp.fDefense then
                -- 法防
                index = 3
            elseif obj.id == StaticFightProp.dodge then
                -- 闪避
                index = 7
            elseif obj.id == StaticFightProp.crit then
                -- 暴击
                index = 6
            elseif obj.id == StaticFightProp.hit then
                -- 命中
                index = 8
            elseif obj.id == StaticFightProp.flex then
                -- 韧性
                index = 9
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
                equipProp:setString(obj.name .. "：" .. attribs[obj.id])
            end
        end

        local holeNums = { }
        for key, obj in pairs(DictHoleConsume) do
            if obj.qualityId == dictEquipData.equipQualityId then
                holeNums[obj.times + 1] = obj.num
            end
        end
        local inlayThingId = { }
        if pvp.InstEquipGem then
            for key, obj in pairs(pvp.InstEquipGem) do
                if _equipInstId == obj.int["3"] then
                    inlayThingId[obj.int["5"]] = obj.int["4"]
                    -- 物品Id 0表示未镶嵌宝石
                end
            end
        end
        local dictEquipQualityData = DictEquipQuality[tostring(dictEquipAdvanceData.equipQualityId)]
        -- 装备品质字典表
        local holeNum = dictEquipQualityData.holeNum
        -- 拥有宝石孔数
        for key, uiItem in pairs(ui_inlayItems) do
            if key <= holeNum then
                uiItem:loadTexture("ui/low_small_white.png")
                uiItem:setVisible(true)
                local _icon = uiItem:getChildByName("image_gem")
                local _gemName = ccui.Helper:seekNodeByName(uiItem, "text_gem_name")
                local _gemProp = uiItem:getChildByName("text_gem_property")
                local _thingId = inlayThingId[key]
                if _thingId then
                    if _thingId == 0 then
                        -- 已打孔了
                        _gemName:setVisible(false)
                        _gemProp:setVisible(false)
                        _icon:loadTexture("ui/frame_tianjia.png")
                    else
                        -- 镶嵌了物品
                        _gemName:setVisible(true)
                        _gemProp:setVisible(true)
                        local dictThingData = DictThing[tostring(_thingId)]
                        _gemName:setString(dictThingData.name)
                        uiItem:loadTexture(utils.getThingQualityImg(dictThingData.bkGround))
                        _icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
                        _gemProp:setString("+" .. dictThingData.fightPropValue .. DictFightProp[tostring(dictThingData.fightPropId)].name)
                        utils.addThingParticle(StaticTableType.DictThing .. "_" .. _thingId, _icon, true)
                    end
                else
                    -- 未打孔
                    _gemName:setVisible(false)
                    _gemProp:setVisible(false)
                    _icon:loadTexture("ui/mg_suo.png")
                end
            else
                uiItem:setVisible(false)
            end
        end

        ui_equipDescribe:setString(dictEquipData.description)
    elseif net.InstPlayerEquip and _equipInstId then
        UIGuidePeople.isGuide(btn_intensify, UIEquipmentNew)
        setBottomBtn(true)
        local instEquipData = net.InstPlayerEquip[tostring(_equipInstId)]
        _equipTypeId = instEquipData.int["3"]
        -- 装备类型ID
        local dictEquipId = instEquipData.int["4"]
        -- 装备字典ID
        local equipLv = instEquipData.int["5"]
        -- 装备等级
        _equipCardInstId = instEquipData.int["6"]
        -- 装备上卡牌ID
        local equipAdvanceId = instEquipData.int["8"]
        -- 装备进阶字典ID
        local dictEquipData = DictEquipment[tostring(dictEquipId)]
        -- 装备字典表
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
        -- 装备进阶字典表

      
        local equipAdvanceData = { }
        for key, obj in pairs(DictEquipAdvance) do
            if _equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
                equipAdvanceData[#equipAdvanceData + 1] = obj
            end
        end
        utils.quickSort(equipAdvanceData, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
        if equipAdvanceId == 0 and(not dictEquipAdvanceData) then
            dictEquipAdvanceData = equipAdvanceData[1]
        end

         _equipQualityId = dictEquipAdvanceData.equipQualityId

        ui_equipName:setString(dictEquipData.name)
        ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.middle, true))
        ui_equipIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedbigUiId or dictEquipData.bigUiId)].fileName)
        ui_equipLevel:setString("LV" .. equipLv)
        ui_equipQuality:setString(tostring(dictEquipData.qualityLevel))

        if (dictEquipAdvanceData and dictEquipAdvanceData.starLevel == 5 and dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.purple) then
            btn_clean:loadTextures("ui/god.png", "ui/god.png")
        else
            btn_clean:loadTextures("ui/clean.png", "ui/clean.png")
        end

        for i = 1, 5 do
            local ui_starImg = ui_equipIcon:getParent():getChildByName("image_star" .. i)
            if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
                ui_starImg:loadTexture("ui/star01.png")
            else
                ui_starImg:loadTexture("ui/star02.png")
            end
            if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
                ui_starImg:setVisible(false)
            else
                ui_starImg:setVisible(true)
            end
        end

        local equipPropData = { }
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
            equipPropData[key] = utils.stringSplit(obj, "_")
            -- [1]:fightPropId, [2]:initValue, [3]:addValue
        end

        local propIndex, spaceH = 1, 0
        local equipPropItem = ui_equipPropPanel:getChildByName("text_base_property" .. propIndex)
        -- local ui_property_bian = ui_equipPropPanel:getChildByName("image_property_bian")
        local x, y = equipPropItem:getPosition()
        local childs = ui_equipPropPanel:getChildren()
        for i = 1, #childs do
            -- if i ~= propIndex and childs[i] ~= ui_property_bian then
            if i ~= propIndex then
                ui_equipPropPanel:removeChild(childs[i], true)
            end
        end

        local attribs = utils.getEquipAttribute(_equipInstId)
        local _jlAttribs = utils.getEquipAttribute(_equipInstId, true)
        local _instFormationId = 0
        for key, obj in pairs(net.InstPlayerLineup) do
            if obj.int["5"] == _equipInstId then
                _instFormationId = obj.int["3"]
                break
            end
        end
        local _ipebAddPropPer = utils.getQixiaAddPropPerValue(_instFormationId, _equipTypeId)
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

            local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])

            y = y - equipProp:getContentSize().height / 2
            local _jlText = ccui.Text:create()
            _jlText:setFontName(dp.FONT)
            _jlText:setString(string.format(Lang.ui_equipment_new6, _jlAttribs[fightPropId] * (_ipebAddPropPer / 100)))
            _jlText:setFontSize(20)
            _jlText:setTextColor(cc.c3b(255, 0, 0))
            _jlText:setAnchorPoint(cc.p(0, 0.5))
            _jlText:setPosition(cc.p(x, y - _jlText:getContentSize().height / 2))
            ui_equipPropPanel:addChild(_jlText)
            y = y - _jlText:getContentSize().height - spaceH - equipPropItem:getContentSize().height / 2

--            y = y - equipProp:getContentSize().height - spaceH

            -- 		equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. formula.getEquipAttribute(equipLv, initValue, addValue))
            equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
        end
        y = y + equipPropItem:getContentSize().height + spaceH
        -- ui_property_bian:setPosition(cc.p(ui_property_bian:getPositionX(), y))

        local function isContain(dictFightPropId)
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
            if obj.id == StaticFightProp.blood then
                -- 血
                index = 5
            elseif obj.id == StaticFightProp.wAttack then
                -- 物攻
                index = 2
            elseif obj.id == StaticFightProp.fAttack then
                -- 法攻
                index = 1
            elseif obj.id == StaticFightProp.wDefense then
                -- 物防
                index = 4
            elseif obj.id == StaticFightProp.fDefense then
                -- 法防
                index = 3
            elseif obj.id == StaticFightProp.dodge then
                -- 闪避
                index = 7
            elseif obj.id == StaticFightProp.crit then
                -- 暴击
                index = 6
            elseif obj.id == StaticFightProp.hit then
                -- 命中
                index = 8
            elseif obj.id == StaticFightProp.flex then
                -- 韧性
                index = 9
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
                equipProp:setString(obj.name .. "：" .. attribs[obj.id])
            end
        end

        local holeNums = { }
        for key, obj in pairs(DictHoleConsume) do
            if obj.qualityId == dictEquipData.equipQualityId then
                holeNums[obj.times + 1] = obj.num
            end
        end
        local inlayThingId = { }
        if net.InstEquipGem then
            for key, obj in pairs(net.InstEquipGem) do
                if _equipInstId == obj.int["3"] then
                    inlayThingId[obj.int["5"]] = obj.int["4"]
                    -- 物品Id 0表示未镶嵌宝石
                end
            end
        end
        local dictEquipQualityData = DictEquipQuality[tostring(dictEquipAdvanceData.equipQualityId)]
        -- 装备品质字典表
        local holeNum = dictEquipQualityData.holeNum
        -- 拥有宝石孔数
        for key, uiItem in pairs(ui_inlayItems) do
            if key <= holeNum then
                uiItem:loadTexture("ui/low_small_white.png")
                uiItem:setVisible(true)
                local _icon = uiItem:getChildByName("image_gem")
                local _gemName = ccui.Helper:seekNodeByName(uiItem, "text_gem_name")
                local _gemProp = uiItem:getChildByName("text_gem_property")
                local _thingId = inlayThingId[key]
                if _thingId then
                    if _thingId == 0 then
                        -- 已打孔了
                        _gemName:setVisible(false)
                        _gemProp:setVisible(false)
                        _icon:loadTexture("ui/frame_tianjia.png")
                    else
                        -- 镶嵌了物品
                        _gemName:setVisible(true)
                        _gemProp:setVisible(true)
                        local dictThingData = DictThing[tostring(_thingId)]
                        _gemName:setString(dictThingData.name)
                        uiItem:loadTexture(utils.getThingQualityImg(dictThingData.bkGround))
                        _icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
                        _gemProp:setString("+" .. dictThingData.fightPropValue .. DictFightProp[tostring(dictThingData.fightPropId)].name)
                        utils.addThingParticle(StaticTableType.DictThing .. "_" .. _thingId, _icon, true)
                    end
                else
                    -- 未打孔
                    _gemName:setVisible(false)
                    _gemProp:setVisible(false)
                    _icon:loadTexture("ui/mg_suo.png")
                end
            else
                uiItem:setVisible(false)
            end
        end

        ui_equipDescribe:setString(dictEquipData.description)
    elseif _dictEquipId then
        setBottomBtn(false)
        local dictEquipData = DictEquipment[tostring(_dictEquipId)]
        local equipLv = 1
        if _dictEquipData then
            equipLv = _dictEquipData.int["5"]
        end
        ui_equipName:setString(dictEquipData.name)
        _equipQualityId = dictEquipData.equipQualityId
        ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.big))
        ui_equipIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.bigUiId)].fileName)
        ui_equipLevel:setString("LV" .. equipLv)
        ui_equipQuality:setString(Lang.ui_equipment_new7 .. dictEquipData.qualityLevel)

        if _dictEquipData then
            local equipAdvanceId = _dictEquipData.int["8"]
            -- 装备进阶字典ID
            local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
            -- 装备进阶字典表
            local equipAdvanceData = { }
            for key, obj in pairs(DictEquipAdvance) do
                if _dictEquipData.int["3"] == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
                    equipAdvanceData[#equipAdvanceData + 1] = obj
                end
            end
            utils.quickSort(equipAdvanceData, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
            if equipAdvanceId == 0 and(not dictEquipAdvanceData) then
                dictEquipAdvanceData = equipAdvanceData[1]
            end
            if equipAdvanceId >= 1000 and dictEquipAdvanceData then
                _equipQualityId = dictEquipAdvanceData.equipQualityId
                ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.big))
                ui_equipIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.RedbigUiId)].fileName)
            end
            for i = 1, 5 do
                local ui_starImg = ui_equipIcon:getParent():getChildByName("image_star" .. i)
                if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
                    ui_starImg:loadTexture("ui/star01.png")
                else
                    ui_starImg:loadTexture("ui/star02.png")
                end
                if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
                    ui_starImg:setVisible(false)
                else
                    ui_starImg:setVisible(true)
                end
            end
        else
            for i = 1, 5 do
                ui_equipIcon:getParent():getChildByName("image_star" .. i):loadTexture("ui/star02.png")
            end
        end

        local equipPropData = { }
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
            equipPropData[key] = utils.stringSplit(obj, "_")
            -- [1]:fightPropId, [2]:initValue, [3]:addValue
        end
        local propIndex, spaceH = 1, 3
        local equipPropItem = ui_equipPropPanel:getChildByName("text_base_property" .. propIndex)
        -- local ui_property_bian = ui_equipPropPanel:getChildByName("image_property_bian")
        local x, y = equipPropItem:getPosition()
        local childs = ui_equipPropPanel:getChildren()
        for i = 1, #childs do
            -- if i ~= propIndex and childs[i] ~= ui_property_bian then
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

            equipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. formula.getEquipAttribute(equipLv, initValue, addValue))
        end
        y = y + equipPropItem:getContentSize().height + spaceH
        -- ui_property_bian:setPosition(cc.p(ui_property_bian:getPositionX(), y))

        local function isContain(dictFightPropId)
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
            if obj.id == StaticFightProp.blood then
                -- 血
                index = 5
            elseif obj.id == StaticFightProp.wAttack then
                -- 物攻
                index = 2
            elseif obj.id == StaticFightProp.fAttack then
                -- 法攻
                index = 1
            elseif obj.id == StaticFightProp.dodge then
                -- 闪避
                index = 7
            elseif obj.id == StaticFightProp.crit then
                -- 暴击
                index = 6
            elseif obj.id == StaticFightProp.hit then
                -- 命中
                index = 8
            elseif obj.id == StaticFightProp.flex then
                -- 韧性
                index = 9
            elseif obj.id == StaticFightProp.wDefense then
                -- 物防
                index = 4
            elseif obj.id == StaticFightProp.fDefense then
                -- 法防
                index = 3
            end
            if index <= 5 then
                tempDictFightProp[index] = obj
            end
            -- tempDictFightProp[index] = obj
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

        local holeNums = { }
        for key, obj in pairs(DictHoleConsume) do
            if obj.qualityId == dictEquipData.equipQualityId then
                holeNums[obj.times + 1] = obj.num
            end
        end
        local inlayThingId = { }
        if net.InstEquipGem then
            for key, obj in pairs(net.InstEquipGem) do
                if _dictEquipData and _dictEquipData.int["1"] == obj.int["3"] then
                    inlayThingId[obj.int["5"]] = obj.int["4"]
                    -- 物品Id 0表示未镶嵌宝石
                end
            end
        end
        local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)]
        -- 装备品质字典表
        local holeNum = dictEquipQualityData.holeNum
        -- 拥有宝石孔数
        for key, uiItem in pairs(ui_inlayItems) do
            if key <= holeNum then
                uiItem:loadTexture("ui/low_small_white.png")
                uiItem:setVisible(true)
                local _icon = uiItem:getChildByName("image_gem")
                local _gemName = ccui.Helper:seekNodeByName(uiItem, "text_gem_name")
                local _gemProp = uiItem:getChildByName("text_gem_property")
                local _thingId = inlayThingId[key]
                if _thingId then
                    if _thingId == 0 then
                        -- 已打孔了
                        _gemName:setVisible(false)
                        _gemProp:setVisible(false)
                        _icon:loadTexture("ui/frame_tianjia.png")
                    else
                        -- 镶嵌了物品
                        _gemName:setVisible(true)
                        _gemProp:setVisible(true)
                        local dictThingData = DictThing[tostring(_thingId)]
                        _gemName:setString(dictThingData.name)
                        uiItem:loadTexture(utils.getThingQualityImg(dictThingData.bkGround))
                        _icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
                        _gemProp:setString("+" .. dictThingData.fightPropValue .. DictFightProp[tostring(dictThingData.fightPropId)].name)
                        utils.addThingParticle(StaticTableType.DictThing .. "_" .. _thingId, _icon, true)
                    end
                else
                    -- 未打孔
                    _gemName:setVisible(false)
                    _gemProp:setVisible(false)
                    _icon:loadTexture("ui/mg_suo.png")
                end
            else
                uiItem:setVisible(false)
            end
        end
        ui_equipDescribe:setString(dictEquipData.description)

        for i = 1, 4 do
            ui_inlayItems[i]:setTouchEnabled(false)
        end
    end
    if _equipQualityId == StaticEquip_Quality.white or _equipQualityId == StaticEquip_Quality.green then
        ui_equipIcon:getParent():getChildByName("text_title"):setVisible(false)
        for i = 1, 5 do
            ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(false)
        end
    else
        ui_equipIcon:getParent():getChildByName("text_title"):setVisible(true)
        for i = 1, 5 do
            ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(true)
            if i > 3 and _equipQualityId == StaticEquip_Quality.blue then
                ui_equipIcon:getParent():getChildByName("image_star" .. i):setVisible(false)
            end
        end
    end

    local imageInfo = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "image_equipment_new")

    local suitCount = 0
    local suitStarLvl = 5
	local suitRedStarLvl = 5
    local suitEquipData , suitEquipDataRed= nil
    if _equipInstId and _equipCardInstId and net.InstPlayerLineup then
        local _instFormationId = nil
        for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["3"] == _equipCardInstId then
                _instFormationId = key
                break
            end
        end
        local count = 0

        function addSuitCountAndStarLvl(equipId, isSuitEquip, starLvl, index)
            local iconLvl = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. index)
            local starLvlImg = iconLvl:getChildByName("image_lv")
            starLvlImg:setVisible(false)
            if isSuitEquip then
                if starLvl > 0 then
                    starLvlImg:setVisible(true)
                    starLvlImg:getChildByName("label_lv"):setString(tostring(starLvl))
                end
            end
            if _equipInstId ~= equipId and isSuitEquip then
                suitCount = suitCount + 1
            end
            -- cclog("startLevel : "..starLvl )
			local instEquipData = net.InstPlayerEquip[tostring(equipId)]
			local tempStarLevel = starLvl
			if instEquipData.int["8"] > 0 then
				local dictEquipAdvanceData = instEquipData.int["8"] >= 1000 and DictEquipAdvancered[tostring(instEquipData.int["8"])] or DictEquipAdvance[tostring(instEquipData.int["8"])]
				if dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.golden then
					if suitRedStarLvl > tempStarLevel then
						suitRedStarLvl = tempStarLevel
					end
					tempStarLevel = 5
                    cclog("tempStarLevel : "..tempStarLevel)
				else
					suitRedStarLvl = -1
				end
			else
				suitRedStarLvl = -1
			end
            if tempStarLevel < suitStarLvl then
                suitStarLvl = tempStarLevel
            end
        end
        cclog("suitEquipData  Id " .. tostring(net.InstPlayerEquip[tostring(_equipInstId)].int["4"]) .. " _equipInstId : " .. _equipInstId)
        suitEquipData , suitEquipDataRed = utils.getEquipSuit(tostring(net.InstPlayerEquip[tostring(_equipInstId)].int["4"]))
        if not suitEquipData then
            cclog("获取套装信息有误")
        end
        local suitEquipTable = utils.stringSplit(suitEquipData.suitEquipIdList, ";")

        ccui.Helper:seekNodeByName(imageInfo, "image_base_di_info"):getChildByName("text_hint"):setString(suitEquipData.name)
        for i = 1, 4 do
            local dictEquipData = DictEquipment[tostring(suitEquipTable[i])]
            -- 装备字典数据
            local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. i)
            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
            ccui.Helper:seekNodeByName(icon, "text_gem_name"):setString(dictEquipData.name)
            utils.showThingsInfo(icon, StaticTableType.DictEquipment, dictEquipData.id)
            local qualitySuperscriptImg = utils.getThingQualityImg(dictEquipData.equipQualityId)
            icon:loadTexture(qualitySuperscriptImg)
            utils.GrayWidget(icon, true)
            utils.GrayWidget(icon:getChildByName("image_gem"), true)
            icon:getChildByName("image_lv"):setVisible(false)

        end
        for key, obj in pairs(net.InstPlayerLineup) do
            -- cclog( " obj:"..obj.int["3"] .. "  ".._equipInstId .. "  "..obj.int["5"])
            if _instFormationId and tonumber(_instFormationId) == tonumber(obj.int["3"]) then
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

                local qualitySuperscriptImg = nil
                local equipStarLvl = 0
                if tonumber(instEquipData.int["8"]) > 0 then
                    local dictEquipAdvanceData = instEquipData.int["8"] >= 1000 and DictEquipAdvancered[tostring(instEquipData.int["8"])] or DictEquipAdvance[tostring(instEquipData.int["8"])]
                    -- 装备进阶字典表
                    equipStarLvl = dictEquipAdvanceData.starLevel
                    cclog("sssssssssssss equipQualityId : "..dictEquipAdvanceData.equipQualityId)
                    qualitySuperscriptImg = utils.getThingQualityImg(dictEquipAdvanceData.equipQualityId)
                end

                -- local _isShowHint = isHint(equipTypeId, instEquipId)
                if equipTypeId == StaticEquip_Type.outerwear then
                    -- 护甲
                    local isSuit = false
                    local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 2)
                    if instEquipData.int["8"] >= 1000 then
                        icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                    end
                    if qualitySuperscriptImg then
                        icon:loadTexture(qualitySuperscriptImg)
                    end
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[2]) then

                        utils.GrayWidget(icon, true)
                        utils.GrayWidget(icon:getChildByName("image_gem"), true)
                        isSuit = false
                    else

                        isSuit = true
                        utils.GrayWidget(icon, false)
                        utils.GrayWidget(icon:getChildByName("image_gem"), false)
                    end
                    utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 2)
                elseif equipTypeId == StaticEquip_Type.pants then
                    -- 头盔
                    local isSuit = false
                    local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 3)
                    if instEquipData.int["8"] >= 1000 then
                        icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                    end
                    if qualitySuperscriptImg then
                        icon:loadTexture(qualitySuperscriptImg)
                    end
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[3]) then

                        utils.GrayWidget(icon, true)
                        utils.GrayWidget(icon:getChildByName("image_gem"), true)
                        isSuit = false
                    else

                        utils.GrayWidget(icon, false)
                        utils.GrayWidget(icon:getChildByName("image_gem"), false)
                        isSuit = true
                    end
                    utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 3)
                elseif equipTypeId == StaticEquip_Type.necklace then
                    -- 饰品
                    local isSuit = false
                    local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 4)
                    if instEquipData.int["8"] >= 1000 then
                        icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                    end
                    if qualitySuperscriptImg then
                        icon:loadTexture(qualitySuperscriptImg)
                    end
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[4]) then

                        utils.GrayWidget(icon, true)
                        utils.GrayWidget(icon:getChildByName("image_gem"), true)
                        isSuit = false
                    else

                        utils.GrayWidget(icon, false)
                        utils.GrayWidget(icon:getChildByName("image_gem"), false)
                        isSuit = true
                    end
                    utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 4)
                elseif equipTypeId == StaticEquip_Type.equip then
                    -- 武器
                    local isSuit = false
                    local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 1)
                    if instEquipData.int["8"] >= 1000 then
                        icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                    end
                    if qualitySuperscriptImg then
                        icon:loadTexture(qualitySuperscriptImg)
                    end
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[1]) then

                        utils.GrayWidget(icon, true)
                        utils.GrayWidget(icon:getChildByName("image_gem"), true)
                        isSuit = false
                    else

                        utils.GrayWidget(icon, false)
                        utils.GrayWidget(icon:getChildByName("image_gem"), false)
                        isSuit = true
                    end
                    utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 1)
                end
                if count >= 4 then
                    break
                end
            end
        end
        -- cclog("suitCount :"..suitCount .. "  suitStarLvl :"..suitStarLvl )
    elseif _dictEquipId then

        suitEquipData , suitEquipDataRed = utils.getEquipSuit(tostring(_dictEquipId))
        if not suitEquipData then
            cclog("获取套装信息有误")
        end
        local suitEquipTable = utils.stringSplit(suitEquipData.suitEquipIdList, ";")

        ccui.Helper:seekNodeByName(imageInfo, "image_base_di_info"):getChildByName("text_hint"):setString(suitEquipData.name)
        for i = 1, 4 do
            local dictEquipData = DictEquipment[tostring(suitEquipTable[i])]
            -- 装备字典数据
            local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. i)
            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
            ccui.Helper:seekNodeByName(icon, "text_gem_name"):setString(dictEquipData.name)
            utils.showThingsInfo(icon, StaticTableType.DictEquipment, dictEquipData.id)
            local qualitySuperscriptImg = utils.getThingQualityImg(dictEquipData.equipQualityId)
            icon:loadTexture(qualitySuperscriptImg)

            icon:getChildByName("image_lv"):setVisible(false)
            --            local suitEquipData = utils.getEquipSuit(tostring( instEquipData.int["4"] ) )
            --            if suitEquipData then
            if DictEquipment[tostring(_dictEquipId)].equipTypeId == StaticEquip_Type.equip and i == 1 then
                utils.addFrameParticle(icon:getChildByName("image_gem"), true)
                utils.GrayWidget(icon, false)
                utils.GrayWidget(icon:getChildByName("image_gem"), false)
            elseif DictEquipment[tostring(_dictEquipId)].equipTypeId == StaticEquip_Type.outerwear and i == 2 then
                utils.addFrameParticle(icon:getChildByName("image_gem"), true)
                utils.GrayWidget(icon, false)
                utils.GrayWidget(icon:getChildByName("image_gem"), false)
            elseif DictEquipment[tostring(_dictEquipId)].equipTypeId == StaticEquip_Type.pants and i == 3 then
                utils.addFrameParticle(icon:getChildByName("image_gem"), true)
                utils.GrayWidget(icon, false)
                utils.GrayWidget(icon:getChildByName("image_gem"), false)
            elseif DictEquipment[tostring(_dictEquipId)].equipTypeId == StaticEquip_Type.necklace and i == 4 then
                utils.addFrameParticle(icon:getChildByName("image_gem"), true)
                utils.GrayWidget(icon, false)
                utils.GrayWidget(icon:getChildByName("image_gem"), false)
            else
                utils.addFrameParticle(icon:getChildByName("image_gem"), false)
                utils.GrayWidget(icon, true)
                utils.GrayWidget(icon:getChildByName("image_gem"), true)
            end
            --            end
        end

        if _dictEquipData then
            _equipCardInstId = _dictEquipData.int["6"]
            _equipInstId = _dictEquipData.int["4"]
            local _instFormationId = nil
            for key, obj in pairs(net.InstPlayerFormation) do
                if obj.int["3"] == _equipCardInstId then
                    _instFormationId = key
                    break
                end
            end
            local count = 0

            function addSuitCountAndStarLvl(equipId, isSuitEquip, starLvl, index)
                local iconLvl = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. index)
                local starLvlImg = iconLvl:getChildByName("image_lv")
                starLvlImg:setVisible(false)
                if isSuitEquip then
                    if starLvl > 0 then
                        starLvlImg:setVisible(true)
                        starLvlImg:getChildByName("label_lv"):setString(tostring(starLvl))
                    end
                end
                if _equipInstId ~= equipId and isSuitEquip then
                    suitCount = suitCount + 1
                end
                -- cclog("startLevel : "..starLvl )
                local instEquipData = net.InstPlayerEquip[tostring(equipId)]
			    local tempStarLevel = starLvl
			    if instEquipData.int["8"] > 0 then
				    local dictEquipAdvanceData = instEquipData.int["8"] >= 1000 and DictEquipAdvancered[tostring(instEquipData.int["8"])] or DictEquipAdvance[tostring(instEquipData.int["8"])]
				    if dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.golden then
					    if suitRedStarLvl > tempStarLevel then
						    suitRedStarLvl = tempStarLevel
					    end
					    tempStarLevel = 5
                        cclog("tempStarLevel : "..tempStarLevel)
				    else
					    suitRedStarLvl = -1
				    end
			    else
				    suitRedStarLvl = -1
			    end
                if tempStarLevel < suitStarLvl then
                    suitStarLvl = tempStarLevel
                end
            end
            for key, obj in pairs(net.InstPlayerLineup) do
                -- cclog( " obj:"..obj.int["3"] .. "  ".._equipInstId .. "  "..obj.int["5"])
                if _instFormationId and tonumber(_instFormationId) == tonumber(obj.int["3"]) then
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
                    local qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small)
                    local qualitySuperscriptImg = utils.getThingQualityImg(dictEquipData.equipQualityId)
                    local equipStarLvl = 0
                    if tonumber(instEquipData.int["8"]) > 0 then
                        local dictEquipAdvanceData = instEquipData.int["8"] >= 1000 and DictEquipAdvancered[tostring(instEquipData.int["8"])] or DictEquipAdvance[tostring(instEquipData.int["8"])]
                        -- 装备进阶字典表
                        equipStarLvl = dictEquipAdvanceData.starLevel
                        qualitySuperscriptImg = utils.getThingQualityImg(dictEquipAdvanceData.equipQualityId)
                    end

                    -- local _isShowHint = isHint(equipTypeId, instEquipId)
                    if equipTypeId == StaticEquip_Type.outerwear then
                        -- 护甲
                        local isSuit = false
                        local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 2)
                        if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[2]) then

                            utils.GrayWidget(icon, true)
                            utils.GrayWidget(icon:getChildByName("image_gem"), true)
                            isSuit = false
                        else

                            isSuit = true
                            utils.GrayWidget(icon, false)
                            utils.GrayWidget(icon:getChildByName("image_gem"), false)
                        end
                        if instEquipData.int["8"] >= 1000 then
                            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                        end
                        icon:loadTexture(qualitySuperscriptImg)
                        utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                        count = count + 1
                        addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 2)
                    elseif equipTypeId == StaticEquip_Type.pants then
                        -- 头盔
                        local isSuit = false
                        local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 3)
                        if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[3]) then

                            utils.GrayWidget(icon, true)
                            utils.GrayWidget(icon:getChildByName("image_gem"), true)
                            isSuit = false
                        else

                            utils.GrayWidget(icon, false)
                            utils.GrayWidget(icon:getChildByName("image_gem"), false)
                            isSuit = true
                        end
                        if instEquipData.int["8"] >= 1000 then
                            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                        end
                        icon:loadTexture(qualitySuperscriptImg)
                        utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                        count = count + 1
                        addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 3)
                    elseif equipTypeId == StaticEquip_Type.necklace then
                        -- 饰品
                        local isSuit = false
                        local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 4)
                        if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[4]) then

                            utils.GrayWidget(icon, true)
                            utils.GrayWidget(icon:getChildByName("image_gem"), true)
                            isSuit = false
                        else
                            utils.GrayWidget(icon, false)
                            utils.GrayWidget(icon:getChildByName("image_gem"), false)
                            isSuit = true
                        end
                        if instEquipData.int["8"] >= 1000 then
                            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                        end
                        icon:loadTexture(qualitySuperscriptImg)
                        utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                        count = count + 1
                        addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 4)
                    elseif equipTypeId == StaticEquip_Type.equip then
                        -- 武器
                        local isSuit = false
                        local icon = ccui.Helper:seekNodeByName(imageInfo, "image_frame_gem" .. 1)
                        if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[1]) then

                            utils.GrayWidget(icon, true)
                            utils.GrayWidget(icon:getChildByName("image_gem"), true)
                            isSuit = false
                        else
                            utils.GrayWidget(icon, false)
                            utils.GrayWidget(icon:getChildByName("image_gem"), false)
                            isSuit = true
                        end
                        if instEquipData.int["8"] >= 1000 then
                            icon:getChildByName("image_gem"):loadTexture("image/" .. DictUI[tostring(dictEquipData.RedsmallUiId)].fileName)
                        end
                        icon:loadTexture(qualitySuperscriptImg)
                        utils.addFrameParticle(icon:getChildByName("image_gem"), isSuit)
                        count = count + 1
                        addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 1)
                    end
                    if count >= 4 then
                        break
                    end
                end
            end
        end
    end


    for i = 2, 4 do
        local imageNum = ccui.Helper:seekNodeByName(imageInfo, "image_number" .. i)
        local info = imageNum:getChildByName("text_number")
        if i < 2 + suitCount then
            info:setTextColor(cc.c4b(0, 255, 255, 255))
        end
        local propStr = nil
        if i == 2 then
            propStr = suitEquipData.suit2NumProp
        elseif i == 3 then
            propStr = suitEquipData.suit3NumProp
        elseif i == 4 then
            propStr = suitEquipData.suit4NumProp
        end
        local propTable = utils.stringSplit(propStr, ";")
        for key, value in pairs(propTable) do
            local data = utils.stringSplit(value, "_")
            local imgProp = imageNum:getChildByName("text_property" .. key)
            if tonumber(data[2]) < 1 then
                imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" ..(tonumber(data[2]) * 100) .. "%")
            else
                imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" .. data[2])
            end
            if _dictEquipId then
                if _dictEquipData then
                    if i < 2 + suitCount then
                        imgProp:setTextColor(cc.c4b(0, 255, 255, 255))
                    end
                end
            else
                if i < 2 + suitCount then
                    imgProp:setTextColor(cc.c4b(0, 255, 255, 255))
                end
            end
            -- DictFightProp[tostring(StaticFightProp.blood)].name
        end
    end
    for i = 1, 5 do
        local imageStar = ccui.Helper:seekNodeByName(imageInfo, "image_star" .. i)
        local info = imageStar:getChildByName("text_number")
        info:setString(Lang.ui_equipment_new8..i ..Lang.ui_equipment_new9)
        if suitCount >= 4 and i < suitStarLvl then
            info:setTextColor(cc.c4b(0, 255, 255, 255))
        end
        local propStr = nil
        if i == 1 then
            propStr = suitEquipData.suit1StarProp
        elseif i == 2 then
            propStr = suitEquipData.suit2StarProp
        elseif i == 3 then
            propStr = suitEquipData.suit3StarProp
        elseif i == 4 then
            propStr = suitEquipData.suit4StarProp
        elseif i == 5 then
            propStr = suitEquipData.suit5StarProp
        end
        local propTable = utils.stringSplit(propStr, ";")
        for key, value in pairs(propTable) do
            local data = utils.stringSplit(value, "_")
            local imgProp = imageStar:getChildByName("text_property" .. key)
            if tonumber(data[2]) < 1 then
                imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" ..(tonumber(data[2]) * 100) .. "%")
            else
                imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" .. data[2])
            end
            if suitCount >= 3 and i <= suitStarLvl then
                imgProp:setTextColor(cc.c4b(0, 255, 255, 255))
                info:setTextColor(cc.c4b(0, 255, 255, 255))
            end
            -- DictFightProp[tostring(StaticFightProp.blood)].name
        end

        if _dictEquipId then
            if tonumber(DictEquipment[tostring(_dictEquipId)].equipQualityId) == 3 and i >= 4 then
                imageStar:setVisible(false)
            end
        else
            if tonumber(DictEquipment[tostring(net.InstPlayerEquip[tostring(_equipInstId)].int["4"])].equipQualityId) == 3 and i >= 4 then
                imageStar:setVisible(false)
            end
        end

    end
	for i = 1 , 6 do
		local imageStar = ccui.Helper:seekNodeByName(imageInfo, "image_star" .. ( 5 + i ) )
        local info = imageStar:getChildByName("text_number")
        info:setString(Lang.ui_equipment_new10..(i - 1) .. Lang.ui_equipment_new11)
--        info:setVisible( false ) --暂时关闭
		if suitEquipDataRed then
            propStr = suitEquipDataRed[string.format("Redsuit%dStarProp", i - 1)]
--			if i == 1 then
--				propStr = suitEquipDataRed.suit0StarProp
--			elseif i == 2 then
--				propStr = suitEquipDataRed.suit1StarProp
--			elseif i == 3 then
--				propStr = suitEquipDataRed.suit2StarProp
--			elseif i == 4 then
--				propStr = suitEquipDataRed.suit3StarProp
--			elseif i == 5 then
--				propStr = suitEquipDataRed.suit4StarProp
--			elseif i == 6 then
--				propStr = suitEquipDataRed.suit5StarProp
--			end
			local propTable = utils.stringSplit(propStr, ";")
            local imgProp1 = imageStar:getChildByName("text_property1")
			imgProp1:setVisible( false )
			local imgProp2 = imageStar:getChildByName("text_property2")
			imgProp2:setVisible( false )
			for key, value in pairs(propTable) do
				local data = utils.stringSplit(value, "_")
				local imgProp = imageStar:getChildByName("text_property" .. key)
                
				imgProp:setVisible( true )

--                imgProp:setVisible( false ) --暂时关闭
				if tonumber(data[2]) < 1 then
					imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" ..(tonumber(data[2]) * 100) .. "%")
				else
					imgProp:setString(DictFightProp[tostring(data[1])].name .. "+" .. data[2])
				end
				if suitCount >= 3 and 5 <= suitStarLvl and i - 1 <= suitRedStarLvl then
					imgProp:setTextColor(cc.c4b(0, 255, 255, 255))
					info:setTextColor(cc.c4b(0, 255, 255, 255))
				end
				-- DictFightProp[tostring(StaticFightProp.blood)].name
			end
		else
			imageStar:setVisible(false)
		end
	end
end

function UIEquipmentNew.free()
    _dictEquipId = nil
    _dictEquipData = nil
    _equipQualityId = nil
    UIGuidePeople.isGuide(nil, UIEquipmentNew)
end

function UIEquipmentNew.setEquipInstId(equipInstId, isPvp)
    _equipInstId = equipInstId
    _dictEquipId = nil
    _dictEquipData = nil
    _isPvp = isPvp
end

function UIEquipmentNew.setDictEquipId(dictEquipId, obj)
    _dictEquipId = dictEquipId
    _equipInstId = nil
    _dictEquipData = nil
    if obj then
        _dictEquipData = obj
    end
end
