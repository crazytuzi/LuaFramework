
--------------------------------徐福赐礼------------------------------------
--请求徐福赐礼信息
CSXufuciliInfoReq = CSXufuciliInfoReq or BaseClass(BaseProtocolStruct)
function CSXufuciliInfoReq:__init()
	self.msg_type = 8800
	self.function_type = 0
end

function CSXufuciliInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.function_type)
end

--徐福赐礼信息返回
SCXufuciliInfoAck = SCXufuciliInfoAck or BaseClass(BaseProtocolStruct)
function SCXufuciliInfoAck:__init()
	self.msg_type = 8801
	self.active_stamp = 0
	self.gift_type = 0
	self.gift_buy_num_list = {}
	self.is_sold_out = 0
	-- self.bind_gold_buy_times = 0
	-- self.gold_buy_times = 0
	-- self.RMB_buy_times = 0
end

function SCXufuciliInfoAck:Decode()
	self.gift_type = MsgAdapter.ReadInt()							--礼包类型
	self.active_stamp = MsgAdapter.ReadInt()						--该功能激活的时间
	-- self.bind_gold_buy_times = MsgAdapter.ReadInt()				--绑元购买次数
	-- self.gold_buy_times = MsgAdapter.ReadInt()					--元宝购买次数
	-- self.RMB_buy_times = MsgAdapter.ReadInt()					--人民币购买次数
	for i = 0, COMMON_CONSTS.XUFUCILI_GIFT_PRICE_CFG_NUM_MAX - 1 do
		self.gift_buy_num_list[i] = MsgAdapter.ReadChar()
	end

	self.is_sold_out = MsgAdapter.ReadInt()
end

--请求徐福赐礼购买
CSXufuciliBuyReq = CSXufuciliBuyReq or BaseClass(BaseProtocolStruct)
function CSXufuciliBuyReq:__init()
	self.msg_type = 8802
	self.cost_seq = 0
	self.gift_type = 0
end

function CSXufuciliBuyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.gift_type)							--礼包类型
	MsgAdapter.WriteInt(self.cost_seq)							--索引
end

--徐福赐礼购买结果返回
SCXufuciliBuyAck = SCXufuciliBuyAck or BaseClass(BaseProtocolStruct)
function SCXufuciliBuyAck:__init()
	self.msg_type = 8803
	self.is_succ = 0
	self.gift_type = 0
	self.bind_gold_rest_buy_num = 0
	self.gold_rest_buy_num = 0
	self.RMB_rest_buy_num = 0
end

function SCXufuciliBuyAck:Decode()
	self.is_succ = MsgAdapter.ReadInt()							--购买是否成功
	self.gift_type = MsgAdapter.ReadShort()						--对应功能
	self.bind_gold_rest_buy_num = MsgAdapter.ReadShort()		--绑元剩余购买次数
	self.gold_rest_buy_num = MsgAdapter.ReadShort()				--元宝剩余购买次数
	self.RMB_rest_buy_num = MsgAdapter.ReadShort()				--人民币剩余购买次数
end

--请求徐福赐礼所有功能开启信息
CSXufuciliAllActiveStampInfoReq = CSXufuciliAllActiveStampInfoReq or BaseClass(BaseProtocolStruct)
function CSXufuciliAllActiveStampInfoReq:__init()
	self.msg_type = 8804
end

function CSXufuciliAllActiveStampInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--徐福赐礼功能开启信息返回
SCXufuciliAllActiveStampInfoAck = SCXufuciliAllActiveStampInfoAck or BaseClass(BaseProtocolStruct)
function SCXufuciliAllActiveStampInfoAck:__init()
	self.msg_type = 8805
end

function SCXufuciliAllActiveStampInfoAck:Decode()
	self.gift_sold_out_flag = MsgAdapter.ReadUInt()
	self.count = MsgAdapter.ReadInt() or 0
	self.active_stamp = {}
	for i = 1, self.count do
		self.active_stamp[i] = MsgAdapter.ReadUInt()
	end
end

--寻路加速信息
SCRunAccelerateInfo = SCRunAccelerateInfo or BaseClass(BaseProtocolStruct)
function SCRunAccelerateInfo:__init()
	self.msg_type = 8807
	self.is_auto_run = 0
	self.auto_run_time = 0
	self.run_accelerate_add_speed = 0
