 --
 --
 -- @authors shan 
 -- @date    2014-05-06 17:47:47
 -- @version 
 --



local GameHTTPNetWork = class("GameHTTPNetWork")

function GameHTTPNetWork:SendData(playerID, serverID, requestID, tableData , callback, errorcb )
	local net =  require ("utility.HttpNetWorkBase").new()
	net:SendData(playerID, serverID, requestID, tableData , callback, errorcb )
end


--
-- 
--
--  
function GameHTTPNetWork:SendRequest( requestID, msgData, callback, errorcb, url )
	local net =  require ("utility.HttpNetWorkBase").new()

	if(GAME_DEBUG == true) then
		-- mac or win 模拟器使用本地accid
		if(device.platform == "mac" or device.platform == "windows") then
			msgData.uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
			msgData.acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")
			-- msgData.acc = CCUserDefault:sharedUserDefault():getStringForKey("accid")
		end
	end

	if( GAME_DEBUG == true and ANDROID_NO_SDK == true) then
		if(device.platform == "android") then
			msgData.uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
			msgData.acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")
		end
    end

    if CSDKShell.GetSDKTYPE() == SDKType.SIMULATOR then
        msgData.uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
        msgData.acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")
    end
	-- msgData.uac = 1411479369
	-- msgData.acc = "simulate__"..1411479369 --1409989917	
	-- msgData.platformID = "simulate"
	net:SendData(playerID, sessionID, requestID, msgData , callback, errorcb, url )
end

return GameHTTPNetWork


