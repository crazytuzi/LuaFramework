UIAllianceManageChange = {}

local ui_scrollView = nil
local ui_svItem = nil

local userData = nil

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
        if ui_svItem and ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
        end
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local ITEM_ROW = 3
    local SCROLLVIEW_ITEM_SPACE = 0
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
		_initItemFunc(scrollViewItem, obj, key)
		ui_scrollView:addChild(scrollViewItem)
        if key % ITEM_ROW == 0 then
		    _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
        end
	end
    if #_listData % ITEM_ROW ~= 0 then
        _innerHeight = _innerHeight + ui_svItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
    local _index = 1
	for i = 1, #childs do
        local _x = _index * (ui_scrollView:getContentSize().width / ITEM_ROW) - (ui_scrollView:getContentSize().width / ITEM_ROW / 2)
        local _y = prevChild and (prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE) or (ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        _index = _index + 1
        if i % ITEM_ROW == 0 then
            _index = 1
            prevChild = childs[i]
        end
        childs[i]:setPosition(_x, _y)
	end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.convertUnionFlag then
        UIManager.popScene()
        UIAllianceManage.setup()
    end
end

function UIAllianceManageChange.init()
    local image_basemap = UIAllianceManageChange.Widget:getChildByName("image_basemap")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local btn_ok = image_basemap:getChildByName("btn_ok")
    btn_closed:setPressedActionEnabled(true)
    btn_ok:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_ok then
                local childs = ui_scrollView:getChildren()
                for key, obj in pairs(childs) do
                    if obj:getChildByName("image_choose"):isVisible() and userData.allianceIconId ~= obj:getTag() then
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.convertUnionFlag,
                            msgdata = { int = { unionFlagId = obj:getTag() } }
                        } , netCallbackFunc)
                        return
                    end
                end
                UIManager.popScene()
            end
        end
    end
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_ok:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_flag")
    ui_svItem = ui_scrollView:getChildByName("image_di_flag1"):clone()
end

function UIAllianceManageChange.setup()
    local image_basemap = UIAllianceManageChange.Widget:getChildByName("image_basemap")
    local ui_allianceIcon = image_basemap:getChildByName("image_equipment")
    ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(userData.allianceIconId)].bigUiId)].fileName)
    layoutScrollView(DictUnionFlag, function(_item, _data)
        _item:setTag(_data.id)
        local ui_icon = _item:getChildByName("image_flag")
        local ui_choose = _item:getChildByName("image_choose")
        ui_icon:loadTexture("image/" .. DictUI[tostring(_data.bigUiId)].fileName)
        if userData.allianceIconId == _data.id then
            ui_choose:setVisible(true)
        else
            ui_choose:setVisible(false)
        end
        _item:setTouchEnabled(true)
        _item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local childs = ui_scrollView:getChildren()
                for key, obj in pairs(childs) do
                    obj:getChildByName("image_choose"):setVisible(false)
                end
                ui_choose:setVisible(true)
            end
        end)
    end)
end

function UIAllianceManageChange.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_manage_change")
end

function UIAllianceManageChange.free()
    cleanScrollView(true)
    userData = nil
end