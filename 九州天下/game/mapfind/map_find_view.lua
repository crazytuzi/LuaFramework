MapFindView = MapFindView or BaseClass(BaseView)

local MapFindFlushSlideMaxNumber = 0

function MapFindView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {"uis/views/mapfind", "MapFind"}
	self.play_audio = true
	self:SetMaskBg()
end

function MapFindView:LoadCallBack()
	self.reward_item_root = self:FindObj("RewardItem")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.reward_item_root)
	self.items = {}
	self.flush_item = {}
	for i = 1, 6 do
		self.items[i] = self:FindObj("Item" .. i)
		self.flush_item[i] = MapFlushItem.New(self.items[i])
	end
	self.list = self:FindObj("List")
	self.free_times_value = self:FindVariable("FreeTimes")
	self.flush_time = self:FindVariable("FlushTime")
	self.end_time_value = self:FindVariable("EndTime")
	self.slider = self:FindVariable("Slider")
	self.find_spend = self:FindVariable("FindSpend")
	self.show_spend = self:FindVariable("ShowSpend")
	self.flush_map_cost = self:FindVariable("FlushMapCost")
	self.flush_map_cost = self:FindVariable("FlushMapCost")
	self.has_get = self:FindVariable("HasGet")
	self.camp = {}
	self.find_item = {}
	self.names = {}
	self.routes = {}
	for i = 1, 3 do
		self.camp[i] = self:FindVariable("Camp" .. i)
		self.find_item[i] = self:FindObj("FindItem" .. i)
		self.find_item[i] = FindItem.New(self.find_item[i], self)
		self.names[i] = self:FindVariable("Name" .. i)
		self.routes[i] = self:FindVariable("Route" .. i)
	end
	self.in_rush_value = self:FindVariable("InRush")
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickRushFlush", BindTool.Bind(self.ClickRushFlush, self))
	self:ListenEvent("ClickReward", BindTool.Bind(self.ClickReward, self))
	self:ListenEvent("ClickFlush", BindTool.Bind(self.ClickFlush, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self.cell_list = {}
	self.list_simple_delegate = self.list.list_simple_delegate
	self.list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.flush_times_value = self:FindVariable("FlushTimes")
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function MapFindView:ReleaseCallBack()
	self.reward_item_root = nil
	self.flush_times_value = nil
	self.list = nil
	self.free_times_value = nil
	self.flush_time = nil
	self.slider = nil
	self.camp = nil
	self.in_rush_value = nil
	self.list_simple_delegate = nil
	self.day_range = nil
	self.names = nil
	self.end_time_value = nil
	self.find_spend = nil
	self.show_spend = nil
	self.flush_map_cost = nil
	self.routes = nil
	if self.reward_item then
		self.reward_item:DeleteMe()
	end
	self.reward_item = nil

	for k, v in pairs(self.flush_item) do
		v:DeleteMe()
	end
	self.flush_item = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	for k, v in pairs(self.find_item) do
		v:DeleteMe()
	end
	self.find_item = nil

	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end
	self.count = nil

	if self.count1 then
		CountDown.Instance:RemoveCountDown(self.count1)
	end
	self.count1 = nil

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function MapFindView:OpenCallBack()
	MapFindCtrl.Instance:SendInfo()
	self.in_rush = false
	self.list.scroller:RefreshAndReloadActiveCellViews(true)
end

function MapFindView:CloseCallBack()
end

function MapFindView:OnFlush()
	self:ConstructData()
end

function MapFindView:GetNumberOfCells()
	return MapFindData.Instance:GetRouteNumber()
end

--滚动条刷新
function MapFindView:RefreshView(cell, data_index)
	local left_cell = self.cell_list[cell]
	if left_cell == nil then
		left_cell = MapRewardItem.New(cell.gameObject)
		self.cell_list[cell] = left_cell
	end
	left_cell:SetIndex(data_index)
	left_cell:SetData(self.day_range)
end

function MapFindView:CloseView()
	self:Close()
end

function MapFindView:OnItemDataChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_MAP_HUNT_BAST_REWARD then
		local get_num = new_num - old_num
		TipsCtrl.Instance:OpenGuildRewardView({item_id = change_item_id, num = get_num})
	end
end

function MapFindView:ClickRushFlush()
	if self.in_rush then
		MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH, MapFindData.Instance:GetSelect(), 0)
	else
		ViewManager.Instance:Open(ViewName.MapfindRushView)
	end
end

function MapFindView:ClickReward()
	ViewManager.Instance:Open(ViewName.MapFindRewardView)
end

function MapFindView:ClickFlush()
	local flush_spend = MapFindData.Instance:GetMapFlushSpend()
	local str = string.format(Language.MapFind.FlushSpend, flush_spend)
	TipsCtrl.Instance:ShowCommonAutoView("map_find_flush_spend", str, function ()
		MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH)
	end)