end

function SCRunAccelerateInfo:Decode()
	self.is_auto_run = MsgAdapter.ReadInt()					-- 是否自动寻路中
	self.auto_run_time = MsgAdapter.ReadUInt()				-- 已自动寻路的时间（ms）
	self.run_accelerate_add_speed = MsgAdapter.ReadInt()	-- 加速度
end

--世界等级信息返回
SCServerLevelInfo = SCServerLevelInfo or BaseClass(BaseProtocolStruct)
function SCServerLevelInfo:__init()
	self.msg_type = 8840
	self.world_level = 0									-- 世界等级
	self.cur_server_level_seq = 0							-- 当前服务器等级配置表seq
	self.cur_server_level = 0								-- 当前服务器等级
	self.cur_satify_role_num = 0							-- 满足服务器等级的玩家个数
	self.server_level_auto_uplevel_last_days = 0			-- 服务器等级自动升级剩余天数
end

function SCServerLevelInfo:Decode()
	self.world_level = MsgAdapter.ReadInt()
	self.cur_server_level_seq = MsgAdapter.ReadInt()
	self.cur_server_level = MsgAdapter.ReadInt()
	self.cur_satify_role_num = MsgAdapter.ReadInt()
	self.server_level_auto_uplevel_last_days = MsgAdapter.ReadInt()
end

--请求世界等级
CSServerLevelInfo = CSServerLevelInfo or BaseClass(BaseProtocolStruct)
function CSServerLevelInfo:__init()
	self.msg_type = 8845
end

function CSServerLevelInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--------------推图副本-------------------------------
--请求
CSTuituFbOperaReq = CSTuituFbOperaReq or BaseClass(BaseProtocolStruct)
function CSTuituFbOperaReq:__init()
	self.msg_type = 8850
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTuituFbOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)							--请求信息
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 皇陵除恶
SCHuanglingFBRoleInfo = SCHuanglingFBRoleInfo or BaseClass(BaseProtocolStruct)
function SCHuanglingFBRoleInfo:__init()
	self.msg_type = 8851

	self.team_info_list = {}
	self.today_kill_role_score = 0
end

function SCHuanglingFBRoleInfo:Decode()
	self.team_info_list = {}
	for i = 1, 3 do
		local vo = {}
		vo.name = MsgAdapter.ReadStrN(32)
		vo.shared_score = MsgAdapter.ReadInt()
		self.team_info_list[i] = vo
	end
	self.today_kill_role_score = MsgAdapter.ReadInt()
end

--推图副本信息
SCTuituFbInfo = SCTuituFbInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbInfo:__init()
	self.msg_type = 8855
end

function SCTuituFbInfo:Decode()
	self.fb_info_list = {}											--副本信息， 数组长度2
	for i = 1, GameEnum.TUTUI_FB_TYPE_NUM_MAX do
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
			chatper_info.total_star = MsgAdapter.ReadShort()		--章节总星数
			chatper_info.star_reward_flag = MsgAdapter.ReadShort()	--章节星数奖励拿取标记，按位与
			MsgAdapter.ReadShort()
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
		self.fb_info_list[i] = one_vo
	end
end

SCTuituFbResultInfo = SCTuituFbResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbResultInfo:__init()
	self.msg_type = 8856
end

function SCTuituFbResultInfo:Decode()
	self.star = MsgAdapter.ReadChar()				-- 通关星级 star > 0则成功 否则失败
	MsgAdapter.ReadChar()
	self.item_count = MsgAdapter.ReadShort()
	self.reward_item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.reward_item_list[i] = vo
	end
end

SCTuituFbSingleInfo = SCTuituFbSingleInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbSingleInfo:__init()
	self.msg_type = 8857
end

