local ROW = 3
local LOW = 5
local MAX_NUM = 15

PrayDepotCellItem = PrayDepotCellItem  or BaseClass(BaseCell)

function PrayDepotCellItem:__init()
	self.depot_item_list = {}
	for i = 1, BEAUTY_COLUMN do
		local handler = function()
			local close_call_back = function()
				self.depot_item_list[i].depot_item:SetToggle(false)
				self.depot_item_list[i].depot_item:ShowHighLight(false)
			end
			if self.depot_item_list[i].depot_item:GetData().item_id ~= nil then
				self.depot_item_list[i].depot_item:ShowHighLight(true)
			else
				self.depot_item_list[i].depot_item:SetToggle(false)
				self.depot_item_list[i].depot_item:ShowHighLight(false)
			end
			local treasure_depot = BeautyPrayView.Instance
			TipsCtrl.Instance:OpenItem(self.depot_item_list[i].depot_item:GetData(), TipsFormDef.FROM_BAOXIANG, nil, close_call_back)
		end
		self.depot_item_list[i] = {}
		self.depot_item_list[i].depot_item = ItemCell.New()
		self.depot_item_list[i].depot_item:SetInstanceParent(self:FindObj("item_" .. i))
		self.depot_item_list[i].grid_index = 0
		self.depot_item_list[i].depot_item:ListenClick(handler)
	end
end

function PrayDepotCellItem:__delete()
	self.depot_item_list = {}

	for k, v in ipairs(self.depot_item_list) do
		v.depot_item:DeleteMe()
	end

	self.depot_item_list = {}
end

function PrayDepotCellItem:SetGridIndex(grid_index_list)
	for i = 1, BEAUTY_COLUMN do
		local depot_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
		self.depot_item_list[i].depot_item:SetData(depot_item)
		self.depot_item_list[i].grid_index = grid_index_list[i]
	end
end

function PrayDepotCellItem:SetToggleGroup(toggle_group)
	for i = 1, BEAUTY_COLUMN do
		self.depot_item_list[i].depot_item:SetToggleGroup(toggle_group)
	end
end

function PrayDepotCellItem:OnFlushItem()
	for i = 1, BEAUTY_COLUMN do
		local depot_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
		self.depot_item_list[i].depot_item:SetData(depot_item)
	end
end


PrayRewardCellItem = PrayRewardCellItem  or BaseClass(BaseCell)
function PrayRewardCellItem:__init(instance, parent)
	self.parent = parent
	self.reward_item_list = {}
	for i = 1, ROW do
		local handler = function()
			local replace_view = TipsCtrl.Instance:GetPetBagView()
			replace_view:SetCurGrid(self.reward_item_list[i].grid_index)
			replace_view:SetItemId(self.reward_item_list[i].reward_item:GetData().item_id)
			if self.reward_item_list[i].reward_item:GetData().item_id ~= nil then
				self.reward_item_list[i].reward_item:ShowHighLight(true)
			end
			local callback = function ()
				self.reward_item_list[i].reward_item:ShowHighLight(false)
			end

			TipsCtrl.Instance:OpenItem(self.reward_item_list[i].reward_item:GetData(),nil ,nil ,callback)
		end
		self.reward_item_list[i] = {}
		self.reward_item_list[i].reward_item = ItemCell.New()
		self.reward_item_list[i].reward_item:SetInstanceParent(self:FindObj("item_" .. i))

		self.reward_item_list[i].grid_index = 0
		self.reward_item_list[i].reward_item:ListenClick(handler)
	end
end

function PrayRewardCellItem:__delete()
	self.reward_item_list = {}

	for k, v in ipairs(self.reward_item_list) do
		v.reward_item:DeleteMe()
	end

	self.reward_item_list = {}
end

function PrayRewardCellItem:ItemCellClick()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	replace_view:SetCurGrid(self.reward_item_list[i].grid_index)
	replace_view:SetAllHL()

end

function PrayRewardCellItem:SetGridIndex(grid_index_list)
	local show_list = BeautyData.Instance:GetRawardReview()
	for i = 1, ROW do
		local item_info = show_list[grid_index_list[i]]
		if item_info then
			self.reward_item_list[i].reward_item:SetData(item_info.reward_item)
			if grid_index_list[i] <= 6 then
				self.reward_item_list[i].reward_item:IsDestoryActivityEffect(false)
				self.reward_item_list[i].reward_item:SetActivityEffect()
			else
				self.reward_item_list[i].reward_item:IsDestoryActivityEffect(true)
				self.reward_item_list[i].reward_item:SetActivityEffect()
			end
			self.reward_item_list[i].reward_item:ShowHighLight(false)
			self.reward_item_list[i].grid_index = grid_index_list[i]
		end
	end
end

function PrayRewardCellItem:SetItemHL()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	for i=1, ROW do
		if self.reward_item_list[i].grid_index == replace_view:GetCurGrid() and nil ~= self.reward_item_list[i].reward_item:GetData().item_id then
			self.reward_item_list[i].reward_item:ShowHighLight(true)
		else
			self.reward_item_list[i].reward_item:ShowHighLight(false)
		end
	end
end

function PrayRewardCellItem:SetToggleGroup(toggle_group)
	for i = 1, ROW do
		self.reward_item_list[i].reward_item:SetToggleGroup(toggle_group)
	end
end


BeautyUpIconCell = BeautyUpIconCell or BaseClass(BaseCell)
BeautyUpIconCell.SelectHuanhuaIndex = 1
	
function BeautyUpIconCell:__init(instance)
	self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))

	--美人名字
	self.beauty_name = self:FindVariable("IconName")
	-- 提示红点
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.red_flag = false
end

function BeautyUpIconCell:__delete()
	self.red_flag = false
end

function BeautyUpIconCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function BeautyUpIconCell:OnFlush()
	if nil == self.data then return end
	self.root_node.toggle.isOn = BeautyUpIconCell.SelectHuanhuaIndex == self.index
	self.beauty_name:SetValue(self.data.name)

	if self.show_red_point ~= nil then
		self.show_red_point:SetValue(self.red_flag)
	end
end	

function BeautyUpIconCell:OnIconBtnClick()
	self.root_node.toggle.isOn = true
	BeautyUpIconCell.SelectHuanhuaIndex = self.index
	self:OnClick()
end

function BeautyUpIconCell:SetRedFlag(value)
	self.red_flag = value
end

-- 美人任务Item
BeautyTaskItem = BeautyTaskItem or BaseClass(BaseCell)
function BeautyTaskItem:__init(instance)
	self:ListenEvent("OnGoToBtn", BindTool.Bind(self.OnGoToBtnHandle, self))
	self:ListenEvent("OnFastBtn", BindTool.Bind(self.OnFastBtnHandle, self))

	self.text = self:FindVariable("Text")
	self.show_button = self:FindVariable("ShowButton")
	self.is_finsh = self:FindVariable("IsFinsh")
	self.btn_str = self:FindVariable("BtnStr")
	self.show_red = self:FindVariable("ShowRed")
end

function BeautyTaskItem:__delete()

end

function BeautyTaskItem:OnFlush()
	if nil == self.data then return end
	local str = self.data.desc
	if self.data.task_type == BEAUTY_TASK_TYPE.KILL or self.data.task_type == BEAUTY_TASK_TYPE.CAMP_JUNGONG then
		local num = BeautyData.Instance:GetTaskNum(self.data.task_type)
		str = string.format(str, num)
	end

	if self.data.task_type == BEAUTY_TASK_TYPE.DAY_TASK then
		str = string.format(str, DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT))
	end
	self.text:SetValue(str)
	--self.show_button:SetValue(true)

	if BeautyData.Instance:GetBeautyTaskFlag(self.data.task_type) == 1 then
		local check_is_finsh = BeautyData.Instance:GetWishIsFinsh(self.data.task_type)
		local is_get = BeautyData.Instance:GetWishIsCanRecharge(self.data.task_type)
		local b_str = Language.Beaut.WishBtnGo
		if check_is_finsh and not is_get then
			b_str = Language.Beaut.WishBtnGet
		elseif check_is_finsh and is_get then
			b_str = Language.Beaut.WishBtnFinsh
		end

		if self.btn_str ~= nil then
			self.btn_str:SetValue(b_str)
		end

		if self.is_finsh ~= nil then
			self.is_finsh:SetValue(check_is_finsh and is_get)
		end

		if self.show_red ~= nil then
			self.show_red:SetValue(check_is_finsh and not is_get)
		end
	end
end	

--前往完成
function BeautyTaskItem:OnGoToBtnHandle()
	if nil == self.data then return end
	local check_is_finsh = BeautyData.Instance:GetWishIsFinsh(self.data.task_type)
	local is_get = BeautyData.Instance:GetWishIsCanRecharge(self.data.task_type)
	if check_is_finsh then
		if not is_get then
			BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_TASK_FETCH_REWARD, self.data.task_type)
		end
	else
		if self.data.open_type == 0 or self.data.open_type == 3 then
			local t = Split(self.data.open_panel, "#")
			local view_name = t[1]
			local tab_index = t[2]
			ViewManager.Instance:Open(view_name, TabIndex[tab_index])
			if self.data.open_type == 3 then
				ViewManager.Instance:Close(ViewName.Beauty)
			end
		elseif self.data.open_type == 1 then
			TipsCtrl.Instance:ShowSystemMsg(self.data.open_panel)
		elseif self.data.open_type == 2 then
			if TaskData.Instance:GetDailyTaskInfo() then
				local task_data = {}
				task_id = TaskData.Instance:GetDailyTaskInfo().task_id
				task_data.task_id = task_id
				task_data.task_status = TaskData.Instance:GetTaskStatus(task_id)
				local task_view = MainUICtrl.Instance:GetView():GetTaskView()
				if task_view then
					task_view:OperateTask(task_data)
					BeautyCtrl.Instance:CloseView()
				end
			end
		end
	end
end

--快速完成
function BeautyTaskItem:OnFastBtnHandle()
	if nil == self.data then return end
	local function ok_callback()
		BeautyCtrl:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_TASK_QUICK_COMPELTE, self.data.task_type)
	end
	local des = string.format(Language.Beaut.WishFastTip, self.data.quick_complete_gold)
	TipsCtrl.Instance:ShowCommonAutoView("beauty_task", des, ok_callback)
end


BeautyNameCell = BeautyNameCell or BaseClass(BaseCell)
function BeautyNameCell:__init(instance)
	self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))

	self.name = self:FindVariable("IconName")
	self.show_red = self:FindVariable("ShowRedPoint")
	self.red_flag = false
end

function BeautyNameCell:__delete()
	self.red_flag = false
end

function BeautyNameCell:SetToggleGroup(group, bool)
	self.root_node.toggle.group = group
	self.root_node.toggle.isOn = bool
end

function BeautyNameCell:SetToggleOn(index)
	self.root_node.toggle.isOn = self.index == index
end

function BeautyNameCell:OnFlush()
	if nil == self.data then return end
	local info = BeautyData.Instance:GetBeautyActiveInfo(self.index - 1)
	if info then
		self.name:SetValue(info.name)
	end

	if self.show_red ~= nil then
		self.show_red:SetValue(self.red_flag)
	end
end	

function BeautyNameCell:OnIconBtnClick()
	self:OnClick()
end

function BeautyNameCell:SetRedFlag(value)
	self.red_flag = value
end