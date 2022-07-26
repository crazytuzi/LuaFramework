require"Lang"
UIActivityExchange = {
    activity =
    {
        { sname = "starStore", isView = false, thingData = nil },-- 星星兑换
        { sname = "levelSell", isView = false, thingData = nil },-- LV专卖
        { sname = "vipSell", isView = false, thingData = nil },-- VIP专享
        { sname = "monthCardStore", isView = false, thingData = nil },-- 月卡贵族
        { sname = "perfectVictory", isView = false, thingData = nil },-- 冲击完胜
    }
}

local SCROLLVIEW_ITEM_SPACE = 0

local ui_pageView = nil
local scrollViewCloneItems = { }

local _curPageViewIndex = nil
local _tempActivityDataIndex = nil
local _tempStarDataThings = nil
local _tempPerfectVictoryDataThings = nil

local function checkMoney(_buyType, _price, flag)
    if _buyType == UIHintBuy.MONEY_TYPE_STAR then
        local panel = ui_pageView:getPage(_curPageViewIndex)
        local image_star = panel:getChildByName("image_star")
        if image_star and tonumber(image_star:getChildByName("text_star_number"):getString()) >= _price then
            return true
        end
        if not flag then
            UIHintBuy.show(UIHintBuy.MONEY_TYPE_STAR)
        end
        return false
    else
        local _money = _buyType == 1 and net.InstPlayer.int["5"] or tonumber(net.InstPlayer.string["6"])
        if _money >= _price then
            return true
        else
            -- UIManager.showToast(string.format("%s不足！", (_buyType == 1 and "元宝" or "银币")))
            UIHintBuy.show(_buyType == 1 and UIHintBuy.MONEY_TYPE_GOLD or UIHintBuy.MONEY_TYPE_SILVER)
            return false
        end
    end
end
-- 章节是否通关
local function checkChapter(chapterId)
    local find = false
    for key, InstPlayerChapterObj in pairs(net.InstPlayerChapter) do
        if tonumber(InstPlayerChapterObj.int["3"]) == chapterId then
            if InstPlayerChapterObj.int["6"] == 1 then
                -- 判断普通章节是否通关
                find = true
            end
        end
    end
    return find
end

local function getActivityIndex()
    local panel = ui_pageView:getPage(_curPageViewIndex)
    if panel then
        return tonumber(utils.stringSplit(panel:getName(), "panel")[2])
    end
end

local function refreshMoney()
    local image_title = UIActivityExchange.Widget:getChildByName("image_title")
    local image_bian = image_title:getChildByName("image_bian")
    ccui.Helper:seekNodeByName(image_bian, "text_gold_number"):setString(tostring(net.InstPlayer.int["5"]))
    ccui.Helper:seekNodeByName(image_bian, "text_silver_number"):setString(net.InstPlayer.string["6"])
end

local function quickSort(data, _func1, _func2)
    if data then
        local _tempData1 = { }
        local _tempData2 = { }
        for key, obj in pairs(data) do
            if _func1(obj) then
                _tempData2[#_tempData2 + 1] = obj
            else
                _tempData1[#_tempData1 + 1] = obj
            end
        end
        -- if #_tempData2 > 0 then
        utils.quickSort(_tempData1, _func2)
        utils.quickSort(_tempData2, _func2)
        for i = 1, #data do
            data[i] = _tempData1[i] and _tempData1[i] or _tempData2[i - #_tempData1]
        end
        -- end
        _tempData1 = nil
        _tempData2 = nil
    end
end

local function layoutScrollView(_scrollView, _listData, _initItemFunc)
    local svItem = nil
    if _scrollView:getChildren()[1] then
        svItem = _scrollView:getChildren()[1]:clone()
    else
        svItem = scrollViewCloneItems[_scrollView:getName()]
    end
    scrollViewCloneItems[_scrollView:getName()] = svItem
    _scrollView:removeAllChildren()

    UIActivityExchange.isFlush = true
    utils.updateScrollView(UIActivityExchange, _scrollView, svItem, _listData, _initItemFunc, { setTag = true, space = SCROLLVIEW_ITEM_SPACE })
end

-- 判断是否是月卡用户
local function isMonthCardUser()
    local _tempActivityTime = nil
    if net.InstActivity and net.SysActivity then
        local _monthCardActivityId = nil
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "monthCard" then
                _monthCardActivityId = obj.int["1"]
                break
            end
        end
        for key, obj in pairs(net.InstActivity) do
            if obj.int["3"] == _monthCardActivityId then
                _tempActivityTime = obj.string["4"]
                break
            end
        end
    end
    if _tempActivityTime and string.len(_tempActivityTime) > 0 and utils.getCurrentTime() < utils.GetTimeByDate(_tempActivityTime) then
        return true
    else
        return false
    end
end

-- 获取购买次数
local function getBuyNums(_id)
    local _tempActivityTime = nil
    if net.InstActivity and net.SysActivity then
        local _monthCardActivityId = nil
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "starStore" then
                _monthCardActivityId = obj.int["1"]
                break
            end
        end
        for key, obj in pairs(net.InstActivity) do
            if obj.int["3"] == _monthCardActivityId then
                _tempActivityTime = obj.string["4"]
                break
            end
        end
    end
    if _tempActivityTime and string.len(_tempActivityTime) > 2 then
        if string.sub(_tempActivityTime, 1, 1) == ";" then
            _tempActivityTime = string.sub(_tempActivityTime, 2, string.len(_tempActivityTime))
        end
        if string.sub(_tempActivityTime, string.len(_tempActivityTime), string.len(_tempActivityTime)) == ";" then
            _tempActivityTime = string.sub(_tempActivityTime, 1, string.len(_tempActivityTime) -1)
        end
        local _tempData = utils.stringSplit(_tempActivityTime, ";")
        for key, obj in pairs(_tempData) do
            local _data = utils.stringSplit(obj, "_")
            -- [1]id, [2]nums
            if _id == tonumber(_data[1]) then
                return tonumber(_data[2])
            end
        end
    end
    return 0
end

local function getStarNums()
    if net.InstActivity and net.SysActivity then
        local _monthCardActivityId = nil
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "starStore" then
                _monthCardActivityId = obj.int["1"]
                break
            end
        end
        for key, obj in pairs(net.InstActivity) do
            if obj.int["3"] == _monthCardActivityId then
                return obj.int["6"]
            end
        end
    end
    return 0
end

local function initActivityTitle()
    local image_title = UIActivityExchange.Widget:getChildByName("image_title")
    local base_title = image_title:getChildByName("base_title"):getChildByName("view_title")
    local space = 27
    local _prevX = nil
    for key, obj in pairs(UIActivityExchange.activity) do
        local item = base_title:getChildByName("btn_base_" .. key)
        if obj.isView then
            item:setVisible(true)
            if _prevX then
                item:setPositionX(_prevX + space - 7 + item:getContentSize().width / 2)
            else
                item:setPositionX(space + item:getContentSize().width / 2)
            end
            _prevX = item:getRightBoundary()
        else
            item:setVisible(false)
        end
        if obj.sname == "perfectVictory" then
            utils.addImageHint(UIActivityExchange.checkPerfectVictoryImageHint(), item, 100, 10, 10, 100)
        end
        item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local _childs = ui_pageView:getPages()
                for _k, _o in pairs(_childs) do
                    if _o:getName() ==("panel" .. key) then
                        ui_pageView:scrollToPage(_k - 1)
                        break
                    end
                end
            end
        end )
    end
end

-- 星星兑换
local function starStore(data)
    local _activityIndex = getActivityIndex()

    if UIActivityExchange.activity[_activityIndex].thingData == nil then
        local _tempData = { }
        for key, obj in pairs(DictActivityStarStore) do
            _tempData[#_tempData + 1] = obj
        end
        UIActivityExchange.activity[_activityIndex].thingData = _tempData
        _tempData = nil
    end

    if data then
        local code = tonumber(data.header)
        refreshMoney()
        if code == StaticMsgRule.starStoreBuy then
            if _tempStarDataThings then
                utils.showGetThings(_tempStarDataThings)
                _tempStarDataThings = nil
            end
            UIActivityExchange.checkImageHint()
        end
    end

    local panel = ui_pageView:getPage(_curPageViewIndex)
    local _curStarCount = 0
    if net.InstPlayerAchievementValue then
        for key, obj in pairs(net.InstPlayerAchievementValue) do
            if DictAchievementType[tostring(obj.int["3"])].sname == "chapter" then
                _curStarCount = obj.int["4"]
                break
            end
        end
    end
    panel:getChildByName("image_star"):getChildByName("text_star_number"):setString(tostring(_curStarCount - getStarNums()))

    local scrollView = ccui.Helper:seekNodeByName(panel, "view_good")
    local activity = UIActivityExchange.activity[_activityIndex]
    quickSort(activity.thingData, function(obj) if obj.buyCount - getBuyNums(obj.id) <= 0 then return true end end, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
    -- utils.quickSort( activity.thingData , function(obj1, obj2) if obj1.rank > obj2.rank then return true end end )
    layoutScrollView(scrollView, activity.thingData, function(_item, _data)
        local itemProps = utils.getItemProp(_data.things)
        local ui_name = _item:getChildByName("text_title")
        -- ui_name:setTextColor(itemProps.qualityColor)
        ui_name:setString(itemProps.name)
        ui_name:enableOutline(cc.c4b(51, 25, 4, 255), 2)
        local _exchangeNums = _data.buyCount - getBuyNums(_data.id)
        _item:getChildByName("text_price_xian"):setString(string.format(Lang.ui_activity_exchange1, _exchangeNums))
        -- 	local ui_moneyImage = _item:getChildByName("image_gold_xian")
        -- 	ui_moneyImage:loadTexture(_data.buyType == 1 and "ui/jin.png" or "ui/yin.png") --1-元宝 2-银币
        -- 	ui_moneyImage:getChildByName("text_gold_number"):setString(tostring(_data.buyValue))
        local textImage = _item:getChildByName("image_di")
        textImage:getChildByName("text_condition"):setString(Lang.ui_activity_exchange2 .. DictChapter[tostring(_data.chapterId)].name .. Lang.ui_activity_exchange3)
        _item:getChildByName("image_star"):getChildByName("text_gold_number"):setString(tostring(_data.starNum))
        local ui_itemFrame = _item:getChildByName("image_frame_good")
        ui_itemFrame:loadTexture(itemProps.frameIcon)
        local ui_itemIcon = ui_itemFrame:getChildByName("image_good")
        ui_itemIcon:loadTexture(itemProps.smallIcon)
        ui_itemFrame:getChildByName("text_number"):setString("×" .. itemProps.count)
        utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
        local btn_exchange = _item:getChildByName("btn_exchange")
        btn_exchange:setTitleText(Lang.ui_activity_exchange4)
        local noEnoughImage = _item:getChildByName("image_wdc")
        noEnoughImage:setVisible(false)
        btn_exchange:setVisible(true)
        local _btnEnabled = true
        if _exchangeNums <= 0 then
            _btnEnabled = false
            btn_exchange:setTitleText(Lang.ui_activity_exchange5)
        elseif not checkChapter(tonumber(_data.chapterId)) then
            _btnEnabled = false
            btn_exchange:setVisible(false)
            noEnoughImage:setVisible(true)
        end

        btn_exchange:setBright(_btnEnabled)
        btn_exchange:setTouchEnabled(_btnEnabled)
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if checkMoney(UIHintBuy.MONEY_TYPE_STAR, _data.starNum) and checkChapter(tonumber(_data.chapterId)) then
                    UIManager.showLoading()
                    _tempStarDataThings = _data.things
                    netSendPackage( { header = StaticMsgRule.starStoreBuy, msgdata = { int = { starStoreId = _data.id } } }, starStore)
                end
            end
        end )
    end )
end

-- LV专卖
local function levelSell(data)
    local code = tonumber(data.header)
    local _activityIndex = getActivityIndex()
    if code == StaticMsgRule.getLvSell then
        local _tempData = { }
        local _msgData = utils.stringSplit(data.msgdata.string["1"], "/")
        for key, obj in pairs(_msgData) do
            local _listData = utils.stringSplit(obj, " ")
            _tempData[#_tempData + 1] = {
                id = tonumber(_listData[1]),
                level = tonumber(_listData[2]),
                things = _listData[3],
                nowPrice = tonumber(_listData[4]),
                limitNum = tonumber(_listData[5])-- 限购次数：0-已购买(*因为只能购买一次)
            }
        end
        UIActivityExchange.activity[_activityIndex].thingData = nil
        UIActivityExchange.activity[_activityIndex].thingData = _tempData
        _tempData = nil
    elseif code == StaticMsgRule.lvSellBuy then
        refreshMoney()
        if _tempActivityDataIndex and UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex] then
            local obj = UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex]
            utils.showGetThings(obj.things)
            obj.limitNum =(obj.limitNum - 1 < 0) and 0 or(obj.limitNum - 1)
            _tempActivityDataIndex = nil
        end
    end
    local activity = UIActivityExchange.activity[_activityIndex]
    quickSort(activity.thingData, function(obj) if obj.limitNum <= 0 then return true end end, function(obj1, obj2) if obj1.level > obj2.level then return true end end)
    local panel = ui_pageView:getPage(_curPageViewIndex)
    panel:getChildByName("image_basemap"):getChildByName("text_lv"):setString("LV." .. net.InstPlayer.int["4"])
    local scrollView = ccui.Helper:seekNodeByName(panel, "view_good")
    layoutScrollView(scrollView, activity.thingData, function(_item, _data)
        local _index = _item:getTag()
        local ui_goodFrame = _item:getChildByName("image_base_good")
        local ui_title = _item:getChildByName("text_title")
        ui_title:setString(string.format(Lang.ui_activity_exchange6, _data.level))
        ui_title:enableOutline(cc.c4b(51, 25, 4, 255), 2)
        _item:getChildByName("image_gold_xian"):getChildByName("text_gold_number"):setString(tonumber(_data.nowPrice))

        local things = utils.stringSplit(_data.things, ";")

        for i = 1, 4 do
            local ui_itemFrame = ui_goodFrame:getChildByName("image_frame_good" .. i)

            if things[i] then
                ui_itemFrame:show()
                local itemProps = utils.getItemProp(things[i])
                ui_itemFrame:loadTexture(itemProps.frameIcon)
                local ui_itemIcon = ui_itemFrame:getChildByName("image_good")
                ui_itemIcon:loadTexture(itemProps.smallIcon)
                ui_itemFrame:getChildByName("text_name"):setString(itemProps.name)
                ui_itemFrame:getChildByName("image_base_number"):getChildByName("text_number"):setString(tostring(itemProps.count))
                utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
            else
                ui_itemFrame:hide()
            end
        end

        local btn_exchange = _item:getChildByName("btn_prize")
        btn_exchange:setTitleText(Lang.ui_activity_exchange7)
        local _btnEnabled = true
        if _data.limitNum <= 0 then
            _btnEnabled = false
            btn_exchange:setTitleText(Lang.ui_activity_exchange8)
        end
        btn_exchange:setBright(_btnEnabled)
        btn_exchange:setTouchEnabled(_btnEnabled)
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if net.InstPlayer.int["4"] >= _data.level then
                    if checkMoney(1, _data.nowPrice) then
                        UIManager.showLoading()
                        _tempActivityDataIndex = _index
                        netSendPackage( { header = StaticMsgRule.lvSellBuy, msgdata = { int = { id = _data.id } } }, levelSell)
                    end
                else
                    UIHintBuy.show(UIHintBuy.MONEY_TYPE_LEVEL)
                end
            end
        end )
    end )
