return { new = function(parent,info,focus_index,param)
-----------------------------------------------------------------------
local Mnode = require "src/young/node"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local MPackManager = require "src/layers/bag/PackManager"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local root = cc.Layer:create()
root:setContentSize(cc.size(960,640))
if parent then
	parent:addChild(root)
end

local rootSize = root:getContentSize()
--dump(rootSize, "rootSize")
local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
-- local bg = Mnode.createSprite(
-- {
-- 	src = "res/common/bg/bg.png",
-- 	parent = root,
-- 	pos = cc.p(rootSize.width/2, rootSize.height/2-30),
-- })

-- local bg_size = bg:getContentSize()

local bg_frame = Mnode.createNode(
{
	--src = "res/common/bg/bg-6.png",
	parent = root,
	pos = cc.p(rootSize.width/2, rootSize.height/2-30),
    cSize = cc.size(930, 535),
})

local bg_frame_size = bg_frame:getContentSize()

local left_bg_size = cc.size(115,500)
local left_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(28, 40),
        left_bg_size,
        5
    )
-- Mnode.createSprite(
-- {
-- 	parent = bg_frame,
-- 	src = "res/common/bg/buttonBg6.png",
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(17, bg_frame_size.height/2),
-- })
-- local left_bg_size = left_bg:getContentSize()

local right_bg = Mnode.createSprite(
{
	parent = bg_frame,
	src = "res/common/bg/bg63.jpg",
	anchor = cc.p(1, 0.5),
	pos = cc.p(bg_frame_size.width-17, bg_frame_size.height/2),
})
local right_bg_size = right_bg:getContentSize()
-----------------------------------------------------------------------
switchLeftView = function(this, node)
	local content = right_bg:getChildByTag(1)
	if content then removeFromParent(content) end
	
	Mnode.addChild(
	{
		parent = right_bg,
		child = node,
		anchor = cc.p(0, 0.5),
		pos = cc.p(0, right_bg_size.height/2),
		tag = 1,
		zOrder = 1,
	})
end

switchRightView = function(this, node)
	local content = right_bg:getChildByTag(2)
	if content then removeFromParent(content) end
	
	Mnode.addChild(
	{
		parent = right_bg,
		child = node,
		anchor = cc.p(1, 0.5),
		pos = cc.p(right_bg_size.width-5, right_bg_size.height/2),
		tag = 2,
		zOrder = 2,
	})
end

local buildBeauty = function()
	local rightNode = require("src/layers/beautyWoman/BeautyLeftNode").new()
	local leftNode = require("src/layers/beautyWoman/BeautyRightNode").new()

	root:switchLeftView(leftNode)
	root:switchRightView(rightNode)
end

local buildWing = function()
	
	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_WING ) and G_WING_INFO.id ~= nil then
		local rightNode = require("src/layers/wingAndRiding/WingAndRidingLeftNode").new(root, 1, nil, nil, param)
		local leftNode = require("src/layers/wingAndRiding/WingAndRidingRightNode").new(root, 1, nil, nil, param)

		root:switchLeftView(leftNode)
		root:switchRightView(rightNode)
	else
		right_bg:removeChildByTag(1)
		right_bg:removeChildByTag(2)
		-- if G_WING_INFO.id == nil then
		-- 	MessageBox(string.format(game.getStrByKey("wr_wing_noWingTip"),getConfigItemByKey("NewFunctionCfg", "q_ID", 2).q_level), "")
		-- end
		local emptyBg=createSprite(right_bg, "res/common/bg/bg79.jpg", cc.p(right_bg_size.width/2, right_bg_size.height/2), cc.p(0.5, 0.5))
		emptyBg:setTag(1)
		createLabel(emptyBg, string.format(game.getStrByKey("func_opentips_wing"),40),cc.p(emptyBg:getContentSize().width/2,28), cc.p(0.5,0.5), 22, true,0, nil,MColor.lable_yellow)
	end
end

