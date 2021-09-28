LingZhuData = LingZhuData or BaseClass()

function LingZhuData:__init()
	if LingZhuData.Instance ~= nil then
		ErrorLog("[LingZhuData] attempt to create singleton twice!")
		return
	end
	LingZhuData.Instance = self

	local lingzhu_cfg = ConfigManager.Instance:GetAutoConfig("lingzhu_auto")

	self.other_cfg = lingzhu_cfg.other[1]
	self.lingzhu_grade_cfg = ListToMap(lingzhu_cfg.grade, "grade")
	self.lingzhu_image_list_cfg = ListToMap(lingzhu_cfg.image_list, "image_id")
	self.lingzhu_special_img_cfg = ListToMap(lingzhu_cfg.special_img, "image_id")
	self.lingzhu_special_image_upgrade_cfg = ListToMap(lingzhu_cfg.special_image_upgrade, "special_img_id", "grade")

	self.special_grade_max_level = self:CalcSpecialImgMaxLevel()

	RemindManager.Instance:Register(RemindName.LingZhu_UpGrade, BindTool.Bind(self.CalcUpgradeRemind, self))
	RemindManager.Instance:Register(RemindName.LingZhu_ZiZhi, BindTool.Bind(self.CalcZiZhiRemind, self))
	RemindManager.Instance:Register(RemindName.LingZhu_HuanHua, BindTool.Bind(self.CalcHuanHuaRemind, self))
end

function LingZhuData:__delete()
	RemindManager.Instance:UnRegister(RemindName.LingZhu_UpGrade)
	RemindManager.Instance:UnRegister(RemindName.LingZhu_ZiZhi)
	RemindManager.Instance:UnRegister(RemindName.LingZhu_HuanHua)

	LingZhuData.Instance = nil
end

function LingZhuData:SetLingZhuInfo(info)
	self.lingzhu_info = info

	self.special_img_grade_list = self.lingzhu_info.special_img_grade_list
	self.active_image_flag_list = bit:d2b(info.active_image_flag)
	self.active_special_image_flag_list = bit:ll2b(info.active_special_image_flag_high, info.active_special_image_flag_low)
end

function LingZhuData:GetLingZhuInfo()
	return self.lingzhu_info
end

-- 全属性加成所需阶数
function LingZhuData:GetActiveNeedGrade()
  	return self.other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function LingZhuData:GetGrade()
	if self.lingzhu_info then
  		return self.lingzhu_info.grade or 0
  	end
  	return 0
end

