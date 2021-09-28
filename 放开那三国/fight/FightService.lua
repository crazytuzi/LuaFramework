-- FileName: FightService.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗主场景

module("FightService", package.seeall)

--[[
	@des 	:进入对应得副本
	@param 	:callBackFunc 完成回调方法
	@return :
--]]
function getTeamInfo( callBackFunc , copyteam_id)
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			TeamGroupData.setTeamInfo(dictData.ret )
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end
	local args= CCArray:create()
    args:addObject(CCInteger:create(copyteam_id) )
   	Network.rpc(requestFunc, "team.enter", "team.enter", args, true)
end

