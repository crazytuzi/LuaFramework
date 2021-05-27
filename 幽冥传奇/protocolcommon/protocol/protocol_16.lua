--===================================请求==================================
-- 邀请加入队伍
CSInviteJoinTeam = CSInviteJoinTeam or BaseClass(BaseProtocolStruct)
function CSInviteJoinTeam:__init()
	self:InitMsgType(16, 1)
	self.role_name = ""
end

function CSInviteJoinTeam:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
end

-- 退出队伍
CSQuitTeamReq = CSQuitTeamReq or BaseClass(BaseProtocolStruct)
function CSQuitTeamReq:__init()
	self:InitMsgType(16, 2)
end

function CSQuitTeamReq:Encode()
	self:WriteBegin()
end

-- 申请加入队伍(返回 16 9)
CSApplyJoinTeam = CSApplyJoinTeam or BaseClass(BaseProtocolStruct)
function CSApplyJoinTeam:__init()
	self:InitMsgType(16, 3)
	self.role_name = ""
end

function CSApplyJoinTeam:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
end

-- 设置一个人为队长
CSSetTeamLeader = CSSetTeamLeader or BaseClass(BaseProtocolStruct)
function CSSetTeamLeader:__init()
	self:InitMsgType(16, 4)
	self.role_id = 0
end

function CSSetTeamLeader:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
end

-- 踢出一个玩家
CSRemoveTeammate = CSRemoveTeammate or BaseClass(BaseProtocolStruct)
function CSRemoveTeammate:__init()
	self:InitMsgType(16, 5)
	self.role_id = 0
end

function CSRemoveTeammate:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
end

-- 设置拾取的方式
CSSetTeamPickupMode = CSSetTeamPickupMode or BaseClass(BaseProtocolStruct)
function CSSetTeamPickupMode:__init()
	self:InitMsgType(16, 6)
	self.mode = 0
end

function CSSetTeamPickupMode:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.mode)
end

-- 设置队伍拾取和队伍分配的时候的最低需要Loot的物品等级(返回 16 6)
CSSetTeamPickupItemLv = CSSetTeamPickupItemLv or BaseClass(BaseProtocolStruct)
function CSSetTeamPickupItemLv:__init()
	self:InitMsgType(16, 7)
	self.item_lv = 0
end

function CSSetTeamPickupItemLv:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.item_lv)
end

-- 队长分配的时候选择物品的分配者
CSSetTeamLeaderChooseBelong = CSSetTeamLeaderChooseBelong or BaseClass(BaseProtocolStruct)
function CSSetTeamLeaderChooseBelong:__init()
	self:InitMsgType(16, 8)
	self.series = 0
	self.role_id = 0
end

function CSSetTeamLeaderChooseBelong:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUInt(self.role_id)
end

-- 解散队伍
CSDismissTeam = CSDismissTeam or BaseClass(BaseProtocolStruct)
function CSDismissTeam:__init()
	self:InitMsgType(16, 9)
end

function CSDismissTeam:Encode()
	self:WriteBegin()
end

-- 回复申请入队
CSJoinTeamApplyReply = CSJoinTeamApplyReply or BaseClass(BaseProtocolStruct)
function CSJoinTeamApplyReply:__init()
	self:InitMsgType(16, 10)
	self.role_id = 0
	self.result = 0	--1同意入队, 0不同意思入队
end

function CSJoinTeamApplyReply:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
	MsgAdapter.WriteUChar(self.result)

end

-- 回复邀请入队
CSJoinTeamInviteReply = CSJoinTeamInviteReply or BaseClass(BaseProtocolStruct)
function CSJoinTeamInviteReply:__init()
	self:InitMsgType(16, 11)
	self.role_name = ""
	self.result = 0	--1同意入队, 0不同意思入队
	self.is_auto = 0 -- 1自动, 0非自己动
end

function CSJoinTeamInviteReply:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
	MsgAdapter.WriteUChar(self.result)
	MsgAdapter.WriteUChar(self.is_auto)
end

-- 召唤队友
CSCallTeammate = CSCallTeammate or BaseClass(BaseProtocolStruct)
function CSCallTeammate:__init()
	self:InitMsgType(16, 12)
	self.role_name = ""
end

function CSCallTeammate:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
end

-- 创建队伍
CSCreateTeamReq = CSCreateTeamReq or BaseClass(BaseProtocolStruct)
function CSCreateTeamReq:__init()
	self:InitMsgType(16, 13)
end

function CSCreateTeamReq:Encode()
	self:WriteBegin()
end

-- 申请获得附近队伍
CSGetNearTeamReq = CSGetNearTeamReq or BaseClass(BaseProtocolStruct)
function CSGetNearTeamReq:__init()
	self:InitMsgType(16, 14)
end

function CSGetNearTeamReq:Encode()
	self:WriteBegin()
end

--队伍成员信息(返回 16 1)
CSGetTeamInfo = CSGetTeamInfo or BaseClass(BaseProtocolStruct)
function CSGetTeamInfo:__init()
	self:InitMsgType(16, 15)
end

function CSGetTeamInfo:Encode()
	self:WriteBegin()
end



--===================================下发==================================

-- 初始化队伍成员列表
SCTeamInfo = SCTeamInfo or BaseClass(BaseProtocolStruct)
function SCTeamInfo:__init()
	self:InitMsgType(16, 1)
	self.mode = 0
	self.count = 0
	self.teammate_list = {}
	self.leader_id = 0
	self.item_lv_limit = 0
	self.team_id = 0
	self.fb_id = 0
	self.team_state = 0
end

function SCTeamInfo:Decode()
	self.mode = MsgAdapter.ReadUChar()
	self.count = MsgAdapter.ReadUChar()
	self.teammate_list = {}
	for i = 1, self.count do
		local vo = CommonReader.ReadTeamInfo()
		vo.is_teammate = true
		self.teammate_list[i] = vo
	end
	self.leader_id = MsgAdapter.ReadUInt()
	self.item_lv_limit = MsgAdapter.ReadUChar()
	self.team_id = MsgAdapter.ReadUInt()
	self.fb_id = MsgAdapter.ReadInt()
	self.team_state = MsgAdapter.ReadUChar()
end

-- 添加一个成员
SCAddTeammate = SCAddTeammate or BaseClass(BaseProtocolStruct)
function SCAddTeammate:__init()
	self:InitMsgType(16, 2)
	self.member_info = {}
end

function SCAddTeammate:Decode()
	self.member_info = CommonReader.ReadTeamInfo()
	self.member_info.is_teammate = true
end

-- 删除一个成员
SCRemoveTeammate = SCRemoveTeammate or BaseClass(BaseProtocolStruct)
function SCRemoveTeammate:__init()
	self:InitMsgType(16, 3)
	self.role_id = 0
end

function SCRemoveTeammate:Decode()
	self.role_id = MsgAdapter.ReadUInt()
end

-- 设置一个人为队长
SCSetTeamLeader = SCSetTeamLeader or BaseClass(BaseProtocolStruct)
function SCSetTeamLeader:__init()
	self:InitMsgType(16, 4)
	self.leader_id = 0
end

function SCSetTeamLeader:Decode()
	self.leader_id = MsgAdapter.ReadUInt()
end

-- 设置拾取方式
SCSetPickUpMode = SCSetPickUpMode or BaseClass(BaseProtocolStruct)
function SCSetPickUpMode:__init()
	self:InitMsgType(16, 5)
	self.mode = 0
end

function SCSetPickUpMode:Decode()
	self.mode = MsgAdapter.ReadUChar()
end

-- 设置队伍拾取和队伍分配的时候的最低需要Loot的物品等级
SCSetPickUpItemLv = SCSetPickUpItemLv or BaseClass(BaseProtocolStruct)
function SCSetPickUpItemLv:__init()
	self:InitMsgType(16, 6)
	self.item_pickup_lv = 0
end

function SCSetPickUpItemLv:Decode()
	self.item_pickup_lv = MsgAdapter.ReadUChar()
end

-- 一个玩家离线
SCTeammateOutline = SCTeammateOutline or BaseClass(BaseProtocolStruct)
function SCTeammateOutline:__init()
	self:InitMsgType(16, 7)
	self.role_id = 0
end

function SCTeammateOutline:Decode()
	self.role_id = MsgAdapter.ReadUInt()
end

-- 玩家申请加入队伍
SCOneTeamApply = SCOneTeamApply or BaseClass(BaseProtocolStruct)
function SCOneTeamApply:__init()
	self:InitMsgType(16, 9)
	self.apply_info = {}
end

function SCOneTeamApply:Decode()
	self.apply_info = CommonReader.ReadTeamInfo()
end

-- 邀请加入队伍
SCOneTeamInvite = SCOneTeamInvite or BaseClass(BaseProtocolStruct)
function SCOneTeamInvite:__init()
	self:InitMsgType(16, 10)
	self.invite_info = {}
end

function SCOneTeamInvite:Decode()
	self.invite_info = CommonReader.ReadTeamInfo()
end

-- 队员死亡或者复活
SCTeammateDieOrRelive = SCTeammateDieOrRelive or BaseClass(BaseProtocolStruct)
function SCTeammateDieOrRelive:__init()
	self:InitMsgType(16, 11)
	self.role_id = 0
	self.die_or_relive = 0   --0死亡, 1复活
end

function SCTeammateDieOrRelive:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.die_or_relive = MsgAdapter.ReadUChar()
end

-- 角色移动时，广播消息给队友
SCTeammatePos = SCTeammatePos or BaseClass(BaseProtocolStruct)
function SCTeammatePos:__init()
	self:InitMsgType(16, 12)
	self.role_id = 0
	self.scene_id = 0
	self.x = 0
	self.y = 0
	self.is_out_exp_range = 0 -- 是否超出了经验共享范围,0:超出，1未超出
end

function SCTeammatePos:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.scene_id = MsgAdapter.ReadInt()
	self.x = MsgAdapter.ReadUShort()
	self.y = MsgAdapter.ReadUShort()
	self.is_out_exp_range = MsgAdapter.ReadUChar()
end

-- 返回附近队伍
SCNearbyTeam = SCNearbyTeam or BaseClass(BaseProtocolStruct)
function SCNearbyTeam:__init()
	self:InitMsgType(16, 14)
	self.count = 0
	self.team_list = {}
end

function SCNearbyTeam:Decode()
	self.count = MsgAdapter.ReadUChar()
	self.team_list = {}
	for i = 1, self.count do
		local vo = CommonReader.ReadTeamInfo()
		self.team_list[i] = vo
	end
end