-- 全属性加成百分比
function LingZhuData:GetAllAttrPercent()
  	local attr_percent = math.floor(self.other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function LingZhuData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

--获取对应等级相关数据
function LingZhuData:GetLingZhuGradeCfgInfoByGrade(grade)
	grade = grade or (self.lingzhu_info and self.lingzhu_info.grade) or 0
	return self.lingzhu_grade_cfg[grade]
end

--获取清空祝福值的最小阶数
function LingZhuData:GetClearBlessGradeLimit()
	for k, v in ipairs(self.lingzhu_grade_cfg) do
		if v.is_clear_bless == 1 then
			return v.show_grade, v.gradename
		end
	end

	return 0, ""
end

function LingZhuData:GetLingZhuImageCfgInfoByImageId(image_id)
	return self.lingzhu_image_list_cfg[image_id]
end

function LingZhuData:GetSpecialImageCfgInfoByImageId(image_id)
	return self.lingzhu_special_img_cfg[image_id]
end

--获取对应的资源id
function LingZhuData:GetResIdByImageId(image_id)
	local image_info = nil
	if image_id > 1000 then
		--特殊形象由1000开始
		image_id = image_id - 1000
		image_info = self:GetSpecialImageCfgInfoByImageId(image_id)
	else
		image_info = self:GetLingZhuImageCfgInfoByImageId(image_id)
	end

	if image_info then
		return image_info.res_id
	end

	return 0
end

--计算特殊形象等级上限
function LingZhuData:CalcSpecialImgMaxLevel()
	local level_limit = 0
	for k, v in pairs(self.lingzhu_special_image_upgrade_cfg) do
		for k2, v2 in pairs(v) do
			if v2.grade > level_limit then
				level_limit = v2.grade
			end
		end
		break
	end

	return level_limit
end

--获取特殊形象等级上限
function LingZhuData:GetSpecialImgMaxLevel()
	return self.special_grade_max_level
end

--获取对应的幻化image_id是否已使用
function LingZhuData:GetHuanHuaIdIsUsed(image_id, is_special)
	if nil == self.lingzhu_info then
		return false
	end

	--特殊形象加1000
	if is_special then
		image_id = image_id + 1000
	end

	return self.lingzhu_info.used_imageid == image_id
end

--获取最多的属性丹数量
function LingZhuData:GetMaxShuXingDanCount(grade)
	local max_num = 0
	if nil == self.lingzhu_info then
		return max_num
	end

	grade = grade or self.lingzhu_info.grade

	--先获取当前阶数的属性丹最大数量
	local grade_info = self:GetLingZhuGradeCfgInfoByGrade(grade)
	if nil == grade_info then
		return max_num
	end
	max_num = max_num + grade_info.shuxingdan_limit

	--加上幻化形象增加的属性丹数量
	local flag = 0
	for k, v in pairs(self.lingzhu_special_image_upgrade_cfg) do
		if self.active_special_image_flag_list[64 - k] == 1 then
			max_num = max_num + v[0].shuxingdan_count
		end
	end

	return max_num
end

--获取可显示的幻化列表
function LingZhuData:GetHuanHuaCfgList()
	local huanhua_list = nil

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in pairs(self.lingzhu_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			if nil == huanhua_list then
				huanhua_list = {}
			end

			table.insert(huanhua_list, v)
		end
	end

	return huanhua_list
end

--获取对应幻化等级
function LingZhuData:GetHuanHuaGrade(image_id)
	if nil == self.special_img_grade_list then
		return 0
	end

	return self.special_img_grade_list[image_id] or 0
end

--获取对应幻化信息
function LingZhuData:GetHuanHuaCfgInfo(image_id, grade)
	grade = grade or self:GetHuanHuaGrade(image_id)

	if self.lingzhu_special_image_upgrade_cfg[image_id] then
		return self.lingzhu_special_image_upgrade_cfg[image_id][grade]
	end

	return nil
end

--获取对应幻化形象是否已激活
function LingZhuData:GetHuanHuaIsActiveByImageId(image_id)
	if nil == self.active_special_image_flag_list then
		return false
	end

	return self.active_special_image_flag_list[64 - image_id] == 1
end

--获取对应幻化形象的红点
function LingZhuData:GetHuanHuaRemindByImageId(image_id)
	--没达到对应开服天数, 或者等级没达到要求没有红点
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local image_info = self.lingzhu_special_img_cfg[image_id]
	if not image_info or open_server_day < image_info.open_day or main_vo.level < image_info.lvl then
		return 0
	end

	if nil == self.special_img_grade_list then
		return 0
	end

	--满级的话没有红点
	local grade = self.special_img_grade_list[image_id]
	if nil == grade or grade >= self.special_grade_max_level then
		return 0
	end

	local grade_list = self.lingzhu_special_image_upgrade_cfg[image_id]
	if nil == grade_list then
		return 0
	end

	local grade_info = grade_list[grade]
	if nil == grade_info then
		return 0
	end

	local have_num = ItemData.Instance:GetItemNumInBagById(grade_info.stuff_id)
	if have_num >= grade_info.stuff_num then
		return 1
	end

	return 0
end

--计算升级材料是否足够
function LingZhuData:CalcUpgradeRemind()
	if nil == self.lingzhu_info then
		return 0
	end

	--没有下一阶表示已满阶
	local next_grade_info = self:GetLingZhuGradeCfgInfoByGrade(self.lingzhu_info.grade + 1)
	if nil == next_grade_info then
		return 0
	end

	local grade_info = self:GetLingZhuGradeCfgInfoByGrade(self.lingzhu_info.grade)
	if nil == grade_info then
		return 0
	end

	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
	if need_item_num <= have_item_num then
		--升阶材料足够
		return 1
	end

	return 0
end

--计算幻化形象红点
function LingZhuData:CalcHuanHuaRemind()
	if nil == self.special_img_grade_list then
		return 0
	end

	--判断是否有幻化形象可激活或可升级
	local grade_list = nil				--对应资源的等级列表
	local grade_info = nil				--对应等级相关数据
	local img_info = nil				--对应资源相关数据
	local have_num = 0
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.special_img_grade_list) do
		grade_list = self.lingzhu_special_image_upgrade_cfg[k]
		img_info = self.lingzhu_special_img_cfg[k]

		--达到对应开服天数, 人物等级达到要求, 当前等级数据存在且下一级数据也存在则进入物品数量判断
		if img_info
			and open_server_day >= img_info.open_day
			and main_vo.level >= img_info.lvl
			and grade_list
			and grade_list[v]
			and grade_list[v + 1] then

			grade_info = grade_list[v]
			have_num = ItemData.Instance:GetItemNumInBagById(grade_info.stuff_id)
			if have_num >= grade_info.stuff_num then
				return 1
			end
		end
	end

	return 0
end

--计算资质丹红点
function LingZhuData:CalcZiZhiRemind()
	if nil == self.lingzhu_info then
		return 0
	end

	--判断资质升级是否达到上限
	if self.lingzhu_info.shuxingdan_count < self:GetMaxShuXingDanCount() then
		--是否拥有资质丹
	 	local zizhi_info = AppearanceData.Instance:GetZiZhiCfgInfoByType(ZIZHI_TYPE.LINGZHU)
	 	if nil == zizhi_info then
	 		return 0
	 	end

	 	if ItemData.Instance:GetItemNumInBagById(zizhi_info.item_id) > 0 then
	 		return 1
	 	end
	end

	return 0
end