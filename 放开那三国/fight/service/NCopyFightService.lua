-- FileName: NCopyFightService.lua
-- Author: 
-- Date: 15-08-03 
-- Purpose: 普通副本战斗网络层

module("NCopyFightService", package.seeall)

-- /**
--  * 判断是否可以进入某据点某难度级别进行攻击
--  * @param int pCopyId 副本id
--  * @param int pBaseId 据点id
--  * @param int pBaseLv   据点难度级别     npc:0,简单难度:1,普通难度:2,困难难度:3
--  * @return string 'ok' 'execution'(没有体力了） 'bag'(背包满了)
--  */
function enterBaseLevel(pCopyId, pBaseId, pBaseLv, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId, pBaseLv})
   	Network.rpc(requestFunc, "ncopy.enterBaseLevel", "ncopy.enterBaseLevel", args, true)
end

-- /**
-- * 战斗接口
-- * @param int pCopy_id
-- * @param int pBase_id
-- * @param int pLevel
-- * @param int pArmy_id
-- * @param array pFmt 当前玩家的阵型数据
-- * @param array pHerolist
-- * @return array
-- * <code>
-- * [
-- * 		err:int					ok表示操作成功，execution表示行动力不足
-- * 		fightRet:array 			战斗过程以及结果
-- * 		reward:array			奖励信息
-- * 				[
-- * 					soul:int
-- * 					silver:int
-- * 					gold:int
-- * 					exp:int
-- * 					item:array
-- *                     [
-- *                         iteminfo:array
-- *                             [
-- *                                 item_id:int
--    *                                 item_template_id:int
--    *                                 item_num:int
-- *                             ]
-- *                     ]
-- * 					hero:array
-- *                     [
-- *                         dropHeroInfo:array
-- *                         [
-- *                             mstId:int    掉落武将的monsterId
--    *                             htid:int     掉落的武将htid
-- *                         ]
-- *                        
-- *                     ]
-- * 				]
-- *      extra_reward:array      
-- *          [
-- *             item=>array
-- *             [
-- *                 ItemTmplId=>num
-- *             ]
-- *             hero=>array
-- *             [
-- *                 Htid=>num
-- *             ]
-- *             silver=>int
-- *             soul=>int
-- *             treasFrag=>array
-- *             [
-- *                 TreasFragTmplId=>num
-- *             ]
-- *          ]
-- * 		appraisal:int			战斗结果
-- * 		score:int				副本当前得分
-- * 		newcopyorbase:array		开启的新副本或者据点
-- *      mysmerchant:array       触发了神秘商人，如果为空  表示没有触发
-- * ]
-- * </code>
-- */
function doBattle(pCopyId, pBaseId, pLevel, pArmyId, pFmtArray, pHerolist, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId, pLevel, pArmyId, pFmtArray, pHerolist})
   	Network.rpc(requestFunc, "ncopy.doBattle", "ncopy.doBattle", args, true)
end

-- /**
--  * 离开据点某难度级别    应用场景：攻击成功或者失败后点击返回按钮
--  * @param int pCopyId				副本id
--  * @param int pBaseId				据点id
--  * @param int pBaseLv				据点难度级别
--  * @return 'ok'
--  */
function leaveBaseLevel(pCopyId, pBaseId, pBaseLv, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId, pBaseLv})
   	Network.rpc(requestFunc, "ncopy.leaveBaseLevel", "ncopy.leaveBaseLevel", args, true)
end