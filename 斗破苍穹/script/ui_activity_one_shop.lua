require"Lang"
UIActivityOneShop = {}

local ui_scrollView = nil
local ui_svItem = nil

local setScrollViewItem = nil

local _currentJF = 0
local _exchangedData = nil

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
    local SCROLLVIEW_ITEM_SPACE = 20
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

local function refreshCurrentJF()
    local image_basemap = UIActivityOneShop.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_title"):setString(Lang.ui_activity_one_shop1 .. _currentJF)
end

setScrollViewItem = function(_item, _data, _index)
    local _itemData = utils.stringSplit(_data, ",")
    local _id = tonumber(_itemData[1])
    local _exchangeJF = tonumber(_itemData[2])
    local _maxExchangeCount = tonumber(_itemData[3])
    local _thing = _itemData[4]

    local ui_JFText = _item:getChildByName("image_base_title"):getChildByName("text_lv_number")
    local ui_frame = _item:getChildByName("image_frame_chip")
    local ui_icon = ui_frame:getChildByName("image_chip")
    local ui_count = ui_frame:getChildByName("text_number")
    local ui_flag = ui_frame:getChildByName("image_sui")
    local ui_name = _item:getChildByName("text_name")
    local ui_haveCount = _item:getChildByName("text_number")
    local btn_change = _item:getChildByName("btn_change")
    local ui_exchangeCount = _item:getChildByName("text_change_number")

    ui_JFText:setString(tostring(_exchangeJF))
    ui_haveCount:setVisible(false)
    local itemProp = utils.getItemProp(_thing)
    if itemProp then
        if itemProp.frameIcon then
            ui_frame:loadTexture(itemProp.frameIcon)
        end
        if itemProp.smallIcon then
            ui_icon:loadTexture(itemProp.smallIcon)
            utils.showThingsInfo(ui_icon, itemProp.tableTypeId, itemProp.tableFieldId)
        end
        if itemProp.name then
            ui_name:setString(itemProp.name)
            if itemProp.qualityColor then
                ui_name:setTextColor(itemProp.qualityColor)
            end
        end
        if itemProp.flagIcon then
            ui_flag:loadTexture(itemProp.flagIcon)
            ui_flag:setVisible(true)
            if itemProp.tableTypeId == StaticTableType.DictCardSoul then
                local _soulCount = 0
                if net.InstPlayerCardSoul then
                    for key, obj in pairs(net.InstPlayerCardSoul) do
                        if obj.int["4"] == itemProp.tableFieldId then
                            _soulCount = obj.int["5"]
                            break
                        end
                    end
                end
                local _cardId = DictCardSoul[tostring(itemProp.tableFieldId)].cardId
                local soulNum = DictQuality[tostring(DictCard[tostring(_cardId)].qualityId)].soulNum
                ui_haveCount:setString(Lang.ui_activity_one_shop2 .. _soulCount .. "/" .. soulNum)
                ui_haveCount:setVisible(true)
            elseif itemProp.tableTypeId == StaticTableType.DictThing then
                local dictData = DictThing[tostring(itemProp.tableFieldId)]
                if dictData and dictData.id >= 200 and dictData.id < 300 then
                    local tempData = DictEquipment[tostring(dictData.equipmentId)]
                    if tempData then
                        local itemCountDesc = Lang.ui_activity_one_shop3 .. utils.getThingCount(dictData.id) .. "/" .. DictEquipQuality[tostring(tempData.equipQualityId)].thingNum
                        ui_haveCount:setString(itemCountDesc)
                        ui_haveCount:setVisible(true)
                    end
                end
            end
        else
           ui_flag:setVisible(false)
        end
        if itemProp.count then
            ui_count:setString("×" .. itemProp.count)
        end
    end
    local _exchangedCount = 0
    if _exchangedData then
        for key, obj in pairs(utils.stringSplit(_exchangedData, ";")) do
            local _tempData = utils.stringSplit(obj, ",")
            local id = tonumber(_tempData[1])
            if _id == id then
                _exchangedCount = tonumber(_tempData[2])
                break
            end
        end
    end
    ui_exchangeCount:setString(string.format(Lang.ui_activity_one_shop4, _exchangedCount, _maxExchangeCount))
    if _currentJF < _exchangeJF or _exchangedCount == _maxExchangeCount then
        btn_change:setBright(false)
    else
        btn_change:setBright(true)
    end
    btn_change:setPressedActionEnabled(true)
    btn_change:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _exchangedCount == _maxExchangeCount then
                return UIManager.showToast(Lang.ui_activity_one_shop5)
            elseif _currentJF < _exchangeJF then
                return UIManager.showToast(Lang.ui_activity_one_shop6)
            end
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.jiFenChangeReward, msgdata = { int = { id = _id, num = 1 } }
            } , function(_msgData)
                utils.showGetThings(_thing)
                if _exchangedData and _exchangedData ~= "" then
                    local _tempExchangeData = _exchangedData
                    _exchangedData = string.gsub(_exchangedData, _id..",".._exchangedCount, _id..",".._exchangedCount+1)
                    if _exchangedData == _tempExchangeData then
                        _exchangedData = _exchangedData .. ";" .. _id .. "," .. _exchangedCount+1
                    end
                else
                    _exchangedData = _id .. "," .. (_exchangedCount + 1)
                end
                setScrollViewItem(_item, _data, _index)
                _currentJF = _msgData.msgdata.int.curJiFen
                refreshCurrentJF()
            end )
        end
    end)
end

function UIActivityOneShop.init()
    local image_basemap = UIActivityOneShop.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)

    ui_scrollView = image_basemap:getChildByName("view_award_lv")
    ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
end

function UIActivityOneShop.setup()
    refreshCurrentJF()
end

function UIActivityOneShop.free()
    cleanScrollView(true)
    _currentJF = 0
    _exchangedData = nil
end

function UIActivityOneShop.show()
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.openJiFenChange, msgdata = {}
    } , function(_msgData)
        _currentJF = _msgData.msgdata.int.curJiFen
        UIManager.pushScene("ui_activity_one_shop")
        _exchangedData = _msgData.msgdata.string.exchange
        local _reward = utils.stringSplit(_msgData.msgdata.string.reward, ";")
        layoutScrollView(_reward, setScrollViewItem)
    end )
end
