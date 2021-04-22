--
--                             _ooOoo_
--                            o8888888o
--                            88" . "88
--                            (| -_- |)
--                            O\  =  /O
--                         ____/`---'\____
--                       .'  \\|     |//  `.
--                      /  \\|||  :  |||//  \
--                     /  _||||| -:- |||||-  \
--                     |   | \\\  -  /// |   |
--                     | \_|  ''\---/''  |   |
--                     \  .-\__  `-`  ___/-. /
--                   ___`. .'  /--.--\  `. . __
--                ."" '<  `.___\_<|>_/___.'  >'"".
--               | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--               \  \ `-.   \_ __\ /__ _/   .-` /  /
--          ======`-.____`-.___\_____/___.-`____.-'======
--                             `=---='
--
------------------------ 佛祖保佑，不出bug ------------------------- 

--
-- Kumo.Wang
-- 酒馆高级招将兑换界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTavernExchange = class("QUIDialogTavernExchange", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetTavernExchange = import("..widgets.QUIWidgetTavernExchange")

QUIDialogTavernExchange.ARENA_BUY_SUCCESS = "ARENA_BUY_SUCCESS"

function QUIDialogTavernExchange:ctor(options)
	local ccbFile = "ccb/Dialog_Exchange_Tavern.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogTavernExchange.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	self._ccbOwner.frame_tf_title:setString("兑 换")

	q.setButtonEnableShadow(self._ccbOwner.btn_close)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._isHalf = options.isHalf
		self._callback = options.callback
	end

	if self._isHalf == nil then
		local halfTime = (remote.user.luckyAdvanceHalfPriceRefreshAt or 0)/1000
	    local lastRefreshTime = q.date("*t", q.serverTime())
	   	if lastRefreshTime.hour < 5 then
	   		halfTime = halfTime + DAY
	   	end
		lastRefreshTime.hour = 5
	    lastRefreshTime.min = 0
	    lastRefreshTime.sec = 0
	    lastRefreshTime = q.OSTime(lastRefreshTime)

	    if halfTime <= lastRefreshTime then
			self._isHalf = true
	    end
	end

	self._data = {}
	
	self:_initListView()
end

function QUIDialogTavernExchange:_init()
	print("[QUIDialogTavernExchange:_init()]", self._isHalf)
	local price1 = db:getConfigurationValue("ADVANCE_LUCKY_DRAW_TOKEN_COST")
	local price10 = db:getConfigurationValue("ADVANCE_LUCKY_DRAW_10_TIMES_TOKEN_COST")
	self._data = {
		{buyType = 1, itemId = 24, price = price1, discount = self._isHalf and 5 or 10}, 
		{buyType = 10, itemId = 24, price = price10, discount = 9}, 
	}

	if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
	self:_initListView()
end

function QUIDialogTavernExchange:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local item = list:getItemFromCache()
                local data = self._data[index]
                if not item then
                    item = QUIWidgetTavernExchange.new()
                    isCacheNode = false
                end
                item:setInfo(data)
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_ok", handler(self, self._onClickBtnOK), nil, true)
                
                return isCacheNode
            end,
            spaceY = 0,
            enableShadow = true,
            ignoreCanDrag = true,
            totalNumber = #self._data,
        }  
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogTavernExchange:_onClickBtnOK( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    local info = item:getInfo()
    local itemType = remote.items:getItemType(info.itemId)
    if itemType == nil then
        itemType = ITEM_TYPE.ITEM
    end

	local buyMoreOptions = {
		maxNum = 99999999999,
		callback = handler(self, self._onBuyHandler),
		itemInfo = {
			itemId = info.itemId,
			itemType = itemType,
			itemCount = info.buyType,
			resource_1 = ITEM_TYPE.TOKEN_MONEY,
			resource_number_1 = tonumber(info.price),
			isHalf = info.buyType == 1 and self._isHalf or false, 
		}
	}

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernBuyMore", 
  		options = buyMoreOptions})
end

function QUIDialogTavernExchange:_onBuyHandler(isHalf)
	print("[QUIDialogTavernExchange:_onBuyHandler()]", isHalf, isHalf ~= nil)
	if isHalf ~= nil then
		self:getOptions().isHalf = isHalf
		self._isHalf = isHalf
	end
	print("self._isHalf = ", self._isHalf)
end

function QUIDialogTavernExchange:viewDidAppear()
	QUIDialogTavernExchange.super.viewDidAppear(self)

	self:_init()
end

function QUIDialogTavernExchange:viewWillDisappear()
	QUIDialogTavernExchange.super.viewWillDisappear(self)
end

function QUIDialogTavernExchange:_backClickHandler()
	 self:_onTriggerClose()
end

function  QUIDialogTavernExchange:_onTriggerClose(e)
	if e ~= nil then
	 	app.sound:playSound("common_close")
 	end
	self:playEffectOut()

	if self._callback then
		self._callback()
	end
end

return QUIDialogTavernExchange 