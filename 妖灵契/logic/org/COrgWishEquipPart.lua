local COrgWishEquipPart = class("COrgWishEquipPart", CBox)

function COrgWishEquipPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self:InitContent()
end

function COrgWishEquipPart.InitContent(self)
	self.m_ChipBox = self:NewUI(1, CBox)
	self.m_ChipGrid = self:NewUI(2, CGrid)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_ScrollView = self:NewUI(5, CScrollView)

	self.m_ChipBoxArr = {}
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_ChipBox:SetActive(false)
	self:SetActive(false)
	self.m_TipsLabel:SetText("[6e4f40]请选择需要许愿的装备合成材料")
end

function COrgWishEquipPart.SetData(self)
	local oData = data.orgdata.EquipWishSort
	local count = 0
	for i,v in ipairs(oData) do
		count = count + 1
		if self.m_ChipBoxArr[count] == nil then
			self.m_ChipBoxArr[count] = self:CreateChipBox()
			self.m_ChipGrid:AddChild(self.m_ChipBoxArr[count])
		end
		self.m_ChipBoxArr[count]:SetData(data.orgdata.EquipWish[v])
		self.m_ChipBoxArr[count]:SetActive(true)
	end
	count = count + 1
	for i = count, #self.m_ChipBoxArr do
		self.m_ChipBoxArr[count]:SetActive(false)
	end
	self:SetActive(true)
	self.m_ChipGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function COrgWishEquipPart.CreateChipBox(self)
	local oChipBox = self.m_ChipBox:Clone()
	oChipBox.m_ProgressLabel = oChipBox:NewUI(1, CLabel)
	oChipBox.m_ChipQualityBgSprite = oChipBox:NewUI(2, CSprite)
	oChipBox.m_ChipSprite = oChipBox:NewUI(3, CSprite)
	oChipBox.m_ChipQualityBgSprite:AddUIEvent("click", callback(self, "OnClickWish", oChipBox))
	function oChipBox.SetData(self, oData)
		oChipBox.m_Data = oData
		oChipBox.m_ProgressLabel:SetText("拥有：" .. g_ItemCtrl:GetTargetItemCountBySid(oData.id))
		oChipBox.m_Info = DataTools.GetItemData(oData.id)
		-- oChipBox.m_ChipQualityBgSprite:SetItemQuality(self.m_Info.quality)
		self.m_ChipQualityBgSprite:SetSize(80, 80)
		oChipBox.m_ChipQualityBgSprite:SetSpriteName("pic_tongyong_diwen_zuixin")
		oChipBox.m_ChipSprite:SpriteItemShape(self.m_Info.icon)
	end

	return oChipBox
end

function COrgWishEquipPart.OnClickWish(self, oChipBox)
	printc("oChipBox.m_Info.sid: " .. oChipBox.m_Info.id)
	local windowConfirmInfo = {
		msg = string.format("[ffffff]确认许愿[ff0000]%sx%s[ffffff]吗？", oChipBox.m_Info.name, oChipBox.m_Data.amount),
		okStr = "确认",
		cancelStr = "取消",
		okCallback = function()
			self:OnClickClose()
			netorg.C2GSOrgEquipWish(oChipBox.m_Info.id)
			printc(oChipBox.m_Data.id)
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function COrgWishEquipPart.OnClickClose(self)
	self:SetActive(false)
end

return COrgWishEquipPart