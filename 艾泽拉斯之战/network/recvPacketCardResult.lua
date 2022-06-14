-- 抽卡结果

function packetHandlerCardResult()
	local tempArrayCount = 0;
	local cardResultType = nil;
	local cardInfo = {};

-- 卡牌数据改变,在什么时刻发生的,参照type.def
	cardResultType = networkengine:parseInt();
-- 卡牌升级数据
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		cardInfo[i] = ParseCardUpgrade();
	end

	CardResultHandler( cardResultType, cardInfo );
end

