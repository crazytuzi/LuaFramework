-- FileName: ECopyFightService.lua 
-- Author: lichenyang 
-- Date: 15-08-03 
-- Purpose: 精英副本战斗网络接口

module("ECopyFightService", package.seeall)

-- /**
-- * 判断是否能够进入某副本进行攻击
-- * @param int $copyId				精英副本id
-- * @return string ok						如果能够进入副本进行攻击，返回‘ok’
-- */
function enterCopy(pCopyId, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId})
   	Network.rpc(requestFunc, "ecopy.enterCopy", "ecopy.enterCopy", args, true)
end
-- /**
-- * 精英副本的战斗接口
-- * @param int $copyId
-- * @param int $army_id
-- * @param array $fmt			玩家的当前阵型
-- * @return array
-- * <code>
-- * [
-- * 		err:int					ok表示操作成功，execution表示行动力不足
-- * 		fightRet:array 			战斗过程以及结果
-- * 		curHP:array				战斗英雄的当前血量
-- * 				[
-- * 					heroid:int
-- * 				]
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
-- *                                 item_template_id:int
-- *                                 item_num:int
-- *                             ]
-- *                     ]
-- * 					hero:array
-- *                     [
-- *                         dropHeroInfo:array
-- *                         [
-- *                             mstId:int    掉落武将的monsterId
-- *                             htid:int     掉落的武将htid
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
-- * ]
-- * </code>
-- */
function doBattle(pCopyId, pArmyId, pFmtArray, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pArmyId, pFmtArray})
   	Network.rpc(requestFunc, "ecopy.doBattle", "ecopy.doBattle", args, true)
end
-- /**
-- * 离开副本  应用场景：战斗成功或者失败之后点击返回按钮
-- * @param int $copyId
-- * @return string 'ok'
-- */
function leaveCopy(pCopyId, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId})
   	Network.rpc(requestFunc, "ecopy.leaveCopy", "ecopy.leaveCopy", args, true)
end