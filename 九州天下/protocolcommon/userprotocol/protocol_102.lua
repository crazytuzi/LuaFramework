
-- 拉取阵营返回
SCCampInfo = SCCampInfo or BaseClass(BaseProtocolStruct)
function SCCampInfo:__init()
	self.msg_type = 10200
end

function SCCampInfo:Decode()
	self.camp_item_list = {}
	for i = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self.camp_item_list[i] = {}
		self.camp_item_list[i].camp_type = MsgAdapter.ReadInt()
		self.camp_item_list[i].camp_role_count = MsgAdapter.ReadInt()
		self.camp_item_list[i].total_capability = MsgAdapter.ReadLL()
		self.camp_item_list[i].camp_level = MsgAdapter.ReadInt()	-- 国家等级
		self.camp_item_list[i].camp_exp = MsgAdapter.ReadLL()		-- 国家经验
		self.camp_item_list[i].camp_name = MsgAdapter.ReadStrN(32)	-- 国家自定义名字
	end

	self.my_camp_type = MsgAdapter.ReadInt()						-- 本国的类型
	self.king_guild_id = MsgAdapter.ReadInt()						-- 国王军团ID
	self.king_guild_name = MsgAdapter.ReadStrN(32)					-- 国王军团名字

	self.officer_list = {}
	for i = 1, GameEnum.CAMP_POST_UNIQUE_TYPE_COUNT do				-- 本国官职列表 CAMP_POST_UNIQUE_TYPE_COUNT = 5
		self.officer_list[i] = {}
		self.officer_list[i].role_id = MsgAdapter.ReadInt()
		self.officer_list[i].name = MsgAdapter.ReadStrN(32)
		self.officer_list[i].guild_name = MsgAdapter.ReadStrN(32)
	end

	self.notice = MsgAdapter.ReadStrN(256)							-- 本国公告
	self.reborn_dan_num = MsgAdapter.ReadInt()						-- 本国复活丹数量
	self.alliance_camp = MsgAdapter.ReadInt()						-- 同盟国
end

-- 国家成员信息
SCCampMemInfo = SCCampMemInfo or BaseClass(BaseProtocolStruct)
function SCCampMemInfo:__init()
	self.msg_type = 10201
end

function SCCampMemInfo:Decode()
	local read_mem_func = function (vo)
		vo.post = MsgAdapter.ReadChar()								-- 官职
		vo.is_online = MsgAdapter.ReadChar()						-- 是否在线
		vo.sex = MsgAdapter.ReadShort()								-- 性别
		vo.name = MsgAdapter.ReadStrN(32)							-- 姓名
		vo.level = MsgAdapter.ReadShort()							-- 等级
		vo.vip_level = MsgAdapter.ReadShort()						-- vip等级
		vo.guild_name = MsgAdapter.ReadStrN(32)						-- 家族名
		vo.capability = MsgAdapter.ReadInt()						-- 战力
		vo.jungong = MsgAdapter.ReadInt()							-- 军功
		vo.kill_num = MsgAdapter.ReadShort()						-- 击杀数
		MsgAdapter.ReadShort()
		vo.camp_can_talk_timestamp = MsgAdapter.ReadUInt()			-- 可在国家频道聊天的时间
		vo.remove_neijian_timestamp = MsgAdapter.ReadUInt()			-- 是否是内奸
	end

	self.oneself_mem_info = {}
	read_mem_func(self.oneself_mem_info)

	self.page = MsgAdapter.ReadShort()
	self.total_page = MsgAdapter.ReadShort()
	self.order_type = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()

	-- static const int ITEM_COUNT_PER_PAGE = 6;	// 一页有多少条记录
	self.mem_info_item_list = {}
	for i = 1, self.count do
		self.mem_info_item_list[i] = {}
		read_mem_func(self.mem_info_item_list[i])
	end
end

-- 通用返回信息
SCCampCommonInfo = SCCampCommonInfo or BaseClass(BaseProtocolStruct)
function SCCampCommonInfo:__init()
	self.msg_type = 10202
end

function SCCampCommonInfo:Decode()
	self.result_type = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
	self.param3 = MsgAdapter.ReadUInt()
	self.param4 = MsgAdapter.ReadInt()
