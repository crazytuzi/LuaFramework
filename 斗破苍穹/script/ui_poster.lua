require"Lang"
UIPoster = { }

local function doPay()
    local obj = DictRecharge[tostring(9)]
    local instActivityObj = UIActivityCard.getMonthCardData(UIActivityCard.GOLD_MONTH_CARD)
    if instActivityObj then
        if instActivityObj.string["4"] == "" then
            UIManager.showToast(Lang.ui_poster1)
        else
            if UIActivityPanel.isEndActivityByEndTime(instActivityObj.string["4"]) then
                UIGiftRecharge.doGetOrderID(obj)
            else
                UIManager.showToast(Lang.ui_poster2)
            end
        end
    else
        UIGiftRecharge.doGetOrderID(obj)
    end
end

function UIPoster.init()
    local image_hint = UIPoster.Widget:getChildByName("image_hint")
    local btn_closed = image_hint:getChildByName("btn_closed")
    local btn_go = image_hint:getChildByName("btn_go")
    btn_closed:setPressedActionEnabled(true)
    btn_go:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_go then
                utils.checkGOLD(1)
            end
        end
    end
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_go:addTouchEventListener(onButtonEvent)
end

function UIPoster.setup()
    local uiDatas = {
        { tableTypeId = 7, tableFieldId = 91 },
        { tableTypeId = 6, tableFieldId = 1 },
        { tableTypeId = 6, tableFieldId = 65 },
        { tableTypeId = 6, tableFieldId = 48 },
        { tableTypeId = 6, tableFieldId = 85 }
    }
    local ui_buttons = { }
    local image_hint = UIPoster.Widget:getChildByName("image_hint")
    -- 云韵
    ui_buttons[1] = image_hint:getChildByName("panel_ruolin")
    ui_buttons[2] = image_hint:getChildByName("panel_jian")
    ui_buttons[3] = image_hint:getChildByName("panel_lingyu")
    ui_buttons[4] = image_hint:getChildByName("panel_mingjia")
    ui_buttons[5] = image_hint:getChildByName("panel_guan")

    for key, uiItem in pairs(ui_buttons) do
        utils.showThingsInfo(uiItem, uiDatas[key].tableTypeId, uiDatas[key].tableFieldId)
        utils.addFrameParticle(uiItem, true)
    end
end

function UIPoster.free()

end

function UIPoster.show()
    UIManager.pushScene("ui_poster")
end
