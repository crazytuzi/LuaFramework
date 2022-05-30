local NORMAL_FONT_SIZE = 22

local GuildRankItem = class("GuildRankItem", function()
	return CCTableViewCell:new()
end)

function GuildRankItem:getContentSize()
	if self.cntSize == nil then
		local proxy = CCBProxy:create()
		local rootNode = {}
		CCBuilderReaderLoad("guild/guild_rank_item.ccbi", proxy, rootNode)
		self.cntSize = rootNode.itemBg:getContentSize()
	end
	return self.cntSize
end

function GuildRankItem:ctor()
	display.addSpriteFramesWithFile("ui/ui_guild_common_bg.plist", "ui/ui_guild_common_bg.png")
end

function GuildRankItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	self._id = param.id
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("guild/guild_rank_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	self:updateItem(itemData)
	return self
end

function GuildRankItem:createTTF(text, color, nameKey, size)
	local lbl = ui.newTTFLabelWithOutline({
	text = text,
	size = size or NORMAL_FONT_SIZE,
	color = color,
	outlineColor = cc.c3b(10, 10, 10),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	ResMgr.replaceKeyLableEx(lbl, self._rootnode, nameKey, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildRankItem:refresh(param)
	self._id = param.id
	self:updateItem(param.itemData)
end

function GuildRankItem:updateItem(itemData)
	
	self:createTTF(tostring(itemData.leaderName), cc.c3b(238, 12, 205), "player_name_lbl")
	
	local lv = self:createTTF("LV." .. tostring(itemData.leaderLevel), cc.c3b(238, 12, 205), "player_lv_lbl")
	lv:align(display.CENTER)
	
	self:createTTF(tostring(itemData.sumAttack), cc.c3b(78, 255, 0), "guild_power_lbl")
	local bgName = "#guild_cbg_itemBg_4.png"
	local lvBgName = "#guild_cbg_itemTopLvBg_4.png"
	local playerBgName = "#guild_cbg_itemTopBg_4.png"
	local markIconName = "#guild_cbg_markBg_4.png"
	local rank = self._id
	if rank < 4 then
		bgName = "#guild_cbg_itemBg_" .. rank .. ".png"
		playerBgName = "#guild_cbg_itemTopBg_" .. rank .. ".png"
		lvBgName = "#guild_cbg_itemTopLvBg_" .. rank .. ".png"
		markIconName = "#guild_cbg_markBg_" .. rank .. ".png"
		self._rootnode.rank_num_lbl:setVisible(false)
	else
		self._rootnode.rank_num_lbl:setVisible(true)
		local rankNumLbl = self:createTTF(tostring(rank), cc.c3b(251, 235, 197), "rank_num_lbl", 42)
		rankNumLbl:align(display.CENTER)
		--rankNumLbl:setPosition(-rankNumLbl:getContentSize().width / 2, 0)
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
	self._rootnode.mark_icon:setDisplayFrame(display.newSprite(markIconName):getDisplayFrame())
	self._rootnode.lv_lbl:setString("LV." .. tostring(itemData.level))
	self._rootnode.name_lbl:setString(tostring(itemData.name))
end

return GuildRankItem