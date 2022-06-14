-- 请求当前自己伤害排名

function sendAskTopRank(topType)
	networkengine:beginsend(67);
-- 排行榜类型，参照typedef的TYPE_DEF枚举
	networkengine:pushInt(topType);
	networkengine:send();
end

