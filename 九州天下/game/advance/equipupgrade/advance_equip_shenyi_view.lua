AdvanceEquipShenyiView = AdvanceEquipShenyiView or BaseClass(BaseRender)

function AdvanceEquipShenyiView:__init(instance)
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

	self.view_change = GlobalEventSystem:Bind(AdvanceEquipupType.SHENYI_EQUIPUP_CHANGE, BindTool.Bind1(self.OnFlush, self))
end

function AdvanceEquipShenyiView:__delete()
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

function AdvanceEquipShenyiView:OnHandUpGrade(is_only_one_level)
	local shenyi_grade = ShenyiData.Instance:GetShenyiInfo().grade

	if (shenyi_grade == 0) or nil then
		return
	end

	local is_only_bind = 0
	if self.only_bind.toggle.isOn then is_only_bind = 1 end

	local is_only_equip = 0
	if self.only_equip.toggle.isOn then is_only_equip = 1 end

	local can_up_list = AdvanceData.Instance:GetShenyiCanUplevel()
	if can_up_list[self.cur_index + 1] then
		local bind_list = AdvanceData.Instance:GetShenyiCanUplevel(is_only_bind == 1, is_only_equip == 1)
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
	AdvanceEquipUpCtrl.Instance:SendShenyiEquipUpLevelReq(self.cur_index, is_only_one_level, is_only_bind, is_only_equip)
	print("点击提升等级按钮")
end

function AdvanceEquipShenyiView:OnAutomatic()
	-- for i = 0, 3 do
	self:OnHandUpGrade(0)
	-- end
end

function AdvanceEquipShenyiView:OnStorageExp()
	print("点击存储按钮")
end

function AdvanceEquipShenyiView:OnClickItem(index)
	self.cur_index = index
	self:SetItemData(self.cur_index, true)
end

function AdvanceEquipShenyiView:GetItemCells()
	local shenyi_equip_list = ShenyiData.Instance:GetShenyiInfo().equip_info_list
	local item_cfg = nil
	local data = {}
	self.cells = {ItemCell.New(self:FindObj("Item1")),
		ItemCell.New(self:FindObj("Item2")),
		ItemCell.New(self:FindObj("Item3")),
		ItemCell.New(self:FindObj("Item4")),
	}

	for k, v in pairs(self.cells) do
		data.item_id = shenyi_equip_list[k - 1].equip_id
		self.item_id_list[k -1] = data.item_id
		v:ListenClick(BindTool.Bind(self.OnClickItem, self, k - 1))
		v:SetData(data)
	end
	self.current_item = ItemCell.New(self:FindObj("CurrentItem"))
end

