
BaseVo = BaseVo or BaseClass()
function BaseVo:__init()
	self.obj_id = COMMON_CONSTS.INVALID_OBJID		-- 场景中的id
	self.name = ""									-- 名字
	self.pos_x = 0									-- X坐标
	self.pos_y = 0									-- Y坐标
end

function BaseVo:__delete()
end

-- 装饰物
DecorationVo = DecorationVo or BaseClass(BaseVo)
function DecorationVo:__init()
	self.scene_index = 0
	self.decoration_id = 0
end

-- 传送点
DoorVo = DoorVo or BaseClass(BaseVo)
function DoorVo:__init()
	self.door_id = 0
	self.name = ""
	self.type = 0
end

-- 栅栏
FenceVo = FenceVo or BaseClass(BaseVo)
function FenceVo:__init()
	self.fence_id = 0
	self.name = ""
	self.type = 0
	self.res_id = 0
end

-- 跳跃点
JumpPointVo = JumpPointVo or BaseClass(BaseVo)
function JumpPointVo:__init()
	self.id = 0
	self.range = 3
	self.target_id = 0
	self.jump_type = 0
	self.air_craft_id = 0
	self.is_show = 0
	self.jump_speed = 2
	self.jump_act = 0
	self.jump_tong_bu = 0
	self.offset = {x = 0, y = 0, z = 0}
end

-- 特效
EffectObjVo = EffectObjVo or BaseClass(BaseVo)
function EffectObjVo:__init()
	self.product_method = 0
	self.product_id = 0
	self.birth_time = 0
	self.disappear_time = 0
	self.param1 = 0
	self.param2 = 0
	self.src_pos_x = 0
	self.src_pos_y = 0
end

-- 触碰物
TriggerObjVo = TriggerObjVo or BaseClass(BaseVo)
function TriggerObjVo:__init()
	self.obj_id = 0
	self.action_type = 0
	self.pos_x = 0
	self.pos_y = 0
	self.param0 = 0
	self.param1 = 0
	self.affiliation = 0
	self.trigger_name = ""
end

-- 城主雕像
CityOwnerStatueVo = CityOwnerStatueVo or BaseClass(BaseVo)
function CityOwnerStatueVo:__init()
	self.obj_id = COMMON_CONSTS.INVALID_OBJID
	self.pos_x = 0
	self.pos_y = 0
end

-- 掉落物
FallItemVo = FallItemVo or BaseClass(BaseVo)
function FallItemVo:__init()
	self.item_id = 0
	self.owner_role_id = 0
	self.coin = 0
	self.monster_id = 0
	self.item_num = 0
	self.drop_time = 0
	self.create_time = 0
	self.is_buff_falling = 0
	self.buff_appearan = 0
end

-- 采集物
GatherVo = GatherVo or BaseClass(BaseVo)
function GatherVo:__init()
	self.gather_id = 0
	self.param = 0
end

-- 世界事件
EventVo = EventVo or BaseClass(BaseVo)
function EventVo:__init()
	self.world_event_id = 0
	self.hp = 0
	self.max_hp = 0
	self.move_speed = 0
	self.dir = 0
	self.distance = 0
	self.buff_mark_low = 0							-- 战斗特殊效果低32位
	self.buff_mark_high = 0							-- 战斗特殊效果高32位
end

-- 怪
MonsterVo = MonsterVo or BaseClass(BaseVo)
function MonsterVo:__init()
	self.monster_id = 0
	self.monster_type = 0
	self.hp = 0
	self.max_hp = 0
	self.move_speed = 0
	self.dir = 0
	self.distance = 0
	self.buff_mark_low = 0							-- 战斗特殊效果低32位
	self.buff_mark_high = 0							-- 战斗特殊效果高32位
	self.status_type = 0
	self.special_param = 1                          -- 是否展示仙缘
end

-- 神石
ShenShiVo = ShenShiVo or BaseClass(BaseVo)
function ShenShiVo:__init()
	self.has_owner = 0
	self.hp = 0
	self.max_hp = 0
	self.pos_x = 0
	self.pos_y = 0
	self.obj_id = 0
	self.owner_obj_id = 0
	self.owner_uid = 0
