-- FileName: CountryWarSignService.lua
-- Author: shengyixian
-- Date: 2015-11-16
-- Purpose: 国战报名网络层
module("CountryWarSignService",package.seeall)

-- /**
--  * 选择一个国家并且报名
--  * @param int $countryId								国家代号
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret=>string 								ok|fail|errtime,成功|失败|时间不对
--  * 		countrySignNum									各个国家的报名人数信息
--  * 		{
--  * 			countryId:int => count:int,					国家代号:魏1蜀2吴3群4
--  * 		}
--  * }
--  * 
--  * </code>
--  * 
--  */
function signForOneCountry(countryId,pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ countryId })
	Network.rpc(requestFunc,"countrywarinner.signForOneCountry","countrywarinner.signForOneCountry",args,true)
end