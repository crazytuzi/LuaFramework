require"Lang"
UIPilltowerBlood = {}

local userData = nil

function UIPilltowerBlood.init()
    local image_hint = UIPilltowerBlood.Widget:getChildByName("image_hint")
    local btn_sure = image_hint:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if userData.isRefreshBlood then
                UIPilltowerEmbattle.refreshCardBlood()
            end
            UIManager.popScene()
        end
    end)
end

function UIPilltowerBlood.setup()
    local image_hint = UIPilltowerBlood.Widget:getChildByName("image_hint")
    local image_pilltower = image_hint:getChildByName("image_pilltower")
    local firstUseCount = DictSysConfig[tostring(StaticSysConfig.FirstUseStar)].value --先手消耗数量
    local medalCount = userData.isFirst and (UIPilltower.UserData.medalCount - firstUseCount) or UIPilltower.UserData.medalCount
    image_pilltower:getChildByName("text_number"):setString("×" .. medalCount)
    for i = 1, 9 do
        local itemPanel = image_hint:getChildByName("imag_di_card"..i)
        local _data = UIPilltower.UserData.myCardData[i]
        if _data then
            local ui_cardFrame = itemPanel:getChildByName("image_frame_card")
            local ui_cardIcon = ui_cardFrame:getChildByName("image_card")
            local barPanel = itemPanel:getChildByName("image_loading")
            local ui_cardName = barPanel:getChildByName("text_name")
            local ui_bloodBar = barPanel:getChildByName("bar_loading")
            local ui_bloodPercent = barPanel:getChildByName("text_number")
            local medalPanel = itemPanel:getChildByName("image_di_info")
            local ui_medalNum = ccui.Helper:seekNodeByName(medalPanel, "text_number")

            local instCardData = net.InstPlayerCard[tostring(_data.instCardId)]
            local dictCard = DictCard[tostring(instCardData.int["3"])]
            ui_cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
            ui_cardIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            ui_cardName:setString(dictCard.name)
            local totalBlood = math.floor(utils.getCardAttribute(_data.instCardId)[StaticFightProp.blood])
            local currentBlood = (_data.cardBlood > totalBlood) and totalBlood or _data.cardBlood
            ui_bloodBar:setPercent(currentBlood / totalBlood * 100)
            ui_bloodPercent:setString(math.floor(ui_bloodBar:getPercent()) .. "%")
            local _state = nil --0:复活，1:加血
            local _useMedal = 0 --所需勋章数
            if ui_bloodBar:getPercent() == 100 then --满状态
                itemPanel:setColor(cc.c3b(160,160,160))
                itemPanel:setTouchEnabled(false)
                ui_medalNum:setString("×0")
            elseif ui_bloodBar:getPercent() == 0 then --复活
                _state = 0
                itemPanel:setTouchEnabled(true)
                _useMedal = DictSysConfig[tostring(StaticSysConfig.LifeUseStar)].value
                ui_medalNum:setString("×".._useMedal)
            else --加血
                _state = 1
                itemPanel:setTouchEnabled(true)
                _useMedal = DictSysConfig[tostring(StaticSysConfig.BloodUseStar)].value
                ui_medalNum:setString("×".._useMedal)
            end
            itemPanel:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    itemPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.9), cc.ScaleTo:create(0.1, 1)))
                elseif eventType == ccui.TouchEventType.ended then
                    if medalCount >= _useMedal then
                        itemPanel:setTouchEnabled(false)
                        local ui_anim = ActionManager.getEffectAnimation(44, function(armature)
                            if armature:getParent() then armature:removeFromParent() end
                        end)
                        ui_anim:setPosition(ui_cardFrame:getContentSize().width / 2, ui_cardFrame:getContentSize().height / 2)
                        ui_cardFrame:addChild(ui_anim)
                        local _add = 1
                        if ui_bloodBar:getPercent() < 50 then _add = 2 end
                        sender:scheduleUpdateWithPriorityLua(function()
                            local _percent = ui_bloodBar:getPercent() + _add
                            if _percent > 100 then _percent = 100 end
                            ui_bloodBar:setPercent(math.floor(_percent))
                            ui_bloodPercent:setString(math.floor(_percent).."%")
                            if _percent >= 100 then
                                sender:unscheduleUpdate()
                            end
                        end, 0)

                        UIPilltower.UserData.medalCount = UIPilltower.UserData.medalCount - _useMedal
                        medalCount = medalCount - _useMedal
                        UIPilltower.UserData.myCardData[i].cardBlood = totalBlood
--                        ui_bloodBar:setPercent(100)
--                        ui_bloodPercent:setString("100%")
                        image_pilltower:getChildByName("text_number"):setString("×" .. medalCount)
                        userData.isRefreshBlood = true
                    else
                        UIManager.showToast(Lang.ui_pilltower_blood1)
                    end
                end
            end)
        else
            itemPanel:setVisible(false)
        end
    end
end

function UIPilltowerBlood.free()
    userData = nil
end

function UIPilltowerBlood.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_pilltower_blood")
end
