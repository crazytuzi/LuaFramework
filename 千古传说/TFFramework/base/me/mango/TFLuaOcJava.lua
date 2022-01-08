TFLuaOcJava = {}
SCREEN_ORIENTATION_LANDSCAPE = 0
SCREEN_ORIENTATION_PORTRAIT  = 1


local callStaticMethod

if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    if CCLuaJavaBridge and CCLuaJavaBridge.callStaticMethod then 
        callStaticMethod = CCLuaJavaBridge.callStaticMethod
    else 
        callStaticMethod = function() print("TFLuaJava: This platform is not support.") end
    end
elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    if CCLuaObjcBridge and CCLuaObjcBridge.callStaticMethod then 
        callStaticMethod = CCLuaObjcBridge.callStaticMethod
    else 
        callStaticMethod = function() return false, -7 end
    end 
end

local function checkArguments(args, sig)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end

    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")V"

    return args, table.concat(sig)
end

function TFLuaOcJava.callStaticMethod(className, methodName, args,sig)
    if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        local args, sig = checkArguments(args, sig)
       print("==JAVA=>TFLuaOcJava.callStaticMethod(\"%s\",\n\t\"%s\",\n\targs,\n\t\"%s\"", className, methodName, sig)
        return callStaticMethod(className, methodName, args, sig)
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local ok, ret = callStaticMethod(className, methodName, args)
        if not ok then
            local msg = string.format("==OC=>TFLuaOcJava.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                    className, methodName, tostring(args), tostring(ret))
            if ret == -1 then
                print(msg .. "INVALID PARAMETERS")
            elseif ret == -2 then
                print(msg .. "CLASS NOT FOUND")
            elseif ret == -3 then
                print(msg .. "TFTHOD NOT FOUND")
            elseif ret == -4 then
                print(msg .. "EXCEPTION OCCURRED")
            elseif ret == -5 then
                print(msg .. "INVALID TFTHOD SIGNATURE")
            elseif ret == -7 then
                print(msg .. "PLATFORM NOT SUPPORT")
            else
                print(msg .. "UNKNOWN")
            end
        end
        return ok, ret
    end
end

function TFLuaOcJava.disableDeviceSleep(bNotSleep)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("AppController","disableDeviceSleep",{notSleep = bNotSleep})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/HeroesLegends","disableDeviceSleep",{bNotSleep})
    end
end

function TFLuaOcJava.enableScreenAutoRotate(autoRotate)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("RootViewController","enableScreenAutoRotate",{bautoRotate = autoRotate})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/HeroesLegends","enableScreenAutoRotate",{autoRotate})
    end
end

function TFLuaOcJava.setScreenOrientation(orientation)
    TFLuaOcJava.enableScreenAutoRotate(false)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("RootViewController","setScreenOrientation",{norientation = orientation})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/HeroesLegends","setScreenOrientation",{orientation})
    end
end


return TFLuaOcJava

