local MsgBoxEx = class("MsgBoxEx", function (param)
	return require("utility.ShadeLayer").new()
end)

function MsgBoxEx:ctor(param)
	local size = param.size or cc.size(560, 390)
	local baseNode = display.newNode()
	self:addChild(baseNode)
	baseNode:setContentSize(size)
	local confirmFunc = param.confirmFunc
	local closeFunc = param.closeFunc
	local closeListener = param.closeListener
	local backFunc = param.backFunc
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("public/window_msgBoxEx", rootProxy, self._rootnode, baseNode, size)
	baseNode:setPosition(display.cx, display.cy)
	baseNode:addChild(rootnode, 1)
	local resTable = param.resTable or {}
	local innerbg = self._rootnode.inner_node
	local heightRate = {
	0.7,
	0.45,
	0.2
	}
	if #resTable == 2 then
		heightRate = {0.6, 0.4}
	elseif #resTable == 1 then
		heightRate = {0.5}
	elseif #resTable == 4 then
		heightRate = {
		0.7,
		0.5,
		0.3,
		0.1
		}
	end
	for row = 1, #resTable do
		local node = ResMgr.getArrangedNode(resTable[row])
		node:setPosition(innerbg:getContentSize().width / 2 - node.rowWidth / 2, heightRate[row] * innerbg:getContentSize().height)
		innerbg:addChild(node)
	end
	local bgWidth = size.width
	local bgHeight = size.height
	self._rootnode.confirm_btn:addHandleOfControlEvent(function (sender, eventName)
		if confirmFunc ~= nil then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			confirmFunc(self)
		else
			self:removeSelf()
		end
	end,
	CCControlEventTouchUpInside)
	
	local showClose = param.showClose or false
	if showClose then
		self._rootnode.backBtn:setVisible(true)
	end
	
	local function close()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if closeFunc ~= nil then
			closeFunc(self)
		else
			self:removeSelf()
		end
		if closeListener ~= nil then
			closeListener()
		end
	end
	
	self._rootnode.backBtn:addHandleOfControlEvent(function (sender, eventName)
		if backFunc ~= nil then
			backFunc(self)
			self:removeSelf()
		else
			close()
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.cancel_btn:addHandleOfControlEvent(function (sender, eventName)
		close()
	end,
	CCControlEventTouchUpInside)
end

return MsgBoxEx