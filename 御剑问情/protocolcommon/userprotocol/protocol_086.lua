-- 名将信息
SCGreateSoldierItemInfo = SCGreateSoldierItemInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierItemInfo:__init()
	self.msg_type = 8600

	self.seq = 0
	self.item_info = {}
end

function SCGreateSoldierItemInfo:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.item_info = {}
	self.item_info.seq = self.seq
	self.item_info.grade = MsgAdapter.ReadShort()
	self.item_info.level = MsgAdapter.ReadShort()
	self.item_info.guangwu = MsgAdapter.ReadShort()
	self.item_info.shenwu = MsgAdapter.ReadShort()

	self.item_info.cur_level_exp = MsgAdapter.ReadInt()
	self.item_info.cur_guangwu_exp = MsgAdapter.ReadInt()
	self.item_info.cur_shenwu_exp = MsgAdapter.ReadInt()

	self.unactive_timestamp = MsgAdapter.ReadUInt()				-- 形象ID结束时间（0代表永久）
end

--  名将其他信息
SCGreateSoldierOtherInfo = SCGreateSoldierOtherInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierOtherInfo:__init()
	self.msg_type = 8601
	self.cur_used_seq = 0
	self.is_on_bianshen_trail = 0
	self.has_dailyfirst_draw_ten = 0
	self.bianshen_end_timestamp = 0
	self.bianshen_cd = 0
	self.bianshen_cd_reduce_s = 0
	self.main_slot_seq = -1
end

function SCGreateSoldierOtherInfo:Decode()
	self.cur_used_seq = MsgAdapter.ReadChar()
	self.is_on_bianshen_trail = MsgAdapter.ReadChar()
	self.has_dailyfirst_draw_ten = MsgAdapter.ReadChar()
	self.main_slot_seq = MsgAdapter.ReadChar()
	self.bianshen_end_timestamp = MsgAdapter.ReadUInt()
	self.bianshen_cd = MsgAdapter.ReadInt()											-- 变身剩余cd (ms)
	MsgAdapter.ReadLL()
	self.bianshen_cd_reduce_s = MsgAdapter.ReadInt()								-- 变身CD缩短时间

	self.cur_used_special_img_id = MsgAdapter.ReadShort()							-- 当前使用特殊形象id
	self.small_goal_can_fetch_flag = MsgAdapter.ReadChar()							-- 小目标是否可以免费领取标记 可免费/不可免费 0/1
	self.small_goal_fetch_flag =  MsgAdapter.ReadChar()								-- 小目标领取标记 领取/未领取 0/1
	self.system_open_timestamp = MsgAdapter.ReadUInt()								-- 系统开放时间
	self.special_img_active_flag = MsgAdapter.ReadUInt() 							-- 名将特殊形象激活标记
	self.special_img_can_fetch_flag = MsgAdapter.ReadUInt() 						-- 名将特殊形象可领取标记
	self.special_img_fetch_flag = MsgAdapter.ReadUInt() 							-- 名将特殊形象领取标记
	
	self.special_img_level_list = {}												-- 特殊形象等级列表
	for i = 0, GameEnum.GREATE_SOLDIER_SPEICAL_IMG_COUNT_MAX - 1 do
		self.special_img_level_list[i] = MsgAdapter.ReadShort()
	end
end

-- 名将将位信息
SCGreateSoldierSlotInfo = SCGreateSoldierSlotInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierSlotInfo:__init()
	self.msg_type = 8602

	self.slot_param = {}				-- 0是主将位
end

function SCGreateSoldierSlotInfo:Decode()
	self.slot_param = {}
	for i = 1, COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT do
		local data = {}
		data.item_seq = MsgAdapter.ReadChar()						-- 名将seq
		MsgAdapter.ReadChar()
		data.level = MsgAdapter.ReadShort()							-- 等级
		data.level_val = MsgAdapter.ReadUInt()						-- 升级祝福值
		self.slot_param[i] = data
	end
end

-- 名将请求
CSGreateSoldierOpera = CSGreateSoldierOpera or BaseClass(BaseProtocolStruct)
function CSGreateSoldierOpera:__init()
	self.msg_type = 8603
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSGreateSoldierOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end




-- 请求所有天赋
CSTalentOperaReqAll = CSTalentOperaReqAll or BaseClass(BaseProtocolStruct)
function CSTalentOperaReqAll:__init()
	self.msg_type = 8610
	self.operate_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTalentOperaReqAll:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end



