TipsStarRewardView = TipsStarRewardView or BaseClass(BaseView)

function TipsStarRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips_prefab", "StarRewardTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsStarRewardView:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TipsStarRewardView:SetData(items)
	self.data_list = items
end

function TipsStarRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self.item_list = {}
	for i = 1, 3 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
end

function TipsStarRewardView:CloseView()
	self:Close()
end

function TipsStarRewardView:OpenCallBack()
	self:Flush()
end
function TipsStarRewardView:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
	end
end

function TipsStarRewardView:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
end