function SCTuituFbSingleInfo:Decode()
	self.fb_type = MsgAdapter.ReadShort()						-- 副本类型
	self.chatper = MsgAdapter.ReadChar()					    -- 副本章节
	self.level = MsgAdapter.ReadChar()				    		-- 副本关卡等级
	self.cur_chapter = MsgAdapter.ReadShort()					-- 当前进行章节
	self.cur_level = MsgAdapter.ReadShort()						-- 当前进行关卡等级
	self.today_join_times = MsgAdapter.ReadShort()				-- 今日进入副本次数
	self.buy_join_times = MsgAdapter.ReadShort()				-- 购买次数
	self.total_star = MsgAdapter.ReadShort()			        -- 章节总星数
	self.star_reward_flag = MsgAdapter.ReadShort()		        -- 章节星数奖励标记
	self.layer_info = {}										-- 关卡信息
	self.layer_info.pass_star = MsgAdapter.ReadChar()
	self.layer_info.reward_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

SCTuituFbFetchResultInfo = SCTuituFbFetchResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbFetchResultInfo:__init()
	self.msg_type = 8858
end

function SCTuituFbFetchResultInfo:Decode()
	self.is_success = MsgAdapter.ReadShort()
	self.fb_type = MsgAdapter.ReadShort()
	self.chapter = MsgAdapter.ReadShort()
	self.seq = MsgAdapter.ReadShort()
end
--------------推图副本 end---------------------------

---------------- 法阵
CSFazhenOpera = CSFazhenOpera or BaseClass(BaseProtocolStruct)
function CSFazhenOpera:__init()
	self.msg_type = 8860

	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSFazhenOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

SCFazhenInfo = SCFazhenInfo or BaseClass(BaseProtocolStruct)
function SCFazhenInfo:__init()
	self.msg_type = 8870

	self.star_level = 0
	self.rolefazhen_level = 0
	self.grade = 0
	self.used_imageid = 0
	self.grade_bless_val = 0
	self.shuxingdan_count = 0
	self.chengzhangdan_count = 0
	self.active_image_flag = 0
	self.active_special_image_flag = 0
	self.clear_upgrade_time = 0
	self.special_img_grade_list = {}
end

function SCFazhenInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.rolefazhen_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadLL()
	self.active_special_image_flag = MsgAdapter.ReadLL()
	self.clear_upgrade_time = MsgAdapter.ReadInt()
	-- self.star_level = MsgAdapter.ReadShort()
	for i = 0, COMMON_CONSTS.MAX_SPECIAL_IMAGE_ID_COUNT - 1 do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

---------------- 天赋 ----------------------
CSTalentSystemOperateReq = CSTalentSystemOperateReq or BaseClass(BaseProtocolStruct)
function CSTalentSystemOperateReq:__init()
	self.msg_type = 8830

	self.type = 0
	self.page_index = 0
	self.talent_attr_list = {}
end

function CSTalentSystemOperateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.page_index)
	for i=1,3 do
		MsgAdapter.WriteInt(self.talent_attr_list[i])
	end
end

SCTalentSystemInfo = SCTalentSystemInfo or BaseClass(BaseProtocolStruct)
function SCTalentSystemInfo:__init()
	self.msg_type = 8831

	self.exchange_times = 0
	self.total_talent_points = 0
	self.page_index = 0
	self.remain_talent_points = 0
	self.is_actived_page = 0
	self.talent_attr_list = {}
end

function SCTalentSystemInfo:Decode()
	self.exchange_times = MsgAdapter.ReadInt()
	self.total_talent_points = MsgAdapter.ReadInt()
	self.remain_talent_points = MsgAdapter.ReadInt()
	self.page_index = MsgAdapter.ReadShort()
	self.is_actived_page = MsgAdapter.ReadUShort()
	for i = 1, 3 do
		self.talent_attr_list[i] = MsgAdapter.ReadInt()
	end
end

CSTeamSkillOperaReq = CSTeamSkillOperaReq or BaseClass(BaseProtocolStruct)
function CSTeamSkillOperaReq:__init()
	self.msg_type = 8880

	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTeamSkillOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
end

SCTeamSkillInfo = SCTeamSkillInfo or BaseClass(BaseProtocolStruct)
function SCTeamSkillInfo:__init()
	self.msg_type = 8890
	
	self.reason_type = 0
	self.skill_info = {}
	self.checklist = {}
end

