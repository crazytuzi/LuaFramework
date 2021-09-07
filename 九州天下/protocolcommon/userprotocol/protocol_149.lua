--跨服排行活动
CSCrossRARankGetRank = CSCrossRARankGetRank or BaseClass(BaseProtocolStruct)
function CSCrossRARankGetRank:__init()
	self.msg_type = 14901
	self.cross_activity_type = 0
	self.param_1 = 0
end

function CSCrossRARankGetRank:Encode()
	
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.cross_activity_type)
	MsgAdapter.WriteShort(self.param_1)
end

--跨服统一请求协议
CSCrossCommonOperaReq = CSCrossCommonOperaReq or BaseClass(BaseProtocolStruct)
function CSCrossCommonOperaReq:__init()
	self.msg_type = 14902

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSCrossCommonOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteLL(self.param_3)
end

-- 通知玩家进入跨服
SCNoticeCanEnterCross = SCNoticeCanEnterCross or BaseClass(BaseProtocolStruct)
function SCNoticeCanEnterCross:__init()
	self.msg_type = 14903

	self.activity_type = 0
end

function SCNoticeCanEnterCross:Decode()
	self.activity_type = MsgAdapter.ReadInt()
end

-- 跨服组队本，房间信息改变
SCNoticeCrossTeamFBRoomInfoChange = SCNoticeCrossTeamFBRoomInfoChange or BaseClass(BaseProtocolStruct)
function SCNoticeCrossTeamFBRoomInfoChange:__init()
	self.msg_type = 14904

	self.layer = 0
	self.room = 0
	self.opera_uuid = 0
	self.opera_uid = 0
	self.opera_platform = 0
	self.opera_type = 0
end

function SCNoticeCrossTeamFBRoomInfoChange:Decode()
	self.layer = MsgAdapter.ReadInt()
	self.room = MsgAdapter.ReadInt()
	-- self.opera_uuid = MsgAdapter.ReadLL()
	self.opera_uid = MsgAdapter.ReadUInt()
	self.opera_platform = MsgAdapter.ReadUInt()
	self.opera_type = MsgAdapter.ReadInt()
	self.opera_uuid = self.opera_uid + (self.opera_platform * (2 ^ 32))
end

-- 跨服组队本，房间列表信息
SCCrossTeamFBRoomListInfo = SCCrossTeamFBRoomListInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFBRoomListInfo:__init()
	self.msg_type = 14905

	self.room_count = 0
	self.room_info = {}
end

function SCCrossTeamFBRoomListInfo:Decode()
	self.room_info = {}
	self.room_count = MsgAdapter.ReadInt()
	for i = 1, self.room_count do
		self.room_info[i] = {}
		self.room_info[i].need_capability = MsgAdapter.ReadInt()
		self.room_info[i].password = MsgAdapter.ReadInt()
		self.room_info[i].is_auto_start = MsgAdapter.ReadInt()
		self.room_info[i].leader_name = MsgAdapter.ReadStrN(32)
		self.room_info[i].leader_prof = MsgAdapter.ReadChar()
		self.room_info[i].leader_sex = MsgAdapter.ReadChar()
		self.room_info[i].fb_state = MsgAdapter.ReadChar()
		self.room_info[i].user_count = MsgAdapter.ReadChar()
		self.room_info[i].room = MsgAdapter.ReadInt()
		self.room_info[i].layer = MsgAdapter.ReadInt()
	end
end

-- 跨服组队本，房间信息
SCCrossTeamFBRoomInfo = SCCrossTeamFBRoomInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFBRoomInfo:__init()
	self.msg_type = 14906

	self.layer = 0
	self.room = 0
	self.is_auto_start = 0
	self.fb_state = 0
	self.user_count = 0
	self.user_info = {}
end

function SCCrossTeamFBRoomInfo:Decode()
	self.user_info = {}
	self.layer = MsgAdapter.ReadInt()
	self.room = MsgAdapter.ReadInt()
	self.is_auto_start = MsgAdapter.ReadShort()
	self.fb_state = MsgAdapter.ReadShort()
	self.user_count = MsgAdapter.ReadInt()
	for i = 1, self.user_count do
		self.user_info[i] = {}
		-- self.user_info[i].uuid = MsgAdapter.ReadLL()
		self.user_info[i].uid = MsgAdapter.ReadUInt()
		self.user_info[i].platform = MsgAdapter.ReadUInt()
		self.user_info[i].prof = MsgAdapter.ReadChar()
		self.user_info[i].sex = MsgAdapter.ReadChar()
		self.user_info[i].camp = MsgAdapter.ReadChar()
		self.user_info[i].user_state = MsgAdapter.ReadChar()
		self.user_info[i].name = MsgAdapter.ReadStrN(32)
		self.user_info[i].capability = MsgAdapter.ReadInt()
		self.user_info[i].index = MsgAdapter.ReadInt()
		self.user_info[i].uuid = self.user_info[i].uid + (self.user_info[i].platform * (2 ^ 32))
		self.user_info[i].server_id = UserVo.GetServerId(self.user_info[i].uid)
	end
end

--跨服充值排行
SCCrossRAChongzhiRankGetRankACK = SCCrossRAChongzhiRankGetRankACK or BaseClass(BaseProtocolStruct)
function SCCrossRAChongzhiRankGetRankACK:__init()
	self.msg_type = 14907
end

function SCCrossRAChongzhiRankGetRankACK:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_count do
		local vo = {}
		vo.total_chongzhi = MsgAdapter.ReadInt()
		vo.role_name = MsgAdapter.ReadStrN(32)
		vo.server_id = MsgAdapter.ReadInt()
		vo.plat_type = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.avatar_key_big = MsgAdapter.ReadInt()
		vo.avatar_key_small = MsgAdapter.ReadInt()
		vo.prof = MsgAdapter.ReadShort()
		vo.sex = MsgAdapter.ReadShort()
		self.rank_list[i] = vo
	end
end

-- 14908 跨服排行活动，请求战区排行榜返回
SCCrossRARankGetRankACK = SCCrossRARankGetRankACK or BaseClass(BaseProtocolStruct)
function SCCrossRARankGetRankACK:__init()
	self.msg_type = 14908
end

function SCCrossRARankGetRankACK:Decode()
	self.rank_type = MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadShort()
	self.rank_list = {}
	for i = 1, self.rank_count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
      	vo.user_id = MsgAdapter.ReadInt()
      	vo.user_name = MsgAdapter.ReadStrN(32)
      	vo.level = MsgAdapter.ReadInt()
      	vo.prof = MsgAdapter.ReadChar()
      	vo.sex = MsgAdapter.ReadChar()
      	vo.camp = MsgAdapter.ReadChar()
      	MsgAdapter.ReadChar()
      	vo.exp = MsgAdapter.ReadLL()
      	vo.rank_type = MsgAdapter.ReadInt()
      	vo.rank_value = MsgAdapter.ReadLL()
      	vo.record_index = MsgAdapter.ReadInt()
      	vo.flexible_ll = MsgAdapter.ReadLL()
      	MsgAdapter.ReadLL()
      	vo.flexible_name = MsgAdapter.ReadStrN(32)
      	vo.avatar_key_big = MsgAdapter.ReadInt()
		vo.avatar_key_small = MsgAdapter.ReadInt()
      	vo.origin_merge_server_id = MsgAdapter.ReadInt()
      	self.rank_list[i] = vo
	end
end