-- FileName: CountryWarCheerService.lua
-- Author: lichenyang
-- Date: 2015-11-16
-- Purpose: 国战助威
--[[TODO List]]

module("CountryWarCheerService", package.seeall)
-- /**
--  * 助威某个人
--  * @param int pPid
--  * @param int pServerId
--  * 
--  * @return
--  * {
--  * 		ret:string									ok|fail|errman|errtime,成功|失败|对象不合法|时间不对
--  * 		
--  * }
--  */
function supportOneUser( pPid, pServerId, pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPid, pServerId })
	Network.rpc(requestFunc,"countrywarinner.supportOneUser","countrywarinner.supportOneUser",args,true)
end

-- /**
--  * 助威某个势力
--  * @param int pCountryId
--  * 
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret:string									ok|fail|errman|errtime,成功|失败|对象不合法|时间不对
--  * }
--  * 
--  * </code>
--  */
function supportOneCountry( pCountryId, pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pCountryId })
	Network.rpc(requestFunc,"countrywarinner.supportFinalSide","countrywarinner.supportFinalSide",args,true)
end

-- /**
--  * 		我的助威 要显示什么信息，等策划
--  * 
--  * @return
--  * 
--  * <code>
--  * 
--  * 		{
--  * 			user
--  * 			{
--  * 				pid
--  * 				server_id
--  * 				uname
--  * 				htid
--  * 				vip
--  * 				level
--  * 				fight_force
--  * 				dress=>{}
--  * 			}
--  * 			countryId=>int
--  * 		}
--  * 
--  * </code>
--  * 
--  */
function getMySupport(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getMySupport","countrywarinner.getMySupport",nil,true)
end