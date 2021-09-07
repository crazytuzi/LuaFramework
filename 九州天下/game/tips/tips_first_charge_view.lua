TipsFirstChargeView = TipsFirstChargeView or BaseClass(BaseView)

function TipsFirstChargeView:__init()
	self.ui_config = {"uis/views/tips/firstchargetip", "FirstChargeTips"}
	self.view_layer = UiLayer.MainUI
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/voice/firstchargeguide", self.audio_config.other[1].FirstchargeGuide)
	end
end

function TipsFirstChargeView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.res_id = nil
	if self.data_listen and PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.old_level = nil
end

function TipsFirstChargeView:SetDataChangeCallback()
	if not self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.old_level = main_role_vo.level
	end
end

function TipsFirstChargeView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.res_id = nil
	self.display = nil
	self.fight_power = nil
end

function TipsFirstChargeView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		if self.old_level then
			local fun_cfg = OpenFunData.Instance:OpenFunCfg() or {}
			local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
			if history_recharge < DailyChargeData.Instance:GetTotalChongZhiYi() and fun_cfg.first_charge_tip and value >= fun_cfg.first_charge_tip.trigger_param and self.old_level < fun_cfg.first_charge_tip.trigger_param then
				self.old_level = value
				self:Open()
				if not self.upgrade_timer_quest then
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						self:Close()
					end, fun_cfg.first_charge_tip.with_param)
				end
			end
		end
	end
end

-- 创建完调用
function TipsFirstChargeView:LoadCallBack()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("OnClickCharge",
		BindTool.Bind(self.OnClickCharge, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnBgClick",
		BindTool.Bind(self.OnBgClick, self))

	self.fight_power = self:FindVariable("FightPower")
end

function TipsFirstChargeView:OpenCallBack()
	self:Flush()
end

function TipsFirstChargeView:CloseCallBack()
	self.res_id = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function TipsFirstChargeView:OnClickCharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TipsFirstChargeView:OnClickClose()
	self:Close()
end

function TipsFirstChargeView:OnBgClick()
	self:Close()
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

function TipsFirstChargeView:OnFlush(param_list)
	if self.model and not self.res_id then
		local reward_cfg =DailyChargeData.Instance:GetFirstRewardByWeek()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", reward_cfg.wepon_index)
		local weapon_show_id = "100" .. main_role_vo.prof .. num_str

		self.model:SetMainAsset(ResPath.GetWeaponShowModel(weapon_show_id))
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WEAPON], weapon_show_id, DISPLAY_PANEL.ADVANCE_SUCCE)

		self.res_id = weapon_show_id

		local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(DailyChargeData.Instance:GetTotalChongZhiYi())
		if item_info_list and item_info_list[1] then
			local gifts_info = DailyChargeData.Instance:GetChongZhiReward(DailyChargeData.Instance:GetTotalChongZhiYi()).first_reward_item
			local gift_id = gifts_info and gifts_info.item_id or 0
			local data = CommonStruct.ItemDataWrapper()
			data.item_id = item_info_list[1].item_id
			data.param = CommonStruct.ItemParamData()
			data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
			self.fight_power:SetValue(EquipData.Instance:GetEquipLegendFightPowerByData(data, false, true, nil))
		end
	end
end
