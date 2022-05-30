local NORMAL_FONT_SIZE = 22

local GuildBattleGuildListItem = class("GuildBattleGuildListItem", function()
	return CCTableViewCell:new()
end)

function GuildBattleGuildListItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_battle_guild_list_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self._contentSz
end

function GuildBattleGuildListItem:create(param)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_battle_guild_list_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	self:refresh(param.itemData)
	return self
end

function GuildBattleGuildListItem:refresh(itemData)
	local bgName = "#sh_bg_4.png"
	local lvBgName = "#sh_lv_bg_4.png"
	local playerBgName = "#sh_name_bg_4.png"
	local mark = itemData.rank
	if mark > 10 then
		mark = 10
	end
	local markIcon = "#sh_mark_" .. mark .. ".png"
	if itemData.rank == 0 then
		bgName = "#sh_bg_5.png"
		playerBgName = "#sh_name_bg_6.png"
		lvBgName = "#sh_lv_bg_5.png"
	elseif itemData.rank < 4 then
		bgName = "#sh_bg_" .. itemData.rank .. ".png"
		playerBgName = "#sh_name_bg_" .. itemData.rank .. ".png"
		lvBgName = "#sh_lv_bg_" .. itemData.rank .. ".png"
	end
	self._rootnode.bg_node:removeAllChildren()
	local bg = display.newScale9Sprite(bgName, 0, 0, self._rootnode.bg_node:getContentSize())
	bg:setAnchorPoint(0, 0)
	self._rootnode.bg_node:addChild(bg)
	self._rootnode.name_bg:removeAllChildren()
	local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode.name_bg:getContentSize())
	playerBg:setAnchorPoint(0, 0)
	self._rootnode.name_bg:addChild(playerBg)
	self._rootnode.lv_bg:setDisplayFrame(display.newSprite(lvBgName):getDisplayFrame())
	self._rootnode.mark_icon:setDisplayFrame(display.newSprite(markIcon):getDisplayFrame())
	
	self._rootnode.guild_name_lbl:setString(itemData.unionName)
	self._rootnode.guild_gongxun_lbl:setString(itemData.medal)
	
end

return GuildBattleGuildListItem