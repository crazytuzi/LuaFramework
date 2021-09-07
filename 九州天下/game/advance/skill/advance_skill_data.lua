AdvanceSkillData = AdvanceSkillData or BaseClass()
local ADVANCE_SKILL_VIEW_LEARN = 1
local ADVANCE_SKILL_VIEW_COPY  = 2
function AdvanceSkillData:__init()
	if AdvanceSkillData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	AdvanceSkillData.Instance = self

	self.skill_all_cfg = nil	--ConfigManager.Instance:GetAutoConfig("jingling_auto").skill
	self.skill_flush_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").skill_refresh, "stage")
	self.skill_book_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").skill_book, "type")
	self.grade_open_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").grade_skill_num, "grade")
	self.skill_info_list = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").skill,"skill_id")
	self.image_open_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").image_level, "image_type")
	self.skill_att_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_auto").skill,"skill_type","book_id")
	self.skill_cur_index = 0
	self.skill_cur_cell_index = 1
	self.skill_storage_cell_index = 0
	self.refresh_count = 0
	self.skill_info = {}
	--self.skill_num_cfg = self:GetSkillNumLevelCfg()
	self.book_item_id = self:InitBookList()
	self.table_index = 1
end

function AdvanceSkillData:__delete()
	if AdvanceSkillData.Instance then
		AdvanceSkillData.Instance = nil
	end
end

function AdvanceSkillData:SetAdvanceSkillInfo(protocol)
	self.skill_info.skill_storage_list = protocol.skill_storage_list
	self.skill_info.skill_refresh_item_list = protocol.skill_refresh_item_list
	self.skill_info.image_skills = protocol.image_skills
end

function AdvanceSkillData:GetAllSkillInfoCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto") or {}
end

function AdvanceSkillData:GetSkillCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.skill_all_cfg then
		self.skill_all_cfg = skill_cfg.skill
	end
	return self.skill_all_cfg
end

function AdvanceSkillData:InitBookList()
	local book_list = {}
	for k,v in pairs(self:GetSkillCfg()) do
		if v ~= nil then
			book_list[v.book_id] = v.book_id
		end
	end

	return book_list
end

function AdvanceSkillData:SetCurAdvanceType(advance_type)
	self.cur_advance_type = advance_type
end

function AdvanceSkillData:GetCurAdvanceType()
	return self.cur_advance_type
end

function AdvanceSkillData:GetAdvanceSkillInfo()
	return self.skill_info
end

function AdvanceSkillData:GetOneSkillCfgBySkillId(skill_id)
	if skill_id == nil then
		return
	end

	return self:GetSkillCfg()[skill_id]
end

function AdvanceSkillData:GetSpiritOtherByStr(str)
	if str == nil then
		return
	end

	return ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1][str]
end

function AdvanceSkillData:GetSpiritSkillBookCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.skill_book_cfg then
		self.skill_book_cfg = ListToMap(skill_cfg.skill_book, "type")
	end
	return self.skill_book_cfg
end

function AdvanceSkillData:GetActivateSkillItemId()
	return self:GetSpiritOtherByStr("get_skill_item")
end

function AdvanceSkillData:SetGetSkillViewCurCellIndex(cell_index)
	self.skill_cur_cell_index = cell_index
end

function AdvanceSkillData:GetSkillViewCurCellIndex()
	return self.skill_cur_cell_index
end

function AdvanceSkillData:GetSkliiFlsuhCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.skill_flush_cfg then
		self.skill_flush_cfg = ListToMap(skill_cfg.skill_refresh, "stage")
	end
	return self.skill_flush_cfg
end

function AdvanceSkillData:GetSkliiFlsuhStageByTimes(flush_times)
	if flush_times == nil then
		return {}
	end

	for k, v in pairs(self:GetSkliiFlsuhCfg()) do
		if flush_times >= v.min_count and flush_times <= v.max_count then
			return v
		end
	end

	return {}
end

function AdvanceSkillData:GetGradeOpenCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.grade_open_cfg then
		self.grade_open_cfg = ListToMap(skill_cfg.grade_skill_num, "grade")
	end
	return self.grade_open_cfg
