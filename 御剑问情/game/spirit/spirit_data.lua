SpiritData = SpiritData or BaseClass()

SpiritDataExchangeType = {
	Type = 5
}

SOUL_ATTR_NAME_LIST = {
	[0] = "gongji",
	[1] = "fangyu",
	[2] = "maxhp",
	[3] = "mingzhong",
	[4] = "shanbi",
	[5] = "baoji",
	[6] = "jianren",
}

-- 天赋属性图标
SPIRIT_TALENT_ICON_LIST = {
	[1] = "icon_info_gj",
	[2] = "icon_info_fy",
	[3] = "icon_info_hp",
	[4] = "icon_info_mz",
	[5] = "icon_info_sb",
	[6] = "icon_info_bj",
	[7] = "icon_info_kb",
}

SPIRIT_ATTR_TYPE = {
	[1] = "fangyu",
	[2] = "gongji",
	[3] = "maxhp",
}

SPIRIT_ATTR_APTITUDE = {
	["gongji_zizhi"] = "gongji",
	["maxhp_zizhi"] = "maxhp",
	["fangyu_zizhi"] = "fangyu",
}

SPIRIT_QUALITY = {
	BLUE = 0,
	PURPLE = 1,
}

SOUL_SPECIAL_COLOR = {
	ORANGE = 3,
	RED = 4,
}

QUICK_FLUSH_STATE = {
	NO_START = 0,
	REQUIRE_START = 1,
	GAI_MING_ZHONG = 2,
	CHOU_HUN_ZHONG = 3
}

SOUL_FROM_VIEW = {SOUL_POOL = 1, SOUL_BAG = 2}

LINGPO_ANIM_TIME = 0.3

-- 彩色命魂对应index
SPECIAL_SOUL_INDEX = {
	SPECIAL_1 = 7,
	SPECIAL_2 = 8,
}

