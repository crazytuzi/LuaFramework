GiftItem = GiftItem or class("GiftItem",BaseItem)
local GiftItem = GiftItem

function GiftItem:ctor(parent_node,layer)
	self.abName = "friendGift"
	self.assetName = "GiftItem"
	self.layer = layer

	self.model = FriendModel:GetInstance()
	GiftItem.super.Load(self)
	self.global_events = {}
end

function GiftItem:dctor()
	if self.goods then
		self.goods:destroy()
	end
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end
	if self.event_id2 then
		GlobalEvent:RemoveListener(self.event_id2)
		self.event_id2 = nil
	end

	for i=1, #self.global_events do
		GlobalEvent:RemoveListener(self.global_events[i])
	end
	self.global_events = nil
end

function GiftItem:LoadCallBack()
	self.nodes = {
		"buybtn/gold","buybtn/had","item","item_name","selected","bg","buybtn/gold/goldicon","bg2",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.item_name = GetText(self.item_name)
	self.had = GetText(self.had)
	self.gold = GetText(self.gold)
	self.goldicon = GetImage(self.goldicon)

	self:UpdateView()
end

function GiftItem:AddEvent()
	local function call_back(target,x,y)
		self.model:Brocast(FriendEvent.SelectFlower, self.data)
	end
	AddClickEvent(self.bg2.gameObject,call_back)

	local function call_back(item_id)
		SetVisible(self.selected, self.data==item_id)
	end
	self.event_id = self.model:AddListener(FriendEvent.SelectFlower, call_back)

	local function call_back()
		self:UpdateNum()
	end
	self.event_id2 = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
end

--data:item_id
function GiftItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function GiftItem:UpdateView()
	local item = Config.db_item[self.data]
	self.item_name.text = item.name
	local goods = GoodsIconSettorTwo(self.item)
	local param = {}
	param["model"] = self.model
	param["item_id"] = self.data
	param["can_click"] = true
	goods:SetIcon(param)

	--goods:UpdateIconByItemIdClick(self.data, nil, {x=94,y=94})
	self.goods = goods
	self:UpdateNum()
	if self.is_selected then
		SetVisible(self.selected, self.is_selected)
		self.model:Brocast(FriendEvent.SelectFlower, self.data)
	end
end

function GiftItem:UpdateNum()
	local num = BagController:GetInstance():GetItemListNum(self.data)
	if num > 0 then
		SetVisible(self.gold, false)
		SetVisible(self.had, true)
		self.had.text = string.format("Own: %d", num)
	else
		SetVisible(self.gold, true)
		SetVisible(self.had, false)
		local flower = Config.db_flower[self.data]
		local cost = String2Table(flower.cost)
		local gold_id = cost[1][1]
		local gold_num = cost[1][2]
		local image = "img_money_gold"
		if gold_id == enum.ITEM.ITEM_BGOLD then
			image = "img_money_b_gold"
		end
		lua_resMgr:SetImageTexture(self,self.goldicon, 'system_image', image,true)
		self.gold.text = gold_num
	end
end

function GiftItem:Selecte()
	self.is_selected = true
end
