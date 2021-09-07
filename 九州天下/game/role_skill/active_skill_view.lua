ActiveSkillView = ActiveSkillView or BaseClass(BaseRender)

local PROFESSOIN_SKILL_NUM = 5 	-- 主动技能数
local SKILL_JIE = 200			-- 200级为一阶

function ActiveSkillView:__init(instance)
	self.profession_skill = {}
	self.profession_skill_data = {}
	self.tmp_info = {}
	self.first_open = true
	self.index = 1
	self.auto_level_up = false
	self.is_guide = false
	self.up_count = 0	--用于引导时的次数
	self.first_open = true
	self.skill_level_info = {}
	self.need_coin = 0
end

function ActiveSkillView:__delete()
	self.profession_skill = {}
	self.profession_skill_data = nil
	self.skill_level_info = {}
	self.tmp_info = {}

	self.skill_name = nil
	self.skill_cur_level = nil
	self.skill_max_level = nil
	self.cur_prower = nil
	self.next_power = nil
	self.cur_hurt = nil
	self.next_hurt = nil
	self.coin_cost = nil
	self.need_coin = 0
end

function ActiveSkillView:LoadCallBack(instance)
	self.profession_skill_data, _ = RoleSkillData.Instance:GetAllSkillList()
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClickAutoUpLevel", BindTool.Bind(self.OnClickAutoUpLevel, self))
	self:ListenEvent("OnClickStopAutoUpLevel", BindTool.Bind(self.OnClickStopAutoUpLevel, self))

	self.skill_name = self:FindVariable("SkillName")				--名字
	self.skill_cur_level = self:FindVariable("CurrentLevel")		--当前等级
	self.skill_max_level = self:FindVariable("MaxLevel")			--最高等级
	self.cur_prower = self:FindVariable("CurPower")					--当前战力
	self.next_power = self:FindVariable("NextPower")				--下级战力
	self.cur_hurt = self:FindVariable("CurHurt")					--当前额外伤害
	self.next_hurt = self:FindVariable("NextHurt")					--下级额外伤害
	self.coin_cost = self:FindVariable("CoinCost")					--升级消耗铜币
	self.cur_dose = self:FindVariable("CurDose")					--描述
	self.show_stop = self:FindVariable("ShowStop")					
	self.show_cost = self:FindVariable("ShowCost")					
	self.skill_name_image = self:FindVariable("SkillNameImage")
	self.auto_button = self:FindObj("AutoButton")

	for i = 1, PROFESSOIN_SKILL_NUM do
		local skill = self:FindObj("ProSkill"..i)
		local icon = skill:FindObj("Icon")
		local effect = skill:FindObj("Effect")
		local name_lable = skill:FindObj("SkillNameLable")
		local skill_name = name_lable:FindObj("Name")
		local skill_level = name_lable:FindObj("Level")
		
		table.insert(self.profession_skill, {skill = skill, icon = icon,
					 name_lable = name_lable, skill_name = skill_name, skill_level = skill_level, effect = effect})
	end

	self.active_skill_red = {}
	for i = 1, 5 do
		self.active_skill_red[i] = self:FindVariable("ShowSkillRed_" .. i)
	end
	self:AddSkillListenEvent()
	self:FlushSkillInfo()
	self:FlushSkillRed()
	self:SetSkillIcon()
end

function ActiveSkillView:SetFirstOpen()
	self.first_open = true
end

function ActiveSkillView:AddSkillListenEvent()
	for k, v in pairs(self.profession_skill) do
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickSkill, self,
		self.profession_skill_data[k].skill_icon, self.profession_skill_data[k].skill_id,
		self.profession_skill_data[k].skill_name, k, false, 0.4))
	end
end

function ActiveSkillView:OnFlush(param_list)
	self:FlushSkillInfo()
	self:FlushSkillRed()
	self:SetSkillIcon()
	if self.auto_level_up then
		self:RemoveCountDown()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			 if self.auto_level_up then
			 	self:SetNextSkillInfo()
			 end
		end, 0.2)
	end
