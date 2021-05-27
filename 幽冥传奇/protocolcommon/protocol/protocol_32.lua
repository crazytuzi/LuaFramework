
-- 阵营公告数据
CSCampNoticeInfo = CSCampNoticeInfo or BaseClass(BaseProtocolStruct)
function CSCampNoticeInfo:__init()
	self:InitMsgType(32, 1)
end

function CSCampNoticeInfo:Encode()
	self:WriteBegin()
end

-- 阵营职位信息
CSCampPositionInfo = CSCampPositionInfo or BaseClass(BaseProtocolStruct)
function CSCampPositionInfo:__init()
	self:InitMsgType(32, 2)
end

function CSCampPositionInfo:Encode()
	self:WriteBegin()
end

-- 邀请玩家任职
CSCampPositionInvite = CSCampPositionInvite or BaseClass(BaseProtocolStruct)
function CSCampPositionInvite:__init()
	self:InitMsgType(32, 3)
	self.position_id = 0
	self.player_name = ""
end

function CSCampPositionInvite:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.position_id)
	MsgAdapter.WriteStr(self.player_name)
end

-- 邀请结果
CSCampPositionInviteReply = CSCampPositionInviteReply or BaseClass(BaseProtocolStruct)
function CSCampPositionInviteReply:__init()
	self:InitMsgType(32, 4)
	self.obj_id = 0
	self.position_id = 0
	self.result = 0				--1=接受邀请,0=拒绝邀请
end

function CSCampPositionInviteReply:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteInt(self.position_id)
	MsgAdapter.WriteInt(self.result)
end

-- 任免职位
CSSetCampPosition = CSSetCampPosition or BaseClass(BaseProtocolStruct)
function CSSetCampPosition:__init()
	self:InitMsgType(32, 5)
	self.position_id = 0
end

function CSSetCampPosition:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.position_id)
end

-- 设置阵营公告
CSSetCampNotice = CSSetCampNotice or BaseClass(BaseProtocolStruct)
function CSSetCampNotice:__init()
	self:InitMsgType(32, 6)
	self.content = ""
end

function CSSetCampNotice:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.content)
end

-- 申请结盟
CSApplyAlliance = CSApplyAlliance or BaseClass(BaseProtocolStruct)
function CSApplyAlliance:__init()
	self:InitMsgType(32, 7)
	self.target_camp_id = 0
end

function CSApplyAlliance:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.target_camp_id)
end

-- 申请结盟结果
CSApplyAllianceReply = CSApplyAllianceReply or BaseClass(BaseProtocolStruct)
function CSApplyAllianceReply:__init()
	self:InitMsgType(32, 8)
	self.result = 0
	self.player_name = ""
end

function CSApplyAllianceReply:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.result)
	MsgAdapter.WriteStr(self.player_name)
end

-- 阵营Buff数据
CSCampBuffInfo = CSCampBuffInfo or BaseClass(BaseProtocolStruct)
function CSCampBuffInfo:__init()
	self:InitMsgType(32, 9)
end

function CSCampBuffInfo:Encode()
	self:WriteBegin()
end

-- 阵营实力数据
CSCampScoreInfo = CSCampScoreInfo or BaseClass(BaseProtocolStruct)
function CSCampScoreInfo:__init()
	self:InitMsgType(32, 10)
end

function CSCampScoreInfo:Encode()
	self:WriteBegin()
end

-- 提升江湖地位
CSUpCampStatus = CSUpCampStatus or BaseClass(BaseProtocolStruct)
function CSUpCampStatus:__init()
	self:InitMsgType(32, 11)
end

function CSUpCampStatus:Encode()
	self:WriteBegin()
end

-- 解除盟约
CSRelieveCamp = CSRelieveCamp or BaseClass(BaseProtocolStruct)
function CSRelieveCamp:__init()
	self:InitMsgType(32, 12)
end

function CSRelieveCamp:Encode()
	self:WriteBegin()
end



--================================下发================================

