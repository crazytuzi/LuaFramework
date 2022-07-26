require"Lang"
UIActivityFoundation = { }

local instActivityObj = nil
local btn_kfjj = nil
local btn_qmfl = nil
local btn_buy = nil
local btn_recharge = nil
local tag = 1
local kfjj_di = nil
local qmfl_di = nil
local ui_scrollView = nil
local ui_svItem = nil
local ui_scrollViewWel = nil
local ui_svItemWel = nil
local buyCount = 0
local getThing = nil

--- type 1 购买基金 2 领取基金
local function sendNetData(_type, _fundId, getGoods)
    local sendData = nil
    if _type == 1 then
        sendData = {
            header = StaticMsgRule.buyFund,
        }
    elseif _type == 2 then
        sendData = {
            header = StaticMsgRule.getFund,
            msgdata =
            {
                int =
                {
                    fundId = _fundId,
                }
            }
        }
    end
    if sendData then
        UIManager.showLoading()
        netSendPackage(sendData, function(pack)
            UIManager.flushWidget(UIActivityFoundation)
            if getGoods then utils.showGetThings(getGoods) end
        end )
    end
end

local function checkJiJinImageHint(param, item, tag)
    local result = false
    local isGet = nil
    local instActivityObj = UIActivityPanel.getInstThingByName("fund")
    local fundThing = { }
    for key, obj in pairs(DictActivityFund) do
        table.insert(fundThing, obj)
    end
    utils.quickSort(fundThing, function(value1, value2)
        return value1.id > value2.id
    end )
    for key, obj in pairs(fundThing) do
        local tempFlag = false
        if net.InstPlayer.int["19"] >= 2 then
            if net.InstPlayer.int["4"] >= obj.level then
                if instActivityObj then
                    local getIds = utils.stringSplit(instActivityObj.string["4"], ";")
                    for key, tempobj in pairs(getIds) do
                        if tonumber(tempobj) == tonumber(obj.id) then
                            isGet = true
                            break
                        end
                    end
                    if isGet then
                        tempFlag = false
                    else
                        tempFlag = true
                    end
                else
                    tempFlag = false
                end

            else
                tempFlag = false
            end
        else
            tempFlag = false
        end
        result = result or tempFlag
        isGet = nil
    end
    if item then
        if tag then
            if result or param then
                item:getChildByName("image_hint"):setVisible(true)
            end
        else
            utils.addImageHint(result or param, item, UIActivityPanel.imageHintTag, 15, 15)
        end
    end
    return result or param
end

local function checkQmflImageHint(item, tag)
    local result_qmfl = false
    local function handle(data)
        local _msgData = utils.stringSplit(data.msgdata.string["1"], " ")
        buyCount = tonumber(_msgData[1])
        local _listData = utils.stringSplit(_msgData[2], ";")
        local itemData = { }
        for key, obj in pairs(_listData) do
            local data = utils.stringSplit(obj, "|")
            itemData[#itemData + 1] = {
                id = tonumber(data[1]),
                goodsInfo = data[2],
                buyNumber = tonumber(data[3]),
                useAble = tonumber(data[4])
            }
        end
        for key, obj in pairs(itemData) do
            if obj.useAble == 0 and buyCount >= obj.buyNumber then
                result_qmfl = true
                break
            end
        end
        UIHomePage.qmflFlag = result_qmfl
        checkJiJinImageHint(result_qmfl, item, tag)
    end
    netSendPackage( { header = StaticMsgRule.getAllPeapleWeal }, handle)
end

-- item是要加红点的控件，tag用于标记是首页活动按钮还是活动界面的item
function UIActivityFoundation.checkImageHint(item, tag)
    if UIHomePage.accessCount == 1 and tag then
        checkQmflImageHint(item, tag)
    elseif UIHomePage.accessCount > 1 and tag then
        return UIHomePage.qmflFlag or checkJiJinImageHint(false, nil, tag)
    else
        checkQmflImageHint(item, tag)
    end
