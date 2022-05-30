require("data.data_error_error")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local data_touzi_touzi = require("data.data_touzi_touzi")
local data_config_config = require("data.data_config_config")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")

local CreditShop = class("CreditShop", function(param)
	return require("game.nbactivity.BaseListPage").new(param)
end)

function CreditShop:createCell(index)
	local item = require("game.nbactivity.Credit.CreditItemView").new()
	return item:create({
	index = index,
	viewSize = self.cellContentSize,
	itemData = self._cellData[index + 1],
	confirmFunc = self.showBuyBox
	})
end

function CreditShop:refreshCell(cell, index)
	cell:refresh({
	index = index,
	itemData = self._cellData[index + 1],
	confirmFunc = self.showBuyBox
	})
end

function CreditShop:getData(func)
	
	local function init(data)
		self._itemList = data.toolsList --道具列表
		self._point = data.point --积分
		self._start = data.sDate --开始时间
		self._end = data.eDate --结束时间
		self._countDownTime = data.countDown --倒计时		
		for k, v in pairs(self._itemList) do
			v.itemid = data_xianshishangdian_xianshishangdian[v.id].itemid
			v.type = data_xianshishangdian_xianshishangdian[v.id].type
			v.itemnum = data_xianshishangdian_xianshishangdian[v.id].num
			v.sale = data_xianshishangdian_xianshishangdian[v.id].sale
			v.vip = data_xianshishangdian_xianshishangdian[v.id].vip
			v.needPoint = data_xianshishangdian_xianshishangdian[v.id].price
		end
		func()
	end
	
	RequestHelper.creditShopSystem.getBaseInfo({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

function CreditShop:confirmFunc(index, num, showBuyBox, cell)
	local function init(data)
		if data.isOtherDay == 0 then
			return
		end
		if data.checkBagList and 0 < #data.checkBagList then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBagList
			})
			self:addChild(layer, 10)
		else
			self._cellData[index + 1].canBuyNum = self._cellData[index + 1].canBuyNum - num
			self._cellData[index + 1].leftNum = self._cellData[index + 1].leftNum - num
			self._cellData[index + 1].hasNum = self._cellData[index + 1].hasNum + num
			self._point = self._point - num * self._cellData[index + 1].needPoint
			self._rootnode.mNumber:setString(self._point)
			if 0 < 1 then
				local param = {
				index = index,
				itemData = self._cellData[index + 1],
				confirmFunc = showBuyBox
				}
				self._listTable:reloadCell(index, param)
			else
			end
			local cellDatas = {}
			local itemData = {
			id = self._cellData[index + 1].itemid,
			iconType = ResMgr.getResType(self._cellData[index + 1].type),
			type = self._cellData[index + 1].type,
			num = 1,
			name = data_item_item[self._cellData[index + 1].itemid].name,
			describe = data_item_item[self._cellData[index + 1].itemid].describe or ""
			}
			table.insert(cellDatas, itemData)
			display.getRunningScene():addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({cellDatas = cellDatas, num = num}), 1000)
		end
	end
	
	RequestHelper.creditShopSystem.getReword({
	callback = function(data)
		dump(data)
		init(data)
	end,
	id = self._cellData[index + 1].id,
	count = num
	})
end

function CreditShop:ctor(param)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/integ_ralmall.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	self._rootnode.listbng:setContentSize(cc.size(display.width * 0.98, param.viewSize.height - 300 - 0))
	self._rootnode.listview:setContentSize(cc.size(display.width * 0.95, param.viewSize.height - 300 - 30))
	local boardWidth = self._rootnode.listview:getContentSize().width
	local boardHeight = self._rootnode.listview:getContentSize().height
	self._listViewSize = CCSizeMake(boardWidth, boardHeight)
	self._listViewNode = self._rootnode.listview
	
	self._rootnode.desc_btn:addHandleOfControlEvent(function(sender, eventName)
		local layer = require("game.SplitStove.SplitDescLayer").new(11)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 100000)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self:getData(function()
		self:setUpView()
	end)
end

function CreditShop:getTimeStr(timeDate)
	local dateStr = os.date("%Y-%m-%d", math.ceil(tonumber(timeDate) / 1000))
	local time = string.split(dateStr, "-")
	local timeStr
	timeStr = time[1] .. common:getLanguageString("@Year")
	timeStr = timeStr .. time[2] .. common:getLanguageString("@Month")
	timeStr = timeStr .. time[3] .. common:getLanguageString("@Day")
	return timeStr
end

function CreditShop:setUpView()
	function self.showBuyBox(index, cell)
		if display.getRunningScene():getChildByTag(111111) then
			return
		end
		local itemData = {
		name = data_item_item[self._cellData[index + 1].itemid].name,
		iconType = ResMgr.getResType(data_item_item[self._cellData[index + 1].itemid].type),
		id = self._cellData[index + 1].itemid,
		had = self._cellData[index + 1].hasNum,
		limitNum = self._cellData[index + 1].canBuyNum,
		needReputation = self._cellData[index + 1].needPoint
		}
		if self._cellData[index + 1].num1 == 0 then
			show_tip_label(common:getLanguageString("@goumaics"))
			return
		end
		local popup = require("game.nbactivity.XianShiShop.ExchangeCountBox").new({
		reputation = self._point,
		itemData = itemData,
		shopType = CREDIT_SHOP_TYPE,
		listener = function(num)
			self:confirmFunc(index, num, self.showBuyBox, cell)
		end,
		closeFunc = function()
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		popup:setPositionY(0)
		display.getRunningScene():addChild(popup, 1000000, 111111)
	end
	
	local startTime = self:getTimeStr(self._start)
	local endTime = self:getTimeStr(self._end)
	self._rootnode.timeLabel:setString(startTime .. common:getLanguageString("@DateTo") .. endTime)
	self._rootnode.mNumber:setString(self._point)
	self._cellData = self._itemList
	self.cellContentSize = require("game.nbactivity.Credit.CreditItemView").new():getContentSize()
	self:initList()
end

return CreditShop