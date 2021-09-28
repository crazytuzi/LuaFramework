GuildAltarView = GuildAltarView or BaseClass(BaseRender)

local SkillEnum = {
		"gongji",
		"maxhp",
		"fangyu",
		"mingzhong",
		"shanbi",
		"baoji",
		"jianren"
	}

function GuildAltarView:__init(instance)
	if instance == nil then
		return
	end

	self.button_level_up = self:FindObj("ButtonLevelUp"):GetComponent("ButtonEx")
	self.skills = {}
	self.skill_variables = {}

	for i = 1, GUILD_SKILL_COUNT do
		self.skills[i] = self:FindObj("Skill" .. i)
		self.skill_variables[i] = {}
		local variable_table = self.skills[i]:GetComponent(typeof(UIVariableTable))
		self.skill_variables[i].icon = variable_table:FindVariable("Icon")
		self.skill_variables[i].level = variable_table:FindVariable("Level")
		self.skill_variables[i].name = variable_table:FindVariable("Name")
		self.skill_variables[i].plus = variable_table:FindVariable("Plus")

		self:ListenEvent("OnClick" .. i,
		function() self:OnClick(i) end)
	end

	self.scroller_rect = self:FindObj("ScrollerRect")
	self.total_fight = self:FindVariable("TotalFightNumber")
	self.current_point = self:FindVariable("CurrentPoint")
	self.next_point = self:FindVariable("NextPoint")
	self.icon = self:FindVariable("Icon")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_type = self:FindVariable("SkillType")
	self.skill_level = self:FindVariable("SkillLevel")
	self.guild_level = self:FindVariable("GuildLevel")
	self.contribution = self:FindVariable("Contribution")
	self.max_level = self:FindVariable("MaxLevel")
	self.show_effect = self:FindVariable("ShowEffect")
	self.fightnum = self:FindVariable("FightNumber")
	self.show_effect:SetValue(false)
	self:ListenEvent("OnClickLevelUp",
		BindTool.Bind(self.OnClickLevelUp, self))

	self.last_skill_level = 0
	self.last_play_time = 0
	self:AutoSelect()
	self:Flush()
end

function GuildAltarView:__delete()
	self:RemoveDelayTime()
end

function GuildAltarView:GetSkillIcon(skill_id)
	return ResPath.GetGuildSkillIcon(skill_id)
end

-- 刷新页面
function GuildAltarView:OnFlush()
	for i = 1, GUILD_SKILL_COUNT do
		local skill_level = GuildData.Instance:GetSkillLevel(i)
		local config = GuildData.Instance:GetSkillConfig(i, skill_level)
		if skill_level and config then
			local bundle, asset = self:GetSkillIcon(config.icon_id)
			self.skill_variables[i].icon:SetAsset(bundle, asset)
			self.skill_variables[i].level:SetValue("LV." .. skill_level)
			self.skill_variables[i].name:SetValue(Language.Common.AttrNameNoUnderline[SkillEnum[i]]) -- 技能名字未定
		end
	end
	for k,v in pairs(self.skills) do
		v.isOn = false
	end
	if self.skills[self.select_index] then
		self.skills[self.select_index].toggle.isOn = true
	end
	self:FlushDetails(self.select_index)
	self:FlushFlag()
	self:FlushTotalFightNum()
end

-- 点击技能
function GuildAltarView:OnClick(index)
	self.select_index = index

	self:FlushFlag()

	self:FlushDetails(self.select_index)
end

-- 刷新技能是否可以升级
function GuildAltarView:FlushFlag()
	local gongxian = GuildData.Instance:GetGuildGongxian()
	local guild_level = GuildDataConst.GUILDVO.guild_level or 0
	for i = 1, GUILD_SKILL_COUNT do
		local skill_level = GuildData.Instance:GetSkillLevel(i) or 0
		local config = GuildData.Instance:GetSkillConfig(i, skill_level)
		local uplevel_gongxian = 0
		local guild_level_limit = 0
		if config then
			uplevel_gongxian = config.uplevel_gongxian or 0
			guild_level_limit = config.guild_level_limit or 0
		end

		if i == self.select_index then
			if skill_level >= GuildData.Instance:GetMaxGuildSkillLevel() then
				self.button_level_up.interactable = false
			else
				self.button_level_up.interactable = true
			end
		end

		if skill_level < GuildData.Instance:GetMaxGuildSkillLevel() and gongxian >= uplevel_gongxian and guild_level >= guild_level_limit then
			self.skill_variables[i].plus:SetValue(true)
		else
			self.skill_variables[i].plus:SetValue(false)
		end
	end
end

function GuildAltarView:FlushTotalFightNum()
	local total = 0
	for i = 1, GUILD_SKILL_COUNT do
		local level = GuildData.Instance:GetSkillLevel(i) or 0
		local config = GuildData.Instance:GetSkillConfig(i, level)
		local capability = 0
		if config then
			local value = {}
			value[SkillEnum[i]] = config[SkillEnum[i]]
			capability = CommonDataManager.GetCapability(value)
		end
		total = total + capability
	end

	self.total_fight:SetValue(total)
end


