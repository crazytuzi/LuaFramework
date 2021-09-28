-- FileName: FightStrModel.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗串模型

module("FightStrModel", package.seeall)


local _fightInfo = {}
local _battleInfo = {}
--[[
	@des: 设置战斗串
--]]
function setFightRet( pFightRet )
	require("script/utils/LuaUtil")
	_fightRet = pFightRet
    local amf3_obj = Base64.decodeWithZip(pFightRet)
    local lua_obj = amf3.decode(amf3_obj)
    _fightInfo = lua_obj
    _battleInfo = {}
    printTable("_fightInfo", _fightInfo)
    recombine()
    printTable("_battleInfo", _battleInfo)
end

--[[
	@des:战斗串预处理
--]]
function recombine()
	for i=1,#_fightInfo.battle do
		local block = _fightInfo.battle[i]
		if block.arrChild then
			table.insert(_battleInfo, block)
			local totalNum = getTotalDamage(block)
			for j=1,#block.arrChild do
				local childBlock = block.arrChild[j]
				table.insert(_battleInfo, childBlock)
				totalNum = totalNum + getTotalDamage(childBlock)
			end
			--给最后一个子回合添加总伤字段
			_battleInfo[#_battleInfo].showTotal = true
			_battleInfo[#_battleInfo].totalNum = totalNum
		else
			--没有子回合也添加总伤害字段
			block.totalNum = getTotalDamage(block)
			table.insert(_battleInfo, block)
		end
	end
end

--[[
	@des:得到战斗串信息
--]]
function getFightInfo()
	return _fightInfo
end

--[[
	@des:清除数据
--]]
function clearData()
	_fightInfo = {}
	_battleInfo = {}
end

--[[
	@des:得到我方玩家信息
--]]
function getPlayerInfo()
	return _fightInfo.team1
end

--[[
	@des:得到我方玩家信息
--]]
function getEnemyInfo()
	return _fightInfo.team2
end

--[[
	@des:得到数据块
--]]
function getBlockByIndex( pBattleIndex )
	return _battleInfo[tonumber(pBattleIndex)]
end

--[[
	@des:得到战斗回合最大索引
--]]
function getMaxBlockIndex()
	return table.count(_battleInfo)
end

--[[
	@des:得到最大回合数
	@ret:int
--]]
function getMaxRound()
	local maxRound = _battleInfo[#_battleInfo].round or 0
	return maxRound
end

--[[
	@des:得到当前回合数
--]]
function getCurRound( pIndex )
	local curRound = _battleInfo[pIndex].round or 0
	return curRound
end

--[[
	@des:得到team1宠物id
--]]
function getTeam1PetTid()
	local petTid = nil
	if(_fightInfo.team1.arrPet ~= nil) then
        petTid = _fightInfo.team1.arrPet[1].pet_tmpl
    end
    return petTid
end

--[[
	@des:得到team2宠物id
--]]
function getTeam2PetTid()
	local petTid = nil
    if(_fightInfo.team2.arrPet ~= nil) then
        petTid = _fightInfo.team2.arrPet[1].pet_tmpl
    end
    return petTid
end

--[[
	@des:得到team1战斗力
--]]
function getTeam1FightForce()
	local fightForce = 0
	if _fightInfo.team1.fightForce then
		fightForce = _fightInfo.team1.fightForce
	end
	return fightForce
end

--[[
	@des:得到team2战斗力
--]]
function getTeam2FightForce()
	local fightForce = 0
	if _fightInfo.team2.fightForce then
		fightForce = _fightInfo.team2.fightForce
	end
	return fightForce
end


--[[
	@des:team1是否判断是否先手
--]]
function isFirstAttack()
	return tonumber(_fightInfo.firstAttack)
end

--[[
	@:判读是否为空动作数据块
--]]
function isNoAction(pBlockInfo)
	local isNo = true
	--buffer
	if pBlockInfo.enBuffer or 
		pBlockInfo.deBuffer or 
		pBlockInfo.buffer or 
		pBlockInfo.imBuffer then
			isNo = false
			return isNo
	end
	--mandown
	if pBlockInfo.mandown then
		isNo = false
		return isNo
	end
	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.mandown then
				isNo = false
				return isNo
			end
			--buffer
			if v.enBuffer or 
				v.deBuffer or 
				v.buffer or 
				v.imBuffer then
					isNo = false
					return isNo
			end
			if v.arrDamage then
				isNo = false
				return isNo
			end
			if v.reaction ~= 1 then
				isNo = false
				return isNo
			end
		end
	end
	return isNo
end

--[[
	@des:得到武将信息
--]]
function getHeroInfoByHid( pHid )

	if _fightInfo.team1 == nil and _fightInfo.team2 == nil then
		return
	end
	local heroInfo = nil
	for k,v in pairs(_fightInfo.team1.arrHero) do
		if tonumber(v.hid) == tonumber(pHid) then
			heroInfo = v
			heroInfo._isEnemy = false
		end
	end
	for k,v in pairs(_fightInfo.team2.arrHero) do
		if tonumber(v.hid) == tonumber(pHid) then
			heroInfo = v
			heroInfo._isEnemy = true
		end
	end
	heroInfo.name = getHeroName(heroInfo)
	return heroInfo
end

--[[
	@des:得到角色名称
	@parm:heroInfo 角色信息
	@ret:string 角色名称
--]]
function getHeroName( pHeroInfo )
	require "db/DB_Heroes"
	require "db/DB_Monsters_tmpl"
	require "script/model/hero/HeroModel"
	local dbInfo = DB_Heroes.getDataById(pHeroInfo.htid)
	if not dbInfo then
		local monsterInfo = DB_Monsters.getDataById(pHeroInfo.htid)
		dbInfo = DB_Monsters_tmpl.getDataById(monsterInfo.htid)
	end
	local name = dbInfo.name
	if HeroModel.isNecessaryHero(pHeroInfo.htid) then
		if pHeroInfo._isEnemy == true then
			name = getEnemyInfo().name
		else
			name = getPlayerInfo().name
		end
	end
	return name
end

--[[
	@des:得到所有的死亡玩家
--]]
function getDeadHids()
	local deadHids = {}
	for k1,v1 in pairs(_battleInfo) do
		if v1.mandown == true then
			deadHids[v1.attacker] = v1.attacker
		end
		if v1.arrReaction then
			for k2,v2 in pairs(v1.arrReaction) do
				if v2.mandown == true then
					deadHids[v2.defender] = v2.defender
				end
			end
		end
	end
	return deadHids
end

--[[
	@des:得到卡牌的剩余所有伤害
	@parm:hid
--]]
function getRemainDamage( pHid, pBattleIndex)
	local damageCount = 0
	for i=pBattleIndex+1, #_battleInfo do
		local v = _battleInfo[i]
		local atkNum = getAtkDamageValue(v, pHid)
		local bufNum = getBufferDamage(v, pHid)
		damageCount = damageCount + atkNum - bufNum
	end
	return damageCount
end

--[[
    @des: 计算单个被打击武将伤害
    @parm: pBlockInfo 块数据
    @parm: pHid 武将id
    @ret: number
--]]
function getAtkDamageValue( pBlockInfo, pHid)
    local defBlock = nil
    if pBlockInfo.arrReaction then
	    for k,v in pairs(pBlockInfo.arrReaction) do
	        if tonumber(v.defender) == tonumber(pHid) then
	            defBlock = v
	        end
	    end
	end
    local retValue = 0
    if defBlock and defBlock.arrDamage then
	    for k,v in pairs(defBlock.arrDamage) do
	       retValue = retValue + tonumber(v.damageValue)
	    end
	end
    return retValue
end

--[[
	@des:得到单个武将的buffer伤害
	@parm:parm1 描述
	@ret:ret 描述
--]]
function getBufferDamage( pBlockInfo, pHid )
	local number = 0
	if pBlockInfo.buffer then
		if tonumber(pBlockInfo.attacker) == tonumber(pHid) then
			for k,v in pairs(pBlockInfo.buffer) do
				if tonumber(v.type) == BufferType.HP then
					number =number + tonumber(v.data)
				end
			end
		end
	end
	if pBlockInfo.arrReaction then
		for k1,v1 in pairs(pBlockInfo.arrReaction) do
			if v1.buffer and tonumber(v1.defender) == tonumber(pHid) then
				for k2,v2 in pairs(v1.buffer) do
					if tonumber(v2.type) == BufferType.HP then
						number = number + tonumber(v2.data)
					end
				end
			end
		end
	end
	return number
end


--[[
    @des: 计算总伤害伤害
    @parm: pBlockInfo 块数据
    @parm: pHid 武将id
    @ret: number
--]]
function getTotalDamage(pBlockInfo)
    local totalDamage = 0
    if pBlockInfo.arrReaction == nil then
        return totalDamage
    end
    --技能伤害
    for i=1,#(pBlockInfo.arrReaction) do
        --处理伤害
        if(pBlockInfo.arrReaction[i].arrDamage ~= nil) then
            local damage = 0
            for j=1,#(pBlockInfo.arrReaction[i].arrDamage) do
                damage = damage+pBlockInfo.arrReaction[i].arrDamage[j].damageValue
            end
            totalDamage = totalDamage + damage
        end
    end
    return totalDamage
end

--[[
    @des:得到被攻击者数量
--]]
function getDefenderCount(pBlockInfo)
    local num = 0
    if pBlockInfo.arrReaction then
       num = table.count(pBlockInfo.arrReaction)
    end
    return num
end

--[[
    @des:得到特效打击次数
--]]
function getAttackKeyFrameCount(pBlockInfo)
    local atkHid    = pBlockInfo.attacker
    local atkCard   = FightScene.getCardByHid(atkHid)
    local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
    local skillId   = pBlockInfo.action
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)

    local keyFrameCount = 0
    local effectPath = FightUtil.getEffectPath(skillInfo.attackEffct, atkCard:isEnemy())
    if effectPath then
        local xmlData = AnimationXML:new()
        xmlData:load(effectPath)
        keyFrameCount = xmlData:getKeyFrameCount()
    end
    return keyFrameCount
end
