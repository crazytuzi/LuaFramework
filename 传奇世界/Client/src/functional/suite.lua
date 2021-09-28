local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
require "src/young/node"


createTooltip = function(self, params)
	-- 提示信息
	local MMenuButton = require "src/component/button/MenuButton"
	local params = params or {}
	local cSize = params.cSize or cc.size(200, 34)
	local text = params.text or "请设置标题"
	local n_tips = 
	--[[
	Mnode.createColorLayer(
	{
		--src = cc.c4b(0 ,0 ,0, 0),
		src = cc.c4b(139, 125, 107, 255*0.95),
		cSize = cSize,
		--opacity = 0,
	})
	--]]
	
	---[[
	Mnode.createScale9Sprite(
	{
		src = "res/common/scalable/2.png",
		cSize = cSize,
		opacity = 255*0.75,
	})
	--]]
	

	local n_tips_size = n_tips:getContentSize()

	local n_str = Mnode.createLabel(
	{
		src = text,
		parent = n_tips,
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(n_tips_size.width/2, n_tips_size.height/2),
	})

	local duration = 0.25
	local DelayTime = cc.DelayTime:create(3)
	local FadeOut = cc.FadeOut:create(duration)
	local func = cc.CallFunc:create(function(node)
		node:removeFromParent()
	end)
	local final = cc.Sequence:create(DelayTime, FadeOut, func)
	n_tips:runAction(final)
	
	return n_tips
end