GuildTotemView = GuildTotemView or BaseClass(BaseRender)

function GuildTotemView:__init(instance)
	if instance == nil then
		return
	end

	self.button_level_up = self:FindObj("ButtonLevelUp")
	self.button_help = self:FindObj("ButtonHelp")
	self.qizhi_display = self:FindObj("QiZhiDisplay")

	self.slider = self:FindVariable("Slider")
	self.current_level = self:FindVariable("CurrentLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")
	self.leader_gong_ji = self:FindVariable("LeaderGongJi")
	self.current_exp = self:FindVariable("CurrentExp")
	self.next_exp = self:FindVariable("NextExp")
	self.current_hp = self:FindVariable("CurrentHp")
	self.next_hp = self:FindVariable("NextHp")
	self.count = self:FindVariable("Count")
	self.red_point = self:FindVariable("RedPoint")
	self.arrow = self:FindVariable("Arrow")
	self.max_level = self:FindVariable("MaxLevel")
	self.btn_text = self:FindVariable("BtnText")
	self.level = self:FindVariable("Level")

	self.last_totem_level = GuildDataConst.GUILDVO.guild_totem_level

	self:ListenEvent("OnClickLevelUp",
		BindTool.Bind(self.OnClickLevelUp, self))
	self:ListenEvent("OpenWindow",
		BindTool.Bind(self.OpenWindow, self))

	self.amount = 0
	self.qizhi_model = nil
	self.res_id = -1
end

function GuildTotemView:__delete()
	if self.qizhi_model then
		self.qizhi_model:DeleteMe()
		self.qizhi_model = nil
	end
end

function GuildTotemView:Flush()
	local totem_level = GuildDataConst.GUILDVO.guild_totem_level
	local totem_exp = GuildDataConst.GUILDVO.guild_totem_exp
	local totem_config = GuildData.Instance:GetTotemConfig()
	if totem_config then
		local exp = totem_config.max_exp
		if exp ~= 0 then
			self.amount = totem_exp / exp
			if self.amount > 1 then
				self.amount = 1
			end
		else
			self.amount = 1
		end
		if self.amount >= 1 then
			local info = GuildData.Instance:GetGuildMemberInfo()
			if info then
				if info.post == GuildDataConst.GUILD_POST.TUANGZHANG or info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
					self.red_point:SetValue(true)
				end
			end
		else
			self.red_point:SetValue(false)
		end
		self.count:SetValue(totem_exp .. "/" .. exp)
		self.slider:SetValue(self.amount)
		self.level:SetValue(totem_level)
		self.current_level:SetValue("Lv." .. totem_level)
		self.next_level:SetValue("Lv." .. totem_level + 1)
		self.fight_power:SetValue(self:CalculateFp())
		self.gong_ji:SetValue(totem_config.gongji)
		self.fang_yu:SetValue(totem_config.fangyu)
		self.sheng_ming:SetValue(totem_config.maxhp)
		self.leader_gong_ji:SetValue(totem_config.leader_gongji)
		self.current_exp:SetValue(totem_config.bless_exp)
		self.current_hp:SetValue(CommonDataManager.ConverMoney(totem_config.totem_hp))
	end
	totem_config = GuildData.Instance:GetTotemConfig(totem_level + 1)
	if totem_config then
		self.button_level_up:GetComponent("ButtonEx").interactable = true
		self.arrow:SetValue(true)
		self.max_level:SetValue(false)
		self.next_exp:SetValue(totem_config.bless_exp)
		self.next_hp:SetValue(CommonDataManager.ConverMoney(totem_config.totem_hp))
		self.btn_text:SetValue(Language.Common.Up)
	else
		self.red_point:SetValue(false)
		GuildCtrl.Instance.view:SetRedPoint(Guild_PANEL.totem, false)
		self.button_level_up:GetComponent("ButtonEx").interactable = false
		self.next_exp:SetValue("")
		self.next_hp:SetValue("")
		self.arrow:SetValue(false)
		self.max_level:SetValue(true)
		self.btn_text:SetValue(Language.Common.YiManJi)
	end

	if(totem_level > self.last_totem_level) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.TotemUpSucc)
		self.last_totem_level = totem_level
	end
	self:SetQizhiModel(totem_level)
end

function GuildTotemView:OnClickLevelUp()
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
		return
	end
	if self.amount < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotTotemEXP)
		return
	end
	GuildCtrl.Instance:SendGuildTotemUplevelReq()
end

function GuildTotemView:CalculateFp()
	local temp_fight_power = 0
	local totem_config = GuildData.Instance:GetTotemConfig()
	if totem_config then
		local value = {maxhp = totem_config.maxhp, gongji = totem_config.gongji, fangyu = totem_config.fangyu}
		temp_fight_power = CommonDataManager.GetCapability(value)
	end

	local info = GuildData.Instance:GetGuildMemberInfo()
	if info then
		if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
			local value = {gongji = totem_config.leader_gongji}
			temp_fight_power = temp_fight_power + CommonDataManager.GetCapability(value)
		end
	end
	return temp_fight_power
end

function GuildTotemView:OpenWindow()
	TipsCtrl.Instance:ShowHelpTipView(150)
end

function GuildTotemView:CloseAllWindow()

end

function GuildTotemView:InitQizhiModel()
	if not self.qizhi_model then
		self.qizhi_model = RoleModel.New()
		self.qizhi_model:SetDisplay(self.qizhi_display.ui3d_display)
	end
end

function GuildTotemView:SetQizhiModel(level)
	local res_id = GuildData.Instance:GetQiZhiResId(level)
	if self.res_id ~= res_id then
		self.res_id = res_id
		local asset_bundle, name = ResPath.GetQiZhiModel(res_id)
		if not self.qizhi_model then
			self:InitQizhiModel()
		end
		if self.qizhi_model then
			if asset_bundle and name then
				self.qizhi_model:SetMainAsset(asset_bundle, name)
			end
		end
	end
end