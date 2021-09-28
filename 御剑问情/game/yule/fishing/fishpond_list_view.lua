FishPondListView = FishPondListView or BaseClass(BaseView)

local ROW = 2
local COLUMN = 3
function FishPondListView:__init()
    self.ui_config = {"uis/views/yuleview_prefab", "FishPondListView"}
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function FishPondListView:__delete()

end

function FishPondListView:RemindChangeCallBack()

end

function FishPondListView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.list_view = nil
	self.show_left = nil
	self.show_right = nil
end

function FishPondListView:LoadCallBack()
	self.show_left = self:FindVariable("ShowLeft")
	self.show_right = self:FindVariable("ShowRight")

	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickLeft", BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickRight", BindTool.Bind(self.ClickRight, self))
end

function FishPondListView:OnValueChanged()
	self:UpDatePageBtn()
end

function FishPondListView:GetMaxCellNum()
	local per_oage_num = ROW * COLUMN
	local real_count = math.ceil(#self.list_data/per_oage_num) * per_oage_num
	return real_count
end

function FishPondListView:RefreshCellList(data_index, cell)
	data_index = data_index + 1
	local pond_cell = self.cell_list[cell]
	if nil == pond_cell then
		pond_cell = FishPondItemCell.New(cell.gameObject)
		self.cell_list[cell] = pond_cell
	end
	pond_cell:SetIndex(data_index)
	pond_cell:SetData(self.list_data[data_index])
end

function FishPondListView:CloseWindow()
	self:Close()
end

function FishPondListView:ClickLeft()
	local now_page = self.list_view.list_page_scroll2:GetNowPage()
	if now_page > 0 then
		self.list_view.list_page_scroll2:JumpToPage(now_page - 1)
	end
end

function FishPondListView:ClickRight()
	local now_page = self.list_view.list_page_scroll2:GetNowPage()
	local max_page_count = math.ceil(#self.list_data / (ROW * COLUMN))
	if now_page < max_page_count - 1 then
		self.list_view.list_page_scroll2:JumpToPage(now_page + 1)
	end
end

function FishPondListView:OpenCallBack()
	self:Flush()
end

function FishPondListView:CloseCallBack()
	
end

function FishPondListView:UpDatePageBtn()
	local now_page = self.list_view.list_page_scroll2:GetNowPage()
	local max_page_count = math.ceil(#self.list_data / (ROW * COLUMN))
	if now_page == 0 then
		self.show_left:SetValue(false)
		self.show_right:SetValue(true)
	elseif now_page == max_page_count - 1 then
		self.show_left:SetValue(true)
		self.show_right:SetValue(false)
	else
		self.show_left:SetValue(true)
		self.show_right:SetValue(true)
	end
end

function FishPondListView:OnFlush()
	local general_info = FishingData.Instance:GetWorldGeneralInfo()
	if nil == general_info then
		return
	end

	self.list_data = general_info

	local max_page_count = math.ceil(#self.list_data / (ROW * COLUMN))
	self.list_view.list_page_scroll2:SetPageCount(max_page_count)

	self.list_view.list_view:Reload()
	self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	self:UpDatePageBtn()
end


---------------FishPondItemCell----------------------------
FishPondItemCell = FishPondItemCell or BaseClass(BaseCell)

function FishPondItemCell:__init()
	self.role_name = self:FindVariable("RoleName")
	self.fish_name = self:FindVariable("FishName")
	self.time_des = self:FindVariable("TimeDes")
	self.set_visible = self:FindVariable("SetVisible")

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function FishPondItemCell:__delete()
	self:ClearCountDown()
end

function FishPondItemCell:OnFlush()
	if nil == self.data then
		self.set_visible:SetValue(false)
		return
	end
	self.set_visible:SetValue(true)

	self.role_name:SetValue(self.data.owner_name)
	local fish_info = FishingData.Instance:GetFishInfoByQuality(self.data.fish_quality)
	if nil == fish_info then
		return
	end
	local fish_name = ToColorStr(fish_info.fish_name, FISH_NAME_COLOR[self.data.fish_quality])
	self.fish_name:SetValue(fish_name)

	--计算成熟时间
	self:StartCountDown(fish_info)
end

function FishPondItemCell:Click()
	ViewManager.Instance:Close(ViewName.FishPondListView)
	FishingData.Instance:SetNowFishPondUid(self.data.owner_uid)
	FishingData.Instance:SetNowFishList(self.data)
	--刷新池塘
	ViewManager.Instance:FlushView(ViewName.YuLeView, "enter_other", {true})
end

function FishPondItemCell:ClearCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FishPondItemCell:StartCountDown(fish_info)
	self:ClearCountDown()

	local server_times = TimeCtrl.Instance:GetServerTime()
	local fang_yu_times = self.data.fang_fish_time
	local need_times = fish_info.need_time
	local left_time = need_times - (server_times - fang_yu_times)
	if left_time <= 0 then
		--已成熟
		self.time_des:SetValue(Language.Fishpond.HasFarmDes)
	else
		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:ClearCountDown()
				self.time_des:SetValue(Language.Fishpond.HasFarmDes)
				return
			end
			local times = math.ceil(total_time - elapse_time)
			local time_str = TimeUtil.FormatSecond(times)
			local des = string.format(Language.Fishpond.NotHasFarmDes, time_str)
			self.time_des:SetValue(des)
		end
		self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
		local time_str = TimeUtil.FormatSecond(left_time)
		local des = string.format(Language.Fishpond.NotHasFarmDes, time_str)
		self.time_des:SetValue(des)
	end
end