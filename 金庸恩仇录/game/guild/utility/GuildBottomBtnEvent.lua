GuildBottomBtnEvent = {}
GuildBottomBtnEvent.canTouchEnabled = true
local BOTTOM_BTN_TYPE = {
manager = 1,
member = 2,
chat = 3,
dynamic = 4,
back = 5,
fuli = 6
}
local MAX_ZORDER = 100
local btnNames = {
"manager_btn",
"member_btn",
"chat_btn",
"dynamic_btn",
"back_btn",
"fuli_btn"
}

function GuildBottomBtnEvent.setTouchEnabled(bEnabled)
	GuildBottomBtnEvent.canTouchEnabled = bEnabled
end

function GuildBottomBtnEvent.registerBottomEvent(btnMaps)
	
	local function onTouchBtn(sender)
		if GuildBottomBtnEvent.canTouchEnabled ~= nil and GuildBottomBtnEvent.canTouchEnabled == true then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local nextState
			local tag = sender:getTag()
			dump(tag)
			if tag == BOTTOM_BTN_TYPE.manager then
				game.runningScene:addChild(require("game.guild.GuildManagerLayer").new(), MAX_ZORDER)
			elseif tag == BOTTOM_BTN_TYPE.member then
				nextState = GAME_STATE.STATE_GUILD_ALLMEMBER
			elseif tag == BOTTOM_BTN_TYPE.chat then
				local id = game.player:getGuildMgr():getGuildInfo().m_id
				if id and id > 0 then
					RewardLayerMgr.createLayerByType(RewardLayerMgrType.chatGuild, game.runningScene, MAX_ZORDER)
				else
					ResMgr.showErr(1700002)
				end
				--[[
				RequestHelper.chat.getGuildId({
				callback = function(data)
					if data.err ~= "" then
						dump(data.err)
					else
						local guildId = data.rtnObj
						if guildId == 0 then
							ResMgr.showErr(1700002)
						else
							RewardLayerMgr.createLayerByType(RewardLayerMgrType.chatGuild, game.runningScene, MAX_ZORDER)
						end
					end
				end
				})
				]]
			elseif tag == BOTTOM_BTN_TYPE.dynamic then
				nextState = GAME_STATE.STATE_GUILD_DYNAMIC
			elseif tag == BOTTOM_BTN_TYPE.back then
				nextState = GAME_STATE.STATE_MAIN_MENU
			elseif tag == BOTTOM_BTN_TYPE.fuli then
				local function toList(data)
					game.runningScene:addChild(require("game.guild.guildFuli.GuildFuliLayer").new(data), MAX_ZORDER)
				end
				game.player:getGuildMgr():RequestFuliList(toList)
			end
			if nextState ~= nil then
				GameStateManager:ChangeState(nextState)
			end
		end
	end
	for i, v in ipairs(btnNames) do
		if btnMaps[v] ~= nil then
			btnMaps[v]:addHandleOfControlEvent(function(sender, eventName)
				onTouchBtn(sender)
			end,
			CCControlEventTouchUpInside)
		end
	end
end

return GuildBottomBtnEvent