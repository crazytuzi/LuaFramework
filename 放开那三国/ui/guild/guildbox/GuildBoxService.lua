-- FileName: GuildBoxService.lua 
-- Author: licong 
-- Date: 14-11-13 
-- Purpose: 军团宝箱服务器接口


module("GuildBoxService", package.seeall)

-- /**
-- * 军团宝箱
-- * 
-- * @return array 掉落东西
-- * <code>
-- * {
-- *     'item'
-- *     {
-- *         $itemTmplId => $num
-- *     }
-- *     'hero'
-- *     {
-- *         $htid => $num
-- *     }
-- *     'treasFrag'
-- *     {
-- *         $treasFragTmplId => $num
-- *     }
-- *     'silver' => $num
-- *     'soul' => $num
-- * }
-- * </code>
-- */
function lottery(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("lottery---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	Network.rpc(requestFunc, "guild.lottery", "guild.lottery", nil, true)
end
