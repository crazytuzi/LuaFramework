-- FileName: WorldArenaRankService.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 排行榜 网络接口
--[[TODO List]]

module("WorldArenaRankService", package.seeall)

-- /**
-- * 获得排行
-- * 
-- * @return array
-- * {
-- * 		pos_rank => array				对决排行
-- * 		[
-- * 			{
-- * 				rank
-- * 				server_id
-- * 				server_name
-- * 				pid
-- * 				uname
-- * 				htid
-- * 				level
-- * 				vip
-- * 				fight_force
-- * 				dress
-- * 			}
-- * 		]
-- * 		kill_rank => array				击杀排行
-- * 		[
-- * 			{
-- * 				rank
-- * 				kill_num				击杀数
-- * 				server_id
-- * 				server_name
-- * 				pid
-- * 				uname
-- * 				htid
-- * 				level
-- * 				vip
-- * 				fight_force
-- * 				dress
-- * 			}
-- * 		]
-- * 		conti_rank => array				连杀排行
-- * 		[
-- * 			{
-- * 				rank
-- * 				max_conti_num			最大连杀数					
-- * 				server_id
-- * 				server_name
-- * 				pid
-- * 				uname
-- * 				htid
-- * 				level
-- * 				vip
-- * 				fight_force
-- * 				dress
-- * 			}
-- * 		]
-- * }
-- */
function getRankList( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getRankList-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldarena.getRankList","worldarena.getRankList",nil,true)
end










