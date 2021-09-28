-- FileName: FightController.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗主场景

module("FightController", package.seeall)

--[[
	@des:进入战斗
--]]
function enterBattle( pCallback )
	local bType = FightModel.getbType()
	local copyId = FightModel.getCopyId()
	local baseId = FightModel.getBaseId()
	local armInx = FightMainLoop.getArmyIndex()
	local armyId = FightModel.getArmyIdByIndex(armInx)
	local baseLv = FightModel.getBaseLv()
	local requestCallback = function ( dictData)
		if(dictData.err ~= "ok")then
	        require "script/ui/tip/AlertTip"
	        AlertTip.showAlert( GetLocalizeStringBy("key_3168"), nil, false, nil)
	        FightScene.closeScene()
	        return
	    end
	    if(dictData.ret == "execution") then
	        require "script/ui/tip/AlertTip"
	        AlertTip.showAlert( GetLocalizeStringBy("key_3355"), nil, false, nil)
	        FightScene.closeScene()
	    elseif (dictData.ret == "bag") then
	        require "script/ui/tip/AlertTip"
	        AlertTip.showAlert( GetLocalizeStringBy("key_2027"), nil, false, nil)
	        FightScene.closeScene()
	    end
	    pCallback()
	end
	if bType == BattleType.NORMAL then
		--普通副本	
		NCopyFightService.enterBaseLevel(copyId, baseId, baseLv, requestCallback)
	elseif bType == BattleType.ELITE then
		--精英副本
		ECopyFightService.enterCopy(copyId, requestCallback)
	elseif bType == BattleType.ACTIVITY then
		--活动副本
		ACopyFightService.enterBaseLevel(copyId, baseId, baseLv, requestCallback)
	elseif bType == BattleType.TOWER then
		--试炼塔
		TowerFightService.enterLevel(copyId, requestCallback)
	elseif bType == BattleType.HERO then
		--武将列传
		HCopyFightService.enterBaseLevel(copyId, baseId, baseLv, requestCallback)
	elseif bType == BattleType.MYSICAL_FLOOR then
		--神秘层
		TowerFightService.enterSpecailLevel(copyId, requestCallback)
	else
		error("don't support battle type" .. bType)
	end
end

--[[
	@des:离开战斗
--]]
function levelBattle( pCallback )
	local bType = FightModel.getbType()
	local copyId = FightModel.getCopyId()
	local baseId = FightModel.getBaseId()
	local armInx = FightMainLoop.getArmyIndex()
	local armyId = FightModel.getArmyIdByIndex(armInx)
	local baseLv = FightModel.getBaseLv()
	local requestCallback = function ( dictData )
		pCallback()
	end
	if bType == BattleType.NORMAL then
		--普通副本	
		NCopyFightService.leaveBaseLevel(copyId, baseId, baseLv, requestCallback)
	elseif bType == BattleType.ELITE then
		--精英副本
		ECopyFightService.leaveCopy(copyId, requestCallback)
	elseif bType == BattleType.ACTIVITY then
		--活动副本
		ACopyFightService.leaveBaseLevel(copyId, baseLv, requestCallback)
	elseif bType == BattleType.TOWER then
		--试炼塔
		TowerFightService.leaveTower(requestCallback)
	elseif bType == BattleType.HERO then
		--武将列传
		HCopyFightService.leaveBaseLevel(copyId, baseId, baseLv, requestCallback)
	else
		pCallback()
	end
end

--[[
	@des:战斗
--]]
function doBattle( pCallback )
	local bType  = FightModel.getbType()
	local copyId = FightModel.getCopyId()
	local baseId = FightModel.getBaseId()
	local armInx = FightMainLoop.getArmyIndex()
	local armyId = FightModel.getArmyIdByIndex(armInx)
	local baseLv = FightModel.getBaseLv()
	local herols = FightModel.getHerolist()
	local playCardLayer = FightScene.getPlayerCardLayer()
	local fmtAry = playCardLayer:getFormation()
	local formation = CCDictionary:create()
	for k,v in pairs(fmtAry) do
		if tonumber(v)~=0 then
			formation:setObject(CCInteger:create(v), k)
		end
	end
	local heroList = CCDictionary:create()
	for k,v in pairs(herols) do
		heroList:setObject(CCInteger:create(v), k)
	end

	local requestCallback = function ( dictData )
		--1.刷新数据
		FightModel.addItem(dictData.reward.item)
		FightModel.addHero(dictData.reward.hero)
		FightModel.setResult(dictData.appraisal)
		FightModel.addSilver(dictData.reward.silver)
		FightModel.addExpNum(dictData.reward.exp)
		FightModel.addSoul(dictData.reward.soul)
		FightModel.setDoBattleInfo(dictData)
		
		pCallback(dictData.fightRet)
	end
	if bType == BattleType.NORMAL then
		--普通副本	
		NCopyFightService.doBattle(copyId, baseId, baseLv, armyId, formation, heroList, requestCallback)
	elseif bType == BattleType.ELITE then
		--精英副本
		ECopyFightService.doBattle(copyId, armyId, formation, requestCallback)
	elseif bType == BattleType.ACTIVITY then
		--活动副本
		ACopyFightService.doBattle(copyId, baseId, armyId, formation, requestCallback)
	elseif bType == BattleType.TOWER then
		--试炼塔
		TowerFightService.defeatMonster(copyId, armyId, requestCallback)
	elseif bType == BattleType.HERO then
		--武将列传
		HCopyFightService.doBattle(copyId, baseId, baseLv, armyId, formation, heroList, requestCallback)
	elseif bType == BattleType.MYSICAL_FLOOR then
		--神秘层
		TowerFightService.defeatSpecialTower(copyId, armyId, formation, requestCallback)
	else
		error("don't support battle type" .. bType)
	end
end