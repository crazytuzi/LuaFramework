return { new = function(superior, params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local MProcessBar = require "src/layers/role/ProcessBar"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local protoId = params.protoId
local star = params.attrs[MPackStruct.eAttrStarLevel]
local quality = params.attrs[MPackStruct.eAttrQuality]
local qualityInfo = MequipOp.qualityInfo(quality)
local strengthLvUpper = MequipOp.upQualityStrengthUL(protoId, quality)

local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local PropIcon = Mprop.new(
{
	protoId = protoId,
	--bg = "res/common/23.png",
	star = star,
})
-----------------------------------------------------------------------	
-- 强化是否已经达到上限
local isStrengthenRUL = function()
	return params.attrs[MPackStruct.eAttrStrengthLevel] >= strengthLvUpper
end
-----------------------------------------------------------------------
local materialNodes = {}
local changeRemainNum1 = function()
	for i, v in ipairs(materialNodes) do
		v.own:setString("剩余" .. bag:countByProtoId(v.material.protoId) .. "个")
	end
end

local changeRemainNum2 = function(node, num)
	node.own:setString("剩余" .. num .. "个")
end

local stopTiming = function(node)
	local action = node:getActionByTag(2)
	if action then node:stopAction(action) end
end

local consumeInfo = function()
	local cur = 0
	local post = {}
	for i, v in ipairs(materialNodes) do
		local material = v.material
		local use = v.use
		cur = cur + use * material.effect
		if use > 0 then
			local item = {}
			item.protoId = material.protoId
			item.num = use
			post[#post + 1] = item
		end
	end
	
	return cur, post
end

local curInfo = function()
	local attrs = params.attrs
	local level = attrs[MPackStruct.eAttrStrengthLevel]
	local exp = attrs[MPackStruct.eAttrStrengthExp]
	local protoId = params.protoId
	local upgradeExp = MequipOp.upStrengthExpNeed(protoId, level)
	return level, exp, upgradeExp
end
-----------------------------------------------------------------------
local root = nil

local closeHandler = function()
	local cur, post = consumeInfo()
	if cur > 0 then MPackManager:upStrengthEquip(params.girdId, post) end
	if root then removeFromParent(root) root = nil end
end

root = Mbaseboard.new(
{
	src = "res/common/3-1.png",
	close = {
		scale = 0.8,
		handler = closeHandler,
	},
	title = {
		src = "装备强化",
		size = 22,
		color = MColor.yellow,
		offset = { y = -5 },
	},
})
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_STRENGTHEN_CLOSE)

local rootSize = root:getContentSize()

local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
local strengthExp = MProcessBar.new(
{
	bg = res .. "58.png",
	bar = res .. "59.png",
})

strengthExp.refresh = function(self, exp)
	local attrs = params.attrs
	local level = attrs[MPackStruct.eAttrStrengthLevel]
	local exp = exp or attrs[MPackStruct.eAttrStrengthExp]
	local upgradeExp = MequipOp.upStrengthExpNeed(protoId, level)

	strengthExp:setProgress(
	{
		cur = exp,
		max = MequipOp.isStrengthRUL(protoId, level) and 1 or upgradeExp,
	})
end; strengthExp:refresh()
-----------------------------------------------------------------------
local upgradeCheck = function(node)
	local level, exp, upgradeExp = curInfo()
	local cur, post = consumeInfo()
	
	if cur >=  upgradeExp - exp then
		MPackManager:upStrengthEquip(params.girdId, post)
		
		for i, v in ipairs(materialNodes) do
			v.use = 0
		end
		
		if not isStrengthenRUL() then
			-- 播放升级特效
			local effectNode = Effects:create(false) -- true -> 自动clean
			effectNode:playActionData("equipstreng", 7, 1, 1)
			performWithDelay(effectNode,function() removeFromParent(effectNode) effectNode = nil end,1.0)
			Mnode.overlayNode(
			{
				parent = PropIcon,
				{
					node = effectNode,
					zOrder = 100,
				}
			})
			
			return true
		else
			return false
		end
	else
		strengthExp:refresh(exp + cur)
		return false
	end
end

local onClick = function(node)

	local level, exp, upgradeExp = curInfo()
	
	-- 检测是否达到该品阶的最大强化等级
	if isStrengthenRUL() and exp == upgradeExp then
		dump("已经达到强化极限")
		return false
	end
				
	-- 检测背包中是否还有消耗材料
	local holding = bag:countByProtoId(node.material.protoId)
	if holding <= node.use then
		dump("该种材料不足")
		return false
	end
	
	-- 使用该材料(数量为1)
	node.use = node.use + 1

	-- 剩余数量减少1
	changeRemainNum2(node, holding - node.use)
	
	-- 播放使用特效
	local effectNode = Effects:create(false) -- true -> 自动clean
	performWithDelay(effectNode,function() removeFromParent(effectNode) effect = effectNode end,1)
	effectNode:playActionData("equipuplv", 11, 1.2, 1)
	Mnode.overlayNode(
	{
		parent = PropIcon,
		{
			node = effectNode,
			zOrder = 99,
		}
	})
	
	return true
end

local timeout = function(node)
		
	local result = onClick(node)
	if result then
		upgradeCheck(node)
	else
		stopTiming(node)
	end
	
end

local buildUpStrengthMaterialNode = function(params)
	local ret = nil
	
	local info = MequipOp.upStrengthMaterialNeed(quality)
	local nodes = {}
	for i = 1, #info do
		local cur = info[i]
		local bg = cc.Sprite:create( MpropOp.border(cur.protoId) )
		materialNodes[i] = bg
		
		local own = Mnode.createLabel(
		{
			src = "剩余" .. bag:countByProtoId(cur.protoId) .. "个",
			size = 20,
		})
		
		bg.own = own
		bg.material = cur
		bg.use = 0
		
		if i == 1 then
			G_TUTO_NODE:setTouchNode(bg, TOUCH_STRENGTHEN_USE_1)
		elseif i == 2 then
			G_TUTO_NODE:setTouchNode(bg, TOUCH_STRENGTHEN_USE_2)
		elseif i == 3 then
			G_TUTO_NODE:setTouchNode(bg, TOUCH_STRENGTHEN_USE_3)
		end

		Mnode.listenTouchEvent(
		{
			node = bg,
			swallow = false,
			
			begin = function(touch, event)
			
				-- 已经有一种强化石正在使用中
				if ret.catch then return false end
				
				-- 检测触摸区域
				local node = event:getCurrentTarget()
				local touchOutside = not Mnode.isTouchInNodeAABB(node, touch)
				if touchOutside then return false end
				
				-- 检测能否使用该材料
				local result = onClick(node)
				if not result then return false end
				
				-- 升级检测
				upgradeCheck(node)
				
				ret.catch = touch
				
				-- 处理按住事件
				local sequence = cc.Sequence:create( cc.DelayTime:create(0.2), cc.CallFunc:create(timeout) )
				local forever = cc.RepeatForever:create(sequence)
				forever:setTag(2)
				node:runAction(forever)
				
				return true
			end,
			
			moved = function(touch, event)
				if touch == ret.catch then
					local node = event:getCurrentTarget()
					local touchOutside = not Mnode.isTouchInNodeAABB(node, touch)
					if touchOutside then stopTiming(node) end
				end
			end,
			
			ended = function(touch, event)
				if touch == ret.catch then
					local node = event:getCurrentTarget()
					
					stopTiming(node)
					
					ret.catch = nil
					
					-- 升级检测
					upgradeCheck(node)
				end
			end
		})
		
		-----------------------------------------------------------------
		nodes[i] = Mnode.overlayNode(
		{
			parent = bg,
			nodes = 
			{
				-- 背景
				{
					node = cc.Sprite:create("res/common/23.png"),
					zOrder = -2,
				},
				
				-- 原型
				{
					node = cc.Sprite:create( MpropOp.icon(cur.protoId) ),
					zOrder = -1,
				},
				
				-- 名字
				{
					node = Mnode.createLabel(
					{
						src = MpropOp.name(cur.protoId),
						size = 20,
						color = MpropOp.nameColor(cur.protoId),
					}),
					
					origin = "bo",
					offset = { y = -5, },
				},
				
				-- 剩余
				{
					node = own,
					origin = "bo",
					offset = { y = -30, },
				},
			},
		})
	end
	
	ret = Mnode.combineNode(
	{
		nodes = nodes,
		margins = 58,
	})
	
	return ret
end

-- 物品图标底板
local IconBaseboard = Mnode.createScale9Sprite(
{
	src = res .. "53.png",
	cSize = cc.size(421, 110),
})

local bSize = IconBaseboard:getContentSize()

-- 物品图标
Mnode.addChild(
{
	parent = IconBaseboard,
	child = PropIcon,
	pos = cc.p(50, bSize.height/2 + 5),
})

-- 物品名字
Mnode.addChild(
{
	parent = IconBaseboard,
	child = Mnode.createLabel(
	{
		src = MpropOp.name(protoId) .. qualityInfo.level,
		color = qualityInfo.color,
		size = 20,
	}),
	
	anchor = cc.p(0, 0.5),
	pos = cc.p(105, 78),
})

-- 强化等级和强化上限
local strengthLv = Mnode.createLabel(
{
	src = "",
	color = MColor.green,
	size = 20,
})

strengthLv.refresh = function(self)
	local level = params.attrs[MPackStruct.eAttrStrengthLevel]
	
	self:setString(level .. "/" .. strengthLvUpper)
end

strengthLv:refresh()

Mnode.addChild(
{
	parent = IconBaseboard,
	child = strengthLv,
	anchor = cc.p(0, 0.5),
	pos = cc.p(300, 78),
})

Mnode.overlayNode(
{
	parent = root,
	
	nodes = {
		-- 物品图标
		{
			node = IconBaseboard,
			origin = "t",
			offset = { y = -75 },
		},
		
		-- 进度条
		{
			node = strengthExp,
			offset = { y = 35 },
		},
		
		-- 强化石选择提示
		{
			node = cc.Sprite:create(res .. "65.png"),
			offset = { y = -10 },
		},
		
		-- 所需消耗的材料
		{
			node = Mnode.overlayNode(
			{
				parent = Mnode.createScale9Sprite(
				{
					src = res .. "53.png",
					cSize = cc.size(421, 172),
				}),
				
				{
					node = buildUpStrengthMaterialNode(),
					offset = { y = 25, },
				},
			}),
			
			origin = "b",
			offset = { y = 50 },
		},
	},
})
-----------------------------------------------------------------------
local onUpgrade = function(observable, event)
	if event ~= "upStrength" then return end
	
	--local level, exp, upgradeExp = curInfo()
	--local cur, post = consumeInfo()
	
	strengthExp:refresh()
	strengthLv:refresh()
	
	changeRemainNum1()
end

root:registerScriptHandler(function(event)
	if event == "enter" then
		superior:listen(onUpgrade)
		G_TUTO_NODE:setShowNode(root, SHOW_STRENGTHEN)
	elseif event == "exit" then
		superior:nolisten(onUpgrade)
	end
end)
-----------------------------------------------------------------------
return root
end }