end

function MapFindView:ClickHelp()
	local tips_id = 223
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MapFindView:ConstructData()
	local data = MapFindData.Instance
	self.city_route = data:GetMapCampDataByDayRange(data:GetRouteIndex())
	-- MapFindFlushSlideMaxNumber = self.flush_items_data[#self.flush_items_data].need_flush_count
	-- MapFindFlushSlideMaxNumber = MapFindFlushSlideMaxNumber + MapFindFlushSlideMaxNumber * 0.2
	self.free_times = data:GetFreeTimes()
	self.next_time_flush = data:GetNextFlushTime()
	self.route_info = data:GetRouteInfo()
	local now_time = TimeCtrl.Instance:GetServerTime()
	self.end_time = ActivityData.Instance:GetActivityStatus()[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT].end_time - now_time
	self:SetDataView()
	self.flush_map_cost:SetValue(data:GetMapFlushSpend())
end

function MapFindView:GetFreeFindTime()
	return self.free_times
end

function MapFindView:SetDataView()


	self.reward_item:SetData(self.city_route.reward_item)
	self.in_rush_value:SetValue(self.in_rush)

	self:SetSlider()
	self:FlushDataView()
	for i, v in ipairs(self.camp) do
		v:SetAsset(ResPath.GetImgWorldMap(self.city_route["city_" .. i]))
		self.names[i]:SetValue(MapFindData.Instance:GetNameById(self.city_route["city_" .. i]))
	end

	for k, v in pairs(self.find_item) do
		v:SetData(k)
	end
	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end
	self.count = nil
	if self.count1 then
		CountDown.Instance:RemoveCountDown(self.count1)
	end
	self.count1 = nil
	self.count1 = CountDown.Instance:AddCountDown(self.end_time, 1, function ()
		self.end_time = self.end_time - 1
		local end_time = TimeUtil.FormatSecond2DHMS(self.end_time - 1, 1)
		self.end_time_value:SetValue(end_time)
	end)


	self.count = CountDown.Instance:AddCountDown(self.next_time_flush, 1, function ()
		self.next_time_flush = self.next_time_flush - 1
		local next_time_flush = TimeUtil.FormatSecond(self.next_time_flush - 1)
		self.flush_time:SetValue(next_time_flush)
	end)

	self:ShowView()
end

function MapFindView:ShowView()
	self.show_spend:SetValue(self.free_times == 0)
	if self.free_times == 0 then
		self.find_spend:SetValue(MapFindData.Instance:GetMapFindSpend())
	else
		self.free_times_value:SetValue(self.free_times)
	end
	for k, v in pairs(self.routes) do
		v:SetValue(MapFindData.Instance:GetActiveFlag(k) == 1)
	end
	if MapFindData.Instance:GetActiveFlag(3) == 1 then
		self.has_get:SetValue(true)
		local bunble, asset = ResPath.GetItemActivityEffect()
		self.reward_item:SetSpecialEffect(bunble, asset)
	else
		self.has_get:SetValue(false)
	end
end

function MapFindView:SetSlider()
	self.flush_items_data = MapFindData.Instance:GetFlushDataByOpenday()
	local data = MapFindData.Instance
	local flush_times = data:GetFlushTimes()
	local length = 20
	local total_length = 140
	local fill_length = 0
	local last_count = 0
	for k, v in pairs(self.flush_items_data) do
		if flush_times < v.need_flush_count then
			fill_length = (flush_times - last_count) / (v. need_flush_count - last_count) * length + fill_length
			break
		else
			last_count = v.need_flush_count
			fill_length = fill_length + length
		end
	end
	if flush_times > self.flush_items_data[#self.flush_items_data].need_flush_count then
		fill_length = (flush_times - last_count) / (1.1 * last_count) * length + fill_length
	end

	self.slider:SetValue(fill_length / total_length)
	self.flush_times_value:SetValue(ToColorStr(flush_times, TEXT_COLOR.GREEN))
end


function MapFindView:FlushDataView()
	self.flush_items_data = MapFindData.Instance:GetFlushDataByOpenday()
	self:SetFlushDataView()
end

function MapFindView:SetFlushDataView()
	local flush_times = MapFindData.Instance:GetFlushTimes()
	for i, v in ipairs(self.flush_item) do
		v:SetData(self.flush_items_data[i])
		if flush_times >= self.flush_items_data[i].need_flush_count then
			v:ShowView(true)
		else
			v:ShowView(false)
		end
	end
end


-------------------------地图奖励-----------
MapRewardItem = MapRewardItem or BaseClass(BaseCell)

function MapRewardItem:__init()
	self.item_root = self:FindObj("Item")
	self.images = {}
	self.names = {}
	for i = 1, 3 do
		self.images[i] = self:FindVariable("Image" .. i)
		self.names[i] = self:FindVariable("Name" .. i)
	end
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.item_root)
end

function MapRewardItem:__delete()
	self.item:DeleteMe()
end

function MapRewardItem:SetData(day_range)
	local data_index = self:GetIndex()
	local data = MapFindData.Instance:GetMapCampDataByDayRange(data_index + 1)

	for i = 1, 3 do
		self.images[i]:SetAsset(ResPath.GetImgWorldMap(data["city_" .. i]))
		self.names[i]:SetValue(MapFindData.Instance:GetNameById(data["city_" .. i]))
	end

	self.item:SetData(data.reward_item)
end


----------------------------地图累刷------------

MapFlushItem = MapFlushItem or BaseClass(BaseRender)

function MapFlushItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.root_node)
	self.text = self:FindVariable("text")
	self.show_eff = self:FindVariable("ShowEff")
	self.have_got = self:FindVariable("Have_got")
	self.show_red = self:FindVariable("showRed")
