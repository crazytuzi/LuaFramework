require"Lang"
UIActivityOneUse = {}

local userData = nil

function UIActivityOneUse.init()
    local image_basemap = UIActivityOneUse.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)
end

function UIActivityOneUse.setup()
    local image_basemap = UIActivityOneUse.Widget:getChildByName("image_basemap")
    local ui_gold = ccui.Helper:seekNodeByName(image_basemap:getChildByName("image_base_info"), "text_gold_number")
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    local btn_sure = image_basemap:getChildByName("btn_sure")
    local image_base_sell = image_basemap:getChildByName("image_base_sell")
    local ui_selectNum = ccui.Helper:seekNodeByName(image_base_sell, "text_number")
    local btn_add = ccui.Helper:seekNodeByName(image_base_sell, "btn_add")
    local btn_add_ten = ccui.Helper:seekNodeByName(image_base_sell, "btn_add_ten")
    local btn_add_max = ccui.Helper:seekNodeByName(image_base_sell, "btn_add_max")
    local btn_cut = ccui.Helper:seekNodeByName(image_base_sell, "btn_cut")
    btn_add:setPressedActionEnabled(true)
    btn_add_ten:setPressedActionEnabled(true)
    btn_add_max:setPressedActionEnabled(true)
    btn_cut:setPressedActionEnabled(true)

    local MAX_COUNT = userData.buyCount
    local _schedulerId, _isLongPressed = nil, false
    local stopScheduler = function()
        if _schedulerId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
		end
        _schedulerId = nil
    end
    local onTouchEventEnd = function(sender)
        local _count = net.InstPlayer.int["5"]
        local _curSelectedCount = tonumber(ui_selectNum:getString())
        if sender == btn_add then
            _curSelectedCount = _curSelectedCount + 1
            if _count < _curSelectedCount or _curSelectedCount > MAX_COUNT then
                _curSelectedCount = _curSelectedCount - 1
                UIManager.showToast(_curSelectedCount >= MAX_COUNT and Lang.ui_activity_one_use1 or Lang.ui_activity_one_use2)
                stopScheduler()
            end
        elseif sender == btn_add_ten then
            _curSelectedCount = _curSelectedCount + 100
            if _count < _curSelectedCount or _curSelectedCount > MAX_COUNT then
                if _curSelectedCount > MAX_COUNT then
                    _curSelectedCount = MAX_COUNT
                    UIManager.showToast(Lang.ui_activity_one_use3)
                else
                    _curSelectedCount = _count
                    UIManager.showToast(Lang.ui_activity_one_use4)
                end
                stopScheduler()
            end
        elseif sender == btn_cut then
            _curSelectedCount = _curSelectedCount - 1
            if _curSelectedCount <= 0 then
                _curSelectedCount = 0
                stopScheduler()
            end
--        elseif sender == btn_cut_ten then
--            _curSelectedCount = _curSelectedCount - 10
--            if _curSelectedCount <= 0 then
--                _curSelectedCount = 0
--                stopScheduler()
--            end
        elseif sender == btn_add_max then
            if _count >= MAX_COUNT then
                _curSelectedCount = MAX_COUNT
            else
                _curSelectedCount = _count
            end
            stopScheduler()
        end
--        ui_gold:setString(tostring(_count - _curSelectedCount))
        ui_selectNum:setString(tostring(_curSelectedCount))
    end
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            stopScheduler()
            _isLongPressed = false
            local _curTimer = os.clock()
			_schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
                if not _isLongPressed and os.clock() - _curTimer >= 0.5 then
                    _isLongPressed = true
                end
                if _isLongPressed then
                    onTouchEventEnd(sender)
                end
            end, 0.1, false)
        elseif eventType == ccui.TouchEventType.canceled then
            stopScheduler()
        elseif eventType == ccui.TouchEventType.ended then
            stopScheduler()
            if _isLongPressed then
                return
            end
            onTouchEventEnd(sender)
        end
    end
    btn_add:addTouchEventListener(onBtnEvent)
    btn_add_ten:addTouchEventListener(onBtnEvent)
    btn_add_max:addTouchEventListener(onBtnEvent)
    btn_cut:addTouchEventListener(onBtnEvent)
    ui_selectNum:setString("0")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local _curSelectedCount = tonumber(ui_selectNum:getString())
            if _curSelectedCount == 0 then
                return UIManager.showToast(Lang.ui_activity_one_use5)
            end
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.addGoldShop, msgdata = { int = { count = _curSelectedCount } }
            } , function(_msgData)
                UIManager.popScene()
                UIActivityTime.refreshMoney()
                UIActivityOne.setup()
            end )
        end
    end)
end

function UIActivityOneUse.free()
    userData = nil
end

function UIActivityOneUse.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_activity_one_use")
end
