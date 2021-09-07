ShenGeData = ShenGeData or BaseClass()

SHENGE_SYSTEM_REQ_TYPE = {
		SHENGE_SYSTEM_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
		SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE = 1,					-- 分解		p1 虚拟背包索引
		SHENGE_SYSTEM_REQ_TYPE_COMPOSE = 2,						-- 合成		p1 物品1的虚拟背包索引 p2 物品2的虚拟背包索引 p3 物品1的虚拟背包索引；
		SHENGE_SYSTEM_REQ_TYPE_SET_RUAN = 3,					-- 装备符文 p1 虚拟背包索引  p2 符文页 p3 格子索引；
		SHENGE_SYSTEM_REQ_TYPE_CHANGE_RUNA_PAGE = 4,			-- 切换符文页 p1 符文页
		SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG = 5,					-- 抽奖 p1 次数；
		SHENGE_SYSTEM_REQ_TYPE_UPLEVEL = 6,						-- 升级 符文 p1 0 背包 1 符文页  p2 背包索引/ 符文页  p3 格子索引
		SHENGE_SYSTEM_REQ_TYPE_SORT_BAG = 7,					-- 整理背包
		SHENGE_SYSTEM_REQ_TYPE_UNLOAD_SHENGE = 8,				-- 拆除符文		p1 符文页 	p2格子索引
		SHENGE_STYTEM_REQ_TYPE_CLEAR_PAGE = 9,					-- 清除符文页	p1 符文页
		SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG = 10,			-- 升级掌控		p1 0:升级1次, 1:升级10次
		SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR = 11,				-- 升级掌控后重算战斗力
		SHENGE_SYSTEM_REQ_TYPE_XILIAN = 12,						-- 神格神躯洗炼 p1 神躯id  p2 洗炼点  p3是否自动购

}

SHENGE_SYSTEM_INFO_TYPE ={
		SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE = 0,				-- 背包单个符文信息											p2 count数量
		SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO = 1,				-- 背包全部信息				p1当前使用符文页				p2 count数量
		SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO = 2,				-- 符文页单个的符文信息		p1符文页 						p2 count数量			p3 符文页历史最高等级
		SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO = 3,			-- 符文页的全部符文信息		p1符文页						p2 count数量			p3 符文页历史最高等级
		SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO = 4,			-- 奖品列表					p1 已使用免费次数					p2 count数量		p3 免费抽奖剩余时间
		SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO = 5,		-- 精华信息																		p3 精华积分
		SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX = 6,			-- 符文页					p1 当前使用符文页
		SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO = 7,		-- 合成信息
		SHENGE_SYSTEM_INFO_TYPE_ACTIVE_COMBINE_INFO = 8,		-- 激活的组合索引			p1 组合索引
		SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO = 9,				-- 抽奖信息					p1 已用免费抽奖次数									p3 下次抽奖cd
}

ShenGeEnum = {
	SHENGE_SYSTEM_BAG_MAX_GRIDS = 250,								-- 背包最大格子数量不可变 数据库
	SHENGE_SYSTEM_MAX_SHENGE_PAGE = 5,								-- 最大符文页 不可变 数据库
	SHENGE_SYSTEM_CUR_SHENGE_PAGE = 3,								-- 当期符文页数
	SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID = 16,							-- 当前普通符文格子数
	SHENGE_SYSTEM_MAX_SHENGE_GRID = 20,								-- 普通符文最大格子数 不可变 数据库
	SHENGE_SYSTEM_MAX_SHENGE_LEVEL = 30,							-- 最大符文等级
	SHENGE_SYSTEM_PER_SHENGE_PAGE_MAX_ZHONGJI_SHENGE_COUNT = 4,		-- 符文页终极符文最大个数
	SHENGE_SYSTEM_RECOVER_TIME_INTERVAL = 5,
	SHENGE_SYSTEM_QUALITY_MAX_VALUE = 4								-- 神格品质最大值(掌控的格子数)

}

ShenGeZhanKongEnum =
{
	"gongji_pro",
	"fangyu_pro",
	"maxhp_pro",
	"shanbi_pro",
	"baoji_pro",
	"kangbao_pro",
	"mingzhong_pro",
	"ignore_fangyu",
}

ShenGeZhanKongEnumName =
{
	gongji_pro = "攻击",
	fangyu_pro = "防御",
	maxhp_pro = "生命",
	shanbi_pro = "闪避",
	baoji_pro = "暴击",
	kangbao_pro = "抗暴",
	mingzhong_pro = "命中",
	ignore_fangyu = "无视防御",
}

ShenGeZKCapAttr = {
	gongji_pro = "gongji",
	fangyu_pro = "fangyu",
	maxhp_pro = "maxhp",
	shanbi_pro = "shanbi",
	baoji_pro = "baoji",
	kangbao_pro = "jianren",
	mingzhong_pro = "mingzhong",
	ignore_fangyu = "ignore_fangyu",
}


