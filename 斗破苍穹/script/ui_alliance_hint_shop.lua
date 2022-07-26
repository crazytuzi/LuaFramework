require"Lang"
UIAllianceHintShop = {}

local userData = nil

function UIAllianceHintShop.init()
end

function UIAllianceHintShop.setup()
    local btn_cancel = ccui.Helper:seekNodeByName(UIAllianceHintShop.Widget, "btn_cancel")
    local btn_ok = ccui.Helper:seekNodeByName(UIAllianceHintShop.Widget, "btn_ok")
    local btn_closed = ccui.Helper:seekNodeByName(UIAllianceHintShop.Widget, "btn_closed")
    btn_cancel:setPressedActionEnabled(true)
    btn_ok:setPressedActionEnabled(true)
    btn_closed:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_ok and userData.callbackFunc then
                userData.callbackFunc()
            end
            UIManager.popScene()
        end
    end
    btn_cancel:addTouchEventListener(onButtonEvent)
    btn_ok:addTouchEventListener(onButtonEvent)
    btn_closed:addTouchEventListener(onButtonEvent)
    local text_hint = ccui.Helper:seekNodeByName(UIAllianceHintShop.Widget, "text_hint")
    text_hint:setString(string.format(Lang.ui_alliance_hint_shop1, userData.consumeValue, userData.consumeName))
    local ui_frame = ccui.Helper:seekNodeByName(UIAllianceHintShop.Widget, "image_frame_good")
    local ui_icon = ui_frame:getChildByName("image_good")
    local ui_name = ui_frame:getChildByName("text_name")
    if userData.itemDetail then
        if userData.itemDetail.frameIcon then
            ui_frame:setTexture(userData.itemDetail.frameIcon)
        end
        if userData.itemDetail.smallIcon then
            ui_icon:setTexture(userData.itemDetail.smallIcon)
        end
        if userData.itemDetail.name then
            ui_name:setString(userData.itemDetail.name .. "×" .. userData.itemDetail.count)
        end
    end
end

function UIAllianceHintShop.free()
    userData = nil
end

function UIAllianceHintShop.show(_talbeParams)
    userData = _talbeParams
    UIManager.pushScene("ui_alliance_hint_shop")
end
