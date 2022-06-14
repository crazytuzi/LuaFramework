-- 聊天同步

function packetHandlerChat()
	local tempArrayCount = 0;
	local channel = nil;
	local chatType = nil;
	local playerID = nil;
	local level = nil;
	local icon = nil;
	local vip = nil;
	local miracle = nil;
	local talker = nil;
	local content = nil;
	local params = {};

-- 频道
	channel = networkengine:parseInt();
-- 聊天类型
	chatType = networkengine:parseInt();
-- 发起者的id
	playerID = networkengine:parseInt();
-- 发起者等级
	level = networkengine:parseInt();
-- 发起者头像
	icon = networkengine:parseInt();
-- 发起者的vip
	vip = networkengine:parseInt();
-- 发起者的奇迹等级
	miracle = networkengine:parseInt();
-- 发起者名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		talker = networkengine:parseString(strlength);
else
		talker = "";
end
-- 内容
	local strlength = networkengine:parseInt();
if strlength > 0 then
		content = networkengine:parseString(strlength);
else
		content = "";
end
-- 参数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		params[i] = networkengine:parseInt();
	end

	ChatHandler( channel, chatType, playerID, level, icon, vip, miracle, talker, content, params );
end

