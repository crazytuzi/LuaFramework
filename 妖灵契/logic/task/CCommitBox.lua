local CCommitBox = class("CCommitBox", CBox)

function CCommitBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_Callback = cb
	self.m_Item = nil
	
	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_BorderSprite = self:NewUI(2, CSprite)
	self.m_AmountLabel = self:NewUI(3, CLabel)
	self:AddUIEvent("click", callback(self, "OnClickCommitBox"))
	self:RefreshBox()
end

function CCommitBox.OnClickCommitBox(self)
	if self.m_Item then
		if self.m_Callback then
			local exist = self.m_Callback(self)
			if not exist then
				CItemTipsView:ShowView(function(oView)
					oView:SetItem(self.m_Item)
				end)
			end
		end
	end
end

function CCommitBox.SetBagItem(self, oItem)
	self.m_Item = oItem
	self:RefreshBox()
end

function CCommitBox.RefreshBox(self)
	local showItem = self.m_Item ~= nil
	self.m_IconSprite:SetActive(showItem)
	if showItem then
		local shape = self.m_Item:GetValue("icon") or 0
		self.m_IconSprite:SpriteItemShape(shape)
		local amount = self.m_Item:GetValue("amount") or 0
		self:SetAmountText(amount)
		local quality = self.m_Item:GetValue("quality") or 0
		if quality then
			self:SetBorder(true, quality)
		else
			self:SetBorder(false)
		end
	else
		self:SetAmountText(0)
		self:SetBorder(false)
	end
end

function CCommitBox.SetBorder(self, isBorder, quality)
	if quality then
		self.m_BorderSprite:SetItemQuality(quality)
	end
	self.m_BorderSprite:SetActive(isBorder)
end

function CCommitBox.SetAmountText(self, count)
	local showAmount = count > 1
	self.m_AmountLabel:SetActive(showAmount)
	if showAmount then self.m_AmountLabel:SetText(count) end
end

return CCommitBox