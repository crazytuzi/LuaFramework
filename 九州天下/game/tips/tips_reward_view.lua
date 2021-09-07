TipsRewardView = TipsRewardView or BaseClass(BaseView)

function TipsRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips", "RewardTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsRewardView:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TipsRewardView:SetData(items)
	self.data_list = items
end

function TipsRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	local item_manager = self:FindObj("ItemManager")
	local child_number = item_manager.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = item_manager.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.item_list[count] = ItemCellReward.New()
			self.item_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end
end

function TipsRewardView:CloseView()
	self:Close()
end

function TipsRewardView:OpenCallBack()
	for k,v in pairs(self.item_list) do
		v:SetActive(self.data_list[k] ~= nil)
		if self.data_list[k] then
			v:SetData(self.data_list[k])
		end
	end
end
