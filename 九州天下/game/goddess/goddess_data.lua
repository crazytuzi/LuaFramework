GoddessData = GoddessData or BaseClass()

GODDRESS_HUANHUA_MAX_LEVEL = 100
GODDRESS_MAX_LEVEL = 100
GODDRESS_XIANNV_ID_1 = 0
GODDRESS_XIANNV_ID_2 = 1
GODDRESS_XIANNV_ID_3 = 2
GODDRESS_XIANNV_ID_4 = 3
GODDRESS_XIANNV_ID_5 = 4
GODDRESS_XIANNV_ID_6 = 5
GODDRESS_XIANNV_ID_7 = 6

GODDESS_ATTR_TYPE =
{
	GONG_JI = 1,
	FANG_YU = 2,
	SHENG_MING = 3,
	XIANNV_GONGJI = 4,
}

GODDESS_REQ_TYPE =
{
	NORMAL_CHOU_EXP = 0,		--抽取经验-普通抽取，param1 是否自动购买，param2 是否自动选择碎片， param3 是否10连抽
	PERFECT_CHOU_EXP = 1,		--抽取经验-完美抽取，param1 是否自动购买，param2 是否自动选择碎片， param3 是否10连抽
	FETCH_EXP = 2,				--领取经验
	UPGRADE_GRID = 3,			--提升共鸣格子，param1 格子ID
	CHOU_LING = 4,				--灵液抽取
	FETCH_LING = 5,				--灵液领取，param1 是否双倍领取（0 否，1 是）
}

GODDESS_NOTIFY_TYPE =
{
	UNFETCH_EXP = 0,			--基本信息，param1 剩余灵液，param2 今日已使用免费引灵次数, param3 今日已领取灵液次数
	SHENGWU_INFO = 1,			--圣物信息，param1 圣物ID，param2 圣物等级，param3 圣物经验值
	GRID_INFO = 2,				--格子信息，param1 格子ID，param2 格子等级
}

GODDESS_CHOUEXP_TYPE =
{
	COMMON = 0,			-- 普通回忆
	PERFECT = 1,		-- 高级回忆
}

-- 共鸣最中间格子特殊显示
GODDRESS_XIANNV_GRID_ID_12 = 12
GODDRESS_XIANNV_GRID_ID_25 = 25
GODDRESS_XIANNV_GRID_ID_26 = 26
GODDRESS_XIANNV_GRID_ID_27 = 27
GODDRESS_XIANNV_GRID_ID_28 = 28

XIANNV_SHENGWU_MAX_ID = 3
XIANNV_SHENGWU_GONGMING_MAX_GRID_ID = 28
XIANNV_SHENGWU_MILING_TYPE_COUNT = 6
XIANNV_SHENGWU_CHOU_EXP_COUNT = 6

FIX_SHOW_TIME = 8
GoddessHuanHuaActiveMatNum = 1

function GoddessData:__init()
	if GoddessData.Instance then
		print_error("[GoddessData] Attemp to create a singleton twice !")
	end
	GoddessData.Instance = self

	self.huanhua_id = 0
	self.xiannv_name_list = {}
	self.active_xiannv_flag = 0
	self.active_huanhua_flag = 0
	self.xn_item_list = {}
	self.pos_list = {}
	self.xiannv_huanhua_level = {}
	self.xiannv_huanhua_level = {}

	self.shengwu_lingye = 0
	self.shengwu_chou_id = -1
	self.shengwu_chou_exp = {}
	self.shengwu_list = {}
	self.grid_level_list = {}
	self.sc_miling_list = {}

	--self.xiannv_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
	--self.halo_skill_auto = ConfigManager.Instance:GetAutoConfig("halo_auto").halo_skill
	--self.grid_client_cfg = self.xiannv_cfg.grid_client_cfg
	--self.xiannv_skill_cfg = ListToMap(self.xiannv_cfg.xiannv, "skill_id")
	--self.xiannv_cfg_active_item = ListToMap(self.xiannv_cfg.xiannv, "active_item")
	--self.skill_cfg = ListToMap(self.xiannv_cfg.skill_cfg, "skill_id", "level")
	--self.shengwu_cfg = ListToMap(self.xiannv_cfg.shengwu_cfg, "shengwu_id", "level")
	--self.level_attr_level_cfg = ListToMap(self.xiannv_cfg.level_attr, "xiannv_id", "level")
	--self.zizhi_attr_level_cfg = ListToMap(self.xiannv_cfg.zizhi_attr, "xiannv_id", "level")

	--local beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
	--self.id_level_cfg = ListToMap(beauty_cfg.beauty_huanhua_level, "seq", "level")

	--self.gongming_grid_cfg = ListToMap(self.xiannv_cfg.gongming_cfg, "grid_id", "level")
	--self.grid_icon_cfg = ListToMap(self.xiannv_cfg.grid_depend_cfg, "grid_id")


	self.chou_exp_is_auto_fetch = 0 		--通知是否自动抽取
	self.chou_exp_add_exp_list = {} 		--通知抽取结果的数组
	self.cur_gold_miling_times = 0

	self.show_client_level_list = nil
	self.show_client_line_list = nil
	self.show_client_max_level = 0
	self.used_free_aura_search_times = 0
	self.shengwu_chou_type = 0

	self.halo_limit_grade = {}
	-- for k,v in pairs(self.halo_skill_auto) do
	-- 	if v.skill_idx == 0 then 	--光环神佑index
	-- 		table.insert(self.halo_limit_grade, v.grade)
	-- 	end
	-- end

	RemindManager.Instance:Register(RemindName.Goddess_FaZhe, BindTool.Bind(self.GetGoddessRemind, self, RemindName.Goddess_FaZhe))
	RemindManager.Instance:Register(RemindName.Goddess_GongMing, BindTool.Bind(self.GetGoddessRemind, self, RemindName.Goddess_GongMing))
end

function GoddessData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Goddess_FaZhe)
	RemindManager.Instance:UnRegister(RemindName.Goddess_GongMing)

	self.show_client_level_list = nil
	self.show_client_line_list = nil
	GoddessData.Instance = nil
end

function GoddessData:GetAllCfg()
	if not self.xiannv_cfg then
		self.xiannv_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
	end
	return self.xiannv_cfg
end

