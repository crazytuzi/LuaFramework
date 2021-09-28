TitleShopView = TitleShopView or BaseClass(BaseView)


local display_List = {
	[7017001] = "huanzhuangshop_IceLong",
	[910202001] = "huanzhuangshop_fashion_panel_shanzi",
	[910101901] = "huanzhuangshop_fashion_panel_jian",
	[7119001] = "huanzhuangshop_fight_mount_motan",
	[11103] = "huanzhuangshop_xian_nv_women",
	[1101001] = "huanzhuangshop_fashion_panel_jian2",
	[1001001] = "huanzhuangshop_fashion_panel_dao",
	[1002001] = "huanzhuangshop_fashion_panel_guzheng",
	[1102001] = "huanzhuangshop_fashion_panel_shanzi2",
}

local default_display = {
	[DISPLAY_TYPE.MOUNT] = "huanzhuangshop_mount_panel2",
	[DISPLAY_TYPE.WING] = "huanzhuangshop_wing_panel2",
	[DISPLAY_TYPE.FOOTPRINT] = "huanzhuangshop_foot_panel2",
	[DISPLAY_TYPE.FASHION] = "huanzhuangshop_fashion_panel2",
	[DISPLAY_TYPE.HALO] = "huanzhuangshop_halo_panel2",
	[DISPLAY_TYPE.SPIRIT] = "huanzhuangshop_spirit_panel2",
	[DISPLAY_TYPE.FIGHT_MOUNT] = "huanzhuangshop_fight_mount_panel2",
	[DISPLAY_TYPE.SHENGONG] = "huanzhuangshop_shengong_panel2",
	[DISPLAY_TYPE.SHENYI] = "huanzhuangshop_shenyi_panel2",
	[DISPLAY_TYPE.XIAN_NV] = "huanzhuangshop_xian_nv_panel2",
	[DISPLAY_TYPE.ZHIBAO] = "huanzhuangshop_zhibao_panel",
}

function TitleShopView:__init()
	self.ui_config = {"uis/views/randomact/huanzhuangshop_prefab", "TitleShopView"}
	self.play_audio = true
	self.cell_list = {}
end

function TitleShopView:__delete()

end

function TitleShopView:LoadCallBack()
	self.show_type = 0
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))

	self:ListenEvent("OpenTab1",
		BindTool.Bind(self.OnClickTab, self, 1))

	self:ListenEvent("OpenTab2",
		BindTool.Bind(self.OnClickTab, self, 0))

	self.toggle = {}
	self.toggle[0] = self:FindObj("toggle2").toggle
	self.toggle[1] = self:FindObj("toggle1").toggle

	self.act_time = self:FindVariable("ActTime")
	self.red_point = self:FindVariable("red_point")
	self:InitScroller()
end

function TitleShopView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.red_point = nil

	for i,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.toggle) do
		v = nil
	end
	self.toggle = {}
	self.cell_list = {}
end

function TitleShopView:OnClickTab(show_type)
	if self.show_type == show_type then
		return
	end
	self.show_type = show_type
	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function TitleShopView:InitScroller()
	self.scroller = self:FindObj("ListView")
	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			target_cell = HuanZhuangTitleShopCell.New(cell.gameObject)
			self.cell_list[cell] = target_cell
			target_cell:SetFlushModelValue(true)
			target_cell:SetIndex(data_index)
		else
			target_cell:SetFlushModelValue(false)
		end
		target_cell:SetShowType(self.show_type)
		target_cell:SetData(self.data[data_index])
		target_cell:Flush()
	end
end

function TitleShopView:OpenCallBack()
	self:Flush()
end

function TitleShopView:ShowIndexCallBack(index)
	self.toggle[index].isOn = true
	self:OnClickTab(index)
end

function TitleShopView:CloseCallBack()

end

function TitleShopView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			local data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
			for k2,v2 in pairs(self.cell_list) do
				v2:SetData(data[v2:GetIndex()])
				v2:Flush("FlsuhData")
			end
		else
			if self.scroller then
				self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end
	self.red_point:SetValue(HuanzhuangShopData.Instance:TitleShopPoint() > 0)
end

function TitleShopView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end

function TitleShopView.ChangeModel(model, item_id, item_id2, cell)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end

	if cell then
		cell:UpAni(false)
	end

	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	local panel_name = ""

	if model then
		local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
		if display_role ~= DISPLAY_TYPE.FOOTPRINT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
		end
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end

		panel_name = display_List[res_id] and display_List[res_id] or ""

	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				-- bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		model:SetRoleResid(main_role:GetRoleResId())
		model:SetWingResid(res_id)

	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetFootResid(res_id)
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		local fashion_part_type = 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..game_vo.prof..game_vo.sex]
				else
					weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
				fashion_part_type = v.part_type or -1
			end

		end
		if res_id == 0 then
			res_id = main_role:GetRoleResId()
		end

		if fashion_part_type == SHIZHUANG_TYPE.WUQI then
			bundle, asset = ResPath.GetWeaponModel(weapon_res_id)
			panel_name = display_List[res_id] and display_List[res_id] or ""
		else
			if tonumber(weapon_res_id) == 0 then
				weapon_res_id = main_role:GetWeaponResId()
				weapon2_res_id = main_role:GetWeapon2ResId()
			end

			model:SetRoleResid(res_id)
			model:SetWeaponResid(weapon_res_id)
			if weapon2_res_id then
				model:SetWeapon2Resid(weapon2_res_id)
			end
		end

		if cell then
			cell:UpAni(fashion_part_type == SHIZHUANG_TYPE.WUQI)
		end

	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetHaloResid(res_id)

	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id and v.item_id== item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end

		if res_id == 10033001 then	-- 特殊处理松鼠
			model:SetTrigger(ANIMATOR_PARAM.REST)
		else
			model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end

	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end

		panel_name = display_List[res_id] and display_List[res_id] or ""
		model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				bundle, asset = ResPath.GetGoddessModel(role_res_id)
				info.weapon_res_id = v.res_id
				model:SetGoddessModelResInfo(info)
				model:SetPanelName(default_display[display_role] or "")
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.wing_res_id = v.res_id
				model:SetGoddessModelResInfo(info)
				model:SetPanelName(default_display[display_role] or "")
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
				-- self:SetModel(info)
				-- return
			end
			res_id = xiannv_resid
		end

		if display_List[res_id] then
			model:SetTrigger(ANIMATOR_PARAM.ATTACK2)
		else
			model:SetTrigger(ANIMATOR_PARAM.ATTACK1)
		end

		panel_name = display_List[res_id] and display_List[res_id] or ""

	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == item_id then
				bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
				res_id = v.image_id
				break
			end
		end
	end

	if panel_name == "" then
		panel_name = default_display[display_role] or ""
	end

	model:SetPanelName(panel_name)

	if bundle and asset and model then
		model:SetMainAsset(bundle, asset)
	end

