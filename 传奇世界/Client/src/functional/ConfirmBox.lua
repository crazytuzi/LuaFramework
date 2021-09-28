return { new = function(params)
----------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
----------------------------------------------------------------
local tips = params.tips

local title = params.title or game.getStrByKey("tip")

local parent = params.parent or getRunScene()
local parent_size = parent:getContentSize()

local sure_tips = params.sure_tips or game.getStrByKey("sure")
local cancel_tips = params.cancel_tips or game.getStrByKey("cancel")

local handler = params.handler or function(box)
	if tips then removeFromParent(box) end 
end

local closer = params.closer or function(box)
	removeFromParent(box) 
end

local builder = params.builder or function(box)
end
----------------------------------------------------------------
local root = cc.Sprite:create("res/common/bg/bg31.png")
local rootSize = root:getContentSize()
----------------------------------------------------------------
Mnode.createLabel(
{
	src = title,
	parent = root,
	size = 20,
	color = MColor.lable_yellow,
	pos = cc.p(200, 262),
})
----------------------------------------------------------------
-- 确定按钮
local ConfirmBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
	--effect = "b2s",
	label = {
		src = sure_tips,
		size = 22,
		color = MColor.lable_yellow,
	},
	
	cb = function() 
		handler(root)
		--removeFromParent(root)
	end,
})

G_TUTO_NODE:setTouchNode(ConfirmBtn, TOUCH_STRENGTHEN_CONFIRM_YES)

Mnode.addChild(
{
	parent = root,
	child = ConfirmBtn,
	pos = tips and cc.p(rootSize.width/2, 50) or cc.p(300, 50),
})

-- 取消按钮
local CancelBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
	--effect = "b2s",
	label = {
		src = cancel_tips,
		size = 22,
		color = MColor.lable_yellow,
	},
	
	cb = function() 
		closer(root) 
	end,
})

Mnode.addChild(
{
	parent = root,
	child = CancelBtn,
	pos = cc.p(111, 50),
})

if tips then CancelBtn:setVisible(false) end

-- 构建内容信息
local content = builder(root)
if type(content) == "userdata" then
	Mnode.addChild(
	{
		parent = root,
		child = content,
		pos = cc.p(rootSize.width/2, 200),
	})
end

local Manimation = require "src/young/animation"
Manimation:transit(
{
	ref = parent,
	node = root,
	sp = g_scrCenter,
	ep = cc.p(parent_size.width/2, parent_size.height/2),
	--trend = "-",
	curve = "-",
	zOrder = 200,
	swallow = true,
})

G_TUTO_NODE:setShowNode(root, SHOW_STRENGTHEN_CONFIRM)
ConfirmBtn:registerScriptHandler(function(event)
	if event == "enter" then
		G_TUTO_NODE:setShowNode(root, SHOW_STRENGTHEN_CONFIRM)
	elseif event == "exit" then

	end
end)
----------------------------------------------------------------
return root

end }

