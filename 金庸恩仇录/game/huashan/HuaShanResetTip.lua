
local HuaShanResetTip = class("HuaShanResetTip", function()
	return require("utility.ShadeLayer").new()
end)

function HuaShanResetTip:ctor(param)
	local _costNum = param.cost
	local _remainNum = param.remainNum
	local _listener = param.listener
	local _cancelListener = param.cancelListener
	local _showType = param.showType
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_reset_msg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.cost_num:setString(common:getLanguageString("@SwordfightReset", _costNum or 0))
	self._rootnode.remainLabel:setString(common:getLanguageString("@SwordfightTime", _remainNum or 0))
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.cancelBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if _cancelListener then
			_cancelListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		_listener()
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	if _showType == 1 then
		self._rootnode.costNode:setVisible(true)
		self._rootnode.freeNode:setVisible(false)
	else
		self._rootnode.costNode:setVisible(false)
		self._rootnode.freeNode:setVisible(true)
	end
end

return HuaShanResetTip