-- 所有天赋
SCTalentAllInfo = SCTalentAllInfo or BaseClass(BaseProtocolStruct)
function SCTalentAllInfo:__init()
	self.msg_type = 8611
end

function SCTalentAllInfo:Decode()
	self.talent_info_list = {}
	self.count = MsgAdapter.ReadInt()
	for talent_type = 0, GameEnum.TALENT_TYPE_MAX - 1 do
		self.talent_info_list[talent_type] = {}
		for talent_index = 0, GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 do
			local info = {}
			info.is_open = MsgAdapter.ReadChar()		-- 格子是否开启
			info.skill_star = MsgAdapter.ReadChar()		-- 技能星级
			info.skill_id = MsgAdapter.ReadShort()		-- 技能星级
			self.talent_info_list[talent_type][talent_index] = info
		end
	end
end

-- 单个天赋格更新
SCTalentUpdateSingleGrid = SCTalentUpdateSingleGrid or BaseClass(BaseProtocolStruct)
function SCTalentUpdateSingleGrid:__init()
	self.msg_type = 8612
end

function SCTalentUpdateSingleGrid:Decode()
	self.talent_type = MsgAdapter.ReadShort()
	self.talent_index = MsgAdapter.ReadShort()

	self.grid_info = {}
	self.grid_info.is_open = MsgAdapter.ReadChar()			-- 格子是否开启
	self.grid_info.skill_star = MsgAdapter.ReadChar()		-- 技能星级
	self.grid_info.skill_id = MsgAdapter.ReadShort()		-- 技能星级
end

-- 抽奖页所有数据
SCTalentChoujiangPage = SCTalentChoujiangPage or BaseClass(BaseProtocolStruct)
function SCTalentChoujiangPage:__init()
	self.msg_type = 8613
end

function SCTalentChoujiangPage:Decode()
	self.free_chou_count = MsgAdapter.ReadInt()
	self.cur_count = MsgAdapter.ReadShort()
	self.choujiang_grid_skill = {}
	for i = 1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		self.choujiang_grid_skill[i] = MsgAdapter.ReadUShort()
	end
end

------------------ 宝宝Boss相关协议 ------------------
-- 请求信息协议
CSBabyBossOperate = CSBabyBossOperate or BaseClass(BaseProtocolStruct)
function CSBabyBossOperate:__init()
	self.msg_type = 8614
	self.operate_type = 0
	self.param_0 = 0
end

function CSBabyBossOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_0)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteShort(self.reserve_sh)
end

-- 宝宝Boss人物信息
SCBabyBossRoleInfo = SCBabyBossRoleInfo or BaseClass(BaseProtocolStruct)
function SCBabyBossRoleInfo:__init()
	self.msg_type = 8615
end

function SCBabyBossRoleInfo:Decode()
	self.enter_times = MsgAdapter.ReadShort()    -- 进入次数
	self.angry_value = MsgAdapter.ReadShort()    -- 愤怒值
	self.kick_time = MsgAdapter.ReadUInt()		 -- 踢出时间
end

-- 宝宝Boss信息
SCAllBabyBossInfo = SCAllBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCAllBabyBossInfo:__init()
	self.msg_type = 8616
end

function SCAllBabyBossInfo:Decode()
	self.boss_count = MsgAdapter.ReadInt()
	self.boss_info_list = {}
	for i = 1, self.boss_count do
		local boss_info = {}
		boss_info.scene_id = MsgAdapter.ReadShort()
		boss_info.boss_id = MsgAdapter.ReadUShort()
		boss_info.next_refresh_time = MsgAdapter.ReadUInt()
		local killer_info = {}
		for j = 1, GameEnum.BABY_BOSS_KILLER_MAX_COUNT do
			local temp_killer_info = {}
			temp_killer_info.killer_uid = MsgAdapter.ReadInt()
			temp_killer_info.killier_time = MsgAdapter.ReadUInt()
			temp_killer_info.killer_name = MsgAdapter.ReadStrN(32)
			table.insert( killer_info, temp_killer_info )
		end
		boss_info.killer_info = killer_info
		self.boss_info_list[i] = boss_info
	end
end

-- 宝宝Boss信息(单个)
SCSingleBabyBossInfo = SCSingleBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCSingleBabyBossInfo:__init()
	self.msg_type = 8617
end

