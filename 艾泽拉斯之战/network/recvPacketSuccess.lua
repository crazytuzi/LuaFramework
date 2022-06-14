-- 通用操作完成代码

function packetHandlerSuccess()
	local tempArrayCount = 0;
	local responseID = nil;
	local code = nil;

-- 对应的包ID
	responseID = networkengine:parseInt();
-- 成功码
	code = networkengine:parseInt();

	SuccessHandler( responseID, code );
end

