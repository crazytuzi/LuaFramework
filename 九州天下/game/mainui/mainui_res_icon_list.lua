MainuiResIconListView = MainuiResIconListView or BaseClass(BaseView)

function MainuiResIconListView:__init()
	self.ui_config = {"uis/views/main", "MainuiResIconListDetail"}
	self.view_layer = UiLayer.Pop
	self.cell_list_t = {{}, {}, {}, {}}
	self.scroller_t = {}
	self.scroller_data = {}
	self.dir = 1 --1 左下 2 右上 3 左上 4 右下
	self.obj_list = {}
end

function MainuiResIconListView:__delete()

end

function MainuiResIconListView:ReleaseCallBack( ... )
	for k, v in pairs(self.cell_list_t) do
		for _,v1 in pairs(v) do
			v1:DeleteMe()
		end
		self.cell_list_t[k] = {}
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
	self.click_obj = nil
	self.scroller_t = {}
	self.obj_list = {}
end

function MainuiResIconListView:LoadCallBack()
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
end

function MainuiResIconListView:FlushList(dir)
	if dir == 2 then 
		self:LoadCell(dir)
	else
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
					detail_cell = MainuiResIconDetailCell.New(cell.gameObject)
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
end

function MainuiResIconListView:LoadCell(dir)
	for k, v in pairs(self.obj_list) do
		GameObject.Destroy(v)
	end
	self.obj_list = {}
	self.cell_list_t = {{}, {}, {}, {}}

	local panel = self["panel" .. dir] or self.panel1
	PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "MainuiResButton"), function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, #self.scroller_data do
			local item_cell = self.cell_list_t[dir][i]
			if item_cell == nil then
				local obj = GameObject.Instantiate(prefab)
				self.obj_list[i] = obj
				local obj_transform = obj.transform
				obj_transform:SetParent(panel.transform, false)

				local rect = obj_transform:GetComponent(
					typeof(UnityEngine.RectTransform))
				rect.anchorMax = Vector2(0, 0)
				rect.anchorMin = Vector2(0, 0)
			
				local x_s = (i % 4) == 0 and 4 or (i % 4)
				local show_x = 56 + 101 * (x_s - 1)
				local show_y = 60 + 98 * math.floor((i - 1) / 4)
				rect.anchoredPosition3D = Vector3(show_x, show_y, 0)
				rect.sizeDelta = Vector2(0, 0)

				item_cell = MainuiResIconDetailCell.New(obj)
				item_cell.list_detail_view = self
				self.cell_list_t[dir][i] = item_cell
			end
			item_cell:SetIndex(i)
			item_cell:SetData(self.scroller_data[i])
		end
	end)
end

function MainuiResIconListView:CloseWindow()
	self:Close()
end

function MainuiResIconListView:CloseCallBack()
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

function MainuiResIconListView:SetRoleName(name)
	self.role_name = name
end

function MainuiResIconListView:SetCloseCallBack(callback)
	self.close_call_back = callback
end

function MainuiResIconListView:OpenCallBack()
	local item_count = #self.scroller_data or 0
	self:ChangePanelHeight(item_count)
	self.show_down:SetValue(self.dir == 1 or self.dir == 4)
	self.show_right:SetValue(self.dir == 2 or self.dir == 4)
	self:Flush()
end

function MainuiResIconListView:SetClickObj(obj, dir)
	self.click_obj = obj
	self.dir = dir or 1
end

--改变列表长度
function MainuiResIconListView:ChangePanelHeight(item_count)
	local panel = self["panel" .. self.dir] or self.panel1

	local panel_width = 0
	local panel_height = 120

	if item_count > 4 then 
		panel_width = 93 * 4 + 8 * (4 - 1) + 20
		panel_height = 101 * math.floor((item_count - 1) / 4) + panel_height
	else
		panel_width = 93 * item_count + 8 * (item_count - 1) + 20
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
	local_pos_tbl.y = local_pos_tbl.y - 60 * y_dir
	local x_dir = (self.dir == 1 or self.dir == 3) and 1 or -1
	local_pos_tbl.x = local_pos_tbl.x + 30 * x_dir

	self.rect.anchoredPosition = local_pos_tbl
end

function MainuiResIconListView:SetData(data)
	self.scroller_data = data
	self:Open()
end

function MainuiResIconListView:OnFlush()
	self:FlushList(self.dir)
end

----------------------------------------------------------------------------
--MainuiResIconDetailCell 		列表滚动条格子
----------------------------------------------------------------------------

MainuiResIconDetailCell = MainuiResIconDetailCell or BaseClass(BaseCell)

function MainuiResIconDetailCell:__init()
	self.res = self:FindVariable("Res")
	self.red = self:FindVariable("Red")
	self.eff = self:FindVariable("ShowEffect")
	self.list_detail_view = nil
	self:ListenEvent("Click",BindTool.Bind(self.OnButtonClick, self))
end

function MainuiResIconDetailCell:__delete()
	self.list_detail_view = nil
end

function MainuiResIconDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.res:SetAsset(ResPath.GetMainUIButton(self.data.res))
	self.eff:SetValue(self.data.show_eff or false)
	self.red:SetValue(self.data.remind ~= nil and self.data.remind > 0)
end

function MainuiResIconDetailCell:OnButtonClick()
	self.list_detail_view:Close()
	self.data.callback()
end
