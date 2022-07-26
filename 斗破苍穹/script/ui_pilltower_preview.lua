require"Lang"
UIPilltowerPreview = {}

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil
local _maxPointId = nil --当日最高层数

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
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function setScrollViewItem(_item, _data)
    local ui_title = _item:getChildByName("image_base_hint"):getChildByName("text_lv")
    if _data.rankSub == _data.rankSup then
        ui_title:setString(string.format(Lang.ui_pilltower_preview1, _data.rankSub))
    else
        ui_title:setString(string.format(Lang.ui_pilltower_preview2, _data.rankSub, _data.rankSup))
    end
    
    local _thingData = utils.stringSplit(_data.awards, ";")
    for i = 1, 4 do
        local ui_frame = _item:getChildByName("image_frame_good"..i)
        if _thingData[i] then
            local itemProps = utils.getItemProp(_thingData[i])
            if itemProps.frameIcon then
                ui_frame:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                ui_frame:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                utils.showThingsInfo(ui_frame:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
            end
            if itemProps.name then
                ui_frame:getChildByName("text_name"):setString(itemProps.name)
                if itemProps.qualityColor then
                    ui_frame:getChildByName("text_name"):setTextColor(itemProps.qualityColor)
                end
            end
            ccui.Helper:seekNodeByName(ui_frame, "text_number"):setString(tostring(itemProps.count))
        else
            ui_frame:setVisible(false)
        end
    end
end

function UIPilltowerPreview.init()
    local image_basemap = UIPilltowerPreview.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    local function onClickEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(onClickEvent)
    ui_scrollView = image_basemap:getChildByName("view_rank")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIPilltowerPreview.setup()
    local _prevUIBtn = nil
    local image_basemap = UIPilltowerPreview.Widget:getChildByName("image_basemap")
    local ui_textHint = image_basemap:getChildByName("text_hint")

    local _curFightPoint, _curFightStartPointId = UIPilltower.UserData.curFightPoint, 5
    if _curFightPoint % userData.maxPointCount == 0 then
        _curFightStartPointId = _curFightPoint
    else
        _curFightStartPointId = math.floor(_curFightPoint / userData.maxPointCount) * userData.maxPointCount + userData.maxPointCount
    end
    local ui_listView = {}
    for i = 1, 3 do
        ui_listView[i] = image_basemap:getChildByName("image_base_level"..i)
        if not DictDantaLayer[tostring(_curFightStartPointId + 2 * userData.maxPointCount)] then
            _curFightStartPointId = _curFightStartPointId - userData.maxPointCount
        end
    end
    for key, _item in pairs(ui_listView) do
        local ui_title = _item:getChildByName("image_base_hint"):getChildByName("text_lv")
        ui_title:setString(string.format(Lang.ui_pilltower_preview3, _curFightStartPointId))
        if _curFightPoint > _curFightStartPointId or _maxPointId >= _curFightStartPointId then
            _item:getChildByName("image_state"):loadTexture("ui/rw_ylq.png")
        else
            _item:getChildByName("image_state"):loadTexture("ui/wdc.png")
        end
        local layerAwards = DictDantaLayer[tostring(_curFightStartPointId)].layerAwards
        local awards = utils.stringSplit(layerAwards, "#")[2]
        local _thingData = utils.stringSplit(awards, ";")
        for i = 1, 3 do
            local ui_frame = _item:getChildByName("image_frame_good"..i)
            if _thingData[i] then
                local itemProps = utils.getItemProp(_thingData[i])
                if itemProps.frameIcon then
                    ui_frame:loadTexture(itemProps.frameIcon)
                end
                if itemProps.smallIcon then
                    ui_frame:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                    utils.showThingsInfo(ui_frame:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                end
                if itemProps.name then
                    ui_frame:getChildByName("text_name"):setString(itemProps.name)
                    if itemProps.qualityColor then
                        ui_frame:getChildByName("text_name"):setTextColor(itemProps.qualityColor)
                    end
                end
                ccui.Helper:seekNodeByName(ui_frame, "text_number"):setString(tostring(itemProps.count))
            else
                ui_frame:setVisible(false)
            end
        end
        awards = nil
        _curFightStartPointId = _curFightStartPointId + userData.maxPointCount
    end
    local rankAward = nil
    local btn_level = image_basemap:getChildByName("btn_level")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if _prevUIBtn == sender then
				return
			end
			_prevUIBtn = sender
            btn_level:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_level:setTitleColor(cc.c3b(255, 255, 255))
            btn_rank:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_rank:setTitleColor(cc.c3b(255, 255, 255))
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            sender:setTitleColor(cc.c3b(51, 25, 4))
            if sender == btn_level then
                ui_textHint:setString(Lang.ui_pilltower_preview4)
                layoutScrollView({}, setScrollViewItem)
                for key, item in pairs(ui_listView) do
                    item:setVisible(true)
                end
                ui_scrollView:setVisible(false)
            elseif sender == btn_rank then
                ui_textHint:setString(Lang.ui_pilltower_preview5)
                for key, item in pairs(ui_listView) do
                    item:setVisible(false)
                end
                if not rankAward then
                    rankAward = {}
                    for key, obj in pairs(DictDantaDayAward) do
                        rankAward[#rankAward+1] = obj
                    end
                    utils.quickSort(rankAward, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
                end
                layoutScrollView(rankAward, setScrollViewItem)
                ui_scrollView:setVisible(true)
            end
        end
    end
    btn_level:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    btn_level:releaseUpEvent()
end

function UIPilltowerPreview.free()
    userData = nil
    cleanScrollView(true)
    _maxPointId = nil
end

function UIPilltowerPreview.show(_tableParams)
    UIPilltower.netSendPackage({int={p2=8}}, function(_msgData)
        if _msgData then
            _maxPointId = _msgData.msgdata.int.r1 --当日最高层数
        end
        if _maxPointId == nil then
            _maxPointId = 0
        end
        userData = _tableParams
        UIManager.pushScene("ui_pilltower_preview")
    end)
end
