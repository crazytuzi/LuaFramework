require("cocos.cocosbuilder.CCBReaderLoad")

local DownloadTipLayer = class("DownloadTipLayer", function()
	return require("utility.ShadeLayer").new()
end)

function DownloadTipLayer:ctor(param)
	local _size = param.size or 0
	local _listener = param.listener
	local _cancelListener = param.cancelListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("public/update_tip.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local sizeStr = ""
	if _size > 1024 and _size < 1048576 then
		sizeStr = string.format("%dKB", _size / 1024)
	elseif _size < 1024 then
		sizeStr = string.format("%dB", _size)
	else
		sizeStr = string.format("%.2fM", _size / 1024 / 1024)
	end
	require("utility.richtext.richText")
	require("game.GameConst")
	self._rootnode.update_tip_1:setVisible(false)
	self._rootnode.update_tip_2:setVisible(true)
	local text = common:getLanguageString("@ToUpdateTips", sizeStr)
	local showSize = self._rootnode.update_tip_2:getContentSize()
	local infoNode = getRichText(text, showSize.width * 0.9)
	local infoSize = infoNode:getContentSize()
	self._rootnode.update_tip_2:addChild(infoNode)
	infoNode:setPosition(10, infoNode:getContentSize().height)
	local function close()
		if _cancelListener then
			_cancelListener()
		end
		CSDKShell.exit()
		self:removeSelf()
	end
	self._rootnode.cancelBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.cancelBtn:setVisible(false)
	local width = self._rootnode.tag_bg:getContentSize().width
	self._rootnode.confirmBtn:setPositionX(width / 2)
	self._rootnode.confirmBtn:addHandleOfControlEvent(function()
		self._rootnode.confirmBtn:setEnabled(false)
		self:setVisible(false)
		self:performWithDelay(function()
			self:removeSelf()
			_listener()
		end,
		0.001)
	end,
	CCControlEventTouchUpInside)
end

return DownloadTipLayer