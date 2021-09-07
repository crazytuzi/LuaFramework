LeiJiRechargeView = LeiJiRechargeView or BaseClass(BaseView)

function LeiJiRechargeView:__init()
	self.ui_config = {"uis/views/leijirechargeview","LeiJiRechargeView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.index = 0
	self.cur_select = 1
	self.box_select = 0

	self.temp_select_index = -1
end

function LeiJiRechargeView:LoadCallBack()
	self.show_num_list = {}
	for i=1,10 do
	 	self:ListenEvent("Btn_Recharge"..i, BindTool.Bind(self.OnBtnRecharge,self,i))
	 	self["show_box_icon"..i]   = self:FindVariable("Show_Box_Icon"..i)
	 	self["show_icon"..i]   = self:FindVariable("Show_Icon"..i)
	 	-- self["model" .. i] = RoleModel.New()
	 	self["Toggle_Image"..i] = self:FindObj("Toggle_Image".. i)
		self["show_remin"..i] = self:FindVariable("Show_Remin".. i)
		self.show_num_list[i] = self:FindVariable("Show_num".. i)
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
	-- self.show_box_icon  = self:FindVariable("Show_Box_Icon")
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
	-- self.show_partical_eff = self:FindVariable("show_partical_eff")
	-- self.model_bg_effect = self:FindObj("EffectModel")

	self.listcontain = self:FindObj("ListContain")
	self.listcontain.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnBoxClickLeftButton",
		BindTool.Bind(self.OnBoxClickLeftButton, self))
	self:ListenEvent("OnBoxClickRightButton",
		BindTool.Bind(self.OnBoxClickRightButton, self))

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self:ShowBoxIcon()
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
	 	self["show_box_icon"..i] = nil
	 	self["show_icon"..i] = nil
	 	self["Toggle_Image"..i] = nil
		self["show_remin"..i] = nil
		self.show_num_list[i] = nil
	end
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
	self.left_btn_show = nil
	self.right_btn_show = nil
	self.xiamian_left = nil
	self.xiamian_right = nil
	self.show_recharge_icon = nil
	self.is_show_recharge_icon = nil
	self.show_bg_effect = nil
	self.listcontain = nil
	self.display = nil
end

function LeiJiRechargeView:CloseCallBack()
	self.temp_select_index = -1
end

