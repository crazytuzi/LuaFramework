function __G__TRACKBACK__(errorMessage)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
	print(debug.traceback("", 2))
	print("----------------------------------------")
end

package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)

local rootpath = cc.FileUtils:getInstance():getWritablePath() .. "updateres/"
cc.FileUtils:getInstance():addSearchPath(rootpath)

if BIT_64 == 1 then
	cc.LuaLoadChunksFromZIP("src/framework64.zip")
	cc.LuaLoadChunksFromZIP("src/cocos64.zip")
	cc.LuaLoadChunksFromZIP("src/constant64.zip")
else
	cc.LuaLoadChunksFromZIP("src/framework.zip")
	cc.LuaLoadChunksFromZIP("src/cocos.zip")
	cc.LuaLoadChunksFromZIP("src/constant.zip")
end

require("constant.ZipLoader")

removeoldres()

if BIT_64 == 1 then
	ziploader("src/app64.zip")
	ziploader("src/sdk64.zip")
	ziploader("src/update64.zip")
	ziploader("src/utility64.zip")
	ziploader("src/network64.zip")
	ziploader("src/data64.zip")
	ziploader("src/game64.zip")
else
	ziploader("src/app.zip")
	ziploader("src/sdk.zip")
	ziploader("src/update.zip")
	ziploader("src/utility.zip")
	ziploader("src/network.zip")
	ziploader("src/data.zip")
	ziploader("src/game.zip")
end

require("app.MyApp").new():run()