end

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
        if ui_svItemWel and ui_svItemWel:getReferenceCount() >= 1 then
            ui_svItemWel:release()
            ui_svItemWel = nil
        end
        if ui_scrollViewWel then
            ui_scrollViewWel:removeAllChildren()
            ui_scrollViewWel = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
        if ui_svItemWel:getReferenceCount() == 1 then
            ui_svItemWel:retain()
        end
        ui_scrollViewWel:removeAllChildren()
    end
end

local function setScrollViewItem(_Item, _obj)
    local ui_image = ccui.Helper:seekNodeByName(_Item, "image_good")
    local ui_des = _Item:getChildByName("text_info")
    local ui_num = _Item:getChildByName("text_number")
    local btn_exchange = _Item:getChildByName("btn_exchange")
    ui_des:setString(_obj.description)
    ui_num:setString(_obj.goldNum .. Lang.ui_activity_foundation1)
    ui_image:loadTexture("image/poster_item_small_yuanbao.png")
    btn_exchange:setPressedActionEnabled(true)

    local vipNum = net.InstPlayer.int["19"]
    local userLevel = net.InstPlayer.int["4"]
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if instActivityObj then
                if userLevel >= _obj.level then
                    sendNetData(2, _obj.id, string.format("%d_%d_%d", StaticTableType.DictPlayerBaseProp, StaticPlayerBaseProp.gold, _obj.goldNum))
                else
                    UIManager.showToast(string.format(Lang.ui_activity_foundation2, _obj.level))
                end
            else
                UIManager.showToast(Lang.ui_activity_foundation3)
            end
        end
    end
    btn_exchange:addTouchEventListener(btnEvent)
    if vipNum >= 2 and userLevel >= _obj.level and _obj.isGet == 0 then
        btn_exchange:setTitleText(Lang.ui_activity_foundation4)
        btn_exchange:setEnabled(false)
        utils.GrayWidget(btn_exchange, true)
    else
        btn_exchange:setTitleText(Lang.ui_activity_foundation5)
        btn_exchange:setEnabled(true)
        utils.GrayWidget(btn_exchange, false)
    end
end

local function setScrollViewWelItem(_item, _obj)
    local goodsDetail = utils.getItemProp(_obj.goodsInfo)
    local iconFrame = ccui.Helper:seekNodeByName(_item, "image_frame_good")
    local icon = ccui.Helper:seekNodeByName(_item, "image_good")
    local text_name = ccui.Helper:seekNodeByName(_item, "text_number")
    local btn = ccui.Helper:seekNodeByName(_item, "btn_exchange")
    local text_info = ccui.Helper:seekNodeByName(_item, "text_info")
    icon:loadTexture(goodsDetail.smallIcon)
    if goodsDetail.frameIcon then
        iconFrame:loadTexture(goodsDetail.frameIcon)
    end
    text_name:setString(goodsDetail.name .. "x" .. goodsDetail.count)
    text_info:setString(Lang.ui_activity_foundation6 .. _obj.buyNumber .. Lang.ui_activity_foundation7)
    utils.showThingsInfo(icon, goodsDetail.tableTypeId, goodsDetail.tableFieldId)
    btn:setPressedActionEnabled(true)
    btn:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local sendData = {
                header = StaticMsgRule.allPeapleWealReward,
                msgdata =
                {
                    int =
                    {
                        id = _obj.id,
                    }
                }
            }
            UIManager.showLoading()
            netSendPackage(sendData, function(package)
                UIManager.hideLoading()
                UIActivityFoundation.freshButton(2)
                utils.showGetThings(_obj.goodsInfo)
            end )
        end
    end )
    if _obj.useAble == 0 and buyCount >= _obj.buyNumber then
        btn:setTitleText(Lang.ui_activity_foundation8)
        btn:setBright(true)
        btn:setEnabled(true)
    elseif _obj.useAble == 1 then
        btn:setTitleText(Lang.ui_activity_foundation9)
        btn:setBright(false)
        btn:setEnabled(false)
    elseif buyCount < _obj.buyNumber then
        btn:setTitleText(Lang.ui_activity_foundation10)
        btn:setBright(false)
        btn:setEnabled(false)
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local scrollView = tag == 1 and ui_scrollView or ui_scrollViewWel
    local scrollItem = tag == 1 and ui_svItem or ui_svItemWel
    local SCROLLVIEW_ITEM_SPACE = 0
    cleanScrollView()
    scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = scrollItem:clone()
        _initItemFunc(scrollViewItem, obj, key)
        scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < scrollView:getContentSize().height then
        _innerHeight = scrollView:getContentSize().height
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, _innerHeight))
    local childs = scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(scrollView)
