-- 访问领地结果

function packetHandlerSyncIncident()
	local tempArrayCount = 0;
	local infos = {};

-- 领地事件信息
	local __optional_flag__infos = GameClient.Bitset:new(6);
 	networkengine:parseBitset(6, __optional_flag__infos);
	tempArrayCount = 6;
	for i=1, tempArrayCount do
		if __optional_flag__infos:isSetbit(i-1) then
		infos[i] = ParseIncidentSummary();
		end
	end

	SyncIncidentHandler( __optional_flag__infos,  infos );
	__optional_flag__infos:delete();
end

