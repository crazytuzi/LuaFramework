CompositionUILeft = BaseClass(LuaUI)
function CompositionUILeft:__init(...)
	self.URL = "ui://qr7fvjxixy1x4";
	self:__property(...)
	self:Config()
end

function CompositionUILeft:SetProperty(...)
	
end

function CompositionUILeft:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function CompositionUILeft:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Composition","CompositionUILeft");
	self.bg = self.ui:GetChild("bg")
	self.bgType = self.ui:GetChild("bgType")
	self.bgContent = self.ui:GetChild("bgContent")
	self.scrollViewContent = self.ui:GetChild("scrollViewContent")
	self.scrollViewTypeTab = self.ui:GetChild("scrollViewTypeTab")
end

function CompositionUILeft.Create(ui, ...)
	return CompositionUILeft.New(ui, "#", {...})
end

function CompositionUILeft:__delete()
	self:DestroyItemCellUIList()
	self:DestroyTabCellUIList()
	self:DestroyItemInfoUI()
	self:CleanEvent()
	self:SetSelectedFlag(false)
end


function CompositionUILeft:InitData()
	self.itemCellUIList = {}
	self.tabCellUIList = {}
	self.model = CompositionModel:GetInstance()
	self.lastTypeTabSelectedIndex = -1
	self.defaultTypeTabSelectedIndex = 0
	self.curSelectedCellData = {}
	self.hasSelected = false
end

function CompositionUILeft:InitUI()
	self:SetTabCellListUI()
	self:SetItemCellListUI()
	self:InitItemInfoUI()
end

function CompositionUILeft:InitItemInfoUI()
	if not self.itemInfo then
		self.itemInfo = CompositionItemInfo.New()
		self.itemInfo:AddTo(self.ui)
		self.itemInfo:SetXY(13 , 462)
	end
end

function CompositionUILeft:InitEvent()
	local function HandleUpdateItems()
		self:UpdateUI()
	end
	self.handler0 = self.model:AddEventListener(CompositionConst.UpdateItems, HandleUpdateItems)
	self.scrollViewTypeTab.onClickItem:Add(self.OnClickTypeTab, self)
end

function CompositionUILeft:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
end

function CompositionUILeft:UpdateUI()
	self:SetItemCellListUI()
end

function CompositionUILeft:SetItemCellListUI()
	local itemsData = self.model:GetItemsDataByType(self.lastTypeTabSelectedIndex + 1)
	self.scrollViewContent:RemoveChildren()
	local function OnClickPkgCell(cellObj)
		self:OnClickItemCell(cellObj)
	end

	for index = 1, #itemsData do
		local curItemData = itemsData[index]
		local oldItemObj = self:GetItemCellByIndex(index)
		local curItemObj = {}

		if not TableIsEmpty(oldItemObj) then
			curItemObj = oldItemObj
			self.scrollViewContent:AddChild(oldItemObj.ui)
		else
			curItemObj = PkgCell.New(self.scrollViewContent, nil, OnClickPkgCell)
			table.insert(self.itemCellUIList, curItemObj)
		end

		local itemDataType = self.model:GetItemsTypeById(curItemData.id)
		if itemDataType ~= -1 then
			local cnt = PkgModel:GetInstance():GetTotalByBid(curItemData.id)
			--不绑定
			local isBinding = 0 
			curItemObj:SetDataByCfg(itemDataType , curItemData.id, cnt, isBinding)
		end

		curItemObj:OpenTips(false ,false)
		curItemObj:SetupPressShowTips(true, 1)
		curItemObj:SetNumFontSize(20)

		if not TableIsEmpty(self.curSelectedCellData) then
			
			if self.curSelectedCellData.bid == curItemData.id then
				curItemObj:SetSelected(true)
			else
				curItemObj:SetSelected(false)
			end
		end

		self:SetCntUI(curItemObj , curItemData.id)
	end
end

function CompositionUILeft:SetCntUI(pkgCellObj , cellDataBid)
	if not TableIsEmpty(pkgCellObj) and cellDataBid then
		local hasCnt = PkgModel:GetInstance():GetTotalByBid(cellDataBid)
		if hasCnt > 99 then
			pkgCellObj.title.text = "99+"
		else
			pkgCellObj.title.text = hasCnt
		end
	end
end


function CompositionUILeft:GetItemCellByIndex(index)
	return self.itemCellUIList[index] or {}
end

