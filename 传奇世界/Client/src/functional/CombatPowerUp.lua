local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

local build = function(params)
------------------------------------------------------------------------------------
local Minteger = require "src/component/number/model"
local Mnumber = require "src/component/number/view"
------------------------------------------------------------------------------------
local params = params or {}
-- 设置默认值
local src = params.src
if type(src) ~= "string" then src = "res/component/number/10.png" end

-- 数字之间的间隔
local margin = params.margin or 0

-- 数值的起点
local sp = params.sp or 0
sp = math.max(0, sp)

-- 数值的终点
local ep = params.ep or 999999
ep = math.max(sp, ep)

-- 提升数值
local increment = ep - sp
------------------------------------------------------------------------------------
local NumberBuilder = Mnumber.new(src)
------------------------------------------------------------------------------------
local root = cc.Sprite:create("res/common/misc/powerbg_s.png")
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
local numbersTexture = TextureCache:addImage(src)
local csize = numbersTexture:getContentSize()
local NumberW = csize.width/10
local NumberH = csize.height

local buildNumberSpriteFrame = function(number)
	local rect = cc.rect(NumberW * number, 0, NumberW, NumberH)
	return cc.SpriteFrame:createWithTexture(numbersTexture, rect)
end

local numbers = function(number, width)
	local ret = {}
	for _, v in Minteger.new(number, width) do
		ret[#ret + 1] = v
	end
	return ret
end
	
local NumberNode = cc.Node:create()

local eps = numbers(ep)
local sps = numbers(sp, #eps)
local nodes_info = {}

local count = #sps
for i = 1, count do
	local digit = sps[i]
	local pos = cc.p((NumberW + margin) * (i - 1) + NumberW/2, NumberH/2)
	
	local node = Mnode.addChild(
	{
		parent = NumberNode,
		child = Mnode.createSprite({ src = buildNumberSpriteFrame(digit) }),
		pos = pos,
		tag = i,
	})
	
	local info = {}
	info.node = node
	info.tag = i
	info.digit = digit
	info.target = eps[i]
	info.pos = pos
	info.rollCount = 3
	if i > 1 then info.next = nodes_info[i - 1] end
	
	nodes_info[i] = info
end

NumberNode:setContentSize(cc.size((NumberW * count + margin * (count - 1)), NumberH))

local play = nil
play = function(info)
	local duration = 0.05

	local MoveTo1 = cc.MoveTo:create(duration, cc.p(info.pos.x, NumberH * -0.2))

	local CallFunc1 = cc.CallFunc:create(function(node)
		info.rollCount = info.rollCount - 1
		
		if info.rollCount > 0 then
			node:setSpriteFrame(buildNumberSpriteFrame(math.random(0, 9)))
		else
			node:setSpriteFrame(buildNumberSpriteFrame(info.target))
		end
		
		node:setPosition(info.pos.x, NumberH * 1.2)
	end)
	
	local MoveTo2 = cc.MoveTo:create(duration, info.pos)


	local Sequence1 = cc.Sequence:create(MoveTo1, CallFunc1, MoveTo2)
	local Repeat = cc.Repeat:create(Sequence1, info.rollCount)

	local CallFunc2 = cc.CallFunc:create(function(node)
		local next = info.next
		if next then
			play(next)
		else
			AudioEnginer.playEffect("sounds/uiMusic/ui_fire.mp3",false)
			local effectNode = Effects:create(false)
			effectNode:playActionData("powerFire1", 7, 1.2, -1)
			Mnode.addChild(
			{
				parent = root,
				child = effectNode,
				pos = cc.p(rootSize.width - 80, rootSize.height+30),
				--zOrder = -1,
			})
			--------------------------------------------------------------
			local IncNode = Mnode.combineNode(
			{
				nodes = {
					cc.Sprite:create("res/component/number/10_inc.png"),
					NumberBuilder:create(increment, 0),
					cc.Sprite:create("res/group/arrows/8.png"),
				},
			})
			local IncNodeSize = IncNode:getContentSize()
			
			
			local spos = cc.p(rootSize.width - 50, rootSize.height - 10)
			local MoveTo = cc.EaseExponentialOut:create(cc.MoveTo:create(0.5, cc.p(spos.x, spos.y + 16)))
			local DelayTime1 = cc.DelayTime:create(0.7)
			--local Hide = cc.Hide:create()
			--local DelayTime2 = cc.DelayTime:create(1)
			local CallFunc = cc.CallFunc:create(function(node)
				if root then
					removeFromParent(root)
					root = nil
				end
			end)
			--local Sequence = cc.Sequence:create(MoveTo, DelayTime1, Hide, DelayTime2, CallFunc)
			local Sequence = cc.Sequence:create(MoveTo, DelayTime1, CallFunc)
			IncNode:runAction(Sequence)

			Mnode.addChild(
			{
				parent = root,
				child = IncNode,
				pos = spos,
				scale = 0.6,
			})
		end
	end)
	
	local Sequence2 = cc.Sequence:create(Repeat, CallFunc2)

	local node = info.node
	node:runAction(Sequence2)
end

------------------------------------------------------------------------------------
local power = Mnode.createKVP(
{
	k = cc.Sprite:create("res/common/misc/power_b.png"),
	v = NumberNode,
	margin = 10,
})

Mnode.addChild(
{
	parent = root,
	child = power,
	anchor = cc.p(0, 0.5),
	pos = cc.p(100, rootSize.height/2),
	scale = 0.6,
	zOrder = 1,
})

local spos = cc.p(g_scrCenter.x, 200)
local MoveTo = cc.EaseExponentialOut:create(cc.MoveTo:create(0.5, cc.p(spos.x, spos.y + 250)))
local CallFunc = cc.CallFunc:create(function(node)
	play(nodes_info[#nodes_info])
end)
local Sequence = cc.Sequence:create(MoveTo, CallFunc)

root:runAction(Sequence)
------------------------------------------------------------------------------------
local scene = Director:getRunningScene()
local old = scene:getChildByTag(99)
if old then removeFromParent(old) old = nil end
Mnode.addChild(
{
	parent = scene,
	child = root,
	pos = spos,
	zOrder = 100000,
	tag = 99,
})
------------------------------------------------------------------------------------
return root
end

-----------------------------------------------------------------------
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue, old)
	
	if not isMe or attrId ~= PLAYER_BATTLE or not old or attrValue <= old then return end
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then return end--公平竞技场不弹
	--dump({old = old, new = attrValue, increment = attrValue - old}, "power")
	--刚出公平竞技场的时候不弹
	if G_SKYARENA_DATA.tipsLimit and G_SKYARENA_DATA.tipsLimit.fightPowerUpStopTimes and G_SKYARENA_DATA.tipsLimit.fightPowerUpStopTimes==0 then
		G_SKYARENA_DATA.tipsLimit.fightPowerUpStopTimes=1
	else
		build({ sp = old, ep = attrValue, })
	end
end

-- 监听战斗力升高这种变化
listen = function(self)
	local MRoleStruct = require "src/layers/role/RoleStruct"
	MRoleStruct:register(onDataSourceChanged)
end

-- 取消监听
nolisten = function(self)
	local MRoleStruct = require "src/layers/role/RoleStruct"
	MRoleStruct:unregister(onDataSourceChanged)
end
-----------------------------------------------------------------------