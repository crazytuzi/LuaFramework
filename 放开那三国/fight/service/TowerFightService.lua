-- FileName: TowerFightService.lua
-- Author: lichenyang
-- Date: 15-08-03
-- Purpose: 试练塔网络层

module("TowerFightService", package.seeall)


-- /**
-- * 进入某个塔层进行攻击
-- * @param int pLevel	塔层id
-- * @return	string	'ok'
-- */
function enterLevel(pCopyId, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId})
   	Network.rpc(requestFunc, "tower.enterLevel", "tower.enterLevel", args, true)
end

-- /**
-- * 击败塔层中的怪物
-- * @param int pLevel
-- * @param int $armyId
-- * @return array
-- * <code>
-- * [
-- * 	fightRet:
-- * 	appraisal:int
-- * 	reward:array
-- * 			[
-- * 				silver:int
-- * 				soul:int
-- * 				item:array
-- * 				stamina:int
-- * 				execution:int
-- * 			]
-- * cd:int
-- * newcopyorbase:array     
-- *     [
-- *         pass:bool
-- *         tower_info:array
-- *     ]   
-- * ]
-- * </code>
-- */
function defeatMonster(pLevel, pArmyId, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pLevel, pArmyId})
   	Network.rpc(requestFunc, "tower.defeatMonster", "tower.defeatMonster", args, true)
end


-- /**
-- * 离开爬塔系统
-- * @return string 'ok'
-- */
function leaveTower(pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
   	Network.rpc(requestFunc, "tower.leaveTower", "tower.leaveTower", nil, true)
end

-- /**
-- * 
-- * @param int $towerLvId
-- * @return string 'ok'
-- */
function enterSpecailLevel(pTowerLvId, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pTowerLvId})
   	Network.rpc(requestFunc, "tower.enterSpecailLevel", "tower.enterSpecailLevel", args, true)
end
-- /**
-- * 击败塔层中的怪物
-- * @param int $level
-- * @param int $armyId
-- * @return array
-- * <code>
-- * [
-- * 	fightRet:
-- * 	appraisal:int
-- * 	reward:array
-- * 			[
-- * 				silver:int
-- * 				soul:int
-- * 				item:array
-- * 				stamina:int
-- * 				execution:int
-- * 			]
-- * cd:int
-- * newcopyorbase:array     
-- *     [
-- *         pass:bool
-- *         tower_info:array
-- *     ]   
-- * ]
-- * </code>
-- */
function defeatSpecialTower(pTowerLvId, pArmyId, pFmt, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pTowerLvId, pArmyId, pFmt})
   	Network.rpc(requestFunc, "tower.defeatSpecialTower", "tower.defeatSpecialTower", args, true)
end