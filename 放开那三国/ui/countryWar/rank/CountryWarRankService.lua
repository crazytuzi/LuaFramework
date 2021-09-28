-- FileName:CountryWarRankService.lua
-- Author:FQQ
-- Data:2015-11-30
-- Purpose:国战积分排行榜网络层

module ("CountryWarRankService",package.seeall)

-- * 获取决赛的参赛选手，只在助威阶段需要使用
-- * 
-- * @return
-- * {
-- * 		ret:string									ok
-- * 		memberInfo:										
-- * 		{
-- * 			contryId:int
-- * 			{
-- * 				{
-- * 					pid
-- * 					server_id
-- * 					server_name
-- * 					uname
-- * 					htid
-- * 					vip
-- * 					level
-- * 					fight_force
-- * 					fans_num
-- * 					dress=>{}
-- * 				}
-- * 			}
-- * 		}
-- * }
-- * 
-- */
function getFinalMembers(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getFinalMembers","countrywarinner.getFinalMembers",nil,true)
end