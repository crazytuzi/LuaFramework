local MAX_ZORDER = 1111
require("game.Biwu.BiwuFuc")
local data_item_item = require("data.data_item_item")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")

local XianShiMainView = class("XianShiMainView", function()
	return display.newNode()
end)

function XianShiMainView:ctor(param)
	self:setNodeEventEnabled(true)
	self._curInfoIndex = -1
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/xianshishangdian_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	local titleSize = self._rootnode.titlebng:getContentSize()
	self._rootnode.listbng:setContentSize(cc.size(display.width * 0.98, param.viewSize.height - titleSize.height - 0))
	self._rootnode.listview:setContentSize(cc.size(display.width * 0.95, param.viewSize.height - titleSize.height - 30))
	self.timeLabel1 = self._rootnode.timetitle1
	self:getData(function()
		self:setUpView()
	end)
end

function XianShiMainView:setUpView()
	self._data = self._itemList
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	local boardWidth = self._rootnode.listview:getContentSize().width
	local boardHeight = self._rootnode.listview:getContentSize().height
	local showBuyBox
	function showBuyBox(index, cell)
		if display.getRunningScene():getChildByTag(111111) then
			return
		end
		local itemData = {
		name = data_item_item[self._data[index + 1].itemid].name,
		iconType = ResMgr.getResType(data_item_item[self._data[index + 1].itemid].type),
		id = self._data[index + 1].itemid,
		had = self._data[index + 1].hasNum,
		limitNum = self._data[index + 1].canBuyNum,
		needReputation = self._data[index + 1].price
		}
		if self._data[index + 1].num1 == 0 then
			show_tip_label(common:getLanguageString("@goumaics"))
			return
		end
		
		local popup = require("game.Arena.ExchangeCountBox").new({
		--local popup = require("game.nbactivity.XianShiShop.ExchangeCountBox").new({
		shopType = XIANSHI_SHOP_TYPE,
		reputation = game.player:getGold(),
		itemData = itemData,
		listener = function(num)
			self:confirmFunc(index, num, showBuyBox, cell)
		end,
		closeFunc = function()
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		popup:setPositionY(0)
		display.getRunningScene():addChild(popup, 1000000, 111111)
	end
	local function createFunc(index)
		local item = require("game.nbactivity.XianShiShop.XianShiItemView").new()
		return item:create({
		index = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = self._data[index + 1],
		confirmFunc = showBuyBox
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self._data[index + 1],
		confirmFunc = showBuyBox
		})
	end
	local cellContentSize = require("game.nbactivity.XianShiShop.XianShiItemView").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = cellContentSize,
	direction = kCCScrollViewDirectionVertical
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listview:addChild(self.ListTable)
	self._rootnode.listview:setPositionY(self._rootnode.listview:getPositionY() + 5)
	local startTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._start) / 1000))
	local endTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._end) / 1000))
	local startTimeStr = string.split(startTimeStr, "-")
	local startTime
	startTime = startTimeStr[1] .. common:getLanguageString("@Year")
	startTime = startTime .. startTimeStr[2] .. common:getLanguageString("@Month")
	startTime = startTime .. startTimeStr[3] .. common:getLanguageString("@Day")
	local endTimeStr = string.split(endTimeStr, "-")
	local endTime
	endTime = endTimeStr[1] .. common:getLanguageString("@Year")
	endTime = endTime .. endTimeStr[2] .. common:getLanguageString("@Month")
	endTime = endTime .. endTimeStr[3] .. common:getLanguageString("@Day")
	self._rootnode.timelabel:setString(startTime .. common:getLanguageString("@DateTo") .. endTime)
	alignNodesOneByOne(self._rootnode.timetitle, self._rootnode.timelabel)
	local timeAll = math.floor(self._countDownTime / 1000)
	self._rootnode.timelabel1:setString(self:timeFormat(timeAll))
	alignNodesOneByOne(self._rootnode.timetitle1, self._rootnode.timelabel1)
	local function countDown()
		timeAll = timeAll - 1
		if timeAll <= 0 then
			self._scheduler.unscheduleGlobal(self._schedule)
			self._rootnode.timelabel1:setString(common:getLanguageString("@ActivityOver"))
			show_tip_label(common:getLanguageString("@ActivityOver"))
		else
			self._rootnode.timelabel1:setString(self:timeFormat(timeAll))
		end
	end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(countDown, 1, false)
