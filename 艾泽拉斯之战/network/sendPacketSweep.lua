-- 扫荡

function sendSweep(adventureID, adventureType, count)
	networkengine:beginsend(53);
-- 关卡ID
	networkengine:pushInt(adventureID);
-- 关卡类型
	networkengine:pushInt(adventureType);
-- 扫荡次数
	networkengine:pushInt(count);
	networkengine:send();
end

