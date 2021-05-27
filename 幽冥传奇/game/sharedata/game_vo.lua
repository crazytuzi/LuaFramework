
BaseVo = BaseVo or BaseClass()
function BaseVo:__init()
	self.obj_id = COMMON_CONSTS.INVALID_OBJID		-- 场景中的id
	self.obj_key = 0
	self.entity_type = -1
	self.name = ""									-- 名字
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 4
end

function BaseVo:__delete()
end

-- 装饰物
DecorationVo = DecorationVo or BaseClass(BaseVo)
function DecorationVo:__init()
	self.decoration_id = 0
end

-- 特效
EffectObjVo = EffectObjVo or BaseClass(BaseVo)
function EffectObjVo:__init()
	self.deliverer_obj_id = 0
	self.effect_type = 0
	self.effect_id = 0
	self.target_pos_x = 0
	self.target_pos_y = 0
	self.remain_time = 0
end

-- 掉落物
FallItemVo = FallItemVo or BaseClass(BaseVo)
function FallItemVo:__init()
	self.item_id = 0
	self.item_num = 0
	self.zhuanshen_level = 0
	self.quanghua_level = 0
	self.icon_id = 0
	self.is_remind = 0
	self.lock_time = 0
	self.expire_time = 0
end

-- 采集物
GatherVo = GatherVo or BaseClass(BaseVo)
function GatherVo:__init()
	self.gather_id = 0
	self.param = 0
end

-- 怪
MonsterVo = MonsterVo or BaseClass(BaseVo)
function MonsterVo:__init()
	self.owner_name = ""
	self.name_color = 0
	self.monster_race = 0
	self.monster_type = 0
	self.monster_id = 0
	self.owner_obj_id = 0
	self.is_hide_name = 0
	self.effect_list = nil
	self.buff_list = nil
end

-- NPC
NpcVo = NpcVo or BaseClass(BaseVo)
function NpcVo:__init()
	self.npc_id = 0
	self.npc_type = 0
	self.task_state = 0
	self.is_special_model = 0
end

-- SpecialVo
SpecialVo = SpecialVo or BaseClass(BaseVo)
function SpecialVo:__init()
	self.model_id = 0
end

-- 烈焰神力
FireObjVo = FireObjVo or BaseClass(BaseVo)
function FireObjVo:__init()
	self.owner_obj_id = 0

	self[OBJ_ATTR.CREATURE_HP] = 1
	self[OBJ_ATTR.CREATURE_MOVE_SPEED] = 1000
end

-- 角色
RoleVo = RoleVo or BaseClass(BaseVo)
function RoleVo:__init()
	self.name_color = 0xffffffff
	self.role_id = 0
	self.guild_name = ""
	self.partner_name = ""
	self.effect_list = nil
	self.buff_list = nil
	for i = 0, OBJ_ATTR.MAX do
		self[i] = 0
	end
	self.name_color_state = 0
end

-- 主角
MainRoleVo = MainRoleVo or BaseClass(RoleVo)
function MainRoleVo:__init()
	self.server_id = 0								-- 服ID
	self.scene_id = 0								-- 场景ID
	self.scene_name = ""
	self.map_name = ""
	self.fb_id = 0
	self.pet_obj_id = 0
	self.primary_server_id = 0						-- 原服务器id
end

-- 矿位展示展示
DigOreShowVo = DigOreShowVo or BaseClass(BaseVo)
function DigOreShowVo:__init()
	self.slot = 0
	self.quality = 0
	self.start_dig_time = 0
	self.role_name = ""
	self.gilde_name = ""
end
