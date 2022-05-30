local GameHTTPNetWork = class("GameHTTPNetWork")

function GameHTTPNetWork:SendData(playerID, serverID, requestID, tableData, callback, errorcb)
	local net = require("utility.HttpNetWorkBase").new()
	net:SendData(playerID, serverID, requestID, tableData, callback, errorcb)
end

function GameHTTPNetWork:SendRequest(requestID, msgData, callback, errorcb, url)
	local net = require("utility.HttpNetWorkBase").new()
	--[[
	if device.platform == "mac" or device.platform == "windows" then
		local uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
		local q = string.find(uac, "_")
		if q == nil then
			msgData.uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
			msgData.acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")
		end
	end
	]]
	if game.player.m_serverID and game.player.m_serverID ~= "" then
		msgData.idx = game.player.m_serverID or ""
	end
	
	if game.player.m_accountAdd and game.player.m_accountAdd~="" then
		if msgData.uac and msgData.uac~="" then
			msgData.uac = msgData.uac .. game.player.m_accountAdd
		end
		if msgData.acc and msgData.acc~="" then
			msgData.acc = msgData.acc .. game.player.m_accountAdd
		end
	end
	net:SendData(playerID, sessionID, requestID, msgData, callback, errorcb, url)
end

return GameHTTPNetWork