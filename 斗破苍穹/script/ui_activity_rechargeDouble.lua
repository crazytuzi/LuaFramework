require"Lang"
require "net"
require "SDK"

UIActivityRechargeDouble = {
    retList = nil,-- retList格式为  字典id_0;字典id_1;....最后没有分号 字典id后边的0和1：//0-未充过钱  1-充过钱
}
local scrollView = nil
local listItem = nil
local retListTab = nil

local function giftVipCallBack(pack)
    if pack.msgdata.int and pack.msgdata.int["1"] then
        dp.rechargeGold = pack.msgdata.int["1"]
    else
        return
    end

    UIManager.pushScene("ui_gift_vip")
    if UIGiftVip.Widget then
        UIGiftVip.hideRecharge()
    end
end

function UIActivityRechargeDouble.init(...)
    -- local btn_close = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "btn_close")
    local btn_sure = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "btn_sure")
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_sure then
                utils.checkGOLD(0, giftVipCallBack)
            end
        end
    end
    -- btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    -- btn_close:addTouchEventListener(TouchEvent)
    btn_sure:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "view")
    listItem = scrollView:getChildByName("image_base_di")
    listItem:retain()
end


local function setScrollViewItem(Item, obj)
    local ui_image = ccui.Helper:seekNodeByName(Item, "image_good")
    local ui_number = ccui.Helper:seekNodeByName(Item, "text_number")
    local ui_price = ccui.Helper:seekNodeByName(Item, "text_price")
    local ui_text_info = ccui.Helper:seekNodeByName(Item, "text_info")
    local ui_text_xiangou = ccui.Helper:seekNodeByName(Item, "text_xiangou")
    local imageName = DictUI[tostring(obj.uiId)].fileName
    ui_image:loadTexture("image/" .. imageName)
    ui_price:setString(obj.rmb .. Lang.ui_activity_rechargeDouble1)
    if SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" then
        if obj.firstAmt == 0 then
            ui_number:setString(obj.rmb .. Lang.ui_activity_rechargeDouble2)
        else
            ui_number:setString(obj.rmb * 10 .. Lang.ui_activity_rechargeDouble3)
        end
    else
        ui_number:setString(obj.rmb * 10 .. Lang.ui_activity_rechargeDouble4)
    end
    if tonumber(retListTab[obj.id]) ~= 0 then
        ui_text_info:setString(obj.noFirstAmtDes)
        ui_text_xiangou:setVisible(false)
    elseif obj.firstAmt == -1 then
        ui_text_info:setString(obj.noFirstAmtDes)
        ui_text_xiangou:hide()
    else
        ui_text_info:setString(obj.firstAmtDes)
        if obj.id == 1 or obj.id == 9 then
            ui_text_xiangou:setVisible(false)
        else
            ui_text_xiangou:setVisible(true)
        end
    end
    if IOS_PREVIEW then
        ui_text_xiangou:setVisible(false)
    end
    Item:setEnabled(true)
    Item:setTouchEnabled(true)
    local function chargeEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if obj.id == 1 or obj.id == 9 then
                -- if device.platform == "ios" then
                local type = obj.id == 1 and UIActivityCard.SILVER_MONTH_CARD or UIActivityCard.GOLD_MONTH_CARD
                local name = obj.id == 1 and Lang.ui_activity_rechargeDouble5 or Lang.ui_activity_rechargeDouble6
                local instActivityObj = UIActivityCard.getMonthCardData(type)
                if instActivityObj then
                    if instActivityObj.string["4"] == "" then
                        UIManager.showToast(Lang.ui_activity_rechargeDouble7 .. name .. Lang.ui_activity_rechargeDouble8)
                    else
                        if UIActivityPanel.isEndActivityByEndTime(instActivityObj.string["4"]) then
                            UIGiftRecharge.doGetOrderID(obj)
                        else
                            UIManager.showToast(Lang.ui_activity_rechargeDouble9 .. name .. Lang.ui_activity_rechargeDouble10)
                        end
                    end
                else
                    UIGiftRecharge.doGetOrderID(obj)
                end
                -- else
                --     UIGiftRecharge.doGetOrderID(obj)
                --     -- UIManager.showToast("暂未开放!")
                -- end
            else
                UIGiftRecharge.doGetOrderID(obj)
            end
        end
    end
    Item:addTouchEventListener(chargeEvent)