end
function ActiveSkillView:CloseCallBack()
	for k,v in pairs(self.profession_skill) do
		v.effect:SetActive(false)
	end
end

function ActiveSkillView:FlushSkillRed()
	for i = 1, 5 do
		local flag = RoleSkillData.Instance:IsShowSkillRedPoint(i)
		self.active_skill_red[i]:SetValue(flag)
	end
end

function ActiveSkillView:FlushSkillInfo()
	local max_skill_id = 0
	if next(self.tmp_info) then
		local val = self.tmp_info[1]
		for k,v in pairs(self.tmp_info) do
			if val > v then
				val = v
				max_skill_id = k
			end
		end
	end
	if self.first_open and 0 ~= max_skill_id and self.profession_skill[max_skill_id] then
		self.profession_skill[max_skill_id].skill.toggle.isOn = true
		self.first_open = false
	else
		self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 2)
	end
end

function ActiveSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, is_passive, delay_play_skill_time)
	self.index = index
	self.temp_skill_id = skill_id
	self.is_click_skill = true
	self:GetSkillInfo(skill_id, skill_name, index)
end

function ActiveSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id]
	self.skill_name:SetValue(skill_name)
    self.skill_name_image:SetAsset(ResPath.GetRoleSkillName(skill_id))
	if skill_info == nil then
		self:SetSkillInfo(skill_cfg, index, nil, skill_info)
	else
		-- 客户端记录的技能等级，熟练度
		local proficient = SkillData.Instance:GetSkillProficiency(skill_id)
		local level = skill_info.level
		self:SetSkillInfo(skill_cfg, index, level, skill_info)
	end
end

function ActiveSkillView:SetSkillInfo(skill_cfg, index, level, skill_info, is_passive)
	if nil == skill_cfg then return end
	local extralevel = SkillData.Instance:GetSkillExperLevel() or 0
	local cur_level = (level + extralevel) or 0
	local next_level = cur_level + 1
	local is_max_level = false 
	local desc = ""
	local max_str = "MAX" --满级需要显示max
	if next_level >= #skill_cfg then
		next_level = #skill_cfg
		is_max_level = true
	end

	local desc = ""
	local cur_cfg = skill_cfg[cur_level]
	local next_cfg = skill_cfg[next_level]
	local Leveladdtext = cur_level  % SKILL_JIE
	local nextlevel = next_level % SKILL_JIE

	self.skill_cur_level:SetValue(Leveladdtext)
	self.skill_max_level:SetValue(not is_max_level and nextlevel or max_str)
	self.show_cost:SetValue(is_max_level)

	if next_cfg then
		self.cur_prower:SetValue(cur_cfg and cur_cfg.capbility or 0)
		self.cur_hurt:SetValue(cur_cfg and tonumber(cur_cfg.fix_hurt) or 0)
		self.coin_cost:SetValue(next_cfg and next_cfg.coin_cost or 0)
		self.need_coin = next_cfg and next_cfg.coin_cost or 0
		self.next_hurt:SetValue(not is_max_level and next_cfg.fix_hurt or max_str)
		self.next_power:SetValue(not is_max_level and next_cfg.capbility or max_str)

		desc = string.gsub(self.profession_skill_data[index].skill_desc, "%[.-%]" , function(str)
		local cur_desc = cur_level > 0 and skill_cfg[cur_level][string.sub(str, 2, -2)] or 0
		local next_desc = ""
		if skill_cfg[next_level] then
			if not is_max_level then
				next_desc = string.format(Language.Common.SkillNextText, (skill_cfg[next_level][string.sub(str, 2, -2)] or 0))
			else
				next_desc = string.format(Language.Common.SkillNextText, Language.Common.YiManJi)
			end
		end
			return cur_desc .. next_desc
		end)
		self.cur_dose:SetValue(desc)
	end
	if self.skill_level_info[index] then
		if self.skill_level_info[index] ~= skill_info.level then
			self.profession_skill[index].effect:SetActive(false)
			self.profession_skill[index].effect:SetActive(true)
			self.skill_level_info[index] = skill_info.level
		end
	else
		self.skill_level_info[index] = skill_info.level
	end
