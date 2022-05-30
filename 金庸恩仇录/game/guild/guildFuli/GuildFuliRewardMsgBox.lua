local GuildFuliRewardMsgBox = class("GuildFuliRewardMsgBox", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFuliRewardMsgBox:ctor(param)
	local tili = param.tili
	local naili = param.naili
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_guildFuli_reward_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.tili_lbl:setString(tostring(tili))
	rootnode.naili_lbl:setString(tostring(naili))
	
	local function closeFunc()
		self:removeSelf()
	end
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
end

return GuildFuliRewardMsgBox