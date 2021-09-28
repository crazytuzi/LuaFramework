return { new = function(params)
----------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
----------------------------------------------------------------
local params = params or {}
local handler = params.handler or function() end
local builder = params.builder or function() end
local title = params.title or "未设置"
local config = params.config or { sp = 1, ep = 1, cur = 1 }
local onValueChanged = params.onValueChanged or function() end
local parent = params.parent or getRunScene()
local parent_size = parent:getContentSize()
local tag = params.tag
----------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg27.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -5, y = 5 },
	},
	title = {
		src = params.title,
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

local rootSize = root:getContentSize()
----------------------------------------------------------------
-- local bd = cc.Sprite:create("res/common/bg/bg27.png")
local bd = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(15, 100),
        cc.size(370,374),
        5
    )
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = bd,
-- 	pos = cc.p(rootSize.width/2, rootSize.height/2 + 20),
-- })

local bbSize = bd:getContentSize()

root.bd = bd
----------------------------------------------------------------
root.buildPropName = function(this, grid, bind)
	local MpropOp = require "src/config/propOp"
	local protoId = MPackStruct.protoIdFromGird(grid)
	
	-- 是否绑定
	local isBind = nil
	if bind ~= nil then
		isBind = bind
	else
		isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	end
	
	local parent = this.bd
	local cSize = parent:getContentSize()
					
	local title_bd = Mnode.createSprite(
	{
		parent = parent,
		src = "res/common/bg/bg27-3.png",
		pos = cc.p(cSize.width/2, 344),
	})
	
	local title_bd_size = title_bd:getContentSize()
	
	-- 物品名字
	Mnode.createLabel(
	{
		parent = title_bd,
		src = MpropOp.name(protoId),
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(20, title_bd_size.height/2),
		size = 20,
	})
	
	-- 是否绑定
	Mnode.createLabel(
	{
		parent = title_bd,
		src = isBind and (game.getStrByKey("already")..game.getStrByKey("theBind")) or (game.getStrByKey("not")..game.getStrByKey("theBind")),
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(210, title_bd_size.height/2),
		size = 20,
	})
	
	-- 物品等级
	Mnode.createLabel(
	{
		parent = title_bd,
		src = "LV."..tostring(MpropOp.levelLimits(protoId)),
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(285, title_bd_size.height/2),
		size = 20,
	})
end
----------------------------------------------------------------
-- 构建用户添加的内容信息
local node = builder(root, bd)
----------------------------------------------------------------
-- 分隔线
Mnode.createSprite(
{
	src = "res/common/bg/bg27-2.png",
	parent = bd,
	pos = cc.p(bbSize.width/2, bbSize.height/2),
})

local selector = Mnode.createSelector(
{
	config = config,
	onValueChanged = function(selector, value)
		onValueChanged(root, value)
	end,
})

selector:setScale(0.9)

Mnode.addChild(
{
	parent = bd,
	child = selector,
	pos = cc.p(bbSize.width/2, 116),
})

-- 选择范围
Mnode.createLabel(
{
	parent = bd,
	src = game.getStrByKey("input")..game.getStrByKey("range").."：" .. config.sp .. "-" .. config.ep,
	anchor = cc.p(0, 0.5),
	pos = cc.p(14, 30),
	color = MColor.lable_yellow,
	size = 20,
})
----------------------------------------------------------------
-- 确定按钮
local ConfirmBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
	label = {
		src = game.getStrByKey("sure"),
		size = 22,
		color = MColor.lable_yellow,
	},
	cb = function() handler(root, selector:value()) end,
})

Mnode.addChild(
{
	parent = root,
	child = ConfirmBtn,
	pos = cc.p(295, 50),
})

-- 最大按钮
local CancelBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
	label = {
		src = "最大",
		size = 22,
		color = MColor.lable_yellow,
	},
	cb = function()
		selector:setToMax()
	end,
})

Mnode.addChild(
{
	parent = root,
	child = CancelBtn,
	pos = cc.p(109, 50),
})

Manimation:transit(
{
	ref = parent,
	node = root,
	zOrder = 200,
	swallow = true,
	ep = cc.p(parent_size.width/2, parent_size.height/2),
	tag = tag,
})
----------------------------------------------------------------
return root

end }