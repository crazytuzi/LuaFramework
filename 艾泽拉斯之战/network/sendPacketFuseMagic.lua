-- 融合魔法

function sendFuseMagic(star)
	networkengine:beginsend(82);
-- 选择几星融合
	networkengine:pushInt(star);
	networkengine:send();
end

