ShenqiData = ShenqiData or BaseClass()

ShenqiData.ShenqiInfo = {
	ShenBingNum = 5,	--神兵数量
	BaoJiaNum = 5,		--宝甲数量
	MaterialNum = 4,	--镶嵌材料数量
}

local upgrage_add_exp = 35		--升一级所加经验(最少)

function ShenqiData:__init()
	if ShenqiData.Instance then
		return print_error("[ShenqiData] attempt to create singleton twice!")
	end
	ShenqiData.Instance = self

	self.shenqi_cfg = nil						-- 神器配置
	self.shenqi_other_cfg = nil					-- 神兵升级材料配置
	self.shenbing_inlay_cfg = nil				-- 获取All神兵镶嵌配置
	self.baojia_inlay_cfg = nil					-- 获取All神兵镶嵌配置	
	self.shenbing_image_cfg = nil				-- 获取神兵形象配置
	self.baojia_image_cfg = nil					-- 获取宝甲形象配置
	self.shenbing_texiao_cfg = nil				-- 获取神兵特效配置
	self.baojia_texiao_cfg = nil				-- 获取宝甲特效配置
	self.decompose_cfg = nil					-- 神兵分解配置

	self.shenbing_upgrade_cfg = nil      		-- 获取神兵升级配置
	self.baojia_upgrade_cfg = nil				-- 获取宝甲升级配置
	self.add_per_cfg = nil
	self.shenbing_eff_cfg = nil
	self.baojia_eff_cfg = nil
	--  神器所有信息
	self.shenqi_all_info = {
		shenbing_image_flag = 0,				-- 神兵形象激活标记
		shenbing_texiao_flag = 0,				-- 神兵特效激活标记
		baojia_image_flag = 0,					-- 宝甲形象激活标记
		baojia_texiao_flag = 0,					-- 宝甲特效激活标记

		shenbing_cur_image_id = 0,				-- 当前使用神兵形象id
		shenbing_cur_texiao_id = 0,				-- 当前使用神兵特效id
		baojia_cur_image_id = 0,				-- 当前使用宝甲形象id
		baojia_cur_texiao_id = 0,				-- 当前使用宝甲特效id

		shenbing_list = {},						-- 神兵列表
		baojia_list = {},						-- 宝甲列表						
	}

	self.decompose_result_info = {				-- 分解材料结果
		item_count = 0,
		item_list =  {},
	}
end

function ShenqiData:__delete()
	ShenqiData.Instance = nil
end

-- 设置神器所有信息
function ShenqiData:SetShenqiAllInfo(protocol)
	self.shenqi_all_info.shenbing_image_flag = protocol.shenbing_image_flag
	self.shenqi_all_info.shenbing_texiao_flag = protocol.shenbing_texiao_flag
	self.shenqi_all_info.baojia_image_flag = protocol.baojia_image_flag
	self.shenqi_all_info.baojia_texiao_flag = protocol.baojia_texiao_flag

	self.shenqi_all_info.shenbing_cur_image_id = protocol.shenbing_cur_image_id
	self.shenqi_all_info.shenbing_cur_texiao_id = protocol.shenbing_cur_texiao_id
	self.shenqi_all_info.baojia_cur_image_id = protocol.baojia_cur_image_id
	self.shenqi_all_info.baojia_cur_texiao_id = protocol.baojia_cur_texiao_id

	self.shenqi_all_info.shenbing_list = protocol.shenbing_list
	self.shenqi_all_info.baojia_list = protocol.baojia_list
end

function ShenqiData:SetShenBingListByIndex(protocol)
	self.shenqi_all_info.info_type = protocol.info_type
	if self.shenqi_all_info.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_SHENBING then
		self.shenqi_all_info.shenbing_list[protocol.item_index] = protocol.shenqi_item
	elseif self.shenqi_all_info.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_BAOJIA then
		self.shenqi_all_info.baojia_list[protocol.item_index] = protocol.shenqi_item
	end
end

-- 返回神器所有信息
function ShenqiData:GetShenqiAllInfo()
	return self.shenqi_all_info
end

