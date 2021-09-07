TipsDiMaiCampBuffView = TipsDiMaiCampBuffView or BaseClass(BaseView)

function TipsDiMaiCampBuffView:__init()
	self.ui_config = {"uis/views/tips/dimaitips", "CampBuffTips"}
	self.play_audio = true
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
end

function TipsDiMaiCampBuffView:__delete()
end

function TipsDiMaiCampBuffView:ReleaseCallBack()
	if self.name_cell_list and next(self.name_cell_list) then
		for _,v in pairs(self.name_cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.name_cell_list = {}
	end

	self.view_data = nil
	self.scroller = nil
	self.attr_obj = nil
	self.show_name = nil
end

function TipsDiMaiCampBuffView:LoadCallBack()
	self.name_cell_list = {}

	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))

	self.scroller = self:FindObj("NameList")
	local name_view_delegate = self.scroller.list_simple_delegate
	name_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNameListNumberOfCells, self)
	name_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNameListView, self)

	self.attr_obj = self:FindObj("AttrObj")

	self.show_name = self:FindVariable("ShowName")
end

function TipsDiMaiCampBuffView:GetNameListNumberOfCells()
	if self.view_data then
		return #self.view_data
	end
	return 0
end

function TipsDiMaiCampBuffView:RefreshNameListView(cell, data_index)
	data_index = data_index + 1
	local item_cell = self.name_cell_list[cell]
	if item_cell == nil then
		item_cell = DesItemCell.New(cell.gameObject)
		self.name_cell_list[cell] = item_cell
	end
	item_cell:SetIndex(data_index)
	item_cell:SetData(self.view_data[data_index])
end

function TipsDiMaiCampBuffView:OnFlush()
	if self.view_data then
		self.show_name:SetValue(#self.view_data <= 0)

		local total_attr = CommonStruct.Attribute()
		for i = 1, #self.view_data do
			if self.view_data[i].uid ~= 0 then
				CheckCtrl.Instance:SendQueryRoleInfoReq(self.view_data[i].uid)
			end

			local camp_buff_cfg = DiMaiData.Instance:GetDiMaiCampBuffCfg(self.view_data[i].layer, self.view_data[i].point)
			if camp_buff_cfg then
				camp_buff_cfg = CommonDataManager.GetAttributteByClass(camp_buff_cfg)
				total_attr = CommonDataManager.AddAttributeAttr(total_attr, camp_buff_cfg)
			end
		end
		
		total_attr = CommonDataManager.GetAttributteNoUnderline(total_attr)
		CommonDataManager.SetRoleAttr(self.attr_obj, total_attr, nil)
			
		self:FlushScroller()
	end
end

function TipsDiMaiCampBuffView:SetData(data)
	self.view_data = data
	self:Flush()
end

function TipsDiMaiCampBuffView:OnClickClose()
	self:Close()
end

function TipsDiMaiCampBuffView:FlushScroller()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end

---------------DesItemCell--------------
DesItemCell = DesItemCell or BaseClass(BaseCell)

function DesItemCell:__init()
	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
	self.role_name = self:FindVariable("RoleName")
	self.scene_name = self:FindVariable("SceneName")
end

function DesItemCell:__delete()
	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end
end

function DesItemCell:OnFlush()
end

function DesItemCell:RoleInfoCallBack(uid, info)
	if self.data then
		if self.data.uid == uid then
			local dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(self.data.layer, self.data.point)
			if dimai_info_cfg then
				local map_name = dimai_info_cfg.dimai_name
				self.scene_name:SetValue(map_name or "")
				local camp_name = CampData.Instance:GetCampNameByCampType(info.camp_id, true, false, false)
				if camp_name then
					self.role_name:SetValue(camp_name .. info.role_name)
				end
			end
		end
	end
end