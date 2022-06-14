-- 同步服务器时间

function packetHandlerTime()
	local tempArrayCount = 0;
	local time = nil;
	local timezone = nil;
	local refleshDays = nil;
	local serverBeginTime = nil;

-- 服务器当前时间
	time = networkengine:parseUInt64();
-- 时区，值为0~24，减去12，再取相反数，就是UTC
	timezone = networkengine:parseInt();
-- 服务器开服到现在刷新数，用于伤害排行榜
	refleshDays = networkengine:parseInt();
-- 服务器开服那天的零点时刻
	serverBeginTime = networkengine:parseUInt64();

	TimeHandler( time, timezone, refleshDays, serverBeginTime );
end