function SCSingleBabyBossInfo:Decode()
	self.boss_info = {}
	self.boss_info.scene_id = MsgAdapter.ReadShort()
	self.boss_info.boss_id = MsgAdapter.ReadUShort()
	self.boss_info.next_refresh_time = MsgAdapter.ReadUInt()
	local killer_info = {}
	for i = 1, GameEnum.BABY_BOSS_KILLER_MAX_COUNT do
		local temp_killer_info = {}
		temp_killer_info.killer_uid = MsgAdapter.ReadInt()
		temp_killer_info.killier_time = MsgAdapter.ReadUInt()
		temp_killer_info.killer_name = MsgAdapter.ReadStrN(32)
		table.insert( killer_info, temp_killer_info )
	end
	self.boss_info.killer_info = killer_info
end

SCTalentAttentionSkillID = SCTalentAttentionSkillID or BaseClass(BaseProtocolStruct)
function SCTalentAttentionSkillID:__init()
	self.msg_type = 8618
	self.count = 0
	self.save_skill_id = {}
end

function SCTalentAttentionSkillID:Decode()
	self.save_skill_id = {}
	self.count = MsgAdapter.ReadInt()
    for i=1,self.count do
    	local info = MsgAdapter.ReadShort()
    	table.insert(self.save_skill_id, info)
    end
end

-- end


------------通用日志协议------------------------

-- 请求日志协议
CSGetLuckyLog = CSGetLuckyLog or BaseClass(BaseProtocolStruct)
function CSGetLuckyLog:__init()
	self.msg_type = 8620
	self.activity_type = 0
end

function CSGetLuckyLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.activity_type)
end


-- 日志信息
SCLuckyLogRet = SCLuckyLogRet or BaseClass(BaseProtocolStruct)
function SCLuckyLogRet:__init()
	self.msg_type = 8621
	self.activity_type = 0
	self.count = 0
	self.log_item = {}
end

function SCLuckyLogRet:Decode()
	self.log_item = {}
	self.activity_type = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
    for i = 1, self.count do
    	local data = {}
    	data.uid = MsgAdapter.ReadInt()
    	data.role_name = MsgAdapter.ReadStrN(32)
    	data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		data.timestamp = MsgAdapter.ReadUInt()
		self.log_item[i] = data
    end
end

-------------------------无双装备-----------------------------------------
--周末装备装备信息
SCTianshenhutiALlInfo = SCTianshenhutiALlInfo or BaseClass(BaseProtocolStruct)
function SCTianshenhutiALlInfo:__init()
	self.msg_type = 8622
	self.equip_list = {}				-- 每个部位对应装备ID
	self.free_flag = 0					-- 免费标记
	-- self.backpack_num = 0				-- 背包里装备数量（有效数组长度）
	self.backpack_list = {}				-- 背包里拥有的所有装备列表
	self.roll_score = 0
end

function SCTianshenhutiALlInfo:Decode()
	self.equip_list = {}
	for i=0, GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.item_id = MsgAdapter.ReadUShort()
		if vo.item_id > 0 then
			self.equip_list[i] = vo
		end
	end
	self.free_flag = MsgAdapter.ReadShort()
	local backpack_num = MsgAdapter.ReadUShort()
	self.roll_score = MsgAdapter.ReadInt()
	self.next_free_roll_time = MsgAdapter.ReadUInt()
	self.accumulate_roll_times  = MsgAdapter.ReadShort()                  		--累计抽奖次数
    MsgAdapter.ReadShort()                          							-- 预留位
	self.backpack_list = {}
	for i = 1, backpack_num do
		self.backpack_list[i] = {}
		self.backpack_list[i].index = i - 1
		self.backpack_list[i].item_id = MsgAdapter.ReadUShort()
	end
end

--周末装备抽奖结果
SCTianshenhutiRollResult = SCTianshenhutiRollResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiRollResult:__init()
	self.msg_type = 8623
	self.reward_list = {}
end

function SCTianshenhutiRollResult:Decode()
	self.reward_list = {}
	local index = 1
	local reward_count = MsgAdapter.ReadShort()
	for i=1, reward_count do
		local item_id =  MsgAdapter.ReadUShort()
		if item_id > 0 then
			self.reward_list[index] = {}
			self.reward_list[index].item_id = item_id
			index = index + 1
		end
	end
end

--周末装备相关请求结果
SCTianshenhutiReqResult = SCTianshenhutiReqResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiReqResult:__init()
	self.msg_type = 8624
	self.req_type = 0
	self.param_1 = 0
end

function SCTianshenhutiReqResult:Decode()
	self.req_type = MsgAdapter.ReadUShort()
	self.param_1 = MsgAdapter.ReadUShort()
	self.new_equip = {}
	local vo = {}
	vo.item_id = MsgAdapter.ReadUShort()
	table.insert(self.new_equip, vo)
	MsgAdapter.ReadUShort()
end

--周末装备积分变动
SCTianshenhutiScoreChange = SCTianshenhutiScoreChange or BaseClass(BaseProtocolStruct)
function SCTianshenhutiScoreChange:__init()
	self.msg_type = 8626
	self.roll_score = 0
end

function SCTianshenhutiScoreChange:Decode()
	self.roll_score = MsgAdapter.ReadInt()
end

--周末装备一键合成结果
SCTianshenhutiCombineOneKeyResult = SCTianshenhutiCombineOneKeyResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiCombineOneKeyResult:__init()
	self.msg_type = 8627
	self.new_equip = {}
end

function SCTianshenhutiCombineOneKeyResult:Decode()
	local combine_count = MsgAdapter.ReadInt()
	self.new_equip = {}
	for i=1, combine_count do
		local item_id = MsgAdapter.ReadUShort()
		self.new_equip[i] = {}
		self.new_equip[i].item_id = item_id
	end
end

-- 周末装备装备请求
CSTianshenhutiReq = CSTianshenhutiReq or BaseClass(BaseProtocolStruct)
function CSTianshenhutiReq:__init()
	self.msg_type = 8625
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
end

function CSTianshenhutiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
	MsgAdapter.WriteUShort(self.param_4)
	MsgAdapter.WriteUShort(0)
end

-------------------------boss掉落日志-------------------------------
--请求日志信息
CSGetDropLog = CSGetDropLog or BaseClass(BaseProtocolStruct)
function CSGetDropLog:__init()
	self.msg_type = 8628
end

function CSGetDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--日志信息返回
SCDropLogRet = SCDropLogRet or BaseClass(BaseProtocolStruct)
function SCDropLogRet:__init()
	self.msg_type = 8629
end

function SCDropLogRet:Decode()
	local count = MsgAdapter.ReadInt()

	self.log_list = {}
	for i = 1, count do
		local log_info = {}
		log_info.uid = MsgAdapter.ReadInt()
		log_info.role_name = MsgAdapter.ReadStrN(32)
		log_info.monster_id = MsgAdapter.ReadInt()
		log_info.item_id = MsgAdapter.ReadUShort()
		log_info.item_num = MsgAdapter.ReadShort()
		log_info.timestamp = MsgAdapter.ReadInt()
		log_info.scene_id = MsgAdapter.ReadInt()

		table.insert(self.log_list, 1, log_info)
	end
end
-------------------------boss掉落日志END-------------------------------

-------------------------Boss图鉴-----------------------------------------
--图鉴信息
SCBossHandBookAllInfo = SCBossHandBookAllInfo or BaseClass(BaseProtocolStruct)
function SCBossHandBookAllInfo:__init()
	self.msg_type = 8630
	self.handbook_level_list = {}
end

function SCBossHandBookAllInfo:Decode()
	self.handbook_level_list = {}
	for i = 0, GameEnum.BOSS_HANDBOOK_CARD_MAX_COUNT - 1 do
		self.handbook_level_list[i] = MsgAdapter.ReadInt()
	end
end

--单个图鉴信息
SCBossHandBookCardInfo = SCBossHandBookCardInfo or BaseClass(BaseProtocolStruct)
function SCBossHandBookCardInfo:__init()
	self.msg_type = 8631
	self.card_idx = 0 				-- 第几个图鉴
	self.level = 0 					-- 图鉴等级
end

function SCBossHandBookCardInfo:Decode()
	self.card_idx = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
end

--装备图鉴part
CSBossHandBookPutOn = CSBossHandBookPutOn or BaseClass(BaseProtocolStruct)
function CSBossHandBookPutOn:__init()
	self.msg_type = 8632
	self.card_idx = 0 				-- 第几个图鉴 从0开始
end

function CSBossHandBookPutOn:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.card_idx)
end

---------------------------------------------------------------
--锁妖塔
CSSuoyaotaFbOperaReq = CSSuoyaotaFbOperaReq or BaseClass(BaseProtocolStruct)
function CSSuoyaotaFbOperaReq:__init()
	self.msg_type = 8640
end

function CSSuoyaotaFbOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

SCSuoyaotaFbAllInfo = SCSuoyaotaFbAllInfo or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbAllInfo:__init()
	self.msg_type = 8641
end

