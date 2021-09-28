-- FileName: TransformMainService.lua 
-- Author: licong 
-- Date: 16/3/1 
-- Purpose: 转换网络接口


module("TransformMainService", package.seeall)


-- /**
-- * 神兵转换
-- * @param int $itemId 转换前的神兵id
-- * @param int $itemTplId 待转换的神兵模板id
-- * @return int $itemId 转换后的神兵id
-- */
-- public function transfer($itemId, $itemTplId);
function transfer(p_itemId, p_toTid, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_itemId, p_toTid })
	Network.rpc(requestFunc,"godweapon.transfer","godweapon.transfer",args,true)
end


-- /**
-- * 宝物转换
-- * @param int $itemId 转换前的宝物id
-- * @param int $itemTplId 待转换的宝物模板id
-- * @return int $itemId 转换后的宝物id
-- */
-- public function transferTreasure($itemId, $itemTplId);
function transferTreasure(p_itemId, p_toTid, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_itemId, p_toTid })
	Network.rpc(requestFunc,"forge.transferTreasure","forge.transferTreasure",args,true)
end