-- 刷新技能细节
function GuildAltarView:FlushDetails(skill_index)
	local level = GuildData.Instance:GetSkillLevel(skill_index) or 0
	local config = GuildData.Instance:GetSkillConfig(skill_index, level)

	if config then
		self:SetCurrentSkillInfo(config)
		local bundle, asset = self:GetSkillIcon(config.icon_id)
		self.icon:SetAsset(bundle, asset)
		self.skill_name:SetValue(Language.Common.AttrNameNoUnderline[SkillEnum[skill_index]])
		self.skill_level:SetValue(level)
		local guild_level = GuildDataConst.GUILDVO.guild_level or 0
		if config.guild_level_limit > guild_level then
			self.guild_level:SetValue(ToColorStr(config.guild_level_limit, TEXT_COLOR.RED))
		else
			self.guild_level:SetValue(config.guild_level_limit)
		end

		local gongxian = GuildData.Instance:GetGuildGongxian()
		local gongxian_str = CommonDataManager.ConverMoney(gongxian)
		if gongxian >= config.uplevel_gongxian then
			self.contribution:SetValue(ToColorStr(gongxian_str, TEXT_COLOR.TONGYONG_TS) .." / " .. config.uplevel_gongxian)
		else
			self.contribution:SetValue(ToColorStr(gongxian_str, TEXT_COLOR.RED) .." / " .. config.uplevel_gongxian)
		end
	end

	if level < GuildData.Instance:GetMaxGuildSkillLevel() then
		config = GuildData.Instance:GetSkillConfig(skill_index, level + 1)
		if config then
			self:SetNextSkillInfo(config)
		end
	else
		self.max_level:SetValue(true)
		self.next_point:SetValue("")
	end
end

-- 设置当前等级技能的信息
function GuildAltarView:SetCurrentSkillInfo(info)
	self.current_point:SetValue(Language.Guild.YongJiuTiSheng .. ToColorStr(info[SkillEnum[self.select_index]],
	 "#0000f1") .. Language.Guild.Dian .. Language.Common.AttrNameNoUnderline[SkillEnum[self.select_index]])

	local value = {}
	value[SkillEnum[self.select_index]] = info[SkillEnum[self.select_index]]
	local capability  = CommonDataManager.GetCapability(value)

	self.fightnum:SetValue(capability)
	--local capability = info[SkillEnum[self.select_index]] * PointWeight[self.select_index]
	--capability = math.floor(capability)
end

-- 设置下一等级技能的信息
function GuildAltarView:SetNextSkillInfo(info)
	self.max_level:SetValue(false)
	self.next_point:SetValue(Language.Guild.YongJiuTiSheng ..  ToColorStr(info[SkillEnum[self.select_index]],
	 "#0000f1") .. Language.Guild.Dian .. Language.Common.AttrNameNoUnderline[SkillEnum[self.select_index]])
	local value = {}
	value[SkillEnum[self.select_index]] = info[SkillEnum[self.select_index]]
	local capability  = CommonDataManager.GetCapability(value)
	--local capability = info[SkillEnum[self.select_index]] * PointWeight[self.select_index]
	--capability = math.floor(capability)
end

function GuildAltarView:CalculateFp()
	local temp_fight_power = 0
	local totem_config = GuildData.Instance:GetTotemConfig()
	if totem_config then
		local value = {maxhp = totem_config.maxhp, gongji = totem_config.gongji, fangyu = totem_config.fangyu}
		temp_fight_power = CommonDataManager.GetCapability(value)
	end

	return temp_fight_power
end

-- 点击技能升级按钮
function GuildAltarView:OnClickLevelUp()
	local level = GuildData.Instance:GetSkillLevel(self.select_index)
	if(level >= GuildData.Instance:GetMaxGuildSkillLevel()) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildLevelMax)
		return
	end
	local config = GuildData.Instance:GetSkillConfig(self.select_index, level)
	if config then
		local gongxian = GuildData.Instance:GetGuildGongxian()
		if(gongxian < config.uplevel_gongxian) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.EnoughGongXian)
			return
		end

		local skill_index = config.skill_idx
		self.last_skill_level = level
		GuildCtrl.Instance:SendGuildSkillUplevelReq(skill_index)
	end
end

-- 检查技能是否升级成功
function GuildAltarView:CheckLevelUp()
	local level = GuildData.Instance:GetSkillLevel(self.select_index)
	if level > self.last_skill_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SkillUpSucc)
		if self.last_play_time + 1 <= Status.NowTime then
			self.last_play_time = Status.NowTime
			self:PlayEffect()
			AudioService.Instance:PlayAdvancedAudio()
		end
	end
end

function GuildAltarView:PlayEffect()
	self:RemoveDelayTime()
	self.show_effect:SetValue(false)
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
	 self.show_effect:SetValue(true)
	 self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.show_effect:SetValue(false) end, 1)
	 end, 0.1)
end

function GuildAltarView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

-- 自动选择可升级的技能
function GuildAltarView:AutoSelect()
	self.select_index = 1
	local guild_level = GuildDataConst.GUILDVO.guild_level or 0
	local gongxian = GuildData.Instance:GetGuildGongxian()
	for i = 1, GUILD_SKILL_COUNT do
		local skill_level = GuildData.Instance:GetSkillLevel(i)
		if skill_level < GuildData.Instance:GetMaxGuildSkillLevel() then
			local config = GuildData.Instance:GetSkillConfig(i, skill_level)
			if config then
				if config.guild_level_limit <= guild_level then
					if gongxian >= config.uplevel_gongxian then
						self.select_index = i
						break
					end
				end
			end
		end
	end
	local value = (self.select_index - 1) / GUILD_SKILL_COUNT
	value = value > 1 and 1 or value
	self.scroller_rect.scroll_rect.verticalNormalizedPosition = 1 - value
end