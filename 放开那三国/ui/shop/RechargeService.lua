-- FileName: RechargeService.lua
-- Author: lichenyang
-- Date: 2015-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("RechargeService", package.seeall)

--[[
	/**
	 * 获取玩家的人民币消费情况
	 * @return array
	 * <code>
	 * [
	 *     is_pay:bool
	 *     can_buy_monthlycard:bool
	 *	   charge_info:array
	 *	   [
	 *			charge_id => charge_time
	 *	   ]
	 * ]
	 * </code>
	 */
--]]
function getChargeInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"user.getChargeInfo","user.getChargeInfo",nil,true)
end