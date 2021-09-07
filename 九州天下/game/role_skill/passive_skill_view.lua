PassiveSkillView = PassiveSkillView or BaseClass(BaseRender)

local PASSIVE_SKILL_NUM = 9 	-- 被动技能数
function PassiveSkillView:__init(instance)
	self.passive_index = 7
	self.temp_skill_id = 0
	self.passive_skill = {}								-- 被动技能
	self.passive_skill_data = {}
	_, self.passive_skill_data = RoleSkillData.Instance:GetAllSkillList()

	self.index = 1
	self.auto_up_grade = false
	self.skill_level_info = {}
end

function PassiveSkillView:__delete()
	if self.item_cell1 then
		self.item_cell1:DeleteMe()
		self.item_cell1 = nil
	end
	if self.item_cell2 then
		self.item_cell2:DeleteMe()
		self.item_cell2 = nil
	end
	self.passive_skill = {}
	self.passive_skill_data = {}
	self.skill_level_info = {}
	self.index = 1
	self.auto_level_up = false

	self.skill_cur_level = nil
	self.skill_name = nil
	self.current_effect = nil
	self.material_name = nil
	self.up_need_material_num = nil
	self.up_have_material_num = nil
	self.current_fightpower = nil
	self.skill_max_level = nil
	self.level_need = nil
	self.upgrade_button = nil
	self.coin_cost = nil
	self.select_icon = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function PassiveSkillView:LoadCallBack(instance)
	self:ListenEvent("OnClickUpgradeButton", BindTool.Bind(self.OnClickUpgradeButton, self))
	self:ListenEvent("StopLevelUp", BindTool.Bind(self.StopLevelUp, self))

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	self.skill_cur_level = self:FindVariable("CurrentLevel")
	self.skill_name = self:FindVariable("SkillName")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextrentEffect")
	self.show_next_effect = self:FindVariable("ShowNextEffect")
	self.material_name = self:FindVariable("MaterialName")
	self.up_need_material_num = self:FindVariable("NeedMaterialNum")
	self.up_have_material_num = self:FindVariable("HaveMaterialNum")
	self.current_fightpower = self:FindVariable("CurrentFightPower")
	self.next_fightpower = self:FindVariable("NextFightPower")
	self.skill_max_level = self:FindVariable("MaxLevel")
	self.level_need = self:FindVariable("RoleLeveNeed")
	self.upgrade_button = self:FindVariable("ShowUpgradeButton")
	self.coin_cost = self:FindVariable("CoinCost")
	self.cur_coin_cost = self:FindVariable("CurCoinCost")
	self.select_icon = self:FindVariable("SelectIcon")

	for i = 1, PASSIVE_SKILL_NUM do
		local skill = self:FindObj("PassiveSkill"..i)
		local name_lable = skill:FindObj("SkillNameLable")
		local skill_name = name_lable:FindObj("Name")
		local skill_level = name_lable:FindObj("Level")
		local icon = skill:FindObj("Icon")
		local arrow = skill:FindObj("Arrow")
		local effect = skill:FindObj("Effect")
		local animator = arrow.animator
		table.insert(self.passive_skill, {skill = skill, icon = icon, arrow = arrow, skill_name = skill_name, skill_level = skill_level, animator = animator, effect = effect})
	end

	self.item_cell1 = ItemCell.New()
	self.item_cell1:SetInstanceParent(self:FindObj("ItemCell1"))
	self.item_cell2 = ItemCell.New()
	self.item_cell2:SetInstanceParent(self:FindObj("ItemCell2"))
	self:AddSkillListenEvent()
	self:SetSkillIcon()
end

function PassiveSkillView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "coin" and self:IsOpen() then
		self:Flush()
	end
end

function PassiveSkillView:AddSkillListenEvent()
	for k, v in pairs(self.passive_skill) do
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickSkill, self,
			self.passive_skill_data[k].skill_icon, self.passive_skill_data[k].skill_id,
			self.passive_skill_data[k].skill_name, k, true, 0.4))
	end
	self:FlushSkillInfo()
end

function PassiveSkillView:FlushSkillInfo()
	self:GetSkillInfo(self.passive_skill_data[self.index].skill_id, self.passive_skill_data[self.index].skill_name, self.index)
end

function PassiveSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id]
	
	local level = skill_info and skill_info.level or 0
	self.skill_name:SetValue(skill_name)
	self.temp_skill_id = skill_id
	self:SetSkillInfo(skill_cfg, index, level, skill_info)
end