function SCTeamSkillInfo:Decode()
	self.reason_type = MsgAdapter.ReadInt()

	-- 1 大技能， 2-3 中技能， 4-7 小技能
	for i = 1, TEAM_SKILL.TOTLE_NUM do
		local temp = {}
		temp.level = MsgAdapter.ReadInt()
		temp.exp = MsgAdapter.ReadInt()
		self.skill_info[i] = temp
	end

	-- 转换 检查是否可以升级用
	self.checklist = {}
	local median_index = 0
	local base_index = 0
	for i = 1, TEAM_SKILL.TOTLE_NUM do
		local temp = {}
		temp.level = self.skill_info[i].level
		temp.exp = self.skill_info[i].exp
		local index = 0
		local second_index = 0

		if i > TEAM_SKILL.HIGH and i <= (TEAM_SKILL.MEDIAN + TEAM_SKILL.HIGH) then
			index = TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_MEDIAN
			second_index = median_index
			median_index = median_index + 1
		elseif i > (TEAM_SKILL.MEDIAN + TEAM_SKILL.HIGH) then
			index = TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_PRIMARY
			second_index = base_index
			base_index = base_index + 1
		end
		self.checklist[index] = self.checklist[index] or {}
		self.checklist[index][second_index] = temp
	end
end

---------------------------抢地脉----------------------------------
-- 地脉操作请求
CSDimaiOpera = CSDimaiOpera or BaseClass(BaseProtocolStruct)
function CSDimaiOpera:__init()
	self.msg_type = 8891
end

function CSDimaiOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 地脉副本信息
SCFBDimaiInfo = SCFBDimaiInfo or BaseClass(BaseProtocolStruct)
function SCFBDimaiInfo:__init()
	self.msg_type = 8992
end

function SCFBDimaiInfo:Decode()
	self.layer = MsgAdapter.ReadInt()
	self.point = MsgAdapter.ReadInt()
 	self.is_win = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadInt()
end

local LoadDimaiInfo = function()
	local dimai_info = {}
	dimai_info.layer = MsgAdapter.ReadInt()
	dimai_info.point = MsgAdapter.ReadInt()
	dimai_info.uid = MsgAdapter.ReadInt()									-- 地脉属于的玩家
	dimai_info.protect_begin_time = MsgAdapter.ReadUInt()					-- 地脉保护起始时间
	dimai_info.challenge_succ_times = MsgAdapter.ReadInt()					-- 地脉挑战成功次数
	return dimai_info
end

-- 玩家的地脉信息
SCRoleDimaiInfo = SCRoleDimaiInfo or BaseClass(BaseProtocolStruct)
function SCRoleDimaiInfo:__init()
	self.msg_type = 8993
	self.dimai_info = {}
	self.camp_dimai_list = {}
end

function SCRoleDimaiInfo:Decode()
	self.dimai_info = LoadDimaiInfo()										-- 占领的地脉
	self.dimai_buy_times = MsgAdapter.ReadInt()								-- 今日地脉购买次数
	self.dimai_challenge_reward_fetch_flag = MsgAdapter.ReadUInt()			-- 地脉挑战奖励领取标记

	-- 本国拥有的地脉信息
	self.camp_dimai_list = {}
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		self.camp_dimai_list[i] = LoadDimaiInfo()
	end
end

-- 一层地脉信息
SCLayerDimaiInfo = SCLayerDimaiInfo or BaseClass(BaseProtocolStruct)
function SCLayerDimaiInfo:__init()
	self.msg_type = 8994
	self.layer = 0
	self.item_list = {}
end

function SCLayerDimaiInfo:Decode()
	self.layer = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, 9 do
		local vo = {}
		vo.is_challenging = MsgAdapter.ReadInt()
		vo.dimai_info = LoadDimaiInfo()
		self.item_list[i] = vo
	end
end

-- 单个地脉信息
SCSingleDimaiInfo = SCSingleDimaiInfo or BaseClass(BaseProtocolStruct)
function SCSingleDimaiInfo:__init()
	self.msg_type = 8995
	self.is_challenging = 0
	self.dimai_info = {}
end

function SCSingleDimaiInfo:Decode()
	self.is_challenging = MsgAdapter.ReadInt()
	self.dimai_info = LoadDimaiInfo()
end