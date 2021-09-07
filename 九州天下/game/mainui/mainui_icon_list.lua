MainuiIconListView = MainuiIconListView or BaseClass(BaseView)

function MainuiIconListView:__init()
	self.ui_config = {"uis/views/main", "MainuiIconListDetail"}
	self.view_layer = UiLayer.Pop
	self.cell_list_t = {{}, {}, {}, {}}
	self.scroller_t = {}
	self.scroller_data = {}
	self.dir = 1 --1 左下 2 右上 3 左上 4 右下
end

function MainuiIconListView:__delete()

end

function MainuiIconListView:ReleaseCallBack( ... )
	for k, v in pairs(self.cell_list_t) do
		for _,v1 in pairs(v) do
			v1:DeleteMe()
		end
		self.cell_list_t[k] = {}
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.MainUIIconList)
	end

	-- 清理变量和对象
	self.panel1 = nil
	self.panel2 = nil
	self.panel3 = nil
	self.panel4 = nil
	self.change_point = nil
	self.show_down = nil
	self.show_right = nil
	self.rect = nil
	self.scroller_t = {}
end

function MainuiIconListView:LoadCallBack()
	--获取UI
	self.panel1 = self:FindObj("Panel1")
	self.panel2 = self:FindObj("Panel2")
	self.panel3 = self:FindObj("Panel3")
	self.panel4 = self:FindObj("Panel4")

	self.change_point = self:FindObj("ChangePoint")
	self.show_down = self:FindVariable("ShowBg")
	self.show_right = self:FindVariable("ShowRight")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.rect = self.change_point.transform:GetComponent(typeof(UnityEngine.RectTransform))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.MainUIIconList, BindTool.Bind(self.GetUiCallBack, self))
end

function MainuiIconListView:FlushList(dir)
	if self.scroller_t[dir] == nil then
		self.scroller_t[dir] = self:FindObj("ButtonList" .. dir)
		local scroller_delegate = self.scroller_t[dir].list_simple_delegate
		--生成数量
		scroller_delegate.NumberOfCellsDel = function()
			return #self.scroller_data or 0
		end
		--刷新函数
		scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
			data_index = data_index + 1

			local detail_cell = self.cell_list_t[dir][cell]
			if detail_cell == nil then
				detail_cell = MainuiIconDetailCell.New(cell.gameObject)
				detail_cell.list_detail_view = self
				self.cell_list_t[dir][cell] = detail_cell
			end

			detail_cell:SetIndex(data_index)
			detail_cell:SetData(self.scroller_data[data_index])
		end
	else
		self.scroller_t[dir].scroller:ReloadData(0)
	end
end

function MainuiIconListView:CloseWindow()
	self:Close()
end

function MainuiIconListView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.scroller_data = {}

	self.role_name = ""

	self.click_obj = nil

	if not self.root_node then
		return
	end
end

function MainuiIconListView:SetRoleName(name)
	self.role_name = name
end

function MainuiIconListView:SetCloseCallBack(callback)
	self.close_call_back = callback
end

function MainuiIconListView:OpenCallBack()
	local item_count = #self.scroller_data or 0
	self:ChangePanelHeight(item_count)
	self.show_down:SetValue(self.dir == 1 or self.dir == 4)
	self.show_right:SetValue(self.dir == 2 or self.dir == 4)
	self:Flush()
end

function MainuiIconListView:SetClickObj(obj, dir)
	self.click_obj = obj
	self.dir = dir or 1
end

--改变列表长度
function MainuiIconListView:ChangePanelHeight(item_count)
	local panel = self["panel" .. self.dir] or self.panel1

	local panel_width = panel.rect.rect.width
	local panel_height = 63 * item_count + 8 * (item_count - 1) + 30
	if panel_height > 400 then
		panel_height = 400
	end
	panel.rect.sizeDelta = Vector2(panel_width, panel_height)
	if not self.click_obj then
		return
	end
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local obj_world_pos = self.click_obj.transform:GetComponent(typeof(UnityEngine.RectTransform)).position
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, obj_world_pos)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	local y_dir =  (self.dir == 1 or self.dir == 4) and 1 or -1
	local_pos_tbl.y = local_pos_tbl.y - 45 * y_dir
	local_pos_tbl.x = local_pos_tbl.x

	self.rect.anchoredPosition = local_pos_tbl
end

function MainuiIconListView:SetData(data)
	self.scroller_data = data
	self:Open()
end

function MainuiIconListView:OnFlush()
	self:FlushList(self.dir)
end

function MainuiIconListView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.MainUIBossHunter or ui_name == GuideUIName.MainUIExperience then
		for k, v in pairs(self.cell_list) do
			local data = v:GetData()
			local name = data.name
			if name == Language.Mainui.BossLieShou or name == Language.Mainui.MieShiLiLian then
				if v.root_node and v.root_node.gameObject.activeInHierarchy then
					return v.root_node
				end
			end
		end
		for k, v in pairs(self.cell_list2) do
			local data = v:GetData()
			local name = data.name
			if name == Language.Mainui.BossLieShou or name == Language.Mainui.MieShiLiLian then
				if v.root_node and v.root_node.gameObject.activeInHierarchy then
					return v.root_node
				end
			end
		end
	end
end

----------------------------------------------------------------------------
--MainuiIconDetailCell 		列表滚动条格子
----------------------------------------------------------------------------

MainuiIconDetailCell = MainuiIconDetailCell or BaseClass(BaseCell)

function MainuiIconDetailCell:__init()
	self.text = self:FindVariable("Text")
	self.red = self:FindVariable("Red")
	self.list_detail_view = nil
	self:ListenEvent("Click",BindTool.Bind(self.OnButtonClick, self))
end

function MainuiIconDetailCell:__delete()
	self.list_detail_view = nil
end

function MainuiIconDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.text:SetValue(self.data.name)
	self.red:SetValue(self.data.remind ~= nil and self.data.remind > 0)
end

function MainuiIconDetailCell:OnButtonClick()
	self.list_detail_view:Close()
	self.data.callback()
end