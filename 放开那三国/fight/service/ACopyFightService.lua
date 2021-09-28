-- FileName: ACopyFightService.lua
-- Author: lichenyang
-- Date: 15-08-03 
-- Purpose: 活动副本战斗网络接口

module("ACopyFightService", package.seeall)

-- /**
--  * 进入某个据点的难度级别进行攻击(活动类别：活动据点)
--  * @param int pCopyId
--  * @param int pBaseLv
--  * @return string 'ok'
--  */
function enterBaseLevel(pCopyId, pBaseId, pBaseLv, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId})
   	Network.rpc(requestFunc, "acopy.enterBaseLevel", "acopy.enterBaseLevel", args, true)
end
-- /**
--  * 活动副本中的活动据点的战斗接口
--  * @param int pCopyId
--  * @param int pBaseLv
--  * @param int pArmyId
--  * @param array pFmtA玩家的当前阵型
--  * @return array
--  * <code>
--  * [
--  *      err:string (nodefeatnum  execution ok三个值）
--  * 		fightRet:array
--  * 		curHp:array
--  * 				[
--  * 					array[hid:int   hp:int  costHp:int]
--  * 				]
--  * 		cd:int							战斗冷却时间
--  * 		reward:array
--  * 				[
--  * 					silver:int			银两奖励
--  * 					exp:int				经验奖励
--  * 					gold:int			金币奖励
--  * 					soul:int			将魂奖励
--  * 					item:array			物品奖励
--  * 					bag:array			背包中格子的变化
--  * 					card:array			掉落的卡牌
--  * 				]
--  *      extra_reward:array    格式同reward字段
--  * 		appraisal:int
--  *      hurt:int
--  * ]
--  * </code>
--  */
function atkActBase(pCopyId, pBaseLv, pArmyId, pFmtArray, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId,pBaseLv,pArmyId,pFmtArray})
   	Network.rpc(requestFunc, "acopy.atkActBase", "acopy.atkActBase", args, true)
end

-- /**
--  * 攻击摇钱树
--  * @param int pCopyId
--  * @param int pArmyId
--  * @param array pFmt
--  * @return array
--  * <code>
--  * [
--  *      err:string (nodefeatnum  execution ok三个值）
--  * 		fightRet:array
--  * 		curHp:array
--  * 				[
--  * 					array[hid:int   hp:int  costHp:int]
--  * 				]
--  * 		cd:int							战斗冷却时间
--  * 		reward:array
--  * 				[
--  * 					silver:int			银两奖励
--  * 					exp:int				经验奖励
--  * 					gold:int			金币奖励
--  * 					soul:int			将魂奖励
--  * 					item:array			物品奖励
--  * 					bag:array			背包中格子的变化
--  * 					card:array			掉落的卡牌
--  * 				]
--  *      extra_reward:array    格式同reward字段
--  * 		appraisal:int
--  * ]
--  * </code>
--  */
function doBattle(pCopyId, pBaseId, pArmyId, pFmtArray, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId,pBaseId,pArmyId,pFmtArray})
   	Network.rpc(requestFunc, "acopy.doBattle", "acopy.doBattle", args, true)
end
	
-- /**
--  * 攻击摇钱树
--  * @param int pCopyId
--  * @param int pCyItem 0表示使用攻击次数   1表示使用物品
--  * @param array pCmt
--  * @return array
--  * <code>
--  * [
--  *      err:string (nodefeatnum  execution ok三个值）
--  * 		fightRet:array
--  * 		curHp:array
--  * 				[
--  * 					array[hid:int   hp:int  costHp:int]
--  * 				]
--  * 		cd:int							战斗冷却时间
--  * 		reward:array
--  * 				[
--  * 					silver:int			银两奖励
--  * 					exp:int				经验奖励
--  * 					gold:int			金币奖励
--  * 					soul:int			将魂奖励
--  * 					item:array			物品奖励
--  * 					bag:array			背包中格子的变化
--  * 					card:array			掉落的卡牌
--  * 				]
--  *      extra_reward:array    格式同reward字段
--  * 		appraisal:int
--  *      hurt:int
--  * ]
--  * </code>
--  */
function atkGoldTree(pCopyId, pCyItem, pFmtArray, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId,pCyItem,pFmtArray})
   	Network.rpc(requestFunc, "acopy.atkGoldTree", "acopy.atkGoldTree", args, true)
end


-- /**
-- * 离开某个副本的据点难度级别(活动类型：活动据点）
-- * @param int $copyId
-- * @param int $baseLv
-- * @return string 'ok'
-- */
function leaveBaseLevel(pCopyId, pBaseLv, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseLv})
   	Network.rpc(requestFunc, "acopy.atkGoldTree", "acopy.atkGoldTree", args, true)
end
