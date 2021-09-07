--精灵法阵升星请求
CSJinglingFazhenUpStarLevel = CSJinglingFazhenUpStarLevel or BaseClass(BaseProtocolStruct)
function CSJinglingFazhenUpStarLevel:__init()
	self.msg_type = 6900
	self.is_auto_buy = 0
	self.repeat_times = 0
end

function CSJinglingFazhenUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_auto_buy)
	MsgAdapter.WriteInt(self.repeat_times)
end

--请求使用精灵法阵形象
CSUseJinglingFazhenImage = CSUseJinglingFazhenImage or BaseClass(BaseProtocolStruct)
function CSUseJinglingFazhenImage:__init()
	self.msg_type = 6901
	self.image_id = 0
end

function CSUseJinglingFazhenImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.image_id)
end

--请求精灵法阵信息
CSJinglingFazhenGetInfo = CSJinglingFazhenGetInfo or BaseClass(BaseProtocolStruct)
function CSJinglingFazhenGetInfo:__init()
	self.msg_type = 6902
end

function CSJinglingFazhenGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求使用精灵法阵特殊形象
CSJinglingFazhenSpecialImgUpgrade =  CSJinglingFazhenSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSJinglingFazhenSpecialImgUpgrade:__init()
	self.msg_type = 6903
	self.special_image_id = 0
end

function CSJinglingFazhenSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

--精灵法阵升级装备请求
CSJinglingFazhenUplevelEquip =  CSJinglingFazhenUplevelEquip or BaseClass(BaseProtocolStruct)
function CSJinglingFazhenUplevelEquip:__init()
	self.msg_type = 6904
	self.equip_idx = 0
end

function CSJinglingFazhenUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_idx)
	MsgAdapter.WriteShort(0)
end


-- 精灵法阵信息
SCJinglingFazhenInfo = SCJinglingFazhenInfo or BaseClass(BaseProtocolStruct)

function SCJinglingFazhenInfo:__init()
	self.msg_type = 6925
end

function SCJinglingFazhenInfo:Decode()
	MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.grade_bless_val = MsgAdapter.ReadInt()

	self.active_special_image_flag = MsgAdapter.ReadInt()

	self.shuxingdan_count = MsgAdapter.ReadInt()
	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

---------------------------------------飞仙装备---------------------------------------------

CSZhuanShengOpearReq = CSZhuanShengOpearReq or BaseClass(BaseProtocolStruct)
function CSZhuanShengOpearReq:__init()
	self.msg_type = 6950

	self.opera_type = 0
	self.reserve_sh = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSZhuanShengOpearReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

-- 转生装备
SCZhuanShengAllInfo = SCZhuanShengAllInfo or BaseClass(BaseProtocolStruct)
function SCZhuanShengAllInfo:__init()
	self.msg_type = 6975

	self.last_time_free_chou_timestamp = 0 				-- 上次免费抽时间戳
	self.personal_xiuwei = 0 							-- 个人修为
	self.zhuansheng_level = 0 							-- 当前转生等级
	self.day_change_times = 0 							-- 当天兑换次数
end

function SCZhuanShengAllInfo:Decode()
	self.zhuansheng_equip_list = {}
	for i=0, GameEnum.ZHUANSHENG_EQUIP_TYPE_MAX -1 do
		self.zhuansheng_equip_list[i] = ProtocolStruct.ReadItemDataWrapper()
	end
	self.last_time_free_chou_timestamp = MsgAdapter.ReadUInt()
	self.personal_xiuwei = MsgAdapter.ReadInt()
	self.zhuansheng_level = MsgAdapter.ReadShort()
	self.day_change_times = MsgAdapter.ReadShort()
end


SCZhuanShengOtherInfo = SCZhuanShengOtherInfo or BaseClass(BaseProtocolStruct)
function SCZhuanShengOtherInfo:__init()
	self.msg_type = 6977

	self.notice_reason = 0
	self.last_time_free_chou_timestamp = 0 				-- 上次免费抽时间戳
	self.personal_xiuwei = 0 							-- 个人修为
	self.zhuansheng_level = 0 							-- 当前转生等级
	self.day_change_times = 0 							-- 当天兑换次数
end

function SCZhuanShengOtherInfo:Decode()
	self.notice_reason = MsgAdapter.ReadInt()
	self.last_time_free_chou_timestamp = MsgAdapter.ReadUInt()
	self.personal_xiuwei = MsgAdapter.ReadInt()
	self.zhuansheng_level = MsgAdapter.ReadShort()
	self.day_change_times = MsgAdapter.ReadShort()
