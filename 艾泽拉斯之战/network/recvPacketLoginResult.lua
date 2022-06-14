-- 登陆结果包

function packetHandlerLoginResult()
	local tempArrayCount = 0;
	local result = nil;
	local exception = nil;

-- 登陆结果
	result = networkengine:parseInt();
-- 登陆异常原因
	local strlength = networkengine:parseInt();
if strlength > 0 then
		exception = networkengine:parseString(strlength);
else
		exception = "";
end

	LoginResultHandler( result, exception );
end

