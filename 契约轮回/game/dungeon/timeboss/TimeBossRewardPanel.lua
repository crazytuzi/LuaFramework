TimeBossRewardPanel = TimeBossRewardPanel or class("TimeBossRewardPanel",BaseRewardPanel)
local TimeBossRewardPanel = TimeBossRewardPanel

function TimeBossRewardPanel:ctor()
	self.abName = "dungeon"
	self.assetName = "TimeBossRewardPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.is_hide_other_panel = true
	
	self.btn_list = {
		{btn_res = "common:btn_blue_2",btn_name ="Close", call_back = handler(self,self.OkFunc)},
		{btn_res = "common:btn_yellow_2",btn_name ="Keep opening", call_back = handler(self,self.OpenBox)},
	}

	self.model = TimeBossModel:GetInstance()
	self.item_list = {}
	self.events = {}
end

function TimeBossRewardPanel:dctor()
end

function TimeBossRewardPanel:Open(data, bossid, count)
	self.data = data
	self.bossid = bossid
	self.count = count
	TimeBossRewardPanel.super.Open(self)
end

function TimeBossRewardPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","btnclose","btnopen", "ScrollView/Viewport",
		"icon","icon/equip_num",
	}
	self:GetChildren(self.nodes)
	self.icon = GetImage(self.icon)
	self.equip_num = GetText(self.equip_num)
	self:AddEvent()
	self:SetMask()
end

function TimeBossRewardPanel:AddEvent()

	local function call_back(data, bossid, count)
		self.data = data
		self.bossid = bossid
		self.count = count
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.UpdateBoxRewards, call_back)
end

function TimeBossRewardPanel:OpenCallBack()
	self:UpdateView()
end

function TimeBossRewardPanel:UpdateView( )
	destroyTab(self.item_list)
	self.item_list = {}
	self.cur_index = 1
	self.reward_ids = table.keys(self.data.reward)
	local key = string.format("%s@%s@%s", self.bossid, self.data.type, self.count+1)
	local rewardcfg = Config.db_timeboss_box_reward[key]
	if rewardcfg then
		local cost = String2Table(rewardcfg.cost)[1]
		local item_id = cost[1]
		local num = cost[2]
		local itemcfg = Config.db_item[item_id]
		local had_num = BagModel.GetInstance():GetItemNumByItemID(item_id)
		self.equip_num.text = string.format("%s/%s", had_num, num)
		GoodIconUtil.GetInstance():CreateIcon(self, self.icon, itemcfg.icon, true)
	else
		SetVisible(self.icon, false)
	end
	local count = #self.reward_ids
	self.schedule_id = GlobalSchedule:Start(handler(self,self.AddGoodsItem), 0.08, count)
end

function TimeBossRewardPanel:CloseCallBack(  )
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function TimeBossRewardPanel:OkFunc()
	self:FinishEffect()
	self:Close()
end

function TimeBossRewardPanel:OpenBox()
	self:FinishEffect()
	self.model:Brocast(TimeBossEvent.RequstOpenBox, self.data.type)
end

--添加寻宝结果物品（创建UI）
function TimeBossRewardPanel:AddGoodsItem()
	local i = self.cur_index --当前物品索引

	local item_id = self.reward_ids[i]
	local num = self.data.reward[item_id]
	local bind = 2
	local goods = self.item_list[i] or STGoodsItem(self.Content)
	goods:SetData(item_id, num, bind, self.StencilId)
	self.item_list[i] = goods
	self.cur_index = i + 1
	if i >= 30 then
		GlobalSchedule:Stop(self.schedule_id)
		for j=i, #self.reward_ids do
			item_id = rewards[i]
			num = self.data.reward[item_id]
			bind = 2
			local goods = self.item_list[j] or STGoodsItem(self.Content)
			goods:SetData(item_id, num, bind, self.StencilId)
			self.item_list[j] = goods
		end
	end
	if i == #self.reward_ids or i>=30 then
		if #self.item_list > #self.reward_ids then
			for i=#self.item_list, #self.reward_ids+1, -1 do
				self.item_list[i]:destroy()
				self.item_list[i] = nil
			end
		end
	end
end

--显示剩下的奖励
function TimeBossRewardPanel:ShowLeftRewards()
	if self.cur_index < #self.reward_ids then
		for i=self.cur_index, #self.reward_ids do
			item_id = self.reward_ids[i]
			num = self.data.reward[item_id]
			bind = 2
			local goods = self.item_list[i] or STGoodsItem(self.Content)
			goods:SetData(item_id, num, bind, self.StencilId)
			self.item_list[#self.item_list+1] = goods
		end
	end
end

--结束特效展示
function TimeBossRewardPanel:FinishEffect()
	if self.schedule_id then
		self:ShowLeftRewards()
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function TimeBossRewardPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end