
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

--boss之家操作
CSBossFamilyOperate = CSBossFamilyOperate or BaseClass(BaseProtocolStruct)
function CSBossFamilyOperate:__init()
	self.msg_type = 5506
	self.operate_type = 0
	self.param_1 = 1
end

function CSBossFamilyOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
end

--请求采集物生成点列表信息
CSReqGatherGeneraterList = CSReqGatherGeneraterList or BaseClass(BaseProtocolStruct)
function CSReqGatherGeneraterList:__init()
	self.msg_type = 5525
	self.get_scene_id = 0
	self.scene_key = 0
end

function CSReqGatherGeneraterList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.get_scene_id)
	MsgAdapter.WriteInt(self.scene_key)
end


--下发当前场景采集物生成点列表信息
SCGatherGeneraterList = SCGatherGeneraterList or BaseClass(BaseProtocolStruct)
function SCGatherGeneraterList:__init()
	self.msg_type = 5526
	self.gather_list = {}
end

function SCGatherGeneraterList:Decode()
	self.gather_list = {}
	local gather_count = MsgAdapter.ReadInt()
	for i=1, gather_count do
		self.gather_list[i] = {}
		self.gather_list[i].gather_id = MsgAdapter.ReadInt()
		self.gather_list[i].pos_x = MsgAdapter.ReadInt()
		self.gather_list[i].pos_y = MsgAdapter.ReadInt()
		self.gather_list[i].next_refresh_time = MsgAdapter.ReadUInt()
	end
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

--副本掉落统计
SCFBDropInfo = SCFBDropInfo or BaseClass(BaseProtocolStruct)
function SCFBDropInfo:__init()
	self.msg_type = 5527
end

function SCFBDropInfo:Decode()
	self.get_coin = MsgAdapter.ReadInt()
	self.get_item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.get_item_count do
		self.item_list[i] = {}
		self.item_list[i].num = MsgAdapter.ReadShort()
		self.item_list[i].item_id = MsgAdapter.ReadUShort()
	end
end

--副本结束
SCFBFinish = SCFBFinish or BaseClass(BaseProtocolStruct)
function SCFBFinish:__init()
	self.msg_type = 5528
end

function SCFBFinish:Decode()

end

-- 刷新下一波
CSTowerDefendNextWave = CSTowerDefendNextWave or BaseClass(BaseProtocolStruct)
function CSTowerDefendNextWave:__init()
	self.msg_type = 5529
end

function CSTowerDefendNextWave:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-----------------------------封神殿-------------------------------------------
-- 请求爬塔副本信息
CSPataFbNewAllInfo = CSPataFbNewAllInfo or BaseClass(BaseProtocolStruct)
function CSPataFbNewAllInfo:__init()
	self.msg_type = 5580
end

function CSPataFbNewAllInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 爬塔副本信息返回
SCPataFbNewAllInfo = SCPataFbNewAllInfo or BaseClass(BaseProtocolStruct)
function SCPataFbNewAllInfo:__init()
	self.msg_type = 5581
end

function SCPataFbNewAllInfo:Decode()
	self.pass_layer = MsgAdapter.ReadShort()
	self.today_layer = MsgAdapter.ReadShort()
end

-- 请求神器信息
CSPataFbNewShenQiInfoReq = CSPataFbNewShenQiInfoReq or BaseClass(BaseProtocolStruct)
function CSPataFbNewShenQiInfoReq:__init()
	self.msg_type = 5582
end

function CSPataFbNewShenQiInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 神器信息返回
SCPataFbNewShenQiInfo = SCPataFbNewShenQiInfo or BaseClass(BaseProtocolStruct)
function SCPataFbNewShenQiInfo:__init()
	self.msg_type = 5583
end

function SCPataFbNewShenQiInfo:Decode()
	self.shenqi_level = MsgAdapter.ReadShort()					-- 神器等级
	MsgAdapter.ReadShort()
	self.next_flush_exp_timestamp = MsgAdapter.ReadUInt()		-- 下次获取经验时间
	self.exp = MsgAdapter.ReadLL()								-- 当前经验值
end

-- 领取经验
CSPataFbNewGetSheneqiExp = CSPataFbNewGetSheneqiExp or BaseClass(BaseProtocolStruct)
function CSPataFbNewGetSheneqiExp:__init()
	self.msg_type = 5584
end

function CSPataFbNewGetSheneqiExp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end
---------------------------------------------------------------------------------------