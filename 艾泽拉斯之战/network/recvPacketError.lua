-- 通用错误代码

function packetHandlerError()
	local tempArrayCount = 0;
	local responseID = nil;
	local code = nil;

-- 对应的包ID
	responseID = networkengine:parseInt();
-- 错误代码
	code = networkengine:parseInt();

	ErrorHandler( responseID, code );
end

