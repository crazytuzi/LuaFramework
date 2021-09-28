-- FileName: TsTallyService.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换网络接口层

module("TsTallyService", package.seeall)

--[[
	@desc 	: 兵符转换
	@param 	: pItemId 转换前的兵符id
	@param 	: pToTid  待转换的兵符模板id
	@param 	: pErrCallback 后端没转换成功回调
	@return : number  转换后的兵符id
	/**
	 * 兵符转换
	 * 
	 * @param int $itemId 转换前的兵符id
	 * @param int $itemTplId 待转换的兵符模板id
	 * @return int $itemId 转换后的兵符id
	 */
	public function transferTally($itemId, $itemTplId);
--]]
function transferTally( pCallback, pItemId, pToTid, pErrCallback )
	local requestCallback = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if (pCallback ~= nil) then
				pCallback(dictData.ret)
			end
		else
			if (pErrCallback ~= nil) then
				pErrCallback()
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pItemId, pToTid })
	Network.rpc(requestCallback,"forge.transferTally","forge.transferTally",args,true)
end