function PassiveSkillView:SetSkillInfo(skill_cfg, index, level, skill_info, is_passive)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_level = level or 0
	local next_level = cur_level + 1
	local desc = ""
	local next_desc = ""
	if next_level >= #skill_cfg then
		next_level = #skill_cfg
	end
	self.skill_cur_level:SetValue(cur_level)

	local skill_data = nil
	local skill_id = nil
	if skill_cfg[cur_level] ~= nil then
		skill_id = skill_cfg[cur_level].skill_id
	elseif skill_cfg[next_level] ~= nil then
		skill_id = skill_cfg[next_level].skill_id
	end

	if skill_id then
		for k,v in pairs(self.passive_skill_data) do
			if v.skill_id == skill_id then
				skill_data = v
				break
			end
		end
	end


	if cur_level < #skill_cfg then
		local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg[next_level].item_cost_id)
		local count = ItemData.Instance:GetItemNumInBagById(skill_cfg[next_level].item_cost_id)

		self.level_need:SetValue(skill_cfg[next_level].learn_level_limit)
		self.up_need_material_num:SetValue(skill_cfg[next_level].item_cost)
		self.up_have_material_num:SetValue(string.format( count < skill_cfg[next_level].item_cost and Language.Mount.ShowRedNum or Language.Mount.ShowGrayGreenStr, count))
		
		self.item_cell1:SetData({item_id = skill_cfg[next_level].item_cost_id})
		self.item_cell2:SetData({item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN})
		self.coin_cost:SetValue(string.format(skill_cfg[next_level].coin_cost > PlayerData.Instance.role_vo.coin and Language.Mount.ShowRedNum or "<color=#ffffff>%s</color>", CommonDataManager.ConverMoney(skill_cfg[next_level].coin_cost)))
		self.material_name:SetValue(item_cfg.name)
	else
		self.level_need:SetValue("-/-")
		self.up_need_material_num:SetValue(0)
		self.coin_cost:SetValue(0)
	end

	local cap_now = 0
	local cap_next = 0
	if skill_cfg[next_level] then
		-- 战斗力
		local attr = CommonStruct.Attribute()
		local next_attr = CommonStruct.Attribute()
		for k, v in pairs(Language.Common.PassvieSkillList) do
			if skill_cfg[cur_level] and skill_cfg[cur_level].skill_name == v then
				if skill_data and skill_data.show_cap >= 1 then
					cap_now = cap_now + skill_cfg[cur_level].capbility
				else
					attr[k] = skill_cfg[cur_level].param_a
				end
			end

			if skill_cfg[next_level].skill_name == v then
				if skill_data and skill_data.show_cap >= 1 then
					cap_next = cap_next + skill_cfg[next_level].capbility
				else
					next_attr[k] = skill_cfg[next_level].param_a
				end
			end
		end
		local next_capability = CommonDataManager.GetCapabilityCalculation(next_attr)
		local capability = CommonDataManager.GetCapabilityCalculation(attr)

		capability = capability + cap_now
		next_capability = next_capability + cap_next
		self.current_fightpower:SetValue(capability)
		self.next_fightpower:SetValue(next_capability - capability)
	end

	desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
		local value = 0
		if cur_level > 0 then
			local begin = string.find(str, "param_b")
			value = skill_cfg[cur_level][string.sub(str, 2, -2)]
			if skill_data and skill_data.show_cap == 2 and value and begin ~= nil then
				value = value / 1000
			end
		end

		local cur_desc = cur_level > 0 and value or 0
		return cur_desc 
	end)

	if skill_cfg[next_level] then
		next_desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
			local begin = string.find(str, "param_b")
			local value = 0
			if next_level > 0 then
				value = skill_cfg[next_level][string.sub(str, 2, -2)]
				if skill_data and skill_data.show_cap == 2 and value and begin ~= nil then
					value = value / 1000
				end
			end

			local next_desc = next_level > 0 and value or 0
			return next_desc 
		end)
	end
	self.current_effect:SetValue(desc)
	self.next_effect:SetValue(next_desc)
	self.show_next_effect:SetValue(cur_level >= #skill_cfg)
	local bundle, asset = ResPath.GetRoleSkillIcon(self.passive_skill_data[index].skill_icon)
	self.select_icon:SetAsset(bundle, asset)

	if self.skill_level_info[index] then
		if self.skill_level_info[index] ~= cur_level then
			self.passive_skill[index].effect:SetActive(false)
			self.passive_skill[index].effect:SetActive(true)
			self.skill_level_info[index] = cur_level
		end
	else
		self.skill_level_info[index] = cur_level
	end
end

function PassiveSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, is_passive, delay_play_skill_time)
	self.upgrade_button:SetValue(true)

	self.index = index
	self.temp_skill_id = skill_id
	self.is_click_skill = true

	self:GetSkillInfo(skill_id, skill_name, index)
end

function PassiveSkillView:CloseCallBack()
	for k,v in pairs(self.passive_skill) do
		v.effect:SetActive(false)
	end
end


function PassiveSkillView:OnFlush(param_list)
	self:FlushSkillInfo()
	self:SetSkillIcon()
end

function PassiveSkillView:OnClickUpgradeButton()
	SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id)
end

function PassiveSkillView:StopLevelUp()
	self.auto_level_up = false
	if self.show_stop then
		self.show_stop:SetValue(false)
	end
end

function PassiveSkillView:SetSkillIcon()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = 0
	-- 被动技能
	for k, v in pairs(self.passive_skill) do
		local passive_info = SkillData.Instance:GetSkillInfoById(self.passive_skill_data[k].skill_id)
		local skill_info = SkillData.Instance:GetSkillInfoById(self.passive_skill_data[k].skill_id)
		if passive_info then
			v.icon.grayscale.GrayScale = 0
			level = passive_info.level
		else
			level = 0
			-- v.icon.grayscale.GrayScale = 255
		end
		local bundle, asset = ResPath.GetRoleSkillIcon(self.passive_skill_data[k].skill_icon)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill_name.text.text = self.passive_skill_data[k].skill_name
		v.skill_level.text.text = "Lv" .. (skill_info and skill_info.level or 0)

		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s".. self.passive_skill_data[k].skill_id]
		if skill_cfg then
			if level < #skill_cfg then
				local count = ItemData.Instance:GetItemNumInBagById(skill_cfg[level + 1].item_cost_id)
				if count < skill_cfg[level + 1].item_cost or not PlayerData.GetIsEnoughAllCoin(skill_cfg[level + 1].coin_cost) then
					v.arrow:SetActive(false)
				else
					v.arrow:SetActive(true)
				end
			else
				v.arrow:SetActive(false)
			end
		end
	end
end