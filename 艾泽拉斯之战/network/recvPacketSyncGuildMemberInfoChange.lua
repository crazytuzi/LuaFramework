-- 公会成员信息变更

function packetHandlerSyncGuildMemberInfoChange()
	local tempArrayCount = 0;
	local id = nil;
	local warScore = nil;
	local __optional_flag__ = GameClient.Bitset:new(1);
	networkengine:parseBitset(1, __optional_flag__);

-- 成员id
	id = networkengine:parseInt();
	if __optional_flag__:isSetbit(0) then
		-- 个人积分
	warScore = networkengine:parseInt();
	end

	SyncGuildMemberInfoChangeHandler( __optional_flag__, id, warScore );
	__optional_flag__:delete();
end

