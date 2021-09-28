-- FileName: SignleRechargeService.lua 
-- Author: fuqiongqiong
-- Date: 2016-3-3
-- Purpose: 单充回馈网络层

module("SignleRechargeService",package.seeall)

--[[
	/**
	 * @return
	 * <code>
	 * array
	 * [
	 * 		hadReward:array	当天已经领奖的数组
	 * 		=>[
	 * 			$rewardId => [                    //数组
	 *                        	  0 => $select0,  //$select0：选择的第几个奖励
	 *                       	  1 => $select1,
	 *                            2 => $select2,
	 *                            ...//每领取一次就多一条记录
	 *                       	],   //数组的元素个数表示已领取的次数
	 *            ...
	 * 		   ]
	 * 		toReward:array 当天充值达到领取条件但还没领取的奖励
	 * 		=>[
	 * 			$rewardId => $num,
	 * 	          ...
	 * 		  ]
	 * ]
	 * </code>
	 */
--]]
function getInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"onerecharge.getInfo","onerecharge.getInfo",nil,true)
end

--[[
	/**
	 *
	 * @param $rewardId:int 从1开始
	 * @param $select:int 若奖励可全部领取，该值为0不用专门传入；若奖励N选1，则传入玩家选  择的奖励在配置表中的位置，从1开始。
	 * @return 'ok':成功领取
	 */
--]]
function gainReward( rewardId, rewardIndex, pCallback )
	local requestFunc = function ( cbFlag,dictData,bRet )
		if dictData.err == "ok" then
			if (pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		end
	end
	-- local args = CCArray:create()
	-- args:addObject(CCInteger:create(rewardId))
	local args = Network.argsHandler(rewardId, rewardIndex)
	Network.rpc(requestFunc, "onerecharge.gainReward", "onerecharge.gainReward", args, true)	
end
