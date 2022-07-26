UIAllianceEscortDynamic = {}

local userData = nil

local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView()
    ui_scrollView:removeAllChildren()
end

local function getDynamicItem()
	local ui_richText = ccui.RichText:create()
	ui_richText:setName("ui_richText")
	ui_richText:ignoreContentAdaptWithSize(false)
	ui_richText:setContentSize(cc.size(ui_scrollView:getContentSize().width - 10, 55))
	return ui_richText
end

local function layoutScrollView(_listData, _initItemFunc)
    local SCROLLVIEW_ITEM_SPACE = 20
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = getDynamicItem()
		_initItemFunc(scrollViewItem, obj, key)
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
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UIAllianceEscortDynamic.init()
    local image_hint = UIAllianceEscortDynamic.Widget:getChildByName("image_hint")
    local btn_closed = image_hint:getChildByName("btn_closed")
    btn_closed:setPressedActionEnabled(true)
    btn_closed:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)
    ui_scrollView = image_hint:getChildByName("view")
end

function UIAllianceEscortDynamic.setup()
    local dynaData = {}
    if net.InstUnionLootDyna then
        for key, obj in pairs(net.InstUnionLootDyna) do
            dynaData[#dynaData + 1] = obj
        end
        utils.quickSort(dynaData, function(obj1, obj2) if obj1.int["1"] < obj2.int["1"] then return true end end)
    end
    layoutScrollView(dynaData, function(_item, _data, _index)
        _item:pushBackElement(ccui.RichElementText:create(1, cc.c3b(255,255,255), 255, _data.string["3"] .. "   ", dp.FONT, 18))
        local richText = utils.richTextFormat(_data.string["2"])
        for key, obj in pairs(richText) do
		    _item:pushBackElement(ccui.RichElementText:create(key + 1, obj.color, 255, obj.text, dp.FONT, 18))
	    end
    end)
end

function UIAllianceEscortDynamic.free()
    cleanScrollView(true)
    userData = nil
end

function UIAllianceEscortDynamic.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_dynamic")
end