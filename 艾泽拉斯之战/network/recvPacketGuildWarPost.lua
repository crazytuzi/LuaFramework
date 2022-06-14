-- 据点信息的回复

function packetHandlerGuildWarPost()
	local tempArrayCount = 0;
	local index = nil;
	local inspireCount = nil;
	local step = nil;
	local fighting = {};
	local precent = {};
	local players = {};

-- postID
	index = networkengine:parseInt();
-- 鼓舞次数
	inspireCount = networkengine:parseInt();
-- 第几梯队
	step = networkengine:parseInt();
-- 是否在战斗
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		fighting[i] = networkengine:parseInt();
	end
-- 每个防守玩家当前血量百分比
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		precent[i] = networkengine:parseInt();
	end
-- 玩家信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		players[i] = ParseLadderPlayer();
	end

	GuildWarPostHandler( index, inspireCount, step, fighting, precent, players );
end

