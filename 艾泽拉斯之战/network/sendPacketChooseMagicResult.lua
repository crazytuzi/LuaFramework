-- 选择魔法结果

function sendChooseMagicResult(magicID)
	networkengine:beginsend(43);
-- 选择魔法的id
	networkengine:pushInt(magicID);
	networkengine:send();
end

