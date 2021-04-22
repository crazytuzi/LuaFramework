
--[[
	

]]

local scheduler = require("framework.scheduler")
local socket = require "socket"

local QAutoReloadChangeCodeFile = class("QAutoReloadChangeCodeFile")

function QAutoReloadChangeCodeFile:ctor(  )
	-- body
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local udp, err = socket.udp()
    if udp then
        udp:settimeout(0)
        udp:setsockname("127.0.0.1",2014)
    end
    self.autoCodeConn = udp
    -- scheduler.scheduleGlobal(handler(self, self._doAutoReLoad),0.5)


end

function QAutoReloadChangeCodeFile:clearCache( fileName )
	-- body
	
	q[fileName] = nil
	local navigationManager= app:getNavigationManager()
	for _,v in pairs(navigationManager._layersAndControllers) do
		local controller = v[2]
		local controllerClassCache = controller and controller._controllerClassCache or {}
		local transitionClassCache = controller and controller._transitionClassCache or {}
		-- printTable(controllerClassCache)
		if controllerClassCache[fileName] then
			controllerClassCache[fileName] = nil
			return true
		end
		if transitionClassCache[fileName] then
			transitionClassCache[fileName] = nil
			return true
		end
	end
end
function QAutoReloadChangeCodeFile:doAutoReLoad(  )
	-- body
	local info = debug.getinfo(1, "S")
	local path = info.source
	path = string.sub(path, 2, -1) -- 去掉开头的"@"
	path = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
	
	-- Volumes/Macintosh/Users/zzh/Documents/dldl/dldl_client/Scripts/../Client/scripts/app/developTools/
	local paths = string.split(path,"/../")
	path = nil
	path = string.match(paths[1], "^.*/")
    path = "/"..path.."Client/scripts/app"
	local LUA_PATH = path
	local getLuaFileInfo = io.popen('find * ' .. LUA_PATH)
	local luaFileTable = {};
	for file in getLuaFileInfo:lines() do 
		if string.find(file,"Client") and not string.find(file,"MyApp.lua") 
			and not string.find(file,"utils") and not string.find(file,"QYuewenSDK_IngameUI_Implementation.lua") 
			and not string.find(file,"QSQLiteDataBase.lua") and not string.find(file,"app/network") then
			if string.find(file,"%.lua$") then
				table.insert(luaFileTable,file);
			end
		end
		
	end

	local filePathArr = luaFileTable
	for _,filePath in pairs(filePathArr) do
		xpcall(function()
	        if(filePath and #filePath > 0)then
	            --处理.lua后缀的文件
	            if(string.sub(filePath, -4) == ".lua") then
	            	local isNeedReload = false
	                local luaFile = filePath
	                luaFile = string.gsub(luaFile, "\\", "%/")
	                luaFile = string.gsub(luaFile, ".*/scripts/", "")
	                luaFile = string.gsub(luaFile, "%/", "%.")
	                luaFile = string.gsub(luaFile, "%.lua$", "")

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
return QAutoReloadChangeCodeFile