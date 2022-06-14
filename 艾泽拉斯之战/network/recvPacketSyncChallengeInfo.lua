-- 每日随机的四个大力魔法

function packetHandlerSyncChallengeInfo()
	local tempArrayCount = 0;
	local greatMagics = {};
	local challengeDamageDefence = nil;
	local challengeDamageResilience = nil;

-- 急速挑战，每日4个大力魔法
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		greatMagics[i] = networkengine:parseInt();
	end
-- 伤害挑战boss防御和攻击等级
	challengeDamageDefence = networkengine:parseInt();
-- 伤害挑战boss暴击和韧性等级
	challengeDamageResilience = networkengine:parseInt();

	SyncChallengeInfoHandler( greatMagics, challengeDamageDefence, challengeDamageResilience );
end

