WingData = WingData or BaseClass()

WingDataConst = {
	AUTOBUY = {
		YES = 1,
		NO = 0,
	},
	-- TabbarContent = {
	-- 	INVALID = -1,                               -- 无效
	-- 	Wing_Attr = 1,                              -- 羽翼属性
	-- 	Wing_Evol = 2,                              --羽翼进化
	-- 	Wing_FaZhen = 3,                            --法阵进阶
	-- },
	Effect = {
		BaoJi = "3007",
		Success = "3006",
	},
	-- TimerHandler = {                                -- 计时器句柄
	-- 	Auto = {},
	-- }
}

WINGJINJIE = {
	WINGQIJINJIE_MAX_LEVEL = 10,
	WINGQIJINJIE_MAX_INDEX = 16,
}

WING_BIGGRADE_TO_QUALITY = {
	[0] = 6,							--特殊羽翼金色
	[1] = 1,							-- 绿
	[2] = 1,
	[3] = 2,							-- 蓝
	[4] = 2,
	[5] = 2,							-- 紫
	[6] = 2,
	[7] = 3,
	[8] = 3,
	[9] = 3,
	[10] = 4,							-- 橙色
}


function WingData:__init()
    if WingData.Instance then
        print_error("[WingData] Attemp to create a singleton twice !")
    end

    WingData.Instance = self

    self.select_jinhua_img = 0                      -- 选择的形象对应的进化值
	self.jinhua = 0                                 -- 进化值
	self.jinhua_bless = 0                           -- 进化祝福值
	self.special_img_flag = 0                       -- 特殊形象标记
	self.select_special_img = -1                    -- 选中的特殊形象
	self.fazhen_data = {}
	self.auto_buy = 0

	self.shuxingdan_list = {}						--属性丹信息
	self.special_img_grade_list = {}                -- 羽翼进阶列表
	self.image_list_cfg = {} 						-- 形象列表配置
end

function WingData:__delete()
    WingData.Instance = nil
end

-- 设置属性丹信息
function WingData:SetShuxingdanInfo(info)
	self.shuxingdan_list = info
end

-- 设置属性丹信息
function WingData:GetShuxingdanInfo()
	return self.shuxingdan_list
end

-- 获取属性丹总属性
function WingData:GetShuXingdanAttr()
	local attr = BrowseData.GetShuxingdanAllAttr(SHUXINGDAN_TYPE.SHUXINGDAN_TYPE_WING, self.shuxingdan_list)
	return attr or CommonStruct.Attribute()
end

-- 设置选择的形象id
function WingData:SetSelectImageId(image_id)
	self.select_jinhua_img = image_id
end

-- 获取选择的形象id
function WingData:GetSelectImageId()
	return self.select_jinhua_img
end

-- 设置特殊形象标记
function WingData:SetSpecialImgFlag(value)
	self.special_img_flag = value
end

-- 获取特殊形象标记
function WingData:GetSpecialImgJihuo(index)
	return self.special_img_flag[index]
end

-- 设置选中的特殊形象
function WingData:SetSelectSpecialImg(value)
	self.select_special_img = value
end

-- 设置选中的特殊形象
function WingData:GetSelectSpecialImg()
	return self.select_special_img
end

-- 设置进化值
function WingData:SetJinHua(jinhua)
	self.jinhua = jinhua
end

-- 获取进化值
function WingData:GetJinHua()
	return self.jinhua
end

-- 设置进化祝福值
function WingData:SetJinHuaBless(bless)
	self.jinhua_bless = bless
end

-- 获取进化祝福值
function WingData:GetJinHuaBless()
	return self.jinhua_bless
end

-- 设置自动购买道具标识
function WingData:SetAutoBuyFlag(auto_buy)
	self.auto_buy = auto_buy
end

-- 获取自动购买道具标识
function WingData:GetAutoBuyFlag()
	return self.auto_buy
end

function WingData:SetSpecialImgGradeList(special_img_grade_list)
	if nil == special_img_grade_list then return end
	self.special_img_grade_list = special_img_grade_list
end

function WingData:GetSpecialImgGradeList()
	return self.special_img_grade_list
end

-- 根据小阶获取对应大阶数
function WingData:GetBigGrade(grade)
	if nil == grade then
		return
	end
	local vo = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[grade]
	local big_grade = 1
	if nil ~= vo then
		big_grade = vo.big_grade
	end

	return big_grade
end