end

-- 分配复活次数
SCCampRebornInfo = SCCampRebornInfo or BaseClass(BaseProtocolStruct)
function SCCampRebornInfo:__init()
	self.msg_type = 10203
end

function SCCampRebornInfo:Decode()
	self.king_reborn_times_idx = MsgAdapter.ReadChar()
	self.officer_reborn_times_idx = MsgAdapter.ReadChar()
	self.jingying_reborn_times_idx = MsgAdapter.ReadChar()
	self.guomin_reborn_times_idx = MsgAdapter.ReadChar()

	self.pre_king_reborn_times_idx = MsgAdapter.ReadChar()
	self.pre_officer_reborn_times_idx = MsgAdapter.ReadChar()
	self.pre_jingying_reborn_times_idx = MsgAdapter.ReadChar()
	self.pre_guomin_reborn_times_idx = MsgAdapter.ReadChar()
end

-- 召集信息
SCCampCall = SCCampCall or BaseClass(BaseProtocolStruct)
function SCCampCall:__init()
	self.msg_type = 10204
end

function SCCampCall:Decode()
	self.call_type = MsgAdapter.ReadInt()						-- 召集类型
	self.uid = MsgAdapter.ReadInt()								-- 召集者信息
	self.name = MsgAdapter.ReadStrN(32)							-- 姓名
	self.post = MsgAdapter.ReadChar()							-- 职位		
	MsgAdapter.ReadChar()										-- 保留
	self.nation = MsgAdapter.ReadShort()						-- 国家名字
	self.scene_id = MsgAdapter.ReadInt()						-- 场景ID
	self.x = MsgAdapter.ReadInt()								-- x
	self.y = MsgAdapter.ReadInt()								-- y
end

-- 国家拍卖物品列表
SCCampSaleItemList = SCCampSaleItemList or BaseClass(BaseProtocolStruct)
function SCCampSaleItemList:__init()
	self.msg_type = 10205
end

function SCCampSaleItemList:Decode()
	self.reason_type = MsgAdapter.ReadInt()
	self.order_type = MsgAdapter.ReadInt()						-- 排序规则
	self.page = MsgAdapter.ReadShort()							-- 第几页（从0开始）
	self.total_page = MsgAdapter.ReadShort()					-- 总页数
	self.camo_gold = MsgAdapter.ReadInt()						-- 国家元宝
	self.count = MsgAdapter.ReadInt()							-- 物品列表中物品个数

	-- static const int MAX_ITEM_COUNT_PER_PAGE = 6;			-- 一页有多少个物品
	self.item_info_list = {}									-- 当前页物品列表
	for i = 1, self.count do
		local vo = {}
		vo.sale_id = MsgAdapter.ReadInt()						-- 售卖物品唯一ID
		vo.cur_uid = MsgAdapter.ReadInt()						-- 当前竞价的玩家
		vo.item_id = MsgAdapter.ReadUShort()					-- 物品ID
		vo.cur_gold = MsgAdapter.ReadShort()					-- 当前价格
		vo.xiajia_timestamp = MsgAdapter.ReadUInt()				-- 下架时间
		self.item_info_list[i] = vo
	end
end

-- 上架物品的售卖结果项
SCCampSaleResultList = SCCampSaleResultList or BaseClass(BaseProtocolStruct)
function SCCampSaleResultList:__init()
	self.msg_type = 10206
end

function SCCampSaleResultList:Decode()
	self.count = MsgAdapter.ReadInt()
	self.sale_result_item_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.result_type = MsgAdapter.ReadShort()					-- 售卖结果
		vo.sold_gold = MsgAdapter.ReadShort()					-- 购买价钱
		vo.item_id = MsgAdapter.ReadUShort()					-- 售卖物品
		vo.recycle_gold = MsgAdapter.ReadShort()				-- 回收价钱
		vo.uid = MsgAdapter.ReadInt()							-- 购买者
		vo.name = MsgAdapter.ReadStrN(32)						-- 购买者名字
		vo.sold_timestamp = MsgAdapter.ReadUInt()				-- 售卖时间
		self.sale_result_item_list[i] = vo
	end
end