end

-- 技能槽开启数量
function AdvanceSkillData:GetSkillOpenNum(index)
	local open_num = 0
	local initial_num = self:GetSpiritOtherByStr("initial_skill_num") or 0
	local grade = nil
	open_num = open_num + initial_num
	local next_open_grade = 0

	if index == ADVANCE_SKILL_TYPE.MOUNT then
		local mount_info = MountData.Instance:GetMountInfo()
		grade = mount_info.grade
	elseif index == ADVANCE_SKILL_TYPE.WING then
		local wing_info = WingData.Instance:GetWingInfo()
		grade = wing_info.grade
	elseif index == ADVANCE_SKILL_TYPE.HALO then
		local halo_info = HaloData.Instance:GetHaloInfo()
		grade = halo_info.grade
	elseif index == ADVANCE_SKILL_TYPE.FAZHEN then
		local fazhen_info = FaZhenData.Instance:GetFightMountInfo()
		grade = fazhen_info.grade
	elseif index == ADVANCE_SKILL_TYPE.BEAUTY_HALO then
		local beauty_halo_info = BeautyHaloData.Instance:GetBeautyHaloInfo()
		grade = beauty_halo_info.grade
	elseif index == ADVANCE_SKILL_TYPE.HALIDOM then
		local halidom_info = HalidomData.Instance:GetHalidomInfo()
		grade = halidom_info.grade
	elseif index == ADVANCE_SKILL_TYPE.FOOT then
		local foot_info = ShengongData.Instance:GetShengongInfo()
		grade = foot_info.grade
	elseif index == ADVANCE_SKILL_TYPE.MANTLE then
		local mantle_info = ShenyiData.Instance:GetShenyiInfo()
		grade = mantle_info.grade
	end

	local cur_grade_open = 0
	if grade == nil then
		return open_num, next_open_grade
	else
		local grade_cfg = self:GetGradeOpenCfg()[grade]
		if grade_cfg ~= nil then
			open_num = open_num + grade_cfg.skill_open_num
			cur_grade_open = grade_cfg.skill_open_num
		end
	end

	if grade ~= #self:GetGradeOpenCfg() then
		for i = grade, #self:GetGradeOpenCfg() do
			if self:GetGradeOpenCfg()[i] ~= nil and self:GetGradeOpenCfg()[i].skill_open_num > cur_grade_open then
				next_open_grade = self:GetGradeOpenCfg()[i].show_grade
				break
			end
		end
	end

	return open_num, next_open_grade
end

