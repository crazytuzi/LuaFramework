require"Lang"
UIActivityDailyDeals = {}

local _buyIndex = nil
local _activityData = nil

local netCallbackFunc = nil

local function initActivityUI()
	if _activityData then
		local image_base_good1 = ccui.Helper:seekNodeByName(UIActivityDailyDeals.Widget, "image_base_good1")
		for i = 1, 6 do
			local item = image_base_good1:getChildByName("image_frame_good" .. i)
			if item and _activityData.things[i] and _activityData.price[i] then
				item:setVisible(true)
				local itemProps = utils.getItemProp(_activityData.things[i])
				item:loadTexture(itemProps.frameIcon)
				local text_good = item:getChildByName("text_good")
				text_good:setString(itemProps.name)
				text_good:setTextColor(itemProps.qualityColor)
				local image_good = item:getChildByName("image_good")
				image_good:loadTexture(itemProps.smallIcon)
				utils.showThingsInfo(image_good, itemProps.tableTypeId, itemProps.tableFieldId)
                utils.addThingParticle(_activityData.things[i],image_good,true)

				ccui.Helper:seekNodeByName(item, "text_number"):setString(tostring(itemProps.count))
				ccui.Helper:seekNodeByName(item, "text_gold_number"):setString("×" .. _activityData.price[i])
				local btn_exchange = item:getChildByName("btn_exchange")
				if _activityData.buyState[i] == "0" then
					utils.GrayWidget(btn_exchange, false)
					btn_exchange:setEnabled(true)
					btn_exchange:setTitleText(Lang.ui_activity_dailyDeals1)
					btn_exchange:setPressedActionEnabled(true)
					btn_exchange:addTouchEventListener(function(sender, eventType)
						if eventType == ccui.TouchEventType.ended then
							audio.playSound("sound/button.mp3")
							if UIActivityTime.checkMoney(1, tonumber(_activityData.price[i])) then
								UIManager.showLoading()
								_buyIndex = i
								netSendPackage({header=StaticMsgRule.dailyDeals, msgdata={int={id=_activityData.id, index=_buyIndex - 1}}}, netCallbackFunc)
							end
						end
					end)
				else
					utils.GrayWidget(btn_exchange, true)
					btn_exchange:setEnabled(false)
					btn_exchange:setTitleText(Lang.ui_activity_dailyDeals2)
				end
			else
				item:setVisible(false)
			end
		end
	end
end

netCallbackFunc = function(pack)
	local code = tonumber(pack.header)
	if code == StaticMsgRule.getDailyDeals then
		_activityData = {}
		local _msgData = utils.stringSplit(pack.msgdata.string["1"], " ")
		_activityData.id = tonumber(_msgData[1])
		_activityData.listName = _msgData[2]
		_activityData.things = utils.stringSplit(_msgData[3], ";")
		_activityData.price = utils.stringSplit(_msgData[4], ";")
		_activityData.buyState = utils.stringSplit(_msgData[5], ";")
	elseif code == StaticMsgRule.dailyDeals then
		UIActivityTime.refreshMoney()
		if _buyIndex and _activityData and _activityData.things[_buyIndex] then
			utils.showGetThings(_activityData.things[_buyIndex])
			_activityData.buyState[_buyIndex] = "1" --已购买
			_buyIndex = nil
		end
	end
	initActivityUI()
end

function UIActivityDailyDeals.init()

end

function UIActivityDailyDeals.setup()
	UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.getDailyDeals, msgdata={}}, netCallbackFunc)
end

function UIActivityDailyDeals.free()
	_buyIndex = nil
end
