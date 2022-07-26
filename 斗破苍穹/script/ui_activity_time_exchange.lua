require"Lang"
UIActivityTimeExchange = { }

local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function setScrollViewItem(_item, _data, key)
    local text_count = ccui.Helper:seekNodeByName(_item, "text_number")
    -- 剩余次数
    local goodsOne = ccui.Helper:seekNodeByName(_item, "image_frame_good1")
    local goodsTwo = ccui.Helper:seekNodeByName(_item, "image_frame_good2")
    local goodsThree = ccui.Helper:seekNodeByName(_item, "image_frame_good3")
    local goodsFour = ccui.Helper:seekNodeByName(_item, "image_frame_good_after")
    local text_time = ccui.Helper:seekNodeByName(_item, "text_title")
    local btn = ccui.Helper:seekNodeByName(_item, "btn_exchange")
    text_count:setString(Lang.ui_activity_time_exchange1 .. _data.count)
    local _tableStartTime = os.date("*t", _data.startTime / 1000)
    local _tableEndTime = os.date("*t", _data.endTime / 1000)
    text_time:setString(string.format(Lang.ui_activity_time_exchange2, _tableStartTime.month, _tableStartTime.day, _tableStartTime.hour, _tableEndTime.month, _tableEndTime.day, _tableEndTime.hour))
    local _goodsData = utils.stringSplit(_data.goods, ";")
    if #_goodsData == 1 then
        goodsOne:setVisible(false)
        goodsTwo:setVisible(false)
        goodsThree:setVisible(true)
    elseif #_goodsData == 2 then
        goodsOne:setVisible(true)
        goodsTwo:setVisible(true)
        goodsThree:setVisible(false)
    end
    for key, obj in pairs(_goodsData) do
        -- {name,smallIcon,bigIcon,frameIcon,qualityColor,flagIcon,count,tableTypeId,tableFieldId}
        local _goodsDetail = utils.getItemProp(obj)
        if #_goodsData == 1 then
            if key == 1 then
                goodsThree:getChildByName("text_good"):setString(_goodsDetail.name)
                goodsThree:getChildByName("image_good"):loadTexture(_goodsDetail.smallIcon)
                goodsThree:getChildByName("text_number"):setString("x" .. _goodsDetail.count)
                if _goodsDetail.frameIcon then
                    goodsThree:loadTexture(_goodsDetail.frameIcon)
                    utils.addThingParticle(obj, goodsThree, true)
                end
                utils.showThingsInfo(goodsThree, _goodsDetail.tableTypeId, _goodsDetail.tableFieldId)
            end
        elseif #_goodsData == 2 then
            if key == 1 then
                goodsOne:getChildByName("text_good"):setString(_goodsDetail.name)
                goodsOne:getChildByName("image_good"):loadTexture(_goodsDetail.smallIcon)
                goodsOne:getChildByName("text_number"):setString("x" .. _goodsDetail.count)
                if _goodsDetail.frameIcon then
                    goodsOne:loadTexture(_goodsDetail.frameIcon)
                    utils.addThingParticle(obj, goodsOne, true)
                end
                utils.showThingsInfo(goodsOne, _goodsDetail.tableTypeId, _goodsDetail.tableFieldId)
            elseif key == 2 then
                goodsTwo:getChildByName("text_good"):setString(_goodsDetail.name)
                goodsTwo:getChildByName("image_good"):loadTexture(_goodsDetail.smallIcon)
                goodsTwo:getChildByName("text_number"):setString("x" .. _goodsDetail.count)
                if _goodsDetail.frameIcon then
                    goodsTwo:loadTexture(_goodsDetail.frameIcon)
                    utils.addThingParticle(obj, goodsTwo, true)
                end
                utils.showThingsInfo(goodsTwo, _goodsDetail.tableTypeId, _goodsDetail.tableFieldId)
            end
        end
    end
    local _getGoods = utils.getItemProp(_data.getGoods)
    goodsFour:getChildByName("text_good_147"):setString(_getGoods.name)
    goodsFour:getChildByName("image_good_195"):loadTexture(_getGoods.smallIcon)
    goodsFour:getChildByName("text_number_149"):setString("x" .. _getGoods.count)
    if _getGoods.frameIcon then
        goodsFour:loadTexture(_getGoods.frameIcon)
        utils.addThingParticle(_data.getGoods, goodsFour, true)
    end
    utils.showThingsInfo(goodsFour, _getGoods.tableTypeId, _getGoods.tableFieldId)
    local function callBack(data)
        UIManager.hideLoading()
        UIManager.flushWidget(UIActivityTimeExchange)
        utils.showGetThings(_data.getGoods)
    end
    btn:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.requestExchange,
                msgdata =
                {
                    int =
                    {
                        id = _data.id
                    }
                }
            } , callBack)
        end
    end )
    local nowtime = utils.getCurrentTime()
    if tonumber(utils.stringSplit(_data.count, "/")[1]) <= 0 then
        btn:setTitleText(Lang.ui_activity_time_exchange3)
        btn:setBright(false)
        btn:setEnabled(false)
        btn:setPressedActionEnabled(false)
    elseif nowtime < tonumber(_data.startTime) / 1000 then
        btn:setTitleText(Lang.ui_activity_time_exchange4)
        btn:setPressedActionEnabled(false)
        btn:setBright(false)
        btn:setEnabled(false)
    elseif nowtime > tonumber(_data.endTime) / 1000 then
        btn:setTitleText(Lang.ui_activity_time_exchange5)
        btn:setBright(false)
        btn:setEnabled(false)
        btn:setPressedActionEnabled(false)
    else
        btn:setTitleText(Lang.ui_activity_time_exchange6)
        btn:setBright(true)
        btn:setEnabled(true)
        btn:setPressedActionEnabled(true)
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local SCROLLVIEW_ITEM_SPACE = 10
    cleanScrollView()
    ui_scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj, key)
        ui_scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < ui_scrollView:getContentSize().height then
        _innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function netCallbackFunc(data)
    UIManager.hideLoading()
    local _tempData = { }
    local _msgData = utils.stringSplit(data.msgdata.string["1"], "|")
    for key, obj in pairs(_msgData) do
        local _listData = utils.stringSplit(obj, " ")
        _tempData[#_tempData + 1] = {
            id = tonumber(_listData[1]),
            count = tostring(_listData[2]),
            startTime = _listData[3],
            endTime = _listData[4],
            goods = _listData[5],
            getGoods = _listData[6]
        }
    end
    utils.quickSort(_tempData, function(value1, value2)
        local count1 = tonumber(utils.stringSplit(value1.count, "/")[1])
        local count2 = tonumber(utils.stringSplit(value2.count, "/")[1])
        local temp1 = value1.id > value2.id
        local temp2 = count1 <= 0 and count2 > 0
        return temp1 or temp2
    end )
    layoutScrollView(_tempData, setScrollViewItem)
end

function UIActivityTimeExchange.init()
    ui_scrollView = ccui.Helper:seekNodeByName(UIActivityTimeExchange.Widget, "view_success")
    ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
    ui_scrollView:getChildByName("image_base_good"):setVisible(false)
end

function UIActivityTimeExchange.setup()
    if ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.refreshExchange, msgdata = { } }, netCallbackFunc)
end

function UIActivityTimeExchange.free()
    cleanScrollView()
end