end

function ActiveSkillView:SetSkillIcon()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 主动技能
	for k, v in pairs(self.profession_skill) do
		local info = SkillData.Instance:GetSkillInfoById(self.profession_skill_data[k].skill_id)
		self.tmp_info[k] = 0
		if info == nil then
			-- v.icon.grayscale.GrayScale = 255
			v.skill_level.text.text = string.format(Language.Role.SkillLevel, 0)
		else
			-- v.icon.grayscale.GrayScale = 0
			 --等级数
			local c_level = info.level < 2000 and string.format(Language.Role.SkillLevel,info.level%SKILL_JIE) or ""
			--重数
			local num_level = info.level >= SKILL_JIE and string.format(Language.Role.SkillChong, math.floor(info.level/SKILL_JIE)) or ""
			local text_level = info.level < 2000 and info.level >= SKILL_JIE and num_level.."-"..c_level or c_level..num_level
			local active_skill_add = SkillData.Instance:GetSkillExperLevel()

			v.skill_level.text.text = text_level .. string.format(Language.Role.SkilladdLevel,active_skill_add)
		end
		v.skill_name.text.text = self.profession_skill_data[k].skill_name
		local bundle, asset = ResPath.GetRoleSkillIcon(self.profession_skill_data[k].skill_icon)
		v.icon.image:LoadSprite(bundle, asset)
		self.tmp_info[k] = info.level
	end
end

function ActiveSkillView:OnClickUpLevel()
	SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id or 0)
end

function ActiveSkillView:SetNextSkillInfo()
	local skill_info, index = RoleSkillData.Instance:GetCurUpLevelSkillId(self.temp_skill_id)
	if skill_info ~= nil or index ~= nil then
		self.temp_skill_id = skill_info.skill_id
		self.index = index
		if self.profession_skill[index] and self.profession_skill[index].skill then
			self.profession_skill[index].skill.toggle.isOn = true
		end
		self:FlushSkillInfo()
		self:FlushSkillRed()
		self:SetSkillIcon()
	end
	self:OnClickAutoUpLevel()
end
function ActiveSkillView:OnClickAutoUpLevel()
	local first_flag = self.auto_level_up
	self.auto_level_up = true
	self.show_stop:SetValue(true)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..self.temp_skill_id]
	local skill_info = SkillData.Instance:GetSkillInfoById(self.temp_skill_id)
	local level = skill_info and skill_info.level + 1 or 1

	if level > #skill_cfg or nil == skill_cfg[level] then
		self:StopLevelUp()
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.MaxValue)
		return
	end
	local item_id = skill_cfg[level].item_cost_id

	if skill_cfg[level].coin_cost > PlayerData.Instance.role_vo.coin then
		if not first_flag then
			TipsCtrl.Instance:ShowItemGetWayView(65536)
		end

		self:StopLevelUp()
		return
	end

	if self.is_guide then			-- 引导直接控制升级次数
		self.up_count = self.up_count + 1
		if self.up_count > PROFESSOIN_SKILL_NUM then
			self:StopLevelUp()
			return
		end
	end

	SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id, nil, 1)
end

function ActiveSkillView:OnClickStopAutoUpLevel()
	self:StopLevelUp()
end

function ActiveSkillView:StopLevelUp()
	self.auto_level_up = false
	self.show_stop:SetValue(false)
	self.is_guide = false
end

function ActiveSkillView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ActiveSkillView:GetAutoButton()
	self.is_guide = true
	return self.auto_button, BindTool.Bind(self.OnClickAutoUpLevel, self)
end