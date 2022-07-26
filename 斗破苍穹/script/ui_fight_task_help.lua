require"Lang"
UIFightTaskHelp = { }

function UIFightTaskHelp.init()
    local image_basemap = UIFightTaskHelp.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_fight = image_basemap:getChildByName("btn_fight")
    btn_close:setPressedActionEnabled(true)
    btn_fight:setPressedActionEnabled(true)

    image_basemap:getChildByName("image_task3"):getChildByName("text_info"):setString(Lang.ui_fight_task_help1)
    image_basemap:getChildByName("text_info_perfect"):setString(Lang.ui_fight_task_help2)

    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close or sender == btn_fight then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(TouchEvent)
    btn_fight:addTouchEventListener(TouchEvent)
end

function UIFightTaskHelp.show(barrierLevelId)
    UIManager.pushScene("ui_fight_task_help")
    -- local text_info_perfect = ccui.Helper:seekNodeByName(UIFightTaskHelp.Widget, "text_info_perfect")
    -- text_info_perfect:setString(string.format(text_info_perfect:getString(), DictBarrierLevel[tostring(barrierLevelId)].waveNum))
    local level = DictBarrierLevel[tostring(barrierLevelId)].level
    local image_basemap = UIFightTaskHelp.Widget:getChildByName("image_basemap")
    for i = level + 1, 4 do
        if i == 4 then
            image_basemap:getChildByName("image_task_all"):hide()
            image_basemap:getChildByName("text_info_perfect"):hide()
        else
            image_basemap:getChildByName("image_task" .. i):hide()
        end
    end
end