function SCSuoyaotaFbAllInfo:Decode()
	self.fb_info_list = {}
	local one_vo = {}
	one_vo.pass_chapter = MsgAdapter.ReadShort() + 1			--已通过最大章节
	one_vo.pass_level = MsgAdapter.ReadShort() + 1				--已通过最大关卡等级
	one_vo.today_join_times = MsgAdapter.ReadShort()			--今日进入次数
	one_vo.buy_join_times = MsgAdapter.ReadShort()				--购买次数
	one_vo.chapter_info_list = {}								--章节列表，数组长度50

	for j = 1, 50 do
		local chatper_info = {}
		chatper_info.is_pass_chapter = MsgAdapter.ReadChar()	--是否章节通关(一章里面所有关卡通关)
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		chatper_info.total_star = MsgAdapter.ReadShort()		--章节总星数
		chatper_info.star_reward_flag = MsgAdapter.ReadShort()	--章节星数奖励拿取标记，按位与
		chatper_info.level_info_list = {}						--关卡列表，数组大小20
		for k = 1 , 20 do
			local level_info = {}
			level_info.pass_star = MsgAdapter.ReadChar()		--关卡通关星数
			level_info.reward_flag = MsgAdapter.ReadChar()		--关卡奖励拿取标记（0或1）
			MsgAdapter.ReadShort()
			chatper_info.level_info_list[k] = level_info
		end
		one_vo.chapter_info_list[j] = chatper_info
	end
	self.fb_info_list = one_vo
end

SCSuoyaotaFbResultInfo = SCSuoyaotaFbResultInfo or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbResultInfo:__init()
	self.msg_type = 8642
end

function SCSuoyaotaFbResultInfo:Decode()
	self.star = MsgAdapter.ReadChar()				-- 通关星级 star > 0则成功 否则失败
	MsgAdapter.ReadChar()
	self.item_count = MsgAdapter.ReadShort()
	self.reward_item_list = {}
	for i = 0, self.item_count - 1 do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.reward_item_list[i] = vo
	end
end

SCSuoyaotaFbSingleInfo = SCSuoyaotaFbSingleInfo or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbSingleInfo:__init()
	self.msg_type = 8643
end

function SCSuoyaotaFbSingleInfo:Decode()
	self.fb_type = MsgAdapter.ReadShort()						-- 副本类型
	self.chatper = MsgAdapter.ReadChar()					    -- 副本章节
	self.level = MsgAdapter.ReadChar()				    		-- 副本关卡等级 --xianzai da
	self.cur_chapter = MsgAdapter.ReadShort()					-- 当前进行章节
	self.cur_level = MsgAdapter.ReadShort()						-- 当前进行关卡等级 --最大
	self.today_join_times = MsgAdapter.ReadShort()				-- 今日进入副本次数
	self.buy_join_times = MsgAdapter.ReadShort()				-- 购买次数
	self.total_star = MsgAdapter.ReadShort()			        -- 章节总星数
	self.star_reward_flag = MsgAdapter.ReadShort()		        -- 章节星数奖励标记
	self.layer_info = {}										-- 关卡信息
	self.layer_info.pass_star = MsgAdapter.ReadChar()
	self.layer_info.reward_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

SCSuoyaotaFbFetchResultInfo = SCSuoyaotaFbFetchResultInfo or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbFetchResultInfo:__init()
	self.msg_type = 8644
end

function SCSuoyaotaFbFetchResultInfo:Decode()
	self.is_success = MsgAdapter.ReadShort()
	self.fb_type = MsgAdapter.ReadShort()
	self.chapter = MsgAdapter.ReadShort()
	self.seq = MsgAdapter.ReadShort()
end

SCSuoyaotaFbPowerInfo = SCSuoyaotaFbPowerInfo or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbPowerInfo:__init()
	self.msg_type = 8645
end

function SCSuoyaotaFbPowerInfo:Decode()
	self.power = MsgAdapter.ReadInt()
	self.buy_join_times = MsgAdapter.ReadInt()
end

SCSuoyaotaFbTitle = SCSuoyaotaFbTitle or BaseClass(BaseProtocolStruct)
function SCSuoyaotaFbTitle:__init()
	self.msg_type = 8646

	self.role_name = {}
end

function SCSuoyaotaFbTitle:Decode()
	for i = 1, 50 do
		self.role_name[i] = MsgAdapter.ReadStrN(32)
	end
end

----------------------腰饰-----------------------------
--腰饰数据
SCYaoShiInfo = SCYaoShiInfo or BaseClass(BaseProtocolStruct)
function SCYaoShiInfo:__init()
	self.msg_type = 8650
end

