require"Lang"
UIActivityVipWelfare = { }

local ui = UIActivityVipWelfare

local scrollViewDayItem
local scrollViewWeekItem

local DictVipDayGift = nil
local DictVipWeekGift = nil

local _countdownTime = 0

local function weekCountDown()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
        ui.reset()
        return
    end

    if ui.Widget and ui.Widget:getParent() then
        local text_time = ccui.Helper:seekNodeByName(ui.Widget, "text_time")
        local day = math.floor(_countdownTime /(24 * 3600) % 7)
        local hour = math.floor(_countdownTime / 3600 % 24)
        local minute = math.floor(_countdownTime / 60 % 60)
        local second = math.floor(_countdownTime % 60)
        text_time:setString(string.format(Lang.ui_activity_vip_welfare1, day, hour, minute, second))
    end
end

local function netCallbackFunc(pack)
    local msgdata = pack.msgdata
    if pack.header == StaticMsgRule.queryVipWelfare then
        DictVipDayGift = { }
        for k, v in pairs(msgdata.message.daily.message) do
            DictVipDayGift[v.int["2"]] = { id = v.int["1"], vipLevel = v.int["2"], things = v.string["3"] }
        end
        DictVipWeekGift = { }
        for k, v in pairs(msgdata.message.weekly.message) do
            DictVipWeekGift[v.int["2"] + 1] = { id = v.int["1"], vipLevel = v.int["2"], thing = v.string["3"], oldPrice = v.int["4"], curPrice = v.int["5"] }
        end

        ui.dailyIDs = { }
        for key, value in ipairs(utils.stringSplit(msgdata.string.dailyIDs, ";")) do
            if value ~= "" then
                ui.dailyIDs[tonumber(value)] = true
            end
        end
        ui.weeklyIDs = { }
        for key, value in ipairs(utils.stringSplit(msgdata.string.weeklyIDs, ";")) do
            if value ~= "" then
                ui.weeklyIDs[tonumber(value)] = true
            end
        end

        local maxVipLevel = 0
        for id, value in pairs(ui.dailyIDs) do
            for vipLevel, obj in pairs(DictVipDayGift) do
                if obj.id == id then
                    maxVipLevel = math.max(maxVipLevel, vipLevel)
                    break
                end
            end
        end

        if maxVipLevel > 0 then
            local t = os.date("*t")
            t = string.format("%d-%02d-%02d", t.year, t.month, t.day)
            local prefix = string.gsub(net.InstPlayer.string["2"], "@", "_")
            cc.UserDefault:getInstance():setStringForKey(prefix .. "vipWelfare", t .. "_" .. maxVipLevel)
        end

        local t = utils.getCurrentTime()
        local tab = os.date("*t", t)
        tab.hour = 0
        tab.min = 0
        tab.sec = 0
        local _endTime
        if tab.wday > 1 then
            _endTime = os.time(tab) + 24 * 60 * 60 *(9 - tab.wday)
        else
            _endTime = os.time(tab) + 24 * 60 * 60
        end
        _countdownTime = _endTime - t
        dp.addTimerListener(weekCountDown)

        ccui.Helper:seekNodeByName(ui.Widget, ui.dayOrWeek == 2 and "btn_week" or "btn_day"):releaseUpEvent()
    end
end

local function setScrollViewDayItem(item, obj)
    local text_title = item:getChildByName("text_title")
    local btn_exchange = item:getChildByName("btn_exchange")
    local image_get = item:getChildByName("image_get")
    local image_di = item:getChildByName("image_di")
    local things = utils.stringSplit(obj.things, ";")
    for i = 1, 4 do
        local image_frame_good = image_di:getChildByName("image_frame_good" .. i)
        if things[i] then
            image_frame_good:show()
            local image_good = image_frame_good:getChildByName("image_good")
            local text_price = image_frame_good:getChildByName("text_price")
            local itemProps = utils.getItemProp(things[i])
            text_price:setString("×" .. itemProps.count)
            image_good:loadTexture(itemProps.smallIcon)
            utils.addBorderImage(itemProps.tableTypeId, itemProps.tableFieldId, image_frame_good)
            utils.showThingsInfo(image_good, itemProps.tableTypeId, itemProps.tableFieldId)
        else
            image_frame_good:hide()
        end
    end
    text_title:enableOutline(cc.c4b(0x33, 0x19, 0x04, 255), 2)
    if obj.vipLevel > net.InstPlayer.int["19"] then
        image_get:hide()
        text_title:setString(string.format(Lang.ui_activity_vip_welfare2, obj.vipLevel, obj.limit * 10 - dp.rechargeGold))
        btn_exchange:show():setTitleText(Lang.ui_activity_vip_welfare3)
        btn_exchange:loadTextureNormal("ui/tk_btn01.png")
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                utils.checkGOLD(1)
            end
        end )
    else
        text_title:setString(string.format(Lang.ui_activity_vip_welfare4, obj.vipLevel))
        if ui.dailyIDs[obj.id] then
            image_get:show()
            btn_exchange:hide()
        else
            image_get:hide()
            btn_exchange:show():setTitleText(Lang.ui_activity_vip_welfare5)
            btn_exchange:loadTextureNormal("ui/tk_btn_red.png")
            btn_exchange:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    audio.playSound("sound/button.mp3")
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.getVipWelfareDaily, msgdata = { int = { dictId = obj.id } } }, function(pack)
                        utils.showGetThings(obj.things)
                        ui.dailyIDs[obj.id] = true
                        setScrollViewDayItem(item, obj)

                        local currentVipNum = net.InstPlayer.int["19"]
                        local btn_day = ccui.Helper:seekNodeByName(ui.Widget, "btn_day")
                        local showHint = not ui.dailyIDs[DictVipDayGift[currentVipNum].id]
                        btn_day:getChildByName("image_hint"):setVisible(showHint)
                        if ui.flushTitleHint then ui.flushTitleHint(showHint) end
                    end )
                end
            end )
        end
    end
