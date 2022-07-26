UIActivityOnePreview = {}

local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local SCROLLVIEW_ITEM_SPACE = 10
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
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

function UIActivityOnePreview.init()
    local image_hint = UIActivityOnePreview.Widget:getChildByName("image_hint")
    local btn_close = image_hint:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)

    ui_scrollView = image_hint:getChildByName("view")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIActivityOnePreview.setup()
    
end

function UIActivityOnePreview.free()
    cleanScrollView(true)
end

function UIActivityOnePreview.show()
    UIManager.showLoading()
    local _up = 0
    netSendPackage( {
        header = StaticMsgRule.openOneGoldShopPanel, msgdata = {}
    } , function(_msgData)
        _up = _msgData.msgdata.int.up
        end
    )
    netSendPackage( {
        header = StaticMsgRule.lookOneGoldShopThing, msgdata = {}
    } , function(_msgData)
        UIManager.pushScene("ui_activity_one_preview")
        local _reward = utils.stringSplit(_msgData.msgdata.string.reward, ";")
        layoutScrollView(_reward, function(_item, _data, _index)
            local ui_timeLabel = ccui.Helper:seekNodeByName(_item, "text_lv_number")
            local ui_frame = _item:getChildByName("image_frame_good")
            local ui_icon = ui_frame:getChildByName("image_good")
            local ui_name = ui_frame:getChildByName("text_name")
            local ui_end = _item:getChildByName("image_end")
            local _tempData = utils.stringSplit(_data, ",")
            ui_timeLabel:setString(_tempData[1] .. ":00")
            local itemProp = utils.getItemProp(_tempData[2])
            if itemProp then
                if itemProp.frameIcon then
                    ui_frame:loadTexture(itemProp.frameIcon)
                end
                if itemProp.smallIcon then
                    ui_icon:loadTexture(itemProp.smallIcon)
                    utils.showThingsInfo(ui_icon, itemProp.tableTypeId, itemProp.tableFieldId)
                end
                if itemProp.name then
                    if itemProp.qualityColor then
                        ui_name:setTextColor(itemProp.qualityColor)
                    end
                    ui_name:setString(itemProp.name .. "×" .. itemProp.count)
                end
                if _up then
                    ui_end:setVisible(false)
                else
                    ui_end:setVisible(true)
                end
            end
        end)
    end )
end