-- 8537
function ShenqiData:SetShenqiImageInfo(protocol)
	self.shenqi_all_info.info_type = protocol.info_type
	if self.shenqi_all_info.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_SHENBING then
		self.shenqi_all_info.shenbing_image_flag = protocol.image_active_flag
		self.shenqi_all_info.shenbing_texiao_flag = protocol.texiao_active_flag
		self.shenqi_all_info.shenbing_cur_image_id = protocol.cur_use_imgage_id
		self.shenqi_all_info.shenbing_cur_texiao_id = protocol.cur_use_texiao_id
	elseif self.shenqi_all_info.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_BAOJIA then
		self.shenqi_all_info.baojia_image_flag = protocol.image_active_flag
		self.shenqi_all_info.baojia_texiao_flag = protocol.texiao_active_flag
		self.shenqi_all_info.baojia_cur_image_id = protocol.cur_use_imgage_id
		self.shenqi_all_info.baojia_cur_texiao_id = protocol.cur_use_texiao_id
	end
end

-- 设置分解结果
function ShenqiData:SetShenqiDecomposeResultInfo(protocol)
	self.decompose_result_info.item_count = protocol.item_count
	self.decompose_result_info.item_list = protocol.item_list
end

-- 获取分解结果
function ShenqiData:GetShenqiDecomposeResultInfo()
	return self.decompose_result_info
end


----------------------------------------------------------------------------------
-- 读配置区段
----------------------------------------------------------------------------------

function ShenqiData:GetShenqiCfg()
	if not self.shenqi_cfg then
		self.shenqi_cfg = ConfigManager.Instance:GetAutoConfig("shenqi_cfg_auto")
	end
	return self.shenqi_cfg
end

-- 神兵和宝甲升级材料的id
function ShenqiData:GetShenqiOtherCfg()
	if not self.shenqi_other_cfg then
		self.shenqi_other_cfg = self:GetShenqiCfg().other[1] or {}
	end
	return self.shenqi_other_cfg
end

-- 获取All神兵-镶嵌的配置
function ShenqiData:GetShenbingInlayAllCfg()
	if not self.shenbing_inlay_cfg then
		self.shenbing_inlay_cfg = self:GetShenqiCfg().shenbing_inlay or {}
	end
	return self.shenbing_inlay_cfg
end

-- 根据item_id获取神器配置
function ShenqiData:GetShenqiInlayCfgById(item_id)
	local shenbing_inlay_cfg = self:GetShenbingInlayAllCfg()
	for k,v in pairs(shenbing_inlay_cfg) do
		if v.inlay_stuff_id == item_id then
			return true
		end
	end

	local baojia_inlay_cfg = self:GetBaojiaInlayAllCfg()
	for k,v in pairs(baojia_inlay_cfg) do
		if v.inlay_stuff_id == item_id then
			return true
		end
	end

	return false
end

-- 获取All宝甲-镶嵌的配置
function ShenqiData:GetBaojiaInlayAllCfg()
	if not self.baojia_inlay_cfg then
		self.baojia_inlay_cfg = self:GetShenqiCfg().baojia_inlay or {}
	end
	return self.baojia_inlay_cfg
end

-- 获取神兵-升级的配置
function ShenqiData:GetShenbingUpgradeCfg()
    if not self.shenbing_upgrade_cfg then
    	self.shenbing_upgrade_cfg = ListToMap(self:GetShenqiCfg().shenbing_uplevel, "level")
    end
	return self.shenbing_upgrade_cfg
end

-- 获取宝甲-升级的配置
function ShenqiData:GetBaojiaUpgradeCfg()
	if not self.baojia_upgrade_cfg then
		self.baojia_upgrade_cfg = ListToMap(self:GetShenqiCfg().baojia_uplevel,"level")
	end
	return self.baojia_upgrade_cfg
end

function ShenqiData:ShenBingEffCfg()
    if not self.shenbing_eff_cfg then
    	self.shenbing_eff_cfg = ListToMap(self:GetShenqiCfg().shenbing_texiao, "seq")
    end
    return self.shenbing_eff_cfg
end

function ShenqiData:BaoJiaEffEfg()
    if not self.baojia_eff_cfg then
    	self.baojia_eff_cfg = ListToMap(self:GetShenqiCfg().baojia_texiao, "seq")
    end	
    return self.baojia_eff_cfg
end


