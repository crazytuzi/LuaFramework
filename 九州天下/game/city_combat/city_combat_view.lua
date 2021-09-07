CityCombatView = CityCombatView or BaseClass(BaseView)

ITEMTOTALNUM = 4

function CityCombatView:__init()
	self.ui_config = {"uis/views/citycombatview","CityCombatView"}
	self.play_audio = true
	self:SetMaskBg()

	self.act_id = ACTIVITY_TYPE.GONGCHENGZHAN
	self.emperor_is_show = true
end

function CityCombatView:__delete()

end

function CityCombatView:ReleaseCallBack()
	if self.cz_item_cell_list then
		for k,v in pairs(self.cz_item_cell_list) do
			v:DeleteMe()
		end
	end
	self.cz_item_cell_list = {}

	-- if self.cy_item_cell_list then
	-- 	for k,v in pairs(self.cy_item_cell_list) do
	-- 		v:DeleteMe()
	-- 	end
	-- end
	-- self.cy_item_cell_list = nil
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	-- 清理变量和对象
	self.role_display = nil
	self.explain = nil
	self.title_time = nil
	self.guild_name = nil
	self.hui_zhang_name = nil
	-- self.title = nil
	self.reminding = nil
	self.has_chengzhu = nil
end

function CityCombatView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))

	self.role_display = self:FindObj("RoleDisplay")
	self.cz_item_cell_list = {}
	for i = 1, ITEMTOTALNUM do
		self.cz_item_cell_list[i] = ItemCell.New()
		self.cz_item_cell_list[i]:SetInstanceParent(self:FindObj("ItemChengZhu" .. i))
		self.cz_item_cell_list[i]:SetActive(false)
	end

	-- self.cy_item_cell_list = {}
	-- for i = 1, 3 do
	-- 	self.cy_item_cell_list[i] = ItemCell.New()
	-- 	self.cy_item_cell_list[i]:SetInstanceParent(self:FindObj("ItemNormal" .. i))
	-- 	self.cy_item_cell_list[i]:SetActive(false)
	-- end

	self.explain = self:FindVariable("Explain")
	self.title_time = self:FindVariable("TitleTime")
	self.guild_name = self:FindVariable("GuildName")
	self.hui_zhang_name = self:FindVariable("HuiZhangName")
	-- self.title = self:FindVariable("Title")
	self.reminding = self:FindVariable("Reminding")
	self.has_chengzhu = self:FindVariable("HasChengZhu")
	--self.emperor_is_show = self:FindVariable("EmperorIsShow")
	-- local other_config = CityCombatData.Instance:GetOtherConfig()
	-- if other_config then
	-- 	self.title:SetAsset(ResPath.GetTitleIcon(other_config.cz_chenghao))
	-- end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function CityCombatView:OpenCallBack()
	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:FlushReward()
	self:Flush()
end

function CityCombatView:CloseCallBack()
	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function CityCombatView:CloseWindow()
	self:Close()
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
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if act_info then
		for i=1,ITEMTOTALNUM do
			if act_info["reward_item" .. i] and next(act_info["reward_item" .. i]) then
				if self.cz_item_cell_list[i] then
					self.cz_item_cell_list[i]:SetActive(true)
					self.cz_item_cell_list[i]:SetData(act_info["reward_item" .. i])
				end
			end
		end

		
		-- for k,v in pairs(other_config.cy_reward_item) do
		-- 	if v.item_id > 0 then
		-- 		if self.cy_item_cell_list[k + 1] then
		-- 			self.cy_item_cell_list[k + 1]:SetActive(true)
		-- 			self.cy_item_cell_list[k + 1]:SetData(v)
		-- 		end
		-- 	end
		-- end
	end
end

function CityCombatView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		if not self.role_model then
			self.role_model = RoleModel.New("city_combat_view")
			self.role_model:SetDisplay(self.role_display.ui3d_display)
		end
		if self.role_model then
			self.role_model:SetModelResInfo(info, false, false, true, false, true)
		end
	end
end

function CityCombatView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	--self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)
	--self.explain:SetValue(act_info.dec)
	self:SetExplainH(act_info)
	--活动介绍

	local own_info = CityCombatData.Instance:GetCityOwnerInfo()
	if own_info and own_info.guild_id > 0 then
		self.has_chengzhu:SetValue(true)
		local guild_info = GuildData.Instance:GetGuildInfoById(own_info.guild_id)
		if guild_info then
			self.guild_name:SetValue(guild_info.guild_name)
		end

		--获取到国家
		local str = ToColorStr(Language.Common.ScnenCampNameAbbr[own_info.guild_id], COLOR[CAMP_BY_STR[own_info.guild_id]])
		self.hui_zhang_name:SetValue(str.."·"..own_info.owner_name)
		self.tuanzhang_uid = own_info.owner_id
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.tuanzhang_uid)
	else
		self.has_chengzhu:SetValue(false)
		self.tuanzhang_uid = 0
		self.hui_zhang_name:SetValue(Language.Common.ZanWu)
		self.guild_name:SetValue(Language.Common.ZanWu)
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

--描述
function CityCombatView:SetExplainH(act_info)
	local min_level = tonumber(act_info.min_level)
	local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
	local level_str = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	local time_des = ""

	if act_info.is_allday == 1 then
		time_des = Language.Activity.AllDay
	else
		time_des = ActivityData.Instance:GetNextOpenWeekTime(act_info.act_id) or ""
	end
	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	self.explain:SetValue(detailexplain)
end