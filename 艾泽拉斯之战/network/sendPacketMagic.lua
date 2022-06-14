-- 施放国王魔法

function sendMagic(skillID, posX, posY)
	networkengine:beginsend(8);
-- 魔法的id
	networkengine:pushInt(skillID);
-- 魔法释放的位置
	networkengine:pushInt(posX);
-- 魔法释放的位置
	networkengine:pushInt(posY);
	networkengine:send();
end

