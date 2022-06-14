-- 系统奖励

function sendSystemReward(rewardType, id)
	networkengine:beginsend(46);
-- 奖励的type
	networkengine:pushInt(rewardType);
-- 奖励的id
	networkengine:pushInt(id);
	networkengine:send();
end

