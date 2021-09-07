RewardContentView = RewardContentView or BaseClass(BaseRender)

function RewardContentView:__init(instance)
	self:ListenEvent("reward_click", BindTool.Bind(self.RewardOnClick,self))
	self:ListenEvent("item_click", BindTool.Bind(self.ItemOnClick,self))
	self.detail_text = self:FindVariable("detail_text")
	-- self.reward_icon = self:FindVariable("reward_icon")
	self.show_btn_red_point = self:FindVariable("show_btn_red_point")
	self.btn_text = self:FindVariable("btn_text")
	self.reward_btn = self:FindObj("reward_btn")
	self.item_cell = self:FindObj("item_cell")
	self.reward_text = self:FindObj("Text")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.item_cell)
	self.reward_item_id = 0
end

function RewardContentView:__delete()
	self.reward_item:DeleteMe()
end

function RewardContentView:FlushRewrdInfo()
	local rewrd_info = SettingData.Instance:GetRewardInfo()
	self.reward_item_id = rewrd_info.reward_item.item_id
	local data = {}
	data.item_id = rewrd_info.reward_item.item_id
	self.detail_text:SetValue(rewrd_info.explain)
	self.reward_item:SetData(data)
	-- local bundle, asset = ResPath.GetItemIcon(ItemData.Instance:GetItemConfig(self.reward_item_id).icon_id)
	-- self.reward_icon:SetAsset(bundle, asset)
	local server_version = SettingData.Instance:GetServerVersion()
	local fetch_reward_version = SettingData.Instance:FetchRewardVersion()
	if fetch_reward_version < server_version then
		self.reward_btn.grayscale.GrayScale = 0
		self.reward_text.grayscale.GrayScale = 0
		self.reward_btn.button.interactable = true
		self.btn_text:SetValue(Language.Common.LingQuJiangLi)
	else
		self.reward_btn.grayscale.GrayScale = 255
		self.reward_text.grayscale.GrayScale = 255
		self.reward_btn.button.interactable = false
		self.btn_text:SetValue(Language.Common.YiLingQu)
	end
end

function RewardContentView:SetRedPoint(red_point)
	self.show_btn_red_point:SetValue(red_point)
end

function RewardContentView:RewardOnClick()
	local server_version = SettingData.Instance:GetServerVersion()
	local fetch_reward_version = SettingData.Instance:FetchRewardVersion()
	if fetch_reward_version < server_version then
		SettingCtrl.Instance:SendUpdateNoticeFetchReward()
	end
end

function RewardContentView:ItemOnClick(is_click)
	if is_click then
		local data = {}
		data.item_id = self.reward_item_id
		local close_call_back = function()
			self.item_cell.toggle.isOn = false
		end
		TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
	end
end