-- 服务器仙女信息同步
function GoddessData:OnGoddessInfo(protocol)
	self.active_xiannv_flag = protocol.active_xiannv_flag
	self.active_huanhua_flag = protocol.active_huanhua_flag
	self.huanhua_id = protocol.huanhua_id
	self.xiannv_name_list = protocol.xiannv_name
	self.xn_item_list = protocol.xn_item_list
	self.pos_list = protocol.pos_list
	self.xiannv_huanhua_level = protocol.xiannv_huanhua_level

	self.shengwu_lingye = protocol.shengwu_lingye
	self.last_ling_ye = self.shengwu_lingye
	self.shengwu_chou_id = protocol.shengwu_chou_id
	self.shengwu_chou_exp = protocol.shengwu_chou_exp
	self.shengwu_list = protocol.shengwu_list
	self.grid_level_list = protocol.grid_level_list
	self.sc_miling_list = protocol.miling_list

	self.used_free_aura_search_times = protocol.day_free_miling_times
	self.reveived_times = protocol.day_fetch_ling_time
	self.cur_gold_miling_times = protocol.cur_gold_miling_times
	self.show_client_line_list = self:GetGridShowLine()
end

function GoddessData:OnSCXiannvViewChange(protocol)
	self.obj_id = protocol.obj_id
	self.use_xiannv_id = protocol.use_xiannv_id
	self.huanhua_id = protocol.huanhua_id
	self.xiannv_name = protocol.xiannv_name
end

-- 升级仙女信息同步
function GoddessData:OnXiannvInfo(protocol)
	self.xn_item_list[protocol.xiannv_id] = protocol.xn_item
end

function GoddessData:GetHuanHuaId()
	return self.huanhua_id
end

--红点提醒
function GoddessData:GetGoddessRemind(remind_name)
	local is_show_remind = false
	if remind_name == RemindName.Goddess_FaZhe then
		local red_point_list = self:GetFaZheRedPoint()
		is_show_remind = red_point_list
	elseif remind_name == RemindName.Goddess_GongMing then
		local red_point_list = self:GetGongMingRedPoint()
		is_show_remind = red_point_list
	end
	return is_show_remind and 1 or 0
end

function GoddessData:OpenFunCallBack()
	RemindManager.Instance:Fire(RemindName.Goddess)
end

function GoddessData:GetXianNvNameList()
	return self.xiannv_name_list
end

function GoddessData:GetXiannvName(id)
	if self.xiannv_name_list[id] == "" then
		return self:GetXianNvCfg(id).name
	else
		return self.xiannv_name_list[id]
	end
end

function GoddessData:GetXianNvlist()
	return self.xn_item_list
end

function GoddessData:GetXianNvItem(xiannv_id)
	return self.xn_item_list[xiannv_id]
end

function GoddessData:GetXiannvId(pos)
	return self.pos_list[pos]
end

function GoddessData:GetXianNvFlag()
	return self.active_xiannv_flag
end

function GoddessData:GetXianNvHuanHuaFlag()
	return self.active_huanhua_flag
end

function GoddessData:IsXianNvActive()
	return self.active_xiannv_flag ~= 0
end

-- 获取仙女Pos，获得出战数据
function GoddessData:GetXianNvPos()
	return self.pos_list
end

-- 获取单个仙女xiannv_huanhua_level
function GoddessData:GetXianNvHuanHuaLevel(xiannv_id)
	return self.xiannv_huanhua_level[xiannv_id]
end

-- 获取仙女配置
function GoddessData:IsGoddessSkill(skill_id)
	if not self.xiannv_skill_cfg then
		self.xiannv_skill_cfg = ListToMap(self:GetAllCfg().xiannv, "skill_id")
	end
		
	return (self.xiannv_skill_cfg[skill_id] and true or false)
end

-- 获取仙女配置
function GoddessData:GetXianNvCfg(id)
	return ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").xiannv[id]
end

-- 获取仙女其他配置
function GoddessData:GetXianNvOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").other[1]
end

--获取仙女等级配置
function GoddessData:GetXianNvLevelCfg(id, level)
	if not self.level_attr_level_cfg then
		self.level_attr_level_cfg = ListToMap(self:GetAllCfg().level_attr, "xiannv_id", "level")
	end
	return self.level_attr_level_cfg[id][level] or nil
end

--获取仙女资质配置
function GoddessData:GetXianNvZhiziCfg(id, zhizi)
	if not self.zizhi_attr_level_cfg then
		self.zizhi_attr_level_cfg = ListToMap(self:GetAllCfg().zizhi_attr, "xiannv_id", "level")
	end
	return self.zizhi_attr_level_cfg[id][zhizi] or nil 
end

--获取仙女幻化配置
function GoddessData:GetXianNvHuanHuaCfg(id)
	return ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").huanhua[id]
end

--获取人物技能配置
function GoddessData:GetRoleSkillCfg(skill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id][1]
end

--获取仙女幻化等级配置
function GoddessData:GetXianNvHuanHuaLevelCfg(id, level, is_next)
	if not self.id_level_cfg then
		local beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
		self.id_level_cfg = ListToMap(beauty_cfg.beauty_huanhua_level, "seq", "level")
	end

	local level = level or self.xiannv_huanhua_level[id] or 0
	if is_next then
		level = level + 1
	end
	return self.id_level_cfg[id][level]
end

--根据激活id获得仙女id
function GoddessData:GetXianIdByActiveId(item_id)
	if not xiannv_cfg_active_item then
		self.xiannv_cfg_active_item = ListToMap(self:GetAllCfg().xiannv, "active_item")
	end
	return xiannv_cfg_active_item[item_id] or -1
end

function GoddessData:GetXiannvGongji()
	local xiannv_gongji = 0
	for k,v in pairs(self.pos_list) do
		if v ~= -1 then
			xiannv_gongji = xiannv_gongji + self:GetXianNvLevelCfg(v, GameVoManager.Instance:GetMainRoleVo().level).xiannv_gongji + self:GetXianNvZhiziCfg(v,self:GetXianNvItem(v).xn_zizhi)
		end
	end
	return xiannv_gongji
end