function ShenqiData:GetAddPerCfg()
	if not self.add_per_cfg then
		self.add_per_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("equipforge_auto").shenqi_add_per, "add_type")
	end
	return self.add_per_cfg
end

-- 获取属性加成
function ShenqiData:GetJiaChengPer(shenqi_type)
    local add_per_cfg = self:GetAddPerCfg()
	if add_per_cfg then
		local addper = add_per_cfg[shenqi_type].add_per
		return addper
	end
	return 0
end

-- 获取等级限制加成
function ShenqiData:GetJiaChengMinLevel(shenqi_type)
	local add_per_cfg = self:GetAddPerCfg()
	if add_per_cfg then
		local condition = add_per_cfg[shenqi_type].condition
		return condition
	end
	return 20
end

-- 获取神兵-形象的配置
function ShenqiData:GetShenbingImageCfg()
	if not self.shenbing_image_cfg then
		self.shenbing_image_cfg = self:GetShenqiCfg().shenbing_image or {}
	end
	return self.shenbing_image_cfg
end

-- 获取宝甲-形象的配置
function ShenqiData:GetBaojiaImageCfg()
	if not self.baojia_image_cfg then
		self.baojia_image_cfg = self:GetShenqiCfg().baojia_image or {}
	end
	return self.baojia_image_cfg
end

-- 获取神兵-特效的配置
function ShenqiData:GetShenbingTexiaoCfg()
	if not self.shenbing_texiao_cfg then
		self.shenbing_texiao_cfg = self:GetShenqiCfg().shenbing_texiao or {}
	end
	return self.shenbing_texiao_cfg
end

-- 获取宝甲-特效的配置
function ShenqiData:GetBaojiaTexiaoCfg()
	if not self.baojia_texiao_cfg then
		self.baojia_texiao_cfg = self:GetShenqiCfg().baojia_texiao or {}
	end
	return self.baojia_texiao_cfg
end

-- 获取神兵-镶嵌的配置
function ShenqiData:GetShenbingInlayCfg()
	local data_list = {}
	for k,v in pairs(self:GetShenbingInlayAllCfg()) do
		if not data_list[v.id] then
			data_list[v.id] = v
		end
	end
	return data_list
end

-- 获取宝甲-镶嵌的配置
function ShenqiData:GetBaojiaInlayCfg()
	local data_list = {}
	for k,v in pairs(self:GetBaojiaInlayAllCfg()) do
		if not data_list[v.id] then
			data_list[v.id] = v
		end
	end
	return data_list
end

-- 神兵-分解的配置
function ShenqiData:GetShenbingDecomposeCfg()
	if not self.decompose_cfg then
		self.decompose_cfg = self:GetShenqiCfg().decompose or {}
	end
	return self.decompose_cfg
end

-- 获取当前神兵信息
function ShenqiData:GetShenBingList(id)
	local shenqi_all_info = self:GetShenqiAllInfo()
	local shenbing_list = shenqi_all_info.shenbing_list
	return shenbing_list[id] or {}
end

-- 获取已经激活的神兵数量
function ShenqiData:GetShenBingActvityNum()
	local shenqi_all_info = self:GetShenqiAllInfo()
	local shenbing_list = shenqi_all_info.shenbing_list
	local activity_num = 0
	for k, v in pairs(shenbing_list) do
		if v and v.quality_list then
			local is_activity = true
			for qk, qv in pairs(v.quality_list) do
				if qv <= 0 then
					is_activity = false
				end
			end
			if is_activity then
				activity_num = activity_num + 1
			end
		end
	end
	return activity_num
end

-- 获取符合等级的剑灵数量
function ShenqiData:GetShenBingLevel()
	local shenqi_all_info = self:GetShenqiAllInfo()
	local shenbing_list = shenqi_all_info.shenbing_list
	local activity_num = 0
	local min_level = self:GetJiaChengMinLevel(SHENBING_ADDPER.QILING_TYPE)
	for k, v in pairs(shenbing_list) do
		if v.level >= min_level then
			activity_num = activity_num + 1
		end
	end
 	return activity_num
end

