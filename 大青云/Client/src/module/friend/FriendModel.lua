--[[
好友
lizhuangzhuang
2014年10月17日15:42:39
]]

_G.FriendModel = Module:new();

--好友列表
FriendModel.friendList = {};
--推荐列表
FriendModel.recommendList = {};

--获取好友
function FriendModel:GetFriendVO(roleId)
	return self.friendList[roleId];
end

--添加好友
function FriendModel:AddFriendVO(friendVO)
	if self.friendList[friendVO:GetRoleId()] then
		Debug("Error:add friendVO error.Has one already.");
		return;
	end
	self.friendList[friendVO:GetRoleId()] = friendVO;
end

--删除好友
function FriendModel:RemoveFriendVO(roleId)
	self.friendList[roleId] = nil;
end

--搜索
function FriendModel:Search(key)
	key = string.gsub(key,"%[","%%%[");
	key = string.gsub(key,"%]","%%%]");
	local list = {};
	for k,friendVO in pairs(self.friendList) do
		local startIndex = string.find(friendVO:GetRoleName(),key);
		if startIndex then
			table.push(list,friendVO);
		end
	end
	return list;
end

--根据关系类型获取列表
function FriendModel:GetListByRType(rType)
	local list = {};
	for i,friendVO in pairs(self.friendList) do
		if friendVO:GetHasRelation(rType) then
			table.push(list,friendVO);
		end
	end
	return list;
end

--是否有某种关系
function FriendModel:GetHasRelation(roleId,rType)
	local friendVO = self.friendList[roleId];
	if not friendVO then
		return false;
	end
	return friendVO:GetHasRelation(rType);
end

--是否是好友
function FriendModel:GetIsFriend(roleId)
	return self:GetHasRelation(roleId,FriendConsts.RType_Friend);
end

--是否是黑名单
function FriendModel:GetIsBlack(roleId)
	return self:GetHasRelation(roleId,FriendConsts.RType_Black);
end