require "config"

luaj = {}

local callJavaStaticMethod
if Config.MOBILE_ANDROID == 1 then
	callJavaStaticMethod = LuaJavaBridge.callStaticMethod
else
	callJavaStaticMethod = function() LogErr("can not call luaj") end
end

function luaj.checkArguments(args, sig)
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

function luaj.callStaticMethod(className, methodName, args, sig)
	LogErr("enter callJavaStaticMethod")
    local args, sig = luaj.checkArguments(args, sig)
	LogErr("enter callJavaStaticMethod check")
    return callJavaStaticMethod(className, methodName, args, sig)
end

function luaj.isvip(arg)
	local t = {}
	for k,v in string.gmatch(arg, "(%w+)=(%w+)") do
		t[k] = v
	end
	LogInfo("status: " .. t.status .. "  level: " .. t.level .. "  ext: " .. t.ext)
	require "protocoldef.knight.gsp.yuanbao.cvipinfo"
	local vip = CVipInfo.Create()
	vip.status = t.status
	vip.viplevel = t.level
	vip.ext= t.ext
	LuaProtocolManager.getInstance():send(vip)
end

return luaj
