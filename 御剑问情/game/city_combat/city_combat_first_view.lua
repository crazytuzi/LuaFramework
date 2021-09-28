CityCombatFirstView = CityCombatFirstView or BaseClass(BaseView)

function CityCombatFirstView:__init()
	self.ui_config = {"uis/views/citycombatview_prefab","CityCombatFirstView"}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GONGCHENGZHAN
end

function CityCombatFirstView:__delete()

end

function CityCombatFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	-- 清理变量和对象
	self.role_display = nil
	self.explain = nil
	self.guild_name = nil
	self.hui_zhang_name = nil
	self.title = nil
	self.has_chengzhu = nil
	self.desc = nil
end

function CityCombatFirstView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))

	self.role_display = self:FindObj("RoleDisplay")

	self.explain = self:FindVariable("Explain")
	self.guild_name = self:FindVariable("GuildName")
	self.hui_zhang_name = self:FindVariable("HuiZhangName")
	self.title = self:FindVariable("Title")
	self.has_chengzhu = self:FindVariable("HasChengZhu")
	self.desc = self:FindVariable("desc")

	local other_config = CityCombatData.Instance:GetOtherConfig()
	if other_config then
		self.title:SetAsset(ResPath.GetTitleIcon(other_config.cz_chenghao))
	end
	
	self.desc:SetValue(Language.Daily.CityCombatFirstDesc)
end

function CityCombatFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function CityCombatFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

end

function CityCombatFirstView:CloseWindow()
	self:Close()
end

function CityCombatFirstView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function CityCombatFirstView:ClickEnter()
	self:Close()
	ViewManager.Instance:Open(ViewName.CityCombatView)
end

function CityCombatFirstView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		-- if not self.role_model then
		-- 	self.role_model = RoleModel.New("city_combat_first_panel")
		-- 	self.role_model:SetDisplay(self.role_display.ui3d_display)
		-- end
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

function CityCombatFirstView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self.explain:SetValue(act_info.dec)

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.tuanzhang_uid = game_vo.role_id
	self.hui_zhang_name:SetValue(game_vo.name)
	if not self.role_model then
		self.role_model = RoleModel.New("city_combat_first_panel")
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	self:FlushTuanZhangModel(self.tuanzhang_uid, game_vo)
end

function CityCombatFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end