-- 初始阵营数据
SCInitCampInfo = SCInitCampInfo or BaseClass(BaseProtocolStruct)
function SCInitCampInfo:__init()
	self:InitMsgType(32, 1)
	self.camp_id = 0
	self.camp_status = 0
	self.camp_score = 0
	self.alliance_camp_id = 0
	self.alliance_next_time = 0
	self.leader_name = ""
	self.camp_notice = ""
	self.buff_count = 0
end

function SCInitCampInfo:Decode()
	self.camp_id = MsgAdapter.ReadInt()
	self.camp_status = MsgAdapter.ReadInt()
	self.camp_score = MsgAdapter.ReadInt()
	self.alliance_camp_id = MsgAdapter.ReadInt()
	self.alliance_next_time = MsgAdapter.ReadUInt()
	self.leader_name = MsgAdapter.ReadStr()
	self.camp_notice = MsgAdapter.ReadStr()
	self.buff_count = MsgAdapter.ReadUChar()
end

-- 阵营公告数据
SCCampNoticeChange = SCCampNoticeChange or BaseClass(BaseProtocolStruct)
function SCCampNoticeChange:__init()
	self:InitMsgType(32, 2)
	self.content = ""

end

function SCCampNoticeChange:Decode()
	self.content = MsgAdapter.ReadStr()
end

-- 江湖地位变化
SCCampStatusChange = SCCampStatusChange or BaseClass(BaseProtocolStruct)
function SCCampStatusChange:__init()
	self:InitMsgType(32, 4)
	self.camp_id = 0
	self.pass_status = 0
	self.status_id = 0
end

function SCCampStatusChange:Decode()
	self.content = MsgAdapter.ReadInt()
	self.content = MsgAdapter.ReadInt()
	self.content = MsgAdapter.ReadInt()
end

-- 阵营职位信息
SCCampPositionChange = SCCampPositionChange or BaseClass(BaseProtocolStruct)
function SCCampPositionChange:__init()
	self:InitMsgType(32, 5)
	self.position_count = 0
	self.position_t = {}
end

function SCCampPositionChange:Decode()
	self.position_count = MsgAdapter.ReadInt()
	self.position_t = {}
	for i = 1, self.position_count do
		local vo = {}
		vo.position_id = MsgAdapter.ReadInt()
		vo.role_name = MsgAdapter.ReadStr()
		position_t[i] = vo
	end
end

-- 邀请任命职位
SCInviteCampPosition = SCInviteCampPosition or BaseClass(BaseProtocolStruct)
function SCInviteCampPosition:__init()
	self:InitMsgType(32, 6)
	self.leader_id = 0
	self.position_id = 0
	self.leader_name = ""
end

function SCInviteCampPosition:Decode()
	self.leader_id = MsgAdapter.ReadLL()
	self.position_id = MsgAdapter.ReadInt()
	self.leader_name = MsgAdapter.ReadStr()
end

-- 职位变更
SCCampPositionChange = SCCampPositionChange or BaseClass(BaseProtocolStruct)
function SCCampPositionChange:__init()
	self:InitMsgType(32, 7)
	self.pass_position = 0
	self.cur_position = 0
	self.sponsor_name = ""
	self.target_name = ""
end

function SCCampPositionChange:Decode()
	self.pass_position = MsgAdapter.ReadInt()
	self.cur_position = MsgAdapter.ReadInt()
	self.sponsor_name = MsgAdapter.ReadStr()
	self.target_name = MsgAdapter.ReadStr()
end

-- 盟主设置成功
SCCampLeaderSettingSuc = SCCampLeaderSettingSuc or BaseClass(BaseProtocolStruct)
function SCCampLeaderSettingSuc:__init()
	self:InitMsgType(32, 9)
	self.position_id = 0
	self.role_name = 0
end

function SCCampLeaderSettingSuc:Decode()
	self.position_id = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStr()
end

-- 添加阵营Buff
SCAddCampBuff = SCAddCampBuff or BaseClass(BaseProtocolStruct)
function SCAddCampBuff:__init()
	self:InitMsgType(32, 10)
	self.buff_type = 0
	self.buff_gound = 0
	self.buff_time = 0
	self.buff_name = ""
	self.buff_attr = 0
	self.buff_cycle_time = 0
	self.buff_add_time = 0
