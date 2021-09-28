-- FileName: HCopyFightService.lua
-- Author: lichenyang
-- Date: 15-08-03 
-- Purpose: 武将列传网络层

module("HCopyFightService", package.seeall)


-- /**
--  * 判断是否可以进入某据点某难度级别进行攻击
--  * @param int pCopyId 副本id
--  * @param int pBaseId 据点id
--  * @param int pBaseLv   据点难度级别     npc:0,简单难度:1,普通难度:2,困难难度:3
--  * @return string 'ok' 'execution'(没有体力了） 'bag'(背包满了) 'formation'(武将不在阵型中) 'maxpassnum'(达到最大通关次数)
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
   	Network.rpc(requestFunc, "hcopy.enterBaseLevel", "hcopy.enterBaseLevel", args, true)
end

-- /**
--  * 战斗接口
--  * @param int pCopy_id
--  * @param int pBase_id
--  * @param int pLevel
--  * @param int pCrmy_id
--  * @param array pCmt 当前玩家的阵型数据
--  * @param array pCerolist
--  * @return array
--  * <code>
--  * [
--  * 		err:int					ok表示操作成功，execution表示行动力不足
--  * 		fightRet:array 			战斗过程以及结果
--  * 		reward:array			奖励信息
--  * 				[
--  * 					soul:int
--  * 					silver:int
--  * 					gold:int
--  * 					exp:int
--  * 					item:array
--  *                     [
--  *                         iteminfo:array
--  *                             [
--  *                                 item_id:int
--  *                                 item_template_id:int
--  *                                 item_num:int
--  *                             ]
--  *                     ]
--  * 					hero:array
--  *                     [
--  *                         dropHeroInfo:array
--  *                         [
--  *                             mstId:int    掉落武将的monsterId
--  *                             htid:int     掉落的武将htid
--  *                         ]
--  *
--  *                     ]
--  * 				]
--  *      extra_reward:array
--  *          [
--  *             item=>array
--  *             [
--  *                 ItemTmplId=>num
--  *             ]
--  *             hero=>array
--  *             [
--  *                 Htid=>num
--  *             ]
--  *             silver=>int
--  *             soul=>int
--  *             treasFrag=>array
--  *             [
--  *                 TreasFragTmplId=>num
--  *             ]
--  *          ]
--  * 		appraisal:int			战斗结果
--  *
--  *      newcopyorbase : array
--  *       	[
--  *         		hero_copy : array  如果此副本有变化，如开启新据点，会返回副本最新数据，与getCopyInfo(pCopyid)相同。如果未通关，没有此字段。
--  *       			[
--  *  					copyid : int    副本id
--  *   					finish_num => int 已通关次数
--  * 						va_copy_info =>          副本扩展信息
--  * 							[
--  * 			    				progress:array
--  *              					[
--  *                 					base_id=>base_status(base_status的取值：0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关）
--  *              					]
--  * 							]
--  *       			]
--  *         		pass_hero_copy : array 如果副本通关， 返回此数据。未通关，则没有此数据。
--  *       			[
--  *       				copyid => pass_num   副本id => 通关次数
--  *          		]
--  *        	]
--  * ]
--  * </code>
-- */
function doBattle(pCopyId, pBaseId, pLevel,pCrmyId, pFmtArray, pCerolist, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId, pLevel,pCrmyId, pFmtArray, pCerolist})
   	Network.rpc(requestFunc, "hcopy.doBattle", "hcopy.doBattle", args, true)
end

-- /**
--  * 离开据点某难度级别    应用场景：攻击成功或者失败后点击返回按钮
--  * @param int pCopyId				副本id
--  * @param int pBaseId				据点id
--  * @param int pBaseLv				据点难度级别
--  * @return 'ok'
-- */
function leaveBaseLevel(pCopyId, pBaseId, pBaseLv, pCallback)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pCopyId, pBaseId, pBaseLv})
   	Network.rpc(requestFunc, "hcopy.leaveBaseLevel", "hcopy.leaveBaseLevel", args, true)
end
