local COST_TYPE = {silver = 1, gold = 2}
local yColor = cc.c3b(255, 222, 0)

local GuildDadianDynamicItem = class("GuildDadianDynamicItem", function()
	return CCTableViewCell:new()
end)

function GuildDadianDynamicItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_dadian_dynamic_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
	end
	return self._contentSz
end

function GuildDadianDynamicItem:setBtnEnabled(bEnabled)
	self._rootnode.contributeBtn:setEnabled(bEnabled)
end

function GuildDadianDynamicItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_dadian_dynamic_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	self:refreshItem(itemData)
	return self
end

function GuildDadianDynamicItem:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildDadianDynamicItem:refreshItem(itemData)
	self._rootnode.name_lbl:setString(itemData.roleName)
	self._rootnode.coin_lbl:setString(itemData.conMoney)
	arrangeTTFByPosX({
	self._rootnode.name_lbl,
	self._rootnode.msg_lbl_1,
	self._rootnode.coin_lbl,
	self._rootnode.msg_lbl_2
	})
end

return GuildDadianDynamicItem