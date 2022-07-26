require"Lang"
UIActivityNormalExchange = { }

local ui_scrollView = nil
local ui_svItem = nil
local DictActivity = nil

local function cleanScrollView()
    if ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    ui_scrollView:removeAllChildren()
end

local function layoutScrollView(_listData, _initItemFunc)
    cleanScrollView()
    utils.updateScrollView(UIActivityNormalExchange, ui_scrollView, ui_svItem, _listData, _initItemFunc, { space = 10 })
end

local function setScrollViewItem(_item, _data)
    if _data == nil then
        return cclog(Lang.ui_activity_normalExchange1)
    end
    local _tempData = utils.stringSplit(_data, "|")
    -- id|costItem|getItem|countLimit
    local itemData = nil
    if _tempData and #_tempData >= 4 then
        itemData = {
            id = tonumber(_tempData[1]),
            costItem = _tempData[2],
            getItem = _tempData[3],
            countLimit = tonumber(_tempData[4]),
            exchangeCount = tonumber(_tempData[5])
        }
    end
    _tempData = nil
    if itemData then
        local text_time = _item:getChildByName("image_base_hint"):getChildByName("text_time")
        if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
            local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
            local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
            text_time:setString(string.format(Lang.ui_activity_normalExchange2,
            _startTime[2], _startTime[3], _startTime[5], _startTime[6], _endTime[2], _endTime[3], _endTime[5], _endTime[6]))
        else
            text_time:setString(Lang.ui_activity_normalExchange3)
        end
        local thingItems = { }
        for i = 1, 4 do
            thingItems[4 + 1 - i] = _item:getChildByName("image_frame_good" .. i)
        end
        local thingsData = utils.stringSplit(itemData.costItem, ";")

        local convertNum = itemData.countLimit - itemData.exchangeCount
        for i, thingItem in pairs(thingItems) do
            local _thingName = thingItem:getChildByName("text_name")
            local _thingIcon = thingItem:getChildByName("image_good")
            if thingsData[i] then
                local itemProps = utils.getItemProp(thingsData[i], nil, true)
                if itemProps.name then
                    _thingName:show():setString(itemProps.name .. "\n" ..(itemProps.playerCount or 0) .. "/" .. itemProps.count)
                else
                    _thingName:show():setString("")
                end
                if itemProps.smallIcon then
                    _thingIcon:loadTexture(itemProps.smallIcon)
                    _thingIcon:setTouchEnabled(true)
                    utils.showThingsInfo(_thingIcon, itemProps.tableTypeId, itemProps.tableFieldId)
                    utils.addParticleEffect(thingItem, itemProps.playerCount >= itemProps.count, { anchorSize = 14, offset = 7 })
                else
                    utils.addParticleEffect(thingItem, false)
                end
                if itemProps.frameIcon then
                    thingItem:loadTexture(itemProps.frameIcon)
                end
                convertNum = math.min(convertNum, math.floor(itemProps.playerCount / itemProps.count))
            else
                _thingIcon:loadTexture("ui/mg_suo.png")
                _thingIcon:setTouchEnabled(false)
                _thingName:setVisible(false)
                utils.addParticleEffect(thingItem, false)
            end
        end
        local giftItem = _item:getChildByName("image_frame_gift")
        local text_hint = giftItem:getChildByName("text_hint")
        local btn_exchange = giftItem:getChildByName("btn_exchange")
        local _giftName = giftItem:getChildByName("text_name")
        local _giftIcon = giftItem:getChildByName("image_gift")
        local itemProps = utils.getItemProp(itemData.getItem)
        if itemProps.name then
            _giftName:setString(itemProps.name .. "\n×" .. itemProps.count)
        end
        if itemProps.smallIcon then
            _giftIcon:loadTexture(itemProps.smallIcon)
            utils.showThingsInfo(_giftIcon, itemProps.tableTypeId, itemProps.tableFieldId)
        end
        if itemProps.frameIcon then
            giftItem:loadTexture(itemProps.frameIcon)
        end
        text_hint:setString(Lang.ui_activity_normalExchange4 .. itemData.countLimit - itemData.exchangeCount)
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local maxConvertNum = itemData.countLimit - itemData.exchangeCount
                if maxConvertNum > 0 then
                    if convertNum <= 0 then
                        UIManager.showToast(Lang.ui_activity_normalExchange5)
                        return
                    end
                    if maxConvertNum > 1 then
                        UISellProp.setData( { id = itemData.id, thing = itemData.getItem, convertNum = convertNum }, UIActivityNormalExchange)
                        UIManager.pushScene("ui_sell_prop")
                    else
                        UIManager.showLoading()
                        netSendPackage( { header = StaticMsgRule.overflowExchange, msgdata = { int = { id = itemData.id, count = 1 } } }, function(_msgData)
                            UIManager.showToast(Lang.ui_activity_normalExchange6)
                            UIManager.flushWidget(UIActivityNormalExchange)
                        end )
                    end
                else
                    UIManager.showToast(Lang.ui_activity_normalExchange7)
                end
            end
        end )
    end
end

function UIActivityNormalExchange.init()
    local image_basemap = UIActivityNormalExchange.Widget:getChildByName("image_basemap")
    ui_scrollView = image_basemap:getChildByName("view_info")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIActivityNormalExchange.onActivity(_params)
    DictActivity = _params
end

function UIActivityNormalExchange.setup()
    cleanScrollView()
    ccui.Helper:seekNodeByName( UIActivityNormalExchange.Widget ,  "text_name" ):setString(Lang.ui_activity_normalExchange8)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.intoOverflowExchange, msgdata = { } }, function(_msgData)
        local msg = _msgData.msgdata.string["1"]
        if msg then
            local temp = utils.stringSplit(msg, "/")
            local tempMsgTable = {}
            for i = 1 , #temp do
                local aa = utils.stringSplit( temp[i] , "|" );
                table.insert( tempMsgTable , temp[i] )
            end
            layoutScrollView(tempMsgTable, setScrollViewItem)
        end
    end )
end

function UIActivityNormalExchange.free()
    DictActivity = nil
    cleanScrollView()
end
