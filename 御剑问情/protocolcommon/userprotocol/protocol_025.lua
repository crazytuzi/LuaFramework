local function DecodeMountEquipInfo()
	local t = {}
	t.equip_id = MsgAdapter.ReadUShort()
	t.level = MsgAdapter.ReadShort()
	t.exp = MsgAdapter.ReadInt()
	t.attr_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_ATTR_COUNT - 1 do
		t.attr_list[i] = MsgAdapter.ReadInt()
	end
	return t
end

-- 上战斗坐骑
CSGoonFightMount = CSGoonFightMount or BaseClass(BaseProtocolStruct)

function CSGoonFightMount:__init()
	self.msg_type = 2500
	self.goon_mount = 0
end

function CSGoonFightMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.goon_mount)
end

-- 战斗坐骑进阶请求
CSUpgradeFightMount = CSUpgradeFightMount or BaseClass(BaseProtocolStruct)

function CSUpgradeFightMount:__init()
	self.msg_type = 2501
	self.repeat_times = 1
	self.auto_buy = 0
end

function CSUpgradeFightMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

-- 战斗坐骑使用形象请求
CSUseFightMountImage = CSUseFightMountImage or BaseClass(BaseProtocolStruct)

function CSUseFightMountImage:__init()
	self.msg_type = 2502
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseFightMountImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

-- 战斗坐骑信息请求
CSFightMountGetInfo = CSFightMountGetInfo or BaseClass(BaseProtocolStruct)
function CSFightMountGetInfo:__init()
	self.msg_type = 2503
end

function CSFightMountGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 战斗坐骑升级装备请求
CSFightMountUplevelEquip = CSFightMountUplevelEquip  or BaseClass(BaseProtocolStruct)
function CSFightMountUplevelEquip:__init()
	self.msg_type = 2504
	self.equip_index = 0
end

function CSFightMountUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_index)
	MsgAdapter.WriteShort(0)
end

-- 战斗坐骑技能升级请求
CSFightMountSkillUplevelReq = CSFightMountSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSFightMountSkillUplevelReq:__init()
	self.msg_type = 2505
	self.skill_idx = 0
	self.auto_buy = 0
end

function CSFightMountSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.auto_buy)
end

--坐骑特殊形象进阶
CSFightMountSpecialImgUpgrade = CSFightMountSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSFightMountSpecialImgUpgrade:__init()
	self.msg_type = 2506
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSFightMountSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--坐骑升星
CSFightMountUpStarLevel = CSFightMountUpStarLevel or BaseClass(BaseProtocolStruct)
function CSFightMountUpStarLevel:__init()
	self.msg_type = 2507
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSFightMountUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end

-- 战斗坐骑信息
SCFightMountInfo = SCFightMountInfo or BaseClass(BaseProtocolStruct)

function SCFightMountInfo:__init()
	self.msg_type = 2550
end

function SCFightMountInfo:Decode()
	self.mount_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.mount_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.star_level = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadUInt()
	self.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()

	self.equip_skill_level = MsgAdapter.ReadInt()

	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeMountEquipInfo()
	-- end

	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID - 1  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 战斗坐骑外观改变信息
SCFightMountAppeChange = SCFightMountAppeChange or BaseClass(BaseProtocolStruct)

function SCFightMountAppeChange:__init()
	self.msg_type = 2551
end

function SCFightMountAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.mount_appeid = MsgAdapter.ReadUShort()
end

--在npc商店出售物品
CSNPCShopSell = CSNPCShopSell or BaseClass(BaseProtocolStruct)
function CSNPCShopSell:__init( )
	self.msg_type = 2555
end

function CSNPCShopSell:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.npc_id)
	MsgAdapter.WriteShort(self.function_index)
	MsgAdapter.WriteShort(self.open_type)
	MsgAdapter.WriteShort(self.count)
	for k,v in pairs(self.index_t) do
		print_log("CSNPCShopSellCSNPCShopSell",v)
		MsgAdapter.WriteShort(v)
	end
end

-- 神兽操作请求
CSShenshouOperaReq = CSShenshouOperaReq or BaseClass(BaseProtocolStruct)
function CSShenshouOperaReq	:__init()
	self.msg_type = 2560
	self.param_4 = 0
