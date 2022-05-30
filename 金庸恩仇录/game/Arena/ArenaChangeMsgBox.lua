require("game.GameConst")

local ArenaChangeMsgBox = class("ArenaChangeMsgBox", function(data)
	return require("utility.ShadeLayer").new()
end)

function ArenaChangeMsgBox:ctor(param)
	local resetFunc = param.resetFunc
	local battleFunc = param.battleFunc
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	local rootnode = rootnode or {}
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/arena/arena_change_msgBox.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	setControlBtnEvent(self._rootnode.backBtn, function()
		resetFunc()
		self:removeSelf()
	end,
	function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end)
	
	setControlBtnEvent(self._rootnode.confirm_btn, function()
		battleFunc()
	end)
	
end

return ArenaChangeMsgBox