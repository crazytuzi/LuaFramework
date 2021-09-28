--//Util.lua

Enum = {};
function new(self, nBase)	
	local ret = {};
	local _base = nBase or 0;
	local _count = _base;
	setmetatable(ret, Enum)
	Enum.__call = function(self) local nRet = _count;_count = _count + 1; return nRet; end
	ret.check = function(self,nNum)
		return type(nNum) == "number" and nNum >= _base and nNum < _count;
	end
	ret.min = function(self) return _base end
	ret.max = function(self) return _count - 1 end
	return ret
end
setmetatable(Enum, {__call = new })



---------------------------------------------------------
--#public	dice	
--@rate		the rate of success
--@return  ture:the success false:fail
-----------------------------------------------------------
function dice(rate)
	if not rate then return false end
	local num = math.random()
	return num < rate
end

--@note：用字符串执行类方法
function execMethod(methodName,...)
	local index=string.find(methodName,"[.]")
	if (not index) then	return	end

	local clsName=string.sub(methodName,1,index-1)
	local sglStr=clsName..".getInstance"
	local code,inst2=pcall(loadstring("local inst1="..sglStr.." return inst1"))
	local instance
	if (type(inst2)=="function") then
		instance=inst2()
	else
		local code,inst2=pcall(loadstring("local inst1="..clsName.." return inst1"))
		if (type(inst2)=="function") then
			instance=inst2()
		end
	end
	local code,fun=pcall(loadstring("local fun1="..methodName.." return fun1"))
	if (instance and type(fun)=="function") then
		return fun(instance,unpack({...}))
	end
end