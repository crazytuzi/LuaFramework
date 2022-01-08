function __G__TRACKBACK__(msg)
    print("----------------------------------------");
    local msg = "LUA ERROR: " .. tostring(msg) .. "/n"
    msg = msg .. debug.traceback()
    print(msg)
    TFLOGERROR(msg)
    print("----------------------------------------");
end

require('TFFramework.base.me.mango.TFLuaOcJava')
require('TFFramework.utils.TFDeviceInfo')

local updatePath = CCFileUtils:sharedFileUtils():getWritablePath()

local tblResPath = {}
if TFConfigInfo:GetPlatformID() == TF_PLATFORM_IOS then
    updatePath = updatePath .. '../Library/'
    tblResPath =
    {
        updatePath .. "TFDebug/",
    }
elseif TFConfigInfo:GetPlatformID() == TF_PLATFORM_ANROID then
    local sdPath = TFDeviceInfo.getSDPath()
    if sdPath and #sdPath >1 then   
        local  sPackName = TFDeviceInfo.getPackageName()
        updatePath = sdPath .."playmore/" .. sPackName .. "/"
    end
    tblResPath =
    {
        updatePath,
        updatePath     .. "TFDebug/",
    }
else

    local projectDire = updatePath .. "../../Resource_D/"

    tblResPath =
    {    
        "./Cocos/Resource/",
        "./Cocos/TFFramework/",
        "./Cocos/",
    }
end

local function ResPathConfig()
    for i = #tblResPath, 1, -1  do
        TFFileUtil:addPathToSearchAtFront(tblResPath[i])
        print("add path: ", tblResPath[i])
    end
    if(TFFileUtil:existFile("LuaScript/TFPathConfig.lua")) then
        local tPath = require("LuaScript.TFPathConfig")
        local tUpdate
        local tPackage
        if tPath.Update == nil and tPath.Package == nil then
            tUpdate = tPath
            tPackage = tPath
        else
            tUpdate = tPath.Update
            tPackage = tPath.Package
        end
        
        for i , k in pairs(tUpdate) do
            CCFileUtils:sharedFileUtils():addSearchPath(updatePath..k)
        end
        for i , k in pairs(tPackage) do
            CCFileUtils:sharedFileUtils():addSearchPath(k)
        end
        package.loaded["LuaScript.TFPathConfig"] = nil
    end
end

xpcall(ResPathConfig, __G__TRACKBACK__);
