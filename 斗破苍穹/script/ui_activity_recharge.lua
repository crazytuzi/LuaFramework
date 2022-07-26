require"Lang"
UIActivityRecharge = { }
local scrollView = nil
local listItem = nil
local thingItem = nil
local _dictActivityObj = nil
local instActivityObj = nil
local itemTable = { }
local starTime = nil
local endTime = nil
UIActivityRecharge.rechargeGold = 0
UIActivityRecharge.todayRecharge = 0

-- type 0:是否在表中 1：领取状态
local function inTable(type, id)
    for key, value in pairs(itemTable) do
        local item = utils.stringSplit(value, "_")
        if type == 0 then
            if id == tonumber(item[1]) then
                return 1
            end
        elseif type == 1 then
            if id == tonumber(item[1]) then
                return tonumber(item[2])
            end
            if key == #itemTable then
                return 2
            end
        end
    end
    return 0
end
local function sendNetData(_addRechargeId, getGoods)
    local sendData = {
        header = StaticMsgRule.getAddRecargeThings,
        msgdata =
        {
            int =
            {
                addRechargeId = _addRechargeId,
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, function(pack)
        UIManager.flushWidget(UIActivityRecharge)
        if getGoods then utils.showGetThings(getGoods) end
    end )
end

function UIActivityRecharge.init(...)
    scrollView = ccui.Helper:seekNodeByName(UIActivityRecharge.Widget, "view_info")
    --  滚动层
    listItem = scrollView:getChildByName("image_base_good"):clone()
    thingItem = ccui.Helper:seekNodeByName(UIActivityRecharge.Widget, "image_frame_good"):clone()
    scrollView:removeAllChildren()
end

local function setChildScrollViewItem(_thingItem, obj)
    local thing_table = utils.stringSplit(obj, "_")
    local thingIcon = _thingItem:getChildByName("image_good")
    local thingCount = _thingItem:getChildByName("text_price")
    --utils.addThingParticle(obj, thingIcon, true)
    local tableTypeId, tableFieldId, value = thing_table[1], thing_table[2], thing_table[3]
    local name, icon = utils.getDropThing(tableTypeId, tableFieldId)
    thingIcon:loadTexture(icon)
    thingCount:setString("×" .. value)
    utils.addBorderImage(tableTypeId, tableFieldId, _thingItem)
    utils.showThingsInfo(thingIcon, tableTypeId, tonumber(tableFieldId))
    utils.addFrameParticle(thingIcon, true)
end
local function isGetGoods(_obj)
    local isGet = false
    local itemGetType = inTable(1, tonumber(_obj.int.id))
    if itemGetType == 1 then
        return false
    elseif itemGetType == 0 then
        return true
    end
    if instActivityObj then
        local getIds = utils.stringSplit(instActivityObj.string["4"], ";")
        for key, obj in pairs(getIds) do
            if tonumber(obj) == tonumber(_obj.int.id) then
                isGet = true
                break
            end
        end
    end
    return isGet
end
local function setScrollViewItem(_Item, _obj)
    local childScrollView = ccui.Helper:seekNodeByName(_Item, "view_good")
    local ui_des = _Item:getChildByName("text_info")
    local ui_num = _Item:getChildByName("text_number")
    local btn_exchange = _Item:getChildByName("btn_exchange")
    local ui_time = ccui.Helper:seekNodeByName(_Item, "text_time")
    ui_des:setString(_obj.string.description)

    childScrollView:removeAllChildren()
    btn_exchange:setPressedActionEnabled(true)
    local isGet = isGetGoods(_obj)
    local chargeGold = 0
    if inTable(0, tonumber(_obj.int.id)) == 1 then
        ui_time:setVisible(false)
        chargeGold = UIActivityRecharge.todayRecharge
    else
        ui_time:setVisible(true)
        if starTime and endTime then
            ui_time:setString(string.format(Lang.ui_activity_recharge1, starTime[2], starTime[3], starTime[5], endTime[2], endTime[3], endTime[5]))
        end
        chargeGold = UIActivityRecharge.rechargeGold
    end
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            --  if utils.GetTimeByDate(_dictActivityObj.string["5"]) - utils.getCurrentTime() > 0 then
            if chargeGold >= _obj.int.progress then
                sendNetData(_obj.int.id, _obj.string.things)
            else
                utils.checkGOLD(1)
            end
            --  else
            -- UIManager.showToast("累冲礼包活动已结束！")
            -- end
        end
    end
    btn_exchange:addTouchEventListener(btnEvent)

    if chargeGold >= _obj.int.progress then
        ui_num:setString(string.format(Lang.ui_activity_recharge2, _obj.int.progress, _obj.int.progress))
        if isGet then
            btn_exchange:setTitleText(Lang.ui_activity_recharge3)
            btn_exchange:setEnabled(false)
            utils.GrayWidget(btn_exchange, true)
        else
            btn_exchange:setTitleText(Lang.ui_activity_recharge4)
            btn_exchange:setEnabled(true)
            utils.GrayWidget(btn_exchange, false)
        end
    else
        ui_num:setString(string.format(Lang.ui_activity_recharge5, chargeGold, _obj.int.progress))
        btn_exchange:setTitleText(Lang.ui_activity_recharge6)
        btn_exchange:setEnabled(true)
        utils.GrayWidget(btn_exchange, false)
    end
    local getThing = utils.stringSplit(_obj.string.things, ";")
    for key, obj in pairs(getThing) do
        local childThingItem = thingItem:clone()
        childScrollView:addChild(childThingItem)
        setChildScrollViewItem(childThingItem, obj)
    end
    local width, space = 0, -5
    local childs = childScrollView:getChildren()
    width =(thingItem:getContentSize().width + space) * #childs

    if width < childScrollView:getContentSize().width then
        width = childScrollView:getContentSize().width
    end
    childScrollView:setInnerContainerSize(cc.size(width, childScrollView:getContentSize().height))
    local x, y = 0, childScrollView:getContentSize().height / 2
    for i = 1, #childs do
        x = thingItem:getContentSize().width / 2 + space +(i - 1) *(thingItem:getContentSize().width + space)
        childs[i]:setPosition(cc.p(x, y))
    end
end

function UIActivityRecharge.setup()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    if thingItem:getReferenceCount() == 1 then
        thingItem:retain()
    end
    scrollView:removeAllChildren()
    instActivityObj = UIActivityPanel.getInstThingByName("addRecharge")
    --  local ui_time = ccui.Helper:seekNodeByName(UIActivityRecharge.Widget, "text_time")
    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "addRecharge" then
                _dictActivityObj = obj
                if obj.string["4"] and string.len(obj.string["4"]) > 0 then
                    starTime = utils.changeTimeFormat(obj.string["4"])
                end
                if obj.string["5"] and string.len(obj.string["5"]) > 0 then
                    endTime = utils.changeTimeFormat(obj.string["5"])
                end
                break
            end
        end
    end


    local function chargeCallBack(pack)
        --        if pack.msgdata.int and pack.msgdata.int["1"] then
        UIActivityRecharge.rechargeGold = pack.msgdata.int["2"]
        UIActivityRecharge.todayRecharge = pack.msgdata.int["1"]
        --        else
        --            UIActivityRecharge.rechargeGold = 0
        --        end
        itemTable = utils.stringSplit(pack.msgdata.string["3"], ";")
        local rechargeThing = { }

        for key, obj in pairs(pack.msgdata.message) do
            if inTable(0, tonumber(obj.int.id)) == 1 then
                table.insert(rechargeThing, obj)
            elseif _dictActivityObj.string["5"] and string.len(_dictActivityObj.string["5"]) > 0 and utils.GetTimeByDate(_dictActivityObj.string["5"]) - utils.getCurrentTime() > 0 then
                if obj.int.id > 100 then
                    table.insert(rechargeThing, obj)
                end
            end
        end

        utils.quickSort(rechargeThing, function(value1, value2)
            if not isGetGoods(value1) and isGetGoods(value2) then
                return false
            elseif isGetGoods(value1) and not isGetGoods(value2) then
                return true
            elseif value1.int.id > value2.int.id then
                return true
            else
                return false
            end
        end )

        local hasNotGet = false
        for i, _obj in ipairs(rechargeThing) do
            local isGet = isGetGoods(_obj)
            local chargeGold = 0
            if inTable(0, tonumber(_obj.int.id)) == 1 then
                chargeGold = UIActivityRecharge.todayRecharge
            else
                chargeGold = UIActivityRecharge.rechargeGold
            end

            if chargeGold >= _obj.int.progress then
                if not isGet then
                    hasNotGet = true
                    break
                end
            end
        end
        local t = os.date("*t")
        t = string.format("%d-%02d-%02d", t.year, t.month, t.day)
        cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "activityrecharge", t .. "_" ..(hasNotGet and 1 or 0))
        if UIActivityRecharge.flushTitleHint then UIActivityRecharge.flushTitleHint(hasNotGet) end
        if rechargeThing then
            utils.updateView(UIActivityRecharge, scrollView, listItem, rechargeThing, setScrollViewItem)
        end
    end
    utils.checkGOLD(6, chargeCallBack)
end

function UIActivityRecharge.free(...)
    _dictActivityObj = nil
    instActivityObj = nil
    UIActivityRecharge.flushTitleHint = nil
    scrollView:removeAllChildren()
end

function UIActivityRecharge.checkImageHint(showHintCallback)
    local t = os.date("*t")
    t = string.format("%d-%02d-%02d", t.year, t.month, t.day)

    if showHintCallback then
        local value = cc.UserDefault:getInstance():getStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "activityrecharge")
        if value ~= "" and string.sub(value, 1, #t) == t then
            value = utils.stringSplit(value, "_")
            showHintCallback(tonumber(value[2]) == 1)
            return
        end
    end

    instActivityObj = UIActivityPanel.getInstThingByName("addRecharge")
    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "addRecharge" then
                _dictActivityObj = obj
                if obj.string["4"] and string.len(obj.string["4"]) > 0 then
                    starTime = utils.changeTimeFormat(obj.string["4"])
                end
                if obj.string["5"] and string.len(obj.string["5"]) > 0 then
                    endTime = utils.changeTimeFormat(obj.string["5"])
                end
                break
            end
        end
    end

    local function chargeCallBack(pack)
        UIActivityRecharge.rechargeGold = pack.msgdata.int["2"]
        UIActivityRecharge.todayRecharge = pack.msgdata.int["1"]
        itemTable = utils.stringSplit(pack.msgdata.string["3"], ";")
        local rechargeThing = { }

        for key, obj in pairs(pack.msgdata.message) do
            if inTable(0, tonumber(obj.int.id)) == 1 then
                table.insert(rechargeThing, obj)
            elseif _dictActivityObj.string["5"] and string.len(_dictActivityObj.string["5"]) > 0 and utils.GetTimeByDate(_dictActivityObj.string["5"]) - utils.getCurrentTime() > 0 then
                if obj.int.id > 100 then
                    table.insert(rechargeThing, obj)
                end
            end
        end

        local hasNotGet = false
        for i, _obj in ipairs(rechargeThing) do
            local isGet = isGetGoods(_obj)
            local chargeGold = 0
            if inTable(0, tonumber(_obj.int.id)) == 1 then
                chargeGold = UIActivityRecharge.todayRecharge
            else
                chargeGold = UIActivityRecharge.rechargeGold
            end

            if chargeGold >= _obj.int.progress then
                if not isGet then
                    hasNotGet = true
                    break
                end
            end
        end
        cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "activityrecharge", t .. "_" ..(hasNotGet and 1 or 0))
        if showHintCallback then
            showHintCallback(hasNotGet)
        end
    end
    utils.checkGOLD(6, chargeCallBack)
end
