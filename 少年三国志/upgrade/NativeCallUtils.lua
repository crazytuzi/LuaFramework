

local function call_luaoc(className, methodName, args)
	local callStaticMethod = CCLuaObjcBridge.callStaticMethod

	local ok, ret = callStaticMethod(className, methodName,args)

    if ok then
    	return ok, ret
    else
        print("call native failed..." .. tostring(ret))
         local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            print(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            print(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            print(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            print(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            print(msg .. "INVALID METHOD SIGNATURE")
        else
            print(msg .. "UNKNOWN")
        end
        return ok, ret
    end
end


local function checkArguments(args, sig, returnType)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end

    sig = {"("}
    for i, v in ipairs(args) do

        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "I"  -- 'F' for number ,but we always use "interger" lua
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end

    local returnSig = 'V'
    if returnType  ~= nil then
    	if returnType == "boolean" then
    		returnSig = 'Z'
    	elseif returnType == "int" then
    		returnSig = 'I'
    	elseif returnType == "string" then
    		returnSig = 'Ljava/lang/String;'
    	end
    end

    sig[#sig + 1] = ")" .. returnSig

    return args, table.concat(sig)
end


local function call_luaj(className, methodName, args, returnType)
	local callJavaStaticMethod = CCLuaJavaBridge.callStaticMethod
    local sig 
	args, sig = checkArguments(args, sig, returnType)
	print("call_luaj:" .. className .. "," .. methodName .. tostring(sig))
	local ok, ret = callJavaStaticMethod(className, methodName, args, sig)

    if ok then
    	return ok, ret
    else
        print("call java native failed..." ..tostring(ret))
        return ok, ret
    end
end


local function convertIosParam(param)
	local p = {}
	for i, v in ipairs(param) do 
		for k, v2 in pairs(v) do
			p[k] = v2
			break
		end
	end
	return p
end

local function convertAndroidParam(param)
    local p = {}
	for i, v in ipairs(param) do 
		for k, v2 in pairs(v) do
			table.insert(p, v2)
			break
		end
	end
	return p
end

local function convertWPParam(param)
    if type(param) ~= "table" then 
        return nil
    end

    for i, v in ipairs(param) do 
        for k, v2 in pairs(v) do
            if type(v2) == "function" then
                return v2
            end
        end
    end

    return nil
end


local NativeCallUtils = {}

function NativeCallUtils.call(platform, className, func, param, returnType)


	if platform == "ios" then
		--ios

		if param ~= nil then
			param = convertIosParam(param)

		    local ok, ret = call_luaoc(className, func, param)
		    return ret, ok
		else
		    local ok, ret = call_luaoc(className, func)
		    return ret, ok
		end

	elseif platform == "android" then
		--android
	
		if param ~= nil then
			param = convertAndroidParam(param)
		    local ok, ret = call_luaj(className, func, param,  returnType)
		    return ret, ok
		else
		    local ok, ret = call_luaj(className, func, param,  returnType)
		    return ret, ok
		end

    elseif platform == "wp8" or platform == "winrt" then
        local ret
        local funHandler = convertWPParam(param)
      --  print("func:"..func..", param="..(json.encode(param) or "nil"))
        if funHandler and func == "registerScriptHandler" then 
            WP8Native:registerWP8Call(funHandler)
            ret = 0
        else
            ret = WP8Native:callSdkFuntion(func, json.encode(param)) or "nil"
        end
        return ret, true
	end

end


return NativeCallUtils