local buildHorse = function()
	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) and G_RIDING_INFO.id ~= nil and #G_RIDING_INFO.id ~= 0 then
		local rightNode = require("src/layers/wingAndRiding/RidingLeftNode").new(root)
		local leftNode = require("src/layers/wingAndRiding/RidingRightNode").new(root)

		root:switchLeftView(leftNode)
		root:switchRightView(rightNode)
	else
		right_bg:removeChildByTag(1)
		right_bg:removeChildByTag(2)
		-- if G_RIDING_INFO.id == nil or #G_RIDING_INFO.id == 0 then
		-- 	MessageBox(string.format(game.getStrByKey("wr_riding_noRidingTip"),getConfigItemByKey("NewFunctionCfg", "q_ID", 1).q_level), "")
		-- end
		local emptyBg=createSprite(right_bg, "res/common/bg/bg79-1.jpg", cc.p(right_bg_size.width/2, right_bg_size.height/2), cc.p(0.5, 0.5))
		emptyBg:setTag(1)
		createLabel(emptyBg, string.format(game.getStrByKey("func_opentips_ride"),15),cc.p(emptyBg:getContentSize().width/2,28), cc.p(0.5,0.5), 22, true,0, nil,MColor.lable_yellow)
	end
end

local buildDress = function()
	local MroleInfo = require("src/layers/role/roleInfo")
	local MdressView = require "src/layers/role/dressView"
	
	root:switchLeftView(MdressView.new())
	root:switchRightView(MroleInfo.new())
end

--------------------------------------------------------------------------------------
-- 创建选项卡
local juese = game.getStrByKey("role")
local zuoqi = game.getStrByKey("horse")
local xianyi = game.getStrByKey("wing")
local meiren = game.getStrByKey("beauty")

local config = {
	[juese] = {
		action = buildDress,
	},
	
	[zuoqi] = {
		action = buildHorse,
	},
	
	[xianyi] = {
		action = buildWing,
	},

	[meiren] = {
		action = buildBeauty,
	},
}

local tabs = {}
dump(G_VIP_INFO)
tabs[#tabs+1] = nil--not not (G_VIP_INFO.vipLevel>0) and meiren or nil
--if G_CONTROL:isFuncOn( GAME_SWITCH_ID_WING ) then
	tabs[#tabs+1] =xianyi -- not not G_WING_INFO.id and xianyi or nil
--end
--if G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) then
	tabs[#tabs+1] =zuoqi-- not not (#G_RIDING_INFO.id>0) and zuoqi or nil
--end
tabs[#tabs+1] = juese

local arrows = cc.MenuItemImage:create("res/group/arrows/9.png", "")
	
local TabControl = Mnode.createTabControl(
{
	src = {"res/component/TabControl/9.png", "res/component/TabControl/10.png"},
	color = {MColor.lable_yellow, MColor.lable_yellow},
	size = 25,
	titles = tabs,
	margins = 5,
	ori = "|",
	cb = function(node, tag)
		local x, y = node:getPosition()
		local size = node:getContentSize()
		arrows:setPosition(x+size.width/2+6, y)
		config[tabs[tag]].action()
	end,
	selected = juese,
})
G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(zuoqi), TOUCH_ROLE_RIDE)
G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(xianyi), TOUCH_ROLE_WING)

TabControl:addChild(arrows)

local chose
if focus_index == 2 then
	chose = zuoqi
elseif focus_index == 3 then
	chose = xianyi
elseif focus_index == 4 then	
	chose = meiren
end
dump(chose)
if chose then
	TabControl:focus(chose)
end

Mnode.addChild(
{
	parent = left_bg,
	child = TabControl,
	anchor = cc.p(0.5, 1),
	pos = cc.p(left_bg_size.width/2, left_bg_size.height-10),
})
-----------------------------------------------------------------------

root:registerScriptHandler(function(event)
	if event == "enter" then
		G_WR_ADVANCE_INFO = {}
	elseif event == "exit" then
		--G_TUTO_NODE:setShowNode(root, SHOW_MAIN)
	end
end)

-----------------------------------------------------------------------
return root
end }