end

-- 神力值改变
SCZhuanShengXiuweiNotice = SCZhuanShengXiuweiNotice or BaseClass(BaseProtocolStruct)
function SCZhuanShengXiuweiNotice:__init()
	self.msg_type = 6980
end

function SCZhuanShengXiuweiNotice:Decode()
	self.notice_reason = MsgAdapter.ReadInt()
	self.add_xiuwei = MsgAdapter.ReadInt()
end

---------------------------------------飞仙装备---------------------------------------------

--------------------------------------- 新转生装备--------------------------------------------
-- 转生操作请求
CSRebirthOpearReq = CSRebirthOpearReq or BaseClass(BaseProtocolStruct)
function CSRebirthOpearReq:__init()
	self.msg_type = 6935

	self.opera_type = 0
	self.reserve_sh = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
end

function CSRebirthOpearReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
	MsgAdapter.WriteInt(self.param_4)
end

-- 转生装备信息
SCRebirthAllInfo = SCRebirthAllInfo or BaseClass(BaseProtocolStruct)
function SCRebirthAllInfo:__init()
	self.msg_type = 6936

	self.zhuansheng_level = 0 							-- 当前转生等级
	self.cur_bless = 0									-- 当前祝福值
	self.suit_activity_grade = 0 						-- 套装当前激活等级
	self.suit_opened_grade = 0 							-- 套装开启的等级
	self.inuse_equip_list = {}							-- 10个槽信息
end

function SCRebirthAllInfo:Decode()
	self.zhuansheng_level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.cur_bless = MsgAdapter.ReadInt()
	self.suit_activity_grade = MsgAdapter.ReadShort()
	self.suit_opened_grade = MsgAdapter.ReadShort()

	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do 	-- 装备部位类型
		local vo = {}
		vo.slot_flag = MsgAdapter.ReadShort()			-- 槽的标志位,0未加物品
		vo.prefix_type = MsgAdapter.ReadChar()			-- 前缀类型,0是无前缀
		MsgAdapter.ReadChar()

		vo.attr_base_param = {}							-- 装备的基本属性
		vo.attr_base_param.attr_base_type = MsgAdapter.ReadInt()
		vo.attr_base_param.attr_base_value = MsgAdapter.ReadInt()

		vo.attr_param = {}								-- 装备的随机属性
		for j = 1, GameEnum.ZHUANSHENGSYSTEM_ATTR_VALUE do
			local attr_vo = {}
			attr_vo.attr_type = MsgAdapter.ReadInt()
			attr_vo.attr_level = MsgAdapter.ReadInt()
			vo.attr_param[j] = attr_vo
		end

		vo.attr_xilian_param = {}						-- 装备的洗练出的属性
		for j = 1, GameEnum.ZHUANSHENGSYSTEM_ATTR_VALUE do
			local attr_xilian_vo = {}
			attr_xilian_vo.attr_type = MsgAdapter.ReadInt()
			attr_xilian_vo.attr_level = MsgAdapter.ReadInt()
			vo.attr_xilian_param[j] = attr_xilian_vo
		end
		
		self.inuse_equip_list[i] = vo
	end
end
--------------------------------------- 转生装备--------------------------------------------


--------------------------------符文系统----------------------------------
--请求操作
CSRuneSystemReq = CSRuneSystemReq or BaseClass(BaseProtocolStruct)
function CSRuneSystemReq:__init()
	self.msg_type = 6981
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
end

function CSRuneSystemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteShort(self.param4)
end

--获取符文列表数据
SCRuneSystemBagInfo = SCRuneSystemBagInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemBagInfo:__init()
	self.msg_type = 6982
end

function SCRuneSystemBagInfo:Decode()
	self.info_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.bag_list = {}
	for i = 1, count do
		local bag_info = {}
		bag_info.quality = MsgAdapter.ReadChar()
		bag_info.type = MsgAdapter.ReadChar()
		bag_info.level = MsgAdapter.ReadShort()
		bag_info.index = MsgAdapter.ReadInt()
		table.insert(self.bag_list, bag_info)
	end
end

--符文槽信息
SCRuneSystemRuneGridInfo = SCRuneSystemRuneGridInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemRuneGridInfo:__init()
	self.msg_type = 6983
	self.rune_grid = {}
	self.rune_grid_awaken = {}
