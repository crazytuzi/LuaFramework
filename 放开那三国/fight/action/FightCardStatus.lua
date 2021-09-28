-- FileName: FightCardStatus.lua
-- Author: licheng
-- Date: 2015-07-01
-- Purpose: 战斗中卡牌动作
--[[TODO List]]

module("FightCardStatus", package.seeall)

--[[
	@des:更新攻击者怒气
	@parm:pBlockInfo 数据块
--]]
function updateAttackerRage( pBlockInfo )
	local attackHid  = pBlockInfo.attacker
	--得到卡牌对象
	local atkCard = FightScene.getCardByHid(attackHid)
	--本身怒气
	local rageNum = 0
	pBlockInfo.rage = pBlockInfo.rage or 0
	rageNum = rageNum + tonumber(pBlockInfo.rage)
	--buffer怒气
	-- pBlockInfo.buffer = pBlockInfo.buffer or {}
	-- for k,v in pairs(pBlockInfo.buffer) do
	-- 	if tonumber(v.type)== BufferType.RAGE then
	-- 		rageNum = rageNum + tonumber(v.data)
	-- 	end
	-- end
	atkCard:addRage(rageNum)
end

--[[
	@des:更新被攻击者怒气
	@parm:pBlockInfo 数据块
--]]
function updateDefenderRage( pBlockInfo )
	local defCards = {}
	for k,damageBlock in pairs(pBlockInfo.arrReaction) do
		local rageNum = 0
		--buffer伤害
		damageBlock.buffer = damageBlock.buffer or {}
		for k,v in pairs(damageBlock.buffer) do
			if tonumber(v.type)== BufferType.RAGE then
				rageNum = rageNum + tonumber(v.data)
			end
		end
		local card = FightScene.getCardByHid(damageBlock.defender)
		card:addRage(rageNum)
	end
end

--[[
	@des:更新攻击者血量
	@parm:pBlockInfo 数据块
--]]
function updateAttackerHp( pBlockInfo )
	local attackHid  = pBlockInfo.attacker
	--得到卡牌对象
	local atkCard = FightScene.getCardByHid(attackHid)
	local damageHp = 0
	--buffer伤害
	pBlockInfo.buffer = pBlockInfo.buffer or {}
	for k,v in pairs(pBlockInfo.buffer) do
		if tonumber(v.type)== BufferType.HP then
			damageHp = damageHp + tonumber(v.data)
		end
	end
	atkCard:addHp(damageHp)
end

--[[
	@des:更新被攻击者血量
	@parm:pBlockInfo 数据块
--]]
function updateDefenderHp( pBlockInfo )
	local defCards = {}
	for k,damageBlock in pairs(pBlockInfo.arrReaction) do
		local damageHp = 0
		--打击伤害
		damageBlock.arrDamage = damageBlock.arrDamage or {}
		for k,v in pairs(damageBlock.arrDamage) do
			damageHp = damageHp - tonumber(v.damageValue)
		end
		--buffer伤害
		damageBlock.buffer = damageBlock.buffer or {}
		for k,v in pairs(damageBlock.buffer) do
			if tonumber(v.type)== BufferType.HP then
				damageHp = damageHp + tonumber(v.data)
			end
		end
		local card = FightScene.getCardByHid(damageBlock.defender)
		card:addHp(damageHp)
	end
end
