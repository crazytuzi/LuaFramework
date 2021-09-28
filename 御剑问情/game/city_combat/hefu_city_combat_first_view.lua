HeFuCombatFirstView = HeFuCombatFirstView or BaseClass(BaseView)

function HeFuCombatFirstView:__init()
	self.ui_config = {"uis/views/hefucitycombatview_prefab","HeFuCityCombatFirstView"}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GONGCHENGZHAN
end

function HeFuCombatFirstView:__delete()

end

function HeFuCombatFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

    if self.arward_item then
		for k,v in pairs(self.arward_item) do
			v:DeleteMe()
		end
	end    
	self.arward_item = {}
     
	-- 清理变量和对象
	self.role_display = nil
	self.explain = nil
	self.guild_name = nil
	self.hui_zhang_name = nil
	self.has_chengzhu = nil
	self.desc = nil
	self.title_icon = nil
end

function HeFuCombatFirstView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("OpenTip", BindTool.Bind(self.OpenTip, self))

	self.arward_item = {}
	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item_"..i))
		self.arward_item[i] = item_cell
	end

	self.role_display = self:FindObj("RoleDisplay")
	self.role_model = RoleModel.New("city_combat_first_panel")
	self.role_model:SetDisplay(self.role_display.ui3d_display)

	self.title_icon = self:FindVariable("Title_Icon")
	self.explain = self:FindVariable("Explain")
	self.guild_name = self:FindVariable("GuildName")
	self.hui_zhang_name = self:FindVariable("HuiZhangName")
	self.has_chengzhu = self:FindVariable("HasChengZhu")
	self.desc = self:FindVariable("desc")

	local other_config = CityCombatData.Instance:GetHefuCfg().other[1]
	if other_config then
		self.title_icon:SetAsset(ResPath.GetTitleIcon(other_config.title_show))
	end
	
	self.desc:SetValue(Language.Daily.CityCombatFirstDesc)
end

function HeFuCombatFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()

	HefuActivityCtrl.Instance:SendCSARoleOperaReq(CSA_SUB_GONGCHENGZHAN.CSA_SUB_TYPE_FOUNDATION)
end

function HeFuCombatFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

end

function HeFuCombatFirstView:CloseWindow()
	self:Close()
end

function HeFuCombatFirstView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function HeFuCombatFirstView:ClickEnter()
	self:Close()
	ViewManager.Instance:Open(ViewName.CityCombatView)
end

function HeFuCombatFirstView:OpenTip()
	local level = CityCombatData.Instance:GetTeQuanLevel()
	local hefu_info = CityCombatData.Instance:GetHefuCfg().other[1]
	local name = Language.HeFuCombatTip.City_Master
	local tequan_level = level
	local asset, bunble = ResPath.GetHeFuCityRes("Icon_tip")
	local max_level = hefu_info.gcz_sepcial_attr_add_limit/hefu_info.gcz_sepcial_attr_add
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

function HeFuCombatFirstView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		if self.role_model then
			self.role_model:SetModelResInfo(info, false, true, true)
			local other_cfg = CityCombatData.Instance:GetOtherConfig()
			for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
				if v.active_stuff_id == other_cfg.cz_fashion_yifu_id then
					local res_id = v["resouce" .. info.prof .. info.sex]
					self.role_model:SetRoleResid(res_id)
					-- self.role_model:SetWeaponResid(0)
					-- self.role_model:SetWeapon2Resid(0)
					break
				end
			end
		end
	end
end

function HeFuCombatFirstView:OnFlush()
	local hefu_info = CityCombatData.Instance:GetHefuCfg().other[1]
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	for k, v in pairs(self.arward_item) do
		if hefu_info.gcz_camp_reward[k - 1] then
			v:SetItemActive(true)
			v:SetData(hefu_info.gcz_camp_reward[k - 1])
		else
			v:SetItemActive(false)
		end
	end

	self.explain:SetValue(act_info.dec)

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.tuanzhang_uid = game_vo.role_id
	self.hui_zhang_name:SetValue(game_vo.name)
	self:FlushTuanZhangModel(self.tuanzhang_uid, game_vo)
end

function HeFuCombatFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end