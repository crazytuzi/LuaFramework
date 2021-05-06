--------------------------------------------------------------------
--物品批量使用界面


--------------------------------------------------------------------
local CItemTipsMoreBatUsePage = class("CItemTipsMoreBatUsePage", CPageBase)

function CItemTipsMoreBatUsePage.ctor(self, obj)
	self.m_ItemInfo = nil
	self.m_ItemMaxCount = nil
	self.m_ItemUseCount = 1
	self.m_ReduceWhenUse = false
	CPageBase.ctor(self, obj)

end

function CItemTipsMoreBatUsePage.OnInitPage(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemIconSprite = self:NewUI(2, CSprite)
	self.m_ItemNameLabel = self:NewUI(3, CLabel)
	self.m_OwnCountLabel = self:NewUI(4, CLabel)
	self.m_CancelBtn = self:NewUI(5, CButton)
	self.m_UseBtn = self:NewUI(6, CButton)
	self.m_Maxbtn = self:NewUI(7, CButton)
	self.m_IncreassBtn = self:NewUI(8, CButton)
	self.m_ReduceBtn = self:NewUI(9, CButton)
	self.m_CountLabelBtn = self:NewUI(10, CButton)
	self.m_CountLabel = self:NewUI(11, CLabel)
	self.m_ItemTypeLabel = self:NewUI(12, CLabel)
	self.m_ItemPriceLabel = self:NewUI(13, CLabel)
	self.m_ItemLimitTimeLabel = self:NewUI(14, CLabel)
	self.m_ItemBingSprite = self:NewUI(15, CSprite)
	self.m_ItemQulitySprite = self:NewUI(16, CSprite)
	self.m_DesLabel = self:NewUI(17, CLabel)

	self:InitContent()
end

function CItemTipsMoreBatUsePage.InitContent( self )
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseParentView"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCloseParentView"))
	self.m_UseBtn:AddUIEvent("click", callback(self, "OnBtnClick", "use"))
	self.m_Maxbtn:AddUIEvent("click", callback(self, "OnBtnClick", "max"))
	self.m_CountLabelBtn:AddUIEvent("click", callback(self, "OnBtnClick", "count"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "reduce"))
	self.m_IncreassBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "increass"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
end

function CItemTipsMoreBatUsePage.ShowPage( self ,tItem )
	CPageBase.ShowPage(self)
	self:SetInitBox(tItem)
end

function CItemTipsMoreBatUsePage.SetInitBox( self ,tItem )
	if not tItem then
		return
	end
	self.m_ItemInfo = tItem

	self:RefreshPage()
end

function CItemTipsMoreBatUsePage.RefreshPage(self )
	local oItem = self.m_ItemInfo
	local shape = oItem:GetValue("icon") or 0
	local name = oItem:GetValue("name") or ""
	local count = oItem:GetValue("amount")
	local unitcost = oItem:GetValue("sale_price") or 1
	local quality = oItem:GetValue("itemlevel") or 0
	local iType = oItem:GetValue("type")
	local limit = oItem:IsLimitItem()
	local bing =  oItem:IsBingdingItem()
	local maxUseCount = 9999 								--零时定义为99
	maxUseCount =  ( count < maxUseCount )  and count or  maxUseCount

	self.m_ItemIconSprite:SpriteItemShape(shape)
	self.m_ItemQulitySprite:SetItemQuality(quality)
	self.m_ItemNameLabel:SetText(name)
	self.m_OwnCountLabel:SetText(string.format("拥有数量: %d", count))
	self.m_ItemTypeLabel:SetText(string.format("类型: %s", define.Item.ItemTypeString[iType]))
	if unitcost ~= 0 then
		self.m_ItemPriceLabel:SetActive(true)
		self.m_ItemPriceLabel:SetText(string.format("价格: %d", unitcost))
	else
		self.m_ItemPriceLabel:SetActive(false)
	end
	if limit then
		self.m_ItemLimitTimeLabel:SetActive(true)
		self.m_ItemLimitTimeLabel:SetText(oItem:GetLimitTime())
	else
		self.m_ItemLimitTimeLabel:SetActive(false)
	end	
	self.m_ItemBingSprite:SetActive(bing)
	if count < self.m_ItemUseCount then
		self.m_ItemUseCount = count
	end
	local desStr = string.format("[作用]%s", oItem:GetValue("introduction"))
	desStr = desStr .. "\n".. oItem:GetValue("description")
	self.m_DesLabel:SetText(desStr)

	self.m_CountLabel:SetText(tostring(self.m_ItemUseCount))
	self.m_ItemMaxCount = maxUseCount
end

function CItemTipsMoreBatUsePage.OnBtnClick(self, tKey )

	if tKey == "reduce" then
		self.m_ItemUseCount = self.m_ItemUseCount - 1
		if self.m_ItemUseCount < 1 then
			self.m_ItemUseCount = 1
		end
		self.m_CountLabel:SetText(tostring(self.m_ItemUseCount))

	elseif tKey == "increass" then
		self.m_ItemUseCount = self.m_ItemUseCount + 1
		if self.m_ItemUseCount > self.m_ItemMaxCount then
			self.m_ItemUseCount = self.m_ItemMaxCount
		end
		self.m_CountLabel:SetText(tostring(self.m_ItemUseCount))

	elseif tKey == "max" then
		self.m_ItemUseCount = self.m_ItemMaxCount
		self.m_CountLabel:SetText(tostring(self.m_ItemUseCount))

	elseif tKey == "use" then
		local sid = self.m_ItemInfo:GetValue("sid")
		local id = self.m_ItemInfo:GetValue("id")
		local subType = self.m_ItemInfo:GetValue("sub_type")
		local targetId = g_AttrCtrl.pid		
		if self.m_ReduceWhenUse ~= true then
			g_ItemCtrl:C2GSItemUse(id, targetId, self.m_ItemUseCount)
		else
			g_NotifyCtrl:FloatMsg(string.format("%s数量发生变化，请重新确定数量", self.m_ItemInfo:GetValue("name")))
			if CItemTipsMainView:GetView() ~= nil then
			   CItemTipsMainView:CloseView()
			end			
		end
		self:OnCloseParentView()

	elseif tKey == "count" then
		local function syncCallback(self, count)
				self.m_ItemUseCount = count
				self.m_CountLabel:SetText(tostring(count))
		end
		g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_ItemUseCount, min = 1, max = self.m_ItemMaxCount, syncfunc = syncCallback , obj = self},
		{widget=  self, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, -75)})

	end
end

function CItemTipsMoreBatUsePage.OnRePeatPress(self, tKey , ...)

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

function CItemTipsMoreBatUsePage.OnCloseParentView( self )
	CItemTipsMoreView.OnClose(self.m_ParentView )
end

function CItemTipsMoreBatUsePage.OnCtrlItemlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local id = self.m_ItemInfo:GetValue("id")
		local count =  g_ItemCtrl:GetTargetItemCountById(id)
		if self.m_ItemMaxCount > count then
			self.m_ReduceWhenUse = true
		end

	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if oCtrl.m_EventData ~= nil and oCtrl.m_EventData:GetValue("id") == self.m_ItemInfo:GetValue("id") then		
		   if oCtrl.m_EventData:GetValue("amount") < self.m_ItemMaxCount then
				self.m_ReduceWhenUse = true
			else
				self.m_ItemInfo = oCtrl.m_EventData
				self.m_ItemMaxCount = oCtrl.m_EventData:GetValue("amount")
		   end
		end
	end
end

return CItemTipsMoreBatUsePage