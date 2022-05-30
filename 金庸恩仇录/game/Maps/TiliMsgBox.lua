require("game.GameConst")
local data_item_item = require("data.data_item_item")

local TiliMsgBox = class("TiliMsgBox", function(data)
	return require("utility.ShadeLayer").new()
end)

function TiliMsgBox:ctor(param)
	self.upateListener = param.updateListen
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/fuben/tili_msgBox.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	self.icon = self._rootnode.icon
	self.id = 4007
	self.tiliNum = data_item_item[self.id].para2
	self._rootnode.tili_num:setString(tostring(self.tiliNum))
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

function TiliMsgBox:useFunc()
	if self.itemNum > 0 then
		do
			local function onUse(num)
				RequestHelper.useItem({
				callback = function(data)
					game.player.m_strength = game.player.m_strength + data["2"][1].n
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
			game.runningScene:addChild(useCountBox, 1000)
		end
	else
		show_tip_label(common:getLanguageString("@NotProp"))
	end
end

function TiliMsgBox:buyFunc()
	if self.goldNum < self.costNum then
		show_tip_label(common:getLanguageString("@PriceEnough"))
	else
		RequestHelper.buy({
		callback = function(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				game.player:updateMainMenu({
				silver = data["3"],
				gold = data["2"],
				tili = game.player.m_strength + self.tiliNum
				})
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

function TiliMsgBox:init(data)
	self.data = data
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

function TiliMsgBox:sendReq()
	RequestHelper.getItemSaleData({
	callback = function(data)
		if string.len(data["0"]) > 0 then
			CCMessageBox(data["0"], "Error")
		else
			self:init(data)
		end
	end,
	id = self.id
	})
end

return TiliMsgBox