end

local function netCallbackFuncQmfl(data)
    UIManager.hideLoading()
    local _tempData = { }
    local _msgData = utils.stringSplit(data.msgdata.string["1"], " ")
    buyCount = tonumber(_msgData[1])
    if buyCount > 9999 then
        buyCount = 9999
    end
    local tempCount = buyCount
    local textNumber1 = ccui.Helper:seekNodeByName(qmfl_di, "text_number1")
    local textNumber2 = ccui.Helper:seekNodeByName(qmfl_di, "text_number2")
    local textNumber3 = ccui.Helper:seekNodeByName(qmfl_di, "text_number3")
    local textNumber4 = ccui.Helper:seekNodeByName(qmfl_di, "text_number4")
    textNumber1:setString(math.floor(tempCount / 1000))
    tempCount = tempCount % 1000
    textNumber2:setString(math.floor(tempCount / 100))
    tempCount = tempCount % 100
    textNumber3:setString(math.floor(tempCount / 10))
    tempCount = tempCount % 10
    textNumber4:setString(tempCount)
    local _listData = utils.stringSplit(_msgData[2], ";")
    local itemData = { }
    for key, obj in pairs(_listData) do
        local data = utils.stringSplit(obj, "|")
        itemData[#itemData + 1] = {
            id = tonumber(data[1]),
            goodsInfo = data[2],
            buyNumber = tonumber(data[3]),
            useAble = tonumber(data[4])
        }
    end
    utils.quickSort(itemData, function(value1, value2)
        if value1.useAble == value2.useAble then
            return value1.id > value2.id
        elseif value1.useAble ~= value2.useAble then
            return value1.useAble == 1 and value2.useAble == 0
        end
    end )
    layoutScrollView(itemData, setScrollViewWelItem)
end

local function refreshList(index)
    if index == 1 then
        local fundThing = { }
        for key, obj in pairs(DictActivityFund) do
            local isGet = nil
            if instActivityObj then
                local getIds = utils.stringSplit(instActivityObj.string["4"], ";")
                for key, _obj in pairs(getIds) do
                    if tonumber(_obj) == tonumber(obj.id) then
                        isGet = true
                    end
                end
            end
            if isGet then
                obj["isGet"] = 0
            else
                obj["isGet"] = 1
            end
            table.insert(fundThing, obj)
        end
        utils.quickSort(fundThing, function(value1, value2)
            if value1.isGet == value2.isGet then
                return value1.id > value2.id
            elseif value1.isGet ~= value2.isGet then
                return value1.isGet == 0 and value2.isGet ~= 0
            end
        end )
        if fundThing then
            layoutScrollView(fundThing, setScrollViewItem)
        end
    elseif index == 2 then
        UIManager.showLoading()
        local sendData = {
            header = StaticMsgRule.getAllPeapleWeal,
        }
        netSendPackage(sendData, netCallbackFuncQmfl)
    end
end

function UIActivityFoundation.freshButton(index)
    tag = index
    if index == 1 and btn_kfjj then
        btn_kfjj:loadTextureNormal("ui/yh_btn02.png")
        btn_kfjj:getChildByName("text_label_name"):setTextColor(cc.c4b(51, 25, 4, 255))
        btn_qmfl:loadTextureNormal("ui/yh_btn01.png")
        btn_qmfl:getChildByName("text_label_name"):setTextColor(cc.c4b(255, 255, 255, 255))
        kfjj_di:setVisible(true)
        qmfl_di:setVisible(false)
        ui_scrollView:setVisible(true)
        ui_scrollViewWel:setVisible(false)
        refreshList(1)
    elseif index == 2 and btn_qmfl then
        btn_qmfl:loadTextureNormal("ui/yh_btn02.png")
        btn_qmfl:getChildByName("text_label_name"):setTextColor(cc.c4b(51, 25, 4, 255))
        btn_kfjj:loadTextureNormal("ui/yh_btn01.png")
        btn_kfjj:getChildByName("text_label_name"):setTextColor(cc.c4b(255, 255, 255, 255))
        kfjj_di:setVisible(false)
        qmfl_di:setVisible(true)
        ui_scrollView:setVisible(false)
        ui_scrollViewWel:setVisible(true)
        refreshList(2)
    end