end

-- VIP专享
local function vipSell(data)
    local code = tonumber(data.header)
    local _activityIndex = getActivityIndex()
    if code == StaticMsgRule.getVipSell then
        local _tempData = { }
        local _msgData = utils.stringSplit(data.msgdata.string["1"], "/")
        for key, obj in pairs(_msgData) do
            local _listData = utils.stringSplit(obj, " ")
            _tempData[#_tempData + 1] = {
                id = tonumber(_listData[1]),
                vipLevel = tonumber(_listData[2]),
                things = _listData[3],
                oldPrice = tonumber(_listData[4]),
                nowPrice = tonumber(_listData[5]),
                limitNum = tonumber(_listData[6])-- 限购次数：0-已购买(*因为只能购买一次)
            }
        end
        UIActivityExchange.activity[_activityIndex].thingData = nil
        UIActivityExchange.activity[_activityIndex].thingData = _tempData
        _tempData = nil
    elseif code == StaticMsgRule.vipSellBuy then
        refreshMoney()
        if _tempActivityDataIndex and UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex] then
            local obj = UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex]
            utils.showGetThings(obj.things)
            obj.limitNum =(obj.limitNum - 1 < 0) and 0 or(obj.limitNum - 1)
            _tempActivityDataIndex = nil
        end
    end
    local activity = UIActivityExchange.activity[_activityIndex]
    quickSort(activity.thingData, function(obj) if obj.limitNum <= 0 then return true end end, function(obj1, obj2) if obj1.vipLevel > obj2.vipLevel then return true end end)
    local panel = ui_pageView:getPage(_curPageViewIndex)
    panel:getChildByName("image_basemap"):getChildByName("text_vip"):setString("VIP." .. net.InstPlayer.int["19"])
    local scrollView = ccui.Helper:seekNodeByName(panel, "view_good")
    layoutScrollView(scrollView, activity.thingData, function(_item, _data)
        local _index = _item:getTag()
        local ui_goodFrame = _item:getChildByName("image_frame_good")
        ui_goodFrame:getChildByName("image_good"):loadTexture("image/ui_snall_libao.png")
        local ui_title = _item:getChildByName("text_title")
        ui_title:setString(string.format(Lang.ui_activity_exchange9, _data.vipLevel))
        ui_title:enableOutline(cc.c4b(51, 25, 4, 255), 2)
        _item:getChildByName("image_di_info"):getChildByName("text_info"):setString(string.format(Lang.ui_activity_exchange10, _data.vipLevel))
        _item:getChildByName("text_price_xian"):setString(string.format(Lang.ui_activity_exchange11, _data.limitNum))
        _item:getChildByName("image_gold_yuan"):getChildByName("text_gold_number"):setString(tonumber(_data.oldPrice))
        _item:getChildByName("image_gold_xian"):getChildByName("text_gold_number"):setString(tonumber(_data.nowPrice))
        ui_goodFrame:setTouchEnabled(true)
        ui_goodFrame:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIAwardGet.setOperateType(UIAwardGet.operateType.giftBag, _data.things)
                UIManager.pushScene("ui_award_get")
            end
        end )
        local btn_exchange = _item:getChildByName("btn_exchange")
        btn_exchange:setTitleText(Lang.ui_activity_exchange12)
        local _btnEnabled = true
        if _data.limitNum <= 0 then
            _btnEnabled = false
            btn_exchange:setTitleText(Lang.ui_activity_exchange13)
        end
        btn_exchange:setBright(_btnEnabled)
        btn_exchange:setTouchEnabled(_btnEnabled)
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if net.InstPlayer.int["19"] >= _data.vipLevel then
                    if checkMoney(1, _data.nowPrice) then
                        UIManager.showLoading()
                        _tempActivityDataIndex = _index
                        netSendPackage( { header = StaticMsgRule.vipSellBuy, msgdata = { int = { id = _data.id } } }, vipSell)
                    end
                else
                    UIHintBuy.show(UIHintBuy.MONEY_TYPE_VIP)
                end
            end
        end )
    end )
