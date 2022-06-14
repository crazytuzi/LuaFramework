-- 发起战斗

function sendBattle(battleType, adventureID, param1)
	networkengine:beginsend(1);
-- 战斗类型，见typedef的BattleType
	networkengine:pushInt(battleType);
-- 副本或者活动的ID
	networkengine:pushInt(adventureID);
-- param1 用于公会战postID下的ladderPlayer.id
	networkengine:pushInt(param1);
	networkengine:send();
end

