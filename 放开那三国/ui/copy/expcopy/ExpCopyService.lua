-- Filename: ExpCopyLayer.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 主角经验网络层

module("ExpCopyService", package.seeall)


-- /**
--  * 攻击摇钱树
--  * @param int $copyId
--  * @param int $armyId
--  * @param array $fmt
--  * @return array
--  * <code>
--  * [
--  *      	err:string (nodefeatnum  execution ok三个值）
--  * 	   	fightRet:array
--  * 	   	curHp:array
--  * 				[
--  * 					array[hid:int   hp:int  costHp:int]
--  * 				]
--  * 	   	cd:int							战斗冷却时间
--  * 	   	reward:array
--  * 				[
--  * 					silver:int			银两奖励
--  * 					exp:int				经验奖励
--  * 					gold:int			金币奖励
--  * 					soul:int			将魂奖励
--  * 					item:array			物品奖励
--  * 					bag:array			背包中格子的变化
--  * 					card:array			掉落的卡牌
--  * 				]
--  *      	extra_reward:array    格式同reward字段
--  * 	   	appraisal:int
--  * ]
--  * </code>
--  */
function doBattle(p_copyId,p_baseId,p_armyId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_copyId))
	args:addObject(CCInteger:create(p_baseId))
	args:addObject(CCInteger:create(p_armyId))
	Network.rpc(requestFunc, "acopy.doBattle", "acopy.doBattle", args, true)
end




-- /**
--  * 购买主角经验副本攻击次数
--  * @param int $num
--  * @return string 'ok'
--  */
function buyExpUserAtkNum(p_num, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_num))
	Network.rpc(requestFunc, "acopy.buyExpUserAtkNum", "acopy.buyExpUserAtkNum", args, true)
end