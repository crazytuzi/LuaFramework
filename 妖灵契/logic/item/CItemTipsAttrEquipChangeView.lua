-----------------------------------------------------------------------------
--装备的替换显示界面


-----------------------------------------------------------------------------

local CItemTipsAttrEquipChangeView = class("CItemTipsAttrEquipChangeView", CViewBase)

CItemTipsAttrEquipChangeView.enum =
{
	ChangeInfo = 1,	--装备对比信息
	SellInfo = 2,	--出售信息
	Composite = 3,	--装备合成预览
}

function CItemTipsAttrEquipChangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsAttrEquipChangeView.prefab", cb)
	self.m_DepthType = "Dialog"
	--self.m_ExtendClose = "Black"
	self.m_Type = nil
end

function CItemTipsAttrEquipChangeView.OnCreateView(self)

	self.m_TBox = self:NewUI(1, CBox)
	self.m_TBox.m_OrgHeight = self.m_TBox:GetHeight()
	self.m_TNameLabel = self:NewUI(2, CLabel)
	self.m_TAttrTable = self:NewUI(3, CTable)
	self.m_TItemTipsBox = self:NewUI(4, CItemTipsBox)
	self.m_TPosLabel = self:NewUI(5, CLabel)
	self.m_TFitLabel = self:NewUI(6, CLabel)
	self.m_TLevelLabel = self:NewUI(7, CLabel)
	self.m_TScoreLabel = self:NewUI(8, CLabel)
	self.m_BBox = self:NewUI(9, CBox)
	self.m_BBox.m_OrgHeight = self.m_BBox:GetHeight()
	self.m_BNameLabel = self:NewUI(10, CLabel)
	self.m_BAttrTable = self:NewUI(11, CTable)
	self.m_BItemTipsBox = self:NewUI(12, CItemTipsBox)
	self.m_BPosLabel = self:NewUI(13, CLabel)
	self.m_BFitLabel = self:NewUI(14, CLabel)
	self.m_BLevelLabel = self:NewUI(15, CLabel)
	self.m_BScoreLabel = self:NewUI(16, CLabel)
	self.m_TitleClone = self:NewUI(17, CBox)
	self.m_OpClone = self:NewUI(18, CBox)
	self.m_SEClone = self:NewUI(19, CBox)
	self.m_ContentListClone = self:NewUI(20, CBox)
	self.m_EquipGrid = self:NewUI(21, CGrid)
	self.m_EquipBox = self:NewUI(22, CBox)
	self.m_TQualityTitleSpr = self:NewUI(23, CSprite)	
	self.m_BQualityTitleSpr = self:NewUI(24, CSprite)
	self.m_TSubQualitySpr = self:NewUI(25, CSprite)
	self.m_BSubQualitySpr = self:NewUI(26, CSprite)
	self.m_OpClone2 = self:NewUI(27, CBox)
	self.m_EquipListWidget = self:NewUI(28, CBox)
	self.m_MaskBox = self:NewUI(29, CBox)	
	self.m_MaskGrid = self:NewUI(30, CGrid)
	self.m_TargetLockBtn = self:NewUI(31, CButton)
	self.m_BaseLockBtn = self:NewUI(32, CButton)

	self.m_TargetUI = {}
	self.m_TargetUI.m_Box = self.m_TBox
	self.m_TargetUI.m_NameLabel = self.m_TNameLabel
	self.m_TargetUI.m_AttrTable = self.m_TAttrTable
	self.m_TargetUI.m_ItemBox = self.m_TItemTipsBox
	self.m_TargetUI.m_PosLabel = self.m_TPosLabel
	self.m_TargetUI.m_FitLabel = self.m_TFitLabel
	self.m_TargetUI.m_LevelLabel = self.m_TLevelLabel
	self.m_TargetUI.m_ScoreLabel = self.m_TScoreLabel
	self.m_TargetUI.m_QualityTitleSpr = self.m_TQualityTitleSpr
	self.m_TargetUI.m_SubQualityTitleSpr = self.m_TSubQualitySpr

	self.m_BaseUI = {}
	self.m_BaseUI.m_Box = self.m_BBox
	self.m_BaseUI.m_NameLabel = self.m_BNameLabel
	self.m_BaseUI.m_AttrTable = self.m_BAttrTable
	self.m_BaseUI.m_ItemBox = self.m_BItemTipsBox
	self.m_BaseUI.m_PosLabel = self.m_BPosLabel
	self.m_BaseUI.m_FitLabel = self.m_BFitLabel
	self.m_BaseUI.m_LevelLabel = self.m_BLevelLabel
	self.m_BaseUI.m_ScoreLabel = self.m_BScoreLabel	
	self.m_BaseUI.m_QualityTitleSpr = self.m_BQualityTitleSpr
	self.m_BaseUI.m_SubQualityTitleSpr = self.m_BSubQualitySpr

	self.m_SelectItem = nil
	self.m_BaseItem = nil
	self.m_IsClickChange = false
	self.m_EquipItemList = {}
	self.m_CompareAttr = {}

	self:InitContent()