-- 获取最大阶数
function WingData:GetMaxBigGrade()
	return (#ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua / 10)
end

-- 判断是否合法等级
function WingData:IsLegalGrade(grade)
	if nil == grade then
		return
	end
	return grade > 0 and grade <= #ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua
end

function WingData:SetFaZhenData(fazhen_data)
	self.fazhen_data = fazhen_data
end

function WingData:GetFaZhenData()
	return self.fazhen_data
end

-- 羽翼附魔
function WingData:SetWingFuMoLevelList(list)
	self.fumo_level_list = list
end

function WingData:GetWingFuMoLevelList()
	return self.fumo_level_list or {}
end


-- 获取等级属性
function WingData:GetJinHuaAttribute(config)
	local attribute = CommonStruct.Attribute()
	if nil == config then return attribute end
	attribute = CommonDataManager.GetAttributteByClass(config)

	return attribute
end

-- 获取特殊翅膀属性
function WingData:GetSpeicalJinHuaAttribute(index)
	local attribute = CommonStruct.Attribute()
	local special_img = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	if nil == index then return attribute end
	if special_img and special_img[index] then
		local config = special_img[index]
		attribute = CommonDataManager.GetAttributteByClass(config)
	end
	return attribute
end

function WingData:GetSpeicalWingCfg(img_id)
	local special_img = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	for k,v in pairs(special_img) do
		if v.img_id == img_id then
			return v
		end
	end
	return nil
end

-- 格式化羽翼大等级形象配置
function WingData:FormatWingImageCfg()
	self.image_list_cfg = {}
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua
	local res_id = -1
	local big_grade = -1
	local role_prof = PlayerData.Instance:GetRoleBaseProf()
	for i = 1, #wing_cfg do
		if wing_cfg[i] and big_grade ~= wing_cfg[i]["big_grade"] then
			big_grade = wing_cfg[i]["big_grade"]
			res_id = wing_cfg[i]["res_id_" .. role_prof]
			table.insert(self.image_list_cfg, {level = i, res_id = res_id, cfg = wing_cfg[i]})
		end
	end
end

-- 获取羽翼大等级形象配置
function WingData:GetWingImageCfg()
	if #self.image_list_cfg == 0 then self:FormatWingImageCfg() end
	local wing_img_cfg = {}
	local res_id = -1
	local role_prof = PlayerData.Instance:GetRoleBaseProf()
	for k,v in pairs(self.image_list_cfg) do
		-- if v and res_id ~= v.res_id then
		if v then
			res_id = v.res_id
			table.insert(wing_img_cfg, v)
		end
	end
	return wing_img_cfg
end


-- 根据等级获取羽翼形象索引
function WingData:GetWingImageIndexWithLevel(level)
	local wing_img_cfg = self:GetWingImageCfg()
	local len = #wing_img_cfg
	local index = 0
	for i = 1, len do
		if wing_img_cfg[len - i + 1] and level >= wing_img_cfg[len - i + 1].level then
			index = len - i + 1
			break
		end
	end

	return index
end

-- 根据id获取等级
function WingData:GetWingLevel(wing_id)
	if nil == self:GetSpecialImgGradeList() or nil == next(self:GetSpecialImgGradeList() ) then return end
	local wing_cfg = self:GetWingCfg(wing_id)
	local wing_upgrade = self:GetSpecialImgGradeList()[wing_cfg.img_id]
	if nil ~= wing_upgrade then
		return wing_upgrade
	end
end

function WingData:GetSpecialWingResId(image_id, prof)
	if nil == image_id then return 0 end
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img[image_id]
	local res_id = 0
	if wing_cfg ~= nil then
		local role_prof = PlayerData.Instance:GetRoleBaseProf(prof)
		res_id = wing_cfg["res_id_" .. role_prof] or 0
	end
	return res_id
end

-- 获取形象资源id
function WingData:GetWingResId(level, prof)
	if nil == level then return 0 end
	local res_id = 0
	--local role_prof = PlayerData.Instance:GetRoleBaseProf(prof)
	--local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[level]
	--if nil ~= wing_cfg then
	--	res_id = wing_cfg["res_id_" .. role_prof] or 0
	--end
	return res_id
end

-- 获取头像资源id
function WingData:GetWingHeadResId(level)
	if nil == level then return 0 end
	local res_id = 0
	local role_prof = PlayerData.Instance:GetRoleBaseProf()
	local index = self:GetWingImageIndexWithLevel(level)
	local wing_cfg = self:GetBiggradeWingImageCfg()[index]
	if nil ~= wing_cfg and nil ~= wing_cfg.cfg then
		res_id = wing_cfg.cfg["head_id_" .. role_prof] or 0
	end

	return res_id
end

function WingData:GetAllJinHuaAttribute()
	local attribute = CommonStruct.Attribute()
	for i = 1, 32 do
		local is_active = self:GetSpecialImgJihuo(i - 1)
		if 1 == is_active then
			local sp_wing_attr = self:GetSpeicalJinHuaAttribute(i - 1)
			if nil ~= sp_wing_attr then
				attribute = CommonDataManager.AddAttributeAttr(attribute, sp_wing_attr)
			end
		end
	end
	return attribute
end

-- 根据坐骑id获取相应配置 special_wing_upagrade是空表
function WingData:GetWingCfg(wing_id)
	local cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("wing_auto").special_wing_upagrade) do
		if v.item_id == wing_id then
			cfg = v
		end
	end

	return cfg
end

-- 获取战力提升
function WingData:GetWingCapacityLerp(wing_id, wing_cur_level, wing_next_level)
	local next_capability = 0

	local cur_cfg = self:GetWingLevelCfg(wing_id, wing_cur_level)
	local next_cfg = self:GetWingLevelCfg(wing_id, wing_next_level)

	local cur_attribute = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attribute = CommonDataManager.GetAttributteByClass(next_cfg)

	local attribute = CommonDataManager.LerpAttributeAttr(cur_attribute, next_attribute)
	return CommonDataManager.GetCapability(attribute)
end

  -- 根据坐骑id和等级获取坐骑的等级信息
function WingData:GetWingLevelCfg(wing_id, level)
	for _,v in pairs(ConfigManager.Instance:GetAutoConfig("wing_auto").special_wing_upagrade) do
		if v.item_id == wing_id and v.grade == level then
			return v
		end
	end
	return nil
end

function WingData:GetEnchantingLevelByType(type)
	if nil == type then return end

	return self.fumo_level_list[type] or 0
end

function WingData:GetEnChantingCfgByTypeAndLv(type, level)
	if nil == type then return end

	local cfg = {}
	local cur_level = level or self:GetEnchantingLevelByType(type)

	if nil == ConfigManager.Instance:GetAutoConfig("wing_auto").fumo_cfg or nil == next(ConfigManager.Instance:GetAutoConfig("wing_auto").fumo_cfg) then
	return cfg
	end

	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("wing_auto").fumo_cfg) do
		if type == v.magic_wing_type + 1 and cur_level == v.fumo_level then
			cfg = v
		end
	end

	return cfg
end