-- 获取已经激活的宝甲数量
function ShenqiData:GetBaoJiaActvityNum()
	local baojia_all_info = self:GetShenqiAllInfo()
	local baojia_list = baojia_all_info.baojia_list
	local activity_num = 0
	for k, v in pairs(baojia_list) do
		if v and v.quality_list then
			local is_activity = true
			for qk, qv in pairs(v.quality_list) do
				if qv <= 0 then
					is_activity = false
				end
			end
			if is_activity then
				activity_num = activity_num + 1
			end
		end
	end
	return activity_num
end

-- 获取符合等级的器灵数量
function ShenqiData:GetQiLingLevel()
	local baojia_all_info = self:GetShenqiAllInfo()
	local baojia_list = baojia_all_info.baojia_list
	local activity_num = 0
	local min_level = self:GetJiaChengMinLevel(SHENBING_ADDPER.QILING_TYPE)
	for k, v in pairs(baojia_list) do
		if v.level >= min_level then
			activity_num = activity_num + 1
		end
	end
 	return activity_num
end

-- 获取当前宝甲信息
function ShenqiData:GetBaojiaInfo(id)
	local shenqi_all_info = self:GetShenqiAllInfo()
	local baojia_list = shenqi_all_info.baojia_list
	return baojia_list[id] or {}
end

-- 获取当前镶嵌的材料的ID
function ShenqiData:GetXiangQianStuffListById(id, list, cfg)
	local stuff_list = {}
	if list ~= nil and list.quality_list ~= nil then
		for k, v in pairs(list.quality_list) do
			local cfg = self:GetSingleXiangQianCfg(id, k, v, cfg)
			if next(cfg) then
				table.insert(stuff_list, cfg.inlay_stuff_id)  --材料的id
			else
				table.insert(stuff_list, 0)
			end
		end
	end

	return stuff_list
end

-- 通过神兵id、部位、品质获取单个镶嵌配置
function ShenqiData:GetSingleXiangQianCfg(id, part_type, quality, cfg)
	local data = {}
	for k, v in pairs(cfg) do
		if id == v.id and part_type == v.part_type and quality == v.quality then
			data = v
		end
	end

	return data
end

-- 通过材料id获取单个镶嵌配置
function ShenqiData:GetSingleXiangQianCfgByStuff(stuff_id, cfg)
	local data = {}
	for k, v in pairs(cfg) do
		if stuff_id == v.inlay_stuff_id then
			data = v
		end
	end

	return data
end

-- 获取是否可以镶嵌
function ShenqiData:GetIsCanXiangQian(id, list, cfg)
	local can_xiangqian_list = {false, false, false, false}
	local cur_stuff_list_cfg = {}
	local cur_stuff_list = self:GetXiangQianStuffListById(id, list, cfg)
	for k, v in pairs(cur_stuff_list) do
		table.insert(cur_stuff_list_cfg, self:GetSingleXiangQianCfgByStuff(v, cfg))
	end

	local bag_data = ItemData.Instance:GetBagItemDataList()
	for _, v in pairs(bag_data) do
		local bag_stuff_cfg = self:GetSingleXiangQianCfgByStuff(v.item_id, cfg)
		if next(bag_stuff_cfg) then
			for _, v1 in pairs(cur_stuff_list_cfg) do
				if bag_stuff_cfg.id == v1.id and bag_stuff_cfg.part_type == v1.part_type and bag_stuff_cfg.quality > v1.quality then
					can_xiangqian_list[v1.part_type + 1] = true
				end
			end

			if nil == next(cur_stuff_list_cfg[bag_stuff_cfg.part_type + 1]) and bag_stuff_cfg.id == id then
				can_xiangqian_list[bag_stuff_cfg.part_type + 1] = true
			end
		end
	end

	return can_xiangqian_list
end

-- 获取背包中最高品质的镶嵌材料
function ShenqiData:GetMaxQualityStuff(id, part_type, cfg, info)
	local quality = 0
	local bag_data = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_data) do
		local bag_stuff_cfg = self:GetSingleXiangQianCfgByStuff(v.item_id, cfg)
		if next(bag_stuff_cfg) then
			if bag_stuff_cfg.id == id and bag_stuff_cfg.part_type == part_type 
				and bag_stuff_cfg.quality > info.quality_list[part_type] then
				quality = bag_stuff_cfg.quality
			end
		end
	end

	return quality
end

