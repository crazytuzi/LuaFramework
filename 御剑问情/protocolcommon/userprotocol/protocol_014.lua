--返回角色信息
SCRoleInfoAck = SCRoleInfoAck or BaseClass(BaseProtocolStruct)
function SCRoleInfoAck:__init()
	self.msg_type = 1400
end

function SCRoleInfoAck:Decode()
	self.attr_t = {}
	self.attr_t.sex = MsgAdapter.ReadChar()
	self.attr_t.prof = MsgAdapter.ReadChar()
	self.attr_t.camp = MsgAdapter.ReadChar()
	self.attr_t.authority_type = MsgAdapter.ReadChar()						-- 身份类型，待定
	self.attr_t.level = MsgAdapter.ReadShort()
	self.attr_t.energy = MsgAdapter.ReadShort()

	self.attr_t.hp = MsgAdapter.ReadInt()
	self.attr_t.base_max_hp = MsgAdapter.ReadInt()
	self.attr_t.mp = MsgAdapter.ReadInt()
	self.attr_t.base_max_mp = MsgAdapter.ReadInt()

	self.attr_t.base_gongji = MsgAdapter.ReadInt()							-- 基础攻击
	self.attr_t.base_fangyu = MsgAdapter.ReadInt()							-- 基础防御
	self.attr_t.base_mingzhong = MsgAdapter.ReadInt()						-- 基础命中
	self.attr_t.base_shanbi = MsgAdapter.ReadInt()							-- 基础闪避
	self.attr_t.base_baoji = MsgAdapter.ReadInt()							-- 基础暴击
	self.attr_t.base_jianren = MsgAdapter.ReadInt()							-- 基础坚韧
	self.attr_t.base_move_speed = MsgAdapter.ReadInt()						-- 基础移动速度
	self.attr_t.base_fujia_shanghai = MsgAdapter.ReadInt()
	self.attr_t.base_dikang_shanghai = MsgAdapter.ReadInt()
	self.attr_t.base_per_jingzhun = MsgAdapter.ReadInt()
	self.attr_t.base_per_baoji = MsgAdapter.ReadInt()
	self.attr_t.base_per_kangbao = MsgAdapter.ReadInt()
	self.attr_t.base_per_pofang = MsgAdapter.ReadInt()
	self.attr_t.base_per_mianshang = MsgAdapter.ReadInt()
	self.attr_t.base_constant_zengshang = MsgAdapter.ReadInt()
	self.attr_t.base_constant_mianshang = MsgAdapter.ReadInt()

	self.attr_t.exp = MsgAdapter.ReadLL()									-- 经验
	self.attr_t.max_exp = MsgAdapter.ReadLL()								-- 最大经验
	self.attr_t.attack_mode = MsgAdapter.ReadChar()							-- 攻击模式
	self.attr_t.name_color = MsgAdapter.ReadChar()							-- 名字颜色
	self.attr_t.move_mode = MsgAdapter.ReadChar()							-- 运动模式
	self.attr_t.move_mode_param = MsgAdapter.ReadChar()						-- 运动模式参数
	self.attr_t.xiannv_huanhua_id =	MsgAdapter.ReadShort()					-- 仙女幻化id
	self.attr_t.jump_remain_times = MsgAdapter.ReadShort()					-- 跳跃剩余次数
	self.attr_t.jump_last_recover_time = MsgAdapter.ReadUInt()				-- 最后恢复跳跃时间
	self.attr_t.capability = MsgAdapter.ReadInt()							-- 战斗力

	self.attr_t.buff_mark_low = MsgAdapter.ReadInt()						-- buff效果标记低位
	self.attr_t.buff_mark_high = MsgAdapter.ReadInt()						-- buff效果标记高位

	self.attr_t.evil = MsgAdapter.ReadInt()									-- 罪恶值
	self.attr_t.xianhun = MsgAdapter.ReadInt()								-- 仙魂
	self.attr_t.yuanli = MsgAdapter.ReadInt()								-- 元力
	self.attr_t.nv_wa_shi = MsgAdapter.ReadInt()							-- 女娲石
	self.attr_t.lingjing = MsgAdapter.ReadInt()								-- 灵晶
	self.attr_t.chengjiu = MsgAdapter.ReadInt()								-- 成就
	self.attr_t.hunli = MsgAdapter.ReadInt()								-- 粉尘
	self.attr_t.guanghui = MsgAdapter.ReadInt()								-- 光辉

	self.attr_t.guild_id = MsgAdapter.ReadInt()								-- 军团ID
	self.attr_t.guild_name = MsgAdapter.ReadStrN(32)						-- 军团名字
	self.attr_t.last_leave_guild_time = MsgAdapter.ReadUInt()				-- 最后离开军团时间
	self.attr_t.guild_post = MsgAdapter.ReadChar()							-- 军团职位
	self.attr_t.is_team_leader = MsgAdapter.ReadChar()						-- 组队队长标志
	self.attr_t.mount_appeid = MsgAdapter.ReadShort()						-- 坐骑外观

	self.attr_t.husong_color = MsgAdapter.ReadChar()						-- 护送任务颜色
	self.attr_t.is_change_avatar = MsgAdapter.ReadChar()					-- 是否换过头像
	self.attr_t.husong_taskid = MsgAdapter.ReadUShort()						-- 护送任务ID

	self.attr_t.nuqi = MsgAdapter.ReadInt()									-- 怒气
	self.attr_t.honour = MsgAdapter.ReadInt()								-- 荣誉

	self.attr_t.guild_gongxian = MsgAdapter.ReadInt()						-- 贡献
	self.attr_t.guild_total_gongxian = MsgAdapter.ReadInt()					-- 总贡献

	self.attr_t.max_hp = MsgAdapter.ReadInt()
	self.attr_t.max_mp = MsgAdapter.ReadInt()
	self.attr_t.gong_ji = MsgAdapter.ReadInt()
	self.attr_t.fang_yu = MsgAdapter.ReadInt()
	self.attr_t.ming_zhong = MsgAdapter.ReadInt()
	self.attr_t.shan_bi = MsgAdapter.ReadInt()
	self.attr_t.bao_ji = MsgAdapter.ReadInt()
	self.attr_t.jian_ren = MsgAdapter.ReadInt()
	self.attr_t.move_speed = MsgAdapter.ReadInt()
	self.attr_t.fujia_shanghai = MsgAdapter.ReadInt()
	self.attr_t.dikang_shanghai = MsgAdapter.ReadInt()
	self.attr_t.per_jingzhun = MsgAdapter.ReadInt()
	self.attr_t.per_baoji = MsgAdapter.ReadInt()
	self.attr_t.per_kangbao = MsgAdapter.ReadInt()
	self.attr_t.per_pofang = MsgAdapter.ReadInt()
	self.attr_t.per_mianshang = MsgAdapter.ReadInt()
	self.attr_t.constant_zengshang = MsgAdapter.ReadInt()
	self.attr_t.constant_mianshang = MsgAdapter.ReadInt()

	self.attr_t.appearance = ProtocolStruct.ReadRoleAppearance()			-- 外观
	self.attr_t.used_sprite_grade = MsgAdapter.ReadChar()					-- 仙女神交等级
	self.attr_t.used_sprite_quality = MsgAdapter.ReadChar()					-- 仙女品质等级
	self.attr_t.flyup_use_image = MsgAdapter.ReadShort()
	self.attr_t.chengjiu_title_level = MsgAdapter.ReadShort()				-- 仙女缠绵等级
	self.attr_t.used_sprite_id = MsgAdapter.ReadUShort()					-- 仙女id
	self.attr_t.sprite_name = MsgAdapter.ReadStrN(32)						-- 仙女名字

	self.attr_t.shengwang = MsgAdapter.ReadInt()							-- 声望
	self.attr_t.avatar_key_big = MsgAdapter.ReadUInt()						-- 大头像
	self.attr_t.avatar_key_small = MsgAdapter.ReadUInt()					-- 小头像
	self.attr_t.lover_uid = MsgAdapter.ReadInt()							-- 伴侣uid
	self.attr_t.lover_name = MsgAdapter.ReadStrN(32)						-- 伴侣名字
	self.attr_t.last_marry_time = MsgAdapter.ReadUInt()						-- 上次结婚时间
	self.attr_t.use_sprite_halo_img = MsgAdapter.ReadShort()				-- 仙女光环形象
	self.attr_t.used_sprite_jie = MsgAdapter.ReadShort()					-- 使用仙女的阶数
	self.attr_t.xianjie_level = MsgAdapter.ReadShort()
	self.attr_t.day_revival_times = MsgAdapter.ReadUShort()					-- 当日复活次数
	self.attr_t.cross_honor = MsgAdapter.ReadInt()							-- 跨服荣誉
	self.attr_t.plat_type = MsgAdapter.ReadInt()							-- 平台类型

	self.attr_t.jinghua_husong_status = MsgAdapter.ReadChar()				-- 精华护送状态
	self.attr_t.use_sprite_imageid = MsgAdapter.ReadChar()					-- 精灵飞升形象
	self.attr_t.user_pet_special_img = MsgAdapter.ReadShort()
	self.attr_t.gongxun = MsgAdapter.ReadInt()								-- 功勋

	self.attr_t.pet_id = MsgAdapter.ReadInt()								-- 宠物ID
	self.attr_t.pet_level = MsgAdapter.ReadShort()							-- 宠物等级
	self.attr_t.pet_grade = MsgAdapter.ReadShort()							-- 宠物阶级
	self.attr_t.pet_name = MsgAdapter.ReadStrN(32)							-- 宠物名字
	self.attr_t.user_lq_special_img = MsgAdapter.ReadShort()				-- 宠物特殊形象

	self.attr_t.use_xiannv_halo_img = MsgAdapter.ReadShort()				-- 精灵光环形象
	self.attr_t.multi_mount_res_id = MsgAdapter.ReadInt()					-- 双人坐骑ID
	self.attr_t.multi_mount_is_owner = MsgAdapter.ReadInt()					-- 是否是双人坐骑的主人
	self.attr_t.multi_mount_other_uid = MsgAdapter.ReadInt()				-- 一起骑乘的玩家obj_id

	self.little_pet_name = MsgAdapter.ReadStrN(32) 							--小宠物名字
	self.attr_t.little_pet_using_id = MsgAdapter.ReadShort()				--小宠物形象id

	self.attr_t.fight_mount_appeid = MsgAdapter.ReadShort()					-- 战斗坐骑外观
	self.attr_t.wuqi_color = MsgAdapter.ReadShort()							-- 武器颜色
	self.attr_t.touxian = MsgAdapter.ReadShort()							-- 头衔等级

	self.baojia_specical_texiao_id = MsgAdapter.ReadShort()					--穿戴宝甲
	self.attr_t.lingzhu_use_imageid = MsgAdapter.ReadShort()				--灵珠
	self.attr_t.lingchong_used_imageid = MsgAdapter.ReadShort()				--灵宠
	self.attr_t.linggong_used_imageid = MsgAdapter.ReadShort()				--灵弓
	self.attr_t.lingqi_used_imageid = MsgAdapter.ReadShort()				--灵骑
	MsgAdapter.ReadShort()

	self.attr_t.sup_baby_id = MsgAdapter.ReadShort()						--超级宝宝id
	MsgAdapter.ReadShort()
	self.attr_t.sup_baby_name = MsgAdapter.ReadStrN(32)						--超级宝宝名字
