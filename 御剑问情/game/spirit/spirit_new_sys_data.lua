SpiritNewSysData = SpiritNewSysData or BaseClass()

function SpiritNewSysData:__init()
	SpiritNewSysData.Instance = self
	self.level_list = {}
	self.unfight_level_list = {}
	self.grade_list = {}
	self.aptitude_level_list = {}
	self.aptitude_grade_list = {}
end

function SpiritNewSysData:__delete()

end

function SpiritNewSysData:GetLevelCfg()
	return self.level_list
end

function SpiritNewSysData:GetUnFightLevelCfg()
	return self.unfight_level_list
end

function SpiritNewSysData:CreateUnFightLevelList(protocol)
	if next(protocol) == nil then return end
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").chengzhang_grade
	for i=0,3 do
		self.unfight_level_list[i] = {}
		local level_attr = SpiritData.Instance:GetSpiritLevelCfgByLevel(i,1)
		if protocol[i] then
			local grade = protocol[i].param and protocol[i].param.rand_attr_val_1
			self.grade_list[i] = grade
			grade = cfg[grade + 1] and grade or grade - 1
			self.unfight_level_list[i].maxhp = level_attr.maxhp * 0.5 + cfg[grade + 1].maxhp
			self.unfight_level_list[i].gongji = level_attr.gongji * 0.5 + cfg[grade + 1].gongji
			self.unfight_level_list[i].fangyu = level_attr.fangyu * 0.5 + cfg[grade + 1].fangyu
		else
			self.unfight_level_list[i].maxhp = 0
			self.unfight_level_list[i].gongji = 0
			self.unfight_level_list[i].fangyu = 0
		end
	end
end

function SpiritNewSysData:CreateLevelList(protocol)
	if next(protocol) == nil then return end
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").chengzhang_grade
	for i=0,3 do
		self.level_list[i] = {}
		local level_attr = SpiritData.Instance:GetSpiritLevelCfgByLevel(i,1)
		if protocol[i] then
			local grade = protocol[i].param and protocol[i].param.rand_attr_val_1
			--print_error(grade)
			self.grade_list[i] = grade
			grade = cfg[grade + 1] and grade or grade - 1
			self.level_list[i].maxhp = level_attr.maxhp + cfg[grade + 1].maxhp
			self.level_list[i].gongji = level_attr.gongji + cfg[grade + 1].gongji
			self.level_list[i].fangyu = level_attr.fangyu + cfg[grade + 1].fangyu
		else
			self.level_list[i].maxhp = 0
			self.level_list[i].gongji = 0
			self.level_list[i].fangyu = 0
		end
	end
end

function SpiritNewSysData:GetUseItem(cur_index)
	cur_index = cur_index or 0
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1]
	local use_item = {}
	--print_error(cfg.cz_grade_stuff_id)
	use_item.have_num = ItemData.Instance:GetItemNumInBagById(cfg.cz_grade_stuff_id)
	use_item.item_info = {item_id = cfg.cz_grade_stuff_id,num = use_item.have_num}
	--print_error(use_item.have_num)
	cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").chengzhang_grade
	local grade = 0
	if self.grade_list[cur_index] then
		grade = self.grade_list[cur_index] + 1
	end
	grade = cfg[grade] and grade or grade - 1
	use_item.need_num = cfg[grade] and cfg[grade].need_bless_val or 0
	use_item.pack_num = cfg[grade] and cfg[grade].pack_num or 0
	return use_item
end


function SpiritNewSysData:GetAptitudeLevelCfg()
	return self.aptitude_level_list
end

function SpiritNewSysData:CreateAptitudeLevelList(protocol)
	if next(protocol) == nil then return end
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").wuxing_grade
	for i=0,3 do
		self.aptitude_level_list[i] = {}
		local level_attr = SpiritData.Instance:GetSpiritLevelCfgByLevel(i,1)
		if protocol[i] then
			local grade = protocol[i].param and protocol[i].param.rand_attr_val_2
			self.aptitude_grade_list[i] = grade
			grade = cfg[grade + 1] and grade or grade - 1
			self.aptitude_level_list[i].maxhp = cfg[grade + 1].maxhp
			self.aptitude_level_list[i].gongji = cfg[grade + 1].gongji
			self.aptitude_level_list[i].fangyu = cfg[grade + 1].fangyu
		else
			self.aptitude_level_list[i].maxhp = 0
			self.aptitude_level_list[i].gongji = 0
			self.aptitude_level_list[i].fangyu = 0
		end
	end
end

function SpiritNewSysData:GetAptitudeUseItem(cur_index)
	cur_index = cur_index or 0
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1]
	local use_item = {}
	--print_error(cfg.wx_grade_stuff_id)
	use_item.have_num = ItemData.Instance:GetItemNumInBagById(cfg.wx_grade_stuff_id)
	use_item.item_info = {item_id = cfg.wx_grade_stuff_id,num = use_item.have_num}
	-- print_error(use_item.have_num)
	cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").wuxing_grade
	local grade = 0
	if self.aptitude_grade_list[cur_index] then
		grade = self.aptitude_grade_list[cur_index] + 1
	end
	grade = cfg[grade] and grade or grade - 1
	use_item.need_num = cfg[grade] and cfg[grade].need_bless_val or 0
	use_item.pack_num = cfg[grade] and cfg[grade].pack_num or 0
	return use_item
end

function SpiritNewSysData:GetMaxGrade()
	local cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").wuxing_grade
	return #cfg - 1
end

function SpiritNewSysData:GetGradeByIndex(index)
	return self.grade_list[index] or 0
end

function SpiritNewSysData:GetAptitudeGradeByIndex(index)
	return self.aptitude_grade_list[index] or 0
end