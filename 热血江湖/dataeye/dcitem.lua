DCItem = { };

--[[道具购买
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	virtualCurrency:购买道具花费的虚拟币数量 long long类型
	currencyType:虚拟币类型 String类型
	consumePoint:消费点
]]
function DCItem.buy(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint)
	if i3k_game_data_eye_valid() then
		DCLuaItem:buy(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint);
	end
end

--[[道具购买
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    virtualCurrency:购买道具花费的虚拟币数量 long long类型
    currencyType:虚拟币类型 String类型
    consumePoint:消费点
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.buyInLevel(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint, levelId)
	if i3k_game_data_eye_valid() then
		DCLuaItem:buyInLevel(itemId, itemType, itemCount, virtualCurrency, currencyType, consumePoint, levelId);
	end
end

--[[获得道具
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	reason:获得道具的原因
]]
function DCItem.get(itemId, itemType, itemCount, reason)
	if i3k_game_data_eye_valid() then
		DCLuaItem:get(itemId, itemType, itemCount, reason);
	end
end

--[[获得道具
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    reason:获得道具的原因
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.getInLevel(itemId, itemType, itemCount, reason, levelId)
	if i3k_game_data_eye_valid() then
		DCLuaItem:getInLevel(itemId, itemType, itemCount, reason, levelId);
	end
end

--[[消耗道具
	itemId:道具ID String类型
	itemType:道具类型 String类型
	itemCount:道具数量 int类型
	reason:消耗道具的原因
]]
function DCItem.consume(itemId, itemType, itemCount, reason)
	if i3k_game_data_eye_valid() then
		DCLuaItem:consume(itemId, itemType, itemCount, reason);
	end
end

--[[消耗道具
    itemId:道具ID String类型
    itemType:道具类型 String类型
    itemCount:道具数量 int类型
    reason:消耗道具的原因
    levelId:当前事件发生时所在的关卡ID
]]
function DCItem.consumeInLevel(itemId, itemType, itemCount, reason, levelId)
	if i3k_game_data_eye_valid() then
		DCLuaItem:consumeInLevel(itemId, itemType, itemCount, reason, levelId);
	end
end

return DCItem;