end

function SCRuneSystemRuneGridInfo:Decode()
	self.rune_grid = {}
	for i = 1, GameEnum.RUNE_SYSTEM_SLOT_MAX_NUM do
		self.rune_grid[i] = {}
		self.rune_grid[i].quality = MsgAdapter.ReadChar()
		self.rune_grid[i].type = MsgAdapter.ReadChar()
		self.rune_grid[i].level = MsgAdapter.ReadShort()
	end
	self.rune_grid_awaken = {}
	for i = 1, GameEnum.RUNE_SYSTEM_SLOT_MAX_NUM do
		self.rune_grid_awaken[i] = {}
		self.rune_grid_awaken[i].maxhp = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].gongji = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].fangyu = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].ignore_fangyu = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].shanbi = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].baoji = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].jianren = MsgAdapter.ReadInt()
		self.rune_grid_awaken[i].add_per = MsgAdapter.ReadInt()
	end
end

--符文格奖励反馈
SCRuneSystemRuneGridAwakenInfo = SCRuneSystemRuneGridAwakenInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemRuneGridAwakenInfo:__init()
	self.msg_type = 6991
end

function SCRuneSystemRuneGridAwakenInfo:Decode()
	self.awaken_seq = MsgAdapter.ReadShort()
	self.is_need_recalc = MsgAdapter.ReadShort()
end

--符文其他信息
SCRuneSystemOtherInfo = SCRuneSystemOtherInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemOtherInfo:__init()
	self.msg_type = 6984

	self.pass_layer = 0                                 -- 层数
	self.rune_jinghua = 0								-- 精华
	self.rune_suipian = 0							    -- 碎片
	self.magic_crystal = 0								-- 魔晶
	self.suipian_list = {}								-- 寻宝获得碎片
	self.next_free_xunbao_timestamp = 0		 			-- 下次免费时间戳
	self.rune_slot_open_flag = 0						-- 符文槽开启标记 （0-7）  符文合成开启标记（15）
	self.free_xunbao_times = 0							-- 免费寻宝次数
	self.rune_awaken_times = 0							-- 符文觉醒次数
end

function SCRuneSystemOtherInfo:Decode()
	self.suipian_list ={}
	self.pass_layer = MsgAdapter.ReadInt()
	self.rune_jinghua = MsgAdapter.ReadInt()
	self.rune_suipian = MsgAdapter.ReadInt()
	self.magic_crystal = MsgAdapter.ReadInt()
	for i = 1, GameEnum.RUNE_SYSTEM_XUNBAO_RUNE_MAX_COUNT do
		self.suipian_list[i] = MsgAdapter.ReadChar()
	end
	MsgAdapter.ReadShort()
	self.next_free_xunbao_timestamp = MsgAdapter.ReadUInt()
	self.rune_slot_open_flag = MsgAdapter.ReadUShort()
	self.free_xunbao_times = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.rune_awaken_times = MsgAdapter.ReadInt()
end

--一键分解
CSRuneSystemDisposeOneKey = CSRuneSystemDisposeOneKey or BaseClass(BaseProtocolStruct)
function CSRuneSystemDisposeOneKey:__init()
	self.msg_type = 6989
	self.list_count = 0
	self.index_list = {}
end

function CSRuneSystemDisposeOneKey:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.list_count)
	for i = 1, self.list_count do
		local index = self.index_list[i] or -1
		MsgAdapter.WriteShort(index)
	end
end

--合成成功提示
SCRuneSystemComposeInfo = SCRuneSystemComposeInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemComposeInfo:__init()
	self.msg_type = 6990
end

function SCRuneSystemComposeInfo:Decode()
end

--符文塔扫荡
CSRuneTowerAutoFb = CSRuneTowerAutoFb or BaseClass(BaseProtocolStruct)
function CSRuneTowerAutoFb:__init()
	self.msg_type = 6992
end

function CSRuneTowerAutoFb:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 领取离线时间
CSRuneTowerFetchTime = CSRuneTowerFetchTime or BaseClass(BaseProtocolStruct)
function CSRuneTowerFetchTime:__init()
	self.msg_type = 6985
end

function CSRuneTowerFetchTime:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 挂机塔信息
SCRuneTowerInfo = SCRuneTowerInfo or BaseClass(BaseProtocolStruct)
function SCRuneTowerInfo:__init()
	self.msg_type = 6986

	self.pass_layer = 0
	self.fb_today_layer = 0
	self.offline_time = 0
	self.add_exp = 0
	self.add_jinghua = 0
	self.add_equip_blue = 0
	self.add_equip_orange = 0
	self.fetch_time_count = 0