end

function CItemTipsAttrEquipChangeView.InitContent(self)
	self.m_TitleClone:SetActive(false)
	self.m_OpClone:SetActive(false)
	self.m_SEClone:SetActive(false)
	self.m_ContentListClone:SetActive(false)
	self.m_EquipBox:SetActive(false)
	self.m_OpClone2:SetActive(false)
	self.m_MaskBox:SetActive(false)

	UITools.ResizeToRootSize(self.m_MaskGrid)
	self.m_MaskGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnMaskClose"))
		return oBox
	end)


	self.m_TargetLockBtn:AddUIEvent("click", callback(self, "OnSwitchLockUnEquip"))
	self.m_BaseLockBtn:AddUIEvent("click", callback(self, "OnSwitchLockEquiped"))
	self.m_MaskBox:AddUIEvent("click", callback(self, "OnMaskClose"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
end


function CItemTipsAttrEquipChangeView.SetData(self, item, list, type, bShowMaskWidget)
	self.m_Type = type or CItemTipsEquipChangeView.enum.ChangeInfo

	local tItem
	local bItem
	if list then
		tItem = list[1]
		bItem = g_ItemCtrl:GetEquipedByPos(tItem:GetValue("pos"))
	else
		tItem = item
		bItem = g_ItemCtrl:GetEquipedByPos(tItem:GetValue("pos"))
	end

	self.m_BaseItem = bItem
	self.m_SelectItem = tItem

	if bItem and self.m_Type == CItemTipsEquipChangeView.enum.ChangeInfo then
		self.m_BBox:SetActive(true)
		self:InitBox(bItem, self.m_BaseUI, true, list == nil)
	else
		self.m_BBox:SetActive(false)
	end		

	if tItem then
		self.m_TBox:SetActive(true)
		self:InitBox(tItem, self.m_TargetUI, false, list == nil)
	else
		self.m_TBox:SetActive(false)
	end

	self:RefreshLockInfo()

	self.m_EquipItemList = list
	if list and next(list) then
		self.m_EquipListWidget:SetActive(true)
		self.m_MaskBox:SetActive(true)
		self:RefreshEquipGird()
	else
		self.m_EquipListWidget:SetActive(false)
		self.m_MaskBox:SetActive(bShowMaskWidget)
	end
end

function CItemTipsAttrEquipChangeView.InitBox(self, tItem, uiTable, isBase, isBag)
	if not tItem then
		return
	end


	uiTable.m_ItemBox:SetItemData(tItem:GetEquipStoneSid(), 1, nil , {oItem = tItem})
	uiTable.m_AttrTable:Clear()
	uiTable.m_PosLabel:SetText("类型:"..define.Equip.PosName[tItem:GetValue("pos")] ) 
	local level = tItem:GetValue("equip_level") or tItem:GetValue("level")
	uiTable.m_LevelLabel:SetText("等级:"..level) 
	uiTable.m_FitLabel:SetText("适用:"..tItem:GetEquipFitInfo())

	if self.m_Type == CItemTipsAttrEquipChangeView.enum.Composite then
		uiTable.m_ScoreLabel:SetText("") 
	else
		if isBase then
			uiTable.m_ScoreLabel:SetText("评分:"..tItem:GetEquipScore())
		else
			uiTable.m_ScoreLabel:SetText("评分:"..tItem:GetEquipBaseScore())
		end		
	end
	local quality = tItem:GetValue("quality") or 1
	uiTable.m_QualityTitleSpr:SetTitleQuality(quality, 1)
	uiTable.m_SubQualityTitleSpr:SetTitleQuality(quality, 2)

	local t1 = tItem:GetEquipAttrBase() or {}
	local t2 = self.m_BaseItem:GetEquipAttrStrength() or {}
	local t3 = self.m_BaseItem:GetEquipAttrFuWen() or {}
	local t4 = self.m_BaseItem:GetEquipAttrGem() or {}

	--显示强化等级
	local strengthLevel = 0
	for _,v in pairs (t2) do
		if v.key == "level" then	
			local lv = v.value or 0
			strengthLevel = tonumber(lv) 
		end
	end
	local name
	if self.m_Type == CItemTipsAttrEquipChangeView.enum.Composite then
		name = string.format("%s%s", data.colordata.ITEM.Quality[tItem:GetValue("quality")], tItem:GetValue("name"))
	else
		name = string.format("%s%s+%d", data.colordata.ITEM.Quality[tItem:GetValue("itemlevel")], tItem:GetValue("name"), strengthLevel)		
	end
	uiTable.m_NameLabel:SetText(name)
	local t1_temp
	if self.m_Type == CItemTipsAttrEquipChangeView.enum.Composite then
		t1_temp = g_ItemCtrl:GetItemAttrBySid(tItem:GetValue("sid"))
	else
		t1_temp =  table.copy(t1)
		--强化属性和装备属性加在一起显示
		for k, v in pairs(t2) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
				local isFind = false
				for _k, _v in pairs(t1_temp) do
					if _v.key == v.key then
						isFind = true					
						_v.value = _v.value + v.value
						_v.strength_value = v.value or 0
					end
				end
				--如果装备没有该强化属性，则插入强化属性
				if isFind == false then
					local t = {key = v.key, value = v.value, strength_value = v.value}				
					table.insert(t1_temp, t)
				end			
			end
		end
	end
	t1_temp = self:SortAttr(t1_temp)
	self:AddTitleBox("装备属性", uiTable.m_AttrTable)
	local baseAttr = {}
	local min, max = g_ItemCtrl:GetEquipWaveRange()
	for _,v in ipairs (t1_temp) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			local sKey = define.Attr.String[v.key] or v.key
			local str 
			local isUp
			if self.m_Type == CItemTipsAttrEquipChangeView.enum.Composite then
				str = string.format("%s+%s~%s", sKey, g_ItemCtrl:AttrStringConvert(v.key, min / 100 * v.value), g_ItemCtrl:AttrStringConvert(v.key, max / 100 * v.value))				
			else
				str = string.format("%s+%s", sKey, g_ItemCtrl:AttrStringConvert(v.key, v.value))				
				if isBase then
					self.m_CompareAttr[v.key] = v.value
				else
					local baseAttr = self.m_CompareAttr[v.key] or 0
					if baseAttr > v.value then
						isUp = false
					elseif baseAttr < v.value then
						isUp = true
					end
				end
			end
			local d = {str = str, isUp = isUp}
			table.insert(baseAttr, d)
			self:AddContentListBox(baseAttr, uiTable.m_AttrTable)	
			baseAttr = {}
		end
	end

	if self.m_Type ~= CItemTipsAttrEquipChangeView.enum.Composite then
		--显示淬灵属性
		local fuwenAttr = { }	
		for _,v in pairs (t3) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 then					
				local sKey = define.Attr.String[v.key] or v.key
				local str = sKey.."+"..g_ItemCtrl:AttrStringConvert(v.key, v.value)
				local d = {str = "[54e414]"..str}
				table.insert(fuwenAttr, d)
			end	
		end
		if next(fuwenAttr) then
			self:AddTitleBox("淬灵属性", uiTable.m_AttrTable)
			self:AddContentListBox(fuwenAttr, uiTable.m_AttrTable)
		end

		local gemAttr = self.m_BaseItem:GetEquipGemAttr()
		local str = nil
		if next(gemAttr) ~= nil then
			for k, v in pairs(gemAttr) do
				if str ~= nil then
					str = str .. "\n"
				end			
				str = string.format("%s+%s", define.Attr.String[k], g_ItemCtrl:AttrStringConvert(k, v)) 
			end
		end
		if str then		
			self:AddTitleBox("宝石属性", uiTable.m_AttrTable)
			table.sort(t4, function(a,b)
				return a.sid > b.sid
			end)
			local temp = table.copy(data.itemdata.GEM[t4[1].sid]) 
			local name = temp.name
			name = string.gsub(name, string.format("%d级", temp.level), "")
			local d = {str = string.format("[4dc8e5]%s   %s", name, str)}
			self:AddContentListBox({[1] = d} , uiTable.m_AttrTable)
		end
	end
	
	--装备特效
	local other = tItem:GetEquipSEString()
	if other ~= "无" then
		self:AddTitleBox("装备效果", uiTable.m_AttrTable)	
		self:AddContentSEBox(tItem:GetEquipSEString(2), uiTable.m_AttrTable)
	end

	--是否是装备链接
	if isBase ~= true then
		if isBag then
			if self.m_Type == CItemTipsEquipChangeView.enum.ChangeInfo then
				local tBox = self.m_OpClone2:Clone()
				tBox:SetActive(true)
				tBox.m_ChangeBtn = tBox:NewUI(1, CButton)
				tBox.m_SellBtn = tBox:NewUI(2, CButton)
				tBox.m_ChangeBtn:AddUIEvent("click", callback(self, "OnEquip"))
				tBox.m_SellBtn:AddUIEvent("click", callback(self, "OnSell"))
				uiTable.m_AttrTable:AddChild(tBox)
			end
		else
			local tBox = self.m_OpClone:Clone()
			tBox:SetActive(true)
			tBox.m_ChangeBtn = tBox:NewUI(1, CButton)
			tBox.m_ChangeBtn:AddUIEvent("click", callback(self, "OnEquip"))
			uiTable.m_AttrTable:AddChild(tBox)
		end	
	end

	self:AdjustHeight(uiTable.m_Box, uiTable.m_AttrTable)
end

function CItemTipsAttrEquipChangeView.OnEquip(self)
	local equipLevel = self.m_SelectItem:GetValue("level")
	if equipLevel > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg("无法装备比角色等级高的装备")	
	else	
		self.m_IsClickChange = true
		g_ItemCtrl:C2GSPromoteEquipLevel(self.m_SelectItem:GetValue("pos"), self.m_SelectItem:GetValue("id"))
	end
end

function CItemTipsAttrEquipChangeView.OnSell(self)
	local sale_price = self.m_BaseItem:GetValue("sale_price")
	if sale_price > 0 then
		local oView = CItemBagMainView:GetView()
		if oView and oView.m_SellInfoPart and oView.m_SellInfoPart.ShowSellInfoWidget then
			oView.m_SellInfoPart:ShowSellInfoWidget(self.m_BaseItem:GetValue("id"))
			self:CloseView()
		end							
	else
		g_NotifyCtrl:FloatMsg("该装备不可出售")
	end	
end

function CItemTipsAttrEquipChangeView.AddTitleBox(self, text, oTable)
	local tBox = self.m_TitleClone:Clone()
	tBox:SetActive(true)
	tBox.m_TitleLabel = tBox:NewUI(1, CLabel):SetText(text)			
	oTable:AddChild(tBox)
end

function CItemTipsAttrEquipChangeView.AddContentListBox(self, list, oTable)
	local tBox = self.m_ContentListClone:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel1 = tBox:NewUI(1, CLabel)
	tBox.m_CompareSpr1 = tBox:NewUI(2, CSprite)
	tBox.m_ContentLabel2 = tBox:NewUI(3, CLabel)
	tBox.m_CompareSpr2 = tBox:NewUI(4, CSprite)
	tBox.m_Box1 = self:NewUI(5, CBox)
	tBox.m_Box2 = self:NewUI(6, CBox)
	tBox.m_ContentLabel1:SetActive(false)
	tBox.m_CompareSpr1:SetActive(false)
	tBox.m_ContentLabel2:SetActive(false)
	tBox.m_CompareSpr2:SetActive(false)	
	if list[1] and list[1].str then
		tBox.m_ContentLabel1:SetActive(true)
		tBox.m_ContentLabel1:SetText(list[1].str)

		if list[1].isUp ~= nil then
			tBox.m_CompareSpr1:SetActive(true)
			if list[1].isUp then
				tBox.m_CompareSpr1:SetSpriteName("pic_tisheng")
			else
				tBox.m_CompareSpr1:SetSpriteName("pic_xiajiang")
			end
			tBox.m_Box1:SimulateOnEnable()
		end		
	end

	if list[2] and list[2].str then
		tBox.m_ContentLabel2:SetActive(true)
		tBox.m_ContentLabel2:SetText(list[2].str)

		if list[2].isUp ~= nil then
			tBox.m_CompareSpr2:SetActive(true)
			if list[2].isUp then
				tBox.m_CompareSpr2:SetSpriteName("pic_tisheng")
			else
				tBox.m_CompareSpr2:SetSpriteName("pic_xiajiang")
			end
			tBox.m_Box2:SimulateOnEnable()
		end		
	end

	oTable:AddChild(tBox)
end

function CItemTipsAttrEquipChangeView.AddContentSEBox(self, text, oTable)
	local tBox = self.m_SEClone:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel = tBox:NewUI(1, CLabel):SetText(text)
	oTable:AddChild(tBox)
end

function CItemTipsAttrEquipChangeView.AdjustHeight(self, oBox, oTable )
	oTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(oTable.m_Transform)
	oBox:SetHeight( oBox.m_OrgHeight + bounds.max.y - bounds.min.y)
end

function CItemTipsAttrEquipChangeView.RefreshEquipGird(self)
	local size = (#self.m_EquipItemList > 5) and #self.m_EquipItemList or 5
	for i = 1, size do
		local oBox = self.m_EquipBox:Clone()
		oBox.m_Widget = oBox:NewUI(1, CBox)
		oBox.m_ItemSprite = oBox:NewUI(2, CSprite)
		oBox.m_QualitySprite = oBox:NewUI(3, CSprite)
		oBox.m_ItemNameLabel = oBox:NewUI(4, CLabel)
		oBox.m_SelectedSpr = oBox:NewUI(5, CSprite)
		oBox.m_UpSprite = oBox:NewUI(6, CSprite)
		oBox.m_DownSprite = oBox:NewUI(7, CSprite)
		oBox.m_SelNamlLabel = oBox:NewUI(8, CLabel)
		oBox.m_SelScoreLabel = oBox:NewUI(9, CLabel)
		oBox.m_Widget = oBox:NewUI(10, CBox)
		oBox.m_ScoreLabel = oBox:NewUI(11, CLabel)
		oBox:SetActive(true)
		local oItem = self.m_EquipItemList[i] 		
		oBox.m_UpSprite:SetActive(false)
		oBox.m_DownSprite:SetActive(false)
		if oItem then
			oBox.m_ItemSprite:SpriteItemShape(oItem:GetValue("icon"))
			oBox.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
			oBox.m_ItemNameLabel:SetText(oItem:GetValue("name"))
			oBox.m_SelNamlLabel:SetText(oItem:GetValue("name"))
			oBox.m_ScoreLabel:SetText(string.format("评分: %d", oItem:GetEquipBaseScore()))
			oBox.m_SelScoreLabel:SetText(string.format("评分: %d", oItem:GetEquipBaseScore()))
			oBox:AddUIEvent("click", callback(self, "OnClickEquipListItem", oItem))			
			oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
			oBox.m_SelectedSpr:SetActive(true)
			oBox:SetSelected(i == 1)			
			local pos = oItem:GetValue("pos")
			local score = oItem:GetEquipBaseScore()
			local equip = g_ItemCtrl:GetEquipedByPos(pos)
			local equipedScore = equip:GetEquipBaseScore()

			if score > equipedScore then
				oBox.m_UpSprite:SetActive(true)
			elseif score < equipedScore then
				oBox.m_DownSprite:SetActive(true)
			end
			oBox.m_Widget:SimulateOnEnable()
		else
			oBox.m_SelectedSpr:SetActive(false)
			oBox.m_ItemSprite:SetActive(false)
			oBox.m_QualitySprite:SetActive(false)
			oBox.m_ItemNameLabel:SetActive(false)
			oBox.m_ScoreLabel:SetActive(false)
		end
		self.m_EquipGrid:AddChild(oBox)
	end
end

function CItemTipsAttrEquipChangeView.OnClickEquipListItem(self, oItem)
	self.m_SelectItem = oItem
	self:InitBox(oItem, self.m_TargetUI)	
end

function CItemTipsAttrEquipChangeView.OnCtrlItemlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then	
		local count = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
		--如果点击了更换装备，则关闭该画面
		if self.m_IsClickChange == true and count == 0 then
			self:CloseView()
		end
		self:RefreshLockInfo()	
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		self:RefreshLockInfo()	

	end
end

function CItemTipsAttrEquipChangeView.SortAttr(self, attrs)
	local t = {}
	for _k, _v in ipairs(define.Attr.AttrKey) do 
		for k,v in pairs(attrs) do
			if define.Attr.String[v.key] ~= nil and _v == v.key then			
				local d = {key = v.key, value = v.value}
				table.insert(t, d)		
			end
		end
	end
	return t
end

function CItemTipsAttrEquipChangeView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CItemTipsAttrEquipChangeView.OnMaskClose(self)
	self:CloseView()
end


function CItemTipsAttrEquipChangeView.OnSwitchLockUnEquip(self)
	if self.m_SelectItem then
		g_ItemCtrl:SwitchEquipLock(self.m_SelectItem)	
	end
end

function CItemTipsAttrEquipChangeView.OnSwitchLockEquiped(self)
	g_ItemCtrl:SwitchEquipLock(g_ItemCtrl:GetEquipedByPos(self.m_BaseItem:GetValue("pos")))	
end

function CItemTipsAttrEquipChangeView.RefreshLockInfo(self)
	if not self.m_SelectItem then
		return
	end

	if self.m_Type == CItemTipsAttrEquipChangeView.enum.Composite then
		self.m_TargetLockBtn:SetActive(false)
		return
	else
		self.m_TargetLockBtn:SetActive(true)
	end

	local id = self.m_SelectItem:GetValue("id")
	local oItem = g_ItemCtrl:GetItem(id)
	if oItem then
		self.m_SelectItem = oItem
	end
	local function LockSprite(b)
		if b then
			return "btn_shangsuo_zhuangtai"
		else
			return "btn_shangsuo_zhuangtai2"
		end
	end
	local unEquipLock = self.m_SelectItem:IsEuqipLock()
	self.m_TargetLockBtn:SetSpriteName(LockSprite(unEquipLock))

	local equipedData = g_ItemCtrl:GetEquipedByPos(self.m_SelectItem:GetValue("pos"))
	if equipedData then
		local equipedLock = equipedData:IsEuqipLock()
		self.m_BaseLockBtn:SetSpriteName(LockSprite(equipedLock))
	end
end

return CItemTipsAttrEquipChangeView