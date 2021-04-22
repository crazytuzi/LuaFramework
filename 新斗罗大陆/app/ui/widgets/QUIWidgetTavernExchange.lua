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
-- 酒馆高级招将兑换界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTavernExchange = class("QUIWidgetTavernExchange", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetTavernExchange:ctor(options)
	local ccbFile = "ccb/Widget_Exchange_Tavern.ccbi"
	QUIWidgetTavernExchange.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetTavernExchange:refreshInfo()
	self:setInfo(self._info)
end

function QUIWidgetTavernExchange:setInfo(info)
	self._info = info
	self._ccbOwner.tf_token_num:setString(self._info.price or "")

	if not self._info.discount or self._info.discount == 10 then
		self._ccbOwner.ccb_dazhe:setVisible(false)
	else
		self._ccbOwner.chengDisCountBg:setVisible(false)
		self._ccbOwner.lanDisCountBg:setVisible(false)
		self._ccbOwner.ziDisCountBg:setVisible(false)
		self._ccbOwner.hongDisCountBg:setVisible(true)
		self._ccbOwner.ccb_dazhe:setVisible(true)
		if self._info.discount == 5 then
			self._ccbOwner.discountStr:setString("半价")
			if self._info.price then
				self._ccbOwner.tf_token_num:setString(tonumber(self._info.price) * 0.5)
			end
		else
			self._ccbOwner.discountStr:setString(self._info.discount.."折")
		end
	end

	self._ccbOwner.node_item:removeAllChildren()
	if self._info.itemId then
		local itemType = remote.items:getItemType(self._info.itemId)
        if itemType == nil then
            itemType = ITEM_TYPE.ITEM
        end
		local box = QUIWidgetItemsBox.new()
        box:setGoodsInfo(self._info.itemId, itemType, self._info.buyType, true)
        self._ccbOwner.node_item:addChild(box)
	end
end

function QUIWidgetTavernExchange:getInfo()
	return self._info
end

function QUIWidgetTavernExchange:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetTavernExchange