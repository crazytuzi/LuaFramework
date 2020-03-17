--[[
聊天人物操作菜单
lizhuangzhuang
2014年9月30日14:04:57
]]
_G.classlist['ChatRoleOperUtil'] = 'ChatRoleOperUtil'
_G.ChatRoleOperUtil = {};
ChatRoleOperUtil.objName = 'ChatRoleOperUtil'
--获取所有操作列表
function ChatRoleOperUtil:GetOperList(chatRoleVO)
	local list = {};
	if GMModule:IsGM() then
		for i,oper in ipairs(GMConsts.AllOper) do
			local vo = {};
			vo.name = GMConsts:GetOperName(oper);
			vo.oper = oper;
			table.push(list,vo);
		end
	end
	for i,oper in ipairs(ChatConsts.AllROper) do
		local show = self:CheckOper(oper,chatRoleVO);
		if show then
			local vo = {};
			vo.name = ChatConsts:GetOperName(oper);
			vo.oper = oper;
			table.push(list,vo);
		end
	end
	return list;
end

--检查权限
--@param oper 操作
--@param chatRoleVO 操作对象
--@return 是否显示
function ChatRoleOperUtil:CheckOper(oper,chatRoleVO)
	if oper == ChatConsts.ROper_Chat then
		return true;
	elseif oper == ChatConsts.ROper_ShowInfo then
		return true;
	elseif oper == ChatConsts.ROper_AddFriend then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Friend) then
			return false;
		end
		if FriendModel:GetIsFriend(chatRoleVO:GetID()) then
			return false;
		else
			return true;
		end
	elseif oper == ChatConsts.ROper_AddBlack then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Friend) then
			return false;
		end
		if FriendModel:GetIsBlack(chatRoleVO:GetID()) then
			return false;
		else
			return true;
		end
	elseif oper == ChatConsts.ROper_GuildInvite then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then
			return false;
		end
		--帮派邀请
		if not UnionUtils:CheckMyUnion() then return false end
		if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.invitation) == 1 then
			return true
		else
			return false
		end
	elseif oper == ChatConsts.ROper_GuildApply then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then
			return false;
		end
		if chatRoleVO:GetGuildId() ~= "0_0" then
			return false;
		end
		--帮派申请
		if UnionUtils:CheckMyUnion() then return false end
		if UnionUtils:GetUnionPermissionByDuty(chatRoleVO:GetGuildPos(), UnionConsts.invitation_verify) == 1 then
			return true
		else
			return false
		end
	elseif oper == ChatConsts.ROper_TeamCreate then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Team) then
			return false;
		end
		-- 创建队伍：我不在队伍中时显示
		return not TeamModel:IsInTeam();
	elseif oper == ChatConsts.ROper_TeamApply then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Team) then
			return false;
		end
		-- 申请入队：我不在队伍中，且对方有队伍时显示
		if TeamModel:IsInTeam() then
			return false;
		end
		local chatRoleTeam = chatRoleVO:GetTeamId();
		return chatRoleTeam and chatRoleTeam ~= "0_0";
	elseif oper == ChatConsts.ROper_TeamInvite then
		if not FuncManager:GetFuncIsOpen(FuncConsts.Team) then
			return false;
		end
		-- 邀请入队：我在队伍中，且对方不在队伍中时显示
		local chatRoleTeam = chatRoleVO:GetTeamId();
		return TeamModel:IsInTeam() and (chatRoleTeam == nil or chatRoleTeam == "0_0");
	elseif oper == ChatConsts.ROper_CopyName then
		return true;
	elseif oper == ChatConsts.ROper_Report then
		if chatRoleVO:GetFromChannel() == ChatConsts.Channel_Guild then
			return true;
		end
		return false;
	end
	return false;
end
