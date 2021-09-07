LianXuChongZhiChu = LianXuChongZhiChu or BaseClass(BaseRender)

function LianXuChongZhiChu:__init()
	--self:InitListView()
end

function LianXuChongZhiChu:__delete()
	if self.cell_list then
		for _, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.cell_list = {}
end

function LianXuChongZhiChu:LoadCallBack()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	self.rest_time = self:FindVariable("RestTime")
	self.today_coin_gao = self:FindVariable("ToDayChongZhi")
	self.num_today_gao = self:FindVariable("NumTodayGao")
	self.capability = self:FindVariable("Capability")
	self:ListenEvent("OnRecharBtn", BindTool.Bind(function()
		ViewManager.Instance:Open(ViewName.RechargeView)
	end, self))
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.show_foot_camera = self:FindVariable("show_foot_camera")
	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_display = self:FindObj("foot_display")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	self.foot_display.ui3d_display:Display(ui_foot.gameObject, camera)
	if not IsNil(camera) then
		 camera.transform.localPosition = Vector3(67.87, 5.3, -664.5)
		 ui_foot.gameObject.transform.localPosition = Vector3(68, 0, -665)
	end

	self:Flush()
end

function LianXuChongZhiChu:OnFlush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local wuqi_id_1 = 950000101 + main_role_vo.prof * 100000  
	local res_id = 1200001 + main_role_vo.prof * 1000


	-- self.model:SetWeaponResid(wuqi_id_1)
	-- self.model:SetWeapon2Resid(wuqi_id_2)
	-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HALO], res_id, DISPLAY_PANEL.CHONGZHITEHUI_CHU)

	self.rest_time:SetValue(KaifuActivityData.Instance:GetActivityOpenDayLianChong(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU))
	local info_gao = KaifuActivityData.Instance:GetChongZhiChu()
	local max_num = 0
	local today_num = max_num
	if nil ~= info_gao then
		local cfg = KaifuActivityData.Instance:ChongZhiTeHuiChu() or {}
		local check_value = info_gao.continue_chongzhi_days
		local need_check = true
		for k,v in pairs(cfg) do
			if v ~= nil then
				if max_num < v.day_index then
					max_num = v.day_index
				end
				
				if need_check then
					if info_gao.continue_chongzhi_days < v.day_index then
						check_value = v.day_index
						need_check = false
					elseif info_gao.continue_chongzhi_days == v.day_index then
						need_check = false
					end
				end
			end
		end

		self.num_today_gao:SetValue(info_gao.continue_chongzhi_days)
		self.today_coin_gao:SetValue(info_gao.today_chongzhi)
		today_num = check_value < max_num and check_value or max_num
	end

	local tehuichu = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	local now_config = {}
	for k,v in pairs(tehuichu) do
		if v.day_index == today_num then
			now_config.path = v.path
			now_config.name = v.name
			now_config.power = v.power
			now_config.model_type = v.model_type
			break
		end
	end
	local main_role = Scene.Instance:GetMainRole()
	if next(now_config) then
		if now_config.model_type == 3 then
			self.show_foot_camera:SetValue(true) 
			self:SetFootModle("Foot_"..now_config.name)
		elseif now_config.model_type == 1 then
			self.model:SetMainAsset(now_config.path, now_config.name)
		elseif now_config.model_type == 2 then

			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetMantleResid(now_config.name)
		elseif now_config.model_type == 4 then

			local scale = Vector3(0.5, 0.5, 0.5)
			self.model:SetModelScale(scale)
			self.model:SetDisplayPositionAndRotation("lian_xu_chong_zhichu4")
			self.model:SetMainAsset(now_config.path, now_config.name)
		elseif now_config.model_type == 5 then

			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(now_config.name)
		elseif now_config.model_type == 6 then
			
			local bundle, asset = ResPath.GetGoddessNotLModel(11101)
			self.model:SetMainAsset(bundle, asset)
			self.model:SetHaloResid(now_config.name, true)
		else
			self.model:SetMainAsset(now_config.path, now_config.name)
		end
		self.capability:SetValue(now_config.power)
	end
end


function LianXuChongZhiChu:GetNumberOfCells()
	return #KaifuActivityData.Instance:ChongZhiTeHuiChu()
