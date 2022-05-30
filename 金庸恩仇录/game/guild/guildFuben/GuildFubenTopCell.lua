local GuildFubenTopCell = class("GuildFubenTopCell", function()
	return CCTableViewCell:new()
end)

function GuildFubenTopCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("guild/guild_fuben_top_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function GuildFubenTopCell:setSelected(bSelected)
	local itemImg
	if bSelected == true then
		itemImg = "#guild_fuben_select_" .. tostring(self._chapterId) .. ".png"
	elseif bSelected == false then
		itemImg = "#guild_fuben_unselect_" .. tostring(self._chapterId) .. ".png"
	end
	self._rootnode.tag_btn:setDisplayFrame(display.newSprite(itemImg):getDisplayFrame())
end

function GuildFubenTopCell:getIcon()
	return self._rootnode.tag_btn
end

function GuildFubenTopCell:getChapterId()
	return self._chapterId
end

function GuildFubenTopCell:create(param)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_fuben_top_item.ccbi", proxy, self._rootnode)
	node:setPosition(0, viewSize.height / 2)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function GuildFubenTopCell:refresh(param)
	self:refreshItem(param)
end

function GuildFubenTopCell:refreshItem(param)
	self._chapterId = param.chapterId
	self:setSelected(param.bSelected)
end

return GuildFubenTopCell