end

local function initWidget()
    btn_buy = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "btn_buy")
    btn_recharge = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "btn_recharge")
    btn_kfjj = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "btn_kfjj")
    btn_qmfl = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "btn_qmfl")
    ui_scrollView = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "view_info")
    ui_scrollViewWel = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "view_info_walfare")
    ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
    ui_svItemWel = ui_scrollViewWel:getChildByName("image_base_good"):clone()
    kfjj_di = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "image_di")
    qmfl_di = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "image_di_welfare")
end

function UIActivityFoundation.init()
    initWidget()
    local text_tokfjj = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "text_slogan4")
    local btn_tokfjj = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "btn_buy")
    btn_buy:setPressedActionEnabled(true)
    btn_kfjj:setPressedActionEnabled(true)
    btn_qmfl:setPressedActionEnabled(true)
    btn_recharge:setPressedActionEnabled(true)
    btn_tokfjj:setPressedActionEnabled(true)
    text_tokfjj:setTouchEnabled(true)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_buy then
                if net.InstPlayer.int["19"] >= 2 then
                    sendNetData(1)
                else
                    UIManager.showToast(Lang.ui_activity_foundation11)
                end
            elseif sender == btn_kfjj then
                if tag ~= 1 then
                    UIActivityFoundation.freshButton(1)
                end
            elseif sender == btn_qmfl then
                if tag ~= 2 then
                    UIActivityFoundation.freshButton(2)
                end
            elseif sender == btn_recharge then
                utils.checkGOLD(1)
            elseif sender == btn_tokfjj then
                UIActivityFoundation.freshButton(1)
            elseif sender == text_tokfjj then
                UIActivityFoundation.freshButton(1)
            end
        end
    end
    btn_buy:addTouchEventListener(btnEvent)
    btn_kfjj:addTouchEventListener(btnEvent)
    btn_qmfl:addTouchEventListener(btnEvent)
    btn_recharge:addTouchEventListener(btnEvent)
    btn_tokfjj:addTouchEventListener(btnEvent)
    text_tokfjj:addTouchEventListener(btnEvent)
end

function UIActivityFoundation.setup()
    if ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_svItemWel:getReferenceCount() == 1 then
        ui_svItemWel:retain()
    end
    instActivityObj = UIActivityPanel.getInstThingByName("fund")
    local vipNum = net.InstPlayer.int["19"]
    if vipNum >= 2 and instActivityObj then
        btn_buy:setTitleText(Lang.ui_activity_foundation12)
        btn_buy:setEnabled(false)
        utils.GrayWidget(btn_buy, true)
    else
        btn_buy:setTitleText(Lang.ui_activity_foundation13)
        btn_buy:setEnabled(true)
        utils.GrayWidget(btn_buy, false)
    end
    local label_vip = ccui.Helper:seekNodeByName(UIActivityFoundation.Widget, "text_number_now")
    label_vip:setString("VIP " .. net.InstPlayer.int["19"])
    UIActivityFoundation.freshButton(tag)
    UIHomePage.qmflFlag = false
    UIActivityPanel.addImageHint(false, "fund")
end

function UIActivityFoundation.free(...)
    instActivityObj = nil
    cleanScrollView()
end

function UIActivityFoundation.isActivityEnd()
    local Fundobj = nil
    if net.InstActivity then
        for key, obj in pairs(net.InstActivity) do
            if net.SysActivity[tostring(obj.int["3"])].string and net.SysActivity[tostring(obj.int["3"])].string["9"] == "fund" then
                Fundobj = obj
                break
            end
        end
    end
    if Fundobj then
        local getIds = utils.stringSplit(Fundobj.string["4"], ";")
        if #getIds == utils.getDictTableNum(DictActivityFund) then
            return true
        end
    end
end
