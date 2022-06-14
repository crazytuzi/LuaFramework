-- 请求的攻略录像玩家信息

function packetHandlerGlobalReplaySummary()
	local tempArrayCount = 0;
	local battleType = nil;
	local progressID = nil;
	local name = nil;
	local icon = nil;

-- 战斗类型
	battleType = networkengine:parseInt();
-- 第几关
	progressID = networkengine:parseInt();
-- 最牛玩家名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		name = networkengine:parseString(strlength);
else
		name = "";
end
-- 最牛玩家图标
	icon = networkengine:parseInt();

	GlobalReplaySummaryHandler( battleType, progressID, name, icon );
end

