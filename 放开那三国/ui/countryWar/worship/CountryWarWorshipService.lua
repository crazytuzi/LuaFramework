-- FileName: CountryWarWorshipService.lua
-- Author: yangrui
-- Date: 2015-11-16
-- Purpose: 国战膜拜Service

module("CountryWarWorshipService", package.seeall)

-- /**
--  *膜拜
--  * @return
--  * <code>
--  * 
--  * {
--  * 		ret:string									ok|fail|errman|errtime,成功|失败|没资格|时间不对
--  * }
--  * 
--  * </code>
--  * 
--  */
function worship( pCallback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if pCallback ~= nil then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.worship","countrywarinner.worship",nil)
end
