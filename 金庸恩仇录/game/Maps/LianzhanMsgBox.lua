local LianzhanMsgBox = class("LianzhanMsgBox", function()
	return require("utility.ShadeLayer").new()
end)
function LianzhanMsgBox:ctor(param)
	local gold = param.gold
	local listener = param.listener
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("battle/liangzhan_msgbox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.goldNumLbl:setString(gold)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if listener ~= nil then
			listener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
end

return LianzhanMsgBox