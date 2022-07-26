require"Lang"
UIActivityGrabTheHour = {}

local activityTime = {
	startTime = { --整点抢购的时间点
		DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeOne)].value,
		DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeTwo)].value,
		DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeThree)].value
	},
	keepTime = { --整点抢购的持续时间(以小时为单位)
		DictSysConfig[tostring(StaticSysConfig.grabTheHourSustainTimeOne)].value,
		DictSysConfig[tostring(StaticSysConfig.grabTheHourSustainTimeTwo)].value,
		DictSysConfig[tostring(StaticSysConfig.grabTheHourSustainTimeThree)].value
	}
}

local _tempHourDataThings = nil
local _activityData = nil
local _countdownTime = 0

local netCallbackFunc = nil

UIActivityGrabTheHour.flagOne = true
UIActivityGrabTheHour.flagTwo = true
UIActivityGrabTheHour.flagThree = true

local function getTimer(curTime, hour, minute)
	local _date = os.date("*t", curTime)
	_date.hour = hour
	if minute then
		_date.min = minute
	else
		_date.min = 0
	end
	_date.sec = 0
	return os.time(_date)
end

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    local _curTime = utils.getCurrentTime()
    local ui_baseImage = UIActivityGrabTheHour.Widget:getChildByName("image_basemap"):getChildByName("image_base_di")
	local hour = math.floor(_countdownTime / 3600 % 24) --小时
	local minute = math.floor(_countdownTime / 60 % 60) --分
	local second = math.floor(_countdownTime % 60) --秒
	ccui.Helper:seekNodeByName(ui_baseImage, "text_time"):setString(string.format(" %02d:%02d:%02d", hour, minute, second))
	_countdownTime = 0
    for i = 1, 3 do
		local _startTime = getTimer(_curTime, activityTime.startTime[i])
		local _endTime = _startTime + activityTime.keepTime[i] * 60 * 60
		if _curTime >= _startTime and _curTime < _startTime + 1 then
			UIActivityGrabTheHour.setup()
			_countdownTime = _endTime - _curTime
			break
		elseif _curTime > _startTime and _curTime < _endTime then
			_countdownTime = _endTime - _curTime
			break
		end
	end
end

