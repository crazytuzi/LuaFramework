LeiJiRechargeView = LeiJiRechargeView or BaseClass(BaseView)

local DISPLAYNAME = {
	[22525] = "leijichongzhi_panel_1",
	[7017001] = "leijichongzhi_panel_2",
	[10016001] = "leijichongzhi_panel_3",
	[00020] = "leijichongzhi_panel_4",
	[0001] = "leijichongzhi_panel_5",
}

local SHOWWUQI_AND_SHIZHUANG = 9
function LeiJiRechargeView:__init()
	self.ui_config = {"uis/views/leijirechargeview_prefab","LeiJiRechargeView"}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.index = 0
	self.cur_select = 1
	self.box_select = 0

	self.temp_select_index = -1
	self.show_icon_list = {}
end

function LeiJiRechargeView:LoadCallBack()
	self.show_num_list = {}
	self.show_icon_list = {}
	for i=1,10 do
	 	self:ListenEvent("Btn_Recharge"..i, BindTool.Bind(self.OnBtnRecharge,self,i))
		self["show_remin"..i] = self:FindVariable("Show_Remin".. i)
		self["show_hl"..i] = self:FindVariable("ShowHL"..i)
		self.show_num_list[i] = self:FindVariable("Show_num".. i)
		self.show_icon_list[i] = self:FindVariable("Show_Icon".. i)
	end
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))

	self.show_get_btn = self:FindVariable("ShowGetBtn")
	self.button_show  = self:FindVariable("Button_Show")
	self.cur_chongzhi_zuanshi  = self:FindVariable("cur_chongzhi_zuanshi")
	self.recharge_zuanshi  = self:FindVariable("Recharge_Zuanshi")
	self.show_recharge_text  = self:FindVariable("Show_Recharge_Text")
	self.rest_day = self:FindVariable("RestDay")
	self.show_reset_day = self:FindVariable("ShowResetDay")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.reset_hour = self:FindVariable("ResetHour")
	self.reset_min = self:FindVariable("ResetMin")
	self.reset_sec = self:FindVariable("ResetSec")
	self.zhandouli = self:FindVariable("ZhanDouLi")
	self.is_show_zhanduli = self:FindVariable("Is_Show_ZhanDuLi")
	self.is_show_zhanduli_icon = self:FindVariable("Is_Show_ZhanDuLi_Icon")
	self.is_model = self:FindVariable("is_model")
	self.show_item_eff = self:FindVariable("ShowEffect")
	self.left_btn_show = self:FindVariable("Left_Btn_Show")
	self.right_btn_show = self:FindVariable("Right_Btn_Show")
	self.xiamian_left = self:FindVariable("XiaMian_Left")
	self.xiamian_right = self:FindVariable("XiaMian_Right")
	self.show_recharge_icon = self:FindVariable("Show_Recharge_Icon")
	self.is_show_recharge_icon = self:FindVariable("Is_Show_Recharge_Icon")
	self.show_bg_effect = self:FindVariable("ShowBgEffect")
	self.show_name = self:FindVariable("show_name")
	self.item_count = self:FindVariable("ItemCount")
	self.is_active_wan = self:FindVariable("is_active_wan")
	self.item_contain = self:FindObj("ItemContain")

	-- self.show_partical_eff = self:FindVariable("show_partical_eff")
	-- self.model_bg_effect = self:FindObj("EffectModel")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("leijichongzhi_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.left_btn_show:SetValue(false)
	self.right_btn_show:SetValue(false)

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self:ShowNum()
end

function LeiJiRechargeView:ReleaseCallBack()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.item_list = {}
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	-- 清理变量和对象
	for i=1,10 do
		self["show_remin"..i] = nil
		self.show_num_list[i] = nil
		self["show_hl"..i] = nil
	end
	self.show_icon_list = {}
	self.item_count = nil
	self.show_get_btn = nil
	self.button_show  = nil
	self.cur_chongzhi_zuanshi = nil
	self.recharge_zuanshi  = nil
	self.show_recharge_text  = nil
	self.rest_day = nil
	self.show_reset_day = nil
	self.exp_radio = nil
	self.reset_hour = nil
	self.reset_min = nil
	self.reset_sec = nil
	self.zhandouli = nil
	self.is_show_zhanduli = nil
	self.is_show_zhanduli_icon = nil
	self.is_model = nil
	self.show_item_eff = nil
	self.show_recharge_icon = nil
	self.is_show_recharge_icon = nil
	self.show_bg_effect = nil
	self.listcontain = nil
	self.display = nil
	self.is_active_wan = nil
	self.show_name = nil
	self.xiamian_left = nil
	self.xiamian_right = nil
	self.left_btn_show = nil
	self.right_btn_show = nil
	self.item_contain = nil
end

function LeiJiRechargeView:CloseCallBack()
	self.temp_select_index = -1
end

function LeiJiRechargeView:GetDisplayName(id)
	local display_name = "leijichongzhi_panel"
	for k,v in pairs(DISPLAYNAME) do
		if k == id then
			display_name = v
			return display_name
		end
	end
	return display_name
end

-- 模型展示
function LeiJiRechargeView:ShowModel(index)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local bundle3, asset3 = ResPath.GetLeiJiRechargeDisName(index)
	if cfg and self.temp_select_index ~= index then
		self.temp_select_index = index
		-- self.show_name:SetAsset(bundle3, asset3)
		if cfg[index] then
			self.show_bg_effect:SetValue(cfg[index].special_show == 1)
			local tbl = Split(cfg[index].model_show, ",")
			-- 足迹
			if #tbl == 1 then
				if cfg[index].is_foot >= 1 then
					self.model:ClearModel()
					self.model:SetPanelName("leijichongzhi_panel")
					self.model:SetRoleResid(main_role:GetRoleResId())
					self.model:SetFootResid(tostring(cfg[index].model_show))
					self.model:SetRotation(Vector3(0, -90, 0))
					self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
					self.is_show_recharge_icon:SetValue(false)
				elseif string.find(tbl[1], "Halo") then
					self.model:ClearModel()
					self.model:SetPanelName("leijichongzhi_panel")
					self.is_show_recharge_icon:SetValue(false)
					self.model:SetFootState(false)
					self.model:SetRotation(Vector3(0, 0, 0))
					self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
					self.model:SetRoleResid(main_role:GetRoleResId())
					local temp = Split(cfg[index].model_show, "_")
					self.model:SetHaloResid(tonumber(temp[2]))
				else
					self.is_show_recharge_icon:SetValue(false)
					self.model:SetFootState(false)
					self.model:ClearModel()
					local display_name = self:GetDisplayName(tonumber(tbl[1]))
					self.model:SetPanelName(display_name)

					if index == SHOWWUQI_AND_SHIZHUANG then      --第九个显示时装和武器，写死了
						if cfg[index - 1] and cfg[index - 1].model_show  then
							local tb_wuqi = Split(cfg[index - 1].model_show, ",") or 0
                            ItemData.ChangeModel(self.model, tonumber(tbl[1]), tonumber(tb_wuqi[1]))
                        end
                    else
                    	ItemData.ChangeModel(self.model, tonumber(tbl[1]))
                    end

					self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
				end
			elseif tbl[3] then
				if tonumber(tbl[3]) == 0 then
					self.model:ClearModel()
					self.model:SetFootState(false)
					self.is_show_recharge_icon:SetValue(false)
					local display_name = self:GetDisplayName(tonumber(tbl[2]))
					self.model:SetPanelName(display_name)
					self.model:SetMainAsset(tbl[1], tbl[2])
					-- 人物光环，特殊处理
					if string.find(tbl[1], "effects") then
						self.model:SetRoleResid(main_role:GetRoleResId())
					end
					self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
				elseif tonumber(tbl[3]) == 1 then
					self.model:ClearModel()
					self.model:SetFootState(false)
					self.is_show_recharge_icon:SetValue(true)
					self.show_recharge_icon:SetAsset(tbl[1], tbl[2])
				end
			end
			-- 写死了第五个按钮是仙女，如果以后策划改了，就让他们配个类型读吧
			if string.find(tbl[1], "goddess") ~= nil then
				self.model:SetTrigger("show_idle_1")
			elseif string.find(tbl[1], "mount") ~= nil then
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
			end

			if #tbl ~= 1 and cfg[index].is_foot <= 1 then
				if string.find(tbl[1], "mount") == nil then
					self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
				end
				self.model.display:SetRotation(Vector3(0, 0, 0))
			end
			-- local cfg_pos = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").leijirecharge_model[index]
			-- if cfg_pos then
			-- 	self.model:SetTransform(cfg_pos)
			-- 	self.display.raw_image.raycastTarget = cfg_pos.can_rotate
			-- end
		end
	end


end

	-- 打开界面显示的初始值
function LeiJiRechargeView:OpenCallBack()
	RemindManager.Instance:SetTodayDoFlag(RemindName.KfLeichong)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2091, 0)
	self:KaiFuTime()
	self:FlusNextCanGet()
