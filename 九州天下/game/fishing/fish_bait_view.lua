-- FishingView = FishingView or BaseClass(BaseView)

function FishingView:InitFishBait()
	self.buy_fish_bait_type = 0										-- 购买鱼饵的类型 0是普通鱼饵 1是特级鱼饵 2是黄金鱼饵
	self.buy_fish_bait_item_id = 0									-- 购买鱼饵的物品ID
	self.buy_fish_bait_num = 0										-- 购买鱼饵的数量


	self:ListenEvent("OnBuyFishBait", BindTool.Bind(self.OnBuyFishBaitHandler, self))
	

	self.lbl_fish_bait = self:FindVariable("LabelFishBait")			-- 鱼饵数量
end

function FishingView:DeleteFishBait()
	self.lbl_fish_bait = nil


	self.buy_fish_bait_type = 0
	self.buy_fish_bait_item_id = 0
	self.buy_fish_bait_num = 0
end

function FishingView:FlushFishBait()
	FishingData.Instance:BaitUpdate()
	local fish_bait_cfg = FishingData.Instance:GetFishingFishBaitCfgByType(self.buy_fish_bait_type)
	if fish_bait_cfg then
		self.buy_fish_bait_item_id = fish_bait_cfg.item_id
		self.buy_fish_bait_num = fish_bait_cfg.item_num
		local item_num = ItemData.Instance:GetItemNumInBagById(fish_bait_cfg.item_id)
		if self.lbl_fish_bait then
			self.lbl_fish_bait:SetValue(string.format(Language.Fishing.LabelFishBait, item_num))
		end
	end
end

function FishingView:FlushItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.buy_fish_bait_item_id == item_id then
		self:Flush("flush_fish_bait_view")
	end
end

function FishingView:OnBuyFishBaitHandler()
	local fish_bait_cfg = FishingData.Instance:GetFishingFishBaitCfgByType(self.buy_fish_bait_type)
	if fish_bait_cfg then
		local item_cfg = ItemData.Instance:GetItemConfig(fish_bait_cfg.item_id)
		if item_cfg then
			local need_gold = fish_bait_cfg.item_num * fish_bait_cfg.gold_price
			local des = string.format(Language.Fishing.IsBuyFishBait, need_gold, fish_bait_cfg.item_num, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
			TipsCtrl.Instance:ShowCommonAutoView("fish", des, function ()
				FishingCtrl.Instance:SendBuyFishBait(self.buy_fish_bait_type, fish_bait_cfg.item_num)
			end)
		end
	end
end


