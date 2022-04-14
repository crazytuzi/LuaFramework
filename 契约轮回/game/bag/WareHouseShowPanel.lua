--
-- @Author: chk
-- @Date:   2018-08-20 17:46:39
--
WareHouseShowPanel = WareHouseShowPanel or class("WareHouseShowPanel",BaseBagPanel)
local WareHouseShowPanel = WareHouseShowPanel

function WareHouseShowPanel:ctor(parent_node,layer)
	self.abName = "bag"
	self.assetName = "WareHouseShowPanel"
	self.layer = layer
	self.model = BagModel:GetInstance()
	self.bagId = BagModel.wareHouseId

	BagModel.Instance.wareHouseCellCount = Config.db_bag[BagModel.wareHouseId].cap
	WareHouseShowPanel.super.Load(self)
end

function WareHouseShowPanel:dctor()
	self.model:ArrangeGoods(self.model.wareHouseItems)
	self.model.EnabledQuickDoubleClick = false
end

function WareHouseShowPanel:LoadCallBack()
	self.nodes = {
		"btnContain/ArrangeBtn/Text",

	}
	self:GetChildren(self.nodes)
	self.arrangeTxt = self.Text:GetComponent('Text')

	WareHouseShowPanel.super.LoadCallBack(self)

	self.ArrangeBtnBtn = self.ArrangeBtn:GetComponent('Button')

	local cellCount = Config.db_bag[BagModel.wareHouseId].cap
	cellCount = cellCount or 20
	self:CreateItems(cellCount)
	self.model.wareGoodsTipCon = self.goodsTipContainer
	self.model.wareEquipTipCon = self.equipTipContainer

	self.model.EnabledQuickDoubleClick = true
	GlobalEvent:Brocast(GoodsEvent.EnabledQuickDoubleClick, BagModel.bagId, true)
	BagController.Instance:RequestBagInfo(BagModel.wareHouseId)
end

function WareHouseShowPanel:AddEvent()
	WareHouseShowPanel.super.AddEvent(self)
	self.events[#self.events+1] = self.model:AddListener(BagEvent.OpenCellView,handler(self,self.DealOpenCellView))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.LoadWareItems,handler(self,self.LoadItems))
end

function WareHouseShowPanel:OnEnable()
	self.model.EnabledQuickDoubleClick = true
	GlobalEvent:Brocast(GoodsEvent.EnabledQuickDoubleClick, BagModel.bagId, true)
end

function WareHouseShowPanel:OnDisable()
	self.model.EnabledQuickDoubleClick = false
	GlobalEvent:Brocast(GoodsEvent.EnabledQuickDoubleClick,BagModel.bagId, false)
end

--仓库整理
function WareHouseShowPanel:ArrangeBag()
	WareHouseShowPanel.super.ArrangeBag(self)

	self.ArrangeBtnBtn.interactable = false
	local fromSortIdx,endSortIdx = self.model:ArrangeGoods(self.model.wareHouseItems)
	if fromSortIdx > 0 and endSortIdx > 0 and fromSortIdx ~= endSortIdx then
		for idx = fromSortIdx, endSortIdx do
			self.model:Brocast(BagEvent.BagArrange,BagModel.wareHouseId,idx)
		end
	end
end


function WareHouseShowPanel:ArrangeCutDown()
	if self.crntArrangeSec <= 0 then
		self.arrangBagEnd = true
		self.crntArrangeSec = 0
		GlobalSchedule:Stop(self.arrange_span_sche_id)

		self.ArrangeBtnBtn.interactable = true
		self.arrangeTxt.text = ConfigLanguage.Bag.WareArrange
	else
		self.arrangeTxt.text = tostring(self.crntArrangeSec)
	end


	self.crntArrangeSec = self.crntArrangeSec - 1
end

function WareHouseShowPanel:DealOpenCellView(bagWare,index)
	if self.bagId == bagWare then
		local openCellCount = self.model:GetOpenCellCount(index,bagWare)
		if openCellCount > 0 then
			--[[local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
			self.model.openCellIptView = OpenBagCellInputView(UITransform,"UI")
			self.model.openCellIptView:UpdateInfo(bagWare,openCellCount)--]]
			lua_panelMgr:GetPanelOrCreate(OpenBagInputPanel):Open(bagWare, openCellCount)
		end

	end
end


function WareHouseShowPanel:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS)
end

function WareHouseShowPanel:UpdateCellCB(itemCLS)
	itemCLS.bag = BagModel.wareHouseId
	itemCLS.need_deal_quick_double_click = true
	if self.model.wareHouseItems ~=nil then
		local itemBase = self.model.wareHouseItems[itemCLS.__item_index]
		if itemBase ~= nil and itemBase ~= 0 then
			local configItem = Config.db_item[itemBase.id]
			if configItem ~= nil then --配置表存该物品
				--type,uid,id,num,bag,bind,outTime
				local param = {}
				param["type"] = configItem.type
				param["uid"] = itemBase.uid
				param["id"] = configItem.id
				param["num"] = itemBase.num
				param["bag"] = itemBase.bag
				param["bind"] = itemBase.bind
				param["itemSize"] = {x=80, y=80}
				param["outTime"] = itemBase.etime
				param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
				param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
				param["model"] = self.model
				param["itemIndex"] = itemCLS.__item_index
				param["stencil_id"] = self.StencilId
				itemCLS:UpdateItem(param)
			end

		else
			local param = {}
			param["bag"] = BagModel.wareHouseId
			param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
            param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
			param["model"] = self.model
			param["stencil_id"] = self.StencilId
			param["itemSize"] = {x=80, y=80}
			itemCLS:InitItem(param)
		end
	else
		local param = {}

		param["bag"] = BagModel.wareHouseId
		param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
        param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
		param["model"] = self.model
		param["stencil_id"] = self.StencilId
		param["itemSize"] = {x=80, y=80}
		itemCLS:InitItem(param)
	end

	itemCLS:SetCellIsLock(BagModel.wareHouseId)
end



function WareHouseShowPanel:SetData(data)

end

function WareHouseShowPanel:GetWareItemDataByIndex(index)
	return self.model:GetWareItemDataByIndex(index)
end

function WareHouseShowPanel:QuickDoubleClick(index)
	local itemBase = self:GetWareItemDataByIndex(index)
	if itemBase ~= nil then
		GoodsController.GetInstance():RequestTakeOut(itemBase.uid,itemBase.num)
	end
end
