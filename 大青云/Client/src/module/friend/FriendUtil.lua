--[[
好友Util
lizhuangzhuang
2014年10月23日11:54:07
]]

_G.FriendUtil = {};

function FriendUtil:Sort(list,type)
	if #list<=0 then return; end
	if type == FriendConsts.RType_Friend then
		table.sort(list,FriendUtil.FriendSortFunc);
	elseif type == FriendConsts.RType_Enemy then
		table.sort(list,FriendUtil.EnemySortFunc);
	elseif type == FriendConsts.RType_Recent then
		table.sort(list,FriendUtil.RecentSortFunc);
	end
end

--好友排序
function FriendUtil.FriendSortFunc(A,B)
	--在线
	if A:GetOnlineState()==1 and B:GetOnlineState()~=1 then
		return true;
	end
	if A:GetOnlineState()~=1 and B:GetOnlineState()==1 then
		return false;
	end
	--VIP
	if A:GetVIPLevel() > B:GetVIPLevel() then
		return true;
	end
	if A:GetVIPLevel() < B:GetVIPLevel() then
		return false;
	end
	--level
	if A:GetLevel() > B:GetLevel() then
		return true;
	end
	if A:GetLevel() < B:GetLevel() then
		return false;
	end
	--名字
	return A:GetRoleName() < B:GetRoleName();
end

--最近联系人排序
function FriendUtil.RecentSortFunc(A,B)
	if A:GetRecentTime() > B:GetRecentTime() then
		return true;
	end
	if A:GetRecentTime() < B:GetRecentTime() then
		return false;
	end
	return A:GetRoleName() < B:GetRoleName();
end

--仇人排序
function FriendUtil.EnemySortFunc(A,B)
	if A:GetKillTime() > B:GetKillTime() then
		return true;
	end
	if A:GetKillTime() < B:GetKillTime() then
		return false;
	end
	return A:GetRoleName() < B:GetRoleName();
end

--根据亲密度值获取亲密度配置
function FriendUtil:GetIntimacyCfg(value)
	for i,cfg in pairs(t_intimacy) do
		if value>=cfg.startVal and value<=cfg.endVal then
			return cfg;
		end
	end
	return;
end