end

function UIActivityRechargeDouble.setup(...)
    local function chargeCallBack(pack)
        if pack.msgdata.int and pack.msgdata.int["1"] then
            dp.rechargeGold = pack.msgdata.int["1"]
        else
            return
        end
        if pack.msgdata.string and pack.msgdata.string["2"] then
            UIActivityRechargeDouble.retList = pack.msgdata.string["2"]
        else
            return
        end
        scrollView:removeAllChildren()
        -- if UIGiftVip.getState() then
        -- 	ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "image_hint"):setVisible(true)
        -- else
        ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "image_hint"):setVisible(false)
        -- end
        local currentVipNum = net.InstPlayer.int["19"]
        local nextVipNum = currentVipNum + 1
        local limit = nil
        if DictVIP[tostring(nextVipNum + 1)] then
            limit = DictVIP[tostring(nextVipNum + 1)].limit
        end
        local ui_label_vip = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "text_vip")
        local ui_text_loading = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "text_loading")
        local ui_loading = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "bar_loading")
        local ui_image_gold = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "image_gold")
        local ui_text_vip = ui_image_gold:getChildByName("text_vip")
        local ui_text_recharge = ui_image_gold:getChildByName("text_recharge")
        local ui_text_hint = ccui.Helper:seekNodeByName(UIActivityRechargeDouble.Widget, "text_hint")
        ui_label_vip:setString(currentVipNum)
        if limit then
            ui_image_gold:setVisible(true)
            ui_text_hint:setVisible(false)
            ui_text_loading:setString(string.format("%d/%d", dp.rechargeGold, limit * 10))
            local number = dp.rechargeGold /(limit * 10) * 100
            if number > 100 then
                ui_loading:setPercent(100)
            else
                ui_loading:setPercent(number)
            end
            ui_text_vip:setString(string.format(Lang.ui_activity_rechargeDouble11, nextVipNum))
            ui_text_recharge:setString(string.format(Lang.ui_activity_rechargeDouble12, limit * 10 - dp.rechargeGold))
        else
            ui_text_loading:setString("MAX")
            ui_loading:setPercent(100)
            ui_image_gold:setVisible(false)
            ui_text_hint:setVisible(true)
        end
        if UIActivityRechargeDouble.retList then
            retListTab = { }
            local _retListTab = utils.stringSplit(UIActivityRechargeDouble.retList, ";")
            for key, obj in pairs(_retListTab) do
                local strTab = utils.stringSplit(obj, "_")
                table.insert(retListTab, strTab[1], strTab[2])
            end
        end
        local rechargeThing = { }
        for key, obj in pairs(DictRecharge) do
            table.insert(rechargeThing, obj)
        end
        utils.quickSort(rechargeThing, function(obj1, obj2)
            local rmb1 = obj1.firstAmt == 0 and obj1.rmb - 10000 or obj1.rmb
            local rmb2 = obj2.firstAmt == 0 and obj2.rmb - 10000 or obj2.rmb
            return rmb1 > rmb2
        end )
        if listItem then
            cclog(".....listItem : " .. listItem:getContentSize().height)
        end
        utils.updateView(UIActivityRechargeDouble, scrollView, listItem, rechargeThing, setScrollViewItem)

    end
    utils.checkGOLD(1, chargeCallBack)
end

function UIActivityRechargeDouble.free()
    scrollView:removeAllChildren()
    retListTab = nil
    UIActivityRechargeDouble.retList = nil
end

function UIActivityRechargeDouble.checkImageHint()
    return true
end