end

function CSShenshouOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
	MsgAdapter.WriteInt(self.param_4)
end

-- 神兽请求强化装备
CSSHenshouReqStrength = CSSHenshouReqStrength or BaseClass(BaseProtocolStruct)
function CSSHenshouReqStrength	:__init()
	self.msg_type = 2561
end

function CSSHenshouReqStrength:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.shenshou_id) 					-- 神兽id
	MsgAdapter.WriteShort(self.equip_index)						-- 要强化的装备下标
	MsgAdapter.WriteShort(self.is_double_shuliandu)				-- 是否双倍熟练度
	MsgAdapter.WriteShort(self.destroy_num)						-- 消耗物品个数
	for i=1, #self.destroy_backpack_index_list do
		MsgAdapter.WriteShort(self.destroy_backpack_index_list[i] or 0)
	end
end

-- 神兽背包信息
SCShenshouBackpackInfo = SCShenshouBackpackInfo or BaseClass(BaseProtocolStruct)
function SCShenshouBackpackInfo:__init()
	self.msg_type = 2562
end

function SCShenshouBackpackInfo:Decode()
	self.is_full_backpack = MsgAdapter.ReadChar()			-- 是否全量信息下发
	MsgAdapter.ReadChar()
	self.grid_num = MsgAdapter.ReadShort()					-- 格子数量
	self.grid_list = {}										-- 格子信息列表
	for i=1, self.grid_num do
		local data = {}
		MsgAdapter.ReadShort()
		data.index = MsgAdapter.ReadShort()
		data.item_id = MsgAdapter.ReadShort()
		data.strength_level = MsgAdapter.ReadShort()		-- 强化等级
		data.shuliandu = MsgAdapter.ReadInt()				-- 熟练度
		data.attr_list = {}
		for j=1, GameEnum.SHENSHOU_MAX_EQUIP_ATTR_COUNT do
			local vo = {}
			vo.attr_type = MsgAdapter.ReadShort()
			MsgAdapter.ReadShort()
			vo.attr_value = MsgAdapter.ReadInt()
			data.attr_list[j] = vo
		end
		self.grid_list[i] = data
	end
end

-- 神兽信息
SCShenshouListInfo = SCShenshouListInfo or BaseClass(BaseProtocolStruct)
function SCShenshouListInfo:__init()
	self.msg_type = 2563
end

function SCShenshouListInfo:Decode()
	self.is_all_shenshou = MsgAdapter.ReadChar()			-- 是否全量信息下发
	MsgAdapter.ReadChar()
	self.shenshou_num = MsgAdapter.ReadShort()
	self.shenshou_list = {}								-- 有装备信息的神兽列表
	for i=1, self.shenshou_num do
		local data = {}
		MsgAdapter.ReadShort()
		data.shou_id = MsgAdapter.ReadShort()
		data.has_zhuzhan = MsgAdapter.ReadChar()			-- 是否助战了
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		data.equip_list = {}
		for j=1, GameEnum.SHENSHOU_MAX_EQUIP_SLOT_INDEX + 1 do
			local t = {}
			t.slot_index = j - 1
			t.item_id = MsgAdapter.ReadShort()
			t.strength_level = MsgAdapter.ReadShort()
			t.shuliandu = MsgAdapter.ReadInt()
			t.attr_list = {}
			for k=1, GameEnum.SHENSHOU_MAX_EQUIP_ATTR_COUNT do
				local tab = {}
				tab.attr_type = MsgAdapter.ReadShort()
				MsgAdapter.ReadShort()
				tab.attr_value = MsgAdapter.ReadInt()
				t.attr_list[k] = tab
			end
			data.equip_list[j] = t
		end
		self.shenshou_list[i] = data
	end
end

-- 神兽额外助战位
SCShenshouBaseInfo = SCShenshouBaseInfo or BaseClass(BaseProtocolStruct)
function SCShenshouBaseInfo:__init()
	self.msg_type = 2564
end

function SCShenshouBaseInfo:Decode()
	self.extra_zhuzhan_count = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end
-- 神兽唤灵刷新列表
SCShenshouHuanlingListInfo = SCShenshouHuanlingListInfo or BaseClass(BaseProtocolStruct)

