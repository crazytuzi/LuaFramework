--
-- @Author: LaoY
-- @Date:   2018-12-18 19:37:55
--
GiftRewardMaigcPanel = GiftRewardMaigcPanel or class("GiftRewardMaigcPanel",BaseRewardPanel)
local GiftRewardMaigcPanel = GiftRewardMaigcPanel

function GiftRewardMaigcPanel:ctor()
	self.abName = "goods"
	self.assetName = "GiftRewardMaigcPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.use_close_btn = true

	self.model = GoodsModel:GetInstance()
	self.item_list = {}
	self.global_event_list = {}

	self.wait_load_data = {}
	self.schedule_id = nil
	self.all_item_count = nil
	self.money_list = nil
end

function GiftRewardMaigcPanel:dctor()
	if self.global_event_list then
		self.model:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}

	if self.reward_item then
		self.reward_item:destroy()
		self.reward_item = nil
	end

	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end

	self.wait_load_data = {}
end

function GiftRewardMaigcPanel:Open(item_id,data)
	self.item_id = item_id
	self.data = data
	self:UpdateButton()
	GiftRewardMaigcPanel.super.Open(self)
end

function GiftRewardMaigcPanel:UpdateButton()
	local value = BagModel:GetInstance():GetItemNumByItemID(self.item_id)
	if self.last_value == value then
		return
	end
	self.last_value = value
	if value <= 0 then
		self.btn_list = {
			{btn_res = "common:btn_yellow_2",btn_name = "Confirm",call_back = handler(self,self.ContinueUse)},
		}
	else
		self.btn_list = {
			{btn_res = "common:btn_yellow_2",btn_name = "Keep using",call_back = handler(self,self.ContinueUse)},
		}
	end
	if self.back_ground then
		self.back_ground:SetData(self.btn_list)
	end
end

function GiftRewardMaigcPanel:LoadCallBack()
	self.nodes = {
		"text_des","GiftRewardMaigcItem","scroll","scroll/Viewport/Content",
	}
	self:GetChildren(self.nodes)

	self.text_des_component = self.text_des:GetComponent('Text')
	self.GiftRewardMaigcItem_gameobject = self.GiftRewardMaigcItem.gameObject
	SetVisible(self.GiftRewardMaigcItem,false)

	self.reward_item = GoodsIconSettorTwo(self.transform)
	self.reward_item.is_dont_set_pos = true
	self.reward_item:UpdateSize(76)
	self.reward_item:SetPosition(0,-191)

	self:SetButtonConPosition(-280)

	self:SetTitlePosition(225)

	self:AddEvent()
end

function GiftRewardMaigcPanel:ContinueUse()
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

function GiftRewardMaigcPanel:AddEvent()
	local function call_back()
		self:UpdateButton()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

function GiftRewardMaigcPanel:OpenCallBack()
	self:UpdateView()
	self:UpdateInfo()
end

function GiftRewardMaigcPanel:UpdateInfo()
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
	param.is_dont_set_pos = true
	self.reward_item:SetIcon(param)
	-- self.reward_item:SetVisible(false)
	--self.reward_item:UpdateIconByItemIdClick(self.item_id,num)
end

function GiftRewardMaigcPanel:UpdateView( )
	if not self.data then
		return
	end
	local count = 0
	local money_list = {}
	self.wait_load_data = {}
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
				local data = {}
				data.count = count
				data.item_id = item_id
				data.num = num
				table.insert(self.wait_load_data,data)
			else
				item:SetVisible(true)
				item:SetData(count,item_id,num)
			end
			
		end

	end

	self.all_item_count = count

	self:SeparateFrameInstantia()
	

end

--分帧实例化
function GiftRewardMaigcPanel:SeparateFrameInstantia()

	local num = #self.wait_load_data
	if num <= 0 then
		return
	end

	local function op_call_back(cur_frame_count,cur_all_count)
		local data = self.wait_load_data[cur_all_count]
			if data then
				local item = GiftRewardMaigcItem(self.GiftRewardMaigcItem_gameobject,self.Content)
				self.item_list[data.count] = item
				item:SetData(data.count,data.item_id,data.num)
			end
	end
	local function all_frame_op_complete()
		self:SeparateFrameInstantiaComplete()
	end
	--一帧实例化一个 保证不卡
	self.schedule_id =  SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)
end

--分帧实例化结束
function GiftRewardMaigcPanel:SeparateFrameInstantiaComplete(  )
	self.schedule_id = nil
	self.wait_load_data = {}
	for i=self.all_item_count+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end

	if not table.isempty(self.money_list) then
		SetVisible(self.text_des,true)
		self.text_des_component.text = self:GetMoneyTypeText(self.money_list)
	else
		SetVisible(self.text_des,false)
	end
end

