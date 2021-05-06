local CItemPartnerEquipSoulSelectView = class("CItemPartnerEquipSoulSelectView", CViewBase)

function CItemPartnerEquipSoulSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemPartnerEquipSoulSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemPartnerEquipSoulSelectView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_OKBtn = self:NewUI(2, CButton)
	self.m_TypeScrollView = self:NewUI(3, CScrollView)
	self.m_TypeGrid = self:NewUI(4, CGrid)
	self.m_TypeBox = self:NewUI(5, CBox)
	self.m_ItemScrollView = self:NewUI(6, CScrollView)
	self.m_ItemGrid = self:NewUI(7, CGrid)
	self.m_ItemBox = self:NewUI(8, CBox)
	self.m_SelectCntBtn = self:NewUI(9, CButton)
	self.m_SelectCntLabel = self:NewUI(10, CLabel)
	self.m_MaxBtn = self:NewUI(11, CButton)
	self.m_IncreassBtn = self:NewUI(12, CButton)
	self.m_ReduceBtn = self:NewUI(13, CButton)

	self.m_SelType = nil
	self.m_SelItem = nil
	self.m_TypeData = {}
	self.m_ItemBoxList = {}
	self.m_Quality = 5

	self.m_SelectCnt = 1
	self.m_MySidCnt = 1

	self:InitContent()
end

function CItemPartnerEquipSoulSelectView.InitContent(self)
	self.m_TypeBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_OKBtn:AddUIEvent("click", callback(self, "ClickOk"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "reduce"))
	self.m_IncreassBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "increass"))	
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnClickMax"))
	self.m_SelectCntBtn:AddUIEvent("click", callback(self, "OnClickCount"))	
	self:InitTypeList()
end

function CItemPartnerEquipSoulSelectView.SetItem(self, oItem)
	if not oItem then
		self:CloseView()
		return
	end
	self.m_Id = oItem:GetValue("id")
	if oItem:GetValue("sid") == 13270 then
		self.m_Quality = 4
	elseif oItem:GetValue("sid") == 13269 then
		self.m_Quality = 3
	else
		--sid == 13271
		self.m_Quality = 5
	end	

	self.m_SelectMax = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
	self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))

	self.m_TitleLabel:SetText(oItem:GetValue("name"))
	self:ClickType(1)
end

function CItemPartnerEquipSoulSelectView.InitTypeList(self)
	local list = data.partnerequipdata.ParSoulType
	local t = {}
	for k, v in pairs(list) do
		table.insert(t, v)
	end
	table.sort(t, function (a, b)
		return a.id < b.id
	end)
	self.m_TypeData = t
	for i, v in ipairs(self.m_TypeData) do
		local oBox = self.m_TypeBox:Clone()
		oBox:SetActive(true)
		oBox.m_NameLabel = oBox:NewUI(1, CLabel)
		oBox.m_DesLabel = oBox:NewUI(2, CLabel)
		oBox.m_IconSpr = oBox:NewUI(3, CSprite)
		oBox:SetGroup(self.m_TypeGrid:GetInstanceID())
		oBox.m_NameLabel:SetText(v.name)
		oBox.m_Id = i
		oBox:SetSelected(i == 1)
		oBox.m_IconSpr:SpriteItemShape(v.icon)
		oBox:AddUIEvent("click", callback(self, "ClickType", i))
		oBox.m_DesLabel:SetText(string.format("%s:%s", "核心效果", v.skill_desc))
		self.m_TypeGrid:AddChild(oBox)
	end
end