-- 大臣活动状态信息 
SCCampDachenActStatus = SCCampDachenActStatus or BaseClass(BaseProtocolStruct)
function SCCampDachenActStatus:__init()
	self.msg_type = 10207
	self.item_list = {}
end

function SCCampDachenActStatus:Decode()
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX do
		local vo = {}
		vo.act_status = MsgAdapter.ReadInt()        								-- 活动状态，0关 1开
		vo.act_status_switch_timestamp = MsgAdapter.ReadUInt() 						-- 状态切换时间
		vo.standby_cd = MsgAdapter.ReadUInt()										-- 准备时间剩余
		vo.last_kill_my_dachen_camp = MsgAdapter.ReadInt()  						-- 上一次击杀本国大臣的国家
		vo.dachen_hp_percent = MsgAdapter.ReadInt()  								-- 大臣当前血量百分比
		vo.hurt_percent = {}
		for j = 1, CAMP_TYPE.CAMP_TYPE_MAX do
			vo.hurt_percent[j] = MsgAdapter.ReadInt() 								-- 其他国家对大臣的伤害百分比
		end
		table.remove(vo.hurt_percent, 1)
		self.item_list[i] = vo
	end
	table.remove(self.item_list, 1)
end

-- 击杀大臣奖励
SCKillCampDachen = SCKillCampDachen or BaseClass(BaseProtocolStruct)
function SCKillCampDachen:__init()
	self.msg_type = 10208
	self.reward_items = {}
end

function SCKillCampDachen:Decode()
	self.camp_type = MsgAdapter.ReadInt()    			-- 击杀大臣所在阵营
	self.reward_times = MsgAdapter.ReadDouble()    		-- 奖励倍数
	for i=1, GAME_ENUM_KO_REWARD_ITEM_COUNT.REWARD_ITEM_COUNT do
		local temp = {}
		temp.item_id = MsgAdapter.ReadUShort() 
		temp.num = MsgAdapter.ReadShort() 
		temp.is_bind = MsgAdapter.ReadChar() 
		MsgAdapter.ReadChar() 
		MsgAdapter.ReadShort()
		if temp.item_id > 0 then
			self.reward_items[i] = temp
		end
	end
end

-- 角色的国家信息 
SCCampRoleInfo = SCCampRoleInfo or BaseClass(BaseProtocolStruct)
function SCCampRoleInfo:__init()
	self.msg_type = 10209
end

function SCCampRoleInfo:Decode()
	self.camp_type = MsgAdapter.ReadInt()						-- 国家类型
	self.camp_post = MsgAdapter.ReadInt()						-- 国家官职

	self.neizheng_yunbiao_times = MsgAdapter.ReadShort()		-- 内政-运镖次数
	self.neizheng_banzhuang_times = MsgAdapter.ReadShort()		-- 内政-搬砖次数
	self.neizheng_officer_welfare_times = MsgAdapter.ReadShort()-- 内政-官员福利次数
	self.neizheng_guomin_welfare_times = MsgAdapter.ReadShort()	-- 内政-国民福利次数
	self.neizheng_set_neijian_times = MsgAdapter.ReadShort()	-- 内政-设置内奸次数
	self.neizheng_unset_neijian_times = MsgAdapter.ReadShort()	-- 内政-取消内奸次数
	self.neizheng_callin_times = MsgAdapter.ReadChar()			-- 内政-已使用召集次数
	MsgAdapter.ReadChar()										-- 保留位
	MsgAdapter.ReadShort()										-- 保留位
end

-- 查询玩家列表 
SCCampSearchMemList = SCCampSearchMemList or BaseClass(BaseProtocolStruct)
function SCCampSearchMemList:__init()
	self.msg_type = 10210
end

function SCCampSearchMemList:Decode()
	self.count = MsgAdapter.ReadInt()
	self.item_info_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.role_id = MsgAdapter.ReadInt()						-- 玩家ID
		vo.is_forbidden_talk = MsgAdapter.ReadChar()			-- 是否禁言
		vo.is_neijian = MsgAdapter.ReadChar()					-- 是否是内奸
		vo.level = MsgAdapter.ReadShort()						-- 等级
		vo.name = MsgAdapter.ReadStrN(32)						-- 玩家名字
		vo.guild_name = MsgAdapter.ReadStrN(32)					-- 家族名字
		vo.capability = MsgAdapter.ReadInt()					-- 战斗力
		vo.post = MsgAdapter.ReadShort()						-- 官职
		vo.sex = MsgAdapter.ReadChar()							-- 性别
		vo.vip_level = MsgAdapter.ReadChar()					-- vip等級

		self.item_info_list[i] = vo
	end
