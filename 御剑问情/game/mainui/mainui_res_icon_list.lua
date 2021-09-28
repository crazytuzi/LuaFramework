MainuiResIconListView = MainuiResIconListView or BaseClass(BaseView)

function MainuiResIconListView:__init()
	self.ui_config = {"uis/views/main_prefab", "MainuiResIconListDetail"}
	self.view_layer = UiLayer.MainUIHigh
	self.cell_list_t = {{}, {}, {}, {}}
	self.scroller_t = {}
	self.scroller_data = {}
	self.dir = 1 --1 左下 2 右上 3 左上 4 右下
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
	self.scroller_t = {}
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
	if self.scroller_t[dir] == nil then
		self.scroller_t[dir] = self:FindObj("ButtonList" .. dir)
		local scroller_delegate = self.scroller_t[dir].page_simple_delegate
		--生成数量
		scroller_delegate.NumberOfCellsDel = function()
			return math.ceil(#self.scroller_data / 4) * 4
		end
		--刷新函数
		scroller_delegate.CellRefreshDel = function(data_index, cell)
			local grid_index = math.floor(data_index / 4) * 4 + (4 - data_index % 4)

			local detail_cell = self.cell_list_t[dir][cell]
			if detail_cell == nil then
				detail_cell = MainuiResIconDetailCell.New(cell.gameObject)
				detail_cell.list_detail_view = self
				self.cell_list_t[dir][cell] = detail_cell
			end

			detail_cell:SetIndex(grid_index)
			detail_cell:SetData(self.scroller_data[grid_index])
			detail_cell.root_node:SetActive(self.scroller_data[grid_index] ~= nil)
		end
	end
	self.scroller_t[dir].list_view:Reload()
	self.scroller_t[dir].list_view:JumpToIndex(0)
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
	local row = item_count < 4 and item_count or 4
	local col = math.max(math.ceil(item_count / 4), 1)
	local panel_width = 93 * row + 8 * (row - 1) + 20
	local panel_height = 93 * col + 8 * (col - 1) + 30

	panel.rect.sizeDelta = Vector2(panel_width, panel_height)
	if not self.click_obj then
		self:Close()
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
	-- local x_dir = (self.dir == 1 or self.dir == 3) and 1 or -1
	-- local_pos_tbl.x = local_pos_tbl.x + 30 * x_dir

	self.rect.anchoredPosition = local_pos_tbl
end

function MainuiResIconListView:SetData(data)
	self.scroller_data = data
	if self.click_obj then
		self:Open()
	end
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
	self.text = self:FindVariable("textRes")
	self.list_detail_view = nil
	self:ListenEvent("Click",BindTool.Bind(self.OnButtonClick, self))
end

function MainuiResIconDetailCell:__delete()
	self.list_detail_view = nil
end

function MainuiResIconDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	if self.data.res and self.data.res ~= "" then
		self.res:SetAsset(ResPath.GetMainUI(self.data.res))
		self.text:SetAsset(ResPath.GetMainUI(self.data.res .. "_text"))
	end

	self.eff:SetValue(self.data.show_eff or false)
	if self.data.func == "appearance" then
		self.red:SetValue(self.data.remind)
	else
		self.red:SetValue(self.data.remind ~= nil and self.data.remind > 0)
	end
end

function MainuiResIconDetailCell:OnButtonClick()
	self.list_detail_view:Close()
	self.data.callback()
end