end

-- 月卡贵族
local function monthCardStore(data)
    local code = tonumber(data.header)
    local _activityIndex = getActivityIndex()
    if code == StaticMsgRule.monthCardStore then
        local _tempData = { }
        for key, obj in pairs(data.msgdata.message.DictActivityMonthCardStoreTemp.message) do
            _tempData[#_tempData + 1] = obj
        end
        UIActivityExchange.activity[_activityIndex].thingData = nil
        UIActivityExchange.activity[_activityIndex].thingData = _tempData
        _tempData = nil
    elseif code == StaticMsgRule.monthCardStoreBuy then
        refreshMoney()
        if _tempActivityDataIndex and UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex] then
            local obj = UIActivityExchange.activity[_activityIndex].thingData[_tempActivityDataIndex]
            utils.showGetThings(obj.string["3"])
            obj.int["4"] =(obj.int["4"] -1 < 0) and 0 or(obj.int["4"] -1)
            _tempActivityDataIndex = nil
        end
    end
    local activity = UIActivityExchange.activity[_activityIndex]
    quickSort(activity.thingData, function(obj) if obj.int["4"] <= 0 then return true end end, function(obj1, obj2) if obj1.int["1"] > obj2.int["1"] then return true end end)
    local panel = ui_pageView:getPage(_curPageViewIndex)
    local image_hint_1 = panel:getChildByName("image_basemap"):getChildByName("image_hint_1")
    local image_hint_2 = panel:getChildByName("image_basemap"):getChildByName("image_hint_2")
    local _isMonthCardUser = isMonthCardUser()
    if _isMonthCardUser then
        image_hint_2:setVisible(false)
        image_hint_1:setVisible(true)
    else
        image_hint_1:setVisible(false)
        image_hint_2:setVisible(true)
    end
    local scrollView = ccui.Helper:seekNodeByName(panel, "view_good")
    layoutScrollView(scrollView, activity.thingData, function(_item, _data)
        local _index = _item:getTag()
        local _id = _data.int["1"]
        local _things = _data.string["3"]
        local _buyCount = _data.int["4"]
        local _buyType = _data.int["5"]
        local _nowPrice = _data.int["6"]
        local _oldPrice = _data.int["7"]
        -- local _vipLevel = _data.int["8"]
        local _giftBagName = _data.string["9"]
        local ui_name = _item:getChildByName("text_title")
        local ui_itemFrame = _item:getChildByName("image_frame_good")
        local ui_itemIcon = ui_itemFrame:getChildByName("image_good")
        local ui_itemNums = ui_itemFrame:getChildByName("text_number")
        local _isGiftBag = false
        -- 是否为礼包
        local _tempThings = utils.stringSplit(_things, ";")
        if #_tempThings > 1 then
            _isGiftBag = true
        end
        _tempThings = nil
        if _isGiftBag then
            ui_itemIcon:setTouchEnabled(true)
            ui_itemIcon:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    UIAwardGet.setOperateType(UIAwardGet.operateType.giftBag, _things)
                    UIManager.pushScene("ui_award_get")
                end
            end )
            ui_name:setString(_giftBagName)
            ui_itemFrame:loadTexture("ui/quality_small_purple.png")
            ui_itemIcon:loadTexture("image/ui_snall_libao.png")
            ui_itemNums:setVisible(false)
        else
            local itemProps = utils.getItemProp(_things)
            ui_name:setTextColor(itemProps.qualityColor)
            ui_name:setString(itemProps.name)
            ui_itemFrame:loadTexture(itemProps.frameIcon)
            ui_itemIcon:loadTexture(itemProps.smallIcon)
            utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
            ui_itemNums:setString("×" .. itemProps.count)
            ui_itemNums:setVisible(true)
        end
        ui_name:enableOutline(cc.c4b(51, 25, 4, 255), 2)

        _item:getChildByName("text_price_xian"):setString(Lang.ui_activity_exchange14 .. _buyCount)
        local ui_nowPrice = _item:getChildByName("image_gold_xian")
        local ui_oldPrice = _item:getChildByName("image_gold_yuan")
        local _buyTypeImg =(_buyType == 1 and "ui/jin.png" or "ui/yin.png")
        ui_nowPrice:loadTexture(_buyTypeImg)
        ui_oldPrice:loadTexture(_buyTypeImg)
        ui_nowPrice:getChildByName("text_gold_number"):setString(tostring(_nowPrice))
        ui_oldPrice:getChildByName("text_gold_number"):setString(tostring(_oldPrice))
        local btn_exchange = _item:getChildByName("btn_exchange")
        btn_exchange:setTitleText(Lang.ui_activity_exchange15)
        local _btnEnabled = true
        if _buyCount <= 0 then
            _btnEnabled = false
            btn_exchange:setTitleText(Lang.ui_activity_exchange16)
        end
        btn_exchange:setBright(_btnEnabled)
        btn_exchange:setTouchEnabled(_btnEnabled)
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if isMonthCardUser() then
                    if checkMoney(_buyType, _nowPrice) then
                        UIManager.showLoading()
                        _tempActivityDataIndex = _index
                        netSendPackage( { header = StaticMsgRule.monthCardStoreBuy, msgdata = { int = { monthCardStoreTempId = _id } } }, monthCardStore)
                    end
                else
                    UIHintBuy.show(UIHintBuy.MONEY_TYPE_MONTHCARD)
                end
            end
        end )
    end )
