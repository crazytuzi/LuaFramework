local data_config_union_config_union = require("data.data_config_union_config_union")
local NORMAL_FONT_SIZE = 22
local SMALL_FONT_SIZE = 18

local GuildMemberVerifyItem = class("GuildMemberVerifyItem", function()
	return CCTableViewCell:new()
end)

function GuildMemberVerifyItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_guildMember_verify_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
	end
	return self._contentSz
end

function GuildMemberVerifyItem:getRoleId()
	return self._roleId
end

function GuildMemberVerifyItem:getPlayerIcon()
	return self._rootnode.player_icon
end

function GuildMemberVerifyItem:setBtnEnabled(bEnabled)
	self._rootnode.accept_btn:setEnabled(bEnabled)
	self._rootnode.reject_btn:setEnabled(bEnabled)
end

function GuildMemberVerifyItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local acceptFunc = param.acceptFunc
	local rejectFunc = param.rejectFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_guildMember_verify_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	
	self._onlineLbl = self:createTTF(tostring(itemData.rank), cc.c3b(58, 209, 73), "online_lbl", SMALL_FONT_SIZE)
	self._onlineLbl:align(display.CENTER_TOP)
	
	self._rootnode.accept_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if acceptFunc ~= nil then
			self:setBtnEnabled(false)
			acceptFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.reject_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if rejectFunc ~= nil then
			self:setBtnEnabled(false)
			rejectFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:refreshItem(itemData)
	return self
end

function GuildMemberVerifyItem:createTTF(text, color, name, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or NORMAL_FONT_SIZE,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	})
	ResMgr.replaceKeyLableEx(lbl, self._rootnode, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildMemberVerifyItem:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildMemberVerifyItem:refreshItem(itemData)
	--dump(itemData)
	self._roleId = itemData.roleId
	self._rootnode.guild_lv_lbl:setString("LV." .. tostring(itemData.roleLevel))
	self._rootnode.guild_name_lbl:setString(tostring(itemData.roleName))
	self:createTTF(tostring(itemData.rank), cc.c3b(238, 12, 205), "arena_lbl")
	self:createTTF(tostring(itemData.attack), cc.c3b(234, 62, 43), "power_lbl")
	self:createTTF(tostring(itemData.timeStr), cc.c3b(78, 255, 0), "time_lbl")
	
	self._onlineLbl:setString(tostring(itemData.onlineStr))
	if itemData.isOnline == true then
		self._onlineLbl:setColor(cc.c3b(58, 209, 73))
	else
		self._onlineLbl:setColor(cc.c3b(170, 170, 170))
	end
	ResMgr.refreshIcon({
	id = itemData.resId,
	itemBg = self._rootnode.player_icon,
	resType = ResMgr.HERO,
	cls = itemData.rolecls
	})
end

return GuildMemberVerifyItem