-- 每日随机的四个大力魔法

function packetHandlerSyncGreatMagic()
	local tempArrayCount = 0;
	local greatMagics = {};

-- 每日4个大力魔法
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		greatMagics[i] = networkengine:parseInt();
	end

	SyncGreatMagicHandler( greatMagics );
end