-- 获取剑灵激活状态
function ShenqiData:GetStuffActiveState(type,index,list)
	local data = {}
	for k,v in pairs(list) do
		if v.active_texiao_id == 1 then 
			data = v
			break
		end 
	end

	local shenqi_all_info = self:GetShenqiAllInfo()
	local str = ""
	if shenqi_all_info.shenbing_list[index].level >= data.level then
		str = Language.Shenqi.Actived
	else
		str = string.format(Language.Shenqi.StuffLevel[type], data.level)
	end
	return str
end

-- 获取激活数量
function ShenqiData:GetActiveNum(flag)
	local flag_table = bit:d2b(flag)
	local active_num = 0
	for i,v in ipairs(flag_table) do
		if v == 1 then
			active_num = active_num + 1
		end
	end
	return active_num
end

--根据等级和相应是配置获取升级配置
function ShenqiData:GetCfgByLevel(level,list)
	return list[level] or {}
end

-- 根据id获取品质
function ShenqiData:GetQualityByItemId(item_id)
	local quality = 1
	local decompose_cfg = self:GetShenbingDecomposeCfg()
	for k, v in pairs(decompose_cfg) do
		if v.stuff_id == item_id then
			quality = v.quality
		end
	end

	return quality
end

-- 获取背包里可分解的材料
function ShenqiData:GetCanFenjieStuff()
	local data = {}
	local decompose_cfg = self:GetShenbingDecomposeCfg()
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_data_list) do
		for k2,v2 in pairs(decompose_cfg) do
			if v.item_id == v2.stuff_id then
				local quality = self:GetQualityByItemId(v.item_id)
				v.quality = quality
				table.insert(data, v)
			end
		end
	end
	return data
end

-- 根据品质获取分解材料
function ShenqiData:GetFenjieListbyQuality(quality)
	local data = {}
	local data_list = ShenqiData.Instance:GetCanFenjieStuff()
	for k,v in pairs(data_list) do
		if quality == v.quality then
			data[k] = v
		end
	end
	return data
end

function ShenqiData:GetHeadResId(id)
	if id == nil then
		return nil
	end

	local shenbing_image_cfg = self:GetShenbingImageCfg()
	for k,v in pairs(shenbing_image_cfg) do
		if v.id == id then
			return v.head_id
		end
	end

	return nil
end

-- 根据形象id获取资源id
function ShenqiData:GetResCfgByIamgeID(index)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local shenbing_image_cfg = self:GetShenbingImageCfg()
	for k,v in pairs(shenbing_image_cfg) do
		if index == v.id and v["resource_id_" .. main_role_vo.prof .. main_role_vo.sex] then
			return v["resource_id_" .. main_role_vo.prof .. main_role_vo.sex]
		end
	end
	return 0
end

-- 根据data获取资源id
function ShenqiData:GetDataResCfgByIamgeID(data)
	local shenbing_image_cfg = self:GetShenbingImageCfg()
	for k,v in pairs(shenbing_image_cfg) do
		if data.shengbing_img_id == v.id and v["resource_id_" .. data.prof .. data.sex] then
			return v["resource_id_" .. data.prof .. data.sex]
		end
	end
	return 0
end

-- 根据形象id获取宝甲资源id
function ShenqiData:GetBaojiaResCfgByIamgeID(index)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local baojia_image_cfg = self:GetBaojiaImageCfg()
	for k,v in pairs(baojia_image_cfg) do
		if index == v.id and v["resource_id_" .. main_role_vo.prof .. main_role_vo.sex] then
			return v["resource_id_" .. main_role_vo.prof .. main_role_vo.sex]

		end
	end
	return 0
end

-- 根据形象id、职业、性别获取宝甲资源id
function ShenqiData:GetBaojiaResCfgByInfo(index,prof,sex)
	local baojia_image_cfg = self:GetBaojiaImageCfg()
	for k,v in pairs(baojia_image_cfg) do
		if index == v.id and v["resource_id_" .. prof .. sex] then
			return v["resource_id_" .. prof .. sex]

		end
	end
	return 0
end

-- 根据形象id、职业、性别获取资源id
function ShenqiData:GetResCfgByInfo(index,prof,sex)
	local shenbing_image_cfg = self:GetShenbingImageCfg()
	for k,v in pairs(shenbing_image_cfg) do
		if index == v.id and v["resource_id_" .. prof .. sex] then
			return v["resource_id_" .. prof .. sex]
		end
	end
	return 0
