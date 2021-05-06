-----------------------------------------------------------------------------
--装备的替换显示界面


-----------------------------------------------------------------------------

local CItemTipsEquipChangeView = class("CItemTipsEquipChangeView", CViewBase)

CItemTipsEquipChangeView.enum =
{
	ChangeInfo = 1,	--装备对比信息
	SellInfo = 2	--出售信息
}

CItemTipsEquipChangeView.EnumPopup = 
{
	Equip  = { Enum = 1, String = "更换", Key = "change"},
	Get  = { Enum = 2, String = "获取", Key = "get"},	
	Sell = { Enum = 3, String = "出售", Key = "sell"},	
	Strength = { Enum = 4, String = "突破", Key = "strength"},
}

function CItemTipsEquipChangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsEquipChangeView.prefab", cb)
	self.m_DepthType = "Dialog"

	self.m_Type = nil
	self.m_OwnerView = nil 
end

function CItemTipsEquipChangeView.OnCreateView(self)
	self.m_ItemInfo = nil
	self.m_UnEquipBox = self:NewUI(1, CBox)
	self.m_EquipedBox = self:NewUI(2, CBox)
	self.m_AttrContentCloneBox = self:NewUI(3, CBox)
	self.m_AttrTitleCloneBox = self:NewUI(4, CBox)
	self.m_UnEquipNameLabel = self:NewUI(5, CLabel)
	self.m_UnEquipTable = self:NewUI(6, CTable)
	self.m_EquipBtn = self:NewUI(7, CButton)
	self.m_UnconfirmBtn = self:NewUI(8, CButton)
	self.m_MorePopupBox = self:NewUI(9, CPopupBox, true, CPopupBox.EnumMode.NoneSelectedMode, nil, true)
	self.m_EquipedNameLabel = self:NewUI(10, CLabel)
	self.m_EquipedTable = self:NewUI(11, CTable)
	self.m_UnEquipIconSprite = self:NewUI(12, CSprite)
	self.m_EquipedIconSprite = self:NewUI(13, CSprite)
	self.m_EquipBtnLabel = self:NewUI(14, CLabel)
	self.m_UnconfirmBtnLabel = self:NewUI(15, CLabel)
	self.m_PopupMainLabel = self:NewUI(16, CLabel)
	self.m_UnEquipQulitySprite = self:NewUI(17, CSprite)
	self.m_EquipQulitySprite = self:NewUI(18, CSprite)
	self.m_MaskGrid = self:NewUI(19, CGrid)
	self.m_UnEquipBtnGroup = self:NewUI(20, CBox)
	self.m_EquipInfoGroup = self:NewUI(21, CBox)
	self.m_ListGroup = self:NewUI(22, CBox)
	self.m_MaskBox = self:NewUI(23, CBox)
	self.m_EquipBtnGorup = self:NewUI(24, CBox)
	self.m_CloseBtn = self:NewUI(25, CButton)
	self.m_UnEquipInfoLabel = self:NewUI(26, CLabel)
	self.m_UnEquipAttrBgSpr = self:NewUI(27, CSprite)
	self.m_EquipedInfoLabel = self:NewUI(28, CLabel)
	self.m_EquipedAttrBgSpr = self:NewUI(29, CSprite)
	self.m_UnEquipLockBtn = self:NewUI(30, CButton)
	self.m_EquipedLockBtn = self:NewUI(31, CButton)
	self.m_AttrContentCloneSEBox = self:NewUI(32, CBox)
	self.m_PopupList = {}
	self.m_IsEuqiped = false
	self.m_IsClickSell = false
	self.m_IsClickChange = false
	self.m_EquipItemList = nil

	CItemTipsEquipChangeView.SellItemLevelConfirm =  define.Item.Quality.Blue --大于这个品质的，出售带提示
	self:InitContent()
end

