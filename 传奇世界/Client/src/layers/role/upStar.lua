return { new = function(superior, params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local MProcessBar = require "src/layers/role/ProcessBar"
local MMenuButton = require "src/component/button/MenuButton"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local protoId = params.protoId
local now = params.attrs[MPackStruct.eAttrStarLevel]
local future = now + 1
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/3.png",
	close = {
		scale = 0.8,
	},
	title = {
		src = "装备升星",
		size = 22,
		color = MColor.yellow,
		offset = { y = -5 },
	},
})

local rootSize = root:getContentSize()

local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
local isUpStarMaterialEnough = true
local buildUpStarMaterialNode = function()
	local info = MequipOp.upStarMaterialNeed(protoId, now)
	local nodes = {}
	for i = 1, #info do
		local cur = info[i]
		local ownNum = bag:countByProtoId(cur.protoId)
		-----------------------------------------------------------------
		local enough = ownNum >= cur.num
		isUpStarMaterialEnough = isUpStarMaterialEnough and enough
		nodes[i] = Mnode.combineNode(
		{
			nodes = 
			{
				Mnode.combineNode(
				{
					nodes = {
						Mnode.createLabel(
						{
							src = ownNum .. "/" .. cur.num,
							size = 20,
						}),
						
						cc.Sprite:create( res .. (enough and "g.png" or "x.png") ),
					},
					
					margins = 10,
				}),
				
				Mnode.createLabel(
				{
					src = MpropOp.name(cur.protoId),
					size = 20,
					color = MpropOp.nameColor(cur.protoId),
				}),
				
				Mprop.new(
				{
					protoId = cur.protoId,
					bg = "res/common/23.png",
					cb = "tips",
				}),
			},
			
			margins = { 0, 10 },
			ori = "|",
		})
	end
	
	return Mnode.combineNode(
	{
		nodes = nodes,
		margins = 40,
	})
end
-----------------------------------------------------------------------
local arrow = cc.Sprite:create("res/group/arrows/3.png")
arrow:setFlippedX(true)

Mnode.overlayNode(
{
	parent = root,
	nodes = 
	{
		{
			node = Mnode.overlayNode(
			{
				parent = cc.Sprite:create(res .. "60.png"),
				nodes = {
					{
						node = Mnode.overlayNode(
						{
							parent = Mprop.new(
							{
								protoId = protoId,
								--bg = "res/common/23.png",
								star = now,
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
						}),
						
						offset = { x = -100, y = 20 },
					},
					
					{
						node = arrow,
					},
					
					{
						node = Mnode.overlayNode(
						{
							parent = Mprop.new(
							{
								protoId = protoId,
								--bg = "res/common/23.png",
								star = future,
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
						}),
						
						offset = { x = 100, y = 20 },
					},
				}
			}),
			
			origin = "t",
			offset = { y = -70, },
		},
		
		{
			node = cc.Sprite:create(res .. "61.png"),
			offset = { x = 0, y = 15 },
		},
		
		{
			node = Mnode.overlayNode(
			{
				parent = Mnode.createScale9Sprite(
				{
					src = res .. "53.png",
					cSize = cc.size(421, 172),
				}),
				
				{
					node = buildUpStarMaterialNode(),
					
					offset = { x= 0, y = 0 },
				},
			}),
			
			origin = "c",
			offset = { y = -95, },
		},
		
		{
			node = MMenuButton.new(
			{
				src = "res/component/button/4.png",
				label = {
					src = "升星",
					size = 20,
				},
				cb = function()
					-- 在此判断升星条件是否具备
					if isUpStarMaterialEnough then
						local MConfirmBox = require "src/functional/ConfirmBox"
						local box = MConfirmBox.new(
						{
							handler = function(box)
								MPackManager:upStarEquip(params.girdId)
								if box then box:removeFromParent() box = nil end
							end,
							
							builder = function(box)
								local cost = MequipOp.upStarCoinNeed(protoId, now)
								return Mnode.createLabel(
								{
									src = "是否花费" .. cost .. "绑定金币提升星级？",
									color = MColor.white,
									size = 20,
								})
							end,
						})
					else
						TIPS( { type = 1 , str = "^c(green)材料不足^" } )
					end
				end,
			}),
			
			origin = "b",
			offset = { y = 10, },
		},
	}
})
-----------------------------------------------------------------------
local onUpgrade = function(observable, event)
	if event ~= "upStar" then return end
	if root then root:removeFromParent() root = nil end
	
	local MupStarSucceed = require "src/layers/role/upStarSucceed"
	local parent = observable:getParent()
	local pos = parent:convertToNodeSpace(g_scrCenter)
	Mnode.addChild(
	{
		parent = parent,
		child = MupStarSucceed.new(observable, params),
		swallow = true,
		pos = pos,
	})
end

root:registerScriptHandler(function(event)
	if event == "enter" then
		superior:listen(onUpgrade)
	elseif event == "exit" then
		superior:nolisten(onUpgrade)
	end
end)
-----------------------------------------------------------------------
return root
end }