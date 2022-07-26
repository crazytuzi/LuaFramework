UIActivityTime = {}

local ui_scrollView = nil
local ui_svItem = nil

UIActivityTime._jumpActivityName = nil
local _prevActivity = nil
local _StrongHeroFlag = 0--当天是否为巅峰强者节日版  0-不是   1-是
local _FundShow = 0--当天是否显示福利基金 0-不是 1-是
local _SevenArenaShow = 0 --当天是否显示强者榜活动 0-不显示 1-显示
local _SevenArenaTime = nil --强者榜开服时间（用来计算截止时间）
local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function setScrollViewFocus(_index, isJumpTo)
    local childs = ui_scrollView:getChildren()
    for key, obj in pairs(childs) do
        local ui_focus = obj:getChildByName("image_choose")
        if _index == key then
            ui_focus:setVisible(true)
            local contaniner = ui_scrollView:getInnerContainer()
            local w =(contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
            local dt
            if w == 0 then
                dt = 0
            else
                dt =(obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
                if dt < 0 then
                    dt = 0
                end
            end
            if isJumpTo then
                ui_scrollView:jumpToPercentHorizontal(dt * 100)
            else
                ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
            end
        else
            ui_focus:setVisible(false)
        end
    end
end

local function layoutScrollView(_listData, _initItemFunc)
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerWidth, SCROLLVIEW_ITEM_SPACE = 0, 10
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
        scrollViewItem:setName("item_"..key)
		_initItemFunc(scrollViewItem, obj, key)
		ui_scrollView:addChild(scrollViewItem)
		_innerWidth = _innerWidth + scrollViewItem:getContentSize().width + SCROLLVIEW_ITEM_SPACE
	end
	_innerWidth = _innerWidth + SCROLLVIEW_ITEM_SPACE
	if _innerWidth < ui_scrollView:getContentSize().width then
		_innerWidth = ui_scrollView:getContentSize().width
	end
	ui_scrollView:setInnerContainerSize(cc.size(_innerWidth, ui_scrollView:getContentSize().height))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(childs[i]:getContentSize().width / 2 + SCROLLVIEW_ITEM_SPACE, ui_scrollView:getContentSize().height / 2)
		else
			childs[i]:setPosition(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + SCROLLVIEW_ITEM_SPACE, ui_scrollView:getContentSize().height / 2)
		end
		prevChild = childs[i]
	end
end

local function replaceWidget(aWidgetName, _params)
    if _params then
        local tableObj = WidgetManager.getAllWidgetClass()[aWidgetName]
        if tableObj and type(tableObj.onActivity) == "function" then
            tableObj.onActivity(_params)
        end
    end
	local ui_widget = WidgetManager.create(aWidgetName)
	if ui_widget then
		local prev_uiWidget = UIManager.uiLayer:getChildByTag(ui_widget:getTag())
		if prev_uiWidget then
			local class = WidgetManager.getClass(prev_uiWidget:getName())
			UIManager.uiLayer:removeChild(prev_uiWidget, false)
			if class and class.free then
				class.free()
			end
		end
		UIManager.uiLayer:addChild(ui_widget)
	end
end

--_buyType 1:元宝, 2:银币
function UIActivityTime.checkMoney(_buyType, _price)
	local _money = (_buyType == 1 and net.InstPlayer.int["5"] or tonumber(net.InstPlayer.string["6"]))
	if _money >= _price then
		return true
	else
		-- UIManager.showToast(string.format("%s不足！", (_buyType == 1 and "元宝" or "银币")))
		UIHintBuy.show(_buyType == 1 and UIHintBuy.MONEY_TYPE_GOLD or UIHintBuy.MONEY_TYPE_SILVER)
		return false
	end
end

function UIActivityTime.refreshMoney()
    local image_bian = ccui.Helper:seekNodeByName(UIActivityTime.Widget, "image_bian")
    ccui.Helper:seekNodeByName(image_bian, "text_gold_number"):setString(tostring(net.InstPlayer.int["5"]))
    ccui.Helper:seekNodeByName(image_bian, "text_silver_number"):setString(net.InstPlayer.string["6"])
end

function UIActivityTime.init()
    ui_scrollView = ccui.Helper:seekNodeByName(UIActivityTime.Widget, "view_title")
    ui_svItem = ui_scrollView:getChildByName("btn_base_warrior"):clone()
    local recharge = ccui.Helper:seekNodeByName(UIActivityTime.Widget, "image_recharge")
    recharge:setTouchEnabled(true)
    recharge:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            utils.checkGOLD(1)
        end
    end)
end

function UIActivityTime.getActivityThing()
     local DictActivity = {}
     if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if 100 < obj.int["1"] and obj.int["1"] <= 200 then --限时抢购的活动范围
                if obj.int["8"] == 1 then
                    local _startTime = obj.string["4"]
                    local _endTime = obj.string["5"]
                    local _curTime = utils.getCurrentTime()
                    if obj.string["9"] == "fund_reward" and _FundShow == 0 then
                    elseif obj.string["9"] == "Stronger_ranking" and _SevenArenaShow == 0 then
                    elseif (_startTime == "" and _endTime == "") or (utils.GetTimeByDate(_startTime) < _curTime and _curTime < utils.GetTimeByDate(_endTime)) then
                        DictActivity[#DictActivity + 1] = obj
                    end
                end
            end
        end
        utils.quickSort(DictActivity, function(obj1, obj2) if obj1.int["11"] > obj2.int["11"] then return true end end)
    end
    return DictActivity
end

function UIActivityTime.setup()
    local image_bian = ccui.Helper:seekNodeByName(UIActivityTime.Widget, "image_bian")
    ccui.Helper:seekNodeByName(image_bian, "label_fight"):setString(tostring(utils.getFightValue()))
    UIActivityTime.refreshMoney()
    local DictActivity = UIActivityTime.getActivityThing()
    
    layoutScrollView(DictActivity, function(_item, _data, _index)
        if _data.string["9"] == "StrongHero" and _StrongHeroFlag == 1 then
            _item:getChildByName("image_warrior"):loadTexture("ui/activity_title10_1.png")
        else
            print( "icon :" , _data.int["3"] , " "  , DictUI[tostring(_data.int["3"])].fileName ) ;
            _item:getChildByName("image_warrior"):loadTexture("ui/" .. DictUI[tostring(_data.int["3"])].fileName)
        end
        _item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended and _prevActivity ~= sender then
                _prevActivity = sender
                setScrollViewFocus(_index)
                _item:removeChildByTag(100)
                if _data.string["9"] == "Stronger_ranking" then
                    UIActivityStrongerRanking.setTime(_SevenArenaTime)
                end
                if _data.string["9"] == "StrongHero" and _StrongHeroFlag == 1 then
                    _data.StrongHeroFlag = _StrongHeroFlag
                else
                    _data.StrongHeroFlag = nil
                end
                replaceWidget("ui_activity_" .. _data.string["9"], _data)
            end
        end)
        if _data.string["9"] == "grabTheHour" then
            utils.addImageHint(UIActivityGrabTheHour.checkImageHint(),_item,100,15,13)
        end
        if _data.string["9"] == "LimitTimeHero" then
            utils.addImageHint(UIAactivityLimitTimeHero.checkImageHint(),_item,100,15,13)
        end
        
    end)
    local childs = ui_scrollView:getChildren()
    if childs[1] then
        childs[1]:releaseUpEvent()
    end
end
function UIActivityTime.jumpName( sname )
    UIActivityTime._jumpActivityName = sname
    local DictActivity = UIActivityTime.getActivityThing()
    
    for key , value in pairs ( DictActivity ) do
        _data = value
        _index = key
        _item = ui_scrollView:getChildByName("item_"..key)
        if UIActivityTime._jumpActivityName and _data.string["9"] == tostring( UIActivityTime._jumpActivityName ) then --跳转活动
            cclog("_index : ".._index)
             _prevActivity = _item
             _item:removeChildByTag(100)
             setScrollViewFocus(_index)
            replaceWidget("ui_activity_" .. _data.string["9"], _data)
             break
        end
    end
end

function UIActivityTime.show()
    UIManager.showLoading()
    netSendPackage({ header = StaticMsgRule.intoLimitActivity, msgdata = { }}, function(_msgData)
         local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
        _StrongHeroFlag = _msgData.msgdata.int["1"] --当天是否为巅峰强者节日版  0-不是   1-是
        _FundShow = _msgData.msgdata.int["2"]
        if net.InstPlayer.int["4"] < openLv   then
             _SevenArenaShow = 0
        else
             _SevenArenaShow = _msgData.msgdata.int["3"]
        end  
        _SevenArenaTime = _msgData.msgdata.string["4"]
        UIManager.hideWidget("ui_team_info")
        UIManager.showWidget("ui_activity_time")
    end)
end

function UIActivityTime.free()
    cleanScrollView()
    UIActivityTime._jumpActivityName = nil
end