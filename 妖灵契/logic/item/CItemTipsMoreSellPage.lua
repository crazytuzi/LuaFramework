--------------------------------------------------------------------
--单个物品出售界面


--------------------------------------------------------------------
local CItemTipsMoreSellPage = class("CItemTipsMoreSellPage", CPageBase)


function CItemTipsMoreSellPage.ctor(self, obj)
	self.m_ItemInfo = nil
	self.m_ItemMaxCount = nil 
	self.m_ItemSellCount = 1
	self.m_ItemUnitCost =  1
	self.m_RedueceWhenSell = false
	CPageBase.ctor(self, obj)
end

function CItemTipsMoreSellPage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemIconSprite = self:NewUI(2, CSprite)
	self.m_ItemNameLabel = self:NewUI(3, CLabel)
	self.m_DesLabel = self:NewUI(4, CLabel)
	self.m_Maxbtn = self:NewUI(5, CButton)
	self.m_ReduceBtn = self:NewUI(6, CButton)
	self.m_IncreassBtn = self:NewUI(7, CButton)
	self.m_CountLabelBtn = self:NewUI(8, CButton)
	self.m_CountLabel = self:NewUI(9, CLabel)
	self.m_SellBtn = self:NewUI(10, CButton)
	self.m_UnitCostLabel = self:NewUI(11, CLabel)
	self.m_TotalCostLabel = self:NewUI(12, CLabel)
	self.m_ItemCountLabel = self:NewUI(13, CLabel)
	self.m_ItemTypeLabel = self:NewUI(14, CLabel)
	self.m_ItemPriceLabel = self:NewUI(15, CLabel)
	self.m_ItemLimitTimeLabel = self:NewUI(16, CLabel)
	self.m_ItemBingSprite = self:NewUI(17, CSprite)
	self.m_ItemQulitySprite = self:NewUI(18, CSprite)

	self:InitContent()
end

function CItemTipsMoreSellPage.InitContent( self )
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseParentView"))
	self.m_SellBtn:AddUIEvent("click", callback(self, "OnBtnClick", "sell"))
	self.m_Maxbtn:AddUIEvent("click", callback(self, "OnBtnClick", "max"))
	self.m_CountLabelBtn:AddUIEvent("click", callback(self, "OnBtnClick", "count"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "reduce"))
	self.m_IncreassBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "increass"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
end

function CItemTipsMoreSellPage.ShowPage( self ,tItem )
	CPageBase.ShowPage(self)
	self:SetInitBox(tItem)
end

function CItemTipsMoreSellPage.SetInitBox( self ,tItem )
	if not tItem then
		return
	end
	self.m_ItemInfo = tItem
	self:RefreshPage()
end

function CItemTipsMoreSellPage.RefreshPage(self )
	local d = self.m_ItemInfo
	local shape = d:GetValue("icon") or 0
	local name = d:GetValue("name") or ""
	local count = d:GetValue("amount")
	local des = d:GetValue("description")
	local iType = d:GetValue("type")
	local unitcost = d:GetValue("sale_price") or 1
	local limit = d:IsLimitItem()
	local bing =  d:IsBingdingItem()
	local quality = d:GetValue("itemlevel") or 0
	self.m_ItemMaxCount = count
	self.m_ItemSellCount = 1
	self.m_ItemUnitCost = unitcost
	self.m_ItemIconSprite:SpriteItemShape(shape)
	self.m_ItemNameLabel:SetText(name)
	self.m_ItemQulitySprite:SetItemQuality(quality)
	self.m_ItemCountLabel:SetText(string.format("数量: %d", count))
	self.m_ItemTypeLabel:SetText(string.format("类型: %s", define.Item.ItemTypeString[iType]))
	self.m_ItemPriceLabel:SetText(string.format("价格: %d", unitcost))
	if limit then
		self.m_ItemLimitTimeLabel:SetActive(true)
		self.m_ItemLimitTimeLabel:SetText(d:GetLimitTime())
	else
		self.m_ItemLimitTimeLabel:SetActive(false)
	end
	self.m_ItemBingSprite:SetActive(bing)
	if des ~= "" and des ~= nil then
		self.m_DesLabel:SetText(des)
	end
	self:UpdateCostText()
end

function CItemTipsMoreSellPage.OnCloseParentView( self )
	CItemTipsMoreView.OnClose(self.m_ParentView )
end

function CItemTipsMoreSellPage.UpdateCostText( self )
	self.m_CountLabel:SetText(tostring(self.m_ItemSellCount))
	self.m_UnitCostLabel:SetText(tostring(self.m_ItemUnitCost))
	self.m_TotalCostLabel:SetText(tostring(self.m_ItemUnitCost * self.m_ItemSellCount))
end

function CItemTipsMoreSellPage.OnBtnClick( self, tKey )
	if tKey == "reduce" then
		self.m_ItemSellCount = self.m_ItemSellCount - 1
		if self.m_ItemSellCount < 1 then
			self.m_ItemSellCount = 1
		end
		self:UpdateCostText()

	elseif tKey == "increass" then
		self.m_ItemSellCount = self.m_ItemSellCount + 1
		if self.m_ItemSellCount > self.m_ItemMaxCount then
			self.m_ItemSellCount = self.m_ItemMaxCount
		end
		self:UpdateCostText()

	elseif tKey == "max" then
		self.m_ItemSellCount = self.m_ItemMaxCount
		self:UpdateCostText()

	elseif tKey == "sell" then
		if self.m_RedueceWhenSell ~= true then
			local id = self.m_ItemInfo:GetValue("id")
			g_ItemCtrl:C2GSRecycleItem(id, self.m_ItemSellCount)
		else
			g_NotifyCtrl:FloatMsg(string.format("%s数量发生变化，请重新确定数量", self.m_ItemInfo:GetValue("name")))
			if CItemTipsMainView:GetView() ~= nil then
			   CItemTipsMainView:CloseView()
			end
		end
		self:OnCloseParentView()

	elseif tKey == "count" then
		local function syncCallback(self, count)
				self.m_ItemSellCount = count
				self:UpdateCostText()
		end
		g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_ItemSellCount, min = 1, max = self.m_ItemMaxCount, syncfunc = syncCallback , obj = self},
		{widget = self, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, -43)})
	end
end

function CItemTipsMoreSellPage.OnRePeatPress(self, tKey , ...)
	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 
	if tKey == "reduce" then
		self:OnBtnClick("reduce")
	elseif tKey == "increass" then
		self:OnBtnClick("increass")
	end
end

function CItemTipsMoreSellPage.OnCtrlItemlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local id = self.m_ItemInfo:GetValue("id")
		local count =  g_ItemCtrl:GetTargetItemCountById(id)
		if self.m_ItemMaxCount > count then
			self.m_RedueceWhenSell = true
		end

	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if oCtrl.m_EventData ~= nil and oCtrl.m_EventData:GetValue("id") == self.m_ItemInfo:GetValue("id") then
		   if oCtrl.m_EventData:GetValue("amount") < self.m_ItemMaxCount then
				self.m_RedueceWhenSell = true
			else
				self.m_ItemInfo = oCtrl.m_EventData
				self.m_ItemMaxCount = oCtrl.m_EventData:GetValue("amount")
		   end
		end
	end
end

return CItemTipsMoreSellPage