function AdvanceEquipShenyiView:SetItemData(index, is_click)
	self.cells[index + 1]:SetHighLight(true)
	local shenyi_equip_list = ShenyiData.Instance:GetShenyiInfo().equip_info_list
	local shenyi_equip_cfg = ShenyiData.Instance:GetShenyiEquipCfg()
	local attr_list = shenyi_equip_list[index].attr_list

	local range_attr = ShenyiData.Instance:GetShenyiEquipRandAttr()
	local item_cfg = ItemData.Instance:GetItemConfig(shenyi_equip_list[index].equip_id)
	local attr = CommonStruct.Attribute()
	local shenyi_grade = ShenyiData.Instance:GetShenyiInfo().grade
	local equip_level_limit = ShenyiData.Instance:GetSpecialImageAttrSum().equip_limit
	if shenyi_grade > 0 then
		if shenyi_equip_list[index].level >= equip_level_limit then
			self.keep_exp:SetValue(shenyi_equip_list[index].exp)
		else
			self.keep_exp:SetValue(0)
		end
		self.had_limit:SetValue(shenyi_equip_list[index].level >= equip_level_limit)
		self.no_limit:SetValue(shenyi_equip_list[index].level < equip_level_limit)
	end

	self.info_level:SetValue(shenyi_equip_list[index].level)
	self.current_level:SetValue(shenyi_equip_list[index].level)
	self.next_level:SetValue(shenyi_equip_list[index].level + 1)

	for k, v in pairs(self.cells) do
		local data = {}
		local item_cfg1 = ItemData.Instance:GetItemConfig(shenyi_equip_list[k - 1].equip_id)
		if item_cfg1 then
			data.item_id = shenyi_equip_list[k - 1].equip_id
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
		else
			data.item_id = ShenyiDataEquipId[k]
			v:SetIconGrayScale(true)
			v:ShowQuality(false)
		end
		if self.uplevel_list[k] then
			data.is_show_up_level = true
			if shenyi_equip_list[k - 1].level <= 0 then
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

	for k, v in pairs(shenyi_equip_cfg) do
		if v.equip_idx == index  then
			if  index == 0 then
				self.show_speical_pro:SetValue(false)
				for i, j in pairs(self.show_base_pro_list) do
					self.show_random_pro_list[i]:SetValue(shenyi_equip_list[index].level > 0)
					j:SetValue(shenyi_equip_list[index].level > 0)
				end
				if item_cfg ~= nil then
					self.base_pro_list[1].base_pro:SetValue(v.gongji * shenyi_equip_list[index].level * item_cfg.color)
					self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
					self.base_pro_list[2].base_pro:SetValue(v.fangyu * shenyi_equip_list[index].level * item_cfg.color)
					self.base_pro_list[2].base_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
					self.base_pro_list[3].base_pro:SetValue(v.maxhp * shenyi_equip_list[index].level * item_cfg.color)
					self.base_pro_list[3].base_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
					self.random_pro_list[1].random_pro:SetValue(attr_list[0])
					self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
					self.random_pro_list[2].random_pro:SetValue(attr_list[1])
					self.random_pro_list[2].random_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
					self.random_pro_list[3].random_pro:SetValue(attr_list[2])
					self.random_pro_list[3].random_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
					attr.gong_ji = v.gongji * shenyi_equip_list[index].level * item_cfg.color + attr_list[0]
					attr.fang_yu = v.fangyu * shenyi_equip_list[index].level * item_cfg.color + attr_list[1]
					attr.max_hp = v.maxhp * shenyi_equip_list[index].level * item_cfg.color + attr_list[2]
				end
			else
				self.show_speical_pro:SetValue(shenyi_equip_list[index].level > 0)
				for i, j in pairs(self.show_base_pro_list) do
					if i == 1 then
						j:SetValue(shenyi_equip_list[index].level > 0)
						self.show_random_pro_list[i]:SetValue(shenyi_equip_list[index].level > 0)
					else
						self.show_random_pro_list[i]:SetValue(false)
						j:SetValue(false)
					end
				end
				if item_cfg ~= nil then
					if index == 1 then
						self.base_pro_list[1].base_pro:SetValue(v.gongji * shenyi_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.gongji)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_pofang)
						attr.gong_ji = v.gongji * shenyi_equip_list[index].level * item_cfg.color + attr_list[0]
					elseif index == 2 then
						self.base_pro_list[1].base_pro:SetValue(v.fangyu * shenyi_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.fangyu)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_mianshang)
						attr.fang_yu = v.fangyu * shenyi_equip_list[index].level * item_cfg.color + attr_list[0]
					else
						self.base_pro_list[1].base_pro:SetValue(v.maxhp * shenyi_equip_list[index].level * item_cfg.color)
						self.base_pro_list[1].base_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
						self.random_pro_list[1].random_pro:SetValue(attr_list[0])
						self.random_pro_list[1].random_pro_name:SetValue(Language.Common.MountEquipAttr.maxhp)
						self.special_prof:SetValue(attr_list[1])
						self.special_prof_name:SetValue(Language.Common.MountEquipAttr.per_mianshang)
						attr.max_hp = v.maxhp * shenyi_equip_list[index].level * item_cfg.color + attr_list[0]
					end
				end
			end
			if shenyi_equip_list[index].level > 0 then
				local capability = CommonDataManager.GetCapability(attr)
				self.fight_power:SetValue(capability)
				local uplevel_exp = math.ceil(0.5 * (shenyi_equip_list[index].level) + 2 + (shenyi_equip_list[index].level)^3 * GameEnum.EQUIP_UPGRADE_PERCENT) * 10
				if is_click then
					self.exp_radio:InitValue(shenyi_equip_list[index].exp / uplevel_exp)
				else
					self.exp_radio:SetValue(shenyi_equip_list[index].exp / uplevel_exp)
				end
			else
				self.exp_radio:InitValue(0)
				self.fight_power:SetValue(0)
			end
		end
	end
end

function AdvanceEquipShenyiView:OnFlush(param_t)
	if param_t ~= nil then
		self.cur_index = (param_t.index and param_t.index <= 3) and param_t.index or self.cur_index
		self.uplevel_list = param_t.list
	end

	if self.cur_index ~= nil then
		self:SetItemData(self.cur_index, true)
	end
end