function SCShenshouHuanlingListInfo:__init()
	self.msg_type = 2565
end

function SCShenshouHuanlingListInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.cur_draw_times = MsgAdapter.ReadInt()
	self.huanling_list = {}
	for i = 1, GameEnum.SHENSHOU_MAX_RERFESH_ITEM_COUNT do
		local data = {}
		data.huanling_seq = MsgAdapter.ReadShort()
		data.draw = MsgAdapter.ReadChar()
		data.pool_index = MsgAdapter.ReadChar()
		self.huanling_list[i] = data
	end
end

-- 神兽唤灵抽奖结果
SCShenshouHuanlingDrawInfo = SCShenshouHuanlingDrawInfo or BaseClass(BaseProtocolStruct)

function SCShenshouHuanlingDrawInfo:__init()
	self.msg_type = 2566
end

function SCShenshouHuanlingDrawInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.seq = MsgAdapter.ReadShort()
	self.cur_draw_times = MsgAdapter.ReadShort()
end

-- 形象赋灵信息
SCImgFulingInfo = SCImgFulingInfo or BaseClass(BaseProtocolStruct)

function SCImgFulingInfo:__init()
	self.msg_type = 2570
end

function SCImgFulingInfo:Decode()
	self.fuling_list = {}
	for i = 0, GameEnum.IMG_FULING_JINGJIE_TYPE_MAX - 1 do
		self.fuling_list[i] = {}
		self.fuling_list[i].img_id_list = {}
		for index = 1, GameEnum.IMG_FULING_SLOT_COUNT do
			self.fuling_list[i].img_id_list[index] = MsgAdapter.ReadChar()
		end

		self.fuling_list[i].img_count = MsgAdapter.ReadChar()
		self.fuling_list[i].level = MsgAdapter.ReadShort()
		self.fuling_list[i].skill_level = MsgAdapter.ReadShort()
		self.fuling_list[i].cur_exp = MsgAdapter.ReadUInt()
	end
end

--形象操作
CSImgFulingOperate = CSImgFulingOperate or BaseClass(BaseProtocolStruct)
function CSImgFulingOperate:__init()
	self.msg_type = 2571
end

function CSImgFulingOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
end

-- 超级宝宝改名请求
CSSupBabyRenameReq = CSSupBabyRenameReq or BaseClass(BaseProtocolStruct)
function CSSupBabyRenameReq:__init()
	self.msg_type = 2580
	self.new_name = ""
end

function CSSupBabyRenameReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStrN(self.new_name, 32)
end

-- 发送超级宝宝信息
SCSupBabyInfo = SCSupBabyInfo or BaseClass(BaseProtocolStruct)
function SCSupBabyInfo:__init()
	self.msg_type = 2581
end

function SCSupBabyInfo:Decode()
	self.super_baby_info = {}
	self.super_baby_info.grade = MsgAdapter.ReadShort()
	self.super_baby_info.baby_id = MsgAdapter.ReadShort()
	self.super_baby_info.fight_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.super_baby_info.baby_name = MsgAdapter.ReadStrN(32)
end

-- 超级宝宝场景广播
SCSupBabyViewBroadcast = SCSupBabyViewBroadcast or BaseClass(BaseProtocolStruct)
function SCSupBabyViewBroadcast:__init()
	self.msg_type = 2582
end

function SCSupBabyViewBroadcast:Decode()
	self.role_obj_id = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.super_baby_info = {}
	self.super_baby_info.grade = MsgAdapter.ReadShort()
	self.super_baby_info.baby_id = MsgAdapter.ReadShort()
	self.super_baby_info.fight_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.super_baby_info.baby_name = MsgAdapter.ReadStrN(32)
end

-- 超级宝宝领取标志
SCSupBabyAwardFlag = SCSupBabyAwardFlag or BaseClass(BaseProtocolStruct)
function SCSupBabyAwardFlag:__init()
	self.msg_type = 2583
end

function SCSupBabyAwardFlag:Decode()
	self.little_target_award_flag = MsgAdapter.ReadShort()				-- 0 不可领取 1 可以领取 2 已经领取
	self.award_flag = MsgAdapter.ReadShort()							-- 0 不可领取 1 可以领取 2 已经领取
end