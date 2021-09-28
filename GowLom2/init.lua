function DISPATCH_GLOBAL_EVENT(jsonStr)
	xpcall(function ()
		local dispatcher = cc.Director:getInstance():getEventDispatcher()

		if dispatcher.isEnabled(dispatcher) then
			local data = json.decode(jsonStr)
			local eventcustom = cc.EventCustom:new(data.evt)

			eventcustom.setDataString(eventcustom, tostring(data.ex))
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventcustom)
		else
			scheduler.performWithDelayGlobal(function ()
				DISPATCH_GLOBAL_EVENT(jsonStr)

				return 
			end, 0.2)
		end

		return 
	end, __G__TRACKBACK__)

	return 
end

local fileUtils = cc.FileUtils.getInstance(slot0)
local searchPaths = fileUtils.getSearchPaths(fileUtils)
local gameFolder = MirLaunch.currentGameFolder
local gameStoreFolder = MirLaunch.currentGameStorePath
local gameSearchPaths = {
	gameFolder,
	gameFolder .. "/res",
	gameFolder .. "/res/data/",
	gameFolder .. "/rs",
	gameStoreFolder,
	gameStoreFolder .. "res/",
	gameStoreFolder .. "res/data/"
}

for _, path in ipairs(gameSearchPaths) do
	table.insert(searchPaths, 1, path)
end

fileUtils.setSearchPaths(fileUtils, searchPaths)
fileUtils.purgeCachedEntries(fileUtils)
require("G")

local debugErr = nil

if 0 < DEBUG then
	xpcall(function ()
		if device.platform == "android" then
			local tprint = print
			local f = io.open(WRITABLEPATH .. "log.txt", "w")

			function print(...)
				tprint(...)

				for k, v in pairs({
					...
				}) do
					f:write(tostring(v))
					f:write("\t")
				end

				f:write("\n")
				f:flush()

				return 
			end
		end

		if device.platform == "windows" or 0 < DEBUG then
			local console = cc.Director.getInstance(slot0):getConsole()

			console.listenOnTCP(console, 8866)
			console.addCommand(console, {
				help = "execute lua script",
				name = "l"
			}, function (fd, args)
				if type(args) == "string" then
					scheduler.performWithDelayGlobal(function ()
						local func, err = loadstring(args)

						if err then
							print(err)
						else
							func()
						end

						return 
					end, 0)
				end

				return 
			end)
			console.addCommand(slot0, {
				help = "use mir2 say",
				name = "say"
			}, function (fd, args)
				scheduler.performWithDelayGlobal(function ()
					local args = ycFunction:a2u(args, string.len(args))
					args = string.trim(args)

					print(args)
					common.sendGMCmd(args)

					return 
				end, 0)

				return 
			end)
		end

		return 
	end, function (errstr, msg)
		debugErr = "err: " .. errstr
		debugErr = debugErr .. "\n"

		return 
	end)
end

xpcall(function ()
	local function appRun()
		require("an.init")
		require("mir2.init")

		return 
	end

	searchPaths()

	if 0 < DEBUG then
		print("====searchPaths====")

		for k, v in pairs(searchPaths) do
			print("*  " .. v)
		end

		print("===================")
	end

	return 
end, __G__TRACKBACK__)

return 
