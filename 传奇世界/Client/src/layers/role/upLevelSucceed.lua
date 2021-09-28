return { new = function(superior, params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MSucceedView = require "src/layers/role/SucceedView"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local now = params.protoId
local past = params.oldProtoId

local star = params.attrs[MPackStruct.eAttrStarLevel]
local quality = params.attrs[MPackStruct.eAttrQuality]

local qualityInfo = MequipOp.qualityInfo(quality)
-----------------------------------------------------------------------
local root = MSucceedView.new(res .. "45.png")

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
				
				offset = { x = 25, },
			},
			
			{
				node = Mnode.createLabel(config[2].v),
				origin = "r",
				offset = { x = -10 },
			},
		}
	})
end
-----------------------------------------------------------------------
local arrow = cc.Sprite:create("res/group/arrows/3.png")
arrow:setFlippedX(true)


local buildIconNode = function(protoId)
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
				src = MpropOp.name(protoId) .. qualityInfo.level,
				color = qualityInfo.color,
				size = 18,
			}),
			
			origin = "bo",
			offset = { y = -20, },
		}
	})
end
-----------------------------------------------------------------------
local attr_nodes = {}
-- 属性变化

-- 攻防属性变化

local buildADAttrValue = function(attrName, grid)
	local protoId = MPackStruct.protoIdFromGird(grid)
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	local starLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStarLevel)
	local base = MequipOp.combatAttr(protoId, attrName)
	local growInfo = MequipOp.upStarGrowAttrPair(protoId, starLv)
	local grow = growInfo[attrName]
	local ret = ""
	ret = ret .. base["["] .. "-" .. base["]"]
	ret = ret .. ((grow and strengthLv > 0) and ("(" .. strengthLv * grow["["] .. "-" .. strengthLv * grow["]"] .. ")") or "")
	return ret
end

local i = 5
while i > 0 do
	local base = MequipOp.combatAttr(MPackStruct.protoIdFromGird(params.oldGrid), i)
	if base["["] > 0 or base["]"] > 0 then
		local attr = Mnode.overlayNode(
		{
			parent = buildRecordNode(
			{
				{ 
					k = {
						src = Mconvertor:combatAttr(i) .. "：",
						size = 22,
						color = MColor.yellow,
					},
					
					v = {
						src = buildADAttrValue(i, params.oldGrid),
						size = 22,
						color = MColor.white,
					},
				},
				
				{
					v = {
						src = buildADAttrValue(i, params.grid),
						size = 22,
						color = MColor.green,
					},
				},
			}),
			
			{
				node = cc.Sprite:create(res .. "64.png"),
				zOrder = -1,
			}
		})

		attr_nodes[#attr_nodes+1] = attr
	end
	
	i = i - 1
end

-- 战斗力
local power = Mnode.overlayNode(
{
	parent = buildRecordNode(
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
	}),
	
	{
		node = cc.Sprite:create(res .. "64.png"),
		zOrder = -1,
	}
})

attr_nodes[#attr_nodes+1] = power
---------------------------------------------------------------
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
					buildIconNode(past),
					
					-- 箭头
					arrow,
					
					-- 现在
					buildIconNode(now),
				},
				
				margins = 30,
			}),
			
			origin = "t",
			offset = { y = -60, },
		},
		
		{
			node = Mnode.combineNode(
			{
				nodes = attr_nodes,
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