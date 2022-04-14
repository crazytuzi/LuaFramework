--
-- @Author: LaoY
-- @Date:   2018-12-18 21:03:48
--

GiftRewardNorPanel = GiftRewardNorPanel or class("GiftRewardNorPanel",BaseRewardPanel)
local GiftRewardNorPanel = GiftRewardNorPanel

function GiftRewardNorPanel:ctor()
	self.abName = "goods"
	self.assetName = "GiftRewardNorPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.use_close_btn = true

	self.model = GoodsModel:GetInstance()
	self.item_list = self.item_list or {}
end

function GiftRewardNorPanel:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}

	if self.reward_item then
		self.reward_item:destroy()
		self.reward_item = nil
	end
end

function GiftRewardNorPanel:Open(item_id,data)
	self.item_id = item_id
	self.data = data

	local value = BagModel:GetInstance():GetItemNumByItemID(item_id)
	if value <= 0 then
		self.btn_list = {
			{btn_res = "common:btn_yellow_2",btn_name = "Confirm",call_back = handler(self,self.ContinueUse)},
		}
	else
		self.btn_list = {
			{btn_res = "common:btn_yellow_2",btn_name = "Keep using",call_back = handler(self,self.ContinueUse)},
		}
	end

	GiftRewardNorPanel.super.Open(self)
end

function GiftRewardNorPanel:LoadCallBack()
	self.nodes = {
		"text_des","scroll","scroll/Viewport/Content",
	}
	self:GetChildren(self.nodes)

	self.text_des_component = self.text_des:GetComponent('Text')

	SetLocalPositionY(self.scroll,70)

	self.reward_item = GoodsIconSettorTwo(self.transform)
	self.reward_item.is_dont_set_pos = true
	self.reward_item:UpdateSize(76)
	self.reward_item:SetPosition(0,-108)

	self:SetBackgroundHeight(225)
	self:SetButtonConPosition(-210)

	self:AddEvent()
end

function GiftRewardNorPanel:ContinueUse()
	local value = BagModel:GetInstance():GetItemNumByItemID(self.item_id)
	if value <= 0 then
		self:Close()
		return
	end
	local uid = BagModel:GetInstance():GetUidByItemID(self.item_id)
	if not uid then
		return
	end
	local gift_config = self.model:GetGiftConfig(self.item_id)
	if gift_config then
		local cost = String2Table(gift_config.cost)
		if gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_GOLD_Multiple then
			GoodsController:GetInstance():RequestUseItem(uid,1)
			self:Close()
		-- elseif cost and cost[1] and cost[1] > 0 then
		-- 	self:Close()
		elseif gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_SELECT then
			GoodsController:GetInstance():RequestUseItem(uid,1)
			self:Close()
		else
			GoodsController:GetInstance():RequestUseGoods(uid,1)
		end 
	end
	-- self:Close()
end

function GiftRewardNorPanel:AddEvent()

end

function GiftRewardNorPanel:OpenCallBack()
	self:UpdateView()
	self:UpdateInfo()
end

function GiftRewardNorPanel:UpdateInfo()
	if not self.item_id then
		self.reward_item:SetVisible(false)
		return
	end
	self.reward_item:SetVisible(true)
	local num = BagModel:GetInstance():GetItemNumByItemID(self.item_id)
	local param = {}
	param["model"] = self.model
	param["item_id"] = self.item_id
	param["num"] = num
	self.reward_item:SetIcon(param)
	--self.reward_item:UpdateIconByItemIdClick(self.item_id,num)
end

function GiftRewardNorPanel:UpdateView( )
	if not self.data then
		return
	end
	local count = 0
	local money_list = {}
	local tab = Stack2List(self.data,true,true)
	local len = #tab
	for i=1,len do
		local item_id = tab[i][1]
		local num = tab[i][2]
		local cf = Config.db_item[item_id]
		if cf and cf.type == enum.ITEM_TYPE.ITEM_TYPE_MONEY then
			money_list[#money_list+1] = {cf.id,num}
		else
			count = count + 1
			local item = self.item_list[count]
			if not item then
				item = GoodsIconSettorTwo(self.Content)
				--item:UpdateSize(76)
				self.item_list[count] = item
			else
				item:SetVisible(true)
			end

			local param = {}
			param["size"] = {x=76,y=76}
			param["model"] = self.model
			param["item_id"] = item_id
			param["num"] = num
			item:SetIcon(param)
			--item:UpdateIconByItemIdClick(item_id,num)
		end
	end

	local len = count < 14 and 14 or count
	SetSizeDeltaX(self.Content,81*len)

	for i=count+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end

	if not table.isempty(money_list) then
		SetVisible(self.text_des,true)
		self.text_des_component.text = self:GetMoneyTypeText(money_list)
	else
		SetVisible(self.text_des,false)
	end
end