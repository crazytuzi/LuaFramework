--[[
	工会每位成员
	2015年1月8日, AM 11:04:28
	wangyanwei 
]]

_G.FriendUnionVO = {};

function FriendUnionVO:New(vo)
	local obj = setmetatable({},{__index = self})
	obj.roleName = vo.name;
	obj.roleId = vo.id;
	obj.icon = vo.iconID;
	obj.posId = ResUtil:GetUnionPosIconImg(vo.pos);
	obj.lvl = vo.level;
	obj.lvlStr = string.format(StrConfig['friend101'],vo.level);
	obj.vipLvl = vo.vipLevel;
	if vo.online == 1 then 
		obj.online = true;
	else
		obj.online = false;
	end
	return obj;
end

function FriendUnionVO:GetRoleId()
	return self.roleId;
end

function FriendUnionVO:GetRoleName()
	return self.roleName;
end

function FriendUnionVO:GetIconId()
	return self.icon;
end

function FriendUnionVO:GetLevel()
	return self.lvl;
end

function FriendUnionVO:GetVIPLevel()
	return self.vipLvl;
end

function FriendUnionVO:GetOnlineState()
	return self.online;
end