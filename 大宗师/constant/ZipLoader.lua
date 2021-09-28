--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-11-1
--
require("lfs")
require("constant.version")

function getlocalversion()
    local v = CCUserDefault:sharedUserDefault():getStringForKey("VERSION", VERSION)
    if tonumber(v) > tonumber(VERSION) then
        return tostring(v)
    else
        return tostring(VERSION)
    end
end

function saveversion(vernum)
    CCUserDefault:sharedUserDefault():setStringForKey("VERSION", tostring(vernum))
    CCUserDefault:sharedUserDefault():setStringForKey("RES_VERSION", tostring(vernum))
    CCUserDefault:sharedUserDefault():flush()
end

function getresversion()
    return CCUserDefault:sharedUserDefault():getStringForKey("RES_VERSION", tostring(0))
end

local zippath = CCFileUtils:sharedFileUtils():getWritablePath() .. "updateres/"
local function exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

local function rmdir(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path.. "/" ..file
            local attr = lfs.attributes (f)
            if(type(attr) == "table") then
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

local function exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function removeoldres()
    local p = string.sub(zippath, 1, #zippath - 1)
    if (tonumber(getlocalversion()) > tonumber(getresversion()) or tonumber(getresversion()) == 0) and exists(p) then
        rmdir(p)
        CCUserDefault:sharedUserDefault():setStringForKey("RES_VERSION", tostring(getlocalversion()))
        CCUserDefault:sharedUserDefault():flush()
    else
        print("no old res")
    end
end

--
function ziploader(zipname)
    local updatezip = zippath .. zipname
--    print(updatezip)
    if exists(updatezip) then
        CCLuaLoadChunksFromZIP(updatezip)
    else
        CCLuaLoadChunksFromZIP(zipname)
    end
end

