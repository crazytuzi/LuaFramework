-- 设置guildWar阵型

function sendGuildWarPlanFlag(postID, guardID, enterFlag)
	networkengine:beginsend(160);
-- 据点id
	networkengine:pushInt(postID);
-- 防守玩家id
	networkengine:pushInt(guardID);
-- 进入还是离开布阵界面
	networkengine:pushInt(enterFlag);
	networkengine:send();
end

