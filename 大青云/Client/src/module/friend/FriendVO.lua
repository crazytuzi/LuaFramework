--[[
好友VO
lizhuangzhuang
2014年10月17日21:28:46
]]

_G.FriendVO = {};

--Flag的每一位代表什么意思
FriendVO.RBitmap = {
	[1] = FriendConsts.RType_Friend,
	[2]	= FriendConsts.RType_Enemy,
	[3] = FriendConsts.RType_Black,
	[4] = FriendConsts.RType_Recent
};

function FriendVO:new(roleId)
	local obj = {};
	for k,v in pairs(FriendVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.roleId = roleId;
	return obj;
end

function FriendVO:SetInfo(vo)
	self.roleName = vo.roleName;
	self.level = vo.level;
	self.iconId = vo.iconID;
	self.vipLevel = vo.vipLevel;
	self.onlineState = vo.onlinestatus;
	self:SetRelation(vo.relationFlag);
	self.intimacy = vo.relationDegree;--亲密度
	self.beKillNum = vo.beKillNum;--被击杀次数
	self.recentTime = vo.recentTime;--最近联系时间
	self.killTime = vo.killTime;--最近被击杀时间
	self.teamId = vo.teamId;
	self.guildId = vo.guildId;
	self.guildPos = vo.guildPos;
end

function FriendVO:GetRoleId()
	return self.roleId;
end

function FriendVO:GetRoleName()
	return self.roleName;
end

function FriendVO:GetLevel()
	return self.level;
end

function FriendVO:GetIconId()
	return self.iconId;
end

function FriendVO:GetVIPLevel()
	return self.vipLevel;
end

function FriendVO:SetOnlineState(v)
	self.onlineState = v;
end
function FriendVO:GetOnlineState()
	return self.onlineState;
end

--亲密度
function FriendVO:GetIntimacy()
	return self.intimacy;
end

function FriendVO:GetBeKillNum()
	return self.beKillNum;
end

function FriendVO:SetRecentTime(time)
	self.recentTime = time;
end
function FriendVO:GetRecentTime()
	return self.recentTime;
end

function FriendVO:SetKillTime(time)
	self.killTime = time;
end
function FriendVO:GetKillTime()
	return self.killTime;
end

function FriendVO:GetTeamId()
	return self.teamId;
end

function FriendVO:GetGuildId()
	return self.guildId;
end

function FriendVO:GetGuildPos()
	return self.guildPos;
end

--获取所有关系数量
function FriendVO:GetRelationCount()
	local len = 0;
	for rType,v in pairs(self.relations) do
		if v == 1 then
			len = len + 1;
		end
	end
	return len;
end

--设置关系
function FriendVO:SetRelation(rFlag)
	local flag = toint32(rFlag);
	self.relations = {};
	for b,rType in pairs(FriendVO.RBitmap) do
		self.relations[rType] = bit.rshift(bit.lshift(flag,32-b),31);
	end
end

--获取是否有某种关系
function FriendVO:GetHasRelation(rType)
	if self.relations[rType] and self.relations[rType]==1 then
		return true;
	end
	return false;
end

--是否是好友
function FriendVO:GetIsFriend()
	return self:GetHasRelation(FriendConsts.RType_Friend);
end

--是否黑名单
function FriendVO:GetIsBlack()
	return self:GetHasRelation(FriendConsts.RType_Black);
end

--是否仇人
function FriendVO:GetIsEnemy()
	return self:GetHasRelation(FriendConsts.RType_Enemy);
end

--删除某种关系
function FriendVO:RemoveRelation(rType)
	if not self.relations then
		self.relations = {};
	end
	self.relations[rType] = 0;
end