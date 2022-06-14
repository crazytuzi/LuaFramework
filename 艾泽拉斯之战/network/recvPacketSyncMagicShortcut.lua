-- 同步魔法快捷方式

function packetHandlerSyncMagicShortcut()
	local tempArrayCount = 0;
	local shortcuts = {};

-- 魔法的配置
	local __optional_flag__shortcuts = GameClient.Bitset:new(16);
 	networkengine:parseBitset(16, __optional_flag__shortcuts);
	tempArrayCount = 16;
	for i=1, tempArrayCount do
		if __optional_flag__shortcuts:isSetbit(i-1) then
		shortcuts[i] = ParseActionBar();
		end
	end

	SyncMagicShortcutHandler( __optional_flag__shortcuts,  shortcuts );
	__optional_flag__shortcuts:delete();
end