end

local function setScrollViewWeekItem(item, obj)
    local text_title = item:getChildByName("text_title")
    local text_hint = item:getChildByName("text_hint")
    local btn_buy = item:getChildByName("btn_buy")
    local image_buy = item:getChildByName("image_buy")
    local image_di = item:getChildByName("image_di")
    local text_title_di = item:getChildByName("image_title_di"):getChildByName("text_title_di")
    local image_frame_good = image_di:getChildByName("image_frame_good")
    local image_gold_yuan = image_di:getChildByName("image_gold_yuan")
    local image_gold_xian = image_di:getChildByName("image_gold_xian")

    text_title:setString(string.format(Lang.ui_activity_vip_welfare6, obj.vipLevel))
    text_title:enableOutline(cc.c4b(0x33, 0x19, 0x04, 255), 2)

    text_hint:setString(string.format(Lang.ui_activity_vip_welfare7, obj.vipLevel))

    local image_good = image_frame_good:getChildByName("image_good")
    local text_number = image_frame_good:getChildByName("text_number")
    local itemProps = utils.getItemProp(obj.thing)
    text_number:setString("×" .. itemProps.count)
    image_good:loadTexture(itemProps.smallIcon)
    utils.addBorderImage(itemProps.tableTypeId, itemProps.tableFieldId, image_frame_good)
    utils.showThingsInfo(image_good, itemProps.tableTypeId, itemProps.tableFieldId)

    image_gold_yuan:getChildByName("text_gold_number"):setString(tostring(obj.oldPrice))
    image_gold_xian:getChildByName("text_gold_number"):setString(tostring(obj.curPrice))

    local value = 10 * math.max(obj.curPrice, 1) / math.max(obj.oldPrice, 1)
    value = string.gsub(string.format("%.1f", value), "%.0", "")
    text_title_di:setString(value .. Lang.ui_activity_vip_welfare8)

    if obj.vipLevel > net.InstPlayer.int["19"] then
        image_buy:hide()
        btn_buy:show():setTitleText(Lang.ui_activity_vip_welfare9)
        btn_buy:loadTextureNormal("ui/tk_btn01.png")
        btn_buy:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                utils.checkGOLD(1)
            end
        end )
    else
        if ui.weeklyIDs[obj.id] then
            image_buy:show()
            btn_buy:hide()
        else
            image_buy:hide()
            btn_buy:show():setTitleText(Lang.ui_activity_vip_welfare10)
            btn_buy:loadTextureNormal("ui/tk_btn_red.png")
            btn_buy:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    audio.playSound("sound/button.mp3")
                    if obj.curPrice > net.InstPlayer.int["5"] then
                        UIManager.showToast(Lang.ui_activity_vip_welfare11)
                        return
                    end
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.getVipWelfareWeekly, msgdata = { int = { dictId = obj.id } } }, function(pack)
                        utils.showGetThings(obj.thing)
                        ui.weeklyIDs[obj.id] = true
                        setScrollViewWeekItem(item, obj)
                    end )
                end
            end )
        end
    end
end

