require("game.GameConst")

local JieFuJiPinResult = class("JieFuJiPinResult", function(data)
	return require("utility.ShadeLayer").new()
end)

function JieFuJiPinResult:ctor(data)
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	self.jumpFunc = data.jumpFunc
	local totalDamge = data.totalDamage
	local totalMoney = data.totalMoney
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/huodong/jiefujipin_result_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local setNumPos = function(parent, num)
		num:setPosition(parent:getPositionX() + parent:getContentSize().width, parent:getPositionY())
	end
	self.curDamageNum = ui.newTTFLabelWithShadow({
	text = totalDamge,
	size = 26,
	color = cc.c3b(230, 56, 56),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_LEFT
	})
	self.curDamageNum:align(display.LEFT_CENTER)
	setNumPos(self._rootnode.total_num, self.curDamageNum)
	self._rootnode.listView:addChild(self.curDamageNum)
	alignNodesOneByOne(self._rootnode.msg_tag, self._rootnode.silver_icon, 3)
	
	self.curSilverNum = ui.newTTFLabelWithShadow({
	text = totalMoney,
	size = 26,
	color = FONT_COLOR._WHITE,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_LEFT
	})
	self.curSilverNum:align(display.LEFT_CENTER)
	setNumPos(self._rootnode.silver_icon, self.curSilverNum)
	self._rootnode.listView:addChild(self.curSilverNum)
	
	--È·ÈÏ°´¼ü
	self._rootnode.confirm_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self.jumpFunc()
	end,
	CCControlEventTouchDown)
	
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
end

function JieFuJiPinResult:setJumpFunc(func)
	self.jumpFunc = func
end

return JieFuJiPinResult