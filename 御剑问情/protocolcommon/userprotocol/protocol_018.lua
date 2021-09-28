-- 请求已接任务列表放回
SCTaskListAck = SCTaskListAck or BaseClass(BaseProtocolStruct)
function SCTaskListAck:__init()
	self.msg_type = 1801
end
function SCTaskListAck:Decode()
	self.task_accepted_list = {}
	local count = MsgAdapter.ReadInt()
	for i=1,count do
		local task_info = ProtocolStruct.ReadTaskInfo()
		self.task_accepted_list[task_info.task_id] = task_info
	end
end

--单条已接任务信息
SCTaskInfo = SCTaskInfo or BaseClass(BaseProtocolStruct)
function SCTaskInfo:__init()
	self.msg_type = 1802
end
function SCTaskInfo:Decode()
	self.reason = MsgAdapter.ReadShort()	--0.信息改变 1.接取 2.移除
	self.task_id = MsgAdapter.ReadUShort()
	self.is_complete = MsgAdapter.ReadChar()
	self.is_silent = MsgAdapter.ReadChar()
	self.param = MsgAdapter.ReadShort()
	self.accept_time = MsgAdapter.ReadUInt()
end

--已完成任务列表返回
SCTaskRecorderList = SCTaskRecorderList or BaseClass(BaseProtocolStruct)
function SCTaskRecorderList:__init()
	self.msg_type = 1803
end
function SCTaskRecorderList:Decode()
	self.task_completed_id_list = {}
	local count = MsgAdapter.ReadUInt()
	for i=1,count do
		self.task_completed_id_list[MsgAdapter.ReadUShort()] = 1
	end
end

--任务记录列表数据改变
SCTaskRecorderInfo = SCTaskRecorderInfo or BaseClass(BaseProtocolStruct)
function SCTaskRecorderInfo:__init()
	self.msg_type = 1804
end
function SCTaskRecorderInfo:Decode()
	self.completed_task_id = MsgAdapter.ReadUShort()
end

-- 护送人物信息
SCHusongInfo = SCHusongInfo or BaseClass(BaseProtocolStruct)
function SCHusongInfo:__init()
	self.msg_type = 1806
end

function SCHusongInfo:Decode()
	self.notfiy_reason = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadShort()
	self.task_id = MsgAdapter.ReadUShort()
	self.task_color = MsgAdapter.ReadChar()
	self.accept_in_activitytime = MsgAdapter.ReadChar()
	self.is_use_hudun = MsgAdapter.ReadChar()
end

--日常任务信息
SCTuMoTaskInfo = SCTuMoTaskInfo or BaseClass(BaseProtocolStruct)
function SCTuMoTaskInfo:__init()
	self.msg_type = 1805
	self.notify_reason = 0												-- 通知原因
	self.commit_times = 0												-- 提交任务次数
	self.is_accept = 0													-- 任务是否已经被接受
	self.task_id = 0													-- 任务id
	self.has_fetch_complete_all_reward = 0								-- 是否领取了完成所有任务的奖励
	self.star_level = 0													-- 星星等级
	self.reserve_sh = 0													-- 保留

end
function SCTuMoTaskInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()	--通知原因 TUMO_NOTIFY_REASON_TYPE
	self.commit_times = MsgAdapter.ReadShort()	--提交任务次数 最大次数是20次
	self.is_accept = MsgAdapter.ReadChar()		--任务是否已经被接受(领取)
	self.has_fetch_complete_all_reward = MsgAdapter.ReadChar() 		--是否领取了完成所有任务的奖励
	self.task_id = MsgAdapter.ReadUShort() 		--任务iD
	-- self.star_level = MsgAdapter.ReadChar() 		--星星等级
	-- self.reserve_sh = MsgAdapter.ReadShort() 		--保留
end

-- 公会任务信息
SCGuildTaskInfo = SCGuildTaskInfo or BaseClass(BaseProtocolStruct)
function SCGuildTaskInfo:__init()
	self.msg_type = 1807
end

function SCGuildTaskInfo:Decode()
	self.double_reward_flag = MsgAdapter.ReadChar()
	self.is_finish = MsgAdapter.ReadChar()		-- 是否完成所有任务
	self.complete_task_count = MsgAdapter.ReadShort()
	self.guild_task_max_count = MsgAdapter.ReadInt()
