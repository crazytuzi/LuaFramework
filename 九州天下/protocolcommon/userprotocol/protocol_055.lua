
--无双副本踢出通知
SCWushuangFBKickOutNotify = SCWushuangFBKickOutNotify or BaseClass(BaseProtocolStruct)
function SCWushuangFBKickOutNotify:__init()
	self.msg_type = 5501
	self.notify_reason = 0 					--0 通关，1 时间结束
end

function SCWushuangFBKickOutNotify:Decode()
	self.notify_reason = MsgAdapter.ReadChar()
end

--无双副本信息返回
SCWushuangFBInfo = SCWushuangFBInfo or BaseClass(BaseProtocolStruct)
function SCWushuangFBInfo:__init()
	self.msg_type = 5502
	self.pass_level = 0 					-- 当前已通关层数
	self.has_fetch_day_reward = 0 			-- 今天奖励领取状态（0 未领取，1 已领取）
	self.reserve_ch = 0 					--
end

function SCWushuangFBInfo:Decode()
	self.pass_level = MsgAdapter.ReadShort()
	self.has_fetch_day_reward = MsgAdapter.ReadChar()
	self.reserve_ch = MsgAdapter.ReadChar()
end

--转职飞升副本结束通知
SCZhuanzhiFBNotify = SCZhuanzhiFBNotify or BaseClass(BaseProtocolStruct)
function SCZhuanzhiFBNotify:__init()
	self.msg_type = 5505
	self.notify_reason = 0
end

function SCZhuanzhiFBNotify:Decode()
	self.notify_reason = MsgAdapter.ReadChar()
	self.zhuanzhi_fb_type = MsgAdapter.ReadChar()
end

--请求无双副本信息
CSWushuangFBInfo = CSWushuangFBInfo or BaseClass(BaseProtocolStruct)
function CSWushuangFBInfo:__init()
	self.msg_type = 5551
	self.request_type = 0 					-- 0 请求信息，1 请求奖励
end

function CSWushuangFBInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.request_type)
end

--经验副本信息
SCExpFbInfo = SCExpFbInfo or BaseClass(BaseProtocolStruct)
function SCExpFbInfo:__init()
	self.msg_type = 5555
	self.time_out_stamp = 0				--副本超时结束时间戳
	self.scene_type = 0					--场景类型
	self.is_finish = 0					--是否结束
	self.guwu_times = 0					--鼓舞次数
	self.team_member_num = 0			--队伍人数
	self.exp = 0						--经验
	self.wave = 0						--波数
	self.kill_allmonster_num = 0		--杀怪数
	self.start_time = 0 				--开始时间
end

function SCExpFbInfo:Decode()
	self.time_out_stamp = MsgAdapter.ReadLL()
	self.scene_type = MsgAdapter.ReadChar()
	self.is_finish = MsgAdapter.ReadChar()
	self.guwu_times = MsgAdapter.ReadChar()
	self.team_member_num = MsgAdapter.ReadChar()
	self.exp = MsgAdapter.ReadLL()
	self.wave = MsgAdapter.ReadShort()
	self.kill_allmonster_num = MsgAdapter.ReadUShort()
	self.start_time = MsgAdapter.ReadLL()
end

-- 经验副本购买鼓舞
CSExpFbPayGuwu = CSExpFbPayGuwu or BaseClass(BaseProtocolStruct)
function CSExpFbPayGuwu:__init()
	self.msg_type = 5556
end

function CSExpFbPayGuwu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--组队装备副本
SCTeamEquipFbInfo = SCTeamEquipFbInfo or BaseClass(BaseProtocolStruct)
function SCTeamEquipFbInfo:__init()
	self.msg_type = 5570
	self.user_count = 0
	self.user_info = {}
end

function SCTeamEquipFbInfo:Decode()
	self.user_count = MsgAdapter.ReadInt()
	self.user_info = {}
	for i = 1, self.user_count do
		self.user_info[i] = {}
		self.user_info[i].user_name = MsgAdapter.ReadStrN(32)
		self.user_info[i].dps = MsgAdapter.ReadInt()
	end
end

--组队装备副本掉落次数信息
SCTeamEquipFbDropCountInfo = SCTeamEquipFbDropCountInfo or BaseClass(BaseProtocolStruct)
function SCTeamEquipFbDropCountInfo:__init()
	self.msg_type = 5571
	self.team_equip_fb_pass_flag = 0
	self.team_equip_fb_day_count = 0
	self.team_equip_fb_day_buy_count = 0