function AdvanceSkillData:GetGradeCfgByType(index)
	local data = {}
	if index == nil then
		return data
	end

	if index == ADVANCE_SKILL_TYPE.MOUNT then
		local mount_info = MountData.Instance:GetMountInfo()
		if mount_info ~= nil and mount_info.grade ~= nil then
			local grade_cfg = MountData.Instance:GetCurMountCfg(mount_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.WING then
		local wing_info = WingData.Instance:GetWingInfo()
		if wing_info ~= nil and wing_info.grade ~= nil then
			local grade_cfg = WingData.Instance:GetWingGradeCfg(wing_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.HALO then
		local halo_info = HaloData.Instance:GetHaloInfo()
		if halo_info ~= nil and halo_info.grade ~= nil then
			local grade_cfg = HaloData.Instance:GetHaloGradeCfg(halo_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.FAZHEN then
		local fazhen_info = FaZhenData.Instance:GetFightMountInfo()
		if fazhen_info ~= nil and fazhen_info.grade ~= nil then
			local grade_cfg = FaZhenData.Instance:GetMountGradeCfg(fazhen_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.BEAUTY_HALO then
		local beauty_halo_info = BeautyHaloData.Instance:GetBeautyHaloInfo()
		if beauty_halo_info ~= nil and beauty_halo_info.grade ~= nil then
			local grade_cfg = BeautyHaloData.Instance:GetBeautyHaloGradeCfg(beauty_halo_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.HALIDOM then
		local halidom_info = HalidomData.Instance:GetHalidomInfo()
		if halidom_info ~= nil and halidom_info.grade ~= nil then
			local grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(halidom_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.FOOT then
		local foot_info = ShengongData.Instance:GetShengongInfo()
		if foot_info ~= nil and foot_info.grade ~= nil then
			local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(foot_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	elseif index == ADVANCE_SKILL_TYPE.MANTLE then
		local mantle_info = ShenyiData.Instance:GetShenyiInfo()
		if mantle_info ~= nil and mantle_info.grade ~= nil then
			local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(mantle_info.grade)
			if grade_cfg ~= nil then
				data = grade_cfg
			end
		end
	end

	return data
end

-- 获取背包里的技能书道具
function AdvanceSkillData:GetBagSkillBookItem()
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
function AdvanceSkillData:IsSkillBookItem(item_id)
	if self.book_item_id == nil or self.book_item_id[item_id] == nil then
		return false
	end

	return true
end

-- 获得精灵第一个没有技能的格子索引
-- 因为精灵的技能放在哪个位置是客户端决定，所以这边逐一往后排(用于技能仓库)
function AdvanceSkillData:GetFirstNotSkillCellIndex(image_type)
	local index = 0
	if self.skill_info.image_skills == nil or image_type == nil then
		return index
	end

	local check_data = self.skill_info.image_skills[image_type]
	if check_data ~= nil then
		for k,v in pairs(check_data) do
			if v ~= nil and v.skill_id <= 0 then
				index = k - 1
				break
			end
		end
	end

	return index
end

-- 技能背包要先判断是否已经学习了前置技能,有的话顶掉，没有的话再继续往后面插入技能
function AdvanceSkillData:GetLearnSkillCellIndex(image_type, to_learn_skill_id)
	local index = 0
	local has_pre_skill = false
	if self.skill_info == nil or self.skill_info.image_skills == nil then
		return index, has_pre_skill
	end

	if image_type == nil or to_learn_skill_id == nil then
		return index, has_pre_skill
	end

	local info_data = self.skill_info.image_skills[image_type]
	if info_data == nil then
		return index, has_pre_skill
	end

	local to_learn_skill_cfg = self:GetOneSkillCfgBySkillId(to_learn_skill_id)
	if to_learn_skill_cfg == nil then
		return index, has_pre_skill
	end

	local pre_skill_id = to_learn_skill_cfg.pre_skill
	for k,v in pairs(info_data) do
		if v.skill_id > 0 and v.skill_id == pre_skill_id then
			has_pre_skill = true
			return k - 1,  has_pre_skill
		end
	end

	return self:GetFirstNotSkillCellIndex(image_type), has_pre_skill
end

function AdvanceSkillData:GetOneSkillCfgByItemId(item_id)
	if item_id == nil then
		return {}
	end

	for k,v in pairs(self:GetSkillCfg()) do
		if v.book_id == item_id then
			return v
		end
	end

	return {}
end

-- 精灵技能界面的三个网格都用这个接口
function AdvanceSkillData:SetSpiritSkillViewCellData(cell_data)
	self.sprite_skill_cell_data = cell_data
end

function AdvanceSkillData:GetSpiritSkillViewCellData()
	return self.sprite_skill_cell_data or {}
end

-- 获取技能背包第一个空格子的索引
function AdvanceSkillData:GetStorageFirstNotSkillIndex()
	local index = 0
	if self.skill_info.skill_storage_list == nil then
		return index
	end


	for k,v in ipairs(self.skill_info.skill_storage_list) do
		if v ~= nil and v.skill_id <= 0 then
			index = k - 1
			break
		end
	end

	return index
end

function AdvanceSkillData:GetStorageFirstSkillIndex()
	local index = -1
	if self.skill_info.skill_storage_list == nil then
		return index
	end

	for k,v in ipairs(self.skill_info.skill_storage_list) do
		if v ~= nil and v.skill_id > 0 then
			index = v.index or k - 1
			break
		end
	end

	return index	
end

function AdvanceSkillData:GetSkillStorageList()
	local skill_storage_list = {}
	if self.skill_info.skill_storage_list == nil then
		return skill_storage_list
	end

	skill_storage_list = TableCopy(self.skill_info.skill_storage_list)
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

	table.sort(skill_storage_list, sort_function("skill_level", "skill_id"))
	return skill_storage_list
end

function AdvanceSkillData:GetSkillBookCfgMaxType()
	return #self:GetSpiritSkillBookCfg()
end

function AdvanceSkillData:SetPlayerRefreshCount(num)
	self.refresh_count = num
end

function AdvanceSkillData:GetFreeFlushLeftTimes()
	local left_times = 0
	if self.skill_info.skill_refresh_item_list == nil then
		return left_times
	end

	local all_free_times = self:GetSpiritOtherByStr("skill_free_refresh_count") or 0
	left_times = all_free_times - self.refresh_count
	return left_times
end

--function AdvanceSkillData:GetSkillNumLevelCfg()
	-- local cfg = self:GetSpiritLevelConfig()
	-- local skill_num_cfg = {}
	-- local old_num = cfg[1].skill_num
	-- local old_item = cfg[1].item_id
	-- for i=1,#cfg do
	-- 	if cfg[i].item_id ~= old_item then
	-- 		old_num = cfg[i].skill_num
	-- 		old_item = cfg[i].item_id
	-- 	end
	-- 	if cfg[i].skill_num > old_num then
	-- 		table.insert(skill_num_cfg,cfg[i])
	-- 		old_num = cfg[i].skill_num
	-- 	end
	-- end
	-- return skill_num_cfg
--end

-- function AdvanceSkillData:GetMaxSkillNumByID(item_id)
-- 	local max_skill_num = 0
-- 	for k,v in pairs(self.skill_num_cfg) do
-- 		if v.item_id ~= item_id and max_skill_num ~= 0 then
-- 			return max_skill_num
-- 		end
-- 		if v.item_id == item_id and v.skill_num > max_skill_num then
-- 			max_skill_num = v.skill_num
-- 		end
-- 	end
-- 	return max_skill_num
-- end

-- function AdvanceSkillData:GetSkillNumNextLevelById(item_id,skill_num)
-- 	for i,v in ipairs(self.skill_num_cfg) do
-- 		if v.item_id == item_id and v.skill_num > skill_num then
-- 			return v.level
-- 		end
-- 	end
-- 	return 0
-- end

function AdvanceSkillData:GetAdvanceSkillNumByType(image_type)
	local skill_num = 0
	if image_type == nil or self.skill_info.image_skills == nil then
		return skill_num
	end

	local data = self.skill_info.image_skills[image_type]
	if data == nil then
		return skill_num
	end

	for k,v in pairs(data) do
		if v ~= nil and v.skill_id > 0 then
			skill_num = skill_num + 1
		end
	end
	
	return skill_num
end

-- 包括基础技能槽 + 悟性带来的技能槽 + 等级带来的技能槽
function AdvanceSkillData:GetMaxSkillCellNumByIndex(sprite_index)
	local max_num = 0
	local data = self:GetGradeOpenCfg()[#self:GetGradeOpenCfg()]
	if data ~= nil then
		max_num = data.skill_open_num
	end

	local initial_num = self:GetSpiritOtherByStr("initial_skill_num") or 0
	max_num = max_num + initial_num

	return max_num
end

function AdvanceSkillData:ShowSkillRedPoint(spirit_type)
	local bool = OpenFunData.Instance:CheckIsHide("advanceskill") 
	if bool == false then return false end

	if not self:CheckIsCanOpen(spirit_type) then
		return false
	end

	local is_show = false
	if self.skill_info.skill_refresh_item_list == nil then
		return is_show
	end

	local free_refresh_left_times = self:GetFreeFlushLeftTimes()
	local activie_cell_num = 0
	for k,v in pairs(self.skill_info.skill_refresh_item_list) do
		if v ~= nil and v.is_active == 1 then
			activie_cell_num = activie_cell_num + 1
		end
	end

	local activate_item_id = self:GetActivateSkillItemId()
	local item_num = ItemData.Instance:GetItemNumInBagById(activate_item_id)
	if (free_refresh_left_times > 0 and activie_cell_num > 0) or item_num > 0 then
		is_show = true
	end
	if self:GetSkillShowRedPoint(spirit_type) ~= nil then
		if self:GetSkillShowRedPoint(spirit_type) ~= 0 then
			is_show = true
		end
	end
	if self:GetItemShowRedPoint() ~= nil then
		if self:GetItemShowRedPoint() then
			is_show = true
		end
	end
	
	return is_show
end
function AdvanceSkillData:GetItemShowRedPoint()
	local free_refresh_times = self:GetFreeFlushLeftTimes()
	local activate_item_id = self:GetActivateSkillItemId()
	local item_num = ItemData.Instance:GetItemNumInBagById(activate_item_id)
	local advance_info = self:GetAdvanceSkillInfo()
	if advance_info == nil then return true end
	local skill_refresh_item_list = advance_info.skill_refresh_item_list
	if skill_refresh_item_list == nil then return true end

	local activie_cell_num = 0
	for k,v in pairs(skill_refresh_item_list) do
		if v ~= nil and v.is_active == 1 then
			activie_cell_num = activie_cell_num + 1
		end
	end

	if (free_refresh_times > 0 and activie_cell_num > 0) or item_num > 0 then
		return true
	end

	for i = 1, #skill_refresh_item_list do
		if free_refresh_times >= 1 then
			if skill_refresh_item_list[i].is_active == 1 or item_num >= 1 then
				return true
			end
		end
	end
	return false
end

function AdvanceSkillData:GetSkillShowRedPoint(spirit_type)
	local true_num = 0
	if self:SkillLearnRedPoint(spirit_type) or self:SkillTuoYinRedPoint(spirit_type) then
		true_num = 1
	end

	return true_num
end

function AdvanceSkillData:GetSkilInfoListCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.skill_info_list then
		self.skill_info_list = ListToMap(skill_cfg.skill,"skill_id")
	end
	return self.skill_info_list
end

--通过id 获取技能类型和等级
function AdvanceSkillData:GetSkillDataInfo(id)
	if self:GetSkilInfoListCfg() == nil then return end
	local skill_data = self:GetSkilInfoListCfg()[id]
	if skill_data == nil then return end
	return skill_data.skill_type,skill_data.skill_level
end

--技能学习红点
function AdvanceSkillData:SkillLearnRedPoint(spirit_type)
	local falg = false
	local cur_sprite_index = spirit_type or self:GetCurAdvanceType()
	if cur_sprite_index == nil then
		return false
	end

	local is_show = OpenFunData.Instance:CheckIsHide(ADVANCE_TAB_ACTIVE[cur_sprite_index])
	if not is_show then
		return false
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = self:GetImageOpenCfg(cur_sprite_index)
	if cfg ~= nil and next(cfg) ~= nil then
		if level < cfg.open_level then
			return false
		end
	end	

	if self.skill_info == nil or self.skill_info.image_skills == nil then
		return false
	end

	local sprite_skills_num = self:GetAdvanceSkillNumByType(cur_sprite_index)
	local open_cell_num = self:GetSkillOpenNum(cur_sprite_index)
	local skill_num = #self:GetBagSkillBookItem()
	if open_cell_num <= 0 then
		return false
	end
	local skill_data = self.skill_info.image_skills[cur_sprite_index]

	if skill_data == nil then return false end
	local bag_skill_list = self:GetBagSkillBookItem()
	--local sameskill_num = 0
	for i=1,skill_num do
		local item_id = bag_skill_list[i].item_id
		local data = self:GetOneSkillCfgByItemId(item_id)
		local no_same_num = 0
		local check_flag = false
		local is_has_learn = false
		for j=1,#skill_data do
			local learn_type ,learn_level = self:GetSkillDataInfo(skill_data[j].skill_id)
			if learn_type ~= data.skill_type then
				no_same_num = no_same_num + 1
			else
				-- if learn_level ~= data.skill_level then
				-- 	no_same_num = no_same_num + 1
				-- end
				if learn_level < data.skill_level then
					no_same_num = no_same_num + 1
				end
			end

			if not is_has_learn and skill_data[j].skill_id <= 0 and skill_data[j].index + 1 <= open_cell_num then
				is_has_learn = true
			end

		--有技能等级为1的，可是没有学过相同的，就有红点
			if data.skill_level == 1 and no_same_num == #skill_data and not check_flag and is_has_learn then
				falg = true
				break				
			end

			--有技能等级大于1的，并且学了前置技能，就有可能可以学，不过要这个技能没学过
			if data.skill_level >= 2 and data.skill_type == learn_type and data.skill_level - 1 == learn_level then
				check_flag = true			
			end

			if no_same_num == #skill_data and check_flag then
				falg = true
				break							
			end
		end
	end
	return falg
end

--拓印红点
function AdvanceSkillData:SkillTuoYinRedPoint(spirit_type)
	local falg = false
	local cur_sprite_index = spirit_type or self:GetCurAdvanceType()
	if cur_sprite_index == nil then
		return false
	end

	local is_show = OpenFunData.Instance:CheckIsHide(ADVANCE_TAB_ACTIVE[cur_sprite_index])
	if not is_show then
		return false
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = self:GetImageOpenCfg(cur_sprite_index)
	if cfg ~= nil and next(cfg) ~= nil then
		if level < cfg.open_level then
			return false
		end
	end	

	if self.skill_info == nil or self.skill_info.image_skills == nil then
		return false
	end

	local sprite_skills_num = self:GetAdvanceSkillNumByType(cur_sprite_index)
	local open_cell_num = self:GetSkillOpenNum(cur_sprite_index)
	local skill_num = self:GetStorageFirstSkillIndex()
	local skill_data = self.skill_info.image_skills[cur_sprite_index]
	if skill_data == nil then return false end

	local is_has = false

	local skill_storage_list = self:GetSkillStorageList()
	for j=1,#self:GetSkillStorageList() do
		local skill_id = skill_storage_list[j].skill_id
		if skill_id  == 0 then
			break
		end
		if self:GetSkilInfoListCfg() == nil then return end
		local skill_level = skill_storage_list[j].skill_level
		local skill_type = self:GetSkilInfoListCfg()[skill_id].skill_type
		local check_num = 0
		for i=1, open_cell_num do
			local tayin_type ,tayin_level = self:GetSkillDataInfo(skill_data[i].skill_id)
			if skill_type ~= tayin_type then
				check_num = check_num + 1
			end

			if check_num == open_cell_num then
				is_has = true
				break
			end
		end
	end

	if open_cell_num > sprite_skills_num and skill_num >= 0 and (is_has or sprite_skills_num == 0) then
		falg = true
	end
	return falg
end

--技能学习item红点
function AdvanceSkillData:SkillItemRedPoint(data)
	if data.skill_id == nil then return false end
	local falg = false
	local cur_sprite_index = self:GetCurAdvanceType()
	if cur_sprite_index == nil then
		return false
	end
	if self.skill_info == nil or self.skill_info.image_skills == nil then
		return false
	end
	local open_cell_num = self:GetSkillOpenNum(cur_sprite_index)
	local sprite_skills_num = self:GetAdvanceSkillNumByType(cur_sprite_index)
	local bag_skill_list = self:GetBagSkillBookItem()
	local skill_type,skill_level = self:GetSkillDataInfo(data.skill_id)
	local skill_num = self:GetStorageFirstNotSkillIndex()
	local skill_info_data = self.skill_info.image_skills[cur_sprite_index]
	local sameskill_num = 0

	if self.table_index == ADVANCE_SKILL_VIEW_LEARN then
		for i=1,#bag_skill_list do
			local item_id = bag_skill_list[i].item_id
			local skill_data = self:GetOneSkillCfgByItemId(item_id)
			local no_same_num = 0
			local check_flag = false
			for j=1,#skill_info_data do
				local s_type,level = self:GetSkillDataInfo(skill_info_data[j].skill_id)
				if skill_data.skill_type ~= s_type then
					no_same_num = no_same_num + 1
				else
					-- if skill_data.skill_level ~= level then
					-- 	no_same_num = no_same_num + 1
					-- end
					if level < skill_data.skill_level then
						no_same_num = no_same_num + 1
					end
				end

				if data.skill_id == 0 then
					--有技能等级为1的，可是没有学过相同的，就有红点
					if skill_data.skill_level == 1 and no_same_num == #skill_info_data and not check_flag then
						falg = true
						break				
					end
				else
					--有技能等级大于1的，并且学了前置技能，就有可能可以学，不过要这个技能没学过
					if skill_data.skill_level >= 2 and skill_data.skill_type == skill_type and skill_data.skill_level - 1 == skill_level then
						--falg = true
						check_flag = true			
					end

					if no_same_num == #skill_info_data and check_flag then
						falg = true
						break							
					end
				end
			end
		end
		if not (data.index <= open_cell_num - 1) then
			falg = false
		end
	elseif self.table_index == ADVANCE_SKILL_VIEW_COPY then
		local skill_storage_list = self:GetSkillStorageList()
		if skill_storage_list == nil then return false end
		local skill_num = self:GetStorageFirstSkillIndex()
		local is_has = false
		for j=1, #self:GetSkillStorageList() do
			local skill_id = skill_storage_list[j].skill_id
			if skill_id  == 0 then
				break
			end
			local copy_type,copy_level = self:GetSkillDataInfo(skill_id)
			local check_num = 0
			for i=1,#skill_info_data do
				local s_type,level = self:GetSkillDataInfo(skill_info_data[i].skill_id)
				if data.skill_id <= 0 and s_type ~= copy_type then
					check_num = check_num + 1
				end
				if check_num == #skill_info_data then
					is_has = true
					break
				end
			end
		end
		if data.index <= open_cell_num - 1 and skill_num >= 0 and (is_has or sprite_skills_num == 0) then
			falg = true
		end
	end
	return falg
end

function AdvanceSkillData:SetTableIndex(index)
	self.table_index = index
end

function AdvanceSkillData:GetImageListOpenCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.image_open_cfg then
		self.image_open_cfg = ListToMap(skill_cfg.image_level, "image_type")
	end
	return self.image_open_cfg
end

function AdvanceSkillData:GetImageOpenCfg(image_type)
	local cfg = {}
	if image_type == nil then
		return cfg
	end

	if self:GetImageListOpenCfg() == nil then
		return {}
	end

	for k,v in pairs(self:GetImageListOpenCfg()) do
		if v.image_type == image_type then
			return v
		end
	end

	return cfg
end

function AdvanceSkillData:CheckIsCanOpen(spirit_type)
	local falg = true
	local cur_sprite_index = spirit_type or self:GetCurAdvanceType()
	if cur_sprite_index == nil then
		return false
	end

	local is_show = OpenFunData.Instance:CheckIsHide(ADVANCE_TAB_ACTIVE[cur_sprite_index])
	if not is_show then
		return false
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = self:GetImageOpenCfg(cur_sprite_index)
	if cfg ~= nil and next(cfg) ~= nil then
		if level < cfg.open_level then
			return false
		end
	end	

	return falg
end

function AdvanceSkillData:GetSkillAttCfg()
	local skill_cfg = self:GetAllSkillInfoCfg()
	if not self.skill_att_cfg then
		self.skill_att_cfg = ListToMap(skill_cfg.skill,"skill_type","book_id")
	end
	return self.skill_att_cfg
end

function AdvanceSkillData:SetSkillListInfo(type,item_id)
	if self:GetSkillAttCfg() == nil and self:GetSkillAttCfg()[type] == nil then return end
	local skill_att = self:GetSkillAttCfg()[type][item_id]
	if skill_att == nil then return end
	for k,v in pairs(CommonDataManager.SkillAtt) do
		if v == type then
			return skill_att[k]
		end
	end
end
