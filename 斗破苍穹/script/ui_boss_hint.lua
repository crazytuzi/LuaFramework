require"Lang"
UIBossHint = {}

local userData = nil

function UIBossHint.init()
    UIBossHint.Widget:stopAllActions()
    local image_basemap = UIBossHint.Widget:getChildByName("image_basemap")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_closed:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
--            if userData and userData.callbackFunc then
--                userData.callbackFunc()
--                userData.callbackFunc = nil
--            end
        end
    end
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_sure:addTouchEventListener(onButtonEvent)
end

function UIBossHint.setup()
    local image_basemap = UIBossHint.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_hurt"):setString(Lang.ui_boss_hint1 .. userData.hurt)
    local image_di = image_basemap:getChildByName("image_di")
    local text_hint = ccui.Helper:seekNodeByName(image_di:getChildByName("image_base_di"), "text_hint")
    text_hint:setString(string.format(Lang.ui_boss_hint2, userData.attackCount))
    local _thingData = nil
    for key, obj in pairs(DictWorldBossTimesReward) do
        if userData.attackCount >= obj.startRank and (userData.attackCount <= obj.endRank or obj.endRank == -1) then
            _thingData = obj.rewardThings
            break
        end
    end
    if _thingData then
        local data = utils.stringSplit(_thingData, ";")
        for key, obj in pairs(data) do
            local thingItem = image_di:getChildByName("image_frame_good" .. key)
            if thingItem then
                local ui_icon = thingItem:getChildByName("image_good")
                local ui_name = ui_icon:getChildByName("text_name")
                local ui_count = ccui.Helper:seekNodeByName(thingItem, "text_number")
                local itemProps = utils.getItemProp(obj)
                if itemProps then
                    if itemProps.frameIcon then
                        thingItem:loadTexture(itemProps.frameIcon)
                    end
                    if itemProps.name then
                        ui_name:setString(itemProps.name)
                    end
                    if itemProps.smallIcon then
                        ui_icon:loadTexture(itemProps.smallIcon)
                    end
                    if itemProps.count then
                        ui_count:setString(tostring(itemProps.count))
                    end
                end
            end
        end
        data = nil
    end
    if userData.isAuto then
        local btn_sure = image_basemap:getChildByName("btn_sure")
        UIBossHint.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
            btn_sure:releaseUpEvent()
        end)))
    end
end

function UIBossHint.free()
    if userData and userData.callbackFunc then
        userData.callbackFunc()
        userData.callbackFunc = nil
    end
    userData = nil
end

function UIBossHint.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_boss_hint")
end