local function initActivityUI()
    if _activityData then
        for key, obj in pairs(_activityData) do
		    local _id = obj.int["1"]
		    local _things = obj.string["3"]
		    local _count = obj.int["4"]
		    local _buyType = obj.int["5"]
		    local _buyPrice = obj.int["6"]
		    local _originPrice = obj.int["7"]
		    local _rank = obj.int["8"]
		    local _surplusNum = obj.int["9"]
		    local _giftBagName = obj.int["10"]
		    local item = ccui.Helper:seekNodeByName(UIActivityGrabTheHour.Widget, "image_base_good" .. key)
		    local ui_name = item:getChildByName("text_info")
		    local ui_itemIcon = item:getChildByName("panel_good"):getChildByName("image_good")
		    utils.GrayWidget(ui_itemIcon, false)

		    local _isGiftBag = false --是否为礼包
		    local _tempThings = utils.stringSplit(_things, ";")
		    if #_tempThings > 1 then
			    _isGiftBag = true
		    end
		    _tempThings = nil
		    if _isGiftBag then
			    ui_itemIcon:setTouchEnabled(true)
			    ui_itemIcon:addTouchEventListener(function(sender, eventType)
				    if eventType == ccui.TouchEventType.ended then
					    UIAwardGet.setOperateType(UIAwardGet.operateType.giftBag, _things)
	   			        UIManager.pushScene("ui_award_get")
				    end
			    end)
			    ui_name:setString(_giftBagName)
			    ui_itemIcon:loadTexture("image/ui_big_libao.png")
		    else
                local itemProps = utils.getItemProp(_things)
			    local itemName = itemProps.name
			    if itemProps.count > 1 then
				    itemName = itemName .. "×" .. itemProps.count
			    end
			    ui_name:setTextColor(itemProps.qualityColor)
			    ui_name:setString(itemName)
                if itemProps.bigIcon then
			        ui_itemIcon:loadTexture(itemProps.bigIcon)
                else
                    ui_itemIcon:loadTexture("image/poster_item_big_tongyongbaoxiang.png")
                end
			    utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
		    end
		    item:getChildByName("image_title_di"):getChildByName("text_title_di"):setString(activityTime.startTime[key]..Lang.ui_activity_grabTheHour1)
		    item:getChildByName("text_price_xian"):setString(string.format(Lang.ui_activity_grabTheHour2, _surplusNum))
		    item:getChildByName("image_di"):getChildByName("bar_good"):setPercent(utils.getPercent(_surplusNum, _count))
		    local ui_buyPrice = item:getChildByName("image_gold_xian")
		    local ui_originPrice = item:getChildByName("image_gold_yuan")
		    local _buyTypeImg = (_buyType == 1 and "ui/jin.png" or "ui/yin.png")
		    ui_buyPrice:loadTexture(_buyTypeImg)
		    ui_originPrice:loadTexture(_buyTypeImg)
		    ui_buyPrice:getChildByName("text_gold_number"):setString(tostring(_buyPrice))
		    ui_originPrice:getChildByName("text_gold_number"):setString(tostring(_originPrice))
		    local ui_imageSell = item:getChildByName("panel_good"):getChildByName("image_sell")
		    ui_imageSell:setVisible(false)
		    local btn_exchange = item:getChildByName("btn_exchange")
		    local _btnEnabled = true
		    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour3)

		    local isBuy = function()
			    if net.InstPlayerGrabTheHour then
				    for _ipgtKey, _ipgtObj in pairs(net.InstPlayerGrabTheHour) do
					    if _id == _ipgtObj.int["3"] then
						    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour4)
						    _btnEnabled = false
						    return true
					    end
				    end
			    end
			    return false
		    end

		    local _curTime = utils.getCurrentTime()
		    local _startTime = getTimer(_curTime, activityTime.startTime[key])
		    local _endTime = _startTime + activityTime.keepTime[key] * 60 * 60

		    if _curTime < _startTime then
			    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour5)
			    _btnEnabled = false
		    elseif _surplusNum <= 0 then
			    if not isBuy() then
				    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour6)
				    _btnEnabled = false
			    end
			    utils.GrayWidget(ui_itemIcon, true)
			    ui_imageSell:setVisible(true)
                if key == 1 then
                    UIActivityGrabTheHour.flagOne = false
                elseif key == 2 then
                    UIActivityGrabTheHour.flagTwo = false
                elseif key == 3 then
                    UIActivityGrabTheHour.flagThree = false
                end
		    elseif _curTime > _startTime and _curTime < _endTime then
			    if not isBuy() then
				    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour7)
				    _btnEnabled = true
                    if key == 1 then
                        UIActivityGrabTheHour.flagOne = false
                    elseif key == 2 then
                        UIActivityGrabTheHour.flagTwo = false
                    elseif key == 3 then
                        UIActivityGrabTheHour.flagThree = false
                    end
			    end
		    elseif _curTime >= _endTime then
			    if not isBuy() then
				    btn_exchange:setTitleText(Lang.ui_activity_grabTheHour8)
				    _btnEnabled = false
			    end
		    end
		
		    btn_exchange:setBright(_btnEnabled)
		    btn_exchange:setTouchEnabled(_btnEnabled)
		    btn_exchange:setPressedActionEnabled(true)
		    btn_exchange:addTouchEventListener(function(sender, eventType)
			    if eventType == ccui.TouchEventType.ended then
				    if UIActivityTime.checkMoney(_buyType, _buyPrice) then
					    UIManager.showLoading()
					    _tempHourDataThings = _things
					    netSendPackage({header=StaticMsgRule.grabTheHourBuy, msgdata={int={grabTheHourId=_id}}}, netCallbackFunc)
				    end
			    end
		    end)
	    end
    end
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.grabTheHour then
		_activityData = {}
		for key, obj in pairs(_msgData.msgdata.message.DictActivityGrabTheHour.message) do
			_activityData[#_activityData + 1] = obj
		end
		utils.quickSort(_activityData, function(obj1, obj2) if obj1.int["8"] > obj2.int["8"] then return true end end)
	else
		UIActivityTime.refreshMoney()
		if _tempHourDataThings then
			utils.showGetThings(_tempHourDataThings)
			_tempHourDataThings = nil
		end
		UIActivityGrabTheHour.setup()
		return
	end
    initActivityUI()
end

function UIActivityGrabTheHour.checkImageHint()
    local result = false
    local _curTime = utils.getCurrentTime()
    _startTimeOne = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeOne)].value)
	_startTimeTwo = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeTwo)].value)
    _startTimeThree = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.grabTheHourTimeThree)].value)
    if _curTime >= _startTimeOne and _curTime <=  _startTimeOne + 2*60*60 and UIActivityGrabTheHour.flagOne then
        result = true
    elseif _curTime >= _startTimeTwo and _curTime <= _startTimeTwo + 2*60*60 and UIActivityGrabTheHour.flagTwo then
        result = true
    elseif _curTime >= _startTimeThree and _curTime <= _startTimeThree + 2*60*60 and UIActivityGrabTheHour.flagThree then
        result = true
    else
        result = false
    end
    return result
end

function UIActivityGrabTheHour.init()

end

function UIActivityGrabTheHour.setup()
    dp.addTimerListener(countDowun)
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.grabTheHour, msgdata={}}, netCallbackFunc)
end

function UIActivityGrabTheHour.free()
    _tempHourDataThings = nil
    _countdownTime = 0
    dp.removeTimerListener(countDowun)
end
