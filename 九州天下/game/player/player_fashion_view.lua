------------------------------------------------------------
--人物时装View
------------------------------------------------------------
PlayerFashionView = PlayerFashionView or BaseClass(BaseRender)

function PlayerFashionView:__init()
	self.scroller_select_number = 1
	self.scroller_select_type = SHIZHUANG_TYPE.BODY
	self.select_fashion = {}
	self.cell_list = {}
	self.cur_index = 1
	self.ison_item = false
	self.equip_cell = {}
	self.show_btn = {}
	self.is_dismount = true
	self.cur_mount = 0
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.cur_fashion_list = FashionData.Instance:GetCurIndex()
end

function PlayerFashionView:__delete()
	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange()
	end
	if self.attr_tips then
		self.attr_tips:DeleteMe()
		self.attr_tips = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.equip_cell) do
		v:DeleteMe()
	end
	self.equip_cell = {}
	self.show_btn = {}
	self.cur_mount = 0
	self.is_dismount = true

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function PlayerFashionView:CloseCallBack()
	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange()
	end
end

function PlayerFashionView:LoadCallBack(instance)
	--总属性Tips面板
	self.attr_tips = AttrTips.New(self:FindObj("FashionTips"))
	self.attr_tips:SetActive(false)
	--总属性按钮
	self:ListenEvent("ShowAttrTips", BindTool.Bind(self.ShowAttrTips, self))
	self:ListenEvent("DressClick", BindTool.Bind(self.DressClick, self))
	self:ListenEvent("UnLoadClick", BindTool.Bind(self.OnUnLoadClick, self))
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("OnCloseAttrTips", BindTool.Bind(self.OnCloseAttrTips, self))
	self:ListenEvent("OnDismountBtn", BindTool.Bind(self.OnDismountBtn, self))

	--按钮
	self.is_active = self:FindVariable("IsActive")
	self.is_can_dress = self:FindVariable("IsDressed")
	self.desc = self:FindVariable("Desc")
	self.dismount_text = self:FindVariable("DismountText")
	self.display = self:FindObj("Display")
 
    for i = 1, 4 do
    	self.show_btn[i] = self:FindVariable("IsShowBtn"..i)
    	self:ListenEvent("OnClose"..i, BindTool.Bind(self.OnClose, self, i))
    end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}}
	for k,v in pairs(vo.appearance) do
		self.temp_vo.appearance[k] = v
	end

	self.temp_vo.appearance.halo_used_imageid = 0
	self.temp_vo.appearance.wing_used_imageid = 0
	local data = WingData.Instance:GetWingInfo()
	if data  and data.used_imageid then
		self.temp_vo.appearance.wing_used_imageid  = data.used_imageid
	end

	self.cell_list = {}
	self.list_data = FashionData.Instance:GetShowMasterCollectInfo()
	self.icon_list = self:FindObj("IconListView")

	local list_view_delegate = self.icon_list.list_simple_delegate
	--生成数量
	list_view_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	--刷新函数
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	local bunble, asset = ResPath.GetImages("bg_cell_equip")
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetItemCellBg(bunble, asset)
		item:ListenClick(BindTool.Bind(self.OnClickFashionItem, self, i))
		self.equip_cell[i] = item
	end
    
	self.red_point_list = {
		[RemindName.PlayerFashion] = self:FindVariable("ShowJinjieRedPoint"),
	}
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:InitScroller()
	self:UpdateItemListData()
	self:SetDismountText()
	self:FlushModel()
end

function PlayerFashionView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New("player_fashion_view")
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		self.role_model:RemoveMount()
		self.role_model:ResetRotation()
	    self.role_model:SetModelResInfo(self.temp_vo, nil, nil, nil,nil, true)
		self.role_model:SetRotation(Vector3(0, 0, 0))
		self.role_model:SetModelScale(Vector3(1, 1, 1))
	end
end

function PlayerFashionView:SetFashion(temp_vo, fashion_data)
	if self.role_model then
		self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(temp_vo, true, false, true, nil, true, nil, nil,true)
		if nil == self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI] or 0 == self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI] then
			local main_role = Scene.Instance:GetMainRole()
			self.role_model:SetWeaponResid(main_role:GetWeaponResId())
		end

		if fashion_data[SHIZHUANG_TYPE_KEY.MOUNT] then
			local mount_image_cfg = FashionData.Instance:GetMountImageidCfg(fashion_data[SHIZHUANG_TYPE_KEY.MOUNT])
			if mount_image_cfg then
				if fashion_data[SHIZHUANG_TYPE_KEY.MOUNT] >= GameEnum.MOUNT_SPECIAL_IMA_ID then
					self.role_model:SetMountResid(mount_image_cfg.res_id)
					self.role_model:SetRotation(Vector3(0, -30, 0))
					self.role_model:SetModelScale(Vector3(0.6, 0.6, 0.6))
				else
					self.role_model:RemoveMount()
			    	self.role_model:SetModelScale(Vector3(1, 1, 1))
			    	self.role_model:SetRotation(Vector3(0, 0, 0))
				end
			end
		end
		if fashion_data[SHIZHUANG_TYPE_KEY.WING] then
			local wing_image_cfg = FashionData.Instance:GetWingImageidCfg(fashion_data[SHIZHUANG_TYPE_KEY.WING])
			if wing_image_cfg then
				self.role_model:SetWingResid(wing_image_cfg.res_id)
			end			
		end
	end
end

function PlayerFashionView:UpdateItemListData()
	local item_list = FashionData.Instance:GetCurFashionList()
	for k,v in pairs(self.equip_cell) do
		if nil ~= item_list[k] and nil ~= item_list[k].item_id then
			v:SetData(item_list[k])
		else
			local bundle, asset = ResPath.GetPlayerImage("fashion_equip_bg_" .. k)
			v:SetData({})
			v:SetAsset(bundle, asset)

			if self.select_fashion ~= nil then
				self.select_fashion[k - 1] = nil
			end
		end
	end
end

function PlayerFashionView:SetClickItemData(index, item_id)
	if self.equip_cell[index] and item_id and item_id > 0 then
		self.equip_cell[index]:SetData({item_id = item_id})
	end
end

function PlayerFashionView:OnClickFashionItem(index)
	local cell = self.equip_cell[index]
	if cell and cell.data and cell.data.item_id then
		cell:OnClickItemCell(cell.data)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.TipsFashionGo)
		cell:SetHighLight(false)
	end

	self:CheckIsCanActive()
end

function PlayerFashionView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
		elseif k == "dismount" then
			self:SetDismount(true)
		elseif k == "fashion_icon" then
			self:FlushIconList()
		elseif k == "cur_fashion" then
			self:SetFashionCurData()
		end
	end	
	self.scroller_data = FashionData.Instance:GetCurItemListData()
	self.scroller.scroller:ReloadData(0)
	self.list_data = FashionData.Instance:GetShowMasterCollectInfo()
	self.icon_list.scroller:RefreshActiveCellViews()

	-- if self.scroller_data and self.scroller_data[self.scroller_select_number + 1] then
	-- 	self:SetShowDress(self.scroller_data[self.scroller_select_number + 1].item_id, self.scroller_select_number)
	-- end
	for i = 1, 4 do
		if self.equip_cell[i].data.item_id then
        	self.show_btn[i]:SetValue(true)
       else
       		self.show_btn[i]:SetValue(false)
       end
	end

	self:CheckIsCanActive()
end

-- function PlayerFashionView:SetShowDress(item_id, show_order, is_take_off)
-- 	if item_id == nil then return end
-- 	local is_show_dress = false
-- 	if FashionData.Instance:GetCurFashionList() and FashionData.Instance:GetCurFashionList()[show_order + 1] and item_id == FashionData.Instance:GetCurFashionList()[show_order + 1].item_id then
-- 		is_show_dress = true
-- 	end

-- 	if is_take_off then
-- 		is_show_dress = false
-- 		self.is_active:SetValue(true)
-- 	end

-- 	self.is_can_dress:SetValue(is_show_dress)
-- end

