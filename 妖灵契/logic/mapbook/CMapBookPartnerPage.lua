local CMapBookPartnerPage = class("CMapBookPartnerPage", CPageBase)

function CMapBookPartnerPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookPartnerPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_Texture = self:NewUI(2, CTexture)
	self.m_WrapContent = self:NewUI(3, CWrapContent)
	self.m_WrapObj = self:NewUI(4, CBox)
	self.m_NoGetSpr = self:NewUI(5, CSprite)
	self.m_PartnerBookBtn = self:NewUI(6, CButton)
	self.m_BGTexture = self:NewUI(7, CSprite)
	self.m_ScrollView = self:NewUI(8, CScrollView)
	self.m_NameLabel = self:NewUI(9, CLabel)
	self.m_SkillGrid = self:NewUI(10, CGrid)
	self.m_SkillBox = self:NewUI(11, CBox)
	self.m_PhotoBtn = self:NewUI(12, CButton)
	self.m_MainPart = self:NewUI(13, CObject)
	self.m_TopPart = self:NewUI(14, CObject)
	self.m_PopupBox = self:NewUI(15, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_NoGetSpr:SetActive(false)
	self.m_SkillBox:SetActive(false)
	self.m_WrapObj:SetActive(false)
	self.m_PhotoBtn:SetActive(false)
	self:InitWrapContent()
	self.m_CurParid = nil
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_PhotoBtn:AddUIEvent("click", callback(self, "ShowPhotoPage"))
	self.m_Texture:AddUIEvent("click", callback(self, "OnShowFullTexture"))
	self.m_BGTexture:AddUIEvent("click", callback(self, "OnShowFullTexture"))
	self.m_PartnerBookBtn:AddUIEvent("click", callback(self, "ShowPartnerBook"))
	g_GuideCtrl:AddGuideUI("mapbook_partner_Photo_tab", self.m_PartnerBookBtn)
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookEvent"))
	
	self.m_PopupBox:Clear()
	self.m_PopupBox:SetCallback(callback(self, "OnSortChange"))
	local sortlist = {"精英", "传说", "全部"}
	
	for k, v in ipairs(sortlist) do
		self.m_PopupBox:AddSubMenu(v)
	end

	self:RefreshAll()
end

function CMapBookPartnerPage.InitWrapContent(self)
	self.m_WrapContent:SetCloneChild(self.m_WrapObj, 
		function(oChild)
			oChild.m_IconList = {}
			for i = 1, 3 do
				local box = oChild:NewUI(i, CBox)
				box.m_Texture = box:NewUI(1, CTexture)
				box:SetActive(false)
				table.insert(oChild.m_IconList, box)
			end
			return oChild
		end)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			oChild:SetActive(true)
			for i = 1, 3 do
				local box = oChild.m_IconList[i]
				if dData[i] then
					box:SetActive(true)
					box.m_ID = dData[i].partner_type
					box.m_Texture:LoadCardPhoto(dData[i]["icon"])
					if self:IsGetPartner(dData[i].partner_type) then
						box.m_Texture:SetColor(Utils.HexToColor("ffffffff"))
					else
						box.m_Texture:SetColor(Utils.HexToColor("464646ff"))
					end
					box:AddUIEvent("click", callback(self, "OnClickPartner", dData[i].partner_type))
				else
					box.m_ID = nil
					box:SetActive(false)
				end
			end
		else
			oChild:SetActive(false)
		end
	end)
end

function CMapBookPartnerPage.OnShowPage(self)
	if g_MapBookCtrl:IsHasPartnerBookNotify() then
		self.m_PartnerBookBtn:AddEffect("RedDot")
	else
		self.m_PartnerBookBtn:DelEffect("RedDot")
	end
end

function CMapBookPartnerPage.OnMapBookEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdateRedPoint then
		if g_MapBookCtrl:IsHasPartnerBookNotify() then
			self.m_PartnerBookBtn:AddEffect("RedDot")
		else
			self.m_PartnerBookBtn:DelEffect("RedDot")
		end
	end
end

function CMapBookPartnerPage.ShowPartnerPage(self)
	self.m_ParentView:ShowPartnerPage()
	-- body
end

function CMapBookPartnerPage.ShowPartnerBook(self)
	self.m_ParentView:ShowPartnerBookPage()
	-- body
end

function CMapBookPartnerPage.RefreshAll(self, iRare)
	local dividlist, list = self:GetPartnerList(iRare or 0)
	self.m_WrapContent:SetData(dividlist, true)
	self.m_ScrollView:ResetPosition()
	local defaultpartner = list[1].partner_type
	
	if not g_GuideCtrl:IsCustomGuideFinishByKey("MapBook") then
		local index = table.index(list, 302)
		if index then
			defaultpartner = 302
		end
	end
	self:OnClickPartner(defaultpartner)
end

function CMapBookPartnerPage.CreateBox(self)
	local oChild = self.m_IconBox:Clone()
	oChild:SetActive(true)
	oChild.m_Spr = oChild:NewUI(1, CSprite)
	oChild.m_Boder = oChild:NewUI(2, CSprite)
	oChild.m_Label = oChild:NewUI(3, CLabel)
	oChild:SetGroup(self.m_Grid:GetInstanceID())
	return oChild
end

