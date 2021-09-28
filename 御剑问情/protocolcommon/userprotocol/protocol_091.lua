TeamStruct = TeamStruct or {}

function TeamStruct.TeamMemberInfoRead()
	local stu = {}
	stu.role_id = MsgAdapter.ReadInt()
	stu.name = MsgAdapter.ReadStrN(32)
	--stu.avatar = MsgAdapter.ReadChar()
	stu.scene_index = MsgAdapter.ReadInt()
	stu.scene_id = MsgAdapter.ReadInt()
	stu.is_online = MsgAdapter.ReadInt()
	stu.prof = MsgAdapter.ReadChar()
	stu.camp = MsgAdapter.ReadChar()
	stu.sex = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	stu.level = MsgAdapter.ReadShort()
	MsgAdapter.ReadChar()
	stu.fbroom_read = MsgAdapter.ReadChar()

	stu.capability = MsgAdapter.ReadInt()
	stu.avatar_key_big = MsgAdapter.ReadUInt()
	stu.avatar_key_small = MsgAdapter.ReadUInt()
	return stu
end

function TeamStruct.TeamItemRead()
	local stu = {}
	stu.team_index = MsgAdapter.ReadInt()
	stu.leader_name = MsgAdapter.ReadStrN(32)
	stu.leader_level = MsgAdapter.ReadInt()
	stu.cur_member_num = MsgAdapter.ReadInt()
	stu.leader_vip_level = MsgAdapter.ReadChar()
	stu.leader_prof = MsgAdapter.ReadChar()
	stu.leader_camp = MsgAdapter.ReadChar()
	stu.leader_sex = MsgAdapter.ReadChar()
	stu.team_type = MsgAdapter.ReadChar()
	stu.reserve_ch = MsgAdapter.ReadChar()
	stu.reserve_sh = MsgAdapter.ReadShort()
	stu.avatar_key_big = MsgAdapter.ReadUInt()
	stu.avatar_key_small = MsgAdapter.ReadUInt()
	stu.member_uid_list = {}
	for i=1, GameEnum.TEAM_MAX_COUNT do
		stu.member_uid_list[i] = MsgAdapter.ReadInt()
	end
	return stu
end

--玩家申请创建队伍 9150
CSCreateTeam = CSCreateTeam or BaseClass(BaseProtocolStruct)

function CSCreateTeam:__init()
	self.msg_type = 9150

	self.must_check = 0
	self.assign_mode = 1
	self.member_can_invite = 0
	self.team_type = 0
end

function CSCreateTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteChar(self.must_check)
    MsgAdapter.WriteChar(self.assign_mode)
    MsgAdapter.WriteChar(self.member_can_invite)
	MsgAdapter.WriteChar(self.team_type)
end

--邀请加入队伍 9151
CSInviteUser = CSInviteUser or BaseClass(BaseProtocolStruct)

function CSInviteUser:__init()
	self.msg_type = 9151

	self.role_id = 0
end

function CSInviteUser:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.role_id)
end

--回复邀请 9152
CSInviteUserTransmitRet = CSInviteUserTransmitRet or BaseClass(BaseProtocolStruct)

function CSInviteUserTransmitRet:__init()
	self.msg_type = 9152

	self.inviter = 0
	self.result	= 0 -- 0 同意
end

function CSInviteUserTransmitRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.inviter)
    MsgAdapter.WriteInt(self.result)
end

--队长回复申请加入队伍审核 9153
CSReqJoinTeamRet = CSReqJoinTeamRet or BaseClass(BaseProtocolStruct)

function CSReqJoinTeamRet:__init()
	self.msg_type = 9153

	self.req_role_id = 0
	self.result = 0
end

function CSReqJoinTeamRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.req_role_id)
    MsgAdapter.WriteInt(self.result)
end

--玩家申请加入某队伍 9154
CSReqJoinTeam = CSReqJoinTeam or BaseClass(BaseProtocolStruct)

function CSReqJoinTeam:__init()
	self.msg_type = 9154

	self.team_index = 0
	self.is_call_in_ack = 0 -- 是否回应招募
end

function CSReqJoinTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

    MsgAdapter.WriteInt(self.team_index)
    MsgAdapter.WriteInt(self.is_call_in_ack)
end

--队长解散队伍 9155(废弃)
CSDismissTeam = CSDismissTeam or BaseClass(BaseProtocolStruct)

function CSDismissTeam:__init()
	self.msg_type = 9155
end

function CSDismissTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--踢出队友 9156
CSKickOutOfTeam = CSKickOutOfTeam or BaseClass(BaseProtocolStruct)

function CSKickOutOfTeam:__init()
	self.msg_type = 9156

	self.role_id = 0
end

function CSKickOutOfTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.role_id)
end

--换队长 9157
CSChangeTeamLeader = CSChangeTeamLeader or BaseClass(BaseProtocolStruct)

function CSChangeTeamLeader:__init()
	self.msg_type = 9157

	self.role_id = 0
end

function CSChangeTeamLeader:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.role_id)
end

--玩家退出队伍 9158
CSExitTeam = CSExitTeam or BaseClass(BaseProtocolStruct)

function CSExitTeam:__init()
	self.msg_type = 9158
end

function CSExitTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求附近队伍
CSTeamListReq = CSTeamListReq or BaseClass(BaseProtocolStruct)

function CSTeamListReq:__init()
	self.msg_type = 9159
end

function CSTeamListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--改变队伍加入是否是要队长通过 9160
CSChangeMustCheck = CSChangeMustCheck or BaseClass(BaseProtocolStruct)

function CSChangeMustCheck:__init()
	self.msg_type = 9160

	self.must_check = 0
end

function CSChangeMustCheck:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.must_check)
end

--改变队伍分配模式 9161
CSChangeAssignMode = CSChangeAssignMode or BaseClass(BaseProtocolStruct)

function CSChangeAssignMode:__init()
	self.msg_type = 9161

	self.assign_mode = 1
end

function CSChangeAssignMode:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.assign_mode)
end

--改变队伍是否普通队员可邀请 9162
CSChangeMemberCanInvite = CSChangeMemberCanInvite or BaseClass(BaseProtocolStruct)

function CSChangeMemberCanInvite:__init()
	self.msg_type = 9162

	self.member_can_invite = 0
end

function CSChangeMemberCanInvite:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.member_can_invite)
end

--改变队伍限制条件 9163
CSChangeTeamLimit = CSChangeTeamLimit or BaseClass(BaseProtocolStruct)

function CSChangeTeamLimit:__init()
	self.msg_type = 9163

	self.limit_capability = 0
	self.limit_level = 0
end

function CSChangeTeamLimit:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.limit_capability)
    MsgAdapter.WriteInt(self.limit_level)
end

--快速组队
CSAutoHaveTeam = CSAutoHaveTeam or BaseClass(BaseProtocolStruct)

function CSAutoHaveTeam:__init()
	self.msg_type = 9164
end

function CSAutoHaveTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 自动答应加入队伍
CSAutoApplyJoinTeam = CSAutoApplyJoinTeam or BaseClass(BaseProtocolStruct)

function CSAutoApplyJoinTeam:__init()
	self.msg_type = 9165
	self.is_auto_join_team = 0
end

function CSAutoApplyJoinTeam:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.is_auto_join_team)
end


--发送队伍信息给玩家 9100
SCTeamInfo = SCTeamInfo or BaseClass(BaseProtocolStruct)

function SCTeamInfo:__init()
	self.msg_type = 9100
end

function SCTeamInfo:Decode()
	self.team_index = MsgAdapter.ReadInt()
	self.team_leader_index = MsgAdapter.ReadChar()
	self.assign_mode = MsgAdapter.ReadChar()
	self.must_check = MsgAdapter.ReadChar()
	self.member_can_invite = MsgAdapter.ReadChar()
	self.limit_capability = MsgAdapter.ReadInt()
	self.limit_level = MsgAdapter.ReadInt()
	self.member_count = MsgAdapter.ReadInt()
	self.team_type = MsgAdapter.ReadChar()
	self.teamfb_mode = MsgAdapter.ReadChar()
	self.teamfb_layer = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.team_member_list = {}
	for i=1,self.member_count do
		self.team_member_list[i] = TeamStruct.TeamMemberInfoRead()
	end
