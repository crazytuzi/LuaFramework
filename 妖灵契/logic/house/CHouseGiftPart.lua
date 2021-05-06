local CHouseGiftPart = class("CHouseGiftPart", CBox)

function CHouseGiftPart.ctor(self, obj, dDragArgs)
	CBox.ctor(self, obj)
	self.m_DragArgs = dDragArgs
	self.m_GiftGrid = self:NewUI(1, CGrid)
	self.m_GiftBox = self:NewUI(2, CBox)
	self.m_GiveCntLabel = self:NewUI(3, CLabel)
	self.m_TeaArtBtn = self:NewUI(4, CSprite)
	self.m_AddCountBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CHouseGiftPart.InitContent(self)
	self.m_GiftBoxArr = {}
	self.m_AddCountBtn:AddUIEvent("click", callback(self, "OnClickAdd"))
	self.m_TeaArtBtn:AddUIEvent("click", callback(self, "OnTeaArtBtn"))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	self.m_GiftBox:SetActive(false)
	self:SetData()
	self:RefreshLabel()
end

function CHouseGiftPart.OnClickAdd(self)
	CBuyGiftCntView:ShowView()
end

function CHouseGiftPart.SetData(self)
	local oData = g_HouseCtrl:GetGiftList()
	for i,v in ipairs(oData) do
		if self.m_GiftBoxArr[i] == nil then
			self.m_GiftBoxArr[i] = self:CreateGiftBox()
		end
		self.m_GiftBoxArr[i]:SetData(v)
		self.m_GiftBoxArr[i]:SetActive(true)
	end
	for i= #oData + 1 , #self.m_GiftBoxArr do
		self.m_GiftBoxArr[i]:SetActive(false)
	end
	self.m_TeaArtBtn:SetActive(#oData == 0)

	self.m_GiftGrid:Reposition()
	self:RefreshLabel()
end

function CHouseGiftPart.CreateGiftBox(self)
	local oGiftBox = self.m_GiftBox:Clone()
	oGiftBox.m_Sprtite = oGiftBox:NewUI(1, CSprite)
	oGiftBox.m_CntLabel = oGiftBox:NewUI(2, CLabel)
	oGiftBox.m_TempSprite = oGiftBox:NewUI(3, CSprite)
	oGiftBox.m_Sprtite:AddUIEvent("click", callback(self, "OnDetail"))
	if self.m_DragArgs then
		g_UITouchCtrl:AddDragObject(oGiftBox.m_Sprtite, self.m_DragArgs)
	end
	self.m_GiftGrid:AddChild(oGiftBox)
	
	function oGiftBox.SetData(self, dData)
		oGiftBox.m_Sprtite.m_ID = dData.id
		oGiftBox.m_Sprtite.m_ItemData = DataTools.GetItemData(dData.sid)
		oGiftBox.m_Sprtite:SpriteItemShape(oGiftBox.m_Sprtite.m_ItemData.icon)
		oGiftBox.m_TempSprite:SpriteItemShape(oGiftBox.m_Sprtite.m_ItemData.icon)
		oGiftBox.m_CntLabel:SetText(tostring(dData.amount))
	end
	return oGiftBox
end

function CHouseGiftPart.RefreshLabel(self)
	self.m_GiveCntLabel:SetText(string.format("今日送礼次数：%s次", g_HouseCtrl.m_RemainGiveGiftCnt))
end

function CHouseGiftPart.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.HouseItemAdd or
		oCtrl.m_EventID == define.House.Event.HouseItemDel or
		oCtrl.m_EventID == define.House.Event.GiftRerfesh then
			self:SetData()
	elseif oCtrl.m_EventID == define.House.Event.GiveCntRefresh then
		self:RefreshLabel()
	end
end

function CHouseGiftPart.OnDetail(self, oBox)
	CHouseItemDescView:ShowView(function(oView)
		oView:SetItemShape(oBox)
	end)
end

function CHouseGiftPart.OnTeaArtBtn(self)
	local windowConfirmInfo = {
		msg = "目前没有礼物，确认移动至工作台吗？",
		okStr = "是",
		cancelStr = "否",
		okCallback = function()
			nethouse.C2GSOpenWorkDesk(g_HouseCtrl.m_OwnerPid)
		end
	}
	CHouseConfirmView:ShowView(function (oView)
		oView:SetWindowConfirm(windowConfirmInfo)
	end)
	
end

return CHouseGiftPart