end

-- 气运塔状态 
SCCampQiyunTowerStatus = SCCampQiyunTowerStatus or BaseClass(BaseProtocolStruct)
function SCCampQiyunTowerStatus:__init()
	self.msg_type = 10211
end

function SCCampQiyunTowerStatus:Decode()
	self.is_xiuzhan = MsgAdapter.ReadInt()						-- 是否休战中
	self.item_list = {}
	for i = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		local vo = {}
		vo.qiyun_val = MsgAdapter.ReadInt()						-- 气运值
		vo.cur_add_percent = MsgAdapter.ReadShort()				-- 当前加成速率
		vo.is_alive = MsgAdapter.ReadShort()					-- 是否还存在

		vo.speed_reduce_end_timestamp = {}						-- 生产速率下降的结束时间
		for j = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			vo.speed_reduce_end_timestamp[j] = MsgAdapter.ReadUInt()
		end

		vo.speed_increase_end_timestmap = {}					-- 生产速率加成的结束时间
		for j = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			vo.speed_increase_end_timestmap[j] = MsgAdapter.ReadUInt()
		end

		vo.qiyun_tower_reborn_timestamp = MsgAdapter.ReadUInt()	-- 气运塔复活时间（如果是0，代表未摧毁）
		vo.qiyun_tower_hp_percent = MsgAdapter.ReadInt()		-- 气运塔当前血量百分比
		vo.hurt_percent = {}									-- 其他国家对气运塔的伤害百分比
		for j = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			vo.hurt_percent[j] = MsgAdapter.ReadInt()
		end
		self.item_list[i] = vo
	end

end

-- 气运战报 
SCCampQiyunBattleReport = SCCampQiyunBattleReport or BaseClass(BaseProtocolStruct)
function SCCampQiyunBattleReport:__init()
	self.msg_type = 10212
end

function SCCampQiyunBattleReport:Decode()
	self.attack_report_list = {}								-- 攻方
	for i = 1, GameEnum.MAX_REPORT_COUNT do
		local vo = {}
		vo.report_type = MsgAdapter.ReadInt()					-- 战报类型
		vo.report_timestamp = MsgAdapter.ReadUInt()				-- 生成时间
		vo.my_camp = MsgAdapter.ReadChar()						-- 我方阵营
		vo.enemy_camp = MsgAdapter.ReadChar()					-- 地方阵营
		MsgAdapter.ReadShort()
		vo.rob_qiyun_val = MsgAdapter.ReadInt()					-- 掠夺的气运值
		vo.percent = MsgAdapter.ReadShort()						-- 下降或上升的速度
		vo.is_refresh_percent = MsgAdapter.ReadShort()			-- 是否刷新了下降或上升的速度
		if vo.report_type ~= 0 then
			self.attack_report_list[i] = vo
		end
	end
	self.defend_report_list = {}								-- 防守方
	for i = 1, GameEnum.MAX_REPORT_COUNT do
		local vo = {}
		vo.report_type = MsgAdapter.ReadInt()					-- 战报类型
		vo.report_timestamp = MsgAdapter.ReadUInt()				-- 生成时间
		vo.my_camp = MsgAdapter.ReadChar()						-- 我方阵营
		vo.enemy_camp = MsgAdapter.ReadChar()					-- 地方阵营
		MsgAdapter.ReadShort()
		vo.rob_qiyun_val = MsgAdapter.ReadInt()					-- 掠夺的气运值
		vo.percent = MsgAdapter.ReadShort()						-- 下降或上升的速度
		vo.is_refresh_percent = MsgAdapter.ReadShort()			-- 是否刷新了下降或上升的速度
		if vo.report_type ~= 0 then
			self.defend_report_list[i] = vo
		end
	end
end

