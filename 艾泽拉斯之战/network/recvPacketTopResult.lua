-- 伤害挑战结果

function packetHandlerTopResult()
	local tempArrayCount = 0;
	local topType = nil;
	local maxScore = nil;
	local currentScore = nil;
	local rank = nil;

-- 排行榜类型
	topType = networkengine:parseInt();
-- 最高积分
	maxScore = networkengine:parseInt();
-- 本次积分
	currentScore = networkengine:parseInt();
-- 当前排名
	rank = networkengine:parseInt();

	TopResultHandler( topType, maxScore, currentScore, rank );
end