end

-- NPC
NpcVo = NpcVo or BaseClass(BaseVo)
function NpcVo:__init()
	self.npc_id = 0
end

-- 宠物
PetObjVo = PetObjVo or BaseClass(BaseVo)
function PetObjVo:__init()
	self.pet_id = 0
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.pet_name = ""
	self.pos_x = 0
	self.pos_y = 0
end

-- 镖车
TruckObjVo = TruckObjVo or BaseClass(BaseVo)
function TruckObjVo:__init()
	self.truck_color = 0
	self.owner_role_id = 0
	self.owner_obj_id = -1
end

-- 多人坐骑
MultiMountObjVo = MultiMountObjVo or BaseClass(BaseVo)
function MultiMountObjVo:__init()
	self.mount_id = 0
	self.mount_res_id = 0
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.partner_role_id = 0
	self.partner_obj_id = -1
	self.dir = 0
	self.move_speed = 0
end

-- 精灵
SpriteObjVo = SpriteObjVo or BaseClass(BaseVo)
function SpriteObjVo:__init()
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.pos_x = 0
	self.pos_y = 0
	self.name = ""
	self.sprite_id = 0
end

-- 女神
GoddessObjVo = GoddessObjVo or BaseClass(BaseVo)
function GoddessObjVo:__init()
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.pos_x = 0
	self.pos_y = 0
	self.name = ""
	self.wing_res_id = 0
	self.shen_gong_res_id = 0
	self.goddess_res_id = -1
end

-- 灵宠
LingChongObjVo = LingChongObjVo or BaseClass(BaseVo)
function LingChongObjVo:__init()
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.pos_x = 0
	self.pos_y = 0
	self.name = ""
	self.lingchong_used_imageid = 0
	self.linggong_used_imageid = 0
	self.lingqi_used_imageid = 0
end

-- 超级宝宝
SuperBabyObjVo = SuperBabyObjVo or BaseClass(BaseVo)
function SuperBabyObjVo:__init()
	self.owner_role_id = 0
	self.owner_obj_id = -1
	self.pos_x = 0
	self.pos_y = 0
	self.name = ""
	self.lover_name = ""
	self.sup_baby_id = -1
	self.sup_baby_name = ""
end

-- 温泉皮艇
BoatObjVo = BoatObjVo or BaseClass(BaseVo)
function BoatObjVo:__init()
	self.pos_x = 0
	self.pos_y = 0
	self.name = ""
	self.boy_obj_id = 0
	self.girl_obj_id = 0
	self.action_type = 0
end

--夫妻光环
CoupleHaloObjVo = CoupleHaloObjVo or BaseClass(BaseVo)
function CoupleHaloObjVo:__init()
	self.target_obj_id_1 = 0
	self.target_obj_id_2 = 0
	self.halo_type = 0
end

-- 城主雕像
CityOwnerObjVo = CityOwnerObjVo or BaseClass(BaseVo)
function CityOwnerObjVo:__init()
	self.obj_id = COMMON_CONSTS.INVALID_OBJID
	self.sex = 0
	self.prof = 0
	self.appearance = nil
	self.wuqi_color = 0
end

