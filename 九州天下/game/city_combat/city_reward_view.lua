CityRewardView = CityRewardView or BaseClass(BaseView)

function CityRewardView:__init()
	self.ui_config = {"uis/views/citycombatview","CityRewardView"}
	self.view_layer = UiLayer.Pop
end

function CityRewardView:__delete()

end

function CityRewardView:ReleaseCallBack()
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end

	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.reward_count_down = nil
	end
	
	self.list_view = nil
	self.get_time = nil
end

function CityRewardView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

	self.list_view = self:FindObj("NameList")
	self.get_time = self:FindVariable("get_time")
	self.cell_list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self:Flush()
end

function CityRewardView:GetNumberOfCells()
	local scene_type = Scene.Instance:GetSceneType()
	local reward_list = nil
	if scene_type == SceneType.GongChengZhan then
		reward_list = CityCombatData.Instance:GetZhanChangLuckInfoList()
	elseif scene_type == SceneType.ClashTerritory then
		reward_list = CityCombatData.Instance:GetTWLuckInfoList()
	elseif scene_type == SceneType.LingyuFb then
		reward_list = CityCombatData.Instance:GetGBLuckInfoList()
	elseif scene_type == SceneType.QunXianLuanDou then
		reward_list = CityCombatData.Instance:GetQXLDLuckInfoList()
	end
	if nil == reward_list then return 0 end
	return #reward_list
end

function CityRewardView:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = CityRewardItem.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local reward_list = CityCombatData.Instance:GetZhanChangLuckInfoList()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GongChengZhan then
		reward_list = CityCombatData.Instance:GetZhanChangLuckInfoList()
	elseif scene_type == SceneType.ClashTerritory then
		reward_list = CityCombatData.Instance:GetTWLuckInfoList()
	elseif scene_type == SceneType.LingyuFb then
		reward_list = CityCombatData.Instance:GetGBLuckInfoList()
	elseif scene_type == SceneType.QunXianLuanDou then
		reward_list = CityCombatData.Instance:GetQXLDLuckInfoList()
	end
	decs_item:SetData({name = reward_list[data_index + 1]})
end

function CityRewardView:OnFlush()
	self.list_view.scroller:ReloadData(0)
	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.reward_count_down = nil
	end
	local next_reward_time = 0
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GongChengZhan then
		next_reward_time = CityCombatData.Instance:GetZhanChangRewardTime()
	elseif scene_type == SceneType.ClashTerritory then
		next_reward_time = CityCombatData.Instance:GetTWRewardTime()
	elseif scene_type == SceneType.LingyuFb then
		next_reward_time = CityCombatData.Instance:GetGBRewardTime()
	elseif scene_type == SceneType.QunXianLuanDou then
		next_reward_time = CityCombatData.Instance:GetQXLDRewardTime()
	end
	if 0 == next_reward_time then return end
	local servre_time = TimeCtrl.Instance:GetServerTime()
	self:RewardCountDown(0, next_reward_time - servre_time)
	self.reward_count_down = CountDown.Instance:AddCountDown(next_reward_time - servre_time, 1, BindTool.Bind(self.RewardCountDown, self))
end

function CityRewardView:RewardCountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.get_time:SetValue("")
		return
	end
	local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
	self.get_time:SetValue(time_str)
end

function CityRewardView:CloseWindow()
	self:Close()
end

---------------------CityRewardItem--------------------------------
CityRewardItem = CityRewardItem or BaseClass(BaseCell)

function CityRewardItem:__init()
	self.name = self:FindVariable("name")
end

function CityRewardItem:__delete()
	self.name = nil
end

function CityRewardItem:OnFlush()
	if self.data == nil then return end
	self.name:SetValue(self.data.name)
end