function CMapBookPartnerPage.UpdateBox(self, box, dData)
	box:SetActive(true)
	box.m_Spr:SpriteAvatar(dData["icon"])
	box:AddUIEvent("click", callback(self, "OnClickPartner", dData["partner_type"]))
	box.m_PartnerType = dData["partner_type"]
	if self.m_CurParid == dData["partner_type"] then
		box:ForceSelected(true)
	else
		box:ForceSelected(false)
	end
	g_PartnerCtrl:ChangeRareBorder(box.m_Boder, dData["rare"])
	if self:IsGetPartner(dData["partner_type"]) then
		box.m_Label:SetActive(false)
	else
		box.m_Label:SetActive(true)
	end
end

function CMapBookPartnerPage.GetPartnerList(self, key)
	local list = {}
	for parid, v in pairs(data.partnerdata.DATA) do
		if v["show_type"] == 1 then
			if key == 0 then
				table.insert(list, v)
			else
				if key == v["rare"] then
					table.insert(list, v)
				end
			end
		end
	end
	
	table.sort(list, function(a, b)
		if a["rare"] ~= b["rare"] then
			return a["rare"] > b["rare"]
		end
		if a["partner_type"] < b["partner_type"] then
			return true
		end
		return false
	end)
	
	local newlist = {}
	local dlist = {}
	for i, oPartner in ipairs(list) do
		table.insert(dlist, oPartner)
		if #dlist > 2 then
			table.insert(newlist, dlist)
			dlist = {}
		end
	end
	if #dlist > 0 then
		table.insert(newlist, dlist)
	end
	return newlist, list
end

function CMapBookPartnerPage.OnSortChange(self, oBox)
	local idx = self.m_PopupBox:GetSelectedIndex()
	local t = {1, 2, 0}
	local iRare = t[idx] or 0
	self:RefreshAll(iRare)
end

function CMapBookPartnerPage.RefreshDesc(self, parid)
	local pdata = data.partnerdata.DATA[parid]
	if not pdata then
		return
	end
	self.m_NameLabel:SetText(pdata["name"])
	self:UpdateSkill(parid)
	local k = 1
	if table.index({1753, 1754, 1755}, pdata["shape"]) then 
		k = 1
	end
	
	self.m_Texture:LoadFullPhoto(pdata["shape"], function () 
		self.m_Texture:SnapFullPhoto(pdata["shape"], k)
		self.m_Texture:SetActive(true)
		if self:IsGetPartner(parid) then
			self.m_Texture:SetColor(Utils.HexToColor("ffffffff"))
			self.m_NoGetSpr:SetActive(false)
		else
			self.m_Texture:SetColor(Utils.HexToColor("464646ff"))
			self.m_NoGetSpr:SetActive(true)
		end
	end)
	--self.m_DescLabel:SetText(pdata["desc"])
end

function CMapBookPartnerPage.IsGetPartner(self, parid)
	return g_PartnerCtrl:IsGetPartner(parid) 
end

function CMapBookPartnerPage.OnBack(self)
	self.m_ParentView:ShowMainPage()
end

function CMapBookPartnerPage.OnClickPartner(self, parid)
	self.m_CurParid = parid
	self:RefreshDesc(parid)
end

function CMapBookPartnerPage.DefaultSelect(self, parid)
	self.m_CurParid = parid
	self:OnClickPartner(parid)
	--self.m_WrapContent:MoveRelative(Vector3.New(idx*100, 0, 0))
end

function CMapBookPartnerPage.UpdateSkill(self, iType)
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(self.m_ChipType)
	local pdata = data.partnerdata.DATA[iType]
	self.m_SkillGrid:Clear()
	local skilllist = pdata["skill_list"]
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillid in ipairs(skilllist) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_Icon:SpriteSkill(d[skillid]["icon"])
		box.m_Label:SetText("1")
		box.m_ID = skillid
		box.m_Level = 1
		box.m_IsAwake = false
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CMapBookPartnerPage.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CMapBookPartnerPage.OnShowFullTexture(self)
	if self.m_IsLock then
		return
	end
	if not g_PartnerCtrl:IsGetPartner(self.m_CurParid) then
		return
	end
	if self.m_IsFull then
		self.m_Texture:SetLocalPos(Vector3.New(-3, -28, 0))
		self.m_Texture:SetLocalScale(Vector3.New(1, 1, 1))
		local v = Quaternion.Euler(0, 0, 0)
		self.m_Texture:SetLocalRotation(v)
		self.m_BGTexture:SetActive(false)
		self.m_Texture:SetParent(self.m_MainPart.m_Transform)
		self.m_IsFull = false
	else
		self.m_IsFull = true
		self.m_IsLock = true
		local v = Quaternion.Euler(0, 0, 90)
		local v = Vector3.New(0, 0, 90)
		local t = 1
		local tween1 = DOTween.DOLocalMove(self.m_Texture.m_Transform, Vector3.New(0, 0, 0), t)
		local tween2 = DOTween.DOLocalRotate(self.m_Texture.m_Transform, v, t)
		local tween3 = DOTween.DOScale(self.m_Texture.m_Transform, Vector3.New(2, 2, 2), t)
		DOTween.OnComplete(tween3, function ()
			self.m_IsLock = false
		end)
		self.m_BGTexture:SetActive(true)
		self.m_Texture:SetParent(self.m_BGTexture.m_Transform)
		self.m_Texture:SetActive(false)
		self.m_Texture:SetActive(true)
	end
end

function CMapBookPartnerPage.ShowPhotoPage(self)
	self.m_ParentView:ShowPhotoPage()
end

return CMapBookPartnerPage