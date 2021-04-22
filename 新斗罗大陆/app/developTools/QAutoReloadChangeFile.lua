
--[[
	

]]

local scheduler = require("framework.scheduler")
local socket = require "socket"

local QAutoReloadChangeFile = class("QAutoReloadChangeFile")

function QAutoReloadChangeFile:ctor(  )
	-- body
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local udp, err = socket.udp()
    if udp then
        udp:settimeout(0)
        udp:setsockname("127.0.0.1",2014)
    end
    self.autoCodeConn = udp
    scheduler.scheduleGlobal(handler(self, self._doAutoReLoad),0.5)


end

function QAutoReloadChangeFile:clearCache( fileName )
	-- body
	
	q[fileName] = nil
	local navigationManager= app:getNavigationManager()
	for _,v in pairs(navigationManager._layersAndControllers) do
		local controller = v[2]
		local controllerClassCache = controller and controller._controllerClassCache or {}
		local transitionClassCache = controller and controller._transitionClassCache or {}
		-- printTable(controllerClassCache)
		if controllerClassCache[fileName] then
			print("clear controllerClassCache  ",fileName)
			controllerClassCache[fileName] = nil
			return true
		end
		if transitionClassCache[fileName] then
			print("clear transitionClassCache ",fileName)
			transitionClassCache[fileName] = nil
			return true
		end
	end
end
function QAutoReloadChangeFile:_doAutoReLoad(  )
	-- body
	local filePathStr, client_address, client_port = self.autoCodeConn:receivefrom()
	if not filePathStr then
		return
	end

	local filePathArr = string.split(filePathStr, ";")
	print(filePathStr)
	printTable(filePathArr)
	for _,filePath in pairs(filePathArr) do
		xpcall(function()
	        if(filePath and #filePath > 0)then
	            --处理.lua后缀的文件
	            print("----------------------111------------------------------")
	            print("--------------- auto reload lua file ---------------")
	            print(filePath)
	            if(string.sub(filePath, -4) == ".lua") then
	            	local isNeedReload = false
	                local luaFile = filePath
	                luaFile = string.gsub(luaFile, "\\", "%/")
	                luaFile = string.gsub(luaFile, ".*/scripts/", "")
	                luaFile = string.gsub(luaFile, "%/", "%.")
	                luaFile = string.gsub(luaFile, "%.lua$", "")
	                print("doAutoReLoad -> " .. luaFile)

	                package.loaded[luaFile] = nil
	                
	                --
	                string.gsub(luaFile,".*%.(.*)",function ( fileName )
	                	-- body
	                	isNeedReload = self:clearCache(fileName)
	                end)

	                if not isNeedReload then
	                	import(luaFile)
	                end
	            elseif(string.sub(filePath, -5) == ".ccbi") then
	            	QCCBDataCache:sharedCCBDataCache():removeAllData()
	            end
	        end
    	end, debug.traceback) 
	end
	-- self.autoCodeConn:sendto("success", client_address, client_port)
end
return QAutoReloadChangeFile