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
local now = params.attrs[MPackStruct.eAttrQuality]
local past = now - 1

--[[
local incHp = 0
for i=0, past do
	incHp = incHp + MequipOp.upQualityIncHp(protoId, i)
end
]]

local nowQualityInfo = MequipOp.qualityInfo(now)
local pastQualityInfo = MequipOp.qualityInfo(past)
-----------------------------------------------------------------------
local root = MSucceedView.new(res .. "41.png")

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


local buildQualityNode = function(quality, info)
	return Mnode.overlayNode(
	{
		parent = Mprop.new(
		{
			protoId = protoId,
			--bg = "res/common/23.png",
		}),
		
		{
			node = Mnode.createLabel(
			{
				src = MpropOp.name(protoId) .. info.level,
				color = info.color,
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

-- 强化等级上限提升
local strength = buildRecordNode(
{
	{ 
		k = {
			src = "强化上限：",
			size = 22,
			color = MColor.yellow,
		},
		
		v = {
			src = MequipOp.upQualityStrengthUL(protoId, past),
			size = 22,
			color = MColor.white,
		},
	},
	
	{
		v = {
			src = MequipOp.upQualityStrengthUL(protoId, now),
			size = 22,
			color = MColor.green,
		},
	},
})

-- 增加 HP值 提升
local HP = buildRecordNode(
{
	{ 
		k = {
			src = "生命值：",
			size = 22,
			color = MColor.yellow,
		},
		
		v = {
			src = MequipOp.upQualityIncHp(protoId, past),
			size = 22,
			color = MColor.white,
		},
	},
	
	{
		v = {
			src = MequipOp.upQualityIncHp(protoId, now),
			size = 22,
			color = MColor.green,
		},
	},
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
					buildQualityNode(past, pastQualityInfo),
					
					-- 箭头
					arrow,
					
					-- 现在
					buildQualityNode(now, nowQualityInfo),
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
					strength,
					HP,
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