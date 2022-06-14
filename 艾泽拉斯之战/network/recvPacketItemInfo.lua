-- 物品信息

function packetHandlerItemInfo()
	local tempArrayCount = 0;
	local opcode = nil;
	local bagType = nil;
	local items = {};

-- 操作类型1,add,2,update
	opcode = networkengine:parseInt();
-- 包裹类型
	bagType = networkengine:parseInt();
-- 物品信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		items[i] = ParseItemInfoData();
	end

	ItemInfoHandler( opcode, bagType, items );
end

