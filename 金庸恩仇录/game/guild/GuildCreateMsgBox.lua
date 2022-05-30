local data_config_union_config_union = require("data.data_config_union_config_union")
local guildNameMaxLen = data_config_union_config_union[1].guild_name_max_length
local createNeedGold = data_config_union_config_union[1].create_guild_need_gold
local CreateGuildType = {gold = 0, coin = 1}

local GuildCreateMsgBox = class("GuildCreateMsgBox", function()
	return require("utility.ShadeLayer").new()
end)

function GuildCreateMsgBox:reqCreateGuild(guildName, createType)
	RequestHelper.Guild.create({
	name = guildName,
	type = CreateGuildType.gold,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			local rtnObj = data.rtnObj
			local guildMgr = game.player:getGuildMgr()
			guildMgr:setIsInUnion(true)
			guildMgr:setGuildInfo(rtnObj)
			game.player:updateMainMenu({
			gold = rtnObj.surplusGold
			})
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_MAINSCENE)
		end
	end
	})
end

function GuildCreateMsgBox:reName(guildName)
	local renameMsg = function(param)
		local _callback = param.callback
		local msg = {
		m = "union",
		a = "updateUnionName",
		name = param.name
		}
		RequestHelper.request(msg, _callback, param.errback)
	end
	renameMsg({
	name = guildName,
	callback = function(data)
		dump(data)
		local guildInfo = game.player:getGuildMgr():getGuildInfo()
		guildInfo.m_name = data.rtnObj
		self._nameLbl:setString(guildInfo.m_name)
		self:removeSelf()
		show_tip_label(common:getLanguageString("@GuildRenameSuccess"))
	end
	})
end

function GuildCreateMsgBox:ctor(param)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_create_guild_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if param then
		self._msgType = param.type
		self._nameLbl = param.nameLbl
	end
	local titleStr = "@GuildBuild"
	if self._msgType == 2 then
		titleStr = "@GuildRename"
		rootnode.modify_tips:setString(common:getLanguageString("@GuildRenameCost"))
		createNeedGold = data_config_union_config_union[1].changeUnionName
		rootnode.gold_need_lbl:setString("" .. createNeedGold)
	else
		createNeedGold = data_config_union_config_union[1].create_guild_need_gold
	end
	rootnode.titleLabel:setString(common:getLanguageString(titleStr))
	local editBoxNode = rootnode.editBox_node
	local cntSize = editBoxNode:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#win_base_inner_bg_black.png",
	size = cc.size(cntSize.width, cntSize.height),
	x = cntSize.width / 2,
	y = cntSize.height / 2
	})
	self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setFontColor(FONT_COLOR.WHITE)
	self._editBox:setPlaceHolder(common:getLanguageString("@HintGuildBuild"))
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	editBoxNode:addChild(self._editBox)
	
	local function closeFunc()
		self:removeSelf()
	end
	
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local textStr = self._editBox:getText()
		if textStr == "" then
			show_tip_label(data_error_error[2900003].prompt)
		elseif string.utf8len(textStr) > guildNameMaxLen then
			show_tip_label(data_error_error[2900039].prompt)
		elseif game.player:getGold() < createNeedGold then
			show_tip_label(data_error_error[2900004].prompt)
		elseif common:checkSensitiveWord(textStr) == true or ResMgr.checkSensitiveWord(textStr) == true then
			show_tip_label(data_error_error[2900041].prompt)
		else
			if self._msgType == 2 then
				self:reName(textStr)
			else
				self:reqCreateGuild(textStr, CreateGuildType.gold)
			end
			self._editBox:setText("")
		end
	end,
	CCControlEventTouchUpInside)
	
end

return GuildCreateMsgBox