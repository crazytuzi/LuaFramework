YYSTResultPanel = YYSTResultPanel or class("YYSTResultPanel",BaseRewardPanel)
local YYSTResultPanel = YYSTResultPanel


function YYSTResultPanel:ctor()
	self.abName = "search_treasure"
	self.assetName = "YYSTResultPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.is_hide_other_panel = true

	self.item_list = {}

	self.model = SearchTreasureModel:GetInstance()
	local search_one_str = ConfigLanguage.SearchT.SearchOne
	local search_ten_str = ConfigLanguage.SearchT.SearchTen
	if self.model.act_id == 100003 then
		--特殊处理限时抢购
		search_one_str = "Draw once"
		search_ten_str = "Draw 10 times"
	end

	self.btn_list = {
		{btn_res = "common:btn_yellow_2",btn_name = ConfigLanguage.Mix.Confirm,format = "Auto closing in %s sec", auto_time=10, call_back = handler(self,self.OkFunc)},
		-- 说明
		{btn_res = "common:btn_blue_2",btn_name = search_one_str,call_back = handler(self,self.SearchOne)},
		{btn_res = "common:btn_blue_2",btn_name = search_ten_str,call_back = handler(self,self.SearchTen)},
	}
	
end

function YYSTResultPanel:dctor()
end

function YYSTResultPanel:Open(type_id)
	YYSTResultPanel.super.Open(self)
	self.type_id = type_id
end

function YYSTResultPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView/Viewport",
		"tips2/value1","tips3/value2","ScrollView","tips2","tips3","tips1",
		"tips1/value0","tips1/zuanshi","tips2/zuanshi2",
	}
	self:GetChildren(self.nodes)
	self.value1 = GetText(self.value1)
	--self.value2 = GetText(self.value2)
	self.value0 = GetText(self.value0)
	self.zuanshi = GetImage(self.zuanshi)
	self.zuanshi2 = GetImage(self.zuanshi2)
	self:SetMask()

	local function schedule_fun()
		self:Close()
	end

	self:AddEvent()
end


function YYSTResultPanel:DoSearch(num, need_gold)
	local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
	if not bo then
	  return
	end
	SearchTreasureController:GetInstance():RequestSearch(self.type_id, num)
	--self:Close()
end

function YYSTResultPanel:RequestSearch(num)

	local cost = self:GetCost()
	local item_id = cost[1][2]

	if item_id == 90010003 then
		--特殊处理直接用钻石抽奖的
		local price = cost[1][3]
		if num == 10 then
			price = cost[2][3]
		end
		self:DoSearch(num,price)
		return
	end

	
	local had_num = BagController:GetInstance():GetItemListNum(item_id)
	if had_num >= num then
		self:DoSearch(num, 0)
	else
		local need_num = 1
		for i=1, #cost do 
			if num == cost[i][1] then
				need_num = cost[i][3]
				break
			end
		end
		local gold_num = need_num - had_num
		local gold = Config.db_voucher[item_id].price * gold_num
		local message = ""
		local ItemName = Config.db_item[item_id].name
		if had_num > 0 then
			message = string.format(ConfigLanguage.SearchT.AlertMsg5, ItemName, gold, ItemName, gold_num)
		else
			message = string.format(ConfigLanguage.SearchT.AlertMsg4, ItemName, gold, ItemName, gold_num)
		end
		local function ok_fun()
			self:DoSearch(num, gold)
		end
		Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false, nil, self.__cname)
	end
end

function YYSTResultPanel:OkFunc()
	self:FinishEffect()
	self:Close()
end

function YYSTResultPanel:SearchOne( )
	self:FinishEffect()
	self:RequestSearch(1)
end

function YYSTResultPanel:SearchTen()
	self:FinishEffect()
	self:RequestSearch(10)
end

function YYSTResultPanel:SearchFifty()
	self:FinishEffect()
	self:RequestSearch(50)
