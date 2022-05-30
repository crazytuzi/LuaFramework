local VipLibaoRewardLayer = class("VipLibaoRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function VipLibaoRewardLayer:ctor(param)
	local vipLv = param.vipLv
	local title = param.title
	local itemData = param.itemData
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_reward_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.vip_level_lbl:setString(tostring(vipLv))
	self._rootnode.title_lbl:setString(tostring(title))
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	self:createListView(itemData)
end

function VipLibaoRewardLayer:createListView(itemData)
	local viewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item = require("game.shop.vipLibao.VipLibaoRewardItem").new()
		return item:create({
		viewSize = viewSize,
		itemData = itemData[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(itemData[index + 1])
	end
	local cellContentSize = require("game.shop.vipLibao.VipLibaoRewardItem").new():getContentSize()
	local listViewTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #itemData,
	cellSize = cellContentSize
	})
	listViewTable:setPosition(0, 0)
	self._rootnode.listView:addChild(listViewTable)
end

return VipLibaoRewardLayer