end

-- 角色属性
SCRoleAttributeValue = SCRoleAttributeValue or BaseClass(BaseProtocolStruct)
function SCRoleAttributeValue:__init()
	self.msg_type = 1402
end

function SCRoleAttributeValue:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.count = MsgAdapter.ReadUChar()
	self.attr_notify_reason = MsgAdapter.ReadUChar()

	self.attr_pair_list = {}
	for i = 1, self.count do
		self.attr_pair_list[i] = {
			attr_type = MsgAdapter.ReadInt(),
			attr_value = MsgAdapter.ReadInt(),
		}
	end
end

-- 经验变更
SCChaExpChange = SCChaExpChange or BaseClass(BaseProtocolStruct)
function SCChaExpChange:__init()
	self.msg_type = 1403
end

function SCChaExpChange:Decode()
	self.reason = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.exp = MsgAdapter.ReadLL()
	self.delta = MsgAdapter.ReadLL()
	self.add_percent = MsgAdapter.ReadInt()
end

--角色等级变更
SCLevelChange = SCLevelChange or BaseClass(BaseProtocolStruct)
function SCLevelChange:__init()
	self.msg_type = 1404
end

function SCLevelChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.level = MsgAdapter.ReadShort()
	self.exp = MsgAdapter.ReadLL()
	self.max_exp = MsgAdapter.ReadLL()
end

--角色转职广播
SCRoleChangeProf = SCRoleChangeProf or BaseClass(BaseProtocolStruct)
function SCRoleChangeProf:__init()
	self.msg_type = 1405
end

function SCRoleChangeProf:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.prof = MsgAdapter.ReadShort()
	self.max_hp = MsgAdapter.ReadInt()
end

--阵营变更
SCRoleAddCamp = SCRoleAddCamp or BaseClass(BaseProtocolStruct)
function SCRoleAddCamp:__init()
	self.msg_type = 1406
end

function SCRoleAddCamp:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end

--角色名字颜色改变
SCRoleNameColorChange = SCRoleNameColorChange or BaseClass(BaseProtocolStruct)
function SCRoleNameColorChange:__init()
	self.msg_type = 1408
end

function SCRoleNameColorChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.name_color = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end

--罪恶值值改变
SCRoleEvilChange = SCRoleEvilChange or BaseClass(BaseProtocolStruct)
function SCRoleEvilChange:__init()
	self.msg_type = 1410
end

function SCRoleEvilChange:Decode()
	self.evil = MsgAdapter.ReadInt()
end

