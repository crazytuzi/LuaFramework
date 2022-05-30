require("lfs")
require("constant.version")

require("config")
require("framework.init")
require("cocos.init")
--require("framework.debug")
--device = require("framework.device")

--获取本地版本号
function getlocalversion()
	local v = cc.UserDefault:getInstance():getIntegerForKey("VERSION", VERSION)
	if v > VERSION then
		return v
	else
		return VERSION
	end
end

function saveversion(vernum)
	cc.UserDefault:getInstance():setIntegerForKey("VERSION", vernum)
	cc.UserDefault:getInstance():setIntegerForKey("RES_VERSION", vernum)
	cc.UserDefault:getInstance():flush()
end

function getresversion()
	return cc.UserDefault:getInstance():getIntegerForKey("RES_VERSION", 0)
end

local zippath = cc.FileUtils:getInstance():getWritablePath() .. "updateres/"

local exists = function(path)
	local attr = lfs.attributes(path)
	return attr ~= nil
	--[[
	local file,err = io.open(path,"rb")
	if file ~= nil then
		io.close(file)
		return true
	end
	return false
	]]
end

local function rmdir(path)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)
			if type(attr) == "table" then
				if attr.mode == "directory" then
					rmdir(f)
				else
					print("rm " .. f)
					os.remove(f)
				end
			end
		end
	end
end

function removeoldres()
	local p = string.sub(zippath, 1, #zippath - 1)
	if (getlocalversion() > getresversion() or getresversion() == 0) and exists(p) then
		rmdir(p)
		cc.UserDefault:getInstance():setIntegerForKey("RES_VERSION", getlocalversion())
		cc.UserDefault:getInstance():flush()
	else
		print("no old res")
	end
end

function requireLua(path)
	local isExist = false
	isExist = exists(path)
	if isExist then
		for file in lfs.dir(path) do
			if file ~= "." and file ~= ".." then
				local f = path .. "/" .. file
				local attr = lfs.attributes(f)
				if type(attr) == "table" then
					if attr.mode == "directory" then
						requireLua(f)
					else
						local gamaPath = zippath .. "src/"
						local tempFile = string.sub(f, #gamaPath + 1, #f)
						local pos, _ = string.find(tempFile, ".lua")
						if pos ~= nil and pos > 0 then
							local luaPath = string.sub(tempFile, 1, #tempFile - 4)
							luaPath = string.gsub(luaPath, "/", ".")
							if package.preload[luaPath] ~= nil then
								package.preload[luaPath] = nil
							end
							if package.loaded[luaPath] ~= nil then
								package.loaded[luaPath] = nil
							end
						end
					end
				end
			end
		end
	end
end

function ziploader(zipname)
	local updatezip = zippath .. zipname
	if exists(updatezip) then
		cc.LuaLoadChunksFromZIP(updatezip)
	else
		cc.LuaLoadChunksFromZIP(zipname)
	end
	local tmpPath = string.sub(updatezip, 1, #updatezip - 4)
	requireLua(tmpPath)
end