local data_card_card = require("data.data_card_card")
local data_item_item = require("data.data_item_item")
require("data.data_error_error")
local _schedulerTime = require("framework.scheduler")
local MAX_ZODER = 1001

local HeiShiLayer = class("HeiShiLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(100, 100, 100, 0))
end)

function HeiShiLayer:ctor(param)
	local viewSize = param.viewSize
	self.callback = param.callback
	self:setNodeEventEnabled(true)
	self:requestData()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local contentNode = CCBuilderReaderLoad("nbhuodong/heishi_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(contentNode)
	local girlSprite = display.newSprite("#smShop_girl.png")
	girlSprite:setPosition(-display.cx + girlSprite:getContentSize().width / 2, 0)
	self._rootnode.bg_node:addChild(girlSprite)
	local listHeigt = viewSize.height - self._rootnode.bottom_node:getContentSize().height - self._rootnode.title_node:getContentSize().height
	local listSize = CCSizeMake(viewSize.width * 0.71, listHeigt * 0.96)
	self._listViewSize = CCSizeMake(listSize.width * 0.98, listSize.height * 0.96)
	local listBg = display.newScale9Sprite("#sm_list_bg.png", 0, 0, listSize)
	listBg:setAnchorPoint(1, 0)
	listBg:setPosition(self._rootnode.listView_node:getContentSize().width, 0)
	self._rootnode.listView_node:addChild(listBg)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:setAnchorPoint(1, 0)
	self._listViewNode:setPosition(self._rootnode.listView_node:getContentSize().width - 5, listSize.height * 0.02)
	self._rootnode.listView_node:addChild(self._listViewNode)
	
	self._rootnode.refreshBtn:addHandleOfControlEvent(function(eventName, sender)
		if self.callback then
			self.callback(self.jifen)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.time_msg:setVisible(false)
	self._rootnode.time_msg:setString(common:getLanguageString("@tbrefresh", "00:00:00"))
end

function HeiShiLayer:timeFormat(timeAll)
	local basehour = 3600
	local basemin = 60
	local hour = math.floor(timeAll / basehour)
	local time = timeAll - hour * basehour
	local min = math.floor(time / basemin)
	local time = time - basemin * min
	local sec = math.floor(time)
	if hour < 10 then
		hour = "0" .. hour or hour
	end
	if min < 10 then
		min = "0" .. min or min
	end
	if sec < 10 then
		sec = "0" .. sec or sec
	end
	local nowTimeStr = hour .. ":" .. min .. ":" .. sec
	return nowTimeStr
end

function HeiShiLayer:reloadData()
	if not self.showHeiShiLayer then
		return
	end
	function countDown()
		if not self.showHeiShiLayer then
			return
		end
		self.lastFlushTime = self.lastFlushTime - 1000
		if self.lastFlushTime <= 0 then
			self:requestData()
			return
		end
		self._rootnode.time_msg:setString(common:getLanguageString("@tbrefresh", self:timeFormat(self.lastFlushTime / 1000)))
	end
	self._rootnode.jifen_num:setString(common:getLanguageString("@tbjf", self.jifen))
	local refreshFunc
	local function cb(jifen, idx, num, pnum)
		if not jifen then
			self:requestData()
			return
		end
		self.jifen = jifen
		self.blackShopList[idx].serverLast = num
		self.blackShopList[idx].selfBuy = pnum
		self._exchangeItemList:reloadData()
		self._rootnode.jifen_num:setString(common:getLanguageString("@tbjf", self.jifen))
	end
	local function createFunc(index)
		local item = require("game.nbactivity.TanBao.HeiShiItem").new()
		return item:create({
		idx = index + 1,
		viewSize = self._listViewSize,
		itemData = self.blackShopList[index + 1],
		jifen = self.jifen,
		callback = cb
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(index + 1, self.blackShopList[index + 1], self.jifen)
	end
	local datanum = get_table_len(self.blackShopList)
	self._exchangeItemList = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = datanum,
	cellSize = require("game.nbactivity.TanBao.HeiShiItem").new():getContentSize()
	})
	self._listViewNode:removeAllChildren()
	self._listViewNode:addChild(self._exchangeItemList, MAX_ZODER)
end

function HeiShiLayer:requestData()
	local function _callback(data)
		if not self.showHeiShiLayer then
			return
		end
		self.lastFlushTime = data.rtnObj.lastFlushTime
		self.jifen = data.rtnObj.jifen
		self.blackShopList = data.rtnObj.blackShopList
		self:reloadData()
	end
	local _error = function(err)
	end
	local msg = {
	m = "activity",
	a = "blackShopEnter"
	}
	RequestHelper.request(msg, _callback, _error)
end

function HeiShiLayer:onEnter()
	self.showHeiShiLayer = true
end

function HeiShiLayer:onExit()
	self.showHeiShiLayer = false
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	if self._scheduleTime then
		_schedulerTime.unscheduleGlobal(self._scheduleTime)
	end
end

return HeiShiLayer