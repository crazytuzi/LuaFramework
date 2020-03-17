--[[
队伍:相关工具方法
郝户
2014年9月27日22:59:52
]]

_G.TeamUtils = {};

--获取玩家组队状态文字描述
--@param teamState: 1已组队 2未组队
function TeamUtils:GetTeamStateTxt( teamState )
	local txt = "";
	if teamState == TeamConsts.OutTeam then
		txt = StrConfig["team4"];
	elseif teamState == TeamConsts.InTeam then
		txt = StrConfig["team5"];
	end
	return txt;
end

--根据id判断是不是队长
function TeamUtils:IsCaptain(playerId)
	return TeamModel:GetCaptainId() == playerId;
end

--判断自己是不是队长
function TeamUtils:MainPlayerIsCaptain()
	return self:IsCaptain( MainPlayerController:GetRoleID() );
end

--判断是不是自己
function TeamUtils:IsMainPlayer(memberVO)
	return MainPlayerController:GetRoleID() == memberVO.roleID;
end

--为队伍面板3d渲染器取名
function TeamUtils:GetDrawObjName(index)
	return "teamMember"..index;
end

function TeamUtils:GetDrawObj(index)
	return UIDrawManager:GetUIDraw( self:GetDrawObjName(index) );
end

--获取队员3d形象avatar
function TeamUtils:GetMemberAvatar( memberVO )
	local avatar = CPlayerAvatar:new();
	avatar:CreateByVO(memberVO)
	avatar.noPfx = true;
	return avatar;
end

-- 判断是否3d形象属性 (对应memberVO的属性)
function TeamUtils:IsAppearance(attrName)
	return TeamConsts.AppearanceAttrs[attrName] == true;
end

TeamUtils.noticeMap = {}
function TeamUtils:RegisterNotice(ui,backFun)
	local uiName = ui:GetName();
	if self.noticeMap[uiName] then 
		TeamUtils:UnRegisterNotice(uiName)
	end;
	--todo
	if not TeamModel:IsInTeam() then 
		return false;
	end;

	local fun = function(name) self:UnRegisterNotice(name) end;
	local vo = {};
	vo.backFun = backFun;
	vo.name = uiName;
	vo.confirm = UIConfirm:Open(StrConfig['fubenentertema001'],function()
		TeamController:QuitTeam() 
		backFun();
	end,

	function()
		fun(vo.name)
	end)
	self.noticeMap[uiName] = vo;
	return true;
end;

function TeamUtils:UnRegisterNotice(uiName)
	if self.noticeMap[uiName] then 
		UIConfirm:Close(self.noticeMap[uiName].confirm)
		self.noticeMap[uiName] = nil;
	end;
end;