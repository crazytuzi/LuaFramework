-- 访问领地

function sendIncident(incidentIndex)
	networkengine:beginsend(49);
-- 访问的领地索引,从0开始, 如果需要刷新全部，请填写-1
	networkengine:pushInt(incidentIndex);
	networkengine:send();
end