function GoddessData:GetPower(the_post_list, the_level, the_xn_item_list)
	local power = 0
	local pos_list = the_post_list or self.pos_list
	local level = the_level or GameVoManager.Instance:GetMainRoleVo().level
	local xn_item_list = the_xn_item_list or self.xn_item_list

	for k,v in pairs(pos_list) do
		if v ~= -1 then
			local xiannv_cfg = self:GetXianNvLevelCfg(v, GameVoManager.Instance:GetMainRoleVo().level)
			local zhi_zhi_gongji = 0
			if xn_item_list[v].xn_zizhi ~= 0 then
				zhi_zhi_gongji = self:GetXianNvZhiziCfg(v , xn_item_list[v].xn_zizhi).xiannv_gongji
			end
			if k == 1 then
				power = power + (xiannv_cfg.xiannv_gongji + zhi_zhi_gongji)
			else
				power = power + (xiannv_cfg.xiannv_gongji + zhi_zhi_gongji) * GameEnum.ZHUZHAN_XIANNV_SHANGHAI_PRECENT
			end
		end
	end
	for k,v in pairs(xn_item_list) do
		if k ~= pos_list[1] and k ~= pos_list[2] and k ~= pos_list[3] and k ~= pos_list[4] then
			local cfg = self:GetXianNvLevelCfg(k, level)
			local zhi_zhi_gongji = 0
			if v.xn_zizhi > 0 then
				zhi_zhi_gongji = self:GetXianNvZhiziCfg(k,v.xn_zizhi).xiannv_gongji
				power = power + (cfg.xiannv_gongji + zhi_zhi_gongji) * GameEnum.WEI_ZHUZHAN_XIANNV_SHANGHAI_PRECENT
			end
		end
	end
	return math.floor(power)
end

--女神信息 和 女神幻化属性
function GoddessData:GetAllPower(the_post_list, the_level, the_xn_item_list, huanhua_list)
	local power = 0
	the_post_list = the_post_list or self.pos_list
	the_level = the_level or GameVoManager.Instance:GetMainRoleVo().level
	the_xn_item_list = the_xn_item_list or self.xn_item_list
	huanhua_list = huanhua_list or self.xiannv_huanhua_level
	for i=0, 6 do
		local zi_zhi = the_xn_item_list[i].xn_zizhi
		if zi_zhi > 0 then
			local xiannv_cfg = self:GetXianNvCfg(i)

			local level_attr_cfg = self:GetXianNvLevelCfg(i, the_level)
			local zhizhi_attr_cfg = self:GetXianNvZhiziCfg(i, zi_zhi)

			local attr = {}
			if zhizhi_attr_cfg then
				attr.maxhp = zhizhi_attr_cfg.maxhp + level_attr_cfg.maxhp
				attr.gongji = zhizhi_attr_cfg.gongji + level_attr_cfg.gongji
				attr.fangyu = zhizhi_attr_cfg.fangyu + level_attr_cfg.fangyu
				attr.mingzhong = zhizhi_attr_cfg.mingzhong + level_attr_cfg.mingzhong
				attr.xiannv_gongji = zhizhi_attr_cfg.xiannv_gongji + level_attr_cfg.xiannv_gongji
			else
				attr.maxhp = level_attr_cfg.maxhp
				attr.gongji = level_attr_cfg.gongji
				attr.fangyu = level_attr_cfg.fangyu
				attr.mingzhong = level_attr_cfg.mingzhong
				attr.xiannv_gongji = level_attr_cfg.xiannv_gongji
			end
			power = power +	self:GetSingleXiannvPower(i, attr ,the_post_list)
			huanhua_level = huanhua_list[i]
			if huanhua_level > 0 then
				power = power + self:GetHuanhuaPower(i, huanhua_level)
			end
		end
	end
	return power
end

function GoddessData:GetHuanhuaPower(huanhua_id,level)
	local huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(huanhua_id,level)
	return CommonDataManager.GetCapability(huanhua_level_attr)
end

function GoddessData:GetSingleCampPower(pos_index, xiannv_id, xn_item_list)
	local xiannv_id = xiannv_id or self.pos_list[pos_index]
	local power = 0
	local xn_item_list = xn_item_list or self.xn_item_list
	if xiannv_id == -1 then return power end

	local xiannv_cfg = self:GetXianNvLevelCfg(xiannv_id, GameVoManager.Instance:GetMainRoleVo().level)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local zhi_zhi_gongji = 0
	if xn_item_list[xiannv_id].xn_zizhi ~= 0 then
		zhi_zhi_gongji = self:GetXianNvZhiziCfg(xiannv_id , xn_item_list[xiannv_id].xn_zizhi).xiannv_gongji
		if pos_index == 1 then
			power = xiannv_cfg.xiannv_gongji + zhi_zhi_gongji
		else
			power = (xiannv_cfg.xiannv_gongji + zhi_zhi_gongji) * GameEnum.ZHUZHAN_XIANNV_SHANGHAI_PRECENT
		end
	end
	return power
end

function GoddessData:GetAllSingleAttr(the_type, xn_item_list, level)
	local value = 0
	for k,v in pairs(xn_item_list) do
		if the_type == GODDESS_ATTR_TYPE.GONG_JI then
			value = self:GetXianNvLevelCfg(k, level).gongji
			if v.xn_zizhi ~= 0 then
				value= value + self:GetXianNvZhiziCfg(k, v.xn_zizhi).gongji
			end
		elseif the_type == GODDESS_ATTR_TYPE.FANG_YU then
			value = self:GetXianNvLevelCfg(k, level).fangyu
			if v.xn_zizhi ~= 0 then
				value = value + self:GetXianNvZhiziCfg(k, v.xn_zizhi).fangyu
			end
		elseif the_type == GODDESS_ATTR_TYPE.SHENG_MING then
			value = self:GetXianNvLevelCfg(k, level).maxhp
			if v.xn_zizhi ~= 0 then
				value = value + self:GetXianNvZhiziCfg(k, v.xn_zizhi).maxhp
			end
		elseif the_type == GODDESS_ATTR_TYPE.XIANNV_GONGJI then
			value = self:GetXianNvLevelCfg(k, level).xiannv_gongji
			if v.xn_zizhi ~= 0 then
				value = value + self:GetXianNvZhiziCfg(k, v.xn_zizhi).xiannv_gongji
			end
		end
	end
	return value
end