function ShenGeData:__init()
	if nil ~= ShenGeData.Instance then
		return
	end
	ShenGeData.Instance = self

	self.bag_list_cont = 0
	self.zhangkong_is_rolling = false
	self.is_can_play_bless_ani = true
	self.is_can_play_zhangkong_ani = true

	self.shen_ge_system_info = {}
	self.shen_ge_item_info = {}
	self.shen_ge_bag_info = {}
	self.shen_ge_bless_reward_list = {}

	self.shen_ge_inlay_info = {}
	self.shen_ge_inlay_level = {}
	self.shen_ge_inlay_history_level = {}

	self.one_key_decompose_data_list = {}
	self.same_types_num_list = {}
	self.same_types_total_num_list = {}
	self.bless_opera_state = {}

	self.shen_ge_cfg_auto = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto")
	self.attribute_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "quality", "types")
	self.shenge_preview_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "types", "quality", "level")
	self.item_id_to_shen_ge_cfg = ListToMapList(self.shen_ge_cfg_auto.item_id_to_shenge, "quality", "types")
	self.choujiang_cfg = ListToMapList(self.shen_ge_cfg_auto.choujiangcfg, "seq")
	self.compose_shen_ge = ListToMapList(self.shen_ge_cfg_auto.decomposecfg, "kind", "quality")
	self.bless_show_shen_ge = ListToMapList(self.shen_ge_cfg_auto.show, "caowei")

	self.group_cfg = self.shen_ge_cfg_auto.combination --ListToMapList(, "seq")

	self.zhangkong_cfg = self.shen_ge_cfg_auto.zhangkong
	self.zk_grid_cfg = ListToMapList(self.shen_ge_cfg_auto.zhangkong, "grid")
	self.other_cfg = self.shen_ge_cfg_auto.other[1]
	self.zhangkong_total_info = {}
	self.zhangkong_single_info = {}
	self:SetShenliName()

	self.shenqu_cfg = self.shen_ge_cfg_auto.shenqu
	self.shenqu_xilian_cfg = ListToMapList(self.shen_ge_cfg_auto.shenqu_xilian, "shenqu_id", "point_type")

	self.sort_open_groove_cfg = self.shen_ge_cfg_auto.shengegroove
	table.sort(self.sort_open_groove_cfg, function(a, b)
		return a.shenge_open < b.shenge_open
	end)

	self.notify_data_change_callback_list = {}		--物品有更新变化时进行回调

	RemindManager.Instance:Register(RemindName.ShenGe_ShenGe, BindTool.Bind(self.CalcShenGeRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Bless, BindTool.Bind(self.CalcBlessRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Zhangkong, BindTool.Bind(self.CalcZhangkongRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Godbody, BindTool.Bind(self.CalcGodbodyRedPoint, self))
end

function ShenGeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenGe_ShenGe)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Bless)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Zhangkong)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Godbody)

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance = nil
	end
end

function ShenGeData:CalcShenGeRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	if self:CalcShenRedPointByPageNum(0) then
		return 1
	end

	return 0
end

function ShenGeData:CalcShenRedPointByPageNum(page_num)
	page_num = page_num or self:GetCurPageIndex()
	local slot_state_list = self:GetSlotStateList(page_num)
	for i = 0, 3 do
		for i2 = i * 4, i * 4 + 3 do
			local inlay_data = self:GetInlayData(page_num, i2)
			if slot_state_list[i2] and (nil == inlay_data or inlay_data.item_id <= 0) and #self:GetSameQuYuDataList(i + 1) > 0 then
				return true
			end
		end
	end

	for k, v in pairs(self.shen_ge_inlay_info[page_num] or {}) do
		if self:GetShenGeInlayCellCanUpLevel(page_num, k) then
			return true
		end
	end
	return false
end

function ShenGeData:GetShenGeInlayCellCanUpLevel(page, index)
	local inlay_info = self:GetInlayData(page, index)
	if nil == inlay_info then
		return false
	end

	local shen_ge_data = inlay_info.shen_ge_data
	local next_attr_cfg = self:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level + 1)
	if nil == next_attr_cfg or not next(next_attr_cfg) then
		return false
	end
	local cur_all_fragments = self:GetFragments(true)
	return cur_all_fragments >= next_attr_cfg.next_level_need_marrow_score
end

--祈福
function ShenGeData:CalcBlessRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item
	if cfg ~= nil then
		local item_num = ItemData.Instance:GetItemNumInBagById(cfg.item_id)
		if item_num >= 1 then
			return 1
		end
	end
	return 0
end

function ShenGeData:CalcZhangkongRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	if self:IsZhangkongAllMaxLevel() then
		return 0
	end

	local item_amount_val = ItemData.Instance:GetItemNumInBagById(self:GetZhangkongItemID())
	if item_amount_val == 0 then
		return 0
	elseif item_amount_val > 0 then
		return 1
	end
	return 0
end

--战阵
function ShenGeData:CalcGodbodyRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shen_ge_godbody") then
		return 0
	end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local need_level = ShenGeData.Instance:GetShenquCfgById(0).role_level or 0
	if level < need_level then
		return 0
	end

	for i = 0, 9 do
		local cfg = ShenGeData.Instance:GetShenquCfgById(i)
		if cfg ~= nil then
			local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			local need_num = cfg["stuff_num_2"]
			if item_num >= need_num then
				return 1
			end
		end
	end
	return 0
