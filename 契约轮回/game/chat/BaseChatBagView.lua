BaseChatBagView = BaseChatBagView or class("BaseChatBagView", BaseItem)
local BaseChatBagView = BaseChatBagView

function BaseChatBagView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatBagView"

	self.items = {}
	self.itemDatas = {}
	self.cellCount = 21
	self.putOnedEquipCount = 0
	self.bagId = BagModel.bagId
	self.model = ChatModel.GetInstance()

	self.globalEvents = {}
end

function BaseChatBagView:dctor()
	if self.scrollView ~= nil then
		self.scrollView:OnDestroy()
		self.scrollView = nil
	end

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.items = nil
	self.itemDatas = nil
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function BaseChatBagView:LoadCallBack()
	self.nodes = {
		"Viewport/Content","Viewport",
	}
	self:GetChildren(self.nodes)
	self.ScrollView = self.transform
	self:AddEvent()

	self:SetMask()
	self:LoadItems()
end

function BaseChatBagView:AddEvent()
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail,handler(self,self.DealGoodsDetail))
end

function BaseChatBagView:DealGoodsDetail(goodsDetail)
	if self.gameObject.activeInHierarchy then
		GlobalEvent:Brocast(ChatEvent.ClickGoods,goodsDetail)
	end
end

function BaseChatBagView:SetData(data)

end

function BaseChatBagView:LoadItems( ... )
	local param = {}
	local cellSize = {width = 74,height = 74}
	param["scrollViewTra"] = self.ScrollView
	param["cellParent"] = self.Content
	param["cellSize"] = cellSize
	param["cellClass"] = ChatBagItemSettor
	param["begPos"] = Vector2(10,-10)
	param["spanX"] = 22
	param["spanY"] = 5
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = self.cellCount
	self.scrollView = ScrollViewUtil.CreateItems(param)
end

function BaseChatBagView:CreateCellCB( itemCLS )
	self:UpdateCellCB(itemCLS)
end

function BaseChatBagView:UpdateCellCB(itemCLS)
	-- body
end


function BaseChatBagView:UpdateCellCB(itemCLS)
	if self.itemDatas ~=nil then
		local itemBase = self.itemDatas[itemCLS.__item_index]
		--Chkprint('--chk BagShowPanel.lua,line 111-- itemBase=',itemBase,itemCLS.__item_index)
		if itemBase ~= nil and itemBase ~= 0 then
			local configItem = Config.db_item[itemBase.id]
			if configItem ~= nil then --配置表存该物品
				local param = {}
				--type,uid,id,num,bag,bind,outTime
				param["type"] = configItem.type
				param["uid"] = itemBase.uid
				param["id"] = configItem.id
				param["num"] = itemBase.num
				param["bag"] = itemBase.bag
				param["bind"] = itemBase.bind
				param["outTime"] = itemBase.etime
				param["itemSize"] = {x=78, y=78}
				param["stencil_id"] = self.StencilId
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["click_call_back"] = handler(self,self.SelectItemCB)
				param["model"] = self.model
				param["itemIndex"] = itemCLS.__item_index
				itemCLS:DeleteItem()
				itemCLS:UpdateItem(param)
			end
		else
			local param = {}
			param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
			param["model"] = self.model
			itemCLS:InitItem(param)
		end
	else
		local param = {}

		param["bag"] = self.bagId
		param["model"] = self.model
		param["get_item_cb"] = handler(self,self.GetItemDataByIndex)

		itemCLS:InitItem(param)
	end
end

function BaseChatBagView:GetItemDataByIndex(index)
	return self.itemDatas[index]
end

function BaseChatBagView:SelectItemCB(item_idx)
	if item_idx <= self.putOnedEquipCount then
		GlobalEvent:Brocast(ChatEvent.ClickGoods,self.itemDatas[item_idx])
	else
		GoodsController.Instance:RequestItemInfo(self.bagId, self.itemDatas[item_idx].uid)
	end
end

function BaseChatBagView:SetMask()
	self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
