local callJavaStaticMethod = CCLuaJavaBridge.callStaticMethod
local CreateNewFunction = function(args, i, func)
  args[i] = function(retdata)
    print([[



]])
    print("->CreateNewFunction:\n")
    print("retdata:", retdata)
    print([[



]])
    if retdata then
      local len = #retdata
      local a = loadstring(retdata)()
      dump(a, "a")
      if type(a) == "table" and #a > 1 then
        func(unpack(loadstring(retdata)()))
      else
        func(a)
      end
    else
      func()
    end
  end
end
local function checkArguments(args, sig)
  if type(args) ~= "table" then
    args = {}
  end
  if sig then
    return args, sig
  end
  sig = {"("}
  for i, v in ipairs(args) do
    local t = type(v)
    if t == "number" then
      sig[#sig + 1] = "F"
    elseif t == "boolean" then
      sig[#sig + 1] = "Z"
    elseif t == "function" then
      sig[#sig + 1] = "I"
      CreateNewFunction(args, i, v)
    else
      sig[#sig + 1] = "Ljava/lang/String;"
    end
  end
  sig[#sig + 1] = ")Ljava/lang/String;"
  return args, table.concat(sig)
end
function callStaticMethodJava(className, methodName, args, sig)
  local args, sig = checkArguments(args, sig)
  printInfo([[
luaj.callStaticMethod("%s",
	"%s",
	args,
	"%s"]], className, methodName, sig)
  return callJavaStaticMethod(className, methodName, args, sig)
end