end

-- 根据data数据获取宝甲资源id
function ShenqiData:GetDataBaojiaResCfgByIamgeID(data)
	local baojia_image_cfg = self:GetBaojiaImageCfg()
	for k,v in pairs(baojia_image_cfg) do
		if data.baojia_img_id == v.id and v["resource_id_" .. data.prof .. data.sex] then
			return v["resource_id_" .. data.prof .. data.sex]
		end
	end
	return 0
end

-- 根据物品id获取分解材料的个数
function ShenqiData:GetFenjieNumByItemID(item_id, stuff_type)
	local num = 0
	local decompose = self:GetShenbingDecomposeCfg()
	for k,v in pairs(decompose) do
		if v.stuff_id == item_id and v.stuff_type == stuff_type then
			num = v.get_item[0].num
			break
		end
	end
	return num
end

-- 单个神兵镶嵌是否显示红点
function ShenqiData:GetIsShowSbXiangQiangRpByIndex(index)
	local shenbing_info = ShenqiData.Instance:GetShenBingList(index)
	local shenbing_cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
	local can_xiangqian_list = self:GetIsCanXiangQian(index, shenbing_info, shenbing_cfg)
	for i = 1, ShenqiData.ShenqiInfo.MaterialNum do
		if can_xiangqian_list[i] then
			return true
		end
	end

	return false
end

-- 单个宝甲镶嵌是否显示红点
function ShenqiData:GetIsShowBjXiangQiangRpByIndex(index)
	local baojia_info = ShenqiData.Instance:GetBaojiaInfo(index)
	local baojia_cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
	local can_xiangqian_list = self:GetIsCanXiangQian(index, baojia_info, baojia_cfg)
	for i = 1, ShenqiData.ShenqiInfo.MaterialNum do
		if can_xiangqian_list[i] then
			return true
		end
	end

	return false
end

-- 神兵镶嵌是否显示红点
function ShenqiData:GetIsShowSbXiangQiangRp()
	for i = 1, ShenqiData.ShenqiInfo.ShenBingNum do
		local can_xiangqian_list = self:GetIsShowSbXiangQiangRpByIndex(i)
		if can_xiangqian_list then
			return true
		end
	end 

	return false
end

-- 宝甲镶嵌是否显示红点
function ShenqiData:GetIsShowBjXiangQiangRp()
	for i = 1, ShenqiData.ShenqiInfo.BaoJiaNum do
		local can_xiangqian_list = self:GetIsShowBjXiangQiangRpByIndex(i)
		if can_xiangqian_list then
			return true
		end
	end 

	return false
