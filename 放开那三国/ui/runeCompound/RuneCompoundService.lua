-- Filename: RuneCompoundService.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成网络接口

module("RuneCompoundService", package.seeall)

--[[
	/**
	 * 符印合成
	 *
	 * @param int $method id
	 * @param array $arrItemId 消耗的物品id
	 * @return string $ret 结果：'ok' 成功
	 */
	 public function composeRune($method, $arrItemId);
--]]
function composeRune( pMethodId, pMatIdsTable, pCallback )
	local callback = function ( cbFlag, dictData, bRet )
		if bRet ~= true or dictData.err ~= "ok" then return end

		local tbArgs = {}
		table.insert(tbArgs, pMethodId)
		table.insert(tbArgs, pMatIdsTable)

		if pCallback ~= nil then
			dictData.tbArgs = tbArgs
			pCallback(dictData)
		end
	end

	local arrArgs = Network.argsHandlerOfTable({pMethodId, pMatIdsTable})
	Network.rpc(callback, "forge.composeRune", "forge.composeRune", arrArgs, true)
end