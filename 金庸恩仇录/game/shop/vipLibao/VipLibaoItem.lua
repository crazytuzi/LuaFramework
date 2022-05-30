local MAX_ZORDER = 150

local VipLibaoItem = class("VipLibaoItem", function()
	return CCTableViewCell:new()
end)

function VipLibaoItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function VipLibaoItem:setBuyBtnEnabled(bEnable)
	if bEnable == true then
		self._rootnode.has_buy_tag:setVisible(false)
		self._rootnode.buyBtn:setVisible(true)
		self._rootnode.buyBtn:setEnabled(true)
	else
		self._rootnode.has_buy_tag:setVisible(true)
		self._rootnode.buyBtn:setVisible(false)
		self._rootnode.buyBtn:setEnabled(false)
	end
end

function VipLibaoItem:getVipLevel()
	return self._vipLv
end

function VipLibaoItem:create(param)
	local viewSize = param.viewSize
	local buyFunc = param.buyFunc
	self._getLevelGiftAry = param.getLevelGiftAry or {}
	local cellDatas = param.cellDatas
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self._rootnode.itemDesLbl:setColor(cc.c3b(99, 47, 8))
	self:refreshItem(cellDatas)
	
	self._rootnode.buyBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if buyFunc ~= nil then
			self._rootnode.buyBtn:setEnabled(false)
			buyFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	return self
end

function VipLibaoItem:tableCellTouched(x, y)
	local itemIcon = self._rootnode["itemIcon"]
	if cc.rectContainsPoint(itemIcon:getBoundingBox(), itemIcon:convertToNodeSpace(cc.p(x, y))) then
		local layer = require("game.shop.vipLibao.VipLibaoRewardLayer").new({
		vipLv = self._vipLv,
		title = self._title,
		itemData = self._itemData,
		closeFunc = function()
			--itemIcon:setTouchEnabled(true)
		end
		})
		game.runningScene:addChild(layer, MAX_ZORDER)
	end
end

function VipLibaoItem:refresh(cellDatas)
	self:refreshItem(cellDatas)
end

function VipLibaoItem:refreshItem(cellDatas)
	self._itemData = cellDatas.itemData
	self._vipLv = cellDatas.vipLv
	self._title = cellDatas.title
	self._rootnode.vip_level_lbl:setString(tostring(self._vipLv))
	self._rootnode.newPrice_lbl:setString(tostring(cellDatas.newPrice))
	self._rootnode.oldPrice_lbl:setString(tostring(cellDatas.oldPrice))
	self._rootnode.itemDesLbl:setString(tostring(cellDatas.describe))
	self._rootnode.title_lbl:setString(tostring(self._title))
	local bBuyEnabled = true
	for i, v in ipairs(self._getLevelGiftAry) do
		if self._vipLv == v then
			bBuyEnabled = false
			break
		end
	end
	self:setBuyBtnEnabled(bBuyEnabled)
	alignNodesOneByOne(self._rootnode.newPriceName, self._rootnode.newPriceIcon, -120)
end

function VipLibaoItem:getReward(getLevelGiftAry)
	self._getLevelGiftAry = getLevelGiftAry
	self:setBuyBtnEnabled(false)
end

return VipLibaoItem