-- 刺探任务状态
SCCampCitanStatus = SCCampCitanStatus or BaseClass(BaseProtocolStruct)
function SCCampCitanStatus:__init()
	self.msg_type = 10213
end

function SCCampCitanStatus:Decode()
	self.task_phase = MsgAdapter.ReadChar()										-- 任务阶段
	self.task_aim = MsgAdapter.ReadChar()										-- 当前目标：0.无目标；1.去找敌国NPC刷情报；2.去找本国NPC提交情报
	self.get_qingbao_color = MsgAdapter.ReadChar()								-- 拿到的情报颜色
	self.cur_qingbao_color = MsgAdapter.ReadChar()								-- 当前刷到的情报颜色
	self.task_aim_camp = MsgAdapter.ReadChar()									-- 目标阵营
	self.yesterday_unaccept_times = MsgAdapter.ReadChar()						-- 昨日未参加任务的次数
	self.cur_buy_times = MsgAdapter.ReadShort()									-- 当前购买的次数
	self.next_refresh_camp_info_timestmap =  MsgAdapter.ReadUInt()				-- 下一次可以刷新国家情报的时间
	self.has_share_color = MsgAdapter.ReadInt()									-- 是否分享过
	self.is_relive_in_myslef_camp = MsgAdapter.ReadInt()                        -- 是否免费复活(回到本国)
end

-- 运镖任务状态
SCCampYunbiaoStatus = SCCampYunbiaoStatus or BaseClass(BaseProtocolStruct)
function SCCampYunbiaoStatus:__init()
	self.msg_type = 10214
end

function SCCampYunbiaoStatus:Decode()
	self.neizheng_yunbiao_end_time = MsgAdapter.ReadUInt()
end

-- 营救任务状态 10215
SCCampYingjiuStatus = SCCampYingjiuStatus or BaseClass(BaseProtocolStruct)
function SCCampYingjiuStatus:__init()
	self.msg_type = 10215

	self.task_phase = 0								-- 任务阶段
	self.task_seq = 0								-- 当前任务序号
	self.task_aim_camp = 0							-- 目标阵营
	self.yesterday_unaccept_times = 0				-- 昨日未参加任务的次数

	self.param1 = 0									-- 特殊参数1 当前任务进度
	self.param2 = 0									-- 特殊参数2 
	self.is_ack = 0 								-- 是否主动请求 1:0 是：否
end

function SCCampYingjiuStatus:Decode()
	self.task_phase = MsgAdapter.ReadChar()
	self.task_seq = MsgAdapter.ReadChar()
	self.task_aim_camp = MsgAdapter.ReadChar()
	self.yesterday_unaccept_times = MsgAdapter.ReadChar()

	self.param1 = MsgAdapter.ReadShort()
	self.param2 = MsgAdapter.ReadShort()
	self.is_ack = MsgAdapter.ReadInt()
end

-- 搬砖任务状态
SCCampBanzhuanStatus = SCCampBanzhuanStatus or BaseClass(BaseProtocolStruct)
function SCCampBanzhuanStatus:__init()
	self.msg_type = 10216
end

function SCCampBanzhuanStatus:Decode()
	self.task_phase = MsgAdapter.ReadChar()						-- 任务阶段
	self.task_aim = MsgAdapter.ReadChar()						-- 当前目标
	self.task_aim_camp = MsgAdapter.ReadChar()					-- 目标阵营
	self.has_share_color = MsgAdapter.ReadChar()				-- 是否分享过
	self.get_color = MsgAdapter.ReadChar()						-- 拿到的砖头颜色
	self.cur_color = MsgAdapter.ReadChar()						-- 当前刷到的颜色
	self.yesterday_unaccept_times = MsgAdapter.ReadShort()		-- 昨日未参加任务的次数
	self.cur_buy_times = MsgAdapter.ReadInt()					-- 当前购买的次数
	self.next_refresh_camp_banzhuan_timestmap = MsgAdapter.ReadUInt()		-- 下一次可以国家搬砖的采集的时间
	self.is_relive_in_myslef_camp = MsgAdapter.ReadInt()        -- 是否免费复活(回到本国)
end

