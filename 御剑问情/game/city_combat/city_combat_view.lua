CityCombatView = CityCombatView or BaseClass(BaseView)

function CityCombatView:__init()
	self.ui_config = {"uis/views/citycombatview_prefab","CityCombatView"}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GONGCHENGZHAN
end

function CityCombatView:__delete()

end

function CityCombatView:ReleaseCallBack()
	if self.cz_item_cell_list then
		for k,v in pairs(self.cz_item_cell_list) do
			v:DeleteMe()
		end
	end
	self.cz_item_cell_list = nil

	if self.cy_item_cell_list then
		for k,v in pairs(self.cy_item_cell_list) do
			v:DeleteMe()
		end
	end
	self.cy_item_cell_list = nil
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if self.wife_model then
		self.wife_model:DeleteMe()
		self.wife_model = nil
	end

	-- 清理变量和对象
	self.role_display_1 = nil
	self.role_display_2 = nil
	self.explain = nil
	self.title_time = nil
	self.guild_name = nil
	self.hui_zhang_name_1 = nil
	self.hui_zhang_name_2 = nil
	self.title_1 = nil
	self.title_2 = nil
	self.reminding = nil
	self.has_chengzhu = nil
	self.has_chengzhu_wife = nil
	self.duihuan_number = nil
	self.showeffect = nil
	self.time = nil
end

function CityCombatView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickDuiHuan", BindTool.Bind(self.ClickDuiHuan, self))
	self:ListenEvent("ClickWorship", BindTool.Bind(self.ClickWorship, self))
	self:ListenEvent("OpenTip", BindTool.Bind(self.OpenTip, self))

	self.role_display_1 = self:FindObj("RoleDisplay1")
	self.role_display_2 = self:FindObj("RoleDisplay2")

	self.cz_item_cell_list = {}
	for i = 1, 4 do
		self.cz_item_cell_list[i] = ItemCell.New()
		self.cz_item_cell_list[i]:SetInstanceParent(self:FindObj("ItemChengZhu" .. i))
		self.cz_item_cell_list[i]:SetActive(false)
	end

	self.cy_item_cell_list = {}
	for i = 1, 3 do
		self.cy_item_cell_list[i] = ItemCell.New()
		self.cy_item_cell_list[i]:SetInstanceParent(self:FindObj("ItemNormal" .. i))
		self.cy_item_cell_list[i]:SetActive(false)
	end

	self.explain = self:FindVariable("Explain")
	self.title_time = self:FindVariable("TitleTime")
	self.guild_name = self:FindVariable("GuildName")
	self.hui_zhang_name_1 = self:FindVariable("HuiZhangName1")
	self.hui_zhang_name_2 = self:FindVariable("HuiZhangName2")
	self.title_1 = self:FindVariable("Title1")
	self.title_2 = self:FindVariable("Title2")
	self.reminding = self:FindVariable("Reminding")
	self.has_chengzhu = self:FindVariable("HasChengZhu")
	self.has_chengzhu_wife = self:FindVariable("HasChengZhuWife")
	self.duihuan_number = self:FindVariable("DuiHuanNumber")
	self.showeffect = self:FindVariable("ShowEffect")
	self.time = self:FindVariable("Time")

	local other_config = CityCombatData.Instance:GetOtherConfig()
	if other_config then
		self.title_1:SetAsset(ResPath.GetTitleIcon(other_config.cz_chenghao))
	end
end

function CityCombatView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function CityCombatView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function CityCombatView:CloseWindow()
	self:Close()
end

function CityCombatView:ClickDuiHuan()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
end

function CityCombatView:ClickWorship()
	CityCombatCtrl.Instance:GoWorship()
end

function CityCombatView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function CityCombatView:ClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end

	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	ActivityCtrl.Instance:SendActivityEnterReq(self.act_id, index)
	ViewManager.Instance:CloseAll()
end

function CityCombatView:FlushReward()
	local other_config = CityCombatData.Instance:GetOtherConfig()
	if nil == other_config then
		return
	end

	for k, v in pairs(other_config.cz_reward_item) do
		if v.item_id > 0 and self.cz_item_cell_list[k + 1] then
			self.cz_item_cell_list[k + 1]:SetActive(true)
			self.cz_item_cell_list[k + 1]:SetData(v)
		end
	end
	for k, v in pairs(other_config.cy_reward_item) do
		if v.item_id > 0 and self.cy_item_cell_list[k + 1] then
			self.cy_item_cell_list[k + 1]:SetActive(true)
			self.cy_item_cell_list[k + 1]:SetData(v)
		end
	end
end

