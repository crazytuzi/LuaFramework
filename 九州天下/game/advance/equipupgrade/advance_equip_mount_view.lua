AdvanceEquipMountView = AdvanceEquipMountView or BaseClass(BaseRender)

function AdvanceEquipMountView:__init(instance)
	self.fight_power = self:FindVariable("FightPower")
	self.info_level = self:FindVariable("Level")
	self.quality_name = self:FindVariable("QualityNmae")
	self.quality_color = self:FindVariable("QualityColor")
	self.special_prof = self:FindVariable("SpecialProf")
	self.special_prof_name = self:FindVariable("SpecialProfName")
	self.exp_radio = self:FindVariable("Explain")
	self.current_level = self:FindVariable("CurrentLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.equip_name = self:FindVariable("EquipName")
	self.show_speical_pro = self:FindVariable("IsSpecialProf")
	self.keep_exp = self:FindVariable("KeepExp")
	self.had_limit = self:FindVariable("HadLimit")
	self.no_limit = self:FindVariable("NoLimit")

	self.base_pro_list = {}
	self.random_pro_list = {}
	self.show_random_pro_list = {}
	self.show_base_pro_list = {}
	for i = 1, 3 do
		local base_pro = self:FindVariable("BasePro"..i)
		local base_pro_name = self:FindVariable("BaseProName"..i)
		local random_pro = self:FindVariable("RandomPro"..i)
		local random_pro_name = self:FindVariable("RandomProName"..i)
		local show_base_pro = self:FindVariable("IsBasePro"..i)
		local show_random_pro = self:FindVariable("IsRandom"..i)
		self.show_random_pro_list[i] = show_random_pro
		self.show_base_pro_list[i] = show_base_pro
		self.random_pro_list[i] = {random_pro = random_pro, random_pro_name = random_pro_name}
		self.base_pro_list[i] = {base_pro = base_pro, base_pro_name = base_pro_name}
	end

	self:ListenEvent("HandUpGrade",
		BindTool.Bind(self.OnHandUpGrade, self))	-- 提升等级按钮
	self:ListenEvent("Automatic",
		BindTool.Bind(self.OnAutomatic, self))		-- 自动提升按钮

	self.only_bind = self:FindObj("OnlyBind")
	self.only_equip = self:FindObj("OnlyEquip")

	self.item_id_list = {}
	self:GetItemCells()

	self.cur_index = 0

	self.view_change = GlobalEventSystem:Bind(AdvanceEquipupType.MOUT_EQUIPUP_CHANGE, BindTool.Bind1(self.OnFlush, self))
end

function AdvanceEquipMountView:__delete()
	self.cells = nil
	self.cur_index = nil
	self.show_base_pro_list = nil
	self.show_random_pro_list = nil
	self.item_id_list = nil

	if self.view_change ~= nil then
		GlobalEventSystem:UnBind(self.view_change)
		self.view_change = nil
	end
end

function AdvanceEquipMountView:OnHandUpGrade(is_only_one_level)
	local mount_grade = MountData.Instance:GetMountInfo().grade
	if (mount_grade == 0) or nil then
		return
	end

	local is_only_bind = 0
	if self.only_bind.toggle.isOn then is_only_bind = 1 end

	local is_only_equip = 0
	if self.only_equip.toggle.isOn then is_only_equip = 1 end

	local can_up_list = AdvanceData.Instance:GetMountCanUplevel()
	if can_up_list[self.cur_index + 1] then
		local bind_list = AdvanceData.Instance:GetMountCanUplevel(is_only_bind == 1, is_only_equip == 1)
		if nil == bind_list[self.cur_index + 1] and 1 == is_only_bind and 0 == is_only_equip then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.NoBind)
			return
		end

		if nil == bind_list[self.cur_index + 1] and 1 == is_only_bind and 1 == is_only_equip then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.NoBindEquip)
			return
		end
	end

	is_only_one_level = is_only_one_level or 1
	AdvanceEquipUpCtrl.Instance:SendMountEquipUpLevelReq(self.cur_index, is_only_one_level, is_only_bind, is_only_equip)
