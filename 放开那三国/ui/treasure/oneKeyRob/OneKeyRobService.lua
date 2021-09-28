-- FileName: OneKeyRobService.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: 
--[[TODO List]]

module("OneKeyRobService", package.seeall)


-- /**
-- 	 * 一键夺宝
-- 	 * @param $treasureId int 宝物模板id
-- 	 * @param $ifUse int 0|1 是否自动使用体力丹(0不适用,1使用)
-- 	 * @return array
-- 	 * {
-- 	 * 	'res' => 本字段一定会返回
-- 	 * 			(ok, enough-碎片够合成一个宝物, bagFull-背包满, noStamina--没体力,当没选择自动使用耐力丹,并且没体力时候,
-- 	 * 			noMedicine-没有体力丹, fail-用户自检失败 没有任何一个该宝物对应的碎片)
-- 	 * 	'detail' => [
-- 	 * 		'reward' => array
-- 	 * 					{
-- 	 * 						'exp' => int,
-- 	 * 						'silver' => int,
-- 	 * 						'fragNum' => int,
-- 	 * 					},
-- 	 *		'card' => array 同以前
-- 	 *		'fragId' => int 抢到的碎片id，如果没有该字段，就是本次没抢到
-- 	 * 		'medicine' => int 消耗的耐力丹数量
-- 	 *		]
-- 	 * }
-- 	 */
function oneKeySeize(pTreasureId, pIfUse, pReqeustNum, pCallback)
	print("pCallback",pCallback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallback ~= nil) then
				pCallback(dictData.ret)
			else
				error("callback is error")
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pTreasureId, pIfUse})
	Network.rpc(requestFunc, "fragseize.oneKeySeize" .. pReqeustNum, "fragseize.oneKeySeize", args, true)
	-- requestFunc()
end