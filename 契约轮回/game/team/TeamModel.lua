TeamModel = TeamModel or class("TeamModel",BaseModel)
local this = TeamModel

function TeamModel:ctor()
	TeamModel.Instance = self
	
	self:InitSub();
	self:Reset()
end

function TeamModel:Reset()
	self.invite_list = {}
	self.apply_list = {}
	self.apply_team_ids = {}
	self.agree_ids = {}
	self.team_info = nil
	self.auto_call = false
	self.merge_count = {}   --记录副本设置合并
	self.merges = {}        --记录队伍成员合并次数
	self.remind_cd = 0
end

function TeamModel.GetInstance()
	if TeamModel.Instance == nil then
		TeamModel()
	end
	return TeamModel.Instance
end

function TeamModel:UpdateTeamInfo(TeamInfo)
	self.team_info = TeamInfo
	if not self.team_info or not TeamInfo or 
		(self.team_info and TeamInfo and self.team_info.id ~= TeamInfo.id) then
		self.apply_team_ids = {}
	end
	if self.team_info then
		local members = self.team_info.members
		for k, v in pairs(members) do
			v.role.team = self.team_info.id
		end
	end
end

function TeamModel:GetTeamInfo()
	return self.team_info
end

--是否增加机器人
function TeamModel:GetAddFaker()
	return CacheManager.GetInstance():GetInt("team_addfaker", 0)
end

--0-不加，1-加（默认0）
function TeamModel:SetAddFaker(addfaker)
	CacheManager.GetInstance():SetInt("team_addfaker", addfaker)
end


function TeamModel:UpdateTeamList(TeamList)
	self.team_list = TeamList
end

function TeamModel:GetTeamList()
	return self.team_list
end

function TeamModel:SelfInTeam()
	local in_team = false
	local role_id = RoleInfoModel.GetInstance():GetMainRoleId()
	local teamInfo = self:GetTeamInfo()
	for i, v in pairs(teamInfo.members or {}) do
		if v.role.id == role_id then
			in_team = true
			break
		end
	end
	return in_team
end
--更新申请列表
function TeamModel:UpdateApplyList(ApplyList)
	self.apply_list = ApplyList
end

function TeamModel:AddApplyList(ApplyList)
	for i=1, #ApplyList do
		table.insert(self.apply_list, ApplyList[i])
	end
end

function TeamModel:DeleteFromApplyList(role_id)
	for i=1, #self.apply_list do
		if role_id == self.apply_list[i].role.id then
			table.remove(self.apply_list, i)
		end
	end
end

function TeamModel:GetApplyList()
	return self.apply_list
end

function TeamModel:UpdateInviteList(InviteList)
	self.invite_list = InviteList
end

function TeamModel:AddInviteList(InviteList)
	for i=1, #InviteList do
		table.insert(self.invite_list, InviteList[i])
	end
end

function TeamModel:GetInivteList()
	return self.invite_list
end


function TeamModel:GetCaptain(TeamInfo)
	local members = TeamInfo.members
	local captain_id = TeamInfo.captain_id
	for i=1, #members do
		if captain_id == members[i].role.id then
			return members[i].role
		end
	end
end

function TeamModel:IsCaptain(role_id)
	return self.team_info and self.team_info.captain_id == role_id or false
end

function TeamModel:AddApplyTeamId(team_id)
	self.apply_team_ids[team_id] = 1
end

function TeamModel:GetApplyTeamIds()
	return self.apply_team_ids
end

function TeamModel:DelApplyTeamId(team_id)
	table.removebyvalue(self.apply_team_ids,team_id)
end


function TeamModel:UpdateTeamMember(role_id, is_online, scene_id)
	if not self.team_info then return end
	local members = self.team_info.members
	for i=1, #members do
		local member = members[i]
		if member.role.id == role_id then
			member.is_online = is_online
			member.scene_id = scene_id
		end
	end
end

function TeamModel:GetMember(role_id)
	local members = self.team_info.members
	for i=1, #members do
		local member = members[i]
		if member.role.id == role_id then
			return member
		end
	end
end

function TeamModel:SetAgreeIds(role_ids, merges)
	self.agree_ids = role_ids
end

function TeamModel:SetShowMerge(role_id, count)
	self.merges[role_id] = count
end

function TeamModel:IsAgree(role_id)
	for i=1, #self.agree_ids do
		if role_id == self.agree_ids[i] or faker:GetInstance():is_fake(role_id) then
			return true
		end
	end
	return false
end

function TeamModel:IsMembersAgree()
	local members = self.team_info.members
	for i=1, #members do
		local member = members[i]
		if not self:IsAgree(member.role_id) then
			return false
		end
	end
	return true
end

function TeamModel:InitSub()
    self.allSub = {};
	for k,v in pairs(Config.db_team_target_sub) do
		self.allSub[v.dunge_id] = v;
	end
end

function TeamModel:GetSubIDByDungeID(dungeid)
	if self.allSub and self.allSub[dungeid] then
		return self.allSub[dungeid];
	end
	return nil;
end

function TeamModel:GetMyTeamMemberNum()
	return self.team_info and #self.team_info.members or 0
end

--获取在线成员数
function TeamModel:GetTeamOnlineMemNum()
	local num = 0
	if self.team_info then
		for _, member in pairs(self.team_info.members) do
			if member.is_online == 1 then
				num = num + 1
			end
		end
	end
	return num
end

function TeamModel:FormatPower(power)
	if power >= 10000000 then
		local power = GetShowNumber(power)
		power = string.gsub(power, "0K", "wan")
		power = string.gsub(power, "00M", "yi")
		return power
	end
	return power
end

function TeamModel:GetExpPlus()
	local num = self:GetTeamOnlineMemNum()
	local exp = 0
	if num == 2 then
		exp = 20
	elseif num == 3 then
		exp = 30
	end
	return "+" .. exp .. "%"
end

--设置合并次数
function TeamModel:SetMerge(stype, count)
	self.merge_count[stype] = count
end

function TeamModel:GetMerge(stype)
	return self.merge_count[stype] or 1
end

function TeamModel:GetMergeByDungeId(dunge_id)
	local stype = Config.db_dunge[dunge_id].stype
	return self.merge_count[stype] or 1
end
