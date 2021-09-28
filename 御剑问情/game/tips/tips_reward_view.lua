TipsRewardView = TipsRewardView or BaseClass(BaseView)

function TipsRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips_prefab", "RewardTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.text = nil
end

function TipsRewardView:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.text = nil
	
end

function TipsRewardView:ReleaseCallBack()
	self.tittle = nil
	self.text = nil
	self.desc_text = nil
end

function TipsRewardView:SetData(items)
	self.data_list = items
end

function TipsRewardView:SetTittle(tittle)
	if tittle == nil then
		return 
	end
	self.tittle_name = tittle
end

function TipsRewardView:SetDescText(text)
	if nil == text then
		self.text = " "
		return
	end

	self.text = text
end

function TipsRewardView:LoadCallBack()
	self.tittle = self:FindVariable("Tittle")
	self.desc_text = self:FindVariable("desc_text")
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
	self.tittle:SetValue(self.tittle_name)
	self.desc_text:SetValue(self.text)
	for k,v in pairs(self.item_list) do
		local index = k
		if self.data_list[0] then
			index = k - 1
		end
		v:SetParentActive(self.data_list[index] ~= nil)
		if self.data_list[index] then
			v:SetData(self.data_list[index])
		end
	end
end
