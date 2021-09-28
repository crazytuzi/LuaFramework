--队伍成员对象
local TeamMemObj = class("TeamMemObj")

function TeamMemObj:ctor( nUid, stInfo )
	-- body
	self.m_nUid = nUid
	self:update(stInfo)
end
--[[
	optional int32 roleSid = 1;
	optional string name = 2;
	optional int32 roleLevel = 3;
	optional int32 sex = 4;
	optional int32 school = 5;
	optional int32 actived = 6;
	optional int32 wingId = 7;
	optional int32 weapon = 8;
	optional int32 upperBody = 9;
	optional int32 curHP = 10; 				//100 is 100%
	optional string factionName = 11;
	optional int32 battleNum = 12;
]]
--兼容teaminfo内容(可能是从G_TEAM_INFO来的，也可能是服务器直接发过来的包)
function TeamMemObj:update( stInfo )
	-- body
	if not stInfo then
		return
	end
	self.m_nRoleId = stInfo.roleId or stInfo.roleSid
	self.m_strName = stInfo.name
	self.m_nLv = stInfo.roleLevel
	self.m_nSex = stInfo.sex
	self.m_nSchool = stInfo.school
	self.m_bActived = stInfo.actived   --0不在线 1在线
	self.m_nWindId = stInfo.windId or stInfo.wingId
	self.m_nWeaponId = stInfo.weaponId or stInfo.weapon
	self.m_nCloseId = stInfo.closeId or stInfo.upperBody
	self.m_nCurHp = stInfo.curHP
	self.m_strFactionName = stInfo.factionName
	self.m_bIsFactionName = stInfo.isFactionSame or (self.m_nRoleId ~= userInfo.currRoleStaticId and self.m_strFactionName ~= "" and self.m_strFactionName == MRoleStruct:getAttr(PLAYER_FACTIONNAME))
	-- self.m_nBattleNum = stInfo.battleNum
end

function TeamMemObj:getUid( ... )
	-- body
	return self.m_nUid
end
-- function TeamMemObj:getBattleNum( ... )
-- 	-- body
-- 	return self.m_nBattleNum
-- end

function TeamMemObj:setCaptain( bCaptain )
	-- body
	self.m_bCaptain = bCaptain
end

function TeamMemObj:isCapTain( ... )
	-- body
	return self.m_bCaptain == true
end

function TeamMemObj:getRoleId( ... )
	-- body
	return self.m_nRoleId
end

function TeamMemObj:getName( ... )
	-- body
	return self.m_strName
end

function TeamMemObj:getLevel( ... )
	-- body
	return self.m_nLv
end

function TeamMemObj:getSex( ... )
	-- body
	return self.m_nSex
end

function TeamMemObj:getSchool( ... )
	-- body
	return self.m_nSchool
end

function TeamMemObj:isActive( ... )
	-- body
	return self.m_bActived
end

function TeamMemObj:getWindId( ... )
	-- body
	return self.m_nWindId
end

function TeamMemObj:getWeaponId( ... )
	-- body
	return self.m_nWeaponId
end

function TeamMemObj:getCloseId( ... )
	-- body
	return self.m_nCloseId
end

function TeamMemObj:getCurHp( ... )
	-- body
	return self.m_nCurHp
end

function TeamMemObj:getFactionName( ... )
	-- body
	return self.m_strFactionName
end

function TeamMemObj:isFactionName( ... )
	-- body
	return self.m_bIsFactionName
end

function TeamMemObj:dispose( ... )
	-- body
end

return TeamMemObj