function CityCombatView:FlushTuanZhangModel()
	local own_info = CityCombatData.Instance:GetCityOwnerInfo()
	local role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	if nil ~= role_info  then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1]
		local res_id = FashionData.GetFashionResByItemId(other_cfg.cz_fashion_yifu_id, role_info.sex, role_info.prof) or 0

		if not self.role_model then
			self.role_model = RoleModel.New("city_combat_panel_1")
			self.role_model:SetDisplay(self.role_display_1.ui3d_display)
		end
		if self.role_model then
			self.role_model:SetModelResInfo(role_info, false, true, true)
			self.role_model:SetRoleResid(res_id)
		end
		self.has_chengzhu:SetValue(true)
	end

	local lover_info = CityCombatData.Instance:GetLoverRoleInfo()
	if nil ~= lover_info then
		self.has_chengzhu_wife:SetValue(true)

		local other_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1]
		local res_id = FashionData.GetFashionResByItemId(other_cfg.cz_fashion_yifu_id, lover_info.sex, lover_info.prof) or 0

		if not self.wife_model then
			self.wife_model = RoleModel.New("city_combat_panel_2")
			self.wife_model:SetDisplay(self.role_display_2.ui3d_display)
		end
		if self.wife_model then
			self.wife_model:SetModelResInfo(lover_info, false, true, true)
			self.wife_model:SetRoleResid(res_id)
		end

		local other_config = CityCombatData.Instance:GetOtherConfig()
		if other_config then
			title_id = GameEnum.FEMALE == lover_info.sex and other_config.cz_wife_title_id or other_config.cz_husband_title_id
			self.title_2:SetAsset(ResPath.GetTitleIcon(title_id or 0))
		end
		self.hui_zhang_name_2:SetValue(ToColorStr(lover_info.role_name,TEXT_COLOR.GOLD))
	end
end

function CityCombatView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)
	self.explain:SetValue(act_info.dec)

	local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.SHENGWANG))
	self.duihuan_number:SetValue(nume)

	local own_info = CityCombatData.Instance:GetCityOwnerInfo()
	if own_info and own_info.guild_id > 0 then
		local guild_info = GuildData.Instance:GetGuildInfoById(own_info.guild_id)
		if guild_info then
			self.guild_name:SetValue(guild_info.guild_name)
		end
		self.hui_zhang_name_1:SetValue(ToColorStr(own_info.owner_name,TEXT_COLOR.GOLD))
	else
		self.has_chengzhu:SetValue(false)
		self.has_chengzhu_wife:SetValue(false)
		self.hui_zhang_name_1:SetValue(ToColorStr(Language.Common.ZanWu,TEXT_COLOR.GOLD))
		self.hui_zhang_name_2:SetValue(ToColorStr(Language.Common.ZanWu,TEXT_COLOR.GOLD))
		self.guild_name:SetValue(Language.Common.ZanWu)
	end

	self:FlushTuanZhangModel()
	self:FlushReward()

	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	self.showeffect:SetValue(is_act_open)

	local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	if nil ~= act_cfg then
		self.time:SetValue(act_cfg.open_time .. "-".. act_cfg.end_time)
	end
	
end

function CityCombatView:SetTitleTime(act_info)
	if ActivityData.Instance:GetActivityIsOpen(self.act_id) then
		self.reminding:SetValue(false)
	else
		self.reminding:SetValue(true)
	end

	self.title_time:SetValue(ActivityData.Instance:GetNextOpenWeekTime(act_info.act_id) or "")
end

function CityCombatView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end

function CityCombatView:OpenTip()
	local level = CityCombatData.Instance:GetTeQuanLevel()
	local hefu_info = CityCombatData.Instance:GetHefuCfg().other[1]
	local name = Language.HeFuCombatTip.City_Master
	local tequan_level = level
	local max_level = hefu_info.gcz_sepcial_attr_add_limit/hefu_info.gcz_sepcial_attr_add
	local asset, bunble = ResPath.GetHeFuCityRes("Icon_tip")
	local now_des = ""
	local next_des = ""
	
	if level > 0 then
		now_des = string.format(Language.HeFuCombatTip.Tequan_Info, hefu_info.gcz_sepcial_attr_add/100 * level.."%")
	else
		now_des = Language.HeFuCombatTip.No_Level
	end

	if level < max_level then
		next_des = string.format(Language.HeFuCombatTip.Tequan_Info, hefu_info.gcz_sepcial_attr_add/100 * (level + 1).."%")
	else
		next_des = Language.HeFuCombatTip.Max_Level
	end

	CityCombatCtrl.Instance:ShowTequanTips(name, tequan_level, now_des, next_des, asset, bunble)
end