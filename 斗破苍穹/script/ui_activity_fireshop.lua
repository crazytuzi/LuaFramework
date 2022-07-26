require"Lang"
UIActivityFireShop = {}

local activityId = nil
local _countDownTime = 0
local countDownTimeFunc

local function initItem(_data)
    local _flagIconTag = 10000
    local image_basemap = UIActivityFireShop.Widget:getChildByName("image_basemap")
    local image_shadow_down = image_basemap:getChildByName("image_shadow_down")
    for i = 1, 6 do
        local itemData = _data and _data["fire"..i] or nil
        local ui_item = ccui.Helper:seekNodeByName(image_basemap, "image_base_good" .. i)
        local ui_name = ui_item:getChildByName("text_info")
        local ui_frame = ui_item:getChildByName("image_frame_good")
        local ui_icon = ui_frame:getChildByName("image_good")
        local ui_priceIcon = ui_frame:getChildByName("image_price")
        local ui_price = ui_priceIcon:getChildByName("text_price")
        local ui_count = ccui.Helper:seekNodeByName(ui_frame, "text_number")
        local btn_exchange = ui_item:getChildByName("btn_exchange")
        if ui_frame:getChildByTag(_flagIconTag) then
            ui_frame:getChildByTag(_flagIconTag):removeFromParent()
        end
        if itemData then
            local itemProps = utils.getItemProp(itemData.int["3"].."_"..itemData.int["4"].."_"..itemData.int["5"])
            if itemProps then
                if itemProps.name then
                    ui_name:setString(itemProps.name)
                end
                if itemProps.qualityColor then
                    ui_name:setTextColor(itemProps.qualityColor)
                end
                if itemProps.frameIcon then
                    ui_frame:loadTexture(itemProps.frameIcon)
                end
                if itemProps.smallIcon then
                    ui_icon:loadTexture(itemProps.smallIcon)
                   utils.showThingsInfo(ui_icon, itemProps.tableTypeId, itemProps.tableFieldId)
                end
                if itemProps.count then
                    ui_count:setString(tostring(itemProps.count))
                end
                if itemProps.flagIcon then
                    local ui_flagIcon = ccui.ImageView:create(itemProps.flagIcon)
                    ui_flagIcon:setAnchorPoint(cc.p(0.2, 0.8))
                    ui_flagIcon:setPosition(cc.p(0, ui_frame:getContentSize().height))
                    ui_frame:addChild(ui_flagIcon, _flagIconTag, _flagIconTag)
                end
            end
            --出售类型 1-元宝 2-火能石
            if itemData.int["6"] == 1 then
                ui_priceIcon:loadTexture("ui/jin.png")
            else
                ui_priceIcon:loadTexture("ui/small_xiuwei.png")
            end
            ui_price:setString("×" .. itemData.int["7"])
            --是否售完 0-未售完 1-售完
            if itemData.int["8"] == 1 then
                utils.GrayWidget(ui_frame, true)
	            utils.GrayWidget(btn_exchange, true)
            else
                utils.GrayWidget(ui_frame, false)
	            utils.GrayWidget(btn_exchange, false)
            end
        end
        btn_exchange:setPressedActionEnabled(true)
        btn_exchange:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if itemData then
                    if itemData.int["8"] == 1 then
                        UIManager.showToast(Lang.ui_activity_fireshop1)
                        return
                    elseif itemData.int["6"] == 1 then--出售类型 1-元宝 2-火能石
                        if net.InstPlayer.int["5"] < itemData.int["7"] then
                            UIManager.showToast(Lang.ui_activity_fireshop2)
                            return
                        end
                    elseif itemData.int["6"] == 2 then
                        if net.InstPlayer.int["21"] < itemData.int["7"] then
                            UIActivityMiteer.PromptDialog(Lang.ui_activity_fireshop3, 2)
                            return
                        end
                    end
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.convertFireShopGoods,
                        msgdata =
                        {
                            int = { instId = itemData.int["1"] }
                        }
                    } , function(_msgData)
                        UIManager.showToast(Lang.ui_activity_fireshop4)
                        UIActivityFireShop.setup()
                    end)
                else
                    UIManager.showToast(Lang.ui_activity_fireshop5)
                end
            end
        end)
    end
end

--type 1-进入火能商店界面 2-火能商店刷新物品
local function refreshFireShopData(_type, _callbackFunc)
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.updateAuctionOrFireShop,
        msgdata =
        {
            int = { type = _type }
        }
    } , _callbackFunc)
end

function UIActivityFireShop.onActivity(_activityId)
    activityId = _activityId
end

function UIActivityFireShop.init()
    local image_basemap = UIActivityFireShop.Widget:getChildByName("image_basemap")
    local btn_refresh = ccui.Helper:seekNodeByName(image_basemap, "btn_refresh")
    btn_refresh:setPressedActionEnabled(true)
    btn_refresh:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            refreshFireShopData(2, function(_msgData)
                UIActivityFireShop.setup()
            end)
        end
    end)
end