--战斗力变化
SCCapabilityChange = SCCapabilityChange or BaseClass(BaseProtocolStruct)
function SCCapabilityChange:__init()
	self.msg_type = 1414
end

function SCCapabilityChange:Decode()
	self.capability = MsgAdapter.ReadInt()
	self.other_capability = MsgAdapter.ReadInt()
	self.capability_list = {}
	for i = 0, CAPABILITY_TYPE.CAPABILITY_TYPE_MAX - 1 do
		self.capability_list[i] = MsgAdapter.ReadInt()
	end
end

--请求所有模块战力值
CSGetRoleCapability = CSGetRoleCapability or BaseClass(BaseProtocolStruct)
function CSGetRoleCapability:__init()
	self.msg_type = 1459
end

function CSGetRoleCapability:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--查看角色信息请求
CSQueryRoleInfo = CSQueryRoleInfo or BaseClass(BaseProtocolStruct)
function CSQueryRoleInfo:__init()
	self.msg_type = 1455
	self.target_uid = 0
end

function CSQueryRoleInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
end

---------------------------------------------------------------------------
local function LoadEquipInfo()
	local t = {}
	t.equip_id = MsgAdapter.ReadUShort()
	t.level = MsgAdapter.ReadShort()
	t.attr_list = {}
	for i=0,2 do
		t.attr_list[i] = MsgAdapter.ReadInt()
	end
	return t
end

local function LoadEquipmentInfo()
	local t = {}
	t.equip_id = MsgAdapter.ReadUShort()
	t.star_level = MsgAdapter.ReadUChar()
	t.has_lucky = MsgAdapter.ReadChar()

	t.quality = MsgAdapter.ReadShort()
	t.reserve_2 = MsgAdapter.ReadShort()
	t.reserve_3 = MsgAdapter.ReadShort()
	t.fuling_level = MsgAdapter.ReadShort()

	t.strengthen_level = MsgAdapter.ReadShort()		--格子强化等级
	t.shen_level = MsgAdapter.ReadShort()			--格子神铸等级
	t.star_level = MsgAdapter.ReadShort()			--格子星星等级
	MsgAdapter.ReadShort()
	t.eternity_level = MsgAdapter.ReadShort()		--格子永恒等级
	MsgAdapter.ReadShort()

	t.xianpin_type_list = {}
	for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
		local xianpin_type = MsgAdapter.ReadUShort()
		if xianpin_type > 0 then
			table.insert(t.xianpin_type_list, xianpin_type)
		end
	end
	return t
end

local function LoadShizhuangPart()
	local t = {}
	t.use_index = MsgAdapter.ReadChar()
	t.reserve_ch = MsgAdapter.ReadChar()
	t.reserve_sh = MsgAdapter.ReadShort()
	t.active_flag = MsgAdapter.ReadInt()
	t.active_flag2 = MsgAdapter.ReadInt()
	return t
end

local function LoadXiannvBaseInfo()
	local t = {}
	t.xn_level = MsgAdapter.ReadShort()
	t.xn_zizhi = MsgAdapter.ReadShort()
	return t
end

local MAX_XIANNV_HUANHUA_COUNT = 64
local MAX_XIANNV_COUNT = 7
local MAX_XIANNV_POS = 4

local function LoadXiannvInfo()
	local t = {}
	t.active_xiannv_flag = MsgAdapter.ReadShort()
	t.huanhua_id = MsgAdapter.ReadShort()
	t.active_huanhua_flag = MsgAdapter.ReadLL()
	t.xiannv_huanhua_level = {}
	for i=0, MAX_XIANNV_HUANHUA_COUNT -1 do
		t.xiannv_huanhua_level[i] = MsgAdapter.ReadInt()
	end
	t.xiannv_item_list = {}
	for i=0,MAX_XIANNV_COUNT - 1 do
		t.xiannv_item_list[i] = LoadXiannvBaseInfo()
	end
	t.pos_list = {}
	for i=1,MAX_XIANNV_POS do
		t.pos_list[i] = MsgAdapter.ReadChar()
	end
	t.xiannv_name = MsgAdapter.ReadStrN(32)
	return t
end

local JINGLING_MAX_TAKEON_NUM = 4
local MAX_XIANPIN_NUM = 6
local JINGLING_PTHANTOM_MAX_TYPE = 10
local function LoadJingLingBaseInfo()
	local t = {}
	t.jingling_id = MsgAdapter.ReadShort()
	t.jingling_level = MsgAdapter.ReadShort()

	t.is_bind = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	t.talent_list = {}
	for i=1, MAX_XIANPIN_NUM do
		t.talent_list[i] = MsgAdapter.ReadShort()
	end
	return t
end

local function LoadJinglingInfo()
	local t = {}
	t.jingling_item_list = {}
	for i=1,JINGLING_MAX_TAKEON_NUM do
		t.jingling_item_list[i] = LoadJingLingBaseInfo() --精灵信息
	end
	t.phantom_level_list = {}
	for i=1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE do
		table.insert(t.phantom_level_list, MsgAdapter.ReadShort())		--幻化等级
	end
	t.use_jingling_id = MsgAdapter.ReadShort()			--出战精灵id
	MsgAdapter.ReadShort()
	t.phantom_image_flag_low = MsgAdapter.ReadUInt()		--幻化激活标记（低）
	t.phantom_image_flag_hight = MsgAdapter.ReadUInt()		--幻化激活标记（高）
	t.phantom_imgageid = MsgAdapter.ReadInt()			--使用的幻化id
	for i=1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE_NEW do
		table.insert(t.phantom_level_list, MsgAdapter.ReadShort())		--新增幻化等级
	end
	for i=1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE_NEW_2 do
		table.insert(t.phantom_level_list, MsgAdapter.ReadShort())		--新增幻化等级
	end
	return t
end

local function LoadStoneItem()
	local t = {}
	t.stone_id = MsgAdapter.ReadInt()
	t.reserve = MsgAdapter.ReadShort()
	t.reserve2 = MsgAdapter.ReadShort()
	return t
end

local MAX_STONE_COUNT = 5
local function LoadStonesOnPart()
	local t = {}
	for i=0,MAX_STONE_COUNT - 1 do
		t[i] = LoadStoneItem()
	end
	return t
end

local MAX_STONE_EQUIP_PART = 10
local function LoadStoneParam()
	local t = {}
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	for i=0, MAX_STONE_EQUIP_PART - 1 do
		t[i] = LoadStonesOnPart()
	end
	return t
end

local LIEMING_FUHUN_SLOT_COUNT = 10
local function LoadLieMingInfo()
	local t = {}
	t.hunshou_id = MsgAdapter.ReadShort()
	t.level = MsgAdapter.ReadShort()
	t.curr_exp = MsgAdapter.ReadLL()
	return t
end