function PlayerFashionView:CheckIsCanActive()
	local cur_data = FashionData.Instance:GetCurFashionList()
	local is_can = false
	if self.equip_cell ~= nil then
		for k,v in pairs(self.equip_cell) do
			if v ~= nil and v.data ~= nil then
				if cur_data[k] == nil or cur_data[k].item_id == nil then
					if v.data.item_id ~= nil and v.data.item_id > 0 then
						local is_active, value = FashionData.Instance:CheckIsActiveByItem(k - 1, v.data.item_id)
						if is_active then
							is_can = true
							break
						end	
					end
				elseif v.data.item_id == nil or v.data.item_id == 0 then
					if cur_data[k] ~= nil then
						is_can = true
						break
					end
				elseif v.data.item_id ~= cur_data[k].item_id then
					local is_active, value = FashionData.Instance:CheckIsActiveByItem(k - 1, v.data.item_id)
					if is_active then
						is_can = true
						break
					end					
				end
			end
		end
	end

	if self.is_active then
		self.is_active:SetValue(is_can)
	end
end

function PlayerFashionView:RefreshListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = FashionCellButton.New(cell.gameObject)
		cell_item:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.cell_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(self.list_data[data_index])
end

function PlayerFashionView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_index = cell.index
	PlayerData.Instance:SetFashionSelect(cell.index)
	self:FlushIconList()
	self.is_active:SetValue(false)

	local desc_cfg = FashionData.Instance:GetShowMasterCollectInfo()
	if desc_cfg ~= nil and desc_cfg[self.cur_index] ~= nil then
		FashionData.Instance:SetClickIndex(desc_cfg[self.cur_index].seq)
		self.desc:SetValue(desc_cfg[self.cur_index].suit_account)
	end
	self.ison_item = true

	self:CheckIsCanActive()
end

function PlayerFashionView:SendChangTaskRollReq()
	local desc_cfg = FashionData.Instance:GetShowMasterCollectInfo()
	if desc_cfg ~= nil and self.cur_index ~= nil and desc_cfg[self.cur_index] ~= nil then
	end
	GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_MASTER_COLLECT_ITEM_INFO, desc_cfg[self.cur_index].seq)
end

function PlayerFashionView:OnClickJinjie()
	ViewManager.Instance:Open(ViewName.PlayerFashionHuanhua, TabIndex.fashion_clothe_jinjie)
end

--刷新Icon数据
function PlayerFashionView:FlushIconList()
	if self.icon_list and self.icon_list.scroller.isActiveAndEnabled then
		self.icon_list.scroller:RefreshAndReloadActiveCellViews(true)
		self:SendChangTaskRollReq()
	end
end

--初始化滚动条
function PlayerFashionView:InitScroller()
	self.scroller_data = FashionData.Instance:GetCurItemListData()
	local desc_cfg = FashionData.Instance:GetShowMasterCollectInfo()
	if desc_cfg ~= nil and desc_cfg[self.cur_index] ~= nil then
		self.desc:SetValue(desc_cfg[self.cur_index].suit_account)
		FashionData.Instance:SetClickIndex(desc_cfg[self.cur_index].seq + 1)
	end
	
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/player_prefab", "FashionItem"), function (prefab)
		if nil == prefab then
			return
		end

		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条数量
function PlayerFashionView:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条大小
function PlayerFashionView:GetCellSize()
	return 112
end

--滚动条刷新
function PlayerFashionView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = PlayerFashionCell.New(cell_view.gameObject)
		cell = self.cell_list[cell_view]
		cell.fashion_view = self
		cell:SetClickCallBack(BindTool.Bind(self.OnClickSubCallBack, self))
	end
	cell.root_node.toggle.group = self.scroller.toggle_group
	cell:SetIndex(data_index)
	local data = self.scroller_data[data_index]
	cell:SetData(data)
	if self.ison_item then
		cell:SetToggleGroup(false)
	end
	return cell_view
end

function PlayerFashionView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function PlayerFashionView:OpenCallBack()
	self.attr_tips:SetActive(false)
	self.scroller_data = FashionData.Instance:GetCurItemListData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
	self:ClearTempVo()

	--绑定刷新函数
	self.flush_callback = BindTool.Bind(self.FlushFashion, self)
	FashionCtrl.Instance:NotifyWhenFashionChange(self.flush_callback)
	self:UpdateItemListData()
end

function PlayerFashionView:OnCloseAttrTips()
	self.attr_tips:SetActive(false)
end