function CItemPartnerEquipSoulSelectView.RefreshItemList(self, iType)
	local d = self.m_TypeData[iType]
	local t = data.partnerequipdata.ParSoulAttr
	if d and t then
		for i = 1, 13 do
			local oBox = self.m_ItemBoxList[i]
			if not oBox then
				oBox = self.m_ItemBox:Clone()
				oBox:SetActive(true)
				oBox.m_IconSpr = oBox:NewUI(1, CSprite)
				oBox.m_BordSpr = oBox:NewUI(2, CSprite)
				oBox.m_AttrSpr = oBox:NewUI(3, CSprite)
				oBox.m_Effect = oBox:NewUI(4, CUIEffect)
				oBox.m_SelSpr = oBox:NewUI(5, CSprite)	
				oBox.m_AttrLabel = oBox:NewUI(6, CLabel)			
				table.insert(self.m_ItemBoxList, oBox)
				self.m_ItemGrid:AddChild(oBox)
			end			
			oBox.m_AttrLabel:SetText(t[i].text)
			oBox.m_SelSpr:SetActive(self.m_SelItem == i)
			oBox.m_IconSpr:SpriteItemShape(d.icon)
			oBox.m_Effect:SetActive(self.m_Quality == 5) 
			oBox.m_Effect:Above(oBox)
			oBox:AddUIEvent("click", callback(self, "ClickItem", i))
			oBox.m_AttrSpr:SetSpriteName("pic_parattr_"..tostring(i))
			oBox.m_BordSpr:SetSpriteName("pic_yuling_"..tostring(self.m_Quality))			
		end
	end
	self.m_ItemScrollView:ResetPosition()
	self.m_ItemGrid:Reposition()
end

function CItemPartnerEquipSoulSelectView.ClickType(self, idx)
	if self.m_SelType ~= idx then
		self.m_SelType = idx
		self:RefreshItemList(self.m_SelType)
	end
end

function CItemPartnerEquipSoulSelectView.ClickItem(self, idx)
	if self.m_SelItem ~= idx then
		if self.m_SelItem then
			local oBox = self.m_ItemBoxList[self.m_SelItem]
			if oBox then
				oBox.m_SelSpr:SetActive(false)
			end
		end
		self.m_SelItem = idx
		local oBox = self.m_ItemBoxList[self.m_SelItem]
		if oBox then
			oBox.m_SelSpr:SetActive(true)
		end
	end
end

function CItemPartnerEquipSoulSelectView.ClickOk(self)		
	-- 	local t = data.partnerequipdata.ParSoulAttr
	-- 	if not self.m_TypeData or not self.m_TypeData[self.m_SelType] or not t or not t[self.m_SelItem] then
	-- 		return
	-- 	end
	-- 	local sid = 7000000 + self.m_TypeData[self.m_SelType].id * 10000 + self.m_Quality * 100 + self.m_SelItem
	-- 	local color1 = "[654A33]"
	-- 	local color2 
	-- 	if self.m_Quality == 4 then
	-- 		color2 = data.colordata.COLORINDARK["#O"]
	-- 	else
	-- 		color2 = data.colordata.COLORINDARK["#R"]
	-- 	end
	-- 	local args = 
	-- 	{
	-- 		msgBBCode = true,
	-- 		msg = string.format("%s此次选择的御灵为%s[%s·%s]%s，\n是否获取该御灵？", color1, color2, self.m_TypeData[self.m_SelType].name, t[self.m_SelItem].text, color1),
	-- 		okCallback = function ( )
	-- 			netitem.C2GSChooseItem(self.m_Id, {[1] = tostring(sid)}, 1)
	-- 			self:CloseView()
	-- 		end
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowConfirm(args)
	-- else
	-- 	g_NotifyCtrl:FloatMsg("请选择御灵属性")
	-- end
end

function CItemPartnerEquipSoulSelectView.OnRePeatPress(self, tKey , ...)
	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 

	if tKey == "reduce" then
		self.m_SelectCnt = self.m_SelectCnt - 1
		if self.m_SelectCnt  < 1 then
			self.m_SelectCnt = 1
		end
		self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))		

	elseif tKey == "increass" then
		self.m_SelectCnt = self.m_SelectCnt + 1
		if self.m_SelectCnt > self.m_SelectMax then
			self.m_SelectCnt = self.m_SelectMax
			g_NotifyCtrl:FloatMsg("超过最大数量")
		end
		self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))

	end
end

function CItemPartnerEquipSoulSelectView.OnClickMax(self)
	self.m_SelectCnt = self.m_SelectMax
	self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))
end

function CItemPartnerEquipSoulSelectView.OnClickCount(self)
	local function syncCallback(self, count)
		self.m_SelectCnt = count
		self.m_SelectCntLabel:SetText(tostring(count))
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_SelectCnt, min = 1, max = self.m_SelectMax, syncfunc = syncCallback , obj = self},
	{widget=  self, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, -75)})
end

return CItemPartnerEquipSoulSelectView