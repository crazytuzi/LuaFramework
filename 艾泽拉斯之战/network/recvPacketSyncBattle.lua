-- 开战双方阵型配置

function packetHandlerSyncBattle()
	local tempArrayCount = 0;
	local battleType = nil;
	local battleGuid = nil;
	local isReplay = nil;
	local force = nil;
	local attackPlan = {};
	local guardPlan = {};
	local attackMagics = {};
	local guardMagics = {};

-- 战斗类型，回包确认
	battleType = networkengine:parseInt();
-- 战斗guid
	battleGuid = networkengine:parseUInt();
-- 是否是录像
	isReplay = networkengine:parseBool();
-- 你是进攻方还是防守方
	force = networkengine:parseInt();
-- 进攻方军团配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		attackPlan[i] = ParseUnitInfo();
	end
-- 防守方军团配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		guardPlan[i] = ParseUnitInfo();
	end
-- 进攻方魔法配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		attackMagics[i] = ParseMagicInfo();
	end
-- 防守方魔法配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		guardMagics[i] = ParseMagicInfo();
	end

	SyncBattleHandler( battleType, battleGuid, isReplay, force, attackPlan, guardPlan, attackMagics, guardMagics );
end

