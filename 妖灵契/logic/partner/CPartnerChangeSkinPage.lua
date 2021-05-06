local CPartnerChangeSkinPage = class("CPartnerChangeSkinPage", CPageBase)

function CPartnerChangeSkinPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerChangeSkinPage.OnInitPage(self)
	self.m_SkinPart = self:NewUI(1, CBox)
	self.m_FlowerObj = self:NewUI(2, CObject)
	self.m_EmptyTexture = self:NewUI(3, CTexture)
	self.m_Container = self:NewUI(4, CBox)
	self.m_LeftPart = self:NewUI(5, CBox)
	
	self:InitLeft()
	self:InitSkin()
	--self:InitCost()
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerChangeSkinPage.InitLeft(self)
	self.m_ActorTexture = self.m_LeftPart:NewUI(1, CActorTexture)
	self.m_StarBox = self.m_LeftPart:NewUI(2, CBox)
	self.m_PowerLabel = self.m_LeftPart:NewUI(3, CLabel)
	self.m_RareSpr = self.m_LeftPart:NewUI(4, CSprite)
	self.m_SwitchBtn = self.m_LeftPart:NewUI(5, CButton)
	self.m_LeftBtn = self.m_LeftPart:NewUI(6, CButton)
	self.m_RightBtn = self.m_LeftPart:NewUI(7, CButton)

	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", 1))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", -1))
	self.m_SwitchBtn:SetText("皮肤")
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchRight"))
end

function CPartnerChangeSkinPage.InitSkin(self)
	self.m_SkinGrid = self.m_SkinPart:NewUI(1, CGrid)
	self.m_SkinTexture = self.m_SkinPart:NewUI(2, CTexture)
	self.m_ScorllView = self.m_SkinPart:NewUI(3, CScrollView)
	self.m_ChangeBtn = self.m_SkinPart:NewUI(4, CButton)
	self.m_UseLabel = self.m_SkinPart:NewUI(6, CLabel)
	self.m_SkinNameLabel = self.m_SkinPart:NewUI(10, CLabel)
	self.m_SkinBoxArr = {}
	self.m_SkinBoxDic = {}
	self.m_GridX = self.m_SkinGrid:GetLocalPos().x
	self.m_CellWidth, self.m_CellHeight = self.m_SkinGrid:GetCellSize()
	self.m_ChangeBtn:AddUIEvent("click", callback(self, "OnChangeSkin"))
end

function CPartnerChangeSkinPage.InitIcon(self)
	-- self.m_LeftIcon = self.m_IconPart:NewUI(1, CPartnerIconItem)
	-- self.m_RightIcon = self.m_IconPart:NewUI(2, CPartnerIconItem)
end

function CPartnerChangeSkinPage.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerSkin then
		self:UpdateSkinBtn()
	end
end

function CPartnerChangeSkinPage.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner(oCtrl.m_EventData)
		self:UpdateSkinBtn()
	end
end

function CPartnerChangeSkinPage.UpdateView(self)
	if self:GetActive() then
		self:UpdatePartner()
		self:UpdateSkinBtn()
	end
end

function CPartnerChangeSkinPage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
end

function CPartnerChangeSkinPage.UpdatePartner(self, iParID)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	
	if not oPartner then
		self:ShowUI(false)
		return
	else
		self:ShowUI(true)
	end

	self.m_SwitchBtn:SetText("皮肤")
	self.m_SwitchBtn:SetActive(false)
	local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_ActorTexture:ChangeShape(shape, {})
	self.m_PowerLabel:SetText(tostring(oPartner:GetValue("power")))
	self:UpdateStar(oPartner:GetValue("star"))
	if iParID ~= self.m_CurParID then
		self:UpdateSkin()
	end
end

function CPartnerChangeSkinPage.ShowUI(self, bshow)
	self.m_Container:SetActive(bshow)
	self.m_EmptyTexture:SetActive(not bshow)
	self.m_FlowerObj:SetActive(true)
end

function CPartnerChangeSkinPage.ShowNoAwake(self)
	self.m_Container:SetActive(true)
	self.m_LeftPart:SetActive(true)
	self.m_SkinPart:SetActive(false)
	self.m_EmptyTexture:SetActive(true)
	self.m_FlowerObj:SetActive(false)
end

function CPartnerChangeSkinPage.SetNonePartner(self)
	self:ShowUI(false)
end


