TombExploreView = TombExploreView or BaseClass(BaseView)

function TombExploreView:__init()
	self.ui_config = {"uis/views/tombexplore","TombExploreView"}
end

function TombExploreView:ReleaseCallBack()

end

function TombExploreView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpCLick, self))
	self:ListenEvent("CloseHelp", BindTool.Bind(self.CloseHelp, self))
	self:ListenEvent("EnterClick", BindTool.Bind(self.EnterClick, self))

	self.show_help = self:FindVariable("ShowHelp")
	self.show_help:SetValue(false)
	self.need_level = self:FindVariable("NeedLevel")
	self.open_day_time = self:FindVariable("OpenDayTime")

	-- self.reward_list = {}
	-- local item_manager = self:FindObj("RewardManager")
	-- local child_number = item_manager.transform.childCount
	-- for i = 0, child_number - 1 do
	-- 	local obj = item_manager.transform:GetChild(i).gameObject
	-- 	if string.find(obj.name, "ItemCell") ~= nil then
	-- 		local item_cell = ItemCellReward.New(U3DObject(obj))
	-- 		table.insert(self.reward_list, item_cell)
	-- 	end
	-- end

	self:Flush()
end

function TombExploreView:OpenCallBack()

end

function TombExploreView:Flush()
	--等级
	local min_level = TombExploreData.Instance:GetTombActivityLevel()
	self.need_level:SetValue(min_level)
	--时间
	local time_text = TombExploreData.Instance:GetTombActivityOpenTime()
	self.open_day_time:SetValue(time_text)
	--奖励物品
	-- local rewards = TombExploreData.Instance:GetTombActivityRewards()
	-- local count = 1
	-- for k,v in pairs(rewards) do
	-- 	print(self.reward_list[count])
	-- 	self.reward_list[count]:SetActive(true)
	-- 	self.reward_list[count]:SetData(v)
	-- 	count = count + 1
	-- 	if count > #self.reward_list then
	-- 		print("奖励超出可显示范围")
	-- 		break
	-- 	end
	-- end
	-- if count <= #self.reward_list then
	-- 	for i=count, #self.reward_list do
	-- 		self.reward_list[i]:SetActive(false)
	-- 	end
	-- end
end

function TombExploreView:HelpCLick()
	local is_open = self.show_help:GetBoolean()
	self.show_help:SetValue(not is_open)
end

function TombExploreView:CloseHelp()
	self.show_help:SetValue(false)
end

function TombExploreView:EnterClick()
	print("点击了进入")
	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.TOMB_EXPLORE)
end