function UIActivityFireShop.setup()
    local instActivityObj = nil
    if net.InstActivity then
        for key, obj in pairs(net.InstActivity) do
            if activityId == obj.int["3"] then
                instActivityObj = obj
                break
            end
        end
    end
    local image_basemap = UIActivityFireShop.Widget:getChildByName("image_basemap")
    local ui_fireStoneCount = image_basemap:getChildByName("image_firestone"):getChildByName("text_number")
    local image_base_tab = image_basemap:getChildByName("image_base_tab")
    local ui_refreshItemIcon = ccui.Helper:seekNodeByName(image_base_tab, "image_refresh")
    local ui_refreshItemName = ccui.Helper:seekNodeByName(image_base_tab, "text_refresh")
    local ui_refreshItemCount = ccui.Helper:seekNodeByName(image_base_tab, "text_refresh_number")
    local ui_freeRefreshCount = ccui.Helper:seekNodeByName(image_base_tab, "text_free_number")
    local ui_freeRefreshTime = ccui.Helper:seekNodeByName(image_base_tab, "text_free_time")
    local ui_goldRefreshCount = ccui.Helper:seekNodeByName(image_base_tab, "text_gold")
    local btn_refresh = ccui.Helper:seekNodeByName(image_base_tab, "btn_refresh")
    --火能石数量
    local _fireStoneCount = net.InstPlayer.int["21"]
    --刷新令数量
    local _refreshTokenCount = utils.getThingCount(StaticThing.refreshSign)

    ui_fireStoneCount:setString(tostring(_fireStoneCount))

    local _vipNum = net.InstPlayer.int["19"]
	local _freeRefreshNum = DictVIP[tostring(_vipNum + 1)].hJYReset
    local _useRefreshNum = instActivityObj and instActivityObj.int["6"] or 0
    ui_freeRefreshCount:setString(string.format("%d/%d", _freeRefreshNum - _useRefreshNum, _freeRefreshNum))

    local _goldRefreshCount = 0
    if instActivityObj and instActivityObj.string["7"] and instActivityObj.string["7"] ~= "" then
        _goldRefreshCount = tonumber(instActivityObj.string["7"])
    end
    if instActivityObj and instActivityObj.string["8"]  and instActivityObj.string["8"] ~= "" then
        local temp = utils.stringSplit(instActivityObj.string["8"], " ")
        local date = utils.stringSplit(temp[1], "-")
        local oldDay = date[3]
        local _tableStartTime = os.date("*t", utils.getCurrentTime())
        local newDay = _tableStartTime.day
        if tonumber(oldDay) ~= newDay then
            _goldRefreshCount = 0
        end
    end
--    if UIActivityHJY.isReset then
--        _goldRefreshCount = 0
--    end
    ui_goldRefreshCount:setString(Lang.ui_activity_fireshop6..( DictVIP[tostring(_vipNum + 1 )].hjyFreshCount - _goldRefreshCount ) )
--    if _freeRefreshNum - _useRefreshNum == 0 then
--        UIActivityPanel.addImageHint(UIActivityHJY.checkImageHint(),"hJYStore")
--    end

    if _refreshTokenCount == 0 and _freeRefreshNum - _useRefreshNum == 0 then --没次数或者刷新令  显示元宝
        ui_refreshItemName:setString(Lang.ui_activity_fireshop7)
        ui_refreshItemIcon:loadTexture("ui/jin.png")
        ui_refreshItemCount:setString("×" .. DictSysConfig[tostring(StaticSysConfig.hJYStoreResetGold)].value)
    else
        ui_refreshItemName:setString(Lang.ui_activity_fireshop8)
        ui_refreshItemIcon:loadTexture("ui/sxl.png")
        ui_refreshItemCount:setString("×" .. _refreshTokenCount)
    end

    ui_freeRefreshTime:setVisible(false)
    if instActivityObj then
        local starTime = utils.GetTimeByDate(instActivityObj.string["4"])
        local currentTime = utils.getCurrentTime()
        local storeResetTime = DictSysConfig[tostring(StaticSysConfig.hJYStoreResetTime)].value
        _countDownTime = storeResetTime * 3600 - math.abs(currentTime - starTime) % (storeResetTime * 3600)
        if _countDownTime > 0 and instActivityObj.int["6"] > 0 then
            local hour = math.floor(_countDownTime / 3600)
            local min = math.floor(_countDownTime % 3600 / 60)
            local sec = _countDownTime % 60
            ui_freeRefreshTime:setString(string.format(" %02d:%02d:%02d", hour, min, sec))
            ui_freeRefreshTime:setVisible(true)
            dp.addTimerListener(countDownTimeFunc)
        else
            _countDownTime = 0
            dp.removeTimerListener(countDownTimeFunc)
        end
    end

    refreshFireShopData(1, function(_msgData)
        local ipfsData = _msgData.msgdata.message.InstPlayerFireShop and _msgData.msgdata.message.InstPlayerFireShop.message or nil
        initItem(ipfsData)
    end)
    
end

countDownTimeFunc = function()
    if _countDownTime > 0 then
        _countDownTime = _countDownTime - 1
        local hour = math.floor(_countDownTime / 3600)
        local min = math.floor(_countDownTime % 3600 / 60)
        local sec = _countDownTime % 60
        local image_basemap = UIActivityFireShop.Widget:getChildByName("image_basemap")
        local image_base_tab = image_basemap:getChildByName("image_base_tab")
        local ui_freeRefreshTime = ccui.Helper:seekNodeByName(image_base_tab, "text_free_time")
        ui_freeRefreshTime:setString(string.format(" %02d:%02d:%02d", hour, min, sec))
    else
        _countDownTime = 0
        dp.removeTimerListener(countDownTimeFunc)
        UIActivityFireShop.setup()
    end
end

function UIActivityFireShop.updateTimer(intervalTime)
    if _countDownTime then
        _countDownTime = _countDownTime - intervalTime
        if _countDownTime < 0 then
            _countDownTime = 0
        end
    end
end

function UIActivityFireShop.free()
    _countDownTime = 0
    dp.removeTimerListener(countDownTimeFunc)
end