end

function XianShiMainView:timeFormat(timeAll)
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
	local nowTimeStr = hour .. common:getLanguageString("@Hour") .. min .. common:getLanguageString("@Minute") .. sec .. common:getLanguageString("@Sec")
	return nowTimeStr
end

function XianShiMainView:getData(func)
	local function init(data)
		self._itemList = data.toolsList
		self._vipLevel = data.vipLevel
		self._start = data.sDate
		self._end = data.eDate
		self._countDownTime = data.countDown
		for k, v in pairs(self._itemList) do
			v.itemid = data_xianshishangdian_xianshishangdian[v.id].itemid
			v.type = data_xianshishangdian_xianshishangdian[v.id].type
			v.itemnum = data_xianshishangdian_xianshishangdian[v.id].num
			v.vip = data_xianshishangdian_xianshishangdian[v.id].vip
			v.price = data_xianshishangdian_xianshishangdian[v.id].price
			v.sale = data_xianshishangdian_xianshishangdian[v.id].sale
			v.discount = data_xianshishangdian_xianshishangdian[v.id].discount
		end
		dump(self._itemList)
		func()
	end
	
	RequestHelper.xianshiShopSystem.getBaseInfo({
	callback = function(data)
		init(data)
	end
	})
end

function XianShiMainView:clear()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
		self._schedule = nil
	end
	require("game.Spirit.SpiritCtrl").clear()
end

function XianShiMainView:showResetPopup()
	local function okFunc()
		self:getData(function()
			self:setUpView()
		end)
	end
	local msgBox = require("utility.MsgBox").new({
	size = cc.size(500, 300),
	content = "\n       宝库已在零点刷新，请重新挖宝！",
	showClose = true,
	directclose = true,
	midBtnFunc = okFunc
	})
	CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 10000)
end

function XianShiMainView:confirmFunc(index, num, showBuyBox, cell)
	
	local function init(data)
		if data.isOtherDay == 0 then
			self:showResetPopup()
			return
		end
		if data.checkBagList and 0 < #data.checkBagList then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBagList
			})
			self:addChild(layer, 10)
		else
			self._data[index + 1].canBuyNum = self._data[index + 1].canBuyNum - num
			self._data[index + 1].leftNum = self._data[index + 1].leftNum - num
			self._data[index + 1].hasNum = self._data[index + 1].hasNum + num
			if 0 < 1 then
				local param = {
				index = index,
				itemData = self._data[index + 1],
				confirmFunc = showBuyBox
				}
				self.ListTable:reloadCell(index, param)
			else
			end
			local cellDatas = {}
			local itemData = {
			id = self._data[index + 1].itemid,
			iconType = ResMgr.getResType(self._data[index + 1].type),
			type = self._data[index + 1].type,
			num = 1,
			name = data_item_item[self._data[index + 1].itemid].name,
			describe = data_item_item[self._data[index + 1].itemid].describe or ""
			}
			table.insert(cellDatas, itemData)
			display.getRunningScene():addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({cellDatas = cellDatas, num = num}), 1000)
		end
	end
	
	RequestHelper.xianshiShopSystem.getReword({
	callback = function(data)
		init(data)
	end,
	id = self._data[index + 1].id,
	count = num
	})
end

function XianShiMainView:getReword(id, num)
	
end

function XianShiMainView:onEnter()
	
end

function XianShiMainView:onExit()
	self:clear()
end

return XianShiMainView