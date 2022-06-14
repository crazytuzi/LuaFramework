-- 玩家额外属性同步

function packetHandlerSyncPlayerExtra()
	local tempArrayCount = 0;
	local attr = {};

-- 属性数组
	local __optional_flag__attr = GameClient.Bitset:new(32);
 	networkengine:parseBitset(32, __optional_flag__attr);
	tempArrayCount = 32;
	for i=1, tempArrayCount do
		if __optional_flag__attr:isSetbit(i-1) then
			attr[i] = networkengine:parseInt();
		end
	end

	SyncPlayerExtraHandler( __optional_flag__attr,  attr );
	__optional_flag__attr:delete();
end

