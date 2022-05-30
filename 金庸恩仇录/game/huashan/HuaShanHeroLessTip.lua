local HuaShanHeroLessTip = class("HuaShanHeroLessTip", function()
	return require("utility.ShadeLayer").new()
end)

function HuaShanHeroLessTip:ctor(param)
	local listener = param.listener
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_tiaozhan.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local function close()
		if closeFunc ~= nil then
			closeFunc()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end
	
	self._rootnode.backBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.confirm_btn:addHandleOfControlEvent(function()
		self._rootnode.confirm_btn:setEnabled(false)
		if listener then
			listener()
		end
		close()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.cancel_btn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
end

return HuaShanHeroLessTip