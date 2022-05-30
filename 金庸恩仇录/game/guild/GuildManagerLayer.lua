local data_config_union_config_union = require("data.data_config_union_config_union")
require("data.data_error_error")
local data_ui_ui = require("data.data_ui_ui")
local MAX_ZORDER = 100

local GuildManagerLayer = class("GuildManagerLayer", function()
	return require("utility.ShadeLayer").new()
end)

local modifyManifesto = function(text, node)
	if common:checkSensitiveWord(text) and ResMgr.checkSensitiveWord(text) == true then
		show_tip_label(data_error_error[2900041].prompt)
		return
	end
	RequestHelper.Guild.modify({
	text = text,
	type = 1,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		elseif data.rtnObj.success == 0 then
			show_tip_label(data_error_error[2900043].prompt)
			game.player:getGuildMgr():getGuildInfo().m_unionOutdes = text
			node:removeSelf()
		end
	end
	})
end

local function zijian(node)
	RequestHelper.Guild.zijian({
	leaderId = game.player:getGuildMgr():getGuildInfo().m_bossId,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			node:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			game.player:getGuildMgr():setCoverVo(rtnObj)
			PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN)
			node:removeSelf()
			game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
			title = common:getLanguageString("@Hint"),
			msg = data_ui_ui[6].content,
			isSingleBtn = true,
			confirmFunc = function(msgBox)
				msgBox:removeSelf()
			end
			}),
			MAX_ZORDER)
		end
	end,
	errback = function(data)
		node:removeSelf()
	end
	})
end

local reqDemise = function(node)
	RequestHelper.Guild.demise({
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			node:setBtnEnabled(true)
		else
			if data.rtnObj.success == 0 then
				game.player:getGuildMgr():setJopType(GUILD_JOB_TYPE.normal)
				if GameStateManager.currentState == GAME_STATE.STATE_GUILD_MAINSCENE or GameStateManager.currentState == GAME_STATE.STATE_GUILD_GUILDLIST or GameStateManager.currentState == GAME_STATE.STATE_GUILD_ALLMEMBER or GameStateManager.currentState == GAME_STATE.STATE_GUILD_VERIFY or GameStateManager.currentState == GAME_STATE.STATE_GUILD_DADIAN or GameStateManager.currentState == GAME_STATE.STATE_GUILD_DYNAMIC then
					GameStateManager:setState(GameStateManager.currentState)
				end
			else
			end
			node:removeSelf()
		end
	end,
	errback = function(data)
		node:removeSelf()
	end
	})
end

function GuildManagerLayer:ctor()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local ccbiName = "guild/guild_manager_leader.ccbi"
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	if jopType == GUILD_JOB_TYPE.assistant then
		ccbiName = "guild/guild_manager_assistant.ccbi"
	elseif jopType ~= GUILD_JOB_TYPE.leader then
		ccbiName = "guild/guild_manager_normal.ccbi"
	end
	local node = CCBuilderReaderLoad(ccbiName, proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(common:getLanguageString("@GuildFuntions"))
	local function closeFunc()
		self:removeSelf()
	end
	
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	if rootnode.zijian_btn ~= nil then
		if game.player:getAppOpenData().zijianbangzhu == APPOPEN_STATE.close then
			rootnode.zijian_btn:setVisible(false)
		else
			rootnode.zijian_btn:setVisible(true)
		end
	end
	local tags = {
	"verify_btn",
	"zijian_btn",
	"modify_btn",
	"demise_btn",
	"autotime_btn"
	}
	local function onTouchBtn(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if tag == tags[1] then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_VERIFY)
		elseif tag == tags[2] then
			show_tip_label(data_error_error[2800001].prompt)
		elseif tag == tags[3] then
			game.runningScene:addChild(require("game.guild.GuildModifyMsgBox").new({
			title = common:getLanguageString("@GuildAnoncement"),
			text = game.player:getGuildMgr():getGuildInfo().m_unionOutdes,
			msgMaxLen = data_config_union_config_union[1].guild_manifesto_max_length,
			confirmFunc = function(text, node)
				modifyManifesto(text, node)
			end
			}),
			MAX_ZORDER)
			self:removeSelf()
		elseif tag == tags[4] then
			game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
			title = common:getLanguageString("@Hint"),
			msg = data_ui_ui[4].content,
			isSingleBtn = false,
			confirmFunc = function(node)
				reqDemise(node)
			end
			}),
			MAX_ZORDER)
			self:removeSelf()
		elseif tag == tags[5] then
			game.runningScene:addChild(require("game.guild.guildAutoTime.GuildAutoTimeLayer").new(), MAX_ZORDER)
			self:removeSelf()
		end
	end
	for i, v in ipairs(tags) do
		if rootnode[v] ~= nil then
			rootnode[v]:addHandleOfControlEvent(function(sender, eventName)
				onTouchBtn(v)
			end,
			CCControlEventTouchUpInside)
		end
	end
end

return GuildManagerLayer