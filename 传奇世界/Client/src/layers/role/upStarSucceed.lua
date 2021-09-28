return { new = function(superior, params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MSucceedView = require "src/layers/role/SucceedView"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local protoId = params.protoId
local now = params.attrs[MPackStruct.eAttrStarLevel]
local past = now - 1
-----------------------------------------------------------------------
local root = MSucceedView.new(res .. "44.png")
local rootSize = root:getContentSize()

local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
local buildRecordNode = function(config)
	return Mnode.overlayNode(
	{
		parent = Mnode.createNode({ cSize = cc.size(480, 48) }),
		nodes = 
		{
			{
				node = Mnode.createKVP(
				{
					k = Mnode.createLabel(config[1].k),
					
					v = config[1].v,
				}),
				
				origin = "l",
				offset = { x = 10 },
			},
			
			{
				node = cc.Sprite:create("res/group/arrows/4.png"),
			},
			
			{
				node = Mnode.createKVP(
				{
					k = Mnode.createLabel(config[1].k),
					
					v = config[2].v,
				}),
				
				origin = "r",
				offset = { x = -10 },
			},
		}
	})
end
-----------------------------------------------------------------------
local arrow = cc.Sprite:create("res/group/arrows/3.png")
arrow:setFlippedX(true)


local buildStarNode = function(star)
	return Mnode.overlayNode(
	{
		parent = Mprop.new(
		{
			protoId = protoId,
			--bg = "res/common/23.png",
			star = star,
		}),
		
		{
			node = Mnode.createLabel(
			{
				src = MpropOp.name(protoId),
				color = MpropOp.nameColor(protoId),
				size = 18,
			}),
			
			origin = "bo",
			offset = { y = -20, },
		}
	})
end
-----------------------------------------------------------------------
-- 属性变化
-- 战斗力
local power = buildRecordNode(
{
	{ 
		k = {
			src = "战斗力：",
			size = 22,
			color = MColor.yellow,
		},
		
		v = {
			src = params.oldPower,
			size = 22,
			color = MColor.white,
		},
	},
	
	{
		v = {
			src = params.attrs[MPackStruct.eAttrCombatPower],
			size = 22,
			color = MColor.green,
		},
	},
})

Mnode.overlayNode(
{
	parent = power,
	{
		node = cc.Sprite:create(res .. "64.png"),
		zOrder = -1,
	}
})

Mnode.overlayNode(
{
	parent = root,
	nodes = 
	{
		{
			node = Mnode.combineNode(
			{
				nodes = {
					-- 过去
					buildStarNode(past),
					
					-- 箭头
					arrow,
					
					-- 现在
					buildStarNode(now),
				},
				
				margins = 30,
			}),
			
			origin = "t",
			offset = { y = -60, },
		},
		
		{
			node = Mnode.combineNode(
			{
				nodes = 
				{
					power,
				},
				
				ori = "|",
				margins = 0,
			}),
			
			origin = "b",
			offset = { y = 35, },
		},
	}
})
-----------------------------------------------------------------------

-----------------------------------------------------------------------
return root
end }