function ui.init()
    local btn_day = ccui.Helper:seekNodeByName(ui.Widget, "btn_day")
    local btn_week = ccui.Helper:seekNodeByName(ui.Widget, "btn_week")
    local image_arrow = ccui.Helper:seekNodeByName(ui.Widget, "image_arrow")

    image_arrow:setTouchEnabled(true)
    local afAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(image_arrow:getPositionX() + 30, image_arrow:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        image_arrow:setPositionX(image_arrow:getPositionX() -30)
        image_arrow:setOpacity(255)
    end )))
    image_arrow:runAction(afAction)

    local buttons = { btn_day, btn_week }

    local function selectButton(index)
        if ui.dayOrWeek == index then return end
        ui.dayOrWeek = index
        for i, button in ipairs(buttons) do
            if i == index then
                button:loadTextureNormal("ui/yh_btn02.png")
                button:getChildByName("text_day"):setTextColor(cc.c3b(0x33, 0x19, 0x04))
            else
                button:loadTextureNormal("ui/yh_btn01.png")
                button:getChildByName("text_day"):setTextColor(display.COLOR_WHITE)
            end
        end
        text_time = ccui.Helper:seekNodeByName(ui.Widget, "text_time")
        local view_good = ccui.Helper:seekNodeByName(ui.Widget, "view_good")
        view_good:removeAllChildren()
        local list

        local currentVipNum = net.InstPlayer.int["19"]
        local nextVipNum = currentVipNum + 1
        local limit = nil
        local vipLevel = 0
        if DictVIP[tostring(nextVipNum + 1)] then
            limit = DictVIP[tostring(nextVipNum + 1)].limit
            vipLevel = DictVIP[tostring(nextVipNum + 1)].level
        end
        if index == 1 then
            list = { }
            table.insert(list, DictVipDayGift[currentVipNum])
            if limit then
                local t = DictVipDayGift[currentVipNum + 1]
                t.limit = limit
                table.insert(list, t)
            end
            text_time:hide()

            local showHint = not ui.dailyIDs[DictVipDayGift[currentVipNum].id]
            btn_day:getChildByName("image_hint"):setVisible(showHint)
            if ui.flushTitleHint then ui.flushTitleHint(showHint) end
        elseif index == 2 then
            list = DictVipWeekGift
            text_time:show()
        end
        utils.updateScrollView(ui, view_good, index == 1 and scrollViewDayItem or scrollViewWeekItem, list, index == 1 and setScrollViewDayItem or setScrollViewWeekItem)
    end

    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_day then
                selectButton(1)
            elseif sender == btn_week then
                selectButton(2)
            elseif sender == image_arrow then
                UIManager.pushScene("ui_gift_vip")
            end
        end
    end

    btn_day:addTouchEventListener(touchEvent)
    btn_week:addTouchEventListener(touchEvent)
    image_arrow:addTouchEventListener(touchEvent)
end

function ui.reset()
    if ui.Widget and ui.Widget:getParent() then
        dp.removeTimerListener(weekCountDown)
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.queryVipWelfare, msgdata = { } }, netCallbackFunc)
    end
end

function ui.checkImageHint(showHintCallback)
    local t = os.date("*t")
    t = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local prefix = string.gsub(net.InstPlayer.string["2"], "@", "_")
    if showHintCallback then
        local value = cc.UserDefault:getInstance():getStringForKey(prefix .. "vipWelfare")
        if value ~= "" and string.sub(value, 1, #t) == t then
            value = utils.stringSplit(value, "_")
            showHintCallback(value[2] == "" or tonumber(value[2]) ~= net.InstPlayer.int["19"])
            return
        end
    end

    netSendPackage( { header = StaticMsgRule.queryVipWelfare, msgdata = { } }, function(pack)
        local msgdata = pack.msgdata
        if pack.header == StaticMsgRule.queryVipWelfare then
            local DictVipDayGift = { }
            for k, v in pairs(msgdata.message.daily.message) do
                DictVipDayGift[v.int["2"]] = { id = v.int["1"], vipLevel = v.int["2"], things = v.string["3"] }
            end

            local dailyIDs = { }
            for key, value in ipairs(utils.stringSplit(msgdata.string.dailyIDs, ";")) do
                if value ~= "" then
                    dailyIDs[tonumber(value)] = true
                end
            end

            local maxVipLevel = -1
            for id, value in pairs(dailyIDs) do
                for vipLevel, obj in pairs(DictVipDayGift) do
                    if obj.id == id then
                        maxVipLevel = math.max(maxVipLevel, vipLevel)
                        break
                    end
                end
            end

            if maxVipLevel >= 0 then
                cc.UserDefault:getInstance():setStringForKey(prefix .. "vipWelfare", t .. "_" .. maxVipLevel)
            end

            if showHintCallback then
                showHintCallback(maxVipLevel ~= net.InstPlayer.int["19"])
            end
        end
    end )
end

function ui.setup()
    local view_good = ccui.Helper:seekNodeByName(ui.Widget, "view_good")
    scrollViewDayItem = view_good:getChildByName("image_base_day"):clone()
    scrollViewDayItem:retain()
    scrollViewWeekItem = view_good:getChildByName("image_base_week"):clone()
    scrollViewWeekItem:retain()

    view_good:removeAllChildren()
    local text_time = ccui.Helper:seekNodeByName(ui.Widget, "text_time")
    text_time:hide()

    dp.removeTimerListener(weekCountDown)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.queryVipWelfare, msgdata = { } }, netCallbackFunc)
end

function ui.free()
    local view_good = ccui.Helper:seekNodeByName(ui.Widget, "view_good")
    view_good:removeAllChildren()
    if scrollViewDayItem and scrollViewDayItem:getReferenceCount() >= 1 then
        view_good:addChild(scrollViewDayItem)
        scrollViewDayItem:release()
        scrollViewDayItem = nil
    end
    if scrollViewWeekItem and scrollViewWeekItem:getReferenceCount() >= 1 then
        view_good:addChild(scrollViewWeekItem)
        scrollViewWeekItem:release()
        scrollViewWeekItem = nil
    end
    ui.dayOrWeek = nil
    ui.dailyIDs = nil
    ui.weeklyIDs = nil
    DictVipDayGift = nil
    DictVipWeekGift = nil
    ui.flushTitleHint = nil
    dp.removeTimerListener(weekCountDown)
end