end

function UIActivityExchange.checkPerfectVictoryImageHint()
    local perfectNum = 0
    if net.InstPlayerBarrier then
        for k, v in pairs(net.InstPlayerBarrier) do
            if DictChapter[tostring(v.int["5"])].starNum >= 30 and v.int["6"] == 4 then
                perfectNum = perfectNum + 1
            end
        end
    end

    local instData
    if net.InstActivityPerfectVictory then
        for k, v in pairs(net.InstActivityPerfectVictory) do
            instData = v
        end
    end

    for key, _data in pairs(DictActivityPerfectVictory) do
        if perfectNum >= _data.id then
            if not instData or not string.find(instData.string["3"], "|" .. _data.id .. "|") then
                return true
            end
        end
    end

    return false
end

-- 冲击完胜
local function perfectVictory(data)
    local _activityIndex = getActivityIndex()

    if UIActivityExchange.activity[_activityIndex].thingData == nil then
        local _tempData = { }
        for key, obj in pairs(DictActivityPerfectVictory) do
            _tempData[#_tempData + 1] = obj
        end
        utils.quickSort(_tempData, function(key, other) if key.id > other.id then return true end end)
        UIActivityExchange.activity[_activityIndex].thingData = _tempData
        _tempData = nil
    end

    if data then
        local code = tonumber(data.header)
        if code == StaticMsgRule.perfectVictory then
            if _tempPerfectVictoryDataThings then
                utils.showGetThings(_tempPerfectVictoryDataThings)
                _tempPerfectVictoryDataThings = nil
                initActivityTitle()
            end
        end
    end

    local panel = ui_pageView:getPage(_curPageViewIndex)

    local perfectNum = 0
    for k, v in pairs(net.InstPlayerBarrier) do
        if DictChapter[tostring(v.int["5"])].starNum >= 30 and v.int["6"] == 4 then
            perfectNum = perfectNum + 1
        end
    end

    panel:getChildByName("image_basemap"):getChildByName("text_number"):setString("×" .. perfectNum)

    local scrollView = ccui.Helper:seekNodeByName(panel, "view_good")
    local activity = UIActivityExchange.activity[_activityIndex]
    layoutScrollView(scrollView, activity.thingData, function(_item, _data)

        _item:getChildByName("image_base_hint"):getChildByName("text_lv_number"):setString(tostring(_data.id))

        local things = utils.stringSplit(_data.things, ";")
        local image_base_good = _item:getChildByName("image_base_good")
        for i = 1, 4 do
            local ui_itemFrame = image_base_good:getChildByName("image_frame_good" .. i)

            if things[i] then
                ui_itemFrame:show()
                local itemProps = utils.getItemProp(things[i])
                ui_itemFrame:loadTexture(itemProps.frameIcon)
                local ui_itemIcon = ui_itemFrame:getChildByName("image_good")
                ui_itemIcon:loadTexture(itemProps.smallIcon)
                ui_itemFrame:getChildByName("text_name"):setString(itemProps.name)
                ui_itemFrame:getChildByName("image_base_number"):getChildByName("text_number"):setString(tostring(itemProps.count))
                utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
            else
                ui_itemFrame:hide()
            end
        end

        local btn_exchange = _item:getChildByName("btn_prize")
        local ylqImage = _item:getChildByName("ylq")
        local ylq = false
        if perfectNum >= _data.id then
            local instData
            if net.InstActivityPerfectVictory then
                for k, v in pairs(net.InstActivityPerfectVictory) do
                    instData = v
                end
            end

            if instData and string.find(instData.string["3"], "|" .. _data.id .. "|") then
                btn_exchange:hide()
                _btnEnabled = false
            else
                btn_exchange:show():setTitleText(Lang.ui_activity_exchange17)
                _btnEnabled = true
            end
        else
            btn_exchange:show():setTitleText(Lang.ui_activity_exchange18)
            _btnEnabled = false
        end

        if not btn_exchange:isVisible() then
            if not ylqImage then
                ylqImage = ccui.ImageView:create("ui/rw_ylq.png")
                ylqImage:setName("ylq")
                ylqImage:setPosition(cc.p(btn_exchange:getPosition()))
                _item:addChild(ylqImage)
            end
            ylqImage:show()
        elseif ylqImage then
            ylqImage:hide()
        end

        btn_exchange:setBright(_btnEnabled)
        btn_exchange:setTouchEnabled(_btnEnabled)
        btn_exchange:setPressedActionEnabled(true)
        if _btnEnabled then
            btn_exchange:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    UIManager.showLoading()
                    _tempPerfectVictoryDataThings = _data.things
                    netSendPackage( { header = StaticMsgRule.perfectVictory, msgdata = { int = { id = _data.id } } }, perfectVictory)
                end
            end )
        end
    end )