end

--可接任务列表
SCAccpetableTaskList = SCAccpetableTaskList or BaseClass(BaseProtocolStruct)
function SCAccpetableTaskList:__init()
	self.msg_type = 1808
end
function SCAccpetableTaskList:Decode()
	self.task_can_accept_id_list = {}
	local count = MsgAdapter.ReadInt()
	for i=1,count do
		self.task_can_accept_id_list[MsgAdapter.ReadUShort()] = 1
	end
end

--跑环任务信息
SCPaohuanTaskInfo = SCPaohuanTaskInfo or BaseClass(BaseProtocolStruct)
function SCPaohuanTaskInfo:__init()
	self.msg_type = 1810
end
function SCPaohuanTaskInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()								-- 通知原因
	self.commit_times = MsgAdapter.ReadShort()								-- 提交任务次数
	self.has_fetch_complete_all_reward = MsgAdapter.ReadShort()				-- 领取阶段奖励
	self.is_accept = MsgAdapter.ReadShort()									-- 任务是否已经被接受
	self.task_id = MsgAdapter.ReadUShort()									-- 任务id
end

--跑环翻牌奖池
SCPaoHuanRollPool = SCPaoHuanRollPool or BaseClass(BaseProtocolStruct)
function SCPaoHuanRollPool:__init()
	self.msg_type = 1811
end
function SCPaoHuanRollPool:Decode()
	self.roll_item_list = {}
	for i = 0, 7 do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.is_bind = MsgAdapter.ReadChar()
		vo.num = MsgAdapter.ReadChar()
		self.roll_item_list[i] = vo
	end
end

--跑环翻牌摇奖信息
SCPaoHuanRollInfo = SCPaoHuanRollInfo or BaseClass(BaseProtocolStruct)
function SCPaoHuanRollInfo:__init()
	self.msg_type = 1812
end
function SCPaoHuanRollInfo:Decode()
	self.data = {}
	self.data.reason = MsgAdapter.ReadShort()
	self.data.phase = MsgAdapter.ReadChar()
	self.data.hit_seq = MsgAdapter.ReadChar()
	self.data.clint_click_index = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

--精华护送信息
SCCommonInfo = SCCommonInfo or BaseClass(BaseProtocolStruct)
function SCCommonInfo:__init()
	self.msg_type = 1814
end
function SCCommonInfo:Decode()
	self.info_type = MsgAdapter.ReadInt()		--精华护送相关时，该值为1，见枚举
	self.param1 = MsgAdapter.ReadInt()			--当日提交次数	-- -1表示采集物刷新
	self.param2 = MsgAdapter.ReadInt()			--失效时间
	self.param3 = MsgAdapter.ReadInt()			--采集次数
	self.param4 = MsgAdapter.ReadInt()			--截取成功次数
end

--精华护送状态改变
SCJinghuaHusongViewChange = SCJinghuaHusongViewChange or BaseClass(BaseProtocolStruct)
function SCJinghuaHusongViewChange:__init()
	self.msg_type = 1815
end
function SCJinghuaHusongViewChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()						--视野内角色ID
	self.jinghua_husong_status = MsgAdapter.ReadShort()			--角色对应的护送状态
	self.jinghua_husong_type = MsgAdapter.ReadChar() 			--当前护送精华的类型，0为大灵石，1为小灵石
end

--护送消耗显示
SCHusongConsumeInfo = SCHusongConsumeInfo or BaseClass(BaseProtocolStruct)
function SCHusongConsumeInfo:__init()
	self.msg_type = 1821
	self.token_num = 0
	self.gold_num = 0
	self.bind_gold_num = 0
end
function SCHusongConsumeInfo:Decode()
	self.token_num = MsgAdapter.ReadInt()
	self.gold_num = MsgAdapter.ReadInt()
	self.bind_gold_num = MsgAdapter.ReadInt()
end

--任务转盘奖励
SCTaskRollReward = SCTaskRollReward or BaseClass(BaseProtocolStruct)
function SCTaskRollReward:__init()
	self.msg_type = 1822
end
function  SCTaskRollReward:Decode()
	self.is_finish =MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.list = {}
	for i=1, 20 do
		self.list[i] = {}
		self.list[i].type = MsgAdapter.ReadInt()
		self.list[i].index = MsgAdapter.ReadInt()
	end
end

--跑环翻牌请求
CSPaoHuanRollReq = CSPaoHuanRollReq or BaseClass(BaseProtocolStruct)
function CSPaoHuanRollReq:__init()
	self.msg_type = 1866
	self.client_click_index = 0
end
function CSPaoHuanRollReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.client_click_index)
	MsgAdapter.WriteShort(0)
end

--跑环任务信息请求
CSGetPaoHuanTaskInfo = CSGetPaoHuanTaskInfo or BaseClass(BaseProtocolStruct)
function CSGetPaoHuanTaskInfo:__init()
	self.msg_type = 1867
end
function CSGetPaoHuanTaskInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跑环任务跳过请求
CSPaoHuanSkipTask = CSPaoHuanSkipTask or BaseClass(BaseProtocolStruct)
function CSPaoHuanSkipTask:__init()
	self.msg_type = 1868
end
function CSPaoHuanSkipTask:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skip_all)
	MsgAdapter.WriteUShort(self.task_id)
	MsgAdapter.WriteInt(0)
end


--请求已接任务列表
CSTaskListReq = CSTaskListReq or BaseClass(BaseProtocolStruct)
function CSTaskListReq:__init()
	self.msg_type = 1850
end
function CSTaskListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--放弃任务
CSTaskGiveup = CSTaskGiveup or BaseClass(BaseProtocolStruct)
function CSTaskGiveup:__init()
	self.msg_type = 1851
end
function CSTaskGiveup:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.task_id)
end

--使用飞天神靴
CSFlyByShoe = CSFlyByShoe or BaseClass(BaseProtocolStruct)
function CSFlyByShoe:__init()
	self.msg_type = 1852
end
function CSFlyByShoe:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteInt(self.scene_key)
	MsgAdapter.WriteShort(self.pos_x)
	MsgAdapter.WriteShort(self.pos_y)
	MsgAdapter.WriteShort(self.item_index)
	MsgAdapter.WriteShort(self.is_force)
end

--接受任务
CSTaskAccept = CSTaskAccept or BaseClass(BaseProtocolStruct)
function CSTaskAccept:__init()
	self.msg_type = 1853
end
function CSTaskAccept:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.task_id)
end

--提交完成任务
CSTaskCommit = CSTaskCommit or BaseClass(BaseProtocolStruct)
function CSTaskCommit:__init()
	self.msg_type = 1854
end
function CSTaskCommit:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.task_id)
end

-- 刷新护送人物
CSRefreshHusongTask = CSRefreshHusongTask or BaseClass(BaseProtocolStruct)
function CSRefreshHusongTask:__init()
	self.msg_type = 1857
end

function CSRefreshHusongTask:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.is_autoflush)
	MsgAdapter.WriteChar(self.is_autobuy)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.to_color)
end

-- 购买次数
CSHusongBuyTimes = CSHusongBuyTimes or BaseClass(BaseProtocolStruct)
function CSHusongBuyTimes:__init()
	self.msg_type = 1859
end

function CSHusongBuyTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--和npc对话
CSTaskTalkToNpc = CSTaskTalkToNpc or BaseClass(BaseProtocolStruct)
function CSTaskTalkToNpc:__init()
	self.msg_type = 1855
end
function CSTaskTalkToNpc:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.npc_id)
	MsgAdapter.WriteShort(0)
end

--请求屠魔任务信息
CSGetTuMoTaskInfo = CSGetTuMoTaskInfo or BaseClass(BaseProtocolStruct)
function CSGetTuMoTaskInfo:__init()
	self.msg_type = 1856
end
function CSGetTuMoTaskInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求屠魔任务 提交任务 commit_all task_id -- 1 x 一键完成 0 x 双倍奖励
CSTumoCommitTask = CSTumoCommitTask or BaseClass(BaseProtocolStruct)
function CSTumoCommitTask:__init()
	self.msg_type = 1860
	self.commit_all = 0
	self.task_id = 0
	self.is_force_max_star = 0;
end
function CSTumoCommitTask:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.commit_all)
	MsgAdapter.WriteUShort(self.task_id)
	MsgAdapter.WriteInt(self.is_force_max_star)
end

--一键完成仙盟任务的协议
CSFinishAllGuildTask = CSFinishAllGuildTask or BaseClass(BaseProtocolStruct)
function CSFinishAllGuildTask:__init()
	self.msg_type = 1861
end
function CSFinishAllGuildTask:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--获取完成所有任务奖励请求
CSTumoFetchCompleteAllReward = CSTumoFetchCompleteAllReward or BaseClass(BaseProtocolStruct)
function CSTumoFetchCompleteAllReward:__init()
	self.msg_type = 1863
end
function CSTumoFetchCompleteAllReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--刷新星星
CSTumoResetStar = CSTumoResetStar or BaseClass(BaseProtocolStruct)
function CSTumoResetStar:__init()
	self.msg_type = 1865
end
function CSTumoResetStar:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--普通操作
CSReqCommonOpreate = CSReqCommonOpreate or BaseClass(BaseProtocolStruct)
function CSReqCommonOpreate:__init()
	self.msg_type = 1869
	self.operate_type = 0 							--填2为请求精华护送信息，见枚举COMMON_OPERATE_TYPE，服务端发送SCCommonInfo
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSReqCommonOpreate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

--普通信息
SCCommonInfo = SCCommonInfo or BaseClass(BaseProtocolStruct)
function SCCommonInfo:__init()
	self.msg_type = 1814
end

function SCCommonInfo:Decode()
	self.info_type = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
	self.param3 = MsgAdapter.ReadInt()
	self.param4 = MsgAdapter.ReadInt()
end

--神装信息
SCShenzhaungInfo = SCShenzhaungInfo or BaseClass(BaseProtocolStruct)
function SCShenzhaungInfo:__init()
	self.msg_type = 1879
end

function SCShenzhaungInfo:Decode()
	self.part_list = {}

	for i=0, EquipmentShenData.SHEN_EQUIP_NUM - 1 do
		local vo = {}
		vo.index = i
		vo.level = MsgAdapter.ReadShort()	--每个部位对应的等级
		self.part_list[i] = vo
	end
end

CSShenzhaungOper = CSShenzhaungOper or BaseClass(BaseProtocolStruct)
function CSShenzhaungOper:__init()
	self.msg_type = 1870
end

function CSShenzhaungOper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.index)
	-- MsgAdapter.WriteInt(self.repeat_times)
	-- MsgAdapter.WriteInt(self.is_auto_buy)
end

--查找玩家在哪
CSSeekRoleWhere = CSSeekRoleWhere or BaseClass(BaseProtocolStruct)
function CSSeekRoleWhere:__init()
	self.msg_type = 1871
	self.seek_name = ""
end

function CSSeekRoleWhere:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStrN(self.seek_name, 32)
end

--查找玩家在哪返回
SCSeekRoleInfo = SCSeekRoleInfo or BaseClass(BaseProtocolStruct)
function SCSeekRoleInfo:__init()
	self.msg_type = 1817
end

function SCSeekRoleInfo:Decode()
	self.scene_id = MsgAdapter.ReadInt()  --为0时表示不在线
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

--皇城会战信息
SCHuangChengHuiZhanInfo = SCHuangChengHuiZhanInfo or BaseClass(BaseProtocolStruct)
function SCHuangChengHuiZhanInfo:__init()
	self.msg_type = 1818
end

function SCHuangChengHuiZhanInfo:Decode()
	self.monster_num = MsgAdapter.ReadInt()
	self.next_refrestime = MsgAdapter.ReadUInt()
	local list_count = MsgAdapter.ReadInt()
	self.monster_list = {}
	for i=1,list_count do
		local vo = {}
		vo.monster_id = MsgAdapter.ReadUShort()
		vo.monster_count = MsgAdapter.ReadUShort()
		self.monster_list[vo.monster_id] = vo
	end
end

--皇城会战信息
SCHuangChengHuiZhanRoleInfo = SCHuangChengHuiZhanRoleInfo or BaseClass(BaseProtocolStruct)
function SCHuangChengHuiZhanRoleInfo:__init()
	self.msg_type = 1823
end

function SCHuangChengHuiZhanRoleInfo:Decode()
	self.add_exp = MsgAdapter.ReadLL()
	local list_count = MsgAdapter.ReadInt()
	self.drop_list = {}
	for i=1,list_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		self.drop_list[vo.item_id] = vo
	end
end

-- 进阶奖励操作请求
CSJinjiesysRewardOpera = CSJinjiesysRewardOpera or BaseClass(BaseProtocolStruct)
function CSJinjiesysRewardOpera:__init()
	self.msg_type = 1824
	self.operate = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSJinjiesysRewardOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate)		-- 操作类型
	MsgAdapter.WriteShort(self.param1)		-- 进阶系统类型
	MsgAdapter.WriteShort(self.param2)		-- 大目标/小目标   0/1
	MsgAdapter.WriteShort(self.param3)		-- 暂时无用
end

--进阶奖励信息
SCJinjiesysRewardInfo = SCJinjiesysRewardInfo or BaseClass(BaseProtocolStruct)
function SCJinjiesysRewardInfo:__init()
	self.msg_type = 1825
end

function SCJinjiesysRewardInfo:Decode()
	self.reward_flag = MsgAdapter.ReadUInt()			-- 各系统有没有领取/购买激活道具的标识	大目标
	self.can_reward_flag = MsgAdapter.ReadUInt()		-- 各系统能不能免费领取					大目标
	self.reward_flag_1 = MsgAdapter.ReadUInt()			-- 各系统有没有领取/购买激活道具的标识	小目标
	self.can_reward_flag_1 = MsgAdapter.ReadUInt()		-- 各系统能不能免费领取					小目标
end

--进阶各系统结束时间戳
SCJinjiesysRewardTimestamp = SCJinjiesysRewardTimestamp or BaseClass(BaseProtocolStruct)
function SCJinjiesysRewardTimestamp:__init()
	self.msg_type = 1826
end

function SCJinjiesysRewardTimestamp:Decode()
	self.use_sys_count = MsgAdapter.ReadInt()			--系统数量
	self.timestamp_list = {}
	if self.use_sys_count <= 0 then
		return
	end

	for i=1, self.use_sys_count do
		local systime_stamp = {}
		systime_stamp.reward_type = MsgAdapter.ReadShort()		--大目标/小目标 0/1
		systime_stamp.sys_type = MsgAdapter.ReadShort()			--系统类型
		systime_stamp.end_timestamp = MsgAdapter.ReadUInt()		--结束时间戳
		self.timestamp_list[i] = systime_stamp
	end
end

--周常任务
SCWeekPaohuanTaskInfo = SCWeekPaohuanTaskInfo or BaseClass(BaseProtocolStruct)
function SCWeekPaohuanTaskInfo:__init()
	self.msg_type = 1827
end

function SCWeekPaohuanTaskInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()					-- 通知原因
	self.complete_times = MsgAdapter.ReadShort()				-- 提交任务次数
	self.is_accept = MsgAdapter.ReadShort()						-- 任务是否已经被接受
	self.task_id = MsgAdapter.ReadShort()						-- 任务id
end

-- 师门装备操作请求
CSCampEquipOperate = CSCampEquipOperate or BaseClass(BaseProtocolStruct)
function CSCampEquipOperate:__init()
	self.msg_type = 1872
end

function CSCampEquipOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

--师门装备信息。请求准备信息时会发所有装备的信息。格子里改变会下发，通过count控制
SCCampEquipInfo = SCCampEquipInfo or BaseClass(BaseProtocolStruct)
function SCCampEquipInfo:__init()
	self.msg_type = 1819
	self.equip_list = {}
end

function SCCampEquipInfo:Decode()
	self.equip_list = {}
	self.beast_level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.beast_exp = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i=0, count - 1 do
		local index = MsgAdapter.ReadInt()
		local itemdata = ProtocolStruct.ReadItemDataWrapper()
		self.equip_list[index] = itemdata
		local hunlian_level = MsgAdapter.ReadInt()
		self.equip_list[index].hunlian_level = hunlian_level
		self.equip_list[index].index = index
	end
end

-- 师门普通夺宝请求
CSCampNormalDuobaoOperate = CSCampNormalDuobaoOperate or BaseClass(BaseProtocolStruct)
function CSCampNormalDuobaoOperate:__init()
	self.msg_type = 1873
end

function CSCampNormalDuobaoOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate)
	MsgAdapter.WriteInt(self.param1)
end

-- 运送施放护盾
CSHuSongAddShield = CSHuSongAddShield or BaseClass(BaseProtocolStruct)
function CSHuSongAddShield:__init()
	self.msg_type = 1874