--总属性面板
function PlayerFashionView:ShowAttrTips()
	if self.attr_tips.root_node.gameObject.activeSelf then
		self.attr_tips:SetActive(false)
	else
		local data = FashionData.Instance:GetFashionTotalAttribute()
		TipsCtrl.Instance:OpenGeneralView(data)
		--self.attr_tips:SetData(data)
		--self.attr_tips:SetActive(true)
	end
end

--数据改变时刷新
function PlayerFashionView:FlushFashion()
	self.scroller_data = FashionData.Instance:GetCurItemListData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
	self:FlushApperance()
end

--按下穿戴
function PlayerFashionView:DressClick()
	-- if self.scroller_select_number == SHIZHUANG_TYPE_KEY.WUQI then
	-- 	FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.WUQI, self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI] or 0)
	-- elseif self.scroller_select_number == SHIZHUANG_TYPE_KEY.BODY then
	-- 	FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.BODY, self.select_fashion[SHIZHUANG_TYPE_KEY.BODY] or 0)
	-- elseif self.scroller_select_number == SHIZHUANG_TYPE_KEY.MOUNT then
	-- 	MountCtrl.Instance:SendUseMountImage(self.select_fashion[SHIZHUANG_TYPE_KEY.MOUNT] or self.cur_mount)
	-- elseif self.scroller_select_number == SHIZHUANG_TYPE_KEY.WING then
	-- 	WingCtrl.Instance:SendUseWingImage(self.select_fashion[SHIZHUANG_TYPE_KEY.WING] or 0)
	-- end

	local check_falg = false
	self.send_num = 0
	if self.equip_cell ~= nil then
		local index_list = {}
		index_list[SHIZHUANG_TYPE_KEY.WUQI + 1] = 0
		index_list[SHIZHUANG_TYPE_KEY.BODY + 1] = 0
		mount_img_id = 0
		wing_img_id = 0

		for k, v in pairs(self.equip_cell) do
			if v ~= nil and v.data ~= nil then
				if next(v.data) ~= nil then
					local is_active, value = FashionData.Instance:CheckIsActiveByItem(k - 1, v.data.item_id)
					if is_active and value then
						if not check_falg then
							check_falg = true
						end
						local index = k - 1
						self.send_num = self.send_num + 1
						if index == SHIZHUANG_TYPE_KEY.WUQI then
							-- local function call ()
							-- 	FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.WUQI,  value or 0)
							-- end
							index_list[SHIZHUANG_TYPE_KEY.WUQI + 1] = value or 0
						elseif index == SHIZHUANG_TYPE_KEY.BODY then
							--FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.BODY, value or 0)
							index_list[SHIZHUANG_TYPE_KEY.BODY + 1] = value or 0
						elseif index == SHIZHUANG_TYPE_KEY.MOUNT then
							--MountCtrl.Instance:SendUseMountImage(value or 0)
							mount_img_id = value or 0
						elseif index == SHIZHUANG_TYPE_KEY.WING then
							--WingCtrl.Instance:SendUseWingImage(value or 0)
							wing_img_id = value or 0
						end
					end	
				else
					if not check_falg then
						check_falg = true
					end

					local index = k - 1
					self.send_num = self.send_num + 1
					if index == SHIZHUANG_TYPE_KEY.WUQI then
						--FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.WUQI,  0)
						index_list[SHIZHUANG_TYPE_KEY.WUQI + 1] = value or 0
					elseif index == SHIZHUANG_TYPE_KEY.BODY then
						--FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE_KEY.BODY, 0)
						index_list[SHIZHUANG_TYPE_KEY.BODY + 1] = value or 0
					elseif index == SHIZHUANG_TYPE_KEY.MOUNT then
						local image_id = MountData.Instance:GetCanUseImage()
						--if image_id then
							--MountCtrl.Instance:SendUseMountImage(image_id)
						--end
						mount_img_id = image_id or 0
					elseif index == SHIZHUANG_TYPE_KEY.WING then
						local image_id = WingData.Instance:GetCanUseImage()
						--if image_id then
							--WingCtrl.Instance:SendUseWingImage(image_id)
						--end
						wing_img_id = image_id or 0
					end					
				end		
			end 
		end

		FashionCtrl.Instance:SendUseFashionReq(index_list, mount_img_id, wing_img_id)
	end

	if check_falg then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.FashionSaveTips[2])
	end
end