end

local function isActivity(sname)
    for _k, _activity in pairs(UIActivityExchange.activity) do
        if sname == _activity.sname then
            return true, _k
        end
    end
    return false
end

local function setActivityFocus()
    local image_title = UIActivityExchange.Widget:getChildByName("image_title")
    local base_title = image_title:getChildByName("base_title"):getChildByName("view_title")
    local _activityIndex = getActivityIndex()
    for key, obj in pairs(UIActivityExchange.activity) do
        local item = base_title:getChildByName("btn_base_" .. key)
        if key == _activityIndex then
            item:getChildByName("image_choose"):setVisible(true)
        else
            item:getChildByName("image_choose"):setVisible(false)
        end
    end
end

function UIActivityExchange.init()
    local image_title = UIActivityExchange.Widget:getChildByName("image_title")
    local image_recharge = image_title:getChildByName("image_recharge")
    image_recharge:setTouchEnabled(true)
    image_recharge:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            utils.checkGOLD(1)
        end
    end )

    local panels = { "panel1", "panel5" }
    for i, panel in ipairs(panels) do
        local panel1 = UIActivityExchange.Widget:getChildByName("view_all"):getChildByName(panel)
        local arrow_fight = panel1:getChildByName("image_basemap"):getChildByName("arrow_fight")
        local image_fight = panel1:getChildByName("image_basemap"):getChildByName("image_fight")
        image_fight:setTouchEnabled(true)
        image_fight:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIMenu.onFight(2)
            end
        end )
        local afAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(arrow_fight:getPositionX() + 30, arrow_fight:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
            arrow_fight:setPositionX(arrow_fight:getPositionX() -30)
            arrow_fight:setOpacity(255)
        end )))
        arrow_fight:runAction(afAction)
    end

    local panel4 = UIActivityExchange.Widget:getChildByName("view_all"):getChildByName("panel4")
    local image_hint_2 = panel4:getChildByName("image_basemap"):getChildByName("image_hint_2")
    local image_arrow_month = image_hint_2:getChildByName("image_arrow_month")
    local image_frame_month = image_hint_2:getChildByName("image_frame_month")
    image_frame_month:setTouchEnabled(true)
    image_frame_month:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIActivityPanel.scrollByName("monthCard", "monthCard")
            UIManager.showWidget("ui_activity_panel")
        end
    end )
    local iamAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(image_arrow_month:getPositionX() + 30, image_arrow_month:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        image_arrow_month:setPositionX(image_arrow_month:getPositionX() -30)
        image_arrow_month:setOpacity(255)
    end )))
    image_arrow_month:runAction(iamAction)
    local _weekStr = ""
    local _value = DictSysConfig[tostring(StaticSysConfig.monthCardStoreReset)].value
    if _value == 1 then
        _weekStr = Lang.ui_activity_exchange19
    elseif _value == 2 then
        _weekStr = Lang.ui_activity_exchange20
    elseif _value == 3 then
        _weekStr = Lang.ui_activity_exchange21
    elseif _value == 4 then
        _weekStr = Lang.ui_activity_exchange22
    elseif _value == 5 then
        _weekStr = Lang.ui_activity_exchange23
    elseif _value == 6 then
        _weekStr = Lang.ui_activity_exchange24
    elseif _value == 7 then
        _weekStr = Lang.ui_activity_exchange25
    end
    panel4:getChildByName("image_basemap"):getChildByName("text_day"):setString(_weekStr)

    local panel3 = UIActivityExchange.Widget:getChildByName("view_all"):getChildByName("panel3")
    local image_up = ccui.Helper:seekNodeByName(panel3, "image_up")
    local _pos = image_up:getParent():convertToWorldSpace(cc.p(image_up:getPosition()))
    local ui_upImage = image_up:clone()
    ui_upImage:setVisible(false)
    ui_upImage:setPosition(_pos.x - UIManager.screenSize.width * math.floor(_pos.x / UIManager.screenSize.width), _pos.y)
    UIActivityExchange.Widget:addChild(ui_upImage, image_title:getLocalZOrder() + 1)
    image_up:removeFromParent()
    image_up = nil

    ui_pageView = UIActivityExchange.Widget:getChildByName("view_all")
    ui_pageView:addEventListener( function(sender, eventType)
        if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
            _curPageViewIndex = sender:getCurPageIndex()
            setActivityFocus()
            local _activity = UIActivityExchange.activity[getActivityIndex()]
            if _activity.sname == "vipSell" then
                ui_upImage:setVisible(true)
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.getVipSell, msgdata = { } }, vipSell)
            else
                ui_upImage:setVisible(false)
                if _activity.sname == "levelSell" then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.getLvSell, msgdata = { } }, levelSell)
                elseif _activity.sname == "starStore" then
                    starStore()
                elseif _activity.sname == "perfectVictory" then
                    perfectVictory()
                elseif _activity.sname == "monthCardStore" then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.monthCardStore, msgdata = { } }, monthCardStore)
                end
            end
        end
    end )

    local arrowAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(ui_upImage:getPositionX(), ui_upImage:getPositionY() + 30)), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        ui_upImage:setPositionY(ui_upImage:getPositionY() -30)
        ui_upImage:setOpacity(255)
    end )))
    ui_upImage:runAction(arrowAction)