function CItemTipsEquipChangeView.InitContent(self)
	UITools.ResizeToRootSize(self.m_MaskGrid)
	self.m_MaskGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnMaskClose"))
		return oBox
	end)

	self.m_UnEquipBox.m_OriHeight = self.m_UnEquipBox:GetHeight()
	self.m_UnEquipBox.m_OriLocalPos = self.m_UnEquipBox:GetLocalPos()
	self.m_EquipedBox.m_OriHeight = self.m_EquipedBox:GetHeight()
	self.m_UnEquipAttrBgSpr.m_OriHeight = self.m_UnEquipAttrBgSpr:GetHeight()
	self.m_EquipedAttrBgSpr.m_OriHeight = self.m_EquipedAttrBgSpr:GetHeight()
	
	self.m_EquipedBox:SetActive(false)
	self.m_AttrContentCloneBox:SetActive(false)
	self.m_AttrTitleCloneBox:SetActive(false)
	self.m_AttrContentCloneSEBox:SetActive(false)
	self.m_CloseBtn:SetActive(false)
	self.m_MaskBox:SetActive(false)
	self.m_ListGroup:SetActive(false)
	self.m_MaskBox:AddUIEvent("click", callback(self, "OnMaskClose"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "OnClick", "change"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_UnEquipLockBtn:AddUIEvent("click", callback(self, "OnSwitchLockUnEquip"))
	self.m_EquipedLockBtn:AddUIEvent("click", callback(self, "OnSwitchLockEquiped"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
end

function CItemTipsEquipChangeView.AdjustHeight(self, oTable, oGroupBox, oBgSpr)
	oTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(oTable.m_Transform)
	oGroupBox:SetHeight( oGroupBox.m_OriHeight + bounds.max.y - bounds.min.y)
	oBgSpr:SetHeight(oBgSpr.m_OriHeight + bounds.max.y - bounds.min.y)
end

function CItemTipsEquipChangeView.SetContent( self, type, tItem, list, bShowMaskWidget)
	self.m_Type = type or CItemTipsEquipChangeView.enum.ChangeInfo
	self:SetInitBox(tItem)
	if list and #list > 0 then
		self.m_EquipItemList = list
		self.m_ListGroup:SetActive(true)		
		self.m_EquipInfoGroup:SetLocalPos(Vector3.New(0, -70, 0))
		self:InitEquipListBox()
		self.m_MaskBox:SetActive(true)
		--self.m_CloseBtn:SetActive(true)--暂时隐藏
		self.m_UnconfirmBtn:SetActive(false)
		self.m_MorePopupBox:SetActive(false)
	else
		self.m_MaskBox:SetActive(bShowMaskWidget)
	end
end

function CItemTipsEquipChangeView.SetInitBox( self, tItem)
	if not tItem then
		return
	end
	self.m_ItemInfo = tItem
	local pos = tItem:GetValue("pos")
 	local equipedData = g_ItemCtrl:GetEquipedByPos(pos)
	local tKey = {} 	
 	local tAttr = {}

 	--已装备属性展示开始
 	if equipedData ~= nil then
 		self.m_IsEuqiped = true
	 	self.m_EquipedBox:SetActive(true)
	 	self.m_EquipedNameLabel:SetText(equipedData:GetValue("name"))
	 	self.m_EquipedTable:Clear()
		self.m_EquipedIconSprite:SpriteItemShape(equipedData:GetValue("icon"))	
		self.m_EquipedIconSprite:SetActive(true)	
		self.m_EquipQulitySprite:SetItemQuality(equipedData:GetValue("itemlevel"))	 	
		local equipstr = "[654A33]类型:"..define.Equip.PosName[equipedData:GetValue("pos")]
		equipstr = equipstr .. "\n" .. "等级:"..equipedData:GetValue("equip_level")
		if equipedData:GetEquipFitInfo() ~= "" then
			equipstr = equipstr .. "\n" .."[159a80]适用:"..equipedData:GetEquipFitInfo()
		end
		self.m_EquipedInfoLabel :SetText(equipstr)
		if equipedData:GetEquipScore() ~= "" then
			self:AddContentBox("[629617]评分:"..equipedData:GetEquipScore(), self.m_EquipedTable ) 
		end		
		local tEquiped = equipedData:GetEquipAttrBase() or {}
		tEquiped = self:SortAttr(tEquiped)
		for _,v in pairs (tEquiped) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
				local sKey = define.Attr.String[v.key] or v.key
				local str = sKey.."+"..g_ItemCtrl:AttrStringConvert(v.key, v.value)
				--缓存已装备属性值	
				tAttr[v.key] = tAttr[v.key] or {}
				tAttr[v.key].from = v.value
				self:InserKey(tKey, v.key)
				self:AddContentBox("[81654D]"..str, self.m_EquipedTable)
			end
		end

		if equipedData:GetEquipSEString() ~= "无" then
			self:AddTitleBox("装备效果", self.m_EquipedTable)
			self:AddContentSEBox("[629617]"..equipedData:GetEquipSEString(), self.m_EquipedTable)			
		end
		
		self:AdjustHeight(self.m_EquipedTable, self.m_EquipedBox, self.m_EquipedAttrBgSpr)
 	end
 	--已装备属性展示结束
 	--选中的装备属性展示开始
 	self.m_UnEquipNameLabel:SetText(tItem:GetValue("name"))
 	self.m_UnEquipTable:Clear()
 	self.m_UnEquipIconSprite:SpriteItemShape(tItem:GetValue("icon"))
	self.m_UnEquipIconSprite:SetActive(true) 			
	self.m_UnEquipQulitySprite:SetItemQuality(tItem:GetValue("itemlevel"))	 	
	local unEquipstr = "[654A33]类型:"..define.Equip.PosName[tItem:GetValue("pos")]
	unEquipstr = unEquipstr .. "\n" .. "等级:"..tItem:GetValue("level")
	if tItem:GetEquipFitInfo() ~= "" then
		unEquipstr = unEquipstr .. "\n" .."[159a80]适用:"..tItem:GetEquipFitInfo()
	end
	self.m_UnEquipInfoLabel:SetText(unEquipstr)
	local tUnEquip = tItem:GetEquipAttrBase() or {}
	if tItem:GetEquipScore() ~= "" then
		self:AddContentBox("[629617]评分:"..tItem:GetEquipScore(), self.m_UnEquipTable ) 
	end	
	tUnEquip = self:SortAttr(tUnEquip)
	for _,v in pairs (tUnEquip) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			local sKey = define.Attr.String[v.key] or v.key
			local str = sKey.."+"..g_ItemCtrl:AttrStringConvert(v.key, v.value)
			--缓存选中装备属性值	
			tAttr[v.key] = tAttr[v.key] or {}
			tAttr[v.key].to = v.value
			self:InserKey(tKey, v.key)	
			--该属性，是否是人物属性（装备特技、特效不显示差值变化）
			local isAttr = g_AttrCtrl:IsAttrKey(v.key)
			--是变高还是变低（相等属性，不显示差值变化）
			local isUp = nil
			local changeValue = 0
			if isAttr == true then
				if tAttr[v.key].from == nil then
					isUp = true
					changeValue = tAttr[v.key].to
				else
					-- --如果百分比的属性之前差距 小于 0.1% 则表示相同
					if v.key and (string.find(v.key, "ratio") or v.key == "critical_damage" ) then
						tAttr[v.key].from = math.floor(tAttr[v.key].from / 10 ) * 10
						tAttr[v.key].to = math.floor(tAttr[v.key].to / 10 ) * 10
					end
					
					if tAttr[v.key].from > tAttr[v.key].to then
						isUp = false
						changeValue = tAttr[v.key].from - tAttr[v.key].to
					elseif tAttr[v.key].from < tAttr[v.key].to then
						isUp = true
						changeValue = tAttr[v.key].to - tAttr[v.key].from
					end
				end	
			end
			local changeStr = g_ItemCtrl:AttrStringConvert(v.key, changeValue)

			--如果是预览信息，则不显示对比信息
			if self.m_Type == CItemTipsEquipChangeView.enum.SellInfo then
				isUp = nil
				self.m_UnEquipLockBtn:SetActive(false)
			else
				self.m_UnEquipLockBtn:SetActive(true)
			end

			self:AddContentBox("[81654D]"..str, self.m_UnEquipTable, isUp, changeStr)				
		end	
	end
	if tItem:GetEquipSEString() ~= "无" then
		self:AddTitleBox("装备效果", self.m_UnEquipTable)
		self:AddContentSEBox("[629617]"..tItem:GetEquipSEString(), self.m_UnEquipTable)	
	end
			
	self:AdjustHeight(self.m_UnEquipTable, self.m_UnEquipBox, self.m_UnEquipAttrBgSpr)

 	--选中的装备属性展示结束
 	self:RefreshLockInfo()
 	self:RefreshButtonState() 	
 	self:ResetTypeView()

end

function CItemTipsEquipChangeView.AddTitleBox(self, text, oTable)
	local oBox = self.m_AttrTitleCloneBox:Clone()
	oBox:SetActive(true)
	oBox.m_TitleLabel = oBox:NewUI(1, CLabel):SetText(text)
	oTable:AddChild(oBox)
end

function CItemTipsEquipChangeView.AddContentBox(self, text , oTable, isUp, value)
	local oBox = self.m_AttrContentCloneBox:Clone()
	oBox:SetActive(true)
	oBox.m_ContentLabel = oBox:NewUI(1, CLabel):SetText(text)
	oBox.m_UpBox = oBox:NewUI(2, CWidget)
	oBox.m_UpLabel = oBox:NewUI(3, CLabel)
	oBox.m_DownBox = oBox:NewUI(4, CWidget)
	oBox.m_DownLabel = oBox:NewUI(5, CLabel)
	oBox.m_UpBox:SetActive(false)
	oBox.m_DownBox:SetActive(false)
	if isUp == true then
		oBox.m_UpBox:SetActive(true)
		oBox.m_UpLabel:SetText(string.format("[297c00](%s)", value))
	elseif isUp == false then
		oBox.m_DownBox:SetActive(true)
		oBox.m_DownLabel:SetText(string.format("[ff0000](%s)", value))
	end	
	oTable:AddChild(oBox)
end

function CItemTipsEquipChangeView.AddContentSEBox(self, text, oTable)
	local oBox = self.m_AttrContentCloneSEBox:Clone()
	oBox:SetActive(true)
	oBox.m_ContentLabel = oBox:NewUI(1, CLabel):SetText(text)
	oTable:AddChild(oBox)
end

function CItemTipsEquipChangeView.RefreshButtonState(self)
	self.m_PopupList = {}
	if self.m_IsEuqiped == true then
		self.m_EquipBtnLabel:SetText("更换")
	else
		self.m_EquipBtnLabel:SetText("穿戴")
	end		
	--目前所有装备都有获取途径
	--table.insert(self.m_PopupList, CItemTipsEquipChangeView.EnumPopup.Get)
	if self.m_ItemInfo:GetValue("sale_price") ~= 0 then
		table.insert(self.m_PopupList, CItemTipsEquipChangeView.EnumPopup.Sell)	
	end
	self.m_UnconfirmBtn:SetActive(false)
	self.m_MorePopupBox:SetActive(false)	
	if #self.m_PopupList == 1 then
		self.m_UnconfirmBtn:SetActive(true)
		self.m_UnconfirmBtnLabel:SetText(self.m_PopupList[1].String)
		self.m_UnconfirmBtn:AddUIEvent("click", callback(self, "OnClick", self.m_PopupList[1].Key ))
	elseif #self.m_PopupList > 1 then
		self.m_MorePopupBox:SetActive(true)
		self.m_MorePopupBox:SetCallback(callback(self, "OnMoreClick"))
		for i = 1, #self.m_PopupList  do
			self.m_MorePopupBox:AddSubMenu(self.m_PopupList[i].String)
		end	
	end	

	if self.m_EquipItemList then
		self.m_UnconfirmBtn:SetActive(false)
		self.m_MorePopupBox:SetActive(false)
	end
		
	self:ResetBtnGroupPosition()
end

function CItemTipsEquipChangeView.OnClick(self, sKey)
	local sale_price = self.m_ItemInfo:GetValue("sale_price")
	local id = self.m_ItemInfo:GetValue("id")
	local count = self.m_ItemInfo:GetValue("amount")
	local equipLevel = self.m_ItemInfo:GetValue("level")
	local pos = self.m_ItemInfo:GetValue("pos")
	local itemLevel = self.m_ItemInfo:GetValue("itemlevel")

	if sKey == "change" then
		if equipLevel > g_AttrCtrl.grade then
			g_NotifyCtrl:FloatMsg("无法装备比角色等级高的装备")	
		else
			self.m_IsClickChange = true
			g_ItemCtrl:C2GSPromoteEquipLevel(pos, id)
		end

	elseif sKey	== "get" then
		g_NotifyCtrl:FloatMsg("获取路径...")

	elseif sKey == "sell" then
		--价格大于0，才能出售
		if sale_price > 0 then
			local oView = CItemBagMainView:GetView()
			if oView and oView.m_SellInfoPart and oView.m_SellInfoPart.ShowSellInfoWidget then
				oView.m_SellInfoPart:ShowSellInfoWidget(self.m_ItemInfo:GetValue("id"))
				self:CloseView()
			end				
			--如果数目为1，直接卖出,否则弹出批量出售窗口(一般数目都是为1，装备不可重叠)
			-- if count == 1 then		
			-- 	--高品质的装备出售要有提示
			-- 	if itemLevel > CItemTipsEquipChangeView.SellItemLevelConfirm then
			-- 		local windowConfirmInfo = {
			-- 			msg				= "该装备品质过高，确定要出售么？",
			-- 			title			= "提示",
			-- 			okCallback		= callback(self, "SellConfirm"),						
			-- 		}
			-- 		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			-- 	else
			-- 		self:SellConfirm()
			-- 	end				
			-- else
			-- 	g_WindowTipCtrl:SetWindowItemTipsSellItem(self.m_ItemInfo,
			-- 		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
			-- end			
		else
			g_NotifyCtrl:FloatMsg("该装备不可出售")
		end

	elseif sKey == "strength" then
		--切换画面操作，返回true表示，会关闭打开 tips 的父页面
		if g_ItemCtrl:ItemUseSwitchTo(self.m_ItemInfo, "forge_strength") == true then
			local oView = self.m_OwnerView
			if oView ~= nil then
				--如果是在背包页面切换画面，关闭背包页面
				if oView.classname == "CItemBagMainView" then
					oView:CloseView()
				end
			end
		end
		self:CloseView()

	end
end

function CItemTipsEquipChangeView.OnMoreClick(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local clickType = self.m_MorePopupBox:GetSelectedIndex()
	if self.m_PopupList[clickType].String == "出售" then
		self:OnClick("sell")	
	elseif self.m_PopupList[clickType].String == "获取" then
		self:OnClick("get")	
	elseif self.m_PopupList[clickType].String == "更换" then		
		self:OnClick("change")	
	elseif self.m_PopupList[clickType].String == "突破" then		
		self:OnClick("strength")			
	end
end

function CItemTipsEquipChangeView.OnCtrlItemlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
	oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		self:RefreshLockInfo()	

	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self:RefreshLockInfo()	
		local count = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
		--如果点击了出售装备时，则关闭该画面
		if self.m_IsClickSell == true and count == 0 then
			self:CloseView()

		--如果点击了更换装备，则关闭该画面
		elseif self.m_IsClickChange == true and count == 0 then
			self:CloseView()
		end
	end
end

function CItemTipsEquipChangeView.InserKey( self, t, key)
	for k, v in pairs(t) do
		if v == key then
			return 
		end
	end
	table.insert(t, key)
end

function CItemTipsEquipChangeView.SellConfirm(self)
	local id = self.m_ItemInfo:GetValue("id")
	g_ItemCtrl:C2GSRecycleItem(id, 1)
	self.m_IsClickSell = true	
end

function CItemTipsEquipChangeView.SortAttr( self, tData)
	local t = {}
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(tData) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 and _v == v.key then
				table.insert(t,v)
			end
		end
	end
	return t
end

function CItemTipsEquipChangeView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CItemTipsEquipChangeView.OnMaskClose(self)
	self:CloseView()
end

function CItemTipsEquipChangeView.ResetBtnGroupPosition(self) 
	local h1 = self.m_UnEquipBox:GetLocalPos().y - self.m_UnEquipBox:GetHeight() + 50
	self.m_UnEquipBtnGroup:SetLocalPos(Vector3.New(self.m_UnEquipBtnGroup:GetLocalPos().x, h1, 0))

	local h2 = self.m_EquipedBox:GetLocalPos().y - self.m_EquipedBox:GetHeight() - 120
	self.m_EquipBtnGorup:SetLocalPos(Vector3.New(self.m_EquipBtnGorup:GetLocalPos().x, h2, 0))
end

function CItemTipsEquipChangeView.ResetTypeView(self)
	if self.m_Type == CItemTipsEquipChangeView.enum.SellInfo then
		self.m_EquipedBox:SetActive(false)
		self.m_UnEquipBox:SetLocalPos(Vector3.New(0, self.m_UnEquipBox.m_OriLocalPos.y, self.m_UnEquipBox.m_OriLocalPos.z))
		self.m_UnEquipBtnGroup:SetActive(false)
	else
		self.m_EquipedBox:SetActive(true)		
		self.m_UnEquipBox:SetLocalPos(self.m_UnEquipBox.m_OriLocalPos)
		self.m_UnEquipBtnGroup:SetActive(true)
	end
end

function CItemTipsEquipChangeView.InitEquipListBox(self)
	self.m_ListGroup.m_EquipGrid = self.m_ListGroup:NewUI(1, CGrid)
	self.m_ListGroup.m_EquipBox = self.m_ListGroup:NewUI(2, CBox)
	self.m_ListGroup.m_EquipBox:SetActive(false)

	self:RefreshEquipGird()
end

function CItemTipsEquipChangeView.RefreshEquipGird(self)
	local size = (#self.m_EquipItemList > 5) and #self.m_EquipItemList or 5
	for i = 1, size do
		local oBox = self.m_ListGroup.m_EquipBox:Clone()
		oBox.m_Widget = oBox:NewUI(1, CBox)
		oBox.m_ItemSprite = oBox:NewUI(2, CSprite)
		oBox.m_QualitySprite = oBox:NewUI(3, CSprite)
		oBox.m_ItemNameLabel = oBox:NewUI(4, CLabel)
		oBox.m_SelectedSpr = oBox:NewUI(5, CSprite)
		oBox.m_UpSprite = oBox:NewUI(6, CSprite)
		oBox.m_DownSprite = oBox:NewUI(7, CSprite)
		oBox:SetActive(true)
		local oItem = self.m_EquipItemList[i] 		
		oBox.m_UpSprite:SetActive(false)
		oBox.m_DownSprite:SetActive(false)
		if oItem then
			oBox.m_ItemSprite:SpriteItemShape(oItem:GetValue("icon"))
			oBox.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
			oBox.m_ItemNameLabel:SetText(oItem:GetValue("name"))
			oBox:AddUIEvent("click", callback(self, "OnClickEquipListItem", oItem))			
			oBox:SetGroup(self.m_ListGroup.m_EquipGrid:GetInstanceID())
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
		else
			oBox.m_SelectedSpr:SetActive(false)
			oBox.m_ItemSprite:SetActive(false)
			oBox.m_QualitySprite:SetActive(false)
			oBox.m_ItemNameLabel:SetActive(false)
		end
		self.m_ListGroup.m_EquipGrid:AddChild(oBox)
	end
end

function CItemTipsEquipChangeView.OnClickEquipListItem(self, oItem)
	if oItem ~= self.m_ItemInfo then
		self:SetInitBox(oItem)
	end
end

function CItemTipsEquipChangeView.RefreshLockInfo(self)
	if not self.m_ItemInfo then
		return
	end
	local id = self.m_ItemInfo:GetValue("id")
	local oItem = g_ItemCtrl:GetItem(id)
	if oItem then
		self.m_ItemInfo = oItem
	end
	local function LockSprite(b)
		if b then
			return "btn_shangsuo_zhuangtai"
		else
			return "btn_shangsuo_zhuangtai2"
		end
	end
	local unEquipLock = self.m_ItemInfo:IsEuqipLock()
	self.m_UnEquipLockBtn:SetSpriteName(LockSprite(unEquipLock))

	local equipedData = g_ItemCtrl:GetEquipedByPos(self.m_ItemInfo:GetValue("pos"))
	if equipedData then
		local equipedLock = equipedData:IsEuqipLock()
		self.m_EquipedLockBtn:SetSpriteName(LockSprite(equipedLock))
	end
end

function CItemTipsEquipChangeView.OnSwitchLockUnEquip(self)
	g_ItemCtrl:SwitchEquipLock(self.m_ItemInfo)	
end

function CItemTipsEquipChangeView.OnSwitchLockEquiped(self)
	g_ItemCtrl:SwitchEquipLock(g_ItemCtrl:GetEquipedByPos(self.m_ItemInfo:GetValue("pos")))	
end

return CItemTipsEquipChangeView