local function LoadFootInfo()
	local t = {}
	t.level = MsgAdapter.ReadShort()
	t.grade = MsgAdapter.ReadShort()
	t.used_imageid = MsgAdapter.ReadShort()
	t.shuxingdan_count = MsgAdapter.ReadShort()
	t.chengzhangdan_count = MsgAdapter.ReadShort()
	t.star_level = MsgAdapter.ReadShort()
	t.active_special_image_flag = MsgAdapter.ReadUInt()
	t.active_special_image_flag2 = MsgAdapter.ReadUInt()
	t.equip_skill_level = MsgAdapter.ReadInt()
	t.capability = MsgAdapter.ReadInt()
	t.equip_level_list = {}
	t.skill_level_list = {}

	for i=0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		t.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	for i=0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		t.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	return t
end

local function LoadCloakInfo()
	local t = {}
	t.level = MsgAdapter.ReadInt()
	t.used_imageid = MsgAdapter.ReadInt()
	t.shuxingdan_count = MsgAdapter.ReadInt()
	t.active_special_image_flag = MsgAdapter.ReadInt()
	t.equip_skill_level = MsgAdapter.ReadInt()
	t.capability = MsgAdapter.ReadInt()
	t.equip_level_list = {}
	t.skill_level_list = {}

	for i=0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		t.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	for i=0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		t.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	return t
end

-- ranktag
--查询玩家信息返回
SCGetRoleBaseInfoAck = SCGetRoleBaseInfoAck or BaseClass(BaseProtocolStruct)
function SCGetRoleBaseInfoAck:__init()
	self.msg_type = 1412
end