function GoddessData:GetXiannvAttr(xiannv_id)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local level = self:GetXianNvItem(xiannv_id).xn_zizhi
	local xiannv_cfg = self:GetXianNvCfg(xiannv_id)
	local need_mat_item_id = 0
	if level == 0 then
		level = 1
	end
	local zhizhi_attr_cfg = self:GetXianNvZhiziCfg(xiannv_id,level)
	local level_attr_cfg = self:GetXianNvLevelCfg(xiannv_id,role_level)
	local role_skill_cfg = self:GetRoleSkillCfg(xiannv_cfg.skill_id)
	local attr = {}
	attr.maxhp = zhizhi_attr_cfg.maxhp + level_attr_cfg.maxhp
	attr.gongji = zhizhi_attr_cfg.gongji + level_attr_cfg.gongji
	attr.fangyu = zhizhi_attr_cfg.fangyu + level_attr_cfg.fangyu
	attr.mingzhong = zhizhi_attr_cfg.mingzhong + level_attr_cfg.mingzhong
	attr.xiannv_gongji = zhizhi_attr_cfg.xiannv_gongji + level_attr_cfg.xiannv_gongji
	local power = self:GetSingleXiannvPower(xiannv_id, attr)
	attr.power = math.floor(power)
	local skill_info_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[xiannv_cfg.skill_id]
	local all_desc = skill_info_cfg.skill_desc
	attr.skill_name = skill_info_cfg.skill_name

	attr.skill_desc = string.gsub(all_desc,"%[cd_s]", tonumber(role_skill_cfg.cd_s))
	attr.skill_desc = string.gsub(attr.skill_desc,"%[enemy_num]", tonumber(role_skill_cfg.enemy_num))
	if xiannv_id == 6 then
		attr.skill_desc = string.gsub(attr.skill_desc,"%[param_a]", tonumber(role_skill_cfg.param_a)/1000)
	else
		attr.skill_desc = string.gsub(attr.skill_desc,"%[param_a]", tonumber(role_skill_cfg.param_a)/100)
		attr.skill_desc = string.gsub(attr.skill_desc,"%[param_b]", tonumber(role_skill_cfg.param_b/1000))
	end

	if self:GetXianNvItem(xiannv_id).xn_zizhi == 0 then
		attr.need_mat_item = ItemData.Instance:GetItemConfig(xiannv_cfg.active_item).name
		attr.need_mat_value = GameEnum.ACTIVE_ITEM_NUM
		attr.have_mat_value = ItemData.Instance:GetItemNumInBagById(xiannv_cfg.active_item)
		need_mat_item_id = xiannv_cfg.active_item
	else
		attr.need_mat_item = ItemData.Instance:GetItemConfig(zhizhi_attr_cfg.uplevel_stuff_id).name
		attr.need_mat_value = zhizhi_attr_cfg.uplevel_stuff_num
		attr.have_mat_value = ItemData.Instance:GetItemNumInBagById(zhizhi_attr_cfg.uplevel_stuff_id)
		need_mat_item_id = zhizhi_attr_cfg.uplevel_stuff_id
	end
	local data = {}
	data.item_id = need_mat_item_id
	attr.info = data
	attr.bundle, attr.asset = ResPath.GetRoleSkillIcon(xiannv_cfg.skill_id)
	return attr
end

--获取仙女激活所需要的物品
function GoddessData:GetXiannvActiveItemID(xiannv_id)
	return self:GetXianNvCfg(xiannv_id).active_item
end

--获取仙女幻化激活所需要的物品
function GoddessData:GetXiannvHuanhuaActiveItemID(xiannv_id)
	if self:GetXianNvHuanHuaCfg(xiannv_id) then
		return self:GetXianNvHuanHuaCfg(xiannv_id).active_item
	else
		return nil
	end
end

--获取仙女升级所需要的物品
function GoddessData:GetXiannvUpgradeItemID(xiannv_id,level)
	return self:GetXianNvZhiziCfg(xiannv_id, level).uplevel_stuff_id
end

--获取幻化升级所需要的物品
function GoddessData:GetXiannvHuanhuaUpgradeItemID(xiannv_id,level)
	return self:GetXianNvHuanHuaLevelCfg(xiannv_id, level).uplevel_stuff_id
end

