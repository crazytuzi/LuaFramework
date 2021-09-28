
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    if(device.platform ~= "mac" and device.platform ~= "windows") then
        print("log")
        NetworkHelper.request(ServerInfo.LOG_URL, {
            info = errorMessage .. "       " .. debug.traceback("", 2),

        },function() end, "GET", true)
    end
end
CCLuaLoadChunksFromZIP("game/constant.zip")
require("constant.ZipLoader")
removeoldres()

require("app.MyApp").new():run()