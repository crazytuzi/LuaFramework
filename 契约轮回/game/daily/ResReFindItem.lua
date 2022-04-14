ResReFindItem = ResReFindItem or class("ResReFindItem",BaseCloneItem)
local ResReFindItem = ResReFindItem

function ResReFindItem:ctor(obj,parent_node,layer)
	ResReFindItem.super.Load(self)

end

function ResReFindItem:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.model:RemoveTabListener(self.events)
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function ResReFindItem:LoadCallBack()
	self.nodes = {
		"btn_find", "title", "rewa_con", "money_icon", "price","found",
	}
	self:GetChildren(self.nodes)
	self.title = GetText(self.title)
	self.price = GetText(self.price)
	self.money_icon = GetImage(self.money_icon)
	self.item_list = {}
	self.events = {}
	self.model = DailyModel:GetInstance()
	self:AddEvent()
end

function ResReFindItem:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(DailyEvent.UpdateMoneyType, call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(ResFindCountPanel):Open(self.data)
	end
	AddClickEvent(self.btn_find.gameObject,call_back)
end

--data:p_findback
function ResReFindItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function ResReFindItem:UpdateView()
	local key = self.data.key
	local findbackcfg = Config.db_findback[key]
	self:UpdateByType()
	--奖励内容
	local show_rewards = String2Table(findbackcfg.show_rewards)
	local ratio = 1
	--金币找回
	if self.model.findback_type == 1 then
		show_rewards = String2Table(findbackcfg.show_rewardsgold)
		ratio = 0.55
	end
	
	--如果有层数，要根据层数去算奖励
	if findbackcfg.event ~= "" then
		local stype = String2Table(findbackcfg.event)[2]
		local event = String2Table(findbackcfg.event)[1]
		if event == enum.EVENT.EVENT_DUNGE_FLOOR then
			local floor = self.model.findback_floors[stype] or 1
			show_rewards = show_rewards[floor] or {}
		end
	end
	if findbackcfg.exp_type == 1 then
		local level = self.model.findback_level
		local exp = math.ceil(Config.db_exp_acti_base[level].player_exp * tonumber(findbackcfg.params) * ratio)
		local exp_t = {enum.ITEM.ITEM_EXP, exp}
		table.insert(show_rewards, 1, exp_t)
	end
	for i=1, #self.item_list do 
		self.item_list[i]:destroy()
	end
	self.item_list = {}
	for i=1, #show_rewards do
		local reward = show_rewards[i]
		local item_id = reward[1]
		local num = reward[2]
		local bind = reward[3]
		local param = {}
		param["item_id"] = item_id
		param["num"] = num
		param["bind"] = bind
		param["size"] = {x=60,y=60}
		param["can_click"] = true
		local item = GoodsIconSettorTwo(self.rewa_con)
		item:SetIcon(param)
		self.item_list[#self.item_list+1] = item
	end
end

function ResReFindItem:UpdateByType()
	if not self.data then
		return
	end
	local key = self.data.key
	local findbackcfg = Config.db_findback[key]
	local count1, count2 = self.model:GetFindCount(key)
	local cost = String2Table(findbackcfg.cost)
	if self.model.findback_type == 1 then
		self.title.text = string.format("%s (Retrieve: %s times)", findbackcfg.name, count1)
		local item_id = cost[1][1]
		local num = cost[1][2]
		local itemcfg = Config.db_item[item_id]
		GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, itemcfg.icon, true)
		self.price.text = num
		self.model.findback_total_money = self.model.findback_total_money + count1*num
		self:UpdateRed(count1 > 0)
	else
		local item_id = cost[2][1]
		local num = cost[2][2]
		local itemcfg = Config.db_item[item_id]
		GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, itemcfg.icon, true)
		self.price.text = num
		--vip购买次数花费
		local extra_cost = 0
		if count2 > 0 then
			self.title.text = string.format("%s (Retrieve: %s times, extra: %s)", findbackcfg.name, count1, count2)
			local vip_cost = String2Table(findbackcfg.vip_cost)
			extra_cost = extra_cost + vip_cost[1][2] * count2
		else
			self.title.text = string.format("%s (Retrieve: %s times)", findbackcfg.name, count1)
		end
		if self.model.findback_extra then
			self.model.findback_total_money = self.model.findback_total_money + num*count1 + extra_cost
		else
			self.model.findback_total_money = self.model.findback_total_money + num*count1 
		end
		self:UpdateRed(false)
	end
	if not table.isempty(self.data.counts) and count1+count2 == 0 then
		SetVisible(self.found, true)
		SetVisible(self.btn_find, false)
	else
		SetVisible(self.found, false)
		SetVisible(self.btn_find, true)
	end
end

function ResReFindItem:UpdateInfo()
	self:UpdateView()
end

function ResReFindItem:UpdateRed(flag)
	if flag then
		if not self.reddot then
			self.reddot = RedDot(self.btn_find)
			SetLocalPosition(self.reddot.transform, 55, 14,0)
		end
		SetVisible(self.reddot, true)
	else
		if self.reddot then
			SetVisible(self.reddot, false)
		end
	end
end