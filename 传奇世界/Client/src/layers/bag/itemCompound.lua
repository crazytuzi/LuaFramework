return { new = function()
-------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
-------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -10, y = 4 },
	},
	title = {
		src = "合成",
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

local rootSize = root:getContentSize()
-------------------------------------------------------------
local center = cc.p(rootSize.width/2+2, rootSize.height/2-20)

-- 外边框背景填充图
local frame_width = 6
local bg = cc.Sprite:create("res/common/scalable/panel_outer_base.png", cc.rect(0, 0, 790 - frame_width * 2, 454 - frame_width * 2))
bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)

Mnode.addChild(
{
	parent = root,
	child = bg,
	pos = center,
})

-- 外边框
Mnode.createScale9Sprite(
{
	parent = root,
	src = "res/common/scalable/panel_outer_frame_scale9.png",
	cSize = cc.size(790, 454),
	pos = center,
})

-- 分类背景填充图
local left_bg = Mnode.createScale9Sprite(
{
	parent = root,
	src = "res/common/scalable/panel_inside_scale9.png",
	cSize = cc.size(112, 436),
	pos = cc.p(96, center.y),
})

local left_bg_size = left_bg:getContentSize()

local right_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg80-1.jpg",
	pos = cc.p(486, center.y),
})

local right_bg_size = right_bg:getContentSize()
-------------------------------------------------------------
return root
end }