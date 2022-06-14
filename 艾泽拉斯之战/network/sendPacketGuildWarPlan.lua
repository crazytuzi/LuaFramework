-- 设置guildWar阵型

function sendGuildWarPlan(postID, guardID, addFlag)
	networkengine:beginsend(145);
-- 据点id
	networkengine:pushInt(postID);
-- 防守玩家id
	networkengine:pushInt(guardID);
-- 是添加还是删除
	networkengine:pushInt(addFlag);
	networkengine:send();
end

