-- 删除魔法

function packetHandlerDeleteMagic()
	local tempArrayCount = 0;
	local magicID = nil;

-- 所删除魔法的ID编号
	magicID = networkengine:parseInt();

	DeleteMagicHandler( magicID );
end