function SCYaoShiInfo:Decode()
	self.yaoshi_info = {}
	self.yaoshi_info.level = MsgAdapter.ReadShort()										-- 等级
	self.yaoshi_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.yaoshi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.yaoshi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.yaoshi_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.yaoshi_info.chengzhangdan_count = MsgAdapter.ReadShort()						-- 成长丹数量
	self.yaoshi_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.yaoshi_info.active_image_flag = MsgAdapter.ReadInt()							-- 激活的形象列表
	self.yaoshi_info.active_special_image_flag_low = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-低位
	self.yaoshi_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-高位
	self.yaoshi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.yaoshi_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.yaoshi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.yaoshi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.yaoshi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_WAIST_SPECIAL_IMAGE_COUNT - 1 do 							-- 服务端数组从0开始 有效数值从1开始 数组长度超过63会有问题
		self.yaoshi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 腰饰外观改变
SCYaoShiAppeChange = SCYaoShiAppeChange or BaseClass(BaseProtocolStruct)
function SCYaoShiAppeChange:__init()
	self.msg_type = 8651
end

function SCYaoShiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.yaoshi_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseYaoShiImage = CSUseYaoShiImage or BaseClass(BaseProtocolStruct)
function CSUseYaoShiImage:__init()
	self.msg_type = 8652
end

function CSUseYaoShiImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 腰饰特殊形象进阶
CSYaoShiSpecialImgUpgrade = CSYaoShiSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSYaoShiSpecialImgUpgrade:__init()
	self.msg_type = 8653
end

function CSYaoShiSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求腰饰信息
CSYaoShiGetInfo = CSYaoShiGetInfo or BaseClass(BaseProtocolStruct)
function CSYaoShiGetInfo:__init()
	self.msg_type = 8654
end

function CSYaoShiGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求腰饰进阶
CSUpgradeYaoShi = CSUpgradeYaoShi or BaseClass(BaseProtocolStruct)
function CSUpgradeYaoShi:__init()
	self.msg_type = 8655
end

function CSUpgradeYaoShi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------腰饰END----------------------------

----------------------头饰-----------------------------
--头饰数据
SCTouShiInfo = SCTouShiInfo or BaseClass(BaseProtocolStruct)
function SCTouShiInfo:__init()
	self.msg_type = 8660
end

function SCTouShiInfo:Decode()
	self.toushi_info = {}
	self.toushi_info.level = MsgAdapter.ReadShort()										-- 等级
	self.toushi_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.toushi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.toushi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.toushi_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.toushi_info.chengzhangdan_count = MsgAdapter.ReadShort()						-- 成长丹数量
	self.toushi_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.toushi_info.active_image_flag = MsgAdapter.ReadInt()							-- 激活的形象列表
	self.toushi_info.active_special_image_flag_low = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-低位
	self.toushi_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-高位
	self.toushi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.toushi_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.toushi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.toushi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.toushi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_TOUSHI_SPECIAL_IMAGE_COUNT - 1 do 								-- 服务端数组从0开始 有效数值从1开始 数组长度超过63会有问题
		self.toushi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 头饰外观改变
SCTouShiAppeChange = SCTouShiAppeChange or BaseClass(BaseProtocolStruct)
function SCTouShiAppeChange:__init()
	self.msg_type = 8661
end

function SCTouShiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.toushi_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseTouShiImage = CSUseTouShiImage or BaseClass(BaseProtocolStruct)
function CSUseTouShiImage:__init()
	self.msg_type = 8662
end

function CSUseTouShiImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 头饰特殊形象进阶
CSTouShiSpecialImgUpgrade = CSTouShiSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSTouShiSpecialImgUpgrade:__init()
	self.msg_type = 8663
end

function CSTouShiSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求头饰信息
CSTouShiGetInfo = CSTouShiGetInfo or BaseClass(BaseProtocolStruct)
function CSTouShiGetInfo:__init()
	self.msg_type = 8664
end

function CSTouShiGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求头饰进阶
CSUpgradeTouShi = CSUpgradeTouShi or BaseClass(BaseProtocolStruct)
function CSUpgradeTouShi:__init()
	self.msg_type = 8665
end

function CSUpgradeTouShi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------头饰END----------------------------

----------------------麒麟臂-----------------------------
--麒麟臂数据
SCQilinBiInfo = SCQilinBiInfo or BaseClass(BaseProtocolStruct)
function SCQilinBiInfo:__init()
	self.msg_type = 8670
end

