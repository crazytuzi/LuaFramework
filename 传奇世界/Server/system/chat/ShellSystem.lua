--ShellSystem.lua
--GM命令

ShellSystem = class(EventSetDoer, Singleton)

function ShellSystem:__init()
	self._doer = {
			[SHELL_CS_SHELL_COMMAND]	=			ShellSystem.onShellCmd,
		}

	local Datas = require "data.GmWhiteLisDB"
	self._whitePlayerId = {}
	for _,id in pairs(Datas) do
		table.insert(self._whitePlayerId, id)
	end
end

function ShellSystem:parseWhiteData()
	package.loaded["data.GmWhiteLisDB"]=nil
	local tmpData = require "data.GmWhiteLisDB"
	self._whitePlayerId = {}
	if tmpData then
		for _,id in pairs(tmpData) do
			table.insert(self._whitePlayerId, id)
		end
	end
end

function ShellSystem:onShellCmd(buffer1)
	-- if not g_isOpenShellCmd then
	-- 	return
	-- end
	
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("ShellCommandProtocol" , pbc_string)
	if not req then
		print('ShellSystem:onShellCmd parse failed: '..tostring(err))
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("GM命令，玩家不存在")
		return
	end
	local roleId = player:getID()
	
	local playerId = player:getSerialID()
	local cmdTxt = req.cmdText

	--if not table.contains(self._whitePlayerId, playerId) then
	 --	return
	--end

	local cmd = nil
	local cmdParams = {}
	for w in string.gmatch(cmdTxt, "[%s]*([^%s]+)") do
		if cmd then
			table.insert(cmdParams, w)
		else
			cmd = w
			table.insert(cmdParams, playerId)
		end
	end
	if not cmd then
		--logger:error("Event CS_Shell_Command: empty command")
		return
	end
	local method = GMSystem[cmd]

	if type(method) == "function" then
		local printCMD = "#" .. cmd .." "
		for i = 2, #cmdParams - 1 do
			printCMD = printCMD .. cmdParams[i] .. " "
		end
		print("gm cmd:"..cmd, printCMD, playerId)
		local ret = method(GMSystem, unpack(cmdParams))
	end
end

function ShellSystem:onShellCmd2(playerId,cmdTxt)


	
end

function ShellSystem:shellCmd(cmdStr)
	local command = unserialize(cmdStr)
	local playerId = command.playerId
	local cmdTxt = command.cmdTxt

	local cmd = nil
	local cmdParams = {}
	for w in string.gmatch(cmdTxt, "[%s]*([^%s]+)") do
		if cmd then
			table.insert(cmdParams, w)
		else
			cmd = w
			table.insert(cmdParams, playerId)
		end
	end
	if not cmd then
		return
	end

	local method = GMSystem[cmd]
	
	if type(method) == "function" then
		print("gm cmd ", cmd)
		local player= g_entityMgr:getPlayer(playerId)
		local ret = method(GMSystem, unpack(cmdParams))
	end
end

function ShellSystem.getInstance()
	return ShellSystem()
end

g_eventMgr:addEventListener(ShellSystem.getInstance())