--按下卸下
function PlayerFashionView:OnUnLoadClick()
	-- FashionCtrl.Instance:SendShizhuangUseReq(self.scroller_select_type, 0)
	-- self.select_fashion[self.scroller_select_type] = nil
end

function PlayerFashionView:ClearTempVo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}}
	for k,v in pairs(vo.appearance) do
		self.temp_vo.appearance[k] = v
	end
	self.temp_vo.appearance.halo_used_imageid = 0
	self.temp_vo.appearance.wing_used_imageid = 0
	local data = WingData.Instance:GetWingInfo()
	if data and data.used_imageid then
		self.temp_vo.appearance.wing_used_imageid  = data.used_imageid
	end
	self.select_fashion = {}
end

-- 时装滚动条格子被点选时
function PlayerFashionView:OnClickSubCallBack(cell)
	if nil == cell or nil == cell.data then
		return
	end
	self.scroller_select_number = cell.index - 1
	local data = cell.data
	local desc_cfg = FashionData.Instance:GetShowMasterCollectInfo()
	if desc_cfg == nil or desc_cfg[self.cur_index] == nil then
		return
	end

	local is_active = FashionData.Instance:GetMasterActiveFla(desc_cfg[self.cur_index].seq + 1 , FashionData.Instance:GetMasterFlaIndex(data.show_order))
	self.is_active:SetValue(is_active)
	local type_index = data.index
	if SHIZHUANG_TYPE_KEY.WING == data.show_order or SHIZHUANG_TYPE_KEY.MOUNT == data.show_order then
		type_index = type_index + GameEnum.MOUNT_SPECIAL_IMA_ID
	end
	self.select_fashion[data.show_order] = type_index 
	if data.show_order == SHIZHUANG_TYPE_KEY.MOUNT then
		self.cur_mount = type_index
	end
	self:PreView(data, data.show_order)
	self.ison_item = false
	--self:SetShowDress(data.item_id, data.show_order)
	self:SetClickItemData(cell.index , cell.stuff_id)
    self.show_btn[cell.index]:SetValue(true)
    self:CheckIsCanActive()
end

-- 预览
function PlayerFashionView:PreView(data, index)
	if self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI] then
		self.temp_vo.appearance.fashion_wuqi = self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI]
	end
	if self.select_fashion[SHIZHUANG_TYPE_KEY.BODY] then
		self.temp_vo.appearance.fashion_body = self.select_fashion[SHIZHUANG_TYPE_KEY.BODY]
	end
	self:SetFashion(self.temp_vo, self.select_fashion)

	if index == SHIZHUANG_TYPE_KEY.MOUNT then
		self:SetDismount(false)
		self:SetDismountText()
	end
end

function PlayerFashionView:FlushApperance()
	self:ClearTempVo()
	self:SetFashion(self.temp_vo, self.select_fashion)
end

function PlayerFashionView:RetButton()
	self.is_active:SetValue(false)
	self.is_can_dress:SetValue(false)
end

function PlayerFashionView:OnDismountBtn()
	if MountData.Instance:GetMountInfo().used_imageid <= 0 and self.cur_mount <= 0 then 
		SysMsgCtrl.Instance:ErrorRemind(Language.Mount.MountNotActive)
		return 
	end
	local is_imageid = true

	if self.is_dismount then
		if self.select_fashion[SHIZHUANG_TYPE_KEY.MOUNT] == nil then
			local used_imageid = MountData.Instance:GetMountInfo().used_imageid
			self.select_fashion[SHIZHUANG_TYPE_KEY.MOUNT] = self.cur_mount ~= 0 and self.cur_mount or used_imageid
		end
	else
		self.select_fashion[SHIZHUANG_TYPE_KEY.MOUNT] = nil
		self:FlushModel()
	end
	self:SetFashion(self.temp_vo, self.select_fashion, is_imageid)
	self.is_dismount = not self.is_dismount
	self:SetDismountText()
end