end

---------------------------------------------------------------
--滚动条格子

HuanZhuangTitleShopCell = HuanZhuangTitleShopCell or BaseClass(BaseRender)

function HuanZhuangTitleShopCell:__init()
	self.show_type = 0
	self.flush_model = true
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	self.dis_obj = self:FindObj("dis_obj")
	self.model_ani = self:FindObj("model")
	self.name = self:FindVariable("name")
	self.cost_text = self:FindVariable("cost_text")
	self.power = self:FindVariable("power")
	self.show_buy = self:FindVariable("show_buy")
	self.is_show_title = self:FindVariable("is_show_title")
	self.title_id = self:FindVariable("title_id")
	self.can_click = self:FindVariable("can_click")
	self.get_btn_text = self:FindVariable("get_btn_text")
	self.fetch_btn_text = self:FindVariable("fetch_btn_text")
	self.recharge_num = self:FindVariable("recharge_num")
	self.display = self:FindObj("display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self:FlushModel()
end

function HuanZhuangTitleShopCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function HuanZhuangTitleShopCell:SetShowType(show_type)
	self.show_type = show_type
end

function HuanZhuangTitleShopCell:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			self:FlushAttr()
		else
			self:FlushAttr()
			self:FlushModel()
		end
	end
end

function HuanZhuangTitleShopCell:FlushAttr()
	if nil == self.data then
		return
	end

	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local magic_shop_buy_flag = bit:d2b(info.magic_shop_buy_flag)
	local magic_shop_fetch_reward_flag = bit:d2b(info.magic_shop_fetch_reward_flag)
	local magic_shop_chongzhi_value = info.magic_shop_chongzhi_value

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	self.name:SetValue(item_cfg.name)
	self.show_buy:SetValue(self.show_type == 1)
	self.is_show_title:SetValue(self.show_type == 0)
	self.power:SetValue(self.data.power)
	if 1 == self.show_type then
		local num = 1 == magic_shop_buy_flag[32 - self.data.index] and 0 or 1
		self.can_click:SetValue(num >= 1)
		self.recharge_num:SetValue(self.data.need_gold)
		self.cost_text:SetValue(self.data.need_gold)
		self.get_btn_text:SetValue(num >= 1 and Language.Common.CanPurchase or Language.Common.AlreadyPurchase)
	else
		self.title_id:SetAsset(ResPath.GetTitleIcon(item_cfg.param1))
		local str = magic_shop_chongzhi_value < self.data.need_gold and Language.Common.WEIDACHENG or (0 == magic_shop_fetch_reward_flag[32 - self.data.index] and Language.Common.KeLingQu or Language.Common.YiLingQu)
		self.fetch_btn_text:SetValue(str)
		self.can_click:SetValue(magic_shop_chongzhi_value >= self.data.need_gold and 0 == magic_shop_fetch_reward_flag[32 - self.data.index])
		self.recharge_num:SetValue(self.data.need_gold)
	end
end

function HuanZhuangTitleShopCell:SetData(data)
	self.data = data
end

function HuanZhuangTitleShopCell:SetIndex(index)
	self.index = index
end

function HuanZhuangTitleShopCell:GetIndex()
	return self.index
end

function HuanZhuangTitleShopCell:SetFlushModelValue(value)
	self.flush_model = value
end

function HuanZhuangTitleShopCell:FlushModel()
	-- if not self.flush_model then
	-- 	return
	-- end
	if 1 == self.show_type then
		local tbl = Split(self.data.item_show, ",")
		if #tbl == 1 then
			TitleShopView.ChangeModel(self.model, tonumber(tbl[1]), nil, self)
		elseif tbl[3] then
			if tonumber(tbl[3]) == 0 then
				self.model:SetPanelName("huanzhuang_shop_panel_1")
				self.model:SetMainAsset(tbl[1], tbl[2])
			elseif tonumber(tbl[3]) == 1 then
				self.model:ClearModel()
			end
		end
	end
end

function HuanZhuangTitleShopCell:OnClick()
	local opera_type = 0
	if self.show_type == 0 then
		opera_type = HuanzhuangShopData.OPERATE.RECHARGE
	else
		opera_type = HuanzhuangShopData.OPERATE.BUY
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, opera_type, self.data.index)
end

function HuanZhuangTitleShopCell:UpAni(state)
	self.model_ani.animator.enabled = state
	self.dis_obj:SetActive(not state)
end



