return { new = function(params)
-----------------------------------------------------------------------
local Mnode = require "src/young/node"
local MColor = require "src/config/FontColor"
local Mconvertor = require "src/config/convertor"
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MPackStruct = require "src/layers/bag/PackStruct"
local MPackManager = require "src/layers/bag/PackManager"
-----------------------------------------------------------------------
local res = "res/rolebag/role/"
-----------------------------------------------------------------------
local root = cc.Sprite:create("res/rolebag/role/28.png")
-----------------------------------------------------------------------
local pack = MPackManager:getPack(params.packId)
local info = pack:girdInfo(params.girdId, {
	MPackStruct.eAttrQuality,
	MPackStruct.eAttrStrengthLevel,
	--MPackStruct.eAttrStrengthExp,
	MPackStruct.eAttrStarLevel,
	MPackStruct.eAttrBind,
})
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- 装备名字
local nameBg = cc.Sprite:create("res/rolebag/role/29.png")
local nameBgSize = nameBg:getContentSize()

local nameNode = Mnode.createLabel(
{
	src = "",
	size = 22,
})

Mnode.addChild({
	parent = nameBg,
	child = nameNode,
	pos = cc.p(nameBgSize.width/2, nameBgSize.height/2),
})

local updateName = function()
	local name = MpropOp.name(info.protoId)
	local qualityLevel = info.attrs[MPackStruct.eAttrQuality]
	local qualityInfo = MequipOp.qualityInfo(qualityLevel)
	nameNode:setString(name .. qualityInfo.level)
	nameNode:setColor(qualityInfo.color)
end; updateName()
-----------------------------------------------------------------------
-- 战斗力
local combatPower = Mnode.createKVP({
	k = cc.Sprite:create(res .. "30.png"),
	v = {
		src = "000000000",
		color = MColor.yellow,
		size = 20,
	},
	margin = 5,
})

local gird = pack:getGirdByGirdId(params.girdId)
--dump(gird, "gird")
combatPower:setValue( MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower) )

Mnode.addChild({
	parent = root,
	child = combatPower,
	pos = cc.p(100, 425),
})
-----------------------------------------------------------------------
-- 强化等级
local strengthNode = Mnode.createKVP({
	k = cc.Sprite:create(res .. "31.png"),
	v = {
		src = "000000000",
		color = MColor.yellow,
		size = 20,
	},
	margin = 5,
})

strengthNode:setValue(info.attrs[MPackStruct.eAttrStrengthLevel])

Mnode.addChild({
	parent = root,
	child = strengthNode,
	pos = cc.p(260, 425),
})
-----------------------------------------------------------------------
-- 着装位置
local equipId = MequipOp.kind(info.protoId)
local isBind = info.attrs[MPackStruct.eAttrBind]

local dressInfo = Mnode.createKVP({
	k = Mnode.createLabel({
		src = Mconvertor:equipName(equipId) .. "：",
		size = 20,
	}),
	v = {
		src = isBind and "已绑定" or "未绑定",
		size = 20,
		color = isBind and MColor.red or MColor.green,
	},
})

-- 佩戴职业
local jobNode = Mnode.createKVP({
	k = Mnode.createLabel({
		src = "职业：",
		size = 20,
	}),
	v = {
		src = "战士",
		size = 20,
		color = MColor.yellow,
	},
})
local schoolLimits = MpropOp.schoolLimits(info.protoId)
jobNode:setValue( Mconvertor:school(schoolLimits) )

-- 等级
local levelNode = Mnode.createKVP({
	k = Mnode.createLabel({
		src = "等级：",
		size = 20,
	}),
	v = {
		src = "000000",
		size = 20,
		color = MColor.yellow,
	},
})

levelNode:setValue( MpropOp.levelLimits(info.protoId) )


Mnode.addChild({
	parent = root,
	child = Mnode.combineNode({
		nodes = 
		{
			levelNode,
			jobNode,
			dressInfo,
		},
		ori = "|",
		margins = 7,
		align = "l",
	}),
	pos = cc.p(94, 345),
})

-- 装备icon
local iconNode = require("src/layers/role/equipIcon").new({
	protoId = info.protoId,
	starLevel = info.attrs[MPackStruct.eAttrStarLevel],
})

Mnode.addChild({
	parent = root,
	child = iconNode,
	pos = cc.p(248, 345),
})