function SCGetRoleBaseInfoAck:Decode()
	self.role_id = MsgAdapter.ReadInt() 						--角色ID
	self.role_name = MsgAdapter.ReadStrN(32)					--角色名字
	self.level = MsgAdapter.ReadShort()							--等级
	self.reserve_ch = MsgAdapter.ReadChar()						--平台类型
	self.sex = MsgAdapter.ReadChar()							--性别
	self.camp_id = MsgAdapter.ReadChar()						--阵营
	self.prof = MsgAdapter.ReadChar()							--职业
	self.vip_level = MsgAdapter.ReadChar()						--VIP等级
	self.guild_post = MsgAdapter.ReadChar()						--军团职位

	self.plat_type = MsgAdapter.ReadInt()						--平台类型
	self.plat_name = MsgAdapter.ReadStrN(64)					--平台名
	self.guild_id = MsgAdapter.ReadInt()						--公会ID
	self.guild_name = MsgAdapter.ReadStrN(32)					--公会名字

	-- self.avatar_timestamp = MsgAdapter.ReadLL()				--头像更新时间戳
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()

	self.lover_uid = MsgAdapter.ReadInt()						--伴侣uid
	self.lover_name = MsgAdapter.ReadStrN(32)					--伴侣名字
	self.qingyuan_value = MsgAdapter.ReadInt()					--情缘值
	self.qingyuan_equip_id = MsgAdapter.ReadUShort()			--情缘装备id
	self.qingyuan_equip_star_level = MsgAdapter.ReadShort()		--情缘装备等级

	self.lover_prof = MsgAdapter.ReadChar()						--伴侣职业
	self.lover_sex = MsgAdapter.ReadChar()						--伴侣性别
	self.lover_camp = MsgAdapter.ReadChar()						--伴侣阵营
	self.lover_vip_level = MsgAdapter.ReadChar()				--伴侣VIP等级

	-- self.lover_avatar_timestamp = MsgAdapter.ReadLL()			--伴侣大头像
	self.lover_avatar_key_big = MsgAdapter.ReadUInt()
	self.lover_avatar_key_small = MsgAdapter.ReadUInt()


	self.lover_level = MsgAdapter.ReadShort()					--伴侣等级
	self.name_color = MsgAdapter.ReadShort()					--名字颜色

	self.evil_val = MsgAdapter.ReadInt()						--罪恶值
	self.all_charm = MsgAdapter.ReadInt()						--魅力
	self.capability = MsgAdapter.ReadInt()						--战斗力
	self.hp = MsgAdapter.ReadInt()								--血量
	self.max_hp = MsgAdapter.ReadInt()							--最大血量
	self.gongji = MsgAdapter.ReadInt()							--攻击
	self.fangyu = MsgAdapter.ReadInt()							--防御
	self.mingzhong = MsgAdapter.ReadInt()						--命中
	self.shanbi = MsgAdapter.ReadInt()							--闪避
	self.baoji = MsgAdapter.ReadInt()							--暴击
	self.jianren = MsgAdapter.ReadInt()							--坚韧
	self.fujia_shanghai = MsgAdapter.ReadInt()					--附加伤害
	self.dikang_shanghai = MsgAdapter.ReadInt()					--抵抗伤
	self.per_jingzhun = MsgAdapter.ReadInt()					--精准
	self.per_baoji = MsgAdapter.ReadInt()						--暴击
	self.per_kangbao = MsgAdapter.ReadInt()						--抗暴
	self.per_pofang = MsgAdapter.ReadInt()						--破防百分比
	self.per_mianshang = MsgAdapter.ReadInt()					--免伤百分比
	self.constant_zengshang = MsgAdapter.ReadInt()				--固定增伤
	self.constant_mianshang = MsgAdapter.ReadInt()				--固定免伤

	self.mount_info = {}
	self.mount_info.level = MsgAdapter.ReadShort()
	self.mount_info.grade = MsgAdapter.ReadShort()
	self.mount_info.used_imageid = MsgAdapter.ReadShort()
	self.mount_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.mount_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.mount_info.star_level = MsgAdapter.ReadShort()
	self.mount_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.mount_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.mount_info.equip_skill_level = MsgAdapter.ReadInt()
	self.mount_info.capability = MsgAdapter.ReadInt()
	self.mount_info.equip_info_list = {}
	self.mount_info.skill_level_list = {}
	for i=0,3 do
		self.mount_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.mount_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.wing_info = {}
	self.wing_info.level = MsgAdapter.ReadShort()
	self.wing_info.grade = MsgAdapter.ReadShort()
	self.wing_info.used_imageid = MsgAdapter.ReadShort()
	self.wing_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.wing_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.wing_info.star_level = MsgAdapter.ReadShort()
	self.wing_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.wing_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.wing_info.equip_skill_level = MsgAdapter.ReadInt()
	self.wing_info.capability = MsgAdapter.ReadInt()

	self.wing_info.equip_info_list = {}
	self.wing_info.skill_level_list = {}
	for i=0,3 do
		self.wing_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.wing_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.halo_info = {}
	self.halo_info.level = MsgAdapter.ReadShort()
	self.halo_info.grade = MsgAdapter.ReadShort()
	self.halo_info.used_imageid = MsgAdapter.ReadShort()
	self.halo_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.halo_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.halo_info.star_level = MsgAdapter.ReadShort()
	self.halo_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.halo_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.halo_info.equip_skill_level = MsgAdapter.ReadInt()
	self.halo_info.capability = MsgAdapter.ReadInt()

	self.halo_info.equip_info_list = {}
	self.halo_info.skill_level_list = {}
	for i=0,3 do
		self.halo_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.halo_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.shengong_info = {}
	self.shengong_info.level = MsgAdapter.ReadShort()
	self.shengong_info.grade = MsgAdapter.ReadShort()
	self.shengong_info.used_imageid = MsgAdapter.ReadShort()
	self.shengong_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.shengong_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.shengong_info.star_level = MsgAdapter.ReadShort()
	self.shengong_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.shengong_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.shengong_info.equip_skill_level = MsgAdapter.ReadInt()
	self.shengong_info.capability = MsgAdapter.ReadInt()
	self.shengong_info.equip_info_list = {}
	self.shengong_info.skill_level_list = {}
	for i=0,3 do
		self.shengong_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.shengong_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.shenyi_info = {}
	self.shenyi_info.level = MsgAdapter.ReadShort()
	self.shenyi_info.grade = MsgAdapter.ReadShort()
	self.shenyi_info.used_imageid = MsgAdapter.ReadShort()
	self.shenyi_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.shenyi_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.shenyi_info.star_level = MsgAdapter.ReadShort()
	self.shenyi_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.shenyi_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.shenyi_info.equip_skill_level = MsgAdapter.ReadInt()
	self.shenyi_info.capability = MsgAdapter.ReadInt()
	self.shenyi_info.equip_info_list = {}
	self.shenyi_info.skill_level_list = {}
	for i=0,3 do
		self.shenyi_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.shenyi_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.equipment_info = {}
	for i=1,12 do
		self.equipment_info[i] = LoadEquipmentInfo()
	end

	self.shizhuang_part_list = {}
	for i=1,2 do
		self.shizhuang_part_list[i] = LoadShizhuangPart()
	end

	self.xiannv_shouhu_info = {}
	self.xiannv_shouhu_info.grade = MsgAdapter.ReadShort()
	self.xiannv_shouhu_info.used_imageid = MsgAdapter.ReadShort()

	-- self.huashen_shouhu_info = {}
	-- self.huashen_shouhu_info.grade = MsgAdapter.ReadShort()
	-- self.huashen_shouhu_info.used_imageid = MsgAdapter.ReadShort()

	self.spirit_fazhen_info = {}
	self.spirit_fazhen_info.grade = MsgAdapter.ReadShort()
	self.spirit_fazhen_info.used_imageid = MsgAdapter.ReadShort()

	self.spirit_halo_info = {}
	self.spirit_halo_info.grade = MsgAdapter.ReadShort()
	self.spirit_halo_info.used_imageid = MsgAdapter.ReadShort()

	self.baoju_info = {}
	self.baoju_info.level = MsgAdapter.ReadShort()
	self.baoju_info.used_imageid = MsgAdapter.ReadShort()

	self.fight_mount_info = {}
	-- self.fight_mount_info.mount_flag = MsgAdapter.ReadShort()
	-- MsgAdapter.ReadShort()
	self.fight_mount_info.mount_level = MsgAdapter.ReadShort()
	self.fight_mount_info.grade = MsgAdapter.ReadShort()
	-- self.fight_mount_info.grade_bless_val = MsgAdapter.ReadShort()
	self.fight_mount_info.used_imageid = MsgAdapter.ReadShort()
	self.fight_mount_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.fight_mount_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.fight_mount_info.star_level = MsgAdapter.ReadShort()
	self.fight_mount_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.fight_mount_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.fight_mount_info.equip_skill_level = MsgAdapter.ReadInt()
	self.fight_mount_info.capability = MsgAdapter.ReadInt()
	-- self.fight_mount_info.clear_upgrade_time = MsgAdapter.ReadUInt()
	self.fight_mount_info.equip_info_list = {}
	self.fight_mount_info.skill_level_list = {}
	for i = 0, 3 do
		self.fight_mount_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i = 0, 3 do
		self.fight_mount_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	-- for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID - 1  do
	-- 	self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	-- end
	self.xiannv_info = LoadXiannvInfo()
	self.jingling_info = LoadJinglingInfo()
	self.slot_list = {}
	for i=1,LIEMING_FUHUN_SLOT_COUNT do
		self.slot_list[i] = LoadLieMingInfo()
	end
	self.stone_param = LoadStoneParam()

	self.foot_info = LoadFootInfo()
	self.cloak_info = LoadCloakInfo()

	self.shen_equip_part_list = {}
	for i = 0, GameEnum.SHEN_EQUIP_NUM - 1 do
		self.shen_equip_part_list[i] = {}
		self.shen_equip_part_list[i].index = i
		self.shen_equip_part_list[i].level = MsgAdapter.ReadShort()
	end


	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()

	self.waist_info = {}
	self.waist_info.level = MsgAdapter.ReadShort()
	self.waist_info.grade = MsgAdapter.ReadShort()
	self.waist_info.used_imageid = MsgAdapter.ReadShort()
	self.waist_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.waist_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.waist_info.star_level = MsgAdapter.ReadShort()
	self.waist_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.waist_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.waist_info.equip_skill_level = MsgAdapter.ReadInt()
	self.waist_info.capability = MsgAdapter.ReadInt()
	self.waist_info.equip_info_list = {}
	self.waist_info.skill_level_list = {}
	for i=0,3 do
		self.waist_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.waist_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	self.head_info = {}
	self.head_info.level = MsgAdapter.ReadShort()
	self.head_info.grade = MsgAdapter.ReadShort()
	self.head_info.used_imageid = MsgAdapter.ReadShort()
	self.head_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.head_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.head_info.star_level = MsgAdapter.ReadShort()
	self.head_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.head_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.head_info.equip_skill_level = MsgAdapter.ReadInt()
	self.head_info.capability = MsgAdapter.ReadInt()
	self.head_info.equip_info_list = {}
	self.head_info.skill_level_list = {}
	for i=0,3 do
		self.head_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.head_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.arm_info = {}
	self.arm_info.level = MsgAdapter.ReadShort()
	self.arm_info.grade = MsgAdapter.ReadShort()
	self.arm_info.used_imageid = MsgAdapter.ReadShort()
	self.arm_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.arm_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.arm_info.star_level = MsgAdapter.ReadShort()
	self.arm_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.arm_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.arm_info.equip_skill_level = MsgAdapter.ReadInt()
	self.arm_info.capability = MsgAdapter.ReadInt()
	self.arm_info.equip_info_list = {}
	self.arm_info.skill_level_list = {}
	for i=0,3 do
		self.arm_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.arm_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.mask_info = {}
	self.mask_info.level = MsgAdapter.ReadShort()
	self.mask_info.grade = MsgAdapter.ReadShort()
	self.mask_info.used_imageid = MsgAdapter.ReadShort()
	self.mask_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.mask_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.mask_info.star_level = MsgAdapter.ReadShort()
	self.mask_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.mask_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.mask_info.equip_skill_level = MsgAdapter.ReadInt()
	self.mask_info.capability = MsgAdapter.ReadInt()
	self.mask_info.equip_info_list = {}
	self.mask_info.skill_level_list = {}
	for i=0,3 do
		self.mask_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.mask_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end


	self.xianbao_info = {}
	self.xianbao_info.level = MsgAdapter.ReadShort()
	self.xianbao_info.grade = MsgAdapter.ReadShort()
	self.xianbao_info.used_imageid = MsgAdapter.ReadShort()
	self.xianbao_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.xianbao_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.xianbao_info.star_level = MsgAdapter.ReadShort()
	self.xianbao_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.xianbao_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.xianbao_info.equip_skill_level = MsgAdapter.ReadInt()
	self.xianbao_info.capability = MsgAdapter.ReadInt()
	self.xianbao_info.equip_info_list = {}
	self.xianbao_info.skill_level_list = {}
	for i=0,3 do
		self.xianbao_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.xianbao_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.lingzhu_info = {}
	self.lingzhu_info.level = MsgAdapter.ReadShort()
	self.lingzhu_info.grade = MsgAdapter.ReadShort()
	self.lingzhu_info.used_imageid = MsgAdapter.ReadShort()
	self.lingzhu_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.lingzhu_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.lingzhu_info.star_level = MsgAdapter.ReadShort()
	self.lingzhu_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.lingzhu_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.lingzhu_info.equip_skill_level = MsgAdapter.ReadInt()
	self.lingzhu_info.capability = MsgAdapter.ReadInt()
	self.lingzhu_info.equip_info_list = {}
	self.lingzhu_info.skill_level_list = {}
	for i=0,3 do
		self.lingzhu_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.lingzhu_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.ws_equip_list = {}
	for i=0, GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.item_id = MsgAdapter.ReadUShort()
		if vo.item_id > 0 then
			self.ws_equip_list[i] = vo
		end
	end

	self.lingchong_info = {}
	self.lingchong_info.level = MsgAdapter.ReadShort()
	self.lingchong_info.grade = MsgAdapter.ReadShort()
	self.lingchong_info.used_imageid = MsgAdapter.ReadShort()
	self.lingchong_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.lingchong_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.lingchong_info.star_level = MsgAdapter.ReadShort()
	self.lingchong_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.lingchong_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.lingchong_info.equip_skill_level = MsgAdapter.ReadInt()
	self.lingchong_info.capability = MsgAdapter.ReadInt()
	self.lingchong_info.equip_info_list = {}
	self.lingchong_info.skill_level_list = {}
	for i=0,3 do
		self.lingchong_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.lingchong_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	TestPrint(self.lingchong_info)
	self.linggong_info = {}
	self.linggong_info.level = MsgAdapter.ReadShort()
	self.linggong_info.grade = MsgAdapter.ReadShort()
	self.linggong_info.used_imageid = MsgAdapter.ReadShort()
	self.linggong_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.linggong_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.linggong_info.star_level = MsgAdapter.ReadShort()
	self.linggong_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.linggong_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.linggong_info.equip_skill_level = MsgAdapter.ReadInt()
	self.linggong_info.capability = MsgAdapter.ReadInt()
	self.linggong_info.equip_info_list = {}
	self.linggong_info.skill_level_list = {}
	for i=0,3 do
		self.linggong_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.linggong_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.lingqi_info = {}
	self.lingqi_info.level = MsgAdapter.ReadShort()
	self.lingqi_info.grade = MsgAdapter.ReadShort()
	self.lingqi_info.used_imageid = MsgAdapter.ReadShort()
	self.lingqi_info.shuxingdan_count = MsgAdapter.ReadShort()
	self.lingqi_info.chengzhangdan_count = MsgAdapter.ReadShort()
	self.lingqi_info.star_level = MsgAdapter.ReadShort()
	self.lingqi_info.active_special_image_flag = MsgAdapter.ReadUInt()
	self.lingqi_info.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.lingqi_info.equip_skill_level = MsgAdapter.ReadInt()
	self.lingqi_info.capability = MsgAdapter.ReadInt()
	self.lingqi_info.equip_info_list = {}
	self.lingqi_info.skill_level_list = {}
	for i=0,3 do
		self.lingqi_info.equip_info_list[i] = MsgAdapter.ReadShort()--LoadEquipInfo()
	end
	for i=0,3 do
		self.lingqi_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end