end

function SCRuneTowerInfo:Decode()
	self.pass_layer = MsgAdapter.ReadInt()
	self.fb_today_layer = MsgAdapter.ReadInt()
	self.offline_time = MsgAdapter.ReadInt()
	self.add_exp = MsgAdapter.ReadLL()
	self.add_jinghua = MsgAdapter.ReadInt()
	self.add_equip_blue = MsgAdapter.ReadInt()
	self.add_equip_purple = MsgAdapter.ReadInt()
	self.add_equip_orange = MsgAdapter.ReadInt()
	self.fetch_time_count = MsgAdapter.ReadInt()
end

-- 挂机塔离线挂机信息
SCRuneTowerOfflineInfo = SCRuneTowerOfflineInfo or BaseClass(BaseProtocolStruct)
function SCRuneTowerOfflineInfo:__init()
	self.msg_type = 6988

	self.fb_offline_time = 0
	self.guaji_time = 0
	self.kill_monster_num = 0
	self.old_level = 0
	self.new_level = 0
	self.add_exp = 0
	self.add_jinghua = 0
	self.add_equip_blue = 0
	self.add_equip_purple = 0
	self.add_equip_orange = 0
	self.add_mojing = 0
	self.recycl_equip_blue = 0
	self.recycl_equip_purple = 0
	self.recycl_equip_orange = 0
end

function SCRuneTowerOfflineInfo:Decode()
	self.fb_offline_time = MsgAdapter.ReadInt()
	self.guaji_time = MsgAdapter.ReadInt()
	self.kill_monster_num = MsgAdapter.ReadInt()
	self.old_level = MsgAdapter.ReadInt()
	self.new_level = MsgAdapter.ReadInt()
	self.add_exp = MsgAdapter.ReadLL()
	self.add_jinghua = MsgAdapter.ReadInt()
	self.add_equip_blue = MsgAdapter.ReadInt()
	self.add_equip_purple = MsgAdapter.ReadInt()
	self.add_equip_orange = MsgAdapter.ReadInt()
	self.add_mojing = MsgAdapter.ReadInt()
	self.recycl_equip_blue = MsgAdapter.ReadInt()
	self.recycl_equip_purple = MsgAdapter.ReadInt()
	self.recycl_equip_orange = MsgAdapter.ReadInt()
end

-- 符文塔扫荡奖励
SCRuneTowerAutoReward = SCRuneTowerAutoReward or BaseClass(BaseProtocolStruct)
function SCRuneTowerAutoReward:__init()
	self.msg_type = 6993
	self.reward_jinghua = 0
	self.item_list = {}
end

function SCRuneTowerAutoReward:Decode()
	self.reward_jinghua = MsgAdapter.ReadInt()
	local item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num =  MsgAdapter.ReadShort()
		self.item_list[i] = vo
	end
end

-- 世界boss掉落记录
SCWorldBossDropRecord = SCWorldBossDropRecord or BaseClass(BaseProtocolStruct)
function SCWorldBossDropRecord:__init()
	self.msg_type = 6994
	self.count = 0
	self.drop_record = {}
end

function SCWorldBossDropRecord:Decode()
	self.count = MsgAdapter.ReadInt()
	self.drop_record = {}
	
	for i = 1, self.count do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt() -- 拥有着
		vo.name = MsgAdapter.ReadStrN(32)
		vo.scene_id = MsgAdapter.ReadInt()
		vo.monster_id = MsgAdapter.ReadUShort()
		vo.item_id = MsgAdapter.ReadUShort()
		vo.drop_timestamp = MsgAdapter.ReadUInt()

		self.drop_record[i] = vo
	end
end

-- 红装收集
SCRedEquipCollect = SCRedEquipCollect or BaseClass(BaseProtocolStruct)
function SCRedEquipCollect:__init()
	self.msg_type = 6995
	self.seq = 0
	self.equip_slot = {}
end

function SCRedEquipCollect:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.equip_slot = {}
	for i = 1, 10 do
		local itemdata = ProtocolStruct.ReadItemDataWrapper()
		self.equip_slot[i] = itemdata
	end
end