function SCQilinBiInfo:Decode()
	self.qilinbi_info = {}
	self.qilinbi_info.level = MsgAdapter.ReadShort()									-- 等级
	self.qilinbi_info.grade = MsgAdapter.ReadShort()									-- 阶
	self.qilinbi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.qilinbi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.qilinbi_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.qilinbi_info.chengzhangdan_count = MsgAdapter.ReadShort()						-- 成长丹数量
	self.qilinbi_info.grade_bless_val = MsgAdapter.ReadInt()							-- 进阶祝福值
	self.qilinbi_info.active_image_flag = MsgAdapter.ReadInt()							-- 激活的形象列表
	self.qilinbi_info.active_special_image_flag_low = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-低位
	self.qilinbi_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-高位
	self.qilinbi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.qilinbi_info.temporary_imageid = MsgAdapter.ReadShort()						-- 当前使用临时形象
	self.qilinbi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.qilinbi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.qilinbi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_QILINBI_SPECIAL_IMAGE_COUNT - 1 do 								-- 服务端数组从0开始 有效数值从1开始 数组长度超过63会有问题
		self.qilinbi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 麒麟臂外观改变
SCQilinBiAppeChange = SCQilinBiAppeChange or BaseClass(BaseProtocolStruct)
function SCQilinBiAppeChange:__init()
	self.msg_type = 8671
end

function SCQilinBiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.qilinbi_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseQilinBiImage = CSUseQilinBiImage or BaseClass(BaseProtocolStruct)
function CSUseQilinBiImage:__init()
	self.msg_type = 8672
end

function CSUseQilinBiImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 麒麟臂特殊形象进阶
CSQilinBiSpecialImgUpgrade = CSQilinBiSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSQilinBiSpecialImgUpgrade:__init()
	self.msg_type = 8673
end

function CSQilinBiSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求麒麟臂信息
CSQilinBiGetInfo = CSQilinBiGetInfo or BaseClass(BaseProtocolStruct)
function CSQilinBiGetInfo:__init()
	self.msg_type = 8674
end

function CSQilinBiGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求麒麟臂进阶
CSUpgradeQilinBi = CSUpgradeQilinBi or BaseClass(BaseProtocolStruct)
function CSUpgradeQilinBi:__init()
	self.msg_type = 8675
end

function CSUpgradeQilinBi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------麒麟臂END----------------------------

----------------------面饰-----------------------------
--面饰数据
SCMaskInfo = SCMaskInfo or BaseClass(BaseProtocolStruct)
function SCMaskInfo:__init()
	self.msg_type = 8680
end

function SCMaskInfo:Decode()
	self.mask_info = {}
	self.mask_info.level = MsgAdapter.ReadShort()										-- 等级
	self.mask_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.mask_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.mask_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.mask_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.mask_info.chengzhangdan_count = MsgAdapter.ReadShort()							-- 成长丹数量
	self.mask_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.mask_info.active_image_flag = MsgAdapter.ReadInt()								-- 激活的形象列表
	self.mask_info.active_special_image_flag_low = MsgAdapter.ReadInt()					-- 激活的特殊形象列表-低位
	self.mask_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表-高位
	self.mask_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.mask_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.mask_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.mask_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.mask_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MASK_SPECIAL_IMAGE_COUNT - 1 do 								-- 服务端数组从0开始 有效数值从1开始 数组长度超过63会有问题
		self.mask_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 面饰外观改变
SCMaskAppeChange = SCMaskAppeChange or BaseClass(BaseProtocolStruct)
function SCMaskAppeChange:__init()
	self.msg_type = 8681
end

function SCMaskAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.mask_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseMaskImage = CSUseMaskImage or BaseClass(BaseProtocolStruct)
function CSUseMaskImage:__init()
	self.msg_type = 8682
end

function CSUseMaskImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 面饰特殊形象进阶
CSMaskSpecialImgUpgrade = CSMaskSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSMaskSpecialImgUpgrade:__init()
	self.msg_type = 8683
end

function CSMaskSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求面饰信息
CSMaskGetInfo = CSMaskGetInfo or BaseClass(BaseProtocolStruct)
function CSMaskGetInfo:__init()
	self.msg_type = 8684
end

function CSMaskGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求面饰进阶
CSUpgradeMask = CSUpgradeMask or BaseClass(BaseProtocolStruct)
function CSUpgradeMask:__init()
	self.msg_type = 8685
end

function CSUpgradeMask:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------面饰END----------------------------

----------------------仙宝-----------------------------
--仙宝数据
SCXianBaoInfo = SCXianBaoInfo or BaseClass(BaseProtocolStruct)
function SCXianBaoInfo:__init()
	self.msg_type = 8690
end

