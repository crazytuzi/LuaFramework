local ChongzhiItem = class("ChongzhiItem", function()
	return CCTableViewCell:new()
end)

function ChongzhiItem:getContentSize()
	if self._cntSize == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_item.ccbi", proxy, rootnode)
		self._cntSize = node:getContentSize()
	end
	return self._cntSize
end

function ChongzhiItem:getIcon(index)
	return self._rootnode["icon_" .. tostring(index)]
end

function ChongzhiItem:create(param)
	self._itemData = param.itemData
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_item.ccbi", proxy, self._rootnode)
	local cntSize = node:getContentSize()
	node:setPosition(viewSize.width / 2, cntSize.height / 2)
	self:addChild(node)
	self._cntSize = cntSize
	self:refresh(self._itemData)
	return self
end

function ChongzhiItem:refresh(itemData)
	if itemData ~= nil then
		self._itemData = itemData
		for i = #self._itemData + 1, 3 do
			self._rootnode["tag_" .. i]:setVisible(false)
		end
		for i, v in ipairs(self._itemData) do
			self:refreshItem(v, i)
		end
		self._rootnode.tag_4:setVisible(false)
	else
		local data_chongzhi = require("game.Chongzhi")
		local monthCardPrice = data_chongzhi[CurrentPayWay][MonthCardTYPE].coinnum
		local monthCardBaseGold = data_chongzhi[CurrentPayWay][MonthCardTYPE].basegold
		for i = 1, 3 do
			self._rootnode["tag_" .. i]:setVisible(false)
		end
		self._rootnode.gold_icon_4:setVisible(false)
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
			self._rootnode.icon_4:setDisplayFrame(display.newSprite("#cz_icon_6.png"):getDisplayFrame())
			self._rootnode.gold_icon_4:setVisible(true)
			self._rootnode.gold_lbl_4:setString(tostring(monthCardBaseGold))
		else
			self._rootnode.icon_4:setPositionY(30)
		end
		--ÆÁ±ÎÔÂ¿¨
		--self._rootnode.tag_4:setVisible(true)
		--self._rootnode.price_lbl_4:setVisible(true)
		--local tag_Money = common:getLanguageCoin(monthCardPrice)
		--self._rootnode.price_lbl_4:setString(tag_Money)
	end
end

function ChongzhiItem:refreshItem(data, i)
	self._rootnode["tag_" .. i]:setVisible(true)
	self._rootnode["icon_" .. i]:setDisplayFrame(display.newSprite(data.iconImgName):getDisplayFrame())
	local tag_Money = common:getLanguageCoin(data.price)
	self._rootnode["price_lbl_" .. i]:setString(tag_Money)
	self._rootnode["gold_lbl_" .. i]:setString(tostring(data.basegold))
	--local arrangeNode
	if data.buyCnt > 0 or not data.isShowMark then
		self._rootnode["gift_icon_" .. i]:setVisible(false)
		self._rootnode["gold_x3_" .. i]:setVisible(false)
		--self._rootnode["gold_give_icon_" .. i]:setVisible(true)
		--self._rootnode["gold_give_lbl_" .. i]:setString(tostring(data.chixugold))		
		--if data.chixugold > 999 then
		--	self._rootnode["gold_icon_" .. i]:setPositionX(-self._rootnode["gold_icon_" .. i]:getContentSize().width / 2)
		--else
		--	self._rootnode["gold_icon_" .. i]:setPositionX(0)
		--end
		--arrangeNode = self._rootnode["gold_give_icon_" .. i]
	else
		self._rootnode["gift_icon_" .. i]:setVisible(true)
		self._rootnode["gold_icon_" .. i]:setPositionX(0)
		self._rootnode["gold_x3_" .. i]:setVisible(true)
		self._rootnode["gold_give_icon_" .. i]:setVisible(false)
		--arrangeNode = self._rootnode["gold_x3_" .. i]
	end
	alignNodesOneByOne(self._rootnode["gold_lbl_" .. i], self._rootnode["gold_x3_" .. i])
end

return ChongzhiItem