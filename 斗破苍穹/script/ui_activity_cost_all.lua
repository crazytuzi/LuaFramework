require"Lang"
UIActivityCostAll = { }
local scrollView = nil
local listItem = nil
local dictActivityCost = { }
-- local instActivityObj = nil
local SCROLLVIEW_ITEM_SPACE = 20
UIActivityCostAll.todayCost = 0

-- 得物品
local function sendNetMessage(id1, getGoods)
    -- cclog("id : "..id1)
    local data = {
        header = StaticMsgRule.getTotalCostAward,
        msgdata =
        {
            string =
            {
                id = id1
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(data, function()
        UIManager.flushWidget(UIActivityCostAll)
        if getGoods then utils.showGetThings(getGoods) end
    end )
end

-- 物品图标信息
local function setItemInfo(thing, _icon, _name, _num, thing_table)
    local icon = thing:getChildByName(_icon)
    local name = thing:getChildByName(_name)
    local num = thing:getChildByName(_num)
    icon:loadTexture(thing_table.smallIcon)
    name:setString(thing_table.name)
    thing:loadTexture(thing_table.frameIcon)
    num:setString(thing_table.count)
    utils.showThingsInfo(icon, thing_table.tableTypeId, tonumber(thing_table.tableFieldId))
end
local function setScrollViewItem(item, obj)
    local _btn = item:getChildByName("btn_exchange")
    local enough = true
    if UIActivityCostAll.todayCost < tonumber(obj[2]) then
        enough = false
    end

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- cclog("touchEvent ended")
            if tonumber(obj[4]) ~= 3 then
                if not enough then
                    UIManager.showToast(Lang.ui_activity_cost_all1)
                else
                    sendNetMessage(obj[1], obj[3])
                end
            else
                UIManager.showToast(Lang.ui_activity_cost_all2)
            end
        end
    end
    _btn:setPressedActionEnabled(true)
    _btn:addTouchEventListener(btnEvent)
    local titleText = item:getChildByName("image_title"):getChildByName("text_title")
    if tonumber(obj[4]) == 2 then
        titleText:setString(Lang.ui_activity_cost_all3 .. obj[2] .. Lang.ui_activity_cost_all4 .. "(" .. obj[2] .. "/" .. obj[2] .. ")")
        _btn:setTitleText(Lang.ui_activity_cost_all5)
        _btn:setBright(false)
        _btn:setEnabled(false)
    elseif not enough then
        titleText:setString(Lang.ui_activity_cost_all6 .. obj[2] .. Lang.ui_activity_cost_all7 .. "(" .. UIActivityCostAll.todayCost .. "/" .. obj[2] .. ")")
        _btn:setTitleText(Lang.ui_activity_cost_all8)
        _btn:setBright(false)
        _btn:setEnabled(false)
    else
        titleText:setString(Lang.ui_activity_cost_all9 .. obj[2] .. Lang.ui_activity_cost_all10 .. "(" .. obj[2] .. "/" .. obj[2] .. ")")
        _btn:setTitleText(Lang.ui_activity_cost_all11)
        _btn:setBright(true)
        _btn:setEnabled(true)
    end

    local getThings = utils.stringSplit(obj[3], ";")
    for i = 1, 4 do
        local goods = item:getChildByName("image_frame_good" .. i)
        if i <= #getThings then
            goods:setVisible(true)

            local thing_table = utils.getItemProp(getThings[i])
            setItemInfo(goods, "image_good", "text_good", "text_number", thing_table)
            utils.addThingParticle(getThings[i], goods:getChildByName("image_good"), true)
        else
            goods:setVisible(false)
        end
    end
end
local function layoutScrollView(_listData, _initItemFunc)
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = listItem:clone()
        _initItemFunc(scrollViewItem, obj)
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
function UIActivityCostAll.init()
    scrollView = ccui.Helper:seekNodeByName(UIActivityCostAll.Widget, "view_success")
    listItem = scrollView:getChildByName("image_base_good"):clone()
end
function UIActivityCostAll.setup()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    scrollView:removeAllChildren()
    local startTime, endTime = nil, nil
    local function costCallBack(pack)
        UIActivityCostAll.todayCost = tonumber(pack.msgdata.string.cost)
        startTime = utils.changeTimeFormat(pack.msgdata.string.start)
        endTime = utils.changeTimeFormat(pack.msgdata.string.stop)
        local str = pack.msgdata.string.data
        dictActivityCost = utils.stringSplit(str, "|")

        local rechargeThing = { }
        for key, value in pairs(dictActivityCost) do
            local ss = utils.stringSplit(value, " ")
            table.insert(rechargeThing, ss)
        end
        utils.quickSort(rechargeThing, function(value1, value2)
            if tonumber(value1[4]) ~= 2 and tonumber(value2[4]) == 2 then
                return false
            elseif tonumber(value1[4]) == 2 and tonumber(value2[4]) ~= 2 then
                return true
            elseif tonumber(value1[1]) > tonumber(value2[1]) then
                return true
            else
                return false
            end
        end )
        local result = false
        for key, obj in pairs(rechargeThing) do
            local enough = true
            if UIActivityCostAll.todayCost < tonumber(obj[2]) then
                enough = false
            end
            if tonumber(obj[4]) == 2 then
                result = false
            elseif not enough then
                result = false
            else
                result = true
                break
            end
        end
        if not result then
            UIActivityPanel.addImageHint(false, "SaveConsume")
        end
        if rechargeThing then
            layoutScrollView(rechargeThing, setScrollViewItem)
        end
        if startTime and endTime then
            local timeTitle = ccui.Helper:seekNodeByName(UIActivityCostAll.Widget, "text_time")
            timeTitle:setString(string.format(Lang.ui_activity_cost_all12, startTime[2], startTime[3], startTime[5], startTime[6], startTime[7], endTime[2], endTime[3], endTime[5], endTime[6], endTime[7]))
        end
    end

    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.refreshTotalCost,
    }
    cclog("header:" .. "1191")
    netSendPackage(data, costCallBack)
end
function UIActivityCostAll.free()
    scrollView:removeAllChildren()
end

function UIActivityCostAll.checkImageHint(item, flag)
    local result = false
    local function handle(pack)
        UIActivityCostAll.todayCost = tonumber(pack.msgdata.string.cost)
        local str = pack.msgdata.string.data
        dictActivityCost = utils.stringSplit(str, "|")
        local rechargeThing = { }
        for key, value in pairs(dictActivityCost) do
            local ss = utils.stringSplit(value, " ")
            table.insert(rechargeThing, ss)
        end
        for key, obj in pairs(rechargeThing) do
            local enough = true
            if UIActivityCostAll.todayCost < tonumber(obj[2]) then
                enough = false
            end
            if tonumber(obj[4]) == 2 then
                result = false
            elseif not enough then
                result = false
            else
                result = true
                break
            end
        end
        if not result then
            UIActivityPanel.addImageHint(false, "SaveConsume")
        end
        if item then
            if flag then
                if result then
                    item:getChildByName("image_hint"):setVisible(true)
                end
            else
                utils.addImageHint(result, item, UIActivityPanel.imageHintTag, 15, 15)
            end
        end
        UIHomePage.costAllFlag = result
    end
    netSendPackage( { header = StaticMsgRule.refreshTotalCost }, handle)
end
