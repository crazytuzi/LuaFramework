-- 每日计数,每日行为限制

function packetHandlerCounter()
	local tempArrayCount = 0;
	local counter = {};
	local counterArray = {};
	local counterActivity = {};

-- 统计计数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		counter[i] = networkengine:parseInt();
	end
-- 统计计数数组
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		counterArray[i] = ParseCounterArray();
	end
-- 限时活动完成情况(当前只有充值与消耗)
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		counterActivity[i] = networkengine:parseInt();
	end

	CounterHandler( counter, counterArray, counterActivity );
end

