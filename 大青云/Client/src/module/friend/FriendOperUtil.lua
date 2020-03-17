--[[
好友操作菜单
lizhuangzhuang
2014年10月22日15:54:56
]]

_G.FriendOperUtil = {};

--获取所有操作列表
--@param friendVO 好友VO
--@param rType  关系列表
function FriendOperUtil:GetOperList(friendVO,rType)
	local list = {};
	for i,oper in ipairs(FriendConsts.AllOper) do
		if not rType then
			local unionShow = self:CheckUnionOper(oper,friendVO);
			if unionShow then
				local vo = {};
				vo.name = FriendConsts:GetOperName(oper);
				vo.oper = oper;
				table.push(list,vo);
			end
		else
			local show = self:CheckOper(oper,friendVO,rType);
			if show then
				local vo = {};
				vo.name = FriendConsts:GetOperName(oper);
				vo.oper = oper;
				table.push(list,vo);
			end
		end
		
	end
	return list;
end

--工会好友权限
--@oper 单个选项的index
--@friendVO 工会人的vo
function FriendOperUtil:CheckUnionOper(oper,friendVO)
	local roleId = friendVO.roleId;
	if roleId == MainPlayerController:GetRoleID() then   --是否是本人
		return false;
	end
	local cfg = FriendModel:GetFriendVO(roleId);
	--if not cfg then print("没有找到数据")return end
	--print(cfg:GetOnlineState(),"----")
	--判断是否已经是好友
		if cfg ~= nil then
			if cfg:GetIsBlack() then
				if oper == FriendConsts.Oper_ShowInfo then  --查看资料
					return true;
				elseif oper == FriendConsts.Oper_RemoveBlack then  --移出黑名单
					return true;
				end
			elseif cfg:GetIsFriend() then
				if oper == FriendConsts.Oper_ShowInfo then  --查看资料
					return true;
				elseif oper == FriendConsts.Oper_Chat then  --发送私聊
					return true;
				elseif oper == FriendConsts.Oper_TeamInvite then  --邀请组队
					return true;
				elseif oper == FriendConsts.Oper_RemoveFriend then  --移除好友
					return true;
				elseif oper == FriendConsts.Oper_CopyName then  --赋值名称
					return true;
				elseif oper == FriendConsts.Oper_AddBlack then  --加入黑名单
					return true;
				end
			elseif not cfg:GetIsFriend() then
				if oper == FriendConsts.Oper_ShowInfo then  --查看资料
					return true;
				elseif oper == FriendConsts.Oper_Chat then  --发送私聊
					return true;
				elseif oper == FriendConsts.Oper_TeamInvite then  --邀请组队
					return true;
				elseif oper == FriendConsts.Oper_AddFriend then  --添加好友
					return true;
				elseif oper == FriendConsts.Oper_CopyName then  --赋值名称
					return true;
				elseif oper == FriendConsts.Oper_AddBlack then  --加入黑名单
					return true;
				end
			end
		else
			if oper == FriendConsts.Oper_ShowInfo then  --查看资料
				return true;
			elseif oper == FriendConsts.Oper_Chat then  --发送私聊
				return true;
			elseif oper == FriendConsts.Oper_TeamInvite then  --邀请组队
				return true;
			elseif oper == FriendConsts.Oper_AddFriend then  --添加好友
				return true;
			elseif oper == FriendConsts.Oper_CopyName then  --赋值名称
				return true;
			elseif oper == FriendConsts.Oper_AddBlack then  --加入黑名单
				return true;
			end
		end
	return false;
end

--检查权限
function FriendOperUtil:CheckOper(oper,friendVO,rType)
	local roleId = friendVO:GetRoleId();
	if oper == FriendConsts.Oper_ShowInfo then
		return true;
	elseif oper == FriendConsts.Oper_Chat then
		if rType ~= FriendConsts.RType_Black then
			return true;
		else
			return false;
		end
	elseif oper == FriendConsts.Oper_TeamCreate then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		return not TeamModel:IsInTeam();
	elseif oper == FriendConsts.Oper_TeamApply then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		if TeamModel:IsInTeam() then
			return false;
		end
		local teamId = friendVO:GetTeamId();
		return teamId and teamId ~= "0_0";
	elseif oper == FriendConsts.Oper_TeamInvite then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		local teamId = friendVO:GetTeamId();
		return TeamModel:IsInTeam() and (teamId == nil or teamId == "0_0");
	elseif oper == FriendConsts.Oper_GuildInvite then
		--帮派邀请
		if rType == FriendConsts.RType_Black then
			return false;
		end
		
		if not UnionUtils:CheckMyUnion() then return false end
		if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.invitation) == 1 then
			return true
		else
			return false
		end
	elseif oper == FriendConsts.Oper_GuildApply then
		--帮派申请
		if rType == FriendConsts.RType_Black then
			return false;
		end
		
		if UnionUtils:CheckMyUnion() then return false end
		if UnionUtils:GetUnionPermissionByDuty(friendVO:GetGuildPos(), UnionConsts.invitation_verify) == 1 then
			return true
		else
			return false
		end
	elseif oper == FriendConsts.Oper_AddFriend then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		if not FriendModel:GetIsFriend(roleId) then
			return true;
		end
		return false;
	elseif oper == FriendConsts.Oper_RemoveFriend then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		if FriendModel:GetIsFriend(roleId) then
			return true;
		end
		return false;
	elseif oper == FriendConsts.Oper_CopyName then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		return true;
	elseif oper == FriendConsts.Oper_RemoveRecent then
		if rType == FriendConsts.RType_Recent then
			if FriendModel:GetHasRelation(roleId,FriendConsts.RType_Recent) then
				return true;
			end
		end
		return false;
	elseif oper == FriendConsts.Oper_RemoveEnemy then
		if rType == FriendConsts.RType_Enemy then
			if FriendModel:GetHasRelation(roleId,FriendConsts.RType_Enemy) then
				return true;
			end
		end
		return false;
	elseif oper == FriendConsts.Oper_AddBlack then
		if rType == FriendConsts.RType_Black then
			return false;
		end
		if not FriendModel:GetIsBlack(roleId) then
			return true;
		end
		return false;
	elseif oper == FriendConsts.Oper_RemoveBlack then
		if rType ~= FriendConsts.RType_Black then
			return false;
		end
		if FriendModel:GetIsBlack(roleId) then
			return true;
		end
		return false;
	end
	return false;
end