end

function MapFlushItem:__delete()
	self.item:DeleteMe()
end

function MapFlushItem:SetData(data)
	self.reward_item = data.reward_item
	self.item:SetData(data.reward_item)
	self.item.root_node.transform:SetSiblingIndex(0)
	self.text:SetValue(data.need_flush_count)
	self.index = data.index
	-- self.got =
	-- local width = self.root_node.transform.parent.rect.width
	-- local pos_x = (data.need_flush_count / MapFindFlushSlideMaxNumber) * width
	-- local pos = self.root_node.rect.anchoredPosition3D
	-- pos.x = pos_x
	-- self.root_node.rect.anchoredPosition3D = pos
end

function MapFlushItem:ShowView(show_eff)
	self.show_eff:SetValue(show_eff)
	if MapFindData.Instance:GotReward(self.index) == 1 then
		self.show_red:SetValue(false)
		self.show_eff:SetValue(false)
		self.have_got:SetValue(true)
		self.item:ClearItemEvent()
	else
		self.have_got:SetValue(false)
		local click_func = nil
		if show_eff then
		self.show_red:SetValue(show_eff)
			click_func = function()
				self.item:SetHighLight(false)
				MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FETCH_RETURN_REWARD, self.index)
				AudioService.Instance:PlayRewardAudio()
			end
		else
			click_func = function()
				TipsCtrl.Instance:OpenItem(self.reward_item)
				self.item:SetHighLight(false)
			end
		end
		self.item:ListenClick(click_func)
	end
end


------------------------寻找奖励
FindItem = FindItem or BaseClass(BaseRender)

function FindItem:__init(instance, parent)
	self.parent = parent
	self.Finded = self:FindVariable("Finded")
	self.map = self:FindVariable("map")
	self.name = self:FindVariable("Name")
	self:ListenEvent("ClickFind", BindTool.Bind(self.ClickFind, self))
	self.is_rare = self:FindVariable("IsRare")
	self.index = 0
	self.is_show_effect = self:FindVariable("ShowEffect")
end

function FindItem:__delete()
	self.parent = nil
end

function FindItem:SetData(data)
	local route_info = MapFindData.Instance:GetRouteInfo()
	if route_info then
		self.index = route_info.city_list[data]
		self.map:SetAsset(ResPath.GetImgWorldMap(route_info.city_list[data]))
		self.name:SetValue(MapFindData.Instance:GetNameById(route_info.city_list[data]))

		local fetch = MapFindData.Instance:GetFetchFlag(data)
		self.Finded:SetValue(fetch == 1)
		local is_rare = MapFindData.Instance:IsRareMap(self.index)
		self.is_rare:SetValue(is_rare)

		local find_times = self.parent:GetFreeFindTime() or 0
		self.is_show_effect:SetValue((find_times > 0 and fetch ~= 1) or (is_rare and fetch ~= 1))
	end
end

function FindItem:ClickFind()
	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_HUNT, self.index)
end
