require"Lang"
UIActivityBuy = {}

local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView()
	if ui_svItem:getReferenceCount() == 1 then
		ui_svItem:retain()
	end
	ui_scrollView:removeAllChildren()
end

local function netCallbackFunc(data)
	UIManager.showToast(Lang.ui_activity_buy1)
	UIActivityBuy.setup(true)
end

local _curTime = 0

---返回 天：时：分：秒 
local function getTime(_secsNums)
	-- local day = math.floor(_secsNums / 3600 / 24) --天
	local hour = math.floor(_secsNums / 3600 % 72) --小时
	local minute = math.floor(_secsNums / 60 % 60) --分
	local second = math.floor(_secsNums % 60) --秒
	-- return {day, hour, minute, second}
	return {hour, minute, second}
end

local function countDown(dt)
	_curTime = _curTime - 1
	if _curTime <= 0 then
		_curTime = 0
		if _countdownId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownId)
			_countdownId = nil
		end
	end
	if UIActivityBuy.Widget then
		local ui_timeText = ccui.Helper:seekNodeByName(UIActivityBuy.Widget, "text_time")
		local times = getTime(_curTime)
		ui_timeText:setString(string.format("%02d:%02d:%02d", times[1], times[2], times[3]))
	end
end

local function initScrollViewItem(item, data, enabled)
	item:getChildByName("text_info"):setString(data.description)
	local things = utils.stringSplit(data.things, ";")
	for i = 1, 4 do
		local thingItem = item:getChildByName("image_di"):getChildByName("image_frame_good" .. i)
		if things[i] then
            local itemProps = utils.getItemProp(things[i])
			if itemProps.frameIcon then
				thingItem:loadTexture(itemProps.frameIcon)
			end
			if itemProps.smallIcon then
				thingItem:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
				utils.showThingsInfo(thingItem:getChildByName("image_good"),itemProps.tableTypeId,itemProps.tableFieldId)
			end
			thingItem:getChildByName("text_price"):setString("×" .. itemProps.count)
		else
			thingItem:setVisible(false)
		end
	end
	ccui.Helper:seekNodeByName(item, "text_gold_number"):setString(tostring(data.buyGold))
	local btn_exchange = item:getChildByName("btn_exchange")
	btn_exchange:setBright(enabled)
	btn_exchange:setTouchEnabled(btn_exchange:isBright())
	btn_exchange:setPressedActionEnabled(true)
	btn_exchange:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_exchange then
				if _curTime == 0 and _countdownId == nil then
					UIManager.showToast(Lang.ui_activity_buy2)
				else
					if net.InstPlayer.int["5"] >= data.buyGold then
						UIManager.showLoading()
						netSendPackage({header = StaticMsgRule.flashSale, msgdata = {int={activityFlashSaleId=data.id}}}, netCallbackFunc)
					else
						UIManager.showToast(Lang.ui_activity_buy3)
					end
				end
			end
		end
	end)
end

function UIActivityBuy.init()
	local image_shadow_down = ccui.Helper:seekNodeByName(UIActivityBuy.Widget, "image_shadow_down")
	ui_scrollView = image_shadow_down:getChildByName("view_info")
	ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
end

function UIActivityBuy.setup(_isRefresh)
	cleanScrollView()
	local curActivityId = 7 --暂时写死了
	local dafIds = nil
	if net.InstActivity then
		for key, obj in pairs(net.InstActivity) do
			if obj.int["3"] == curActivityId then
				dafIds = utils.stringSplit(obj.string["4"], ";")
				if _countdownId then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownId)
					_countdownId = nil
				end
				_curTime = obj.int["6"] - utils.getCurrentTime()
				if _curTime > 0 then
					_countdownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown, 1, false)
				else
					_curTime = 0
				end
				break
			end
		end
	end
	local isItemEnabled = function(_id)
		if dafIds then
			for key, obj in pairs(dafIds) do
				if _id == tonumber(obj) then
					return false
				end
			end
		end
		return true
	end
	local innerHeight, space, _index = 0, 0, 0
    local thingTable = {}
    for key , obj in pairs( DictActivityFlashSale ) do
        table.insert( thingTable , obj )
    end
    local function comp( obj1 , obj2 )
        if obj1.id > obj2.id then
            return true
        else
            return false
        end
    end
    utils.quickSort( thingTable , comp )
	for key, obj in pairs(thingTable) do
		_index = _index + 1
		local scrollViewItem = ui_svItem:clone()
		initScrollViewItem(scrollViewItem, obj, isItemEnabled(obj.id))
		ui_scrollView:addChild(scrollViewItem)
		innerHeight = innerHeight + scrollViewItem:getContentSize().height + space
	end
	if innerHeight < ui_scrollView:getContentSize().height then
		innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - 5))
		else
			childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - space))
		end
		prevChild = childs[i]
	end
	if not _isRefresh then
		ActionManager.ScrollView_SplashAction(ui_scrollView)
	end
    cc.UserDefault:getInstance():setBoolForKey("flashSale",false) --进入过这个页面就记录下来，以后不再显示红点
    UIActivityPanel.addImageHint(UIActivityBuy.checkImageHint(),"flashSale")
end

function UIActivityBuy.isActivityEnd()
	local curActivityId = 7 --暂时写死了
	if net.InstActivity then
		for key, obj in pairs(net.InstActivity) do
			if obj.int["3"] == curActivityId then
				if obj.int["6"] - utils.getCurrentTime() > 0 then
					return false
				end
			end
		end
	end
	return true
end

function UIActivityBuy.free()
	cleanScrollView()
	if _countdownId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownId)
		_countdownId = nil
	end
end

function UIActivityBuy.checkImageHint()
    return cc.UserDefault:getInstance():getBoolForKey("flashSale",true)
end
