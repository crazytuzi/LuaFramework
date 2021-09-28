-- FileName: SoulRebornService.lua 
-- Author: licong 
-- Date: 15/9/24 
-- Purpose: 战魂重生网络接口


module("SoulRebornService", package.seeall)

-- /**
--  * 获得信息
--  * 
--  * @return array
--  * <code>
--  * {
--  * 		'num':int 重生次数
--  * }
--  * </code>
--  */
function getInfo( p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--getInfo-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"fsreborn.getInfo","fsreborn.getInfo",nil,true)
end

-- /**
--  * 重生战魂
--  * 
--  * @param int $itemId 物品id
--  * @return array
--  * <code>
--  * {
--  * 		'silver':int 银币
--  * 		'exp':int 战魂经验
--  * 		'item':array 战魂数组
--  * 		{
--  * 			$itemId => $itemTplId
--  * 		}
--  * }
--  * </code>
--  */
function reborn( p_itemId, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--reborn-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ tostring(p_itemId) })
	Network.rpc(requestFunc,"fsreborn.reborn","fsreborn.reborn",args,true)
end


