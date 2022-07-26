require"Lang"
UIAllianceShop = { }

--1-贡献 2-联盟令 3-奖励
local TAG_GX  = 1
local TAG_LML = 2
local TAG_JL  = 3

local userData = nil

local ui_scrollView = nil
local ui_svItem = nil

local dictUnionStore = nil
local instUnionStoreData = nil
local _prevUIBtn = nil
local _curBuyData = nil

local netCallbackFunc = nil

local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
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

local function setScrollViewItem(_item, _data, _index)
    local ui_itemFrame = _item:getChildByName("image_frame_chip")
    local ui_itemIcon = ui_itemFrame:getChildByName("image_chip")
    local ui_itemValue = ui_itemFrame:getChildByName("text_number")
    local ui_itemFlag = ui_itemFrame:getChildByName("image_sui")
    local ui_itemName = _item:getChildByName("text_chip_name")
    local ui_itemHint = _item:getChildByName("text_hint")
    local ui_itemPractice = _item:getChildByName("text_practicing")
    local ui_itemCount = _item:getChildByName("text_number")
    local ui_offerNums = _item:getChildByName("image_fire"):getChildByName("text_number")
    local ui_goldNums = _item:getChildByName("image_gold"):getChildByName("text_number")
    local ui_itemBtn = _item:getChildByName("btn_lineup")

    local itemProps = utils.getItemProp(_data.thing)
    if itemProps.frameIcon then
	    ui_itemFrame:loadTexture(itemProps.frameIcon)
    end
    if itemProps.name then
	    ui_itemName:setString(itemProps.name)
    end
    if itemProps.smallIcon then
	    ui_itemIcon:loadTexture(itemProps.smallIcon)
        utils.showThingsInfo(ui_itemIcon, itemProps.tableTypeId, itemProps.tableFieldId)
    end
    if itemProps.flagIcon then
        ui_itemFlag:loadTexture(itemProps.flagIcon)
        ui_itemFlag:setVisible(true)
    else
        ui_itemFlag:setVisible(false)
    end
    if itemProps.count then
        ui_itemValue:setString("×" .. itemProps.count)
    end
    ui_itemCount:setString("")
    if itemProps.flagIcon and _data.tableTypeId == StaticTableType.DictThing then
        local dictData = DictThing[tostring(_data.tableFieldId)]
        if dictData and dictData.id >= 200 and dictData.id < 300 then
            local tempData = DictEquipment[tostring(dictData.equipmentId)]
            if tempData then
                local itemCountDesc = "(" .. utils.getThingCount(dictData.id) .. "/" .. DictEquipQuality[tostring(tempData.equipQualityId)].thingNum .. ")"
                ui_itemCount:setString(itemCountDesc)
            end
        end
    end

    --default
    ui_offerNums:getParent():setVisible(false)
    ui_goldNums:getParent():setVisible(false)
    ui_itemBtn:setTitleText(Lang.ui_alliance_shop1)

    if _prevUIBtn and _prevUIBtn:getTag() == TAG_JL then
        ui_itemBtn:setTitleText(Lang.ui_alliance_shop2)
    end
    --@consumeType 消耗类型 0-无 1-联盟贡献  2-联盟令
    if _data.consumeType == 0 then
    elseif _data.consumeType == 1 then
        ui_offerNums:getParent():setVisible(true)
        ui_offerNums:getParent():loadTexture("ui/alliance.png")
        ui_offerNums:setString("×".._data.consumeValue)
    elseif _data.consumeType == 2 then
        ui_offerNums:getParent():setVisible(true)
        ui_offerNums:getParent():loadTexture("ui/lm_token.png")
        ui_offerNums:setString("×".._data.consumeValue)
    end

    local _buyCount = 0
    if instUnionStoreData then
        local instUnionStore = utils.stringSplit(instUnionStoreData, ";")
        for key, obj in pairs(instUnionStore) do
            local _tempData = utils.stringSplit(obj, "_")
            local _id = tonumber(_tempData[1])
            local _num = tonumber(_tempData[2])
            if _data.id == _id then
                _buyCount = _num
                break
            end
        end
    end
    if _data.exchangeTimes - _buyCount <= 0 then
        if _prevUIBtn and _prevUIBtn:getTag() == TAG_JL then
            ui_itemBtn:setTitleText(Lang.ui_alliance_shop3)
        else
            ui_itemBtn:setTitleText(Lang.ui_alliance_shop4)
        end
        ui_itemBtn:setBright(false)
    end
    if _prevUIBtn and _prevUIBtn:getTag() == TAG_JL then
        ui_itemHint:setString(string.format(Lang.ui_alliance_shop5, _data.exchangeTimes - _buyCount))
    else
        --@exchangeType 兑换类型 1-当天可兑换  2-永久兑换
        if _data.exchangeType == 1 then
            ui_itemHint:setString(string.format(Lang.ui_alliance_shop6, _data.exchangeTimes - _buyCount))
        elseif _data.exchangeType == 2 then
            ui_itemHint:setString(string.format(Lang.ui_alliance_shop7, _data.exchangeTimes - _buyCount))
        end
    end
    ui_itemPractice:setVisible(false)
    if userData.unionDetail.practiceValue < _data.practiceValueView then
        ui_itemPractice:setVisible(true)
        ui_itemPractice:setString(Lang.ui_alliance_shop8 .. _data.practiceValueView)
        ui_itemBtn:setBright(false)
    end

    ui_itemBtn:setPressedActionEnabled(true)
    ui_itemBtn:addTouchEventListener(function(_sender, _eventType)
		if _eventType == ccui.TouchEventType.ended then
            if userData.unionDetail.practiceValue < _data.practiceValueView then
                return UIManager.showToast(Lang.ui_alliance_shop9)
            elseif _data.exchangeTimes - _buyCount <= 0 then
                if _prevUIBtn and _prevUIBtn:getTag() == TAG_JL then
                    UIManager.showToast(Lang.ui_alliance_shop10)
                else
                    UIManager.showToast(Lang.ui_alliance_shop11)
                end
                return
            end
            if _data.consumeType == 0 then
            elseif _data.consumeType == 1 then
                if net.InstUnionMember.int["5"] < _data.consumeValue then
                    return UIManager.showToast(Lang.ui_alliance_shop12)
                end
            elseif _data.consumeType == 2 then
                if utils.getThingCount(StaticThing.unionWand) < _data.consumeValue then
                    return UIManager.showToast(Lang.ui_alliance_shop13)
                end
            end

            local buyThings = function()
                UIManager.showLoading()
                _curBuyData = _data
                netSendPackage( {
                    header = StaticMsgRule.unionStoreBuy,
                    msgdata = { int = { id = _data.id } }
                } , netCallbackFunc)
            end
            if _prevUIBtn and _prevUIBtn:getTag() == TAG_JL then
                buyThings()
            else
                UIAllianceHintShop.show( { consumeName = (_data.consumeType == 2 and Lang.ui_alliance_shop14 or Lang.ui_alliance_shop15), consumeValue = _data.consumeValue, itemDetail = itemProps, callbackFunc = buyThings })
            end

        end
    end )
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
	if code == StaticMsgRule.intoUnionStore then
        dictUnionStore = {}
        local dictUnionStoreData = utils.stringSplit(_msgData.msgdata.string["1"], "/")
        instUnionStoreData = _msgData.msgdata.string["2"]
        for key, obj in pairs(dictUnionStoreData) do
            local tempObj = utils.stringSplit(obj, "|")
            local _index = tonumber(tempObj[2])
            if dictUnionStore[_index] == nil then
                dictUnionStore[_index] = {}
            end
            dictUnionStore[_index][#dictUnionStore[_index] + 1] = 
            {
                id = tonumber(tempObj[1]),
                storeType = _index,
                thing = tempObj[3],
                practiceValueView = tonumber(tempObj[4]),
                exchangeType = tonumber(tempObj[5]),
                exchangeTimes = tonumber(tempObj[6]),
                consumeType = tonumber(tempObj[7]),
                consumeValue = tonumber(tempObj[8])
            }
        end
        if _curBuyData then
            for key, obj in pairs(dictUnionStore[_curBuyData.storeType]) do
                if obj.id == _curBuyData.id then
                    setScrollViewItem(ui_scrollView:getChildren()[key], obj, key)
                    break
                end
            end
            _curBuyData = nil
        else
            if _prevUIBtn then
                local tempTagButton = _prevUIBtn
                _prevUIBtn = nil
                tempTagButton:releaseUpEvent()
            end
        end
    elseif code == StaticMsgRule.unionStoreBuy then
        if _curBuyData then
            utils.showGetThings(_curBuyData.thing)
            UIAllianceShop.setup()
        end
    end
end

function UIAllianceShop.init()
    local image_basemap = UIAllianceShop.Widget:getChildByName("image_basemap")
	local btn_back = image_basemap:getChildByName("btn_back")
	btn_back:setPressedActionEnabled(true)
	btn_back:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIAlliance.show()
		end
	end)
    local btn_purple = image_basemap:getChildByName("btn_purple")
    local btn_orange = image_basemap:getChildByName("btn_orange")
    local btn_reward = image_basemap:getChildByName("btn_reward")
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevUIBtn == sender then
				return
			end
			_prevUIBtn = sender
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            if sender == btn_purple then
                sender:getChildByName("text_purple"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_orange:getChildByName("text_orange"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_orange:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_reward:getChildByName("text_reward"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_reward:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            elseif sender == btn_orange then
                sender:getChildByName("text_orange"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_purple:getChildByName("text_purple"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_purple:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_reward:getChildByName("text_reward"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_reward:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            elseif sender == btn_reward then
                sender:getChildByName("text_reward"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_purple:getChildByName("text_purple"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_purple:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_orange:getChildByName("text_orange"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_orange:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            end
            layoutScrollView(dictUnionStore and dictUnionStore[sender:getTag()] or nil, setScrollViewItem)
        end
    end
    btn_purple:addTouchEventListener(onBtnEvent)
    btn_orange:addTouchEventListener(onBtnEvent)
    btn_reward:addTouchEventListener(onBtnEvent)

    btn_purple:setTag(TAG_GX)
    btn_orange:setTag(TAG_LML)
    btn_reward:setTag(TAG_JL)

	ui_scrollView = image_basemap:getChildByName("view_award_lv")
	ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
end

function UIAllianceShop.setup()
    dictUnionStore = nil
    local image_basemap = UIAllianceShop.Widget:getChildByName("image_basemap")
    if not _curBuyData then
	    local btn_purple = image_basemap:getChildByName("btn_purple")
        if _prevUIBtn then
            _prevUIBtn:releaseUpEvent()
        elseif UIAllianceShop.showLMLFirst then
            local btn_orange = UIAllianceShop.Widget:getChildByName("image_basemap"):getChildByName("btn_orange")
            btn_orange:releaseUpEvent()
            UIAllianceShop.showLMLFirst = nil
        else
	        btn_purple:releaseUpEvent()
        end
    end
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local textDevote = ccui.Helper:seekNodeByName(image_di_dowm, "image_contribute"):getChildByName("text_number")
    local textUnionWand = ccui.Helper:seekNodeByName(image_di_dowm, "image_token"):getChildByName("text_number")
    textDevote:setString(tostring(net.InstUnionMember.int["5"]))
    textUnionWand:setString(tostring(utils.getThingCount(StaticThing.unionWand)))

    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.intoUnionStore,
        msgdata = { }
    } , netCallbackFunc)
end

function UIAllianceShop.free()
    cleanScrollView()
    userData = nil
    dictUnionStore = nil
    instUnionStoreData = nil
    _prevUIBtn = nil
    _curBuyData = nil
end

function UIAllianceShop.show(_tableParams)
    userData = _tableParams
    UIManager.showWidget("ui_alliance_shop")
end

function UIAllianceShop.showScreen(_tableParams)
    userData = _tableParams
    UIManager.showScreen("ui_alliance_shop")
end