-- 角色
RoleVo = RoleVo or BaseClass(BaseVo)
function RoleVo:__init()
	self.role_id = 0								-- 角色ID
	self.dir = 0									-- 方向
	self.move_mode_param = 0						-- 移动模式参数
	self.role_status = 0							-- 角色状态
	self.hp = 0										-- 当前hp
	self.max_hp = 0									-- 最大hp
	self.mp = 0										-- 最大法力
	self.max_mp = 0									-- 最大法力值

	self.exp = 0									-- 经验
	self.max_exp = 0								-- 最大经验
	self.level = 0									-- 等级
	self.name = ""									-- 名字
	self.camp = 0									-- 阵营
	self.prof = 0									-- 职业
	self.sex = 0									-- 性别
	self.vip_level = 0								-- vip等级
	self.molong_rank = 0 							-- 龙行天下头衔等级
	self.rest_partner_obj_id = 0					-- 双修伙伴id
	self.move_speed = 0								-- 移动速度
	self.distance = 0								-- 方向距离
	self.attack_mode = 0							-- 攻击模式
	self.name_color = 0								-- 名字颜色
	self.move_mode = 0								-- 移动模式
	self.authority_type = 0							-- 身份类型
	self.husong_color = 0							-- 护送任务颜色
	self.is_change_avatar = 0						-- 是否换过头像
	self.husong_taskid = 0							-- 护送任务ID
	self.guild_post = 0								-- 仙盟职位
	self.mount_appeid = 0							-- 坐骑外观

	self.appearance = nil							-- 角色外观数据
	self.used_sprite_id = -1						-- 精灵id
	self.user_pet_special_img = -1					-- 精灵幻化id
	self.use_sprite_imageid = 0						-- 精灵飞升形象
	self.used_sprite_quality = 0					-- 仙女品质等级
	self.chengjiu_title_level = 0					-- 成就称号等级
	self.sprite_name = ""							-- 仙女名字
	self.xianjie_level = 0							-- 仙阶
	self.use_xiannv_halo_img = 0					-- 精灵光环

	self.pet_id = -1								-- 宠物id
	self.pet_level = 0								-- 宠物等级
	self.pet_grade = 0								-- 宠物阶段等级
	self.pet_name = ""								-- 宠物名字

	self.guild_id = 0								-- 军团ID
	self.guild_name = ""							-- 军团名字
	self.used_title_list = {0,0,0}					-- 头顶称号数据
	self.use_jingling_titleid = 0					-- 精灵称号
	self.buff_mark_low = 0							-- 战斗特殊效果低32位
	self.buff_mark_high = 0							-- 战斗特殊效果高32位
	self.special_param = 0							-- 特殊状态
	self.height = 0									-- 跳跃高度
	self.special_appearance = 0						-- 特殊外观
	self.appearance_param = 0						-- 特殊外观参数
	self.shenbing_flag = 0							-- 神兵外观
	self.lover_name = ""							-- 结婚信息
	self.lover_uid = 0								-- 伴侣uid
	self.jilian_type = 0							-- 祭炼类型
	self.jinghua_husong_status = 0					-- 精华护送状态
	self.use_xiannv_id = -1							-- 仙女使用id
	self.used_sprite_jie = 0						-- 仙女阶数
	self.xiannv_name = ""							-- 仙女名字
	self.bianshen_param = ""						-- 变身形象
	self.bianshen_obj_id = -1						-- 变身成其他角色id

	self.guild_gongxian = 0							-- 贡献
	self.guild_total_gongxian = 0					-- 总贡献
	self.all_charm = 0								-- 魅力
	self.day_charm = 0 								-- 每日魅力
	self.shengwang = 0 								-- 声望
	self.is_shadow = 0								-- 是角色影子
	self.tianxiange_level = 0						-- 天仙阁等级
	self.day_revival_times = 0						-- 每日复活次数
	self.shadow_type = 0
	self.shadow_param = 0
	self.halo_type  = 0
	self.multi_mount_res_id = 0						-- 双人坐骑id
	self.multi_mount_is_owner = 0 					-- 是否当前双人坐骑的主人
	self.multi_mount_other_uid = 0 					-- 一起骑乘的玩家role_id
	self.multi_mount_huanhua_res_id = 0 			-- 双人坐骑幻化res_id
	self.wuqi_color = 0								-- 武器颜色
	self.touxian = 0								-- 头衔等级
	self.top_dps_flag = 0							-- boss dps 标记
	self.upgrade_next_skill = 0						-- 进阶装备下一技能ID
	self.upgrade_cur_calc_num = 0					-- 已普攻次数
	self.total_capability = 0						-- 战力
	self.task_appearn = 0							-- 接受任务特殊外观
	self.task_appearn_param_1 = 0					-- 接受任务特殊外观参数
	self.combine_server_equip_active_special = 0	-- 屠龙装备是否激活特效, 0不是1是
	self.lingzhu_use_imageid = -1					-- 灵珠