end

-- 开服时间倒计时
function LeiJiRechargeView:KaiFuTime()
	local residue_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)

	if residue_time < 86400 then
		self:SetRestTime(residue_time)
	else
		self.rest_day:SetValue(math.floor(residue_time / 86400))
		self.show_reset_day:SetValue(true)
	end
end

-- 设置倒计时
function LeiJiRechargeView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.reset_hour:SetValue(left_hour)
			self.reset_min:SetValue(left_min)
			self.reset_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LeiJiRechargeView:OnFlush()
	self:RechargeFlush()
	self:ProgressValue()
end

-- 进度条
function LeiJiRechargeView:ProgressValue()
	local cur_valur = KaifuActivityData.Instance:RechargeProgressValue()
	self.exp_radio:SetValue(cur_valur/10)
end

--根据flag显示匹配的累充金额
function LeiJiRechargeView:ShowNum()
	local config = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	if config == nil then return end

	self.item_count:SetValue(GetListNum(config))

	for i = 1, GetListNum(config) do
		local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(i - 1).need_chognzhi
		local show_cfg = 0

		if cfg then
	 		show_cfg = CommonDataManager.ConverMoney(cfg)
		end
		self.show_num_list[i]:SetValue(show_cfg)
	end
end

-- 领取奖励按钮
function LeiJiRechargeView:OnClickGet()
	if self.cur_flag == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.cur_select - 1)
	elseif self.cur_flag == 1 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
	-- if self.cur_flag == 1 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
	-- end