end
-- 根据信息类型存数据
function ShenGeData:SetShenGeSystemBagInfo(protocol)
	local vo = {}
	vo.info_type = protocol.info_type
	vo.param1 = protocol.param1
	vo.count = protocol.count
	vo.param3 = protocol.param3
	vo.bag_list = protocol.bag_list

	self.shen_ge_system_info[vo.info_type] = vo

	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		self:ChangeShenGeBagInfo(vo.bag_list)
	end

	-- 背包单个、多个数据改变
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE then
		self:ChangeShenGeBagInfo(vo.bag_list)
	end

	-- 全部符文槽信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO then
		self:SetInlayLevel(vo.param1, vo.bag_list)
		self:SetInlayPageHistoryLevel(vo.param1, vo.param3)
		self:SetInlayInfo(vo.param1, vo.bag_list)
	end

	-- 单个、多个符文槽信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then
		self:SetInlayInfo(vo.param1, vo.bag_list)
		self:SetInlayPageHistoryLevel(vo.param1, vo.param3)
	end

	-- 抽奖奖励信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then
		self:ChangeBlessRewardToItemData(protocol.bag_list)
	end

	-- 监听回调
	self:NoticeOneItemChange(protocol.info_type, protocol.param1, protocol.count, protocol.param3, protocol.bag_list)
end

function ShenGeData:GetShenGeSystemBagInfo(info_type)
	return self.shen_ge_system_info[info_type]
end

function ShenGeData:GetInlayData(page, index)
	return self.shen_ge_inlay_info[page] and self.shen_ge_inlay_info[page][index]
end

function ShenGeData:GetBagListCount()
	return self.bag_list_cont
end

function ShenGeData:GetShenGeBlessRewardDataList()
	return self.shen_ge_bless_reward_list
end

function ShenGeData:GetSameQualityInlayDataNum(types, quality)
	return self.same_types_num_list[types] and self.same_types_num_list[types][quality] or 0
end

function ShenGeData:SetBlessAniState(value)
	self.is_can_play_bless_ani = not value
end

function ShenGeData:GetBlessAniState()
	return self.is_can_play_bless_ani
end

function ShenGeData:SetZhangkongAniState(value)
	self.is_can_play_zhangkong_ani = not value
end

function ShenGeData:GetZhangkongAniState()
	return self.is_can_play_zhangkong_ani
end


function ShenGeData:GetFragments(is_no_conver)
	local info = self.shen_ge_system_info[SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO]
	local count = info and info.param3 or 0
	if is_no_conver then
		return count
	end
	return CommonDataManager.ConverMoney(count)
end

function ShenGeData:NoticeOneItemChange(info_type, param1, param2, param3, bag_list)
	for k,v in pairs(self.notify_data_change_callback_list) do  --协议改变
		v(info_type, param1, param2, param3, bag_list)
	end
end

-- 神格背包数据改变
function ShenGeData:ChangeShenGeBagInfo(data_list)
	for _, v in pairs(data_list) do
		if v.quality < 0 and v.type < 0 and v.level <= 0 then
			if nil ~= self.shen_ge_item_info[v.index] then
				self.bag_list_cont = self.bag_list_cont - 1
			end
			self.shen_ge_item_info[v.index] = nil
			self.shen_ge_bag_info[v.index] = nil
		else
			if nil == self.shen_ge_item_info[v.index] then
				self.bag_list_cont = self.bag_list_cont + 1
			end
			local temp_data = {}
			temp_data.item_id = self:GetShenGeItemId(v.type, v.quality)
			temp_data.num = 1
			temp_data.shen_ge_data = v
			local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
			temp_data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.quyu or 0
			self.shen_ge_item_info[v.index] = temp_data
			self.shen_ge_bag_info[v.index] = v
		end
	end
end

function ShenGeData:ChangeBlessRewardToItemData(data_list)
	self.shen_ge_bless_reward_list = {}

	for _, v in pairs(data_list) do
		local temp_data = {}
		temp_data.item_id = self:GetShenGeItemId(v.type, v.quality)
		temp_data.num = 1
		temp_data.shen_ge_data = v
		local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
		temp_data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.quyu or 0
		table.insert(self.shen_ge_bless_reward_list, temp_data)
	end
end

function ShenGeData:GetShenGeItemData(index)
	return self.shen_ge_item_info[index]
end

function ShenGeData:ClearOneKeyDecomposeData()
	self.one_key_decompose_data_list = {}
end

function ShenGeData:GetShenGeSameQualityItemData(quality)
	if nil == next(self.one_key_decompose_data_list) then
		local list = {}
		for k, v in pairs(self.shen_ge_item_info) do
			list[v.shen_ge_data.quality] = list[v.shen_ge_data.quality] or {}
			table.insert(list[v.shen_ge_data.quality], v)
		end

		for k, v in pairs(list) do
			table.sort(v, function(a, b)
				if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
					return a.shen_ge_data.quality > b.shen_ge_data.quality
				end

				if a.shen_ge_data.level ~= b.shen_ge_data.level then
					return a.shen_ge_data.level > b.shen_ge_data.level
				end

				return a.shen_ge_data.type < b.shen_ge_data.type
			end)
		end

		for k, v in pairs(list) do
			self.one_key_decompose_data_list[k] = self.one_key_decompose_data_list[k] or {}
			for i = 1, #v do
				self.one_key_decompose_data_list[k][i] = v[i]
				self.one_key_decompose_data_list[k][i].is_select = false
			end
		end
	end
	return self.one_key_decompose_data_list[quality] or {}
end

