-- 卡牌魔法升星或者新获得提示

function packetHandlerPrompt()
	local tempArrayCount = 0;
	local promptType = nil;
	local id = nil;
	local preExp = nil;
	local exp = nil;
	local preStar = nil;
	local star = nil;
	local overflow = nil;
	local firstGain = nil;

-- 卡牌还是魔法
	promptType = networkengine:parseInt();
-- 卡牌或者魔法的ID号
	id = networkengine:parseInt();
-- 之前的经验
	preExp = networkengine:parseInt();
-- 当前的经验
	exp = networkengine:parseInt();
-- 之前的星级
	preStar = networkengine:parseInt();
-- 星级
	star = networkengine:parseInt();
-- 溢出经验
	overflow = networkengine:parseInt();
-- 是否新物品
	firstGain = networkengine:parseBool();

	PromptHandler( promptType, id, preExp, exp, preStar, star, overflow, firstGain );
end

