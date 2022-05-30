local GuildFubenHelpLayer = class("GuildFubenHelpLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFubenHelpLayer:ctor(param)
	local closeFunc = param.closeFunc
	local title = param.title
	local msg = param.msg
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_fuben_help_layer.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(title or common:getLanguageString("@Hint"))
	rootnode.msg_lbl:setString(msg)
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
end

return GuildFubenHelpLayer