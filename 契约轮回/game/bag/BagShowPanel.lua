--
-- @Author: chk
-- @Date:   2018-08-20 17:48:33
--
BagShowPanel = BagShowPanel or class("BagShowPanel",BaseBagPanel)
local BagShowPanel = BagShowPanel

function BagShowPanel:ctor(parent_node,layer)
	self.abName = "bag"
	self.assetName = "BagShowPanel"
	self.layer = layer
	self.bagId = BagModel.bagId
	self.openCellCount = 1
	self.openCellIcons = {}
	BagModel.Instance.bagOpenCells = Config.db_bag[BagModel.bagId].open
	BagModel.Instance.bagCellsCount = Config.db_bag[BagModel.bagId].cap

	BagShowPanel.super.Load(self)
end

function BagShowPanel:dctor()

	self.model:ArrangeGoods(self.model.bagItems)
	self.is_loaded = false

	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i, v in pairs(self.openCellIcons) do
		v:destroy()
	end

	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
	if self.red_dot2 then
		self.red_dot2:destroy()
		self.red_dot2 = nil
	end

	self.openCellIcons = {}
	self.model.filter_type = 0
end

function BagShowPanel:LoadCallBack()
	self.nodes = {
		"btnContain/SellBtn",
		"arrangeSingleBtn",
		"arrangeSingleBtn/SingleArrangeText",
		--"btnContain/ArrangeBtn",
		"btnContain/ArrangeBtn/ArrangeText",
		"btnContain/DepotBtn",
		"toggle_group/ToggleAll",
		"toggle_group/ToggleEquip",
		"toggle_group/ToggleMt",
		"toggle_group/ToggleOther",
		"toggle_group/ToggleAll/LabelAll",
		"toggle_group/ToggleAll/LabelAll2",
		"toggle_group/ToggleEquip/LabelEquip",
		"toggle_group/ToggleEquip/LabelEquip2",
		"toggle_group/ToggleMt/LabelMt",
		"toggle_group/ToggleMt/LabelMt2",
		"toggle_group/ToggleOther/LabelOther",
		"toggle_group/ToggleOther/LabelOther2",
	}

	self:GetChildren(self.nodes)
	--self.viewPortImage = GetImage(self.Viewport)
	--self.viewPortImage.material = ShaderManager.GetInstance():GetScrollRectMaskMaterial()
	BagShowPanel.super.LoadCallBack(self)
	self:GetRectTransform()
	self:OpenSellPanelEvent()
	self.ToggleAll = GetToggle(self.ToggleAll)
	self.ToggleEquip = GetToggle(self.ToggleEquip)
	self.ToggleMt = GetToggle(self.ToggleMt)
	self.ToggleOther = GetToggle(self.ToggleOther)

	self.bagItems = self.model:GetCurrentBagItems()
	local cellCount = Config.db_bag[BagModel.bagId].cap
	cellCount = cellCount or 20
	self:CreateItems(cellCount)

	BagController.Instance:RequestBagInfo(BagModel.bagId)

	--local background =
end