-- 红装收集-其他信息
SCRedEquipCollectOther = SCRedEquipCollectOther or BaseClass(BaseProtocolStruct)
function SCRedEquipCollectOther:__init()
	self.msg_type = 6996
	self.seq_active_flag = 0
	self.collect_count = 0
	self.act_reward_can_fetch_flag = 0
	self.stars_info = {}
end

function SCRedEquipCollectOther:Decode()
	self.info = {}
	self.seq_active_flag = MsgAdapter.ReadUInt()					-- 套装激活标记（已激活才可穿戴）
	self.collect_count = MsgAdapter.ReadInt()						-- 已集齐的套装数
	self.act_reward_can_fetch_flag = MsgAdapter.ReadUInt()			-- 开服活动可领取标记
	for i=0,17 do
		local vo = {}
		vo.item_count = MsgAdapter.ReadInt()
		vo.stars = MsgAdapter.ReadInt()
		self.stars_info[i] = vo
	end
end

-- 怪物攻城信息
SCMonsterSiegeInfo = SCMonsterSiegeInfo or BaseClass(BaseProtocolStruct)
function SCMonsterSiegeInfo:__init()
	self.msg_type = 6997
	self.monster_siege_camp = 0
	self.monster_siege_tower_build_flag = 0
	self.is_pass = 0
	self.act_status = 0
	self.act_next_status_change_time = 0
	self.camp_level_up_last_time = 0
end

function SCMonsterSiegeInfo:Decode()
	self.monster_siege_camp = MsgAdapter.ReadInt()					-- 参与怪物攻城活动的国家
	self.monster_siege_tower_build_flag = MsgAdapter.ReadUInt()		-- 怪物攻城箭塔建设标记
	self.is_pass = MsgAdapter.ReadInt()								-- 副本是否已通关
	self.act_status = MsgAdapter.ReadInt()							-- 活动状态
	self.act_next_status_change_time = MsgAdapter.ReadUInt() 		-- 活动状态下一次改变的时间
	self.camp_level_up_last_time = MsgAdapter.ReadUInt() 			-- 国家升级剩余时间
end

-- 怪物攻城副本信息
SCMonsterSiegeFbInfo = SCMonsterSiegeFbInfo or BaseClass(BaseProtocolStruct)
function SCMonsterSiegeFbInfo:__init()
	self.msg_type = 6998
	self.is_finish = 0
	self.is_pass = 0
	self.statues_objid = 0
	self.defend_camp = 0
	self.created_attack_monster_count = 0
	self.cur_attack_monster_count = 0
	self.statues_hp_percent = 0
	self.cur_tower_count = 0
end

function SCMonsterSiegeFbInfo:Decode()
	self.is_finish = MsgAdapter.ReadInt()							-- 是否已结束
	self.is_pass = MsgAdapter.ReadInt() 							-- 是否胜利
	self.statues_objid = MsgAdapter.ReadUShort()					-- 雕像ObjID
	self.defend_camp = MsgAdapter.ReadShort()						-- 防守方国家
	self.created_attack_monster_count = MsgAdapter.ReadInt()		-- 已创建的攻击怪物的数量
	self.cur_attack_monster_count = MsgAdapter.ReadInt()			-- 当前攻击怪的数量
	self.statues_hp_percent = MsgAdapter.ReadInt()					-- 雕像剩余血量
	self.cur_tower_count = MsgAdapter.ReadInt()						-- 当前的防御塔数量
end

-- 跨服召集信息
SCCrossCall = SCCrossCall or BaseClass(BaseProtocolStruct)
function SCCrossCall:__init()
	self.msg_type = 6999
	self.call_info = {}		-- 召集者信息
end

function SCCrossCall:Decode()
	self.call_info = {}
	self.call_info.call_type = MsgAdapter.ReadInt()
	self.call_info.origin_server_role_id = MsgAdapter.ReadInt()
	self.call_info.name = MsgAdapter.ReadStrN(32)
	self.call_info.post = MsgAdapter.ReadShort()
	self.call_info.camp = MsgAdapter.ReadShort()
	self.call_info.guild_id = MsgAdapter.ReadInt()
	self.call_info.activity_type = MsgAdapter.ReadInt()
	self.call_info.scene_id = MsgAdapter.ReadInt()
	self.call_info.scene_key = MsgAdapter.ReadInt()
	self.call_info.x = MsgAdapter.ReadInt()
	self.call_info.y = MsgAdapter.ReadInt()
	self.call_info.param = MsgAdapter.ReadInt()
end