end

function UIActivityExchange.setup()
    local image_title = UIActivityExchange.Widget:getChildByName("image_title")
    local image_bian = image_title:getChildByName("image_bian")
    ccui.Helper:seekNodeByName(image_bian, "label_fight"):setString(tostring(utils.getFightValue()))
    refreshMoney()
    if net.SysActivity then
        DictActivity = { }
        for key, obj in pairs(net.SysActivity) do
            --            if 200 < obj.int["1"] and obj.int["1"] <= 300 then --无敌兑换的活动范围
            if 200 < obj.int["1"] and obj.int["1"] <= 300 and obj.string["9"] ~= UIActivityExchange.activity[3].sname then
                -- 关闭‘VIP专享’活动
                local _isActivity, _activityIndex = isActivity(obj.string["9"])
                if _isActivity and obj.int["8"] == 1 then
                    local _startTime = obj.string["4"]
                    local _endTime = obj.string["5"]
                    local _curTime = utils.getCurrentTime()
                    if (_startTime == "" and _endTime == "") or(utils.GetTimeByDate(_startTime) < _curTime and _curTime < utils.GetTimeByDate(_endTime)) then
                        UIActivityExchange.activity[_activityIndex].isView = true
                        DictActivity[_activityIndex] = obj
                    end
                end
            end
        end
    end
    for i = 1, #ui_pageView:getPages() do
        if not(UIActivityExchange.activity[i] and UIActivityExchange.activity[i].isView) then
            ui_pageView:removePage(ui_pageView:getChildByName("panel" .. i))
        end
    end
    initActivityTitle()
    ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        local view_title = ccui.Helper:seekNodeByName(UIActivityExchange.Widget, "view_title")
        local btn_base = view_title:getChildByName("btn_base_" ..(UIActivityExchange.startBase or 1))
        btn_base:releaseUpEvent()
        UIActivityExchange.startBase = nil
    end )))
    UIActivityExchange.checkImageHint()