-- 正在运镖的玩家
SCCampYunbiaoUsers = SCCampYunbiaoUsers or BaseClass(BaseProtocolStruct)
function SCCampYunbiaoUsers:__init()
	self.msg_type = 10217
end

function SCCampYunbiaoUsers:Decode()
	self.count = MsgAdapter.ReadInt()
	self.user_info_list = {}
	for i = 1, self.count do
		local list = {}
		list.role_id = MsgAdapter.ReadInt()
		list.role_name = MsgAdapter.ReadStrN(32)
		list.level = MsgAdapter.ReadInt()
		list.prof = MsgAdapter.ReadChar()
		list.sex = MsgAdapter.ReadChar()
		list.camp = MsgAdapter.ReadChar()
		list.task_color = MsgAdapter.ReadChar()
		list.capability = MsgAdapter.ReadInt()
		list.is_online = MsgAdapter.ReadInt()
		self.user_info_list[i] = list
	end
end

-- 国家任务奖励
SCCampTaskReward = SCCampTaskReward or BaseClass(BaseProtocolStruct)
function SCCampTaskReward:__init()
	self.msg_type = 10218

	self.task_type = 0					-- 任务类型 CAMP_TASK_TYPE
	self.give_times = 0					-- 返还倍数
	self.color = 1						-- 颜色，有的任务可能无用
	self.reward_list = {}				-- 返还的物品
end

function SCCampTaskReward:Decode()
	self.task_type = MsgAdapter.ReadInt()
	self.give_times = MsgAdapter.ReadDouble()
	self.color = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.reward_list = {}
	for i = 1, count do
		local data = {}
		data.item_id = MsgAdapter.ReadInt()
		data.num = MsgAdapter.ReadShort()
		data.is_bind = MsgAdapter.ReadShort()
		self.reward_list[i] = data
	end
end

-- 国旗活动状态信息
SCCampFlagActStatus = SCCampFlagActStatus or BaseClass(BaseProtocolStruct)
function SCCampFlagActStatus:__init()
	self.msg_type = 10219
	self.item_list = {}				
end

function SCCampFlagActStatus:Decode()
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX do
		local vo = {}
		vo.act_status = MsgAdapter.ReadInt()        								-- 活动状态，0关 1开
		vo.act_status_switch_timestamp = MsgAdapter.ReadUInt() 						-- 状态切换时间
		vo.standby_cd = MsgAdapter.ReadUInt()										-- 准备时间剩余
		vo.last_kill_my_flag_camp = MsgAdapter.ReadInt()  							-- 上一次击杀本国国旗的国家
		vo.flag_hp_percent = MsgAdapter.ReadInt()  									-- 国旗当前血量百分比
		vo.hurt_percent = {}
		for j = 1, CAMP_TYPE.CAMP_TYPE_MAX do
			vo.hurt_percent[j] = MsgAdapter.ReadInt() 								-- 其他国家对大臣的伤害百分比
		end
		table.remove(vo.hurt_percent, 1)
		self.item_list[i] = vo
	end
	table.remove(self.item_list, 1)
end

-- 击杀国旗奖励
SCKillCampFlag = SCKillCampFlag or BaseClass(BaseProtocolStruct)
function SCKillCampFlag:__init()
	self.msg_type = 10220
	self.reward_items = {}
end

function SCKillCampFlag:Decode()
	self.camp_type = MsgAdapter.ReadInt()    			-- 击杀大臣所在阵营
	self.reward_times = MsgAdapter.ReadDouble()    		-- 奖励倍数
	for i=1, GAME_ENUM_KO_REWARD_ITEM_COUNT.REWARD_ITEM_COUNT do
		local temp = {}
		temp.item_id = MsgAdapter.ReadUShort() 
		temp.num = MsgAdapter.ReadShort() 
		temp.is_bind = MsgAdapter.ReadChar() 
		MsgAdapter.ReadChar() 
		MsgAdapter.ReadShort() 
		if temp.item_id > 0 then
			self.reward_items[i] = temp
		end
	end
end

-- 国家任务，被分享
SCCampTaskBeShared = SCCampTaskBeShared or BaseClass(BaseProtocolStruct)
function SCCampTaskBeShared:__init()
	self.msg_type = 10221
end

