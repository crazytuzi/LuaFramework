--[[--
	与函数处理相关的方法

	--By: yun.bo
	--2013/7/8
]]

TFFunction = {}
function TFFunction.call(func, ...)
	if func and type(func) == 'function' then
		return func(...)
	end
end

if DEBUG then
	local insHttp = TFClientNetHttp:GetInstance() 
	local httpURL
	local logRequest
	local function lazyInitHttpLog()
		httpURL = 'http://' .. me.svnServerIP .. ':' .. me.svnServerPort .. '/'
		logRequest = httpURL .. 'log?op=1&message="'
	end

	print_ = print
	function print(...)
		local arg = {...}
		local ret = ''
		for k, v in pairs(arg) do
			local str = serialize(v)
			ret = ret .. '   ' .. str
		end
		print_(ret)
		if ENABLE_DEBUG_HTTPMSG == 1 then 
			 -- todo: init once
			lazyInitHttpLog()
			insHttp:httpRequest(TFHTTP_TYPE_GET, logRequest .. ret..'"')
		end
		if TFDirector and DEBUG == 1 then
			TFDirector:writeToDebugerLayer(ret)
		end
		if decoda_output ~= nil then
			return ret
		end
	end
else
	print_ = print
	function print(...)
		local arg = {...}
		local ret = ''
		for k, v in pairs(arg) do
			local str = serialize(v)
			ret = ret .. '   ' .. str
		end
		print_(ret)
	end
end

if decoda_output ~= nil then
    local de_print = print
    function print(...)
        local ret = de_print(...)
        if ret then 
            decoda_output(ret)
        end
    end
end

function TO_CCPT(b2v) 
	return CCPoint(b2v.x*PTM_RATIO, b2v.y*PTM_RATIO) 
end

function TO_B2V(ccpt) 
	return b2Vec2(ccpt.x/PTM_RATIO, ccpt.y/PTM_RATIO) 
end


function isNaN(x)
	return x ~= x
end