function SpiritData:__init()
	if SpiritData.Instance ~= nil then
		return
	end
	SpiritData.Instance = self
	self.spirit_info = {}
	self.item_list = {}
	self.warehouse_item_list = {}
	self.slot_soul_info = {}
	self.soul_bag_info = {}
	self.spirit_meet_info = {}
	self.fazhen_info = {}
	self.halo_info = {}
	self.sprite_skill_cell_data = {}
	self.is_no_play_ani = false
	local level_data=ListToMap(self.GetSpiritLevelConfig(),"level")
	self.max_spirit_level= level_data[#level_data].level
	self.skill_cur_sprite_index = 0
	self.skill_cur_cell_index = 1
	self.skill_storage_cell_index = 0
	self.cur_lingpo_type = -1
	self.skill_num_cfg = self:GetSkillNumLevelCfg()
	self.home_info = {}
	self.home_list = {}
	self.home_record_list = {}
	self.spirit_explore = {}
	self.home_record_result = {}
	self.user_pet_special_img = -1
	self.open_param = nil
	self.soul_select_color = -1
	self.hunli_auto_buy = false
	self.change_state = QUICK_FLUSH_STATE.NO_START
	local jingling_cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto")

	self.jingling_huanhua_list = ListToMapList(jingling_cfg.jingling_phantom, "type")
	self.huanhua_stuff_dic = ListToMap(jingling_cfg.jingling_phantom, "stuff_id")

	self.lingpo_cfg = ListToMap(jingling_cfg.jingling_card, "type", "level")

	self.jingling_advantage_cfg = ConfigManager.Instance:GetAutoConfig("jingling_advantage_cfg_auto")

	RemindManager.Instance:Register(RemindName.SpiritBag, BindTool.Bind(self.GetSpiritBagRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritUpgrade, BindTool.Bind(self.GetSpiritUpgradeRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritUpgradeWuxing, BindTool.Bind(self.GetUpgradeWuxingRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritLingpo, BindTool.Bind(self.GetLingPoRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritFreeHunt, BindTool.Bind(self.GetFreeHuntRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritWarehouse, BindTool.Bind(self.GetWarehouseRemind, self))  -- 猎取
	RemindManager.Instance:Register(RemindName.SpiritHomeBreed, BindTool.Bind(self.GetSpiritHomeBreed, self))
	RemindManager.Instance:Register(RemindName.SpiritHomeReward, BindTool.Bind(self.GetHomeRewardRedRemind, self))
	-- RemindManager.Instance:Register(RemindName.SpiritHomeRevnge, BindTool.Bind(self.GetHomeRevngeRemind, self))
	-- RemindManager.Instance:Register(RemindName.SpiritPlunder, BindTool.Bind(self.GetSpiritPlunderRemind, self))
	-- RemindManager.Instance:Register(RemindName.SpiritExplore, BindTool.Bind(self.GetSpiritExploreRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritSkillLearn, BindTool.Bind(self.GetSpiritLearnRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritSoul, BindTool.Bind(self.GetSpiritSoulRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritSoulGet, BindTool.Bind(self.GetSpiritSoulGetRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritShangZhen, BindTool.Bind(self.GetSpiritShangZhenRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritZhenFaUplevel, BindTool.Bind(self.GetSpiritZhenFaUpRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritZhenFaHunyu, BindTool.Bind(self.GetSpiritFaHunyuRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritMeet, BindTool.Bind(self.GetSpiritMeetRemind, self))
	RemindManager.Instance:Register(RemindName.SpiritHuanhua, BindTool.Bind(self.GetSpiritHuanhua,self))
	RemindManager.Instance:Register(RemindName.SpiritSpecialSpirit,BindTool.Bind(self.GetSpecialSpiritRemind, self))

end

function SpiritData:__delete()
	-- self.spirit_info = {}
	RemindManager.Instance:UnRegister(RemindName.SpiritBag)
	RemindManager.Instance:UnRegister(RemindName.SpiritUpgrade)
	RemindManager.Instance:UnRegister(RemindName.SpiritUpgradeWuxing)
	RemindManager.Instance:UnRegister(RemindName.SpiritLingpo)
	RemindManager.Instance:UnRegister(RemindName.SpiritFreeHunt)
	RemindManager.Instance:UnRegister(RemindName.SpiritWarehouse)
	RemindManager.Instance:UnRegister(RemindName.SpiritHomeBreed)
	RemindManager.Instance:UnRegister(RemindName.SpiritHomeReward)
	-- RemindManager.Instance:UnRegister(RemindName.SpiritHomeRevnge)
	-- RemindManager.Instance:UnRegister(RemindName.SpiritPlunder)
	-- RemindManager.Instance:UnRegister(RemindName.SpiritExplore)
	RemindManager.Instance:UnRegister(RemindName.SpiritSkillLearn)
	RemindManager.Instance:UnRegister(RemindName.SpiritSoul)
	RemindManager.Instance:UnRegister(RemindName.SpiritSoulGet)
	RemindManager.Instance:UnRegister(RemindName.SpiritShangZhen)
	RemindManager.Instance:UnRegister(RemindName.SpiritZhenFaUplevel)
	RemindManager.Instance:UnRegister(RemindName.SpiritZhenFaHunyu)
	RemindManager.Instance:UnRegister(RemindName.SpiritMeet)
	RemindManager.Instance:UnRegister(RemindName.SpiritHuanhua)
	RemindManager.Instance:UnRegister(RemindName.SpiritSpecialSpirit)


	self.spirit_info = {}
	self.chest_shop_mode = nil
	self.free_time = nil
	self.warehouse_item_list = {}
	self.exchange_score = nil
	self.item_list = {}
	self.slot_soul_info = {}
	self.soul_bag_info = {}
	self.fazhen_info = {}
	self.halo_info = {}
	self.is_no_play_ani = nil
	self.zhenfa_attr_list = {}
	self.skill_num_cfg = {}
	self.home_info = {}
	self.home_list = {}
	self.home_record_list = {}
	self.spirit_meet_info = {}

	UnityEngine.PlayerPrefs.DeleteKey("slotnewindex")
	SpiritData.Instance = nil
end

function SpiritData:GetSpiritHuanhua()
	return next(self:ShowHuanhuaRedPoint()) ~= nil and 1 or 0
end

function SpiritData:ClearData()
	self.item_list = {}
end

-- 配置
function SpiritData:GetMaxSpiritGroup()
	return #ConfigManager.Instance:GetAutoConfig("jingling_auto").group
end

function SpiritData:GetSpiritGroup()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").group
end

function SpiritData:GetSpiritHuanImageConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").phantom_image
end

function SpiritData:GetMaxSpiritHuanhuaImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_auto").phantom_image
end

function SpiritData:GetSpiritLevelConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").uplevel
end

function SpiritData:GetSpiritHuanhuaLevelConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").jingling_phantom
end

function SpiritData:GetSpiritImageConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").jingling_image
end

-- 精灵技能
function SpiritData:GetSpiritSkillCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").skill
end

-- 精灵技能刷新
function SpiritData:GetSpiritSkillRefreshCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").skill_refresh
end

-- 精灵技能图鉴
function SpiritData:GetSpiritSkillBookCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").skill_book
end

function SpiritData:GetSpiritOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1]
end


-- 精灵兑换
function SpiritData:GethuntSpiritPriceCfg()
	return ConfigManager.Instance:GetAutoConfig("chestshop_auto").other
end

function SpiritData:GetSpiritResourceCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").soul_name
end

-- 全民比拼仙宠
function SpiritData:GetHuanHuaSpiritResourceCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").phantom_image
end

-- 获取精灵命魂配置
function SpiritData:GetSpiritSoulCfg(id)
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou[id]
end

function SpiritData:GetAllSpiritSoulCfg()
	-- body
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou
end

-- 获取精灵命魂经验配置
function SpiritData:GetSpiritSoulExpCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou_exp
end

-- 获取抽取精灵命魂消耗魂力配置
function SpiritData:GetSpiritCallSoulCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").chouhun
end

-- 获取精灵命魂槽开启配置
function SpiritData:GetSpiritSoulOpenCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunge_activity_condition
end

-- 精灵法阵阶数配置
function SpiritData:GetSpiritFazhenGradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade
end

-- 精灵法阵最大阶数配置
function SpiritData:GetMaxSpiritFazhenGrade()
	return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade
end

-- 精灵法阵形象配置
function SpiritData:GetSpiritFazhenImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").image_list
end

-- 精灵法阵特殊形象配置
function SpiritData:GetSpiritFazhenSpecialImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
end

-- 精灵法阵特殊形象个数
function SpiritData:GetMaxSpiritFazhenSpecialImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
end

-- 精灵法阵特殊形象进阶
function SpiritData:GetSpiritFazhenSpecialImageUpgrade()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_image_upgrade
end

-- 精灵光环阶数配置
function SpiritData:GetSpiritHaloGradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
end

-- 精灵光环最大阶数配置
function SpiritData:GetMaxSpiritHaloGrade()
	return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
end

-- 精灵光环形象配置
function SpiritData:GetSpiritHaloImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").image_list
end

-- 精灵光环特殊形象配置
function SpiritData:GetSpiritHaloSpecialImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
end

-- 精灵光环特殊形象配置
function SpiritData:GetMaxSpiritHaloSpecialImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
end

-- 精灵光环特殊形象进阶
function SpiritData:GetSpiritHaloSpecialImageUpgrade()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_image_upgrade
end

-- 精灵光环特殊形象进阶
function SpiritData:GetExploreModeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").explore_reward_show
end

-- 精灵阵法信息
function SpiritData:GetSpiritZhenfaCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").xianzhen
end

--精灵魂玉信息
function SpiritData:GetSpiritHunyuCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").xianzhen_hunyu
end

--灵魄显示信息
function SpiritData:GetSpiritLingPoShowCfg()
	if self.lingpo_show_cfg == nil then
		local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").show_card
		self.lingpo_show_cfg = ListToMap(cfg, "type")
	end
	return self.lingpo_show_cfg
end

-- 协议
function SpiritData:SetSpiritInfo(protocol)

	self.spirit_info.jingling_name = protocol.jingling_name
	self.spirit_info.use_jingling_id = protocol.use_jingling_id
	self.spirit_info.use_imageid = protocol.use_imageid
	self.spirit_info.m_active_image_flag = protocol.m_active_image_flag
	self.spirit_info.special_img_active_flag_high = protocol.special_img_active_flag_high
	self.spirit_info.special_img_active_flag_low = protocol.special_img_active_flag_low
	self.spirit_info.phantom_imageid = protocol.phantom_imageid
	self.spirit_info.count = protocol.count

	--精灵技能
	self.spirit_info.skill_storage_list = protocol.skill_storage_list
	self.spirit_info.skill_refresh_item_list = protocol.skill_refresh_item_list
	self.spirit_info.phantom_level_list = protocol.phantom_level_list
	self.spirit_info.jingling_list = protocol.jingling_list
	--精灵阵法
	self.spirit_info.xianzhen_level = protocol.xianzhen_level
	self.spirit_info.xianzhen_exp = protocol.xianzhen_exp
	self.spirit_info.xianzhen_up_count = protocol.xianzhen_up_count
	self.spirit_info.hunyu_level_list = protocol.hunyu_level_list
	--灵魄
	self.spirit_info.ling_po_list = protocol.jinglingcard_list
	-- print_error(self.spirit_info.jingling_list)
	SpiritNewSysData.Instance:CreateLevelList(self.spirit_info.jingling_list)
	SpiritNewSysData.Instance:CreateUnFightLevelList(self.spirit_info.jingling_list)
	SpiritNewSysData.Instance:CreateAptitudeLevelList(self.spirit_info.jingling_list)
end

function SpiritData:SetSpiritSkillFreeRefreshTimes(times)
	self.spirit_info.skill_free_refresh_times = times
end

function SpiritData:GetSpiritInfo()
	return self.spirit_info
end

-- 设置上一次点击的类型，  1抽、 10连抽
function SpiritData:SetChestshopMode(chest_shop_mode)
	self.chest_shop_mode = chest_shop_mode
end

function SpiritData:SetHuntSpiritItemList(item_list)
	self.item_list = item_list
	SpiritCtrl.Instance.spirit_view:Flush("hunt")
	TipsCtrl.Instance:ShowTreasureView(self.chest_shop_mode)
	SpiritCtrl.Instance:SendGetSpiritScore()
end

function SpiritData:GetHuntSpiritItemList()
	return self.item_list or {}
end

-- 设置是否播放抽奖动画
function SpiritData:SetPlayAniState(value)
	self.is_no_play_ani = value or false
end

function SpiritData:IsNoPlayAni()
	return self.is_no_play_ani
end

function SpiritData:SetHuntSpiritFreeTime(time)
	self.free_time = time
	SpiritCtrl.Instance.spirit_view:Flush("hunt")
end

-- 获取猎取间隔时间
function SpiritData:GetHuntSpiritFreeTime()
	return self.free_time or 0
end

function SpiritData:SetHuntSpiritWarehouseList(item_list)
	-- self.warehouse_item_list = item_list
	self.warehouse_item_list = self:GetBagBestSpirit(item_list, true)
	SpiritCtrl.Instance.spirit_view:Flush("warehouse")
end

-- 获取仓库数据
function SpiritData:GetHuntSpiritWarehouseList()
	return self.warehouse_item_list or {}
end

-- 设置精灵命魂槽信息
function SpiritData:SetSpiritSlotSoulInfo(protocol)
	self.slot_soul_info.notify_reason = protocol.notify_reason
	self.slot_soul_info.slot_activity_flag = protocol.slot_activity_flag
	self.slot_soul_info.slot_list = protocol.slot_list
	self.cur_hunshou_cfg = nil
end

function SpiritData:GetSpiritSlotSoulInfo()
	return self.slot_soul_info
end

function SpiritData:GetSpiritSoulTotalZhanLi()
	local total_capability = 0
	local slot_soul_info = self:GetSpiritSlotSoulInfo() or {}
	local slot_list = slot_soul_info.slot_list or {}
	local total_attr_list = CommonStruct.AttributeNoUnderline()
	for k, v in pairs(slot_list) do
		if v.id > 0 then
			local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
			local attr_list = self:GetSoulAttrCfg(v.id, v.level) or {}
			total_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = total_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
		end
	end

	total_capability = CommonDataManager.GetCapabilityCalculation(total_attr_list)

	return total_capability
end

function SpiritData:SetSpiritSoulBagInfo(protocol)
	self.soul_bag_info.notify_reason = protocol.notify_reason
	self.soul_bag_info.hunshou_exp = protocol.hunshou_exp
	self.soul_bag_info.liehun_color = protocol.liehun_color
	self.soul_bag_info.hunli = protocol.hunli
	self.soul_bag_info.liehun_pool = protocol.liehun_pool
	self.soul_bag_info.grid_list = protocol.grid_list
end

function SpiritData:GetSpiritSoulBagInfo()
	return self.soul_bag_info
end

-- 设置精灵法阵信息
function SpiritData:SetSpiritFazhenInfo(protocol)
	self.fazhen_info.grade = protocol.grade
	self.fazhen_info.used_imageid = protocol.used_imageid
	self.fazhen_info.active_image_flag = protocol.active_image_flag
	self.fazhen_info.grade_bless_val = protocol.grade_bless_val
	self.fazhen_info.active_special_image_flag = protocol.active_special_image_flag
	self.fazhen_info.active_special_image_list = bit:d2b(self.fazhen_info.active_special_image_flag)
	self.fazhen_info.special_img_grade_list = protocol.special_img_grade_list
end

function SpiritData:GetSpiritFazhenInfo()
	return self.fazhen_info
end

-- 设置精灵光环信息
function SpiritData:SetSpiritHaloInfo(protocol)
	self.halo_info.grade = protocol.grade
	self.halo_info.used_imageid = protocol.used_imageid
	self.halo_info.active_image_flag = protocol.active_image_flag
	self.halo_info.grade_bless_val = protocol.grade_bless_val
	self.halo_info.active_special_image_flag = protocol.active_special_image_flag
	self.halo_info.active_special_image_list = bit:d2b(self.halo_info.active_special_image_flag)
	self.halo_info.special_img_grade_list = protocol.special_img_grade_list
end

--设置特殊精灵信息
function SpiritData:SetSpecialSpiritInfo(protocol)
	self.special_jingling_flag = bit:d2b(protocol.special_jingling_flag) 
	self.active_jingling_timestamp = protocol.active_jingling_timestamp
	self.special_jingling_fetch_flag = bit:d2b(protocol.special_jingling_fetch_flag)
end

function SpiritData:GetSpiritHaloInfo()
	return self.halo_info
end

-- 获取展示精灵列表
function SpiritData:GetDisplaySpiritList()
	local chest_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").rare_item_list
	local list = {}
	for k, v in pairs(chest_cfg) do
		if v.xunbao_type == XUNBAO_TYPE.JINGLING_TYPE then
			list[v.display_index] = {item_id = v.rare_item_id}
		end
	end
	return list
end

-- 获取兑换配置
function SpiritData:GetSpiritExchangeCfgList()
	local list = {}
	local convert_cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k, v in pairs(convert_cfg) do
		if v.conver_type == SpiritDataExchangeType.Type then
			-- local copy_table = TableCopy(v)
			-- copy_table.param = {strengthen_level = 1}
			table.insert(list, v)
		end
	end
	return list
end

-- 精灵积分
function SpiritData:SetSpiritExchangeScore(score)
	self.exchange_score = score
	SpiritCtrl.Instance.spirit_view:Flush("exchange")
end

function SpiritData:GetSpiritExchangeScore()
	return self.exchange_score or 0
end

-- 获取当前空的精灵格子
function SpiritData:HasSameSprite(item_id)
	for k,v in pairs(self.spirit_info.jingling_list) do
		if v.item_id == item_id then
			return true
		end
	end
	return false
end


-- 获取当前空的精灵格子
function SpiritData:HasNotSprite()
	return self.spirit_info.count == 0
end

-- 获取当前空的精灵格子
function SpiritData:GetSpiritItemIndex()
	if self.spirit_info.count == 0 then
		return 1
	end
	if not self.spirit_info.jingling_list then return nil end
	for i = 0, 3 do
		if self.spirit_info.jingling_list[i] == nil then
			return i + 1
		end
	end
	return nil
end

-- 通过等级获取精灵配置
function SpiritData:GetSpiritLevelCfgByLevel(index, level)
	if self.spirit_info.jingling_list[index] == nil then
		return
	end
	local level = level or self.spirit_info.jingling_list[index].param.strengthen_level
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and self.spirit_info.jingling_list[index].item_id == v.item_id then
			return v
		end
	end
	return nil
end

-- 获取当前等级的精灵的回收总灵晶
function SpiritData:GetSpiritAllLingjingByLevel(item_id, level)
	if not item_id then return 0 end
	if level == 0 then
		level = 1
	end
	local all_lingjing = 0
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if item_id == v.item_id then
			if v.level < level then
				all_lingjing = all_lingjing + v.cost_lingjing
			end
		end
	end
	return all_lingjing * 0.8
end

function SpiritData:GetRecyclWuxingValue(wu_xing)
	local wuxing_data = self:GetWuXing()
	return wuxing_data[wu_xing].recycle_stuff_num
end

-- 通过ID获取精灵配置
function SpiritData:GetSpiritLevelCfgById(item_id, level)
	if level == 0 then
		level = 1
	end
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and item_id == v.item_id then
			return v
		end
	end
	return nil
end

-- 通过等级资质获取属性
function SpiritData:GetSpiritLevelAptitude(item_id, level, aptitude, wuxing)
	if level == 0 then
		level = 1
	end
	local attr = {}
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and item_id == v.item_id then
			attr.gongji = self:GetAttrByAptitude(v.gongji, aptitude.gongji_zizhi, wuxing, "gongji_zizhi")
			attr.fangyu = self:GetAttrByAptitude(v.fangyu, aptitude.fangyu_zizhi, wuxing, "fangyu_zizhi")
			attr.maxhp = self:GetAttrByAptitude(v.maxhp, aptitude.maxhp_zizhi, wuxing, "maxhp_zizhi")
			return attr
		end
	end
	return nil
end

function SpiritData:SetCurSpiritId(protocol)
   self.user_pet_special_img = protocol.user_pet_special_img
end

function SpiritData:GetCurSpiritId()
   return self.user_pet_special_img
end

function SpiritData:GetAddAttrValue(total,base)
	local add_attr = {}
	for i=1,3 do
		add_attr[i] = total[SPIRIT_ATTR_TYPE[i]] - base[SPIRIT_ATTR_TYPE[i]]
	end
	return add_attr
end

-- 获取精灵最大升级数
function SpiritData:GetMaxSpiritUplevel(item_id)
	local list = {}
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if v.item_id == item_id then
			table.insert(list, v)
		end
	end
	return #list
end

function SpiritData:InitPhantomCfg()
	local cfg = self:GetSpiritHuanImageConfig()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- huanhua_list通过GetHuanhuaList获取
	self.huanhua_list = {}
	self.open_huanhua_list = {}
	-- open_huanhua_list通过GetOpenHuanhuaList获取
	for i,v in ipairs(cfg) do
		if server_day >= v.open_day then
			table.insert(self.huanhua_list, v)
			self.open_huanhua_list[v.active_image_id] = i
		end
	end

end

function SpiritData:GetHuanHuaList()
	self:InitPhantomCfg()
	return self.huanhua_list
end

function SpiritData:GetOpenHuanhuaList()
	self:GetHuanHuaListByLevel()
	return self.open_huanhua_list
end

function SpiritData:GetHuanHuaListByLevel()
	local list = {}

	local vo_level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(self:GetHuanHuaList()) do
		if vo_level >= v.lvl then
			table.insert(list,v)
		else
			self.open_huanhua_list[v.active_image_id] = nil
		end
	end

	return list
end

function SpiritData:GetListIndex(index)
	if self:GetHuanHuaListByLevel()[index] then
		return self:GetOpenHuanhuaList()[self:GetHuanHuaListByLevel()[index].active_image_id]
	end
end

-- 获取已激活的法阵组合
-- function SpiritData:GetMaxShowFaZhen()
-- 	if self.spirit_info.jingling_list == nil then
-- 		return 0
-- 	end
-- 	local data_list = {self.spirit_info.jingling_list[0] or {}, self.spirit_info.jingling_list[1] or {},
-- 					self.spirit_info.jingling_list[2] or {}, self.spirit_info.jingling_list[3] or {}}
-- 	local list_1 = {}
-- 	local list_2 = {}
-- 	local list_3 = {}
-- 	local list_4 = {}
-- 	local group_2 = {}
-- 	local group_3 = {}
-- 	local group_4 = {}
-- 	local item_ids = {}
-- 	local all_list = {}
-- 	for k, v in pairs(self:GetSpiritGroup()) do
-- 		item_ids[v.id] = {}
-- 		for i = 1, 4 do
-- 			if v["itemid"..i] == data_list[1].item_id then
-- 				list_1[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[2].item_id then
-- 				list_2[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[3].item_id then
-- 				list_3[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[4].item_id then
-- 				list_4[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] > 0 then
-- 				item_ids[v.id][#item_ids[v.id] + 1] = v["itemid"..i]
-- 			end
-- 		end
-- 	end
-- 	for k, v in pairs(self:GetSpiritGroup()) do
-- 		if list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil and #item_ids[v.id] >= 4 then
-- 			group_4[#group_4 + 1] = v
-- 		end
-- 		if #item_ids[v.id] == 2 then
-- 			if (list_1[v.id] ~= nil and list_2[v.id] ~= nil) or (list_1[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_4[v.id] ~= nil) or (list_2[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_2[v.id] ~= nil and list_4[v.id] ~= nil) or (list_3[v.id] ~= nil and list_4[v.id] ~= nil) then
-- 				group_2[#group_2 + 1] = v
-- 			end
-- 		end
-- 		if #item_ids[v.id] == 3 then
-- 			if (list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_4[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil) or
-- 				(list_2[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil) then
-- 				group_3[#group_3 + 1] = v
-- 			end
-- 		end
-- 	end
-- 	return (#group_2 + #group_3 + #group_4), group_2, group_3, group_4
-- end

-- 通过等级、ID获取精灵幻化配置
function SpiritData:GetSpiritHuanhuaCfgById(image_id, level)
	if nil == image_id or nil == level then return nil end
	return self.jingling_huanhua_list[image_id] and self.jingling_huanhua_list[image_id][level + 1] or nil
end

-- 获取精灵幻化升级上限
function SpiritData:GetMaxSpiritHuanhuaLevelById(image_id)
	return #self.jingling_huanhua_list[image_id] - 1
end

-- 获取精灵天赋属性
function SpiritData:GetSpiritTalentAttrCfgById(item_id)
	local talent_cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").talent_attr
	for k, v in pairs(talent_cfg) do
		if item_id == v.item_id then
			return v
		end
	end
end

-- 精灵总战力
function SpiritData:GetAllSpiritFightPower()
	local fight_power = 0
	for k, v in pairs(self.spirit_info.jingling_list) do
		 local attr = CommonDataManager.GetAttributteNoUnderline(self:GetSpiritLevelCfgByLevel(v.index), true)
		 fight_power = fight_power + CommonDataManager.GetCapability(attr)
	end
	return fight_power
end

-- 通过ID获取装备精灵信息
function SpiritData:GetDressSpiritInfoById(item_id)
	if nil == self.spirit_info or nil == self.spirit_info.jingling_list or nil == item_id then
		return
	end
	for k,v in pairs(self.spirit_info.jingling_list) do
		if v.item_id == item_id then
			return v
		end
	end
	return nil
end

-- 获取精灵幻化配置
function SpiritData:GetSpiritHuanConfigByItemId(item_id)
	if nil == item_id then return nil end
	return self.huanhua_stuff_dic[item_id]
end

-- 精灵阵法组合排序
function SpiritData:GetSpiritGroupCfg()
	local list = {}
	local group = {}
	if nil == self.spirit_info or nil == next(self.spirit_info) or nil == self.spirit_info.jingling_list
		or nil == next(self.spirit_info.jingling_list) then
		return group
	end
	local jingling_list = {self.spirit_info.jingling_list[0], self.spirit_info.jingling_list[1],
					self.spirit_info.jingling_list[2], self.spirit_info.jingling_list[3]}

	for k, v in pairs(self:GetSpiritGroup()) do
		local num = 0
		for i = 1, 5 do
			for n, m in pairs(jingling_list) do
				if m.item_id == v["itemid"..i] then
					num = num + 1
					-- table.insert(list[v.id], v)
				end
			end
		end
		list[v.id] = {count = num, id = v.id}
	end

	for k, v in pairs(list) do
		if self:GetSpiritGroupLenghtById(k) <= list[k].count then
			list[k].had_active = 1
			list[k].diffe = 0
		else
			list[k].had_active = 0
			list[k].diffe = self:GetSpiritGroupLenghtById(k) - list[k].count
		end
		local count, pingfen = self:GetSpiritGroupLenghtById(k, true)
		list[k].pingfen = pingfen
	end
	for k, v in pairs(self:GetSpiritGroup()) do
		if list[v.id] then
			table.insert(group, list[v.id])
		end
	end

	table.sort(group, function (a, b)
		if not a.pingfen then
			a.pingfen = 0
		end
		if not b.pingfen then
			b.pingfen = 0
		end
		if a.had_active ~= b.had_active then
			return a.had_active > b.had_active
		end

		if a.diffe ~= b.diffe then
			return a.diffe < b.diffe
		end

		if a.pingfen ~= b.pingfen then
			return a.pingfen > b.pingfen
		end

		if a.pingfen == b.pingfen and a.count ~= b.count then
			return a.count > b.count
		end

		return a.id < b.id
	end)

	return group
end

-- 获取当前组合的长度
function SpiritData:GetSpiritGroupLenghtById(id, zuhe_pingfen)
	if nil == id then return end
	local group_cfg = self:GetSpiritGroup()[id]
	if nil == group_cfg then return end

	local count = 0
	for i = 1, 5 do
		if group_cfg["itemid"..i] > 0 then
			count = count + 1
		end
	end
	if zuhe_pingfen then
		return count, group_cfg.zuhe_pingfen
	end
	return count, 0
end

-- 精灵幻化红点
function SpiritData:ShowHuanhuaRedPoint()
	-- local list = {}
	-- return list
	--
	if nil == self.spirit_info.phantom_level_list then return list end

	local list = {}
	for k, v in pairs(self.huanhua_stuff_dic) do
		local item_num = ItemData.Instance:GetItemNumInBagById(k)
		if item_num > 0 then
			local level = self.spirit_info.phantom_level_list[v.type + 1]

			local level_cfg = self:GetSpiritHuanhuaCfgById(v.type, level)
			if nil ~= level_cfg and level_cfg.stuff_num <= item_num then
				if self:GetOpenHuanhuaList()[v.type] then
					list[v.type] = level_cfg
				end
			end
		end
	end
	return list
end

function SpiritData:CanXianZhenUp()
	local spirit_info = self:GetSpiritInfo()
	if spirit_info.xianzhen_level == SpiritData.Instance:GetZhenfaMaxLevel() then
		return false
	end
	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	local next_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(spirit_info.xianzhen_level + 1)
	if item_num >= next_zhenfa_cfg.stuff_num then
		return true
	else
		return false
	end
end

function SpiritData:CanPromote()
	if self:CanXianZhenUp() then
		return true
	elseif self:ShowAllHunyuRedPoint() then
		return true
	else
		return false
	end
end

function SpiritData:CanHunYuUp(index)
	local spirit_info = self:GetSpiritInfo()
	local hunyu_level_list = spirit_info.hunyu_level_list
	local hunyu_level = hunyu_level_list[index]	or 0
	local hunyu_cfg = SpiritData.Instance:GetHunyuCfg(index, hunyu_level + 1)
	if nil == hunyu_cfg then
		return false
	end
	local item_id = hunyu_cfg.stuff_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_item_num = hunyu_cfg.stuff_num
	if have_item_num >= cost_item_num then
		return true
	else
		return false
	end
end

function SpiritData:CanShangZhen()
	-- local display_list = SpiritData.Instance:GetSpiritInfo().jingling_list
	-- local use_jingling_id = SpiritData.Instance:GetSpiritInfo().use_jingling_id
	-- local shangzhenNum = 0
	-- if display_list then
	-- 	for k, v in pairs(display_list) do
	-- 		if v.item_id > 0 and use_jingling_id ~= v.item_id then
	-- 			shangzhenNum = shangzhenNum + 1
	-- 		end
	-- 	end
	-- end
	-- if shangzhenNum == 3 then
	-- 	return false
	-- else
	-- 	return true
	-- end
	if self:GetCanEquip() then
		return true
	else
		return false
	end
end

function SpiritData:ShowAllHunyuRedPoint()
	for i = 0, GameEnum.XIAN_ZHEN_HUN_YU_TYPE_MAX - 1 do
		if self:CanHunYuUp(i) then
			return true
		end
	end
	return false
end

function SpiritData:ShowZhenFaRedPoint()
	return self:ShowAllHunyuRedPoint() or self:CanXianZhenUp() or self:CanShangZhen()
end

-- 是否显示光环红点
function SpiritData:ShowHaloRedPoint()
	if not self.halo_info or not self.halo_info.grade or self.halo_info.grade <= 0 then
		return false
	end
	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[self.halo_info.grade]
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)
	if bag_num >= grade_cfg.upgrade_stuff_count then
		return true
	end
	return false
end

function SpiritData:GetBagSpiritDataList()
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local spirit_list = {}

	for _, v in pairs(equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
			table.insert(spirit_list, v)
		end
	end

	return spirit_list
end

-- 精灵排序
function SpiritData:GetShangZhenBagBestSpirit()
	local data_list = {}
	for k,v in pairs(self.spirit_info.jingling_list) do
		if v.item_id > 0 then
			local vo = {}
			vo.item_data = v
			if v.item_id == self.spirit_info.use_jingling_id then
				vo.type = 1
			else
				vo.type = 2
			end
			table.insert(data_list, vo)
		end
	end
	for k,v in pairs(self:GetBagBestSpirit()) do
		local vo = {}
		vo.item_data = v
		vo.type = 0
		table.insert(data_list, vo)
	end
	return data_list
end

-- 精灵排序
function SpiritData:GetBagBestSpirit(data_list, is_no_bag)
	data_list = data_list or self:GetBagSpiritDataList()

	local list = {}
	local temp_list = {}
	local color = -1
	local temp_color = -1
	local list_lengh = 0
	local last_sort_list = {}
	for k, v in pairs(data_list) do
		table.insert(temp_list, v)
	end
	table.sort(temp_list, function (a, b)
		if not a then
			a = {item_id = 0}
			return a.item_id > b.item_id
		end
		if not b then
			b = {item_id = 0}
			return a.item_id > b.item_id
		end
		local item_cfg_a = ItemData.Instance:GetItemConfig(a.item_id)
		local item_cfg_b = ItemData.Instance:GetItemConfig(b.item_id)
		if item_cfg_a.click_use ~= item_cfg_b.click_use then
			return item_cfg_a.click_use > item_cfg_b.click_use
		end
		if item_cfg_a.color ~= item_cfg_b.color then
			return item_cfg_a.color > item_cfg_b.color
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.strengthen_level ~= b.param.strengthen_level then
			return a.param.strengthen_level > b.param.strengthen_level
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.param1 ~= b.param.param1 then
			return a.param.param1 > b.param.param1
		end

		-- if a.param and b.param and #a.param.xianpin_type_list ~= #b.param.xianpin_type_list then
		-- 	return #a.param.xianpin_type_list > #b.param.xianpin_type_list
		-- end

		if item_cfg_a.bag_type ~= item_cfg_b.bag_type then
			return item_cfg_a.bag_type < item_cfg_b.bag_type
		end

		return a.item_id > b.item_id
	end)

	return temp_list
end

-- 获取精灵模型ID
function SpiritData:GetSpiritResIdByItemId(item_id)
	if nil == item_id then return end

	for k, v in pairs(self:GetSpiritResourceCfg()) do
		if v.id == item_id then
			return v
		end
	end
	return nil
end

-- 预览精灵从高到低排序
function SpiritData:GetDisPlaySpiritListFromHigh()
	local list = self:GetSpiritResourceCfg()

	local sort_list = {}
	for k, v in pairs(list) do
		local cfg = self:GetSpiritLevelCfgById(v.id, 1)
		local base_attr_list = CommonDataManager.GetAttributteNoUnderline(cfg, true)
		local fight_power = CommonDataManager.GetCapability(base_attr_list)
		local temp_data = {}
		temp_data.fight_power = fight_power
		temp_data.id = v.id
		table.insert(sort_list, temp_data)
	end

	table.sort(sort_list, function(a, b)
		return a.fight_power > b.fight_power
	end)

	return sort_list
end

-- 获取命魂属性配置
function SpiritData:GetSoulAttrCfg(id, level, is_sale_exp)
	level = level or 0
	if nil == id or nil == level then return end

	local soul_cfg = self:GetSpiritSoulCfg(id)
	if soul_cfg then
		local attr_cfg = self:GetSpiritSoulExpCfg()
		if not is_sale_exp then
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level == level then
					return v
				end
			end
		else
			local exp = 0
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level < level then
					exp = exp + v.exp
				end
			end
			return exp
		end
	end

	return nil
end

-- 判断命魂池里面是否有紫色以上品质的命魂
function SpiritData:IsHadMoreThenPurpleSoul()
	for k, v in pairs(self.soul_bag_info.liehun_pool) do
		if self:GetSoulAttrCfg(v.id) and self:GetSoulAttrCfg(v.id).hunshou_color > 2 then
			return true
		end
	end

	return false
end

-- 把命魂池所有类型不同的取出来
function SpiritData:GetSoulPoolHighQuality()
	local list = {}
	local id_list = {}
	local soul_type_list = {}
	local active_count = SpiritData.Instance:GetSlotSoulActiveCount()
	if 0 == active_count then return list end

	if self.soul_bag_info and next(self.soul_bag_info) then
		for k, v in pairs(self.soul_bag_info.liehun_pool) do
			if v.id > 0 and v.id < GameEnum.HUNSHOU_EXP_ID then
				local cfg = self:GetSpiritSoulCfg(v.id)
				if cfg then
					for i = 0, active_count - 1 do
						local slot_info = self.slot_soul_info.slot_list[i]
						id_list[v.id] = id_list[v.id] or {}
						if slot_info.id > 0 then
							local slot_cfg = self:GetSpiritSoulCfg(slot_info.id)
							soul_type_list[slot_cfg.hunshou_type] = soul_type_list[slot_cfg.hunshou_type] or {}
							soul_type_list[slot_cfg.hunshou_type] = slot_cfg.hunshou_color
							if cfg.hunshou_color > slot_cfg.hunshou_color and slot_cfg.hunshou_type == cfg.hunshou_type and not next(id_list[v.id]) then
								id_list[v.id] = {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 1, slot_index = i}
								table.insert(list, {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 1, slot_index = i})
							end
						else
							if not next(id_list[v.id]) and (not soul_type_list[cfg.hunshou_type] or
									(soul_type_list[cfg.hunshou_type] and soul_type_list[cfg.hunshou_type] < cfg.hunshou_color)) then

								soul_type_list[cfg.hunshou_type] = cfg.hunshou_color
								table.insert(list, {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 0, slot_index = i})
							end
						end
					end
				end
			end
		 end
	end
	for k, v in pairs(id_list) do
		if v.change == 1 then
			for m, n in pairs(list) do
				if v.soul_type == n.soul_type and n.color < v.color then
					table.remove(list, m)
				end
			end
		end
	end

	table.sort(list, function(a, b)
		if a.change ~= b.change then
			return a.change > b.change
		end
		if a.color ~= b.color then
			return a.color > b.color
		end
		return a.soul_type < b.soul_type
	end)
	return list
end

-- 获取命魂槽激活个数
function SpiritData:GetSlotSoulActiveCount()
	local count = 0
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 then
				count = count + 1
			end
		end
	end
	return count
end

-- 获取可装备命魂槽个数
function SpiritData:GetSlotSoulEmptyCount()
	local count = 0
	local special_count = 0
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 and v.id <= 0 then
				count = count + 1
				if k >= GameEnum.LIEMING_FUHUN_SLOT_COUNT - 3 then 			--彩色命魂槽
					special_count = special_count + 1
				end
			end
		end
	end
	return count, special_count
end

-- 获取命魂槽命魂类型
function SpiritData:GetSlotSoulTypeList()
	local list = {}
	if self.slot_soul_info and next(self.slot_soul_info) then
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if v.id > 0 then
				local slot_cfg = self:GetSpiritSoulCfg(v.id)
				table.insert(list, slot_cfg.hunshou_type)
			end
		end
	end
	return list
end

function SpiritData:GetSlotSoulEmptyCountList()
	local list = {}
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 and v.id <= 0 then
				table.insert(list, k)
			end
		end
	end
	return list
end

--最大命魂类型即(彩色命魂)
function SpiritData:GetSlotSoulMaxHunShouColor()
	local cfg = self:GetAllSpiritSoulCfg() or {}
	local max_color = cfg[#cfg] and cfg[#cfg].hunshou_color
	return max_color or -1
end

--是否是彩色命魂
function SpiritData:GetCurSlotSouIsPink(hunshou_id)
	local is_pink = false
	if nil == hunshou_id then
		return is_pink
	end

	local max_color = self:GetSlotSoulMaxHunShouColor()
	local cur_cfg = self:GetSpiritSoulCfg(hunshou_id)
	if max_color ~= -1 and cur_cfg and cur_cfg.hunshou_color then
		local cur_hunshou_color = cur_cfg.hunshou_color
		is_pink = cur_hunshou_color == max_color
	end 

	return is_pink
end

-- 判断背包中是否有彩色命魂，有则返回对应1和对应index，没有则返回0和-1
function SpiritData:GetSpecialSoulIndexInBag()
	if self.soul_bag_info == nil or self.soul_bag_info.grid_list == nil then
		return 0, -1
	end
	for k,v in pairs(self.soul_bag_info.grid_list) do
		if self:GetCurSlotSouIsPink(v.id) then
			return 1, v.index
		end
	end
	return 0, -1
end

-- 获取可装备命魂槽索引
function SpiritData:GetSlotSoulEmptyIndex(hunshou_id)
	local index = -1
	if nil == self.slot_soul_info or nil == next(self.slot_soul_info) then
		return index
	end

	local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
	local is_pink = self:GetCurSlotSouIsPink(hunshou_id)
	for k, v in pairs(self.slot_soul_info.slot_list) do 				-- k的值为0~9, 0~6为普通命魂槽位, 7~8为彩色命魂槽位, 9不可穿戴任何命魂
		if (k >= GameEnum.LIEMING_FUHUN_SLOT_COUNT - 3 and is_pink) or (k < GameEnum.LIEMING_FUHUN_SLOT_COUNT - 3 and not is_pink) then
			if k < GameEnum.LIEMING_FUHUN_SLOT_COUNT - 1 and bit_list[32 - k] == 1 and v.id <= 0 then
				index = k
				break
			end
		end
	end

	return index
end

function SpiritData:SpiritFazhenAttrSum(grade)
	grade = grade or self.fazhen_info.grade
	local attr = CommonStruct.AttributeNoUnderline()
	local star_attr_cfg = self:GetSpiritFazhenGradeCfg()[grade]
	if nil == star_attr_cfg then
		return attr
	end
	attr.gongji = attr.gongji + star_attr_cfg.gongji
	attr.fangyu = attr.fangyu + star_attr_cfg.fangyu
	attr.maxhp = attr.maxhp + star_attr_cfg.maxhp

	return attr
end

function SpiritData:GetFazhenSpecialImgUpgradeCfg(image_id, level)
	level = level or self.fazhen_info.special_img_grade_list[image_id]
	if not image_id then return end

	for k, v in pairs(self:GetSpiritFazhenSpecialImageUpgrade()) do
		if v.special_img_id == image_id and v.grade == level then
			return v
		end
	end
	return nil
end

function SpiritData:GetFazhenMaxUpgrade(image_id)
	local count = 0
	if not image_id then return count end

	for i, j in ipairs(self:GetSpiritFazhenSpecialImageUpgrade()) do
		if j.special_img_id == image_id then
			count = count + 1
		end
	end
	return count
end

-- 精灵幻化红点
function SpiritData:ShowFazhenHuanhuaRedPoint()
	local list = {}
	if nil == self.fazhen_info.special_img_grade_list then return list end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		for i, j in ipairs(self:GetSpiritFazhenSpecialImageCfg()) do
			local cfg = self:GetFazhenSpecialImgUpgradeCfg(j.image_id)
			if cfg then
				if cfg.stuff_id == v.item_id and cfg.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.item_id)
					and self:GetFazhenMaxUpgrade(j.image_id) > self.fazhen_info.special_img_grade_list[j.image_id] + 1 then
					list[j.image_id] = cfg
				end
			end
		end
	end

	return list
end

function SpiritData:GetFazhenGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetSpiritFazhenImageCfg()
	if not image_list then return 0 end
	if not image_list[used_imageid] then return 0 end

	local show_grade = image_list[used_imageid].show_grade
	for k, v in pairs(self:GetSpiritFazhenGradeCfg()) do
		if v.show_grade == show_grade then
			return v.grade
		end
	end
	return 0
end

function SpiritData:SpiritHaloAttrSum(grade)
	grade = grade or self.halo_info.grade
	local attr = CommonStruct.AttributeNoUnderline()
	local star_attr_cfg = self:GetSpiritHaloGradeCfg()[grade]
	if nil == star_attr_cfg then
		return attr
	end
	attr.gongji = attr.gongji + star_attr_cfg.gongji
	attr.fangyu = attr.fangyu + star_attr_cfg.fangyu
	attr.maxhp = attr.maxhp + star_attr_cfg.maxhp

	return attr
end

function SpiritData:GetHaloSpecialImgUpgradeCfg(image_id, level)
	level = level or self.halo_info.special_img_grade_list[image_id]
	if not image_id then return end

	for k, v in pairs(self:GetSpiritHaloSpecialImageUpgrade()) do
		if v.special_img_id == image_id and v.grade == level then
			return v
		end
	end
	return nil
end

function SpiritData:GetHaloMaxUpgrade(image_id)
	local count = 0
	if not image_id then return count end

	for i, j in ipairs(self:GetSpiritHaloSpecialImageUpgrade()) do
		if j.special_img_id == image_id then
			count = count + 1
		end
	end
	return count
end

-- 精灵幻化红点
function SpiritData:ShowHaloHuanhuaRedPoint()
	local list = {}
	if nil == self.halo_info.special_img_grade_list then return list end

	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		for i, j in ipairs(self:GetSpiritHaloSpecialImageCfg()) do
			local cfg = self:GetHaloSpecialImgUpgradeCfg(j.image_id)
			if cfg then
				if cfg.stuff_id == v.item_id and cfg.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.item_id)
					and self:GetFazhenMaxUpgrade(j.image_id) > self.halo_info.special_img_grade_list[j.image_id] + 1 then
					list[j.image_id] = cfg
				end
			end
		end
	end
	return list
end

function SpiritData:GetTalentNameByIndex(index)
	local name_list = Language.JingLing.JingLingTalentName
	return name_list[index] or ""
end

function SpiritData:GetShowTalentList(spirit_id, spirit_all_info)
	local list = {}
	local talent_list = {}
	for k,v in pairs(spirit_all_info.jingling_item_list) do
		if v.jingling_id == spirit_id then
			talent_list = v.talent_list
			break
		end
	end
	for k,v in pairs(talent_list) do
		if v ~= 0 then
			table.insert(list, {name = self:GetTalentNameByIndex(v), value = self:GetSpiritTalentAttrCfgById(spirit_id)["type" .. v]/100})
		end
	end

	for i=1,3 do
		if i > #list then
			list[i] = {}
			list[i].name = ""
			list[i].value = 0
		end
	end
	return list
end

function SpiritData:GetSpiritUpLevelCfg(item_id, level)
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and v.item_id == item_id then
			return v
		end
	end
	return nil
end

function SpiritData:GetSpecialSpiritImageCfg(id)
	for k,v in pairs(self:GetSpiritHuanImageConfig()) do
		if v.active_image_id == id then
			return v
		end
	end
end

--出战 + 幻化
function SpiritData:ChuZhanPower()
	local data = nil
	--出战
	for k,v in pairs(self:GetSpiritInfo().jingling_list) do
		if v.item_id == self.spirit_info.use_jingling_id then
			data = v
		end
	end
	local power = 0
	if data then
		local spirit_level_cfg = self:GetSpiritLevelCfgByLevel(data.index)
		local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
		power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteNoUnderline(attr))
	end
	--幻化
	local huanhua_power = 0
	for k, v in ipairs(self.spirit_info.phantom_level_list) do
		local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(k-1, v)
		local attr_list = CommonDataManager.GetAttributteNoUnderline(data, true)
		huanhua_power = huanhua_power +CommonDataManager.GetCapability(attr_list)
	end
	return power + huanhua_power
end

--命魂战力
function SpiritData:MingHunPower()
	local power = 0
	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	local temp_attr_list = CommonDataManager.GetAttributteNoUnderline()
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.id, v.level) or {}
				if cfg and cfg.hunshou_type and temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					local single_attr = attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
					local max_color = self:GetSlotSoulMaxHunShouColor()
					if max_color ~= -1 and cfg.hunshou_color and cfg.hunshou_color == max_color then
						local add_base_attr_per = attr_list.add_base_attr_per or 0
						single_attr = single_attr * (1 + add_base_attr_per * 0.01) 		--彩色命魂有加成
					end

					temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + single_attr
				end
			end
		end
	end
	if temp_attr_list then
	   power = CommonDataManager.GetCapabilityCalculation(temp_attr_list)
	end
	return power
end

-- 命魂基础属性
function SpiritData:GetSpiritSoulBaseAttrList()
	local base_attr = CommonDataManager.GetAttributteNoUnderline() or {}
	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	-- 基础属性值
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.id, v.level) or {}
				if cfg and cfg.hunshou_type and base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					local single_attr = attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
					base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + single_attr
				end
			end
		end
	end
	return base_attr
end

-- 特殊命魂加成属性
function SpiritData:GetSpiritSpecialSoulAttrList()
	local special_add_attr_list = CommonDataManager.GetAttributteNoUnderline() or {}
	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	for k,v in pairs(SPECIAL_SOUL_INDEX) do
		if slot_soul_info and slot_soul_info.slot_list and slot_soul_info.slot_list[v] and slot_soul_info.slot_list[v].id ~= 0 then
			local attr_list = SpiritData.Instance:GetSoulAttrCfg(slot_soul_info.slot_list[v].id, slot_soul_info.slot_list[v].level) or {}
			local add_attr = attr_list.add_base_attr_per / 10000
			self:CalSingleSpecialAddAttr(special_add_attr_list, add_attr)
		end
	end
	return special_add_attr_list
end

-- 计算单个彩色命魂加成基本属性
function SpiritData:CalSingleSpecialAddAttr(special_add_attr_list, add_attr)
	if add_attr == nil or add_attr == 0 then
		return
	end
	if special_add_attr_list == nil or next(special_add_attr_list) == nil then
		return
	end

	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	-- 基础属性值
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
				-- 只计算第一级的基础战力
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.id, 1) or {}
				if cfg and cfg.hunshou_type and special_add_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					local single_attr = attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
					single_attr = single_attr * add_attr 		--彩色命魂有加成
					special_add_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = special_add_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + single_attr
				end
			end
		end
	end
end

-- 获取命魂总属性
function SpiritData:GetSpiritSoulTotalAttrList()
	local base_attr_list = self:GetSpiritSoulBaseAttrList() or {}
	local special_add_attr_list = self:GetSpiritSpecialSoulAttrList() or {}
	for k,v in pairs(special_add_attr_list) do
		base_attr_list[k] = base_attr_list[k] + v
	end
	return base_attr_list
end

-- 获取命魂总战力
function SpiritData:GetSpiritSoulTotalPower()
	local attr_list = self:GetSpiritSoulTotalAttrList() or {}
	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	return math.ceil(power) or 0
end

--法阵战力 + 幻化
function SpiritData:FaZhenPower()
	--法阵
	local power = 0
	local attr_list = SpiritData.Instance:SpiritFazhenAttrSum()
	power = CommonDataManager.GetCapability(attr_list)
	--幻化
	local huanhua_power = 0
	for i=1, self:GetMaxSpiritFazhenSpecialImage() do
		if self.fazhen_info.active_special_image_list[32 - i] > 0 then
			local data = SpiritData.Instance:GetFazhenSpecialImgUpgradeCfg(i)
			local attr_list = CommonDataManager.GetAttributteNoUnderline(data)
			huanhua_power = huanhua_power + CommonDataManager.GetCapability(attr_list)
		end
	end
	return power + huanhua_power
end

--光环 + 幻化
function SpiritData:HaloPower()
	--光环
	local power = 0
	local attr_list = SpiritData.Instance:SpiritHaloAttrSum()
	power = CommonDataManager.GetCapability(attr_list)
	--幻化
	local huanhua_power = 0
	for i=1, self:GetMaxSpiritHaloGrade() do
		if self.halo_info.active_special_image_list[32 - i] > 0 then
			local data = SpiritData.Instance:GetHaloSpecialImgUpgradeCfg(i)
			local attr_list = CommonDataManager.GetAttributteNoUnderline(data)
			huanhua_power = huanhua_power + CommonDataManager.GetCapability(attr_list)
		end
	end
	return power + huanhua_power
end

--获取精灵系统总战力
function SpiritData:GetAllSpiritPower()
	local all_power = 0
	all_power = all_power + self:ChuZhanPower() + self:GetSpiritSoulTotalPower() + self:FaZhenPower() + self:HaloPower()
	return all_power
end

--获取排行榜系统精灵显示战力
function SpiritData:GetRankSpiritPower()
	local all_power = 0
	local zhenfa_power = CommonDataManager.GetCapabilityCalculation(self:GetZhenfaAttrList())
	all_power = all_power + self:ChuZhanPower() + self:GetSpiritSoulTotalPower() + self:FaZhenPower() + self:HaloPower() + zhenfa_power + self:GetUseSpriteAptitudePower()
	return all_power
end

------------------------精灵技能--------------------------------
function SpiritData:GetOneSkillCfgBySkillId(skill_id)
	local skill_cfg = self:GetSpiritSkillCfg()
	-- 配置表的索引刚好是对应的skill_id
	return skill_cfg[skill_id]
end

function SpiritData:GetActivateSkillItemId()
	return self:GetSpiritOtherCfg().get_skill_item
end

function SpiritData:SetSkillViewCurSpriteIndex(sprite_index)
	self.skill_cur_sprite_index = sprite_index
end

function SpiritData:GetSkillViewCurSpriteIndex(sprite_index)
	return self.skill_cur_sprite_index
end

function SpiritData:SetGetSkillViewCurCellIndex(cell_index)
	self.skill_cur_cell_index = cell_index
end

function SpiritData:GetSkillViewCurCellIndex()
	return self.skill_cur_cell_index
end

function SpiritData:GetSkliiFlsuhStageByTimes(flush_times)
	local skill_refresh_cfg = self:GetSpiritSkillRefreshCfg()
	for k, v in pairs(skill_refresh_cfg) do
		if flush_times >= v.min_count and flush_times <= v.max_count then
			return v
		end
	end

	return {}
end

-- 技能槽开启数量
function SpiritData:GetSkillOpenNum(sprite_index)
	local spirit_info = self:GetSpiritInfo()
	local cur_spirit_info = spirit_info.jingling_list[sprite_index]
	if nil == cur_spirit_info then
		return 0, 0, 0
	end
	local spirit_level = cur_spirit_info.param.strengthen_level
	local spirit_item_id = cur_spirit_info.item_id
	local wuxing_level = cur_spirit_info.param.param2

	-- 天赋属性带来的格子数
	local cur_spirit_talent_cfg = self:GetSpiritTalentAttrCfgById(spirit_item_id)
	local talent_cell_cout = cur_spirit_talent_cfg.skill_num or 0

	-- 等级带来的格子数
	local cur_spirit_level_cfg = self:GetSpiritLevelCfgByLevel(sprite_index)
	local level_cell_count = cur_spirit_level_cfg.skill_num or 0

	-- 悟性带来的格子数
	local cur_spirit_wuxing_cfg = self:GetWuXingCfgByLevel(wuxing_level)
	local wuxing_cell_count = cur_spirit_wuxing_cfg.skill_num or 0

	local all_num = talent_cell_cout + level_cell_count + wuxing_cell_count
	return all_num, wuxing_cell_count, level_cell_count
end

-- 获取背包里的技能书道具
function SpiritData:GetBagSkillBookItem()
	local skill_book_list = {}
	local bag_item_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_OTHER)
	local index = 1
	for _, v in pairs(bag_item_list) do
		if self:IsSkillBookItem(v.item_id) then
			skill_book_list[index] = TableCopy(v)
			index = index + 1
		end
	end
	table.sort(skill_book_list, SortTools.KeyUpperSorter("item_id"))
	return skill_book_list
end

-- 是否精灵技能书（写死id判断）
function SpiritData:IsSkillBookItem(item_id)
	local skill_book_star_item_id = 27840
	local end_book_star_item_id = 27887
	if item_id >= skill_book_star_item_id and item_id <= end_book_star_item_id then
		return true
	end

	return false
end

-- 获得精灵第一个没有技能的格子索引
-- 因为精灵的技能放在哪个位置是客户端决定，所以这边逐一往后排(用于技能仓库)
function SpiritData:GetFirstNotSkillCellIndex(sprite_index)
	local cur_select_sprite_info = self.spirit_info.jingling_list[sprite_index]
	if nil == cur_select_sprite_info then
		return
	end
	local skill_list = cur_select_sprite_info.param.jing_ling_skill_list
	for i = 0, GameEnum.JING_LING_SKILL_COUNT_MAX - 1 do
		local skill_info = skill_list[i]
		if skill_info.skill_id <= 0 then
			return i
		end
	end

	return 0
end

-- 技能背包要先判断是否已经学习了前置技能,有的话顶掉，没有的话再继续往后面插入技能
function SpiritData:GetLearnSkillCellIndex(sprite_index, to_learn_skill_id)
	local cur_select_sprite_info = self.spirit_info.jingling_list[sprite_index]
	local has_pre_skill = false
	if nil == cur_select_sprite_info then
		return 0, has_pre_skill
	end
	local skill_list = cur_select_sprite_info.param.jing_ling_skill_list
	-- 获取前置技能id
	local to_learn_skill_cfg = self:GetOneSkillCfgBySkillId(to_learn_skill_id)
	local pre_skill_id = to_learn_skill_cfg.pre_skill
	for k,v in pairs(skill_list) do
		if v.skill_id > 0 and v.skill_id == pre_skill_id then
			has_pre_skill = true
			return k, has_pre_skill
		end
	end

	has_pre_skill = false
	return self:GetFirstNotSkillCellIndex(sprite_index), has_pre_skill
end

function SpiritData:GetOneSkillCfgByItemId(item_id)
	local skill_cfg = self:GetSpiritSkillCfg()
	for k,v in pairs(skill_cfg) do
		if v.book_id == item_id then
			return v
		end
	end

	return {}
end

-- 精灵技能界面的三个网格都用这个接口
function SpiritData:SetSpiritSkillViewCellData(cell_data)
	self.sprite_skill_cell_data = cell_data
end

function SpiritData:GetSpiritSkillViewCellData()
	return self.sprite_skill_cell_data or {}
end

-- 获取技能背包第一个空格子的索引
function SpiritData:GetStorageFirstNotSkillIndex()
	local skill_storage_list = self.spirit_info.skill_storage_list
	for i = 0, 49 do
		if skill_storage_list[i].skill_id <= 0 then
			return i
		end
	end

	return 0
end

function SpiritData:GetSkillStorageList()
	local skill_storage_list = TableCopy(self.spirit_info.skill_storage_list)
	for k,v in pairs(skill_storage_list) do
		if v.skill_id > 0 then
			local cfg = self:GetOneSkillCfgBySkillId(v.skill_id)
			v.skill_level = cfg.skill_level
		else
			v.skill_level = 0
		end
	end
	local function sort_function(sort_key1, sort_key2)
		return function (a, b)
			local order_a = 1000
			local order_b = 1000
			if a[sort_key1] > b[sort_key1] then
				order_a = order_a + 100
			elseif b[sort_key1] > a[sort_key1] then
				order_b = order_b + 100
			end

			if a[sort_key2] > b[sort_key2] then
				order_a = order_a + 10
			elseif b[sort_key2] > a[sort_key2] then
				order_b = order_b + 10
			end

			return order_a > order_b
		end
	end
	table.insert(skill_storage_list, 1, skill_storage_list[0])
	table.sort(skill_storage_list, sort_function("skill_level", "skill_id"))

	return skill_storage_list
end

function SpiritData:GetSkillBookCfgMaxType()
	local skill_book_cfg = self:GetSpiritSkillBookCfg()
	return #skill_book_cfg
end

function SpiritData:GetFreeFlushLeftTimes()
	local all_free_times = self:GetSpiritOtherCfg().skill_free_refresh_count
	local refresh_times = self.spirit_info.skill_free_refresh_times or 0
	local left_times = all_free_times - refresh_times
	return left_times
end

function SpiritData:GetSkillNumLevelCfg()
	local cfg = self:GetSpiritLevelConfig()
	local skill_num_cfg = {}
	local old_num = cfg[1].skill_num
	local old_item = cfg[1].item_id
	for i=1,#cfg do
		if cfg[i].item_id ~= old_item then
			old_num = cfg[i].skill_num
			old_item = cfg[i].item_id
		end
		if cfg[i].skill_num > old_num then
			table.insert(skill_num_cfg,cfg[i])
			old_num = cfg[i].skill_num
		end
	end
	return skill_num_cfg
end

function SpiritData:GetMaxSkillNumByID(item_id)
	local max_skill_num = 0
	for k,v in pairs(self.skill_num_cfg) do
		if v.item_id ~= item_id and max_skill_num ~= 0 then
			return max_skill_num
		end
		if v.item_id == item_id and v.skill_num > max_skill_num then
			max_skill_num = v.skill_num
		end
	end
	return max_skill_num
end

function SpiritData:GetSkillNumNextLevelById(item_id,skill_num)
	for i,v in ipairs(self.skill_num_cfg) do
		if v.item_id == item_id and v.skill_num > skill_num then
			return v.level
		end
	end
	return 0
end

function SpiritData:GetSpriteSkillNumBySpriteIndex(sprite_index)
	local skill_num = 0
	local cur_select_sprite_info = self.spirit_info.jingling_list[sprite_index]
	if nil == cur_select_sprite_info then
		return
	end
	local skill_list = cur_select_sprite_info.param.jing_ling_skill_list
	for k,v in pairs(skill_list) do
		if v.skill_id > 0 then
			skill_num = skill_num + 1
		end
	end

	return skill_num
end

-- 包括基础技能槽 + 悟性带来的技能槽 + 等级带来的技能槽
function SpiritData:GetMaxSkillCellNumByIndex(sprite_index)
	local spirit_info = self:GetSpiritInfo()
	local cur_sprite_info = spirit_info.jingling_list[sprite_index]
	if nil == cur_sprite_info then
		return 0, 0, 0
	end
	local spirit_item_id = cur_sprite_info.item_id
	-- 基础技能槽
	local cur_spirit_talent_cfg = self:GetSpiritTalentAttrCfgById(spirit_item_id)
	local talent_cell_cout = cur_spirit_talent_cfg.skill_num or 0
	-- 等级带来的最大技能槽
	local level_skill_num = SpiritData.Instance:GetMaxSkillNumByID(spirit_item_id)
	-- 悟性带来的最大技能槽
	local wuxing_cfg = self:GetWuXing()
	local last_wuxing_cfg = wuxing_cfg[#wuxing_cfg]
	local wuxing_skill_num = last_wuxing_cfg.skill_num

	local all_num = talent_cell_cout + level_skill_num + wuxing_skill_num
	return all_num, wuxing_skill_num, level_skill_num
end

function SpiritData:ShowSkillRedPoint()
	-- local free_refresh_left_times = self:GetFreeFlushLeftTimes()
	-- local activie_cell_num = 0
	-- if not self.spirit_info.skill_refresh_item_list then return false end
	-- for k,v in pairs(self.spirit_info.skill_refresh_item_list) do
	-- 	-- 格子受限
	-- 	if v.is_active == 1 then
	-- 		activie_cell_num = activie_cell_num + 1
	-- 	end
	-- 	-- 格子全放开
	-- 	-- activie_cell_num = activie_cell_num + 1
	-- end

	-- local activate_item_id = SpiritData.Instance:GetActivateSkillItemId()
	-- local item_num = ItemData.Instance:GetItemNumInBagById(activate_item_id)
	-- if (free_refresh_left_times > 0 and activie_cell_num > 0) or item_num > 0 then
	-- 	return true
	-- end
	return false
end

-- 获取出战精灵悟性的属性加成的战力
function SpiritData:GetUseSpriteAptitudePower()
	local data = nil
	--出战
	for k,v in pairs(self:GetSpiritInfo().jingling_list) do
		if v.item_id == self.spirit_info.use_jingling_id then
			data = v
		end
	end
	if data then
		local spirit_level_cfg = self:GetSpiritLevelCfgByLevel(data.index)
		local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
		local gorup = 0
		local use_id = self.spirit_info.use_jingling_id
		for k,v in pairs(self.spirit_info.jingling_list) do
			if v.item_id == use_id then
				gorup = v.param.param1
			end
		end
		local wuxing_cfg = self:GetWuXingCfgByLevel(gorup)
		if wuxing_cfg then
			attr.gongji = math.floor(attr.gongji * (wuxing_cfg.gongji_zizhi / 1000) + wuxing_cfg.gongji)
			attr.fangyu = math.floor(attr.fangyu * (wuxing_cfg.fangyu_zizhi / 1000) + wuxing_cfg.fangyu)
			attr.maxhp = math.floor(attr.maxhp * (wuxing_cfg.maxhp_zizhi / 1000) + wuxing_cfg.maxhp)
		end
		return CommonDataManager.GetCapability(attr)
	end
	return 0
end

----------------------精灵技能/end--------------------------------
function SpiritData:SetSpiritData(data)
	SpiritCtrl.Instance.spirit_wuxing_view.data=data
end

 -- 获取精灵悟性
function SpiritData:GetWuXing()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").wuxing
end

 -- 获取精灵悟性
function SpiritData:GetWuXingCfgByLevel(wuxing_level)
	local wuxing_cfg = self:GetWuXing()
	for k,v in pairs(wuxing_cfg) do
		if v.wuxing_level == wuxing_level then
			return v
		end
	end

	return {}
end

-- 是否可以升级精灵
function SpiritData:CanUpgrade()
	if nil == self.spirit_info.jingling_list then
		return false
	end

	local max_level = SpiritNewSysData.Instance:GetMaxGrade()
	for k,v in pairs(self.spirit_info.jingling_list) do
		local grade = SpiritNewSysData.Instance:GetGradeByIndex(v.index)
		if grade < max_level then
			if SpiritNewSysData.Instance:GetUseItem().have_num > 0 then
				return true
			end
		end
	end
	return false
end

function SpiritData:CanUpgradeByID(index)
	local data = self.spirit_info.jingling_list[index]
	if nil == data then return false end
	local need_num = self:GetSpiritLevelCfgByLevel(data.index).cost_lingjing
	local bag_num = GameVoManager.Instance:GetMainRoleVo().lingjing
	return need_num < bag_num
end

function SpiritData:CanUpgradeWuxingByIndex(index)
	local data = self.spirit_info.jingling_list[index]
	if nil == data then return false end
	local wuxing_data = self.GetWuXing()
	local bag_num=ItemData.Instance:GetItemNumInBagById(wuxing_data[tonumber(data.param.param1)].stuff_id)
	local need_num = wuxing_data[tonumber(data.param.param1)].stuff_num
	return bag_num >= need_num
end


-- 是否可以升级悟性
function SpiritData:CanUpgradeWuxing()
	if nil == self.spirit_info.jingling_list then
		return false
	end

	local max_level = SpiritNewSysData.Instance:GetMaxGrade()
	for k,v in pairs(self.spirit_info.jingling_list) do
		local grade = SpiritNewSysData.Instance:GetAptitudeGradeByIndex(v.index)
		if grade < max_level then
			if SpiritNewSysData.Instance:GetAptitudeUseItem().have_num > 0 then
				return true
			end
		end
	end
	return false
end

---------------------------------
--精灵移动
--初始化地图
function SpiritData:InitMap(width, height)
	self.home_map = {}

	self.tile_len = 10
	self.all_width = width
	self.all_height = height
	self.width_len = math.floor(width / self.tile_len)
	self.height_len = math.floor(height / self.tile_len)

	self.mask_table = {}							-- 阻挡信息，二维数组
	self.start_pos = {x = 0, y = 0}						-- 起点
	self.end_pos = {x = 0, y = 0}						-- 终点
	self.open_list = {}								-- 开放列表
	self.map = {}									-- 寻路信息缓存
	self.ran_list = {}
	self.way_list = {}
	self.spirit_hinder_list = {}

	--初始化障碍区
	local mask_list = {}
	for i = 0, self.width_len do
		if mask_list[i] == nil then
			mask_list[i] = {}
		end
		for j = 0, self.height_len do
			-- if i <= 15 and j <= 12 then
			-- 	mask_list[i][j] = 1
			-- end

			if j <= 32 then
				mask_list[i][j] = 1
			end

			if j > 58 then
				mask_list[i][j] = 1
			end

			if i <= 2 then
				mask_list[i][j] = 1
			end

			-- if i <= 6 then
			-- 	mask_list[i][j] = 1
			-- end

			if i >= 81 then
				if j > 40 then
					mask_list[i][j] = 1
				end
			end
		end
	end

	--取得可移动的区域
	for i = 0, self.width_len - 1 do
		for j = 0, self.height_len - 1 do
			if self.way_list[i] == nil then
				self.way_list[i] = {}
			end

			self.way_list[i][j] = {}
			self.way_list[i][j].x = i
			self.way_list[i][j].y = j
			if mask_list[i] ~= nil and mask_list[i][j] ~= nil and mask_list[i][j] == 1 then
				self.way_list[i][j].is_block = true
			else
				self.way_list[i][j].is_block = false
				--table.insert(self.ran_list, {x = i, y = j})
				if self.ran_list[i] == nil then
					self.ran_list[i] = {}
				end
				self.ran_list[i][j] = {}
				self.ran_list[i][j].x = i
				self.ran_list[i][j].y = j
				if i > 20 then
					self.ran_list[i][j].other_black = true
				else
					self.ran_list[i][j].other_black = false
				end
			end
		end
	end
end

function SpiritData:PointInfo()
	return {
		x = 0,
		y = 0,
		block = false,
		g = 0,
		h = 0,
		parent = nil,
		dir = 0,
	}
end

--根据坐标计算出对应的格子下标
function SpiritData:GetIndexByPos(pos)
	local pos_t = {x = 0, y = 0}
	if self.tile_len == nil or pos == nil then
		return pos_t
	end

	-- pos_t.x = math.floor((pos.x - self.all_width * 0.5) / self.tile_len)
	-- pos_t.y = math.floor((pos.y - self.all_height * 0.5) / self.tile_len)

	pos_t.x = math.abs(math.floor((pos.x + self.all_width * 0.5) / self.tile_len))
	pos_t.y = math.abs(math.floor((pos.y + self.all_height * 0.5) / self.tile_len))

	return pos_t
end

--根据格子下标计算出对应的坐标
function SpiritData:GetPosByIndex(index)
	local pos = {x = 0, y = 0}
	if self.tile_len == nil or index == nil then
		return pos
	end
	pos.x = index.x  * self.tile_len + self.tile_len * 0.5 - self.all_width * 0.5
	pos.y = index.y  * self.tile_len + self.tile_len * 0.5 - self.all_height * 0.5

	return pos
end

function SpiritData:GetReadPos(pos)
end

--寻路
function SpiritData:FindWay(start_pos, end_pos)
	if start_pos.x < 0 or start_pos.x >= self.width_len or start_pos.y < 0 or start_pos.y >= self.height_len then
		return false
	end
	if end_pos.x < 0 or end_pos.x >= self.width_len or end_pos.y < 0 or end_pos.y >= self.height_len then
		return false
	end

	self:Reset()

	self.start_pos = start_pos
	self.end_pos = end_pos

	if self:IsBlock(start_pos.x, start_pos.y) or self:IsBlock(end_pos.x, end_pos.y) then
		return false
	end

	-- 起点 终点 相同，直接返回
	if start_pos.x == end_pos.x and start_pos.y == end_pos.y then
		return false
	end

	--local cur_pos = cc.p(start_pos.x, start_pos.y)
	local cur_pos = {x = start_pos.x, y = start_pos.y}
	for loops1 = 1, 1000000 do
		-- 将当前点置为已经检查过
		self.map[cur_pos.x][cur_pos.y].block = true
		self.map[cur_pos.x][cur_pos.y].x = cur_pos.x
		self.map[cur_pos.x][cur_pos.y].y = cur_pos.y

		local offset_list = {{1, 0, false}, {1, 1, true},{0, 1, false}, {-1, 1, true}, {-1, 0, false}, {-1, -1, true},{0, -1, false}, {1, -1, true}}	-- 八个方向
		for k, v in pairs(offset_list) do
			local x, y = cur_pos.x + v[1], cur_pos.y + v[2]
			if x >= 0 and x < self.width_len and y >= 0 and y < self.height_len and not self.map[x][y].block and not self:IsBlock(x, y) then
				if x == end_pos.x and y == end_pos.y then
					self.map[x][y].parent = self.map[cur_pos.x][cur_pos.y]
					self.map[x][y].x = x
					self.map[x][y].y = y
					self.map[x][y].dir = k
					return true
				end

				self:CalcWeight(x, y, cur_pos, v[3], k)
			end
		end

		local cant_find = true
		for loops2 = 1, 10000 do
			local next_open = table.remove(self.open_list, 1)
			if nil == next_open then break end

			if not self.map[next_open.x][next_open.y].block then
				cur_pos.x = next_open.x
				cur_pos.y = next_open.y
				cant_find = false
				break
			end
		end
		if cant_find then return false end			-- 说明开放列表为空，那么就没有找到路径
	end

	return false
end

function SpiritData:CalcWeight(next_x, next_y, cur_pos, is_slash, next_dir)
	local next_p = self.map[next_x][next_y]
	local cur_p = self.map[cur_pos.x][cur_pos.y]

	local g = cur_p.g + (is_slash and 14142 or 10000)

	-- 方向改变的时候加权，可以让寻出来的路径尽量走直线
	-- if cur_p.dir ~= next_dir then
	-- 	g = g + 15000
	-- end

	if is_slash then
		if self:IsBlock(next_x, cur_pos.y) or self:IsBlock(cur_pos.x, next_y) then
			return
		end
	end

	if next_p.g == 0 or next_p.g > g then
		next_p.g = g
		next_p.parent = cur_p
		next_p.dir = next_dir						-- 记录当前与parant的dir

		if next_p.h == 0 then
			next_p.h = 10000 * self:CalH(next_x, next_y)
		end

		local f = next_p.h + next_p.g
		table.insert(self.open_list, {x = next_x or 0, y = next_y or 0, f = f or 0,})
	end
end

function SpiritData:Reset()
	self.open_list = {}

	self.map = {}
	for x = 0, self.width_len-1 do
		self.map[x] = {}
		for y = 0, self.height_len-1 do
			self.map[x][y] = self:PointInfo()
		end
	end
end

function SpiritData:CalH(pos_x, pos_y)
	local x_dis = math.abs(pos_x - self.end_pos.x)
	local y_dis = math.abs(pos_y - self.end_pos.y)

	return x_dis + y_dis;
end

function SpiritData:IsBlock(x, y)
	-- if nil == self.mask_table[x] or nil == self.mask_table[x][y] then
	-- 	return true
	-- end
	-- print("self.mask_table[x][y]========", self.mask_table[x][y])
	return self.way_list[x][y].is_block
end

--取得随机的移动位置
function SpiritData:GetMovePoint(start_index, spirit_index)
	local pos = {x = 0, y = 0}
	if self.ran_list == nil or self.width_len == nil or self.height_len == nil then
		return pos
	end

	pos = math.random(1, #self.ran_list)
	if start_index ~= nil and start_index.x == self.ran_list[pos].x and start_index.y == self.ran_list[pos].y then
		if pos == #self.ran_list then
			pos = math.random(1, #self.ran_list - 1)
		elseif pos == 1 then
			pos = math.random(2, #self.ran_list)
		else
			pos = math.random(1, pos - 1)
		end
	end

	return self.ran_list[pos]
end

function SpiritData:GetSpiritHinderList(start_index, spirit_index, is_other)
	local pos = {x = 0, y = 0}
	if self.ran_list == nil or self.width_len == nil or self.height_len == nil then
		return pos
	end

	self.spirit_hinder_list[spirit_index] = start_index
	local check_list = TableCopy(self.ran_list)
	if is_other then
		for k,v in pairs(check_list) do
			if k > 70 then
				check_list[k] = nil
			end
		end
	end

	--local y_value = -4
	for k,v in pairs(self.spirit_hinder_list) do
		if v ~= nil then
			local x_value = -16
			for i = 1, 33 do
				local y_value = -20
				for j = 1, 41 do
					if check_list[v.x + x_value] ~= nil then
						check_list[v.x + x_value][v.y + y_value] = nil
					end
					y_value = y_value + 1
				end
				x_value = x_value + 1
			end
		end
	end

	if start_index ~= nil and check_list[start_index.x] ~= nil then
		check_list[start_index.x][start_index.y] = nil
	end

	local can_list = {}
	for k,v in pairs(check_list) do
		for k1,v1 in pairs(v) do
			if v1 ~= nil then
				table.insert(can_list, {x = v1.x, y = v1.y})
			end
		end
	end

	math.randomseed(os.time())
	-- local len = math.floor(#can_list / 4)
	-- len = len == 0 and 1 or len
	-- local read_index = math.random((spirit_index - 1) * len, #can_list)
	-- self.spirit_hinder_list[spirit_index] = can_list[read_index]

	local pos_index_1 = math.random(1, #can_list * spirit_index)
	local read_index = pos_index_1 % #can_list
	read_index = read_index <=0 and 1 or read_index
	read_index = read_index >= #can_list and #can_list or read_index
	self.spirit_hinder_list[spirit_index] = can_list[read_index]
	return can_list[read_index]
end

--取得到目标点的移动路径，路径为格子
function SpiritData:GetMovePathPoint(start_pos, end_pos)
	local pos_path_list = {}
	if nil ~= self.map[end_pos.x][end_pos.y] then
		local getpath
		getpath = function (pos_point)
			if pos_point.parent ~= nil and "table" == type(pos_point.parent) then
				getpath(pos_point.parent)
			end
			table.insert(pos_path_list, {x = pos_point.x, y = pos_point.y, dis = pos_point.dir})
		end
		getpath(self.map[end_pos.x][end_pos.y])
	end

	return pos_path_list
end

--通过移动的格子路径，取得相对应的移动坐标，除了起始点，其他格子都走中间
function SpiritData:GetReadMoveList(index_list, item, start_pos)
	local move_list = {}
	if index_list == nil then
		return move_list
	end

	local z = 0
	-- if item ~= nil and item.transform ~= nil then
	-- 	z = item.transform.position.z
	-- end

	for i = 2 ,#index_list - 1 do
		local pos = Vector3(0, 0, z)
		pos.x = index_list[i].x  * self.tile_len + self.tile_len * 0.5 - self.all_width * 0.5
		pos.y = index_list[i].y  * self.tile_len + self.tile_len * 0.5 - self.all_height * 0.5
		table.insert(move_list, pos)
	end


	local end_index = index_list[#index_list]
	local end_pos = Vector3(0, 0, z)
	minx = end_index.x * self.tile_len - self.all_width * 0.5
	maxx = minx + self.tile_len - 5
	end_pos.x = math.random(minx, maxx)

	miny = end_index.y * self.tile_len 	- self.all_height * 0.5
	maxy = miny + self.tile_len - 5
	end_pos.y = math.random(miny, maxy)
	table.insert(move_list, end_pos)

	return move_list
end

function SpiritData:SetSpiritHomeInfo(protocol)
	if JING_LING_HOME_REASON.JING_LING_HOME_REASON_QUICK == protocol.reason then
		local quick_list = {}
		quick_list.item_list = {}
		quick_list.index = nil
		if self.home_info.item_list ~= nil then
			for k,v in pairs(protocol.item_list) do
				if v.reward_times > self.home_info.item_list[k].reward_times then
					for k1,v1 in pairs(v.reward_item_list) do
						local add_num = v1.item_num - self.home_info.item_list[k].reward_item_list[k1].item_num
						if v1.item_id > 0 and add_num > 0 then
							table.insert(quick_list.item_list, {item_id = v1.item_id, num = add_num, is_bind = 1})
						end
					end

					local lingjing_id = self:GetSpiritOtherCfgByName("lingjing_id") or 0
					local hunli_id = self:GetSpiritOtherCfgByName("hunli_id") or 0
					local lingjing_num = v.reward_lingjing - self.home_info.item_list[k].reward_lingjing
					local hunli_num = v.reward_hunli - self.home_info.item_list[k].reward_hunli
					if hunli_num > 0 then
						table.insert(quick_list.item_list, 1, {item_id = hunli_id, num = hunli_num, is_bind = 1})
					end

					if lingjing_num > 0 then
						table.insert(quick_list.item_list, 1, {item_id = lingjing_id, num = lingjing_num, is_bind = 1})
					end

					quick_list.index = k
					break
				end
			end

			self:SetQuickRewardList(quick_list)
		end
	end


	self.home_is_change = self.home_info.role_id ~= protocol.role_id

	self.home_info.reason = protocol.reason
	self.home_info.rob_times_of_me = protocol.rob_times_of_me
	self.home_info.role_id = protocol.role_id
	self.home_info.name = protocol.name
	self.home_info.item_list = protocol.item_list

	if self:GetIsMyHome() then
		self:SetMyHomeInfo(TableCopy(self.home_info))
	end
end

function SpiritData:GetHomeIsChange()
	return self.home_is_change
end

function SpiritData:SetMyHomeInfo(data)
	self.my_home_info = data
end

function SpiritData:GetMyHomeInfo()
	return self.my_home_info
end

function SpiritData:SetSpiritHomeListInfo(protocol)
	self.home_list.info_count = protocol.info_count
	self.home_list.info_list = protocol.info_list
end

function SpiritData:SetSpiritHomeRecordInfo(protocol)
	self.home_record_list.read_rob_record_time = protocol.read_rob_record_time
	self.home_record_list.record_count = protocol.record_count
	self.home_record_list.rob_record_list = protocol.rob_record_list
end

function SpiritData:SetSpiritHomeRobData(protocol)
	self.home_record_result.role_id = protocol.role_id
	self.home_record_result.rob_lingjing = protocol.rob_lingjing
	self.home_record_result.rob_hunli = protocol.rob_hunli
	self.home_record_result.is_win = protocol.is_win
	self.home_record_result.item_count = protocol.item_count
	self.home_record_result.item_list = protocol.item_list
end

function SpiritData:GetHomeRoleId()
	return self.home_info.role_id or 0
end

function SpiritData:GetHasRewardIndex()
	local index = nil
	local limlit = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit")
	if self.home_info.item_list == nil or limlit == nil then
		return index
	end

	for k,v in pairs(self.home_info.item_list) do
		if v.item_id > 0 and v.reward_times < limlit then
			index = k
			break
		end
	end

	return index
end

function SpiritData:CheckHomeRevengeRed()
	local is_show = false
	if self.home_record_list.rob_record_list == nil then
		return is_show
	end

	if self.home_record_list.read_rob_record_time == nil then
		return is_show
	end

	local check_time = self.home_record_list.read_rob_record_time

	for k,v in pairs(self.home_record_list.rob_record_list) do
		if v ~= nil and v.rob_time > check_time then
			is_show = true
			break
		end
	end

	return is_show
end

function SpiritData:GetSpiritPreviewRed()
	local is_show = false
	local read_data = self:GetMyHomeInfo()
	if read_data == nil then
		return is_show
	end

	if read_data.item_list == nil then
		return is_show
	end

	-- local max_num = self:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
	-- for k,v in pairs(read_data.item_list) do
	-- 	if v ~= nil and v.reward_times >= max_num then
	-- 		is_show = true
	-- 		break
	-- 	end
	-- end
	local other_cfg = self:GetSpiritOtherCfg() or {}
	for k,v in pairs(read_data.item_list) do
		local _, reward_num = SpiritData.Instance:GetSpiritHomeRewardList(k)
		local is_can_reward = TimeCtrl.Instance:GetServerTime() - v.last_get_time > (other_cfg.home_get_reward_interval or 0) * 8
		if reward_num > 0 and is_can_reward then
			is_show = true
			break
		end
	end

	return is_show
end

function SpiritData:ShowHomeRedPoint()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local is_show = false
	for i = 1, 4 do
		local render_red = self:GetHasHomeRenderRed(i)
		if render_red then
			is_show = true
			break
		end
	end
	return self:GetSpiritPreviewRed()
		or is_show --or (self:CheckHomeRevengeRed() and vo.level >= self:GetSpiritOtherCfg().plunder_limit)
		-- or (RemindManager.Instance:GetRemind(RemindName.SpiritPlunder) > 0 and vo.level >= self:GetSpiritOtherCfg().plunder_limit)
end

function SpiritData:ShowSoulRedPoint()
	local  is_show = false
	local soul_bag_info = self:GetSpiritSoulBagInfo()
	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	if slot_soul_info and next(slot_soul_info) then
		local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
		for k, v in pairs(slot_soul_info.slot_list) do
			local id = v.id or -1
			local attr_cfg = self:GetSoulAttrCfg(id, v.level)
			if attr_cfg ~= nil and soul_bag_info and soul_bag_info.hunshou_exp and v.exp then
				is_show = soul_bag_info.hunshou_exp > attr_cfg.exp - v.exp
				if is_show then
					return true
				end
			else
				is_show = false
			end
		end
	else
		is_show = false
	end
	return is_show
end

function  SpiritData:GetSpiritHomeName()
	return self.home_info.name or ""
end

function SpiritData:GetSpiritHarvertLimlit(model_type)
	local cur = 0
	local max = 0
	if "my" == model_type then
		local now = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_HOME_ROB_COUNT)
		max = self:GetSpiritOtherCfgByName("home_rob_times_limit") or 0
		cur = max - now
	elseif "enemy" == model_type then
		if not self:GetIsMyHome() then
			local now = self.home_info.rob_times_of_me or 0
			max = self:GetSpiritOtherCfgByName("home_rob_repeat_limit") or 0
			cur = max - now
		end
	end

	return cur, max
end

function SpiritData:GetPlunderRed()
	local data = self:GetMySpiritInOther()
	if data ~= nil and data.item_id <= 0 then
		return false
	end
	local now = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_HOME_ROB_COUNT)
	local max = self:GetSpiritOtherCfgByName("home_rob_times_limit") or 0
	local is_show = now < max or false

	return is_show
end

function SpiritData:GetSpiritHomePlunderList()
	return self.home_list.info_list or {}
end

function SpiritData:GetSpiritHomeRecordList()
	return self.home_record_list.rob_record_list or {}
end

function SpiritData:GetSpiritBoxType(count)
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").box_color
	local color = 0
	if cfg == nil then
		return color
	end

	-- for k,v in pairs(cfg) do
	-- 	if v ~= nil and v.count <= count then
	-- 		color = v.box_color
	-- 	elseif v ~= nil and v.count > count then
	-- 		break
	-- 	elseif k == #cfg and v ~= nil then
	-- 		color = v.box_color
	-- 	end
	-- end
	local color = 0
	for k,v in pairs(cfg) do
		if v.count <= count then
			color = v.box_color
			if v.count == count then
				break
			end
		else
			color = v.box_color
			break
		end
	end

	return color
end

--是否在自己的家园
function SpiritData:GetIsMyHome()
	local value = true
	if self.home_info == nil or self.home_info.role_id == nil then
		return value
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	value = main_role_vo.role_id == self.home_info.role_id

	return value
end

function SpiritData:SetHarvertSpirit(index)
	self.harvert_index = index
end

function SpiritData:GetHarvertSpirit()
	return self.harvert_index
end

function SpiritData:GetHasHomeRenderRed(index, red_flag)
	local is_show = false
	if self.spirit_info.jingling_list == nil then
		return is_show
	end

	local read_data = self:GetMyHomeInfo()
	if read_data == nil then
		return is_show
	end

	local has_num = 0
	for k,v in pairs(self.spirit_info.jingling_list) do
		if v ~= nil and v.item_id > 0 then
			has_num = has_num + 1
		end
	end

	if read_data.item_list == nil then
		return is_show
	end

	local can_num = 0
	for k,v in pairs(read_data.item_list) do
		if v ~= nil and v.item_id > 0 then
			can_num = can_num + 1
		end
	end

	if has_num > can_num then
		if index == nil then
			return is_show
		end

		local has_red_num = has_num - can_num
		local pos = 0
		for k,v in pairs(read_data.item_list) do
			if v ~= nil and v.item_id <= 0 then
				pos = pos + 1
				if k == index and pos <= has_red_num then
					is_show = true
				end
			end
		end
	end

	return is_show
end

function SpiritData:GetSpiritHomeModelCfg()
	local data = {}
	if self.home_info == nil or self.home_info.item_list == nil then
		return data
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_other = false
	local state = JING_LING_HOME_STATE.MY
	if main_role_vo ~= nil and main_role_vo.role_id ~= self.home_info.role_id then
		is_other = true
		state = JING_LING_HOME_STATE.OTHER
	end

	for k,v in pairs(self.home_info.item_list) do
		if v ~= nil then
			local v_data = {}
			local res_cfg = self:GetSpiritResIdByItemId(v.item_id)
			v_data.res_id = res_cfg and res_cfg.res_id or 0
			v_data.index = k
			v_data.is_other = is_other
			v_data.cap = v.capability
			v_data.state = state
			table.insert(data, v_data)
		end
	end

	-- if is_other then
	-- 	local m_data = self:GetMySpiritInOther()
	-- 	table.insert(data, m_data)
	-- else
	-- 	local m_data = {}
	-- 	m_data.res_id = 0
	-- 	m_data.index = 5
	-- 	m_data.is_other = false
	-- 	m_data.cap = 0
	-- 	m_data.state = JING_LING_HOME_STATE.MY_IN_OTHER
	-- 	table.insert(data, m_data)
	-- end

	return data
end

--取得自己进去别人家园时，需要显示的精灵
--如果当前出战了精灵，就用该精灵，不然取得装备的精灵里战力最高的
function SpiritData:GetMySpiritInOther()
	local spirit_cfg = {
		item_id = 0,
		res_id = 0,
		cap = 0,
		is_other = false,
		state = JING_LING_HOME_STATE.MY_IN_OTHER,
		spirit_name = "",
		is_enter = false,
	}

	local need_check_fight = false
	local use_id = self.spirit_info.use_jingling_id
	if use_id ~= nil and use_id ~= 0 then
		need_check_fight = true
	end

	local max_cap = nil
	local spirit_list = self:GetSendSpiritInfo()
	for k,v in pairs(spirit_list) do
		if v ~= nil then
			if need_check_fight then
				if use_id == v.item_id then
					spirit_cfg.res_id = v.res_id
					spirit_cfg.cap = v.cap
					spirit_cfg.index = 5
					spirit_cfg.read_index = v.index
					spirit_cfg.item_id = v.item_id
					spirit_cfg.spirit_name = v.spirit_name
					spirit_cfg.is_enter = v.is_enter
					break
				end
			else
				if max_cap == nil then
					max_cap = k
				else
					if spirit_list[max_cap].cap < v.cap then
						max_cap = k
					end
				end
			end
		end
	end

	if not need_check_fight and max_cap ~= nil then
		spirit_cfg.res_id = spirit_list[max_cap].res_id
		spirit_cfg.cap = spirit_list[max_cap].cap
		spirit_cfg.index = 5
		spirit_cfg.read_index = spirit_list[max_cap].index
		spirit_cfg.item_id = spirit_list[max_cap].item_id
		spirit_cfg.spirit_name = spirit_list[max_cap].spirit_name
		spirit_cfg.is_enter = spirit_list[max_cap].is_enter
		--spirit_cfg.state = JING_LING_HOME_STATE.MY_IN_OTHER
	end

	return spirit_cfg
end

function SpiritData:GetJingLingDataById(item)
	local data = {}
	if item == nil then
		return data
	end

	if self.spirit_info.jingling_list ~= nil then
		for k,v in pairs(self.spirit_info.jingling_list) do
			if v ~= nil and v.item_id == item then
				data = v
				break
			end
		end
	end

	return data
end

--可放养的精灵的列表
function SpiritData:GetSendSpiritInfo(put_index)
	local cfg_list = {}
	if self.spirit_info.jingling_list == nil then
		return cfg_list
	end

	local check_index = put_index
	local enter_other_flag = self.enter_other_spirit

	for k,v in pairs(self.spirit_info.jingling_list) do
		if v ~= nil then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg ~= nil then
				local data = {}
				data.index = v.index
				data.read_index = v.index
				--data.cap = self:GetSpiritCap(v)
				data.cap = 0
				local read_cap = self:GetSpiritTotalAttr(v.index)
				if read_cap ~= nil then
					data.cap = CommonDataManager.GetCapabilityCalculation(read_cap)
				end

				data.spirit_name = item_cfg.name
				local res_cfg = self:GetSpiritResIdByItemId(v.item_id)
				data.res_id = res_cfg and res_cfg.res_id or 0
				data.send_state = JING_LING_HOME_SEND_STATE.SEND
				data.timer_index = 0
				if enter_other_flag ~= nil and v.index == enter_other_flag then
					data.is_enter = true
				else
					data.is_enter = false
				end

				if check_index ~= nil then
					for i = 1, GameEnum.JINGLING_MAX_TAKEON_NUM do
						local home_spirit_cfg = self:GetSpiritHomeInfoByIndex(i)
						if home_spirit_cfg.item_id ~= nil and home_spirit_cfg.item_id > 0 then
							if home_spirit_cfg.item_id == v.item_id and i == check_index then
								data.send_state = JING_LING_HOME_SEND_STATE.TAKE_BACK
							elseif home_spirit_cfg.item_id == v.item_id then
								data.send_state = JING_LING_HOME_SEND_STATE.REPLACE
								data.timer_index = i
							end
						end
						-- local home_spirit_cfg = self:GetSpiritHomeInfoByIndex(check_index)
						-- if home_spirit_cfg.item_id ~= nil and home_spirit_cfg.item_id > 0 then
						-- 	local state = home_spirit_cfg.item_id == v.item_id and JING_LING_HOME_SEND_STATE.TAKE_BACK or JING_LING_HOME_SEND_STATE.REPLACE
						-- 	data.send_state = state
						-- end
					end
				end
				data.item_id = v.item_id
				data.put_index = put_index
				table.insert(cfg_list, data)
			end
		end
	end

	return cfg_list
end

function SpiritData:GetSpiritHomeInfoByIndex(index)
	local cfg = {}
	if self.home_info == nil or self.home_info.item_list == nil then
		return cfg
	end

	if index ~= nil and self.home_info.item_list[index] ~= nil then
		cfg = self.home_info.item_list[index]
	else
		cfg = self.home_info
	end

	return cfg
end

function SpiritData:GetSpiritHomeRewardList(index)
	local data = self:GetSpiritHomeInfoByIndex(index)
	local reward_num = 0
	if data == nil or next(data) == nil then
		return {}, reward_num
	end

	local read_data = TableCopy(data)
	local lingjing_id = self:GetSpiritOtherCfgByName("lingjing_id")
	if lingjing_id == nil then
		return {}, reward_num
	end

	local hunli_id = self:GetSpiritOtherCfgByName("hunli_id")
	if hunli_id == nil then
		return {}, reward_num
	end

	local lingjing_num = read_data.reward_lingjing
	local hunli_num = read_data.reward_hunli

	for k,v in pairs(read_data.reward_item_list) do
		if v ~= nil and v.is_bind == nil then
			v.is_bind = 1
			v.num = v.item_num
			if v.item_id > 0 then
				reward_num = reward_num + 1
			end
		end
	end

	if hunli_num > 0 then
		reward_num = reward_num + 1
		table.insert(read_data.reward_item_list, 1, {item_id = hunli_id, num = hunli_num, is_bind = 1})
	end

	if lingjing_num > 0 then
		reward_num = reward_num + 1
		table.insert(read_data.reward_item_list, 1, {item_id = lingjing_id, num = lingjing_num, is_bind = 1})
	end

	return read_data, reward_num
end

function SpiritData:GetSpiritCap(data)
	local fight_power = 0
	local APTITUDE_TYPE = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
	local ATTR_TYPE = {"gongji", "fangyu", "maxhp"}
    local spirit_level_cfg = self:GetSpiritLevelCfgByLevel(data.index)
    if spirit_level_cfg == nil then
    	return fight_power
    end

    local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
    local talent_attr = self:GetSpiritTalentAttrCfgById(data.item_id)
    local had_base_attr = {}
    local wuxing = data.param.param1

    for k, v in pairs(attr) do
    	if v > 0 then
    		table.insert(had_base_attr, {key = k, value = v})
    	end
    end

    local aptitude = {}
    for i=1,3 do
    	--aptitude[APTITUDE_TYPE[i]] = talent_attr[APTITUDE_TYPE[i]]
    	table.insert(aptitude, talent_attr[APTITUDE_TYPE[i]])
    end

    local attr_after_aptitude = {}
    for k,v in pairs(had_base_attr) do
    	local value = self:GetAttrByAptitude(v.value, aptitude[k], wuxing, APTITUDE_TYPE[k])
   		attr_after_aptitude[v.key] = v.value
    end

    fight_power = CommonDataManager.GetCapabilityCalculation(attr_after_aptitude) or 0

   	return fight_power
end

function SpiritData:SetFightResult(reason)
	if reason == 0 then
		self.home_fight_win = "enemy"
	else
		self.home_fight_win = "my"
	end
end

function SpiritData:ResetFightResult()
	self.home_fight_win = nil
	self.harvert_index = nil
end

function SpiritData:GetFightResult()
	return self.home_fight_win
end

function SpiritData:GetHomeFightMaxHp(model_type)
	local max_hp = 0
	if model_type == "my" then
		local my_cfg = self:GetEnterOtherSpirit()
		if my_cfg == nil and my_cfg.item_id == 0 then
			return max_hp
		end

		local my_cap = my_cfg.cap
		max_hp = math.floor(my_cap / 0.2)
	else
		local enemy_index = self:GetHarvertSpirit()
	 	if enemy_index == nil then
	 		return max_hp
	 	end

	 	local enemy_cfg = self:GetSpiritHomeInfoByIndex(enemy_index)
	 	if enemy_cfg == nil then
	 		return max_hp
	 	end
	 	local enemy_cap = enemy_cfg.capability
	 	max_hp = math.floor(enemy_cap / 0.2)
	end

	return max_hp
end

--取得战斗信息
function SpiritData:GetFightInfo(target)
	--local my_cfg = self:GetMySpiritInOther()
	local my_cfg = self:GetEnterOtherSpirit()
	if my_cfg == nil and my_cfg.item_id == 0 then
		return nil
	end


 	local enemy_index = self:GetHarvertSpirit()
 	if enemy_index == nil then
 		return nil
 	end
 	local enemy_cfg = self:GetSpiritHomeInfoByIndex(enemy_index)
 	if enemy_cfg == nil then
 		return
 	end

 	local my_cap = my_cfg.cap
	local enemy_cap = enemy_cfg.capability

	if self.home_fight_win == nil then
		return nil
	end

	-- if my_cap == nil or enemy_cap == nil then
	-- 	return nil
	-- end

	-- local result = self.home_fight_win
	-- local blood = 0
	-- local floating_data = {}
	-- if target == result then
	-- 	blood = math.random(20, 24)
	-- 	floating_data.fighttype = FIGHT_TYPE.NORMAL
	-- 	floating_data.blood = blood * 0.01 * 10000
	-- 	floating_data.percent = blood * 0.01
	-- 	floating_data.pos = {is_left = false, is_top = true}
	-- 	floating_data.text_type = FIGHT_TEXT_TYPE.NORMAL
	-- else
	-- 	local fighttype = FIGHT_TYPE.NORMAL
	-- 	if my_cap > enemy_cap then
	-- 		blood = math.random(25, 30)
	-- 	else
	-- 		blood = math.random(25, 35)
	-- 		local value = math.abs(my_cap - enemy_cap) / my_cap
	-- 		if value <= 0.1 and blood >= 30 then
	-- 			fighttype = FIGHT_TYPE.BAOJI
	-- 		elseif value <= 0.2 and blood >= 28 then
	-- 			fighttype = FIGHT_TYPE.BAOJI
	-- 		elseif value <= 0.3 and blood >= 26 then
	-- 			fighttype = FIGHT_TYPE.BAOJI
	-- 		elseif value <= 0.4 and blood >= 25 then
	-- 			fighttype = FIGHT_TYPE.BAOJI
	-- 		end
	-- 	end

	-- 	floating_data.fighttype = fighttype
	-- 	floating_data.blood = blood * 0.01 * 10000
	-- 	floating_data.percent = blood * 0.01
	-- 	floating_data.pos = {is_left = false, is_top = true}
	-- 	floating_data.text_type = FIGHT_TEXT_TYPE.NORMAL
	-- end
	local fight_list = {}
	local fight_time = 4
	local my_all_lost = 0
	local enemy_all_lost = 0
	local is_my_win = self.home_fight_win == "my"
	local my_max_hp = my_cap / 0.2
	local emeny_max_hp = enemy_cap / 0.2
	local enemy_loss_hp = emeny_max_hp
	local my_loss_hp = my_max_hp

	local fight_tab = {
		fighttype = FIGHT_TYPE.NORMAL,
		blood = 0,
		percent = 0,
		pos = {is_left = false, is_top = true},
		text_type = FIGHT_TEXT_TYPE.NORMAL,
	}


	if is_my_win then
		my_loss_hp = math.floor(my_max_hp - enemy_cap / my_cap * emeny_max_hp)
		if my_loss_hp == 0 then
			my_loss_hp = math.floor(my_max_hp - my_max_hp * 0.03)
		else
			my_loss_hp = math.floor(my_max_hp - my_loss_hp)
		end
		--my_loss_hp = math.floor(my_max_hp - ((my_max_hp - emeny_max_hp) + 0.05 * my_max_hp))
	else
		--enemy_loss_hp = math.floor(enemy_cap / my_cap * emeny_max_hp - my_max_hp)
		enemy_loss_hp = math.floor(emeny_max_hp - my_max_hp / (enemy_cap / my_cap))
		if enemy_loss_hp == 0 then
			enemy_loss_hp = math.floor(emeny_max_hp - emeny_max_hp * 0.03)
		else
			enemy_loss_hp = math.floor(emeny_max_hp - enemy_loss_hp)
		end
		--enemy_loss_hp = math.floor(emeny_max_hp - my_max_hp)
	end

	for i = 1, fight_time do
		local data = {}
		local blood_per = 0
		local blood = 0

		if i == fight_time then
			-- if is_my_win then
			-- 	blood = (enemy_loss_hp - enemy_all_lost) * math.random(1, 1.2)
			-- 	blood_per = 100
			-- 	enemy_all_lost = enemy_all_lost + blood
			-- else
				blood = enemy_loss_hp - enemy_all_lost
				blood_per = blood / enemy_loss_hp * 100
				enemy_all_lost = enemy_all_lost + blood
			-- end
		else
			-- blood_per = math.random(math.floor((1 / fight_time * 100 - 5)), math.floor(1 / fight_time * 100))
			-- blood = blood_per * enemy_loss_hp * 0.01
			-- enemy_all_lost = enemy_all_lost + blood
			blood_per = 25 +  math.random(-3, 3)
			blood = blood_per * enemy_loss_hp * 0.01
			enemy_all_lost = enemy_all_lost + blood
		end
		data["enemy"] = TableCopy(fight_tab)
		data["enemy"].blood = math.ceil(blood)
		data["enemy"].percent = blood_per * 0.01
		data["enemy"].pos = {is_left = false, is_top = true}
		data["enemy"].cur_hp =  math.floor(emeny_max_hp - enemy_all_lost)


		if i == fight_time then
			-- if is_my_win then
				blood = my_loss_hp - my_all_lost
				blood_per = blood / my_loss_hp
				my_all_lost = my_all_lost + blood
			-- else
			-- 	blood = (my_loss_hp - my_all_lost) * math.random(1, 1.2)
			-- 	blood_per = 100
			-- 	my_all_lost = my_all_lost + blood
			-- end
		else
			-- blood_per = math.random(math.floor((1 / fight_time * 100 - 5)), math.floor(1 / fight_time * 100))
			-- blood = blood_per * my_loss_hp * 0.01
			-- my_all_lost = my_all_lost + blood

			blood_per = 20 +  math.random(-3, 3)
			blood = blood_per * my_loss_hp * 0.01
			my_all_lost = my_all_lost + blood
		end
		data["my"] = TableCopy(fight_tab)
		data["my"].blood = math.ceil(blood)
		data["my"].percent = blood_per * 0.01
		data["my"].pos = {is_left = false, is_top = true}
		data["my"].cur_hp = math.floor(my_max_hp - my_all_lost)

		table.insert(fight_list, data)
	end

	return fight_list
	--return floating_data
end

function SpiritData:GetQuickGetList()
	return self.quick_list or {}
end

function SpiritData:SetQuickRewardList(quick_list)
	self.quick_list = quick_list
end

function SpiritData:GetSpiritOtherCfgByName(str)
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1][str]
end

function SpiritData:GetEnterOtherSpirit()
	local fight_spirit = {}
	if self.enter_other_spirit ~= nil then
		local spirit_list = self:GetSendSpiritInfo()
		for k,v in pairs(spirit_list) do
			if v ~= nil then
				if self.enter_other_spirit == v.index then
					fight_spirit.res_id = v.res_id
					fight_spirit.cap = v.cap
					fight_spirit.index = v.index
					fight_spirit.read_index = v.index
					fight_spirit.item_id = v.item_id
					fight_spirit.spirit_name = v.spirit_name
					break
				end
			end
		end

		if next(fight_spirit) == nil then
			self.enter_other_spirit = nil
		end
	else
		fight_spirit = self:GetMySpiritInOther()
		self.enter_other_spirit = fight_spirit.read_index
	end

	return fight_spirit
end

function SpiritData:SetEnterOtherSpirit(index)
	self.enter_other_spirit = index
end

function SpiritData:SetHarvertLastData(data)
	self.last_harvert_data = data
end

function SpiritData:GetHarvertLastData()
	local data = {}
	local read_data = {}

	local lingjing_id = self:GetSpiritOtherCfgByName("lingjing_id") or 0
	local hunli_id = self:GetSpiritOtherCfgByName("hunli_id") or 0

	if self.home_record_result.rob_lingjing > 0 then
		table.insert(data, {item_id = lingjing_id, num = self.home_record_result.rob_lingjing, is_bind = 1})
	end

	if self.home_record_result.rob_hunli > 0 then
		table.insert(data, {item_id = hunli_id, num = self.home_record_result.rob_hunli, is_bind = 1})
	end

	-- for k,v in pairs(self.home_record_result.item_list) do
	-- 	if v ~= nil and v.item_id > 0 and v.item_num > 0 then
	-- 		table.insert(data, {item_id = v.item_id, num = v.item_num, is_bind = 1})
	-- 	end
	-- end
	for k,v in pairs(self.home_record_result.item_list) do
		if v ~= nil and v.item_id > 0 and v.item_num > 0 and data[v.item_id] == nil then
			data[v.item_id] =  {item_id = v.item_id, num = v.item_num, is_bind = 1}
		else
			if data[v.item_id] ~= nil and data[v.item_id].num ~= nil then
				data[v.item_id].num = data[v.item_id].num + 1
			end
		end
	end

	for k,v in pairs(data) do
		if v ~= nil then
			table.insert(read_data, v)
		end
	end

	return read_data
end

-- function SpiritData:SetSpiritExpModel(model)
-- 	self.spirit_exp_model = model
-- end

-- function SpiritData:GetSpiritExpModel()
-- 	return self.spirit_exp_model
-- end
------------精灵探险---------------------------
function SpiritData:SetSpiritExploreInfo(protocol)
	self.spirit_explore.reason = protocol.reason

	if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC == protocol.reason or
		 JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_FAIL == protocol.reason then
		self:SetExploreResult(protocol.reason, cur_stage)

		if self:GetExpFightCfg() == nil then
			self:SetExpFightCfg(TableCopy(self.spirit_explore))
		end
	elseif JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_RESET == protocol.reason then
		self:SetExploreResult(nil, nil)
		self:SetExpFightCfg(nil)
		self:SetExpFightMyCfg(nil)
	end

	self.spirit_explore.explore_mode = protocol.explore_mode
	self.spirit_explore.explore_maxhp = protocol.explore_maxhp
	self.spirit_explore.explore_hp = protocol.explore_hp
	self.spirit_explore.explore_info_list = protocol.explore_info_list
	self.spirit_explore.buy_buff_count = protocol.buy_buff_count
end

-- 精灵奇遇
function SpiritData:SetSpiritMeetInfo(protocol)
	self.spirit_meet_info.pos_list = protocol.pos_list
end

function SpiritData:SetSpiritMeetCount(protocol)
	self.spirit_meet_info.today_gather_blue_jingling_count = protocol.today_gather_blue_jingling_count
end


function SpiritData:GetExploreBuyBuffCount()
	return self.spirit_explore.buy_buff_count or 0
end

function SpiritData:GetSpiritExploreInfo()
	return self.spirit_explore
end

function SpiritData:GetSpiritExpMode()
	return self.spirit_explore.explore_mode or 0
end

--最大血量为0说明还没选择模式
function SpiritData:GetSpiritModeMaxHp()
	return self.spirit_explore.explore_maxhp or 0
end

function SpiritData:GetHasCanReset()
	local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE_RESET)
	local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0
	if limlit_count - day_count > 0 then
		return true
	end

	return false
end

function SpiritData:GetHasCanChanllge()
	local is_has = false
	local all_explore_times = self:GetSpiritOtherCfgByName("explore_times") or 0
	local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE)
	local cur_stage = self:GetCurChallenge()
	local has_chanllge_time = all_explore_times - day_count > 0
	if has_chanllge_time then
		local cur_stage = self:GetCurChallenge()
		if cur_stage <= GameEnum.JING_LING_EXPLORE_LEVEL_COUNT then
			is_has = true
		end
	end
	local max_hp = self.spirit_explore.explore_maxhp or 0
	if max_hp == 0 then
		is_has = true
	end

	return is_has
end

function SpiritData:GetStageInfoByIndex(index)
	local data = {}
	local all_list = self.spirit_explore.explore_info_list
	if all_list == nil or all_list[index] == nil then
		return data
	end

	return all_list[index]
end

function SpiritData:SetExploreResult(result, stage)
	self.explore_result = result
	self.result_stage = stage
end

function SpiritData:SetExpFightCfg(cfg)
	self.exp_fight_cfg = cfg
end

function SpiritData:GetExpFightCfg()
	return self.exp_fight_cfg
end

function SpiritData:SetExpFightMyCfg(cfg)
	self.my_fight_cfg = cfg
end

function SpiritData:GetExpFightMyCfg()
	return self.my_fight_cfg
end

function SpiritData:GetExploreResult()
	local result = "enemy"
	if self.explore_result == nil then
		return result
	end

	if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC == self.explore_result then
		result = "my"
	end

	return result
end

function SpiritData:GetCurChallenge()
	local stage = 1
	local stage_list = self.spirit_explore.explore_info_list
	if stage_list == nil then
		return stage
	end

	for i = 1, GameEnum.JING_LING_EXPLORE_LEVEL_COUNT do
		if stage_list[i] ~= nil and stage_list[i].hp <= 0 then
			stage = stage + 1
		else
			break
		end
	end

	-- if stage > GameEnum.JING_LING_EXPLORE_LEVEL_COUNT then
	-- 	stage = GameEnum.JING_LING_EXPLORE_LEVEL_COUNT
	-- end

	return stage
end

function SpiritData:GetStageHPStr(model_type, is_fight)
	local cur_hp = 0
	local max_hp = 0
	if model_type == nil then
		return cur_hp, max_hp
	end

	if "my" == model_type then
		local cur_data = self:GetSpiritExploreInfo()
		--local cur_data = self:GetExpFightMyCfg()
		if cur_data == nil or next(cur_data) == nil then
			return cur_hp, max_hp
		end

		if is_fight then
			local data = self:GetExpFightCfg()
			if data ~= nil then
				max_hp = math.floor(data.explore_maxhp)
				local result = self:GetExploreResult()
				if result == "my" then
					local change_hp = cur_data.explore_hp - data.explore_hp - data.explore_hp * 0.05
					if change_hp <= 0 then
						cur_hp = math.floor(data.explore_hp + 10)
					else
						cur_hp = math.floor(data.explore_hp)
					end
				else
					cur_hp = math.floor(data.explore_hp)
				end
			end
		else
			cur_hp = math.floor(cur_data.explore_hp)
			max_hp = math.floor(cur_data.explore_maxhp)
		end
	else
		local cur_stage = self:GetCurChallenge()
		local read_cur_data = self:GetStageInfoByIndex(cur_stage)
		local hp_percent = self:GetSpiritOtherCfgByName("explore_hp_percent")
		--local hp = cur_data.hp
		--if is_fight and cur_data.last_hp ~= nil then
			--hp = cur_data.last_hp - cur_data.hp
		-- if cur_data.last_hp ~= nil then
		-- 	hp = cur_data.last_hp
		-- end
		if is_fight then
			local cur_data = self:GetExpFightCfg()
			if cur_data == nil or next(cur_data) == nil then
				return cur_hp, max_hp
			end
			local data = self:GetExpFightCfg()
			if data ~= nil then
				for i = 1, 6 do
					if data.explore_info_list[i].hp > 0 then
						cur_hp = math.floor(data.explore_info_list[i].hp)
						max_hp = math.floor(data.explore_info_list[i].capability * hp_percent * 0.01)
						break
					end
				end
			end
		else
			cur_hp = math.floor(read_cur_data.hp)
			max_hp = math.floor((read_cur_data.capability * hp_percent * 0.01))
		end

		-- if hp_percent ~= nil then
		-- 	--str = cur_data.hp .. "/" .. (cur_data.capability * hp_percent * 0.01)
		-- 	cur_hp = math.floor(hp)
		-- 	max_hp = math.floor((cur_data.capability * hp_percent * 0.01))
		-- end
	end

	return cur_hp, max_hp
end

function SpiritData:GetExpMaxHp(model_type)
	local value = 0
	if model_type == nil then
		return value
	end

	if "my" == model_type then
		-- local all_data = self:GetSpiritExploreInfo()
		-- if all_data == nil or next(all_data) == nil then
		-- 	return value
		-- end

		local my_data = self:GetExpFightCfg()
		if my_data ~= nil then
			value = my_data.explore_maxhp
		end
	else
		--local cur_stage = self:GetCurChallenge()
		--local cur_data = self:GetStageInfoByIndex(cur_stage)
		local cur_data = self:GetExpFightCfg()
		if cur_data == nil or next(cur_data) == nil then
			return value
		end

		local capability = 0
		for i = 1, 6 do
			if cur_data.explore_info_list[i].hp > 0 then
				capability = cur_data.explore_info_list[i].capability
				break
			end
		end

		local hp_percent = self:GetSpiritOtherCfgByName("explore_hp_percent")
		if hp_percent == nil then
			return value
		end

		value = hp_percent * capability * 0.01
	end

	return value
end

function SpiritData:GetExploreReward(stage_index, show_reward, mode)
	local data_list = {}
	if stage_index == nil then
		return data_list
	end

	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").explore_reward
	if cfg == nil or next(cfg) == nil then
		return data_list
	end

	local cur_mode = mode or self:GetSpiritExpMode()
	local stage = stage_index or self:GetCurChallenge()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role_vo.level

	local gift_id = 0
	for k,v in pairs(cfg) do
		if v ~= nil and v.mode == cur_mode and v.level == stage - 1 and v.role_level >= level then
			if show_reward and v.reward_item[0] then
				gift_id = v.reward_item[0].item_id
				if gift_id > 0 then
					return ItemData.Instance:GetGiftItemList(gift_id)
				end
			else
				return v.show_item
			end
		end
	end

	return data_list
end

function SpiritData:GetExpSpiritName(item_name)
	local name = ""
	local cur_stage = self:GetCurChallenge()
	local cur_data = self:GetStageInfoByIndex(cur_stage)
	--local cur_data = self:GetExpFightCfg()
	local my_cfg = self:GetMySpiritInOther()
	if cur_data == nil or next(cur_data) == nil then
		return name
	end

	if item_name == nil then
		return name
	end

	--local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").explore_name
	--if cfg == nil then
		--return name
	--end

	if cur_data.name_id ~= nil and cur_data.capability ~= nil then
		local prefix_name = cur_data.capability > my_cfg.cap and Language.JingLing.SpiritExpPrefix or ""
		--local ran_name = cfg[cur_data.name_id]
		--if ran_name ~= nil then
			--name = prefix_name .. item_name
		--else
			--name = prefix_name .. (cfg[1] or "")
		--end
		name = prefix_name .. item_name
	end

	return name
end

function SpiritData:GetSpiritExpFightList()
	local fight_list = {}
	--local cur_stage = self:GetCurChallenge()
	--local cur_data = self:GetStageInfoByIndex(cur_stage)
	local cur_data = self:GetExpFightCfg()
	if cur_data == nil or next(cur_data) == nil then
		return fight_list
	end

	local all_data = self:GetSpiritExploreInfo()
	--local all_data = self:GetExpFightMyCfg()
	if all_data == nil or next(all_data) == nil then
		return fight_list
	end

	local hp_percent = self:GetSpiritOtherCfgByName("explore_hp_percent")
	if hp_percent == nil then
		return fight_list
	end

	local fight_tab = {
		fighttype = FIGHT_TYPE.NORMAL,
		blood = 0,
		percent = 0,
		pos = {is_left = false, is_top = true},
		text_type = FIGHT_TEXT_TYPE.NORMAL,
	}

	--local max_hp = hp_percent * cur_data.capability * 0.01
	--local enemy_loss_hp = math.ceil(cur_data.hp)
	local max_hp = 1
	local enemy_loss_hp = 0
	local enemy_cur_hp = 0

	for i = 1, 6 do
		if cur_data.explore_info_list[i].hp > 0 then
			enemy_loss_hp = cur_data.explore_info_list[i].hp - all_data.explore_info_list[i].hp
			max_hp = cur_data.explore_info_list[i].capability * hp_percent * 0.01
			enemy_cur_hp = cur_data.explore_info_list[i].hp
			break
		end
	end

	local my_loss_hp = 0
	local my_max_hp = 1
	local my_cur_hp = 0
	if cur_data ~= nil then
		local result = self:GetExploreResult()
		if result == "my" then
			local change_hp = cur_data.explore_hp + cur_data.explore_hp * 0.05 - all_data.explore_hp
			if change_hp <= 0 then
				my_cur_hp = math.floor(cur_data.explore_hp + 10)
				change_hp = cur_data.explore_hp
			else
				my_cur_hp = math.floor(cur_data.explore_hp)
				-- change_hp = math.floor(cur_data.explore_hp)
			end
			my_loss_hp = change_hp
			my_max_hp = cur_data.explore_maxhp
		else
			my_cur_hp = cur_data.explore_hp
			my_max_hp = cur_data.explore_maxhp
			my_loss_hp = cur_data.explore_hp
		end
	end

	--local my_loss_hp = math.ceil(all_data.explore_maxhp - all_data.explore_hp)
	--local my_loss_hp = math.ceil(all_data.explore_hp)
	local fight_time = 0
	local is_my_win = self.spirit_explore.reason == JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC
	-- if not is_my_win then
	-- 	my_loss_hp = all_data.explore_maxhp
	-- end

	if is_my_win then
		fight_time = math.ceil(enemy_loss_hp / max_hp * 4)
	else
		fight_time = math.ceil(my_loss_hp / my_max_hp * 4)
	end

	if fight_time <= 0 then
		return fight_list
	end

	local my_all_lost = 0
	local enemy_all_lost = 0
	for i = 1, fight_time do
		local data = {}
		local blood_per = 0
		local blood = 0

		if i == fight_time then
			if is_my_win then
				blood = (enemy_loss_hp - enemy_all_lost) * math.random(1, 1.2)
				blood_per = 100
				enemy_all_lost = enemy_all_lost + blood
			else
				blood = enemy_loss_hp - enemy_all_lost
				blood_per = blood / enemy_loss_hp * 100
				enemy_all_lost = enemy_all_lost + blood
			end
		else
			blood_per = math.random(math.floor((1 / fight_time * 100 - 5)), math.floor(1 / fight_time * 100))
			blood = blood_per * enemy_loss_hp * 0.01
			enemy_all_lost = enemy_all_lost + blood
		end
		data["enemy"] = TableCopy(fight_tab)
		data["enemy"].blood = math.ceil(blood)
		data["enemy"].percent = blood_per * 0.01
		data["enemy"].pos = {is_left = false, is_top = true}
		data["enemy"].cur_hp =  math.floor(enemy_cur_hp - enemy_all_lost)


		if i == fight_time then
			if is_my_win then
				blood = my_loss_hp - my_all_lost
				blood_per = blood / my_loss_hp
				my_all_lost = my_all_lost + blood
			else
				blood = (my_loss_hp - my_all_lost) * math.random(1, 1.2)
				blood_per = 100
				my_all_lost = my_all_lost + blood
			end
		else
			blood_per = math.random(math.floor((1 / fight_time * 100 - 5)), math.floor(1 / fight_time * 100))
			blood = blood_per * my_loss_hp * 0.01
			my_all_lost = my_all_lost + blood
		end
		data["my"] = TableCopy(fight_tab)
		data["my"].blood = math.ceil(blood)
		data["my"].percent = blood_per * 0.01
		data["my"].pos = {is_left = false, is_top = true}
		data["my"].cur_hp = math.floor(my_cur_hp - my_all_lost)

		table.insert(fight_list, data)
	end
	return fight_list
end

function SpiritData:GetSpiritExpConfig(mode, index)
	local data = {}
	if mode == nil or index == nil then
		return data
	end

	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").explore
	if cfg == nil then
		return data
	end

	for k,v in pairs(cfg) do
		if v ~= nil and v.mode == mode and v.level == index then
			data = v
			break
		end
	end

	return data
end

function SpiritData:SetExploreGetStageIndex(stage_index)
	self.explore_get_index = stage_index
end

function SpiritData:GetExploreGetStageIndex()
	return self.explore_get_index
end

------------------------------阵法----------------------------
--获取阵法信息
function SpiritData:GetZhenfaCfgByLevel(level)
	local zhen_fa_cfg = self:GetSpiritZhenfaCfg()
	for k,v in pairs(zhen_fa_cfg) do
		if v.xianzhen_level == level then
			return v
		end
	end
end

function SpiritData:GetHunyuCfg(hunyu_type,level)
	local hunyu_cfg = self:GetSpiritHunyuCfg()
	for k,v in pairs(hunyu_cfg) do
		if v.hunyu_type == hunyu_type and v.hunyu_level == level then
			return v
		end
	end
end

function SpiritData:GetHunyuMaxLevel()
	local hunyu_cfg = self:GetSpiritHunyuCfg()
	return (#hunyu_cfg / 3) - 1
end

function SpiritData:GetZhenfaMaxLevel()
	local zhen_fa_cfg = self:GetSpiritZhenfaCfg()
	return #zhen_fa_cfg
end

function SpiritData:GetZhenfaAttrList()
	local zhenfa_attr_list ={}
	local spirit_info = self:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_info = self:GetZhenfaCfgByLevel(zhenfa_level)
	local zhenfa_rate = zhenfa_info.convert_rate /100
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.ATTACK_HUNYU, hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU])
	local attackhunyu_rate = attackhunyu_cfg and attackhunyu_cfg.convert_rate or 0
	local defensehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.DEFENSE_HUNYU, hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU])
	local defensehunyu_rate = defensehunyu_cfg and defensehunyu_cfg.convert_rate or 0
	local lifehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.LIFE_HUNYU,hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU])
	local lifehunyu_rate = lifehunyu_cfg and lifehunyu_cfg.convert_rate or 0
	local display_list = self:GetSpiritInfo().jingling_list or {}
	local use_jingling_id = self:GetSpiritInfo().use_jingling_id
	local spirit_attack = {}
	local spirit_defense = {}
	local spirit_life = {}
	if display_list then
		local i = 1
		for k, v in pairs(display_list) do
			if v.item_id > 0 and use_jingling_id ~= v.item_id then
				local spirit_cfg = self:GetSpiritResIdByItemId(v.item_id)
				local spirit_level = v.param.strengthen_level
				spirit_level_cfg = self:GetSpiritLevelCfgByLevel(k,spirit_level)
				spirit_attack[i] = spirit_level_cfg.gongji
				spirit_defense[i] = spirit_level_cfg.fangyu
				spirit_life[i] = spirit_level_cfg.maxhp
				local wuxing = 0
				if v.param then
					wuxing = v.param.param1
				end
				local wuxing_cfg = self:GetWuXingCfgByLevel(wuxing)
				if wuxing_cfg then
					spirit_attack[i] = self:GetAttrByAptitude(spirit_attack[i],0,wuxing,"gongji_zizhi")
					spirit_defense[i] = self:GetAttrByAptitude(spirit_defense[i],0,wuxing,"fangyu_zizhi")
					spirit_life[i] = self:GetAttrByAptitude(spirit_life[i],0,wuxing,"maxhp_zizhi")
				end
				--wuxing[i] = spirit_level_cfg.wuxing
				i = i + 1
			end
		end
	end
	zhenfa_attr_list["zhenfa_rate"] = zhenfa_rate
	zhenfa_attr_list["attackhunyu_rate"] = attackhunyu_rate / 100
	zhenfa_attr_list["defensehunyu_rate"] = defensehunyu_rate / 100
	zhenfa_attr_list["lifehunyu_rate"] = lifehunyu_rate / 100
	zhenfa_attr_list["gong_ji"] = 0
	zhenfa_attr_list["fang_yu"] = 0
	zhenfa_attr_list["max_hp"] = 0
	zhenfa_attr_list["wu_xing"] = 0
	for i, j in ipairs(spirit_attack) do
		zhenfa_attr_list["gong_ji"] = j * (zhenfa_rate / 100 + zhenfa_attr_list["attackhunyu_rate"] / 100) + zhenfa_attr_list["gong_ji"]
	end
	for i, j in ipairs(spirit_defense) do
		zhenfa_attr_list["fang_yu"] = j * (zhenfa_rate / 100 + zhenfa_attr_list["defensehunyu_rate"] / 100) + zhenfa_attr_list["fang_yu"]
	end
	for i, j in ipairs(spirit_life) do
		zhenfa_attr_list["max_hp"] = (j * (zhenfa_rate / 100 + zhenfa_attr_list["lifehunyu_rate"] / 100)) + zhenfa_attr_list["max_hp"]
	end
	return zhenfa_attr_list
end

function SpiritData:GetSpiritZhenfaCapacityByIndex(sprite_index)
	local zhenfa_attr_list ={}
	local spirit_info = self:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_info = self:GetZhenfaCfgByLevel(zhenfa_level)
	local zhenfa_rate = zhenfa_info.convert_rate /100
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.ATTACK_HUNYU, hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU])
	local attackhunyu_rate = attackhunyu_cfg and attackhunyu_cfg.convert_rate or 0
	local defensehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.DEFENSE_HUNYU, hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU])
	local defensehunyu_rate = defensehunyu_cfg and defensehunyu_cfg.convert_rate or 0
	local lifehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.LIFE_HUNYU,hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU])
	local lifehunyu_rate = lifehunyu_cfg and lifehunyu_cfg.convert_rate or 0
	local sprite_info = self:GetSpiritInfo().jingling_list[sprite_index]

	if nil == sprite_info then
		return {}
	end

	local use_jingling_id = self:GetSpiritInfo().use_jingling_id
	local spirit_attack = 0
	local spirit_defense = 0
	local spirit_life = 0

	if sprite_info.item_id > 0 and use_jingling_id ~= sprite_info.item_id then
		local spirit_cfg = self:GetSpiritResIdByItemId(sprite_info.item_id)
		local spirit_level = sprite_info.param.strengthen_level
		spirit_level_cfg = self:GetSpiritLevelCfgByLevel(sprite_index, spirit_level)
		spirit_attack = spirit_level_cfg.gongji
		spirit_defense = spirit_level_cfg.fangyu
		spirit_life = spirit_level_cfg.maxhp

		local wuxing = 0
		if sprite_info.param then
			wuxing = sprite_info.param.param1
		end
		local wuxing_cfg = self:GetWuXingCfgByLevel(wuxing)
		if wuxing_cfg then
			spirit_attack = self:GetAttrByAptitude(spirit_attack, 0,wuxing,"gongji_zizhi")
			spirit_defense = self:GetAttrByAptitude(spirit_defense, 0, wuxing, "fangyu_zizhi")
			spirit_life = self:GetAttrByAptitude(spirit_life, 0, wuxing, "maxhp_zizhi")
		end
	end

	zhenfa_attr_list["gong_ji"] = spirit_attack * (zhenfa_rate / 100 + attackhunyu_rate / 10000)
	zhenfa_attr_list["fang_yu"] = spirit_defense * (zhenfa_rate / 100 + defensehunyu_rate / 10000)
	zhenfa_attr_list["max_hp"] = spirit_life * (zhenfa_rate / 100 + lifehunyu_rate / 10000)

	return zhenfa_attr_list
end

--获取加上悟性加成后的属性
function SpiritData:GetAddWuxingCap(base_attr, wuxing)
	local attr = TableCopy(base_attr)
	attr.gongji = base_attr.gongji or 0
	attr.fangyu = base_attr.fangyu or 0
	attr.maxhp = base_attr.maxhp or 0
	local wuxing_cfg = self:GetWuXingCfgByLevel(wuxing)
	if wuxing_cfg then
		attr.gongji = math.floor(attr.gongji * (1 + wuxing_cfg.gongji_zizhi / 1000) + wuxing_cfg.gongji)
		attr.fangyu = math.floor(attr.fangyu * (1 + wuxing_cfg.fangyu_zizhi / 1000) + wuxing_cfg.fangyu)
		attr.maxhp = math.floor(attr.maxhp * (1 + wuxing_cfg.maxhp_zizhi / 1000) + wuxing_cfg.maxhp)
	end
	return CommonDataManager.GetCapability(attr)
end

------------------------------阵法/end----------------------------

-- 是否有可以装备的精灵
function SpiritData:GetCanEquip()
	local  bag_list = self:GetBagBestSpirit()
	local jingling_list = self.spirit_info.jingling_list
	if self:GetSpiritItemIndex() == nil then
		return false
	end
	for k,v in pairs(bag_list) do
		local can_equip = true
		for k1,v1 in pairs(jingling_list) do
			if v.item_id == v1.item_id then
				can_equip=false
			end
		end
		if can_equip == true then
			return true
		end
	end
	return false
end

--GetAttrByAptitude基础属性，0，悟性等级，资质种类
function SpiritData:GetAttrByAptitude(base_attr,aptitude,wuxing,aptitude_type)
	local  wuxing_data = self:GetWuXing()
	return math.floor(base_attr*(1 + (aptitude + wuxing_data[wuxing][aptitude_type])/ 1000)) + wuxing_data[wuxing][SPIRIT_ATTR_APTITUDE[aptitude_type]]
end

function SpiritData:GetStrenthMaxLevelByid(index)
	if self.spirit_info.jingling_list[index] == nil then return true end
	return self.spirit_info.jingling_list[index].param.strengthen_level ~= self.max_spirit_level
end

function SpiritData:IsMaxLevel(index)
	return self.spirit_info.jingling_list[index].param.strengthen_level == self.max_spirit_level
end

function SpiritData:IsMaxWuXing(index)
	local wuxing_data = self:GetWuXing()
	return self.spirit_info.jingling_list[index].param.param1 == wuxing_data[#wuxing_data].wuxing_level
end

function SpiritData:GetNextWuXingBySkillNum(skill_num)
	local  wuxing_data = self:GetWuXing()
	for k,v in ipairs(wuxing_data) do
		if v.skill_num > skill_num then
			return v.wuxing_level
		end
	end
	return wuxing_data[#wuxing_data].skill_num
end

function SpiritData:GetMaxSkillNum()
	local  wuxing_data = self:GetWuXing()
	return wuxing_data[#wuxing_data].skill_num
end


function SpiritData:GetSpiritNameById(param)
	local cfg = SpiritData.Instance:GetSpiritResourceCfg()
	local name = ""
	for k,v in pairs(cfg) do
		if v.id == param then
			name = v.name
			break
		end
	end
	return name
end

function SpiritData:GetSpiritListLength()
	local index = 0
	if self.spirit_info then
		if self.spirit_info.jingling_list then
			for k,v in pairs(self.spirit_info.jingling_list) do
				index = index + 1
			end
		end
	end
	return index
end

function SpiritData:GetRecycleText(wu_xing)
	local wuxing_data = self:GetWuXing()
	if wuxing_data[wu_xing].recycle_stuff_num == 0 then
		return Language.Tip.IsSureRecoverJl
	else
		return string.format(Language.Tip.IsSureRecoverJlWuXing,"*" .."<color=" ..TEXT_COLOR.YELLOW .. ">".. wuxing_data[wu_xing].recycle_stuff_num .. "</color>")
	end
end

function SpiritData:GetOneKeyRecycleText(color1,color2)
	local bag_list = self:GetBagSpiritDataList()
	for k,v in pairs(bag_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if v.param.param1 ~= 0 and item_cfg.color ~= color1 and item_cfg.color ~= color2 then
			return string.format(Language.Tip.IsSureRecoverJlWuXing, "")
		end
	end
	return Language.JingLing.OneKeyRecyle
end

--获得单个灵魄
function SpiritData:GetLingPoCfg(lingpo_type, level)
	return self.lingpo_cfg[lingpo_type][level]
end

--获得灵魄类型数量
function SpiritData:GetLingPoCfgCount()
	if self.lingpo_cfg_count == nil then
		self.lingpo_cfg_count = self.lingpo_cfg[#self.lingpo_cfg][1].type + 1
	end
	return self.lingpo_cfg_count or 0
end

--获得灵魄最大等级
function SpiritData:GetLingPoMaxLevel()
	return #self.lingpo_cfg[0]
end

--灵魄数据信息
function SpiritData:GetLingPoInfo(ling_po_type)
	if not self.spirit_info.ling_po_list then return nil end
	return self.spirit_info.ling_po_list[ling_po_type]
end

--获得下级灵魄上升属性值
function SpiritData:GetLingPoUpValue(ling_po_type, level)
	local cfg = self:GetLingPoCfg(ling_po_type, level)
	local next_cfg = self:GetLingPoCfg(ling_po_type, level + 1)
	local up_list = {0,0}
	if level == 0 then
		for i=1,2 do
			up_list[i] = next_cfg["attr_value"..i]
		end
		return up_list
	end

	if level == self:GetLingPoMaxLevel() then
		return up_list
	end

	for i=1,2 do
		up_list[i] = next_cfg["attr_value"..i] - cfg["attr_value"..i]
	end
	return up_list
end

--获得战力上升值
function SpiritData:GetLingPoZhanLiUpValue(ling_po_type, level)
	if level == 0 then
		return self:GetLingPoZhanLi(ling_po_type, level + 1)
	end

	if level == self:GetLingPoMaxLevel() then
		return 0
	end

	return self:GetLingPoZhanLi(ling_po_type, level + 1) - self:GetLingPoZhanLi(ling_po_type, level)
end

--灵魄战力
function SpiritData:GetLingPoZhanLi(ling_po_type, level)
	local cfg = self:GetLingPoCfg(ling_po_type, level)
	if not cfg or not next(cfg) then return 0 end

	local attribute = CommonStruct.Attribute()
	attribute.gong_ji = cfg.attr_value1
	attribute.fang_yu = cfg.attr_value2
	attribute.max_hp = cfg.attr_value3
	return CommonDataManager.GetCapability(attribute)
end

function SpiritData:GetLingPoTotalZhanLi()
	local total_capability = 0
	local attribute = CommonStruct.Attribute()
	for k, v in pairs(self.lingpo_cfg) do
		local info = self:GetLingPoInfo(k) or {}
		local level = info.level or 0
		local cfg = v[level]
		if cfg then
			attribute.gong_ji = attribute.gong_ji + cfg.attr_value1
			attribute.fang_yu = attribute.fang_yu + cfg.attr_value2
			attribute.max_hp = attribute.max_hp + cfg.attr_value3
		end
	end
	total_capability = CommonDataManager.GetCapability(attribute)

	return total_capability
end

--灵魄称号属性
function SpiritData:GetLingPoTitleAttr(level)
	local level = level or self:GetLingPoTotalLevel()
	local title_id = TitleData.Instance:GetLingPoTitleId(level)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
	local attr_list = {0,0,0}
	local find_name = {"maxhp", "gongji", "fangyu", "name"}
	if title_cfg then
		for k,v in pairs(find_name) do
			attr_list[k] = title_cfg[v]
		end
	end
	return attr_list
end

function SpiritData:GetLingPoNowTitleAttr(level)
	local level = level or self:GetLingPoNowTotalLevel()
	local title_id = TitleData.Instance:GetLingPoNowTitleId(level)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
	local attr_list = {0,0,0}
	local find_name = {"maxhp", "gongji", "fangyu","name"}
	if title_cfg then
		for k,v in pairs(find_name) do
			attr_list[k] = title_cfg[v]
		end
	end
	return attr_list
end

--灵魄(对应显示)
function SpiritData:GetLingPoSpiritId(ling_po_type)
	return self:GetSpiritLingPoShowCfg()[ling_po_type].show_item or 0
end

--获得当前类型的cfg(0级自动取1级数据)
function SpiritData:GetLingPoCurCfg(cur_index)
  	local info = self:GetLingPoInfo(cur_index)
 	local t = {}
 	if not info then return t end

  	local next_cfg = self:GetLingPoCfg(cur_index, info.level + 1)

 	if info.level == 0 or info.level == self:GetLingPoMaxLevel() or nil == next_cfg then
	    t.cfg = self:GetLingPoCfg(cur_index, info.level == 0 and 1 or info.level)
	    t.exp =	t.cfg.exp
	    t.stuff_id = t.cfg.stuff_id
	    return t
 	end

    t.cfg = self:GetLingPoCfg(cur_index, info.level)

    t.exp = next_cfg.exp
    t.stuff_id = next_cfg.stuff_id

    return t
end

--获得灵魄进阶物品相关数据
function SpiritData:GetLingAdvanceItemInfo(cur_index)
 	local info = self:GetLingPoInfo(cur_index)
 	local t = self:GetLingPoCurCfg(cur_index)
 	local item_info = {["my_count"] = 0, ["need_num"] = 0, ["data"] = {}}
 	if not t.cfg or not next(t.cfg) then return item_info end
 	item_info.my_count = ItemData.Instance:GetItemNumInBagById(t.stuff_id)
 	item_info.need_num = 1
 	item_info.data = {}
 	item_info.data.item_id = t.stuff_id
 	item_info.data.num = item_info.my_count
 	return item_info
end

--获取灵魄当前进阶物品数颜色
function SpiritData:GetLingPoCountColor(cur_index)
	local item_info = self:GetLingAdvanceItemInfo(cur_index)
	local color = item_info.my_count >= item_info.need_num and TEXT_COLOR.WHITE or TEXT_COLOR.RED
	return color
end

--获得灵魄总等级
function SpiritData:GetLingPoTotalLevel()
	local level = 0
	for k,v in pairs(self.spirit_info.ling_po_list) do
		level = level + v.level
	end
	return level
end

function SpiritData:GetLingPoNowTotalLevel()
	local level = 0
	for k,v in pairs(self.spirit_info.ling_po_list) do
		level = level + v.level
	end
	return level
end

--获得灵魄称号等级限制text
function SpiritData:GetCurTitleInfo()
	local total_level = self:GetLingPoTotalLevel()
	local t = {}
	local max_level, max_title_id = TitleData.Instance:GetLingPoMaxLevel()
	if total_level >= max_level then
		t.desc = Language.Common.ActiveMaxLevel
		t.title_id = max_title_id
		return t
	end

	local title_id, level_limit = TitleData.Instance:GetLingPoTitleId(total_level)
	t.desc = string.format(Language.Common.ActiveCurAndNextLevel, total_level, level_limit)
	t.desc2 = string.format(Language.Common.ActiveCurAndNextLevel2, total_level)
	t.title_id = title_id
	return t
end

function SpiritData:GetCurNowTitleInfo()
	local total_level = self:GetLingPoTotalLevel()
	local t = {}
	local max_level, max_title_id = TitleData.Instance:GetLingPoMaxLevel()
	if total_level >= max_level then
		t.desc = Language.Common.ActiveMaxLevel
		t.title_id = max_title_id
		return t
	end

	local title_id, level_limit = TitleData.Instance:GetLingPoNowTitleId(total_level)
	t.desc = string.format(Language.Common.ActiveCurAndNextLevel, total_level, level_limit)
	t.desc2 = string.format(Language.Common.ActiveCurAndNextLevel2, total_level)
	t.title_id = title_id
	return t
end

--单个魂魄红点
function SpiritData:CheckLingpoCellRedPoint(cur_index)
	if not OpenFunData.Instance:CheckIsHide("spirit_lingpo") then return false end

	local t = self:GetLingPoCurCfg(cur_index)
	local item_index =  self:GetSpiritItemIndex()
	if item_index and item_index > 0 and not self:HasSameSprite(t.stuff_id) then
		--该精灵没有在出战列表中并且有空位可出战则不显示红点
		return false
	end

	local info = self:GetLingPoInfo(cur_index)
	if not info or not next(info) or info.level >= self:GetLingPoMaxLevel() then
		return false
	end

	if not t.cfg or not next(t.cfg) then
	 	return false
	end

	return ItemData.Instance:GetItemNumInBagById(t.stuff_id) > 0
end

--灵魄界面红点
function SpiritData:CheckLingpoViewRedPoint()
	if not OpenFunData.Instance:CheckIsHide("spirit_lingpo") then return false end
	local count = self:GetLingPoCfgCount() - 1
	for i=0,count do
		if self:CheckLingpoCellRedPoint(i) then return true end
	end
	return false
end

function SpiritData:SetCurAdvanceLingPoType(cur_lingpo_type)
	self.cur_lingpo_type = cur_lingpo_type
end

--检测是否播放灵魄进度条动画
function SpiritData:CheckPlayLingPoSliderAnim(ling_po_list)
	--self.cur_lingpo_type为空则不是进阶状态
	if not self.spirit_info or not next(self.spirit_info) or self.cur_lingpo_type == -1 then return false end

	if self.spirit_info.ling_po_list[self.cur_lingpo_type].level == ling_po_list[self.cur_lingpo_type].level then
		return false
	end

	return true
end

--获得灵魄进度条播放时间
function SpiritData:CheckLingpoAnimTime(exp, exp_cfg)
	local consult = math.floor(exp/exp_cfg)
	if consult <= 0.3 then
		return LINGPO_ANIM_TIME
	end

	if consult <= 0.6 then
		return LINGPO_ANIM_TIME/2
	end

	return LINGPO_ANIM_TIME/3
end

--灵魄排序后的列表
function SpiritData:GetLingPoSortList()
	local t = {}
	local cfg = self:GetSpiritLingPoShowCfg()
	for k,v in pairs(cfg) do
		t[k + 1] = {}
		t[k + 1].value = self:CheckLingpoCellRedPoint(v.type) and 1 or 0
		t[k + 1].type = v.type
	end
	function sortfun(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		else
			return a.type < b.type
		end
	end
	table.sort(t, sortfun)

	return t
end

--物品id是否属于灵魄id
function SpiritData:CheckIsLingpoItem(item_id)
	local cfg = self:GetSpiritLingPoShowCfg()
	for k,v in pairs(cfg) do
		if v.show_item == item_id then
			return true
		end
	end
	return false
end

function SpiritData:GetSpiritTotalAttr(index)
	local list = self.spirit_info.jingling_list
	local data = list[index]
	if data then
		local item_id = data.item_id
		local level = data.param.strengthen_level
		local aptitude = self:GetSpiritTalentAttrCfgById(item_id)
		local wuxing = data.param.param1
		return self:GetSpiritLevelAptitude(item_id,level,aptitude,wuxing)
	end
	return nil
end

-- 第三个打开参数
function SpiritData:GetOpenParam()
	return self.open_param
end

function SpiritData:SetOpenParam(open_param)
	self.open_param = open_param
end

function SpiritData:ClearOpenParam()
	self.open_param = nil
end

function SpiritData:GetExploreItemIdByMode(mode)
	local config = self:GetExploreModeCfg()
	for k,v in pairs(config) do
		if v.mode == mode then
			return v.reward_jingling
		end
	end
end

function SpiritData:GetExploreZhanliLimitByMode(mode)
	local config = self:GetExploreModeCfg()
	for k,v in pairs(config) do
		if v.mode == mode then
			return v.power_limit
		end
	end
end

function SpiritData:GetSpiritBagRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") then
		return 0
	end

	local is_remind = self:GetSpiritItemIndex() ~= nil and next(self:GetBagBestSpirit()) and self:GetCanEquip()
	return is_remind and 1 or 0
end

function SpiritData:GetSpiritUpgradeRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") then
		return 0
	end
	return self:CanUpgrade() and 1 or 0
end

function SpiritData:GetUpgradeWuxingRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") then
		return 0
	end
	return self:CanUpgradeWuxing() and 1 or 0
end

function SpiritData:GetLingPoRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_lingpo") then
		return false
	end

	local count = self:GetLingPoCfgCount() - 1
	for i=0,count do
		if self:CheckLingpoCellRedPoint(i) then
			return 1
		end
	end
	return 0
end

function SpiritData:GetFreeHuntRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") then
		return false
	end
	return SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime() <= 0 and 1 or 0
end

function SpiritData:GetWarehouseRemind()
	local diff_time = SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	if diff_time <= 0 then
		return 1
	end

	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spiritview") then
		return false
	end
	return nil ~= next(self.warehouse_item_list) and 1 or 0
end

function SpiritData:GetSpiritHomeBreed()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_home") then
		return 0
	end

	for i = 1, 4 do
		if self:GetHasHomeRenderRed(i) then
			return 1
		end
	end

	return 0
end

function SpiritData:GetHomeRewardRedRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_home") then
		return 0
	end

	local is_reward = self:GetSpiritPreviewRed() and self:GetIsMyHome()
	return is_reward and 1 or 0
end

function SpiritData:GetHomeRevngeRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_home") then
		return 0
	end

	return self:CheckHomeRevengeRed() and 1 or 0
end

function SpiritData:GetSpiritPlunderRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_home") then
		return 0
	end

	return self:GetPlunderRed() and 1 or 0
end

function SpiritData:GetSpiritExploreRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_home") then
		return 0
	end

	local data = self:GetMySpiritInOther()
	if data ~= nil and data.item_id <= 0 then
		return 0
	end

	local cur_stage = self:GetCurChallenge()
	if self.spirit_explore.explore_info_list ~= nil and self.spirit_explore.explore_maxhp > 0 then
		for k,v in pairs(self.spirit_explore.explore_info_list) do
			local cfg = SpiritData.Instance:GetSpiritExpConfig(self.spirit_explore.explore_mode or 0, k - 1)
			if v.reward_times < cfg.free_times and k < cur_stage then
				return 1
			end
		end
	end
	return (self:GetHasCanReset() or self:GetHasCanChanllge()) and 1 or 0
end

function SpiritData:GetSpiritMeetRemind()
	if not OpenFunData.Instance:CheckIsHide("spiritview") or not OpenFunData.Instance:CheckIsHide("spirit_meet") then
		return 0
	end

	local has_spirit_count = false
	if self.spirit_meet_info.pos_list then
		for i,v in ipairs(self.spirit_meet_info.pos_list) do
			if v.blue_count > 0 or v.purple_count > 0 then
				has_spirit_count = true
				break
			end
		end
	end

	local spirit_meet_cfg = self:GetSpiritAdvantageCfg()
	local spirit_meet_info = self:GetSpiritAdvantageInfo()
	local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
	local residue_count =  spirit_meet_cfg.other[1].times - spirit_count

	if has_spirit_count and residue_count > 0 then
		return 1
	end
	return 0
end

function SpiritData:GetSpiritLearnRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_skill") then
		return 0
	end

	return self:ShowSkillRedPoint() and 1 or 0
end

function SpiritData:GetSpiritSoulRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_soul") or nil == self.slot_soul_info.slot_activity_flag then
		return 0
	end
	local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag)
	if bit_list then
		local index = 0
		for k, v in pairs(bit_list) do
			if v == 1 then
				index = index + 1
			end
		end

		local old_index = UnityEngine.PlayerPrefs.GetInt("slotoldindex", 999)
		if old_index < index then
			return 1
		end
	end

	local storage_exp = SpiritData.Instance:GetSpiritSoulBagInfo().hunshou_exp or 0
	-- 当前槽上的魂信息
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	for k1,v1 in pairs(slot_soul_info.slot_list) do
		local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(v1.id,v1.level)
		if attr_cfg and attr_cfg.exp then
			if storage_exp >= attr_cfg.exp then
				return 1
			end
		end
	end

	if self:MingHunRed() then
		return 1
	end

	return self:ShowSoulRedPoint() and 1 or 0
end

function SpiritData:GetSpiritSoulGetRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_soul") then
		return 0
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	return vo.hunli >= 50000 and 1 or 0
end

function SpiritData:GetSpiritShangZhenRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_zhenfa") then
		return 0
	end

	return self:CanShangZhen() and 1 or 0
end

function SpiritData:GetSpiritZhenFaUpRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_zhenfa") then
		return 0
	end

	return self:CanXianZhenUp() and 1 or 0
end

function SpiritData:GetSpiritFaHunyuRemind()
	if not OpenFunData.Instance:CheckIsHide("spirit_zhenfa") then
		return 0
	end

	return self:ShowAllHunyuRedPoint() and 1 or 0
end

function SpiritData:GetSpiritAdvantageCfg()
	return self.jingling_advantage_cfg
end

function SpiritData:GetSpiritAdvantageInfo()
	return self.spirit_meet_info
end

function SpiritData:GetSceneHasSpirit(scene_id)
	if not self.spirit_meet_info.pos_list then
		return 0, 0
	end

	for i,v in ipairs(self.spirit_meet_info.pos_list) do
		if v.scene_id == scene_id then
			return v.blue_count, v.purple_count
		end
	end
	return 0, 0
end

function SpiritData:GetIsSpiritGather(id)
	for i,v in ipairs(self.jingling_advantage_cfg.gather_info) do
		if v.gather_id == id then
			return true
		end
	end
	return false
end

function SpiritData:GetSpiritType(id)
	for i,v in ipairs(self.jingling_advantage_cfg.gather_info) do
		if v.gather_id == id then
			return v.gather_type
		end
	end
	return 0
end

function SpiritData:GetSpiritHuanHuaImageCfg(image_id)
	return self:GetSpiritHuanImageConfig()[image_id]
end

function SpiritData:GetNewSpiritLevelCfgById(id,level,aptitude)
	if level == 0 then
		level = 1
	end

	local spirit_cfg = {}
	local level_cfg = self:GetSpiritLevelCfgById(id,1)
	local chengzhang_cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").chengzhang_grade
	local aptitude_cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").wuxing_grade
	level = chengzhang_cfg[level + 1] and level or level - 1
	aptitude = aptitude_cfg[aptitude + 1] and aptitude or aptitude - 1
	spirit_cfg.maxhp = level_cfg.maxhp + chengzhang_cfg[level + 1].maxhp + aptitude_cfg[aptitude + 1].maxhp
	spirit_cfg.gongji = level_cfg.gongji + chengzhang_cfg[level + 1].gongji + aptitude_cfg[aptitude + 1].gongji
	spirit_cfg.fangyu = level_cfg.fangyu + chengzhang_cfg[level + 1].fangyu + aptitude_cfg[aptitude + 1].fangyu
	return spirit_cfg
end

function SpiritData:GetAutoLieHun()
	return  self.is_auto_liehun or 0
end

function SpiritData:SetAutoLieHun(is_buy_quick)
	self.is_auto_liehun = is_buy_quick
end

-- 根据id拿到命魂槽的命魂类型
function SpiritData:MingHunCaoInfo()
	if self.cur_hunshou_cfg then
		return self.cur_hunshou_cfg
	end

	self.cur_hunshou_cfg = {}
	self.cur_hunshou_cfg.normal_list = {}			--正常命魂
	self.cur_hunshou_cfg.special_list = {}			--彩色命魂
	local slot_info = self:GetSpiritSlotSoulInfo()
	if nil == next(slot_info) then
		return self.cur_hunshou_cfg
	end

	local normal_list = {}
	local special_list = {}
	for k,v in pairs(slot_info.slot_list) do
		if v.id and v.id > 0 then
			local cfg = self:GetSpiritSoulCfg(v.id)
			local hunshou_type = cfg and cfg.hunshou_type
			if hunshou_type and k < GameEnum.LIEMING_FUHUN_SLOT_COUNT - 3 then
				normal_list[hunshou_type] = 1
			elseif hunshou_type then
				special_list[hunshou_type] = 1
			end
		end
	end

	self.cur_hunshou_cfg.normal_list = normal_list
	self.cur_hunshou_cfg.special_list = special_list

	return self.cur_hunshou_cfg
end

-- 判断当前背包有没用可以装的命魂
function SpiritData:MingHunRed()
	local count, special_count = self:GetSlotSoulEmptyCount()
	if count == 0 then
		return false
	end

	local equip_list = self:MingHunCaoInfo()
	local bag_list = self.soul_bag_info.grid_list or {}
	for k,v in pairs(bag_list) do
		local cfg = self:GetSpiritSoulCfg(v.id,v.level)
		local hunshou_type = cfg and cfg.hunshou_type
		--判断是否是彩色命魂
		local is_pink = self:GetCurSlotSouIsPink(v.id)
		local list = is_pink and equip_list.special_list or equip_list.normal_list
		if hunshou_type and list[hunshou_type] == nil then
			if is_pink and special_count ~= 0 then 			--有彩色命魂，并且有特殊命魂槽可穿戴
				return true
			elseif not is_pink then
				return true
			end
		end
	end

	return false
end

----------------------------精灵命魂-自动改命--------------------------------------
function SpiritData:SetSeclectColorSeq(seq)
	self.soul_select_color = seq
end

function SpiritData:GetSeclectColorSeq()
	return self.soul_select_color
end

function SpiritData:SetQuickChangeLifeState(state)
	self.change_state = state
end

function SpiritData:GetQuickChangeLifeState()
	return self.change_state
end

function SpiritData:SetHunLiIsAutoBuy(state)
	self.hunli_auto_buy = state
end

function SpiritData:GetHunLiIsAutoBuy()
	return self.hunli_auto_buy
end

function SpiritData:SoulGoldIsEnough()
	local has_gold = PlayerData.Instance:GetRoleVo().gold or 0
	local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
	local select_color = self.soul_select_color or -1
	if nil == lieming_cfg or select_color == -1 or nil == lieming_cfg then return true end

	local need_gold = lieming_cfg.other[1].super_chouhun_price or 0
	if has_gold < need_gold then
		return false
	end

	return true
end

-----------------------------特殊精灵------------------------------------
--特殊精灵配置表
function SpiritData:GetSpecialSpiritCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").special_jingling
end

--根据索引获取特殊精灵的配置
function SpiritData:GetSingleSpecialSpiritCfgByIndex(index)
	local single_special_cfg = {}
	local special_spirit_cfg = self:GetSpecialSpiritCfg()
	if special_spirit_cfg ~= nil and next(special_spirit_cfg) ~= nil then
		single_special_cfg = special_spirit_cfg[index]
	end
	return single_special_cfg
end

--根据索引获取特殊精灵的幻化配置
function SpiritData:GetSpecialSpiritHuanHuaCfgByIndex(special_img_id)
	self:GetSpecialSpiritImageCfg(id)
end

--精灵系统激活时间
function SpiritData:GetSpiritOpenTime()
	return self.active_jingling_timestamp
end

--特殊精灵是否可领取
function SpiritData:GetSpecialSpiritActiveCard(index)
	return (1 == self.special_jingling_flag[33 - index]) and true or false
end

--特殊精灵是否领取过
function SpiritData:GetSpecialSpiritFetchFlag(index)
	return  (1 == self.special_jingling_fetch_flag[33 - index]) and true or false
end

--特殊精灵基础战力
function SpiritData:GetSpecialSpiritCapability(id)
	local single_special_cfg = self:GetSpecialSpiritImageCfg(id)
	local base_capability = 0
	local base_attr = {}
	base_attr.maxhp = special_spirit_attr.maxhp or 0
	base_attr.fangyu = special_spirit_attr.fangyu or 0
	base_attr.gongji = special_spirit_attr.gongji or 0

	base_capability = CommonDataManager.GetCapabilityCalculation(base_attr)
	return base_capability
end

function SpiritData:GetSpecialSpiritFreeTime(index)
	local open_time = self:GetSpiritOpenTime()
	if open_time == 0 or open_time == nil then
		return 0
	end
	local single_spirit_cfg = self:GetSingleSpecialSpiritCfgByIndex(index)
	if single_spirit_cfg == nil and next(single_spirit_cfg) == nil then
		return 0
	end

	local duration_time = single_spirit_cfg.duration_time * 3600 or 0
	local now_time = TimeCtrl.Instance:GetServerTime()
	return open_time + duration_time - now_time
end

function SpiritData:GetSpecialSpiritAddAllPower()
	local spirit_info = self:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local chuzhan_spirit_item_id = spirit_info.use_jingling_id
	local percent = self:GetSingleSpecialSpiritCfgByIndex(1).add_attr_per/10000
	local spirit_base_cfg = {}
	local spirit_data = self:GetSpiritLevelConfig()
	spirit_base_cfg = ListToMap(spirit_data,"item_id","level")

	local fight_power = 0
	local spirit_base_attr = {}
	for k,v in pairs(spirit_list) do
		if chuzhan_spirit_item_id == v.item_id then
			local spirit_cfg = spirit_base_cfg[v.item_id][1]
			spirit_base_attr.maxhp = spirit_cfg.maxhp * percent or 0
			spirit_base_attr.fangyu = spirit_cfg.fangyu * percent or 0
			spirit_base_attr.gongji = spirit_cfg.gongji * percent or 0
			base_capability = CommonDataManager.GetCapabilityCalculation(spirit_base_attr)
			fight_power = fight_power + base_capability
		else
			local spirit_cfg = spirit_base_cfg[v.item_id][1]
			spirit_base_attr.maxhp = spirit_cfg.maxhp * percent * 0.5 or 0
			spirit_base_attr.fangyu = spirit_cfg.fangyu * percent * 0.5 or 0
			spirit_base_attr.gongji = spirit_cfg.gongji * percent * 0.5 or 0
			base_capability = CommonDataManager.GetCapabilityCalculation(spirit_base_attr)
			fight_power = fight_power + base_capability
		end
	end
	return fight_power
end

--红点
function SpiritData:GetSpecialSpiritRemind()
	--小目标达成
	local can_fetch_tittle = self:GetSpecialSpiritActiveCard(2)
	local has_fetch_title = self:GetSpecialSpiritFetchFlag(2)
	local have_title_in_bag = self:HaveSpecialTitleActiveCardInBag()
	if can_fetch_tittle == true and have_title_in_bag == -1 and has_fetch_title == false then
		return 1
	end
	--大目标
	local can_fetch_spirit = self:GetSpecialSpiritActiveCard(1)
	local have_flag = self:GetSpecialSpiritFetchFlag(1)
	local have_spirit_in_bag = self:HaveSpecialSpiritActiveCardInBag()
	local active_flag = self:GetSpecialSpiritActiveFlag()

	if have_spirit_in_bag ~= -1 and active_flag == false then
		return 1 
	end

	if can_fetch_spirit and active_flag == false and have_flag == false then
		return 1
	end

	return 0
end

--显示小目标
function SpiritData:GetLittleTargetActiveFlag()
	local flag = false
    local had_fetch_title = self:GetSpecialSpiritFetchFlag(2)
    local title_has_card_in_bag = self:HaveSpecialTitleActiveCardInBag()
    local active_flag = self:GetSpecialSpiritActiveFlag()

    if had_fetch_title == false and title_has_card_in_bag == -1 and active_flag == false then
    	flag = true
    end 

    return flag
end

--显示大目标
function SpiritData:GetBigTargetActiveFlag()
	local flag = false
	local title_has_card_in_bag = self:HaveSpecialTitleActiveCardInBag()
	local have_card_in_bag = self:HaveSpecialSpiritActiveCardInBag()
	local active_card_flag = self:GetSpecialSpiritActiveCard(1)
	local active_flag = self:GetSpecialSpiritActiveFlag()
	local title_fetch_flag = self:GetSpecialSpiritFetchFlag(2)
	if title_has_card_in_bag ~= -1 and title_fetch_flag == true and (have_card_in_bag ~= -1 or active_card_flag == true or active_flag == true) then
		flag = true
	end
	return flag
end

--特殊精灵是否激活
function SpiritData:GetSpecialSpiritActiveFlag()
	local active_flag = false
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local bit_list = bit:ll2b(spirit_info.special_img_active_flag_high, spirit_info.special_img_active_flag_low)

    local spirit_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(1)
    if spirit_cfg == nil and next(spirit_cfg) == nil then 
        return active_flag
    end
    --特殊精灵幻化id
    local special_index = spirit_cfg.param_0
    active_flag = bit_list[64 - special_index] == 1
    return active_flag
end

--背包是否有特精灵激活卡
function SpiritData:HaveSpecialSpiritActiveCardInBag()
	local has_card_in_bag = -1
	local spirit_cfg = self:GetSingleSpecialSpiritCfgByIndex(1)
    if spirit_cfg == nil and next(spirit_cfg) == nil then 
        return has_card_in_bag
    end

    local speical_item_id = spirit_cfg.special_item.item_id
    has_card_in_bag = ItemData.Instance:GetItemIndex(speical_item_id)
    return has_card_in_bag
end
--背包是否有精灵称号激活卡
function SpiritData:HaveSpecialTitleActiveCardInBag()
	local has_card_in_bag = -1
	local title_cfg = self:GetSingleSpecialSpiritCfgByIndex(2)
    if title_cfg == nil and next(title_cfg) == nil then 
        return has_card_in_bag
    end

    local speical_item_id = title_cfg.special_item.item_id
    has_card_in_bag = ItemData.Instance:GetItemIndex(speical_item_id)
    return has_card_in_bag
end

function SpiritData:GetSpecialSpiritHuanHuaId()
	local index = 1
    local spirit_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(index)
    if spirit_cfg == nil and next(spirit_cfg) == nil then 
        return index
    end
    local special_img_id = spirit_cfg.param_0
    return special_img_id
end