require"Lang"
UIActivityLimitShopping = {}

local _tempActivityDataIndex = nil
local _activityData = nil
local _countdownTime = 0
local DictActivity = nil

local netCallbackFunc = nil

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    if UIActivityLimitShopping.Widget then
        local day = math.floor(_countdownTime / 3600 / 24) --天
	    local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
	    local image_basemap = UIActivityLimitShopping.Widget:getChildByName("image_basemap")
        image_basemap:getChildByName("text_time_left"):setString(string.format(Lang.ui_activity_limitShopping1, day, hour, minute, second))
    end
end

local function initActivityUI()
    if _activityData then
        for key, obj in pairs(_activityData) do
		    local item = ccui.Helper:seekNodeByName(UIActivityLimitShopping.Widget, "image_base_good" .. key)
		    local ui_name = item:getChildByName("text_info")
		    local ui_itemIcon = item:getChildByName("panel_good"):getChildByName("image_good")

		    local _isGiftBag = false --是否为礼包
		    local _tempThings = utils.stringSplit(obj.things, ";")
		    if #_tempThings > 1 then
			    _isGiftBag = true
		    end
		    _tempThings = nil
		    if _isGiftBag then
			    ui_itemIcon:setTouchEnabled(true)
			    ui_itemIcon:addTouchEventListener(function(sender, eventType)
				    if eventType == ccui.TouchEventType.ended then
					    UIAwardGet.setOperateType(UIAwardGet.operateType.giftBag, obj.things)
	   			        UIManager.pushScene("ui_award_get")
				    end
			    end)
			    ui_name:setString(obj.giftBagName)
			    ui_itemIcon:loadTexture("image/ui_big_libao.png")
		    else
                local itemProps = utils.getItemProp(obj.things)
			    local itemName = itemProps.name
			    if itemProps.count > 1 then
				    itemName = itemName .. "×" .. itemProps.count
			    end
                if itemProps.qualityColor then
			        ui_name:setTextColor(itemProps.qualityColor)
                end
			    ui_name:setString(itemName)
			    ui_itemIcon:loadTexture(itemProps.bigIcon)
			    utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
		    end
		    item:getChildByName("text_price_xian"):setString(Lang.ui_activity_limitShopping2 .. obj.limitNum)
		    local ui_nowPrice = item:getChildByName("image_gold_xian")
		    local ui_oldPrice = item:getChildByName("image_gold_yuan")
		    local _buyTypeImg = (obj.buyType == 1 and "ui/jin.png" or "ui/yin.png")
		    ui_nowPrice:loadTexture(_buyTypeImg)
		    ui_oldPrice:loadTexture(_buyTypeImg)
		    ui_nowPrice:getChildByName("text_gold_number"):setString(tostring(obj.nowPrice))
		    ui_oldPrice:getChildByName("text_gold_number"):setString(tostring(obj.oldPrice))
		    local btn_exchange = item:getChildByName("btn_exchange")
		    btn_exchange:setTitleText(Lang.ui_activity_limitShopping3)
		    local _btnEnabled = true
		    if obj.limitNum <= 0 then
			    _btnEnabled = false
			    btn_exchange:setTitleText(Lang.ui_activity_limitShopping4)
		    end
		    btn_exchange:setBright(_btnEnabled)
		    btn_exchange:setTouchEnabled(_btnEnabled)
		    btn_exchange:setPressedActionEnabled(true)
		    btn_exchange:addTouchEventListener(function(sender, eventType)
			    if eventType == ccui.TouchEventType.ended then
				    if UIActivityTime.checkMoney(obj.buyType, obj.nowPrice) then
--					    if limitShoppingCountDown == 0 then
--						    UIManager.showToast("活动已结束！")
--						    return
--					    end
					    UIManager.showLoading()
					    _tempActivityDataIndex = key
					    netSendPackage({header=StaticMsgRule.limitShopping, msgdata={int={id=obj.id}}}, netCallbackFunc)
				    end
			    end
		    end)
	    end
        if DictActivity then
		    local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		    local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
		    local image_basemap = UIActivityLimitShopping.Widget:getChildByName("image_basemap")
            image_basemap:getChildByName("text_time"):setString(string.format(Lang.ui_activity_limitShopping5, _startTime[2], _startTime[3], _endTime[2], _endTime[3]))

		    _countdownTime = utils.GetTimeByDate(DictActivity.string["5"]) - utils.getCurrentTime()
	    end
    end
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
	if code == StaticMsgRule.getLimitShopping then
		_activityData = {}
		local _msgData = utils.stringSplit(_msgData.msgdata.string["1"], "/")
		for key, obj in pairs(_msgData) do
			local _listData = utils.stringSplit(obj, " ")
			_activityData[#_activityData + 1] = {
					id = tonumber(_listData[1]),
					things = _listData[2],
					oldPrice = tonumber(_listData[3]),
					nowPrice = tonumber(_listData[4]),
					buyType = tonumber(_listData[5]), --1-元宝, 2-银币
					limitNum = tonumber(_listData[6]),
					giftBagName = _listData[7]
			}
		end
		utils.quickSort(_activityData, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
	elseif code == StaticMsgRule.limitShopping then
		UIActivityTime.refreshMoney()
		if _tempActivityDataIndex and _activityData and _activityData[_tempActivityDataIndex] then
			local obj = _activityData[_tempActivityDataIndex]
			utils.showGetThings(obj.things)
			obj.limitNum = (obj.limitNum - 1 < 0) and 0 or (obj.limitNum - 1)
			_tempActivityDataIndex = nil
		end
	end
    initActivityUI()
end

function UIActivityLimitShopping.onActivity(_params)
    DictActivity = _params
end

function UIActivityLimitShopping.init()

end

function UIActivityLimitShopping.setup()
    dp.addTimerListener(countDowun)
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.getLimitShopping, msgdata={}}, netCallbackFunc)
end

function UIActivityLimitShopping.free()
    _tempActivityDataIndex = nil
    DictActivity = nil
    _countdownTime = 0
    dp.removeTimerListener(countDowun)
end