end

function LeiJiRechargeView:OnClickClose()
	self:Close()
end

-- 根据左右按钮Index刷新界面显示
function LeiJiRechargeView:RechargeFlush()
	self.item_contain:SetActive(false)

	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(self.cur_select - 1)
	local money_info = KaifuActivityData.Instance:GetLeiJiChongZhiInfo()

	if cfg and money_info then
		self.item_contain:SetActive(true)
		local special_list = Split(cfg.item_special, ",")
		for i=1,3 do
			local item_data = cfg.reward_item[i - 1]
			self.item_list[i].root_node.transform.parent.gameObject:SetActive(item_data ~= nil)

			if item_data then
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_data.item_id)
				if item_cfg and item_cfg.color == 6 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
					item_data.param = EquipData.GetPinkEquipParam()
				end

				local _, big_type = ItemData.Instance:GetItemConfig(item_data.item_id)
				if big_type == GameEnum.ITEM_BIGTYPE_GIF then
					local reward_list = ItemData.Instance:GetGiftItemListByProf(item_data.item_id)
					self.item_list[i]:SetGiftItemId(item_data.item_id)
					item_data = reward_list[1]
					item_data = item_data or cfg.reward_item[i - 1]
				end
				self.item_list[i]:SetData(item_data)
				for _, item_id in ipairs(special_list) do
					if tonumber(item_id) == item_data.item_id then
						self.item_list[i]:ShowSpecialEffect(true)
						local bunble, asset = ResPath.GetItemActivityEffect()
						self.item_list[i]:SetSpecialEffect(bunble, asset)
					end
				end
			end
		end
		self.cur_chongzhi_zuanshi:SetValue(money_info.total_charge_value or 0)
		self.recharge_zuanshi:SetValue(cfg.need_chognzhi >= 100000 and (cfg.need_chognzhi / 10000) or cfg.need_chognzhi)
		self.is_active_wan:SetValue(cfg.need_chognzhi >= 100000)
	end

	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	if chongzhi_cfg and chongzhi_cfg[self.cur_select] then
		if flag_cfg[chongzhi_cfg[self.cur_select].seq].flag == 0  then
			self.button_show:SetValue(Language.Activity.FlagAlreadyReceive)
		elseif flag_cfg[chongzhi_cfg[self.cur_select].seq].flag == 1 then
			self.button_show:SetValue(Language.Common.Recharge)
		else
			self.button_show:SetValue(Language.Activity.FlagCanAlreadyReceive)
		end
		self.cur_flag = flag_cfg[chongzhi_cfg[self.cur_select].seq].flag
		self.show_get_btn:SetValue(flag_cfg[chongzhi_cfg[self.cur_select].seq].flag ~= 0)
		local config = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
		if config == nil then return end

		for i=1, GetListNum(config) do
			if flag_cfg[chongzhi_cfg[i].seq].flag == 2 then
				self["show_remin"..i]:SetValue(true)
			else
				self["show_remin"..i]:SetValue(false)
			end
			self.show_icon_list[i]:SetValue(flag_cfg[chongzhi_cfg[i].seq].flag == 0)
		end
		RemindManager.Instance:Fire(RemindName.KfLeichong)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local bundle, asset = ResPath.GetLeiJiRechargeIcon(self.cur_select)
		self.show_recharge_text:SetAsset(bundle, asset)
	end

	self:ShowModel(self.cur_select)

	local temp_power = cfg.capbility or 0

	self.zhandouli:SetValue(temp_power)

	if self.cur_select == 1 or self.cur_select == 7 then
		self.show_item_eff:SetValue(false)
	else
		self.show_item_eff:SetValue(true)
	end
end

-- 箱子档位
function LeiJiRechargeView:OnBtnRecharge(index, is_click)
	self.cur_select = index
	self:RechargeFlush()
	self:FLushHL()
	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	self.show_get_btn:SetValue(flag_cfg[chongzhi_cfg[index].seq].flag ~= 0)

	-- if self.cur_select >= 10 then
	-- 	self.right_btn_show:SetValue(false)
	-- else
	-- 	self.right_btn_show:SetValue(true)
	-- end
end

function LeiJiRechargeView:FLushHL()

	for i=1,10 do
		if self.cur_select == i then
			self["show_hl"..i]:SetValue(true)
		else
			self["show_hl"..i]:SetValue(false)
		end
	end

end

function LeiJiRechargeView:FlusNextCanGet()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	for k,v in pairs(flag_cfg) do
		if v.flag == 2 then
			self:OnBtnRecharge(v.seq + 1, false)
			self:Flush()
			break
		end
	end
	self:Flush()
end