function SCCampTaskBeShared:Decode()
	self.task_type = MsgAdapter.ReadInt()    			-- 任务类型 CAMP_TASK_TYPE
	self.shared_role_id = MsgAdapter.ReadInt()    		-- 分享者
	self.shared_role_name = MsgAdapter.ReadStrN(32)
end

SCCampTotemPillarInfo = SCCampTotemPillarInfo or BaseClass(BaseProtocolStruct)
function SCCampTotemPillarInfo:__init()
	self.msg_type = 10222
end

function SCCampTotemPillarInfo:Decode()
	self.count = MsgAdapter.ReadInt() 
	self.pillar_info = {}
	for i=1, self.count do
		local vo = {}
		vo.pillar_type = MsgAdapter.ReadInt()
		vo.obj_id = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
		vo.scene_id = MsgAdapter.ReadInt()
		vo.scene_key = MsgAdapter.ReadInt()
		vo.creater_uuid = MsgAdapter.ReadLL()
		vo.creater_name = MsgAdapter.ReadStrN(32)
		vo.param = MsgAdapter.ReadInt()
		self.pillar_info[i] = vo
	end			
end

-- 当前场景的本国图腾柱信息
SCSceneCampTotemPillarInfo = SCSceneCampTotemPillarInfo or BaseClass(BaseProtocolStruct)
function SCSceneCampTotemPillarInfo:__init()
	self.msg_type = 10223
end

function SCSceneCampTotemPillarInfo:Decode()
	self.has_relive_pillar = MsgAdapter.ReadInt()		-- 当前场景是否有复活柱
end


-- 获取阵营信息
CSGetCampInfo = CSGetCampInfo or BaseClass(BaseProtocolStruct)
function CSGetCampInfo:__init()
	self.msg_type = 10250
end

function CSGetCampInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求国民信息
CSQueryCampMemInfo = CSQueryCampMemInfo or BaseClass(BaseProtocolStruct)
function CSQueryCampMemInfo:__init()
	self.msg_type = 10251
end

function CSQueryCampMemInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.page)								-- 从0页开始
	MsgAdapter.WriteInt(self.order_type)
end

-- 发布公告
CSCampPublishNotice = CSCampPublishNotice or BaseClass(BaseProtocolStruct)
function CSCampPublishNotice:__init()
	self.msg_type = 10252
end

function CSCampPublishNotice:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteStrN(self.notice, 256)
end

-- 通用请求
CSCampCommonOpera = CSCampCommonOpera or BaseClass(BaseProtocolStruct)
function CSCampCommonOpera:__init()
	self.msg_type = 10253
end

function CSCampCommonOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.order_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteStrN(self.param4_name, 32)
	MsgAdapter.WriteInt(self.param5)
end

-- 分配复活次数
CSCampSetRebornTimes = CSCampSetRebornTimes or BaseClass(BaseProtocolStruct)
function CSCampSetRebornTimes:__init()
	self.msg_type = 10254
end

function CSCampSetRebornTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteChar(self.king_reborn_times)				-- 发配置的下标
	MsgAdapter.WriteChar(self.officer_reborn_times)				-- 发配置的下标
	MsgAdapter.WriteChar(self.jingying_reborn_times)			-- 发配置的下标
	MsgAdapter.WriteChar(self.guomin_reborn_times)				-- 发配置的下标
end

-- 国家战事通用请求
CSCampWarCommonOpera = CSCampWarCommonOpera or BaseClass(BaseProtocolStruct)
function CSCampWarCommonOpera:__init()
	self.msg_type = 10255
end

function CSCampWarCommonOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

-- 国家任务通用请求
CSCampTaskCommonOpera = CSCampTaskCommonOpera or BaseClass(BaseProtocolStruct)
function CSCampTaskCommonOpera:__init()
	self.msg_type = 10256
end

function CSCampTaskCommonOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

--国家建设提醒国君
SCCampOtherInfo = SCCampOtherInfo or BaseClass(BaseProtocolStruct)

function SCCampOtherInfo:__init()
	self.msg_type = 10257
end

function SCCampOtherInfo:Decode()
	self.exp_is_full_flag = MsgAdapter.ReadInt()
end

