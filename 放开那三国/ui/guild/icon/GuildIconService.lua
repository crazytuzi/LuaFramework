-- Filename: GuildIconService.lua
-- Author: bzx
-- Date: 2015-1-15
-- Purpose: 军团军旗

module("GuildIconService", package.seeall)

--[[
	@desc: 			修改军团军旗
	@p_callback: 	修改成功的回调
	@p_params:{
		iconId		军团军旗Id	
	}
	@return:		nil
--]]
function guildModifyIcon(p_callback, p_params)
	local handle = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if p_callback ~= nil then
			p_callback()
		end
	end
	local args = Network.argsHandlerOfTable(p_params)
	Network.rpc(handle, "guild.modifyIcon", "guild.modifyIcon", args, true)
end