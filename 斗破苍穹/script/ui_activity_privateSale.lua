require"Lang"
UIActivityPrivateSale = {}

local _tempActivityDataIndex = nil
local _activityData = nil

local netCallbackFunc = nil

local function initActivityUI()
    if _activityData then
        local image_basemap = UIActivityPrivateSale.Widget:getChildByName("image_basemap")
	    local _time1 = DictSysConfig[tostring(StaticSysConfig.privateSaleTimeOne)].value
	    local _time2 = DictSysConfig[tostring(StaticSysConfig.privateSaleTimeTwo)].value
	    _time1 = string.format("%02d:%02d", math.floor(_time1), (_time1 - math.floor(_time1)) * 60)
	    _time2 = string.format("%02d:%02d", math.floor(_time2), (_time2 - math.floor(_time2)) * 60)
	    image_basemap:getChildByName("text_time1"):setString(_time1)
	    image_basemap:getChildByName("text_time2"):setString(_time2)
	    for key, obj in pairs(_activityData) do
		    local _id = obj.int["1"]
		    local _smallUiId = obj.int["2"]
		    local _things = obj.string["4"]
		    local _buyCount = obj.int["5"]
		    local _buyType = obj.int["6"]
		    local _price = obj.int["7"]
            local itemProps = utils.getItemProp(_things)
		    local item = image_basemap:getChildByName("image_base_good" .. key)
		    item:getChildByName("image_title"):loadTexture("ui/" .. DictUI[tostring(_smallUiId)].fileName)
		    local ui_name = item:getChildByName("text_info")
		    ui_name:setString(itemProps.name)
            if itemProps.qualityColor then
		        ui_name:setTextColor(itemProps.qualityColor)
            end
		    local ui_frame = item:getChildByName("image_frame_good")
		    ui_frame:loadTexture(itemProps.frameIcon)
		    ui_frame:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
		    utils.showThingsInfo(ui_frame:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
		    local ui_buyTypeImg = ui_frame:getChildByName("image_price")
		    ui_buyTypeImg:loadTexture(_buyType == 1 and "ui/jin.png" or "ui/yin.png")
		    ui_buyTypeImg:getChildByName("text_price"):setString(tostring(_price))
		    ccui.Helper:seekNodeByName(ui_frame, "text_number"):setString(tostring(itemProps.count))
		    local btn_exchange = item:getChildByName("btn_exchange")
		    btn_exchange:setTitleText(Lang.ui_activity_privateSale1)
		    local _btnEnabled = true
		    if net.InstPlayerPrivateSale then
			    for _ippsKey, _ippsObj in pairs(net.InstPlayerPrivateSale) do
				    if _id == _ippsObj.int["3"] then
					    _btnEnabled = false
					    btn_exchange:setTitleText(Lang.ui_activity_privateSale2)
					    break
				    end
			    end
		    end
		    btn_exchange:setBright(_btnEnabled)
		    btn_exchange:setTouchEnabled(_btnEnabled)
		    btn_exchange:setPressedActionEnabled(true)
		    btn_exchange:addTouchEventListener(function(sender, eventType)
			    if eventType == ccui.TouchEventType.ended then
				    if UIActivityTime.checkMoney(_buyType, _price) then
					    UIManager.showLoading()
					    _tempActivityDataIndex = key
					    netSendPackage({header=StaticMsgRule.privateSaleBuy, msgdata={int={privateSaleId=_id}}}, netCallbackFunc)
				    end
			    end
		    end)
	    end
    end
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.privateSale then
		_activityData = {}
		for key, obj in pairs(_msgData.msgdata.message.DictActivityPrivateSale.message) do
			_activityData[#_activityData + 1] = obj
		end
		-- utils.quickSort(_activityData, function(obj1, obj2) if obj1.int["6"] > obj2.int["6"] then return true end end)
	else
		UIActivityTime.refreshMoney()
		if _tempActivityDataIndex and _activityData and _activityData[_tempActivityDataIndex] then
			local obj = _activityData[_tempActivityDataIndex]
			utils.showGetThings(obj.string["4"])
			_tempActivityDataIndex = nil
		end
	end
    initActivityUI()
end

function UIActivityPrivateSale.init()

end

function UIActivityPrivateSale.setup()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.privateSale, msgdata={}}, netCallbackFunc)
end

function UIActivityPrivateSale.free()
    _tempActivityDataIndex = nil
end
