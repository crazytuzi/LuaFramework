local data_config_union_config_union = require("data.data_config_union_config_union")
local NORMAL_FONT_SIZE = 22
local SMALL_FONT_SIZE = 18

local GuildMemberNormalItem = class("GuildMemberNormalItem", function()
	return CCTableViewCell:new()
end)

function GuildMemberNormalItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_guildMember_normal_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self._contentSz
end

function GuildMemberNormalItem:getPlayerIcon()
	return self._rootnode.player_icon
end

function GuildMemberNormalItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local jobFunc = param.jobFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_guildMember_normal_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	
	self._onlineLbl = self:createTTF(common:getLanguageString("@HintUndetermined"), cc.c3b(58, 209, 73), self._rootnode, "online_lbl", SMALL_FONT_SIZE)
	self._onlineLbl:align(display.CENTER_TOP)
	
	self._battleTimesLbl = self:createTTF(common:getLanguageString("@GuildTodayPVPTimes20"), cc.c3b(255, 178, 69), self._rootnode, "battle_times_lbl", SMALL_FONT_SIZE)
	self._battleTimesLbl:align(display.CENTER_BOTTOM)
	
	self._buildLbl = self:createTTF(common:getLanguageString("@HintUndetermined"), cc.c3b(255, 178, 69), self._rootnode, "build_lbl", SMALL_FONT_SIZE)
	self._buildLbl:align(display.CENTER_BOTTOM)
	
	self._rootnode.job_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if jobFunc ~= nil then
			jobFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._centerPosY_up = self._rootnode.center_node:getPositionY()
	self._centerPosY_down = self._centerPosY_up - 10
	self:refreshItem(itemData)
	return self
end

function GuildMemberNormalItem:createTTF(text, color, nodes, name, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or NORMAL_FONT_SIZE,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildMemberNormalItem:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildMemberNormalItem:refreshItem(itemData)
	if itemData.isSelf == true then
		self:createTTF(tostring(itemData.lastContribute), cc.c3b(78, 255, 0), self._rootnode, "gongxian_lbl")
		self._rootnode.lelft_gongxian_node:setVisible(true)
		self._rootnode.center_node:setPositionY(self._centerPosY_up)
	elseif itemData.isSelf == false then
		self._rootnode.lelft_gongxian_node:setVisible(false)
		self._rootnode.center_node:setPositionY(self._centerPosY_down)
	end
	if itemData.jopType == GUILD_JOB_TYPE.normal then
		self._rootnode.cell_bg_leader:setVisible(false)
		self._rootnode.cell_bg_normal:setVisible(true)
		self._rootnode.mem_icon:setVisible(false)
		self._rootnode.mem_normal_lbl:setVisible(true)
	else
		self._rootnode.cell_bg_leader:setVisible(true)
		self._rootnode.cell_bg_normal:setVisible(false)
		self._rootnode.mem_icon:setVisible(true)
		self._rootnode.mem_normal_lbl:setVisible(false)
		self._rootnode.mem_leader_lbl:setString(GUILD_JOB_NAME[itemData.jopType + 1])
	end
	self._rootnode.guild_lv_lbl:setString("LV." .. tostring(itemData.roleLevel))
	self._rootnode.guild_name_lbl:setString(tostring(itemData.roleName))
	self:createTTF(tostring(itemData.rank), cc.c3b(238, 12, 205), self._rootnode, "arena_lbl")
	self:createTTF(tostring(itemData.totalContribute), cc.c3b(247, 228, 97), self._rootnode, "total_gongxian_lbl")
	self:createTTF(tostring(itemData.attack), cc.c3b(78, 255, 0), self._rootnode, "power_lbl")
	self._battleTimesLbl:setString(common:getLanguageString("@GuildTodayPVPtimes") .. tostring(itemData.defenseNum))
	self._buildLbl:setString(tostring(itemData.buildStr))
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

return GuildMemberNormalItem