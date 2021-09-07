InvestContentOneView = InvestContentOneView or BaseClass(BaseRender)

function InvestContentOneView:__init(instance)
	InvestContentOneView.Instance = self
	self:ListenEvent("invest_click", BindTool.Bind(self.InvestClick, self))
	self.reward_content_list = {}
	for i=1,7 do
		self.reward_content_list[i] = InvestRewardContent.New(self:FindObj("reward_content_" .. i))
		self.reward_content_list[i]:SetDayIndex(i-1)
		self.reward_content_list[i]:FlushItem()
	end
end

function InvestContentOneView:__delete()
	for k,v in pairs(self.reward_content_list) do
		v:DeleteMe()
	end
	self.reward_content_list = {}

end

function InvestContentOneView:InvestClick()
	local invest_price = InvestData.Instance:GetInvestPrice()
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local func = function ()
		if role_gold >= invest_price then
			InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_BUY, 0)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.InvestTips, invest_price))
end
------------------------------------------------------------------
InvestRewardContent = InvestRewardContent or BaseClass(BaseCell)

function InvestRewardContent:__init()
	self.day_index = 0
	self.item_list = {}
	for i=1,2 do
		local handler = function()
			local close_call_back = function()
				self:CancelHighLight()
			end
			self.item_list[i]:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		end
		self.item_list[i] = ItemCell.New(self:FindObj("item_" .. i))
		self.item_list[i]:ListenClick(handler)
	end
end

function InvestRewardContent:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function InvestRewardContent:FlushItem()
	local item_info_list = InvestData:GetRewardInfo(self.day_index).reward_item
	for i = 1, 2 do
		self.item_list[i]:SetData(item_info_list[i-1])
	end
end

function InvestRewardContent:SetDayIndex(day_index)
	self.day_index = day_index
end

function InvestRewardContent:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end