function CPartnerChangeSkinPage.UpdateSkin(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local ptype = oPartner:GetValue("partner_type")
	local skinlist = g_PartnerCtrl:GetPartnerSkin(ptype)
	local count = 0
	self.m_LastTablePos = nil
	self.m_CurrentCenter = nil
	for i, v in ipairs(skinlist) do
		count = count + 1
		if self.m_SkinBoxArr[count] == nil then
			self.m_SkinBoxArr[count] = self:CreateSkinBox()
		end
		self.m_SkinBoxArr[count]:SetName(tostring(v.id))
		self.m_SkinBoxArr[count].m_ID = v.id
		self.m_SkinBoxDic[v.id] = self.m_SkinBoxArr[count]
		self.m_SkinBoxDic[v.id].m_Shape = v.shape
		self.m_SkinBoxDic[v.id].index = count - 1
		self.m_SkinBoxArr[count]:LoadCardPhoto(v.icon)
		self.m_SkinBoxArr[count]:SetActive(true)
	end

	count = count + 1
	for i = count, #self.m_SkinBoxArr do
		self.m_SkinBoxArr[i]:SetActive(false)
	end
	self.m_SkinTexture:SetActive(false)
	self.m_SkinGrid:Reposition()
	
	self.m_ScorllView:CenterOn(self.m_SkinBoxArr[1].m_Transform)
	
	if self.m_TimerID == nil then
		self.m_TimerID = Utils.AddTimer(callback(self, "UpdateScale"), 0, 0)
	end
end

function CPartnerChangeSkinPage.UpdateStar(self, iStar)
	if not self.m_StarList then
		self.m_StarList = {}
		for i = 1, 5 do
			self.m_StarList[i] = self.m_StarBox:NewUI(i, CSprite)
		end
	end
	
	for i = 1, 5 do
		if iStar >= i then
			self.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
		else
			self.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end

function CPartnerChangeSkinPage.OnClickAwakeItem(self, itemid)
	local itemList = g_ItemCtrl:GetItemIDListBySid(itemid)
	local itemobj = g_ItemCtrl:GetItem(itemList[1]) or CItem.NewBySid(itemid)
	g_WindowTipCtrl:SetWindowItemTipsBaseItemInfo(itemobj)
end

function CPartnerChangeSkinPage.OnConfirm(self)
	local grade = data.globalcontroldata.GLOBAL_CONTROL.partnerawake.open_grade
	if g_AttrCtrl.grade < grade then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", grade))
	else
		netpartner.C2GSAwakePartner(self.m_CurParID)
	end
end

function CPartnerChangeSkinPage.OnSwitchRight(self)
	if self.m_SkinPart:GetActive() then
		self.m_SkinPart:SetActive(false)
		self.m_SwitchBtn:SetText("皮肤")
	else
		self.m_SkinPart:SetActive(true)
		self:UpdateSkinBtn()
		self.m_SwitchBtn:SetText("材料")
	end
end

function CPartnerChangeSkinPage.OnChangeSkin(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if self.m_ChangeBtn:GetText() == "更换" then
		if self.m_ItemID then
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSUsePartnerItem"]) then
				netpartner.C2GSUsePartnerItem(self.m_ItemID, oPartner.m_ID, 1)
			end
		end
	
	elseif self.m_ChangeBtn:GetText() == "购买" then
		g_NpcShopCtrl:OpenShop(define.Store.Page.PartnerSkin)
	
	elseif self.m_ChangeBtn:GetText() == "终身卡赠送" then
		g_OpenUICtrl:OpenYueKa()
	
	elseif self.m_ChangeBtn:GetText() == "前往觉醒" then
		CPartnerImproveView:ShowView(function (oView)
			oView:OnChangePartner(oPartner.m_ID)
			oView:ShowAwakePage()
		end)
	elseif self.m_ChangeBtn:GetText() == "累充获取" then
		g_OpenUICtrl:OpenTotalPay()
	end
end

function CPartnerChangeSkinPage.CreateSkinBox(self)
	local oSkinBox = self.m_SkinTexture:Clone()
	local mList = oSkinBox:GetComponentsInChildren(classtype.UITexture, true)
	
	local mTexture = mList[1]
	if mTexture then
		oSkinBox.m_BGTexture = CTexture.New(mTexture.gameObject)
		if mList[2] then
			oSkinBox.m_BorderTexture = CTexture.New(mList[2].gameObject)
		end
	end
	self.m_SkinGrid:AddChild(oSkinBox)
	return oSkinBox
end

function CPartnerChangeSkinPage.UpdateScale(self)
	if Utils.IsNil(self) then
		return false
	end
	if self:GetActive() == false then
		return true
	end
	local tablePos = self.m_ScorllView:GetLocalPos().x
	if self.m_LastTablePos == tablePos then
		local oChild = self.m_SkinBoxArr[1]
		if oChild and oChild:GetLocalPos().y == 0 then
		else
			return true
		end
	end
	self.m_LastTablePos = tablePos
	local depthflag = false
	for i,v in ipairs(self.m_SkinBoxArr) do
		local pos = v:GetLocalPos()
		local scaleValue = 1 - (math.abs(pos.x + tablePos)) * 0.002
		if scaleValue < 0.5 then
			scaleValue = 0.5
		end
		v:SetLocalScale(Vector3.New(scaleValue, scaleValue, scaleValue))
		local w, h = v:GetSize()
		pos.y = (1 - scaleValue) * h * 0.75
		v:SetLocalPos(pos)
		if math.abs(scaleValue - 1) < 0.03 then
			depthflag = true
		end
	end
	if depthflag then
		for i,v in ipairs(self.m_SkinBoxArr) do
			local scaleValue = v:GetLocalScale().x
			if math.abs(scaleValue - 1) < 0.03 then
				v:SetDepth(11)
				v.m_BGTexture:SetDepth(10)
				v.m_BorderTexture:SetDepth(12)
			else
				v:SetDepth(8)
				v.m_BGTexture:SetDepth(7)
				v.m_BorderTexture:SetDepth(9)
			end
		end
	end
	self:OnCenter()
	return true
end

function CPartnerChangeSkinPage.OnCenter(self)
	local centerObj = self.m_ScorllView:GetCenteredObject()
	if centerObj == nil or self.m_CurrentCenter == centerObj then
		return
	end
	local itemid = tonumber(centerObj.name)
	local oSkinBox = self.m_SkinBoxDic[itemid]
	self.m_CurrentSkinBox = oSkinBox
	if self.m_CurrentSkinBox == nil then
		return
	end
	self.m_CurrentCenter = centerObj
	self:OnSelectSkin(itemid, oSkinBox.m_Shape)
end

function CPartnerChangeSkinPage.UpdateSkinBtn(self)
	self.m_LastTablePos = nil
	self.m_SkinGrid:Reposition()
	local centerObj = self.m_ScorllView:GetCenteredObject()
	if centerObj == nil then
		return
	end
	local itemid = tonumber(centerObj.name)
	if self.m_CurrentSkinBox == nil then
		return
	end
	self:OnSelectSkin(itemid, self.m_CurrentSkinBox.m_Shape)
end

function CPartnerChangeSkinPage.OnSelectSkin(self, iItemID, iShape)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local itemlist = g_ItemCtrl:GetItemListBySid(iItemID)
	self.m_ItemID = nil
	self.m_ChangeBtn:SetActive(true)
	self.m_UseLabel:SetActive(false)
	local d = DataTools.GetItemData(iItemID)
	
	if iShape == oPartner:GetValue("model_info").shape then
		self.m_UseLabel:SetActive(true)
		self.m_ChangeBtn:SetActive(false)
		self.m_UseLabel:SetText("正在使用")
	elseif #itemlist > 0 then
		if d.skin_type == 3 and oPartner:GetValue("awake") == 0 then
			self.m_UseLabel:SetActive(false)
			self.m_ChangeBtn:SetActive(true)
			self.m_UseLabel:SetText("觉醒后获得")
			self.m_ChangeBtn:SetText("前往觉醒")
		else
			self.m_ItemID = itemlist[1]
			self.m_ChangeBtn:SetText("更换")
		end
	
	elseif d.skin_type == 3 then
		self.m_UseLabel:SetActive(false)
		self.m_ChangeBtn:SetActive(true)
		self.m_UseLabel:SetText("觉醒后获得")
		self.m_ChangeBtn:SetText("前往觉醒")
	
	elseif d.shape == 800 then
		self.m_ChangeBtn:SetText("累充获取")
	else
		self.m_ChangeBtn:SetText("购买")
	end
		
	if d then
		self.m_SkinNameLabel:SetText(d.name)
	end

	self.m_ActorTexture:ChangeShape(iShape, {})
end

function CPartnerChangeSkinPage.OnSwitchPartner(self)
	self.m_ParentView:ShowPartnerScroll()
end

function CPartnerChangeSkinPage.OnLeftOrRightBtn(self, idx)
	local list = g_PartnerCtrl:GetPartnerList()
	table.sort(list, callback(CPartnerMainPage, "PartnerSortFunc"))
	if #list > 1 then
		local curIdx = 1
		for i,oPartner in ipairs(list) do
			if oPartner.m_ID == self.m_CurParID then
				curIdx = i
				break
			end
		end
		curIdx = curIdx + idx
		if curIdx <= 0 then
			curIdx = #list
		elseif curIdx > #list then
			curIdx = 1
		end
		if self.m_ParentView then
			self.m_ParentView:OnChangePartner(list[curIdx].m_ID)
		end
	end
end

return CPartnerChangeSkinPage