end

function AdvanceEquipMountView:OnAutomatic()
	-- for i = 0, 3 do
	self:OnHandUpGrade(0)
	-- end
end

function AdvanceEquipMountView:OnStorageExp()
	print("点击存储按钮")
end

function AdvanceEquipMountView:OnClickItem(index)
	self.cur_index = index
	self:SetItemData(self.cur_index, true)
end

function AdvanceEquipMountView:GetItemCells()
	local mount_equip_list = MountData.Instance:GetMountInfo().equip_info_list
	local item_cfg = nil
	local data = {}
	self.cells = {ItemCell.New(self:FindObj("Item1")),
		ItemCell.New(self:FindObj("Item2")),
		ItemCell.New(self:FindObj("Item3")),
		ItemCell.New(self:FindObj("Item4")),
	}

	for k, v in pairs(self.cells) do
		data.item_id = mount_equip_list[k - 1].equip_id
		self.item_id_list[k -1] = data.item_id
		v:ListenClick(BindTool.Bind(self.OnClickItem, self, k - 1))
		v:SetData(data)
	end
	self.current_item = ItemCell.New(self:FindObj("CurrentItem"))
end

function AdvanceEquipMountView:SetItemData(index, is_click)
	self.cells[index + 1]:SetHighLight(true)
	local mount_equip_list = MountData.Instance:GetMountInfo().equip_info_list
	local mount_equip_cfg = MountData.Instance:GetMountEquipCfg()
	local attr_list = mount_equip_list[index].attr_list
	--local range_attr = MountData.Instance:GetMountEquipRandAttr()
	local item_cfg = ItemData.Instance:GetItemConfig(mount_equip_list[index].equip_id)
	local attr = CommonStruct.Attribute()
	local mount_grade = MountData.Instance:GetMountInfo().grade
	if mount_grade > 0 then
		local equip_level_limit = MountData.Instance:GetSpecialImageAttrSum().equip_limit
		if mount_equip_list[index].level >= equip_level_limit then
			self.keep_exp:SetValue(mount_equip_list[index].exp)
		else
			self.keep_exp:SetValue(0)
		end
		self.had_limit:SetValue(mount_equip_list[index].level >= equip_level_limit)
		self.no_limit:SetValue(mount_equip_list[index].level < equip_level_limit)
	end

	self.info_level:SetValue(mount_equip_list[index].level)
	self.current_level:SetValue(mount_equip_list[index].level)
	self.next_level:SetValue(mount_equip_list[index].level + 1)

	for k, v in pairs(self.cells) do
		local item_cfg1 = ItemData.Instance:GetItemConfig(mount_equip_list[k - 1].equip_id)
		local data = {}
		if item_cfg1 then
			data.item_id = mount_equip_list[k - 1].equip_id
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
		else
			data.item_id = MountDataEquipId[k]
			v:SetIconGrayScale(true)
			v:ShowQuality(false)
		end
		if self.uplevel_list[k] then
			data.is_show_up_level = true
			if mount_equip_list[k - 1].level <= 0 then
				data.can_equip = Language.Mount.CanEquipText
			end
		else
			data.is_show_up_level = false
		end
		self.item_id_list[k -1] = data.item_id
		v:SetData(data)
	end
	local cur_data = {}
	cur_data.item_id = self.item_id_list[index]

	if item_cfg ~= nil then
		self.quality_color:SetValue(Language.Common.QualityRGBColor[item_cfg.color])
		self.quality_name:SetValue(Language.Common.ColorName[item_cfg.color])
		self.current_item:SetIconGrayScale(false)
	else
		self.quality_name:SetValue("")
		self.current_item:SetIconGrayScale(true)
	end
	self.current_item:SetData(cur_data)
	self.current_item:ShowQuality(item_cfg ~= nil)

	for k, v in pairs(mount_equip_cfg) do
		if v.equip_idx == index  then
			if  index == 0 then
				self.show_speical_pro:SetValue(false)
				for i, j in pairs(self.show_base_pro_list) do
					self.show_random_pro_list[i]:SetValue(mount_equip_list[index].level > 0)
					j:SetValue(mount_equip_list[index].level > 0)
				end
				if item_cfg ~= nil then
					self.base_pro_list[1].base_pro:SetValue(v.gongji * mount_equip_list[index].level * item_cfg.color)
					self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
					self.base_pro_list[2].base_pro:SetValue(v.fangyu * mount_equip_list[index].level * item_cfg.color)
					self.base_pro_list[2].base_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
					self.base_pro_list[3].base_pro:SetValue(v.maxhp * mount_equip_list[index].level * item_cfg.color)
					self.base_pro_list[3].base_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
					self.random_pro_list[1].random_pro:SetValue(attr_list[0])
					self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
					self.random_pro_list[2].random_pro:SetValue(attr_list[1])
					self.random_pro_list[2].random_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
					self.random_pro_list[3].random_pro:SetValue(attr_list[2])
					self.random_pro_list[3].random_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
					attr.gong_ji = v.gongji * mount_equip_list[index].level * item_cfg.color + attr_list[0]
					attr.fang_yu = v.fangyu * mount_equip_list[index].level * item_cfg.color + attr_list[1]
					attr.max_hp = v.maxhp * mount_equip_list[index].level * item_cfg.color + attr_list[2]
				end
			else
				self.show_speical_pro:SetValue(mount_equip_list[index].level > 0)
				for i, j in pairs(self.show_base_pro_list) do
					if i == 1 then
						j:SetValue(mount_equip_list[index].level > 0)
						self.show_random_pro_list[i]:SetValue(mount_equip_list[index].level > 0)
					else
						self.show_random_pro_list[i]:SetValue(false)
						j:SetValue(false)
					end
				end
				if item_cfg ~= nil then
					if index == 1 then
						self.base_pro_list[1].base_pro:SetValue(v.gongji * mount_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_pofang)
						attr.gong_ji = v.gongji * mount_equip_list[index].level * item_cfg.color + attr_list[0]
					elseif index == 2 then
						self.base_pro_list[1].base_pro:SetValue(v.fangyu * mount_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_mianshang)
						attr.fang_yu = v.fangyu * mount_equip_list[index].level * item_cfg.color + attr_list[0]
					else
						self.base_pro_list[1].base_pro:SetValue(v.maxhp * mount_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_mianshang)
						attr.max_hp = v.maxhp * mount_equip_list[index].level * item_cfg.color + attr_list[0]
					end
				end
			end
			if mount_equip_list[index].level > 0 then
				local capability = CommonDataManager.GetCapability(attr)
				self.fight_power:SetValue(capability)
				local uplevel_exp = math.ceil(0.5 * (mount_equip_list[index].level) + 2 + (mount_equip_list[index].level)^3 * GameEnum.EQUIP_UPGRADE_PERCENT) * 10
				if is_click then
					self.exp_radio:InitValue(mount_equip_list[index].exp / uplevel_exp)
				else
					self.exp_radio:SetValue(mount_equip_list[index].exp / uplevel_exp)
				end
			else
				self.exp_radio:InitValue(0)
				self.fight_power:SetValue(0)
			end
		end
	end
end

function AdvanceEquipMountView:OnFlush(param_t)
	if param_t ~= nil then
		self.cur_index = (param_t.index and param_t.index <= 3) and param_t.index or self.cur_index
		self.uplevel_list = param_t.list
	end

	if self.cur_index ~= nil then
		self:SetItemData(self.cur_index, true)
	end
end