local CostTipMsgBox = class("CostTipMsgBox", function ()
	return require("utility.ShadeLayer").new()
end)
function CostTipMsgBox:ctor(param)
	local _costNum = param.cost
	local _tip = param.tip
	local _listener = param.listener
	local _cancelListener = param.cancelListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("public/cost_tip_msg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.label_tip_2:setString(_costNum)
	self._rootnode.label_tip_4:setString(_tip)
	local nodeTbl = {}
	for i = 1, 4 do
		nodeTbl[i] = self._rootnode["label_tip_" .. i]
	end
	local parent = self._rootnode.label_tip_1:getParent()
	alignNodesOneByAllCenterX(parent, nodeTbl, 5)
	local function close()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if _cancelListener then
			_cancelListener()
		end
		self:removeSelf()
	end
	self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode["cancelBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode["confirmBtn"]:addHandleOfControlEvent(function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		_listener()
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
end

return CostTipMsgBox