function SCXianBaoInfo:Decode()
	self.xianbao_info = {}
	self.xianbao_info.level = MsgAdapter.ReadShort()										-- 等级
	self.xianbao_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.xianbao_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.xianbao_info.used_imageid = MsgAdapter.ReadShort()									-- 使用的形象
	self.xianbao_info.shuxingdan_count = MsgAdapter.ReadShort()								-- 属性丹数量
	self.xianbao_info.chengzhangdan_count = MsgAdapter.ReadShort()							-- 成长丹数量
	self.xianbao_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.xianbao_info.active_image_flag = MsgAdapter.ReadInt()								-- 激活的形象列表
	self.xianbao_info.active_special_image_flag_high = MsgAdapter.ReadInt()					-- 激活的特殊形象列表1
	self.xianbao_info.active_special_image_flag_low = MsgAdapter.ReadInt()					-- 激活的特殊形象列表2
	self.xianbao_info.clear_upgrade_time = MsgAdapter.ReadInt()								-- 清空祝福值的时间
	self.xianbao_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.xianbao_info.temporary_imageid_has_select = MsgAdapter.ReadShort()					-- 已选定的临时形象
	self.xianbao_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()					-- 临时形象有效时间

	self.xianbao_info.special_img_grade_list = {}
	for i = 1, GameEnum.MAX_XIANBAO_SPECIAL_IMAGE_COUNT do
		self.xianbao_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 仙宝外观改变
SCXianBaoAppeChange = SCXianBaoAppeChange or BaseClass(BaseProtocolStruct)
function SCXianBaoAppeChange:__init()
	self.msg_type = 8691
end

function SCXianBaoAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.xianbao_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseXianBaoImage = CSUseXianBaoImage or BaseClass(BaseProtocolStruct)
function CSUseXianBaoImage:__init()
	self.msg_type = 8692
end

function CSUseXianBaoImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 仙宝特殊形象进阶
CSXianBaoSpecialImgUpgrade = CSXianBaoSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSXianBaoSpecialImgUpgrade:__init()
	self.msg_type = 8693
end

function CSXianBaoSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求仙宝信息
CSXianBaoGetInfo = CSXianBaoGetInfo or BaseClass(BaseProtocolStruct)
function CSXianBaoGetInfo:__init()
	self.msg_type = 8694
end

function CSXianBaoGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求仙宝进阶
CSUpgradeXianBao = CSUpgradeXianBao or BaseClass(BaseProtocolStruct)
function CSUpgradeXianBao:__init()
	self.msg_type = 8695
end

function CSUpgradeXianBao:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------仙宝END----------------------------

SCGreateSoldierEquipSlotInfo = SCGreateSoldierEquipSlotInfo or BaseClass(BaseProtocolStruct)

function SCGreateSoldierEquipSlotInfo:__init()
	self.msg_type = 8604
end

function SCGreateSoldierEquipSlotInfo:Decode()
	self.slot_info_list = {}
	self.count = MsgAdapter.ReadInt()
	for i = 1, self.count do
		self.slot_info_list[i] = {}
		for k = 1, COMMON_CONSTS.GREATE_SOLDIER_EQUIP_PART_COUNT do
			self.slot_info_list[i][k] = {}
			self.slot_info_list[i][k].slot_level = MsgAdapter.ReadShort()
			self.slot_info_list[i][k].slot_equip_item_id = MsgAdapter.ReadUShort()
		end
	end
end

SCGreateSoldierEquipVirtualBagInfo = SCGreateSoldierEquipVirtualBagInfo or BaseClass(BaseProtocolStruct)

function SCGreateSoldierEquipVirtualBagInfo:__init()
	self.msg_type = 8605
end

function SCGreateSoldierEquipVirtualBagInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.grid_info_list = {}

	for i = 1, self.count do
		local grid_index = MsgAdapter.ReadShort()
		self.grid_info_list[grid_index] = MsgAdapter.ReadShort()
	end
end

SCGreateSoldierEquipSingleSlotInfo = SCGreateSoldierEquipSingleSlotInfo or BaseClass(BaseProtocolStruct)

function SCGreateSoldierEquipSingleSlotInfo:__init()
	self.msg_type = 8606
end

function SCGreateSoldierEquipSingleSlotInfo:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.slot_info_list = {}
	for i = 1, COMMON_CONSTS.GREATE_SOLDIER_EQUIP_PART_COUNT do
		self.slot_info_list[i] = {}
		self.slot_info_list[i].slot_level = MsgAdapter.ReadShort()
		self.slot_info_list[i].slot_equip_item_id = MsgAdapter.ReadUShort()
	end
end