function PlayerFashionView:SetFashionCurData()
	self:UpdateItemListData()
	local fashion_list = FashionData.Instance:GetCurIndex()
	local is_change = false
	for i = 0, 3 do
		if self.cur_fashion_list[i] ~= fashion_list[i] then
			self.cur_fashion_list[i] = fashion_list[i]
			if nil ~= self.cur_fashion_list[i] then
				is_change = true
				self.select_fashion[i] = self.cur_fashion_list[i]
				local cur_list = FashionData.Instance:GetCurFashionList()
				if cur_list and cur_list[i + 1] then
					self:SetClickItemData(i + 1, cur_list[i + 1].item_id)
				end
			end
		end

		if i == SHIZHUANG_TYPE_KEY.MOUNT or i == SHIZHUANG_TYPE_KEY.WING then
			if self.select_fashion[i] == nil then
				self.select_fashion[i] = fashion_list[i]
				is_change = true
			end
		end

		if i == SHIZHUANG_TYPE_KEY.BODY then
			if self.select_fashion[i] == nil then
				if self.temp_vo then
					self.temp_vo.appearance.fashion_body = fashion_list[i]
					is_change = true
				end
			end			
		end
	end


	if is_change then
		self:SetFashion(self.temp_vo, self.select_fashion)
	end
end

function PlayerFashionView:SetDismountText()
	if self.is_dismount then
		self.dismount_text:SetValue(Language.Role.NoDismount)
	else
		self.dismount_text:SetValue(Language.Role.Dismount)
	end
end

function PlayerFashionView:SetDismount(bool)
	self.is_dismount = bool
	self:SetDismountText()
end

function PlayerFashionView:OnClose(index)
	local kong = {}
	self.equip_cell[index]:SetData(kong)
	self.show_btn[index]:SetValue(false)
	local bundle, asset = ResPath.GetPlayerImage("fashion_equip_bg_" .. index)
	self.equip_cell[index]:SetAsset(bundle, asset)

	-- if self.scroller_data and self.scroller_data[index] then
	-- 	self:SetShowDress(self.scroller_data[index].item_id, index, true)
	-- end

    if index == 1 then
    	self.role_model:RemoveWeapon()
		-- local main_role = Scene.Instance:GetMainRole()
		-- self.role_model:SetWeaponResid(main_role:GetWeaponResId())
    	self.temp_vo.appearance.fashion_wuqi = 0
        self.select_fashion[SHIZHUANG_TYPE_KEY.WUQI] = nil
    end
    if index == 2 then
    	self.temp_vo.appearance.fashion_body = 0
    	self.select_fashion[SHIZHUANG_TYPE_KEY.BODY] = nil
    	self:SetFashion(self.temp_vo, self.select_fashion)
    end
    if index == 3 then
    	self.role_model:RemoveMount()
    	self.select_fashion[SHIZHUANG_TYPE_KEY.MOUNT] = nil
    	self.role_model:SetModelScale(Vector3(1, 1, 1))
    	self.role_model:SetRotation(Vector3(0, 0, 0))
    	self.cur_mount = 0
    end 

    if index == 4 then
        self.role_model:RemoveWing()
    	self.select_fashion[SHIZHUANG_TYPE_KEY.WING] = nil
    end

     self:CheckIsCanActive()
end
----------------------------------------------------------------------------
--PlayerFashionCell 		时装滚动条格子
----------------------------------------------------------------------------

PlayerFashionCell = PlayerFashionCell or BaseClass(BaseCell)