end

function UIActivityExchange.checkStarStoreImageHint()
    local resultStar = false
    local activity = nil
    for key, obj in pairs(UIActivityExchange.activity) do
        if obj.sname == "starStore" then
            activity = obj
            break
        end
    end
    if activity.thingData == nil then
        local _tempData = { }
        for key, obj in pairs(DictActivityStarStore) do
            _tempData[#_tempData + 1] = obj
        end
        activity.thingData = _tempData
        _tempData = nil
    end
    local _curStarCount = 0
    if net.InstPlayerAchievementValue then
        for key, obj in pairs(net.InstPlayerAchievementValue) do
            if DictAchievementType[tostring(obj.int["3"])].sname == "chapter" then
                _curStarCount = obj.int["4"]
                break
            end
        end
    end
    _curStarCount = _curStarCount - getStarNums()
    for key, obj in pairs(activity.thingData) do
        local _exchangeNums = obj.buyCount - getBuyNums(obj.id)
        if _exchangeNums > 0 and _curStarCount >= obj.starNum and checkChapter(tonumber(obj.chapterId)) then
            resultStar = true
            break
        end
    end

    return resultStar
end

function UIActivityExchange.checkImageHint()
    local result = UIActivityExchange.checkStarStoreImageHint() or UIActivityExchange.checkPerfectVictoryImageHint()
    if UIActivityExchange.Widget then
        local item = UIActivityExchange.Widget:getChildByName("image_title"):getChildByName("base_title"):getChildByName("btn_base_1")
        utils.addImageHint(result, item, 100, 10, 10, 100)
    end
    return result
end

function UIActivityExchange.free()
    _curPageViewIndex = nil
    _tempActivityDataIndex = nil
    _tempStarDataThings = nil
    _tempPerfectVictoryDataThings = nil
    UIActivityExchange.startBase = nil
    UIActivityExchange.activity[1].thingData = nil
end
