local CHouseExchangeTaskRewardPart = class("CHouseExchangeTaskRewardPart", CBox)

function CHouseExchangeTaskRewardPart.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CHouseExchangeTaskRewardPart.InitContent(self)
	self.m_CloseBtn = self:NewUI(1, CBox)
	-- self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CItemTipsBox)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_SubmitBtn = self:NewUI(6, CButton)

	self.m_ItemBox:SetActive(false)
	self.m_ItemBoxArr = {}
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
end

function CHouseExchangeTaskRewardPart.SetData(self, oBox, partnerType)
	self:SetLocalScale(Vector3.one)
	self:SetActive(true)
	self.m_Box = oBox
	self.m_PartnerType = partnerType
	-- if oBox.m_Status == define.House.TaskStatus.Done then
	-- 	self.m_SubmitBtn:SetText("领取")
	-- else
	-- 	self.m_SubmitBtn:SetText("确定")
	-- end

	local count = 0
	for k,v in pairs(oBox.m_Data.item) do
		count = count + 1
		if self.m_ItemBoxArr[count] == nil then
			-- self.m_ItemBoxArr[count] = self:CreateItemBox()
			self.m_ItemBoxArr[count] = self.m_ItemBox:Clone()
			self.m_ItemGrid:AddChild(self.m_ItemBoxArr[count])
		end
		self.m_ItemBoxArr[count]:SetActive(true)
		local info = {
			sid = v.sid,
			amount = v.amount,
			parid = nil,
		}
		if string.find(v.sid, "value") then
			info.sid, info.amount = g_ItemCtrl:SplitSidAndValue(v.sid)
		elseif string.find(v.sid, "partner") then
			info.sid, info.parId = g_ItemCtrl:SplitSidAndValue(v.sid)
		end
		self.m_ItemBoxArr[count]:SetItemData(info.sid, info.amount, info.parid, {isLocal = true, uiType = 1})
	end
	count = count + 1
	for i = count, #self.m_ItemBoxArr do
		self.m_ItemBoxArr[i]:SetActive(false)
	end
	self.m_ItemGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

-- function CHouseExchangeTaskRewardPart.CreateItemBox(self)
-- 	local oItemBox = self.m_ItemBox:Clone()
-- 	oItemBox.m_QualitySprite = oItemBox:NewUI(1, CSprite)
-- 	oItemBox.m_ItemSprite = oItemBox:NewUI(2, CSprite)
-- 	oItemBox.m_AmountLabel = oItemBox:NewUI(3, CLabel)
-- 	function oItemBox.SetData(self, oData)
-- 		oItemBox.m_Data = oData
-- 		oItemBox.m_ItemData = DataTools.GetItemData(oData.sid)
-- 		oItemBox.m_ItemSprite:SpriteItemShape(oItemBox.m_ItemData.icon)
-- 		oItemBox.m_QualitySprite:SetItemQuality(oItemBox.m_ItemData.quality)
-- 		oItemBox.m_AmountLabel:SetText(oData.amount)
-- 	end
-- 	return oItemBox
-- end

function CHouseExchangeTaskRewardPart.OnClickClose(self)
	-- self:SetActive(false)
	self:SetLocalScale(Vector3.New(0.001, 0.001, 0.001))
end

function CHouseExchangeTaskRewardPart.OnSubmit(self)
	-- if self.m_Box.m_Status == define.House.TaskStatus.Done then
	-- 	printc("领取level: " .. self.m_Box.m_Data.level)
	-- 	nethouse.C2GSUnChainPartnerReward(self.m_PartnerType, self.m_Box.m_Data.level)
	-- else
	-- 	printc("确定")
	-- end
	self:OnClickClose()
end

return CHouseExchangeTaskRewardPart