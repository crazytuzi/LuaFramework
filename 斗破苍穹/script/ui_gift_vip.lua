require"Lang"
UIGiftVip = { }

local ui_pageView = nil
local ui_pageViewItem = nil

local _curPageViewIndex = 0
local function netCallbackFunc(data)
    local id = ui_pageView:getPage(_curPageViewIndex):getTag()
    local dictVip = DictVIP[tostring(id)]
    utils.showGetThings(dictVip.giftBagThings)
    UIManager.flushWidget(UIHomePage)
    local btn_get = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_get")
    btn_get:setTouchEnabled(false)
    btn_get:setTitleText(Lang.ui_gift_vip1)
    btn_get:setBright(false)
end

local function cleanPageView(_isRelease)
    if _isRelease then
        if ui_pageViewItem and ui_pageViewItem:getReferenceCount() >= 1 then
            ui_pageViewItem:release()
            ui_pageViewItem = nil
        end
    else
        if ui_pageViewItem:getReferenceCount() == 1 then
            ui_pageViewItem:retain()
        end
    end
    ui_pageView:removeAllPages()
    ui_pageView:removeAllChildren()
end

local function setVipThing(sender)
    _curPageViewIndex = sender:getCurPageIndex()
    local id = sender:getPage(_curPageViewIndex):getTag()
    local dictVip = DictVIP[tostring(id)]
    local ui_vipTitle = ccui.Helper:seekNodeByName(sender:getPage(_curPageViewIndex), "text_title")
    ui_vipTitle:setString(string.format(Lang.ui_gift_vip2, dictVip.level))

    local image_base_di = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "image_base_di")
    local btn_get = image_base_di:getChildByName("btn_get")
    image_base_di:getChildByName("image_title"):getChildByName("text_title"):setString(string.format(Lang.ui_gift_vip3, dictVip.level))
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
        btn_get:setTitleText(Lang.ui_gift_vip4)
        btn_get:setBright(false)
    elseif _state == 1 then
        btn_get:setTouchEnabled(true)
        btn_get:setTitleText(Lang.ui_gift_vip5)
        btn_get:setBright(true)
    elseif _state == 2 then
        btn_get:setTouchEnabled(false)
        btn_get:setTitleText(Lang.ui_gift_vip6)
        btn_get:setBright(false)
    end
    local things = utils.stringSplit(dictVip.giftBagThings, ";")
    for i = 1, 4 do
        local thingItem = image_base_di:getChildByName("image_frame_get_good" .. i)
        thingItem:setVisible(false)
        if things[i] then
            local tableData = utils.stringSplit(things[i], "_")
            local thingName, thingIcon = utils.getDropThing(tableData[1], tableData[2])
            ccui.Helper:seekNodeByName(thingItem, "text_number1"):setString(thingName)
            thingItem:getChildByName("image_get_good1"):loadTexture(thingIcon)
            ccui.Helper:seekNodeByName(thingItem, "text_number"):setString(tableData[3])
            utils.addBorderImage(tableData[1], tableData[2], thingItem)
            thingItem:setVisible(true)
            local thingIcon = thingItem:getChildByName("image_get_good1")
            utils.showThingsInfo(thingIcon, tableData[1], tableData[2])
            utils.addFrameParticle(thingIcon, true)
        end
    end
end

function UIGiftVip.init()
    local btn_close = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_close")
    local btn_get = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_get")
    local btn_recharge = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_sure")
    ui_pageView = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "view_page")
    ui_pageViewItem = ui_pageView:getChildByName("panel"):clone()
    local btn_arrow_l = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_arrow_l")
    local btn_arrow_r = ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_arrow_r")
    btn_close:setPressedActionEnabled(true)
    btn_get:setPressedActionEnabled(true)
    btn_recharge:setPressedActionEnabled(true)
    btn_arrow_l:setPressedActionEnabled(true)
    btn_arrow_r:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_recharge then
                utils.checkGOLD(1)
            elseif sender == btn_get then
                local id = ui_pageView:getPage(_curPageViewIndex):getTag()
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
                    netSendPackage(sendData, netCallbackFunc)
                end
            elseif sender == btn_arrow_l then
                local index = ui_pageView:getCurPageIndex() -1
                if index < 0 then
                    index = 0
                end
                ui_pageView:scrollToPage(index)
            elseif sender == btn_arrow_r then
                local index = ui_pageView:getCurPageIndex() + 1
                if index > #ui_pageView:getPages() then
                    index = #ui_pageView:getPages()
                end
                ui_pageView:scrollToPage(index)
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_get:addTouchEventListener(onBtnEvent)
    btn_recharge:addTouchEventListener(onBtnEvent)
    btn_arrow_l:addTouchEventListener(onBtnEvent)
    btn_arrow_r:addTouchEventListener(onBtnEvent)


    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
            setVipThing(sender)
        end
    end
    ui_pageView:addEventListener(pageViewEvent)