function ShenGeData:SetInlayInfo(page, data_list)
	self.shen_ge_inlay_info[page] = self.shen_ge_inlay_info[page] or {}

	local data = nil
	for k, v in pairs(data_list) do
		self.same_types_num_list[v.type] = self.same_types_num_list[v.type] or {}
		self.same_types_num_list[v.type][v.quality] = self.same_types_num_list[v.type][v.quality] or 0

		data = self:GetInlayData(page, v.index)
		if nil ~= data then
			self.same_types_num_list[data.shen_ge_data.type][data.shen_ge_data.quality] = self.same_types_num_list[data.shen_ge_data.type][data.shen_ge_data.quality] - 1
		end

		if v.quality < 0 and v.type < 0 and v.level <= 0 then
			data_list[k] = nil
			if nil ~= data then
				self.shen_ge_inlay_level[page] = self.shen_ge_inlay_level[page] - data.shen_ge_data.level
			end
			self.shen_ge_inlay_info[page][v.index] = nil
		else
			local data = {}
			data.item_id = self:GetShenGeItemId(v.type, v.quality)
			data.num = 1
			data.shen_ge_data = v
			local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
			data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.quyu or 0
			self.shen_ge_inlay_info[page][v.index] = data

			self.same_types_num_list[v.type][v.quality] = self.same_types_num_list[v.type][v.quality] + 1
		end
	end
end

function ShenGeData:GetCurPageIndex()
	local info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX)
	if nil == info then
		info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO)
		return info.param1
	end
	return info.param1
end

-- 设置当前符文页的符文总等级
function ShenGeData:SetInlayLevel(page, data_list)
	self.shen_ge_inlay_level[page] = 0
	for k, v in pairs(data_list) do
		self.shen_ge_inlay_level[page] = self.shen_ge_inlay_level[page] + v.level
	end
end

function ShenGeData:GetInlayLevel(page)
	return self.shen_ge_inlay_level[page]
end

function ShenGeData:GetInlayCurTotalLevel()
	local sum = 0
	for _, v in pairs(self.shen_ge_inlay_level) do
		sum = sum + v
	end
	return sum
end

function ShenGeData:SetInlayPageHistoryLevel(page, value)
	self.shen_ge_inlay_history_level[page] = value or 0
end

function ShenGeData:GetInlayPageHistoryLevel(page)
	return self.shen_ge_inlay_history_level[page] or 0
end

-- 获取镶嵌历史最高总等级
function ShenGeData:GetInlayHistoryTotalLevel()
	local sum = 0
	for _, v in pairs(self.shen_ge_inlay_history_level) do
		sum = sum + v
	end
	return sum
end

-- 获取神格物品ID
function ShenGeData:GetShenGeItemId(types, quality)
	if nil == self.item_id_to_shen_ge_cfg[quality] or nil == self.item_id_to_shen_ge_cfg[quality][types] then
		return 0
	end

	return self.item_id_to_shen_ge_cfg[quality][types][1].item_id
end

function ShenGeData:GetShenGeQualityByItemId(item_id)
	for k, v in pairs(self.shen_ge_cfg_auto.item_id_to_shenge) do
	 	if v.item_id == item_id then
	 		return v.quality
	 	end
	 end
	 return -1
end

function ShenGeData:GetChoujiangCfg(seq)
	return self.choujiang_cfg[seq]
end

-- 神格祈福转盘格子数据
function ShenGeData:GetShenGeBlessShowData(caowei)
	local show_data = self.bless_show_shen_ge[caowei][1]
	local data = {}
	if show_data and next(show_data) then
		data.item_id = show_data.icon_pic
	 	data.zhanli = show_data.zhanli
	 	data.detail = show_data.detail
	 	data.name = show_data.name
	 	data.index = show_data.caowei
	 	data.color = show_data.name_color
	 	data.roll_type = show_data.roll_type
	end
	return data
end

function ShenGeData:GetBlessIndex(t_type, quality)
	local index = 1
	if t_type == nil or quality == nil then
		return index
	end

	for k,v in pairs(self.shen_ge_cfg_auto.show) do
		if v ~= nil then
			local type_tab = Split(v.roll_type, ":")
			if #type_tab == 2 and tonumber(type_tab[2]) == t_type then
				local quality_tab = Split(type_tab[1], ",")
				for k1, v1 in pairs(quality_tab) do
					if tonumber(v1) == quality then
						index = v.roll_index - 1
						break
					end
				end
			end
		end
	end
	
	return index
end

function ShenGeData:GetShenGeAttributeCfg(types, quality, level)
	if nil ~= level then
		if nil == self.attribute_cfg[quality] or nil == self.attribute_cfg[quality][types] then
			return nil
		end
		return self.attribute_cfg[quality][types][level]
	end

	if nil == self.attribute_cfg[quality] then
		return nil
	end
	return self.attribute_cfg[quality][types]
end

function ShenGeData:GetShenGepreviewCfg(types, quality, level)
	types = types or 0
	quality = quality or 0
	level = level or 1
	return self.shenge_preview_cfg[types]
	and self.shenge_preview_cfg[types][quality]
	and self.shenge_preview_cfg[types][quality][level]
	and self.shenge_preview_cfg[types][quality][level][1] or nil
end

function ShenGeData:GetShenGepreviewCfgForTypes()
	local PreviewtypesCfg = {}
	local cfg_type = -1
	for k,v in pairs(self.attribute_cfg[1]) do
		if cfg_type ~= v[1].types then
			cfg_type = v[1].types
			table.insert(PreviewtypesCfg, cfg_type)
		end
	end
	return PreviewtypesCfg
end

function ShenGeData:GetShenGeGroupCfg(seq)
	return self.group_cfg[seq]
end

function ShenGeData:GetOtherCfg()
	return self.shen_ge_cfg_auto.other[1]
