local SellFrame = class("SellFrame", function (param)
	return display.newNode()
end)

function SellFrame:ctor(param)
	local leftTitle = param.leftTitle
	local rightTitle = param.rightTitle
	local icon = param.icon
	local sellFunc = param.sellFunc
	local downProxy = CCBProxy:create()
	self._downNode = {}
	local downNode = CCBuilderReaderLoad("public/bottom_sell_frame", downProxy, self._downNode)
	downNode:setPosition(display.cx, 0)
	self:addChild(downNode, 1)
	self._downNode.leftTitle:setString(leftTitle)
	self._downNode.rightTitle:setString(rightTitle)
	if icon == nil or icon == 0 or not icon.getDisplayFrame then
	else
		self._downNode.sellIcon:setVisible(true)
		self._downNode.sellIcon:setDisplayFrame(icon:getDisplayFrame())
	end
	self._downNode.sellBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		sellFunc()
	end,
	CCControlEventTouchUpInside)
end

function SellFrame:setLeftNum(num)
	self._downNode.sellNum:setString(num)
end

function SellFrame:setRightNum(num)
	self._downNode.totalNum:setString(num)
end

return SellFrame