end

--仙魂变化
SCRoleXianhun = SCRoleXianhun or BaseClass(BaseProtocolStruct)
function SCRoleXianhun:__init()
	self.msg_type = 1423
end

function SCRoleXianhun:Decode()
	self.xianhun = MsgAdapter.ReadInt()
end

--元力变化
SCRoleYuanli = SCRoleYuanli or BaseClass(BaseProtocolStruct)
function SCRoleYuanli:__init()
	self.msg_type = 1424
end

function SCRoleYuanli:Decode()
	self.yuanli = MsgAdapter.ReadInt()
end

--怒气变化
SCRoleNuqi = SCRoleNuqi or BaseClass(BaseProtocolStruct)
function SCRoleNuqi:__init()
	self.msg_type = 1426
end

function SCRoleNuqi:Decode()
	self.nuqi = MsgAdapter.ReadInt()
end

-- 角色结婚信息改变
SCRoleMarryInfoChange = SCRoleMarryInfoChange or BaseClass(BaseProtocolStruct)
function SCRoleMarryInfoChange:__init()
	self.msg_type = 1430
end

function SCRoleMarryInfoChange:Decode()
	self.lover_uid = MsgAdapter.ReadInt()
	self.lover_name = MsgAdapter.ReadStrN(32)
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserved = MsgAdapter.ReadShort()
	self.last_marry_time = MsgAdapter.ReadUInt()
end

-- 刺客暴击技能点数
SCSkillOtherSkillInfo = SCSkillOtherSkillInfo or BaseClass(BaseProtocolStruct)
function SCSkillOtherSkillInfo:__init()
	self.msg_type = 1433

	self.skill124_effect_star = 0
	self.skill124_effect_baoji = 0
end

--女娲石变化
SCNvWaShi = SCNvWaShi or BaseClass(BaseProtocolStruct)
function SCNvWaShi:__init()
	self.msg_type = 1434
end

function SCNvWaShi:Decode()
	self.nv_wa_shi = MsgAdapter.ReadInt()
end

--经验加成
SCRoleExpExtraPer = SCRoleExpExtraPer or BaseClass(BaseProtocolStruct)
function SCRoleExpExtraPer:__init()
	self.msg_type = 1435
end

function SCRoleExpExtraPer:Decode()
	self.exp_extra_per = MsgAdapter.ReadInt() / 100  --发过来的是万分比
end

function SCSkillOtherSkillInfo:Decode()
	self.skill124_effect_star = MsgAdapter.ReadShort()
	self.skill124_effect_baoji = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end

--技能学习
CSRoleSkillLearnReq = CSRoleSkillLearnReq or BaseClass(BaseProtocolStruct)
function CSRoleSkillLearnReq:__init()
	self.msg_type = 1452
	self.skill_id = 0
	self.one_key_learn = 0
end

function CSRoleSkillLearnReq:Encode( ... )
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_id)
	MsgAdapter.WriteShort(self.one_key_learn)
end

