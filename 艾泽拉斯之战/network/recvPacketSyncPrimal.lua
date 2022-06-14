-- 原生资源同步

function packetHandlerSyncPrimal()
	local tempArrayCount = 0;
	local primals = {};

-- 原生资源数组
	local __optional_flag__primals = GameClient.Bitset:new(4);
 	networkengine:parseBitset(4, __optional_flag__primals);
	tempArrayCount = 4;
	for i=1, tempArrayCount do
		if __optional_flag__primals:isSetbit(i-1) then
			primals[i] = networkengine:parseInt();
		end
	end

	SyncPrimalHandler( __optional_flag__primals,  primals );
	__optional_flag__primals:delete();
end

