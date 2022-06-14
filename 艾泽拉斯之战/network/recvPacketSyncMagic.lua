-- 魔法同步

function packetHandlerSyncMagic()
	local tempArrayCount = 0;
	local magics = {};

-- 魔法信息
	local __optional_flag__magics = GameClient.Bitset:new(256);
 	networkengine:parseBitset(256, __optional_flag__magics);
	tempArrayCount = 256;
	for i=1, tempArrayCount do
		if __optional_flag__magics:isSetbit(i-1) then
			magics[i] = networkengine:parseInt();
		end
	end

	SyncMagicHandler( __optional_flag__magics,  magics );
	__optional_flag__magics:delete();
end

