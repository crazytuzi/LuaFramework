-- 货币兑换协议

function sendAgiotage(agiotageType, adventureID)
	networkengine:beginsend(37);
-- 兑换类型,参照typedef的AGIOTAGE_TYPE
	networkengine:pushInt(agiotageType);
-- 重置副本id号，如果是兑换货币，填写-1
	networkengine:pushInt(adventureID);
	networkengine:send();
end

