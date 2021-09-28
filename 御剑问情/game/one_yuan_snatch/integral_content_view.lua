IntegralContentView = IntegralContentView or BaseClass(BaseRender)

local display_List = {

}

local display_prof_List = {
	[1] = "huanzhuangshop_fashion_panel_jian2",
	[2] = "huanzhuangshop_fashion_panel_dao",
	[4] = "huanzhuangshop_fashion_panel_guzheng",
	[3] = "huanzhuangshop_fashion_panel_shanzi2",
}

local default_display = {
	[DISPLAY_TYPE.MOUNT] = "one_yuan_snatch_mount_panel",
	[DISPLAY_TYPE.WING] = "one_yuan_snatch_wing_panel",
	[DISPLAY_TYPE.FOOTPRINT] = "one_yuan_snatch_foot_panel",
	[DISPLAY_TYPE.FASHION] = "one_yuan_snatch_fashion_panel",
	[DISPLAY_TYPE.HALO] = "one_yuan_snatch_halo_panel",
	[DISPLAY_TYPE.SPIRIT] = "one_yuan_snatch_spirit_panel",
	[DISPLAY_TYPE.FIGHT_MOUNT] = "huanzhuangshop_fight_mount_panel2",
	[DISPLAY_TYPE.SHENGONG] = "huanzhuangshop_shengong_panel2",
	[DISPLAY_TYPE.SHENYI] = "one_yuan_snatch_shenyi_panel",
	[DISPLAY_TYPE.XIAN_NV] = "one_yuan_snatch_xian_nv_panel",
	[DISPLAY_TYPE.ZHIBAO] = "huanzhuangshop_zhibao_panel",
	[DISPLAY_TYPE.GENERAL] = "one_yuan_snatch_tianshen_panel",
}


function IntegralContentView:__init(instance)
	self.cell_list = {}
	
	self.need_jifen = self:FindVariable("need_jifen")
	self.cur_jifen = self:FindVariable("cur_jifen")
	self.cost_money = self:FindVariable("get_jifen1")
	self.get_jifen = self:FindVariable("get_jifen2")

	self.btn_obj = self:FindObj("BuyButton")
	self.btn_text = self:FindVariable("BuyText")
	
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("ExChangeClick",BindTool.Bind(self.ExChangeClick,self))
end

function IntegralContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
	end
	self.cell_list = nil
end

function IntegralContentView:CloseCallBack()
	-- body
end

function IntegralContentView:OpenCallBack()
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO )

	self:Flush()
end

function IntegralContentView:OnFlush()
	if self.list_view and self.list_view.scroller then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
	end

	self:InitPanel()
end

function IntegralContentView:GetNumberOfCells()
	return OneYuanSnatchData.Instance:GetIntergralNum() or 0
end

function IntegralContentView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cfg = OneYuanSnatchData.Instance:GetIntergralGroupIndexCfg(data_index)
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = SnatchCellGroup.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell.view_type = "integral"
		the_cell:SetData(cfg)
	end
end

function IntegralContentView:InitPanel()
	local cfg = OneYuanSnatchData.Instance:GetMaxScoreCfg()
	local convert_info = OneYuanSnatchData.Instance:GetCloudPurchaseConvertInfo()
	local other_cfg = OneYuanSnatchData.Instance:GetOtherCfg()

	if cfg then	
		self.need_jifen:SetValue(cfg.cost_score or 0)
		local item_data = OneYuanSnatchData.Instance:ParseIntergralItemId(cfg.item_id or 0)
		if item_data and item_data.item_id then
			self:ChangeModel(self.model, item_data.item_id, nil, self)
		end

		self.btn_text:SetValue(Language.OneYuanSnatch.ExChange)
		self.btn_obj.grayscale.GrayScale = 0

		local item_info = OneYuanSnatchData.Instance:PurchaseConvertInfoByItemId(item_data.item_id)

		if item_info and item_info.convert_count and item_info.convert_count >= cfg.convert_count_limit then
			self.btn_text:SetValue(Language.OneYuanSnatch.isExChange)
			self.btn_obj.grayscale.GrayScale = 255		
		end

	end

	if convert_info then
		self.cur_jifen:SetValue(convert_info.score or 0)
	end

	if other_cfg and other_cfg[1] then
		local num = other_cfg[1].score_per_gold or 0
		num = num * (other_cfg[1].ticket_gold_price or 0)
		self.get_jifen:SetValue(num)
	end


	
end

function IntegralContentView:ExChangeClick()
	local cfg = OneYuanSnatchData.Instance:GetMaxScoreCfg()
	if cfg and cfg.seq then

		OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT, cfg.seq, 1)
		-- end	
	end	
end


function IntegralContentView:ChangeModel(model, item_id, item_id2, cell)
	local cfg = OneYuanSnatchData.Instance:GetItemIdCfg(item_id)

	if cfg == nil then
		return
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

		if tonumber(weapon_res_id) == 0 then
			weapon_res_id = main_role:GetWeaponResId()
			weapon2_res_id = main_role:GetWeapon2ResId()
		end

		model:SetRoleResid(res_id)
		model:SetWeaponResid(weapon_res_id)
		if weapon2_res_id then
			model:SetWeapon2Resid(weapon2_res_id)
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
	elseif display_role == DISPLAY_TYPE.GENERAL then
		res_id = OneYuanSnatchData.Instance:GreateSoldierImagId(item_id)
		bundle, asset = ResPath.GetGeneralRes(res_id)
	end

	if panel_name == "" then
		panel_name = default_display[display_role] or ""
	end

	model:SetPanelName(panel_name)

	if bundle and asset and model then
		model:SetMainAsset(bundle, asset)
	end

end