function BagShowPanel:AddEvent()
	BagShowPanel.super.AddEvent(self)

	self:ArrangeBagEvent(self.arrangeSingleBtn)
	self.events[#self.events+1] = self.model:AddListener(BagEvent.OpenCellView,handler(self,self.DealOpenCellView))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.LoadBagItems,handler(self,self.LoadItems))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.OpenWarePanel,handler(self,self.DealWarePanelOpen))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.SmeltRedDotEvent, handler(self,self.UpdateRedDot))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.SellItems,handler(self,self.DealSellItems))


	local function call_back()
		local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
		if RoleInfoModel:GetInstance():GetMainRoleLevel() < open_level then
			Notify.ShowText(string.format("Devour unlocks at LV.%d", open_level))
		else
			--if self.model:IsCanSmelt() then
				lua_panelMgr:GetPanelOrCreate(BagSmeltPanel):Open()
			--else
			--	Notify.ShowText("背包中没有可熔炼的装备")
			--end
		end
	end
	AddClickEvent(self.DepotBtn.gameObject,call_back)

	local function call_back(target, value)
		if value then
			self:UpdateBag(0)
		end
		SetVisible(self.LabelAll, value)
		SetVisible(self.LabelAll2, not value)
	end
	AddValueChange(self.ToggleAll.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self:UpdateBag(1)
		end
		SetVisible(self.LabelEquip, value)
		SetVisible(self.LabelEquip2, not value)
	end
	AddValueChange(self.ToggleEquip.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self:UpdateBag(2)
		end
		SetVisible(self.LabelMt, value)
		SetVisible(self.LabelMt2, not value)
	end
	AddValueChange(self.ToggleMt.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self:UpdateBag(3)
		end
		SetVisible(self.LabelOther, value)
		SetVisible(self.LabelOther2, not value)
	end
	AddValueChange(self.ToggleOther.gameObject, call_back)

	local function call_back( ... )
		self:ArrangeBagCB()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.SmeltSuccess, call_back)
end

function BagShowPanel:UpdateBag(filter)
	self.model.filter_type = filter
	self.bagItems = self.model:GetCurrentBagItems()
	self.model:ArrangeGoods(self.bagItems)
	if self.scrollView then
		self.scrollView:OnDestroy()
		local cellCount = Config.db_bag[BagModel.bagId].cap
		cellCount = cellCount or 20
		self:CreateItems(cellCount)
	end
end

function BagShowPanel:InputChange()

end

function BagShowPanel:ArrangeCutDown()
	if self.crntArrangeSec <= 0 then
		self.arrangBagEnd = true
		self.crntArrangeSec = 0
		GlobalSchedule:Stop(self.arrange_span_sche_id)
		self.arrange_span_sche_id = nil

		self.SingleArrangeBtnBtn.interactable = true
		self.ArrangeBtnBtn.interactable = true
		self.ArrangeTextTxt.text = ConfigLanguage.Bag.Arrange
		self.SingleArrangeTextTxt.text = ConfigLanguage.Bag.ArrangeBag
	else
		self.ArrangeTextTxt.text = tostring(self.crntArrangeSec)
		self.SingleArrangeTextTxt.text = self.ArrangeTextTxt.text
	end


	self.crntArrangeSec = self.crntArrangeSec - 1
end

function BagShowPanel:OpenSellPanelEvent()
	local function call_back(target,x,y)
		self.model:GetCanSellItems()
		if table.nums(self.model.canSellItems) <= 0 then
			Notify.ShowText(ConfigLanguage.Bag.NotGoodsCanSell)
		else
			lua_panelMgr:GetPanelOrCreate(BagSellPanel):Open()
		end
	end
	AddClickEvent(self.SellBtn.gameObject,call_back)
end


--背包整理
function BagShowPanel:ArrangeBag()
	BagShowPanel.super.ArrangeBag(self)

	self.ArrangeBtnBtn.interactable = false
	self.SingleArrangeBtnBtn.interactable = false

	self.bagItems = self.model:GetCurrentBagItems()
	local fromSortIdx,endSortIdx = self.model:ArrangeGoods(self.bagItems)
	if fromSortIdx ~= nil and self.model.baseGoodSettorCLS ~= nil then
		self.model.baseGoodSettorCLS:SetSelected(false)
		self.model.baseGoodSettorCLS = nil
	end
	if fromSortIdx > 0 and endSortIdx > 0 and fromSortIdx ~= endSortIdx then
		if self.model.filter_type > 0 then
			self:UpdateBag(self.model.filter_type)
		else
			for idx = fromSortIdx, endSortIdx do
				self.model:Brocast(BagEvent.BagArrange,BagModel.bagId,idx)
			end
		end
	else
		self.model:Brocast(BagEvent.CheckQuickUse)
	end
end


--创建背包格子回调
function BagShowPanel:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS)
end

function BagShowPanel:DealSellItems()
	self.bagItems = self.model:GetCurrentBagItems()
	local fromSortIdx,endSortIdx = self.model:ArrangeGoods(self.bagItems)
	if fromSortIdx > 0 and endSortIdx > 0 and fromSortIdx ~= endSortIdx then
		if self.model.filter_type > 0 then
			self:UpdateBag(self.model.filter_type)
		else
			for idx = fromSortIdx, endSortIdx do
				self.model:Brocast(BagEvent.BagArrange,BagModel.bagId,idx)
			end
		end
	end
end

function BagShowPanel:DealOpenCellView(bagWare,index)
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

function BagShowPanel:DealWarePanelOpen(enable)
	if enable then
		SetVisible(self.btnContain,false)
		SetVisible(self.arrangeSingleBtn,true)
	else
		SetVisible(self.btnContain,true)
		SetVisible(self.arrangeSingleBtn,false)
	end
end

function BagShowPanel:GetRectTransform()
	self.ArrangeBtnBtn = self.ArrangeBtn:GetComponent('Button')
	self.SingleArrangeBtnBtn = self.arrangeSingleBtn:GetComponent('Button')
	self.SingleArrangeTextTxt = self.SingleArrangeText:GetComponent('Text')
	self.ArrangeTextTxt = self.ArrangeText:GetComponent('Text')

	--self.model.bagGoodsTipCon = self.goodsTipContainer
	--self.model.bagEquipTipCon = self.equipTipContainer
end

function BagShowPanel:GetItemDataByIndex(index)
	return self.model:GetItemDataByIndex(index)
end

function BagShowPanel:LoadItems(bagWareId)
	--Chkprint('--chk BagShowPanel.lua,line 91-- data=',data)
	self.bagWareId = bagWareId
	if self.loadingItems then
		return
	end

	self.loadingItems = true

	if self.scrollView ~= nil then
		self.scrollView:Update()
	end

	self.loadingItems = false
end


function BagShowPanel:UpdateCellCB(itemCLS)
	self.bagItems = self.model:GetCurrentBagItems()
	if self.bagItems ~=nil then
		local itemBase = self.bagItems[itemCLS.__item_index]
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
				param["sex"] = itemBase.gender
				param["itemSize"] = {x=80, y=80}
				param["outTime"] = itemBase.etime
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
				param["model"] = self.model
				param["itemIndex"] = itemCLS.__item_index
				param["stencil_id"] = self.StencilId
				itemCLS:DeleteItem()
				itemCLS:UpdateItem(param)
			end
		else
			local param = {}
			param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
			param["model"] = self.model
			param["stencil_id"] = self.StencilId
			param["itemSize"] = {x=80, y=80}
			itemCLS:InitItem(param)
		end
	else
		local param = {}

		param["bag"] = BagModel.bagId
		param["model"] = self.model
		param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["quick_double_click_call_back"] = handler(self,self.QuickDoubleClick)
        param["stencil_id"] = self.StencilId
        param["itemSize"] = {x=80, y=80}

		itemCLS:InitItem(param)
	end

	itemCLS:SetCellIsLock(BagModel.bagId)
end

function BagShowPanel:QuickDoubleClick(index)
	local itemBase = self:GetItemDataByIndex(index)
	if itemBase ~= nil then
		GoodsController.GetInstance():RequestStoreItem(itemBase.uid,itemBase.num)
	end
end

function BagShowPanel:SetData(data)

end

function BagShowPanel:UpdateRedDot()
	local results = self.model:GetCanSmeltEquips()
	local num = self.model:FilterSmelt()
	local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
	if num > 5 and level >= open_level then
		if not self.red_dot then
			self.red_dot = RedDot(self.DepotBtn.transform)
		end
		self.red_dot:SetVisible(true)
		SetLocalPosition(self.red_dot.transform, 55, 14)
	else
		if self.red_dot then
			self.red_dot:SetVisible(false)
		end
	end
	local sell_num = self.model:GetCanSellItems()
	if sell_num >= 20 then
		if not self.red_dot2 then
			self.red_dot2 = RedDot(self.SellBtn.transform)
		end
		self.red_dot2:SetVisible(true)
		SetLocalPosition(self.red_dot2.transform, 55, 14)
	else
		if self.red_dot2 then
			self.red_dot2:SetVisible(false)
		end
	end
end
