KuafuTaskRecordView = KuafuTaskRecordView or BaseClass(BaseView)

local IndexToMap =
{
	[0] = 3150,
	[1] = 3151,
	[2] = 3152,
	[3] = 3153,
	[4] = 3154,
	[5] = 3155,
}

function KuafuTaskRecordView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/kuafuliujie","TaksRecordView"}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function KuafuTaskRecordView:__delete()

end

function KuafuTaskRecordView:LoadCallBack()
	self.item_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
 	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
 	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close,self))
 	RemindManager.Instance:Bind(self.remind_change, RemindName.ShowKfBattleRemind)
end

function KuafuTaskRecordView:OpenCallBack()
	-- 红点处理
--	ClickOnceRemindList[RemindName.ShowKfBattleRemind] = 0
--	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ShowKfBattleRemind)

	self:Flush()
end

function KuafuTaskRecordView:OnFlush()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuTaskRecordView:ReleaseCallBack()
	self.list_view = nil
	
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function KuafuTaskRecordView:GetNumberOfCells()
	return 6
end

function KuafuTaskRecordView:RefreshCell(cell, data_index, cell_index)
	local the_cell = self.item_list[cell]
	if the_cell == nil then
		the_cell = TaskRecordItem.New(cell.gameObject)
		the_cell.parent_view = self
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
 	self.is_double = self:FindVariable("is_double")
 	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo,self))
 	self.item = {}
 	self.item_cell = {}
 	for i = 1,2 do
 		self.item[i] = self:FindObj("ItemCell"..i)
 		self.item_cell[i] = ItemCell.New()
 		self.item_cell[i]:SetInstanceParent(self.item[i])
 	end
end

function TaskRecordItem:__delete( )
	for i = 1,2 do
		if self.item_cell[i] then
			self.item_cell[i]:DeleteMe()
		end
	end
	self.item_cell = {}
	self.parent_view = nil
end

function TaskRecordItem:SetData(data_index)
	self.data = data_index
	local scene_id = IndexToMap[data_index]
	local scene_name = ConfigManager.Instance:GetSceneConfig(scene_id).name
	self.scene_name:SetValue("<color=#FA4904>" .. scene_name .. "</color>")
	local task_cfg = KuafuGuildBattleData.Instance:GetTaskCfgInfo(data_index)
	local finish_num = task_cfg.finish_num
	local total_num = #task_cfg.list
	self.task_progress:SetValue("(" .. finish_num .. "/" .. total_num .. ")")
	self.isfinish:SetValue(not (finish_num < total_num))

	local is_double = KuafuGuildBattleData.Instance:GetIsDoubleRewardByIndex(data_index + 1)
	self.is_double:SetValue(is_double)

	local reward_data = KuafuGuildBattleData.Instance:GetRewardDataByIndex(data_index, 0)
	local data = {item_id = ResPath.CurrencyToIconId.kuafu_jifen, num = 0}
	for k,v in pairs(task_cfg.list) do
		if is_double then
			data.num = v.cfg.reward_credit * 4
		else
			data.num = v.cfg.reward_credit * 2
		end
	end
	self.item_cell[1]:SetData(data)

	local reward_num = 0
	if is_double then
		reward_num = reward_data.reward_item.num * 4
	else
		reward_num = reward_data.reward_item.num * 2
	end
	self.item_cell[2]:SetData({item_id = reward_data.reward_item.item_id, num = reward_num})
end

function TaskRecordItem:OnClickGo()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.CrossGuildBattle then
		local empty_num = ItemData.Instance:GetEmptyNum()
		if empty_num == 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.BagRemind)
			return
		end
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_GUILDBATTLE, KuafuGuildBattleData.Instance:GetSceneIdByIndex())
		return
	end
	if self.data then
		local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.data)
		if map_info then
			GuajiCtrl.Instance:StopGuaji()
			GuajiCtrl.Instance:ClearAllOperate()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToScenePos(map_info.scene_id, map_info.relive_pos_x, map_info.relive_pos_y)
		end
	end
	self.parent_view:Close()
end