end

function LianXuChongZhiChu:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ChongZhiItemCellGroupChu.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	local index = cell_index + 1
	local item_id_group = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	local data = item_id_group[index]
	shop_cell:SetIndex(index)
	shop_cell:SetData(data)
end

function LianXuChongZhiChu:FlushView()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	self:Flush()
end

function LianXuChongZhiChu:SetFootModle(res_id)
		for i = 1, 3 do
			local bundle, asset = ResPath.GetFootEffec(res_id)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
				if nil == prefab then
					return
				end
				local parent_transform = self.foot_parent[i].transform
				if parent_transform then
					for j = 0, parent_transform.childCount - 1 do
						GameObject.Destroy(parent_transform:GetChild(j).gameObject)
					end
					local obj = GameObject.Instantiate(prefab)
					local obj_transform = obj.transform
					obj_transform:SetParent(parent_transform, false)
					PrefabPool.Instance:Free(prefab)
				end
			end)
		end
end

-----------------------------ChongZhiItemCellGroupChu--------------------------
ChongZhiItemCellGroupChu = ChongZhiItemCellGroupChu or BaseClass(BaseRender)

function ChongZhiItemCellGroupChu:__init()
	self.cell_list = {}
	local cell = ChongZhitemCellChu.New(self:FindObj("item"))
	table.insert(self.cell_list, cell)
end

function ChongZhiItemCellGroupChu:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChongZhiItemCellGroupChu:SetToggleGroup()

end

function ChongZhiItemCellGroupChu:SetData(data)
	self.cell_list[1]:SetData(data)
end

function ChongZhiItemCellGroupChu:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------ChongZhitemCellChu--------------------------
ChongZhitemCellChu = ChongZhitemCellChu or BaseClass(BaseCell)
function ChongZhitemCellChu:__init()
	self.leiji_day = self:FindVariable("leiji_day")
	self.chongzhi_coin = self:FindVariable("chongzhi_coin")
	self.button_lq = self:FindVariable("button_lq")
	self.button_cz = self:FindVariable("button_cz")
	self.button_ylq = self:FindVariable("button_ylq")
	self:ListenEvent("button_lingqu", BindTool.Bind(self.OnClickLingQu, self))
	self:ListenEvent("button_chongzhi", BindTool.Bind(self.OnClickChongZhi, self))
	for i = 1,3 do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self:FindObj("picture_" .. i))
		self["item_cell_" .. i]:ShowHighLight(false)
	end
end

function ChongZhitemCellChu:__delete()
	for i = 1,3 do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function ChongZhitemCellChu:OnClickLingQu()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function ChongZhitemCellChu:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ChongZhitemCellChu:OnFlush()
	local item_num = KaifuActivityData.Instance:GetChongZhiChu()
	local can_fetch_reward_flag = bit:d2b(item_num.can_fetch_reward_flag)
	local has_fetch_reward_falg = bit:d2b(item_num.has_fetch_reward_falg)
	if nil == item_num then
		return
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 0 then
		self.button_lq:SetValue(false)
		self.button_cz:SetValue(true)
		self.button_ylq:SetValue(false)
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 1 then
		if has_fetch_reward_falg[32 - self.data.day_index] == 0 then
			self.button_lq:SetValue(true)
			self.button_cz:SetValue(false)
			self.button_ylq:SetValue(false)
		end
		if has_fetch_reward_falg[32 - self.data.day_index] == 1 then
			self.button_lq:SetValue(false)
			self.button_cz:SetValue(false)
			self.button_ylq:SetValue(true)
		end
	end

	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)

	for i=1,3 do
		if self.data.if_open_show == 0 then
			self["item_cell_" .. i]:SetData(item_group[i])
			self["item_cell_" .. i]:SetShowRedPoint(false)
		else
			self["item_cell_" .. i]:SetData(self.data.reward_item)
			self["item_cell_" .. i]:SetItemActive(i == 1)
		end
	end

	self.leiji_day:SetValue(self.data.day_index)
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tehuigao = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	for k, v in pairs(tehuigao) do
		if open_sever_day <= v.open_server_day then
			self.chongzhi_coin:SetValue(v.need_chongzhi)
			return
		end
	end

end