end

function SCAddCampBuff:Decode()
	self.buff_type = MsgAdapter.ReadUShort()
	self.buff_gound = MsgAdapter.ReadUChar()
	self.buff_time = MsgAdapter.ReadLL()
	self.buff_name = MsgAdapter.ReadStr()
	self.buff_attr = CommonReader.ReadObjBuffAttr(self.buff_type)
	self.buff_cycle_time = MsgAdapter.ReadInt()
	self.buff_add_time = MsgAdapter.ReadInt()
end

-- 删除阵营Buff
SCAddCampBuff = SCAddCampBuff or BaseClass(BaseProtocolStruct)
function SCAddCampBuff:__init()
	self:InitMsgType(32, 11)
	self.buff_type = 0
	self.buff_gound = 0
end

function SCAddCampBuff:Decode()
	self.buff_type = MsgAdapter.ReadUShort()
	self.buff_gound = MsgAdapter.ReadUChar()
end

-- 删除某类阵营的所有Buff
SCDelAllTypeCampBuff = SCDelAllTypeCampBuff or BaseClass(BaseProtocolStruct)
function SCDelAllTypeCampBuff:__init()
	self:InitMsgType(32, 12)
	self.buff_type = 0
end

function SCDelAllTypeCampBuff:Decode()
	self.buff_type = MsgAdapter.ReadUShort()
end

-- 阵营实力排名信息
SCCampRankInfo = SCCampRankInfo or BaseClass(BaseProtocolStruct)
function SCCampRankInfo:__init()
	self:InitMsgType(32, 13)
	self.camp_count = 0
	self.camp_rank = {}
end

function SCCampRankInfo:Decode()
	self.camp_count = MsgAdapter.ReadInt()
	self.camp_rank = {}
	for i = 1, self.camp_count do
		local vo = {}
		vo.camp_id = MsgAdapter.ReadInt()
		vo.camp_score = MsgAdapter.ReadInt()
		self.camp_rank[i] = vo
	end
end

-- 阵营盟友发生变化
SCCampMateChange = SCCampMateChange or BaseClass(BaseProtocolStruct)
function SCCampMateChange:__init()
	self:InitMsgType(32, 14)
	self.old_camp_id = 0
	self.new_camp_id = {}
end

function SCCampMateChange:Decode()
	self.old_camp_id = MsgAdapter.ReadInt()
	self.new_camp_id = MsgAdapter.ReadInt()
end

-- 申请阵营结盟
SCApplyCampAlliance = SCApplyCampAlliance or BaseClass(BaseProtocolStruct)
function SCApplyCampAlliance:__init()
	self:InitMsgType(32, 15)
	self.camp_id = 0
	self.obj_id = 0
	self.obj_name = ""
end

function SCApplyCampAlliance:Decode()
	self.camp_id = MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadLL()
	self.obj_name = MsgAdapter.ReadStr()
end

-- 下发阵营Buff数据
SCCampBuffInfo = SCCampBuffInfo or BaseClass(BaseProtocolStruct)
function SCCampBuffInfo:__init()
	self:InitMsgType(32, 16)
	self.buff_count = 0
	self.buff_t = {}
end

function SCCampBuffInfo:Decode()
	self.buff_count = MsgAdapter.ReadUChar()
	for i = 1, self.buff_count do
		local vo = {}
		vo.buff_type = MsgAdapter.ReadUChar()
		vo.buff_gound = MsgAdapter.ReadUChar()
		vo.buff_time = MsgAdapter.ReadLL()
		vo.buff_name = MsgAdapter.ReadStr()
		vo.buff_attr = CommonReader.ReadObjBuffAttr(vo.buff_type)
		vo.buff_cycle_time = MsgAdapter.ReadInt()
		vo.buff_add_time = MsgAdapter.ReadInt()
		self.buff_t[i] = vo
	end
end