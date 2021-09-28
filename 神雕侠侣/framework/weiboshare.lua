WeiboShare = {}

function WeiboShare.Result(result)
	LogInfo("WeiboShare.Result result=" .. tostring(result))
	if result then
		require "protocoldef.knight.gsp.xiake.csendweiboshare"		
    	local share = CSendWeiBoShare.Create()
    	LuaProtocolManager.getInstance():send(share)
	end
end

return WeiboShare
