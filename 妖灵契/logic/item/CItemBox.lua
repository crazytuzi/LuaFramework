local CItemBox = class("CItemBox", CBox)

function CItemBox.ctor(self, obj, boxType)
	self.m_Effect = false
	self.m_Red = false
	self.m_BoxType = boxType

	CBox.ctor(self, obj)
	
	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_LockSprite = self:NewUI(2, CSprite)
	self.m_BorderSprite = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_AmountLabel = self:NewUI(5, CLabel)

	self:ResetStatus()

	self:AddUIEvent("doubleclick", callback(self, "OnItemBoxDoubleClick"))
	self:AddUIEvent("click", callback(self, "OnItemBoxClick"))

	self.m_Effect = false
	self.m_Red = false
end

function CItemBox.SetEffect(self, show)
	-- local effRect = show and self.m_Item and g_ItemCtrl:IsItemEff(self.m_ID)
	-- if effRect then
	-- 	if not self.m_Effect then
	-- 		self.m_Effect = true
	-- 		self:AddEffect("Rect")
	-- 	end
	-- elseif self.m_Effect then
	-- 	self.m_Effect = false
	-- 	self:DelEffect("Rect")
	-- end
end

function CItemBox.SetRed(self, show)
	-- local redDot = show and self.m_Item and g_ItemCtrl:IsItemRed(self.m_ID)
	-- if redDot then
	-- 	if not self.m_Red then
	-- 		self.m_Red = true
	-- 		self:AddEffect("RedDot", 20, Vector2(-24, -24))
	-- 	end
	-- elseif self.m_Red then
	-- 	self.m_Red = false
	-- 	self:DelEffect("RedDot")
	-- end
end

function CItemBox.RemoveItemFloat(self)
	-- g_ItemCtrl:RemoveItemEff(self.m_ID)
	-- g_ItemCtrl:RemoveItemRed(self.m_ID)
end

function CItemBox.OnItemBoxDoubleClick(self)
	if self.m_Item then
		self:SetEffect(false)
		self:SetRed(false)
		self:RemoveItemFloat()

		if g_ItemCtrl.m_RecordItemPageTab == 1 then
			-- 双击直接使用
			g_ItemCtrl:C2GSItemUse(self.m_Item.m_ID)
		elseif g_ItemCtrl.m_RecordItemPageTab == 2 then
			if self.m_BoxType == define.Item.CellType.BagCell then
				--g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_Item.m_ID)
			elseif self.m_BoxType == define.Item.CellType.WHCell then
				local itemPos = self.m_Item:GetValue("pos")
				--g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, itemPos)
			end
		end

		if self:GetSelected() then
			self:ForceSelected(false)
		end
	end
end

function CItemBox.OnItemBoxClick(self)
	if self.m_Item then
		self:SetSelected(true)
		self:SetEffect(false)
		self:SetRed(false)
		self:RemoveItemFloat()
		
		--当前处于背包界面的背包标签
		if g_ItemCtrl.m_RecordItemPageTab == 1 then			
			-- CTradeVolumSubView:ShowView(function(oView)
			-- 	oView:SetTradeVolumSubView(self.m_Item.m_SData)
			-- end)
			CItemTipsView:ShowView(function(oView)
				oView:SetItem(self.m_Item)
			end)

		--当前处于背包界面的仓库标签
		elseif g_ItemCtrl.m_RecordItemPageTab == 2 then

			CItemWHTipsView:ShowView(function(oView)
				oView:SetItemData(self.m_Item, self.m_BoxType)
			end)

		--当前没有打开背包按钮
		else --g_ItemCtrl.m_RecordItemPageTab == 0
			g_WindowTipCtrl:SetWindowItemTip(self.m_Item:GetValue("id"),
				{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)})
		end
	elseif self.m_Lock then
		if self.m_BoxType == define.Item.CellType.BagCell then
			self:ShowLockWindowTip()
		end
	end
end

