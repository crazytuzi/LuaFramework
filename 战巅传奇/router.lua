package.path = package.path .. ";script/"
cc.FileUtils:getInstance():setPopupNotify(false)

-- if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
--     cc.SocketManager:setTICK(-1000)
-- else
--     cc.SocketManager:setTICK(-200)
-- end

collectgarbage("collect")  --运行一个完整的垃圾回收周期
-- avoid memory leak
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

require("base.GameEvent")
require("base.GameMain").new():run()

function require_ex( _mname )
    if DEBUG>0 and device.platform == "windows" then
        print( string.format("require_ex = %s", _mname) )
        if package.loaded[_mname] then
        print( string.format("require_ex module[%s] reload", _mname))
        end
        package.loaded[_mname] = nil
    end
    return require( _mname )
end