-- 登陆时请求一系列消息
CSAllInfoReq = CSAllInfoReq or BaseClass(BaseProtocolStruct)
function CSAllInfoReq:__init()
	self.msg_type = 1454
end

function CSAllInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--通过角色名称查询角色信息
CSFindRoleByName = CSFindRoleByName or BaseClass(BaseProtocolStruct)

function CSFindRoleByName:__init()
	self.msg_type = 1456
    self.gamename = ""
    self.msg_identify = 0
end

function CSFindRoleByName:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStrN(self.gamename, 32)
	MsgAdapter.WriteInt(self.msg_identify)
end

--接受角色名查询后返回信息
SCFindRoleByNameRet = SCFindRoleByNameRet or BaseClass(BaseProtocolStruct)

function SCFindRoleByNameRet:__init()
	self.msg_type = 1409
end

function SCFindRoleByNameRet:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
	self.is_online = MsgAdapter.ReadChar()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadInt()
	self.msg_identify = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
end

--请求角色信息
CSRoleInfoReq = CSRoleInfoReq or BaseClass(BaseProtocolStruct)
function CSRoleInfoReq:__init()
	self.msg_type = 1450
end

function CSRoleInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--获取角色技能列表
SCSkillListInfoAck = SCSkillListInfoAck or BaseClass(BaseProtocolStruct)
function SCSkillListInfoAck:__init()
	self.msg_type = 1401
end

function SCSkillListInfoAck:Decode()
	self.default_skill_index = MsgAdapter.ReadShort()
	self.is_init = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadInt()
	self.skill_list = {}

	for i=1,self.count do
		local skill_info = ProtocolStruct.ReadRoleSkillInfoItem()
		self.skill_list[skill_info.index] = skill_info
	end
end

--获取角色vip信息
SCVipInfo = SCVipInfo or BaseClass(BaseProtocolStruct)
function SCVipInfo:__init()
	self.msg_type = 1407
end

function SCVipInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.vip_level = MsgAdapter.ReadChar()
	self.fetch_qifu_buycoin_reward_flag = MsgAdapter.ReadUChar()

	self.gold_buycoin_times = MsgAdapter.ReadShort()
	self.gold_buyyuanli_times = MsgAdapter.ReadShort()
	self.gold_buyxianhun_times = MsgAdapter.ReadShort()

	self.fetch_qifu_buyxianhun_reward_flag = MsgAdapter.ReadUChar()
	self.fetch_qifu_buyyuanli_reward_flag = MsgAdapter.ReadUChar()
	self.vip_exp = MsgAdapter.ReadInt()
	self.fetch_level_reward_flag = MsgAdapter.ReadInt()

	self.free_buycoin_times = MsgAdapter.ReadShort()
	self.free_buyyuanli_times = MsgAdapter.ReadShort()
	self.free_buyxianhun_times = MsgAdapter.ReadShort()

	self.reserve_sh = MsgAdapter.ReadShort()

	self.last_free_buycoin_timestamp = MsgAdapter.ReadUInt()
	self.last_free_buyyuanli_timestamp = MsgAdapter.ReadUInt()
	self.last_free_buyxianhun_timestamp = MsgAdapter.ReadUInt()
	self.vip_week_gift_resdiue_times = MsgAdapter.ReadInt()
	self.time_temp_vip_time = MsgAdapter.ReadUInt()				--限时vip已开启时间
end


--获得角色单个技能数据
SCSkillInfoAck = SCSkillInfoAck or BaseClass(BaseProtocolStruct)
function SCSkillInfoAck:__init()
	self.msg_type = 1413
end

function SCSkillInfoAck:Decode()
	self.skill_info = ProtocolStruct.ReadRoleSkillInfoItem()
end

--设置攻击模式
CSSetAttackMode = CSSetAttackMode or BaseClass(BaseProtocolStruct)
function CSSetAttackMode:__init()
	self.msg_type = 1453
	self.mode = 0 --0和平 1all 2max
end

function CSSetAttackMode:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mode)
	MsgAdapter.WriteInt(self.is_fanji)
end

--设置攻击模式返回
SCSetAttackMode = SCSetAttackMode or BaseClass(BaseProtocolStruct)
function SCSetAttackMode:__init()
	self.msg_type = 1415
end

function SCSetAttackMode:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.result = MsgAdapter.ReadShort()
	self.attack_mode = MsgAdapter.ReadInt()
	self.last_peace_mode_time = MsgAdapter.ReadUInt()
end

-- 玩家军团信息变更广播
SCRoleGuildInfoChange = SCRoleGuildInfoChange or BaseClass(BaseProtocolStruct)
function SCRoleGuildInfoChange:__init()
	self.msg_type = 1416
end

function SCRoleGuildInfoChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserved = MsgAdapter.ReadChar()
	self.guild_post = MsgAdapter.ReadChar()
	self.guild_id = MsgAdapter.ReadInt()
	self.guild_name = MsgAdapter.ReadStrN(32)
	self.guild_gongxian = MsgAdapter.ReadInt()
	self.guild_total_gongxian = MsgAdapter.ReadInt()
	self.last_leave_guild_time = MsgAdapter.ReadUInt()
end

--  名字修改
SCRoleResetName = SCRoleResetName or BaseClass(BaseProtocolStruct)
function SCRoleResetName:__init()
	self.msg_type = 1419
end

function SCRoleResetName:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserved = MsgAdapter.ReadShort()
	self.game_name = MsgAdapter.ReadStrN(32)
end

--角色性别改变
SCRoleSexChange = SCRoleSexChange or BaseClass(BaseProtocolStruct)
function SCRoleSexChange:__init()
	self.msg_type = 1422
end

function SCRoleSexChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.sex = MsgAdapter.ReadShort()
end

--角色特殊形象改变
SCRoleSpecialAppearanceChange = SCRoleSpecialAppearanceChange or BaseClass(BaseProtocolStruct)
function SCRoleSpecialAppearanceChange:__init()
	self.msg_type = 1425
end

function SCRoleSpecialAppearanceChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.special_appearance = MsgAdapter.ReadShort()
	self.appearance_param =  MsgAdapter.ReadInt()
end

--角色荣誉积分返回
SCRoleCampHonour = SCRoleCampHonour or BaseClass(BaseProtocolStruct)
function SCRoleCampHonour:__init()
	self.msg_type = 1427
end

function SCRoleCampHonour:Decode()
	self.honour = MsgAdapter.ReadInt()
	self.reason = MsgAdapter.ReadInt()
end

--角色体力返回
SCRoleEnergy = SCRoleEnergy or BaseClass(BaseProtocolStruct)
function SCRoleEnergy:__init()
	self.msg_type = 1431
end

function SCRoleEnergy:Decode()
	self.energy = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
end


--声望改变
SCRoleShengwang = SCRoleShengwang or BaseClass(BaseProtocolStruct)
function SCRoleShengwang:__init()
	self.msg_type = 1432
end

function SCRoleShengwang:Decode()
	self.shengwang = MsgAdapter.ReadInt()
end

