--
-- @Author: chk
-- @Date:   2019-01-01 10:55:23
--
FactionDonatePanel = FactionDonatePanel or class("FactionDonatePanel",WindowPanel)
local FactionDonatePanel = FactionDonatePanel

function FactionDonatePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionDonatePanel"
	self.layer = "UI"


	self.panel_type = 4
	self.table_index = nil
	self.items = {}
	self.globalEvents = {}
	self.model = FactionModel:GetInstance()
	self.model.isEchEquip = false
end

function FactionDonatePanel:dctor()
	for i, v in pairs(self.items) do
		v:destroy()
	end

	for i, v in pairs(self.globalEvents) do
		self.model:RemoveListener(v)
	end

	--[[if self.PageScrollView ~= nil then
		self.PageScrollView:OnDestroy()
	end--]]
	if self.PageScrollView then
		self.PageScrollView:OnDestroy()
		self.PageScrollView = nil
	end
	GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function FactionDonatePanel:Open( )
	FactionDonatePanel.super.Open(self)
end

function FactionDonatePanel:LoadCallBack()
	self.nodes = {
		"FactionDonateItem",
		"bgContainer",
		"goodsBG/ScrollView/Viewport/Content",
		"goodsBG/ScrollView",
		"ConfirmBtn",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:CreateItems()

	self:SetTileTextImage("faction_image", "faction_f_j")
end

function FactionDonatePanel:AddEvent()
	local function call_back(target,x,y)
		for i, v in pairs(self.model.donateEquipIds or {}) do
			FactionWareController.Instance:RequestDonateEquip(v)
		end

	end
	AddClickEvent(self.ConfirmBtn.gameObject,call_back)

	self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
end

function FactionDonatePanel:DelItem(bagId,uid)
	for i, v in pairs(self.items) do
		if v.uid == uid then
			v:destroy()
			self.items[i] = nil
		end
	end
end
function FactionDonatePanel:OpenCallBack()
	self:UpdateView()
end

function FactionDonatePanel:UpdateView( )

end

function FactionDonatePanel:CloseCallBack(  )

end

function FactionDonatePanel:CreateItems(cellCount)
	--self.model.donateEquipIds = {}
	--self.model:GetCanDonateEquip()
	--local index = 1
	--for i, v in pairs(self.model.canDonateEquips) do
	--	local configItem = Config.db_item[v.id]
	--	local item = FactionDonateItemSettor(self.Content)
	--	local param = {}
	--	param["parent"] = self.Content
	--	param["type"] = configItem.type
	--	param["uid"] = v.uid
	--	param["id"] = configItem.id
	--	param["num"] = v.num
	--	param["bag"] = self.model.wareId
	--	param["bind"] = v.bind
	--	param["outTime"] = v.etime
	--	param["model"] = self.model
	--	param["click_call_back"] = handler(self,self.RequireEquipInfo)
	--	item.__item_idx = index
	--	item:UpdateItem(param)
	--	table.insert(self.items,item)
	--
	--	index = index + 1
	--	SetLocalScale(item.transform, 1, 1, 1);
	--end
	self.model.donateEquipIds = {}
	self.model:GetCanDonateEquip()
	local len = #self.model.canDonateEquips
	local temp1,temp2 = math.modf(len/18)
	local count = (temp1 + 1)*18
	--if len <= 6 then
	--	count = (6-len)+18
	--else
	--	count =  18  - (len % 6)
	--end
	local param = {}
	local cellSize = {width = 76,height = 76}
	param["scrollViewTra"] = self.ScrollView
	param["cellParent"] = self.Content
	param["cellSize"] = cellSize
	param["cellClass"] = FactionDonateItemSettor
	param["begPos"] = Vector2(0,0)
	param["spanX"] = 4
	param["spanY"] = 10
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = count
	self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function FactionDonatePanel:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS)
end

function FactionDonatePanel:UpdateCellCB(itemCLS)
	self.model:GetCanDonateEquip()
	local bagItems = self.model.canDonateEquips
	if bagItems ~=nil then
		local itemBase = bagItems[itemCLS.__item_index]
		if itemBase ~= nil and itemBase ~= 0 then
			local configItem = Config.db_item[itemBase.id]
			if configItem ~= nil then --配置表存该物品
				local param = {}
				--type,uid,id,num,bag,bind,outTime
				param["type"] = configItem.type
				param["uid"] = itemBase.uid
				param["id"] = configItem.id
				param["num"] = itemBase.num
				param["bag"] = BagModel.bagId
				param["bind"] = itemBase.bind
				param["outTime"] = itemBase.etime
				param["itemSize"] = {x = 78,y = 78}
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["model"] = self.model
				param["model"] = self.model
				param["itemIndex"] = itemCLS.__item_index
				param["click_call_back"] = handler(self,self.RequireEquipInfo)
				itemCLS:DeleteItem()
				itemCLS:UpdateItem(param)
			end
		else
			--Chkprint('--chk BagShowPanel.lua,line 125-- data=',data)
			local param = {}
			param["bag"] = BagModel.bagId
			param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
			param["model"] = self.model
			itemCLS:InitItem(param)
		end
	else
		local param = {}
		param["bag"] = BagModel.bagId
		param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
		param["model"] = self.model
		itemCLS:InitItem(param)
	end
	--itemCLS:SetCellIsLock(BagModel.UpShelfBag)
end
function FactionDonatePanel:GetItemDataByIndex(index)
	return BagModel.Instance:GetItemDataByIndex(index)
end



function FactionDonatePanel:RequireEquipInfo(uid)
	GoodsController.Instance:RequestItemInfo(BagModel.bagId,uid)
end