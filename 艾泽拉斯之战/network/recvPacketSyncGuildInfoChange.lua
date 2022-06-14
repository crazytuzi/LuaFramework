-- 公会信息变更

function packetHandlerSyncGuildInfoChange()
	local tempArrayCount = 0;
	local id = nil;
	local notice = nil;
	local warScore = nil;
	local __optional_flag__ = GameClient.Bitset:new(2);
	networkengine:parseBitset(2, __optional_flag__);

-- 公会id
	id = networkengine:parseInt();
	if __optional_flag__:isSetbit(0) then
		-- 公会公告
	local strlength = networkengine:parseInt();
if strlength > 0 then
		notice = networkengine:parseString(strlength);
else
		notice = "";
end
	end
	if __optional_flag__:isSetbit(1) then
		-- 公会积分
	warScore = networkengine:parseInt();
	end

	SyncGuildInfoChangeHandler( __optional_flag__, id, notice, warScore );
	__optional_flag__:delete();
end

