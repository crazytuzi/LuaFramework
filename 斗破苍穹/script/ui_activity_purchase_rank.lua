require"Lang"
UIActivityPurchaseRank = {}

local userData = nil
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
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    local SCROLLVIEW_ITEM_SPACE = 15
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
    local ui_playerIcon = ccui.Helper:seekNodeByName(_item, "image_player")
    local ui_playerName = ccui.Helper:seekNodeByName(_item, "text_name")
    local ui_rank = ccui.Helper:seekNodeByName(_item, "text_ranking")
    local ui_buyCount = ccui.Helper:seekNodeByName(_item, "text_alliance")
    local ui_backImage = ccui.Helper:seekNodeByName(_item, "image_di_back")
    local ui_backText = ui_backImage:getChildByName("text_back")
    local dictCard = DictCard[tostring(_data.iconId)]
    if dictCard then
        ui_playerIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    end
    ui_playerName:setString(_data.playerName)
    ui_rank:setString(_data.rank)
    ui_buyCount:setString(Lang.ui_activity_purchase_rank1 .. _data.buyCount)
    if _data.backCount > 0 then
        ui_backText:setString(string.format(Lang.ui_activity_purchase_rank2, _data.backCount * 100) .. "%")
        ui_backImage:setVisible(true)
    else
        ui_backImage:setVisible(false)
    end
end

function UIActivityPurchaseRank.init()
    local image_basemap = UIActivityPurchaseRank.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    btn_close:setPressedActionEnabled(true)
    btn_closed:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_closed:addTouchEventListener(onBtnEvent)

    ui_scrollView = image_basemap:getChildByName("view_rank")
    ui_svItem = ui_scrollView:getChildByName("image_di_ranking"):clone()
end

function UIActivityPurchaseRank.setup()
    local image_basemap = UIActivityPurchaseRank.Widget:getChildByName("image_basemap")
    local image_di = image_basemap:getChildByName("image_di")
    image_di:getChildByName("text_number"):setString(Lang.ui_activity_purchase_rank3 .. userData.buyCount)
    image_di:getChildByName("text_rank"):setString(Lang.ui_activity_purchase_rank4 .. userData.currentRank)
    layoutScrollView(userData.rankData, setScrollViewItem)
end

function UIActivityPurchaseRank.show(_tableParams)
    UIManager.showLoading()
    netSendPackage({ header = StaticMsgRule.lookGroupRank, msgdata = { }}, function(_msgData)
        userData = _tableParams
        if userData == nil then
            userData = {}
        end
        --购买个数|当前排名
        local _tempData = utils.stringSplit(_msgData.msgdata.string["1"], "|")
        userData.buyCount = tonumber(_tempData[1])
        userData.currentRank = tonumber(_tempData[2])
        --玩家信息[序号 头像ID 玩家名称 购买个数 返利数(>0时-显示，=0-不显示)]
        local _tempData = utils.stringSplit(_msgData.msgdata.string["2"], "/")
        userData.rankData = {}
        for key, obj in pairs(_tempData) do
            local _tempObj = utils.stringSplit(obj, " ")
            userData.rankData[key] = {
                rank = tonumber(_tempObj[1]),
                iconId = tonumber(_tempObj[2]),
                playerName = _tempObj[3],
                buyCount = tonumber(_tempObj[4]),
                backCount = tonumber(_tempObj[5])
            }
        end
        UIManager.pushScene("ui_activity_purchase_rank")
    end)
end

function UIActivityPurchaseRank.free()
    userData = nil
    cleanScrollView(true)
end