end

-- 获取当前符文页属性
function ShenGeData:GetInlayAttrListAndOtherFightPower(page_index)
	if nil == self.shen_ge_inlay_info[page_index] then
		return {}, 0
	end

	local list = {}
	local other_fight_power = 0
	local attr_cfg , attr_value, attr_type, attr_key = nil, 0, -1, nil
	local kind_cfg = {}

	for _, v in pairs(self.shen_ge_inlay_info[page_index]) do
		attr_cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
		if nil ~= attr_cfg then
			for i = 0, 2 do
				attr_value = attr_cfg["add_attributes_"..i]
				attr_type = attr_cfg["attr_type_"..i]
				attr_key = Language.ShenGe.AttrType[attr_type]
				if nil ~= attr_type and nil ~= attr_value and attr_value > 0 then
					list[attr_key] = list[attr_key] or 0
					list[attr_key] = list[attr_key] + attr_value

					if attr_key ~= nil then
						if kind_cfg[attr_cfg.quyu] == nil then
							kind_cfg[attr_cfg.quyu] = {}
						end
						kind_cfg[attr_cfg.quyu][attr_key] = kind_cfg[attr_cfg.quyu][attr_key] or 0
						kind_cfg[attr_cfg.quyu][attr_key] = kind_cfg[attr_cfg.quyu][attr_key] + attr_value
					end
				end
			end
			other_fight_power = other_fight_power + attr_cfg.capbility
		end
	end

	return list, other_fight_power, kind_cfg
end

-- 神格槽开启预告
function ShenGeData:GetNextGrooveIndexAndNextGroove()
	local cur_page = self:GetCurPageIndex()
	local index = -1
	local next_open_level = -1
	for k, v in pairs(self.sort_open_groove_cfg) do
		if v.shenge_open > self:GetInlayPageHistoryLevel(cur_page) then
			index = v.shenge_groove
			next_open_level = v.shenge_open
			break
		end
	end
	return index, next_open_level
end

-- 神格槽是否开启
function ShenGeData:GetSlotStateList(page)
	local list = {}
	local cur_page = page or self:GetCurPageIndex()
	for k, v in pairs(self.sort_open_groove_cfg) do
		list[v.shenge_groove] = v.shenge_open <= self:GetInlayPageHistoryLevel(cur_page)
	end

	return list
end

function ShenGeData:GetShenGeOpenPageNum()
	local page_num = 0
	for _, v in pairs(self.shen_ge_cfg_auto.shengepage) do
		if v.shengepage_open <= self:GetInlayHistoryTotalLevel() then
			page_num = page_num + 1
		end
	end
	return page_num
end

-- 神格页开启等级
function ShenGeData:GetShenGePageOpenLevel(index)
	for _, v in pairs(self.shen_ge_cfg_auto.shengepage) do
		if v.shengepage == index then
			return v.shengepage_open
		end
	end
	return 0
end

function ShenGeData:GetBagItemKindAndQualityList()
	local list = {}
	local kind_num_list = {}
	local quality_num_list = {}
	local num_limit = 4
	for k, v in pairs(self.shen_ge_item_info) do
		list[v.shen_ge_kind] = list[v.shen_ge_kind] or {}

		kind_num_list[v.shen_ge_kind] = kind_num_list[v.shen_ge_kind] or 0
		kind_num_list[v.shen_ge_kind] = kind_num_list[v.shen_ge_kind] + 1

		quality_num_list[v.shen_ge_kind] = quality_num_list[v.shen_ge_kind] or {}
		quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] = quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] or 0
		quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] = quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] + 1

		table.insert(list[v.shen_ge_kind], v)
	end

	local temp_list = {}
	for k, v in pairs(list) do
		for _, v2 in pairs(v) do
			if kind_num_list[k] >= num_limit and quality_num_list[k][v2.shen_ge_data.quality] >= num_limit and v2.shen_ge_data.quality < 5 then
				table.insert(temp_list, v2)
			end
		end
	end

	return temp_list
end

