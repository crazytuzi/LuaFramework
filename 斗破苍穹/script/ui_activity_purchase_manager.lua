UIActivityPurchaseManager = {}

local ACTIVITY_LIST = {
    { uiFileName = "ui_activity_purchase_trade", activityIcon = "ui/activity_trade.png" },
    { uiFileName = "ui_activity_purchase_gift", activityIcon = "ui/activity_gift.png" }
}

local ui_scrollView = nil
local ui_svItem = nil
local activityTime = {} --startTime, endTime

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
            if ui_focus == nil then
                ui_focus = ccui.ImageView:create("ui/frame_fg.png")
                ui_focus:setName("image_choose")
                ui_focus:setPosition(cc.p(obj:getContentSize().width / 2, obj:getContentSize().height / 2))
                obj:addChild(ui_focus)
            end
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
            if ui_focus then
                ui_focus:removeFromParent()
                ui_focus = nil
            end
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

function UIActivityPurchaseManager.init()
    local base_title = UIActivityPurchaseManager.Widget:getChildByName("base_title")
    ui_scrollView = base_title:getChildByName("view_warrior")
    ui_svItem = ui_scrollView:getChildByName("btn_base_warrior"):clone()
    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "groupon" then
                activityTime.startTime = obj.string["4"]
                activityTime.endTime = obj.string["5"]
                break
            end
        end
    end
end

function UIActivityPurchaseManager.setup()
    layoutScrollView(ACTIVITY_LIST, function(_item, _data, _index)
        _item:getChildByName("image_warrior"):loadTexture(_data.activityIcon)
        _item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                replaceWidget(_data.uiFileName, {time=activityTime, uiTitle=ui_scrollView})
                setScrollViewFocus(_index)
            end
        end)
    end)
    local childs = ui_scrollView:getChildren()
    if childs[1] then
        childs[1]:releaseUpEvent()
    end
end

function UIActivityPurchaseManager.show()
    UIManager.hideWidget("ui_team_info")
    UIManager.showWidget("ui_activity_purchase_manager")
end

function UIActivityPurchaseManager.free()
    cleanScrollView()
end