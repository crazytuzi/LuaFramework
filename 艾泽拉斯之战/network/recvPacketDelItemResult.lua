-- 删除物品

function packetHandlerDelItemResult()
	local tempArrayCount = 0;
	local bagType = nil;
	local positions = {};

-- 背包类型
	bagType = networkengine:parseInt();
-- 位置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		positions[i] = networkengine:parseInt();
	end

	DelItemResultHandler( bagType, positions );
end

