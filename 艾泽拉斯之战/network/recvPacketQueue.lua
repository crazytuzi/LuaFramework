-- 登录队列

function packetHandlerQueue()
	local tempArrayCount = 0;
	local num = nil;
	local time = nil;

-- 前面有多少人
	num = networkengine:parseInt();
-- 开始计时时间
	time = networkengine:parseUInt64();

	QueueHandler( num, time );
end