local WEAPON = 0
local DRESS = 1
local MOUNT = 2
local WING = 3
function PlayerFashionCell:__init()
	self.stuff_id = 0
	self.fashion_name = self:FindVariable("FashionName")
	self.state = self:FindVariable("State")
	self.power = self:FindVariable("Power")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("BaseCell"))
	self.level = self:FindVariable("Level")
	self.attr_name_list = {}
	for i = 1, 3 do
		self.attr_name_list[i] = self:FindVariable("AttrName"..i)
	end

	self.attr_list = {}
	for i = 1, 3 do
		self.attr_list[i] = self:FindVariable("Attr"..i)
	end
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function PlayerFashionCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function PlayerFashionCell:OnFlush()
	if nil == self.data then return end
	local show_index = FashionData.Instance:GetMasterShowId(self.data.seq, self.data.item_id)
	if self.data.show_order == WEAPON then
		fashion_data = FashionData.Instance:GetFashionUpgradeCfg(show_index, WEAPON, false, self.data.level)
	elseif self.data.show_order == DRESS then
		fashion_data = FashionData.Instance:GetFashionUpgradeCfg(show_index, DRESS, false, self.data.level)
	elseif self.data.show_order == MOUNT then
		fashion_data = MountData.Instance:GetSpecialImageUpgradeInfo(show_index, self.data.level > 0 and self.data.level or 1)
	else
		fashion_data = WingData.Instance:GetSpecialImageUpgradeInfo(show_index, self.data.level > 0 and self.data.level or 1)
	end
	if fashion_data then
		if self.data.show_order == 0 or self.data.show_order == 1  then
			self.stuff_id = fashion_data.need_stuff
			self.item_cell:SetData({item_id = fashion_data.need_stuff})
			self.fashion_name:SetValue(ItemData.Instance:GetItemConfig(fashion_data.need_stuff).name)
			self.level:SetValue(fashion_data.level)
		else
			self.item_cell:SetData({item_id = fashion_data.stuff_id})
			self.stuff_id = fashion_data.stuff_id
			self.fashion_name:SetValue(ItemData.Instance:GetItemConfig(fashion_data.stuff_id).name)
			self.level:SetValue(fashion_data.grade)
		end

		local count = 1
		local attrs = CommonDataManager.GetAttributteByClass(fashion_data)
		local grade_power = CommonDataManager.GetCapabilityCalculation(attrs)
		self.power:SetValue(grade_power)
		for k,v in pairs(attrs) do
			if v > 0 then
				self.attr_name_list[count]:SetValue(CommonDataManager.GetAttrName(k)..":")
				self.attr_list[count]:SetValue(v)
				count = count + 1
			end
		end
		if count <= #self.attr_list then
			for i=count,#self.attr_list do
				self.attr_name_list[i]:SetValue("")
				self.attr_list[i]:SetValue("")
			end
		end
	end
	local is_active = FashionData.Instance:GetMasterActiveFla(self.data.seq + 1 , FashionData.Instance:GetMasterFlaIndex(self.data.show_order))
	--0未激活、1已激活、2穿戴中
	self.state:SetValue(is_active)
end

function PlayerFashionCell:SetToggleGroup(group)
	self.root_node.toggle.isOn = group
end

----------------------------------------------------------------------------
--AttrTips   		总属性Tips面板
----------------------------------------------------------------------------
AttrTips = AttrTips or BaseClass(BaseCell)

function AttrTips:__init()
	self.atk = self:FindVariable("Atk")
	self.def = self:FindVariable("Def")
	self.hp = self:FindVariable("HP")
	-- self.rat = self:FindVariable("Rat")
	self.power = self:FindVariable("Power")
end

function AttrTips:__delete()

end

function AttrTips:OnFlush()
	self.atk:SetValue(self.data["gong_ji"] or 0)
	self.def:SetValue(self.data["fang_yu"] or 0)
	self.hp:SetValue(self.data["max_hp"] or 0)
	-- self.rat:SetValue(self.data["ming_zhong"])
	self.power:SetValue(self.data.power)
end

--------------------------------------------------------------------------
--MedalScrollCell 	格子
--------------------------------------------------------------------------
FashionCellButton = FashionCellButton or BaseClass(BaseCell)
function FashionCellButton:__init(instance, left_view)
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
	self.icon = self:FindVariable("Icon")
	self.icon_select = self:FindObj("icon_select")
	self.name = self:FindVariable("Name")
	self.num = self:FindVariable("Num")
	self.info = self:FindVariable("Info")
end

function FashionCellButton:__delete()

end

function FashionCellButton:OnFlush()
	if nil == self.data then return end
	local list_data = FashionData.Instance:GetMasterShow(self.data.seq)
	local num = FashionData.Instance:GetMasterNum(self.data.seq + 1)
	if list_data then
		self.info:SetValue(num < 4 and string.format(Language.Role.FashionButtonLabel, self.data.suit_name, num .. "/" .. #list_data)
		or string.format(Language.Role.FashionButtonLabelAll, self.data.suit_name, num .. "/" .. #list_data) )
	end
	local curr_select = PlayerData.Instance:GetFashionSelect()
	self.icon_select:SetActive(curr_select == self.index)
	local bundle, asset = ResPath.GetItemIcon(self.data.dress_id)
	self.icon:SetAsset(bundle, asset)
end	
