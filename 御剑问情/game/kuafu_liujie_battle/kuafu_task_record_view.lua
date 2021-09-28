KuafuTaskRecordView = KuafuTaskRecordView or BaseClass(BaseView)

local IndexToMap =
{
	[0] = 1450,
	[1] = 1460,
	[2] = 1461,
	[3] = 1462,
	[4] = 1463,
	[5] = 1464,
}

function KuafuTaskRecordView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","TaksRecordView"}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function KuafuTaskRecordView:__delete()

end

function KuafuTaskRecordView:LoadCallBack()
	self.item_list = {}
	self.list_view = self:FindObj("ListView")
	self.gold_num = self:FindVariable("gold_num")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
 	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
 	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close,self))
 	self:ListenEvent("OnClickSkip", BindTool.Bind(self.OnClickSkip, self))
 	RemindManager.Instance:Bind(self.remind_change, RemindName.ShowKfBattleRemind)
end

function KuafuTaskRecordView:OpenCallBack()
	-- 红点处理
	ClickOnceRemindList[RemindName.ShowKfBattleRemind] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ShowKfBattleRemind)

	self:Flush()
end

function KuafuTaskRecordView:OnFlush()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	local gold_num = 0
	for i=1, 6 do
		local task_cfg = KuafuGuildBattleData.Instance:GetTaskCfgInfo(i - 1)
		for k,v in pairs(task_cfg.list) do
			if v.statu ~= 1 then
				gold_num = gold_num + v.cfg.auto_complete_need_gold
			end
		end
	end
	self.gold_num:SetValue(gold_num)
end

function KuafuTaskRecordView:ReleaseCallBack()
	self.list_view = nil
	self.gold_num = nil
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function KuafuTaskRecordView:OnClickSkip()
	local str = string.format(Language.Common.ToGoldOneKey, self.gold_num:GetInteger())
	TipsCtrl.Instance:ShowCommonAutoView("", str, function ()
		TaskCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_CROSS_GUIDE)
	end, function ()
		return
	end)
end

function KuafuTaskRecordView:GetNumberOfCells()
	return 6
end

function KuafuTaskRecordView:RefreshCell(cell, data_index, cell_index)
	local the_cell = self.item_list[cell]
	if the_cell == nil then
		the_cell = TaskRecordItem.New(cell.gameObject)
		self.item_list[cell] = the_cell
	end
	self.item_list[cell]:SetData(data_index)
end

function KuafuTaskRecordView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.ShowKfBattleRemind then
		self:Flush()
	end
end


TaskRecordItem = TaskRecordItem or BaseClass(BaseRender)

function TaskRecordItem:__init()
	self.scene_name = self:FindVariable("scene_name")
	self.task_progress = self:FindVariable("task_progress")
 	self.isfinish = self:FindVariable("is_finish")
 	self.item = {}
 	self.item_cell = {}
 	for i=1,2 do
	 	self.item[i] = self:FindObj("item" .. i)
	 	self.item_cell[i] = ItemCell.New()
	 	self.item_cell[i]:SetInstanceParent(self.item[i])
 	end
end

function TaskRecordItem:__delete()
	if self.item_cell then
		for k,v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = nil
	end
end

function TaskRecordItem:SetData(data_index)
	self.data = data_index
	local scene_id = IndexToMap[data_index]
	local scene_name = ConfigManager.Instance:GetSceneConfig(scene_id).name
	self.scene_name:SetValue(scene_name)
	local task_cfg = KuafuGuildBattleData.Instance:GetTaskCfgInfo(data_index)
	local finish_num = task_cfg.finish_num
	local total_num = #task_cfg.list
	self.task_progress:SetValue("(" .. finish_num .. "/" .. total_num .. ")")
	self.isfinish:SetValue(not (finish_num < total_num))
	for i=1,#self.item do
		local data = {item_id = ResPath.CurrencyToIconId.kuafu_jifen[i], num = 0}
		for k,v in pairs(task_cfg.list) do
		data.num = data.num + v.cfg.reward_credit
		end
		if i == 1 then
			data.num = 200									--策划说写死
		end
		self.item_cell[i]:SetData(data)
	end

end