end

--通知队员离开了队伍	9101
SCOutOfTeam = SCOutOfTeam or BaseClass(BaseProtocolStruct)

function SCOutOfTeam:__init()
	self.msg_type = 9101
	self.reason = 0
	self.user_id = 0
	self.user_name = ""
end

function SCOutOfTeam:Decode()
	self.reason = MsgAdapter.ReadInt()
	self.user_id = MsgAdapter.ReadInt()
	self.user_name = MsgAdapter.ReadStrN(32)
end

--通知被邀请 9102
SCInviteUserTransmit = SCInviteUserTransmit or BaseClass(BaseProtocolStruct)

function SCInviteUserTransmit:__init()
	self.msg_type = 9102
end

function SCInviteUserTransmit:Decode()
	self.inviter = MsgAdapter.ReadInt()
	self.inviter_name = MsgAdapter.ReadStrN(32)
	self.inviter_camp = MsgAdapter.ReadChar()
	self.inviter_prof = MsgAdapter.ReadChar()
	self.inviter_sex = MsgAdapter.ReadChar()
	self.member_num = MsgAdapter.ReadChar()
	self.inviter_level = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
end

--通知队长有人申请加入队伍 9103
SCReqJoinTeamTransmit = SCReqJoinTeamTransmit or BaseClass(BaseProtocolStruct)

function SCReqJoinTeamTransmit:__init()
	self.msg_type = 9103
end

function SCReqJoinTeamTransmit:Decode()
	self.req_role_id = MsgAdapter.ReadInt()
	self.req_role_name = MsgAdapter.ReadStrN(32)
	self.req_role_camp = MsgAdapter.ReadChar()
	self.req_role_prof = MsgAdapter.ReadChar()
	self.req_role_sex = MsgAdapter.ReadChar()
	self.reserved = MsgAdapter.ReadChar()
	self.req_role_level = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.req_role_capability = MsgAdapter.ReadInt()
end

--请求所在场景队伍列表回复 9104
SCTeamListAck = SCTeamListAck or BaseClass(BaseProtocolStruct)

function SCTeamListAck:__init()
	self.msg_type = 9104
	self.count = 0
	self.team_list = {}
end

function SCTeamListAck:Decode()
	self.count = MsgAdapter.ReadInt()
	self.team_list = {}

	for i=1,self.count do
		self.team_list[i] = TeamStruct.TeamItemRead()
	end
end

-- 9105 通知玩家加入了队伍
SCJoinTeam = SCJoinTeam or BaseClass(BaseProtocolStruct)

function SCJoinTeam:__init()
	self.msg_type = 9105

	self.user_id = 0
	self.user_name = ""
end

function SCJoinTeam:Decode()
	self.user_id = MsgAdapter.ReadInt()
	self.user_name = MsgAdapter.ReadStrN(32)
end

-- 角色相关的队伍信息
SCRoleTeamInfo = SCRoleTeamInfo or BaseClass(BaseProtocolStruct)

function SCRoleTeamInfo:__init()
	self.msg_type = 9106
end
function SCRoleTeamInfo:Decode()
	self.is_auto_apply_join_team = MsgAdapter.ReadInt()
	self.have_team = MsgAdapter.ReadInt()
end

-- 组队掉落摇点
SCTeamRollDropRet = SCTeamRollDropRet or BaseClass(BaseProtocolStruct)

function SCTeamRollDropRet:__init()
	self.msg_type = 9107
end
function SCTeamRollDropRet:Decode()
	self.roll1 = MsgAdapter.ReadChar()
	self.roll2 = MsgAdapter.ReadChar()
	self.roll3 = MsgAdapter.ReadChar()
	self.roll4 = MsgAdapter.ReadChar()
end

--通知队长发生变更
SCTeamLeaderChange = SCTeamLeaderChange or BaseClass(BaseProtocolStruct)

function SCTeamLeaderChange:__init()
	self.msg_type = 9108
end
function SCTeamLeaderChange:Decode()
	self.user_id = MsgAdapter.ReadInt()
	self.user_name = MsgAdapter.ReadStrN(32)
end