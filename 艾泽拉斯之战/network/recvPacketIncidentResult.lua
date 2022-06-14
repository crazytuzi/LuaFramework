-- 访问领地结果

function packetHandlerIncidentResult()
	local tempArrayCount = 0;
	local incidentIndex = nil;
	local eventID = nil;

-- 领地索引,从0开始
	incidentIndex = networkengine:parseInt();
-- 领地事件ID号,从1开始,参照incident.xls
	eventID = networkengine:parseInt();

	IncidentResultHandler( incidentIndex, eventID );
end

