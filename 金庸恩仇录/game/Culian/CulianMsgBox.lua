require("game.GameConst")

local CulianMsgBox = class("CulianMsgBox", function(data)
	return require("utility.ShadeLayer").new()
end)

function CulianMsgBox:ctor(param)
	local okListener = param.okListener
	local noListener = param.noListener
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	local rootnode = rootnode or {}
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/lianhualu/cuilian_msg_box.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	setControlBtnEvent(self._rootnode.backBtn, function()
		self:removeSelf()
		if noLictener then
			noListener()
		end
	end)
	
	setControlBtnEvent(self._rootnode.confirm_btn, function()
		self:removeSelf()
		if okListener then
			okListener()
		end
	end)
end

return CulianMsgBox