end

-- 主角
MainRoleVo = MainRoleVo or BaseClass(RoleVo)
function MainRoleVo:__init()
	self.server_id = 0								-- 服ID
	self.scene_id = 0								-- 场景ID
	self.scene_key = 0								-- 场景Key
	self.last_scene_id = 0							-- 最后场景ID

	self.energy = 0									-- 体力

	self.base_max_hp = 0							-- 基础最大血量 不包含Buff附加
	self.base_max_mp = 0
	self.base_gongji = 0							-- 基础攻击
	self.base_fangyu = 0							-- 基础防御
	self.base_mingzhong = 0							-- 基础命中
	self.base_shanbi = 0							-- 基础闪避
	self.base_baoji = 0								-- 基础暴击
	self.base_jianren = 0							-- 基础坚韧
	self.base_move_speed = 0						-- 基础移动速度
	self.base_fujia_shanghai = 0					-- 附加伤害百分比
	self.base_dikang_shanghai = 0					-- 抵抗伤害百分比
	self.base_per_jingzhun = 0						-- 精准百分比
	self.base_per_baoji = 0							-- 暴击百分比
	self.base_per_kangbao = 0						-- 抗暴百分比
	self.base_per_pofang = 0						-- 破防百分比
	self.base_per_mianshang = 0						-- 免伤百分比
	self.base_constant_zengshang = 0				-- 固定增伤
	self.base_constant_mianshang = 0				-- 固定免伤
	self.huixinyiji = 0 							-- 会心一击

	self.exp = 0									-- 经验
	self.max_exp = 0								-- 最大经验
	self.capability = 0								-- 战斗力
	self.other_capability = 0						-- 其他模块战力
	self.jump_remain_times = 0						-- 跳跃剩余次数
	self.jump_last_recover_time = 0					-- 最后恢复跳跃时间
	self.buff_mark = 0								-- buff效果标记
	self.evil = 0									-- 罪恶值
	self.xianhun = 0								-- 仙魂
	self.yuanli = 0									-- 元力
	self.nv_wa_shi = 0								-- 女娲石
	self.lingjing = 0								-- 灵晶
	self.chengjiu = 0								-- 成就
	self.hunli = 0									-- 魂力
	self.guanghui = 0								-- 光辉

	self.is_team_leader = 0							-- 是否队长
	self.nuqi = 0									-- 怒气
	self.honour = 0									-- 荣誉
	self.cross_honor = 0							-- 跨服荣誉

	self.gong_ji = 0								-- 攻击
	self.fang_yu = 0								-- 防御
	self.ming_zhong = 0								-- 命中
	self.shan_bi = 0								-- 闪避
	self.bao_ji = 0									-- 暴击
	self.jian_ren = 0								-- 坚韧

	self.avatar_key_big = 0							-- 大头像
	self.avatar_key_small = 0						-- 小头像

	self.last_marry_time = 0 						-- 上一次结婚时间
	self.gongxun = 0								-- 功勋
	self.create_time = 0							-- 创建时间
	self.last_leave_guild_time = 0 					-- 上一次离开公会时间

	self.plat_type = 0								-- 平台id

	self.gold = 0									-- 元宝
	self.bind_gold = 0								-- 绑定元宝
	self.coin = 0									-- 铜钱
	self.bind_coin = 0 								-- 绑定铜钱

	self.wuqi_color = 0								-- 武器颜色
	self.main_role_id_t = {}						-- 记录主角的role_id, 包括本地和跨服的
	self.gather_obj_id = 0x10000					-- 角色正在采集的采集物id
end

MapMoveVo = MapMoveVo or BaseClass(BaseVo)
function __init()
	self.obj_id = 0
	self.obj_type = 0
	self.type_special_id = 0
	self.dir = 0
	self.distance = 0
	self.pos_x = 0
	self.pos_y = 0
	self.move_speed = 0
	self.monster_key = 0
end
