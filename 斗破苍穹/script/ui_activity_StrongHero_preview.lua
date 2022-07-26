require"Lang"
UIActivityStrongHeroPreview = {}

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
	local _innerHeight, SCROLLVIEW_ITEM_SPACE = 0, 10
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
    local ui_title = _item:getChildByName("image_base_hint"):getChildByName("text_lv")
    ui_title:setString(string.format(Lang.ui_activity_StrongHero_preview1, _data.rank))
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

function UIActivityStrongHeroPreview.init()
    local image_basemap = UIActivityStrongHeroPreview.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local tab_one = image_basemap:getChildByName("tab_one")
    local tab_two = image_basemap:getChildByName("tab_two")
    local tab_three = image_basemap:getChildByName("tab_three")
    btn_close:setPressedActionEnabled(true)
    btn_closed:setPressedActionEnabled(true)
    local _prevTabButton = nil
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            elseif _prevTabButton ~= sender then
                _prevTabButton = sender
                tab_one:getChildByName("text_one"):setTextColor(cc.c4b(255, 255, 255, 255))
                tab_two:getChildByName("text_two"):setTextColor(cc.c4b(255, 255, 255, 255))
                tab_three:getChildByName("text_three"):setTextColor(cc.c4b(255, 255, 255, 255))
                tab_one:loadTextures("ui/yh_btn01.png", "ui/yh_btn01.png")
                tab_two:loadTextures("ui/yh_btn01.png", "ui/yh_btn01.png")
                tab_three:loadTextures("ui/yh_btn01.png", "ui/yh_btn01.png")
                sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
                local _tempListData = {}
                if sender == tab_one then --12:00
                    tab_one:getChildByName("text_one"):setTextColor(cc.c4b(51, 25, 4, 255))
                    if _listData and _listData[12] then
                        _tempListData = _listData[12]
                    end
                elseif sender == tab_two then --21:00
                    tab_two:getChildByName("text_two"):setTextColor(cc.c4b(51, 25, 4, 255))
                    if _listData and _listData[21] then
                        _tempListData = _listData[21]
                    end
                elseif sender == tab_three then --23:00
                    tab_three:getChildByName("text_three"):setTextColor(cc.c4b(51, 25, 4, 255))
                    if _listData and _listData[23] then
                        _tempListData = _listData[23]
                    end
                end
                utils.quickSort(_tempListData, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
                layoutScrollView(_tempListData, setScrollViewItem)
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_closed:addTouchEventListener(onButtonEvent)
    tab_one:addTouchEventListener(onButtonEvent)
    tab_two:addTouchEventListener(onButtonEvent)
    tab_three:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_award_lv")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
    tab_one:releaseUpEvent()
end

function UIActivityStrongHeroPreview.setup()
    if userData then
        local image_basemap = UIActivityStrongHeroPreview.Widget:getChildByName("image_basemap")
        local image_info = image_basemap:getChildByName("image_info")
        local ui_curIntegral = image_info:getChildByName("text_integral_number")
        local ui_curIntegralRank = image_info:getChildByName("text_rank_number")
        ui_curIntegral:setString(tostring(userData.integral))
        ui_curIntegralRank:setString(tostring(userData.rank))
    end
end

function UIActivityStrongHeroPreview.free()
    cleanScrollView(true)
    _listData = nil
    userData = nil
end

function UIActivityStrongHeroPreview.show(_tableParams)
    userData = _tableParams
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.getStrogerHeroRankReward, msgdata={}}, function(_msgData)
        _listData = {} --[1]-12:00, [2]-21:00, [3]-24:00
        local _tempData = utils.stringSplit(_msgData.msgdata.string["1"], "/")
        for key, obj in pairs(_tempData) do
            local _obj = utils.stringSplit(obj, "|")
            if not _listData[tonumber(_obj[2])] then
                _listData[tonumber(_obj[2])] = {}
            end
            _listData[tonumber(_obj[2])][#_listData[tonumber(_obj[2])] + 1] = {
                id = tonumber(_obj[1]),
                rank = tonumber(_obj[3]),
                rewards = _obj[4]
            }
        end
        UIManager.pushScene("ui_activity_StrongHero_preview")
    end)
end