-- 出售价格
local sellPriceNode = Mnode.createKVP({
	k = Mnode.createLabel({
		src = "出售价格：",
		size = 20,
	}),
	v = {
		src = "000000000",
		size = 20,
		HAlign = cc.TEXT_ALIGNMENT_RIGHT,
	},
})
sellPriceNode:setValue( MpropOp.recyclePrice(info.protoId) )
-----------------------------------------------------------------------
-- 攻防属性
local buildADAttrNode = function(attrName, strengthLv, growInfo)
	local base = MequipOp.combatAttr(info.protoId, attrName)
	local name = Mconvertor:combatAttr(attrName)
	local grow = growInfo[attrName]
	
	return Mnode.combineNode(
	{
		nodes = 
		{
			[1] = Mnode.createLabel(
			{
				src = name,
				size = 20,
			}),
			
			[2] = Mnode.createLabel(
			{
				src = base["["] .. "-" .. base["]"],
				size = 20,
			}),
			
			[3] = grow and Mnode.createLabel(
			{
				src = "(" .. strengthLv * grow["["] .. "-" .. strengthLv * grow["]"] .. ")",
				size = 20,
				color = MColor.green,
			}) or nil,
		},
		margins = 15,
	})
	
end

local buildAttrsInfo = function()
	local content = root:getChildByTag(1)
	if content then removeFromParent(content) end
	
	local growInfo = MequipOp.upStarGrowAttrPair(info.protoId, info.attrs[MPackStruct.eAttrStarLevel])
	local strengthLv = info.attrs[MPackStruct.eAttrStrengthLevel]
	
	local nodes = {}
	
	local i = 5
	while i > 0 do
		nodes[#nodes + 1] = buildADAttrNode(i, strengthLv, growInfo)
		i = i - 1
	end
	
	Mnode.addChild({
		parent = root,
		child = Mnode.combineNode(
		{
			nodes = nodes,
			margins = 7,
			ori = "|",
			align = "l",
		}),
		anchor = cc.p(0, 1),
		pos = cc.p(36, 278),
		tag = 1,
	})
end; buildAttrsInfo()
-----------------------------------------------------------------------
Mnode.overlayNode({
	parent = root,
	nodes = 
	{
		{
			node = nameBg,
			origin = "t",
			offset = { y = -10, },
		},
		
		{
			node = Mnode.combineNode({
				nodes = 
				{
					sellPriceNode,
					cc.Sprite:create("res/mainui/12.png"),
				},
				margins = 5,
			}),
			origin = "b",
			offset = { x = -10, y = 20, },
		},
	},
})
-----------------------------------------------------------------------
local updateUpQualityArea = function()
	updateName()
end

local updateUpStrengthArea = function()
	strengthNode:setValue(info.attrs[MPackStruct.eAttrStrengthLevel])
	buildAttrsInfo()
end

local updateUpStarArea = function()
	iconNode:setStarLevel(info.attrs[MPackStruct.eAttrStarLevel])
	buildAttrsInfo()
end

local updateUpLevelArea = function()
	iconNode:protoId(info.protoId)
	levelNode:setValue( MpropOp.levelLimits(info.protoId) )
	buildAttrsInfo()
end
-----------------------------------------------------------------------
local update = function(observable, event, girdId)
	dump(event, "event")
	local gird = pack:getGirdByGirdId(params.girdId)
	if event == "upStrength" then
		MPackStruct.attrsFromGird(gird, {
			MPackStruct.eAttrStrengthLevel,
		}, info.attrs)
		combatPower:setValue( MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower) )
		updateUpStrengthArea()
	elseif event == "upQuality" then
		MPackStruct.attrsFromGird(gird, {
			MPackStruct.eAttrQuality,
		}, info.attrs)
		combatPower:setValue( MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower) )
		updateUpQualityArea()
	elseif event == "upStar" then
		MPackStruct.attrsFromGird(gird, {
			MPackStruct.eAttrStarLevel,
		}, info.attrs)
		combatPower:setValue( MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower) )
		updateUpStarArea()
	elseif event == "upLevel" then
		info.protoId = MPackStruct.protoIdFromGird(gird)
		combatPower:setValue( MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower) )
		updateUpLevelArea()
	end
end
root:registerScriptHandler(function(event)
	if event == "enter" then
		pack:register(update)
	elseif event == "exit" then
		pack:unregister(update)
	end
end)
-----------------------------------------------------------------------
return root
end }