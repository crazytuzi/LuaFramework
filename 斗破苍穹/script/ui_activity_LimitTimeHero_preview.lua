require"Lang"
UIActivityLimitTimeHeroPreview = {}

local ui_scrollView = nil
local ui_svItem = nil
local userData = nil

local _listData = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() > 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem and ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
        end
    end
end

local function layoutScrollView(_listData, _initItemFunc)
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight, SCROLLVIEW_ITEM_SPACE = 0, 25
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
		_initItemFunc(scrollViewItem, obj)
		ui_scrollView:addChild(scrollViewItem)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function setScrollViewItem(_item, _data)
    local ui_titile = _item:getChildByName("image_base_hint"):getChildByName("text_lv")
    ui_titile:setString(string.format(Lang.ui_activity_LimitTimeHero_preview1, _data.saveJifenNum))
    local _thingsData = utils.stringSplit(_data.rewards, ";")
    for key = 1, 3 do
        local _thingItem = _item:getChildByName("image_frame_good" .. key)
        if _thingsData[key] then
            local itemProps = utils.getItemProp(_thingsData[key])
            if itemProps.frameIcon then
                _thingItem:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                _thingItem:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                utils.showThingsInfo(_thingItem:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                utils.addThingParticle(_thingsData[key],_thingItem:getChildByName("image_good"),true)
            end
            if itemProps.name then
                _thingItem:getChildByName("text_name"):setString(itemProps.name)
            end
            _thingItem:getChildByName("text_number"):setString("×" .. itemProps.count)
            _thingItem:setVisible(true)
        else
            _thingItem:setVisible(false)
        end
    end
end

function UIActivityLimitTimeHeroPreview.init()
    local image_basemap = UIActivityLimitTimeHeroPreview.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    btn_close:setPressedActionEnabled(true)
    btn_closed:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_closed:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_award_lv")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIActivityLimitTimeHeroPreview.setup()
    if _listData then
        layoutScrollView(_listData, setScrollViewItem)
        local image_basemap = UIActivityLimitTimeHeroPreview.Widget:getChildByName("image_basemap")
        local image_info = image_basemap:getChildByName("image_info")
        local ui_curIntegral = image_info:getChildByName("text_integral_number")
        local ui_curIntegralRank = image_info:getChildByName("text_rank_number")
        ui_curIntegral:setString(tostring(userData.integral))
        ui_curIntegralRank:setString(tostring(userData.rank))
    end
end

function UIActivityLimitTimeHeroPreview.free()
    cleanScrollView(true)
    _listData = nil
    userData = nil
end

function UIActivityLimitTimeHeroPreview.show(_tableParams)
    userData = _tableParams
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.getJifenRewardList, msgdata={}}, function(_msgData)
        _listData = {}
        local _tempData = utils.stringSplit(_msgData.msgdata.string["1"], "/")
        for key, obj in pairs(_tempData) do
            local _obj = utils.stringSplit(obj, "|")
            _listData[#_listData + 1] = {
                id = tonumber(_obj[1]),
                saveJifenNum = tonumber(_obj[2]),
                rewards = _obj[3]
            }
        end
        utils.quickSort(_listData, function(obj1, obj2) if obj1.saveJifenNum > obj2.saveJifenNum then return true end end)
        UIManager.pushScene("ui_activity_LimitTimeHero_preview")
    end)
end
