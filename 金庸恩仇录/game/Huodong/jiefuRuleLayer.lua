require("game.GameConst")
local data_item_item = require("data.data_item_item")
local data_jiefujipin_jiefujipin = require("data.data_jiefujipin_jiefujipin")

local jiefuRuleLayer = class("jiefuRuleLayer", function(data)
	return require("utility.ShadeLayer").new()
end)

function jiefuRuleLayer:ctor(data)
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	self.jumpFunc = data.jumpFunc
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/huodong/jiefujipin_rule_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	--»∑»œ
	self._rootnode.confirm_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self.jumpFunc()
	end,
	CCControlEventTouchUpInside)
	
	--πÿ±’
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	for i = 1, #data_jiefujipin_jiefujipin do
		local jiefuData = data_jiefujipin_jiefujipin[i]
		local bar = self._rootnode["bar" .. i]
		local curDamageNum = ui.newTTFLabelWithShadow({
		text = jiefuData.damage,
		size = 30,
		color = cc.c3b(234, 193, 135),
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_haibao,
		align = ui.TEXT_ALIGN_LEFT
		})
		curDamageNum:align(display.LEFT_CENTER, bar:getContentSize().width * 0.18, bar:getContentSize().height / 2)
		bar:addChild(curDamageNum)
		local curSilverNum = ui.newTTFLabelWithShadow({
		text = jiefuData.silver,
		size = 30,
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_haibao,
		align = ui.TEXT_ALIGN_LEFT
		})
		curSilverNum:align(display.LEFT_CENTER, bar:getContentSize().width * 0.66, bar:getContentSize().height / 2)
		bar:addChild(curSilverNum)
	end
end

function jiefuRuleLayer:setJumpFunc(func)
	self.jumpFunc = func
end

return jiefuRuleLayer