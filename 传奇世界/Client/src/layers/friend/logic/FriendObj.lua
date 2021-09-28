--Author:		bishaoqing
--DateTime:		2016-06-01 16:38:21
--Region:		好友对象
local FriendObj = class("FriendObj")

function FriendObj:ctor( nUid )
	-- body
	self.m_nUid = nUid
end

--[[
//COPY_SC_GETFRIENDDATARET 13027
message CopyFriendInfo
{
	optional int32 friendSid = 1;
	optional int32 friendSchool = 2;
	optional string friendName = 3;
	optional int32 friendLevel = 4;
	optional int32 friendBattle = 5;
	optional int32 friendSex = 6;
	optional int32 remainCD = 7;
	optional int32 needIngot = 8;
	optional bool isOnline = 9;
}
]]
function FriendObj:reset( stInfo )
	-- body
	self.m_nFriendSid = stInfo.friendSid
	self.m_nFriendSchool = stInfo.friendSchool
	self.m_sFriendName = stInfo.friendName
	self.m_nFriendLevel = stInfo.friendLevel
	self.m_nFriendBattle = stInfo.friendBattle
	self.m_nFriendSex = stInfo.friendSex
	self.m_nRemainCD = stInfo.remainCD
	self.m_nNeedIngot = stInfo.needIngot
	self.m_bIsOnline = stInfo.isOnline
end

function FriendObj:isOnline( ... )
	-- body
	return self.m_bIsOnline == true
end

function FriendObj:getFriendSid( ... )
	-- body
	return self.m_nFriendSid
end

function FriendObj:getFriendSchool( ... )
	-- body
	return self.m_nFriendSchool
end

function FriendObj:getFriendName( ... )
	-- body
	return self.m_sFriendName
end

function FriendObj:getFriendLevel( ... )
	-- body
	return self.m_nFriendLevel
end

function FriendObj:getFriendBattle( ... )
	-- body
	return self.m_nFriendBattle
end

function FriendObj:getFriendSex( ... )
	-- body
	return self.m_nFriendSex
end

function FriendObj:getRemainCD( ... )
	-- body
	return self.m_nRemainCD
end

function FriendObj:getNeedIngot( ... )
	-- body
	return self.m_nNeedIngot
end

function FriendObj:getUid( ... )
	-- body
	return self.m_nUid
end

function FriendObj:dispose( ... )
	-- body
end

return FriendObj