-- 模型展示
function LeiJiRechargeView:ShowModel(index)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local bundle, asset = ResPath.GetLeiJiRechargeImage(1)
	local bundle2, asset2 = ResPath.GetLeiJiRechargeImage(7)
	if cfg and self.temp_select_index ~= index then

		self.temp_select_index = index
		if cfg[index] then
			self.show_bg_effect:SetValue(cfg[index].special_show == 1)
		end
		if index == 1 then
			self.model:SetHaloResid(0)
			local tbl1 = Split(cfg[1].model_show, ",")
			self.model:SetMainAsset(tbl1[1], tbl1[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 2 then
			self.model:SetHaloResid(0)
			self.model:SetMainAsset("actors/weapon/100"..main_role_vo.prof.."01",100 ..main_role_vo.prof.. "01")
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 3 then
			self.model:SetHaloResid(0)
			local tbl3 = Split(cfg[3].model_show, ",")
			self.model:SetMainAsset(tbl3[1], tbl3[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 4 then
			self.model:SetHaloResid(0)
			local tbl4 = Split(cfg[4].model_show, ",")
			self.model:SetMainAsset(tbl4[1], tbl4[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 5 then
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(cfg[5].model_show)
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 6 then
			self.model:SetHaloResid(0)
			local tbl6 = Split(cfg[6].model_show, ",")
			self.model:SetMainAsset(tbl6[1], tbl6[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 7 then
			self.model:SetHaloResid(0)
			local tbl7 = Split(cfg[7].model_show, ",")
			self.model:SetMainAsset(tbl7[1], tbl7[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 8 then
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(cfg[8].model_show)
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 9 then
			self.model:SetHaloResid(0)
			local tbl9 = Split(cfg[9].model_show, ",")
			self.model:SetMainAsset(tbl9[1], tbl9[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		elseif index == 10 then
			self.model:SetHaloResid(0)
			local tbl10 = Split(cfg[10].model_show, ",")
			self.model:SetMainAsset(tbl10[1], tbl10[2])
			self.is_show_recharge_icon:SetValue(false)
			self.display.animator:SetBool("Jump",false)
		end
	end
end

	-- 打开界面显示的初始值
function LeiJiRechargeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2091, 0)

	self:KaiFuTime()
	self.left_btn_show:SetValue(false)
	self.xiamian_left:SetValue(false)
	self.listcontain.scroll_rect.horizontalNormalizedPosition = 0
	self:OnBtnRecharge(1, false)
end

-- 开服时间倒计时
function LeiJiRechargeView:KaiFuTime()
	local leiji_act_open_cfg = KaifuActivityData.Instance:GetKaifuActivityOpenCfg()
	local end_day = leiji_act_open_cfg[2].end_day_idx or 0
	local end_act_day = end_day - TimeCtrl.Instance:GetCurOpenServerDay()
	self.rest_day:SetValue(end_act_day )

	if end_act_day  == 0 then
		-- {sec = 37, min = 44, day = 26, isdst = false, wday = 7, yday = 238, year = 2017, month = 8, hour = 16}
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		self.show_reset_day:SetValue(false)
		self:SetRestTime(reset_time_s)
	else
		self.rest_day:SetValue(end_act_day )
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
	self:ShowBoxIcon()
	self:ProgressValue()
	if KaifuActivityData.Instance:ShowCurIndex() ~= -1 then
		self:OnBtnRecharge(KaifuActivityData.Instance:ShowCurIndex() + 1, false)
	end
end

-- 进度条
function LeiJiRechargeView:ProgressValue()
	local cur_valur = KaifuActivityData.Instance:RechargeProgressValue()
	self.exp_radio:SetValue(cur_valur/10)
end

-- 根据flag显示箱子图标
function LeiJiRechargeView:ShowBoxIcon()
	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	local bundle1, asset1 = ResPath.GetLeiJiRechargeBoxIcon(5)   -- 已领取
	local bundle2, asset2 = ResPath.GetLeiJiRechargeBoxIcon(5)   -- 未领取

	for i=1,10 do
		if flag_cfg[chongzhi_cfg[i].seq].flag == 0 then
			self["show_box_icon" .. i]:SetAsset(bundle2, asset2)
			self["show_icon"..i]:SetValue(true)
		else
			self["show_box_icon" .. i]:SetAsset(bundle1, asset1)
			self["show_icon"..i]:SetValue(false)
		end
	end
end

--根据flag显示匹配的累充金额
function LeiJiRechargeView:ShowNum()
	for i=1,10 do
		local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(i - 1).need_chognzhi
		-- if cfg > 9999 then
		-- 	cfg = (math.floor(cfg/10000) .. "万")
		local show_cfg = CommonDataManager.ConverNum(cfg)
		self.show_num_list[i]:SetValue(show_cfg)
	end
end

-- 领取奖励按钮
function LeiJiRechargeView:OnClickGet()
	if self.cur_flag == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.cur_select - 1)
		-- self:OnBtnRecharge(KaifuActivityData.Instance:ShowCurIndex() + 1)
	end
	-- if self.cur_flag == 1 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
	-- end
end

-- 左边按钮 显示上一挡奖励 档位从0开始
function LeiJiRechargeView:OnClickLastButton()
	self.cur_select = self.cur_select - 1
	if self.cur_select < 1 then
		self.cur_select = 1
	end

	if self.cur_select <= 1 then
		self.left_btn_show:SetValue(true)
	else
		self.left_btn_show:SetValue(true)
	end
	if self.cur_select <= 10 then
		self.right_btn_show:SetValue(true)
	else
		self.right_btn_show:SetValue(false)
	end

	if self.cur_select < 6 then
		self:OnBoxClickLeftButton()
	end

	self:RechargeFlush()
	self:OnBtnRecharge(self.cur_select, false)
end

-- 右边按钮 显示下一挡奖励 档位最高9
function LeiJiRechargeView:OnClickNextButton()
	self.cur_select = self.cur_select + 1
	if self.cur_select > 10 then
		self.cur_select = 10
	end

	if self.cur_select >= 10 then
		self.right_btn_show:SetValue(false)
	else
		self.right_btn_show:SetValue(true)
	end
	if self.cur_select >= 1 then
		self.left_btn_show:SetValue(true)
	else
		self.left_btn_show:SetValue(false)
	end

	if self.cur_select > 6 then
		self:OnBoxClickRightButton()
	end
	self:RechargeFlush()
	self:OnBtnRecharge(self.cur_select, false)
end

function LeiJiRechargeView:OnValueChanged(pos)
	self.xiamian_right:SetValue(pos.x < 1)
	self.xiamian_left:SetValue(pos.x > 0.05)
end

-- 下面左边按钮
function LeiJiRechargeView:OnBoxClickLeftButton()
	self.listcontain.scroll_rect.horizontalNormalizedPosition = 0
	if self.listcontain.scroll_rect.horizontalNormalizedPosition < 0.5 then
		self.xiamian_right:SetValue(true)
		self.xiamian_left:SetValue(false)
	end
end

-- 下面右边按钮
function LeiJiRechargeView:OnBoxClickRightButton()
	self.listcontain.scroll_rect.horizontalNormalizedPosition = 1
	if self.listcontain.scroll_rect.horizontalNormalizedPosition > 0.5 then
		self.xiamian_right:SetValue(false)
		self.xiamian_left:SetValue(true)
	end
end

function LeiJiRechargeView:OnClickClose()
	self:Close()
end

-- 根据左右按钮Index刷新界面显示
function LeiJiRechargeView:RechargeFlush()
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(self.cur_select - 1)
	local money_info = KaifuActivityData.Instance:GetLeiJiChongZhiInfo()

	if cfg and money_info then
		local special_list = Split(cfg.item_special, ",")
		for i=1,3 do
			local item_data = cfg.reward_item[i - 1]
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
		self.cur_chongzhi_zuanshi:SetValue((money_info.total_charge_value or 0) .. Language.Common.ZuanShi)
		self.recharge_zuanshi:SetValue(cfg.need_chognzhi)
	end

	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	if chongzhi_cfg and chongzhi_cfg[self.cur_select] then
		if flag_cfg[chongzhi_cfg[self.cur_select].seq].flag == 0  then
			self.button_show:SetValue(Language.Activity.FlagAlreadyReceive)
		else
			self.button_show:SetValue(Language.Activity.FlagCanAlreadyReceive)
		end
		self.cur_flag = flag_cfg[chongzhi_cfg[self.cur_select].seq].flag
		self.show_get_btn:SetValue(flag_cfg[chongzhi_cfg[self.cur_select].seq].flag == 2)
		for i=1,10 do
			if flag_cfg[chongzhi_cfg[i].seq].flag == 2 then
				self["show_remin"..i]:SetValue(true)
				self.show_get_btn:SetValue(flag_cfg[chongzhi_cfg[self.cur_select].seq].flag == 2)
			else
				self["show_remin"..i]:SetValue(false)
			end
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local bundle, asset = ResPath.GetLeiJiRechargeIcon(self.cur_select)
		self.show_recharge_text:SetAsset(bundle, asset)
	end

	for i=1,10 do
		if self.cur_select == i then
			self["Toggle_Image"..i].toggle.isOn = true
		else
			self["Toggle_Image"..i].toggle.isOn = false
		end
	end
	self:ShowModel(self.cur_select)
	if cfg then
		local gifts_info = cfg.reward_item
		local cur_item_id = cfg.item_id
		local gift_id = gifts_info and gifts_info[0].item_id or 0
		local data = CommonStruct.ItemDataWrapper()
		if self.cur_select == 1 or self.cur_select == 2 or self.cur_select == 4 or self.cur_select == 7 or self.cur_select == 9 or self.cur_select == 10 then
			self.is_model:SetValue(true)
			data.item_id = cur_item_id[0].item_id
			data.param = CommonStruct.ItemParamData()
			data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
			self.is_show_zhanduli:SetValue(false)
			self.is_show_zhanduli_icon:SetValue(false)
			self.zhandouli:SetValue(EquipData.Instance:GetEquipLegendFightPowerByData(data,
			false, true, nil))
		elseif self.cur_select == 5 or self.cur_select == 8 then
			self.is_model:SetValue(true)
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == gifts_info[0].item_id then
					self.x_cfg1 = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					self.fight_power1 = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(self.x_cfg1))
					self.is_show_zhanduli:SetValue(false)
					self.is_show_zhanduli_icon:SetValue(false)
					self.zhandouli:SetValue(self.fight_power1)
				end
			end
		elseif self.cur_select == 3 or self.cur_select == 6 then
			self.is_model:SetValue(true)
			for k, v in pairs(ZhiBaoData.Instance:GetZhiBaoHuanHua()) do
				if v.stuff_id == gifts_info[0].item_id then
					self.x_cfg2 = ZhiBaoData.Instance:GetHuanHuaLevelCfg(v.huanhua_type, false, 1)
					self.fight_power2 = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(self.x_cfg2))
					self.is_show_zhanduli:SetValue(false)
					self.is_show_zhanduli_icon:SetValue(false)
					self.zhandouli:SetValue(self.fight_power2)
				end
			end
		end
	end

	if self.cur_select == 1 or self.cur_select == 7 then
		self.show_item_eff:SetValue(false)
	else
		self.show_item_eff:SetValue(true)
	end

	local cfg_pos = {
			position = Vector3(-0.01, 0.26, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(0.7, 0.7, 0.7)
		}

	local cfg_pos1 = {
			position = Vector3(0, 1.06, 0),
			rotation = Vector3(0, 10.26, 0),
			scale = Vector3(5, 5, 5)
		}
	local cfg_pos3 = {
			position = Vector3(-0.25, 0.48, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(0.6, 0.6, 0.6)
		}
	local cfg_pos4 = {
			position = Vector3(0.02, 0.02, -4.37),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(12, 12, 12)
		}
	local cfg_pos6 = {
			position = Vector3(-0.25, 0.3, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(0.6, 0.6, 0.6)
		}
	local cfg_pos7 = {
			position = Vector3(-0.1, 0.43, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(2, 2, 2)
		}
	local cfg_pos9 = {
			position = Vector3(-6.42, -1.02, -15.5),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(5, 5, 5)
		}

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.cur_select == 1 then
		self.model:SetTransform(cfg_pos1)
	elseif self.cur_select == 2 then
		self.model:SetModelTransformParameter("weapon_model", 100 ..main_role_vo.prof.. "01", DISPLAY_PANEL.FULL_PANEL)
	elseif self.cur_select == 3 then
		self.model:SetTransform(cfg_pos3)
	elseif self.cur_select == 4 then
		self.model:SetTransform(cfg_pos4)
	elseif self.cur_select == 6 then
		self.model:SetTransform(cfg_pos6)
	elseif self.cur_select == 5 then
		self.model:SetModelTransformParameter("halo_model", 9 , DISPLAY_PANEL.OPEN_FUN)
	elseif self.cur_select == 7 then
		self.model:SetTransform(cfg_pos7)
	elseif self.cur_select == 8 then
		self.model:SetModelTransformParameter("halo_model", 7 , DISPLAY_PANEL.OPEN_FUN)
	elseif self.cur_select == 9 then
		self.model:SetTransform(cfg_pos9)
	elseif self.cur_select == 10  then
		self.model:SetTransform(cfg_pos)
	end
end

-- 箱子档位
function LeiJiRechargeView:OnBtnRecharge(index, is_click)
	self.cur_select = index
	self:RechargeFlush()
	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	self.show_get_btn:SetValue(flag_cfg[chongzhi_cfg[index].seq].flag == 2)


	if self.cur_select >= 10 then
		self.right_btn_show:SetValue(false)
	else
		self.right_btn_show:SetValue(true)
	end

	if self.cur_select <= 1 then
		self.left_btn_show:SetValue(false)
	else
		self.left_btn_show:SetValue(true)
	end
	if is_click == false then
		if self.cur_select > 5 then
			self.listcontain.scroll_rect.horizontalNormalizedPosition = 1
			self.xiamian_left:SetValue(true)
			self.xiamian_right:SetValue(false)
		else
			self.listcontain.scroll_rect.horizontalNormalizedPosition = 0
			self.xiamian_left:SetValue(false)
			self.xiamian_right:SetValue(true)
		end
	end
end
