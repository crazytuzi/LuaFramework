local data_config_union_config_union = require("data.data_config_union_config_union")
local NORMAL_FONT_SIZE = 22

local GuildListItem = class("GuildListItem", function()
	return CCTableViewCell:new()
end)

function GuildListItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_guildList_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self._contentSz
end

function GuildListItem:setBtnEnabled(bEnabled)
	self._rootnode.applyBtn:setEnabled(bEnabled)
	self._rootnode.cancelApplyBtn:setEnabled(bEnabled)
end

function GuildListItem:setAppled(bAppled)
	if bAppled == true then
		self._rootnode.applyBtn:setVisible(false)
		self._rootnode.cancelApplyBtn:setVisible(true)
	elseif bAppled == false then
		self._rootnode.applyBtn:setVisible(true)
		self._rootnode.cancelApplyBtn:setVisible(false)
	end
end

function GuildListItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local applyFunc = param.applyFunc
	self._isInUnion = param.isInUnion
	self._guildTotalNum = param.totalNum
	self._curGuildNum = param.curGuildNum
	self._isCanShowMoreBtn = param.isCanShowMoreBtn
	self._id = param.id
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_guildList_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	
	--ÉêÇë
	self._rootnode.applyBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if applyFunc ~= nil then
			self:setBtnEnabled(false)
			applyFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	--È¡ÏûÉêÇë
	self._rootnode.cancelApplyBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if applyFunc ~= nil then
			self:setBtnEnabled(false)
			applyFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:refreshItem(itemData)
	return self
end

function GuildListItem:createTTF(text, color, nodes, keyname, size)
	local lbl = ui.newTTFLabelWithOutline({
	text = text,
	size = size or NORMAL_FONT_SIZE,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	outlineColor =  cc.c3b(10, 10, 10),
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, keyname, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildListItem:refresh(param)
	self._id = param.id
	self:refreshItem(param.itemData)
end

function GuildListItem:refreshItem(itemData)
	if self._isCanShowMoreBtn and self._id == self._curGuildNum then
		self._rootnode.normal_node:setVisible(false)
		self._rootnode.getMore_tag:setVisible(true)
	else
		self._rootnode.normal_node:setVisible(true)
		self._rootnode.getMore_tag:setVisible(false)
		local fontSize = 42
		if tonumber(itemData.rank) > 9 then
			fontSize = 32
		elseif tonumber(itemData.rank) > 99 then
			fontSize = 26
		end
		local rankNumLbl = self:createTTF(tostring(itemData.rank),  cc.c3b(251, 235, 197), self._rootnode, "rank_num_lbl", fontSize)
		rankNumLbl:align(display.CENTER)
		self:createTTF(tostring(itemData.leaderName),  cc.c3b(238, 12, 205), self._rootnode, "player_name_lbl")
		local palyerLv = self:createTTF("LV." .. tostring(itemData.leaderLevel),  cc.c3b(238, 12, 205), self._rootnode, "player_lv_lbl")
		palyerLv:align(display.CENTER)
		self:createTTF(tostring(itemData.nowRoleNum) .. "/" .. tostring(itemData.roleNum),  cc.c3b(247, 228, 97), self._rootnode, "member_num_lbl")
		self:createTTF(tostring(itemData.sumAttack), cc.c3b(78, 255, 0), self._rootnode, "guild_power_lbl")
		if self._isInUnion == false then
			if itemData.apply == true then
				self._rootnode.applyBtn:setVisible(false)
				self._rootnode.cancelApplyBtn:setVisible(true)
			elseif itemData.apply == false then
				self._rootnode.applyBtn:setVisible(true)
				self._rootnode.cancelApplyBtn:setVisible(false)
			end
		else
			self._rootnode.applyBtn:setVisible(false)
			self._rootnode.cancelApplyBtn:setVisible(false)
		end
		self._rootnode.guild_lv_lbl:setString("LV." .. tostring(itemData.level))
		self._rootnode.guild_name_lbl:setString(tostring(itemData.name))
		if itemData.unionOutdes ~= nil and itemData.unionOutdes ~= "" then
			self._rootnode.guild_declaration_lbl:setString(common:getLanguageString("@GuildAnoncement") .. ": " .. tostring(itemData.unionOutdes))
		else
			self._rootnode.guild_declaration_lbl:setString(common:getLanguageString("@GuildAnoncement") .. ": " .. data_config_union_config_union[1].guild_note_msg)
		end
	end
end

return GuildListItem