return { new = function(parent,params,focus_index)
-----------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
-----------------------------------------------------------------------
local params = params or {}
--local role = params.role or MRoleStruct:getAttr(ROLE_NAME)
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local root = cc.Layer:create()
root:setContentSize(cc.size(960,640))

if parent then
	parent:addChild(root)
	local icon = tolua.cast(parent:getChildByTag(2),"cc.Sprite")
	if icon then icon:setTexture(res .. "icon.png") end
	local name = tolua.cast(parent:getChildByTag(1),"cc.Sprite")
	if name then name:setTexture(res .. "label.png") end
end

local M = Mnode.beginNode(root)
local rootSize = root:getContentSize()
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

local buildWing = function()
	local info = params
	--if not info then return end
	
	local wingId = info[PLAYER_EQUIP_WING]
	if wingId == 0 then
		MessageBox(game.getStrByKey("wr_wing_roleNoWingTip"), "")
		return
	end
	
	local otherRoleData = {}
	otherRoleData.school = info[ROLE_SCHOOL]
	otherRoleData.wing = {}
	otherRoleData.wing.id = wingId
	--otherRoleData.wingInfo.skillCount = #info.wing
	otherRoleData.wing.skillTab = info.wing.skillTab
	dump(otherRoleData, "otherRoleData")
	local rightNode = require("src/layers/wingAndRiding/WingAndRidingLeftNode").new(root, 1, nil, otherRoleData)
	local leftNode = require("src/layers/wingAndRiding/WingAndRidingRightNode").new(root, 1, nil, otherRoleData)

	root:switchLeftView(leftNode)
	root:switchRightView(rightNode)
end

local buildHorse = function()
	local info = params
	--if not info then return end
	
	local horseId = info[PLAYER_EQUIP_RIDE]
	
	if horseId == 0 then
		MessageBox(game.getStrByKey("wr_riding_roleNoRidingTip"), "")
		return
	end
	
	local otherRoleData = {}
	otherRoleData.ridingInfo = info.horse
	dump(otherRoleData, "otherRoleData")

	local rightNode = require("src/layers/wingAndRiding/RidingLeftNode").new(root, otherRoleData)
	local leftNode = require("src/layers/wingAndRiding/RidingRightNode").new(root, otherRoleData)

	root:switchLeftView(leftNode)
	root:switchRightView(rightNode)
end

local buildDress = function()
	local info = params
	--if not info then return end
	
	local MroleInfo = require("src/layers/role/roleInfo")
	local MdressView = require "src/layers/role/dressViewStatic"
	
	root:switchLeftView(MdressView.new(info))
	root:switchRightView( MroleInfo.new({ datasource = info, static = true }) )
end

-- 创建选项卡
local juese = game.getStrByKey("role")
local zuoqi = game.getStrByKey("horse")
local xianyi = game.getStrByKey("wing")

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
}

local tabs = {}
if G_CONTROL:isFuncOn( GAME_SWITCH_ID_WING ) then
	tabs[#tabs+1] = params[PLAYER_EQUIP_WING] ~= 0 and xianyi or nil
end
if G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) then
	tabs[#tabs+1] = params[PLAYER_EQUIP_RIDE] ~= 0 and zuoqi or nil
end
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

TabControl:addChild(arrows)

Mnode.addChild(
{
	parent = left_bg,
	child = TabControl,
	anchor = cc.p(0.5, 1),
	pos = cc.p(left_bg_size.width/2, left_bg_size.height-10),
})
-----------------------------------------------------------------------
return root
end }