end
--神兵升级单个红点
function ShenqiData:GetJianLingUpdateRedPoint(index)
	local shenqi_other_cfg1 = self:GetShenqiOtherCfg()
	local shenqi_all_info1 = self:GetShenqiAllInfo()
	local shenbing_upgrade_cfg = self:GetShenbingUpgradeCfg()
	if shenbing_upgrade_cfg == nil or shenqi_all_info1 == nil or shenqi_other_cfg1 == nil then return false end
	local shenbing_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg1.shenbing_uplevel_stuff)
	local shenqi_info1 = shenqi_all_info1.shenbing_list[index]
	local cur_level1 = shenqi_info1.level

	local check_flag = false
	if shenqi_info1 ~= nil and shenqi_info1.quality_list ~= nil then
		for k, v in  pairs(shenqi_info1.quality_list) do
			check_flag = v > 0
			if not check_flag then
				break
			end
		end
	end

	local cur_level_exp1 = self:GetCfgByLevel(cur_level1 + 1, shenbing_upgrade_cfg).need_exp
	if shenqi_info1.level < shenbing_upgrade_cfg[#shenbing_upgrade_cfg].level and check_flag then
			if shenbing_stuff_num * upgrage_add_exp + shenqi_info1.exp >= cur_level_exp1 then
				return true
			end
	end 
	return false
end
-- 全部神兵剑灵是否显示红点
function ShenqiData:GetIsShowSbJianLingRp()
	local shenqi_other_cfg1 = self:GetShenqiOtherCfg()
	local shenqi_all_info1 = self:GetShenqiAllInfo()
	local shenbing_upgrade_cfg = self:GetShenbingUpgradeCfg()
	if shenbing_upgrade_cfg == nil or shenqi_all_info1 == nil or shenqi_other_cfg1 == nil then return false end

	local shenbing_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg1.shenbing_uplevel_stuff)
	for i = 1, ShenqiData.ShenqiInfo.ShenBingNum do
		local shenqi_info1 = shenqi_all_info1.shenbing_list[i]
		local cur_level1 = shenqi_info1.level
		local cur_level_exp1 = self:GetCfgByLevel(cur_level1 + 1, shenbing_upgrade_cfg).need_exp

		local check_flag = false
		if shenqi_info1 ~= nil and shenqi_info1.quality_list ~= nil then
			for k, v in  pairs(shenqi_info1.quality_list) do
				check_flag = v > 0
				if not check_flag then
					break
				end
			end
		end

		if shenqi_info1.level < shenbing_upgrade_cfg[#shenbing_upgrade_cfg].level and check_flag then
			if shenbing_stuff_num * upgrage_add_exp + shenqi_info1.exp >= cur_level_exp1 then
				return true
			end
		end
	end 
	return false
end
--宝甲升级单个红点
function ShenqiData:GetBaoJiaUpdateRedPoint(index)
	local shenqi_other_cfg = self:GetShenqiOtherCfg()
	local shenqi_all_info = self:GetShenqiAllInfo()
	local baojia_upgrade_cfg = self:GetBaojiaUpgradeCfg()
	if baojia_upgrade_cfg == nil  or shenqi_other_cfg == nil or shenqi_all_info == nil  then return  false end
	local baojia_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)
	local shenqi_info = shenqi_all_info.baojia_list[index]
	local cur_level = shenqi_info.level
	local cur_level_exp = self:GetCfgByLevel(cur_level + 1, baojia_upgrade_cfg).need_exp

	local check_flag = false
	if shenqi_info ~= nil and shenqi_info.quality_list ~= nil then
		for k, v in  pairs(shenqi_info.quality_list) do
			check_flag = v > 0
			if not check_flag then
				break
			end
		end
	end

	if cur_level < baojia_upgrade_cfg[#baojia_upgrade_cfg].level and check_flag then
		if baojia_stuff_num * upgrage_add_exp + shenqi_info.exp >= cur_level_exp then
			return true
		end
	end
	return false
end
-- 宝甲器灵是否显示红点
function ShenqiData:GetIsShowBjQiLingRp()
	local shenqi_other_cfg = self:GetShenqiOtherCfg()
	local shenqi_all_info = self:GetShenqiAllInfo()
	local baojia_upgrade_cfg = self:GetBaojiaUpgradeCfg()
	if baojia_upgrade_cfg == nil  or shenqi_other_cfg == nil or shenqi_all_info == nil  then return  false end

	local baojia_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)
	for i = 1, ShenqiData.ShenqiInfo.BaoJiaNum do
		local shenqi_info = shenqi_all_info.baojia_list[i]
		local cur_level = shenqi_info.level
		local cur_level_exp = self:GetCfgByLevel(cur_level + 1, baojia_upgrade_cfg).need_exp

		local check_flag = false
		if shenqi_info ~= nil and shenqi_info.quality_list ~= nil then
			for k, v in  pairs(shenqi_info.quality_list) do
				check_flag = v > 0
				if not check_flag then
					break
				end
			end
		end

		if cur_level < baojia_upgrade_cfg[#baojia_upgrade_cfg].level and check_flag then
			if baojia_stuff_num * upgrage_add_exp + shenqi_info.exp >= cur_level_exp then
				return true
			end
		end
	end
	return false
end

function ShenqiData:GetShenQiEffectCfg(show_type, id)
	if id == nil or show_type == nil then
		return {}
	end
    local shenbing_eff_cfg = self:ShenBingEffCfg()
    local baojia_eff_cfg = self:BaoJiaEffEfg()

	if show_type == SHENQI_TIP_TYPE.SHENBING then
		return shenbing_eff_cfg[id] or {}
	else
		return baojia_eff_cfg[id] or {}
	end
end