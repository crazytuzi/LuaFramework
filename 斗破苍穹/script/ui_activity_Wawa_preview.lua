require"Lang"
UIActivityWawaPreview = {}

local ui_scrollView = nil
local ui_svItem = nil

local _boxDatas = nil

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

function UIActivityWawaPreview.init()
    local image_basemap = UIActivityWawaPreview.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)

    ui_scrollView = image_basemap:getChildByName("view_ranking")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIActivityWawaPreview.setup()
    layoutScrollView(_boxDatas, function(_item, _data, _index)
        if _data then
            local ui_indexLabel = _item:getChildByName("image_base_panel"):getChildByName("text_panel")
            ui_indexLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            ui_indexLabel:setString(string.format(Lang.ui_activity_Wawa_preview1, _index))
            for i = 1, 8 do
                local ui_itemFrame = _item:getChildByName("image_frame_good"..i)
                if _data["things"..i] then
                    local itemProps = utils.getItemProp(_data["things"..i])
                    if itemProps then
                        if itemProps.frameIcon then
                            ui_itemFrame:loadTexture(itemProps.frameIcon)
                        end
                        if itemProps.smallIcon then
                            ui_itemFrame:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                            utils.showThingsInfo(ui_itemFrame:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                        end
                        if itemProps.name then
                            ui_itemFrame:getChildByName("text_name"):setString(itemProps.name)
                        end
                        if itemProps.qualityColor then
                            ui_itemFrame:getChildByName("text_name"):setTextColor(itemProps.qualityColor)
                        end
                        if itemProps.count then
                            ccui.Helper:seekNodeByName(ui_itemFrame, "text_number"):setString(tostring(itemProps.count))
                        end
                    end
                else
                    ui_itemFrame:setVisible(false)
                end
            end
        end
    end)
end

function UIActivityWawaPreview.free()
    cleanScrollView(true)
end

function UIActivityWawaPreview.show()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.lookFoolBoxReward, msgdata={}}, function(_msgData)
        _boxDatas = {}
        local allboxData = _msgData.msgdata.message.allboxdj.message
        for i = 1, UIActivityWawa.MAX_COUNT do
            _boxDatas[i] = allboxData["layer"..i].string
        end
        UIManager.pushScene("ui_activity_Wawa_preview")
    end)
end