--魂力改变
SCRoleHunli = SCRoleHunli or BaseClass(BaseProtocolStruct)
function SCRoleHunli:__init()
	self.msg_type = 1436
end

function SCRoleHunli:Decode()
	self.hunli = MsgAdapter.ReadInt()
end

--灵精改变
SCRoleLingJing = SCRoleLingJing or BaseClass(BaseProtocolStruct)
function SCRoleLingJing:__init()
	self.msg_type = 1437
end

function SCRoleLingJing:Decode()
	self.lingjing = MsgAdapter.ReadInt()
end

--成就改变
SCRoleChengJiu = SCRoleChengJiu or BaseClass(BaseProtocolStruct)
function SCRoleChengJiu:__init()
	self.msg_type = 1438
end

function SCRoleChengJiu:Decode()
	self.chengjiu = MsgAdapter.ReadInt()
end

--功勋改变
SCRoleGongxun = SCRoleGongxun or BaseClass(BaseProtocolStruct)
function SCRoleGongxun:__init()
	self.msg_type = 1468
end

function SCRoleGongxun:Decode()
	self.gongxun = MsgAdapter.ReadInt()
end

-- 第一次头像改变
SCAvatarTimeStampInfo = SCAvatarTimeStampInfo or BaseClass(BaseProtocolStruct)
function SCAvatarTimeStampInfo:__init()
	self.msg_type = 1469
end

function SCAvatarTimeStampInfo:Decode()
	self.is_change_avatar = MsgAdapter.ReadChar()
end


--复活次数改变
SCRoleDayRevivalTimes = SCRoleDayRevivalTimes or BaseClass(BaseProtocolStruct)
function SCRoleDayRevivalTimes:__init()
	self.msg_type = 1439
end

function SCRoleDayRevivalTimes:Decode()
	self.day_revival_times = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
end

--捉鬼活力和次数
SCZhuaGuiRoleInfo = SCZhuaGuiRoleInfo or BaseClass(BaseProtocolStruct)
function SCZhuaGuiRoleInfo:__init()
	self.msg_type = 1440
end

function SCZhuaGuiRoleInfo:Decode()
	self.zhuagui_day_gethunli = MsgAdapter.ReadInt()
	self.zhuagui_day_catch_count = MsgAdapter.ReadInt()
end

--请求加入阵营
CSRoleChooseCamp = CSRoleChooseCamp or BaseClass(BaseProtocolStruct)
function CSRoleChooseCamp:__init()
	self.msg_type = 1457
end

function CSRoleChooseCamp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.camp_type)
	MsgAdapter.WriteChar(self.is_random)
	MsgAdapter.WriteShort(0)
end

--请求修改移动模式
CSSetMoveMode = CSSetMoveMode or BaseClass(BaseProtocolStruct)
function CSSetMoveMode:__init()
	self.msg_type = 1460
end

function CSSetMoveMode:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.move_mode)	--0为正常，1为飞行
	MsgAdapter.WriteShort(self.move_mode_param)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(0)
end

--角色改名请求
CSRoleResetName = CSRoleResetName or BaseClass(BaseProtocolStruct)
function CSRoleResetName:__init()
	self.msg_type = 1461

	self.is_item_reset = 0
	self.new_name = ""
end

function CSRoleResetName:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.is_item_reset)
	MsgAdapter.WriteStrN(self.new_name, 32)
end

--修改头像key
CSSetAvatarTimeStamp = CSSetAvatarTimeStamp or BaseClass(BaseProtocolStruct)
function CSSetAvatarTimeStamp:__init()
	self.msg_type = 1465

	self.avatar_key_big = 0
	self.avatar_key_small = 0
end

function CSSetAvatarTimeStamp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.avatar_key_big)
	MsgAdapter.WriteUInt(self.avatar_key_small)
end


-- 加速检测心跳
CSSpeedUpHello = CSSpeedUpHello or BaseClass(BaseProtocolStruct)
function CSSpeedUpHello:__init()
	self.msg_type = 1464
end

function CSSpeedUpHello:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--查询跨服角色信息
CSCrossQueryRoleInfo = CSCrossQueryRoleInfo or BaseClass(BaseProtocolStruct)
function CSCrossQueryRoleInfo:__init()
	self.msg_type = 1466
	self.plat_type = 0
	self.target_uid = 0
end

function CSCrossQueryRoleInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.plat_type)
	MsgAdapter.WriteInt(self.target_uid)
end

--查询经验加成
CSGetExpExtraPer = CSGetExpExtraPer or BaseClass(BaseProtocolStruct)
function CSGetExpExtraPer:__init()
	self.msg_type = 1467
end

function CSGetExpExtraPer:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--头衔进阶
CSRoleJingJieReq = CSRoleJingJieReq or BaseClass(BaseProtocolStruct)
function CSRoleJingJieReq:__init()
	self.msg_type = 1470
	self.opera_type = 0
	self.is_auto_buy = 0
end

function CSRoleJingJieReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

--头衔进阶
SCRoleJingJie = SCRoleJingJie or BaseClass(BaseProtocolStruct)
function SCRoleJingJie:__init()
	self.msg_type = 1441
end

function SCRoleJingJie:Decode()
	self.jingjie_level = MsgAdapter.ReadInt()
end

--跨服修罗塔掉落日志请求
CSCrossXiuluoTowerDropLog = CSCrossXiuluoTowerDropLog or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerDropLog:__init()
	self.msg_type = 14300
end

function CSCrossXiuluoTowerDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服修罗塔掉落日志
SCCrossXiuluoTowerDropLog = SCCrossXiuluoTowerDropLog or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerDropLog:__init()
	self.msg_type = 14350
	self.log_count = 0
	self.item_list = {}
end

function SCCrossXiuluoTowerDropLog:Decode()
	self.item_list = {}
	self.log_count = MsgAdapter.ReadInt()
	for i = 1, self.log_count do
		local data = {}
		data.log_type = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		data.timestamp = MsgAdapter.ReadUInt()
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		self.item_list[i] = data
	end
end

--跨服六界掉落日志请求
CSCrossGuildBattleDropLog = CSCrossGuildBattleDropLog or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleDropLog:__init()
	self.msg_type = 14400
end

function CSCrossGuildBattleDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服六界精英怪请求
CSCrossGuildBattleGetMonsterInfoReq = CSCrossGuildBattleGetMonsterInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleGetMonsterInfoReq:__init()
	self.msg_type = 14401
end

function CSCrossGuildBattleGetMonsterInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


--跨服六界掉落日志
SCCrossGuildBattleDropLog = SCCrossGuildBattleDropLog or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleDropLog:__init()
	self.msg_type = 14450
	self.log_count = 0
	self.item_list = {}
end

function SCCrossGuildBattleDropLog:Decode()
	self.item_list = {}
	self.log_count = MsgAdapter.ReadInt()
	for i = 1, self.log_count do
		local data = {}
		data.name = MsgAdapter.ReadStrN(32)
		data.timestamp = MsgAdapter.ReadUInt()
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		self.item_list[i] = data
	end
end