function ShenGeData:GetCanComposeDataList(data_list, is_show_enough)
	if self.bag_list_cont <= 0 then
		return {}
	end

	local list = {}
	if data_list.count <= 0 then
		if is_show_enough then
			quality_list = self:GetBagItemKindAndQualityList()
			for _, v in pairs(quality_list) do
				if v.shen_ge_data.quality >= 2 then
					table.insert(list, v)
				end
			end
			return self:SortComposeList(list)
		end

		for _, v in pairs(self.shen_ge_item_info) do
			if v.shen_ge_data.quality >= 2 then
				table.insert(list, v)
			end
		end
		return self:SortComposeList(list)
	end

	local temp_data_list = {}
	for k, v in pairs(data_list) do
		if type(v) == "table" then
			table.insert(temp_data_list, v)
		end
	end

	local index_1 = math.max(#temp_data_list - 0, 1)
	local index_2 = math.max(#temp_data_list - 1, 1)
	local index_3 = math.max(#temp_data_list - 2, 1)
	

	for k, v in pairs(self.shen_ge_item_info) do
		if temp_data_list[index_1].shen_ge_kind == v.shen_ge_kind and v.shen_ge_data.quality == temp_data_list[index_1].shen_ge_data.quality
			and (temp_data_list[index_1].shen_ge_data.index ~= k and temp_data_list[index_2].shen_ge_data.index ~= k and
				temp_data_list[index_3].shen_ge_data.index ~= k) and v.shen_ge_data.quality >= 2 then

				table.insert(list, v)
		end
	end

	return self:SortComposeList(list)
end

function ShenGeData:SortComposeList(list)
	table.sort(list, function(a, b)
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality < b.shen_ge_data.quality
			end

			if a.shen_ge_data.quyu ~= b.shen_ge_data.quyu then
				return a.shen_ge_data.quyu > b.shen_ge_data.quyu
			end

			return a.shen_ge_data.level < b.shen_ge_data.level
		end)
	return list
end

-- 从神格背包获取相同类型、品质的神格
function ShenGeData:GetBagSameQualityAndTypesItemDataList(types, quality, index)
	if self.bag_list_cont <= 0 then
		return {}
	end

	local list = {}
	for _, v in pairs(self.shen_ge_item_info) do
		if v.shen_ge_data.quality == quality and v.shen_ge_data.index ~= index and v.shen_ge_data.type == types then
			table.insert(list, v)
		end
	end
	if #list > 1 then
		table.sort(list, function(a, b)
			if a.shen_ge_data.level ~= b.shen_ge_data.level then
				return a.shen_ge_data.level < b.shen_ge_data.level
			end
			return a.shen_ge_data.index < b.shen_ge_data.index
		end)
	end
	return list
end

-- 获取相同区域的神格
function ShenGeData:GetSameQuYuDataList(qu_yu)
	local list = {}
	local cfg = {}
	for k, v in pairs(self.shen_ge_item_info) do
		cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
		if nil ~= cfg then
			list[cfg.quyu] = list[cfg.quyu] or {}
			table.insert(list[cfg.quyu], v)
		end
	end

	for k, v in pairs(list) do
		table.sort(v, function(a, b)
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality > b.shen_ge_data.quality
			end

			if a.shen_ge_data.level ~= b.shen_ge_data.level then
				return a.shen_ge_data.level > b.shen_ge_data.level
			end

			return a.shen_ge_data.type < b.shen_ge_data.type
		end)
	end

	return list[qu_yu] or {}
end

function ShenGeData:IsShenGeToggle(show_index)
	if show_index == TabIndex.shen_ge_inlay
		or show_index == TabIndex.shen_ge_bless
		or show_index == TabIndex.shen_ge_group
		or show_index == TabIndex.shen_ge_compose then
		return true
	end
	return false
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function ShenGeData:NotifyDataChangeCallBack(callback)
	if callback == nil then
		return
	end

	self.notify_data_change_callback_list[callback] = callback
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function ShenGeData:UnNotifyDataChangeCallBack(callback)
	if nil == self.notify_data_change_callback_list[callback] then
		return
	end

	self.notify_data_change_callback_list[callback] = nil
end

--协议获取掌控总信息
function ShenGeData:SetZhangkongTotalInfo(protocol)
	self.zhangkong_total_info = protocol
end

--协议获取掌控单个修改信息
function ShenGeData:SetZhangkongSingleInfo(protocol)
	self.zhangkong_single_info = protocol
	if self.zhangkong_total_info ~= nil then
		local last_data = {}
		last_data = self:GetZhangkongInfoByGrid(protocol.grid)
		self:SetLastZKExp(last_data)

		self.zhangkong_total_info.zhangkong_list[protocol.grid].level = protocol.level
		self.zhangkong_total_info.zhangkong_list[protocol.grid].exp = protocol.exp
	end
end

function ShenGeData:SetLastZKExp(data)
	self.last_zk_exp = data
end

function ShenGeData:GetLastZKExp()
	return self.last_zk_exp
end

function ShenGeData:GetZhangKongAllInfo()
	return self.zhangkong_total_info or {}
end

--根据grid获取相应格子的信息
function ShenGeData:GetZhangkongInfoByGrid(grid, show_next)
	local data_list = {}
	if self.zhangkong_total_info == nil then
		return data_list
	end
	
	if self.zhangkong_total_info.zhangkong_list == nil or self.zhangkong_total_info.zhangkong_list[grid] == nil then
		return data_list
	end

	local level = self.zhangkong_total_info.zhangkong_list[grid].level

	if level ~= nil then
		data_list.grid = grid
		data_list.level = level
		data_list.show_next = false

		if show_next and data_list.level == 0 then
			data_list.level = 1
			data_list.show_next = true
		end

		local index = data_list.level + data_list.grid * 50 + 1
		local detail_data = self:GetDetailData(data_list.grid, data_list.level)
		data_list.exp = self.zhangkong_total_info.zhangkong_list[grid].exp
		data_list.cfg_exp = detail_data.cfg_exp
		data_list.grade = detail_data.grade
		data_list.star = detail_data.star
		data_list.shenge_pro = 	detail_data.shenge_pro
		data_list.pro = detail_data.pro
		data_list.name = detail_data.name
		data_list.attr_list = detail_data.attr_list
		data_list.des = detail_data.des
	end
	return data_list
end

function ShenGeData:SetShenliName()
	self.shenli_name = {}
	for i = 1, 4 do
		for k,v in pairs(self.zhangkong_cfg) do
			if v.level ~= 0 then
				if v.grid == i - 1 then
					self.shenli_name[i] = v.shenli_name
					break
				end
			end
		end
	end
end

function ShenGeData:GetShenliName(grid)
	self:SetShenliName()
	if self.shenli_name ~= nil then
		return self.shenli_name[grid + 1]
	end
end

function ShenGeData:GetZhankongSingleChangeInfo()
	if self.zhangkong_single_info == nil then
		return
	end
	return self.zhangkong_single_info
end

function ShenGeData:GetDetailData(grid, level)
	local data_list = {}
	for k,v in pairs(self.zhangkong_cfg) do
		if v.level == level and v.grid == grid then
			if level == 100 then
				data_list.cfg_exp = v.exp
			else
				data_list.cfg_exp = nil ~= self.zhangkong_cfg[k] and self.zhangkong_cfg[k].exp or 0
			end
			data_list.grade = v.grade or 0
			data_list.star = v.star or 1
			data_list.shenge_pro = v.shenge_pro
			data_list.name = v.shenli_name
			data_list.attr_list = {}
			data_list.des = v.des

			local temp_attr_list = {}
			if level == 0 then
				temp_attr_list = self.zhangkong_cfg[k]
			else
				temp_attr_list = v
			end
			for m,n in pairs(ShenGeZhanKongEnum) do
				if temp_attr_list[n] ~= 0 then
					local count = #data_list.attr_list
					data_list.attr_list[count + 1] = {}
					data_list.attr_list[count + 1].val = temp_attr_list[n]
					data_list.attr_list[count + 1].name = n
				end
			end

			break
		end
	end
	return data_list
end

function ShenGeData:GetZhangkongCost()
	return self.other_cfg.uplevel_zhangkong_gold
end

function ShenGeData:GetZhangkongItemID()
	return self.other_cfg.uplevel_zhangkong_itemid
end

function ShenGeData:IsExpBaoji(exp)
	if exp == self.shen_ge_cfg_auto.zhangkong_rand_exp_weight[1].exp then
		return false
	else
		return true
	end
end

function ShenGeData:IsZhangkongAllMaxLevel()
	local is_all_max = true
	for i = 0 , 3 do
		local level = self:GetZhangkongInfoByGrid(i).level
		if level ~= 100 then
			is_all_max = false
		end
	end
	return(is_all_max)
end

function ShenGeData:GetZhangkongIsRolling()
	return self.zhangkong_is_rolling
end

function ShenGeData:SetZhangkongIsRolling(is_rolling)
	self.zhangkong_is_rolling = is_rolling
end

function ShenGeData:GetCompseSucceedRate(kind, quality)
	-- local composite_prob = self.compose_shen_ge[kind][quality][1].composite_prob
	return 100
end

function ShenGeData:GetGridCfgByGrid(grid)
	if grid == nil then
		return nil
	end

	return self.zk_grid_cfg[grid]
end

function ShenGeData:GetShenGeZKAttrCfg()
	local cfg = {}
	local cap = 0
	local pro_list = {}
	local attr_cfg = CommonStruct.AttributeNoUnderline()
	local cur_page = self:GetCurPageIndex()
	local attr_list, other_fight_power, kind_cfg = self:GetInlayAttrListAndOtherFightPower(cur_page)
	for i = 1, 4 do
		local data = self:GetZhangkongInfoByGrid(i - 1)
		if data ~= nil then
			for j = 1, 2 do
				if data.attr_list ~= nil and data.attr_list[j] ~= nil then
					local name = ShenGeZhanKongEnumName[data.attr_list[j].name] or ""
					--table.insert(cfg, string.format(Language.ShenGe.ZKTipAttrStr, name, data.attr_list[j].val))
					if data.attr_list[j].val > 0 then
						table.insert(cfg, {str = name .. ":", val = string.format(Language.ShenGe.ZKTipAttrStr, data.attr_list[j].val)})
					end

					local key = ShenGeZKCapAttr[data.attr_list[j].name]
					if key ~= nil then
						attr_cfg[key] = attr_cfg[key] + data.attr_list[j].val
					end
				end
			end	

			--table.insert(cfg, string.format(Language.ShenGe.ZKTipProDesc, Language.ShenGe.ZKFlagDesc[i], data.shenge_pro * 0.01))
			if data.shenge_pro > 0 then
				table.insert(pro_list, {str = Language.ShenGe.ZKFlagDesc[i] .. ":", val = string.format(Language.ShenGe.ZKTipProDesc, data.shenge_pro * 0.01)})
			end

			local pro_val = data.shenge_pro * 0.0001
			if attr_list ~= nil and kind_cfg ~= nil and kind_cfg[i] ~= nil then
				for k, v in pairs(kind_cfg[i]) do
				   if v ~= nil then
				   		local add_val = math.floor(pro_val * attr_list[k])
				   		attr_cfg[k] = attr_cfg[k] + add_val
				   end
				end
			end
		end
	end

	for k,v in pairs(pro_list) do
		if v ~= nil then
			table.insert(cfg, v)
		end
	end

	cap = CommonDataManager.GetCapability(attr_cfg)

	return cfg, cap
end



----------------神躯---------
function ShenGeData:SetShenquAllInfo(protocol)
	self.shenqu_list = protocol.shenqu_list
	self.shenqu_history_max_cap = protocol.shenqu_history_max_cap
end

function ShenGeData:SetShenquSingleInfo(protocol)
	if self.shenqu_list ~= nil and next(self.shenqu_list) then
		self.shenqu_list[protocol.shenqu_id] = protocol.shenqu_attr
	end
	
	if self.shenqu_history_max_cap ~= nil and next(self.shenqu_history_max_cap) then
		self.shenqu_history_max_cap[protocol.shenqu_id] = protocol.shenqu_history_max_cap
	end
end

function ShenGeData:GetShenQuHistoryMaxCap(shenqu_id)
	if self.shenqu_history_max_cap == nil then
		return
	end

	return self.shenqu_history_max_cap[shenqu_id]
end

function ShenGeData:GetOnePointInfo(shenqu_id, point_type)
	if self.shenqu_list ~= nil and next(self.shenqu_list) then
		return self.shenqu_list[shenqu_id][point_type]
	end
	return nil
end

function ShenGeData:GetShenquPointInfoByShenQuId(shenqu_id)
	if self.shenqu_list ~= nil and next(self.shenqu_list) then
		return self.shenqu_list[shenqu_id]
	end
	return {}
end

function ShenGeData:GetAttrPointInfoNumByShenQuId(shenqu_id)
	local data = self:GetShenquPointInfoByShenQuId(shenqu_id)
	local num = 0
	
	for i,v in ipairs(data) do
		local cfg = ShenGeData.Instance:GetShenquCfgById(shenqu_id)
		local ready_count = 0
		if nil ~= v or next(v) then
			ready_count = (v[1].attr_point >= 0 and v[1].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
			ready_count = (v[2].attr_point >= 0 and v[2].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
			ready_count = (v[3].attr_point >= 0 and v[3].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
		end
		if ready_count >= cfg.perfect_num then num = num + 1 end
	end
	return num
end

function ShenGeData:GetShenquCfgById(shenqu_id)
	if self.shenqu_cfg == nil then
		return
	end

	for k,v in pairs(self.shenqu_cfg) do
		if shenqu_id == v.shenqu_id then
			return v
		end
	end
	return nil
end

function ShenGeData:GetShenquXiLianCfg(shenqu_id, point_type)
	if self.shenqu_xilian_cfg == nil or nil == self.shenqu_xilian_cfg[shenqu_id] then
		return nil
	end
	return self.shenqu_xilian_cfg[shenqu_id][point_type]
end

function ShenGeData:GetShenquCount()
	local count = 0
	if self.shenqu_cfg == nil then
		return
	end

	for k,v in pairs(self.shenqu_cfg) do
		count = count + 1
	end
	return count
end

function ShenGeData:GetShenquListData()
	if self.shenqu_cfg == nil then
		return
	end
	
	local shenqu_cfg = TableCopy(self.shenqu_cfg)
	for k,v in pairs(shenqu_cfg) do
		local one_attr_list = self:GetTotalAttrList(v.shenqu_id)
		v.capbility = CommonDataManager.GetCapability(one_attr_list)
	end

	return shenqu_cfg
end

function ShenGeData:GetActiveShenQuNum()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local shenqu_cfg = self.shenqu_cfg
	local active_num = 0
	if shenqu_cfg and next(shenqu_cfg) ~= nil then
		for k, v in pairs(shenqu_cfg) do
			if v.role_level <= level then
				active_num = active_num + 1
			end
		end
	end
	return active_num
end

function ShenGeData:GetTotalAttrList(shenqu_id)
	local total_attr_list = {}
	local base_list = CommonDataManager.GetAttrKeyList()
	if self.shenqu_list == nil or not next(self.shenqu_list) then return {} end
	for k,v in pairs(self.shenqu_list[shenqu_id]) do
		for k1,v1 in pairs(v) do
			if v1.attr_point >= 0 then
				if total_attr_list[base_list[v1.attr_point + 1]] == nil then
					total_attr_list[base_list[v1.attr_point + 1]] = v1.attr_value
				else
					total_attr_list[base_list[v1.attr_point + 1]] = total_attr_list[base_list[v1.attr_point + 1]] + v1.attr_value
				end
			end
		end
	end
	return total_attr_list
end

function ShenGeData:GetOnePointInfoAttr(shenqu_id, point_type)
	local point_info = self:GetOnePointInfo(shenqu_id, point_type)
	if nil == point_info then return {} end
	local total_attr_list = {}
	local base_list = CommonDataManager.GetAttrKeyList()
	for k,v in pairs(point_info) do
		if v.attr_point >= 0 then
			if total_attr_list[base_list[v.attr_point + 1]] == nil then
				total_attr_list[base_list[v.attr_point + 1]] = v.attr_value
			else
				total_attr_list[base_list[v.attr_point + 1]] = total_attr_list[base_list[v.attr_point + 1]] + v.attr_value
			end
		end
	end
	return total_attr_list
end

function ShenGeData:ISShowCommonAuto(list_index,point_index,toggle_value_list)
	local cur_info = self:GetOnePointInfo(list_index,point_index)
	local data = {}

	for i = 1, 3 do
		if cur_info[i].attr_point >= 0 then
			if cur_info[i].attr_point + 1 == point_index then
				data[i] = true
			else 
				data[i] = false
			end
		end
	end
	for i=1,3 do
		if toggle_value_list[i] == 1 and data[i] == true then
			return true
		end
	end
	return false
end
function ShenGeData:SetCurBlessQuickBuyState(is_quick_buy)
	self.bless_opera_state.is_quick_buy = is_quick_buy
end

function ShenGeData:SetCurBlessAutoBuyState(is_auto_buy)
	self.bless_opera_state.is_auto_buy = is_auto_buy
end

function ShenGeData:GetCurBlessAutoList()
	return self.bless_opera_state
end