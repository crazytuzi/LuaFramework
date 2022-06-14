-- 好友状态

function packetHandlerFriendsStatus()
	local tempArrayCount = 0;
	local friendID = nil;
	local icon = nil;
	local level = nil;
	local vip = nil;
	local nickname = nil;
	local lastLoginTime = nil;
	local sendFlag = nil;
	local recvFlag = nil;
	local __optional_flag__ = GameClient.Bitset:new(7);
	networkengine:parseBitset(7, __optional_flag__);

-- 好友id
	friendID = networkengine:parseInt();
	if __optional_flag__:isSetbit(0) then
		-- 头像
	icon = networkengine:parseInt();
	end
	if __optional_flag__:isSetbit(1) then
		-- 等级
	level = networkengine:parseInt();
	end
	if __optional_flag__:isSetbit(2) then
		-- vip
	vip = networkengine:parseInt();
	end
	if __optional_flag__:isSetbit(3) then
		-- 昵称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		nickname = networkengine:parseString(strlength);
else
		nickname = "";
end
	end
	if __optional_flag__:isSetbit(4) then
		-- 好友是否在线,在线为0,不在线是上次登录时间
	lastLoginTime = networkengine:parseUInt64();
	end
	if __optional_flag__:isSetbit(5) then
		-- 赠送标记
	sendFlag = networkengine:parseInt();
	end
	if __optional_flag__:isSetbit(6) then
		-- 接受标记
	recvFlag = networkengine:parseInt();
	end

	FriendsStatusHandler( __optional_flag__, friendID, icon, level, vip, nickname, lastLoginTime, sendFlag, recvFlag );
	__optional_flag__:delete();
end