end

function CSHuSongAddShield:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 同步跳跃
CSSyncJump = CSSyncJump or BaseClass(BaseProtocolStruct)
function CSSyncJump:__init()
	self.msg_type = 1875
	self.scene_id = 0
	self.scene_key = 0
	self.pos_x = 0
	self.pos_y = 0
	self.item_index = 0
end

function CSSyncJump:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteInt(self.scene_key)
	MsgAdapter.WriteShort(self.pos_x)
	MsgAdapter.WriteShort(self.pos_y)
	MsgAdapter.WriteInt(self.item_index)
end

-- 守卫雕象信息
SCCampDefendInfo = SCCampDefendInfo or BaseClass(BaseProtocolStruct)
function SCCampDefendInfo:__init()
	self.msg_type = 1820
	self.rank_list = {}
end

function SCCampDefendInfo:Decode()
	self.self_hurt = MsgAdapter.ReadLL()
	self.statue_attr = {}
	for i = 1, 3 do
		local dx_vo = {}
		dx_vo.hp = MsgAdapter.ReadLL()
		dx_vo.maxhp = MsgAdapter.ReadLL()
		self.statue_attr[i] = dx_vo
	end
	self.rank_list = {}
	for i=1,5 do
		local rank_item = {}
		rank_item.roleid = MsgAdapter.ReadInt()
		rank_item.name = MsgAdapter.ReadStrN(32)
		rank_item.hurt = MsgAdapter.ReadLL()
		table.insert(self.rank_list, rank_item)
	end
end

--名人堂操作请求
CSFamousManOpera = CSFamousManOpera or BaseClass(BaseProtocolStruct)
function CSFamousManOpera:__init()
	self.msg_type = 1876
	self.opera_type = 0
end

function CSFamousManOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

--名人堂名人信息
SCSendFamousManInfo = SCSendFamousManInfo or BaseClass(BaseProtocolStruct)
function SCSendFamousManInfo:__init()
	self.msg_type = 1877
end
function SCSendFamousManInfo:Decode()
	self.famous_list = {}
	self.famous_list[1] = MsgAdapter.ReadInt() --名人堂-等级最先达到X级
	self.famous_list[2] = MsgAdapter.ReadInt() --名人堂-羽翼最先达到X阶
	self.famous_list[3] = MsgAdapter.ReadInt() --名人堂-坐骑最先达到X阶
	self.famous_list[4] = MsgAdapter.ReadInt() --名人堂-最先集齐一套X阶红色装备
	self.famous_list[5] = MsgAdapter.ReadInt() --名人堂-勇者之塔最先通关X层
	self.famous_list[6] = MsgAdapter.ReadInt() --名人堂-最先激活女神XXX
end

--神装信息
SCCSAEquipInfo = SCCSAEquipInfo or BaseClass(BaseProtocolStruct)
function SCCSAEquipInfo:__init()
	self.msg_type = 1880
end

function SCCSAEquipInfo:Decode()
	self.part_list = {}

	for i=0, TulongEquipData.EQUIP_MAX_PART - 1 do
		local vo = {}
		vo.index = i
		vo.level = MsgAdapter.ReadShort()	--每个部位对应的等级
		self.part_list[i] = vo
	end
	self.cs_part_list = {}
	for i=0, TulongEquipData.EQUIP_MAX_PART - 1 do
		local vo = {}
		vo.index = i
		vo.level = MsgAdapter.ReadShort()	--每个部位对应的等级
		self.cs_part_list[i] = vo
	end
	self.combine_server_equip_active_special = MsgAdapter.ReadShort() --屠龙-传世装备是否激活特效,0不是1是
	MsgAdapter.ReadShort()
end

CSCSAEquipOpera = CSCSAEquipOpera or BaseClass(BaseProtocolStruct)
function CSCSAEquipOpera:__init()
	self.msg_type = 1881
end

function CSCSAEquipOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.index)
end

--屠龙-传世装备是否激活特效变化
SCCSAActivePower = SCCSAActivePower or BaseClass(BaseProtocolStruct)
function SCCSAActivePower:__init()
	self.msg_type = 1882
end

function SCCSAActivePower:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.combine_server_equip_active_special = MsgAdapter.ReadShort()
end