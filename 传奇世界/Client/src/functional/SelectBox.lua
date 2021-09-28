return { new = function(params)
----------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
----------------------------------------------------------------
local handler = params.handler or function(box) end
local closer = params.closer or function(box) if box then removeFromParent(box) box = nil end end
local builder = params.builder or function(selector) end
----------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/4.png",
	close = {
		offset = { x = 5, y = 5 },
	},
	title = {
		src = params.title,
		size = 30,
		color = MColor.yellow,
		offset = { y = -5 },
	},
})

local rootSize = root:getContentSize()
----------------------------------------------------------------
local baseboard = cc.Sprite:create("res/common/54.png")
Mnode.addChild(
{
	parent = root,
	child = baseboard,
	pos = cc.p(rootSize.width/2, rootSize.height/2 ),
})

local bbSize = baseboard:getContentSize()

root.baseboard = baseboard
----------------------------------------------------------------
-- 数字选择器
root.addSelector = function(box, config)
	local MSelector = require "src/component/selector/view"
	local selector = MSelector.new(config)
	Mnode.addChild(
	{
		parent = baseboard,
		child = selector:getRootNode(),
		pos = cc.p(bbSize.width/2, 100),
	})
	
	root.selector = selector
end
----------------------------------------------------------------
-- 构建内容信息
local node = builder(root)
if type(node) == "userdata" then
	Mnode.addChild(
	{
		parent = baseboard,
		child = node,
		pos = cc.p(bbSize.width/2, 255),
	})
end
----------------------------------------------------------------
-- 确定按钮
local ConfirmBtn = MMenuButton.new(
{
	src = "res/component/button/5.png",
	--effect = "b2s",
	label = {
		src = "确定",
		size = 22,
		color = MColor.white,
	},
	cb = function() handler(root, root.selector) end,
})

Mnode.addChild(
{
	parent = root,
	child = ConfirmBtn,
	pos = cc.p(466, 38),
})

-- 取消按钮
local CancelBtn = MMenuButton.new(
{
	src = "res/component/button/4.png",
	--effect = "b2s",
	label = {
		src = "取消",
		size = 22,
		color = MColor.white,
	},
	cb = function() closer(root) end,
})

Mnode.addChild(
{
	parent = root,
	child = CancelBtn,
	pos = cc.p(230, 38),
})

Mnode.addChild(
{
	parent = getRunScene(),
	child = root,
	pos = g_scrCenter,
	zOrder = 200,
	swallow = true,
})
----------------------------------------------------------------
return root

end }

