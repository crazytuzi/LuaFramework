require("game.GameConst")
local data_item_item = require("data.data_item_item")

local DuobaoBuyMsgBox = class("DuobaoBuyMsgBox", function(data)
	return require("utility.ShadeLayer").new()
end)

function DuobaoBuyMsgBox:ctor(param)
	self.upateListener = param.updateListen
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	local rootnode = rootnode or {}
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/arena/arena_msgBox.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self.id = 4008
	self.nailiNum = data_item_item[self.id].para2
	self._rootnode.naili_num:setString(tostring(self.nailiNum))
	self.icon = self._rootnode.icon
	ResMgr.refreshIcon({
	itemBg = self.icon,
	id = self.id,
	resType = ResMgr.ITEM
	})
	setControlBtnEvent(self._rootnode.backBtn, function()
		self:removeSelf()
	end)
	setControlBtnEvent(self._rootnode.buy_btn, function()
		self:buyFunc()
	end)
	setControlBtnEvent(self._rootnode.use_btn, function()
		self:useFunc()
	end)
	self:sendReq()
end

function DuobaoBuyMsgBox:useFunc()
	if self.itemNum > 0 then
		do
			local function onUse(num)
				RequestHelper.useItem({
				callback = function(data)
					game.player.m_energy = game.player.m_energy + data["2"][1].n
					if self.upateListener ~= nil then
						self.upateListener()
					end
					self:removeSelf()
				end,
				id = self.id,
				num = num
				})
			end
			local expend = {}
			expend.id = self.id
			expend.num = self.itemNum
			local useCountBox = require("game.Bag.UseCountBox").new({
			name = data_item_item[self.id].name,
			havenum = self.itemNum,
			expend = expend,
			listener = function(num)
				onUse(num)
			end
			})
			self:addChild(useCountBox, 1000)
		end
	else
		show_tip_label(common:getLanguageString("@NotProp"))
	end
end

function DuobaoBuyMsgBox:buyFunc()
	if self.goldNum < self.costNum then
		show_tip_label(common:getLanguageString("@PriceEnough"))
	else
		RequestHelper.buy({
		callback = function(data)
			dump(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				game.player:updateMainMenu({
				silver = data["3"],
				gold = data["2"],
				naili = game.player.m_energy + self.nailiNum
				})
				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
				if self.upateListener ~= nil then
					self.upateListener()
				end
				self:removeSelf()
			end
		end,
		id = self.shopId,
		n = 1,
		coinType = self.coinType,
		coin = self.costNum,
		auto = 1
		})
	end
end

function DuobaoBuyMsgBox:init()
	self.itemNum = self.data["2"]
	local buyData = self.data["1"]
	self.goldNum = buyData.gold
	self.cnt = buyData.cnt
	self.costNum = buyData.coin
	self.shopId = buyData.id
	self.coinType = buyData.coinType
	self._rootnode.item_num:setString(self.itemNum)
	self._rootnode.gold_num:setString(self.costNum)
	if self.itemNum > 0 then
		self._rootnode.use_btn:setEnabled(true)
	else
		self._rootnode.use_btn:setEnabled(false)
	end
end

function DuobaoBuyMsgBox:sendReq()
	RequestHelper.getItemSaleData({
	callback = function(data)
		dump(data)
		if string.len(data["0"]) > 0 then
			CCMessageBox(data["0"], "Error")
		else
			self.data = data
			self:init()
		end
	end,
	id = self.id
	})
end

return DuobaoBuyMsgBox