end

function YYSTResultPanel:AddEvent()
	local function call_back()
		self:UpdateView()
		self.back_ground.item_list[1]:StartTime()
	end
	self.event_id = self.model:AddListener(SearchTreasureEvent.SearchResult, call_back)
end

function YYSTResultPanel:OpenCallBack()
	self:UpdateView()
end

function YYSTResultPanel:AddGoodsItem()
	local reward_ids = self.model:GetSearchResult()
	local i = self.cur_index
	local rewarditem = Config.db_yunying_lottery_rewards[reward_ids[i]]
	local rewards = String2Table(rewarditem.rewards)[1]
	local item_id = rewards[1]
	local num = rewards[2]
	local bind = rewards[3] or 1
	local goods = self.item_list[i] or STGoodsItem(self.Content)
	goods:SetData(item_id, num, bind, self.StencilId)
	self.item_list[i] = goods
	self.cur_index = i + 1

	if i >= 30 then
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
		end
		for j=i, #reward_ids do
			local rewarditem = Config.db_yunying_lottery_rewards[reward_ids[j]]
			local rewards = String2Table(rewarditem.rewards)[1]
			item_id = rewards[1]
			num = rewards[2]
			bind = rewards[3] or 1
			local goods = self.item_list[j] or STGoodsItem(self.Content)
			goods:SetData(item_id, num, bind, self.StencilId)
			self.item_list[j] = goods
		end
	end
	if i == #reward_ids or i>=30 then
		if #self.item_list > #reward_ids then
			for i=#self.item_list, #reward_ids+1, -1 do
				self.item_list[i]:destroy()
				self.item_list[i] = nil
			end
		end
	end
end

--显示剩下的奖励
function YYSTResultPanel:ShowLeftRewards()
	local reward_ids = self.model:GetSearchResult()
	if self.cur_index < #reward_ids then
		for i=self.cur_index, #reward_ids do
			local rewarditem = Config.db_yunying_lottery_rewards[reward_ids[i]]
			local rewards = String2Table(rewarditem.rewards)[1]
			item_id = rewards[1]
			num = rewards[2]
			bind = rewards[3] or 1
			local goods = self.item_list[i] or STGoodsItem(self.Content)
			goods:SetData(item_id, num, bind, self.StencilId)
			self.item_list[#self.item_list+1] = goods
		end
	end
end

--结束特效展示
function YYSTResultPanel:FinishEffect()
	if self.schedule_id then
		self:ShowLeftRewards()
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	self.back_ground.item_list[1]:StopTime()
end

function YYSTResultPanel:UpdateView( )
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = {}
	self.cur_index = 1
	local reward_ids = self.model:GetSearchResult()
	local count = #reward_ids
	if count == 1 then
		SetLocalPositionY(self.ScrollView.transform, -60)
	elseif count == 10 then
		SetLocalPositionY(self.ScrollView.transform, -60)
	else
		SetLocalPositionY(self.ScrollView.transform, 33)
	end
	self.schedule_id = GlobalSchedule:Start(handler(self,self.AddGoodsItem), 0.08, count)

	local cost = self:GetCost()
	self.value0.text = cost[1][3]
	self.value1.text = cost[2][3]
	local icon = Config.db_item[cost[1][2]].icon
	GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi, icon, true)
	GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi2, icon, true)
	--self.value2.text = cost[3][3]
end

function YYSTResultPanel:CloseCallBack(  )
	if self.event_id then
		self.model:RemoveListener(self.event_id)
	end
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = {}
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
	end
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function YYSTResultPanel:GetCost()
	local yycfg = Config.db_yunying[self.model.act_id]
	local reqs = String2Table(yycfg.reqs)
	local cost
	for i=1, #reqs do
		if reqs[i][1] == "cost" then
			cost = reqs[i][2]
			break
		end
	end
	return cost
end

function YYSTResultPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end