end

function SCTeamEquipFbDropCountInfo:Decode()
	self.team_equip_fb_pass_flag = MsgAdapter.ReadInt()
	self.team_equip_fb_day_count = MsgAdapter.ReadInt()
	self.team_equip_fb_day_buy_count = MsgAdapter.ReadInt()
end

-- 组队装备副本购买掉落次数
CSTeamEquipFbBuyDropCount = CSTeamEquipFbBuyDropCount or BaseClass(BaseProtocolStruct)
function CSTeamEquipFbBuyDropCount:__init()
	self.msg_type = 5572
end

function CSTeamEquipFbBuyDropCount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--------------------------------------
--个人塔防
--------------------------------------

-- 刷新下一波
CSTowerDefendNextWave = CSTowerDefendNextWave or BaseClass(BaseProtocolStruct)
function CSTowerDefendNextWave:__init()
	self.msg_type = 5581
end

function CSTowerDefendNextWave:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 个人塔防购买次数
CSTowerDefendBuyJoinTimes = CSTowerDefendBuyJoinTimes or BaseClass(BaseProtocolStruct)

function CSTowerDefendBuyJoinTimes:__init()
	self.msg_type = 5582
end

function CSTowerDefendBuyJoinTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 个人塔防角色信息
SCTowerDefendRoleInfo = SCTowerDefendRoleInfo or BaseClass(BaseProtocolStruct)
function SCTowerDefendRoleInfo:__init()
	self.msg_type = 5590
	self.join_times = 0
	self.buy_join_times = 0
	self.max_pass_level = 0
	self.auto_fb_free_times = 0
	self.item_buy_join_times = 0
end

function SCTowerDefendRoleInfo:Decode()
	self.join_times = MsgAdapter.ReadChar()
	self.buy_join_times = MsgAdapter.ReadChar()
	self.max_pass_level = MsgAdapter.ReadChar()
	self.auto_fb_free_times = MsgAdapter.ReadChar()
	self.item_buy_join_times = MsgAdapter.ReadShort()
	self.personal_last_level_star = MsgAdapter.ReadShort()
end

SCTowerDefendInfo = SCTowerDefendInfo or BaseClass(BaseProtocolStruct)
function SCTowerDefendInfo:__init()
	self.msg_type = 5591
end

function SCTowerDefendInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.time_out_stamp = MsgAdapter.ReadUInt()
	self.is_finish = MsgAdapter.ReadShort()
	self.is_pass = MsgAdapter.ReadShort()
	self.pass_time_s = MsgAdapter.ReadInt()

	self.life_tower_left_hp = MsgAdapter.ReadInt()
	self.life_tower_left_maxhp = MsgAdapter.ReadInt()
	self.curr_wave = MsgAdapter.ReadShort()
	self.energy = MsgAdapter.ReadShort()
	self.next_wave_refresh_time = MsgAdapter.ReadInt()
	self.clear_wave_count = MsgAdapter.ReadShort()
	self.death_count = MsgAdapter.ReadShort()

	-- self.last_perform_time_list = {}
	-- for i=1,2 do
	-- 	table.insert(self.last_perform_time_list, MsgAdapter.ReadUInt())
	-- end

	-- 打怪的掉落，可用在结算面板中
	self.get_coin = MsgAdapter.ReadInt()
	local get_item_count = MsgAdapter.ReadInt()
	self.pick_drop_list = {}

	for i=1, get_item_count do
		local drop_obj = {}
		drop_obj.num = MsgAdapter.ReadShort()
		drop_obj.item_id = MsgAdapter.ReadUShort()

		table.insert(self.pick_drop_list, drop_obj)
	end
end

-- 个人塔防警告
SCTowerDefendWarning = SCTowerDefendWarning or BaseClass(BaseProtocolStruct)
function SCTowerDefendWarning:__init()
	self.msg_type = 5592
	self.warning_type = 0
	self.percent = 0
end

function SCTowerDefendWarning:Decode()
	self.warning_type = MsgAdapter.ReadShort()
	self.percent = MsgAdapter.ReadShort()
end

-- 个人塔防结果
SCTowerDefendResult = SCTowerDefendResult or BaseClass(BaseProtocolStruct)
function SCTowerDefendResult:__init()
	self.msg_type = 5593
	self.is_passed = 0
	self.clear_wave_count = 0
end

function SCTowerDefendResult:Decode()
	self.is_passed = MsgAdapter.ReadChar()
	self.clear_wave_count = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end


