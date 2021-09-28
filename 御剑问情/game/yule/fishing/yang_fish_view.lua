YangFishView = YangFishView or BaseClass(BaseView)

function YangFishView:__init()
    self.ui_config = {"uis/views/yuleview_prefab", "YangFishView"}
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function YangFishView:__delete()

end

function YangFishView:RemindChangeCallBack()

end

function YangFishView:ReleaseCallBack()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.fish_obj_list = nil
	self.cost_des = nil
	self.show_gold = nil
end

function YangFishView:LoadCallBack()
	self.fish_obj_list = {}
	for i = 1, FishingData.FISH_QUALITY_COUNT do
		local fish_obj = self:FindObj("FishItem" .. i)
		table.insert(self.fish_obj_list, fish_obj)
	end

	--初始化奖励
	self.item_list = {}
	for i = 1, FishingData.FISH_QUALITY_COUNT do
		local fish_info = FishingData.Instance:GetFishInfoByQuality(i - 1)
		if nil ~= fish_info then
			local item_list_obj = self:FindObj("ItemList" .. i)
			local name_table = item_list_obj:GetComponent(typeof(UINameTable))
			local variable_table = item_list_obj:GetComponent(typeof(UIVariableTable))

			--显示第一个道具
			local rune_score = fish_info.rune_score
			local item_1_obj = name_table:Find("Item1")
			item_1_obj = U3DObject(item_1_obj)
			local item_1_cell = ItemCell.New()
			item_1_cell:SetInstanceParent(item_1_obj)
			item_1_cell:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = rune_score * 5, is_bind = 0})
			table.insert(self.item_list, item_1_cell)

			local reward_item = fish_info.reward_item
			local only_item = variable_table:FindVariable("OnlyItem")
			if reward_item.item_id > 0 then
				--显示第二个道具
				only_item:SetValue(false)
				local item_2_obj = name_table:Find("Item2")
				item_2_obj = U3DObject(item_2_obj)
				local item_2_cell = ItemCell.New()
				item_2_cell:SetInstanceParent(item_2_obj)
				item_2_cell:SetData({item_id = reward_item.item_id, num = reward_item.num * 5, is_bind = reward_item.is_bind})
				table.insert(self.item_list, item_2_cell)
			else
				--只有一个道具
				only_item:SetValue(true)
			end
		end
	end

	--初始化名字
	for i = 0, FishingData.FISH_QUALITY_COUNT - 1 do
		local fish_info = FishingData.Instance:GetFishInfoByQuality(i)
		if nil ~= fish_info then
			local name = ToColorStr(fish_info.fish_name, TEXT_COLOR.WHITE)
			self:FindVariable("FishName" .. i):SetValue(name)

			local exp = fish_info.exp
			-- 经验要乘以等级再乘以数量
			exp = exp * (50 + Scene.Instance:GetMainRole().vo.level) * 5
			local exp_des = CommonDataManager.ConverNum(exp)
			self:FindVariable("ExpDes" .. i):SetValue(exp_des)
		end
	end

	self.cost_des = self:FindVariable("CostDes")
	self.show_gold = self:FindVariable("ShowGold")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickFarmFish", BindTool.Bind(self.ClickFarmFish, self))
	self:ListenEvent("ClickRefresh", BindTool.Bind(self.ClickRefresh, self))
end

function YangFishView:CloseWindow()
	self:Close()
end

function YangFishView:ClickFarmFish()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list or fish_list.fang_fish_time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotFarmFish)
		return
	end
	YuLeCtrl.Instance:SendFishPoolRaiseReq()
	self:Close()
end

function YangFishView:ClickRefresh()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list or fish_list.fang_fish_time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotRefresh)
		return
	end

	local fish_quality = fish_list.fish_quality
	if fish_quality >= FishingData.FISH_QUALITY_COUNT - 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.MaxQualityDes)
		return
	end
	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_quality)
	if nil == fish_info then
		return
	end
	local up_level_cost = fish_info.up_quality_gold
	local des = string.format(Language.Fishpond.RefreshDes, up_level_cost)
	local function ok_callback()
		YuLeCtrl.Instance:SendFishPoolQueryReq(FISH_POOL_QUERY_TYPE.FISH_POOL_UP_FISH_QUALITY)
	end
	TipsCtrl.Instance:ShowCommonAutoView("refresh_fish", des, ok_callback)
end


function YangFishView:OpenCallBack()
	self:Flush()
end

function YangFishView:CloseCallBack()

end

function YangFishView:OnFlush()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list then
		return
	end

	local fish_quality = fish_list.fish_quality
	self.fish_obj_list[fish_quality + 1].toggle.isOn = true

	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_quality)
	if nil == fish_info then
		return
	end
	local up_level_cost = fish_info.up_quality_gold
	if up_level_cost <= 0 then
		self.show_gold:SetValue(false)
	else
		self.show_gold:SetValue(true)
	end
	self.cost_des:SetValue(up_level_cost)
end