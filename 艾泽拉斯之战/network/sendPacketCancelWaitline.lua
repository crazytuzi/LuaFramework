-- 放弃排队

function sendCancelWaitline(waitlineType)
	networkengine:beginsend(51);
-- 所放弃的排队类型 见typedef的WaitLineType
	networkengine:pushInt(waitlineType);
	networkengine:send();
end

