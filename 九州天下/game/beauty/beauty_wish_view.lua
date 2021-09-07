require("game/beauty/beauty_item")
BeautyWishView = BeautyWishView or BaseClass(BaseRender)

function BeautyWishView:__init(instance)
	self.task_cell_list = {}
end

function BeautyWishView:__delete()
	if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end

	if self.task_cell_list then	
		for k,v in pairs(self.task_cell_list) do
			v:DeleteMe()
		end
		self.task_cell_list = {}
	end
end

function BeautyWishView:LoadCallBack(instance)
	self:ListenEvent("OnReachBtn", BindTool.Bind(self.OnReachBtnHandle, self))
	self:ListenEvent("OnWishReachBtn", BindTool.Bind(self.OnWishReachBtnHandle, self))

	self.display = self:FindObj("Display")
	self.heart_list = {}
	for i=1,5 do
		self.heart_list[i] = self:FindVariable("HeartGray" .. i)
	end
	self.button_gray = self:FindVariable("IsButtonGray")
	self.task_data = BeautyData.Instance:GetDayTaskList()
	self.show_btn_red = self:FindVariable("ShowBtnRed")
	self.task_list = self:FindObj("TaskList")
	local task_view_delegate = self.task_list.list_simple_delegate
	--生成数量
	task_view_delegate.NumberOfCellsDel = function()
		return #self.task_data or 0
	end
	--刷新函数
	task_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTaskListView, self)

	self:InitModel()
end

-- 初始化模型处理函数
function BeautyWishView:InitModel()
	if nil == self.model_display then
		self.model_display = RoleModel.New("beauty_panel")
		self.model_display:SetDisplay(self.display.ui3d_display)
	end
	local cur_index = BeautyData.Instance:GetDayBeautySeq()
	local model_index = 1
	if cur_index >= 100 then		--100以上是拿幻化的模型
		local huanhua_cfg = BeautyData.Instance:GetBeautyHuanhuaCfg((cur_index - 100))
		if huanhua_cfg then
			model_index = huanhua_cfg.model
		end
	else
		--local beaut_info = BeautyData.Instance:GetBeautyActive()[cur_index + 1]
		local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(cur_index)
		if beaut_info then
			model_index = beaut_info.model
		end
	end
	if self.model_display then
		local bundle, asset = ResPath.GetGoddessNotLModel(model_index)
			self.model_display:SetMainAsset(bundle, asset, function ()
			self.model_display:SetLayer(4, 1.0)
			self.model_display:SetTrigger("chuchang", false)

		end)
	end
end

function BeautyWishView:RefreshTaskListView(cell, data_index, cell_index)
	data_index = data_index + 1

	self.task_data = BeautyData.Instance:GetDayTaskList()
	local task_cell = self.task_cell_list[cell]
	if task_cell == nil then
		task_cell = BeautyTaskItem.New(cell.gameObject)
		self.task_cell_list[cell] = task_cell
	end

	task_cell:SetIndex(data_index)
	
	task_cell:SetData(self.task_data[data_index])
end

function BeautyWishView:OnFlush(param_list)
	local task_complete_count = BeautyData.Instance:GetDayTaskCompleteCount()
	for i=1, task_complete_count do
		if self.heart_list[i] then
			self.heart_list[i]:SetValue(true)
		end
	end

	self.task_list.scroller:ReloadData(0)
	self.button_gray:SetValue(BeautyData.Instance:GetIsChanmian() ~= 1)
	if self.show_btn_red ~= nil then
		local task_complete_count = BeautyData.Instance:GetDayTaskCompleteCount()
		self.show_btn_red:SetValue(task_complete_count >= 5 and BeautyData.Instance:GetIsChanmian() ~= 1)
	end
end

function BeautyWishView:OnReachBtnHandle()
	if BeautyData.Instance:GetTaskAllGold() <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Beaut.WishTipComplete)
		return
	end
	local function ok_callback()
		BeautyCtrl:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_TASK_QUICK_COMPELTE, 0)
	end
	local des = string.format(Language.Beaut.WishFastTip, BeautyData.Instance:GetTaskAllGold())
	TipsCtrl.Instance:ShowCommonAutoView("beauty_task", des, ok_callback)
end

function BeautyWishView:OnWishReachBtnHandle()
	local task_complete_count = BeautyData.Instance:GetDayTaskCompleteCount()
	if task_complete_count >= 5 then --达成5个任务
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_TASK_FETCH_REWARD, 0)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Beaut.NoWishFastTips)
	end
end


