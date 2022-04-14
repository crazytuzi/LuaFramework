--
-- @Author: chk
-- @Date:   2018-08-28 10:31:20
--
BagSellPanel = BagSellPanel or class("BagSellPanel",WindowPanel)
local BagSellPanel = BagSellPanel

function BagSellPanel:ctor()
	self.abName = "bag"
	self.assetName = "BagSellPanel"
	self.layer = "UI"

	self.events = {}
	self.panel_type = 6
	self.use_background = true
	self.change_scene_close = true
	self.moneyLbl = nil
	self.model = BagModel:GetInstance()
end

function BagSellPanel:dctor()
	if self.scrollView ~= nil then
		self.scrollView:OnDestroy()
		self.scrollView = nil
	end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	self.model = nil
	if self.StencilMask then
		destroy(self.StencilMask)
		self.StencilMask = nil
	end
end

function BagSellPanel:Open( )
	BagSellPanel.super.Open(self)
end

function BagSellPanel:LoadCallBack()
	self.nodes = {
		"GetMoney/Image/moneyValue",
		"ScrollView",
		"ScrollView/Viewport",
		"ScrollView/Viewport/Content",
		"GetMoney/Image/Value",
		"AutoSetSellBtn",
		"ConfigSellBtn",

	}
	self:GetChildren(self.nodes)
	self:SetMask()
	self.moneyLbl = self.moneyValue:GetComponent('Text')
	self:AddEvent()
	self:LoadItems()
	self:SetSellMoney()

	self:SetTileTextImage("bag_image", "one_key_sell")
	self:SetTitleIcon("system_image","title_icon_1",true)
end

function BagSellPanel:AddEvent()


	local function call_back(target,x,y)
		Notify.ShowText(ConfigLanguage.Mix.NotOpen)
	end
	AddClickEvent(self.AutoSetSellBtn.gameObject,call_back)


	local function call_back(target,x,y)
		local sellParam = self.model:GetSellItemParam()
		if not table.isempty(sellParam) then
			GoodsController.Instance:RequestSellItems(sellParam)
			self:Close()
		end
	end

	AddClickEvent(self.ConfigSellBtn.gameObject,call_back)

	local function call_back()
		Notify.ShowText(ConfigLanguage.Mix.NotOpen)
	end
	AddClickEvent(self.AutoSetSellBtn.gameObject,call_back)

	self.events[#self.events+1] = self.model:AddListener(BagEvent.SetSellMoney,handler(self,self.SetSellMoney))
end



function BagSellPanel:OpenCallBack()
	self:UpdateView()
end

function BagSellPanel:UpdateView( )

end

function BagSellPanel:CloseCallBack(  )

end


function BagSellPanel:LoadItems()
	self.model:GetCanSellItems()

	local cellCount = table.nums(self.model.canSellItems)
	if cellCount < 50 then
		cellCount = 50
	elseif cellCount % 10 ~= 0 then
		cellCount = cellCount + (10 - cellCount % 10)
	end
	local param = {}
	local cellSize = {width = 80,height = 80}
	param["scrollViewTra"] = self.ScrollView
	param["cellParent"] = self.Content
	param["cellSize"] = cellSize
	param["cellClass"] = BagSellItemSettor
	param["begPos"] = Vector2(2,-3)
	param["spanX"] = 10
	param["spanY"] = 10
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = cellCount
	self.scrollView = ScrollViewUtil.CreateItems(param)
end

function BagSellPanel:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS)
end


function BagSellPanel:UpdateCellCB(itemCLS)
	if self.model.canSellItems ~=nil then
		local itemBase = self.model.canSellItems[itemCLS.__item_index]
		if itemBase ~= nil then
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
				param["multy_select"] = true
				param["itemSize"] = {x=80, y=80}
				param["model"] = self.model
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["selectItemCB"] = handler(self,self.SelectItemCB)
				param["get_item_select_cb"] = handler(self,self.GetItemSelect)
				param["stencil_id"] = self.StencilId

				itemCLS:DeleteItem()
				itemCLS:UpdateItem(param)
			else
				local param = {}
				param["bag"] = BagModel.bagId
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["get_item_select_cb"] = handler(self,self.GetItemSelect)
				param["selectItemCB"] = handler(self,self.SelectItemCB)
				param["model"] = self.model
				itemCLS:InitItem(param)
			end
		else
			local param = {}
			param["bag"] = BagModel.bagId
			param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
			param["get_item_select_cb"] = handler(self,self.GetItemSelect)
			param["selectItemCB"] = handler(self,self.SelectItemCB)
			param["model"] = self.model
			itemCLS:InitItem(param)
		end

	end
end


function BagSellPanel:SetSellMoney()
	local money = self.model:GetSellItemsMoney()
	if self.moneyLbl ~= nil then
		self.moneyLbl.text = tostring(money)
	end
end

function BagSellPanel:DelItemCB(uid)
	self.model:DelSellItemByUid(uid)
end

function BagSellPanel:GetItemDataByIndex(idx)
	return self.model.canSellItems[idx]
end

function BagSellPanel:SelectItemCB(uid,is_select)
	self.model:SetSellItemSelect(uid,is_select)
end

function BagSellPanel:GetItemSelect(uid)
	local select = self.model:GetSellItemSelect(uid)
	return select ~= nil and select == true or false
end

function BagSellPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end