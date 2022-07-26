require"Lang"
UIActivityVip = { }

local ui = UIActivityVip

local scrollViewItem = nil

local function onBtnEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        audio.playSound("sound/button.mp3")
        local name = sender:getName()
        if name == "btn_sure" then
            utils.checkGOLD(1)
        else
            local id = sender:getTag()
            local dictVip = DictVIP[tostring(id)]
            if dictVip then
                local sendData = {
                    header = StaticMsgRule.getVipGiftBag,
                    msgdata =
                    {
                        int =
                        {
                            vipId = dictVip.id
                        }
                    }
                }
                UIManager.showLoading()
                netSendPackage(sendData, function(pack)
                    utils.showGetThings(dictVip.giftBagThings)
                    sender:setTouchEnabled(false)
                    sender:setTitleText(Lang.ui_activity_vip1)
                    sender:setBright(false)
                    if UIActivityVip.flushTitleHint then
                        ui.flushTitleHint(ui.checkImageHint())
                    end
                end )
            end
        end
    end
end

function ui.init()
    local btn_sure = ccui.Helper:seekNodeByName(ui.Widget, "btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(onBtnEvent)
end

local function setScrollViewItem(image_base_di, dictVip)
    local btn_get = image_base_di:getChildByName("btn_get")
    image_base_di:getChildByName("image_title"):getChildByName("text_title"):setString(string.format(Lang.ui_activity_vip2, dictVip.level))
    local _state = 0
    -- 0:未领取, 1:领取, 2:已领取
    if net.InstPlayer.int["19"] >= dictVip.level then
        _state = 1
    end
    local vipIds = utils.stringSplit(net.InstPlayer.string["33"], ";")
    if vipIds then
        for key, obj in pairs(vipIds) do
            if tonumber(obj) == dictVip.id then
                _state = 2
                break
            end
        end
    end
    if _state == 0 then
        btn_get:setTouchEnabled(false)
        btn_get:setTitleText(Lang.ui_activity_vip3)
        btn_get:setBright(false)
    elseif _state == 1 then
        btn_get:setTouchEnabled(true)
        btn_get:setTitleText(Lang.ui_activity_vip4)
        btn_get:setBright(true)
        btn_get:addTouchEventListener(onBtnEvent)
    elseif _state == 2 then
        btn_get:setTouchEnabled(false)
        btn_get:setTitleText(Lang.ui_activity_vip5)
        btn_get:setBright(false)
    end
    local things = utils.stringSplit(dictVip.giftBagThings, ";")
    for i = 1, 4 do
        local thingItem = image_base_di:getChildByName("image_frame_get_good" .. i)
        thingItem:setVisible(false)
        if things[i] then
            local tableData = utils.stringSplit(things[i], "_")
            local thingName, thingIcon = utils.getDropThing(tableData[1], tableData[2])
            thingItem:getChildByName("image_base_name"):getChildByName("text_number"):setString(thingName)
            thingItem:getChildByName("image_get_good"):loadTexture(thingIcon)
            thingItem:getChildByName("image_base_number"):getChildByName("text_number"):setString(tableData[3])
            utils.addBorderImage(tableData[1], tableData[2], thingItem)
            thingItem:setVisible(true)
            local thingIcon = thingItem:getChildByName("image_get_good")
            utils.showThingsInfo(thingIcon, tableData[1], tableData[2])
            utils.addFrameParticle(thingIcon, true)
        end
    end
    image_base_di:getChildByName("btn_get"):setTag(dictVip.id)
end

function ui.setup()
    scrollViewItem = ccui.Helper:seekNodeByName(ui.Widget, "image_base_di"):clone()
    scrollViewItem:retain()
    UIGiftVip.flushVipProgress(ui.Widget)
    local view = ccui.Helper:seekNodeByName(ui.Widget, "view")
    view:removeAllChildren()
    local vipData = { }
    for key, obj in pairs(DictVIP) do
        vipData[#vipData + 1] = obj
    end
    utils.quickSort(vipData, function(obj1, obj2) if obj1.level > obj2.level then return true end end)
    utils.updateScrollView(ui, view, scrollViewItem, vipData, setScrollViewItem, { space = 8 })
end

function ui.free()
    local view = ccui.Helper:seekNodeByName(ui.Widget, "view")
    view:removeAllChildren()
    if scrollViewItem and scrollViewItem:getReferenceCount() >= 1 then
        view:addChild(scrollViewItem)
        scrollViewItem:release()
        scrollViewItem = nil
    end
    UIActivityVip.flushTitleHint = nil
end

function ui.checkImageHint()
    if net.InstPlayer.string["33"] == "" then
        return false
    end

    local vipIds = utils.stringSplit(net.InstPlayer.string["33"], ";")

    for k, dictVip in pairs(DictVIP) do
        local _state = 0
        -- 0:未领取, 1:领取, 2:已领取
        if net.InstPlayer.int["19"] >= dictVip.level then
            _state = 1
        end
        for key, obj in pairs(vipIds) do
            if tonumber(obj) == dictVip.id then
                _state = 2
                break
            end
        end
        if _state == 1 then
            return true
        end
    end

    return false
end