function CompositionUILeft:OnClickItemCell(cellObj)
	if cellObj then
		self:UnSelectAllItemCellList()
		cellObj:SetSelected(true)
		self.curSelectedCellData = cellObj:GetData()
		self.model:DispatchEvent(CompositionConst.SelectItem , cellObj:GetData())

		if self.curSelectedCellData and self.curSelectedCellData.bid and self.curSelectedCellData.bid == 35008 then
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end
	end
end

function CompositionUILeft:UnSelectAllItemCellList()
	for index = 1, #self.itemCellUIList do
		if not TableIsEmpty(self.itemCellUIList[index]) then
			self.itemCellUIList[index]:SetSelected(false)
		end
	end
end

function CompositionUILeft:SetTabCellListUI()
	local itemsTypeData = self.model:GetItemsTypeData()
	local function OnClickTypeTab(tabData)
		self:OnClickTypeTab(tabData)
	end
	for index = 1 , #itemsTypeData do
		local oldTabItem = self:GetTypeTabByIndex(index)		
		local curTabItem = {}
		local curTabData = itemsTypeData[index]

		if not TableIsEmpty(oldTabItem) then
			curTabItem = oldTabItem
			self.scrollViewTypeTab:AddChild(curTabItem)
		else
			curTabItem = UIPackage.CreateObject("Composition" , "CompositionTabBtn")
			curTabItem.width = 100
			self.scrollViewTypeTab:AddChild(curTabItem)
			table.insert(self.tabCellUIList , curTabItem)
		end

		self:SetTabCellUI(curTabItem, curTabData)
	end
	self.scrollViewTypeTab:AddSelection(self.defaultTypeTabSelectedIndex , true)
	self.lastTypeTabSelectedIndex = self.defaultTypeTabSelectedIndex
end


function CompositionUILeft:GetTypeTabByIndex(index)
	return self.tabCellUIList[index] or {}
end
 
function CompositionUILeft:SetTabCellUI(tabObj, typeData)
	if tabObj and typeData then
		tabObj.title = typeData.desc
	end
end

function CompositionUILeft:OnClickTypeTab(tabData)
	if self.lastTypeTabSelectedIndex ~= self.scrollViewTypeTab.selectedIndex then
		self.lastTypeTabSelectedIndex = self.scrollViewTypeTab.selectedIndex
		self:SetItemCellListUI()

		if self.lastTypeTabSelectedIndex + 1 == CompositionConst.ItemType.Stone then
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end
	end
end

function CompositionUILeft:DestroyItemCellUIList()
	for index = 1, #self.itemCellUIList do
		self.itemCellUIList[index]:Destroy()
		self.itemCellUIList[index] = nil
	end
	self.itemCellUIList = {}
end

function CompositionUILeft:DestroyTabCellUIList()
	for index = 1, #self.tabCellUIList do
		destroyUI(self.tabCellUIList[index])
	end
	self.tabCellUIList = {}
end

function CompositionUILeft:DestroyItemInfoUI()
	if self.itemInfo then
		self.itemInfo:Destroy()
		self.itemInfo = nil
	end
end

--通过bid，选中对应页签和对应item
function CompositionUILeft:SetSelectById(compositionBid)
	if compositionBid then
		local tradeType = self.model:GetItemTradeType(compositionBid)
		if tradeType ~= -1 then
			self.scrollViewTypeTab.selectedIndex = tradeType -1 --从零开始
			self.lastTypeTabSelectedIndex = self.scrollViewTypeTab.selectedIndex
			self:SetItemCellListUI()
			self:SetSelectCellItemById(compositionBid)
		end
	end
end

--选中某一个Item
function CompositionUILeft:SetSelectCellItemById(compositionBid)
	if compositionBid then
		local itemsData = self.model:GetItemsDataByType(self.lastTypeTabSelectedIndex + 1)
		local cellItemIdx = 0
		for index = 1, #itemsData do
			local curItemData = itemsData[index]
			if curItemData and curItemData.id == compositionBid then
				cellItemIdx = index
				break
			end
		end
		if cellItemIdx ~= 0 then
			local uiCellItem = self:GetItemCellByIndex(cellItemIdx)
			if not TableIsEmpty(uiCellItem) then
				self:OnClickItemCell(uiCellItem)
				self:SetSelectedFlag(true)
			end
		end
	end
end


function CompositionUILeft:SetSelectedFlag(bl)
	self.hasSelected = bl
end

function CompositionUILeft:GetSelectedFlag()
	return self.hasSelected
end