--获取未激活的仙女id集合
function GoddessData:GetXiannvUnActiveList()
	local xn_item_list = self.xn_item_list
	local un_active_xiannv_list = {}
	for k,v in pairs(xn_item_list) do
		if v.xn_level == 0 then
			un_active_xiannv_list[#un_active_xiannv_list + 1] = k
		end
	end
	return un_active_xiannv_list
end

--获取已激活的仙女id集合
function GoddessData:GetXiannvActiveList(the_item_list)
	local xn_item_list = the_item_list or self.xn_item_list
	local active_xiannv_list = {}
	for k,v in pairs(xn_item_list) do
		if v.xn_zizhi > 0 then
			active_xiannv_list[#active_xiannv_list + 1]= k
		end
	end
	return active_xiannv_list
end

--获取未激活的仙女幻化id集合
function GoddessData:GetXiannvHuanhuaUnActiveList()
	local huanhua_flag_list = bit:d2b(self.active_huanhua_flag)
	local un_active_huanhua_list = {}
	for i=0, 6 do
		if huanhua_flag_list[32 - i] == 0 then
			un_active_huanhua_list[#un_active_huanhua_list + 1] = i
		end
	end
	return un_active_huanhua_list
end

--获取已激活的仙女幻化id集合
function GoddessData:GetXiannvHuanhuaActiveList()
	local huanhua_flag_list = bit:d2b(self.active_huanhua_flag)
	local active_huanhua_list = {}
	for i=0, 6 do
		if huanhua_flag_list[32 - i] == 1 then
			active_huanhua_list[#active_huanhua_list + 1] = i
		end
	end
	return active_huanhua_list
end

--获取激活所有仙女所需要的物品集合
function GoddessData:GetActiveXiannvNeedItemList()
	local un_active_xiannv_list = self:GetXiannvUnActiveList()
	local need_item_list = {}
	for k,v in pairs(un_active_xiannv_list) do
		need_item_list[#need_item_list + 1] = self:GetXiannvActiveItemID(v)
	end
	return need_item_list
end

--获取可升级的仙女需要的物品集合
function GoddessData:GetXiannvCanUgrageItemList()
	local need_item_info = {}
	local active_xiannv_list = self:GetXiannvActiveList()
	if #active_xiannv_list == 0 then
		return need_item_info
	end
	for k,v in pairs(active_xiannv_list) do
		if self:GetXianZhiZhi(v) < GODDRESS_MAX_LEVEL then
			local zhizhi_cfg = self:GetXianNvZhiziCfg(v,self:GetXianZhiZhi(v))
			need_item_info[#need_item_info + 1] = {}
			need_item_info[#need_item_info].uplevel_stuff_id = zhizhi_cfg.uplevel_stuff_id
			need_item_info[#need_item_info].uplevel_stuff_num = zhizhi_cfg.uplevel_stuff_num
		end
	end
	return need_item_info
end

--获取可激活的仙女幻化需要的物品集合
function GoddessData:GetXiannvCanActiveItemList()
	local need_item_list = {}
	local active_xiannv_huanhua_list = self:GetXiannvHuanhuaUnActiveList()
	if active_xiannv_huanhua_list == 0 then
		return need_item_list
	end
	if #(self:GetXiannvActiveList()) <= 0 then
		return need_item_list
	end
	for k,v in pairs(active_xiannv_huanhua_list) do
		if v ~= nil then
			need_item_list[#need_item_list + 1] = self:GetXiannvHuanhuaActiveItemID(v)
		end
	end
	return need_item_list
end

--获取可升级的仙女幻化需要的物品集合
function GoddessData:GetXiannvHuanhuaCanUgrageItemList()
	local need_item_info = {}
	local active_xiannv_huanhua_list = self:GetXiannvHuanhuaActiveList()
	if #active_xiannv_huanhua_list == 0 then
		return need_item_info
	end
	for k,v in pairs(active_xiannv_huanhua_list) do
		if self.xiannv_huanhua_level[v] < GODDRESS_HUANHUA_MAX_LEVEL then
			local xiannv_huanhua_cfg = self:GetXianNvHuanHuaLevelCfg(v, self.xiannv_huanhua_level[v])
			if xiannv_huanhua_cfg then
				need_item_info[#need_item_info + 1] = {}
				need_item_info[#need_item_info].uplevel_stuff_id = xiannv_huanhua_cfg.uplevel_stuff_id
				need_item_info[#need_item_info].uplevel_stuff_num = xiannv_huanhua_cfg.uplevel_stuff_num
			end
		end
	end
	return need_item_info
end

function GoddessData:GetXianZhiZhi(xiannv_id)
	local xn_item_list = self.xn_item_list
	for k,v in pairs(xn_item_list) do
		if k == xiannv_id then
			return v.xn_zizhi
		end
	end
end

--获取已上阵的仙女
function GoddessData:GetInCampPos()
	local pos_list = self.pos_list
	local new_list = {}
	for k,v in pairs(pos_list) do
		if v ~= -1 then
			new_list[#new_list + 1] = v
		end
	end
	return new_list
end

function GoddessData:GetFaZheRedPoint()
	local sheng_wu_res = self:GetFaZeRed()
	local is_open = OpenFunData.Instance:CheckIsHide("goddess")
	local is_show = sheng_wu_res and is_open
	
	return is_show
end

function GoddessData:GetGongMingRedPoint()
	local sheng_wu_res = self:GetGongMingRed() or self:GetGongMingGridRed()
	local is_open = OpenFunData.Instance:CheckIsHide("goddess")
	local is_show = sheng_wu_res and is_open
	return is_show
end

function GoddessData:GetCampRedPoint(camp_index)
	local is_show_red = false
	local no_in_camp_count = self:GetOpenCampCount() + 1 - #(self:GetInCampPos())
	local active_count = #self:GetXiannvActiveList()

	if (active_count - #(self:GetInCampPos())) > 0 and no_in_camp_count > 0 then
		is_show_red = self:GetCanGoCampState(HaloData.Instance:GetHaloInfo().grade, camp_index)
	end
	return is_show_red
end

--根据光环阶数,判断能否上阵位
function GoddessData:GetCanGoCampState(grade,camp_index)
	if grade == 0 then
		return camp_index == 1
	end
	return camp_index - 1 <= self:GetOpenCampCount() --不包含主阵位
end

function GoddessData:GetCampIndex(lineup_type)
	local index = 1
	if lineup_type == "fight" then
		index = 1
	elseif lineup_type == "assist_one" then
		index = 2
	elseif lineup_type == "assist_two" then
		index = 3
	elseif lineup_type == "assist_three" then
		index = 4
	end
	return index
end

--不包含主阵位
function GoddessData:GetOpenCampCount()
	local halo_grade = HaloData.Instance:GetHaloInfo().grade
	if halo_grade == nil or halo_grade == 0 then return 0 end
	local open_grade_limit_list = self:GetShowHaloGradeList()
	local open_count = 0
	local is_big = true
	for k,v in pairs(open_grade_limit_list) do
		if halo_grade < v then
			if k == 1 then
				open_count = 0
			else
				open_count = k - 1
			end
			is_big = false
			break
		end
	end
	if is_big then
		open_count = 3
	end
	return open_count
end

function GoddessData:JudgeXianIsActive(xiannv_id)
	local active_list = self:GetXiannvActiveList()
	if #active_list == 0 then
		return
	end
	for k,v in pairs(active_list) do
		if v == xiannv_id then
			return true
		end
	end
	return false
end

function GoddessData:JudgeXiannvIsInCamp(xiannv_id)
	local the_list = self:GetInCampPos()
	for k,v in pairs(the_list) do
		if v == xiannv_id then
			return true
		end
	end
	return false
end

function GoddessData:GetXianHuanhuaNum()
	local cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").huanhua
	local num = 0
	for k,v in pairs(cfg) do
		num = num + 1
	end
	return num
end

function GoddessData:GetXiannvLinupType(lineup_type)
	local index = -1
	for k,v in pairs(Lineup_type) do
		if v == lineup_type then
			index = k
			break
		end
	end
	return index
end

function GoddessData:GetPoslistIndex(xiannv_id)
	local index = -1
	for k,v in pairs(self.pos_list) do
		if v == xiannv_id then
			index = k
			break
		end
	end
	return index
end

function GoddessData:GetPoslistIndex(xiannv_id)
	local index = -1
	for k,v in pairs(self.pos_list) do
		if v == xiannv_id then
			index = k
			break
		end
	end
	return index
end

function GoddessData:GetSingleXiannvPower(xiannv_id, attr, pos_list)
	local power = 0
	local pos_list = self.pos_list
	if pos_list[1] == -1 then
		power = attr.maxhp * 0.2 + attr.gongji * 4.1 + attr.fangyu * 3.4 + attr.xiannv_gongji * 1.6
	else
		local pos_index = self:GetPoslistIndex(xiannv_id)
		if pos_index == -1 then  --未激活
			power = (attr.maxhp * 0.2 + attr.gongji * 4.1 + attr.fangyu * 3.4) + attr.xiannv_gongji * 1.6 * GameEnum.WEI_ZHUZHAN_XIANNV_SHANGHAI_PRECENT
		elseif pos_index == 1 then
			power = (attr.maxhp * 0.2 + attr.gongji * 4.1 + attr.fangyu * 3.4 ) + attr.xiannv_gongji * 1.6
		else
			power = (attr.maxhp * 0.2 + attr.gongji * 4.1 + attr.fangyu * 3.4 ) + attr.xiannv_gongji * 1.6 * GameEnum.ZHUZHAN_XIANNV_SHANGHAI_PRECENT
		end
	end
	return power/1.6
end

function GoddessData:GetShowXiannvResId()
	local role_res_id = -1
	local goddess_huanhua_id = self:GetHuanHuaId()
	if goddess_huanhua_id >= 0 then
		role_res_id = self:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid or -1
	else
		local goddess_id = self:GetXiannvId(1)
		if goddess_id == -1 then
			goddess_id = 0
		end
		role_res_id = self:GetXianNvCfg(goddess_id).resid
	end
	return role_res_id
end

function GoddessData:GetShowTriggerName(index)
	local trigger_name = ""
	trigger_name = "show_idle_" .. index
	return trigger_name
end

function GoddessData:GetCampScale(lineup_index)
	scale = Vector3(1.7,1.7,1.7)
	return scale
end

function GoddessData:GetShowInfoRes(xiannv_id)
	if self.huanhua_id < 0 then
		return self:GetXianNvCfg(xiannv_id).resid
	end
	return self:GetXianNvHuanHuaCfg(self.huanhua_id).resid
end

--获取光环对应开启阶数
function GoddessData:GetShowHaloGradeList()
	return self.halo_limit_grade
end

--获取可激活的仙女
function GoddessData:GetCanActiveXiannvId()
	for k,v in pairs(self.xn_item_list) do
		if v.xn_zizhi <= 0 then
			local active_item = self:GetXianNvCfg(k).active_item
			if ItemData.Instance:GetItemNumInBagById(active_item) > 0 then
				return k
			end
		end
	end
	return -1
end

--重新排序女神位置 已激活-未激活
function GoddessData:GetShowXnIdList()
	local active_list = self:GetXiannvActiveList()
	local no_active_list = self:GetXiannvUnActiveList()
	local new_list = {}
	for k,v in ipairs(active_list) do
		table.insert(new_list, v)
	end
	for k,v in ipairs(no_active_list) do
		table.insert(new_list, v)
	end
	return new_list
end

--获取仙女圣物技能配置
function GoddessData:GetXianNvShengWuSkillCfg(id, level)
	if not self.skill_cfg then
		self.skill_cfg = ListToMap(self:GetAllCfg().skill_cfg, "skill_id", "level")
	end
	return self.skill_cfg[id][level] or nil 
end

--获取仙女圣物技能名字
function GoddessData:GetXianNvShengWuSkillName(id)
	local info_cfg = self:GetXianNvShengWuSkillCfg(id, 0)
	if info_cfg ~= nil then
		return info_cfg.name or ""
	end
	return ""
end

--获取圣物格子配置
function GoddessData:GetXianNvGridIconCfg(grid_id)
	if not self.grid_icon_cfg then
		self.grid_icon_cfg = ListToMap(self:GetAllCfg().grid_depend_cfg, "grid_id")
	end
	return self.grid_icon_cfg[grid_id] or nil
end

--获取圣物格子是否可以点击升级
function GoddessData:GetXianNvGridIconIsCan(info_data)
	if info_data == nil then return false end
	local grid_id1 = tonumber(info_data.grid_id1)
	local grid_id2 = tonumber(info_data.grid_id2)
	local grid_id3 = tonumber(info_data.grid_id3)
	local grid_id4 = tonumber(info_data.grid_id4)
	local level = self:GetXiannvShengwuGridLevel(info_data.grid_id)
	local level1 = 10000
	local level2 = 10000
	local level3 = 10000
	local level4 = 10000
	if grid_id1 then
		level1 = self:GetXiannvShengwuGridLevel(grid_id1)
	end
	if grid_id2 then
		level2 = self:GetXiannvShengwuGridLevel(grid_id2)
	end
	if grid_id3 then
		level3 = self:GetXiannvShengwuGridLevel(grid_id3)
	end
	if grid_id4 then
		level4 = self:GetXiannvShengwuGridLevel(grid_id4)
	end

	if level < level1 and level < level2 and level < level3 and level < level4 then
		return true
	end

	return false
end

--获取圣物格子是否可以升级
function GoddessData:GetXianNvGridIconIsCanUp(grid_id)
	local level = self:GetXiannvShengwuGridLevel(grid_id)
	local info_data = self:GetXianNvGridIconCfg(grid_id)
	local is_can = false
	local can_click = true

	if info_data then
		can_click = self:GetXianNvGridIconIsCan(info_data)
	end

	if can_click then
		local next_data = self:GetXianNvGongMingCfg(grid_id, level + 1)
		local now_data = self:GetXianNvGongMingCfg(grid_id, level)
		if next_data and now_data then
			local cur_lingye = GoddessData.Instance:GetShengWuLingYeValue()
			if cur_lingye >= now_data.upgrade_need_ling then
				is_can = true
			end
		end
	end
	info_data = nil
	return is_can
end

function GoddessData:GetGridLineAllCfg()
	if not self.grid_client_cfg then
		self.grid_client_cfg = self:GetAllCfg().grid_client_cfg
	end
	return self.grid_client_cfg
end

function GoddessData:GetGridLineCfg(grid_id)
	local client_cfg = self:GetGridLineAllCfg()
	return client_cfg[grid_id] or nil
end

function GoddessData:GetGridLineShowByGrid(grid_id)
	local info_list = self.show_client_line_list
	if info_list == nil then
		return false
	end
	return info_list[grid_id] and true or false
end

-- 最低等级为1，，不显示线条。。所以循环到2就可以
function GoddessData:GetGridShowLine()
	local level_list = self:GetGridLevelList()
	local show_list = {}
	local re_show_list = {}
	local re_show_list2 = {}
	local is_has_line = false

	for i = self.show_client_max_level, 1, -1 do
		if level_list[i] ~= nil then
			for k, v in pairs(level_list[i]) do
				local grid_id = v.grid_id
				local info_data = self:GetXianNvGridIconCfg(grid_id)
				if info_data then
					if re_show_list[grid_id] == true then
						local grid_id1 = tonumber(info_data.grid_id1)
						local grid_id2 = tonumber(info_data.grid_id2)
						local grid_id3 = tonumber(info_data.grid_id3)
						local grid_id4 = tonumber(info_data.grid_id4)
						if grid_id1 ~= nil then
							re_show_list[grid_id1] = true
						end
						if grid_id2 ~= nil then
							re_show_list[grid_id2] = true
						end
						if grid_id3 ~= nil then
							re_show_list[grid_id3] = true
						end
						if grid_id4 ~= nil then
							re_show_list[grid_id4] = true
						end
					elseif re_show_list2[grid_id] == true then
						--
					else
						local is_can = self:GetXianNvGridIconIsCan(info_data)
						if is_has_line == false then
							is_has_line = is_can
						end
						if is_can then
							show_list[grid_id] = true
							local grid_id1 = tonumber(info_data.grid_id1)
							local grid_id2 = tonumber(info_data.grid_id2)
							local grid_id3 = tonumber(info_data.grid_id3)
							local grid_id4 = tonumber(info_data.grid_id4)
							if grid_id1 ~= nil then
								re_show_list[grid_id1] = true
							end
							if grid_id2 ~= nil then
								re_show_list[grid_id2] = true
							end
							if grid_id3 ~= nil then
								re_show_list[grid_id3] = true
							end
							if grid_id4 ~= nil then
								re_show_list[grid_id4] = true
							end
						end
					end
				end
				info_data = nil
			end
		end
	end
	if is_has_line == true then
		return show_list
	end
	return nil
end

function GoddessData:GetGridLevelList()
	if self.show_client_level_list == nil then
		self.show_client_level_list = {}
	else
		return self.show_client_level_list
	end
	self.show_client_max_level = 0

	local client_cfg = self:GetGridLineAllCfg()
	for k, v in pairs(client_cfg) do
		if self.show_client_level_list[v.grid_sort] == nil then
			self.show_client_level_list[v.grid_sort] = {}
			if self.show_client_max_level < v.grid_sort then
				self.show_client_max_level = v.grid_sort
			end
		end
		table.insert(self.show_client_level_list[v.grid_sort], v)
	end

	return self.show_client_level_list
end


--获取圣物共鸣格子属性配置
function GoddessData:GetXianNvGongMingCfg(grid_id, level)
	if not self.gongming_grid_cfg then
		self.gongming_grid_cfg = ListToMap(self:GetAllCfg().gongming_cfg, "grid_id", "level")
	end
	return self.gongming_grid_cfg[grid_id][level] or nil
end

-- 获取格子等级
function GoddessData:GetXiannvShengwuGridLevel(index)
	return self.grid_level_list[index] or 0
end

-- 获取格子等级
function GoddessData:SetXiannvShengwuGridLevel(protocol)
	self.grid_level_list[protocol.param1] = protocol.param2
	self.show_client_line_list = self:GetGridShowLine()
end

-- 获取灵液值
function GoddessData:GetShengWuLingYeValue()
	return self.shengwu_lingye or 0
end

-- 设置灵液值
function GoddessData:SetShengWuLingYeValue(num)
	if self.last_ling_ye == nil then
		self.last_ling_ye = num
	else
		self.last_ling_ye = self.shengwu_lingye
	end
	self.shengwu_lingye = num
end

function GoddessData:GetLingYeChange()
	local num = 0
	if self.last_ling_ye ~= nil and self.shengwu_lingye ~= nil then
		num = self.shengwu_lingye - self.last_ling_ye
	end

	return num
end

-- 女神圣物回忆获取的经验列表
function GoddessData:SetXiannvShengwuChouExpList(protocol)
	self.shengwu_chou_id = protocol.shengwu_chou_id
	self.shengwu_chou_type = protocol.shengwu_chou_type
	self.shengwu_chou_exp = protocol.chou_list
end

-- 获取女神圣物回忆获取的经验列表
function GoddessData:GetXiannvShengwuChouExpList()
	return self.shengwu_chou_id, self.shengwu_chou_exp
end

-- 获取女神圣物回忆类型
function GoddessData:GetXiannvShengwuChouType()
	return self.shengwu_chou_type
end

-- 获取觅灵格子总属性
function GoddessData:GetXiannvGridTotalAttr()
	local attr_list = {}
	local level = 0
	local one_cfg = {}
	local value_k = ""
	local value_n = 0
	for i = 0, XIANNV_SHENGWU_GONGMING_MAX_GRID_ID do
		level = self:GetXiannvShengwuGridLevel(i)
		one_cfg = self:GetXianNvGongMingCfg(i, level)
		value_k, value_n = self:GetOneGridAttrDes(one_cfg)
		if value_k ~= nil then
			if attr_list[value_k] == nil then
				attr_list[value_k] = value_n
			else
				attr_list[value_k] = attr_list[value_k] + value_n
			end
		end
	end
	return attr_list
end

function GoddessData:GetOneGridAttrDes(data_cfg)
	if data_cfg == nil then
		return nil, nil
	end
	local attr_list = CommonDataManager.GetAttributteNoUnderline(data_cfg)
	local is_attr_ibutte = false		--是否进阶属性
	for k, v in pairs(attr_list) do
		if v > 0 then
			return k, v
		end
	end

	return nil, nil
end

-- 1为普通，2为高级
function GoddessData:GetXianNvChouExpStuff(index)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").other[1]
	if index == GODDESS_CHOUEXP_TYPE.PERFECT then
		return other_cfg.chou_exp_gold
	else
		return other_cfg.chou_exp_stuff
	end
end

--获取仙女圣物配置
function GoddessData:GetXianNvShengWuCfg(id, level)
	if not self.shengwu_cfg then
		self.shengwu_cfg = ListToMap(self:GetAllCfg().shengwu_cfg, "shengwu_id", "level")
	end
	return self.shengwu_cfg[id][level] or nil
end

--获取仙女圣物名字
function GoddessData:GetXianNvShengWuCfgName(id)
	local one_cfg = self:GetXianNvShengWuCfg(id, 0)
	if one_cfg ~= nil then
		return one_cfg.name or ""
	end
	return ""
end

-- 获取圣物总属性
function GoddessData:GetXiannvShengWuTotalAttr()
	local attr_list = {}
	local level = 0
	local one_cfg = {}
	local value_k = ""
	local value_n = 0
	for i = 0, XIANNV_SHENGWU_MAX_ID do
		local info_data = self:GetXiannvScShengWuIconAttr(i)
		one_cfg = self:GetXianNvShengWuCfg(i, info_data.level)
		local now_attr = CommonDataManager.GetAttributteNoUnderline(one_cfg)

		for k, v in pairs(now_attr) do
			if v > 0 then
				if attr_list[k] == nil then
					attr_list[k] = v
				else
					attr_list[k] = attr_list[k] + v
				end
			end
		end
	end

	return attr_list
end

-- 获取服务器圣物Icon等级
function GoddessData:GetXiannvScShengWuIconAttr(index)
	return self.shengwu_list[index] or {level = 0, exp = 0}
end

-- 设置服务器圣物Icon等级
function GoddessData:SetXiannvScShengWuIconAttr(protocol)
	if self.shengwu_list[protocol.param1] then
		self.shengwu_list[protocol.param1].level = protocol.param2
		self.shengwu_list[protocol.param1].exp = protocol.param4
	end
end

-- 女神圣物抽经验结果（用于客户端播放特效）
function GoddessData:SetXiannvShengwuChouExpResult(protocol)
	self.chou_exp_is_auto_fetch = protocol.is_auto_fetch
	self.chou_exp_add_exp_list = protocol.add_exp_list
end

-- 获取女神圣物抽经验结果（用于客户端播放特效）
function GoddessData:GetXiannvShengwuChouExpResult()
	return self.chou_exp_is_auto_fetch, self.chou_exp_add_exp_list
end

-- 设置觅灵列表
function GoddessData:SetXiannvShengwuMilingList(protocol)
	self.sc_miling_list = protocol.miling_list
end

function GoddessData:GetAuraSearchListInfo()
	function sortfun(a, b)
		return a < b
	end
	table.sort(self.sc_miling_list, sortfun)
	return self.sc_miling_list
end

function GoddessData:GetAuraAnimationStatus()
    return self.is_skip_aura_search_animation
end

function GoddessData:SetAuraIsPlayAnimation(switch)
	self.is_skip_aura_search_animation = switch
end

function GoddessData:SetAuraDoubleReceive(switch)
	self.is_aura_double_receive = switch
end

function GoddessData:GetAuraDoubleReceive()
	return self.is_aura_double_receive
end

function GoddessData:GetAuraNumsByLingNums(nums)
    local  aura_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").chou_ling_cfg
    aura_cfg = ListToMap(aura_cfg,"ling_count")
    if nums <= 6 then
       return aura_cfg[nums].ling_value
    end
end

function GoddessData:SetHadUsedFreeTimes(protocol)
	self.used_free_aura_search_times = protocol.param1
	self.cur_gold_miling_times = protocol.param2
	self.reveived_times = protocol.param3
end

function GoddessData:GetCurrentFreeTimes()
	if self.search_aura_daliy_free_time == nil then
		self.search_aura_daliy_free_time = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").other[1].chou_ling_free_times or 10
	end

    self.current_free_aura_search_times = self.search_aura_daliy_free_time - self.used_free_aura_search_times
    return  self.current_free_aura_search_times
end

function GoddessData:GetAuraSearchConsume()
	if self.search_consume_cfg == nil then
		self.search_consume_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").chou_ling_consume
	end

	local gold = 0
	if self.cur_gold_miling_times == nil then
		return gold
	end

	-- if self.cur_gold_miling_times then
	-- end
	for k,v in pairs(self.search_consume_cfg) do
		if self.cur_gold_miling_times >= v.chou_ling_times then
			gold = v.consume_gold
		end
	end

	return gold
end

function GoddessData:GetAuraSearchReveivedTimes()
   return self.reveived_times or 0
end

function GoddessData:GetAuraShengYuNums()
	if self.sheng_yu_num == nil then
		self.sheng_yu_num = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").other[1].double_ling_gold
	end

	return ItemData.Instance:GetItemNumInBagById(self.sheng_yu_num ) or 0
end

function GoddessData:GetOtherByStr(str)
	return ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto").other[1][str]
end

function GoddessData:GetFaZeRed()
	local has_red = false
	local check_item = self:GetOtherByStr("chou_exp_stuff") or 0
	local item_cfg = ItemData.Instance:GetItem(check_item)
	if item_cfg ~= nil then
		has_red = true
	end

	return has_red
end

function GoddessData:GetGongMingRed()
	if OpenFunData.Instance:CheckIsHide("goddess_gongming") == false then return false end
	local has_red = false
	local fetch_count = self:GetOtherByStr("fetch_ling_time") or 0
	if self.used_free_aura_search_times == nil or self.reveived_times == nil then
		return has_red
	end

	if (fetch_count - self.reveived_times) > 0 then
		has_red = true
	end

	return has_red
end

function GoddessData:GetGongMingGridRed()
	if OpenFunData.Instance:CheckIsHide("goddess_gongming") == false then return false end

	for i = 0, XIANNV_SHENGWU_GONGMING_MAX_GRID_ID do
		if self:GetXianNvGridIconIsCanUp(i) then
			return true
		end
	end
	return false
end

function GoddessData:GetShengWuAddExp(shengwu_id, old_level, cur_level, old_exp, cur_exp)
	local total_exp = 0
	for i = old_level, cur_level do
		if i == old_level then
			local cfg = self:GetXianNvShengWuCfg(shengwu_id, old_level)
			total_exp = total_exp + cfg.upgrade_need_exp - old_exp
		elseif i == cur_level then
			total_exp = total_exp + cur_exp
		else
			local cfg = self:GetXianNvShengWuCfg(shengwu_id, i)
			total_exp = total_exp + cfg.upgrade_need_exp
		end
	end

	return total_exp
end