end

function UIGiftVip.flushVipProgress(widget)
    local currentVipNum = net.InstPlayer.int["19"]
    local nextVipNum = currentVipNum + 1
    local limit = nil
    local _vipLevel = 0
    if DictVIP[tostring(nextVipNum + 1)] then
        limit = DictVIP[tostring(nextVipNum + 1)].limit
        _vipLevel = DictVIP[tostring(nextVipNum + 1)].level
    end
    local ui_label_vip = ccui.Helper:seekNodeByName(widget, "text_vip")
    local ui_text_loading = ccui.Helper:seekNodeByName(widget, "text_loading")
    local ui_loading = ccui.Helper:seekNodeByName(widget, "bar_loading")
    local ui_image_gold = ccui.Helper:seekNodeByName(widget, "image_gold")
    local ui_text_vip = ui_image_gold:getChildByName("text_vip")
    local ui_text_recharge = ui_image_gold:getChildByName("text_recharge")
    local ui_text_hint = ccui.Helper:seekNodeByName(widget, "text_hint")
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
        ui_text_vip:setString(string.format(Lang.ui_gift_vip7, nextVipNum))
        ui_text_recharge:setString(string.format(Lang.ui_gift_vip8, limit * 10 - dp.rechargeGold))
    else
        ui_text_loading:setString("MAX")
        ui_loading:setPercent(100)
        ui_image_gold:setVisible(false)
        ui_text_hint:setVisible(true)
    end
end

function UIGiftVip.setup()
    cleanPageView()

    UIGiftVip.flushVipProgress(UIGiftVip.Widget)

    local vipData = { }
    for key, obj in pairs(DictVIP) do
        if obj.giftBagThings ~= "" then
            vipData[#vipData + 1] = obj
        end
    end
    utils.quickSort(vipData, function(obj1, obj2) if obj1.level > obj2.level then return true end end)
    local vipLevel = net.InstPlayer.int["19"]

    for key, obj in pairs(vipData) do
        local pageViewItem = ui_pageViewItem:clone()
        pageViewItem:setTag(obj.id)
        local scrollView = ccui.Helper:seekNodeByName(pageViewItem, "view_info")
        local ui_text = scrollView:getChildByName("text_info")
        local line = 0
        for w in string.gmatch(obj.description, "\n") do
            line = line + 1
        end
        if utils.utf8len(obj.description) > 100 then
            ui_text:setContentSize(cc.size(450, 28 *(line + 1)))
            scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, 28 *(line + 1)))
            local posy = tonumber(scrollView:getInnerContainerSize().height) -20
            local x, y = ui_text:getPosition()
            ui_text:setPosition(cc.p(x, posy))
        end
        ui_text:setString(obj.description)
        local ui_vipTitle = ccui.Helper:seekNodeByName(pageViewItem, "text_title")
        local dictVip = DictVIP[tostring(obj.id)]
        ui_vipTitle:setString(string.format(Lang.ui_gift_vip9, dictVip.level))
        ui_pageView:addPage(pageViewItem)
    end
    setVipThing(ui_pageView)
    -- ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
    -- 	ui_pageView:scrollToPage(_curPageViewIndex)
    -- end)))

    local index = vipLevel
    if index > #ui_pageView:getPages() then
        index = #ui_pageView:getPages()
    end
    -- ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
    ui_pageView:scrollToPage(index)
    -- end)))
end

function UIGiftVip.hideRecharge()
    ccui.Helper:seekNodeByName(UIGiftVip.Widget, "btn_sure"):setVisible(false)
end

function UIGiftVip.free()
    cleanPageView(true)
end
------是否有领取的物品---------
function UIGiftVip.getState()
    for key, _obj in pairs(DictVIP) do
        if _obj.giftBagThings ~= "" then
            local _state1 = 0
            local _state2 = 0
            if net.InstPlayer.int["19"] >= _obj.level then
                _state1 = 1
            end
            local vipIds = utils.stringSplit(net.InstPlayer.string["33"], ";")
            if vipIds then
                for key, obj in pairs(vipIds) do
                    if tonumber(obj) == _obj.id then
                        _state2 = 2
                        break
                    end
                end
            end
            if _state1 == 1 and _state2 == 0 then
                return true
            end
        end
    end
end
