UIBagHint = {}

local userData = nil

function UIBagHint.init()

end

function UIBagHint.setup()
    local image_basemap = UIBagHint.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    local btn_out = image_basemap:getChildByName("btn_out")
    btn_sure:setPressedActionEnabled(true)
    btn_out:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            if sender == btn_sure then
                if userData and userData.sureCallFunc then
                    userData.sureCallFunc()
                end
            elseif sender == btn_out then
                if userData and userData.cancelCallFunc then
                    userData.cancelCallFunc()
                end
            end
        end
    end
    btn_sure:addTouchEventListener(onButtonEvent)
    btn_out:addTouchEventListener(onButtonEvent)
end

function UIBagHint.free()

end

function UIBagHint.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_bag_hint")
end