-- FileName: GuildService.lua 
-- Author: licong 
-- Date: 15/5/28 
-- Purpose: 军团接口


module("GuildService", package.seeall)

-- /**
-- * 修改军团名
-- *
-- * @param string $name		军团名
-- * @return string $ret		处理结果
-- * 'ok'						成功
-- * 'used'					名称已经使用
-- * 'blank'					名称存在空格
-- * 'harmony'				名称存在敏感词
-- * 'forbidden_guildwar'		报名跨服赛
-- */
function modifyName( p_name, p_callBack)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("modifyName---后端数据")
		if(dictData.err == "ok")then
			print("dictData.ret")
			print_t(dictData.ret)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(p_name))
	Network.rpc(requestFunc, "guild.modifyName", "guild.modifyName", args, true)
end