function CItemBox.ShowLockWindowTip(self)
	-- local lockRows = 1
	-- if g_ItemCtrl:GetBagLockCount() >= 10 then
	-- 	if self.m_Index and (self.m_Index > g_ItemCtrl:GetBagOpenCount() + 5) then
	-- 		lockRows = 2
	-- 	end
	-- end

	-- local baseConsume = tonumber(DataTools.GetGlobalData(103).value/10000 or 100)
	-- local totalConsume = baseConsume*lockRows
	-- local totalCount = 5*lockRows

	-- local tMsg = string.format("是否消耗%s万银币，开启%s个格子？", totalConsume, totalCount)
	-- -- 弹出窗口询问是否开启格子
	-- local windowConfirmInfo = {
	-- 	msg				= tMsg,
	-- 	title			= "开启包裹",
	-- 	okCallback		= function ()
	-- 		g_ItemCtrl:AddItemExtendSize(totalCount)
	-- 	end,
	-- }
	-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CItemBox.SetBagItem(self, oItem)
	local isTouch = false
	if not self.m_Lock then
		self.m_Item = oItem
		if oItem then
			self.m_ID = oItem:GetValue("id")
			self.m_Name = oItem:GetValue("name")
			isTouch = true
		end
		self:RefreshBox()
	elseif self.m_BoxType == define.Item.CellType.ModelEquip then
		isTouch = false
	else
		isTouch = true
	end

	local showEff = false
	if not self.m_Lock and oItem then
		showEff = true
	end
	-- 特效环绕、红点bug暂时使用其他的方式处理了，回头再看
	-- table.print(oItem)
	-- printc(showEff, self.m_Lock, showEff)
	self:SetEffect(showEff)
	self:SetRed(showEff)

	self:SetEnableTouch(isTouch)
end

function CItemBox.ResetStatus(self)
	self.m_Item = nil
	self.m_ID = nil
	self.m_Lock = false

	self:RefreshBox()
end

function CItemBox.RefreshBox(self)
	self:SetLock(self.m_Lock)
	self:SetGradeText(0)

	local showItem = not self.m_Lock and self.m_Item ~= nil
	self.m_IconSprite:SetActive(showItem)
	if showItem then
		local shape = self.m_Item:GetValue("icon") or 0
		self.m_IconSprite:SpriteItemShape(shape)
		local amount = self.m_Item:GetValue("amount") or 0
		self:SetAmountText(amount)
		local quality = self.m_Item:GetValue("itemlevel") or
						 self.m_Item:GetValue("quality") or 0
		if quality then
			self:SetBorder(true, quality)
		else
			self:SetBorder(false)
		end
			self:CreateIDLabel(self.m_Item.m_ID)
	else
		self:SetAmountText(0)
		self:SetBorder(false)
	end
end

function CItemBox.GetBagItem(self)
	return self.m_Item
end

function CItemBox.SetEnableTouch(self, isTouch)
	self:EnableTouch(isTouch)
end

function CItemBox.SetLock(self, isLock, index)
	self.m_Lock = isLock
	if index then
		self.m_Index = index
	end
	self.m_LockSprite:SetActive(isLock)
end

function CItemBox.SetBorder(self, isBorder, quality)
	if quality then
		self.m_BorderSprite:SetItemQuality(quality)
	end
	self.m_BorderSprite:SetActive(isBorder)
end

function CItemBox.SetGradeText(self, grade)
	local showGrade = grade > 0
	self.m_GradeLabel:SetActive(showGrade)
	if showGrade then self.m_GradeLabel:SetText(grade) end
end

function CItemBox.SetAmountText(self, amount)
	local showAmount = amount > 1
	self.m_AmountLabel:SetActive(showAmount)
	if showAmount then self.m_AmountLabel:SetText(amount) end
end

function CItemBox.CreateIDLabel(self, id)
	if not self.m_IDLabel then
		self.m_IDLabel = self.m_AmountLabel:Clone()
		self.m_IDLabel:SetActive(g_GmCtrl.m_IsShowItemID)
		self.m_IDLabel:SetParent(self.m_Transform)
		local pos = self.m_AmountLabel:GetLocalPos()
		pos.y = pos.y + 30
		self.m_IDLabel:SetLocalPos(pos)
	end
	self.m_IDLabel:SetText("ID:"..id)
end

return CItemBox